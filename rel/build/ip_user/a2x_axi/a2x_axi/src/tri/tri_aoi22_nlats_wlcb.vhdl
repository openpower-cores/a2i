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

entity tri_aoi22_nlats_wlcb is

  generic (
    width       : integer := 4;
    offset      : integer range 0 to 65535 := 0 ; 
    init        : integer := 0;  
    ibuf        : boolean := false;       
    dualscan    : string  := ""; 
    needs_sreset: integer := 1 ; 
    expand_type : integer := 1 ; 
    synthclonedlatch   : string                    := "" ;
    btr                : string                    := "NLL0001_X2_A12TH" );

  port (
    vd      : inout power_logic;
    gd      : inout power_logic;
    nclk    : in  clk_logic;
    act     : in  std_ulogic := '1'; 
    forcee   : in  std_ulogic := '0'; 
    thold_b : in  std_ulogic := '1'; 
    d_mode  : in  std_ulogic := '0'; 
    sg      : in  std_ulogic := '0'; 
    delay_lclkr : in  std_ulogic := '0'; 
    mpw1_b  : in  std_ulogic := '1'; 
    mpw2_b  : in  std_ulogic := '1'; 
    scin    : in  std_ulogic_vector(offset to offset+width-1);  
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

    din   <= (A1 and A2) or (B1 and B2) ;       
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

