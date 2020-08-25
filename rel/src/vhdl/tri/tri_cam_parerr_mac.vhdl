-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--********************************************************************
--* TITLE: ERAT CAM Parity Error Macro Tri-Library Model
--* NAME: tri_cam_parerr_mac
library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity tri_cam_parerr_mac  is
  generic (expand_type : integer := 1);
  port(

   np1_cam_cmp_data             :in  std_ulogic_vector(0 to 83);
   np1_array_cmp_data           :in  std_ulogic_vector(0 to 67);

   np2_cam_cmp_data             :out std_ulogic_vector(0 to 83);
   np2_array_cmp_data           :out std_ulogic_vector(0 to 67);
   np2_cmp_data_parerr_epn      :out std_ulogic; 
   np2_cmp_data_parerr_rpn      :out std_ulogic;

   -- Pervasive
   gnd                          :inout power_logic;
   vdd                          :inout power_logic;
   nclk                         :in  clk_logic;
   act                          :in  std_ulogic;
   lcb_act_dis_dc               :in  std_ulogic;
   lcb_delay_lclkr_dc           :in  std_ulogic;
   lcb_clkoff_dc_b_0            :in  std_ulogic;
   lcb_mpw1_dc_b                :in  std_ulogic;
   lcb_mpw2_dc_b                :in  std_ulogic;
   lcb_sg_0                     :in  std_ulogic;
   lcb_func_sl_thold_0          :in  std_ulogic; 
   func_scan_in                 :in  std_ulogic;
   func_scan_out                :out std_ulogic
  );
-- synopsys translate_off
-- synopsys translate_on
end entity tri_cam_parerr_mac;

architecture tri_cam_parerr_mac of tri_cam_parerr_mac is

