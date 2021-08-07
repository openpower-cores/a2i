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
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_perv is
generic(expand_type : integer := 2 ); 
port(
   vdd                        : inout power_logic;
   gnd                        : inout power_logic;
   nclk                       : in  clk_logic;
   an_ac_scan_dis_dc_b        : in  std_ulogic;
   pc_xu_sg_3                 : in  std_ulogic_vector(0 to 4);
   pc_xu_func_sl_thold_3      : in  std_ulogic_vector(0 to 4);
   pc_xu_func_slp_sl_thold_3  : in  std_ulogic_vector(0 to 4);
   pc_xu_func_nsl_thold_3     : in  std_ulogic;
   pc_xu_func_slp_nsl_thold_3 : in  std_ulogic;
   pc_xu_gptr_sl_thold_3      : in  std_ulogic;
   pc_xu_abst_sl_thold_3      : in  std_ulogic;
   pc_xu_abst_slp_sl_thold_3  : in  std_ulogic;
   pc_xu_regf_sl_thold_3      : in  std_ulogic;
   pc_xu_regf_slp_sl_thold_3  : in  std_ulogic;
   pc_xu_time_sl_thold_3      : in  std_ulogic;
   pc_xu_cfg_sl_thold_3       : in  std_ulogic;
   pc_xu_cfg_slp_sl_thold_3   : in  std_ulogic;
   pc_xu_ary_nsl_thold_3      : in  std_ulogic;
   pc_xu_ary_slp_nsl_thold_3  : in  std_ulogic;
   pc_xu_repr_sl_thold_3      : in  std_ulogic;
   pc_xu_bolt_sl_thold_3      : in  std_ulogic;
   pc_xu_bo_enable_3          : in  std_ulogic;
   pc_xu_fce_3                : in  std_ulogic_vector(0 to 1);
   pc_xu_ccflush_dc           : in  std_ulogic;
   an_ac_scan_diag_dc         : in  std_ulogic;
   sg_2                       : out std_ulogic_vector(0 to 3);
   fce_2                      : out std_ulogic_vector(0 to 1);
   func_sl_thold_2            : out std_ulogic_vector(0 to 3);
   func_slp_sl_thold_2        : out std_ulogic_vector(0 to 1);
   func_nsl_thold_2           : out std_ulogic;
   func_slp_nsl_thold_2       : out std_ulogic;
   abst_sl_thold_2            : out std_ulogic;
   abst_slp_sl_thold_2        : out std_ulogic;
   regf_sl_thold_2            : out std_ulogic;
   regf_slp_sl_thold_2        : out std_ulogic;
   time_sl_thold_2            : out std_ulogic;
   gptr_sl_thold_2            : out std_ulogic;
   ary_nsl_thold_2            : out std_ulogic;
   ary_slp_nsl_thold_2        : out std_ulogic;
   repr_sl_thold_2            : out std_ulogic;
   cfg_sl_thold_2             : out std_ulogic;
   cfg_slp_sl_thold_2         : out std_ulogic;
   bolt_sl_thold_2            : out std_ulogic;
   bo_enable_2                : out std_ulogic;
   sg_0                       : out std_ulogic;
   sg_1                       : out std_ulogic;
   ary_nsl_thold_0            : out std_ulogic;
   abst_sl_thold_0            : out std_ulogic;
   time_sl_thold_0            : out std_ulogic;
   repr_sl_thold_0            : out std_ulogic;
   clkoff_dc_b                : out std_ulogic;
   d_mode_dc                  : out std_ulogic;
   delay_lclkr_dc             : out std_ulogic_vector(0 to 4);
   mpw1_dc_b                  : out std_ulogic_vector(0 to 4);
   mpw2_dc_b                  : out std_ulogic;
   g6t_clkoff_dc_b            : out std_ulogic;
   g6t_d_mode_dc              : out std_ulogic;
   g6t_delay_lclkr_dc         : out std_ulogic_vector(0 to 4);
   g6t_mpw1_dc_b              : out std_ulogic_vector(0 to 4);
   g6t_mpw2_dc_b              : out std_ulogic;
   g8t_clkoff_dc_b            : out std_ulogic;
   g8t_d_mode_dc              : out std_ulogic;
   g8t_delay_lclkr_dc         : out std_ulogic_vector(0 to 4);
   g8t_mpw1_dc_b              : out std_ulogic_vector(0 to 4);
   g8t_mpw2_dc_b              : out std_ulogic;
   cam_clkoff_dc_b            : out std_ulogic;
   cam_d_mode_dc              : out std_ulogic;
   cam_delay_lclkr_dc         : out std_ulogic_vector(0 to 4);
   cam_act_dis_dc             : out std_ulogic;
   cam_mpw1_dc_b              : out std_ulogic_vector(0 to 4);
   cam_mpw2_dc_b              : out std_ulogic;
   gptr_scan_in               : in  std_ulogic;
   gptr_scan_out              : out std_ulogic
);

