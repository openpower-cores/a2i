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

--  Description:  XU LSU Load Data Rotator Wrapper
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
-- 1) 1 16Byte input (suppose to reflect reading 8 ways of L1 D$, Selection taken place in EX2)
-- 2) 16 Byte Reload Bus
-- 3) 16 Byte Unaligned Rotator
-- 4) Little Endian Support for 2,4,8,16 Byte Operations
-- 5) Contains Fixed Point Unit (FXU) 8 Byte Load Path
-- 6) Contains Auxilary Unit (AXU) 16 Byte Load Path
-- ##########################################################################################


entity xuq_lsu_data_ld is
generic(expand_type     : integer := 2;         -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
        regmode         : integer := 6;                 -- Register Mode 5 = 32bit, 6 = 64bit
        l_endian_m      : integer := 1);        -- 1 = little endian mode enabled, 0 = little endian mode disabled
port(

     -- Acts to latches
     ex3_stg_act                :in  std_ulogic;
     ex4_stg_act                :in  std_ulogic;
     ex5_stg_act                :in  std_ulogic;

     -- Execution Pipe Load Data Rotator Controls
     ex3_opsize                 :in  std_ulogic_vector(0 to 5);
     ex3_algebraic              :in  std_ulogic;
     ex4_ld_rot_sel             :in  std_ulogic_vector(0 to 4);
     ex4_ld_alg_sel             :in  std_ulogic_vector(0 to 4);
     ex4_le_mode                :in  std_ulogic;
     ex5_ld_data                :in  std_ulogic_vector(0 to 255);
     ex5_ld_data_par            :in  std_ulogic_vector(0 to 31);
     ex6_par_chk_val            :in  std_ulogic;                        -- EX6 Parity Error Check is Valid

     -- Debug Bus
     trace_bus_enable           :in  std_ulogic;
     dat_debug_mux_ctrls        :in  std_ulogic_vector(2 to 3);
     dat_dbg_ld_dat             :out std_ulogic_vector(0 to 63);

     -- Rotated Data
     ld_swzl_data               :out std_ulogic_vector(0 to 255);
     ex6_ld_alg_bit             :out std_ulogic_vector(0 to 5);
     ex6_ld_dvc_byte_mask       :out std_ulogic_vector((64-(2**regmode))/8 to 7);

     ex6_ld_par_err             :out std_ulogic;                        -- EX6 Parity Error Detected on the Load Data
     ex7_ld_par_err             :out std_ulogic_vector(0 to 1);         -- EX7 Parity Error Detected on the Load Data

     -- Pervasive
     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_sl_thold_0_b          :in  std_ulogic;
     func_sl_force              :in  std_ulogic;
     func_nsl_thold_0_b         :in  std_ulogic;
     func_nsl_force             :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_in                    :in  std_ulogic;
     scan_out                   :out std_ulogic
);
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_data_ld;
----
architecture xuq_lsu_data_ld of xuq_lsu_data_ld is

----------------------------
-- components
----------------------------

----------------------------
-- constants
----------------------------
constant ex5_opsize_offset              :natural := 0;
constant ex5_algebraic_offset           :natural := ex5_opsize_offset + 6;
constant rotate_select_offset           :natural := ex5_algebraic_offset + 1;
constant le_mode_select_offset          :natural := rotate_select_offset + 5;
constant ex6_ld_data_par_offset         :natural := le_mode_select_offset + 1;
constant ex5_ld_alg_sel_offset          :natural := ex6_ld_data_par_offset + 32;
constant ex7_ld_par_err_offset          :natural := ex5_ld_alg_sel_offset + 5;
constant my_spare_latches_offset        :natural := ex7_ld_par_err_offset + 2;
constant scan_right                     :natural := my_spare_latches_offset + 14 - 1;

----------------------------
-- signals
----------------------------

