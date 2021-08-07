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
--* TITLE: Instruction Buffer
--*
--* NAME: iuq_ib_buff.vhdl
--*
--*********************************************************************

library ieee; use ieee.std_logic_1164.all;
library ibm; use ibm.std_ulogic_unsigned.all;
             use ibm.std_ulogic_support.all;
             use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
library work; use work.iuq_pkg.all;

entity iuq_ib_buff is
  generic(ibuff_data_width      : integer := 50;
          ibuff_ifar_width      : integer := 22;
          uc_ifar               : integer := 21;
          expand_type           : integer := 2 );
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     pc_iu_sg_2                 : in std_ulogic;
     pc_iu_func_sl_thold_2      : in std_ulogic;
     clkoff_b                   : in std_ulogic;
     an_ac_scan_dis_dc_b        : in std_ulogic;
     tc_ac_ccflush_dc           : in std_ulogic;
     delay_lclkr                : in std_ulogic;
     mpw1_b                     : in std_ulogic;
     scan_in                    : in std_ulogic;
     scan_out                   : out std_ulogic;

     spr_dec_mask_pt_in         : in  std_ulogic_vector(0 to 31);
     spr_dec_mask_pt_out        : out std_ulogic_vector(0 to 31);
     fdep_dbg_data_pt_in        : in  std_ulogic_vector(0 to 21);
     fdep_dbg_data_pt_out       : out std_ulogic_vector(0 to 21);
     fdep_perf_event_pt_in      : in  std_ulogic_vector(0 to 11);
     fdep_perf_event_pt_out     : out std_ulogic_vector(0 to 11);

     pc_iu_trace_bus_enable     : in  std_ulogic;
     pc_iu_event_bus_enable     : in  std_ulogic;
     ib_dbg_data                : out std_ulogic_vector(0 to 15);
     ib_perf_event              : out std_ulogic_vector(0 to 1);

     xu_iu_ib1_flush            : in std_ulogic;
     uc_flush                   : in std_ulogic;

     fdec_ibuf_stall            : in std_ulogic;

     ib_ic_empty                : out std_ulogic;
     ib_ic_below_water          : out std_ulogic;

     -- BP interface
     bp_ib_iu4_ifar             : in EFF_IFAR;       
     bp_ib_iu4_val              : in std_ulogic_vector(0 to 3);
     bp_ib_iu3_0_instr          : in std_ulogic_vector(0 to 31);        
     bp_ib_iu4_0_instr          : in std_ulogic_vector(32 to 43);        
     bp_ib_iu4_1_instr          : in std_ulogic_vector(0 to 43);        
     bp_ib_iu4_2_instr          : in std_ulogic_vector(0 to 43);        
     bp_ib_iu4_3_instr          : in std_ulogic_vector(0 to 43);        

     -- UC interface
     uc_ib_iu4_ifar             : in std_ulogic_vector(62-uc_ifar to 61);       
     uc_ib_iu4_val              : in std_ulogic;
     uc_ib_iu4_instr            : in std_ulogic_vector(0 to 36);        

     -- RAM interface
     rm_ib_iu4_val              : in std_ulogic;
     rm_ib_iu4_force_ram        : in std_ulogic;
     rm_ib_iu4_instr            : in std_ulogic_vector(0 to 35);

     ib_ic_iu5_redirect_tid     : out std_ulogic;

     iu_au_ib1_valid              : out std_ulogic;
     iu_au_ib1_ifar               : out EFF_IFAR;
     iu_au_ib1_data               : out std_ulogic_vector(0 to ibuff_data_width-1)
);
  -- synopsys translate_off
  -- synopsys translate_on
end iuq_ib_buff;


architecture iuq_ib_buff of iuq_ib_buff is

