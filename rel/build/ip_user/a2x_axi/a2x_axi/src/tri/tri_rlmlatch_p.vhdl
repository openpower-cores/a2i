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

entity tri_rlmlatch_p is

  generic (
    init        : integer := 0;  
    ibuf        : boolean := false;       
    dualscan    : string  := ""; 
    needs_sreset: integer := 1 ; 
    expand_type : integer := 1 );

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
    scin    : in  std_ulogic := '0'; 
    din     : in  std_ulogic;        
    scout   : out std_ulogic;        
    dout    : out std_ulogic);       

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_rlmlatch_p;

architecture tri_rlmlatch_p of tri_rlmlatch_p is

  constant width : integer := 1;
  constant offset : natural := 0;
  constant init_v : std_ulogic_vector(0 to width-1) := std_ulogic_vector( to_unsigned( init, width ) );
  constant zeros : std_ulogic_vector(0 to width-1) := (0 to width-1 => '0');

begin  

  -- synopsys translate_off
  um: if expand_type = 0 generate
    component c_rlmreg_p
      generic ( width    : positive  := 4 ;          
            init     : std_ulogic_vector := "0"; 
            dualscan : string := ""              
          );
    port (
         nclk        : in  std_ulogic;        
         act         : in  std_ulogic;        
         thold_b     : in  std_ulogic;        
         sg          : in  std_ulogic;        
         scin        : in  std_ulogic_vector(0 to width-1);  
         din         : in  std_ulogic_vector(0 to width-1);  
         dout        : out std_ulogic_vector(0 to width-1);  
         scout       : out std_ulogic_vector(0 to width-1)   
       );
    end component;
    signal scanin_inv : std_ulogic;
    signal scanout_inv : std_ulogic;
    signal act_or_force : std_ulogic;
    signal din_buf : std_ulogic;
    signal dout_buf : std_ulogic;
  begin
    act_or_force <= act or forcee;

    cib: 
    if ibuf = true generate
      din_buf  <= not din;
      dout     <= not dout_buf;
    end generate cib;
    cnib: 
    if ibuf = false generate
      din_buf  <= din;
      dout     <= dout_buf;
    end generate cnib;

    l:c_rlmreg_p
      generic map (width => width, init  => init_v, dualscan => dualscan)
      port map (
        nclk       => nclk.clk,
        act        => act_or_force,
        thold_b    => thold_b,
        sg         => sg,
        scin(0)    => scanin_inv,
        din(0)     => din_buf,
        scout(0)   => scanout_inv,
        dout(0)    => dout_buf);

    scanin_inv <= scin xor init_v(0);
    scout <= scanout_inv xor init_v(0);
  end generate um;
  -- synopsys translate_on

  a: if expand_type = 1 generate
    signal sreset : std_ulogic;
    signal int_din : std_ulogic;
    signal int_dout : std_ulogic := init_v(0);
    signal unused : std_ulogic;
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    rst: if needs_sreset = 1 generate
        sreset <= nclk.sreset;
    end generate rst;
    no_rst: if needs_sreset /=1 generate
        sreset <= '0';
    end generate no_rst;

    cib: if ibuf = true generate
      int_din <= (not sreset and not din) or
                 (sreset and init_v(0));
    end generate cib;
    cnib: if ibuf = false generate
      int_din <= (not sreset and din) or
                 (sreset and init_v(0));
    end generate cnib;

    l: process (nclk, act, forcee, int_din, int_dout, sreset, thold_b)
    begin
      if rising_edge(nclk.clk) then
        int_dout <= ( (((act or forcee) and thold_b) or sreset ) and int_din ) or
                    ( ((not act and not forcee) or not thold_b) and not sreset and int_dout);
      end if;
    end process l;

    cob: if ibuf = true generate 
	dout <= not int_dout;
    end generate cob;

    cnob: if ibuf = false generate 
	dout <= int_dout;
    end generate cnob;

    scout <= zeros(0);

    unused <= d_mode or sg or delay_lclkr or mpw1_b or mpw2_b or scin;
  end generate a;

end tri_rlmlatch_p;