-- synopsys translate_off
-- synopsys translate_on

end xuq_perv;
architecture xuq_perv of xuq_perv is

signal gptr_sov, gptr_siv              : std_ulogic_vector(0 to 3);
signal perv_sg_2                       : std_ulogic_vector(0 to 3);
signal perv_sg_2_b                     : std_ulogic_vector(0 to 3);
signal gptr_sl_thold_2_int             : std_ulogic;
signal gptr_sl_thold_2_int_b           : std_ulogic;
signal gptr_sl_thold_1, sg_1_int       : std_ulogic;
signal gptr_sl_thold_0, sg_0_int       : std_ulogic;
signal time_sl_thold_0_int             : std_ulogic;
signal ary_nsl_thold_2_int             : std_ulogic;
signal ary_nsl_thold_2_int_b           : std_ulogic;
signal ary_slp_nsl_thold_2_int         : std_ulogic;
signal abst_sl_thold_2_int             : std_ulogic;
signal abst_sl_thold_2_int_b           : std_ulogic;
signal abst_slp_sl_thold_2_int         : std_ulogic;
signal regf_sl_thold_2_int             : std_ulogic;
signal regf_slp_sl_thold_2_int         : std_ulogic;
signal func_slp_nsl_thold_2_int        : std_ulogic;
signal time_sl_thold_2_int             : std_ulogic;
signal time_sl_thold_2_int_b           : std_ulogic;
signal repr_sl_thold_2_int             : std_ulogic;
signal repr_sl_thold_2_int_b           : std_ulogic;
signal ary_nsl_thold_1                 : std_ulogic;
signal abst_sl_thold_1                 : std_ulogic;
signal time_sl_thold_1                 : std_ulogic;
signal repr_sl_thold_1                 : std_ulogic;
signal func_sl_thold_2_int             : std_ulogic_vector(0 to 3);
signal bolt_sl_thold_2_int             : std_ulogic;
signal bo_enable_2_int                 : std_ulogic;
signal fce_2_int                       : std_ulogic_vector(0 to 1);
signal func_slp_sl_thold_2_int         : std_ulogic_vector(0 to 1);
signal cfg_sl_thold_2_int              : std_ulogic;
signal cfg_slp_sl_thold_2_int          : std_ulogic;
signal func_nsl_thold_2_int            : std_ulogic;
signal clkoff_dc_b_int                 : std_ulogic;
signal d_mode_dc_int                   : std_ulogic;
signal delay_lclkr_dc_int              : std_ulogic_vector(0 to 4);
signal mpw1_dc_b_int                   : std_ulogic_vector(0 to 4);
signal mpw2_dc_b_int                   : std_ulogic;
signal g6t_clkoff_dc_b_int             : std_ulogic;
signal g6t_d_mode_dc_int               : std_ulogic;
signal g6t_delay_lclkr_dc_int          : std_ulogic_vector(0 to 4);
signal g6t_mpw1_dc_b_int               : std_ulogic_vector(0 to 4);
signal g6t_mpw2_dc_b_int               : std_ulogic;
signal g8t_clkoff_dc_b_int             : std_ulogic;
signal g8t_d_mode_dc_int               : std_ulogic;
signal g8t_delay_lclkr_dc_int          : std_ulogic_vector(0 to 4);
signal g8t_mpw1_dc_b_int               : std_ulogic_vector(0 to 4);
signal g8t_mpw2_dc_b_int               : std_ulogic;
signal cam_clkoff_dc_b_int            : std_ulogic;
signal cam_d_mode_dc_int              : std_ulogic;
signal cam_delay_lclkr_dc_int         : std_ulogic_vector(0 to 4);
signal cam_mpw1_dc_b_int              : std_ulogic_vector(0 to 4);
signal cam_mpw2_dc_b_int              : std_ulogic;

begin

perv_3to2_reg: tri_plat
  generic map (width => 27, expand_type => expand_type)
