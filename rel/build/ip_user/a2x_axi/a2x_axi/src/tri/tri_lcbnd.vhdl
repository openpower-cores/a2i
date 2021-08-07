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

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_lcbnd is

  generic ( expand_type : integer := 1 ); 

  port (
        vd          : inout power_logic;
        gd          : inout power_logic;
        act         : in    std_ulogic;
        delay_lclkr : in    std_ulogic;
        mpw1_b      : in    std_ulogic;
        mpw2_b      : in    std_ulogic;
        nclk        : in    clk_logic;
        forcee       : in    std_ulogic;
        sg          : in    std_ulogic;
        thold_b     : in    std_ulogic;
        d1clk       : out   std_ulogic;
        d2clk       : out   std_ulogic;
        lclk        : out   clk_logic
       );

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_lcbnd;

architecture tri_lcbnd of tri_lcbnd is

begin

  a: if expand_type = 1 generate
    signal gate_b : std_ulogic;
    signal unused : std_ulogic;
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    gate_b <= forcee or act;

    d1clk <= gate_b;
    d2clk <= thold_b;
    lclk <= nclk;

    unused <= delay_lclkr or mpw1_b or mpw2_b or sg;
  end generate a;

end tri_lcbnd;

