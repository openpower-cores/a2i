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

 
library ieee; 
  use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 
library support;
  use support.power_logic_pkg.all;



entity iuq_axu_fu_dep_cmp is

port(
     lm_v                         : in  std_ulogic_vector(0 to 7);
     is1_instr_v                  : in  std_ulogic;
     vdd                                 	: inout power_logic;
     gnd                                 	: inout power_logic;
     lmc_ex4_v                    : in  std_ulogic;
     dis_byp_is1                  : in  std_ulogic;  
     is1_store_v                  : in  std_ulogic;     
     ex3_ld_v                     : in  std_ulogic;
     ex4_ld_v                     : in  std_ulogic;     
     uc_end_is1                   : in  std_ulogic;
     
     is2_frt_v                    : in  std_ulogic;
     rf0_frt_v                    : in  std_ulogic;
     rf1_frt_v                    : in  std_ulogic;
     ex1_frt_v                    : in  std_ulogic;
     ex2_frt_v                    : in  std_ulogic;
     ex3_frt_v                    : in  std_ulogic;
     ex4_frt_v                    : in  std_ulogic;

     
     lm0_ta                       : in  std_ulogic_vector(0 to 5);
     lm1_ta                       : in  std_ulogic_vector(0 to 5);
     lm2_ta                       : in  std_ulogic_vector(0 to 5);
     lm3_ta                       : in  std_ulogic_vector(0 to 5);
     lm4_ta                       : in  std_ulogic_vector(0 to 5);
     lm5_ta                       : in  std_ulogic_vector(0 to 5);
     lm6_ta                       : in  std_ulogic_vector(0 to 5);
     lm7_ta                       : in  std_ulogic_vector(0 to 5);
     lmc_ex4                      : in  std_ulogic_vector(0 to 5);
     ex4_ta                       : in  std_ulogic_vector(0 to 5);
     ex3_ta                       : in  std_ulogic_vector(0 to 5);
     ex2_ta                       : in  std_ulogic_vector(0 to 5);
     ex1_ta                       : in  std_ulogic_vector(0 to 5);
     rf1_ta                       : in  std_ulogic_vector(0 to 5);
     rf0_ta                       : in  std_ulogic_vector(0 to 5);
     is2_ta                       : in  std_ulogic_vector(0 to 5);

     is1_fra_v                    : in  std_ulogic;
     is1_frb_v                    : in  std_ulogic;
     is1_frc_v                    : in  std_ulogic;
     is1_frt_v                    : in  std_ulogic;
     
     is1_fra                      : in  std_ulogic_vector(0 to 5);
     is1_frb                      : in  std_ulogic_vector(0 to 5);
     is1_frc                      : in  std_ulogic_vector(0 to 5);
     is1_ta                       : in  std_ulogic_vector(0 to 5);

     raw_fra_hit_b                  : out std_ulogic;
     raw_frb_hit_b                  : out std_ulogic;
     raw_frc_hit_b                  : out std_ulogic;
     
     raw_frb_uc_hit_b               : out std_ulogic;
     is1_lmq_waw_hit_b              : out std_ulogic
     
     );
 
     
end iuq_axu_fu_dep_cmp;

