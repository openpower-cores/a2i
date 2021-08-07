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

ENTITY c_prism_bthmx IS
    GENERIC ( btr : string := "BTHMX_X1_A12TH"  );
    PORT(
     X      : IN  STD_ULOGIC;
     SNEG   : IN  STD_ULOGIC; 
     SX     : IN  STD_ULOGIC; 
     SX2    : IN  STD_ULOGIC; 
     RIGHT  : IN  STD_ULOGIC; 
     LEFT   : OUT STD_ULOGIC; 
     Q      : OUT STD_ULOGIC; 
     vd     : inout power_logic;
     gd     : inout power_logic
  );

-- synopsys translate_off


    ATTRIBUTE PIN_BIT_INFORMATION of c_prism_bthmx : entity is
      (
        1 => ("   ","X       ","SAME","PIN_BIT_SCALAR"),
        2 => ("   ","SNEG    ","SAME","PIN_BIT_SCALAR"),
        3 => ("   ","SX      ","SAME","PIN_BIT_SCALAR"),
        4 => ("   ","SX2     ","SAME","PIN_BIT_SCALAR"),
        5 => ("   ","RIGHT   ","SAME","PIN_BIT_SCALAR"),
        6 => ("   ","LEFT    ","SAME","PIN_BIT_SCALAR"),
        7 => ("   ","Q       ","SAME","PIN_BIT_SCALAR"),
        8 => ("   ","VDD     ","SAME","PIN_BIT_SCALAR"),
        9 => ("   ","VSS     ","SAME","PIN_BIT_SCALAR")
        );
-- synopsys translate_on
END                               c_prism_bthmx;

ARCHITECTURE c_prism_bthmx OF c_prism_bthmx IS

   SIGNAL CENTER :STD_ULOGIC;
   SIGNAL XN     :STD_ULOGIC;
   SIGNAL SPOS   :STD_ULOGIC;


BEGIN

   XN <= NOT X;

   SPOS <= NOT SNEG;

   CENTER <= NOT( ( XN AND SPOS ) OR 
                  ( X  AND SNEG )   );

   LEFT <= CENTER; 


   Q <= ( CENTER AND  SX  ) OR 
        ( RIGHT  AND  SX2 ) ;


END;





