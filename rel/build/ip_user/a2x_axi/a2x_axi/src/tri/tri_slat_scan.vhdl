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

entity tri_slat_scan is

  generic ( width              : positive range 1 to 65536 := 1 ;
            offset             : natural  range 0 to 65535 := 0;
            init               : std_ulogic_vector         := "0" ;
            synthclonedlatch   : string                    := "" ;
            btr                : string                    := "c_slat_scan" ;
            reset_inverts_scan : boolean                   := true;
            expand_type : integer := 1 ); 
  port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        dclk     : in    std_ulogic;
        lclk     : in    clk_logic;
        scan_in  : in    std_ulogic_vector(offset to offset+width-1);
        scan_out : out   std_ulogic_vector(offset to offset+width-1);
        q        : out   std_ulogic_vector(offset to offset+width-1);
        q_b      : out   std_ulogic_vector(offset to offset+width-1)
       );

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_slat_scan;

architecture tri_slat_scan of tri_slat_scan is

begin

  a: if expand_type = 1 generate
    constant zeros : std_ulogic_vector(0 to width-1) := (0 to width-1 => '0');
    constant initv : std_ulogic_vector(0 to (init'length + width-1)):=init & (0 to width-1=>'0');
    signal  unused : std_ulogic_vector(0 to width);
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    scan_out <= zeros;
    q <= initv(0 to width-1);
    q_b <= not initv(0 to width-1);
    unused(0) <= dclk;
    unused(1 to width) <= scan_in;
  end generate a;

end tri_slat_scan;

