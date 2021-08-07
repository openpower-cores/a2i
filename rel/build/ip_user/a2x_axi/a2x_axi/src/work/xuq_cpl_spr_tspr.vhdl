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

library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_cpl_spr_tspr is
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

   ex5_val                          : in  std_ulogic;
   cspr_tspr_ex5_is_mtspr           : in  std_ulogic;
   cspr_tspr_ex5_instr              : in  std_ulogic_vector(11 to 20);
   ex5_spr_wd                       : in  std_ulogic_vector(64-regsize to 63);
   ex5_cia_p1                       : in  std_ulogic_vector(62-eff_ifar to 61);
   
   ex4_lr_update                    : in  std_ulogic;
   ex4_ctr_dec_update               : in  std_ulogic;


   spr_iar                          : in  std_ulogic_vector(62-eff_ifar to 61);
	spr_ctr                          : out std_ulogic_vector(0 to regsize-1);
	spr_lr                           : out std_ulogic_vector(0 to regsize-1);

   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_cpl_spr_tspr;
architecture xuq_cpl_spr_tspr of xuq_cpl_spr_tspr is

subtype DO                            is std_ulogic_vector(65-regsize to 64);
signal ctr_d          , ctr_q          : std_ulogic_vector(64-(regsize) to 63);
signal lr_d           , lr_q           : std_ulogic_vector(64-(regsize) to 63);
constant ctr_offset                    : natural := 0;
constant lr_offset                     : natural := ctr_offset      + ctr_q'length;
constant last_reg_offset               : natural := lr_offset       + lr_q'length;
constant last_reg_offset_bcfg          : natural := 1;
constant last_reg_offset_ccfg          : natural := 1;
constant last_reg_offset_dcfg          : natural := 1;
signal ex5_lr_update_q                 : std_ulogic;                 
signal ex5_ctr_dec_update_q            : std_ulogic;                 
constant ex5_lr_update_offset          : integer := last_reg_offset;
constant ex5_ctr_dec_update_offset     : integer := ex5_lr_update_offset           + 1;
constant scan_right                    : integer := ex5_ctr_dec_update_offset      + 1;
signal siv                             : std_ulogic_vector(0 to scan_right-1);
signal sov                             : std_ulogic_vector(0 to scan_right-1);
signal tiup                            : std_ulogic;
signal tidn                            : std_ulogic_vector(00 to 63);
signal ex2_instr                       : std_ulogic_vector(11 to 20);
signal ex5_is_mtspr                    : std_ulogic;
signal ex5_instr                       : std_ulogic_vector(11 to 20);
signal ex5_lr_update                   : std_ulogic;
signal ex5_ctr_dec_update              : std_ulogic;
signal spr_iar_int                     : std_ulogic_vector(0 to 62);

