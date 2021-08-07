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
-- *! FILENAME    : tri_nlat_scan.vhdl
-- *! DESCRIPTION : Basic n-bit latch
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_nlat_scan is

  generic ( offset             : natural  range 0 to 65535 := 0;
            width              : positive range 1 to 65536 := 1 ;
            init               : std_ulogic_vector         := "0" ;
            reset_inverts_scan : boolean                   := true;
            synthclonedlatch   : string                    := "" ;
            needs_sreset : integer := 1 ; -- for inferred latches
            expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
  port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        d1clk    : in    std_ulogic;
        d2clk    : in    std_ulogic;
        lclk     : in    clk_logic;
        din      : in    std_ulogic_vector(offset to offset+width-1);
        scan_in  : in    std_ulogic_vector(offset to offset+width-1);
        q        : out   std_ulogic_vector(offset to offset+width-1);
        q_b      : out   std_ulogic_vector(offset to offset+width-1);
        scan_out : out   std_ulogic_vector(offset to offset+width-1)
       );

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_nlat_scan;

architecture tri_nlat_scan of tri_nlat_scan is

begin

  a: if expand_type = 1 generate
    constant init_v : std_ulogic_vector(0 to (init'length + width-1)):=init & (0 to width-1=>'0');
    constant zeros : std_ulogic_vector(0 to width-1) := (0 to width-1 => '0');

    signal sreset : std_ulogic;
    signal int_din : std_ulogic_vector(0 to width-1);
    signal int_dout : std_ulogic_vector(0 to width-1) := init_v(0 to width-1);
    signal vact, vact_b : std_ulogic_vector(0 to width-1);
    signal vsreset, vsreset_b : std_ulogic_vector(0 to width-1);
    signal vthold, vthold_b : std_ulogic_vector(0 to width-1);
    signal unused : std_ulogic_vector(0 to width-1);
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    rst: if needs_sreset = 1 generate
        sreset <= lclk.sreset;
    end generate rst;
    no_rst: if needs_sreset /=1 generate
        sreset <= '0';
    end generate no_rst;

    vsreset <= (0 to width-1 => sreset);
    vsreset_b <= (0 to width-1 => not sreset);
    int_din <= (vsreset_b and din) or
               (vsreset and init_v(0 to width-1));

    vact <= (0 to width-1 => d1clk);
    vact_b <= (0 to width-1 => not d1clk);

    vthold_b <= (0 to width-1 => d2clk);
    vthold   <= (0 to width-1 => not d2clk);

    l: process (lclk, vact, int_din, vact_b, int_dout, vsreset, vsreset_b, vthold_b, vthold)
    begin
      if rising_edge(lclk.clk) then
        int_dout <= (((vact and vthold_b) or vsreset) and int_din) or
                    (((vact_b or vthold) and vsreset_b) and int_dout);
      end if;
    end process l;
    q <= int_dout;
    q_b <= not int_dout;
    scan_out <= zeros;
    unused <= scan_in;
  end generate a;

end tri_nlat_scan;
