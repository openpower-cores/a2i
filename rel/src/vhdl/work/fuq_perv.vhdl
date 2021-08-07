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

entity fuq_perv is
generic(expand_type : integer := 2 ); -- 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     pc_fu_sg_3                 : in  std_ulogic_vector(0 to 1);
     pc_fu_abst_sl_thold_3      : in  std_ulogic;
     pc_fu_func_sl_thold_3      : in  std_ulogic_vector(0 to 1);
     pc_fu_func_slp_sl_thold_3  : in  std_ulogic_vector(0 to 1);
     pc_fu_gptr_sl_thold_3      : in  std_ulogic;
     pc_fu_time_sl_thold_3      : in  std_ulogic;
     pc_fu_ary_nsl_thold_3      : in  std_ulogic;
     pc_fu_cfg_sl_thold_3       : in  std_ulogic;
     pc_fu_repr_sl_thold_3      : in  std_ulogic;
     pc_fu_fce_3                : in  std_ulogic;
     tc_ac_ccflush_dc           : in  std_ulogic;
     tc_ac_scan_diag_dc         : in  std_ulogic;
     abst_sl_thold_1            : out std_ulogic;
     func_sl_thold_1            : out std_ulogic_vector(0 to 1);
     time_sl_thold_1            : out std_ulogic;
     ary_nsl_thold_1            : out std_ulogic;
     gptr_sl_thold_0            : out std_ulogic;
     cfg_sl_thold_1             : out std_ulogic;
     func_slp_sl_thold_1        : out std_ulogic;

     fce_1                      : out std_ulogic;
     sg_1                       : out std_ulogic_vector(0 to 1);
     clkoff_dc_b                : out std_ulogic;
     act_dis                    : out std_ulogic;
     delay_lclkr_dc             : out std_ulogic_vector(0 to 9);
     mpw1_dc_b                  : out std_ulogic_vector(0 to 9);
     mpw2_dc_b                  : out std_ulogic_vector(0 to 1);
     repr_scan_in               : in  std_ulogic;                 --tc_ac_repr_scan_in(2)
     repr_scan_out              : out std_ulogic;                 --tc_ac_repr_scan_in(2)
     gptr_scan_in               : in  std_ulogic;
     gptr_scan_out              : out std_ulogic
);

-- synopsys translate_off


-- synopsys translate_on

end fuq_perv;
architecture fuq_perv of fuq_perv is


signal abst_sl_thold_2                  : std_ulogic;
signal time_sl_thold_2                  : std_ulogic;
signal func_sl_thold_2                  : std_ulogic_vector(0 to 1);
signal gptr_sl_thold_2                  : std_ulogic;
signal ary_nsl_thold_2                  : std_ulogic;
signal cfg_sl_thold_2                   : std_ulogic;
signal repr_sl_thold_2                  : std_ulogic;
signal func_slp_sl_thold_2              : std_ulogic;

signal sg_2                             : std_ulogic_vector(0 to 1);
signal fce_2                            : std_ulogic;

signal gptr_sl_thold_1                  : std_ulogic;
signal repr_sl_thold_1                  : std_ulogic;
signal sg_1_int                         : std_ulogic_vector(0 to 1);

signal gptr_sl_thold_0_int              : std_ulogic;
signal repr_sl_thold_0                  : std_ulogic;
signal repr_sl_force                    : std_ulogic;
signal repr_sl_thold_0_b                : std_ulogic;
signal repr_in                          : std_ulogic;
signal repr_UNUSED                      : std_ulogic;

signal    spare_unused                    :  std_ulogic;

signal sg_0                             : std_ulogic;
signal gptr_sio                         : std_ulogic;
signal    prv_delay_lclkr_dc             : std_ulogic_vector(0 to 9);
signal    prv_mpw1_dc_b                  : std_ulogic_vector(0 to 9);
signal    prv_mpw2_dc_b                  : std_ulogic_vector(0 to 1);
signal    prv_act_dis                    : std_ulogic;
signal    prv_clkoff_dc_b                : std_ulogic;
signal  tihi : std_ulogic;

begin

tihi <= '1';

perv_3to2_reg: tri_plat
  generic map (width => 12, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,

            din(0 to 1) => pc_fu_func_sl_thold_3(0 to 1),
            din(2)      => pc_fu_gptr_sl_thold_3,
            din(3)      => pc_fu_abst_sl_thold_3,
            din(4 to 5) => pc_fu_sg_3(0 to 1),
            din(6)      => pc_fu_time_sl_thold_3,
            din(7)      => pc_fu_fce_3,
            din(8)      => pc_fu_ary_nsl_thold_3,
            din(9)      => pc_fu_cfg_sl_thold_3,
            din(10)     => pc_fu_repr_sl_thold_3,
            din(11)     => pc_fu_func_slp_sl_thold_3(0),

            q(0 to 1)   => func_sl_thold_2(0 to 1),
            q(2)        => gptr_sl_thold_2,
            q(3)        => abst_sl_thold_2,
            q(4 to 5)   => sg_2(0 to 1),
            q(6)        => time_sl_thold_2,
            q(7)        => fce_2,
            q(8)        => ary_nsl_thold_2,
            q(9)        => cfg_sl_thold_2,
            q(10)       => repr_sl_thold_2,
            q(11)       => func_slp_sl_thold_2 );


