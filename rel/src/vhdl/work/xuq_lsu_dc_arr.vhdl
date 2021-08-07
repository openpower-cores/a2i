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

--  Description:  XU LSU L1 Data Cache Array
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
-- 1) L1 D-Cache Array
-- 2) Load Data Way Select Mux
-- 3) Reload/Store Data select
-- ##########################################################################################

entity xuq_lsu_dc_arr is
generic(expand_type     : integer := 2;                 -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
        dc_size         : natural := 14);               -- 2^14 = 16384 Bytes L1 D$
port(

     -- Acts to latches
     ex3_stg_act                :in  std_ulogic;
     ex4_stg_act                :in  std_ulogic;
     rel3_stg_act               :in  std_ulogic;
     rel4_stg_act               :in  std_ulogic;

     -- XUOP Signals
     ex3_p_addr                 :in  std_ulogic_vector(64-(dc_size-3) to 58);       -- EX3 L1 D$ Array Address
     ex3_byte_en                :in  std_ulogic_vector(0 to 31);        -- EX3 Store Byte Enables
     ex4_256st_data             :in  std_ulogic_vector(0 to 255);       -- EX4 Store Data that will be stored in L1 D$ Array
     ex4_parity_gen             :in  std_ulogic_vector(0 to 31);        -- EX4 Parity Bits for XU/AXU store data
     ex4_load_hit               :in  std_ulogic;                        -- EX4 Instruction is a load hit
     ex5_stg_flush              :in  std_ulogic;                        -- EX5 Stage Flush

     -- Parity Error Inject
     inj_dcache_parity          :in  std_ulogic;                        -- Parity Error Inject

     -- Reload Signals
     ldq_rel_data_val           :in  std_ulogic;
     ldq_rel_addr               :in  std_ulogic_vector(64-(dc_size-3) to 58);       -- Reload Array Address

     -- D$ Array Inputs
     dcarr_rd_data              :in  std_ulogic_vector(0 to 287);       -- D$ Array Read Data

     -- D$ Array Outputs
     dcarr_bw                   :out std_ulogic_vector(0 to 287);       -- D$ Array Bit Enables
     dcarr_addr                 :out std_ulogic_vector(64-(dc_size-3) to 58);       -- D$ Array Address
     dcarr_wr_data              :out std_ulogic_vector(0 to 287);       -- D$ Array Write Data
     dcarr_bw_dly               :out std_ulogic_vector(0 to 31);

     -- Execution Pipe
     ex5_ld_data                :out std_ulogic_vector(0 to 255);       -- EX5 Load Data Coming out of L1 D$ Array
     ex5_ld_data_par            :out std_ulogic_vector(0 to 31);        -- EX5 Load Data Parity Bits
     ex6_par_chk_val            :out std_ulogic;                        -- EX6 Parity Error Check is Valid

     --pervasive
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
end xuq_lsu_dc_arr;
----
architecture xuq_lsu_dc_arr of xuq_lsu_dc_arr is

----------------------------
-- components
----------------------------

----------------------------
-- constants
----------------------------
constant ex6_par_err_val_offset :natural := 0;
constant ex5_load_op_hit_offset :natural := ex6_par_err_val_offset + 1;
constant arr_addr_offset        :natural := ex5_load_op_hit_offset + 1;
constant arr_bw_offset          :natural := arr_addr_offset + 58-(64-(dc_size-3))+1;
constant scan_right             :natural := arr_bw_offset + 32 - 1;

----------------------------
-- signals
----------------------------

signal xuop_addr                :std_ulogic_vector(64-(dc_size-3) to 58);
signal st_byte_en               :std_ulogic_vector(0 to 31);
signal rel_addr                 :std_ulogic_vector(64-(dc_size-3) to 58);
signal arr_addr_d               :std_ulogic_vector(64-(dc_size-3) to 58);
signal arr_addr_q               :std_ulogic_vector(64-(dc_size-3) to 58);
signal arr_st_data              :std_ulogic_vector(0 to 255);
signal arr_parity               :std_ulogic_vector(0 to 31);
signal arr_wr_data              :std_ulogic_vector(0 to 287);
signal arr_bw_d                 :std_ulogic_vector(0 to 31);
signal arr_bw_q                 :std_ulogic_vector(0 to 31);
signal arr_bw_dly_d             :std_ulogic_vector(0 to 31);
signal arr_bw_dly_q             :std_ulogic_vector(0 to 31);
signal arr_rd_data              :std_ulogic_vector(0 to 287);
signal arr_ld_data              :std_ulogic_vector(0 to 255);
signal ld_arr_parity            :std_ulogic_vector(0 to 31);
signal rel_val_data             :std_ulogic;
signal ex5_load_op_hit_d        :std_ulogic;
signal ex5_load_op_hit_q        :std_ulogic;
signal ex6_par_err_val_d        :std_ulogic;
signal ex6_par_err_val_q        :std_ulogic;
signal rel3_ex3_stg_act         :std_ulogic;
signal rel4_ex4_stg_act         :std_ulogic;
signal inj_dcache_parity_b      :std_ulogic;
signal arr_rd_data64_b          :std_ulogic;
signal stickBit64               :std_ulogic;

signal tiup                     :std_ulogic;
signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);
begin

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Act Signals going to all Latches
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