architecture iuq_axu_fu_dep_cmp of iuq_axu_fu_dep_cmp is

  signal lm0_ta_buf, lm0_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lm1_ta_buf, lm1_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lm2_ta_buf, lm2_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lm3_ta_buf, lm3_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lm4_ta_buf, lm4_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lm5_ta_buf, lm5_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lm6_ta_buf, lm6_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lm7_ta_buf, lm7_ta_buf_b :std_ulogic_vector(0 to 5);
  signal lmc_ex4_buf, lmc_ex4_buf_b :std_ulogic_vector(0 to 5);
  signal ex4_ta_buf, ex4_ta_buf_b :std_ulogic_vector(0 to 5);
  signal ex3_ta_buf, ex3_ta_buf_b :std_ulogic_vector(0 to 5);
  signal ex2_ta_buf, ex2_ta_buf_b :std_ulogic_vector(0 to 5);
  signal ex1_ta_buf, ex1_ta_buf_b :std_ulogic_vector(0 to 5);
  signal rf1_ta_buf, rf1_ta_buf_b :std_ulogic_vector(0 to 5);
  signal rf0_ta_buf, rf0_ta_buf_b :std_ulogic_vector(0 to 5);
  signal is2_ta_buf, is2_ta_buf_b :std_ulogic_vector(0 to 5);


  signal is1_fra_buf1 :std_ulogic_vector(0 to 5);
  signal is1_frb_buf1 :std_ulogic_vector(0 to 5);
  signal is1_frc_buf1 :std_ulogic_vector(0 to 5);
  signal is1_frt_buf1 :std_ulogic_vector(0 to 5);
  signal is1_fra_buf2 :std_ulogic_vector(0 to 5);
  signal is1_frb_buf2 :std_ulogic_vector(0 to 5);
  signal is1_frc_buf2 :std_ulogic_vector(0 to 5);
  signal is1_frt_buf2 :std_ulogic_vector(0 to 5);
  signal is1_fra_buf3 :std_ulogic_vector(0 to 5);
  signal is1_frb_buf3 :std_ulogic_vector(0 to 5);
  signal is1_frc_buf3 :std_ulogic_vector(0 to 5);
  signal is1_frt_buf3 :std_ulogic_vector(0 to 5);
  signal is1_fra_buf4 :std_ulogic_vector(0 to 5);
  signal is1_frb_buf4 :std_ulogic_vector(0 to 5);
  signal is1_frc_buf4 :std_ulogic_vector(0 to 5);
  signal is1_frt_buf4 :std_ulogic_vector(0 to 5);
  signal is1_fra_buf5 :std_ulogic_vector(0 to 5);
  signal is1_frb_buf5 :std_ulogic_vector(0 to 5);
  signal is1_frc_buf5 :std_ulogic_vector(0 to 5);
  signal is1_frt_buf5 :std_ulogic_vector(0 to 5);
  signal is1_fra_buf6 :std_ulogic_vector(0 to 5);
  signal is1_frb_buf6 :std_ulogic_vector(0 to 5);
  signal is1_frc_buf6 :std_ulogic_vector(0 to 5);
  signal is1_frt_buf6 :std_ulogic_vector(0 to 5);



  
  signal is1_fra_buf2_b, is1_fra_buf1_b :std_ulogic_vector(0 to 5);
  signal is1_frb_buf2_b, is1_frb_buf1_b :std_ulogic_vector(0 to 5);
  signal is1_frc_buf2_b, is1_frc_buf1_b :std_ulogic_vector(0 to 5);
  signal is1_frt_buf2_b, is1_frt_buf1_b :std_ulogic_vector(0 to 5);  

  signal a_eq_lm0_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm0_01_b , a_eq_lm0_23_b , a_eq_lm0_45_b  :std_ulogic;
  signal a_eq_lm0_u ,a_eq_lm0_v , a_eq_lm0_b   :std_ulogic;
  signal b_eq_lm0_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm0_01_b , b_eq_lm0_23_b , b_eq_lm0_45_b  :std_ulogic;
  signal b_eq_lm0_u ,b_eq_lm0_v , b_eq_lm0_b   :std_ulogic;
  signal c_eq_lm0_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm0_01_b , c_eq_lm0_23_b , c_eq_lm0_45_b  :std_ulogic;
  signal c_eq_lm0_u ,c_eq_lm0_v , c_eq_lm0_b   :std_ulogic;
  signal t_eq_lm0_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm0_01_b , t_eq_lm0_23_b , t_eq_lm0_45_b  :std_ulogic;
  signal t_eq_lm0_u ,t_eq_lm0_v , t_eq_lm0_b   :std_ulogic;
  signal a_eq_lm1_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm1_01_b , a_eq_lm1_23_b , a_eq_lm1_45_b  :std_ulogic;
  signal a_eq_lm1_u ,a_eq_lm1_v , a_eq_lm1_b   :std_ulogic;
  signal b_eq_lm1_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm1_01_b , b_eq_lm1_23_b , b_eq_lm1_45_b  :std_ulogic;
  signal b_eq_lm1_u ,b_eq_lm1_v , b_eq_lm1_b   :std_ulogic;
  signal c_eq_lm1_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm1_01_b , c_eq_lm1_23_b , c_eq_lm1_45_b  :std_ulogic;
  signal c_eq_lm1_u ,c_eq_lm1_v , c_eq_lm1_b   :std_ulogic;
  signal t_eq_lm1_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm1_01_b , t_eq_lm1_23_b , t_eq_lm1_45_b  :std_ulogic;
  signal t_eq_lm1_u ,t_eq_lm1_v , t_eq_lm1_b   :std_ulogic;
  signal a_eq_lm2_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm2_01_b , a_eq_lm2_23_b , a_eq_lm2_45_b  :std_ulogic;
  signal a_eq_lm2_u ,a_eq_lm2_v , a_eq_lm2_b   :std_ulogic;
  signal b_eq_lm2_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm2_01_b , b_eq_lm2_23_b , b_eq_lm2_45_b  :std_ulogic;
  signal b_eq_lm2_u ,b_eq_lm2_v , b_eq_lm2_b   :std_ulogic;
  signal c_eq_lm2_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm2_01_b , c_eq_lm2_23_b , c_eq_lm2_45_b  :std_ulogic;
  signal c_eq_lm2_u ,c_eq_lm2_v , c_eq_lm2_b   :std_ulogic;
  signal t_eq_lm2_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm2_01_b , t_eq_lm2_23_b , t_eq_lm2_45_b  :std_ulogic;
  signal t_eq_lm2_u ,t_eq_lm2_v , t_eq_lm2_b   :std_ulogic;
  signal a_eq_lm3_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm3_01_b , a_eq_lm3_23_b , a_eq_lm3_45_b  :std_ulogic;
  signal a_eq_lm3_u ,a_eq_lm3_v , a_eq_lm3_b   :std_ulogic;
  signal b_eq_lm3_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm3_01_b , b_eq_lm3_23_b , b_eq_lm3_45_b  :std_ulogic;
  signal b_eq_lm3_u ,b_eq_lm3_v , b_eq_lm3_b   :std_ulogic;
  signal c_eq_lm3_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm3_01_b , c_eq_lm3_23_b , c_eq_lm3_45_b  :std_ulogic;
  signal c_eq_lm3_u ,c_eq_lm3_v , c_eq_lm3_b   :std_ulogic;
  signal t_eq_lm3_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm3_01_b , t_eq_lm3_23_b , t_eq_lm3_45_b  :std_ulogic;
  signal t_eq_lm3_u ,t_eq_lm3_v , t_eq_lm3_b   :std_ulogic;
  signal a_eq_lm4_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm4_01_b , a_eq_lm4_23_b , a_eq_lm4_45_b  :std_ulogic;
  signal a_eq_lm4_u ,a_eq_lm4_v , a_eq_lm4_b   :std_ulogic;
  signal b_eq_lm4_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm4_01_b , b_eq_lm4_23_b , b_eq_lm4_45_b  :std_ulogic;
  signal b_eq_lm4_u ,b_eq_lm4_v , b_eq_lm4_b   :std_ulogic;
  signal c_eq_lm4_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm4_01_b , c_eq_lm4_23_b , c_eq_lm4_45_b  :std_ulogic;
  signal c_eq_lm4_u ,c_eq_lm4_v , c_eq_lm4_b   :std_ulogic;
  signal t_eq_lm4_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm4_01_b , t_eq_lm4_23_b , t_eq_lm4_45_b  :std_ulogic;
  signal t_eq_lm4_u ,t_eq_lm4_v , t_eq_lm4_b   :std_ulogic;
  signal a_eq_lm5_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm5_01_b , a_eq_lm5_23_b , a_eq_lm5_45_b  :std_ulogic;
  signal a_eq_lm5_u ,a_eq_lm5_v , a_eq_lm5_b   :std_ulogic;
  signal b_eq_lm5_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm5_01_b , b_eq_lm5_23_b , b_eq_lm5_45_b  :std_ulogic;
  signal b_eq_lm5_u ,b_eq_lm5_v , b_eq_lm5_b   :std_ulogic;
  signal c_eq_lm5_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm5_01_b , c_eq_lm5_23_b , c_eq_lm5_45_b  :std_ulogic;
  signal c_eq_lm5_u ,c_eq_lm5_v , c_eq_lm5_b   :std_ulogic;
  signal t_eq_lm5_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm5_01_b , t_eq_lm5_23_b , t_eq_lm5_45_b  :std_ulogic;
  signal t_eq_lm5_u ,t_eq_lm5_v , t_eq_lm5_b   :std_ulogic;
  signal a_eq_lm6_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm6_01_b , a_eq_lm6_23_b , a_eq_lm6_45_b  :std_ulogic;
  signal a_eq_lm6_u ,a_eq_lm6_v , a_eq_lm6_b   :std_ulogic;
  signal b_eq_lm6_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm6_01_b , b_eq_lm6_23_b , b_eq_lm6_45_b  :std_ulogic;
  signal b_eq_lm6_u ,b_eq_lm6_v , b_eq_lm6_b   :std_ulogic;
  signal c_eq_lm6_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm6_01_b , c_eq_lm6_23_b , c_eq_lm6_45_b  :std_ulogic;
  signal c_eq_lm6_u ,c_eq_lm6_v , c_eq_lm6_b   :std_ulogic;
  signal t_eq_lm6_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm6_01_b , t_eq_lm6_23_b , t_eq_lm6_45_b  :std_ulogic;
  signal t_eq_lm6_u ,t_eq_lm6_v , t_eq_lm6_b   :std_ulogic;
  signal a_eq_lm7_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lm7_01_b , a_eq_lm7_23_b , a_eq_lm7_45_b  :std_ulogic;
  signal a_eq_lm7_u ,a_eq_lm7_v , a_eq_lm7_b   :std_ulogic;
  signal b_eq_lm7_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lm7_01_b , b_eq_lm7_23_b , b_eq_lm7_45_b  :std_ulogic;
  signal b_eq_lm7_u ,b_eq_lm7_v , b_eq_lm7_b   :std_ulogic;
  signal c_eq_lm7_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lm7_01_b , c_eq_lm7_23_b , c_eq_lm7_45_b  :std_ulogic;
  signal c_eq_lm7_u ,c_eq_lm7_v , c_eq_lm7_b   :std_ulogic;
  signal t_eq_lm7_x  :std_ulogic_vector(0 to 5); 
  signal t_eq_lm7_01_b , t_eq_lm7_23_b , t_eq_lm7_45_b  :std_ulogic;
  signal t_eq_lm7_u ,t_eq_lm7_v , t_eq_lm7_b   :std_ulogic;
  signal a_eq_lmc_ex4_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_lmc_ex4_01_b , a_eq_lmc_ex4_23_b , a_eq_lmc_ex4_45_b  :std_ulogic;
  signal a_eq_lmc_ex4_u ,a_eq_lmc_ex4_v , a_eq_lmc_ex4_b   :std_ulogic;
  signal b_eq_lmc_ex4_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_lmc_ex4_01_b , b_eq_lmc_ex4_23_b , b_eq_lmc_ex4_45_b  :std_ulogic;
  signal b_eq_lmc_ex4_u ,b_eq_lmc_ex4_v , b_eq_lmc_ex4_b   :std_ulogic;
  signal c_eq_lmc_ex4_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_lmc_ex4_01_b , c_eq_lmc_ex4_23_b , c_eq_lmc_ex4_45_b  :std_ulogic;
  signal c_eq_lmc_ex4_u ,c_eq_lmc_ex4_v , c_eq_lmc_ex4_b   :std_ulogic;
  signal a_eq_ex4_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_ex4_01_b , a_eq_ex4_23_b , a_eq_ex4_45_b  :std_ulogic;
  signal a_eq_ex4_u ,a_eq_ex4_v , a_eq_ex4_b   :std_ulogic;
  signal b_eq_ex4_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_ex4_01_b , b_eq_ex4_23_b , b_eq_ex4_45_b  :std_ulogic;
  signal b_eq_ex4_u ,b_eq_ex4_v , b_eq_ex4_b   :std_ulogic;
  signal u_eq_ex4_b :std_ulogic;
  signal c_eq_ex4_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_ex4_01_b , c_eq_ex4_23_b , c_eq_ex4_45_b  :std_ulogic;
  signal c_eq_ex4_u ,c_eq_ex4_v , c_eq_ex4_b   :std_ulogic;
  signal a_eq_ex3_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_ex3_01_b , a_eq_ex3_23_b , a_eq_ex3_45_b  :std_ulogic;
  signal a_eq_ex3_u ,a_eq_ex3_v , a_eq_ex3_b   :std_ulogic;
  signal b_eq_ex3_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_ex3_01_b , b_eq_ex3_23_b , b_eq_ex3_45_b  :std_ulogic;
  signal b_eq_ex3_u ,b_eq_ex3_v , b_eq_ex3_b   :std_ulogic;
  signal u_eq_ex3_b :std_ulogic;
  signal c_eq_ex3_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_ex3_01_b , c_eq_ex3_23_b , c_eq_ex3_45_b  :std_ulogic;
  signal c_eq_ex3_u ,c_eq_ex3_v , c_eq_ex3_b   :std_ulogic;
  signal a_eq_ex2_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_ex2_01_b , a_eq_ex2_23_b , a_eq_ex2_45_b  :std_ulogic;
  signal a_eq_ex2_u ,a_eq_ex2_v , a_eq_ex2_b   :std_ulogic;
  signal b_eq_ex2_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_ex2_01_b , b_eq_ex2_23_b , b_eq_ex2_45_b  :std_ulogic;
  signal b_eq_ex2_u ,b_eq_ex2_v , b_eq_ex2_b   :std_ulogic;
  signal u_eq_ex2_b :std_ulogic;
  signal c_eq_ex2_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_ex2_01_b , c_eq_ex2_23_b , c_eq_ex2_45_b  :std_ulogic;
  signal c_eq_ex2_u ,c_eq_ex2_v , c_eq_ex2_b   :std_ulogic;
  signal a_eq_ex1_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_ex1_01_b , a_eq_ex1_23_b , a_eq_ex1_45_b  :std_ulogic;
  signal a_eq_ex1_u ,a_eq_ex1_v , a_eq_ex1_b   :std_ulogic;
  signal b_eq_ex1_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_ex1_01_b , b_eq_ex1_23_b , b_eq_ex1_45_b  :std_ulogic;
  signal b_eq_ex1_u ,b_eq_ex1_v , b_eq_ex1_b   :std_ulogic;
  signal u_eq_ex1_b :std_ulogic;
  signal c_eq_ex1_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_ex1_01_b , c_eq_ex1_23_b , c_eq_ex1_45_b  :std_ulogic;
  signal c_eq_ex1_u ,c_eq_ex1_v , c_eq_ex1_b   :std_ulogic;
  signal a_eq_rf1_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_rf1_01_b , a_eq_rf1_23_b , a_eq_rf1_45_b  :std_ulogic;
  signal a_eq_rf1_u ,a_eq_rf1_v , a_eq_rf1_b   :std_ulogic;
  signal b_eq_rf1_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_rf1_01_b , b_eq_rf1_23_b , b_eq_rf1_45_b  :std_ulogic;
  signal b_eq_rf1_u ,b_eq_rf1_v , b_eq_rf1_b   :std_ulogic;
  signal u_eq_rf1_b :std_ulogic ;
  signal c_eq_rf1_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_rf1_01_b , c_eq_rf1_23_b , c_eq_rf1_45_b  :std_ulogic;
  signal c_eq_rf1_u ,c_eq_rf1_v , c_eq_rf1_b   :std_ulogic;

  signal a_eq_rf0_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_rf0_01_b , a_eq_rf0_23_b , a_eq_rf0_45_b  :std_ulogic;
  signal a_eq_rf0_u ,a_eq_rf0_v , a_eq_rf0_b   :std_ulogic;
  signal b_eq_rf0_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_rf0_01_b , b_eq_rf0_23_b , b_eq_rf0_45_b  :std_ulogic;
  signal b_eq_rf0_u ,b_eq_rf0_v , b_eq_rf0_b   :std_ulogic;
  signal u_eq_rf0_b :std_ulogic;
  signal c_eq_rf0_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_rf0_01_b , c_eq_rf0_23_b , c_eq_rf0_45_b  :std_ulogic;
  signal c_eq_rf0_u ,c_eq_rf0_v , c_eq_rf0_b   :std_ulogic;
  signal a_eq_is2_x  :std_ulogic_vector(0 to 5); 
  signal a_eq_is2_01_b , a_eq_is2_23_b , a_eq_is2_45_b  :std_ulogic;
  signal a_eq_is2_u ,a_eq_is2_v , a_eq_is2_b   :std_ulogic;
  signal b_eq_is2_x  :std_ulogic_vector(0 to 5); 
  signal b_eq_is2_01_b , b_eq_is2_23_b , b_eq_is2_45_b  :std_ulogic;
  signal b_eq_is2_u ,b_eq_is2_v , b_eq_is2_b   :std_ulogic;
  signal u_eq_is2_b :std_ulogic;
  signal c_eq_is2_x  :std_ulogic_vector(0 to 5); 
  signal c_eq_is2_01_b , c_eq_is2_23_b , c_eq_is2_45_b  :std_ulogic;
  signal c_eq_is2_u ,c_eq_is2_v , c_eq_is2_b   :std_ulogic;
  
  signal  a_or_1_1 , a_or_1_2 , a_or_1_3 , a_or_1_4  :std_ulogic;
  signal  a_or_1_5 , a_or_1_6 , a_or_1_7 , a_or_1_8  :std_ulogic;
  signal  a_or_2_1_b , a_or_2_2_b , a_or_2_3_b , a_or_2_4_b  :std_ulogic;
  signal  a_or_3_1 , a_or_3_2 , a_or_4_b  :std_ulogic;
  signal  b_or_1_1 , b_or_1_2 , b_or_1_3 , b_or_1_4  :std_ulogic;
  signal  b_or_1_5 , b_or_1_6 , b_or_1_7 , b_or_1_8  :std_ulogic;
  signal  b_or_2_1_b , b_or_2_2_b , b_or_2_3_b , b_or_2_4_b  :std_ulogic;
  signal  b_or_3_1 , b_or_3_2 , b_or_4_b  :std_ulogic;
  signal  c_or_1_1 , c_or_1_2 , c_or_1_3 , c_or_1_4  :std_ulogic;
  signal  c_or_1_5 , c_or_1_6 , c_or_1_7 , c_or_1_8  :std_ulogic;
  signal  c_or_2_1_b , c_or_2_2_b , c_or_2_3_b , c_or_2_4_b  :std_ulogic;
  signal  c_or_3_1 , c_or_3_2 , c_or_4_b  :std_ulogic;

  signal  t_or_1_1 , t_or_1_2 , t_or_1_3 , t_or_1_4  :std_ulogic;
  signal  t_or_2_1_b , t_or_2_2_b  :std_ulogic;
  signal  t_or_3_1 , t_or_4_b  :std_ulogic;
  signal  u_or_1_5 , u_or_1_6 , u_or_1_7 , u_or_1_8  :std_ulogic;
  signal  u_or_2_3_b , u_or_2_4_b , u_or_3_1 , u_or_4_b  :std_ulogic;

  signal a_group_en  :std_ulogic;
  signal c_group_en  :std_ulogic;
  signal b_group_en  :std_ulogic;
  signal u_group_en  :std_ulogic;
  signal t_group_en  :std_ulogic;
  
  signal lm0_a_cmp_en ,  lm0_b_cmp_en ,  lm0_c_cmp_en ,  lm0_t_cmp_en :std_ulogic;
  signal lm1_a_cmp_en ,  lm1_b_cmp_en ,  lm1_c_cmp_en ,  lm1_t_cmp_en  :std_ulogic;
  signal lm2_a_cmp_en ,  lm2_b_cmp_en ,  lm2_c_cmp_en ,  lm2_t_cmp_en  :std_ulogic;
  signal lm3_a_cmp_en ,  lm3_b_cmp_en ,  lm3_c_cmp_en ,  lm3_t_cmp_en  :std_ulogic;
  signal lm4_a_cmp_en ,  lm4_b_cmp_en ,  lm4_c_cmp_en ,  lm4_t_cmp_en  :std_ulogic;
  signal lm5_a_cmp_en ,  lm5_b_cmp_en ,  lm5_c_cmp_en ,  lm5_t_cmp_en  :std_ulogic;
  signal lm6_a_cmp_en ,  lm6_b_cmp_en ,  lm6_c_cmp_en ,  lm6_t_cmp_en  :std_ulogic;
  signal lm7_a_cmp_en ,  lm7_b_cmp_en ,  lm7_c_cmp_en ,  lm7_t_cmp_en  :std_ulogic;
  signal lmc_ex4_a_cmp_en ,  lmc_ex4_b_cmp_en ,  lmc_ex4_c_cmp_en  :std_ulogic;
  signal is2_a_cmp_en ,  is2_b_cmp_en ,  is2_c_cmp_en ,  is2_u_cmp_en   :std_ulogic;
  signal rf0_a_cmp_en ,  rf0_b_cmp_en ,  rf0_c_cmp_en ,  rf0_u_cmp_en   :std_ulogic;
  signal rf1_a_cmp_en ,  rf1_b_cmp_en ,  rf1_c_cmp_en ,  rf1_u_cmp_en   :std_ulogic;
  signal ex1_a_cmp_en ,  ex1_b_cmp_en ,  ex1_c_cmp_en ,  ex1_u_cmp_en   :std_ulogic;
  signal ex2_a_cmp_en ,  ex2_b_cmp_en ,  ex2_c_cmp_en ,  ex2_u_cmp_en   :std_ulogic;
  signal ex3_a_cmp_en ,  ex3_b_cmp_en ,  ex3_c_cmp_en ,  ex3_u_cmp_en   :std_ulogic;
  signal ex4_a_cmp_en ,  ex4_b_cmp_en ,  ex4_c_cmp_en ,  ex4_u_cmp_en   :std_ulogic;

