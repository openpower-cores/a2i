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


library ieee; use ieee.std_logic_1164.all;
library support; 
                 use support.power_logic_pkg.all;

entity xuq_lsu_mux41 is
  port (
        vdd             :inout power_logic;
        gnd             :inout power_logic;
        D0              :in  std_ulogic;
        D1              :in  std_ulogic;
        D2              :in  std_ulogic;
        D3              :in  std_ulogic; 
        S0              :in  std_ulogic;
        S1              :in  std_ulogic;
        S2              :in  std_ulogic;
        S3              :in  std_ulogic; 
        Y               :out std_ulogic
  );



end entity xuq_lsu_mux41;

architecture xuq_lsu_mux41 of xuq_lsu_mux41 is

signal y0_b     :std_ulogic;
signal y1_b     :std_ulogic;


begin

u_y0: y0_b <= not( (D0 and S0) or (D1 and S1) );
u_y1: y1_b <= not( (D2 and S2) or (D3 and S3) );
u_y:  Y    <= not(y0_b and y1_b);

end xuq_lsu_mux41;

