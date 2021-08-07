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




library ieee;
use ieee.std_logic_1164.all;

library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;

library support;
use support.power_logic_pkg.all;

library tri;
use tri.tri_latches_pkg.all;

entity iuq_perv is
generic(expand_type : integer := 2 ); -- 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     pc_iu_sg_3                 : in  std_ulogic_vector(0 to 3);
     pc_iu_func_sl_thold_3      : in  std_ulogic_vector(0 to 3);
     pc_iu_func_slp_sl_thold_3  : in  std_ulogic;
     pc_iu_gptr_sl_thold_3      : in  std_ulogic;
     pc_iu_time_sl_thold_3      : in  std_ulogic;
     pc_iu_repr_sl_thold_3      : in  std_ulogic;
     pc_iu_abst_sl_thold_3      : in  std_ulogic;
     pc_iu_abst_slp_sl_thold_3  : in  std_ulogic;
     pc_iu_cfg_sl_thold_3       : in  std_ulogic;
     pc_iu_cfg_slp_sl_thold_3   : in  std_ulogic;
     pc_iu_regf_slp_sl_thold_3  : in  std_ulogic;
     pc_iu_ary_nsl_thold_3      : in  std_ulogic;
     pc_iu_ary_slp_nsl_thold_3  : in  std_ulogic;
     pc_iu_func_slp_nsl_thold_3 : in  std_ulogic;
     pc_iu_bolt_sl_thold_3      : in  std_ulogic;
     pc_iu_bo_enable_3          : in  std_ulogic;
     pc_iu_fce_3                : in  std_ulogic;
     tc_ac_ccflush_dc           : in  std_ulogic;
     scan_diag_dc               : in  std_ulogic;
     pc_iu_sg_2                 : out std_ulogic_vector(0 to 3);
     pc_iu_func_sl_thold_2      : out std_ulogic_vector(0 to 3);
     pc_iu_func_slp_sl_thold_2  : out std_ulogic;
     pc_iu_time_sl_thold_2      : out std_ulogic;
     pc_iu_repr_sl_thold_2      : out std_ulogic;
     pc_iu_abst_sl_thold_2      : out std_ulogic;
     pc_iu_abst_slp_sl_thold_2  : out std_ulogic;
     pc_iu_cfg_sl_thold_2       : out  std_ulogic;
     pc_iu_cfg_slp_sl_thold_2   : out  std_ulogic;
     pc_iu_regf_slp_sl_thold_2  : out  std_ulogic;
     pc_iu_ary_nsl_thold_2      : out std_ulogic;
     pc_iu_ary_slp_nsl_thold_2  : out std_ulogic;
     pc_iu_func_slp_nsl_thold_2 : out std_ulogic;
     pc_iu_bolt_sl_thold_2      : out std_ulogic;
     pc_iu_bo_enable_2          : out std_ulogic;
     pc_iu_fce_2                : out std_ulogic;
     clkoff_b                   : out std_ulogic_vector(0 to 2);
     act_dis                    : out std_ulogic_vector(0 to 2);
     d_mode                     : out std_ulogic_vector(0 to 2);
     delay_lclkr                : out std_ulogic_vector(0 to 14);
     mpw1_b                     : out std_ulogic_vector(0 to 14);
     mpw2_b                     : out std_ulogic_vector(0 to 2);
     bht_g8t_clkoff_b           : out std_ulogic;
     bht_g8t_d_mode             : out std_ulogic;
     bht_g8t_delay_lclkr        : out std_ulogic_vector(0 to 4);
     bht_g8t_mpw1_b             : out std_ulogic_vector(0 to 4);
     bht_g8t_mpw2_b             : out std_ulogic;
     g8t_clkoff_b               : out std_ulogic;
     g8t_d_mode                 : out std_ulogic;
     g8t_delay_lclkr            : out std_ulogic_vector(0 to 4);
     g8t_mpw1_b                 : out std_ulogic_vector(0 to 4);
     g8t_mpw2_b                 : out std_ulogic;
     g6t_clkoff_b               : out std_ulogic;
     g6t_d_mode                 : out std_ulogic;
     g6t_delay_lclkr            : out std_ulogic_vector(0 to 3);
     g6t_mpw1_b                 : out std_ulogic_vector(0 to 4);
     g6t_mpw2_b                 : out std_ulogic;
     cam_clkoff_b               : out std_ulogic;
     cam_d_mode                 : out std_ulogic;
     cam_delay_lclkr            : out std_ulogic_vector(0 to 4);
     cam_mpw1_b                 : out std_ulogic_vector(0 to 4);
     cam_mpw2_b                 : out std_ulogic;
     gptr_scan_in               : in  std_ulogic;
     gptr_scan_out              : out std_ulogic
);

