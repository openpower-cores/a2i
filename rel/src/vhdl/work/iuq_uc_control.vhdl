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

--********************************************************************
--*
--* TITLE: Microcode Control
--*
--* NAME: iuq_uc_control.vhdl
--*
--*********************************************************************

library ieee,ibm,support,tri,work;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
use work.iuq_pkg.all;


entity iuq_uc_control is
  generic(ucode_width           : integer := 71;
          expand_type           : integer := 2);
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     pc_iu_func_sl_thold_0_b    : in std_ulogic;
     pc_iu_sg_0                 : in std_ulogic;
     forcee                     : in std_ulogic;
     d_mode                     : in std_ulogic;
     delay_lclkr                : in std_ulogic;
     mpw1_b                     : in std_ulogic;
     mpw2_b                     : in std_ulogic;
     scan_in                    : in std_ulogic;
     scan_out                   : out std_ulogic;

     spr_ic_clockgate_dis       : in std_ulogic;
     xu_iu_spr_xer              : in std_ulogic_vector(57 to 63);
     flush                      : in std_ulogic;
     restart                    : in std_ulogic;
     flush_ifar                 : in std_ulogic_vector(41 to 61);  -- ucode-style address & state to flush to
     ib_flush                   : in std_ulogic;
     ib_flush_ifar              : in std_ulogic_vector(41 to 61);  -- ucode-style address & state to flush to
     buff_avail                 : in std_ulogic;
     load_command               : in std_ulogic;
     new_instr                  : in std_ulogic_vector(0 to 31);
     start_addr                 : in std_ulogic_vector(0 to 9);
     xer_type                   : in std_ulogic;  -- instruction uses XER:  need to wait until XER guaranteed valid
     early_end                  : in std_ulogic;
     force_ep                   : in std_ulogic;
     new_cond                   : in std_ulogic;  -- If '1', will skip lines with skip_cond bit set

     uc_act_thread              : out std_ulogic;
     vld_fast                   : out std_ulogic;

     ra_valid                   : out std_ulogic;
     rom_ra                     : out std_ulogic_vector(0 to 9); -- read address

     data_valid                 : in std_ulogic;
     rom_data                   : in std_ulogic_vector(32 to ucode_width-1);
     rom_data_late              : in std_ulogic_vector(0 to 31);

     ucode_valid                : out std_ulogic;
     ucode_ifar                 : out std_ulogic_vector(41 to 61);
     ucode_instruction          : out std_ulogic_vector(0 to 31);
     is_uCode                   : out std_ulogic;
     extRT                      : out std_ulogic;
     extS1                      : out std_ulogic;
     extS2                      : out std_ulogic;
     extS3                      : out std_ulogic;

     hold_thread                : out std_ulogic;

     uc_control_dbg_data        : out std_ulogic_vector(0 to 3)
);
-- synopsys translate_off



-- synopsys translate_on

end iuq_uc_control;


architecture iuq_uc_control of iuq_uc_control is

constant xu_iu_spr_xer_offset   : natural := 0;
constant bubble_offset          : natural := xu_iu_spr_xer_offset + 7;
constant valid_offset           : natural := bubble_offset + 1;
constant instr_offset           : natural := valid_offset + 1;
constant instr_late_offset      : natural := instr_offset + 32;
constant sel_late_offset        : natural := instr_late_offset + 15;
constant early_end_offset       : natural := sel_late_offset + 11;
constant cond_offset            : natural := early_end_offset + 1;
constant rom_addr_offset        : natural := cond_offset + 1;
constant inloop_offset          : natural := rom_addr_offset + 10;
constant count_offset           : natural := inloop_offset + 1;
constant skip_zero_offset       : natural := count_offset + 5;
constant skip_to_np1_offset     : natural := skip_zero_offset + 1;
constant skip_cond_offset       : natural := skip_to_np1_offset + 1;
constant skip_offset            : natural := skip_cond_offset + 1;
constant wait_offset            : natural := skip_offset + 1;
constant force_ep_offset        : natural := wait_offset + 1;
constant ep_force_late_offset   : natural := force_ep_offset + 1;
constant scan_right             : natural := ep_force_late_offset + 1 - 1;