constant command_width_full     : integer := (ibuff_data_width+EFF_IFAR'length);
constant command_width_lite     : integer := (ibuff_data_width+ibuff_ifar_width);

constant bp_ib_iu4_0_instr_offset       : natural := 0;
constant buffer1_valid_offset           : natural := bp_ib_iu4_0_instr_offset + 32;
constant buffer2_valid_offset           : natural := buffer1_valid_offset + 1;
constant buffer3_valid_offset           : natural := buffer2_valid_offset + 1;
constant buffer4_valid_offset           : natural := buffer3_valid_offset + 1;
constant buffer5_valid_offset           : natural := buffer4_valid_offset + 1;
constant buffer6_valid_offset           : natural := buffer5_valid_offset + 1;
constant buffer7_valid_offset           : natural := buffer6_valid_offset + 1;
constant buffer1_data_offset            : natural := buffer7_valid_offset + 1;
constant buffer2_data_offset            : natural := buffer1_data_offset + command_width_lite;
constant buffer3_data_offset            : natural := buffer2_data_offset + command_width_lite;
constant buffer4_data_offset            : natural := buffer3_data_offset + command_width_lite;
constant buffer5_data_offset            : natural := buffer4_data_offset + command_width_lite;
constant buffer6_data_offset            : natural := buffer5_data_offset + command_width_lite;
constant buffer7_data_offset            : natural := buffer6_data_offset + command_width_lite;
constant stall_buffer_data_offset       : natural := buffer7_data_offset + command_width_lite;
constant buffer_ifar_offset             : natural := stall_buffer_data_offset + command_width_full; 
constant redirect_offset                : natural := buffer_ifar_offset + (EFF_IFAR'length-ibuff_ifar_width);
constant stall_offset                   : natural := redirect_offset + 1;
constant buff1_sel_offset               : natural := stall_offset + 3;
constant perf_event_offset              : natural := buff1_sel_offset + 5;
constant ib_dbg_data_offset             : natural := perf_event_offset + 2;
constant spare_offset                   : natural := ib_dbg_data_offset + 6;
constant trace_bus_enable_offset        : natural := spare_offset + 8;
constant event_bus_enable_offset        : natural := trace_bus_enable_offset + 1;
constant scan_right                     : natural := event_bus_enable_offset + 1 - 1;

signal spare_l2                 : std_ulogic_vector(0 to 7);

signal ib_iu4_val               : std_ulogic_vector(0 to 3);
signal ib_iu4_ifar              : EFF_IFAR;
signal rm_iu4_0_instr           : std_ulogic_vector(0 to ibuff_data_width-1);
signal uc_iu4_0_instr           : std_ulogic_vector(0 to ibuff_data_width-1);
signal bp_iu4_0_instr           : std_ulogic_vector(0 to ibuff_data_width-1);
signal ib_iu4_0_instr           : std_ulogic_vector(0 to ibuff_data_width-1);
signal ib_iu4_1_instr           : std_ulogic_vector(0 to ibuff_data_width-1);
signal ib_iu4_2_instr           : std_ulogic_vector(0 to ibuff_data_width-1);
signal ib_iu4_3_instr           : std_ulogic_vector(0 to ibuff_data_width-1);

signal bp_ib_iu4_0_instr_d      : std_ulogic_vector(0 to 31);
signal bp_ib_iu4_0_instr_l2     : std_ulogic_vector(0 to 31);
signal iu4_act                  : std_ulogic;

signal uc_ib_iu4_ifar_int       : EFF_IFAR;

-- Latch signals
signal buffer1_valid_d          : std_ulogic;
signal buffer1_valid_l2         : std_ulogic;
signal buffer2_valid_d          : std_ulogic;
signal buffer2_valid_l2         : std_ulogic;
signal buffer3_valid_d          : std_ulogic;
signal buffer3_valid_l2         : std_ulogic;
signal buffer4_valid_d          : std_ulogic;
signal buffer4_valid_l2         : std_ulogic;
signal buffer5_valid_d          : std_ulogic;
signal buffer5_valid_l2         : std_ulogic;
signal buffer6_valid_d          : std_ulogic;
signal buffer6_valid_l2         : std_ulogic;
signal buffer7_valid_d          : std_ulogic;
signal buffer7_valid_l2         : std_ulogic;

signal buffer1_data_d           : std_ulogic_vector(0 to command_width_lite-1);
signal buffer1_data_l2          : std_ulogic_vector(0 to command_width_lite-1);
signal buffer2_data_d           : std_ulogic_vector(0 to command_width_lite-1);
signal buffer2_data_l2          : std_ulogic_vector(0 to command_width_lite-1);
signal buffer3_data_d           : std_ulogic_vector(0 to command_width_lite-1);
signal buffer3_data_l2          : std_ulogic_vector(0 to command_width_lite-1);
signal buffer4_data_d           : std_ulogic_vector(0 to command_width_lite-1);
signal buffer4_data_l2          : std_ulogic_vector(0 to command_width_lite-1);
signal buffer5_data_d           : std_ulogic_vector(0 to command_width_lite-1);
signal buffer5_data_l2          : std_ulogic_vector(0 to command_width_lite-1);
signal buffer6_data_d           : std_ulogic_vector(0 to command_width_lite-1);
signal buffer6_data_l2          : std_ulogic_vector(0 to command_width_lite-1);
signal buffer7_data_d           : std_ulogic_vector(0 to command_width_lite-1);
signal buffer7_data_l2          : std_ulogic_vector(0 to command_width_lite-1);

signal buffer_data              : std_ulogic_vector(0 to command_width_full-1);
signal stall_buffer_data_d      : std_ulogic_vector(0 to command_width_full-1);
signal stall_buffer_data_l2     : std_ulogic_vector(0 to command_width_full-1);
signal stall_d                  : std_ulogic_vector(0 to 2);
signal stall_l2                 : std_ulogic_vector(0 to 2);
signal buff1_sel_d              : std_ulogic_vector(0 to 4);
signal buff1_sel_l2             : std_ulogic_vector(0 to 4);

signal buffer1_data             : std_ulogic_vector(0 to command_width_full-1);
signal buffer_ifar_d            : std_ulogic_vector(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width);
signal buffer_ifar_l2           : std_ulogic_vector(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width);
signal buffer_ifar_update       : std_ulogic;
signal buffer_ifar_match        : std_ulogic;
signal buffer_ifar_match_uc     : std_ulogic;
signal redirect_d               : std_ulogic;
signal redirect_l2              : std_ulogic;

-- Logic signals
signal pc_ext_1                 : std_ulogic_vector(60 to 61);
signal pc_ext_2                 : std_ulogic_vector(60 to 61);
signal pc_ext_3                 : std_ulogic_vector(60 to 61);

signal stall_buffer_act         : std_ulogic;
signal buffer1_data_act         : std_ulogic;
signal buffer2_data_act         : std_ulogic;
signal buffer3_data_act         : std_ulogic;
signal buffer4_data_act         : std_ulogic;
signal buffer5_data_act         : std_ulogic;
signal buffer6_data_act         : std_ulogic;
signal buffer7_data_act         : std_ulogic;

signal valid_out                : std_ulogic;
signal data_out                 : std_ulogic_vector(0 to command_width_full-1);

-- Pervasive
signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;

signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);

signal tiup                     : std_ulogic;

signal valid_in                 : std_ulogic_vector(0 to 3);
signal valid_in_uc              : std_ulogic;
signal valid_fast               : std_ulogic;
signal valid_slow               : std_ulogic;

signal perf_event_d             : std_ulogic_vector(0 to 1);
signal perf_event_l2            : std_ulogic_vector(0 to 1);

signal ib_dbg_data_d             : std_ulogic_vector(0 to 5);
signal ib_dbg_data_l2            : std_ulogic_vector(0 to 5);

signal trace_bus_enable_d                   : std_ulogic;
signal trace_bus_enable_q                   : std_ulogic;
signal event_bus_enable_d                   : std_ulogic;
signal event_bus_enable_q                   : std_ulogic;

signal act_dis                          : std_ulogic;
signal d_mode                           : std_ulogic;
signal mpw2_b                           : std_ulogic;

begin


-----------------------------------------------------------------------
-- Logic
-----------------------------------------------------------------------
tiup <= '1';


act_dis <= '0';
d_mode  <= '0';
mpw2_b  <= '1';


----------------------------------------
-- passthrough
----------------------------------------
spr_dec_mask_pt_out     <=      spr_dec_mask_pt_in;
fdep_dbg_data_pt_out    <=      fdep_dbg_data_pt_in;
fdep_perf_event_pt_out  <=      fdep_perf_event_pt_in;
     


----------------------------------------
-- ibuff instruction source muxing
----------------------------------------


ib_iu4_val(0)           <= rm_ib_iu4_val or uc_ib_iu4_val or bp_ib_iu4_val(0);

ib_iu4_val(1 to 3)      <= bp_ib_iu4_val(1 to 3);

uc_ib_iu4_ifar_int(62-uc_ifar to 61)            <= uc_ib_iu4_ifar;
uc_ib_iu4_ifar_int(EFF_IFAR'left to 61-uc_ifar) <= (others => '0');


ib_iu4_ifar             <= gate(uc_ib_iu4_ifar_int, uc_ib_iu4_val) or
                           gate(bp_ib_iu4_ifar    , bp_ib_iu4_val(0));


bp_ib_iu4_0_instr_d     <= bp_ib_iu3_0_instr;

rm_iu4_0_instr(0 to 49) <= rm_ib_iu4_instr(0 to 35) & "000000000" & rm_ib_iu4_force_ram & "0000";
uc_iu4_0_instr(0 to 49) <= uc_ib_iu4_instr(0 to 35) & "000000" & uc_ib_iu4_instr(36) & "0000000";
bp_iu4_0_instr(0 to 49) <= bp_ib_iu4_0_instr_l2(0 to 31) & "0000" & bp_ib_iu4_0_instr(32 to 37) & '0' & bp_ib_iu4_0_instr(38 to 39) & '0' & bp_ib_iu4_0_instr(40 to 43);

ib_iu4_0_instr(0 to 49) <= gate(rm_iu4_0_instr(0 to 49), rm_ib_iu4_val) or
                           gate(uc_iu4_0_instr(0 to 49), uc_ib_iu4_val) or
                           gate(bp_iu4_0_instr(0 to 49), bp_ib_iu4_val(0));

ib_iu4_1_instr(0 to 49) <= bp_ib_iu4_1_instr(0 to 31) & "0000" & bp_ib_iu4_1_instr(32 to 37) & '0' & bp_ib_iu4_1_instr(38 to 39) & '0' & bp_ib_iu4_1_instr(40 to 43);
ib_iu4_2_instr(0 to 49) <= bp_ib_iu4_2_instr(0 to 31) & "0000" & bp_ib_iu4_2_instr(32 to 37) & '0' & bp_ib_iu4_2_instr(38 to 39) & '0' & bp_ib_iu4_2_instr(40 to 43);
ib_iu4_3_instr(0 to 49) <= bp_ib_iu4_3_instr(0 to 31) & "0000" & bp_ib_iu4_3_instr(32 to 37) & '0' & bp_ib_iu4_3_instr(38 to 39) & '0' & bp_ib_iu4_3_instr(40 to 43);


valid_slow      <= (rm_ib_iu4_val or uc_ib_iu4_val) and not redirect_l2;
valid_fast      <= bp_ib_iu4_val(0) and not redirect_l2;

----------------------------------------
-- ibuff
----------------------------------------
valid_in(0 to 3) <= gate(ib_iu4_val(0 to 3), not redirect_l2);
valid_in_uc      <= uc_ib_iu4_val and not redirect_l2;

-- Calculate last 2 bits of address for instr1-3
with ib_iu4_ifar(60 to 61) select
pc_ext_1 <= "11"       when "10",
            "10"       when "01",
            "01"       when others;
pc_ext_2 <= '1' & ib_iu4_ifar(61);
pc_ext_3 <= "11";


buffer_ifar_d <= ib_iu4_ifar(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width) when buffer_ifar_update='1' else buffer_ifar_l2;

-- Check for incoming valids and set new buffer entries
check_vals:process(xu_iu_ib1_flush, uc_flush, valid_in, ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right), ib_iu4_0_instr,
                   pc_ext_1, pc_ext_2, pc_ext_3, stall_l2(0),
                   buffer1_valid_l2, buffer2_valid_l2, buffer3_valid_l2,
                   buffer4_valid_l2, buffer5_valid_l2, buffer6_valid_l2, buffer7_valid_l2,
                   buffer1_data_l2, buffer2_data_l2, buffer3_data_l2,
                   buffer4_data_l2, buffer5_data_l2, buffer6_data_l2, buffer7_data_l2,
                   ib_iu4_1_instr, ib_iu4_2_instr, ib_iu4_3_instr, buffer_ifar_match, buffer_ifar_match_uc, valid_fast, valid_slow, valid_in_uc, uc_iu4_0_instr) begin

    -- default values
    buffer1_valid_d <= buffer1_valid_l2;
    buffer2_valid_d <= buffer2_valid_l2;
    buffer3_valid_d <= buffer3_valid_l2;
    buffer4_valid_d <= buffer4_valid_l2;
    buffer5_valid_d <= buffer5_valid_l2;
    buffer6_valid_d <= buffer6_valid_l2;
    buffer7_valid_d <= buffer7_valid_l2;

    buffer1_data_d <= buffer1_data_l2;
    buffer2_data_d <= buffer2_data_l2;
    buffer3_data_d <= buffer3_data_l2;
    buffer4_data_d <= buffer4_data_l2;
    buffer5_data_d <= buffer5_data_l2;
    buffer6_data_d <= buffer6_data_l2;
    buffer7_data_d <= buffer7_data_l2;

    buffer_ifar_update  <= '0';

    if (stall_l2(0) = '1') then
        if(buffer1_valid_l2 = '0') then
            buffer1_valid_d <= valid_in(0);
            buffer_ifar_update <= valid_in(0);
            buffer2_valid_d <= valid_in(1);
            buffer3_valid_d <= valid_in(2);
            buffer4_valid_d <= valid_in(3);
            buffer1_data_d  <= ib_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
            buffer2_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer3_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer4_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
        end if;
        
        if(buffer1_valid_l2 = '1' and buffer2_valid_l2 = '0' and buffer_ifar_match = '1') then
            buffer2_valid_d <= valid_in(0);
            buffer3_valid_d <= valid_in(1);
            buffer4_valid_d <= valid_in(2);
            buffer5_valid_d <= valid_in(3);
        end if;
        if(buffer1_valid_l2 = '1' and buffer2_valid_l2 = '0') then
            buffer2_data_d  <= ib_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
            buffer3_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer4_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer5_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
        end if;

        if(buffer2_valid_l2 = '1' and buffer3_valid_l2 = '0' and buffer_ifar_match = '1') then
            buffer3_valid_d <= valid_in(0);
            buffer4_valid_d <= valid_in(1);
            buffer5_valid_d <= valid_in(2);
            buffer6_valid_d <= valid_in(3);
        end if;
        if(buffer2_valid_l2 = '1' and buffer3_valid_l2 = '0' ) then
            buffer3_data_d  <= ib_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
            buffer4_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer5_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer6_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
        end if;

        if(buffer3_valid_l2 = '1' and buffer4_valid_l2 = '0' and buffer_ifar_match = '1') then
            buffer4_valid_d <= valid_in(0);
            buffer5_valid_d <= valid_in(1);
            buffer6_valid_d <= valid_in(2);
            buffer7_valid_d <= valid_in(3);
        end if;
        if(buffer3_valid_l2 = '1' and buffer4_valid_l2 = '0') then
            buffer4_data_d  <= ib_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
            buffer5_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer6_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer7_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
        end if;

        --added for ucode
        if(buffer4_valid_l2 = '1' and buffer5_valid_l2 = '0' and buffer_ifar_match_uc = '1') then
            buffer5_valid_d <= valid_in_uc;
        end if;
        if(buffer4_valid_l2 = '1' and buffer5_valid_l2 = '0') then
            buffer5_data_d  <= uc_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
        end if;

        if(buffer5_valid_l2 = '1' and buffer6_valid_l2 = '0' and buffer_ifar_match_uc = '1') then
            buffer6_valid_d <= valid_in_uc;
        end if;
        if(buffer5_valid_l2 = '1' and buffer6_valid_l2 = '0') then
            buffer6_data_d  <= uc_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
        end if;


    else    -- stall_l2 = 0
        buffer1_data_d  <= buffer2_data_l2;
        buffer2_data_d  <= buffer3_data_l2;
        buffer3_data_d  <= buffer4_data_l2;
        buffer4_data_d  <= buffer5_data_l2;
        buffer5_data_d  <= buffer6_data_l2;
        buffer6_data_d  <= buffer7_data_l2;

        buffer1_valid_d <= buffer2_valid_l2;
        buffer2_valid_d <= buffer3_valid_l2;
        buffer3_valid_d <= buffer4_valid_l2;
        buffer4_valid_d <= buffer5_valid_l2;
        buffer5_valid_d <= buffer6_valid_l2;
        buffer6_valid_d <= buffer7_valid_l2;
        buffer7_valid_d <= '0';

        if(buffer1_valid_l2 = '0' and valid_fast = '1') then
            buffer_ifar_update <= valid_in(0);
            buffer1_valid_d <= valid_in(1);
            buffer2_valid_d <= valid_in(2);
            buffer3_valid_d <= valid_in(3);
            buffer1_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer2_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer3_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
        end if;

        if((buffer1_valid_l2 = '1' and buffer2_valid_l2 = '0') or (buffer1_valid_l2 = '0' and valid_slow = '1')) then
            buffer1_valid_d <= valid_in(0);
            buffer_ifar_update <= valid_in(0);
            buffer2_valid_d <= valid_in(1);
            buffer3_valid_d <= valid_in(2);
            buffer4_valid_d <= valid_in(3);
            buffer1_data_d  <= ib_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
            buffer2_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer3_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer4_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
          end if;

        if(buffer2_valid_l2 = '1' and buffer3_valid_l2 = '0' and buffer_ifar_match = '1') then
            buffer2_valid_d <= valid_in(0);
            buffer3_valid_d <= valid_in(1);
            buffer4_valid_d <= valid_in(2);
            buffer5_valid_d <= valid_in(3);
        end if;
        if(buffer2_valid_l2 = '1' and buffer3_valid_l2 = '0') then
            buffer2_data_d  <= ib_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
            buffer3_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer4_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer5_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
        end if;

        if(buffer3_valid_l2 = '1' and buffer4_valid_l2 = '0' and buffer_ifar_match = '1') then
            buffer3_valid_d <= valid_in(0);
            buffer4_valid_d <= valid_in(1);
            buffer5_valid_d <= valid_in(2);
            buffer6_valid_d <= valid_in(3);
        end if;
        if(buffer3_valid_l2 = '1' and buffer4_valid_l2 = '0' ) then
            buffer3_data_d  <= ib_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
            buffer4_data_d  <= ib_iu4_1_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_1;
            buffer5_data_d  <= ib_iu4_2_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_2;
            buffer6_data_d  <= ib_iu4_3_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to 59) & pc_ext_3;
        end if;

        if(buffer4_valid_l2 = '1' and buffer5_valid_l2 = '0' and buffer_ifar_match_uc = '1') then
            buffer4_valid_d <= valid_in_uc;
        end if;
        if(buffer4_valid_l2 = '1' and buffer5_valid_l2 = '0' ) then
            buffer4_data_d  <= uc_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
        end if;

        if(buffer5_valid_l2 = '1' and buffer6_valid_l2 = '0' and buffer_ifar_match_uc = '1') then
            buffer5_valid_d <= valid_in_uc;
        end if;
        if(buffer5_valid_l2 = '1' and buffer6_valid_l2 = '0' ) then
            buffer5_data_d  <= uc_iu4_0_instr & ib_iu4_ifar(EFF_IFAR'right+1-ibuff_ifar_width to EFF_IFAR'right);
        end if;

    end if;      

    if(xu_iu_ib1_flush = '1' or uc_flush = '1') then
      buffer1_valid_d <= '0';
      buffer2_valid_d <= '0';
      buffer3_valid_d <= '0';
      buffer4_valid_d <= '0';
      buffer5_valid_d <= '0';
      buffer6_valid_d <= '0';
      buffer7_valid_d <= '0';
    end if;

