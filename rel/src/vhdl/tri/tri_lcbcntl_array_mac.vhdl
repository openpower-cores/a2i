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

-- *!****************************************************************
-- *! FILENAME    : tri_lcbcntl_array_mac.vhdl
-- *! DESCRIPTION : Used to generate control signals for LCBs
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_lcbcntl_array_mac is

  generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)

  port (
        vdd            : inout power_logic;
        gnd            : inout power_logic;
        sg             : in    std_ulogic;
        nclk           : in    clk_logic;
        scan_in        : in    std_ulogic;
        scan_diag_dc   : in    std_ulogic;
        thold          : in    std_ulogic;
        clkoff_dc_b    : out   std_ulogic;
        delay_lclkr_dc : out   std_ulogic_vector(0 to 4);
        act_dis_dc     : out   std_ulogic;
        d_mode_dc      : out   std_ulogic;
        mpw1_dc_b      : out   std_ulogic_vector(0 to 4);
        mpw2_dc_b      : out   std_ulogic;
        scan_out       : out   std_ulogic
       );

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_lcbcntl_array_mac;

architecture tri_lcbcntl_array_mac of tri_lcbcntl_array_mac is

  signal unused : std_ulogic;
  -- synopsys translate_off
  -- synopsys translate_on

begin

  a: if expand_type = 1 generate
      clkoff_dc_b <= '1';
      delay_lclkr_dc <= "00000";
      act_dis_dc <= '0';
      d_mode_dc <= '0';
      mpw1_dc_b <= "11111";
      mpw2_dc_b <= '1';
      scan_out <= '0';
      unused <= sg or scan_in or scan_diag_dc or thold;
  end generate a;

end tri_lcbcntl_array_mac;