signal lm0_valid     : std_ulogic;
signal lm1_valid     : std_ulogic;
signal lm2_valid     : std_ulogic;
signal lm3_valid     : std_ulogic;
signal lm4_valid     : std_ulogic;
signal lm5_valid     : std_ulogic;
signal lm6_valid     : std_ulogic;
signal lm7_valid     : std_ulogic;










 












 
begin



  ucmp_lm0tabufb: lm0_ta_buf_b(0 to 5) <= not lm0_ta(0 to 5);
  ucmp_lm1tabufb: lm1_ta_buf_b(0 to 5) <= not lm1_ta(0 to 5);
  ucmp_lm2tabufb: lm2_ta_buf_b(0 to 5) <= not lm2_ta(0 to 5);
  ucmp_lm3tabufb: lm3_ta_buf_b(0 to 5) <= not lm3_ta(0 to 5);
  ucmp_lm4tabufb: lm4_ta_buf_b(0 to 5) <= not lm4_ta(0 to 5);
  ucmp_lm5tabufb: lm5_ta_buf_b(0 to 5) <= not lm5_ta(0 to 5);
  ucmp_lm6tabufb: lm6_ta_buf_b(0 to 5) <= not lm6_ta(0 to 5);
  ucmp_lm7tabufb: lm7_ta_buf_b(0 to 5) <= not lm7_ta(0 to 5);
  ucmp_lmxtabufb: lmc_ex4_buf_b(0 to 5) <= not lmc_ex4(0 to 5);
  ucmp_ex4tabufb: ex4_ta_buf_b(0 to 5) <= not ex4_ta(0 to 5);
  ucmp_ex3tabufb: ex3_ta_buf_b(0 to 5) <= not ex3_ta(0 to 5);
  ucmp_ex2tabufb: ex2_ta_buf_b(0 to 5) <= not ex2_ta(0 to 5);
  ucmp_ex1tabufb: ex1_ta_buf_b(0 to 5) <= not ex1_ta(0 to 5);
  ucmp_rf1tabufb: rf1_ta_buf_b(0 to 5) <= not rf1_ta(0 to 5);
  ucmp_rf0tabufb: rf0_ta_buf_b(0 to 5) <= not rf0_ta(0 to 5);
  ucmp_is2tabufb: is2_ta_buf_b(0 to 5) <= not is2_ta(0 to 5);
  
  ucmp_lm0tabuf: lm0_ta_buf(0 to 5) <= not lm0_ta_buf_b (0 to 5);
  ucmp_lm1tabuf: lm1_ta_buf(0 to 5) <= not lm1_ta_buf_b (0 to 5);
  ucmp_lm2tabuf: lm2_ta_buf(0 to 5) <= not lm2_ta_buf_b (0 to 5);
  ucmp_lm3tabuf: lm3_ta_buf(0 to 5) <= not lm3_ta_buf_b (0 to 5);
  ucmp_lm4tabuf: lm4_ta_buf(0 to 5) <= not lm4_ta_buf_b (0 to 5);
  ucmp_lm5tabuf: lm5_ta_buf(0 to 5) <= not lm5_ta_buf_b (0 to 5);
  ucmp_lm6tabuf: lm6_ta_buf(0 to 5) <= not lm6_ta_buf_b (0 to 5);
  ucmp_lm7tabuf: lm7_ta_buf(0 to 5) <= not lm7_ta_buf_b (0 to 5);
  ucmp_lmxtabuf: lmc_ex4_buf(0 to 5) <= not lmc_ex4_buf_b (0 to 5);
  ucmp_ex4tabuf: ex4_ta_buf(0 to 5) <= not ex4_ta_buf_b (0 to 5);
  ucmp_ex3tabuf: ex3_ta_buf(0 to 5) <= not ex3_ta_buf_b (0 to 5);
  ucmp_ex2tabuf: ex2_ta_buf(0 to 5) <= not ex2_ta_buf_b (0 to 5);
  ucmp_ex1tabuf: ex1_ta_buf(0 to 5) <= not ex1_ta_buf_b (0 to 5);
  ucmp_rf1tabuf: rf1_ta_buf(0 to 5) <= not rf1_ta_buf_b (0 to 5);
  ucmp_rf0tabuf: rf0_ta_buf(0 to 5) <= not rf0_ta_buf_b (0 to 5);
  ucmp_is2tabuf: is2_ta_buf(0 to 5) <= not is2_ta_buf_b (0 to 5);

  ucmp_is1frabufb1: is1_fra_buf1_b(0 to 5) <= not is1_fra(0 to 5);
  ucmp_is1frbbufb1: is1_frb_buf1_b(0 to 5) <= not is1_frb(0 to 5);
  ucmp_is1frcbufb1: is1_frc_buf1_b(0 to 5) <= not is1_frc(0 to 5);
  ucmp_is1frtbufb1: is1_frt_buf1_b(0 to 5) <= not is1_ta(0 to 5);
  
  ucmp_is1frabufb2: is1_fra_buf2_b(0 to 5) <= not is1_fra(0 to 5);
  ucmp_is1frbbufb2: is1_frb_buf2_b(0 to 5) <= not is1_frb(0 to 5);
  ucmp_is1frcbufb2: is1_frc_buf2_b(0 to 5) <= not is1_frc(0 to 5);
  ucmp_is1frtbufb2: is1_frt_buf2_b(0 to 5) <= not is1_ta(0 to 5);

  ucmp_is1frabuf1:  is1_fra_buf1(0 to 5)   <= not is1_fra_buf1_b(0 to 5);
  ucmp_is1frbbuf1:  is1_frb_buf1(0 to 5)   <= not is1_frb_buf1_b(0 to 5);
  ucmp_is1frcbuf1:  is1_frc_buf1(0 to 5)   <= not is1_frc_buf1_b(0 to 5);
  ucmp_is1frtbuf1:  is1_frt_buf1(0 to 5)   <= not is1_frt_buf1_b(0 to 5);

  ucmp_is1frabuf2:  is1_fra_buf2(0 to 5)   <= not is1_fra_buf1_b(0 to 5);
  ucmp_is1frbbuf2:  is1_frb_buf2(0 to 5)   <= not is1_frb_buf1_b(0 to 5);
  ucmp_is1frcbuf2:  is1_frc_buf2(0 to 5)   <= not is1_frc_buf1_b(0 to 5);
  ucmp_is1frtbuf2:  is1_frt_buf2(0 to 5)   <= not is1_frt_buf1_b(0 to 5);

  ucmp_is1frabuf3:  is1_fra_buf3(0 to 5)   <= not is1_fra_buf1_b(0 to 5);
  ucmp_is1frbbuf3:  is1_frb_buf3(0 to 5)   <= not is1_frb_buf1_b(0 to 5);
  ucmp_is1frcbuf3:  is1_frc_buf3(0 to 5)   <= not is1_frc_buf1_b(0 to 5);
  ucmp_is1frtbuf3:  is1_frt_buf3(0 to 5)   <= not is1_frt_buf1_b(0 to 5);


  ucmp_is1frabuf4:  is1_fra_buf4(0 to 5)   <= not is1_fra_buf2_b(0 to 5);
  ucmp_is1frbbuf4:  is1_frb_buf4(0 to 5)   <= not is1_frb_buf2_b(0 to 5);
  ucmp_is1frcbuf4:  is1_frc_buf4(0 to 5)   <= not is1_frc_buf2_b(0 to 5);
  ucmp_is1frtbuf4:  is1_frt_buf4(0 to 5)   <= not is1_frt_buf2_b(0 to 5);

  ucmp_is1frabuf5:  is1_fra_buf5(0 to 5)   <= not is1_fra_buf2_b(0 to 5);
  ucmp_is1frbbuf5:  is1_frb_buf5(0 to 5)   <= not is1_frb_buf2_b(0 to 5);
  ucmp_is1frcbuf5:  is1_frc_buf5(0 to 5)   <= not is1_frc_buf2_b(0 to 5);
  ucmp_is1frtbuf5:  is1_frt_buf5(0 to 5)   <= not is1_frt_buf2_b(0 to 5);

  ucmp_is1frabuf6:  is1_fra_buf6(0 to 5)   <= not is1_fra_buf2_b(0 to 5);
  ucmp_is1frbbuf6:  is1_frb_buf6(0 to 5)   <= not is1_frb_buf2_b(0 to 5);
  ucmp_is1frcbuf6:  is1_frc_buf6(0 to 5)   <= not is1_frc_buf2_b(0 to 5);
  ucmp_is1frtbuf6:  is1_frt_buf6(0 to 5)   <= not is1_frt_buf2_b(0 to 5);



  


  
  ucmp_aeqis2_x:  a_eq_is2_x(0 to 5) <= not( is2_ta_buf(0 to 5) xor is1_fra_buf1(0 to 5) ); 
  ucmp_aeqis2_01: a_eq_is2_01_b      <= not( a_eq_is2_x(0) and a_eq_is2_x(1) ); 
  ucmp_aeqis2_23: a_eq_is2_23_b      <= not( a_eq_is2_x(2) and a_eq_is2_x(3) ); 
  ucmp_aeqis2_45: a_eq_is2_45_b      <= not( a_eq_is2_x(4) and a_eq_is2_x(5) ); 
  ucmp_aeqis2_u:  a_eq_is2_u         <= not( a_eq_is2_01_b or a_eq_is2_23_b ); 
  ucmp_aeqis2_w:  a_eq_is2_v         <= not( a_eq_is2_45_b ); 
  ucmp_aeqis2:    a_eq_is2_b         <= not( a_eq_is2_u and a_eq_is2_v and is2_a_cmp_en ); 

  ucmp_aeqrf0_x:  a_eq_rf0_x(0 to 5) <= not( rf0_ta_buf(0 to 5) xor is1_fra_buf1(0 to 5) ); 
  ucmp_aeqrf0_01: a_eq_rf0_01_b      <= not( a_eq_rf0_x(0) and a_eq_rf0_x(1) ); 
  ucmp_aeqrf0_23: a_eq_rf0_23_b      <= not( a_eq_rf0_x(2) and a_eq_rf0_x(3) ); 
  ucmp_aeqrf0_45: a_eq_rf0_45_b      <= not( a_eq_rf0_x(4) and a_eq_rf0_x(5) ); 
  ucmp_aeqrf0_u:  a_eq_rf0_u         <= not( a_eq_rf0_01_b or a_eq_rf0_23_b ); 
  ucmp_aeqrf0_w:  a_eq_rf0_v         <= not( a_eq_rf0_45_b ); 
  ucmp_aeqrf0:    a_eq_rf0_b         <= not( a_eq_rf0_u and a_eq_rf0_v and rf0_a_cmp_en );

  ucmp_aeqrf1_x:  a_eq_rf1_x(0 to 5) <= not( rf1_ta_buf(0 to 5) xor is1_fra_buf1(0 to 5) ); 
  ucmp_aeqrf1_01: a_eq_rf1_01_b      <= not( a_eq_rf1_x(0) and a_eq_rf1_x(1) ); 
  ucmp_aeqrf1_23: a_eq_rf1_23_b      <= not( a_eq_rf1_x(2) and a_eq_rf1_x(3) ); 
  ucmp_aeqrf1_45: a_eq_rf1_45_b      <= not( a_eq_rf1_x(4) and a_eq_rf1_x(5) ); 
  ucmp_aeqrf1_u:  a_eq_rf1_u         <= not( a_eq_rf1_01_b or a_eq_rf1_23_b ); 
  ucmp_aeqrf1_w:  a_eq_rf1_v         <= not( a_eq_rf1_45_b ); 
  ucmp_aeqrf1:    a_eq_rf1_b         <= not( a_eq_rf1_u and a_eq_rf1_v and rf1_a_cmp_en ); 

  ucmp_aeqex1_x:  a_eq_ex1_x(0 to 5) <= not( ex1_ta_buf(0 to 5) xor is1_fra_buf2(0 to 5) ); 
  ucmp_aeqex1_01: a_eq_ex1_01_b      <= not( a_eq_ex1_x(0) and a_eq_ex1_x(1) ); 
  ucmp_aeqex1_23: a_eq_ex1_23_b      <= not( a_eq_ex1_x(2) and a_eq_ex1_x(3) ); 
  ucmp_aeqex1_45: a_eq_ex1_45_b      <= not( a_eq_ex1_x(4) and a_eq_ex1_x(5) ); 
  ucmp_aeqex1_u:  a_eq_ex1_u         <= not( a_eq_ex1_01_b or a_eq_ex1_23_b ); 
  ucmp_aeqex1_w:  a_eq_ex1_v         <= not( a_eq_ex1_45_b ); 
  ucmp_aeqex1:    a_eq_ex1_b         <= not( a_eq_ex1_u and a_eq_ex1_v and ex1_a_cmp_en ); 

  ucmp_aeqex2_x:  a_eq_ex2_x(0 to 5) <= not( ex2_ta_buf(0 to 5) xor is1_fra_buf2(0 to 5) ); 
  ucmp_aeqex2_01: a_eq_ex2_01_b      <= not( a_eq_ex2_x(0) and a_eq_ex2_x(1) ); 
  ucmp_aeqex2_23: a_eq_ex2_23_b      <= not( a_eq_ex2_x(2) and a_eq_ex2_x(3) ); 
  ucmp_aeqex2_45: a_eq_ex2_45_b      <= not( a_eq_ex2_x(4) and a_eq_ex2_x(5) ); 
  ucmp_aeqex2_u:  a_eq_ex2_u         <= not( a_eq_ex2_01_b or a_eq_ex2_23_b ); 
  ucmp_aeqex2_w:  a_eq_ex2_v         <= not( a_eq_ex2_45_b ); 
  ucmp_aeqex2:    a_eq_ex2_b         <= not( a_eq_ex2_u and a_eq_ex2_v and ex2_a_cmp_en ); 

  ucmp_aeqex3_x:  a_eq_ex3_x(0 to 5) <= not( ex3_ta_buf(0 to 5) xor is1_fra_buf2(0 to 5) ); 
  ucmp_aeqex3_01: a_eq_ex3_01_b      <= not( a_eq_ex3_x(0) and a_eq_ex3_x(1) ); 
  ucmp_aeqex3_23: a_eq_ex3_23_b      <= not( a_eq_ex3_x(2) and a_eq_ex3_x(3) ); 
  ucmp_aeqex3_45: a_eq_ex3_45_b      <= not( a_eq_ex3_x(4) and a_eq_ex3_x(5) ); 
  ucmp_aeqex3_u:  a_eq_ex3_u         <= not( a_eq_ex3_01_b or a_eq_ex3_23_b ); 
  ucmp_aeqex3_w:  a_eq_ex3_v         <= not( a_eq_ex3_45_b ); 
  ucmp_aeqex3:    a_eq_ex3_b         <= not( a_eq_ex3_u and a_eq_ex3_v and ex3_a_cmp_en );

  ucmp_aeqex4_x:  a_eq_ex4_x(0 to 5) <= not( ex4_ta_buf(0 to 5) xor is1_fra_buf3(0 to 5) ); 
  ucmp_aeqex4_01: a_eq_ex4_01_b      <= not( a_eq_ex4_x(0) and a_eq_ex4_x(1) ); 
  ucmp_aeqex4_23: a_eq_ex4_23_b      <= not( a_eq_ex4_x(2) and a_eq_ex4_x(3) ); 
  ucmp_aeqex4_45: a_eq_ex4_45_b      <= not( a_eq_ex4_x(4) and a_eq_ex4_x(5) ); 
  ucmp_aeqex4_u:  a_eq_ex4_u         <= not( a_eq_ex4_01_b or a_eq_ex4_23_b ); 
  ucmp_aeqex4_w:  a_eq_ex4_v         <= not( a_eq_ex4_45_b ); 
  ucmp_aeqex4:    a_eq_ex4_b         <= not( a_eq_ex4_u and a_eq_ex4_v and ex4_a_cmp_en ); 


  ucmp_aeqlmx_x:  a_eq_lmc_ex4_x(0 to 5) <= not( lmc_ex4_buf(0 to 5) xor is1_fra_buf3(0 to 5) ); 
  ucmp_aeqlmx_01: a_eq_lmc_ex4_01_b      <= not( a_eq_lmc_ex4_x(0) and a_eq_lmc_ex4_x(1) ); 
  ucmp_aeqlmx_23: a_eq_lmc_ex4_23_b      <= not( a_eq_lmc_ex4_x(2) and a_eq_lmc_ex4_x(3) ); 
  ucmp_aeqlmx_45: a_eq_lmc_ex4_45_b      <= not( a_eq_lmc_ex4_x(4) and a_eq_lmc_ex4_x(5) ); 
  ucmp_aeqlmx_u:  a_eq_lmc_ex4_u         <= not( a_eq_lmc_ex4_01_b or a_eq_lmc_ex4_23_b ); 
  ucmp_aeqlmx_w:  a_eq_lmc_ex4_v         <= not( a_eq_lmc_ex4_45_b ); 
  ucmp_aeqlmx:    a_eq_lmc_ex4_b         <= not( a_eq_lmc_ex4_u and a_eq_lmc_ex4_v and lmc_ex4_a_cmp_en ); 

  ucmp_aeqlm0_x:  a_eq_lm0_x(0 to 5) <= not( lm0_ta_buf(0 to 5) xor is1_fra_buf3(0 to 5) ); 
  ucmp_aeqlm0_01: a_eq_lm0_01_b      <= not( a_eq_lm0_x(0) and a_eq_lm0_x(1) ); 
  ucmp_aeqlm0_23: a_eq_lm0_23_b      <= not( a_eq_lm0_x(2) and a_eq_lm0_x(3) ); 
  ucmp_aeqlm0_45: a_eq_lm0_45_b      <= not( a_eq_lm0_x(4) and a_eq_lm0_x(5) ); 
  ucmp_aeqlm0_u:  a_eq_lm0_u         <= not( a_eq_lm0_01_b or a_eq_lm0_23_b ); 
  ucmp_aeqlm0_w:  a_eq_lm0_v         <= not( a_eq_lm0_45_b ); 
  ucmp_aeqlm0:    a_eq_lm0_b         <= not( a_eq_lm0_u and a_eq_lm0_v and lm0_a_cmp_en ); 

  ucmp_aeqlm1_x:  a_eq_lm1_x(0 to 5) <= not( lm1_ta_buf(0 to 5) xor is1_fra_buf4(0 to 5) ); 
  ucmp_aeqlm1_01: a_eq_lm1_01_b      <= not( a_eq_lm1_x(0) and a_eq_lm1_x(1) ); 
  ucmp_aeqlm1_23: a_eq_lm1_23_b      <= not( a_eq_lm1_x(2) and a_eq_lm1_x(3) ); 
  ucmp_aeqlm1_45: a_eq_lm1_45_b      <= not( a_eq_lm1_x(4) and a_eq_lm1_x(5) ); 
  ucmp_aeqlm1_u:  a_eq_lm1_u         <= not( a_eq_lm1_01_b or a_eq_lm1_23_b ); 
  ucmp_aeqlm1_w:  a_eq_lm1_v         <= not( a_eq_lm1_45_b ); 
  ucmp_aeqlm1:    a_eq_lm1_b         <= not( a_eq_lm1_u and a_eq_lm1_v and lm1_a_cmp_en ); 

  ucmp_aeqlm2_x:  a_eq_lm2_x(0 to 5) <= not( lm2_ta_buf(0 to 5) xor is1_fra_buf4(0 to 5) ); 
  ucmp_aeqlm2_01: a_eq_lm2_01_b      <= not( a_eq_lm2_x(0) and a_eq_lm2_x(1) ); 
  ucmp_aeqlm2_23: a_eq_lm2_23_b      <= not( a_eq_lm2_x(2) and a_eq_lm2_x(3) ); 
  ucmp_aeqlm2_45: a_eq_lm2_45_b      <= not( a_eq_lm2_x(4) and a_eq_lm2_x(5) ); 
  ucmp_aeqlm2_u:  a_eq_lm2_u         <= not( a_eq_lm2_01_b or a_eq_lm2_23_b ); 
  ucmp_aeqlm2_w:  a_eq_lm2_v         <= not( a_eq_lm2_45_b ); 
  ucmp_aeqlm2:    a_eq_lm2_b         <= not( a_eq_lm2_u and a_eq_lm2_v and lm2_a_cmp_en ); 

  ucmp_aeqlm3_x:  a_eq_lm3_x(0 to 5) <= not( lm3_ta_buf(0 to 5) xor is1_fra_buf4(0 to 5) ); 
  ucmp_aeqlm3_01: a_eq_lm3_01_b      <= not( a_eq_lm3_x(0) and a_eq_lm3_x(1) ); 
  ucmp_aeqlm3_23: a_eq_lm3_23_b      <= not( a_eq_lm3_x(2) and a_eq_lm3_x(3) ); 
  ucmp_aeqlm3_45: a_eq_lm3_45_b      <= not( a_eq_lm3_x(4) and a_eq_lm3_x(5) ); 
  ucmp_aeqlm3_u:  a_eq_lm3_u         <= not( a_eq_lm3_01_b or a_eq_lm3_23_b ); 
  ucmp_aeqlm3_w:  a_eq_lm3_v         <= not( a_eq_lm3_45_b ); 
  ucmp_aeqlm3:    a_eq_lm3_b         <= not( a_eq_lm3_u and a_eq_lm3_v and lm3_a_cmp_en ); 

  ucmp_aeqlm4_x:  a_eq_lm4_x(0 to 5) <= not( lm4_ta_buf(0 to 5) xor is1_fra_buf5(0 to 5) ); 
  ucmp_aeqlm4_01: a_eq_lm4_01_b      <= not( a_eq_lm4_x(0) and a_eq_lm4_x(1) ); 
  ucmp_aeqlm4_23: a_eq_lm4_23_b      <= not( a_eq_lm4_x(2) and a_eq_lm4_x(3) ); 
  ucmp_aeqlm4_45: a_eq_lm4_45_b      <= not( a_eq_lm4_x(4) and a_eq_lm4_x(5) ); 
  ucmp_aeqlm4_u:  a_eq_lm4_u         <= not( a_eq_lm4_01_b or a_eq_lm4_23_b ); 
  ucmp_aeqlm4_w:  a_eq_lm4_v         <= not( a_eq_lm4_45_b ); 
  ucmp_aeqlm4:    a_eq_lm4_b         <= not( a_eq_lm4_u and a_eq_lm4_v and lm4_a_cmp_en ); 

  ucmp_aeqlm5_x:  a_eq_lm5_x(0 to 5) <= not( lm5_ta_buf(0 to 5) xor is1_fra_buf5(0 to 5) ); 
  ucmp_aeqlm5_01: a_eq_lm5_01_b      <= not( a_eq_lm5_x(0) and a_eq_lm5_x(1) ); 
  ucmp_aeqlm5_23: a_eq_lm5_23_b      <= not( a_eq_lm5_x(2) and a_eq_lm5_x(3) ); 
  ucmp_aeqlm5_45: a_eq_lm5_45_b      <= not( a_eq_lm5_x(4) and a_eq_lm5_x(5) ); 
  ucmp_aeqlm5_u:  a_eq_lm5_u         <= not( a_eq_lm5_01_b or a_eq_lm5_23_b ); 
  ucmp_aeqlm5_w:  a_eq_lm5_v         <= not( a_eq_lm5_45_b ); 
  ucmp_aeqlm5:    a_eq_lm5_b         <= not( a_eq_lm5_u and a_eq_lm5_v and lm5_a_cmp_en ); 

  ucmp_aeqlm6_x:  a_eq_lm6_x(0 to 5) <= not( lm6_ta_buf(0 to 5) xor is1_fra_buf6(0 to 5) ); 
  ucmp_aeqlm6_01: a_eq_lm6_01_b      <= not( a_eq_lm6_x(0) and a_eq_lm6_x(1) ); 
  ucmp_aeqlm6_23: a_eq_lm6_23_b      <= not( a_eq_lm6_x(2) and a_eq_lm6_x(3) ); 
  ucmp_aeqlm6_45: a_eq_lm6_45_b      <= not( a_eq_lm6_x(4) and a_eq_lm6_x(5) ); 
  ucmp_aeqlm6_u:  a_eq_lm6_u         <= not( a_eq_lm6_01_b or a_eq_lm6_23_b ); 
  ucmp_aeqlm6_w:  a_eq_lm6_v         <= not( a_eq_lm6_45_b ); 
  ucmp_aeqlm6:    a_eq_lm6_b         <= not( a_eq_lm6_u and a_eq_lm6_v and lm6_a_cmp_en ); 

  ucmp_aeqlm7_x:  a_eq_lm7_x(0 to 5) <= not( lm7_ta_buf(0 to 5) xor is1_fra_buf6(0 to 5) ); 
  ucmp_aeqlm7_01: a_eq_lm7_01_b      <= not( a_eq_lm7_x(0) and a_eq_lm7_x(1) ); 
  ucmp_aeqlm7_23: a_eq_lm7_23_b      <= not( a_eq_lm7_x(2) and a_eq_lm7_x(3) ); 
  ucmp_aeqlm7_45: a_eq_lm7_45_b      <= not( a_eq_lm7_x(4) and a_eq_lm7_x(5) ); 
  ucmp_aeqlm7_u:  a_eq_lm7_u         <= not( a_eq_lm7_01_b or a_eq_lm7_23_b ); 
  ucmp_aeqlm7_w:  a_eq_lm7_v         <= not( a_eq_lm7_45_b ); 
  ucmp_aeqlm7:    a_eq_lm7_b         <= not( a_eq_lm7_u and a_eq_lm7_v and lm7_a_cmp_en ); 


  
               

  ucmp_beqis2_x:  b_eq_is2_x(0 to 5) <= not( is2_ta_buf(0 to 5) xor is1_frb_buf1(0 to 5) ); 
  ucmp_beqis2_01: b_eq_is2_01_b      <= not( b_eq_is2_x(0) and b_eq_is2_x(1) ); 
  ucmp_beqis2_23: b_eq_is2_23_b      <= not( b_eq_is2_x(2) and b_eq_is2_x(3) ); 
  ucmp_beqis2_45: b_eq_is2_45_b      <= not( b_eq_is2_x(4) and b_eq_is2_x(5) ); 
  ucmp_beqis2_u:  b_eq_is2_u         <= not( b_eq_is2_01_b or b_eq_is2_23_b ); 
  ucmp_beqis2_w:  b_eq_is2_v         <= not( b_eq_is2_45_b ); 
  ucmp_beqis2:    b_eq_is2_b         <= not( b_eq_is2_u and b_eq_is2_v and is2_b_cmp_en ); 
  ucmp_beqis2_uc: u_eq_is2_b         <= not( b_eq_is2_u and b_eq_is2_v and is2_u_cmp_en ); 

  ucmp_beqrf0_x:  b_eq_rf0_x(0 to 5) <= not( rf0_ta_buf(0 to 5) xor is1_frb_buf1(0 to 5) ); 
  ucmp_beqrf0_01: b_eq_rf0_01_b      <= not( b_eq_rf0_x(0) and b_eq_rf0_x(1) ); 
  ucmp_beqrf0_23: b_eq_rf0_23_b      <= not( b_eq_rf0_x(2) and b_eq_rf0_x(3) ); 
  ucmp_beqrf0_45: b_eq_rf0_45_b      <= not( b_eq_rf0_x(4) and b_eq_rf0_x(5) ); 
  ucmp_beqrf0_u:  b_eq_rf0_u         <= not( b_eq_rf0_01_b or b_eq_rf0_23_b ); 
  ucmp_beqrf0_w:  b_eq_rf0_v         <= not( b_eq_rf0_45_b ); 
  ucmp_beqrf0:    b_eq_rf0_b         <= not( b_eq_rf0_u and b_eq_rf0_v and rf0_b_cmp_en ); 
  ucmp_beqrf0_uc: u_eq_rf0_b         <= not( b_eq_rf0_u and b_eq_rf0_v and rf0_u_cmp_en );

  ucmp_beqrf1_x:  b_eq_rf1_x(0 to 5) <= not( rf1_ta_buf(0 to 5) xor is1_frb_buf1(0 to 5) ); 
  ucmp_beqrf1_01: b_eq_rf1_01_b      <= not( b_eq_rf1_x(0) and b_eq_rf1_x(1) ); 
  ucmp_beqrf1_23: b_eq_rf1_23_b      <= not( b_eq_rf1_x(2) and b_eq_rf1_x(3) ); 
  ucmp_beqrf1_45: b_eq_rf1_45_b      <= not( b_eq_rf1_x(4) and b_eq_rf1_x(5) ); 
  ucmp_beqrf1_u:  b_eq_rf1_u         <= not( b_eq_rf1_01_b or b_eq_rf1_23_b ); 
  ucmp_beqrf1_w:  b_eq_rf1_v         <= not( b_eq_rf1_45_b ); 
  ucmp_beqrf1:    b_eq_rf1_b         <= not( b_eq_rf1_u and b_eq_rf1_v and rf1_b_cmp_en ); 
  ucmp_beqrf1_uc: u_eq_rf1_b         <= not( b_eq_rf1_u and b_eq_rf1_v and rf1_u_cmp_en ); 

  ucmp_beqex1_x:  b_eq_ex1_x(0 to 5) <= not( ex1_ta_buf(0 to 5) xor is1_frb_buf2(0 to 5) ); 
  ucmp_beqex1_01: b_eq_ex1_01_b      <= not( b_eq_ex1_x(0) and b_eq_ex1_x(1) ); 
  ucmp_beqex1_23: b_eq_ex1_23_b      <= not( b_eq_ex1_x(2) and b_eq_ex1_x(3) ); 
  ucmp_beqex1_45: b_eq_ex1_45_b      <= not( b_eq_ex1_x(4) and b_eq_ex1_x(5) ); 
  ucmp_beqex1_u:  b_eq_ex1_u         <= not( b_eq_ex1_01_b or b_eq_ex1_23_b ); 
  ucmp_beqex1_w:  b_eq_ex1_v         <= not( b_eq_ex1_45_b ); 
  ucmp_beqex1:    b_eq_ex1_b         <= not( b_eq_ex1_u and b_eq_ex1_v and ex1_b_cmp_en ); 
  ucmp_beqex1_uc: u_eq_ex1_b         <= not( b_eq_ex1_u and b_eq_ex1_v and ex1_u_cmp_en ); 

  ucmp_beqex2_x:  b_eq_ex2_x(0 to 5) <= not( ex2_ta_buf(0 to 5) xor is1_frb_buf2(0 to 5) ); 
  ucmp_beqex2_01: b_eq_ex2_01_b      <= not( b_eq_ex2_x(0) and b_eq_ex2_x(1) ); 
  ucmp_beqex2_23: b_eq_ex2_23_b      <= not( b_eq_ex2_x(2) and b_eq_ex2_x(3) ); 
  ucmp_beqex2_45: b_eq_ex2_45_b      <= not( b_eq_ex2_x(4) and b_eq_ex2_x(5) ); 
  ucmp_beqex2_u:  b_eq_ex2_u         <= not( b_eq_ex2_01_b or b_eq_ex2_23_b ); 
  ucmp_beqex2_w:  b_eq_ex2_v         <= not( b_eq_ex2_45_b ); 
  ucmp_beqex2:    b_eq_ex2_b         <= not( b_eq_ex2_u and b_eq_ex2_v and ex2_b_cmp_en ); 
  ucmp_beqex2_uc: u_eq_ex2_b         <= not( b_eq_ex2_u and b_eq_ex2_v and ex2_u_cmp_en );

  ucmp_beqex3_x:  b_eq_ex3_x(0 to 5) <= not( ex3_ta_buf(0 to 5) xor is1_frb_buf2(0 to 5) ); 
  ucmp_beqex3_01: b_eq_ex3_01_b      <= not( b_eq_ex3_x(0) and b_eq_ex3_x(1) ); 
  ucmp_beqex3_23: b_eq_ex3_23_b      <= not( b_eq_ex3_x(2) and b_eq_ex3_x(3) ); 
  ucmp_beqex3_45: b_eq_ex3_45_b      <= not( b_eq_ex3_x(4) and b_eq_ex3_x(5) ); 
  ucmp_beqex3_u:  b_eq_ex3_u         <= not( b_eq_ex3_01_b or b_eq_ex3_23_b ); 
  ucmp_beqex3_w:  b_eq_ex3_v         <= not( b_eq_ex3_45_b ); 
  ucmp_beqex3:    b_eq_ex3_b         <= not( b_eq_ex3_u and b_eq_ex3_v and ex3_b_cmp_en ); 
  ucmp_beqex3_uc: u_eq_ex3_b         <= not( b_eq_ex3_u and b_eq_ex3_v and ex3_u_cmp_en ); 
  
  ucmp_beqex4_x:  b_eq_ex4_x(0 to 5) <= not( ex4_ta_buf(0 to 5) xor is1_frb_buf3(0 to 5) ); 
  ucmp_beqex4_01: b_eq_ex4_01_b      <= not( b_eq_ex4_x(0) and b_eq_ex4_x(1) ); 
  ucmp_beqex4_23: b_eq_ex4_23_b      <= not( b_eq_ex4_x(2) and b_eq_ex4_x(3) ); 
  ucmp_beqex4_45: b_eq_ex4_45_b      <= not( b_eq_ex4_x(4) and b_eq_ex4_x(5) ); 
  ucmp_beqex4_u:  b_eq_ex4_u         <= not( b_eq_ex4_01_b or b_eq_ex4_23_b ); 
  ucmp_beqex4_w:  b_eq_ex4_v         <= not( b_eq_ex4_45_b ); 
  ucmp_beqex4:    b_eq_ex4_b         <= not( b_eq_ex4_u and b_eq_ex4_v and ex4_b_cmp_en ); 
  ucmp_beqex4_uc: u_eq_ex4_b         <= not( b_eq_ex4_u and b_eq_ex4_v and ex4_u_cmp_en ); 

  ucmp_beqlmx_x:  b_eq_lmc_ex4_x(0 to 5) <= not( lmc_ex4_buf(0 to 5) xor is1_frb_buf3(0 to 5) ); 
  ucmp_beqlmx_01: b_eq_lmc_ex4_01_b      <= not( b_eq_lmc_ex4_x(0) and b_eq_lmc_ex4_x(1) ); 
  ucmp_beqlmx_23: b_eq_lmc_ex4_23_b      <= not( b_eq_lmc_ex4_x(2) and b_eq_lmc_ex4_x(3) ); 
  ucmp_beqlmx_45: b_eq_lmc_ex4_45_b      <= not( b_eq_lmc_ex4_x(4) and b_eq_lmc_ex4_x(5) ); 
  ucmp_beqlmx_u:  b_eq_lmc_ex4_u         <= not( b_eq_lmc_ex4_01_b or b_eq_lmc_ex4_23_b ); 
  ucmp_beqlmx_w:  b_eq_lmc_ex4_v         <= not( b_eq_lmc_ex4_45_b ); 
  ucmp_beqlmx:    b_eq_lmc_ex4_b         <= not( b_eq_lmc_ex4_u and b_eq_lmc_ex4_v and lmc_ex4_b_cmp_en ); 

  ucmp_beqlm0_x:  b_eq_lm0_x(0 to 5) <= not( lm0_ta_buf(0 to 5) xor is1_frb_buf3(0 to 5) ); 
  ucmp_beqlm0_01: b_eq_lm0_01_b      <= not( b_eq_lm0_x(0) and b_eq_lm0_x(1) ); 
  ucmp_beqlm0_23: b_eq_lm0_23_b      <= not( b_eq_lm0_x(2) and b_eq_lm0_x(3) ); 
  ucmp_beqlm0_45: b_eq_lm0_45_b      <= not( b_eq_lm0_x(4) and b_eq_lm0_x(5) ); 
  ucmp_beqlm0_u:  b_eq_lm0_u         <= not( b_eq_lm0_01_b or b_eq_lm0_23_b ); 
  ucmp_beqlm0_w:  b_eq_lm0_v         <= not( b_eq_lm0_45_b ); 
  ucmp_beqlm0:    b_eq_lm0_b         <= not( b_eq_lm0_u and b_eq_lm0_v and lm0_b_cmp_en ); 

  ucmp_beqlm1_x:  b_eq_lm1_x(0 to 5) <= not( lm1_ta_buf(0 to 5) xor is1_frb_buf4(0 to 5) ); 
  ucmp_beqlm1_01: b_eq_lm1_01_b      <= not( b_eq_lm1_x(0) and b_eq_lm1_x(1) ); 
  ucmp_beqlm1_23: b_eq_lm1_23_b      <= not( b_eq_lm1_x(2) and b_eq_lm1_x(3) ); 
  ucmp_beqlm1_45: b_eq_lm1_45_b      <= not( b_eq_lm1_x(4) and b_eq_lm1_x(5) ); 
  ucmp_beqlm1_u:  b_eq_lm1_u         <= not( b_eq_lm1_01_b or b_eq_lm1_23_b ); 
  ucmp_beqlm1_w:  b_eq_lm1_v         <= not( b_eq_lm1_45_b ); 
  ucmp_beqlm1:    b_eq_lm1_b         <= not( b_eq_lm1_u and b_eq_lm1_v and lm1_b_cmp_en ); 

  ucmp_beqlm2_x:  b_eq_lm2_x(0 to 5) <= not( lm2_ta_buf(0 to 5) xor is1_frb_buf4(0 to 5) ); 
  ucmp_beqlm2_01: b_eq_lm2_01_b      <= not( b_eq_lm2_x(0) and b_eq_lm2_x(1) ); 
  ucmp_beqlm2_23: b_eq_lm2_23_b      <= not( b_eq_lm2_x(2) and b_eq_lm2_x(3) ); 
  ucmp_beqlm2_45: b_eq_lm2_45_b      <= not( b_eq_lm2_x(4) and b_eq_lm2_x(5) ); 
  ucmp_beqlm2_u:  b_eq_lm2_u         <= not( b_eq_lm2_01_b or b_eq_lm2_23_b ); 
  ucmp_beqlm2_w:  b_eq_lm2_v         <= not( b_eq_lm2_45_b ); 
  ucmp_beqlm2:    b_eq_lm2_b         <= not( b_eq_lm2_u and b_eq_lm2_v and lm2_b_cmp_en ); 

  ucmp_beqlm3_x:  b_eq_lm3_x(0 to 5) <= not( lm3_ta_buf(0 to 5) xor is1_frb_buf4(0 to 5) ); 
  ucmp_beqlm3_01: b_eq_lm3_01_b      <= not( b_eq_lm3_x(0) and b_eq_lm3_x(1) ); 
  ucmp_beqlm3_23: b_eq_lm3_23_b      <= not( b_eq_lm3_x(2) and b_eq_lm3_x(3) ); 
  ucmp_beqlm3_45: b_eq_lm3_45_b      <= not( b_eq_lm3_x(4) and b_eq_lm3_x(5) ); 
  ucmp_beqlm3_u:  b_eq_lm3_u         <= not( b_eq_lm3_01_b or b_eq_lm3_23_b ); 
  ucmp_beqlm3_w:  b_eq_lm3_v         <= not( b_eq_lm3_45_b ); 
  ucmp_beqlm3:    b_eq_lm3_b         <= not( b_eq_lm3_u and b_eq_lm3_v and lm3_b_cmp_en ); 

  ucmp_beqlm4_x:  b_eq_lm4_x(0 to 5) <= not( lm4_ta_buf(0 to 5) xor is1_frb_buf5(0 to 5) ); 
  ucmp_beqlm4_01: b_eq_lm4_01_b      <= not( b_eq_lm4_x(0) and b_eq_lm4_x(1) ); 
  ucmp_beqlm4_23: b_eq_lm4_23_b      <= not( b_eq_lm4_x(2) and b_eq_lm4_x(3) ); 
  ucmp_beqlm4_45: b_eq_lm4_45_b      <= not( b_eq_lm4_x(4) and b_eq_lm4_x(5) ); 
  ucmp_beqlm4_u:  b_eq_lm4_u         <= not( b_eq_lm4_01_b or b_eq_lm4_23_b ); 
  ucmp_beqlm4_w:  b_eq_lm4_v         <= not( b_eq_lm4_45_b ); 
  ucmp_beqlm4:    b_eq_lm4_b         <= not( b_eq_lm4_u and b_eq_lm4_v and lm4_b_cmp_en );
  
  ucmp_beqlm5_x:  b_eq_lm5_x(0 to 5) <= not( lm5_ta_buf(0 to 5) xor is1_frb_buf5(0 to 5) ); 
  ucmp_beqlm5_01: b_eq_lm5_01_b      <= not( b_eq_lm5_x(0) and b_eq_lm5_x(1) ); 
  ucmp_beqlm5_23: b_eq_lm5_23_b      <= not( b_eq_lm5_x(2) and b_eq_lm5_x(3) ); 
  ucmp_beqlm5_45: b_eq_lm5_45_b      <= not( b_eq_lm5_x(4) and b_eq_lm5_x(5) ); 
  ucmp_beqlm5_u:  b_eq_lm5_u         <= not( b_eq_lm5_01_b or b_eq_lm5_23_b ); 
  ucmp_beqlm5_w:  b_eq_lm5_v         <= not( b_eq_lm5_45_b ); 
  ucmp_beqlm5:    b_eq_lm5_b         <= not( b_eq_lm5_u and b_eq_lm5_v and lm5_b_cmp_en ); 

  ucmp_beqlm6_x:  b_eq_lm6_x(0 to 5) <= not( lm6_ta_buf(0 to 5) xor is1_frb_buf6(0 to 5) ); 
  ucmp_beqlm6_01: b_eq_lm6_01_b      <= not( b_eq_lm6_x(0) and b_eq_lm6_x(1) ); 
  ucmp_beqlm6_23: b_eq_lm6_23_b      <= not( b_eq_lm6_x(2) and b_eq_lm6_x(3) ); 
  ucmp_beqlm6_45: b_eq_lm6_45_b      <= not( b_eq_lm6_x(4) and b_eq_lm6_x(5) ); 
  ucmp_beqlm6_u:  b_eq_lm6_u         <= not( b_eq_lm6_01_b or b_eq_lm6_23_b ); 
  ucmp_beqlm6_w:  b_eq_lm6_v         <= not( b_eq_lm6_45_b ); 
  ucmp_beqlm6:    b_eq_lm6_b         <= not( b_eq_lm6_u and b_eq_lm6_v and lm6_b_cmp_en ); 

  ucmp_beqlm7_x:  b_eq_lm7_x(0 to 5) <= not( lm7_ta_buf(0 to 5) xor is1_frb_buf6(0 to 5) ); 
  ucmp_beqlm7_01: b_eq_lm7_01_b      <= not( b_eq_lm7_x(0) and b_eq_lm7_x(1) ); 
  ucmp_beqlm7_23: b_eq_lm7_23_b      <= not( b_eq_lm7_x(2) and b_eq_lm7_x(3) ); 
  ucmp_beqlm7_45: b_eq_lm7_45_b      <= not( b_eq_lm7_x(4) and b_eq_lm7_x(5) ); 
  ucmp_beqlm7_u:  b_eq_lm7_u         <= not( b_eq_lm7_01_b or b_eq_lm7_23_b ); 
  ucmp_beqlm7_w:  b_eq_lm7_v         <= not( b_eq_lm7_45_b ); 
  ucmp_beqlm7:    b_eq_lm7_b         <= not( b_eq_lm7_u and b_eq_lm7_v and lm7_b_cmp_en ); 







  


  ucmp_ceqis2_x:  c_eq_is2_x(0 to 5) <= not( is2_ta_buf(0 to 5) xor is1_frc_buf1(0 to 5) ); 
  ucmp_ceqis2_01: c_eq_is2_01_b      <= not( c_eq_is2_x(0) and c_eq_is2_x(1) ); 
  ucmp_ceqis2_23: c_eq_is2_23_b      <= not( c_eq_is2_x(2) and c_eq_is2_x(3) ); 
  ucmp_ceqis2_45: c_eq_is2_45_b      <= not( c_eq_is2_x(4) and c_eq_is2_x(5) ); 
  ucmp_ceqis2_u:  c_eq_is2_u         <= not( c_eq_is2_01_b or c_eq_is2_23_b ); 
  ucmp_ceqis2_w:  c_eq_is2_v         <= not( c_eq_is2_45_b ); 
  ucmp_ceqis2:    c_eq_is2_b         <= not( c_eq_is2_u and c_eq_is2_v and is2_c_cmp_en ); 

  ucmp_ceqrf0_x:  c_eq_rf0_x(0 to 5) <= not( rf0_ta_buf(0 to 5) xor is1_frc_buf1(0 to 5) ); 
  ucmp_ceqrf0_01: c_eq_rf0_01_b      <= not( c_eq_rf0_x(0) and c_eq_rf0_x(1) ); 
  ucmp_ceqrf0_23: c_eq_rf0_23_b      <= not( c_eq_rf0_x(2) and c_eq_rf0_x(3) ); 
  ucmp_ceqrf0_45: c_eq_rf0_45_b      <= not( c_eq_rf0_x(4) and c_eq_rf0_x(5) ); 
  ucmp_ceqrf0_u:  c_eq_rf0_u         <= not( c_eq_rf0_01_b or c_eq_rf0_23_b ); 
  ucmp_ceqrf0_w:  c_eq_rf0_v         <= not( c_eq_rf0_45_b ); 
  ucmp_ceqrf0:    c_eq_rf0_b         <= not( c_eq_rf0_u and c_eq_rf0_v and rf0_c_cmp_en ); 

  ucmp_ceqrf1_x:  c_eq_rf1_x(0 to 5) <= not( rf1_ta_buf(0 to 5) xor is1_frc_buf1(0 to 5) ); 
  ucmp_ceqrf1_01: c_eq_rf1_01_b      <= not( c_eq_rf1_x(0) and c_eq_rf1_x(1) ); 
  ucmp_ceqrf1_23: c_eq_rf1_23_b      <= not( c_eq_rf1_x(2) and c_eq_rf1_x(3) ); 
  ucmp_ceqrf1_45: c_eq_rf1_45_b      <= not( c_eq_rf1_x(4) and c_eq_rf1_x(5) ); 
  ucmp_ceqrf1_u:  c_eq_rf1_u         <= not( c_eq_rf1_01_b or c_eq_rf1_23_b ); 
  ucmp_ceqrf1_w:  c_eq_rf1_v         <= not( c_eq_rf1_45_b ); 
  ucmp_ceqrf1:    c_eq_rf1_b         <= not( c_eq_rf1_u and c_eq_rf1_v and rf1_c_cmp_en ); 

  ucmp_ceqex1_x:  c_eq_ex1_x(0 to 5) <= not( ex1_ta_buf(0 to 5) xor is1_frc_buf2(0 to 5) ); 
  ucmp_ceqex1_01: c_eq_ex1_01_b      <= not( c_eq_ex1_x(0) and c_eq_ex1_x(1) ); 
  ucmp_ceqex1_23: c_eq_ex1_23_b      <= not( c_eq_ex1_x(2) and c_eq_ex1_x(3) ); 
  ucmp_ceqex1_45: c_eq_ex1_45_b      <= not( c_eq_ex1_x(4) and c_eq_ex1_x(5) ); 
  ucmp_ceqex1_u:  c_eq_ex1_u         <= not( c_eq_ex1_01_b or c_eq_ex1_23_b ); 
  ucmp_ceqex1_w:  c_eq_ex1_v         <= not( c_eq_ex1_45_b ); 
  ucmp_ceqex1:    c_eq_ex1_b         <= not( c_eq_ex1_u and c_eq_ex1_v and ex1_c_cmp_en ); 

  ucmp_ceqex2_x:  c_eq_ex2_x(0 to 5) <= not( ex2_ta_buf(0 to 5) xor is1_frc_buf2(0 to 5) ); 
  ucmp_ceqex2_01: c_eq_ex2_01_b      <= not( c_eq_ex2_x(0) and c_eq_ex2_x(1) ); 
  ucmp_ceqex2_23: c_eq_ex2_23_b      <= not( c_eq_ex2_x(2) and c_eq_ex2_x(3) ); 
  ucmp_ceqex2_45: c_eq_ex2_45_b      <= not( c_eq_ex2_x(4) and c_eq_ex2_x(5) ); 
  ucmp_ceqex2_u:  c_eq_ex2_u         <= not( c_eq_ex2_01_b or c_eq_ex2_23_b ); 
  ucmp_ceqex2_w:  c_eq_ex2_v         <= not( c_eq_ex2_45_b ); 
  ucmp_ceqex2:    c_eq_ex2_b         <= not( c_eq_ex2_u and c_eq_ex2_v and ex2_c_cmp_en ); 

  ucmp_ceqex3_x:  c_eq_ex3_x(0 to 5) <= not( ex3_ta_buf(0 to 5) xor is1_frc_buf2(0 to 5) ); 
  ucmp_ceqex3_01: c_eq_ex3_01_b      <= not( c_eq_ex3_x(0) and c_eq_ex3_x(1) ); 
  ucmp_ceqex3_23: c_eq_ex3_23_b      <= not( c_eq_ex3_x(2) and c_eq_ex3_x(3) ); 
  ucmp_ceqex3_45: c_eq_ex3_45_b      <= not( c_eq_ex3_x(4) and c_eq_ex3_x(5) ); 
  ucmp_ceqex3_u:  c_eq_ex3_u         <= not( c_eq_ex3_01_b or c_eq_ex3_23_b ); 
  ucmp_ceqex3_w:  c_eq_ex3_v         <= not( c_eq_ex3_45_b ); 
  ucmp_ceqex3:    c_eq_ex3_b         <= not( c_eq_ex3_u and c_eq_ex3_v and ex3_c_cmp_en ); 

  ucmp_ceqex4_x:  c_eq_ex4_x(0 to 5) <= not( ex4_ta_buf(0 to 5) xor is1_frc_buf3(0 to 5) ); 
  ucmp_ceqex4_01: c_eq_ex4_01_b      <= not( c_eq_ex4_x(0) and c_eq_ex4_x(1) ); 
  ucmp_ceqex4_23: c_eq_ex4_23_b      <= not( c_eq_ex4_x(2) and c_eq_ex4_x(3) ); 
  ucmp_ceqex4_45: c_eq_ex4_45_b      <= not( c_eq_ex4_x(4) and c_eq_ex4_x(5) ); 
  ucmp_ceqex4_u:  c_eq_ex4_u         <= not( c_eq_ex4_01_b or c_eq_ex4_23_b ); 
  ucmp_ceqex4_w:  c_eq_ex4_v         <= not( c_eq_ex4_45_b ); 
  ucmp_ceqex4:    c_eq_ex4_b         <= not( c_eq_ex4_u and c_eq_ex4_v and ex4_c_cmp_en ); 

  ucmp_ceqlmx_x:  c_eq_lmc_ex4_x(0 to 5) <= not( lmc_ex4_buf(0 to 5) xor is1_frc_buf3(0 to 5) ); 
  ucmp_ceqlmx_01: c_eq_lmc_ex4_01_b      <= not( c_eq_lmc_ex4_x(0) and c_eq_lmc_ex4_x(1) ); 
  ucmp_ceqlmx_23: c_eq_lmc_ex4_23_b      <= not( c_eq_lmc_ex4_x(2) and c_eq_lmc_ex4_x(3) ); 
  ucmp_ceqlmx_45: c_eq_lmc_ex4_45_b      <= not( c_eq_lmc_ex4_x(4) and c_eq_lmc_ex4_x(5) ); 
  ucmp_ceqlmx_u:  c_eq_lmc_ex4_u         <= not( c_eq_lmc_ex4_01_b or c_eq_lmc_ex4_23_b ); 
  ucmp_ceqlmx_w:  c_eq_lmc_ex4_v         <= not( c_eq_lmc_ex4_45_b ); 
  ucmp_ceqlmx:    c_eq_lmc_ex4_b         <= not( c_eq_lmc_ex4_u and c_eq_lmc_ex4_v and lmc_ex4_c_cmp_en ); 

  ucmp_ceqlm0_x:  c_eq_lm0_x(0 to 5) <= not( lm0_ta_buf(0 to 5) xor is1_frc_buf3(0 to 5) ); 
  ucmp_ceqlm0_01: c_eq_lm0_01_b      <= not( c_eq_lm0_x(0) and c_eq_lm0_x(1) ); 
  ucmp_ceqlm0_23: c_eq_lm0_23_b      <= not( c_eq_lm0_x(2) and c_eq_lm0_x(3) ); 
  ucmp_ceqlm0_45: c_eq_lm0_45_b      <= not( c_eq_lm0_x(4) and c_eq_lm0_x(5) ); 
  ucmp_ceqlm0_u:  c_eq_lm0_u         <= not( c_eq_lm0_01_b or c_eq_lm0_23_b ); 
  ucmp_ceqlm0_w:  c_eq_lm0_v         <= not( c_eq_lm0_45_b ); 
  ucmp_ceqlm0:    c_eq_lm0_b         <= not( c_eq_lm0_u and c_eq_lm0_v and lm0_c_cmp_en ); 


  ucmp_ceqlm1_x:  c_eq_lm1_x(0 to 5) <= not( lm1_ta_buf(0 to 5) xor is1_frc_buf4(0 to 5) ); 
  ucmp_ceqlm1_01: c_eq_lm1_01_b      <= not( c_eq_lm1_x(0) and c_eq_lm1_x(1) ); 
  ucmp_ceqlm1_23: c_eq_lm1_23_b      <= not( c_eq_lm1_x(2) and c_eq_lm1_x(3) ); 
  ucmp_ceqlm1_45: c_eq_lm1_45_b      <= not( c_eq_lm1_x(4) and c_eq_lm1_x(5) ); 
  ucmp_ceqlm1_u:  c_eq_lm1_u         <= not( c_eq_lm1_01_b or c_eq_lm1_23_b ); 
  ucmp_ceqlm1_w:  c_eq_lm1_v         <= not( c_eq_lm1_45_b ); 
  ucmp_ceqlm1:    c_eq_lm1_b         <= not( c_eq_lm1_u and c_eq_lm1_v and lm1_c_cmp_en ); 

  ucmp_ceqlm2_x:  c_eq_lm2_x(0 to 5) <= not( lm2_ta_buf(0 to 5) xor is1_frc_buf4(0 to 5) ); 
  ucmp_ceqlm2_01: c_eq_lm2_01_b      <= not( c_eq_lm2_x(0) and c_eq_lm2_x(1) ); 
  ucmp_ceqlm2_23: c_eq_lm2_23_b      <= not( c_eq_lm2_x(2) and c_eq_lm2_x(3) ); 
  ucmp_ceqlm2_45: c_eq_lm2_45_b      <= not( c_eq_lm2_x(4) and c_eq_lm2_x(5) ); 
  ucmp_ceqlm2_u:  c_eq_lm2_u         <= not( c_eq_lm2_01_b or c_eq_lm2_23_b ); 
  ucmp_ceqlm2_w:  c_eq_lm2_v         <= not( c_eq_lm2_45_b ); 
  ucmp_ceqlm2:    c_eq_lm2_b         <= not( c_eq_lm2_u and c_eq_lm2_v and lm2_c_cmp_en ); 

  ucmp_ceqlm3_x:  c_eq_lm3_x(0 to 5) <= not( lm3_ta_buf(0 to 5) xor is1_frc_buf4(0 to 5) ); 
  ucmp_ceqlm3_01: c_eq_lm3_01_b      <= not( c_eq_lm3_x(0) and c_eq_lm3_x(1) ); 
  ucmp_ceqlm3_23: c_eq_lm3_23_b      <= not( c_eq_lm3_x(2) and c_eq_lm3_x(3) ); 
  ucmp_ceqlm3_45: c_eq_lm3_45_b      <= not( c_eq_lm3_x(4) and c_eq_lm3_x(5) ); 
  ucmp_ceqlm3_u:  c_eq_lm3_u         <= not( c_eq_lm3_01_b or c_eq_lm3_23_b ); 
  ucmp_ceqlm3_w:  c_eq_lm3_v         <= not( c_eq_lm3_45_b ); 
  ucmp_ceqlm3:    c_eq_lm3_b         <= not( c_eq_lm3_u and c_eq_lm3_v and lm3_c_cmp_en ); 

  ucmp_ceqlm4_x:  c_eq_lm4_x(0 to 5) <= not( lm4_ta_buf(0 to 5) xor is1_frc_buf5(0 to 5) ); 
  ucmp_ceqlm4_01: c_eq_lm4_01_b      <= not( c_eq_lm4_x(0) and c_eq_lm4_x(1) ); 
  ucmp_ceqlm4_23: c_eq_lm4_23_b      <= not( c_eq_lm4_x(2) and c_eq_lm4_x(3) ); 
  ucmp_ceqlm4_45: c_eq_lm4_45_b      <= not( c_eq_lm4_x(4) and c_eq_lm4_x(5) ); 
  ucmp_ceqlm4_u:  c_eq_lm4_u         <= not( c_eq_lm4_01_b or c_eq_lm4_23_b ); 
  ucmp_ceqlm4_w:  c_eq_lm4_v         <= not( c_eq_lm4_45_b ); 
  ucmp_ceqlm4:    c_eq_lm4_b         <= not( c_eq_lm4_u and c_eq_lm4_v and lm4_c_cmp_en ); 

  ucmp_ceqlm5_x:  c_eq_lm5_x(0 to 5) <= not( lm5_ta_buf(0 to 5) xor is1_frc_buf5(0 to 5) ); 
  ucmp_ceqlm5_01: c_eq_lm5_01_b      <= not( c_eq_lm5_x(0) and c_eq_lm5_x(1) ); 
  ucmp_ceqlm5_23: c_eq_lm5_23_b      <= not( c_eq_lm5_x(2) and c_eq_lm5_x(3) ); 
  ucmp_ceqlm5_45: c_eq_lm5_45_b      <= not( c_eq_lm5_x(4) and c_eq_lm5_x(5) ); 
  ucmp_ceqlm5_u:  c_eq_lm5_u         <= not( c_eq_lm5_01_b or c_eq_lm5_23_b ); 
  ucmp_ceqlm5_w:  c_eq_lm5_v         <= not( c_eq_lm5_45_b ); 
  ucmp_ceqlm5:    c_eq_lm5_b         <= not( c_eq_lm5_u and c_eq_lm5_v and lm5_c_cmp_en ); 

  ucmp_ceqlm6_x:  c_eq_lm6_x(0 to 5) <= not( lm6_ta_buf(0 to 5) xor is1_frc_buf6(0 to 5) ); 
  ucmp_ceqlm6_01: c_eq_lm6_01_b      <= not( c_eq_lm6_x(0) and c_eq_lm6_x(1) ); 
  ucmp_ceqlm6_23: c_eq_lm6_23_b      <= not( c_eq_lm6_x(2) and c_eq_lm6_x(3) ); 
  ucmp_ceqlm6_45: c_eq_lm6_45_b      <= not( c_eq_lm6_x(4) and c_eq_lm6_x(5) ); 
  ucmp_ceqlm6_u:  c_eq_lm6_u         <= not( c_eq_lm6_01_b or c_eq_lm6_23_b ); 
  ucmp_ceqlm6_w:  c_eq_lm6_v         <= not( c_eq_lm6_45_b ); 
  ucmp_ceqlm6:    c_eq_lm6_b         <= not( c_eq_lm6_u and c_eq_lm6_v and lm6_c_cmp_en ); 

  ucmp_ceqlm7_x:  c_eq_lm7_x(0 to 5) <= not( lm7_ta_buf(0 to 5) xor is1_frc_buf6(0 to 5) ); 
  ucmp_ceqlm7_01: c_eq_lm7_01_b      <= not( c_eq_lm7_x(0) and c_eq_lm7_x(1) ); 
  ucmp_ceqlm7_23: c_eq_lm7_23_b      <= not( c_eq_lm7_x(2) and c_eq_lm7_x(3) ); 
  ucmp_ceqlm7_45: c_eq_lm7_45_b      <= not( c_eq_lm7_x(4) and c_eq_lm7_x(5) ); 
  ucmp_ceqlm7_u:  c_eq_lm7_u         <= not( c_eq_lm7_01_b or c_eq_lm7_23_b ); 
  ucmp_ceqlm7_w:  c_eq_lm7_v         <= not( c_eq_lm7_45_b ); 
  ucmp_ceqlm7:    c_eq_lm7_b         <= not( c_eq_lm7_u and c_eq_lm7_v and lm7_c_cmp_en ); 





  ucmp_teqlm0_x:  t_eq_lm0_x(0 to 5) <= not( lm0_ta_buf(0 to 5) xor is1_frt_buf1(0 to 5) ); 
  ucmp_teqlm0_01: t_eq_lm0_01_b      <= not( t_eq_lm0_x(0) and t_eq_lm0_x(1) ); 
  ucmp_teqlm0_23: t_eq_lm0_23_b      <= not( t_eq_lm0_x(2) and t_eq_lm0_x(3) ); 
  ucmp_teqlm0_45: t_eq_lm0_45_b      <= not( t_eq_lm0_x(4) and t_eq_lm0_x(5) ); 
  ucmp_teqlm0_u:  t_eq_lm0_u         <= not( t_eq_lm0_01_b or t_eq_lm0_23_b ); 
  ucmp_teqlm0_w:  t_eq_lm0_v         <= not( t_eq_lm0_45_b ); 
  ucmp_teqlm0:    t_eq_lm0_b         <= not( t_eq_lm0_u and t_eq_lm0_v and lm0_t_cmp_en ); 


  ucmp_teqlm1_x:  t_eq_lm1_x(0 to 5) <= not( lm1_ta_buf(0 to 5) xor is1_frt_buf1(0 to 5) ); 
  ucmp_teqlm1_01: t_eq_lm1_01_b      <= not( t_eq_lm1_x(0) and t_eq_lm1_x(1) ); 
  ucmp_teqlm1_23: t_eq_lm1_23_b      <= not( t_eq_lm1_x(2) and t_eq_lm1_x(3) ); 
  ucmp_teqlm1_45: t_eq_lm1_45_b      <= not( t_eq_lm1_x(4) and t_eq_lm1_x(5) ); 
  ucmp_teqlm1_u:  t_eq_lm1_u         <= not( t_eq_lm1_01_b or t_eq_lm1_23_b ); 
  ucmp_teqlm1_w:  t_eq_lm1_v         <= not( t_eq_lm1_45_b ); 
  ucmp_teqlm1:    t_eq_lm1_b         <= not( t_eq_lm1_u and t_eq_lm1_v and lm1_t_cmp_en ); 

  ucmp_teqlm2_x:  t_eq_lm2_x(0 to 5) <= not( lm2_ta_buf(0 to 5) xor is1_frt_buf2(0 to 5) ); 
  ucmp_teqlm2_01: t_eq_lm2_01_b      <= not( t_eq_lm2_x(0) and t_eq_lm2_x(1) ); 
  ucmp_teqlm2_23: t_eq_lm2_23_b      <= not( t_eq_lm2_x(2) and t_eq_lm2_x(3) ); 
  ucmp_teqlm2_45: t_eq_lm2_45_b      <= not( t_eq_lm2_x(4) and t_eq_lm2_x(5) ); 
  ucmp_teqlm2_u:  t_eq_lm2_u         <= not( t_eq_lm2_01_b or t_eq_lm2_23_b ); 
  ucmp_teqlm2_w:  t_eq_lm2_v         <= not( t_eq_lm2_45_b ); 
  ucmp_teqlm2:    t_eq_lm2_b         <= not( t_eq_lm2_u and t_eq_lm2_v and lm2_t_cmp_en ); 

  ucmp_teqlm3_x:  t_eq_lm3_x(0 to 5) <= not( lm3_ta_buf(0 to 5) xor is1_frt_buf3(0 to 5) ); 
  ucmp_teqlm3_01: t_eq_lm3_01_b      <= not( t_eq_lm3_x(0) and t_eq_lm3_x(1) ); 
  ucmp_teqlm3_23: t_eq_lm3_23_b      <= not( t_eq_lm3_x(2) and t_eq_lm3_x(3) ); 
  ucmp_teqlm3_45: t_eq_lm3_45_b      <= not( t_eq_lm3_x(4) and t_eq_lm3_x(5) ); 
  ucmp_teqlm3_u:  t_eq_lm3_u         <= not( t_eq_lm3_01_b or t_eq_lm3_23_b ); 
  ucmp_teqlm3_w:  t_eq_lm3_v         <= not( t_eq_lm3_45_b ); 
  ucmp_teqlm3:    t_eq_lm3_b         <= not( t_eq_lm3_u and t_eq_lm3_v and lm3_t_cmp_en ); 

  ucmp_teqlm4_x:  t_eq_lm4_x(0 to 5) <= not( lm4_ta_buf(0 to 5) xor is1_frt_buf4(0 to 5) ); 
  ucmp_teqlm4_01: t_eq_lm4_01_b      <= not( t_eq_lm4_x(0) and t_eq_lm4_x(1) ); 
  ucmp_teqlm4_23: t_eq_lm4_23_b      <= not( t_eq_lm4_x(2) and t_eq_lm4_x(3) ); 
  ucmp_teqlm4_45: t_eq_lm4_45_b      <= not( t_eq_lm4_x(4) and t_eq_lm4_x(5) ); 
  ucmp_teqlm4_u:  t_eq_lm4_u         <= not( t_eq_lm4_01_b or t_eq_lm4_23_b ); 
  ucmp_teqlm4_w:  t_eq_lm4_v         <= not( t_eq_lm4_45_b ); 
  ucmp_teqlm4:    t_eq_lm4_b         <= not( t_eq_lm4_u and t_eq_lm4_v and lm4_t_cmp_en ); 

  ucmp_teqlm5_x:  t_eq_lm5_x(0 to 5) <= not( lm5_ta_buf(0 to 5) xor is1_frt_buf5(0 to 5) ); 
  ucmp_teqlm5_01: t_eq_lm5_01_b      <= not( t_eq_lm5_x(0) and t_eq_lm5_x(1) ); 
  ucmp_teqlm5_23: t_eq_lm5_23_b      <= not( t_eq_lm5_x(2) and t_eq_lm5_x(3) ); 
  ucmp_teqlm5_45: t_eq_lm5_45_b      <= not( t_eq_lm5_x(4) and t_eq_lm5_x(5) ); 
  ucmp_teqlm5_u:  t_eq_lm5_u         <= not( t_eq_lm5_01_b or t_eq_lm5_23_b ); 
  ucmp_teqlm5_w:  t_eq_lm5_v         <= not( t_eq_lm5_45_b ); 
  ucmp_teqlm5:    t_eq_lm5_b         <= not( t_eq_lm5_u and t_eq_lm5_v and lm5_t_cmp_en ); 

  ucmp_teqlm6_x:  t_eq_lm6_x(0 to 5) <= not( lm6_ta_buf(0 to 5) xor is1_frt_buf6(0 to 5) ); 
  ucmp_teqlm6_01: t_eq_lm6_01_b      <= not( t_eq_lm6_x(0) and t_eq_lm6_x(1) ); 
  ucmp_teqlm6_23: t_eq_lm6_23_b      <= not( t_eq_lm6_x(2) and t_eq_lm6_x(3) ); 
  ucmp_teqlm6_45: t_eq_lm6_45_b      <= not( t_eq_lm6_x(4) and t_eq_lm6_x(5) ); 
  ucmp_teqlm6_u:  t_eq_lm6_u         <= not( t_eq_lm6_01_b or t_eq_lm6_23_b ); 
  ucmp_teqlm6_w:  t_eq_lm6_v         <= not( t_eq_lm6_45_b ); 
  ucmp_teqlm6:    t_eq_lm6_b         <= not( t_eq_lm6_u and t_eq_lm6_v and lm6_t_cmp_en ); 

  ucmp_teqlm7_x:  t_eq_lm7_x(0 to 5) <= not( lm7_ta_buf(0 to 5) xor is1_frt_buf6(0 to 5) ); 
  ucmp_teqlm7_01: t_eq_lm7_01_b      <= not( t_eq_lm7_x(0) and t_eq_lm7_x(1) ); 
  ucmp_teqlm7_23: t_eq_lm7_23_b      <= not( t_eq_lm7_x(2) and t_eq_lm7_x(3) ); 
  ucmp_teqlm7_45: t_eq_lm7_45_b      <= not( t_eq_lm7_x(4) and t_eq_lm7_x(5) ); 
  ucmp_teqlm7_u:  t_eq_lm7_u         <= not( t_eq_lm7_01_b or t_eq_lm7_23_b ); 
  ucmp_teqlm7_w:  t_eq_lm7_v         <= not( t_eq_lm7_45_b ); 
  ucmp_teqlm7:    t_eq_lm7_b         <= not( t_eq_lm7_u and t_eq_lm7_v and lm7_t_cmp_en ); 




  



  ucmp_aor11: a_or_1_1   <= not( a_eq_lm0_b and a_eq_lm1_b );
  ucmp_aor12: a_or_1_2   <= not( a_eq_lm2_b and a_eq_lm3_b );
  ucmp_aor13: a_or_1_3   <= not( a_eq_lm4_b and a_eq_lm5_b );
  ucmp_aor14: a_or_1_4   <= not( a_eq_lm6_b and a_eq_lm7_b );
  ucmp_aor15: a_or_1_5   <= not( a_eq_lmc_ex4_b and a_eq_ex4_b );
  ucmp_aor16: a_or_1_6   <= not( a_eq_ex3_b and a_eq_ex2_b );
  ucmp_aor17: a_or_1_7   <= not( a_eq_ex1_b and a_eq_rf1_b );
  ucmp_aor18: a_or_1_8   <= not( a_eq_rf0_b and a_eq_is2_b );

  ucmp_aor21: a_or_2_1_b <= not( a_or_1_1   or  a_or_1_2 );
  ucmp_aor22: a_or_2_2_b <= not( a_or_1_3   or  a_or_1_4 );
  ucmp_aor23: a_or_2_3_b <= not( a_or_1_5   or  a_or_1_6 );
  ucmp_aor24: a_or_2_4_b <= not( a_or_1_7   or  a_or_1_8 );

  ucmp_aor31: a_or_3_1   <= not( a_or_2_1_b and a_or_2_2_b );
  ucmp_aor32: a_or_3_2   <= not( a_or_2_3_b and a_or_2_4_b );

  ucmp_aor4:  a_or_4_b   <= not( a_group_en and (a_or_3_1 or a_or_3_2) );



  ucmp_bor11: b_or_1_1   <= not( b_eq_lm0_b and b_eq_lm1_b );
  ucmp_bor12: b_or_1_2   <= not( b_eq_lm2_b and b_eq_lm3_b );
  ucmp_bor13: b_or_1_3   <= not( b_eq_lm4_b and b_eq_lm5_b );
  ucmp_bor14: b_or_1_4   <= not( b_eq_lm6_b and b_eq_lm7_b );
  ucmp_bor15: b_or_1_5   <= not( b_eq_lmc_ex4_b and b_eq_ex4_b );
  ucmp_bor16: b_or_1_6   <= not( b_eq_ex3_b and b_eq_ex2_b );
  ucmp_bor17: b_or_1_7   <= not( b_eq_ex1_b and b_eq_rf1_b );
  ucmp_bor18: b_or_1_8   <= not( b_eq_rf0_b and b_eq_is2_b );

  ucmp_bor21: b_or_2_1_b <= not( b_or_1_1   or  b_or_1_2 );
  ucmp_bor22: b_or_2_2_b <= not( b_or_1_3   or  b_or_1_4 );
  ucmp_bor23: b_or_2_3_b <= not( b_or_1_5   or  b_or_1_6 );
  ucmp_bor24: b_or_2_4_b <= not( b_or_1_7   or  b_or_1_8 );

  ucmp_bor31: b_or_3_1   <= not( b_or_2_1_b and b_or_2_2_b );
  ucmp_bor32: b_or_3_2   <= not( b_or_2_3_b and b_or_2_4_b );

  ucmp_bor4:  b_or_4_b   <= not( b_group_en and (b_or_3_1 or b_or_3_2) );


  ucmp_uor15: u_or_1_5   <= not(                u_eq_ex4_b );
  ucmp_uor16: u_or_1_6   <= not( u_eq_ex3_b and u_eq_ex2_b );
  ucmp_uor17: u_or_1_7   <= not( u_eq_ex1_b and u_eq_rf1_b );
  ucmp_uor18: u_or_1_8   <= not( u_eq_rf0_b and u_eq_is2_b );

  ucmp_uor23: u_or_2_3_b <= not( u_or_1_5   or  u_or_1_6 );
  ucmp_uor24: u_or_2_4_b <= not( u_or_1_7   or  u_or_1_8 );

  ucmp_uor31: u_or_3_1   <= not( u_or_2_3_b and u_or_2_4_b );

  ucmp_uor4: u_or_4_b   <= not( u_or_3_1 and u_group_en);


  ucmp_cor11: c_or_1_1   <= not( c_eq_lm0_b and c_eq_lm1_b );
  ucmp_cor12: c_or_1_2   <= not( c_eq_lm2_b and c_eq_lm3_b );
  ucmp_cor13: c_or_1_3   <= not( c_eq_lm4_b and c_eq_lm5_b );
  ucmp_cor14: c_or_1_4   <= not( c_eq_lm6_b and c_eq_lm7_b );
  ucmp_cor15: c_or_1_5   <= not( c_eq_lmc_ex4_b and c_eq_ex4_b );
  ucmp_cor16: c_or_1_6   <= not( c_eq_ex3_b and c_eq_ex2_b );
  ucmp_cor17: c_or_1_7   <= not( c_eq_ex1_b and c_eq_rf1_b );
  ucmp_cor18: c_or_1_8   <= not( c_eq_rf0_b and c_eq_is2_b );

  ucmp_cor21: c_or_2_1_b <= not( c_or_1_1   or  c_or_1_2 );
  ucmp_cor22: c_or_2_2_b <= not( c_or_1_3   or  c_or_1_4 );
  ucmp_cor23: c_or_2_3_b <= not( c_or_1_5   or  c_or_1_6 );
  ucmp_cor24: c_or_2_4_b <= not( c_or_1_7   or  c_or_1_8 );

  ucmp_cor31: c_or_3_1   <= not( c_or_2_1_b and c_or_2_2_b );
  ucmp_cor32: c_or_3_2   <= not( c_or_2_3_b and c_or_2_4_b );

  ucmp_cor4:  c_or_4_b   <= not( c_group_en and (c_or_3_1 or c_or_3_2) );


  ucmp_tor11: t_or_1_1   <= not( t_eq_lm0_b and t_eq_lm1_b );
  ucmp_tor12: t_or_1_2   <= not( t_eq_lm2_b and t_eq_lm3_b );
  ucmp_tor13: t_or_1_3   <= not( t_eq_lm4_b and t_eq_lm5_b );
  ucmp_tor14: t_or_1_4   <= not( t_eq_lm6_b and t_eq_lm7_b );


  ucmp_tor21: t_or_2_1_b <= not( t_or_1_1   or  t_or_1_2 );
  ucmp_tor22: t_or_2_2_b <= not( t_or_1_3   or  t_or_1_4 );


  ucmp_tor31: t_or_3_1   <= not( t_or_2_1_b and t_or_2_2_b );


  ucmp_tor4:  t_or_4_b   <= not( t_group_en and t_or_3_1 );



