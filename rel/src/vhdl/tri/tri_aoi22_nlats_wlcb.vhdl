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
-- *! FILENAME    : tri_aoi22_nlats_wlcb.vhdl
-- *! DESCRIPTION : Multi-bit aoi22-latch, LCB included
-- *!
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_aoi22_nlats_wlcb is

  generic (
    width       : integer := 4;
    offset      : integer range 0 to 65535 := 0 ; --starting bit
    init        : integer := 0;  -- will be converted to the least signficant
                                 -- 31 bits of init_v
    ibuf        : boolean := false;       --inverted latch IOs, if set to true.
    dualscan    : string  := ""; -- if "S", marks data ports as scan for Moebius
    needs_sreset: integer := 1 ; -- for inferred latches
    expand_type : integer := 1 ; -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    synthclonedlatch   : string                    := "" ;
    btr                : string                    := "NLL0001_X2_A12TH" );

  port (
    vd      : inout power_logic;
    gd      : inout power_logic;
    nclk    : in  clk_logic;
    act     : in  std_ulogic := '1'; -- 1: functional, 0: no clock
    forcee   : in  std_ulogic := '0'; -- 1: force LCB active
    thold_b : in  std_ulogic := '1'; -- 1: functional, 0: no clock
    d_mode  : in  std_ulogic := '0'; -- 1: disable pulse mode, 0: pulse mode
    sg      : in  std_ulogic := '0'; -- 0: functional, 1: scan
    delay_lclkr : in  std_ulogic := '0'; -- 0: functional
    mpw1_b  : in  std_ulogic := '1'; -- pulse width control bit
    mpw2_b  : in  std_ulogic := '1'; -- pulse width control bit
    scin    : in  std_ulogic_vector(offset to offset+width-1);  -- scan in
    scout   : out std_ulogic_vector(offset to offset+width-1);
    A1       : in    std_ulogic_vector(offset to offset+width-1); 
    A2       : in    std_ulogic_vector(offset to offset+width-1); 
    B1       : in    std_ulogic_vector(offset to offset+width-1); 
    B2       : in    std_ulogic_vector(offset to offset+width-1); 
    QB       : out   std_ulogic_vector(offset to offset+width-1));

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_aoi22_nlats_wlcb;

architecture tri_aoi22_nlats_wlcb of tri_aoi22_nlats_wlcb is

  constant init_v : std_ulogic_vector(0 to width-1) := std_ulogic_vector( to_unsigned( init, width ) );
  constant zeros : std_ulogic_vector(0 to width-1) := (0 to width-1 => '0');

begin

  a: if expand_type = 1 generate
    signal sreset : std_ulogic;
    signal int_din, din : std_ulogic_vector(0 to width-1);
    signal int_dout : std_ulogic_vector(0 to width-1) := init_v;
    signal vact, vact_b : std_ulogic_vector(0 to width-1);
    signal vsreset, vsreset_b : std_ulogic_vector(0 to width-1);
    signal vthold, vthold_b : std_ulogic_vector(0 to width-1);
    signal unused : std_ulogic_vector(0 to width);
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    rst: if needs_sreset = 1 generate
        sreset <= nclk.sreset;
    end generate rst;
    no_rst: if needs_sreset /=1 generate
        sreset <= '0';
    end generate no_rst;

    vsreset <= (0 to width-1 => sreset);
    vsreset_b <= (0 to width-1 => not sreset);

    din   <= (A1 and A2) or (B1 and B2) ;       -- Output is inverted, so just AND-OR here
    int_din <= (vsreset_b and din) or
               (vsreset and init_v);

    vact <= (0 to width-1 => (act or forcee));
    vact_b <= (0 to width-1 => not (act or forcee));

    vthold_b <= (0 to width-1 => thold_b);
    vthold   <= (0 to width-1 => not thold_b);

    l: process (nclk, vact, int_din, vact_b, int_dout, vsreset, vsreset_b, vthold_b, vthold)
    begin
      if rising_edge(nclk.clk) then
        int_dout <= (((vact and vthold_b) or vsreset) and int_din) or
                    (((vact_b or vthold) and vsreset_b) and int_dout);
      end if;
    end process l;

    QB <= not int_dout;

    scout <= zeros;

    unused(0) <= d_mode or sg or delay_lclkr or mpw1_b or mpw2_b;
    unused(1 to width) <= scin;
  end generate a;

end tri_aoi22_nlats_wlcb;