rel3_ex3_stg_act <= rel3_stg_act or ex3_stg_act;
rel4_ex4_stg_act <= rel4_stg_act or ex4_stg_act;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Inputs
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
tiup <= '1';

xuop_addr    <= ex3_p_addr;
st_byte_en   <= ex3_byte_en;
arr_parity   <= ex4_parity_gen;
rel_val_data <= ldq_rel_data_val;
rel_addr     <= ldq_rel_addr;

arr_rd_data         <= dcarr_rd_data;
arr_st_data         <= ex4_256st_data;
ex5_load_op_hit_d   <= ex4_load_hit;
inj_dcache_parity_b <= not inj_dcache_parity;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Select between different Operations
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

with rel_val_data select
    arr_addr_d <= xuop_addr when '0',
                   rel_addr when others;

with rel_val_data select
    arr_bw_d <=  st_byte_en when '0',
                x"FFFFFFFF" when others;

arr_bw_dly_d <= arr_bw_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Array Data Fix Up
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

arr_wr_data <= arr_st_data(0 to 127)   & arr_parity(0 to 15) &
               arr_st_data(128 to 255) & arr_parity(16 to 31);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Inject Data Cache Error
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Sticking bit64 of the array when Data Cache Parity Error Inject is on
-- Bit64 will be stuck to 1
-- Bit64 refers to bit2 of byte0
arr_rd_data64_b <= not arr_rd_data(64);
stickBit64      <= not (arr_rd_data64_b and inj_dcache_parity_b);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Array Data  Select
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

arr_ld_data   <= arr_rd_data(0 to 63) & stickBit64 & arr_rd_data(65 to 127) & arr_rd_data(144 to 271);

-- Array Parity
ld_arr_parity <= arr_rd_data(128 to 143) & arr_rd_data(272 to 287);

-- Parity Check is Valid
ex6_par_err_val_d <= ex5_load_op_hit_q and not ex5_stg_flush;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Outputs
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

bw_gen : for bi in 0 to 31 generate begin
      dcarr_bw(bi+0)                 <= arr_bw_q(bi);
      dcarr_bw(bi+32)                <= arr_bw_q(bi);
      dcarr_bw(bi+64)                <= arr_bw_q(bi);
      dcarr_bw(bi+96)                <= arr_bw_q(bi);
      dcarr_bw(bi+144)               <= arr_bw_q(bi);
      dcarr_bw(bi+176)               <= arr_bw_q(bi);
      dcarr_bw(bi+208)               <= arr_bw_q(bi);
      dcarr_bw(bi+240)               <= arr_bw_q(bi);
      -- Parity Bits
      dcarr_bw(bi+128+(128*(bi/16))) <= arr_bw_q(bi);
end generate bw_gen;

dcarr_addr    <= arr_addr_q;
dcarr_wr_data <= arr_wr_data;
dcarr_bw_dly  <= arr_bw_dly_q;

ex5_ld_data     <= arr_ld_data;
ex5_ld_data_par <= ld_arr_parity;
ex6_par_chk_val <= ex6_par_err_val_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Registers
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ex6_par_err_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(ex6_par_err_val_offset),
            scout   => sov(ex6_par_err_val_offset),
            din     => ex6_par_err_val_d,
            dout    => ex6_par_err_val_q);

ex5_load_op_hit_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(ex5_load_op_hit_offset),
            scout   => sov(ex5_load_op_hit_offset),
            din     => ex5_load_op_hit_d,
            dout    => ex5_load_op_hit_q);

arr_addr_reg: tri_rlmreg_p
  generic map (width => 58-(64-(dc_size-3))+1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(arr_addr_offset to arr_addr_offset + arr_addr_d'length-1),
            scout   => sov(arr_addr_offset to arr_addr_offset + arr_addr_d'length-1),
            din     => arr_addr_d,
            dout    => arr_addr_q);

arr_bw_reg: tri_rlmreg_p
  generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(arr_bw_offset to arr_bw_offset + arr_bw_d'length-1),
            scout   => sov(arr_bw_offset to arr_bw_offset + arr_bw_d'length-1),
            din     => arr_bw_d,
            dout    => arr_bw_q);

arr_bw_dly_reg: tri_regk
  generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel4_ex4_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => arr_bw_dly_d,
            dout    => arr_bw_dly_q);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);

end xuq_lsu_dc_arr;
