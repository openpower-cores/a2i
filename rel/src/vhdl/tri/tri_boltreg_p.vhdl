-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

-- *!****************************************************************
-- *! FILENAME    : tri_boltreg_p.vhdl
-- *! DESCRIPTION : Multi-bit latch, LCB included
-- *!               Same as tri_rlmreg_p, but different name for lcb
-- *!               for relaxed timing
-- *!
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;
library ibm; 
library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;

entity tri_boltreg_p is

  generic (
    width       : integer := 4;
    offset      : integer range 0 to 65535 := 0 ; --starting bit
    init        : integer := 0;  -- will be converted to the least signficant
                                 -- 31 bits of init_v
    ibuf        : boolean := false;       --inverted latch IOs, if set to true.
    dualscan    : string  := ""; -- if "S", marks data ports as scan for Moebius
    needs_sreset: integer := 1 ; -- for inferred latches
    expand_type : integer := 1 );-- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)

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
    din     : in  std_ulogic_vector(offset to offset+width-1);  -- data in
    scout   : out std_ulogic_vector(offset to offset+width-1);
    dout    : out std_ulogic_vector(offset to offset+width-1) );

end entity tri_boltreg_p;

architecture tri_boltreg_p of tri_boltreg_p is

  constant init_v : std_ulogic_vector(0 to width-1) := std_ulogic_vector( to_unsigned( init, width ) );
  constant zeros : std_ulogic_vector(0 to width-1) := (0 to width-1 => '0');

begin  -- tri_boltreg_p

  -- synopsys translate_off
  um: if expand_type = 0 generate
    component c_rlmreg_p
      generic ( width    : positive  := 4 ;          --bit width value
            init     : std_ulogic_vector := "0"; --latch initialization
            dualscan : string := ""              -- if "S", marks data ports as scan for Moebius
          );
    port (
         nclk        : in  std_ulogic;        -- chip global clock signal
         act         : in  std_ulogic;        -- 1: functional, 0: no clock
         thold_b     : in  std_ulogic;        -- 1: functional, 0: stop the clock.
         sg          : in  std_ulogic;        -- 0: functional, 1: scan
         scin        : in  std_ulogic_vector(0 to width-1);  -- scan in
         din         : in  std_ulogic_vector(0 to width-1);  -- data in
         dout        : out std_ulogic_vector(0 to width-1);  -- data out
         scout       : out std_ulogic_vector(0 to width-1)   -- scan out
       );
    end component;
    signal scanin_inv : std_ulogic_vector(0 to width-1);
    signal scanout_inv : std_ulogic_vector(0 to width-1);
    signal act_or_force : std_ulogic;
    signal din_buf : std_ulogic_vector(0 to width-1);
    signal dout_buf : std_ulogic_vector(0 to width-1);
  begin
    act_or_force <= act or forcee;

    cib: --insert inverters at latch IO if ibuf=true
    if ibuf = true generate
      din_buf  <= not din;
      dout     <= not dout_buf;
    end generate cib;
    cnib: -- no inverters at latch IO if ibuf=false (default)
    if ibuf = false generate
      din_buf  <= din;
      dout     <= dout_buf;
    end generate cnib;

    l:c_rlmreg_p
      generic map (width => width, init  => init_v, dualscan => dualscan)
      port map (
        nclk    => nclk.clk,
        act     => act_or_force,
        thold_b => thold_b,
        sg      => sg,
        scin    => scanin_inv,
        din     => din_buf,
        scout   => scanout_inv,
        dout    => dout_buf);

    scanin_inv <= scin xor init_v;
    scout <= scanout_inv xor init_v;
  end generate um;
  -- synopsys translate_on

  a: if expand_type = 1 generate
    signal sreset : std_ulogic;
    signal int_din : std_ulogic_vector(0 to width-1);
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

    cib: if ibuf = true generate
      int_din <= (vsreset_b and not din) or
                 (vsreset and init_v);
    end generate cib;
    cnib: if ibuf = false generate
      int_din <= (vsreset_b and din) or
                 (vsreset and init_v);
    end generate cnib;

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

    cob: if ibuf = true generate 
	dout <= not int_dout;
    end generate cob;

    cnob: if ibuf = false generate 
	dout <= int_dout;
    end generate cnob;

    scout <= zeros;

    unused(0) <= d_mode or sg or delay_lclkr or mpw1_b or mpw2_b;
    unused(1 to width) <= scin;
  end generate a;

end tri_boltreg_p;
