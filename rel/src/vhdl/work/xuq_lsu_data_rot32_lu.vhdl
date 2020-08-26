-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU LSU Store Data Rotator
--

library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;

-- ##########################################################################################
-- VHDL Contents
-- 1) 1 32Byte input
-- 2) 32 Byte Unaligned Rotate to the Left Rotator
-- ##########################################################################################

entity xuq_lsu_data_rot32_lu is
generic(l_endian_m      : integer := 1);        -- 1 = little endian mode enabled, 0 = little endian mode disabled
port(

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     
     -- Rotator Controls and Data
     rot_sel1                   :in  std_ulogic_vector(0 to 31);
     rot_sel2                   :in  std_ulogic_vector(0 to 31);
     rot_sel3                   :in  std_ulogic_vector(0 to 31);
     rot_sel2_le                :in  std_ulogic_vector(0 to 31);
     rot_sel3_le                :in  std_ulogic_vector(0 to 31);
     rot_data                   :in  std_ulogic_vector(0 to 127);

     -- Rotated Data
     data256_rot_le             :out std_ulogic_vector(0 to 127);
     data256_rot                :out std_ulogic_vector(0 to 127)
);
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_data_rot32_lu;
architecture xuq_lsu_data_rot32_lu of xuq_lsu_data_rot32_lu is

----------------------------
-- signals
----------------------------

signal rot3210                  :std_ulogic_vector(0 to 127);
signal rotC840                  :std_ulogic_vector(0 to 127);
signal rot10                    :std_ulogic_vector(0 to 127);
signal le_rot_data              :std_ulogic_vector(0 to 127);
signal le_rotC840               :std_ulogic_vector(0 to 127);
signal le_rot3210               :std_ulogic_vector(0 to 127);

begin

-- #############################################################################################
-- 32 Byte Rotator
-- B0 => data(0:7)      B8  => data(64:71)      B16 => data(128:135)    B24 => data(192:199)
-- B1 => data(8:15)     B9  => data(72:79)      B17 => data(136:143)    B25 => data(200:207)
-- B2 => data(16:23)    B10 => data(80:87)      B18 => data(144:151)    B26 => data(208:215)
-- B3 => data(24:31)    B11 => data(88:95)      B19 => data(152:159)    B27 => data(216:223)
-- B4 => data(32:39)    B12 => data(96:103)     B20 => data(160:167)    B28 => data(224:231)
-- B5 => data(40:47)    B13 => data(104:111)    B21 => data(168:175)    B29 => data(232:239)
-- B6 => data(48:55)    B14 => data(112:119)    B22 => data(176:183)    B30 => data(240:247)
-- B7 => data(56:63)    B15 => data(120:127)    B23 => data(184:191)    B31 => data(248:255)
-- #############################################################################################

---- 0,1,2,3 byte rotation
--rot_data1_0 <= rot_data(0 to 255);
--rot_data1_1 <= rot_data(8 to 255)  & rot_data(0 to 7);
--rot_data1_2 <= rot_data(16 to 255) & rot_data(0 to 15);
--rot_data1_3 <= rot_data(24 to 255) & rot_data(0 to 23);
--
--rot3210(0 to 63)    <= gate(rot_data1_0(0 to 63), rot_sel1(0)) or gate(rot_data1_1(0 to 63), rot_sel1(1)) or
--                       gate(rot_data1_2(0 to 63), rot_sel1(2)) or gate(rot_data1_3(0 to 63), rot_sel1(3));
--
--rot3210(64 to 127)  <= gate(rot_data1_0(64 to 127), rot_sel1(4)) or gate(rot_data1_1(64 to 127), rot_sel1(5)) or
--                       gate(rot_data1_2(64 to 127), rot_sel1(6)) or gate(rot_data1_3(64 to 127), rot_sel1(7));
--
--rot3210(128 to 191) <= gate(rot_data1_0(128 to 191), rot_sel1(8))  or gate(rot_data1_1(128 to 191), rot_sel1(9)) or
--                       gate(rot_data1_2(128 to 191), rot_sel1(10)) or gate(rot_data1_3(128 to 191), rot_sel1(11));
--
--rot3210(192 to 255) <= gate(rot_data1_0(192 to 255), rot_sel1(12)) or gate(rot_data1_1(192 to 255), rot_sel1(13)) or
--                       gate(rot_data1_2(192 to 255), rot_sel1(14)) or gate(rot_data1_3(192 to 255), rot_sel1(15));
--
---- 0-3,4,8,12 byte rotation
--rot_data2_0 <= rot3210(0 to 255);
--rot_data2_1 <= rot3210(32 to 255) & rot3210(0 to 31);
--rot_data2_2 <= rot3210(64 to 255) & rot3210(0 to 63);
--rot_data2_3 <= rot3210(96 to 255) & rot3210(0 to 95);
--
--rotC840(0 to 63)    <= gate(rot_data2_0(0 to 63), rot_sel2(0)) or gate(rot_data2_1(0 to 63), rot_sel2(1)) or
--                       gate(rot_data2_2(0 to 63), rot_sel2(2)) or gate(rot_data2_3(0 to 63), rot_sel2(3));
--
--rotC840(64 to 127)  <= gate(rot_data2_0(64 to 127), rot_sel2(4)) or gate(rot_data2_1(64 to 127), rot_sel2(5)) or
--                       gate(rot_data2_2(64 to 127), rot_sel2(6)) or gate(rot_data2_3(64 to 127), rot_sel2(7));
--
--rotC840(128 to 191) <= gate(rot_data2_0(128 to 191), rot_sel2(8))  or gate(rot_data2_1(128 to 191), rot_sel2(9)) or
--                       gate(rot_data2_2(128 to 191), rot_sel2(10)) or gate(rot_data2_3(128 to 191), rot_sel2(11));
--
--rotC840(192 to 255) <= gate(rot_data2_0(192 to 255), rot_sel2(12)) or gate(rot_data2_1(192 to 255), rot_sel2(13)) or
--                       gate(rot_data2_2(192 to 255), rot_sel2(14)) or gate(rot_data2_3(192 to 255), rot_sel2(15));
--
---- 0-12,16 byte rotation
--rot_data3_0 <= rotC840(0 to 255);
--rot_data3_1 <= rotC840(128 to 255) & rotC840(0 to 127);
--
--rot10(0 to 63)    <= gate(rot_data3_0(0 to 63), rot_sel3(0)) or gate(rot_data3_1(0 to 63), rot_sel3(1));
--
--rot10(64 to 127)  <= gate(rot_data3_0(64 to 127), rot_sel3(2)) or gate(rot_data3_1(64 to 127), rot_sel3(3));
--
--rot10(128 to 191) <= gate(rot_data3_0(128 to 191), rot_sel3(4))  or gate(rot_data3_1(128 to 191), rot_sel3(5));
--
--rot10(192 to 255) <= gate(rot_data3_0(192 to 255), rot_sel3(6)) or gate(rot_data3_1(192 to 255), rot_sel3(7));

