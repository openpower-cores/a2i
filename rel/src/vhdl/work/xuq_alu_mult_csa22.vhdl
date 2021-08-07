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


ENTITY xuq_alu_mult_csa22 IS
  PORT(
   a       : IN  std_ulogic;
   b       : IN  std_ulogic;
   car     : OUT std_ulogic;
   sum     : OUT std_ulogic
  );
END                               xuq_alu_mult_csa22;

ARCHITECTURE xuq_alu_mult_csa22 OF xuq_alu_mult_csa22 IS

    signal car_b, sum_b : std_ulogic;


BEGIN

  u_22nandc: car_b <= not( a and b );
  u_22nands: sum_b <= not( car_b and (a or b) ); -- this is equiv to an xnor
  u_22invc:  car   <= not car_b;
  u_22invs:  sum   <= not sum_b ;

END;