end process;

--added for clock gating
buffer1_data_act <= not (stall_l2(0) and buffer1_valid_l2);
buffer2_data_act <= not (stall_l2(0) and buffer2_valid_l2);
buffer3_data_act <= not (stall_l2(0) and buffer3_valid_l2);
buffer4_data_act <= not (stall_l2(0) and buffer4_valid_l2);
buffer5_data_act <= not (stall_l2(0) and buffer5_valid_l2);
buffer6_data_act <= not (stall_l2(0) and buffer6_valid_l2);
buffer7_data_act <= not (stall_l2(0) and buffer7_valid_l2);



ib_ic_empty <= not (buffer1_valid_l2 or stall_l2(0));
ib_ic_below_water <= (not buffer4_valid_l2) or (not buffer5_valid_l2 and not stall_l2(0));
--duplicate for iu4_act...incoming pipeline will only contain valid data when buffer is below water and able to accept it
iu4_act           <= (not buffer4_valid_l2) or (not buffer5_valid_l2 and not stall_l2(0));

-- reconstruct buffer1_data
buffer1_data    <= buffer1_data_l2(0 to ibuff_data_width-1) &
                   buffer_ifar_l2(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width) &
                   buffer1_data_l2(ibuff_data_width to command_width_lite-1);

gen_uc_match1: if (ibuff_ifar_width < uc_ifar) generate
begin
-- generate flush based on stored ifar
buffer_ifar_match       <= '1' when buffer_ifar_l2(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width) = ib_iu4_ifar(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width) else
                           '0';