le_mode_on : if l_endian_m = 1 generate begin

      ---- LE,16 byte rotation
      lvl1rot: for byte in 0 to 31 generate begin
            bit: for b in 0 to 3 generate
                signal muxIn    :std_ulogic_vector(0 to 3);
                signal muxSel   :std_ulogic_vector(0 to 3);
            begin
              muxIn  <= rot_data(byte+(b*32))          & rot_data((((16+byte) mod 32))+(b*32)) &
                        rot_data(((31 - byte))+(b*32)) & rot_data(((31 - ((16+byte) mod 32)))+(b*32));
              muxSel <= rot_sel1(4*(byte/4) to (4*(byte/4))+3);
         
              mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
                port map ( vdd => vdd,
                           gnd => gnd,
                           d0  => muxIn(0),
                           d1  => muxIn(1),
                           d2  => muxIn(2),
                           d3  => muxIn(3),
                           s0  => muxSel(0),
                           s1  => muxSel(1),
                           s2  => muxSel(2),
                           s3  => muxSel(3),
                            y  => rot10(byte+(b*32)));
              end generate;
      end generate lvl1rot;

      -- Little-Endian Byte Swap, Specifically for Execution Pipe Stores
      bitSwap : for bit in 0 to 3 generate begin
            byteSwap : for byte in 0 to 31 generate begin
                  le_rot_data(byte+(bit*32)) <= rot_data((31-byte)+(bit*32));
            end generate byteSwap;
    end generate bitSwap;

      -- 0/LE,4,8,12 byte rotation
      lvl2rot: for byte in 0 to 31 generate begin
            bit: for b in 0 to 3 generate
                signal muxIn    :std_ulogic_vector(0 to 3);
                signal muxSel   :std_ulogic_vector(0 to 3);
            begin
              muxIn  <= le_rot_data(byte+(b*32))              & le_rot_data(((4+byte) mod 32)+(b*32)) &
                        le_rot_data(((8+byte) mod 32)+(b*32)) & le_rot_data(((12+byte) mod 32)+(b*32));
              muxSel <= rot_sel2_le(4*(byte/4) to (4*(byte/4))+3);

              mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
                port map ( vdd => vdd,
                           gnd => gnd,
                           d0  => muxIn(0),
                           d1  => muxIn(1),
                           d2  => muxIn(2),
                           d3  => muxIn(3),
                           s0  => muxSel(0),
                           s1  => muxSel(1),
                           s2  => muxSel(2),
                           s3  => muxSel(3),
                           y  => le_rotC840(byte+(b*32)));
            end generate;
      end generate lvl2rot;

      ---- 0/4/8/12/LE,1,2,3 byte rotation
      lvl3rot: for byte in 0 to 31 generate begin
            bit: for b in 0 to 3 generate
                signal muxIn    :std_ulogic_vector(0 to 3);
                signal muxSel   :std_ulogic_vector(0 to 3);
            begin
              muxIn  <= le_rotC840(byte+(b*32))              & le_rotC840(((1+byte) mod 32)+(b*32)) &
                        le_rotC840(((2+byte) mod 32)+(b*32)) & le_rotC840(((3+byte) mod 32)+(b*32));
              muxSel <= rot_sel3_le(4*(byte/4) to (4*(byte/4))+3);

              mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
                port map ( vdd => vdd,
                           gnd => gnd,
                           d0  => muxIn(0),
                           d1  => muxIn(1),
                           d2  => muxIn(2),
                           d3  => muxIn(3),
                           s0  => muxSel(0),
                           s1  => muxSel(1),
                           s2  => muxSel(2),
                           s3  => muxSel(3),
                            y  => le_rot3210(byte+(b*32)));
              end generate;
      end generate lvl3rot;
      data256_rot_le <= le_rot3210;
