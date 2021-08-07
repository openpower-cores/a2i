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



library ieee; use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 


entity xuq_agen_csmux is port(
     sum_0      :in  std_ulogic_vector(0 to 7) ; 
     sum_1      :in  std_ulogic_vector(0 to 7) ;
     ci_b       :in  std_ulogic ;
     sum        :out std_ulogic_vector(0 to 7)
 );


END                                 xuq_agen_csmux;


ARCHITECTURE xuq_agen_csmux  OF xuq_agen_csmux  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

 signal sum0_b, sum1_b :std_ulogic_vector(0 to 7);
 signal int_ci, int_ci_t, int_ci_b :std_ulogic;








BEGIN

 u_ci:  int_ci   <= not ci_b;
 u_cit: int_ci_t <= not ci_b;
 u_cib: int_ci_b <= not int_ci_t;

 u_sum0_0: sum0_b(0) <= not( sum_0(0) and int_ci_b );
 u_sum0_1: sum0_b(1) <= not( sum_0(1) and int_ci_b );
 u_sum0_2: sum0_b(2) <= not( sum_0(2) and int_ci_b );
 u_sum0_3: sum0_b(3) <= not( sum_0(3) and int_ci_b );
 u_sum0_4: sum0_b(4) <= not( sum_0(4) and int_ci_b );
 u_sum0_5: sum0_b(5) <= not( sum_0(5) and int_ci_b );
 u_sum0_6: sum0_b(6) <= not( sum_0(6) and int_ci_b );
 u_sum0_7: sum0_b(7) <= not( sum_0(7) and int_ci_b );

 u_sum1_0: sum1_b(0) <= not( sum_1(0) and int_ci   );
 u_sum1_1: sum1_b(1) <= not( sum_1(1) and int_ci   );
 u_sum1_2: sum1_b(2) <= not( sum_1(2) and int_ci   );
 u_sum1_3: sum1_b(3) <= not( sum_1(3) and int_ci   );
 u_sum1_4: sum1_b(4) <= not( sum_1(4) and int_ci   );
 u_sum1_5: sum1_b(5) <= not( sum_1(5) and int_ci   );
 u_sum1_6: sum1_b(6) <= not( sum_1(6) and int_ci   );
 u_sum1_7: sum1_b(7) <= not( sum_1(7) and int_ci   );

 u_sum_0: sum(0) <= not( sum0_b(0) and sum1_b(0) );
 u_sum_1: sum(1) <= not( sum0_b(1) and sum1_b(1) );
 u_sum_2: sum(2) <= not( sum0_b(2) and sum1_b(2) );
 u_sum_3: sum(3) <= not( sum0_b(3) and sum1_b(3) );
 u_sum_4: sum(4) <= not( sum0_b(4) and sum1_b(4) );
 u_sum_5: sum(5) <= not( sum0_b(5) and sum1_b(5) );
 u_sum_6: sum(6) <= not( sum0_b(6) and sum1_b(6) );
 u_sum_7: sum(7) <= not( sum0_b(7) and sum1_b(7) );


END; 