begin

  um: if expand_type = 0 generate
      signal np2_cam_cmp_data_q         :std_ulogic_vector(0 to np1_cam_cmp_data'length-1);
      signal np2_array_cmp_data_q       :std_ulogic_vector(0 to np1_array_cmp_data'length-1);
      signal np2_cmp_data_calc_par      :std_ulogic_vector(50 to 67);

  begin
      np1_cam_cmp_data_latch: tri_rlmreg_p
        generic map (width => np1_cam_cmp_data'length, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => np1_cam_cmp_data,
                  dout        => np2_cam_cmp_data_q);

      np1_array_cmp_data_latch: tri_rlmreg_p
        generic map (width => np1_array_cmp_data'length, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => np1_array_cmp_data,
                  dout        => np2_array_cmp_data_q);

      -- Parity Calculation
      np2_cmp_data_calc_par(50) <= xor_reduce(np2_cam_cmp_data_q(75 to 82));
      np2_cmp_data_calc_par(51) <= xor_reduce(np2_cam_cmp_data_q(0 to 7));
      np2_cmp_data_calc_par(52) <= xor_reduce(np2_cam_cmp_data_q(8 to 15));
      np2_cmp_data_calc_par(53) <= xor_reduce(np2_cam_cmp_data_q(16 to 23));
      np2_cmp_data_calc_par(54) <= xor_reduce(np2_cam_cmp_data_q(24 to 31));
      np2_cmp_data_calc_par(55) <= xor_reduce(np2_cam_cmp_data_q(32 to 39));
      np2_cmp_data_calc_par(56) <= xor_reduce(np2_cam_cmp_data_q(40 to 47));
      np2_cmp_data_calc_par(57) <= xor_reduce(np2_cam_cmp_data_q(48 to 55));
      np2_cmp_data_calc_par(58) <= xor_reduce(np2_cam_cmp_data_q(57 to 62));
      np2_cmp_data_calc_par(59) <= xor_reduce(np2_cam_cmp_data_q(63 to 66));
      np2_cmp_data_calc_par(60) <= xor_reduce(np2_cam_cmp_data_q(67 to 74));
      np2_cmp_data_calc_par(61) <= xor_reduce(np2_array_cmp_data_q(0 to 5));
      np2_cmp_data_calc_par(62) <= xor_reduce(np2_array_cmp_data_q(6 to 13));
      np2_cmp_data_calc_par(63) <= xor_reduce(np2_array_cmp_data_q(14 to 21));
      np2_cmp_data_calc_par(64) <= xor_reduce(np2_array_cmp_data_q(22 to 29));
      np2_cmp_data_calc_par(65) <= xor_reduce(np2_array_cmp_data_q(30 to 37));
      np2_cmp_data_calc_par(66) <= xor_reduce(np2_array_cmp_data_q(38 to 44));
      np2_cmp_data_calc_par(67) <= xor_reduce(np2_array_cmp_data_q(45 to 50));

      -- Outputs
      np2_cmp_data_parerr_epn   <= or_reduce(np2_cmp_data_calc_par(50 to 60) xor (np2_cam_cmp_data_q(83) & np2_array_cmp_data_q(51 to 60)));
      np2_cmp_data_parerr_rpn   <= or_reduce(np2_cmp_data_calc_par(61 to 67) xor np2_array_cmp_data_q(61 to 67));
      np2_cam_cmp_data          <= np2_cam_cmp_data_q;
      np2_array_cmp_data        <= np2_array_cmp_data_q;
  end generate um;

  a: if expand_type = 1 generate
      signal np2_cam_cmp_data_q         :std_ulogic_vector(0 to np1_cam_cmp_data'length-1);
      signal np2_array_cmp_data_q       :std_ulogic_vector(0 to np1_array_cmp_data'length-1);
      signal np2_cmp_data_calc_par      :std_ulogic_vector(50 to 67);
      signal clk                        :std_ulogic;
      signal sreset_q                   :std_ulogic;
  begin
     clk   <= not nclk.clk;
     rlatch: process (clk)
     begin
       if(rising_edge(clk)) then
         sreset_q             <= nclk.sreset;
       end if;
     end process;

     slatch: process (nclk,sreset_q)
     begin
       if(rising_edge(nclk.clk)) then
         if (sreset_q = '1') then
           np2_cam_cmp_data_q   <= (others=>'0');
           np2_array_cmp_data_q <= (others=>'0');
         else
           np2_cam_cmp_data_q   <= np1_cam_cmp_data;
           np2_array_cmp_data_q <= np1_array_cmp_data;
         end if;
       end if;
     end process;

     -- Parity Calculation
     np2_cmp_data_calc_par(50) <= xor_reduce(np2_cam_cmp_data_q(75 to 82));
     np2_cmp_data_calc_par(51) <= xor_reduce(np2_cam_cmp_data_q(0 to 7));
     np2_cmp_data_calc_par(52) <= xor_reduce(np2_cam_cmp_data_q(8 to 15));
     np2_cmp_data_calc_par(53) <= xor_reduce(np2_cam_cmp_data_q(16 to 23));
     np2_cmp_data_calc_par(54) <= xor_reduce(np2_cam_cmp_data_q(24 to 31));
     np2_cmp_data_calc_par(55) <= xor_reduce(np2_cam_cmp_data_q(32 to 39));
     np2_cmp_data_calc_par(56) <= xor_reduce(np2_cam_cmp_data_q(40 to 47));
     np2_cmp_data_calc_par(57) <= xor_reduce(np2_cam_cmp_data_q(48 to 55));
     np2_cmp_data_calc_par(58) <= xor_reduce(np2_cam_cmp_data_q(57 to 62));
     np2_cmp_data_calc_par(59) <= xor_reduce(np2_cam_cmp_data_q(63 to 66));
     np2_cmp_data_calc_par(60) <= xor_reduce(np2_cam_cmp_data_q(67 to 74));
     np2_cmp_data_calc_par(61) <= xor_reduce(np2_array_cmp_data_q(0 to 5));
     np2_cmp_data_calc_par(62) <= xor_reduce(np2_array_cmp_data_q(6 to 13));
     np2_cmp_data_calc_par(63) <= xor_reduce(np2_array_cmp_data_q(14 to 21));
     np2_cmp_data_calc_par(64) <= xor_reduce(np2_array_cmp_data_q(22 to 29));
     np2_cmp_data_calc_par(65) <= xor_reduce(np2_array_cmp_data_q(30 to 37));
     np2_cmp_data_calc_par(66) <= xor_reduce(np2_array_cmp_data_q(38 to 44));
     np2_cmp_data_calc_par(67) <= xor_reduce(np2_array_cmp_data_q(45 to 50));

     -- Outputs
     np2_cmp_data_parerr_epn   <= or_reduce(np2_cmp_data_calc_par(50 to 60) xor (np2_cam_cmp_data_q(83) & np2_array_cmp_data_q(51 to 60)));
     np2_cmp_data_parerr_rpn   <= or_reduce(np2_cmp_data_calc_par(61 to 67) xor np2_array_cmp_data_q(61 to 67));
     np2_cam_cmp_data          <= np2_cam_cmp_data_q;
     np2_array_cmp_data        <= np2_array_cmp_data_q;

     -- Scan Chains
     func_scan_out <= func_scan_in;
  end generate a;

end tri_cam_parerr_mac;
