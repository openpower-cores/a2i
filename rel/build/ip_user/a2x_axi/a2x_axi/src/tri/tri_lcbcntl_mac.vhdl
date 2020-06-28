-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_lcbcntl_mac is

  generic ( expand_type : integer := 1 ); 

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

end entity tri_lcbcntl_mac;

architecture tri_lcbcntl_mac of tri_lcbcntl_mac is

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

end tri_lcbcntl_mac;

