-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;


entity xuq_lsu_data_rot32_lu is
generic(l_endian_m      : integer := 1);        
port(

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     
     rot_sel1                   :in  std_ulogic_vector(0 to 31);
     rot_sel2                   :in  std_ulogic_vector(0 to 31);
     rot_sel3                   :in  std_ulogic_vector(0 to 31);
     rot_sel2_le                :in  std_ulogic_vector(0 to 31);
     rot_sel3_le                :in  std_ulogic_vector(0 to 31);
     rot_data                   :in  std_ulogic_vector(0 to 127);

     data256_rot_le             :out std_ulogic_vector(0 to 127);
     data256_rot                :out std_ulogic_vector(0 to 127)
);
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_data_rot32_lu;
architecture xuq_lsu_data_rot32_lu of xuq_lsu_data_rot32_lu is




signal rot3210                  :std_ulogic_vector(0 to 127);
signal rotC840                  :std_ulogic_vector(0 to 127);
signal rot10                    :std_ulogic_vector(0 to 127);
signal le_rot_data              :std_ulogic_vector(0 to 127);
signal le_rotC840               :std_ulogic_vector(0 to 127);
signal le_rot3210               :std_ulogic_vector(0 to 127);

begin



le_mode_on : if l_endian_m = 1 generate begin

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

      bitSwap : for bit in 0 to 3 generate begin
            byteSwap : for byte in 0 to 31 generate begin
                  le_rot_data(byte+(bit*32)) <= rot_data((31-byte)+(bit*32));
            end generate byteSwap;
    end generate bitSwap;

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



data256_rot <= rot3210;

end xuq_lsu_data_rot32_lu;