end generate le_mode_on;

le_mode_off : if l_endian_m = 0 generate begin

      ---- 16 byte rotation
      lvl1rot: for byte in 0 to 31 generate begin
            bit: for b in 0 to 3 generate
                signal muxIn    :std_ulogic_vector(0 to 3);
                signal muxSel   :std_ulogic_vector(0 to 3);
            begin
              muxIn  <= rot_data(byte+(b*32))        & rot_data(((16+byte) mod 32)+(b*32)) &
                        rot_data((31 - byte)+(b*32)) & rot_data((31 - ((16+byte) mod 32))+(b*32));
              muxSel <= rot_sel1(4*(byte/4) to (4*(byte/4))+3);
         
              rot10(byte+(b*32)) <= (rot_data(byte+(b*32)) and rot_sel1(b*4*(byte/16))) or
                                    (rot_data(((16+byte) mod 32)+(b*32)) and rot_sel1((b*4*(byte/16))+1));
              end generate;
      end generate lvl1rot;

      le_rot_data    <= (others=>'0');
      le_rotC840     <= (others=>'0');
      le_rot3210     <= (others=>'0');
      data256_rot_le <= (others=>'0');
end generate le_mode_off;

-- 0/16/LE,4,8,12 byte rotation
lvl2rot: for byte in 0 to 31 generate begin
  bit: for b in 0 to 3 generate
        signal muxIn    :std_ulogic_vector(0 to 3);
        signal muxSel   :std_ulogic_vector(0 to 3);
       begin
         muxIn  <= rot10(byte+(b*32))              & rot10(((4+byte) mod 32)+(b*32)) &
                   rot10(((8+byte) mod 32)+(b*32)) & rot10(((12+byte) mod 32)+(b*32));
         muxSel <= rot_sel2(4*(byte/4) to (4*(byte/4))+3);
         
         mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
           port map ( vdd => vdd,
                      gnd => gnd,
                      d0  => muxIn(0),
                      d1  => muxIn(1),
                      d2  => muxIn(2),
                      d3  => muxIn(3),
                      s0  => muxSel(0),
                      s1  => muxSel(1),
                      s2  => muxSel(2),
                      s3  => muxSel(3),
                       y  => rotC840(byte+(b*32)));
       end generate;
end generate lvl2rot;

---- 0/4/8/12/16/LE,1,2,3 byte rotation
lvl3rot: for byte in 0 to 31 generate begin
  bit: for b in 0 to 3 generate
        signal muxIn    :std_ulogic_vector(0 to 3);
        signal muxSel   :std_ulogic_vector(0 to 3);
       begin
         muxIn  <= rotC840(byte+(b*32))              & rotC840(((1+byte) mod 32)+(b*32)) &
                   rotC840(((2+byte) mod 32)+(b*32)) & rotC840(((3+byte) mod 32)+(b*32));
         muxSel <= rot_sel3(4*(byte/4) to (4*(byte/4))+3);
         
         mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
           port map ( vdd => vdd,
                      gnd => gnd,
                      d0  => muxIn(0),
                      d1  => muxIn(1),
                      d2  => muxIn(2),
                      d3  => muxIn(3),
                      s0  => muxSel(0),
                      s1  => muxSel(1),
                      s2  => muxSel(2),
                      s3  => muxSel(3),
                       y  => rot3210(byte+(b*32)));
       end generate;
end generate lvl3rot;

---- 0,1,2,3 byte rotation
--with rot_sel(3 to 4) select
--    rot3210 <= rot_data(24 to 255) & rot_data(0 to 23) when "11",       -- sel = 0001
--               rot_data(16 to 255) & rot_data(0 to 15) when "10",       -- sel = 0010
--               rot_data(8 to 255)  & rot_data(0 to 7)  when "01",       -- sel = 0100
--                                    rot_data(0 to 255) when others;     -- sel = 1000
--
---- 0-3,4,8,12 byte rotation
--with rot_sel(1 to 2) select
--    rotC840 <= rot3210(96 to 255) & rot3210(0 to 95) when "11",
--               rot3210(64 to 255) & rot3210(0 to 63) when "10",
--               rot3210(32 to 255) & rot3210(0 to 31) when "01",
--                                   rot3210(0 to 255) when others;
--
---- 0-12,16 byte rotation
--with rot_sel(0) select
--    rot10 <= rotC840(128 to 255) & rotC840(0 to 127) when '1',
--                                   rotC840(0 to 255) when others;

-- #############################################################################################
-- Outputs
-- #############################################################################################


data256_rot <= rot3210;
-- #############################################################################################

end xuq_lsu_data_rot32_lu;
