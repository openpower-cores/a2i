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
              use ieee.numeric_std.all;

library support;                  use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_direct_err_rpt is

  generic (
      width         : positive := 1 ;      
      expand_type   : integer  := 1 );     
  port (
      vd            : inout power_logic;
      gd            : inout power_logic;

      err_in        : in  std_ulogic_vector(0 to width-1);
      err_out       : out std_ulogic_vector(0 to width-1)
  );
  -- synopsys translate_off

  -- synopsys translate_on

end tri_direct_err_rpt;

architecture tri_direct_err_rpt of tri_direct_err_rpt is

begin  

  a: if expand_type /= 2 generate
  begin
    err_out <= err_in;
  end generate a;

end tri_direct_err_rpt;

