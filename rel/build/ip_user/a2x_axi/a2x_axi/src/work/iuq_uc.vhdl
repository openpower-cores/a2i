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

			

library ieee,ibm,support,tri,work;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
use work.iuq_pkg.all;

entity iuq_uc is
  generic(ucode_width           : integer := 71;
          uc_ifar               : integer := 21;
          regmode               : integer := 6;
          expand_type           : integer := 2);
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     pc_iu_func_sl_thold_2      : in std_ulogic;
     pc_iu_sg_2                 : in std_ulogic;
     an_ac_scan_dis_dc_b        : in std_ulogic;
     tc_ac_ccflush_dc           : in std_ulogic;
     clkoff_b                   : in std_ulogic;
     delay_lclkr                : in std_ulogic;
     mpw1_b                     : in std_ulogic;
     scan_in                    : in std_ulogic;
     scan_out                   : out std_ulogic;

     spr_ic_clockgate_dis       : in  std_ulogic;

     iu_pc_err_ucode_illegal    : out std_ulogic_vector(0 to 3);

     xu_iu_spr_xer0             : in std_ulogic_vector(57 to 63);
     xu_iu_spr_xer1             : in std_ulogic_vector(57 to 63);
     xu_iu_spr_xer2             : in std_ulogic_vector(57 to 63);
     xu_iu_spr_xer3             : in std_ulogic_vector(57 to 63);


     xu_iu_flush            	: in std_ulogic_vector(0 to 3);
     xu_iu_ucode_restart        : in std_ulogic_vector(0 to 3); 
     xu_iu_uc_flush_ifar0       : in std_ulogic_vector(62-uc_ifar to 61);  
     xu_iu_uc_flush_ifar1       : in std_ulogic_vector(62-uc_ifar to 61);  
     xu_iu_uc_flush_ifar2       : in std_ulogic_vector(62-uc_ifar to 61);  
     xu_iu_uc_flush_ifar3       : in std_ulogic_vector(62-uc_ifar to 61);  

     uc_flush_tid               : out std_ulogic_vector(0 to 3);

     fiss_uc_is2_ucode_vld      : in std_ulogic;
     fiss_uc_is2_tid            : in std_ulogic_vector(0 to 3);
     fiss_uc_is2_instr          : in std_ulogic_vector(0 to 31);
     fiss_uc_is2_2ucode         : in std_ulogic;
     fiss_uc_is2_2ucode_type    : in std_ulogic;

     ib_uc_buff0_avail          : in std_ulogic;  
     ib_uc_buff1_avail          : in std_ulogic;  
     ib_uc_buff2_avail          : in std_ulogic;  
     ib_uc_buff3_avail          : in std_ulogic;  

     uc_ib_iu4_valid_tid        : out std_ulogic_vector(0 to 3);
     uc_ib_iu4_ifar             : out std_ulogic_vector(62-uc_ifar to 61);
     uc_ib_iu4_instr            : out std_ulogic_vector(0 to 31);
     uc_ib_iu4_is_ucode         : out std_ulogic;
     uc_ib_iu4_ext              : out std_ulogic_vector(0 to 3);  

     uc_ic_hold_thread          : out std_ulogic_vector(0 to 3);

     pc_iu_trace_bus_enable     : in  std_ulogic;
     uc_dbg_data                : out std_ulogic_vector(0 to 87)

);
-- synopsys translate_off
-- synopsys translate_on
end iuq_uc;
ARCHITECTURE IUQ_UC
          OF IUQ_UC
          IS
SIGNAL GET_ADDRESS_PT                    : STD_ULOGIC_VECTOR(1 TO 96)  := 
(OTHERS=> 'U');
SIGNAL ROM_ISSUE_TABLE_PT                : STD_ULOGIC_VECTOR(1 TO 16)  := 
(OTHERS=> 'U');
SIGNAL force_ep                          : STD_ULOGIC  := 
'U';
SIGNAL late_end                          : STD_ULOGIC  := 
'U';
SIGNAL romtoken_L2                       : STD_ULOGIC_VECTOR(0 TO 3)  := 
"UUUU";
SIGNAL romtoken_d                        : STD_ULOGIC_VECTOR(0 TO 3)  := 
"UUUU";
SIGNAL start_addr                        : STD_ULOGIC_VECTOR(0 TO 9)  := 
"UUUUUUUUUU";
SIGNAL uc_legal                          : STD_ULOGIC  := 
'U';
SIGNAL vld_fast                          : STD_ULOGIC_VECTOR(0 TO 3)  := 
"UUUU";
SIGNAL xer_type                          : STD_ULOGIC  := 
'U';
constant xu_iu_flush_offset             : natural := 0;
constant xu_iu_ucode_restart_offset     : natural := xu_iu_flush_offset + 4;
constant xu_iu_uc_flush_ifar0_offset    : natural := xu_iu_ucode_restart_offset + 4;
constant xu_iu_uc_flush_ifar1_offset    : natural := xu_iu_uc_flush_ifar0_offset + uc_ifar;
constant xu_iu_uc_flush_ifar2_offset    : natural := xu_iu_uc_flush_ifar1_offset + uc_ifar;
constant xu_iu_uc_flush_ifar3_offset    : natural := xu_iu_uc_flush_ifar2_offset + uc_ifar;
constant iu_pc_err_ucode_illegal_offset : natural := xu_iu_uc_flush_ifar3_offset + uc_ifar;
constant ib_uc_buff_avail_offset        : natural := iu_pc_err_ucode_illegal_offset + 4;
constant fiss_uc_is2_ucode_vld_offset   : natural := ib_uc_buff_avail_offset + 4;
constant fiss_uc_is2_tid_offset         : natural := fiss_uc_is2_ucode_vld_offset + 1;
constant fiss_uc_is2_instr_offset       : natural := fiss_uc_is2_tid_offset + 4;
constant fiss_uc_is2_2ucode_offset      : natural := fiss_uc_is2_instr_offset + 32;
constant fiss_uc_is2_2ucode_type_offset : natural := fiss_uc_is2_2ucode_offset + 1;
constant romtoken_offset        : natural := fiss_uc_is2_2ucode_type_offset + 1;
constant romvalid_offset        : natural := romtoken_offset + 4;
constant rom_data_late_offset   : natural := romvalid_offset + 4;
constant iu4_valid_tid_offset   : natural := rom_data_late_offset + 32;
constant iu4_data_tid_offset    : natural := iu4_valid_tid_offset + 4;
constant iu4_ifar_offset        : natural := iu4_data_tid_offset + 4;
constant iu4_is_ucode_offset    : natural := iu4_ifar_offset + uc_ifar;
constant iu4_ext_offset         : natural := iu4_is_ucode_offset + 1;
constant iu5_valid_tid_offset   : natural := iu4_ext_offset + 4;
constant iu5_ifar_offset        : natural := iu5_valid_tid_offset + 4;
constant uc_dbg_data_offset     : natural := iu5_ifar_offset + uc_ifar;
constant spare_offset           : natural := uc_dbg_data_offset + 16;
constant trace_bus_enable_offset: natural := spare_offset + 12;
constant scan_right             : natural := trace_bus_enable_offset + 1 - 1;
signal trace_bus_enable_d                   : std_ulogic;
signal trace_bus_enable_q                   : std_ulogic;
signal iu_pc_err_ucode_illegal_d         : std_ulogic_vector(0 to 3);
signal iu_pc_err_ucode_illegal_l2        : std_ulogic_vector(0 to 3);
signal fiss_uc_is2_ucode_vld_d  : std_ulogic;
signal fiss_uc_is2_tid_d        : std_ulogic_vector(0 to 3);
signal fiss_uc_is2_instr_d      : std_ulogic_vector(0 to 31);
signal fiss_uc_is2_2ucode_d     : std_ulogic;
signal fiss_uc_is2_2ucode_type_d: std_ulogic;
signal fiss_uc_is2_ucode_vld_l2 : std_ulogic;
signal fiss_uc_is2_tid_l2       : std_ulogic_vector(0 to 3);
signal fiss_uc_is2_instr_l2     : std_ulogic_vector(0 to 31);
signal fiss_uc_is2_2ucode_l2    : std_ulogic;
signal fiss_uc_is2_2ucode_type_l2 : std_ulogic;
signal romvalid_d       : std_ulogic_vector(0 to 3);
signal romvalid_l2      : std_ulogic_vector(0 to 3);
signal xu_iu_flush_d            : std_ulogic_vector(0 to 3);
signal xu_iu_flush_l2           : std_ulogic_vector(0 to 3);
signal xu_iu_ucode_restart_d    : std_ulogic_vector(0 to 3);
signal xu_iu_ucode_restart_l2   : std_ulogic_vector(0 to 3);
signal xu_iu_uc_flush_ifar0_d   : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar0_l2  : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar1_d   : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar1_l2  : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar2_d   : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar2_l2  : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar3_d   : std_ulogic_vector(62-uc_ifar to 61);
signal xu_iu_uc_flush_ifar3_l2  : std_ulogic_vector(62-uc_ifar to 61);
signal iu4_valid_tid_d  : std_ulogic_vector(0 to 3);
signal iu4_data_tid_d   : std_ulogic_vector(0 to 3);
signal iu4_ifar_d       : std_ulogic_vector(62-uc_ifar to 61);
signal iu4_is_ucode_d   : std_ulogic;
signal iu4_ext_d        : std_ulogic_vector(0 to 3);
signal iu4_valid_tid_l2 : std_ulogic_vector(0 to 3);
signal iu4_data_tid_l2  : std_ulogic_vector(0 to 3);
signal iu4_ifar_l2      : std_ulogic_vector(62-uc_ifar to 61);
signal iu4_instr_l2     : std_ulogic_vector(0 to 31);
signal iu4_is_ucode_l2  : std_ulogic;
signal iu4_ext_l2       : std_ulogic_vector(0 to 3);
signal iu5_ifar_l2      : std_ulogic_vector(62-uc_ifar to 61);
signal ib_uc_buff_avail_d  : std_ulogic_vector(0 to 3);
signal ib_uc_buff_avail_l2 : std_ulogic_vector(0 to 3);
signal spare_l2         : std_ulogic_vector(0 to 11);
signal load_command     : std_ulogic_vector(0 to 3);
signal early_end        : std_ulogic;
signal new_cond         : std_ulogic;
signal rom_ra0          : std_ulogic_vector(0 to 9);
signal ucode_ifar0      : std_ulogic_vector(62-uc_ifar to 61);
signal ucode_instr0     : std_ulogic_vector(0 to 31);
signal ucode_is_ucode0:   std_ulogic;
signal ucode_ext0       : std_ulogic_vector(0 to 3);
signal rom_ra1          : std_ulogic_vector(0 to 9);
signal ucode_ifar1      : std_ulogic_vector(62-uc_ifar to 61);
signal ucode_instr1     : std_ulogic_vector(0 to 31);
signal ucode_is_ucode1:   std_ulogic;
signal ucode_ext1       : std_ulogic_vector(0 to 3);
signal rom_ra2          : std_ulogic_vector(0 to 9);
signal ucode_ifar2      : std_ulogic_vector(62-uc_ifar to 61);
signal ucode_instr2     : std_ulogic_vector(0 to 31);
signal ucode_is_ucode2:   std_ulogic;
signal ucode_ext2       : std_ulogic_vector(0 to 3);
signal rom_ra3          : std_ulogic_vector(0 to 9);
signal ucode_ifar3      : std_ulogic_vector(62-uc_ifar to 61);
signal ucode_instr3     : std_ulogic_vector(0 to 31);
signal ucode_is_ucode3:   std_ulogic;
signal ucode_ext3       : std_ulogic_vector(0 to 3);
signal ucode_valid      : std_ulogic_vector(0 to 3);
signal uc_control_dbg_data0     : std_ulogic_vector(0 to 3);
signal uc_control_dbg_data1     : std_ulogic_vector(0 to 3);
signal uc_control_dbg_data2     : std_ulogic_vector(0 to 3);
signal uc_control_dbg_data3     : std_ulogic_vector(0 to 3);
signal uc_act           : std_ulogic_vector(0 to 3);
signal uc_any_act       : std_ulogic;
signal rom_act          : std_ulogic;
signal rom_addr         : std_ulogic_vector(0 to 9);
signal rom_data_tid     : std_ulogic_vector(0 to 3);
signal data_valid       : std_ulogic_vector(0 to 3);
signal rom_data         : std_ulogic_vector(0 to ucode_width-1);
signal rom_data_late_d  : std_ulogic_vector(0 to 31);
signal rom_data_late_l2 : std_ulogic_vector(0 to 31);
signal iu4_stage_act    : std_ulogic;
signal ib_flush         : std_ulogic_vector(0 to 3);
signal vld_mask         : std_ulogic_vector(0 to 3);
signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;
signal siv              : std_ulogic_vector(0 to scan_right+5);
signal sov              : std_ulogic_vector(0 to scan_right+5);
signal tiup             : std_ulogic;
signal act_dis          : std_ulogic;
signal d_mode           : std_ulogic;
signal mpw2_b           : std_ulogic;
signal uc_dbg_data_d    : std_ulogic_vector(44 to 59);
signal uc_dbg_data_l2   : std_ulogic_vector(44 to 59);
-- synopsys translate_off
-- synopsys translate_on
  BEGIN 