buffer_ifar_match_uc    <= buffer_ifar_match;   --for ucode-only buffer fill
end generate;

gen_uc_match0: if (ibuff_ifar_width >= uc_ifar) generate
begin
--assume address match on ucode/ram issued instructions for timing
buffer_ifar_match       <= (not bp_ib_iu4_val(0)) or
                           (buffer_ifar_l2(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width) = bp_ib_iu4_ifar(EFF_IFAR'left to EFF_IFAR'right-ibuff_ifar_width));
buffer_ifar_match_uc    <= '1';                 --for ucode-only buffer fill
end generate;

redirect_d              <= valid_in(0) and not xu_iu_ib1_flush and not uc_flush and not buffer_ifar_match and not buffer_ifar_update;

ib_ic_iu5_redirect_tid  <= redirect_l2;


--move stall latch to decode
stall_d(0)             <= fdec_ibuf_stall;     
stall_d(1)             <= fdec_ibuf_stall;     
stall_d(2)             <= fdec_ibuf_stall;     

stall_buffer_data_d <= 
                       buffer1_data             when buffer1_valid_l2 = '1' else
                       ib_iu4_0_instr & ib_iu4_ifar;



buff1_sel_d(0)  <= buffer1_valid_d;
buff1_sel_d(1)  <= buffer1_valid_d;
buff1_sel_d(2)  <= buffer1_valid_d;
buff1_sel_d(3)  <= buffer1_valid_d;
buff1_sel_d(4)  <= buffer1_valid_d;