signal le_mode_select_d         :std_ulogic;
signal le_mode_select_q         :std_ulogic;
signal ex4_opsize_d             :std_ulogic_vector(0 to 5);
signal ex4_opsize_q             :std_ulogic_vector(0 to 5);
signal ex5_opsize_d             :std_ulogic_vector(0 to 5);
signal ex5_opsize_q             :std_ulogic_vector(0 to 5);
signal ex6_opsize_d             :std_ulogic_vector(2 to 5);
signal ex6_opsize_q             :std_ulogic_vector(2 to 5);
signal ex4_algebraic_d          :std_ulogic;
signal ex4_algebraic_q          :std_ulogic;
signal ex5_algebraic_d          :std_ulogic;
signal ex5_algebraic_q          :std_ulogic;
signal ex6_ld_data              :std_ulogic_vector(0 to 255);
signal ex6_ld_data_rot          :std_ulogic_vector(0 to 255);
signal rotate_select_d          :std_ulogic_vector(0 to 4);
signal rotate_select_q          :std_ulogic_vector(0 to 4);
signal ex6_ld_data_par_d        :std_ulogic_vector(0 to 31);
signal ex6_ld_data_par_q        :std_ulogic_vector(0 to 31);
signal par_err_byte             :std_ulogic_vector(0 to 31);
signal par_err_det              :std_ulogic;
signal ex5_ld_alg_sel_d         :std_ulogic_vector(0 to 4);
signal ex5_ld_alg_sel_q         :std_ulogic_vector(0 to 4);
signal ex7_ld_par_err_d         :std_ulogic_vector(0 to 1);
signal ex7_ld_par_err_q         :std_ulogic_vector(0 to 1);
signal ex6_par_err_det1_b       :std_ulogic;
signal ex6_par_err_det1         :std_ulogic;
signal ex6_par_err_det2_b       :std_ulogic;
signal ex6_par_err_det2         :std_ulogic;
signal ld_byte_mask             :std_ulogic_vector(0 to 7);
signal my_spare0_lclk           :clk_logic;
signal my_spare0_d1clk          :std_ulogic;
signal my_spare0_d2clk          :std_ulogic;
signal my_spare_latches_d       :std_ulogic_vector(0 to 13);
signal my_spare_latches_q       :std_ulogic_vector(0 to 13);
signal ex6_load_data0           :std_ulogic_vector(0 to 63);
signal ex6_load_data1           :std_ulogic_vector(0 to 63);
signal ex6_load_data2           :std_ulogic_vector(0 to 63);
signal ex6_load_data3           :std_ulogic_vector(0 to 63);
signal dat_dbg_ld_dat_d         :std_ulogic_vector(0 to 63);
signal dat_dbg_ld_dat_q         :std_ulogic_vector(0 to 63);

signal tiup                     :std_ulogic;
signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);
signal rot_scan_in              :std_ulogic_vector(0 to 7);
signal rot_scan_out             :std_ulogic_vector(0 to 7);



begin

-- #############################################################################################
-- Inputs
-- #############################################################################################

tiup <= '1';

ex4_opsize_d      <= ex3_opsize;
ex5_opsize_d      <= ex4_opsize_q;
ex6_opsize_d      <= ex5_opsize_q(2 to 5);
ex4_algebraic_d   <= ex3_algebraic;
ex5_algebraic_d   <= ex4_algebraic_q;
rotate_select_d   <= ex4_ld_rot_sel;
ex5_ld_alg_sel_d  <= ex4_ld_alg_sel;
le_mode_select_d  <= ex4_le_mode;
ex6_ld_data_par_d <= ex5_ld_data_par;
-- #############################################################################################

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Bus
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

ldDbgData : for byte in 0 to 7 generate begin
      ex6_load_data0(byte*8 to (byte*8)+7) <= ex6_ld_data(byte+0)   & ex6_ld_data(byte+32)  & ex6_ld_data(byte+64)  & ex6_ld_data(byte+96) &
                                              ex6_ld_data(byte+128) & ex6_ld_data(byte+160) & ex6_ld_data(byte+192) & ex6_ld_data(byte+224);
      ex6_load_data1(byte*8 to (byte*8)+7) <= ex6_ld_data(8+byte+0)   & ex6_ld_data(8+byte+32)  & ex6_ld_data(8+byte+64)  & ex6_ld_data(8+byte+96) &
                                              ex6_ld_data(8+byte+128) & ex6_ld_data(8+byte+160) & ex6_ld_data(8+byte+192) & ex6_ld_data(8+byte+224);
      ex6_load_data2(byte*8 to (byte*8)+7) <= ex6_ld_data(16+byte+0)   & ex6_ld_data(16+byte+32)  & ex6_ld_data(16+byte+64)  & ex6_ld_data(16+byte+96) &
                                              ex6_ld_data(16+byte+128) & ex6_ld_data(16+byte+160) & ex6_ld_data(16+byte+192) & ex6_ld_data(16+byte+224);
      ex6_load_data3(byte*8 to (byte*8)+7) <= ex6_ld_data(24+byte+0)   & ex6_ld_data(24+byte+32)  & ex6_ld_data(24+byte+64)  & ex6_ld_data(24+byte+96) &
                                              ex6_ld_data(24+byte+128) & ex6_ld_data(24+byte+160) & ex6_ld_data(24+byte+192) & ex6_ld_data(24+byte+224);