subtype s3 is std_ulogic_vector(0 to 2);

signal bubble_fast      : std_ulogic;
signal valid_fast       : std_ulogic;

-- Latches
signal xu_iu_spr_xer_d  : std_ulogic_vector(57 to 63);
signal bubble_d         : std_ulogic;
signal valid_d          : std_ulogic;
signal instr_d          : std_ulogic_vector(0 to 31);
signal early_end_d      : std_ulogic;
signal cond_d           : std_ulogic;
signal rom_addr_d       : std_ulogic_vector(0 to 9);
signal inLoop_d         : std_ulogic;
signal count_d          : std_ulogic_vector(0 to 4);
signal skip_zero_d      : std_ulogic;
signal skip_to_np1_d    : std_ulogic;
signal skip_cond_d      : std_ulogic;
signal skip_d           : std_ulogic;
signal wait_d           : std_ulogic;

signal xu_iu_spr_xer_l2 : std_ulogic_vector(57 to 63);
signal bubble_l2        : std_ulogic;
signal valid_l2         : std_ulogic;
signal instr_l2         : std_ulogic_vector(0 to 31);
signal early_end_l2     : std_ulogic;
signal cond_l2          : std_ulogic;
signal rom_addr_l2      : std_ulogic_vector(0 to 9);
signal inLoop_l2        : std_ulogic;
signal count_l2         : std_ulogic_vector(0 to 4);
signal skip_zero_l2     : std_ulogic;
signal skip_to_np1_l2   : std_ulogic;
signal skip_cond_l2     : std_ulogic;
signal skip_l2          : std_ulogic;
signal wait_l2          : std_ulogic;

signal force_ep_d       : std_ulogic;
signal force_ep_l2      : std_ulogic;


signal new_command      : std_ulogic;
signal uC_flush         : std_ulogic;    --flush to uCode
signal uc_act           : std_ulogic;

--
signal template_code    : std_ulogic_vector(0 to 31);
signal uc_end           : std_ulogic;
signal uc_end_early     : std_ulogic;
signal loop_begin       : std_ulogic;
signal loop_end         : std_ulogic;
signal loop_end_rom     : std_ulogic;   
signal count_src        : std_ulogic_vector(0 to 2);
signal sel0_5           : std_ulogic;
signal sel6_10          : std_ulogic_vector(0 to 1);
signal sel11_15         : std_ulogic_vector(0 to 1);
signal sel16_20         : std_ulogic_vector(0 to 1);
signal sel21_25         : std_ulogic_vector(0 to 1);
signal sel26_30         : std_ulogic;
signal sel31            : std_ulogic;
signal cr_bf2fxm        : std_ulogic;   -- for mtocrf
signal skip_cond        : std_ulogic;
signal skip_zero        : std_ulogic;
signal loop_addr        : std_ulogic_vector(0 to 9);
signal loop_init        : std_ulogic_vector(0 to 2);
signal ep_instr         : std_ulogic;

signal ucode_end        : std_ulogic;
signal fxm              : std_ulogic_vector(0 to 7);

--timing fixes
signal sel0_5_late      : std_ulogic;
signal sel6_10_late     : std_ulogic_vector(0 to 1);
signal sel11_15_late    : std_ulogic_vector(0 to 1);
signal sel16_20_late    : std_ulogic_vector(0 to 1);
signal sel21_25_late    : std_ulogic_vector(0 to 1);
signal sel26_30_late    : std_ulogic;
signal sel31_late       : std_ulogic;

signal sel_late_d       : std_ulogic_vector(0 to 10);
signal sel_late_l2      : std_ulogic_vector(0 to 10);
signal ep_force_late_d  : std_ulogic;
signal ep_force_late_l2 : std_ulogic;
signal instr_late_d     : std_ulogic_vector(6 to 20);
signal instr_late_l2    : std_ulogic_vector(6 to 20);