-- Instruction output
valid_out <= (buffer1_valid_l2 or valid_fast or stall_l2(0));

buffer_data(0 to 7)                     <= buffer1_data(0 to 7)                         when buff1_sel_l2(1) = '1' else
                                           bp_iu4_0_instr(0 to 7);

buffer_data(8 to 15)                    <= buffer1_data(8 to 15)                        when buff1_sel_l2(2) = '1' else
                                           bp_iu4_0_instr(8 to 15);

buffer_data(16 to 23)                   <= buffer1_data(16 to 23)                       when buff1_sel_l2(3) = '1' else
                                           bp_iu4_0_instr(16 to 23);

buffer_data(24 to 31)                   <= buffer1_data(24 to 31)                       when buff1_sel_l2(4) = '1' else
                                           bp_iu4_0_instr(24 to 31);

buffer_data(32 to command_width_full-1) <= buffer1_data(32 to command_width_full-1)     when buff1_sel_l2(0) = '1' else
                                           (bp_iu4_0_instr(32 to 49) & bp_ib_iu4_ifar);


data_out(0 to 15)                       <= stall_buffer_data_l2(0 to 15)                        when stall_L2(1) = '1' else
                                           buffer_data(0 to 15);

data_out(16 to 31)                      <= stall_buffer_data_l2(16 to 31)                       when stall_L2(2) = '1' else
                                           buffer_data(16 to 31);