port map (vd             => vdd,
            gd             => gnd,
            nclk           => nclk,
            flush          => pc_xu_ccflush_dc,
            din(0 to 3)    => pc_xu_func_sl_thold_3(0 to 3),
            din(4 to 5)    => pc_xu_func_slp_sl_thold_3(0 to 1),
            din(6)         => pc_xu_gptr_sl_thold_3,
            din(7 to 10)   => pc_xu_sg_3(0 to 3),
            din(11 to 12)  => pc_xu_fce_3(0 to 1),
            din(13)        => pc_xu_func_nsl_thold_3,
            din(14)        => pc_xu_abst_sl_thold_3,
            din(15)        => pc_xu_abst_slp_sl_thold_3,
            din(16)        => pc_xu_time_sl_thold_3,
            din(17)        => pc_xu_ary_nsl_thold_3,
            din(18)        => pc_xu_ary_slp_nsl_thold_3,
            din(19)        => pc_xu_cfg_sl_thold_3,
            din(20)        => pc_xu_cfg_slp_sl_thold_3,
            din(21)        => pc_xu_repr_sl_thold_3,
            din(22)        => pc_xu_regf_sl_thold_3,
            din(23)        => pc_xu_regf_slp_sl_thold_3,
            din(24)        => pc_xu_func_slp_nsl_thold_3,
            din(25)        => pc_xu_bolt_sl_thold_3,
            din(26)        => pc_xu_bo_enable_3,
            q(0 to 3)      => func_sl_thold_2_int(0 to 3),
            q(4 to 5)      => func_slp_sl_thold_2_int(0 to 1),
            q(6)           => gptr_sl_thold_2_int,
            q(7 to 10)     => perv_sg_2(0 to 3),
            q(11 to 12)    => fce_2_int(0 to 1),
            q(13)          => func_nsl_thold_2_int,
            q(14)          => abst_sl_thold_2_int,
            q(15)          => abst_slp_sl_thold_2_int,
            q(16)          => time_sl_thold_2_int,
            q(17)          => ary_nsl_thold_2_int,
            q(18)          => ary_slp_nsl_thold_2_int,
            q(19)          => cfg_sl_thold_2_int,
            q(20)          => cfg_slp_sl_thold_2_int,
            q(21)          => repr_sl_thold_2_int,
            q(22)          => regf_sl_thold_2_int,  
            q(23)          => regf_slp_sl_thold_2_int,
            q(24)          => func_slp_nsl_thold_2_int,
            q(25)          => bolt_sl_thold_2_int,
            q(26)          => bo_enable_2_int);

sg_2     <= perv_sg_2;
perv_sg_2_b     <= perv_sg_2;
sg_1     <= sg_1_int;
sg_0     <= sg_0_int;

ary_nsl_thold_2      <= ary_nsl_thold_2_int;
ary_nsl_thold_2_int_b<= ary_nsl_thold_2_int;
ary_slp_nsl_thold_2  <= ary_slp_nsl_thold_2_int;
abst_sl_thold_2      <= abst_sl_thold_2_int;
abst_sl_thold_2_int_b      <= abst_sl_thold_2_int;
abst_slp_sl_thold_2  <= abst_slp_sl_thold_2_int;
regf_sl_thold_2      <= regf_sl_thold_2_int;
regf_slp_sl_thold_2  <= regf_slp_sl_thold_2_int;
time_sl_thold_2      <= time_sl_thold_2_int;
time_sl_thold_2_int_b      <= time_sl_thold_2_int;
repr_sl_thold_2      <= repr_sl_thold_2_int;
repr_sl_thold_2_int_b      <= repr_sl_thold_2_int;
func_sl_thold_2      <= func_sl_thold_2_int;
bolt_sl_thold_2      <= bolt_sl_thold_2_int;
bo_enable_2          <= bo_enable_2_int;
fce_2                <= fce_2_int;
func_slp_sl_thold_2  <= func_slp_sl_thold_2_int;
cfg_sl_thold_2       <= cfg_sl_thold_2_int;
cfg_slp_sl_thold_2   <= cfg_slp_sl_thold_2_int;
func_nsl_thold_2     <= func_nsl_thold_2_int;
func_slp_nsl_thold_2 <= func_slp_nsl_thold_2_int;
clkoff_dc_b          <= clkoff_dc_b_int;
d_mode_dc            <= d_mode_dc_int;
delay_lclkr_dc       <= delay_lclkr_dc_int;
mpw1_dc_b            <= mpw1_dc_b_int;
mpw2_dc_b            <= mpw2_dc_b_int;
time_sl_thold_0      <= time_sl_thold_0_int;

g6t_clkoff_dc_b    <= g6t_clkoff_dc_b_int;
g6t_d_mode_dc      <= g6t_d_mode_dc_int;
g6t_delay_lclkr_dc <= g6t_delay_lclkr_dc_int;
g6t_mpw1_dc_b      <= g6t_mpw1_dc_b_int;
g6t_mpw2_dc_b      <= g6t_mpw2_dc_b_int;