end generate ldDbgData;

with dat_debug_mux_ctrls(2 to 3) select
    dat_dbg_ld_dat_d <= ex6_load_data0 when "00",
                        ex6_load_data1 when "01",
                        ex6_load_data2 when "10",
                        ex6_load_data3 when others; 

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Parity Error Check
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Parity Error Check Per Byte
par_Bdet : for t in 0 to 31 generate begin
      par_err_byte(t) <= ex6_ld_data(t+0)   xor ex6_ld_data(t+32)  xor ex6_ld_data(t+64)  xor ex6_ld_data(t+96)  xor
                         ex6_ld_data(t+128) xor ex6_ld_data(t+160) xor ex6_ld_data(t+192) xor ex6_ld_data(t+224) xor
                         ex6_ld_data_par_q(t);
end generate par_Bdet;

-- Parity Error Detected
par_err_det <= or_reduce(par_err_byte);

ex6par_err1_nand2 : ex6_par_err_det1_b <= not (par_err_det and ex6_par_chk_val);
ex6par_err1_inv   : ex6_par_err_det1   <= not (ex6_par_err_det1_b);

ex7_ld_par_err_d <= (others=>ex6_par_err_det1);
-- #############################################################################################

-- #############################################################################################
-- 32 Byte Rotator
-- #############################################################################################

l1dcrotr : for bit in 0 to 7 generate begin
   sgrp : if (bit = 0) generate
   begin
     bits : entity work.xuq_lsu_data_rot32s_ru(xuq_lsu_data_rot32s_ru)
     generic map(expand_type => expand_type)
     port map (
          opsize                => ex5_opsize_q,
          le                    => le_mode_select_q,
          rotate_sel            => rotate_select_q,
          algebraic             => ex5_algebraic_q,
          algebraic_sel         => ex5_ld_alg_sel_q,

          data                  => ex5_ld_data(bit*32 to (bit*32)+31),
          data_latched          => ex6_ld_data(bit*32 to (bit*32)+31),
          data_rot              => ex6_ld_data_rot(bit*32 to (bit*32)+31),
          algebraic_bit         => ex6_ld_alg_bit,

          vdd                   => vdd,
          gnd                   => gnd,
          nclk                  => nclk,
          act                   => ex5_stg_act,
          func_sl_force => func_sl_force,
          delay_lclkr_dc        => delay_lclkr_dc,
          mpw1_dc_b             => mpw1_dc_b,
          mpw2_dc_b             => mpw2_dc_b,
          func_sl_thold_0_b     => func_sl_thold_0_b,
          sg_0                  => sg_0,
          scan_in               => rot_scan_in(bit),
          scan_out              => rot_scan_out(bit)
     );
   end generate sgrp;
   grp : if (bit /= 0) generate
   begin
     bits : entity work.xuq_lsu_data_rot32_ru(xuq_lsu_data_rot32_ru)
     generic map(expand_type => expand_type)
     port map (
          opsize                => ex5_opsize_q,
          le                    => le_mode_select_q,
          rotate_sel            => rotate_select_q,

          data                  => ex5_ld_data(bit*32 to (bit*32)+31),
          data_latched          => ex6_ld_data(bit*32 to (bit*32)+31),
          data_rot              => ex6_ld_data_rot(bit*32 to (bit*32)+31),

          vdd                   => vdd,
          gnd                   => gnd,
          nclk                  => nclk,
          act                   => ex5_stg_act,
          func_sl_force => func_sl_force,
          delay_lclkr_dc        => delay_lclkr_dc,
          mpw1_dc_b             => mpw1_dc_b,
          mpw2_dc_b             => mpw2_dc_b,
          func_sl_thold_0_b     => func_sl_thold_0_b,
          sg_0                  => sg_0,
          scan_in               => rot_scan_in(bit),
          scan_out              => rot_scan_out(bit)
        );
      end generate grp;   
end generate l1dcrotr;

-- #############################################################################################

-- #############################################################################################
-- Op Size Mask Generation
-- #############################################################################################

with ex6_opsize_q select
    ld_byte_mask <= x"01" when "0001",
                    x"03" when "0010",
                    x"0F" when "0100",
                    x"FF" when others;

ex6_ld_dvc_byte_mask <= ld_byte_mask((64-(2**regmode))/8 to 7);