signal ex5_ctr_di                      : std_ulogic_vector(ctr_q'range);
signal ex5_lr_di                       : std_ulogic_vector(lr_q'range);
signal
	ex2_ctr_rdec   , ex2_iar_rdec   , ex2_lr_rdec    
													: std_ulogic;
signal
	ex2_ctr_re     , ex2_iar_re     , ex2_lr_re      
													: std_ulogic;
signal
	ex5_ctr_wdec   , ex5_iar_wdec   , ex5_lr_wdec    
													: std_ulogic;
signal
	ex5_ctr_we     , ex5_iar_we     , ex5_lr_we      
													: std_ulogic;
signal
	ctr_act        , iar_act        , lr_act         
													: std_ulogic;
signal
	ctr_do         , iar_do         , lr_do          
													: std_ulogic_vector(0 to 64);

begin
   

tiup           <= '1';
tidn           <= (others=>'0');
ex2_instr      <= cspr_tspr_ex2_instr;
ex5_is_mtspr   <= cspr_tspr_ex5_is_mtspr;
ex5_instr      <= cspr_tspr_ex5_instr;

ex5_lr_update        <= ex5_val and ex5_lr_update_q;
ex5_ctr_dec_update   <= ex5_val and ex5_ctr_dec_update_q;

spr_iar_int    <= tidn(0 to 62-eff_ifar) & spr_iar;

ctr_act        <= ex5_ctr_we or ex5_ctr_dec_update;

with ex5_ctr_dec_update_q select
   ctr_d       <= std_ulogic_vector(unsigned(ctr_q) - 1) when '1',
                  ex5_ctr_di                             when others;

iar_act        <= tiup;

lr_act         <= ex5_lr_we or ex5_lr_update;

with ex5_lr_update select
   lr_d        <= ex5_cia_p1 & "00"    when '1',
                  ex5_lr_di            when others;


               

readmux_00 : if a2mode = 0 and hvmode = 0 generate
tspr_cspr_ex2_tspr_rt <=
	(ctr_do(DO'range)         and (DO'range => ex2_ctr_re     )) or
	(iar_do(DO'range)         and (DO'range => ex2_iar_re     )) or
	(lr_do(DO'range)          and (DO'range => ex2_lr_re      ));
end generate;
readmux_01 : if a2mode = 0 and hvmode = 1 generate
tspr_cspr_ex2_tspr_rt <=
	(ctr_do(DO'range)         and (DO'range => ex2_ctr_re     )) or
	(iar_do(DO'range)         and (DO'range => ex2_iar_re     )) or
	(lr_do(DO'range)          and (DO'range => ex2_lr_re      ));
end generate;
readmux_10 : if a2mode = 1 and hvmode = 0 generate
tspr_cspr_ex2_tspr_rt <=
	(ctr_do(DO'range)         and (DO'range => ex2_ctr_re     )) or
	(iar_do(DO'range)         and (DO'range => ex2_iar_re     )) or
	(lr_do(DO'range)          and (DO'range => ex2_lr_re      ));
end generate;
readmux_11 : if a2mode = 1 and hvmode = 1 generate
tspr_cspr_ex2_tspr_rt <=
	(ctr_do(DO'range)         and (DO'range => ex2_ctr_re     )) or
	(iar_do(DO'range)         and (DO'range => ex2_iar_re     )) or
	(lr_do(DO'range)          and (DO'range => ex2_lr_re      ));
end generate;

ex2_ctr_rdec      <= (ex2_instr(11 to 20) = "0100100000");   
ex2_iar_rdec      <= (ex2_instr(11 to 20) = "1001011011");   
ex2_lr_rdec       <= (ex2_instr(11 to 20) = "0100000000");   
ex2_ctr_re        <=  ex2_ctr_rdec;
ex2_iar_re        <=  ex2_iar_rdec;
ex2_lr_re         <=  ex2_lr_rdec;

ex5_ctr_wdec      <= (ex5_instr(11 to 20) = "0100100000");   
ex5_iar_wdec      <= (ex5_instr(11 to 20) = "1001011011");   
ex5_lr_wdec       <= (ex5_instr(11 to 20) = "0100000000");   
ex5_ctr_we        <= ex5_val and ex5_is_mtspr and  ex5_ctr_wdec;
ex5_iar_we        <= ex5_val and ex5_is_mtspr and  ex5_iar_wdec;
ex5_lr_we         <= ex5_val and ex5_is_mtspr and  ex5_lr_wdec;

spr_ctr                    <= ctr_q(64-(regsize) to 63);
spr_lr                     <= lr_q(64-(regsize) to 63);

ex5_ctr_di     <= ex5_spr_wd(64-(regsize) to 63)   ; 
ctr_do         <= tidn(0 to 64-(regsize))          &
						ctr_q(64-(regsize) to 63)        ; 
iar_do         <= tidn(0 to 0)                     &
						spr_iar_int(1 to 62)             & 
						tidn(62 to 63)                   ; 
ex5_lr_di      <= ex5_spr_wd(64-(regsize) to 63)   ; 
lr_do          <= tidn(0 to 64-(regsize))          &
						lr_q(64-(regsize) to 63)         ; 

mark_unused(ctr_do(0 to 64-regsize));
mark_unused(iar_do(0 to 64-regsize));
mark_unused(lr_do(0 to 64-regsize));

ctr_latch : tri_ser_rlmreg_p
generic map(width   => ctr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => ctr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ctr_offset to ctr_offset + ctr_q'length-1),
            scout   => sov(ctr_offset to ctr_offset + ctr_q'length-1),
            din     => ctr_d,
            dout    => ctr_q);
lr_latch : tri_ser_rlmreg_p
generic map(width   => lr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => lr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lr_offset to lr_offset + lr_q'length-1),
            scout   => sov(lr_offset to lr_offset + lr_q'length-1),
            din     => lr_d,
            dout    => lr_q);


mark_unused(tidn(1 to 61));
mark_unused(spr_iar_int(0));
mark_unused(iar_act);
mark_unused(ex5_iar_we);

ex5_lr_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_lr_update_offset),
            scout   => sov(ex5_lr_update_offset),
            din     => ex4_lr_update,
            dout    => ex5_lr_update_q);
ex5_ctr_dec_update_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ctr_dec_update_offset),
            scout   => sov(ex5_ctr_dec_update_offset),
            din     => ex4_ctr_dec_update,
            dout    => ex5_ctr_dec_update_q);

siv(0 to scan_right-1)  <= sov(1 to scan_right-1) & scan_in;
scan_out                <= sov(0);


end architecture xuq_cpl_spr_tspr;