-- synopsys translate_off


-- synopsys translate_on

end iuq_perv;
architecture iuq_perv of iuq_perv is

signal pc_iu_gptr_sl_thold_2_int        : std_ulogic;
signal pc_iu_time_sl_thold_2_int        : std_ulogic;
signal pc_iu_sg_2_int                   : std_ulogic_vector(0 to 3);

signal pc_iu_gptr_sl_thold_1            : std_ulogic;
signal pc_iu_sg_1                       : std_ulogic;
signal pc_iu_gptr_sl_thold_0            : std_ulogic;
signal pc_iu_sg_0                       : std_ulogic;

signal int_g6t_delay_lclkr              : std_ulogic_vector(0 to 4);
signal unused                           : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on


signal gptr_siv                         : std_ulogic_vector(0 to 6);
signal gptr_sov                         : std_ulogic_vector(0 to 6);

begin

perv_3to2_reg: tri_plat
  generic map (width => 23, expand_type => expand_type)
  port map (vd           => vdd,
            gd           => gnd,
            nclk         => nclk,
            flush        => tc_ac_ccflush_dc,
            din(0 to 3)  => pc_iu_func_sl_thold_3(0 to 3),
            din(4)       => pc_iu_gptr_sl_thold_3,
            din(5)       => pc_iu_time_sl_thold_3,
            din(6)       => pc_iu_repr_sl_thold_3,
            din(7)       => pc_iu_abst_sl_thold_3,
            din(8)       => pc_iu_ary_nsl_thold_3,
            din(9 to 12) => pc_iu_sg_3(0 to 3),
            din(13)      => pc_iu_fce_3,
            din(14)      => pc_iu_cfg_slp_sl_thold_3,
            din(15)      => pc_iu_cfg_sl_thold_3,
            din(16)      => pc_iu_regf_slp_sl_thold_3,
            din(17)      => pc_iu_func_slp_sl_thold_3,
            din(18)      => pc_iu_ary_slp_nsl_thold_3,
            din(19)      => pc_iu_abst_slp_sl_thold_3,
            din(20)      => pc_iu_func_slp_nsl_thold_3,
            din(21)      => pc_iu_bolt_sl_thold_3,
            din(22)      => pc_iu_bo_enable_3,
            q(0 to 3)    => pc_iu_func_sl_thold_2(0 to 3),
            q(4)         => pc_iu_gptr_sl_thold_2_int,
            q(5)         => pc_iu_time_sl_thold_2_int,
            q(6)         => pc_iu_repr_sl_thold_2,
            q(7)         => pc_iu_abst_sl_thold_2,
            q(8)         => pc_iu_ary_nsl_thold_2,
            q(9 to 12)   => pc_iu_sg_2_int(0 to 3),
            q(13)        => pc_iu_fce_2,
            q(14)        => pc_iu_cfg_slp_sl_thold_2,
            q(15)        => pc_iu_cfg_sl_thold_2,
            q(16)        => pc_iu_regf_slp_sl_thold_2,
            q(17)        => pc_iu_func_slp_sl_thold_2,
            q(18)        => pc_iu_ary_slp_nsl_thold_2,
            q(19)        => pc_iu_abst_slp_sl_thold_2,
            q(20)        => pc_iu_func_slp_nsl_thold_2,
            q(21)        => pc_iu_bolt_sl_thold_2,
            q(22)        => pc_iu_bo_enable_2);

pc_iu_time_sl_thold_2   <= pc_iu_time_sl_thold_2_int;
pc_iu_sg_2              <= pc_iu_sg_2_int;

perv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_gptr_sl_thold_2_int,
            din(1)      => pc_iu_sg_2_int(0),
            q(0)        => pc_iu_gptr_sl_thold_1,
            q(1)        => pc_iu_sg_1);

perv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_gptr_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            q(0)        => pc_iu_gptr_sl_thold_0,
            q(1)        => pc_iu_sg_0);