perv_2to1_reg: tri_plat
  generic map (width => 12, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,

            din(0 to 1) => func_sl_thold_2(0 to 1),
            din(2)      => gptr_sl_thold_2,
            din(3)      => abst_sl_thold_2,
            din(4 to 5) => sg_2(0 to 1),
            din(6)      => time_sl_thold_2,
            din(7)      => fce_2,
            din(8)      => ary_nsl_thold_2,
            din(9)      => cfg_sl_thold_2,
            din(10)     => repr_sl_thold_2,
            din(11)     => func_slp_sl_thold_2,

            q(0 to 1)   => func_sl_thold_1(0 to 1),
            q(2)        => gptr_sl_thold_1,
            q(3)        => abst_sl_thold_1,
            q(4 to 5)   => sg_1_int(0 to 1),
            q(6)        => time_sl_thold_1,
            q(7)        => fce_1,
            q(8)        => ary_nsl_thold_1,
            q(9)        => cfg_sl_thold_1,
            q(10)       => repr_sl_thold_1,
            q(11)       => func_slp_sl_thold_1  );

sg_1(0 to 1) <= sg_1_int(0 to 1);

perv_1to0_reg: tri_plat
  generic map (width => 3, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => gptr_sl_thold_1,
            din(1)      => sg_1_int(0),
            din(2)      => repr_sl_thold_1,

            q(0)        => gptr_sl_thold_0_int,
            q(1)        => sg_0,
            q(2)        => repr_sl_thold_0  );

  gptr_sl_thold_0 <= gptr_sl_thold_0_int;

-- Pipeline mapping of mpw1_b and delay_lclkr, mpw2_b
-- RF0  8       1
-- RF1  0       0
-- EX1  1       0
-- EX2  2       0
-- EX3  3       0
-- EX4  4       0
-- EX5  5       1
-- EX6  6       1
-- EX7  7       1
-- Ctrl 9       1
perv_lcbctrl0: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0,
            nclk           => nclk,
            scan_in        => gptr_scan_in,
            scan_diag_dc   => tc_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0_int,
            clkoff_dc_b    => prv_clkoff_dc_b,
            delay_lclkr_dc => prv_delay_lclkr_dc(0 to 4),
            act_dis_dc     => open,
            mpw1_dc_b      => prv_mpw1_dc_b(0 to 4),
            mpw2_dc_b      => prv_mpw2_dc_b(0),
            scan_out       => gptr_sio);

perv_lcbctrl1: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0,
            nclk           => nclk,
            scan_in        => gptr_sio,
            scan_diag_dc   => tc_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0_int,
            clkoff_dc_b    => open,
            delay_lclkr_dc => prv_delay_lclkr_dc(5 to 9),
            act_dis_dc     => open,
            mpw1_dc_b      => prv_mpw1_dc_b(5 to 9),
            mpw2_dc_b      => prv_mpw2_dc_b(1),
            scan_out       => gptr_scan_out);

--Outputs
   delay_lclkr_dc(0 to 9) <= prv_delay_lclkr_dc(0 to 9);
   mpw1_dc_b(0 to 9)      <= prv_mpw1_dc_b(0 to 9);
   mpw2_dc_b(0 to 1)      <= prv_mpw2_dc_b(0 to 1);

--never disable act pins, they are used functionally
  prv_act_dis <= '0';
  act_dis     <= prv_act_dis;
  clkoff_dc_b <= prv_clkoff_dc_b;

-- Repower latch for repr scan ins/outs
    repr_sl_lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => prv_clkoff_dc_b,
        thold        => repr_sl_thold_0,  
        sg           => sg_0,
        act_dis      => prv_act_dis,
        forcee => repr_sl_force,
        thold_b      => repr_sl_thold_0_b );

   repr_in <= '0';
   repr_rpwr_lat: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 1)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => repr_sl_force,
             delay_lclkr => prv_delay_lclkr_dc(9),
             mpw1_b      => prv_mpw1_dc_b(9),
             mpw2_b      => prv_mpw2_dc_b(1),
             thold_b  => repr_sl_thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin(0)  => repr_scan_in,
             scout(0) => repr_scan_out,
            ---------------------------------------------
             din(0)  => repr_in,
            ---------------------------------------------
             dout(0) => repr_UNUSED
            ---------------------------------------------
             );

-- Unused logic
   spare_unused <= pc_fu_func_slp_sl_thold_3(1);

end fuq_perv;