-- control
signal last_loop        : std_ulogic;
signal loopback_part1   : std_ulogic;   
signal loopback         : std_ulogic;
signal inc_RT           : std_ulogic;

signal NB_dec           : std_ulogic_vector(0 to 4);
signal NB_comp          : std_ulogic_vector(0 to 1);
signal XER_dec_z        : std_ulogic_vector(0 to 6);
signal XER_low          : std_ulogic_vector(0 to 2);
signal XER_comp         : std_ulogic_vector(0 to 1);
signal count_init       : std_ulogic_vector(0 to 4);
signal skip             : std_ulogic;


signal siv              : std_ulogic_vector(0 to scan_right);
signal sov              : std_ulogic_vector(0 to scan_right);

begin



-----------------------------------------------------------------------
-- load new command
-----------------------------------------------------------------------
new_command <= load_command and not bubble_l2;  -- guard against back-to-back uCode instructions from Issue
uC_flush <= flush and not restart and (valid_l2 or wait_l2);

uc_act <= load_command or valid_l2 or wait_l2 or spr_ic_clockgate_dis;
uc_act_thread <= uc_act;

bubble_d <= not flush and new_command;

valid_d <= (new_command and not flush) or
           (valid_l2 and not (ucode_end and data_valid) and not flush) or
           uC_flush or
           (ib_flush and not flush);


bubble_fast <= bubble_d;

valid_fast <= (new_command and not flush) or
              (valid_l2 and not flush) or
              uC_flush or
              (ib_flush and not flush);


-- RT
instr_d(0 to 5) <= new_instr(0 to 5)            when new_command = '1'
              else instr_l2(0 to 5);

instr_d(6 to 10) <= flush_ifar(49 to 53)        when flush = '1'
               else ib_flush_ifar(49 to 53)     when ib_flush = '1'
               else new_instr(6 to 10)          when new_command = '1'
               else instr_l2(6 to 10) + 1       when inc_RT = '1'
               else instr_l2(6 to 10);

instr_d(11 to 31) <= new_instr(11 to 31)        when new_command = '1'
                else instr_l2(11 to 31);

early_end_d <= early_end            when new_command = '1'
          else early_end_l2;

cond_d <= new_cond                      when new_command = '1'
     else cond_l2;

force_ep_d <= force_ep                      when new_command = '1'
     else force_ep_l2;

rom_addr_d <= flush_ifar(41 to 42) & flush_ifar(54 to 61)       when flush = '1'
         else ib_flush_ifar(41 to 42) & ib_flush_ifar(54 to 61) when ib_flush = '1'
         else start_addr                                        when new_command = '1'
         else loop_addr                                         when loopback = '1'
         else rom_addr_l2(0 to 1) & (rom_addr_l2(2 to 9) + 1)   when data_valid = '1'
         else rom_addr_l2;

rom_ra <= rom_addr_d;

ra_valid <= valid_d and not bubble_d and buff_avail;
vld_fast <= valid_fast and not bubble_fast and buff_avail;

uc_end     <= rom_data(32);
uc_end_early <= rom_data(33);
loop_begin <= rom_data(34);
loop_end   <= rom_data(35) and inLoop_l2;
loop_end_rom <= rom_data(35);   -- for timing fix.  Must check inLoop_l2 wherever this is used.
count_src  <= rom_data(36 to 38);       -- 00: NB(3:4), 01: "000" & 2's comp NB(3:4), 10: mult of 4 & XER(62:63), 11: 2's comp XER(62:63), 100: RT(inverted), 101: NB(0:2) - word mode, 110: XER(57:61) - word mode, 111: loop_init
extRT      <= rom_data(39);
extS1      <= rom_data(40);
extS2      <= rom_data(41);
extS3      <= rom_data(42);
sel0_5     <= rom_data(43);
sel6_10    <= rom_data(44 to 45);
sel11_15   <= rom_data(46 to 47);
sel16_20   <= rom_data(48 to 49);
sel21_25   <= rom_data(50 to 51);
sel26_30   <= rom_data(52);
sel31      <= rom_data(53);
cr_bf2fxm  <= rom_data(54);
skip_cond  <= rom_data(55);
skip_zero  <= rom_data(56);  -- For when XER = 0 & to help with NB coding
loop_addr  <= rom_data(57 to 66);  -- Note: Could latch loop_begin address instead of keeping in ROM
loop_init  <= rom_data(67 to 69);
ep_instr   <= rom_data(70);