perv_lcbcntl0: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_iu_sg_0,
            nclk           => nclk,
            scan_in        => gptr_siv(0),
            scan_diag_dc   => scan_diag_dc,
            thold          => pc_iu_gptr_sl_thold_0,
            clkoff_dc_b    => clkoff_b(0),
            delay_lclkr_dc => delay_lclkr(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => d_mode(0),
            mpw1_dc_b      => mpw1_b(0 to 4),
            mpw2_dc_b      => mpw2_b(0),
            scan_out       => gptr_sov(0));

perv_lcbcntl1: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_iu_sg_0,
            nclk           => nclk,
            scan_in        => gptr_siv(1),
            scan_diag_dc   => scan_diag_dc,
            thold          => pc_iu_gptr_sl_thold_0,
            clkoff_dc_b    => clkoff_b(1),
            delay_lclkr_dc => delay_lclkr(5 to 9),
            act_dis_dc     => open,
            d_mode_dc      => d_mode(1),
            mpw1_dc_b      => mpw1_b(5 to 9),
            mpw2_dc_b      => mpw2_b(1),
            scan_out       => gptr_sov(1));


perv_lcbcntl2: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_iu_sg_0,
            nclk           => nclk,
            scan_in        => gptr_siv(2),
            scan_diag_dc   => scan_diag_dc,
            thold          => pc_iu_gptr_sl_thold_0,
            clkoff_dc_b    => clkoff_b(2),
            delay_lclkr_dc => delay_lclkr(10 to 14),
            act_dis_dc     => open,
            d_mode_dc      => d_mode(2),
            mpw1_dc_b      => mpw1_b(10 to 14),
            mpw2_dc_b      => mpw2_b(2),
            scan_out       => gptr_sov(2));


perv_lcbcntl_g8t_bht: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_iu_sg_0,
            nclk           => nclk,
            scan_in        => gptr_siv(3),
            scan_diag_dc   => scan_diag_dc,
            thold          => pc_iu_gptr_sl_thold_0,
            clkoff_dc_b    => bht_g8t_clkoff_b,
            delay_lclkr_dc => bht_g8t_delay_lclkr(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => bht_g8t_d_mode,
            mpw1_dc_b      => bht_g8t_mpw1_b(0 to 4),
            mpw2_dc_b      => bht_g8t_mpw2_b,
            scan_out       => gptr_sov(3));

perv_lcbcntl_g8t: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_iu_sg_0,
            nclk           => nclk,
            scan_in        => gptr_siv(4),
            scan_diag_dc   => scan_diag_dc,
            thold          => pc_iu_gptr_sl_thold_0,
            clkoff_dc_b    => g8t_clkoff_b,
            delay_lclkr_dc => g8t_delay_lclkr(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => g8t_d_mode,
            mpw1_dc_b      => g8t_mpw1_b(0 to 4),
            mpw2_dc_b      => g8t_mpw2_b,
            scan_out       => gptr_sov(4));

perv_lcbcntl_g6t: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_iu_sg_0,
            nclk           => nclk,
            scan_in        => gptr_siv(5),
            scan_diag_dc   => scan_diag_dc,
            thold          => pc_iu_gptr_sl_thold_0,
            clkoff_dc_b    => g6t_clkoff_b,
            delay_lclkr_dc => int_g6t_delay_lclkr,
            act_dis_dc     => open,
            d_mode_dc      => g6t_d_mode,
            mpw1_dc_b      => g6t_mpw1_b(0 to 4),
            mpw2_dc_b      => g6t_mpw2_b,
            scan_out       => gptr_sov(5));

perv_lcbcntl_cam: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_iu_sg_0,
            nclk           => nclk,
            scan_in        => gptr_siv(6),
            scan_diag_dc   => scan_diag_dc,
            thold          => pc_iu_gptr_sl_thold_0,
            clkoff_dc_b    => cam_clkoff_b,
            delay_lclkr_dc => cam_delay_lclkr(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => cam_d_mode,
            mpw1_dc_b      => cam_mpw1_b(0 to 4),
            mpw2_dc_b      => cam_mpw2_b,
            scan_out       => gptr_sov(6));

g6t_delay_lclkr <= int_g6t_delay_lclkr(0 to 3);
unused <= int_g6t_delay_lclkr(4);

--never disable act pins, they are used functionally
act_dis(0 to 2) <= "000";

-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------

gptr_siv(0 to 6) <= gptr_sov(1 to 6) & gptr_scan_in;
gptr_scan_out <= gptr_sov(0);


end iuq_perv;