tiup  <=  '1';
act_dis  <=  '0';
d_mode  <=  '0';
mpw2_b  <=  '1';
fiss_uc_is2_ucode_vld_d  <=  fiss_uc_is2_ucode_vld;
fiss_uc_is2_tid_d        <=  fiss_uc_is2_tid and not xu_iu_flush;
fiss_uc_is2_instr_d      <=  fiss_uc_is2_instr;
fiss_uc_is2_2ucode_d     <=  fiss_uc_is2_2ucode;
fiss_uc_is2_2ucode_type_d  <=  fiss_uc_is2_2ucode_type;
load_command  <=  gate_and(fiss_uc_is2_ucode_vld_l2, fiss_uc_is2_tid_l2);
uc_flush_tid  <=  gate_and(fiss_uc_is2_ucode_vld_l2, fiss_uc_is2_tid_l2);
early_end  <=  not late_end;
new_cond  <=  not fiss_uc_is2_2ucode_type_l2;
MQQ1:GET_ADDRESS_PT(1) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111101011111"));
MQQ2:GET_ADDRESS_PT(2) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110000111010"));
MQQ3:GET_ADDRESS_PT(3) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111000010101"));
MQQ4:GET_ADDRESS_PT(4) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30) & 
    FISS_UC_IS2_2UCODE_L2 ) , STD_ULOGIC_VECTOR'("01111101011101011"));
MQQ5:GET_ADDRESS_PT(5) <=
    Eq(( FISS_UC_IS2_INSTR_L2(1) & FISS_UC_IS2_INSTR_L2(2) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(21) & 
    FISS_UC_IS2_INSTR_L2(22) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("11111011111010"));
MQQ6:GET_ADDRESS_PT(6) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111000000000"));
MQQ7:GET_ADDRESS_PT(7) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(21) & 
    FISS_UC_IS2_INSTR_L2(22) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00000111001110"));
MQQ8:GET_ADDRESS_PT(8) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30) & 
    FISS_UC_IS2_2UCODE_L2 ) , STD_ULOGIC_VECTOR'("01111100001101011"));
MQQ9:GET_ADDRESS_PT(9) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111110010110"));
MQQ10:GET_ADDRESS_PT(10) <=
    Eq(( FISS_UC_IS2_INSTR_L2(1) & FISS_UC_IS2_INSTR_L2(2) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(21) & 
    FISS_UC_IS2_INSTR_L2(22) & FISS_UC_IS2_INSTR_L2(23) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("111110111111010"));
MQQ11:GET_ADDRESS_PT(11) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111100001111"));
MQQ12:GET_ADDRESS_PT(12) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111101010111"));
MQQ13:GET_ADDRESS_PT(13) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111100011111"));
MQQ14:GET_ADDRESS_PT(14) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111010110111"));
MQQ15:GET_ADDRESS_PT(15) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111100010111"));
MQQ16:GET_ADDRESS_PT(16) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110101010101"));
MQQ17:GET_ADDRESS_PT(17) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30) & 
    FISS_UC_IS2_2UCODE_L2 ) , STD_ULOGIC_VECTOR'("01111101011101010"));
MQQ18:GET_ADDRESS_PT(18) <=
    Eq(( FISS_UC_IS2_INSTR_L2(1) & FISS_UC_IS2_INSTR_L2(2) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(21) & 
    FISS_UC_IS2_INSTR_L2(22) & FISS_UC_IS2_INSTR_L2(23) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("1111100001101010"));
MQQ19:GET_ADDRESS_PT(19) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110010011010"));
MQQ20:GET_ADDRESS_PT(20) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111000010100"));
MQQ21:GET_ADDRESS_PT(21) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("0111110101101111"));
MQQ22:GET_ADDRESS_PT(22) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30) & 
    FISS_UC_IS2_2UCODE_L2 ) , STD_ULOGIC_VECTOR'("01111100001101111"));
MQQ23:GET_ADDRESS_PT(23) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30) & 
    FISS_UC_IS2_2UCODE_L2 ) , STD_ULOGIC_VECTOR'("01111100001101110"));
MQQ24:GET_ADDRESS_PT(24) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("0111110101101110"));
MQQ25:GET_ADDRESS_PT(25) <=
    Eq(( FISS_UC_IS2_INSTR_L2(1) & FISS_UC_IS2_INSTR_L2(2) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(21) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("11111001111010"));
MQQ26:GET_ADDRESS_PT(26) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111000011010"));
MQQ27:GET_ADDRESS_PT(27) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110010111010"));
MQQ28:GET_ADDRESS_PT(28) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111110110111"));
MQQ29:GET_ADDRESS_PT(29) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111110110111"));
MQQ30:GET_ADDRESS_PT(30) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111010010110"));
MQQ31:GET_ADDRESS_PT(31) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110011111100"));
MQQ32:GET_ADDRESS_PT(32) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111000010110"));
MQQ33:GET_ADDRESS_PT(33) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111110010110"));
MQQ34:GET_ADDRESS_PT(34) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111011001111"));
MQQ35:GET_ADDRESS_PT(35) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111010010100"));
MQQ36:GET_ADDRESS_PT(36) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111010010111"));
MQQ37:GET_ADDRESS_PT(37) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("1111110010000000"));
MQQ38:GET_ADDRESS_PT(38) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111011010101"));
MQQ39:GET_ADDRESS_PT(39) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110001110111"));
MQQ40:GET_ADDRESS_PT(40) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111000001101"));
MQQ41:GET_ADDRESS_PT(41) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110010110111"));
MQQ42:GET_ADDRESS_PT(42) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111010010101"));
MQQ43:GET_ADDRESS_PT(43) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("1111111011000111"));
MQQ44:GET_ADDRESS_PT(44) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110010110101"));
MQQ45:GET_ADDRESS_PT(45) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111001001111"));
MQQ46:GET_ADDRESS_PT(46) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("111111000100000"));
MQQ47:GET_ADDRESS_PT(47) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111000001111"));
MQQ48:GET_ADDRESS_PT(48) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(24) & FISS_UC_IS2_INSTR_L2(25) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111101001111"));
MQQ49:GET_ADDRESS_PT(49) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111101101111"));
MQQ50:GET_ADDRESS_PT(50) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111101010111"));
MQQ51:GET_ADDRESS_PT(51) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_2UCODE_L2 ) , STD_ULOGIC_VECTOR'("1000010"));
MQQ52:GET_ADDRESS_PT(52) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(26) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("111111000000000"));
MQQ53:GET_ADDRESS_PT(53) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111100101111"));
MQQ54:GET_ADDRESS_PT(54) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111001001101"));
MQQ55:GET_ADDRESS_PT(55) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111111010111"));
MQQ56:GET_ADDRESS_PT(56) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111101110111"));
MQQ57:GET_ADDRESS_PT(57) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111110110111"));
MQQ58:GET_ADDRESS_PT(58) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111110010111"));
MQQ59:GET_ADDRESS_PT(59) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(21) & FISS_UC_IS2_INSTR_L2(22) & 
    FISS_UC_IS2_INSTR_L2(23) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110110110111"));