template_code(0 to 26)  <= rom_data_late(0 to 26);
template_code(27)       <= rom_data_late(27) or ep_force_late_l2;
template_code(28 to 31) <= rom_data_late(28 to 31);

sel_late_d(0)           <= sel0_5;
sel_late_d(1 to 2)      <= sel6_10;
sel_late_d(3 to 4)      <= sel11_15;
sel_late_d(5 to 6)      <= sel16_20;
sel_late_d(7 to 8)      <= sel21_25;
sel_late_d(9)           <= sel26_30;
sel_late_d(10)          <= sel31;

sel0_5_late             <= sel_late_l2(0);
sel6_10_late            <= sel_late_l2(1 to 2);
sel11_15_late           <= sel_late_l2(3 to 4);
sel16_20_late           <= sel_late_l2(5 to 6);
sel21_25_late           <= sel_late_l2(7 to 8);
sel26_30_late           <= sel_late_l2(9);
sel31_late              <= sel_late_l2(10);

ep_force_late_d <= ep_instr and force_ep_l2;

ucode_end <= uc_end or (uc_end_early and early_end_l2);

with s3'(instr_l2(6 to 8)) select
fxm <= "10000000" when "000",
       "01000000" when "001",
       "00100000" when "010",
       "00010000" when "011",
       "00001000" when "100",
       "00000100" when "101",
       "00000010" when "110",
       "00000001" when others;

-- instr_l2(0:5) & (21:31) never change while processing command
instr_late_d( 6 to 10)   <= instr_l2( 6 to 10);
instr_late_d(11 to 20)   <= instr_l2(11 to 20) when cr_bf2fxm = '0' else ('1' & fxm(0 to 7) & '0');



with sel0_5_late select
ucode_instruction(0 to 5) <= template_code(0 to 5)      when '0',
                             instr_l2(0 to 5)           when others;

with sel6_10_late select
ucode_instruction(6 to 10) <= template_code(6 to 10)    when "00",
                              instr_late_l2(6 to 10)    when "01",
                              instr_late_l2(11 to 15)   when "10",
                              instr_late_l2(16 to 20)   when others;


with sel11_15_late select
ucode_instruction(11 to 15) <= template_code(11 to 15)  when "00",
                               instr_late_l2(11 to 15)  when "01",
                               instr_late_l2(16 to 20)  when "10",
                               instr_late_l2(6 to 10)   when others;

with sel16_20_late select
ucode_instruction(16 to 20) <= template_code(16 to 20)  when "00",
                               instr_late_l2(16 to 20)  when "01",
                               instr_late_l2(6 to 10)   when "10",
                               instr_late_l2(11 to 15)  when others;

with sel21_25_late select
ucode_instruction(21 to 25) <= template_code(21 to 25)  when "00",
                               instr_l2(21 to 25)  when "01",
                               instr_late_l2(16 to 20)  when others;

with sel26_30_late select
ucode_instruction(26 to 30) <= template_code(26 to 30)  when '0',
                               instr_l2(26 to 30)       when others;

with sel31_late select
ucode_instruction(31) <= template_code(31)  when '0',
                         instr_l2(31)       when others;

ucode_valid <= data_valid and not flush and not ib_flush and not skip;
is_ucode <= not ucode_end;       -- is_ucode signal must drop for the last instruction


ucode_ifar(41 to 61) <= rom_addr_l2(0 to 1) & count_l2 & inLoop_l2 & instr_l2(6 to 10) & rom_addr_l2(2 to 9);


