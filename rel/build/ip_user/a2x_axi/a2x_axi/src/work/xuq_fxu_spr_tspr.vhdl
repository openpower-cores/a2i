-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;
 
entity xuq_fxu_spr_tspr is
generic(
   hvmode                           :     integer := 1;
   a2mode                           :     integer := 1;
   expand_type                      :     integer := 2;
   regsize                          :     integer := 64;
   eff_ifar                         :     integer := 62);
port(
   nclk                             : in  clk_logic;
   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;
   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;
   
   cspr_tspr_ex2_instr              : in  std_ulogic_vector(11 to 20);
   tspr_cspr_ex2_tspr_rt            : out std_ulogic_vector(64-regsize to 63);

   ex6_val                          : in  std_ulogic;
   cspr_tspr_ex6_is_mtspr           : in  std_ulogic;
   cspr_tspr_ex6_instr              : in  std_ulogic_vector(11 to 20);
   ex6_spr_wd                       : in  std_ulogic_vector(64-regsize to 63);
   
   tspr_cspr_dbcr2_dac1us           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr2_dac1er           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr2_dac2us           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr2_dac2er           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr3_dac3us           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr3_dac3er           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr3_dac4us           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr3_dac4er           : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr2_dac12m           : out std_ulogic;
   tspr_cspr_dbcr3_dac34m           : out std_ulogic;
   tspr_cspr_dbcr2_dvc1m            : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr2_dvc2m            : out std_ulogic_vector(0 to 1);
   tspr_cspr_dbcr2_dvc1be           : out std_ulogic_vector(0 to 7);
   tspr_cspr_dbcr2_dvc2be           : out std_ulogic_vector(0 to 7);
	spr_dbcr3_ivc                    : out std_ulogic;

   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_fxu_spr_tspr;
architecture xuq_fxu_spr_tspr of xuq_fxu_spr_tspr is

subtype DO                            is std_ulogic_vector(65-regsize to 64);
signal dbcr2_d        , dbcr2_q        : std_ulogic_vector(35 to 63);
signal dbcr3_d        , dbcr3_q        : std_ulogic_vector(54 to 63);
constant dbcr2_offset                  : natural := 0;
constant dbcr3_offset                  : natural := dbcr2_offset    + dbcr2_q'length*a2mode;
constant last_reg_offset               : natural := dbcr3_offset    + dbcr3_q'length;
constant scan_right                    : integer := last_reg_offset;
signal siv                             : std_ulogic_vector(0 to scan_right-1);
signal sov                             : std_ulogic_vector(0 to scan_right-1);
signal tiup                            : std_ulogic;
signal tidn                            : std_ulogic_vector(00 to 63);
signal ex2_instr                       : std_ulogic_vector(11 to 20);
signal ex6_is_mtspr                    : std_ulogic;
signal ex6_instr                       : std_ulogic_vector(11 to 20);
signal spr_dbcr2_dac1us                : std_ulogic_vector(0 to 1);
signal spr_dbcr2_dac1er                : std_ulogic_vector(0 to 1);
signal spr_dbcr2_dac2us                : std_ulogic_vector(0 to 1);
signal spr_dbcr2_dac2er                : std_ulogic_vector(0 to 1);
signal spr_dbcr2_dac12m                : std_ulogic;
signal spr_dbcr2_dvc1m                 : std_ulogic_vector(0 to 1);
signal spr_dbcr2_dvc2m                 : std_ulogic_vector(0 to 1);
signal spr_dbcr2_dvc1be                : std_ulogic_vector(0 to 7);
signal spr_dbcr2_dvc2be                : std_ulogic_vector(0 to 7);
signal spr_dbcr3_dac3us                : std_ulogic_vector(0 to 1);
signal spr_dbcr3_dac3er                : std_ulogic_vector(0 to 1);
signal spr_dbcr3_dac4us                : std_ulogic_vector(0 to 1);
signal spr_dbcr3_dac4er                : std_ulogic_vector(0 to 1);
signal spr_dbcr3_dac34m                : std_ulogic;
signal ex6_dbcr2_di                    : std_ulogic_vector(dbcr2_q'range);
signal ex6_dbcr3_di                    : std_ulogic_vector(dbcr3_q'range);
signal
	ex2_dbcr2_rdec , ex2_dbcr3_rdec 
													: std_ulogic;
signal
	ex2_dbcr2_re   , ex2_dbcr3_re   
													: std_ulogic;
signal
	ex6_dbcr2_wdec , ex6_dbcr3_wdec 
													: std_ulogic;
signal
	ex6_dbcr2_we   , ex6_dbcr3_we   
													: std_ulogic;
signal
	dbcr2_act      , dbcr3_act      
													: std_ulogic;
signal
	dbcr2_do       , dbcr3_do       
													: std_ulogic_vector(0 to 64);

begin


tiup           <= '1';
tidn           <= (others=>'0');
ex2_instr      <= cspr_tspr_ex2_instr;
ex6_is_mtspr   <= cspr_tspr_ex6_is_mtspr;
ex6_instr      <= cspr_tspr_ex6_instr;
             
dbcr2_act      <= ex6_dbcr2_we;
dbcr2_d        <= ex6_dbcr2_di;

dbcr3_act      <= ex6_dbcr3_we;
dbcr3_d        <= ex6_dbcr3_di;

readmux_00 : if a2mode = 0 and hvmode = 0 generate
tspr_cspr_ex2_tspr_rt <=
	(dbcr3_do(DO'range)       and (DO'range => ex2_dbcr3_re   ));
end generate;
readmux_01 : if a2mode = 0 and hvmode = 1 generate
tspr_cspr_ex2_tspr_rt <=
	(dbcr3_do(DO'range)       and (DO'range => ex2_dbcr3_re   ));
end generate;
readmux_10 : if a2mode = 1 and hvmode = 0 generate
tspr_cspr_ex2_tspr_rt <=
	(dbcr2_do(DO'range)       and (DO'range => ex2_dbcr2_re   )) or
	(dbcr3_do(DO'range)       and (DO'range => ex2_dbcr3_re   ));
end generate;
readmux_11 : if a2mode = 1 and hvmode = 1 generate
tspr_cspr_ex2_tspr_rt <=
	(dbcr2_do(DO'range)       and (DO'range => ex2_dbcr2_re   )) or
	(dbcr3_do(DO'range)       and (DO'range => ex2_dbcr3_re   ));
end generate;

ex2_dbcr2_rdec    <= (ex2_instr(11 to 20) = "1011001001");   
ex2_dbcr3_rdec    <= (ex2_instr(11 to 20) = "1000011010");   
ex2_dbcr2_re      <=  ex2_dbcr2_rdec;
ex2_dbcr3_re      <=  ex2_dbcr3_rdec;

ex6_dbcr2_wdec    <= (ex6_instr(11 to 20) = "1011001001");   
ex6_dbcr3_wdec    <= (ex6_instr(11 to 20) = "1000011010");   
ex6_dbcr2_we      <= ex6_val and ex6_is_mtspr and  ex6_dbcr2_wdec;
ex6_dbcr3_we      <= ex6_val and ex6_is_mtspr and  ex6_dbcr3_wdec;

spr_dbcr2_dac1us           <= dbcr2_q(35 to 36);
spr_dbcr2_dac1er           <= dbcr2_q(37 to 38);
spr_dbcr2_dac2us           <= dbcr2_q(39 to 40);
spr_dbcr2_dac2er           <= dbcr2_q(41 to 42);
spr_dbcr2_dac12m           <= dbcr2_q(43);
spr_dbcr2_dvc1m            <= dbcr2_q(44 to 45);
spr_dbcr2_dvc2m            <= dbcr2_q(46 to 47);
spr_dbcr2_dvc1be           <= dbcr2_q(48 to 55);
spr_dbcr2_dvc2be           <= dbcr2_q(56 to 63);
spr_dbcr3_dac3us           <= dbcr3_q(54 to 55);
spr_dbcr3_dac3er           <= dbcr3_q(56 to 57);
spr_dbcr3_dac4us           <= dbcr3_q(58 to 59);
spr_dbcr3_dac4er           <= dbcr3_q(60 to 61);
spr_dbcr3_dac34m           <= dbcr3_q(62);
spr_dbcr3_ivc              <= dbcr3_q(63);
tspr_cspr_dbcr2_dac1us           <= spr_dbcr2_dac1us;
tspr_cspr_dbcr2_dac1er           <= spr_dbcr2_dac1er;
tspr_cspr_dbcr2_dac2us           <= spr_dbcr2_dac2us;
tspr_cspr_dbcr2_dac2er           <= spr_dbcr2_dac2er;
tspr_cspr_dbcr3_dac3us           <= spr_dbcr3_dac3us;
tspr_cspr_dbcr3_dac3er           <= spr_dbcr3_dac3er;
tspr_cspr_dbcr3_dac4us           <= spr_dbcr3_dac4us;
tspr_cspr_dbcr3_dac4er           <= spr_dbcr3_dac4er;
tspr_cspr_dbcr2_dac12m           <= spr_dbcr2_dac12m;
tspr_cspr_dbcr3_dac34m           <= spr_dbcr3_dac34m;
tspr_cspr_dbcr2_dvc1m            <= spr_dbcr2_dvc1m;
tspr_cspr_dbcr2_dvc2m            <= spr_dbcr2_dvc2m;
tspr_cspr_dbcr2_dvc1be           <= spr_dbcr2_dvc1be;
tspr_cspr_dbcr2_dvc2be           <= spr_dbcr2_dvc2be;

mark_unused(tiup);
mark_unused(tidn);
mark_unused(ex6_spr_wd);


ex6_dbcr2_di   <= ex6_spr_wd(32 to 33)             & 
						ex6_spr_wd(34 to 35)             & 
						ex6_spr_wd(36 to 37)             & 
						ex6_spr_wd(38 to 39)             & 
						ex6_spr_wd(41 to 41)             & 
						ex6_spr_wd(44 to 45)             & 
						ex6_spr_wd(46 to 47)             & 
						ex6_spr_wd(48 to 55)             & 
						ex6_spr_wd(56 to 63)             ; 
dbcr2_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & 
						dbcr2_q(35 to 36)                & 
						dbcr2_q(37 to 38)                & 
						dbcr2_q(39 to 40)                & 
						dbcr2_q(41 to 42)                & 
						tidn(40 to 40)                   & 
						dbcr2_q(43 to 43)                & 
						tidn(42 to 43)                   & 
						dbcr2_q(44 to 45)                & 
						dbcr2_q(46 to 47)                & 
						dbcr2_q(48 to 55)                & 
						dbcr2_q(56 to 63)                ; 
ex6_dbcr3_di   <= ex6_spr_wd(32 to 33)             & 
						ex6_spr_wd(34 to 35)             & 
						ex6_spr_wd(36 to 37)             & 
						ex6_spr_wd(38 to 39)             & 
						ex6_spr_wd(41 to 41)             & 
						ex6_spr_wd(63 to 63)             ; 
dbcr3_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & 
						dbcr3_q(54 to 55)                & 
						dbcr3_q(56 to 57)                & 
						dbcr3_q(58 to 59)                & 
						dbcr3_q(60 to 61)                & 
						tidn(40 to 40)                   & 
						dbcr3_q(62 to 62)                & 
						tidn(42 to 62)                   & 
						dbcr3_q(63 to 63)                ; 

mark_unused(dbcr2_do(0 to 64-regsize));
mark_unused(dbcr3_do(0 to 64-regsize));

dbcr2_latch_gen : if a2mode = 1 generate
dbcr2_latch : tri_ser_rlmreg_p
generic map(width   => dbcr2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbcr2_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr2_offset to dbcr2_offset + dbcr2_q'length-1),
            scout   => sov(dbcr2_offset to dbcr2_offset + dbcr2_q'length-1),
            din     => dbcr2_d,
            dout    => dbcr2_q);
end generate;
dbcr2_latch_tie : if a2mode = 0 generate
	dbcr2_q         <= (others=>'0');
end generate;
dbcr3_latch : tri_ser_rlmreg_p
generic map(width   => dbcr3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dbcr3_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr3_offset to dbcr3_offset + dbcr3_q'length-1),
            scout   => sov(dbcr3_offset to dbcr3_offset + dbcr3_q'length-1),
            din     => dbcr3_d,
            dout    => dbcr3_q);


siv(0 to scan_right-1)           <= sov(1 to scan_right-1) & scan_in;
scan_out                         <= sov(0);

end architecture xuq_fxu_spr_tspr;