ld256data : for t in 0 to 31 generate begin      
      ld_swzl_data(t*8 to (t*8)+7) <= ex6_ld_data_rot(t)     & ex6_ld_data_rot(t+32)  & ex6_ld_data_rot(t+64)  & ex6_ld_data_rot(t+96) &
                                      ex6_ld_data_rot(t+128) & ex6_ld_data_rot(t+160) & ex6_ld_data_rot(t+192) & ex6_ld_data_rot(t+224);
end generate ld256data;

-- #############################################################################################

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Spare Latches
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
my_spare_latches_d     <= not my_spare_latches_q;

-- #############################################################################################
-- Outputs
-- #############################################################################################


ex6par_err2_nand2 : ex6_par_err_det2_b <= not (par_err_det and ex6_par_chk_val);
ex6par_err2_inv   : ex6_par_err_det2   <= not (ex6_par_err_det2_b);

ex6_ld_par_err <= ex6_par_err_det2;
ex7_ld_par_err <= ex7_ld_par_err_q;

dat_dbg_ld_dat  <= dat_dbg_ld_dat_q;
-- #############################################################################################

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Registers
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ex4_opsize_reg: tri_regk
  generic map (width => 6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_opsize_d,
            dout    => ex4_opsize_q);

ex5_opsize_reg: tri_rlmreg_p
  generic map (width => 6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_opsize_offset to ex5_opsize_offset + ex5_opsize_d'length-1),
            scout   => sov(ex5_opsize_offset to ex5_opsize_offset + ex5_opsize_d'length-1),
            din     => ex5_opsize_d,
            dout    => ex5_opsize_q);

ex6_opsize_reg: tri_regk
  generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex5_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_opsize_d,
            dout    => ex6_opsize_q);

ex4_algebraic_reg: tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_algebraic_d,
            dout(0) => ex4_algebraic_q);

ex5_algebraic_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_algebraic_offset),
            scout   => sov(ex5_algebraic_offset),
            din     => ex5_algebraic_d,
            dout    => ex5_algebraic_q);

rotate_select_reg: tri_rlmreg_p
  generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rotate_select_offset to rotate_select_offset + rotate_select_d'length-1),
            scout   => sov(rotate_select_offset to rotate_select_offset + rotate_select_d'length-1),
            din     => rotate_select_d,
            dout    => rotate_select_q);

le_mode_select_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(le_mode_select_offset),
            scout   => sov(le_mode_select_offset),
            din     => le_mode_select_d,
            dout    => le_mode_select_q);

ex6_ld_data_par_reg: tri_rlmreg_p
generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex5_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_ld_data_par_offset to ex6_ld_data_par_offset + ex6_ld_data_par_d'length-1),
            scout   => sov(ex6_ld_data_par_offset to ex6_ld_data_par_offset + ex6_ld_data_par_d'length-1),
            din     => ex6_ld_data_par_d,
            dout    => ex6_ld_data_par_q);

ex5_ld_alg_sel_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ld_alg_sel_offset to ex5_ld_alg_sel_offset + ex5_ld_alg_sel_d'length-1),
            scout   => sov(ex5_ld_alg_sel_offset to ex5_ld_alg_sel_offset + ex5_ld_alg_sel_d'length-1),
            din     => ex5_ld_alg_sel_d,
            dout    => ex5_ld_alg_sel_q);

ex7_ld_par_err_reg: tri_rlmreg_p
  generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex7_ld_par_err_offset to  ex7_ld_par_err_offset + ex7_ld_par_err_d'length-1),
            scout   => sov(ex7_ld_par_err_offset to  ex7_ld_par_err_offset + ex7_ld_par_err_d'length-1),
            din     => ex7_ld_par_err_d,
            dout    => ex7_ld_par_err_q);

my_spare0_lcb : entity tri.tri_lcbnd(tri_lcbnd)
generic map (expand_type => expand_type)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            lclk    => my_spare0_lclk);
my_spare_latches_reg: entity tri.tri_inv_nlats(tri_inv_nlats)
generic map (width => 14, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            lclk    => my_spare0_lclk,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            scanin  => siv(my_spare_latches_offset to  my_spare_latches_offset + my_spare_latches_d'length-1),
            scanout => sov(my_spare_latches_offset to  my_spare_latches_offset + my_spare_latches_d'length-1),
            d       => my_spare_latches_d,
            qb      => my_spare_latches_q);

dat_dbg_ld_dat_reg: tri_regk
  generic map (width => 64, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => dat_dbg_ld_dat_d,
            dout    => dat_dbg_ld_dat_q);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
rot_scan_in(0 to 7)  <= rot_scan_out(1 to 7) & sov(0);
scan_out             <= rot_scan_out(0);

end xuq_lsu_data_ld;