lm0_valid  <= lm_v(0);
lm1_valid  <= lm_v(1);  
lm2_valid  <= lm_v(2);  
lm3_valid  <= lm_v(3);  
lm4_valid  <= lm_v(4);  
lm5_valid  <= lm_v(5);  
lm6_valid  <= lm_v(6);  
lm7_valid  <= lm_v(7);  



  lm0_a_cmp_en <= lm0_valid ;
  lm0_b_cmp_en <= lm0_valid ;
  lm0_c_cmp_en <= lm0_valid ;
  lm0_t_cmp_en <= lm0_valid ;

  lm1_a_cmp_en <= lm1_valid ;
  lm1_b_cmp_en <= lm1_valid ;
  lm1_c_cmp_en <= lm1_valid ;
  lm1_t_cmp_en <= lm1_valid ;

  lm2_a_cmp_en <= lm2_valid ;
  lm2_b_cmp_en <= lm2_valid ;
  lm2_c_cmp_en <= lm2_valid ;
  lm2_t_cmp_en <= lm2_valid ;

  lm3_a_cmp_en <= lm3_valid ;
  lm3_b_cmp_en <= lm3_valid ;
  lm3_c_cmp_en <= lm3_valid ;
  lm3_t_cmp_en <= lm3_valid ;

  lm4_a_cmp_en <= lm4_valid ;
  lm4_b_cmp_en <= lm4_valid ;
  lm4_c_cmp_en <= lm4_valid ;
  lm4_t_cmp_en <= lm4_valid ;

  lm5_a_cmp_en <= lm5_valid ;
  lm5_b_cmp_en <= lm5_valid ;
  lm5_c_cmp_en <= lm5_valid ;
  lm5_t_cmp_en <= lm5_valid ;

  lm6_a_cmp_en <= lm6_valid ;
  lm6_b_cmp_en <= lm6_valid ;
  lm6_c_cmp_en <= lm6_valid ;
  lm6_t_cmp_en <= lm6_valid ;

  lm7_a_cmp_en <= lm7_valid ;
  lm7_b_cmp_en <= lm7_valid ;
  lm7_c_cmp_en <= lm7_valid ;
  lm7_t_cmp_en <= lm7_valid ;

  lmc_ex4_a_cmp_en <= lmc_ex4_v; 
  lmc_ex4_b_cmp_en <= lmc_ex4_v; 
  lmc_ex4_c_cmp_en <= lmc_ex4_v; 

  is2_a_cmp_en <= is2_frt_v ;
  is2_b_cmp_en <= is2_frt_v ; 
  is2_c_cmp_en <= is2_frt_v ;

  rf0_a_cmp_en <= rf0_frt_v ;
  rf0_b_cmp_en <= rf0_frt_v ; 
  rf0_c_cmp_en <= rf0_frt_v ;

  rf1_a_cmp_en <= rf1_frt_v ;
  rf1_b_cmp_en <= rf1_frt_v ;
  rf1_c_cmp_en <= rf1_frt_v ;

  ex1_a_cmp_en <= ex1_frt_v ;
  ex1_b_cmp_en <= ex1_frt_v ;
  ex1_c_cmp_en <= ex1_frt_v ;

  ex2_a_cmp_en <= ex2_frt_v ;
  ex2_b_cmp_en <= ex2_frt_v ;
  ex2_c_cmp_en <= ex2_frt_v ;

  ex3_a_cmp_en <= ex3_frt_v and (dis_byp_is1 or is1_store_v or ex3_ld_v) ;
  ex3_b_cmp_en <= ex3_frt_v and (dis_byp_is1 or is1_store_v or ex3_ld_v) ;
  ex3_c_cmp_en <= ex3_frt_v and (dis_byp_is1 or ex3_ld_v) ;

  ex4_a_cmp_en <= ex4_frt_v and (dis_byp_is1 or (is1_store_v and ex4_ld_v));
  ex4_b_cmp_en <= ex4_frt_v and (dis_byp_is1 or (is1_store_v and ex4_ld_v));
  ex4_c_cmp_en <= ex4_frt_v and  dis_byp_is1 ;
  
  
  is2_u_cmp_en <= is2_frt_v ;
  rf0_u_cmp_en <= rf0_frt_v ;
  rf1_u_cmp_en <= rf1_frt_v ;
  ex1_u_cmp_en <= ex1_frt_v ;
  ex2_u_cmp_en <= ex2_frt_v ;
  ex3_u_cmp_en <= ex3_frt_v ;
  ex4_u_cmp_en <= ex4_frt_v ;


  a_group_en <= is1_fra_v  and is1_instr_v ;
  c_group_en <= is1_frc_v  and is1_instr_v ;
  b_group_en <= is1_frb_v  and is1_instr_v ;
  u_group_en <= uc_end_is1 and is1_instr_v ;
  t_group_en <= is1_frt_v  and is1_instr_v ;

  
    raw_fra_hit_b <=  a_or_4_b;
    raw_frb_hit_b <=  b_or_4_b;
    raw_frc_hit_b <=  c_or_4_b;

    raw_frb_uc_hit_b <= u_or_4_b;
    is1_lmq_waw_hit_b <= t_or_4_b;

    
end iuq_axu_fu_dep_cmp;

