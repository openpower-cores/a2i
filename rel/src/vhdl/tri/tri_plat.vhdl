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
-- *! FILENAME    : tri_plat.vhdl
-- *! DESCRIPTION : Non-scannable pipeline latch
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_plat is

  generic (
    width       : positive range 1 to 65536 := 1 ;
    offset      : natural range 0 to 65535  := 0 ;
    init        : integer := 0;  -- will be converted to the least signficant 31 bits of init_v
    synthclonedlatch : string                    := "" ;
    flushlat         : boolean                   := true ;
    expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)

  port (
    vd      : inout power_logic;
    gd      : inout power_logic;
    nclk    : in    clk_logic;
    flush   : in    std_ulogic;
    din     : in    std_ulogic_vector(offset to offset+width-1);
    q       : out   std_ulogic_vector(offset to offset+width-1) );

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_plat;

architecture tri_plat of tri_plat is

  constant init_v : std_ulogic_vector(0 to width-1) := std_ulogic_vector( to_unsigned( init, width ) );

begin  -- tri_plat

  a: if expand_type /= 2 generate
    signal int_din : std_ulogic_vector(0 to width-1);
    signal int_dout : std_ulogic_vector(0 to width-1) := init_v;
    signal vsreset, vsreset_b : std_ulogic_vector(0 to width-1);
  begin

    vsreset <= (0 to width-1 => nclk.sreset);
    vsreset_b <= (0 to width-1 => not nclk.sreset);

    int_din <= (vsreset_b and din) or
               (vsreset and init_v);

    l: process (nclk, int_din, flush, din)
    begin

      if rising_edge(nclk.clk) then
        int_dout <= int_din;
      end if;

      if (flush = '1') then
        int_dout <= din;
      end if;

    end process l;

    q <= int_dout;

  end generate a;

end tri_plat;