MQQ60:GET_ADDRESS_PT(60) <=
    Eq(( FISS_UC_IS2_INSTR_L2(1) & FISS_UC_IS2_INSTR_L2(2) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(21) & 
    FISS_UC_IS2_INSTR_L2(22) & FISS_UC_IS2_INSTR_L2(23) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("11111100010101"));
MQQ61:GET_ADDRESS_PT(61) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("100001"));
MQQ62:GET_ADDRESS_PT(62) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(30) & 
    FISS_UC_IS2_INSTR_L2(31) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("11010010"));
MQQ63:GET_ADDRESS_PT(63) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("100010"));
MQQ64:GET_ADDRESS_PT(64) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(21) & 
    FISS_UC_IS2_INSTR_L2(22) & FISS_UC_IS2_INSTR_L2(24) & 
    FISS_UC_IS2_INSTR_L2(25) & FISS_UC_IS2_INSTR_L2(27) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("1111111101110"));
MQQ65:GET_ADDRESS_PT(65) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(29) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("11011110"));
MQQ66:GET_ADDRESS_PT(66) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("100000"));
MQQ67:GET_ADDRESS_PT(67) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(30) & 
    FISS_UC_IS2_INSTR_L2(31) ) , STD_ULOGIC_VECTOR'("1111001"));
MQQ68:GET_ADDRESS_PT(68) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_2UCODE_L2 ) , STD_ULOGIC_VECTOR'("1010110"));
MQQ69:GET_ADDRESS_PT(69) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(30) & FISS_UC_IS2_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("11101010"));
MQQ70:GET_ADDRESS_PT(70) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("101011"));
MQQ71:GET_ADDRESS_PT(71) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(30) & FISS_UC_IS2_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("11101000"));
MQQ72:GET_ADDRESS_PT(72) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00000001"));
MQQ73:GET_ADDRESS_PT(73) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("101010"));
MQQ74:GET_ADDRESS_PT(74) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(30) & FISS_UC_IS2_2UCODE_L2
     ) , STD_ULOGIC_VECTOR'("11101001"));
MQQ75:GET_ADDRESS_PT(75) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("11111110"));
MQQ76:GET_ADDRESS_PT(76) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00000110"));
MQQ77:GET_ADDRESS_PT(77) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28)
     ) , STD_ULOGIC_VECTOR'("00000111"));
MQQ78:GET_ADDRESS_PT(78) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("00000110"));
MQQ79:GET_ADDRESS_PT(79) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) ) , STD_ULOGIC_VECTOR'("10010"));
MQQ80:GET_ADDRESS_PT(80) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) ) , STD_ULOGIC_VECTOR'("11001"));
MQQ81:GET_ADDRESS_PT(81) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("1111100"));
MQQ82:GET_ADDRESS_PT(82) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("1101"));
MQQ83:GET_ADDRESS_PT(83) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("1011"));
MQQ84:GET_ADDRESS_PT(84) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(2) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ85:GET_ADDRESS_PT(85) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ86:GET_ADDRESS_PT(86) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("101110"));
MQQ87:GET_ADDRESS_PT(87) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) & FISS_UC_IS2_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("101111"));
MQQ88:GET_ADDRESS_PT(88) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(29) & 
    FISS_UC_IS2_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("111111010"));
MQQ89:GET_ADDRESS_PT(89) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3) & 
    FISS_UC_IS2_INSTR_L2(4) ) , STD_ULOGIC_VECTOR'("11011"));
MQQ90:GET_ADDRESS_PT(90) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(2) & 
    FISS_UC_IS2_INSTR_L2(3) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) ) , STD_ULOGIC_VECTOR'("10011"));
MQQ91:GET_ADDRESS_PT(91) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3)
     ) , STD_ULOGIC_VECTOR'("1100"));
MQQ92:GET_ADDRESS_PT(92) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) ) , STD_ULOGIC_VECTOR'("101"));
MQQ93:GET_ADDRESS_PT(93) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(3)
     ) , STD_ULOGIC_VECTOR'("1101"));
MQQ94:GET_ADDRESS_PT(94) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("11111110"));
MQQ95:GET_ADDRESS_PT(95) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(27) & FISS_UC_IS2_INSTR_L2(28)
     ) , STD_ULOGIC_VECTOR'("11111111"));