data_out(32 to command_width_full-1)    <= stall_buffer_data_l2(32 to command_width_full-1)     when stall_L2(0) = '1' else
                                           buffer_data(32 to  command_width_full-1);

iu_au_ib1_valid <= valid_out;

iu_au_ib1_data <= data_out(0 to ibuff_data_width-1);

iu_au_ib1_ifar <= data_out(ibuff_data_width to command_width_full-1);


-----------------------------------------------------------------------
-- Perf
-----------------------------------------------------------------------

perf_event_d(0)         <= not (buffer1_valid_l2 or stall_l2(0));
perf_event_d(1)         <= redirect_l2;

ib_perf_event(0)        <= perf_event_l2(0);    -- ibuf empty
ib_perf_event(1)        <= perf_event_l2(1);    -- ibuf flush

-----------------------------------------------------------------------
-- Debug
-----------------------------------------------------------------------


ib_dbg_data_d(0 to 3)     <= bp_ib_iu4_val(0 to 3);
ib_dbg_data_d(4)          <= rm_ib_iu4_val;
ib_dbg_data_d(5)          <= uc_ib_iu4_val;

ib_dbg_data(0 to 5)     <= ib_dbg_data_l2(0 to 5);
ib_dbg_data(6)          <= redirect_l2;
ib_dbg_data(7)          <= (not buffer4_valid_l2) or (not buffer5_valid_l2 and not stall_l2(0)); --below water
ib_dbg_data(8)          <= stall_l2(0);
ib_dbg_data(9)          <= buffer1_valid_l2;
ib_dbg_data(10)         <= buffer2_valid_l2;
ib_dbg_data(11)         <= buffer3_valid_l2;
ib_dbg_data(12)         <= buffer4_valid_l2;
ib_dbg_data(13)         <= buffer5_valid_l2;
ib_dbg_data(14)         <= buffer6_valid_l2;
ib_dbg_data(15)         <= buffer7_valid_l2;