-----------------------------------------------------------------------
-- control, state machines
-----------------------------------------------------------------------
-- Assumptions:
--   No Nested Loops
--   All Loops must have at least 2 instructions
--   New ucode instructions will be held off until XU flushes IU (to next instruction) on this thread
--   If loop_end is skip_c, the instruction before loop_end must also be skip_c
inLoop_d <= flush_ifar(48)    when uC_flush = '1'
       else '0'               when flush = '1'     -- clear for non-uCode flush
       else ib_flush_ifar(48) when ib_flush = '1'
       else (((data_valid and loop_begin) or inLoop_l2) and not ((data_valid and loop_end) and last_loop) and valid_l2 and not bubble_l2);

last_loop <= (count_l2 = "00000") or (skip_zero_l2 and count_l2 = "00001") or skip_cond_l2;

loopback_part1 <= data_valid and inLoop_l2 and not last_loop;
loopback <= loopback_part1 and loop_end_rom;

inc_RT <= data_valid and loop_end and not (skip_zero_l2 and count_l2 = "00000") and
          count_src(0) and not (count_src = "111");   -- load/store multiple & string op word loops



NB_dec <= instr_l2(16 to 20) - 1;
NB_comp(0) <= instr_l2(19) xor instr_l2(20);
NB_comp(1) <= instr_l2(20);


xu_iu_spr_xer_d <= xu_iu_spr_xer;

XER_dec_z <= "0000000"  when xu_iu_spr_xer_l2(57 to 63) = "0000000"
        else xu_iu_spr_xer_l2(57 to 63) - 1;
XER_low   <= "100"      when XER_dec_z(5 to 6) = "11"
        else '0' & xu_iu_spr_xer_l2(62 to 63);
XER_comp(0) <= xu_iu_spr_xer_l2(62) xor xu_iu_spr_xer_l2(63);
XER_comp(1) <= xu_iu_spr_xer_l2(63);

with count_src select
count_init <= "000" & NB_dec(3 to 4)    when "000",
              "000" & NB_comp(0 to 1)   when "001",
              "00" & XER_low            when "010",
              "000" & XER_comp(0 to 1)  when "011",
              not (instr_l2(6 to 10))   when "100",  
              "00" & NB_dec(0 to 2)     when "101",
              XER_dec_z(0 to 4)         when "110",
              "00" & loop_init          when others;


-- How many cycles is XER bubble?  XER is available in EX6. XER has been latched, moving to 7 bubbles
-- Dependency is now checking XER dependencies, so we do not need extra delay for xer_type
count_d <= flush_ifar(43 to 47)                 when flush = '1'
      else ib_flush_ifar(43 to 47)              when ib_flush = '1'
      else "00000"                              when new_command = '1'  -- 1 cycle bubble
      else count_init                           when (data_valid and loop_begin and not inLoop_l2) = '1'
      else count_l2 - 1                         when ((data_valid and loop_end) = '1')
      else count_l2;


skip_zero_d <= '0'              when (flush or ib_flush or (data_valid and loop_end) or new_command) = '1'
          else skip_zero        when (data_valid and loop_begin) = '1'
          else skip_zero_l2;

-- Now flush is always np1 flush
skip_to_np1_d <= not restart    when flush = '1'
            else '0'            when data_valid = '1'
            else skip_to_np1_l2;

skip_cond_d <= '0'                      when (flush or ib_flush or new_command) = '1'
          else (skip_cond and cond_l2)  when data_valid = '1'
          else skip_cond_l2;

skip <= (((skip_zero and loop_begin) or skip_zero_l2) and (count_l2 = "00000") and inLoop_l2) or
        ( (skip_zero and loop_begin) and count_init = "00000" and not inLoop_l2) or
        (skip_cond and cond_l2) or
        skip_to_np1_l2;

skip_d <= skip; -- Latch is just for trace bus

wait_d <= ((valid_l2 and ucode_end and data_valid) or
           wait_l2)
          and not flush and not ib_flush;      -- Either flushing back to uCode instruction, or XU is flushing to next command


