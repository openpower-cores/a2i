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
library support; use support.power_logic_pkg.all;

ENTITY c_prism_csa32 IS
   GENERIC ( btr : string := "CSA32_A2_A12TH" );
   PORT(
   A       : IN  std_ulogic;
   B       : IN  std_ulogic;
   C       : IN  std_ulogic;
   CAR     : OUT std_ulogic;
   SUM     : OUT std_ulogic;
   vd      : inout power_logic;
   gd      : inout power_logic
  );

-- synopsys translate_off


   ATTRIBUTE PIN_BIT_INFORMATION of c_prism_csa32 : entity is
     (
       1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
       2 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
       3 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
       4 => ("   ","CAR     ","SAME","PIN_BIT_SCALAR"),
       5 => ("   ","SUM     ","SAME","PIN_BIT_SCALAR"),
       6 => ("   ","VDD     ","SAME","PIN_BIT_SCALAR"),
       7 => ("   ","VSS     ","SAME","PIN_BIT_SCALAR")
       );
-- synopsys translate_on
END                               c_prism_csa32;

ARCHITECTURE c_prism_csa32 OF c_prism_csa32 IS


BEGIN

  sum <= a  XOR b  XOR c ;

  car <= (a  AND b ) OR
         (a  AND c ) OR
         (b  AND c );


END;