-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
bp_ib_iu4_0_instr_latch: tri_rlmreg_p
  generic map (width => bp_ib_iu4_0_instr_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => iu4_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(bp_ib_iu4_0_instr_offset to bp_ib_iu4_0_instr_offset+bp_ib_iu4_0_instr_l2'length-1),
            scout   => sov(bp_ib_iu4_0_instr_offset to bp_ib_iu4_0_instr_offset+bp_ib_iu4_0_instr_l2'length-1),
            din     => bp_ib_iu4_0_instr_d(0 to bp_ib_iu4_0_instr_l2'length-1),
            dout    => bp_ib_iu4_0_instr_l2(0 to bp_ib_iu4_0_instr_l2'length-1)  );

buffer1_data_latch: tri_rlmreg_p
  generic map (width => buffer1_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => buffer1_data_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer1_data_offset to buffer1_data_offset+buffer1_data_l2'length-1),
            scout   => sov(buffer1_data_offset to buffer1_data_offset+buffer1_data_l2'length-1),
            din     => buffer1_data_d(0 to command_width_lite-1),
            dout    => buffer1_data_l2(0 to command_width_lite-1)  );

buffer2_data_latch: tri_rlmreg_p
  generic map (width => buffer2_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => buffer2_data_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer2_data_offset to buffer2_data_offset+buffer2_data_l2'length-1),
            scout   => sov(buffer2_data_offset to buffer2_data_offset+buffer2_data_l2'length-1),
            din     => buffer2_data_d(0 to command_width_lite-1),
            dout    => buffer2_data_l2(0 to command_width_lite-1)  );

buffer3_data_latch: tri_rlmreg_p
  generic map (width => buffer3_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => buffer3_data_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer3_data_offset to buffer3_data_offset+buffer3_data_l2'length-1),
            scout   => sov(buffer3_data_offset to buffer3_data_offset+buffer3_data_l2'length-1),
            din     => buffer3_data_d(0 to command_width_lite-1),
            dout    => buffer3_data_l2(0 to command_width_lite-1)  );

buffer4_data_latch: tri_rlmreg_p
  generic map (width => buffer4_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => buffer4_data_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer4_data_offset to buffer4_data_offset+buffer4_data_l2'length-1),
            scout   => sov(buffer4_data_offset to buffer4_data_offset+buffer4_data_l2'length-1),
            din     => buffer4_data_d(0 to command_width_lite-1),
            dout    => buffer4_data_l2(0 to command_width_lite-1)  );

buffer5_data_latch: tri_rlmreg_p
  generic map (width => buffer5_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => buffer5_data_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer5_data_offset to buffer5_data_offset+buffer5_data_l2'length-1),
            scout   => sov(buffer5_data_offset to buffer5_data_offset+buffer5_data_l2'length-1),
            din     => buffer5_data_d(0 to command_width_lite-1),
            dout    => buffer5_data_l2(0 to command_width_lite-1)  );

buffer6_data_latch: tri_rlmreg_p
  generic map (width => buffer6_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => buffer6_data_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer6_data_offset to buffer6_data_offset+buffer6_data_l2'length-1),
            scout   => sov(buffer6_data_offset to buffer6_data_offset+buffer6_data_l2'length-1),
            din     => buffer6_data_d(0 to command_width_lite-1),
            dout    => buffer6_data_l2(0 to command_width_lite-1)  );

buffer7_data_latch: tri_rlmreg_p
  generic map (width => buffer7_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => buffer7_data_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer7_data_offset to buffer7_data_offset+buffer7_data_l2'length-1),
            scout   => sov(buffer7_data_offset to buffer7_data_offset+buffer7_data_l2'length-1),
            din     => buffer7_data_d(0 to command_width_lite-1),
            dout    => buffer7_data_l2(0 to command_width_lite-1)  );

buffer1_valid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer1_valid_offset),
            scout   => sov(buffer1_valid_offset),
            din     => buffer1_valid_d,
            dout    => buffer1_valid_l2   );

buffer2_valid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer2_valid_offset),
            scout   => sov(buffer2_valid_offset),
            din     => buffer2_valid_d,
            dout    => buffer2_valid_l2   );

buffer3_valid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer3_valid_offset),
            scout   => sov(buffer3_valid_offset),
            din     => buffer3_valid_d,
            dout    => buffer3_valid_l2   );

buffer4_valid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer4_valid_offset),
            scout   => sov(buffer4_valid_offset),
            din     => buffer4_valid_d,
            dout    => buffer4_valid_l2   );

buffer5_valid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer5_valid_offset),
            scout   => sov(buffer5_valid_offset),
            din     => buffer5_valid_d,
            dout    => buffer5_valid_l2   );

buffer6_valid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer6_valid_offset),
            scout   => sov(buffer6_valid_offset),
            din     => buffer6_valid_d,
            dout    => buffer6_valid_l2   );