hold_thread <= valid_l2 or wait_l2;

-- Debug
uc_control_dbg_data <= bubble_l2 & valid_l2 & wait_l2 & skip_l2;

-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------

xu_iu_spr_xer_latch: tri_rlmreg_p
  generic map (width => xu_iu_spr_xer_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,    
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_spr_xer_offset to xu_iu_spr_xer_offset + xu_iu_spr_xer_l2'length-1),
            scout   => sov(xu_iu_spr_xer_offset to xu_iu_spr_xer_offset + xu_iu_spr_xer_l2'length-1),
            din     => xu_iu_spr_xer_d,
            dout    => xu_iu_spr_xer_l2);

bubble_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(bubble_offset),
            scout   => sov(bubble_offset),
            din     => bubble_d,
            dout    => bubble_l2);

valid_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(valid_offset),
            scout   => sov(valid_offset),
            din     => valid_d,
            dout    => valid_l2);

instr_latch: tri_rlmreg_p
  generic map (width => instr_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(instr_offset to instr_offset + instr_l2'length-1),
            scout   => sov(instr_offset to instr_offset + instr_l2'length-1),
            din     => instr_d,
            dout    => instr_l2);

instr_late_latch: tri_rlmreg_p
  generic map (width => instr_late_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => data_valid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(instr_late_offset to instr_late_offset + instr_late_l2'length-1),
            scout   => sov(instr_late_offset to instr_late_offset + instr_late_l2'length-1),
            din     => instr_late_d,
            dout    => instr_late_l2);

sel_late_latch: tri_rlmreg_p
  generic map (width => sel_late_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => data_valid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sel_late_offset to sel_late_offset + sel_late_l2'length-1),
            scout   => sov(sel_late_offset to sel_late_offset + sel_late_l2'length-1),
            din     => sel_late_d,
            dout    => sel_late_l2);

early_end_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(early_end_offset),
            scout   => sov(early_end_offset),
            din     => early_end_d,
            dout    => early_end_l2);

cond_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(cond_offset),
            scout   => sov(cond_offset),
            din     => cond_d,
            dout    => cond_l2);

rom_addr_latch: tri_rlmreg_p
  generic map (width => rom_addr_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(rom_addr_offset to rom_addr_offset + rom_addr_l2'length-1),
            scout   => sov(rom_addr_offset to rom_addr_offset + rom_addr_l2'length-1),
            din     => rom_addr_d,
            dout    => rom_addr_l2);

count_latch: tri_rlmreg_p
  generic map (width => count_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(count_offset to count_offset + count_l2'length-1),
            scout   => sov(count_offset to count_offset + count_l2'length-1),
            din     => count_d,
            dout    => count_l2);

inloop_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(inloop_offset),
            scout   => sov(inloop_offset),
            din     => inloop_d,
            dout    => inloop_l2);

skip_zero_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(skip_zero_offset),
            scout   => sov(skip_zero_offset),
            din     => skip_zero_d,
            dout    => skip_zero_l2);

skip_to_np1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(skip_to_np1_offset),
            scout   => sov(skip_to_np1_offset),
            din     => skip_to_np1_d,
            dout    => skip_to_np1_l2);

skip_cond_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(skip_cond_offset),
            scout   => sov(skip_cond_offset),
            din     => skip_cond_d,
            dout    => skip_cond_l2);

skip_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(skip_offset),
            scout   => sov(skip_offset),
            din     => skip_d,
            dout    => skip_l2);

wait_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(wait_offset),
            scout   => sov(wait_offset),
            din     => wait_d,
            dout    => wait_l2);

force_ep_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(force_ep_offset),
            scout   => sov(force_ep_offset),
            din     => force_ep_d,
            dout    => force_ep_l2);

ep_force_late_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => data_valid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(ep_force_late_offset),
            scout   => sov(ep_force_late_offset),
            din     => ep_force_late_d,
            dout    => ep_force_late_l2);

-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);

end iuq_uc_control;