MQQ96:GET_ADDRESS_PT(96) <=
    Eq(( FISS_UC_IS2_INSTR_L2(0) & FISS_UC_IS2_INSTR_L2(1) & 
    FISS_UC_IS2_INSTR_L2(2) & FISS_UC_IS2_INSTR_L2(4) & 
    FISS_UC_IS2_INSTR_L2(5) & FISS_UC_IS2_INSTR_L2(26) & 
    FISS_UC_IS2_INSTR_L2(28) & FISS_UC_IS2_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("11111110"));
MQQ97:START_ADDR(0) <= 
    (GET_ADDRESS_PT(7) OR GET_ADDRESS_PT(17)
     OR GET_ADDRESS_PT(18) OR GET_ADDRESS_PT(23)
     OR GET_ADDRESS_PT(24) OR GET_ADDRESS_PT(37)
     OR GET_ADDRESS_PT(38) OR GET_ADDRESS_PT(39)
     OR GET_ADDRESS_PT(42) OR GET_ADDRESS_PT(43)
     OR GET_ADDRESS_PT(46) OR GET_ADDRESS_PT(49)
     OR GET_ADDRESS_PT(50) OR GET_ADDRESS_PT(52)
     OR GET_ADDRESS_PT(53) OR GET_ADDRESS_PT(55)
     OR GET_ADDRESS_PT(56) OR GET_ADDRESS_PT(57)
     OR GET_ADDRESS_PT(58) OR GET_ADDRESS_PT(60)
     OR GET_ADDRESS_PT(62) OR GET_ADDRESS_PT(63)
     OR GET_ADDRESS_PT(64) OR GET_ADDRESS_PT(68)
     OR GET_ADDRESS_PT(72) OR GET_ADDRESS_PT(76)
     OR GET_ADDRESS_PT(77) OR GET_ADDRESS_PT(78)
     OR GET_ADDRESS_PT(86) OR GET_ADDRESS_PT(87)
     OR GET_ADDRESS_PT(88) OR GET_ADDRESS_PT(90)
     OR GET_ADDRESS_PT(91) OR GET_ADDRESS_PT(93)
     OR GET_ADDRESS_PT(94) OR GET_ADDRESS_PT(95)
     OR GET_ADDRESS_PT(96));
MQQ98:START_ADDR(1) <= 
    (GET_ADDRESS_PT(6) OR GET_ADDRESS_PT(7)
     OR GET_ADDRESS_PT(10) OR GET_ADDRESS_PT(19)
     OR GET_ADDRESS_PT(25) OR GET_ADDRESS_PT(27)
     OR GET_ADDRESS_PT(31) OR GET_ADDRESS_PT(37)
     OR GET_ADDRESS_PT(43) OR GET_ADDRESS_PT(46)
     OR GET_ADDRESS_PT(49) OR GET_ADDRESS_PT(52)
     OR GET_ADDRESS_PT(53) OR GET_ADDRESS_PT(55)
     OR GET_ADDRESS_PT(57) OR GET_ADDRESS_PT(58)
     OR GET_ADDRESS_PT(64) OR GET_ADDRESS_PT(72)
     OR GET_ADDRESS_PT(76) OR GET_ADDRESS_PT(77)
     OR GET_ADDRESS_PT(78) OR GET_ADDRESS_PT(88)
     OR GET_ADDRESS_PT(91) OR GET_ADDRESS_PT(93)
     OR GET_ADDRESS_PT(94) OR GET_ADDRESS_PT(95)
     OR GET_ADDRESS_PT(96));
MQQ99:START_ADDR(2) <= 
    (GET_ADDRESS_PT(6) OR GET_ADDRESS_PT(7)
     OR GET_ADDRESS_PT(26) OR GET_ADDRESS_PT(30)
     OR GET_ADDRESS_PT(35) OR GET_ADDRESS_PT(37)
     OR GET_ADDRESS_PT(41) OR GET_ADDRESS_PT(43)
     OR GET_ADDRESS_PT(44) OR GET_ADDRESS_PT(45)
     OR GET_ADDRESS_PT(46) OR GET_ADDRESS_PT(50)
     OR GET_ADDRESS_PT(52) OR GET_ADDRESS_PT(54)
     OR GET_ADDRESS_PT(56) OR GET_ADDRESS_PT(64)
     OR GET_ADDRESS_PT(72) OR GET_ADDRESS_PT(76)
     OR GET_ADDRESS_PT(77) OR GET_ADDRESS_PT(78)
     OR GET_ADDRESS_PT(79) OR GET_ADDRESS_PT(81)
     OR GET_ADDRESS_PT(88) OR GET_ADDRESS_PT(94)
     OR GET_ADDRESS_PT(95) OR GET_ADDRESS_PT(96)
    );
MQQ100:START_ADDR(3) <= 
    (GET_ADDRESS_PT(4) OR GET_ADDRESS_PT(8)
     OR GET_ADDRESS_PT(9) OR GET_ADDRESS_PT(16)
     OR GET_ADDRESS_PT(19) OR GET_ADDRESS_PT(20)
     OR GET_ADDRESS_PT(26) OR GET_ADDRESS_PT(27)
     OR GET_ADDRESS_PT(31) OR GET_ADDRESS_PT(34)
     OR GET_ADDRESS_PT(38) OR GET_ADDRESS_PT(40)
     OR GET_ADDRESS_PT(42) OR GET_ADDRESS_PT(49)
     OR GET_ADDRESS_PT(50) OR GET_ADDRESS_PT(56)
     OR GET_ADDRESS_PT(57) OR GET_ADDRESS_PT(59)
     OR GET_ADDRESS_PT(69) OR GET_ADDRESS_PT(71)
     OR GET_ADDRESS_PT(74) OR GET_ADDRESS_PT(85)
     OR GET_ADDRESS_PT(87) OR GET_ADDRESS_PT(88)
     OR GET_ADDRESS_PT(93));
MQQ101:START_ADDR(4) <= 
    (GET_ADDRESS_PT(6) OR GET_ADDRESS_PT(7)
     OR GET_ADDRESS_PT(8) OR GET_ADDRESS_PT(9)
     OR GET_ADDRESS_PT(10) OR GET_ADDRESS_PT(18)
     OR GET_ADDRESS_PT(19) OR GET_ADDRESS_PT(20)
     OR GET_ADDRESS_PT(22) OR GET_ADDRESS_PT(28)
     OR GET_ADDRESS_PT(31) OR GET_ADDRESS_PT(32)
     OR GET_ADDRESS_PT(34) OR GET_ADDRESS_PT(35)
     OR GET_ADDRESS_PT(37) OR GET_ADDRESS_PT(40)
     OR GET_ADDRESS_PT(42) OR GET_ADDRESS_PT(43)
     OR GET_ADDRESS_PT(44) OR GET_ADDRESS_PT(46)
     OR GET_ADDRESS_PT(47) OR GET_ADDRESS_PT(49)
     OR GET_ADDRESS_PT(50) OR GET_ADDRESS_PT(52)
     OR GET_ADDRESS_PT(53) OR GET_ADDRESS_PT(54)
     OR GET_ADDRESS_PT(55) OR GET_ADDRESS_PT(56)
     OR GET_ADDRESS_PT(59) OR GET_ADDRESS_PT(60)
     OR GET_ADDRESS_PT(61) OR GET_ADDRESS_PT(64)
     OR GET_ADDRESS_PT(66) OR GET_ADDRESS_PT(72)
     OR GET_ADDRESS_PT(75) OR GET_ADDRESS_PT(76)
     OR GET_ADDRESS_PT(77) OR GET_ADDRESS_PT(78)
     OR GET_ADDRESS_PT(81) OR GET_ADDRESS_PT(85)
     OR GET_ADDRESS_PT(86) OR GET_ADDRESS_PT(94)
     OR GET_ADDRESS_PT(95) OR GET_ADDRESS_PT(96)
    );
MQQ102:START_ADDR(5) <= 
    (GET_ADDRESS_PT(2) OR GET_ADDRESS_PT(3)
     OR GET_ADDRESS_PT(5) OR GET_ADDRESS_PT(7)
     OR GET_ADDRESS_PT(9) OR GET_ADDRESS_PT(14)
     OR GET_ADDRESS_PT(17) OR GET_ADDRESS_PT(22)
     OR GET_ADDRESS_PT(23) OR GET_ADDRESS_PT(24)
     OR GET_ADDRESS_PT(27) OR GET_ADDRESS_PT(30)
     OR GET_ADDRESS_PT(32) OR GET_ADDRESS_PT(34)
     OR GET_ADDRESS_PT(37) OR GET_ADDRESS_PT(38)
     OR GET_ADDRESS_PT(41) OR GET_ADDRESS_PT(43)
     OR GET_ADDRESS_PT(45) OR GET_ADDRESS_PT(46)
     OR GET_ADDRESS_PT(47) OR GET_ADDRESS_PT(52)
     OR GET_ADDRESS_PT(55) OR GET_ADDRESS_PT(56)
     OR GET_ADDRESS_PT(59) OR GET_ADDRESS_PT(64)
     OR GET_ADDRESS_PT(65) OR GET_ADDRESS_PT(70)
     OR GET_ADDRESS_PT(71) OR GET_ADDRESS_PT(72)
     OR GET_ADDRESS_PT(73) OR GET_ADDRESS_PT(74)
     OR GET_ADDRESS_PT(76) OR GET_ADDRESS_PT(77)
     OR GET_ADDRESS_PT(78) OR GET_ADDRESS_PT(80)
     OR GET_ADDRESS_PT(85) OR GET_ADDRESS_PT(87)
     OR GET_ADDRESS_PT(89) OR GET_ADDRESS_PT(94)
     OR GET_ADDRESS_PT(95) OR GET_ADDRESS_PT(96)
    );
MQQ103:START_ADDR(6) <= 
    (GET_ADDRESS_PT(2) OR GET_ADDRESS_PT(4)
     OR GET_ADDRESS_PT(5) OR GET_ADDRESS_PT(7)
     OR GET_ADDRESS_PT(12) OR GET_ADDRESS_PT(16)
     OR GET_ADDRESS_PT(17) OR GET_ADDRESS_PT(21)
     OR GET_ADDRESS_PT(23) OR GET_ADDRESS_PT(27)
     OR GET_ADDRESS_PT(31) OR GET_ADDRESS_PT(33)
     OR GET_ADDRESS_PT(35) OR GET_ADDRESS_PT(36)
     OR GET_ADDRESS_PT(39) OR GET_ADDRESS_PT(43)
     OR GET_ADDRESS_PT(44) OR GET_ADDRESS_PT(46)
     OR GET_ADDRESS_PT(48) OR GET_ADDRESS_PT(50)
     OR GET_ADDRESS_PT(52) OR GET_ADDRESS_PT(53)
     OR GET_ADDRESS_PT(54) OR GET_ADDRESS_PT(58)
     OR GET_ADDRESS_PT(59) OR GET_ADDRESS_PT(60)
     OR GET_ADDRESS_PT(61) OR GET_ADDRESS_PT(62)
     OR GET_ADDRESS_PT(64) OR GET_ADDRESS_PT(66)
     OR GET_ADDRESS_PT(71) OR GET_ADDRESS_PT(72)
     OR GET_ADDRESS_PT(74) OR GET_ADDRESS_PT(76)
     OR GET_ADDRESS_PT(77) OR GET_ADDRESS_PT(78)
     OR GET_ADDRESS_PT(79) OR GET_ADDRESS_PT(80)
     OR GET_ADDRESS_PT(94) OR GET_ADDRESS_PT(95)
     OR GET_ADDRESS_PT(96));
MQQ104:START_ADDR(7) <= 
    (GET_ADDRESS_PT(2) OR GET_ADDRESS_PT(4)
     OR GET_ADDRESS_PT(7) OR GET_ADDRESS_PT(8)
     OR GET_ADDRESS_PT(9) OR GET_ADDRESS_PT(14)
     OR GET_ADDRESS_PT(15) OR GET_ADDRESS_PT(16)
     OR GET_ADDRESS_PT(17) OR GET_ADDRESS_PT(20)
     OR GET_ADDRESS_PT(22) OR GET_ADDRESS_PT(30)
     OR GET_ADDRESS_PT(32) OR GET_ADDRESS_PT(34)
     OR GET_ADDRESS_PT(35) OR GET_ADDRESS_PT(37)
     OR GET_ADDRESS_PT(38) OR GET_ADDRESS_PT(39)
     OR GET_ADDRESS_PT(40) OR GET_ADDRESS_PT(41)
     OR GET_ADDRESS_PT(42) OR GET_ADDRESS_PT(44)
     OR GET_ADDRESS_PT(45) OR GET_ADDRESS_PT(47)
     OR GET_ADDRESS_PT(51) OR GET_ADDRESS_PT(54)
     OR GET_ADDRESS_PT(55) OR GET_ADDRESS_PT(59)
     OR GET_ADDRESS_PT(68) OR GET_ADDRESS_PT(70)
     OR GET_ADDRESS_PT(73) OR GET_ADDRESS_PT(85)
     OR GET_ADDRESS_PT(86) OR GET_ADDRESS_PT(89)
    );
MQQ105:START_ADDR(8) <= 
    (GET_ADDRESS_PT(3) OR GET_ADDRESS_PT(15)
     OR GET_ADDRESS_PT(21) OR GET_ADDRESS_PT(30)
     OR GET_ADDRESS_PT(33) OR GET_ADDRESS_PT(36)
     OR GET_ADDRESS_PT(41) OR GET_ADDRESS_PT(45)
     OR GET_ADDRESS_PT(48) OR GET_ADDRESS_PT(49)
     OR GET_ADDRESS_PT(55) OR GET_ADDRESS_PT(56)
     OR GET_ADDRESS_PT(57) OR GET_ADDRESS_PT(59)
     OR GET_ADDRESS_PT(63) OR GET_ADDRESS_PT(79)
     OR GET_ADDRESS_PT(89) OR GET_ADDRESS_PT(91)
    );
MQQ106:START_ADDR(9) <= 
    (GET_ADDRESS_PT(3) OR GET_ADDRESS_PT(12)
     OR GET_ADDRESS_PT(21) OR GET_ADDRESS_PT(33)
     OR GET_ADDRESS_PT(35) OR GET_ADDRESS_PT(36)
     OR GET_ADDRESS_PT(37) OR GET_ADDRESS_PT(44)
     OR GET_ADDRESS_PT(48) OR GET_ADDRESS_PT(54)
     OR GET_ADDRESS_PT(56) OR GET_ADDRESS_PT(59)
     OR GET_ADDRESS_PT(80) OR GET_ADDRESS_PT(81)
    );
MQQ107:XER_TYPE <= 
    (GET_ADDRESS_PT(3) OR GET_ADDRESS_PT(42)
    );
MQQ108:LATE_END <= 
    (GET_ADDRESS_PT(4) OR GET_ADDRESS_PT(6)
     OR GET_ADDRESS_PT(7) OR GET_ADDRESS_PT(8)
     OR GET_ADDRESS_PT(10) OR GET_ADDRESS_PT(17)
     OR GET_ADDRESS_PT(18) OR GET_ADDRESS_PT(19)
     OR GET_ADDRESS_PT(21) OR GET_ADDRESS_PT(22)
     OR GET_ADDRESS_PT(23) OR GET_ADDRESS_PT(24)
     OR GET_ADDRESS_PT(25) OR GET_ADDRESS_PT(26)
     OR GET_ADDRESS_PT(27) OR GET_ADDRESS_PT(29)
     OR GET_ADDRESS_PT(31) OR GET_ADDRESS_PT(37)
     OR GET_ADDRESS_PT(38) OR GET_ADDRESS_PT(39)
     OR GET_ADDRESS_PT(41) OR GET_ADDRESS_PT(42)
     OR GET_ADDRESS_PT(43) OR GET_ADDRESS_PT(44)
     OR GET_ADDRESS_PT(46) OR GET_ADDRESS_PT(50)
     OR GET_ADDRESS_PT(52) OR GET_ADDRESS_PT(55)
     OR GET_ADDRESS_PT(56) OR GET_ADDRESS_PT(59)
     OR GET_ADDRESS_PT(60) OR GET_ADDRESS_PT(64)
     OR GET_ADDRESS_PT(67) OR GET_ADDRESS_PT(69)
     OR GET_ADDRESS_PT(72) OR GET_ADDRESS_PT(76)
     OR GET_ADDRESS_PT(77) OR GET_ADDRESS_PT(78)
     OR GET_ADDRESS_PT(82) OR GET_ADDRESS_PT(83)
     OR GET_ADDRESS_PT(84) OR GET_ADDRESS_PT(86)
     OR GET_ADDRESS_PT(88) OR GET_ADDRESS_PT(90)
     OR GET_ADDRESS_PT(94) OR GET_ADDRESS_PT(95)
     OR GET_ADDRESS_PT(96));
MQQ109:FORCE_EP <= 
    (GET_ADDRESS_PT(1) OR GET_ADDRESS_PT(11)
     OR GET_ADDRESS_PT(13));
MQQ110:UC_LEGAL <= 
    (GET_ADDRESS_PT(4) OR GET_ADDRESS_PT(6)
     OR GET_ADDRESS_PT(7) OR GET_ADDRESS_PT(8)
     OR GET_ADDRESS_PT(10) OR GET_ADDRESS_PT(16)
     OR GET_ADDRESS_PT(17) OR GET_ADDRESS_PT(18)
     OR GET_ADDRESS_PT(19) OR GET_ADDRESS_PT(20)
     OR GET_ADDRESS_PT(21) OR GET_ADDRESS_PT(22)
     OR GET_ADDRESS_PT(23) OR GET_ADDRESS_PT(24)
     OR GET_ADDRESS_PT(25) OR GET_ADDRESS_PT(26)
     OR GET_ADDRESS_PT(27) OR GET_ADDRESS_PT(30)
     OR GET_ADDRESS_PT(31) OR GET_ADDRESS_PT(32)
     OR GET_ADDRESS_PT(33) OR GET_ADDRESS_PT(35)
     OR GET_ADDRESS_PT(36) OR GET_ADDRESS_PT(37)
     OR GET_ADDRESS_PT(38) OR GET_ADDRESS_PT(39)
     OR GET_ADDRESS_PT(40) OR GET_ADDRESS_PT(41)
     OR GET_ADDRESS_PT(42) OR GET_ADDRESS_PT(43)
     OR GET_ADDRESS_PT(44) OR GET_ADDRESS_PT(45)
     OR GET_ADDRESS_PT(46) OR GET_ADDRESS_PT(47)
     OR GET_ADDRESS_PT(48) OR GET_ADDRESS_PT(49)
     OR GET_ADDRESS_PT(50) OR GET_ADDRESS_PT(52)
     OR GET_ADDRESS_PT(53) OR GET_ADDRESS_PT(54)
     OR GET_ADDRESS_PT(55) OR GET_ADDRESS_PT(56)
     OR GET_ADDRESS_PT(57) OR GET_ADDRESS_PT(58)
     OR GET_ADDRESS_PT(59) OR GET_ADDRESS_PT(60)
     OR GET_ADDRESS_PT(62) OR GET_ADDRESS_PT(64)
     OR GET_ADDRESS_PT(66) OR GET_ADDRESS_PT(69)
     OR GET_ADDRESS_PT(71) OR GET_ADDRESS_PT(72)
     OR GET_ADDRESS_PT(74) OR GET_ADDRESS_PT(76)
     OR GET_ADDRESS_PT(77) OR GET_ADDRESS_PT(78)
     OR GET_ADDRESS_PT(79) OR GET_ADDRESS_PT(81)
     OR GET_ADDRESS_PT(84) OR GET_ADDRESS_PT(88)
     OR GET_ADDRESS_PT(90) OR GET_ADDRESS_PT(91)
     OR GET_ADDRESS_PT(92) OR GET_ADDRESS_PT(93)
     OR GET_ADDRESS_PT(94) OR GET_ADDRESS_PT(95)
     OR GET_ADDRESS_PT(96));

iu_pc_err_ucode_illegal_d         <=  gate_and(fiss_uc_is2_ucode_vld_l2 and not uc_legal, fiss_uc_is2_tid_l2);
err_ucode_illegal: tri_direct_err_rpt
  generic map (width => 4, expand_type => expand_type)
  port map (
            vd          => vdd,
            gd          => gnd,
            err_in      => iu_pc_err_ucode_illegal_L2,
            err_out     => iu_pc_err_ucode_illegal);
xu_iu_flush_d            <=  xu_iu_flush;
xu_iu_ucode_restart_d    <=  xu_iu_ucode_restart;
xu_iu_uc_flush_ifar0_d   <=  xu_iu_uc_flush_ifar0;
xu_iu_uc_flush_ifar1_d   <=  xu_iu_uc_flush_ifar1;
xu_iu_uc_flush_ifar2_d   <=  xu_iu_uc_flush_ifar2;
xu_iu_uc_flush_ifar3_d   <=  xu_iu_uc_flush_ifar3;
uc_control0   : entity work.iuq_uc_control
  generic map( ucode_width => ucode_width,
               expand_type => expand_type)
port map(
   vdd                  => vdd,
   gnd                  => gnd,
   nclk                 => nclk,
   pc_iu_func_sl_thold_0_b => pc_iu_func_sl_thold_0_b,
   pc_iu_sg_0           => pc_iu_sg_0,
   forcee => forcee,
   d_mode               => d_mode,
   delay_lclkr          => delay_lclkr,
   mpw1_b               => mpw1_b,
   mpw2_b               => mpw2_b,
   scan_in              => siv(scan_right + 1),
   scan_out             => sov(scan_right + 1),
   spr_ic_clockgate_dis => spr_ic_clockgate_dis,
   xu_iu_spr_xer        => xu_iu_spr_xer0,
   flush                => xu_iu_flush_l2(0),
   restart              => xu_iu_ucode_restart_l2(0),
   flush_ifar           => xu_iu_uc_flush_ifar0_l2,
   ib_flush             => ib_flush(0),
   ib_flush_ifar        => iu5_ifar_l2,
   buff_avail           => ib_uc_buff0_avail,
   load_command         => load_command(0),
   new_instr            => fiss_uc_is2_instr_l2,
   start_addr           => start_addr,
   xer_type             => xer_type,
   early_end            => early_end,
   force_ep             => force_ep,
   new_cond             => new_cond,
   uc_act_thread        => uc_act(0),
   vld_fast             => vld_fast(0),
   ra_valid             => vld_mask(0),
   rom_ra               => rom_ra0,
   data_valid           => data_valid(0),
   rom_data             => rom_data(32 to ucode_width-1),
   rom_data_late        => rom_data_late_l2(0 to 31),
   ucode_valid          => ucode_valid(0),
   ucode_ifar           => ucode_ifar0,
   ucode_instruction    => ucode_instr0,
   is_ucode             => ucode_is_ucode0,
   extRT                => ucode_ext0(0),
   extS1                => ucode_ext0(1),
   extS2                => ucode_ext0(2),
   extS3                => ucode_ext0(3),
   hold_thread          => uc_ic_hold_thread(0),
   uc_control_dbg_data  => uc_control_dbg_data0
);
uc_control1   : entity work.iuq_uc_control
  generic map( ucode_width => ucode_width,
               expand_type => expand_type)
port map(
   vdd                  => vdd,
   gnd                  => gnd,
   nclk                 => nclk,
   pc_iu_func_sl_thold_0_b => pc_iu_func_sl_thold_0_b,
   pc_iu_sg_0           => pc_iu_sg_0,
   forcee => forcee,
   d_mode               => d_mode,
   delay_lclkr          => delay_lclkr,
   mpw1_b               => mpw1_b,
   mpw2_b               => mpw2_b,
   scan_in              => siv(scan_right + 2),
   scan_out             => sov(scan_right + 2),
   spr_ic_clockgate_dis => spr_ic_clockgate_dis,
   xu_iu_spr_xer        => xu_iu_spr_xer1,
   flush                => xu_iu_flush_l2(1),
   restart              => xu_iu_ucode_restart_l2(1),
   flush_ifar           => xu_iu_uc_flush_ifar1_l2,
   ib_flush             => ib_flush(1),
   ib_flush_ifar        => iu5_ifar_l2,
   buff_avail           => ib_uc_buff1_avail,
   load_command         => load_command(1),
   new_instr            => fiss_uc_is2_instr_l2,
   start_addr           => start_addr,
   xer_type             => xer_type,
   early_end            => early_end,
   force_ep             => force_ep,
   new_cond             => new_cond,
   uc_act_thread        => uc_act(1),
   vld_fast             => vld_fast(1),
   ra_valid             => vld_mask(1),
   rom_ra               => rom_ra1,
   data_valid           => data_valid(1),
   rom_data             => rom_data(32 to ucode_width-1),
   rom_data_late        => rom_data_late_l2(0 to 31),
   ucode_valid          => ucode_valid(1),
   ucode_ifar           => ucode_ifar1,
   ucode_instruction    => ucode_instr1,
   is_ucode             => ucode_is_ucode1,
   extRT                => ucode_ext1(0),
   extS1                => ucode_ext1(1),
   extS2                => ucode_ext1(2),
   extS3                => ucode_ext1(3),
   hold_thread          => uc_ic_hold_thread(1),
   uc_control_dbg_data  => uc_control_dbg_data1
);
uc_control2   : entity work.iuq_uc_control
  generic map( ucode_width => ucode_width,
               expand_type => expand_type)
port map(
   vdd                  => vdd,
   gnd                  => gnd,
   nclk                 => nclk,
   pc_iu_func_sl_thold_0_b => pc_iu_func_sl_thold_0_b,
   pc_iu_sg_0           => pc_iu_sg_0,
   forcee => forcee,
   d_mode               => d_mode,
   delay_lclkr          => delay_lclkr,
   mpw1_b               => mpw1_b,
   mpw2_b               => mpw2_b,
   scan_in              => siv(scan_right + 3),
   scan_out             => sov(scan_right + 3),
   spr_ic_clockgate_dis => spr_ic_clockgate_dis,
   xu_iu_spr_xer        => xu_iu_spr_xer2,
   flush                => xu_iu_flush_l2(2),
   restart              => xu_iu_ucode_restart_l2(2),
   flush_ifar           => xu_iu_uc_flush_ifar2_l2,
   ib_flush             => ib_flush(2),
   ib_flush_ifar        => iu5_ifar_l2,
   buff_avail           => ib_uc_buff2_avail,
   load_command         => load_command(2),
   new_instr            => fiss_uc_is2_instr_l2,
   start_addr           => start_addr,
   xer_type             => xer_type,
   early_end            => early_end,
   force_ep             => force_ep,
   new_cond             => new_cond,
   uc_act_thread        => uc_act(2),
   vld_fast             => vld_fast(2),
   ra_valid             => vld_mask(2),
   rom_ra               => rom_ra2,
   data_valid           => data_valid(2),
   rom_data             => rom_data(32 to ucode_width-1),
   rom_data_late        => rom_data_late_l2(0 to 31),
   ucode_valid          => ucode_valid(2),
   ucode_ifar           => ucode_ifar2,
   ucode_instruction    => ucode_instr2,
   is_ucode             => ucode_is_ucode2,
   extRT                => ucode_ext2(0),
   extS1                => ucode_ext2(1),
   extS2                => ucode_ext2(2),
   extS3                => ucode_ext2(3),
   hold_thread          => uc_ic_hold_thread(2),
   uc_control_dbg_data  => uc_control_dbg_data2
);
uc_control3   : entity work.iuq_uc_control
  generic map( ucode_width => ucode_width,
               expand_type => expand_type)
port map(
   vdd                  => vdd,
   gnd                  => gnd,
   nclk                 => nclk,
   pc_iu_func_sl_thold_0_b => pc_iu_func_sl_thold_0_b,
   pc_iu_sg_0           => pc_iu_sg_0,
   forcee => forcee,
   d_mode               => d_mode,
   delay_lclkr          => delay_lclkr,
   mpw1_b               => mpw1_b,
   mpw2_b               => mpw2_b,
   scan_in              => siv(scan_right + 4),
   scan_out             => sov(scan_right + 4),
   spr_ic_clockgate_dis => spr_ic_clockgate_dis,
   xu_iu_spr_xer        => xu_iu_spr_xer3,
   flush                => xu_iu_flush_l2(3),
   restart              => xu_iu_ucode_restart_l2(3),
   flush_ifar           => xu_iu_uc_flush_ifar3_l2,
   ib_flush             => ib_flush(3),
   ib_flush_ifar        => iu5_ifar_l2,
   buff_avail           => ib_uc_buff3_avail,
   load_command         => load_command(3),
   new_instr            => fiss_uc_is2_instr_l2,
   start_addr           => start_addr,
   xer_type             => xer_type,
   early_end            => early_end,
   force_ep             => force_ep,
   new_cond             => new_cond,
   uc_act_thread        => uc_act(3),
   vld_fast             => vld_fast(3),
   ra_valid             => vld_mask(3),
   rom_ra               => rom_ra3,
   data_valid           => data_valid(3),
   rom_data             => rom_data(32 to ucode_width-1),
   rom_data_late        => rom_data_late_l2(0 to 31),
   ucode_valid          => ucode_valid(3),
   ucode_ifar           => ucode_ifar3,
   ucode_instruction    => ucode_instr3,
   is_ucode             => ucode_is_ucode3,
   extRT                => ucode_ext3(0),
   extS1                => ucode_ext3(1),
   extS2                => ucode_ext3(2),
   extS3                => ucode_ext3(3),
   hold_thread          => uc_ic_hold_thread(3),
   uc_control_dbg_data  => uc_control_dbg_data3
);
MQQ111:ROM_ISSUE_TABLE_PT(1) <=
    Eq(( ROMTOKEN_L2(3) & VLD_FAST(0) & 
    VLD_FAST(1) ) , STD_ULOGIC_VECTOR'("101"));
MQQ112:ROM_ISSUE_TABLE_PT(2) <=
    Eq(( ROMTOKEN_L2(2) & VLD_FAST(0) & 
    VLD_FAST(3) ) , STD_ULOGIC_VECTOR'("110"));
MQQ113:ROM_ISSUE_TABLE_PT(3) <=
    Eq(( ROMTOKEN_L2(2) & ROMTOKEN_L2(3) & 
    VLD_FAST(1) & VLD_FAST(2)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ114:ROM_ISSUE_TABLE_PT(4) <=
    Eq(( ROMTOKEN_L2(1) & VLD_FAST(0) & 
    VLD_FAST(2) & VLD_FAST(3)
     ) , STD_ULOGIC_VECTOR'("1000"));
MQQ115:ROM_ISSUE_TABLE_PT(5) <=
    Eq(( ROMTOKEN_L2(0) & VLD_FAST(1) & 
    VLD_FAST(2) & VLD_FAST(3)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ116:ROM_ISSUE_TABLE_PT(6) <=
    Eq(( ROMTOKEN_L2(2) & VLD_FAST(0) & 
    VLD_FAST(1) & VLD_FAST(3)
     ) , STD_ULOGIC_VECTOR'("1000"));
MQQ117:ROM_ISSUE_TABLE_PT(7) <=
    Eq(( ROMTOKEN_L2(3) & VLD_FAST(0) & 
    VLD_FAST(1) & VLD_FAST(2)
     ) , STD_ULOGIC_VECTOR'("1000"));
MQQ118:ROM_ISSUE_TABLE_PT(8) <=
    Eq(( ROMTOKEN_L2(0) & VLD_FAST(1) & 
    VLD_FAST(2) & VLD_FAST(3)
     ) , STD_ULOGIC_VECTOR'("1000"));
MQQ119:ROM_ISSUE_TABLE_PT(9) <=
    Eq(( ROMTOKEN_L2(1) & VLD_FAST(2) & 
    VLD_FAST(3) ) , STD_ULOGIC_VECTOR'("101"));
MQQ120:ROM_ISSUE_TABLE_PT(10) <=
    Eq(( ROMTOKEN_L2(0) & VLD_FAST(0) & 
    VLD_FAST(2) & VLD_FAST(3)
     ) , STD_ULOGIC_VECTOR'("0100"));
MQQ121:ROM_ISSUE_TABLE_PT(11) <=
    Eq(( ROMTOKEN_L2(1) & VLD_FAST(0) & 
    VLD_FAST(1) & VLD_FAST(3)
     ) , STD_ULOGIC_VECTOR'("0010"));
MQQ122:ROM_ISSUE_TABLE_PT(12) <=
    Eq(( ROMTOKEN_L2(2) & VLD_FAST(0) & 
    VLD_FAST(1) & VLD_FAST(2)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ123:ROM_ISSUE_TABLE_PT(13) <=
    Eq(( ROMTOKEN_L2(1) & VLD_FAST(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ124:ROM_ISSUE_TABLE_PT(14) <=
    Eq(( ROMTOKEN_L2(3) & VLD_FAST(0)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ125:ROM_ISSUE_TABLE_PT(15) <=
    Eq(( ROMTOKEN_L2(0) & VLD_FAST(1)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ126:ROM_ISSUE_TABLE_PT(16) <=
    Eq(( ROMTOKEN_L2(2) & VLD_FAST(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ127:ROMTOKEN_D(0) <= 
    (ROM_ISSUE_TABLE_PT(2) OR ROM_ISSUE_TABLE_PT(8)
     OR ROM_ISSUE_TABLE_PT(10) OR ROM_ISSUE_TABLE_PT(14)
    );
MQQ128:ROMTOKEN_D(1) <= 
    (ROM_ISSUE_TABLE_PT(1) OR ROM_ISSUE_TABLE_PT(4)
     OR ROM_ISSUE_TABLE_PT(11) OR ROM_ISSUE_TABLE_PT(15)
    );
MQQ129:ROMTOKEN_D(2) <= 
    (ROM_ISSUE_TABLE_PT(3) OR ROM_ISSUE_TABLE_PT(6)
     OR ROM_ISSUE_TABLE_PT(12) OR ROM_ISSUE_TABLE_PT(13)
    );
MQQ130:ROMTOKEN_D(3) <= 
    (ROM_ISSUE_TABLE_PT(5) OR ROM_ISSUE_TABLE_PT(7)
     OR ROM_ISSUE_TABLE_PT(9) OR ROM_ISSUE_TABLE_PT(16)
    );

romvalid_d  <=  vld_mask;
rom_addr  <=  gate_and(romtoken_d(0), rom_ra0) or
            gate_and(romtoken_d(1), rom_ra1) or
            gate_and(romtoken_d(2), rom_ra2) or
            gate_and(romtoken_d(3), rom_ra3) ;
uc_any_act  <=  or_reduce(uc_act);
rom_act  <=  uc_any_act;
rom_data_tid  <=  romtoken_L2;
data_valid  <=  romvalid_l2 and rom_data_tid;
uc_rom: entity work.iuq_uc_rom
  generic map( ucode_width => ucode_width,
               regmode     => regmode,
               expand_type => expand_type)
port map(
   vdd                  => vdd,
   gnd                  => gnd,
   nclk                 => nclk,
   pc_iu_func_sl_thold_0_b => pc_iu_func_sl_thold_0_b,
   pc_iu_sg_0           => pc_iu_sg_0,
   forcee => forcee,
   d_mode               => d_mode,
   delay_lclkr          => delay_lclkr,
   mpw1_b               => mpw1_b,
   mpw2_b               => mpw2_b,
   scan_in              => siv(scan_right + 5),
   scan_out             => sov(scan_right + 5),
   rom_act              => rom_act,
   rom_addr             => rom_addr,
   rom_data             => rom_data
);
rom_data_late_d          <=  rom_data(0 to 31);
iu4_stage_act  <=  or_reduce(data_valid);
iu4_valid_tid_d  <=  ucode_valid and not xu_iu_flush_d;
iu4_is_ucode_d   <=  gate_and(rom_data_tid(0), ucode_is_ucode0) or
                   gate_and(rom_data_tid(1), ucode_is_ucode1) or 
                   gate_and(rom_data_tid(2), ucode_is_ucode2) or 
                   gate_and(rom_data_tid(3), ucode_is_ucode3) ;
iu4_ifar_d       <=  gate_and(rom_data_tid(0), ucode_ifar0) or 
                   gate_and(rom_data_tid(1), ucode_ifar1) or 
                   gate_and(rom_data_tid(2), ucode_ifar2) or 
                   gate_and(rom_data_tid(3), ucode_ifar3) ;
iu4_ext_d        <=  gate_and(rom_data_tid(0), ucode_ext0) or 
                   gate_and(rom_data_tid(1), ucode_ext1) or 
                   gate_and(rom_data_tid(2), ucode_ext2) or 
                   gate_and(rom_data_tid(3), ucode_ext3) ;
iu4_data_tid_d   <=  rom_data_tid;
iu4_instr_l2     <=  gate_and(iu4_data_tid_l2(0), ucode_instr0) or 
                   gate_and(iu4_data_tid_l2(1), ucode_instr1) or 
                   gate_and(iu4_data_tid_l2(2), ucode_instr2) or 
                   gate_and(iu4_data_tid_l2(3), ucode_instr3) ;
uc_ib_iu4_valid_tid  <=  iu4_valid_tid_l2;
uc_ib_iu4_ifar  <=  iu4_ifar_l2;
uc_ib_iu4_instr  <=  iu4_instr_l2;
uc_ib_iu4_is_ucode  <=  iu4_is_ucode_l2;
uc_ib_iu4_ext  <=  iu4_ext_l2;
ib_flush  <=  "0000";
iu5_ifar_l2  <=  (others => '0');
sov(iu5_valid_tid_offset TO iu5_valid_tid_offset+4-1) <= 
      siv(iu5_valid_tid_offset to iu5_valid_tid_offset + 4 - 1);
sov(iu5_ifar_offset TO iu5_ifar_offset+iu5_ifar_l2'length-1) <= 
      siv(iu5_ifar_offset to iu5_ifar_offset + iu5_ifar_l2'length-1);
ib_uc_buff_avail_d  <=  ib_uc_buff0_avail & ib_uc_buff1_avail & ib_uc_buff2_avail & ib_uc_buff3_avail;
uc_dbg_data(0 TO 3) <=  uc_control_dbg_data0;
uc_dbg_data(4 TO 7) <=  uc_control_dbg_data1;
uc_dbg_data(8 TO 11) <=  uc_control_dbg_data2;
uc_dbg_data(12 TO 15) <=  uc_control_dbg_data3;
uc_dbg_data(16 TO 19) <=  xu_iu_flush_l2;
uc_dbg_data(20 TO 23) <=  ib_uc_buff_avail_l2;
uc_dbg_data(24) <=  fiss_uc_is2_ucode_vld_l2;
uc_dbg_data(25) <=  fiss_uc_is2_2ucode_l2;
uc_dbg_data(26) <=  fiss_uc_is2_2ucode_type_l2;
uc_dbg_data(27 TO 43) <=  fiss_uc_is2_instr_l2(0 to 5) & fiss_uc_is2_instr_l2(21 to 31);
uc_dbg_data_d(44 TO 59) <=  iu4_instr_l2(0 to 15);
uc_dbg_data(44 TO 59) <=  uc_dbg_data_l2(44 to 59);
uc_dbg_data(60 TO 63) <=  iu4_ext_l2;
uc_dbg_data(64 TO 65) <=  iu4_ifar_l2(41 to 42);
uc_dbg_data(66 TO 73) <=  iu4_ifar_l2(54 to 61);
uc_dbg_data(74) <=  iu4_ifar_l2(48);
uc_dbg_data(75 TO 79) <=  iu4_ifar_l2(43 to 47);
uc_dbg_data(80 TO 83) <=  iu4_valid_tid_l2;
uc_dbg_data(84 TO 87) <=  romtoken_l2;
iu_pc_err_ucode_illegal_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu_pc_err_ucode_illegal_offset + 0),
            scout   => sov(iu_pc_err_ucode_illegal_offset + 0),
            din     => iu_pc_err_ucode_illegal_d(0),
            dout    => iu_pc_err_ucode_illegal_l2(0));
iu_pc_err_ucode_illegal_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu_pc_err_ucode_illegal_offset + 1),
            scout   => sov(iu_pc_err_ucode_illegal_offset + 1),
            din     => iu_pc_err_ucode_illegal_d(1),
            dout    => iu_pc_err_ucode_illegal_l2(1));
iu_pc_err_ucode_illegal_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu_pc_err_ucode_illegal_offset + 2),
            scout   => sov(iu_pc_err_ucode_illegal_offset + 2),
            din     => iu_pc_err_ucode_illegal_d(2),
            dout    => iu_pc_err_ucode_illegal_l2(2));
iu_pc_err_ucode_illegal_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu_pc_err_ucode_illegal_offset + 3),
            scout   => sov(iu_pc_err_ucode_illegal_offset + 3),
            din     => iu_pc_err_ucode_illegal_d(3),
            dout    => iu_pc_err_ucode_illegal_l2(3));
ib_uc_buff_avail_latch: tri_rlmreg_p
  generic map (width => ib_uc_buff_avail_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(ib_uc_buff_avail_offset to ib_uc_buff_avail_offset + ib_uc_buff_avail_l2'length-1),
            scout   => sov(ib_uc_buff_avail_offset to ib_uc_buff_avail_offset + ib_uc_buff_avail_l2'length-1),
            din     => ib_uc_buff_avail_d,
            dout    => ib_uc_buff_avail_l2);
xu_iu_flush_latch: tri_rlmreg_p
  generic map (width => xu_iu_flush_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(xu_iu_flush_offset to xu_iu_flush_offset + xu_iu_flush_l2'length-1),
            scout   => sov(xu_iu_flush_offset to xu_iu_flush_offset + xu_iu_flush_l2'length-1),
            din     => xu_iu_flush_d,
            dout    => xu_iu_flush_l2);
xu_iu_ucode_restart_latch: tri_rlmreg_p
  generic map (width => xu_iu_ucode_restart_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(xu_iu_ucode_restart_offset to xu_iu_ucode_restart_offset + xu_iu_ucode_restart_l2'length-1),
            scout   => sov(xu_iu_ucode_restart_offset to xu_iu_ucode_restart_offset + xu_iu_ucode_restart_l2'length-1),
            din     => xu_iu_ucode_restart_d,
            dout    => xu_iu_ucode_restart_l2);
xu_iu_uc_flush_ifar0_latch: tri_rlmreg_p
  generic map (width => xu_iu_uc_flush_ifar0_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_uc_flush_ifar0_offset to xu_iu_uc_flush_ifar0_offset + xu_iu_uc_flush_ifar0_l2'length-1),
            scout   => sov(xu_iu_uc_flush_ifar0_offset to xu_iu_uc_flush_ifar0_offset + xu_iu_uc_flush_ifar0_l2'length-1),
            din     => xu_iu_uc_flush_ifar0_d,
            dout    => xu_iu_uc_flush_ifar0_l2);
xu_iu_uc_flush_ifar1_latch: tri_rlmreg_p
  generic map (width => xu_iu_uc_flush_ifar1_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_uc_flush_ifar1_offset to xu_iu_uc_flush_ifar1_offset + xu_iu_uc_flush_ifar1_l2'length-1),
            scout   => sov(xu_iu_uc_flush_ifar1_offset to xu_iu_uc_flush_ifar1_offset + xu_iu_uc_flush_ifar1_l2'length-1),
            din     => xu_iu_uc_flush_ifar1_d,
            dout    => xu_iu_uc_flush_ifar1_l2);
xu_iu_uc_flush_ifar2_latch: tri_rlmreg_p
  generic map (width => xu_iu_uc_flush_ifar2_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_uc_flush_ifar2_offset to xu_iu_uc_flush_ifar2_offset + xu_iu_uc_flush_ifar2_l2'length-1),
            scout   => sov(xu_iu_uc_flush_ifar2_offset to xu_iu_uc_flush_ifar2_offset + xu_iu_uc_flush_ifar2_l2'length-1),
            din     => xu_iu_uc_flush_ifar2_d,
            dout    => xu_iu_uc_flush_ifar2_l2);
xu_iu_uc_flush_ifar3_latch: tri_rlmreg_p
  generic map (width => xu_iu_uc_flush_ifar3_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_uc_flush_ifar3_offset to xu_iu_uc_flush_ifar3_offset + xu_iu_uc_flush_ifar3_l2'length-1),
            scout   => sov(xu_iu_uc_flush_ifar3_offset to xu_iu_uc_flush_ifar3_offset + xu_iu_uc_flush_ifar3_l2'length-1),
            din     => xu_iu_uc_flush_ifar3_d,
            dout    => xu_iu_uc_flush_ifar3_l2);
fiss_uc_is2_ucode_vld_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(fiss_uc_is2_ucode_vld_offset),
            scout   => sov(fiss_uc_is2_ucode_vld_offset),
            din     => fiss_uc_is2_ucode_vld_d,
            dout    => fiss_uc_is2_ucode_vld_l2);
fiss_uc_is2_tid_latch: tri_rlmreg_p
  generic map (width => fiss_uc_is2_tid_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(fiss_uc_is2_tid_offset to fiss_uc_is2_tid_offset + fiss_uc_is2_tid_l2'length-1),
            scout   => sov(fiss_uc_is2_tid_offset to fiss_uc_is2_tid_offset + fiss_uc_is2_tid_l2'length-1),
            din     => fiss_uc_is2_tid_d,
            dout    => fiss_uc_is2_tid_l2);
fiss_uc_is2_instr_latch: tri_rlmreg_p
  generic map (width => fiss_uc_is2_instr_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(fiss_uc_is2_instr_offset to fiss_uc_is2_instr_offset + fiss_uc_is2_instr_l2'length-1),
            scout   => sov(fiss_uc_is2_instr_offset to fiss_uc_is2_instr_offset + fiss_uc_is2_instr_l2'length-1),
            din     => fiss_uc_is2_instr_d,
            dout    => fiss_uc_is2_instr_l2);
fiss_uc_is2_2ucode_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(fiss_uc_is2_2ucode_offset),
            scout   => sov(fiss_uc_is2_2ucode_offset),
            din     => fiss_uc_is2_2ucode_d,
            dout    => fiss_uc_is2_2ucode_l2);
fiss_uc_is2_2ucode_type_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(fiss_uc_is2_2ucode_type_offset),
            scout   => sov(fiss_uc_is2_2ucode_type_offset),
            din     => fiss_uc_is2_2ucode_type_d,
            dout    => fiss_uc_is2_2ucode_type_l2);
romtoken_latch: tri_rlmreg_p
  generic map (width => romtoken_l2'length, init => 8, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_any_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(romtoken_offset to romtoken_offset + romtoken_l2'length-1),
            scout   => sov(romtoken_offset to romtoken_offset + romtoken_l2'length-1),
            din     => romtoken_d,
            dout    => romtoken_l2);
romvalid_latch: tri_rlmreg_p
  generic map (width => romvalid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_any_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(romvalid_offset to romvalid_offset + romvalid_l2'length-1),
            scout   => sov(romvalid_offset to romvalid_offset + romvalid_l2'length-1),
            din     => romvalid_d,
            dout    => romvalid_l2);
rom_data_late_latch: tri_rlmreg_p
  generic map (width => rom_data_late_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu4_stage_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(rom_data_late_offset to rom_data_late_offset + rom_data_late_l2'length-1),
            scout   => sov(rom_data_late_offset to rom_data_late_offset + rom_data_late_l2'length-1),
            din     => rom_data_late_d,
            dout    => rom_data_late_l2);
iu4_valid_tid_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_valid_tid_offset+0),
            scout   => sov(iu4_valid_tid_offset+0),
            din     => iu4_valid_tid_d(0),
            dout    => iu4_valid_tid_l2(0));
iu4_valid_tid_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_valid_tid_offset+1),
            scout   => sov(iu4_valid_tid_offset+1),
            din     => iu4_valid_tid_d(1),
            dout    => iu4_valid_tid_l2(1));
iu4_valid_tid_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_valid_tid_offset+2),
            scout   => sov(iu4_valid_tid_offset+2),
            din     => iu4_valid_tid_d(2),
            dout    => iu4_valid_tid_l2(2));
iu4_valid_tid_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => uc_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_valid_tid_offset+3),
            scout   => sov(iu4_valid_tid_offset+3),
            din     => iu4_valid_tid_d(3),
            dout    => iu4_valid_tid_l2(3));
iu4_data_tid_latch: tri_rlmreg_p
  generic map (width => iu4_data_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu4_stage_act,   
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_data_tid_offset to iu4_data_tid_offset + iu4_data_tid_l2'length-1),
            scout   => sov(iu4_data_tid_offset to iu4_data_tid_offset + iu4_data_tid_l2'length-1),
            din     => iu4_data_tid_d,
            dout    => iu4_data_tid_l2);
iu4_ifar_latch: tri_rlmreg_p
  generic map (width => iu4_ifar_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu4_stage_act,       
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_ifar_offset to iu4_ifar_offset + iu4_ifar_l2'length-1),
            scout   => sov(iu4_ifar_offset to iu4_ifar_offset + iu4_ifar_l2'length-1),
            din     => iu4_ifar_d,
            dout    => iu4_ifar_l2);
iu4_is_ucode_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu4_stage_act,       
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_is_ucode_offset),
            scout   => sov(iu4_is_ucode_offset),
            din     => iu4_is_ucode_d,
            dout    => iu4_is_ucode_l2);
iu4_ext_latch: tri_rlmreg_p
  generic map (width => iu4_ext_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu4_stage_act,       
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu4_ext_offset to iu4_ext_offset + iu4_ext_l2'length-1),
            scout   => sov(iu4_ext_offset to iu4_ext_offset + iu4_ext_l2'length-1),
            din     => iu4_ext_d,
            dout    => iu4_ext_l2);
trace_bus_enable_d  <=  pc_iu_trace_bus_enable;
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
uc_dbg_data_latch: tri_rlmreg_p
  generic map (width => uc_dbg_data_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,       
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(uc_dbg_data_offset to uc_dbg_data_offset + uc_dbg_data_l2'length-1),
            scout   => sov(uc_dbg_data_offset to uc_dbg_data_offset + uc_dbg_data_l2'length-1),
            din     => uc_dbg_data_d,
            dout    => uc_dbg_data_l2);
spare_latch: tri_rlmreg_p
  generic map (width => spare_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
siv(0 TO scan_right+5) <=  sov(1 to scan_right+5) & scan_in;
scan_out  <=  sov(0) and an_ac_scan_dis_dc_b;
END IUQ_UC;

