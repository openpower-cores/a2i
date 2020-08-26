-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

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