g8t_clkoff_dc_b    <= g8t_clkoff_dc_b_int;
g8t_d_mode_dc      <= g8t_d_mode_dc_int;
g8t_delay_lclkr_dc <= g8t_delay_lclkr_dc_int;
g8t_mpw1_dc_b      <= g8t_mpw1_dc_b_int;
g8t_mpw2_dc_b      <= g8t_mpw2_dc_b_int;

cam_clkoff_dc_b    <= cam_clkoff_dc_b_int;
cam_delay_lclkr_dc <= cam_delay_lclkr_dc_int;
cam_act_dis_dc     <= '0';
cam_d_mode_dc      <= cam_d_mode_dc_int;
cam_mpw1_dc_b      <= cam_mpw1_dc_b_int;
cam_mpw2_dc_b      <= cam_mpw2_dc_b_int;

gptr_sl_thold_2    <= gptr_sl_thold_2_int;
gptr_sl_thold_2_int_b    <= gptr_sl_thold_2_int;

perv_2to1_reg: tri_plat
  generic map (width => 6, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => gptr_sl_thold_2_int_b,
            din(1)      => perv_sg_2_b(0),
            din(2)      => ary_nsl_thold_2_int_b,
            din(3)      => abst_sl_thold_2_int_b,
            din(4)      => time_sl_thold_2_int_b,
            din(5)      => repr_sl_thold_2_int_b,
            q(0)        => gptr_sl_thold_1,
            q(1)        => sg_1_int,
            q(2)        => ary_nsl_thold_1,
            q(3)        => abst_sl_thold_1,
            q(4)        => time_sl_thold_1,
            q(5)        => repr_sl_thold_1);

perv_1to0_reg: tri_plat
  generic map (width => 6, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => gptr_sl_thold_1,
            din(1)      => sg_1_int,
            din(2)      => ary_nsl_thold_1,
            din(3)      => abst_sl_thold_1,
            din(4)      => time_sl_thold_1,
            din(5)      => repr_sl_thold_1,
            q(0)        => gptr_sl_thold_0,
            q(1)        => sg_0_int,
            q(2)        => ary_nsl_thold_0,
            q(3)        => abst_sl_thold_0,
            q(4)        => time_sl_thold_0_int,
            q(5)        => repr_sl_thold_0);

perv_lcbctrl_0: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0_int,
            nclk           => nclk,
            scan_in        => gptr_siv(3),
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => clkoff_dc_b_int,
            delay_lclkr_dc => delay_lclkr_dc_int(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => d_mode_dc_int,
            mpw1_dc_b      => mpw1_dc_b_int(0 to 4),
            mpw2_dc_b      => mpw2_dc_b_int,
            scan_out       => gptr_sov(3));

perv_lcbctrl_g6t_0: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0_int,
            nclk           => nclk,
            scan_in        => gptr_siv(0),
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => g6t_clkoff_dc_b_int,
            delay_lclkr_dc => g6t_delay_lclkr_dc_int(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => g6t_d_mode_dc_int,
            mpw1_dc_b      => g6t_mpw1_dc_b_int(0 to 4),
            mpw2_dc_b      => g6t_mpw2_dc_b_int,
            scan_out       => gptr_sov(0));

perv_lcbctrl_g8t_0: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0_int,
            nclk           => nclk,
            scan_in        => gptr_siv(1),
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => g8t_clkoff_dc_b_int,
            delay_lclkr_dc => g8t_delay_lclkr_dc_int(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => g8t_d_mode_dc_int,
            mpw1_dc_b      => g8t_mpw1_dc_b_int(0 to 4),
            mpw2_dc_b      => g8t_mpw2_dc_b_int,
            scan_out       => gptr_sov(1));

perv_lcbctrl_cam_0: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0_int,
            nclk           => nclk,
            scan_in        => gptr_siv(2),
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => cam_clkoff_dc_b_int,
            delay_lclkr_dc => cam_delay_lclkr_dc_int(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => cam_d_mode_dc_int,
            mpw1_dc_b      => cam_mpw1_dc_b_int(0 to 4),
            mpw2_dc_b      => cam_mpw2_dc_b_int,
            scan_out       => gptr_sov(2));

gptr_siv(0 to gptr_siv'right)  <= gptr_sov(1 to gptr_siv'right) & gptr_scan_in;
gptr_scan_out  <= gptr_sov(0) and an_ac_scan_dis_dc_b;

mark_unused(pc_xu_func_sl_thold_3(4));         
mark_unused(pc_xu_func_slp_sl_thold_3(2 to 4));
mark_unused(pc_xu_sg_3(4));                  

end xuq_perv;
