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
-- *! FILENAME    : tri_err_rpt.vhdl
-- *! DESCRIPTION : Error Reporting Component
-- *!
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_err_rpt is

  generic (
      width        : positive := 1;               -- number of errors of the same type
      mask_reset_value : std_ulogic_vector := "0";-- use to set default/flush value for mask bits
      inline       : boolean := false;            -- make hold latch be inline; err_out is sticky -- default to shadow
      share_mask   : boolean := false;            -- PERMISSION NEEDED for true
                                                  -- used for width >1 to reduce area of mask (common error disable)
      use_nlats    : boolean := false;            -- only necessary in standby area to be able to reset to init value
      needs_sreset : integer := 1 ;        -- for inferred latches
      expand_type  : integer := 1 );       -- 1 = non-ibm, 2 = ibm (MPG)

  port (
      vd            : inout power_logic;
      gd            : inout power_logic;
      err_d1clk     : in  std_ulogic;           -- caution: if lcb uses powersavings, errors must always get reported
      err_d2clk     : in  std_ulogic;
      err_lclk      : in  clk_logic;
      -- error scan chain (func or mode)
      err_scan_in   : in  std_ulogic_vector(0 to width-1);
      err_scan_out  : out std_ulogic_vector(0 to width-1);
      -- clock gateable mode clocks
      mode_dclk     : in  std_ulogic;
      mode_lclk     : in  clk_logic;
      -- mode scan chain
      mode_scan_in  : in  std_ulogic_vector(0 to width-1);
      mode_scan_out : out std_ulogic_vector(0 to width-1);

      err_in        : in  std_ulogic_vector(0 to width-1);
      err_out       : out std_ulogic_vector(0 to width-1);

      hold_out      : out std_ulogic_vector(0 to width-1); -- sticky error hold latch for trap usage
      mask_out      : out std_ulogic_vector(0 to width-1)
  );
  -- synopsys translate_off

  -- synopsys translate_on

end tri_err_rpt;

architecture tri_err_rpt of tri_err_rpt is

begin  -- tri_err_rpt

  a: if expand_type /= 2 generate
    constant mask_initv : std_ulogic_vector(0 to (mask_reset_value'length + width-1)):=mask_reset_value & (0 to width-1=>'0');
    signal hold_in      : std_ulogic_vector(0 to width-1);
    signal hold_lt      : std_ulogic_vector(0 to width-1);
    signal mask_lt      : std_ulogic_vector(0 to width-1);
    signal unused : std_ulogic_vector(0 to width);
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    -- hold latches
    hold_in  <= err_in or hold_lt;

    hold: entity tri.tri_nlat_scan
    generic map( width => width,
                 needs_sreset => needs_sreset,
                 expand_type => expand_type )
    port map
     ( vd        => vd,
       gd        => gd,
       d1clk     => err_d1clk,
       d2clk     => err_d2clk,
       lclk      => err_lclk,
       scan_in   => err_scan_in(0 to width-1),
       scan_out  => err_scan_out(0 to width-1),
       din       => hold_in,
       q         => hold_lt,
       q_b       => open
     );

    -- mask
    m: if (share_mask = false) generate
        mask_lt <= mask_initv(0 to width-1);
    end generate m;
    sm: if (share_mask = true) generate
        mask_lt <= (others => mask_initv(0));
    end generate sm;

    mode_scan_out <= (others => '0');

    -- assign outputs
    hold_out <= hold_lt;
    mask_out <= mask_lt;

    inline_hold: if (inline = true) generate
        err_out <= hold_lt and not mask_lt;
    end generate inline_hold;

    side_hold: if (inline = false) generate
        err_out <= err_in and not mask_lt;
    end generate side_hold;

    unused(0) <= mode_dclk;
    unused(1 to width) <= mode_scan_in;
  end generate a;

end tri_err_rpt;