buffer7_valid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer7_valid_offset),
            scout   => sov(buffer7_valid_offset),
            din     => buffer7_valid_d,
            dout    => buffer7_valid_l2   );

stall_buffer_act <= not stall_l2(0);
stall_buffer_data_latch: tri_rlmreg_p
  generic map (width => stall_buffer_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => stall_buffer_act,        --tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(stall_buffer_data_offset to stall_buffer_data_offset+stall_buffer_data_l2'length-1),
            scout   => sov(stall_buffer_data_offset to stall_buffer_data_offset+stall_buffer_data_l2'length-1),
            din     => stall_buffer_data_d(0 to command_width_full-1),
            dout    => stall_buffer_data_l2(0 to command_width_full-1)  );

stall_latch: tri_rlmreg_p
  generic map (width => stall_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(stall_offset to stall_offset+stall_l2'length-1),
            scout   => sov(stall_offset to stall_offset+stall_l2'length-1),
            din     => stall_d(0 to 2),
            dout    => stall_l2(0 to 2)   );

buffer_ifar_latch: tri_rlmreg_p
  generic map (width => buffer_ifar_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => valid_in(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buffer_ifar_offset to buffer_ifar_offset+buffer_ifar_l2'length-1),
            scout   => sov(buffer_ifar_offset to buffer_ifar_offset+buffer_ifar_l2'length-1),
            din     => buffer_ifar_d,
            dout    => buffer_ifar_l2  );

redirect_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(redirect_offset),
            scout   => sov(redirect_offset),
            din     => redirect_d,
            dout    => redirect_l2   );




buff1_sel_latch: tri_rlmreg_p
  generic map (width => buff1_sel_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(buff1_sel_offset to buff1_sel_offset+buff1_sel_l2'length-1),
            scout   => sov(buff1_sel_offset to buff1_sel_offset+buff1_sel_l2'length-1),
            din     => buff1_sel_d(0 to 4),
            dout    => buff1_sel_l2(0 to 4)  );


event_bus_enable_d <= pc_iu_event_bus_enable;

event_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_bus_enable_offset),
            scout   => sov(event_bus_enable_offset),
            din     => event_bus_enable_d,
            dout    => event_bus_enable_q);

trace_bus_enable_d <= pc_iu_trace_bus_enable;

trace_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => trace_bus_enable_d,
            dout    => trace_bus_enable_q);

perf_event_latch: tri_rlmreg_p
  generic map (width => perf_event_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => event_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,

            scin    => siv(perf_event_offset to perf_event_offset+perf_event_l2'length-1),
            scout   => sov(perf_event_offset to perf_event_offset+perf_event_l2'length-1),
            din     => perf_event_d(0 to 1),
            dout    => perf_event_l2(0 to 1)  );

ib_dbg_data_latch: tri_rlmreg_p
  generic map (width => ib_dbg_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,

            scin    => siv(ib_dbg_data_offset to ib_dbg_data_offset+ib_dbg_data_l2'length-1),
            scout   => sov(ib_dbg_data_offset to ib_dbg_data_offset+ib_dbg_data_l2'length-1),
            din     => ib_dbg_data_d,
            dout    => ib_dbg_data_l2  );

spare_latch: tri_rlmreg_p
  generic map (width => spare_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spare_offset to spare_offset + spare_l2'length-1),
            scout   => sov(spare_offset to spare_offset + spare_l2'length-1),
            din     => spare_l2,
            dout    => spare_l2);

-------------------------------------------------
-- pervasive
-------------------------------------------------

perv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_sg_1);

perv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_sg_0);

perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);




-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0) and an_ac_scan_dis_dc_b;


end iuq_ib_buff;
