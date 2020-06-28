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


entity xuq_lsu_dc_arr is
generic(expand_type     : integer := 2;                 
        dc_size         : natural := 14);               
port(

     ex3_stg_act                :in  std_ulogic;
     ex4_stg_act                :in  std_ulogic;
     rel3_stg_act               :in  std_ulogic;
     rel4_stg_act               :in  std_ulogic;

     ex3_p_addr                 :in  std_ulogic_vector(64-(dc_size-3) to 58);       
     ex3_byte_en                :in  std_ulogic_vector(0 to 31);        
     ex4_256st_data             :in  std_ulogic_vector(0 to 255);       
     ex4_parity_gen             :in  std_ulogic_vector(0 to 31);        
     ex4_load_hit               :in  std_ulogic;                        
     ex5_stg_flush              :in  std_ulogic;                        

     inj_dcache_parity          :in  std_ulogic;                        

     ldq_rel_data_val           :in  std_ulogic;
     ldq_rel_addr               :in  std_ulogic_vector(64-(dc_size-3) to 58);       

     dcarr_rd_data              :in  std_ulogic_vector(0 to 287);       

     dcarr_bw                   :out std_ulogic_vector(0 to 287);       
     dcarr_addr                 :out std_ulogic_vector(64-(dc_size-3) to 58);       
     dcarr_wr_data              :out std_ulogic_vector(0 to 287);       
     dcarr_bw_dly               :out std_ulogic_vector(0 to 31);

     ex5_ld_data                :out std_ulogic_vector(0 to 255);       
     ex5_ld_data_par            :out std_ulogic_vector(0 to 31);        
     ex6_par_chk_val            :out std_ulogic;                        

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
architecture xuq_lsu_dc_arr of xuq_lsu_dc_arr is


constant ex6_par_err_val_offset :natural := 0;
constant ex5_load_op_hit_offset :natural := ex6_par_err_val_offset + 1;
constant arr_addr_offset        :natural := ex5_load_op_hit_offset + 1;
constant arr_bw_offset          :natural := arr_addr_offset + 58-(64-(dc_size-3))+1;
constant scan_right             :natural := arr_bw_offset + 32 - 1;


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


rel3_ex3_stg_act <= rel3_stg_act or ex3_stg_act;
rel4_ex4_stg_act <= rel4_stg_act or ex4_stg_act;

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


with rel_val_data select
    arr_addr_d <= xuop_addr when '0',
                   rel_addr when others;

with rel_val_data select
    arr_bw_d <=  st_byte_en when '0',
                x"FFFFFFFF" when others;

arr_bw_dly_d <= arr_bw_q;


arr_wr_data <= arr_st_data(0 to 127)   & arr_parity(0 to 15) &
               arr_st_data(128 to 255) & arr_parity(16 to 31);


arr_rd_data64_b <= not arr_rd_data(64);
stickBit64      <= not (arr_rd_data64_b and inj_dcache_parity_b);


arr_ld_data   <= arr_rd_data(0 to 63) & stickBit64 & arr_rd_data(65 to 127) & arr_rd_data(144 to 271);

ld_arr_parity <= arr_rd_data(128 to 143) & arr_rd_data(272 to 287);

ex6_par_err_val_d <= ex5_load_op_hit_q and not ex5_stg_flush;



bw_gen : for bi in 0 to 31 generate begin
      dcarr_bw(bi+0)                 <= arr_bw_q(bi);
      dcarr_bw(bi+32)                <= arr_bw_q(bi);
      dcarr_bw(bi+64)                <= arr_bw_q(bi);
      dcarr_bw(bi+96)                <= arr_bw_q(bi);
      dcarr_bw(bi+144)               <= arr_bw_q(bi);
      dcarr_bw(bi+176)               <= arr_bw_q(bi);
      dcarr_bw(bi+208)               <= arr_bw_q(bi);
      dcarr_bw(bi+240)               <= arr_bw_q(bi);
      dcarr_bw(bi+128+(128*(bi/16))) <= arr_bw_q(bi);
end generate bw_gen;

dcarr_addr    <= arr_addr_q;
dcarr_wr_data <= arr_wr_data;
dcarr_bw_dly  <= arr_bw_dly_q;

ex5_ld_data     <= arr_ld_data;
ex5_ld_data_par <= ld_arr_parity;
ex6_par_chk_val <= ex6_par_err_val_q;

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

