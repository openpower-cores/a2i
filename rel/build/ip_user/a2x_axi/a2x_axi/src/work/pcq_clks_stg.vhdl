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
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_clks_stg is
generic(expand_type             : integer := 2          
);         
port(
    vdd                         : inout power_logic;
    gnd                         : inout power_logic;
    nclk                        : in    clk_logic;
    pc_pc_ccflush_out_dc        : in    std_ulogic;
    pc_pc_gptr_sl_thold_4       : in    std_ulogic;
    pc_pc_time_sl_thold_4       : in    std_ulogic;
    pc_pc_repr_sl_thold_4       : in    std_ulogic;
    pc_pc_cfg_sl_thold_4        : in    std_ulogic;
    pc_pc_cfg_slp_sl_thold_4    : in    std_ulogic;
    pc_pc_abst_sl_thold_4       : in    std_ulogic;
    pc_pc_abst_slp_sl_thold_4   : in    std_ulogic;
    pc_pc_regf_sl_thold_4       : in    std_ulogic;
    pc_pc_regf_slp_sl_thold_4   : in    std_ulogic;
    pc_pc_func_sl_thold_4       : in    std_ulogic_vector(0 to 1);
    pc_pc_func_slp_sl_thold_4   : in    std_ulogic_vector(0 to 1);
    pc_pc_func_nsl_thold_4      : in    std_ulogic;
    pc_pc_func_slp_nsl_thold_4  : in    std_ulogic;
    pc_pc_ary_nsl_thold_4       : in    std_ulogic;
    pc_pc_ary_slp_nsl_thold_4   : in    std_ulogic;
    pc_pc_rtim_sl_thold_4       : in    std_ulogic;
    pc_pc_sg_4                  : in    std_ulogic_vector(0 to 1);
    pc_pc_fce_4                 : in    std_ulogic_vector(0 to 1);
    bolton_enable               : in    std_ulogic;
    bolton_fcshdata             : in    std_ulogic;
    bolton_fcreset              : in    std_ulogic;
    bo_pc_abst_sl_thold_4       : in    std_ulogic;
    bo_pc_pc_abst_sl_thold_4    : in    std_ulogic;
    bo_pc_bolt_sl_thold_4       : in    std_ulogic;
    bo_pc_ary_nsl_thold_4       : in    std_ulogic;
    bo_pc_func_sl_thold_4       : in    std_ulogic;
    bo_pc_time_sl_thold_4       : in    std_ulogic;
    bo_pc_repr_sl_thold_4       : in    std_ulogic;
    bo_pc_sg_4                  : in    std_ulogic;
    pc_xu_ccflush_dc            : out   std_ulogic;
    pc_xu_gptr_sl_thold_3       : out   std_ulogic;
    pc_xu_time_sl_thold_3       : out   std_ulogic;
    pc_xu_repr_sl_thold_3       : out   std_ulogic;
    pc_xu_abst_sl_thold_3       : out   std_ulogic;
    pc_xu_abst_slp_sl_thold_3   : out   std_ulogic;
    pc_xu_bolt_sl_thold_3       : out   std_ulogic;
    pc_xu_regf_sl_thold_3       : out   std_ulogic;
    pc_xu_regf_slp_sl_thold_3   : out   std_ulogic;
    pc_xu_func_sl_thold_3       : out   std_ulogic_vector(0 to 4);
    pc_xu_func_slp_sl_thold_3   : out   std_ulogic_vector(0 to 4);
    pc_xu_cfg_sl_thold_3        : out   std_ulogic;
    pc_xu_cfg_slp_sl_thold_3    : out   std_ulogic;
    pc_xu_func_nsl_thold_3      : out   std_ulogic;
    pc_xu_func_slp_nsl_thold_3  : out   std_ulogic;
    pc_xu_ary_nsl_thold_3       : out   std_ulogic;
    pc_xu_ary_slp_nsl_thold_3   : out   std_ulogic;
    pc_xu_sg_3                  : out   std_ulogic_vector(0 to 4);
    pc_xu_fce_3                 : out   std_ulogic_vector(0 to 1);
    pc_bx_ccflush_dc            : out   std_ulogic;
    pc_bx_func_sl_thold_3       : out   std_ulogic;
    pc_bx_func_slp_sl_thold_3   : out   std_ulogic;
    pc_bx_gptr_sl_thold_3       : out   std_ulogic;
    pc_bx_time_sl_thold_3       : out   std_ulogic;
    pc_bx_repr_sl_thold_3       : out   std_ulogic;
    pc_bx_abst_sl_thold_3       : out   std_ulogic;
    pc_bx_bolt_sl_thold_3       : out   std_ulogic;
    pc_bx_ary_nsl_thold_3       : out   std_ulogic;
    pc_bx_ary_slp_nsl_thold_3   : out   std_ulogic;
    pc_bx_sg_3                  : out   std_ulogic;
    pc_mm_ccflush_dc            : out   std_ulogic;
    pc_iu_ccflush_dc            : out   std_ulogic;
    pc_iu_gptr_sl_thold_4       : out   std_ulogic;
    pc_iu_time_sl_thold_4       : out   std_ulogic;
    pc_iu_repr_sl_thold_4       : out   std_ulogic;
    pc_iu_abst_sl_thold_4       : out   std_ulogic;
    pc_iu_abst_slp_sl_thold_4   : out   std_ulogic;
    pc_iu_bolt_sl_thold_4       : out   std_ulogic;
    pc_iu_regf_slp_sl_thold_4   : out   std_ulogic;
    pc_iu_func_sl_thold_4       : out   std_ulogic;
    pc_iu_func_slp_sl_thold_4   : out   std_ulogic;
    pc_iu_cfg_sl_thold_4        : out   std_ulogic;
    pc_iu_cfg_slp_sl_thold_4    : out   std_ulogic;
    pc_iu_func_nsl_thold_4      : out   std_ulogic;
    pc_iu_func_slp_nsl_thold_4  : out   std_ulogic;
    pc_iu_ary_nsl_thold_4       : out   std_ulogic;
    pc_iu_ary_slp_nsl_thold_4   : out   std_ulogic;
    pc_iu_sg_4                  : out   std_ulogic;
    pc_iu_fce_4                 : out   std_ulogic;
    pc_fu_ccflush_dc            : out   std_ulogic;
    pc_fu_gptr_sl_thold_3       : out   std_ulogic;
    pc_fu_time_sl_thold_3       : out   std_ulogic;
    pc_fu_repr_sl_thold_3       : out   std_ulogic;
    pc_fu_abst_sl_thold_3       : out   std_ulogic;
    pc_fu_abst_slp_sl_thold_3   : out   std_ulogic;
    pc_fu_bolt_sl_thold_3       : out   std_ulogic;
    pc_fu_func_sl_thold_3       : out   std_ulogic_vector(0 to 1);
    pc_fu_func_slp_sl_thold_3   : out   std_ulogic_vector(0 to 1);
    pc_fu_cfg_sl_thold_3        : out   std_ulogic;
    pc_fu_cfg_slp_sl_thold_3    : out   std_ulogic;
    pc_fu_func_nsl_thold_3      : out   std_ulogic;
    pc_fu_func_slp_nsl_thold_3  : out   std_ulogic;
    pc_fu_ary_nsl_thold_3       : out   std_ulogic;
    pc_fu_ary_slp_nsl_thold_3   : out   std_ulogic;
    pc_fu_sg_3                  : out   std_ulogic_vector(0 to 1);
    pc_fu_fce_3                 : out   std_ulogic;
    pc_pc_ccflush_dc            : out   std_ulogic;
    pc_pc_gptr_sl_thold_0       : out   std_ulogic;
    pc_pc_abst_sl_thold_0       : out   std_ulogic;
    pc_pc_bolt_sl_thold_0       : out   std_ulogic;
    pc_pc_func_sl_thold_0       : out   std_ulogic;
    pc_pc_func_slp_sl_thold_0   : out   std_ulogic;
    pc_pc_cfg_sl_thold_0        : out   std_ulogic;
    pc_pc_cfg_slp_sl_thold_0    : out   std_ulogic;
    pc_pc_sg_0                  : out   std_ulogic
);


-- synopsys translate_off

-- synopsys translate_on
end pcq_clks_stg;

architecture pcq_clks_stg of pcq_clks_stg is
signal pc_pc_gptr_sl_thold_3            : std_ulogic;
signal pc_pc_abst_sl_thold_3            : std_ulogic;
signal pc_pc_bolt_sl_thold_3            : std_ulogic;
signal pc_pc_func_sl_thold_3            : std_ulogic;
signal pc_pc_func_slp_sl_thold_3        : std_ulogic;
signal pc_pc_cfg_slp_sl_thold_3         : std_ulogic;
signal pc_pc_cfg_sl_thold_3             : std_ulogic;
signal pc_pc_sg_3                       : std_ulogic;
signal pc_pc_gptr_sl_thold_2            : std_ulogic;
signal pc_pc_abst_sl_thold_2            : std_ulogic;
signal pc_pc_bolt_sl_thold_2            : std_ulogic;
signal pc_pc_func_sl_thold_2            : std_ulogic;
signal pc_pc_func_slp_sl_thold_2        : std_ulogic;
signal pc_pc_cfg_slp_sl_thold_2         : std_ulogic;
signal pc_pc_cfg_sl_thold_2             : std_ulogic;
signal pc_pc_sg_2                       : std_ulogic;
signal pc_pc_gptr_sl_thold_1            : std_ulogic;
signal pc_pc_abst_sl_thold_1            : std_ulogic;
signal pc_pc_bolt_sl_thold_1            : std_ulogic;
signal pc_pc_func_sl_thold_1            : std_ulogic;
signal pc_pc_func_slp_sl_thold_1        : std_ulogic;
signal pc_pc_cfg_slp_sl_thold_1         : std_ulogic;
signal pc_pc_cfg_sl_thold_1             : std_ulogic;
signal pc_pc_sg_1                       : std_ulogic;
signal pc_pc_sg_4_int                   : std_ulogic_vector(0 to 1);
signal pc_pc_time_sl_thold_4_int        : std_ulogic;
signal pc_pc_repr_sl_thold_4_int        : std_ulogic;
signal bo_pc_abst_sl_thold_4_int        : std_ulogic;
signal pc_pc_abst_sl_thold_4_int        : std_ulogic;
signal pc_pc_abst_slp_sl_thold_4_int    : std_ulogic;
signal pc_pc_regf_sl_thold_4_int        : std_ulogic;
signal pc_pc_regf_slp_sl_thold_4_int    : std_ulogic;
signal pc_pc_ary_nsl_thold_4_int        : std_ulogic;
signal pc_pc_ary_slp_nsl_thold_4_int    : std_ulogic;
signal pc_pc_func_sl_thold_4_int        : std_ulogic_vector(0 to 1);
signal pc_pc_bolt_sl_thold_4_int        : std_ulogic;
signal pc_pc_func_slp_sl_thold_4_int    : std_ulogic_vector(0 to 1);
signal pc_pc_func_nsl_thold_4_int       : std_ulogic;
signal pc_pc_func_slp_nsl_thold_4_int   : std_ulogic;
signal unused_signals                   : std_ulogic;


begin

   unused_signals  <= pc_pc_rtim_sl_thold_4;


   pc_xu_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_bx_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_iu_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_fu_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_mm_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_pc_ccflush_dc <= pc_pc_ccflush_out_dc;


pc_pc_sg_4_int(0)              <= bo_pc_sg_4 or bolton_fcshdata when bolton_enable='1' else pc_pc_sg_4(0);
pc_pc_sg_4_int(1)              <= bo_pc_sg_4 or bolton_fcshdata when bolton_enable='1' else pc_pc_sg_4(1);

pc_pc_func_sl_thold_4_int(0)     <= bo_pc_func_sl_thold_4 when bolton_enable='1' else pc_pc_func_sl_thold_4(0);
pc_pc_func_sl_thold_4_int(1)     <= bo_pc_func_sl_thold_4 when bolton_enable='1' else pc_pc_func_sl_thold_4(1);
pc_pc_func_slp_sl_thold_4_int(0) <= bo_pc_func_sl_thold_4 when bolton_enable='1' else pc_pc_func_slp_sl_thold_4(0);
pc_pc_func_slp_sl_thold_4_int(1) <= bo_pc_func_sl_thold_4 when bolton_enable='1' else pc_pc_func_slp_sl_thold_4(1);

pc_pc_func_nsl_thold_4_int     <= bo_pc_func_sl_thold_4 when bolton_enable='1' else pc_pc_func_nsl_thold_4;
pc_pc_func_slp_nsl_thold_4_int <= bo_pc_func_sl_thold_4 when bolton_enable='1' else pc_pc_func_slp_nsl_thold_4;

pc_pc_time_sl_thold_4_int      <= bo_pc_time_sl_thold_4 when bolton_enable='1' else pc_pc_time_sl_thold_4;

pc_pc_repr_sl_thold_4_int <= bo_pc_bolt_sl_thold_4 when (bolton_fcshdata or bolton_fcreset)='1' and bolton_enable='1' else
                             bo_pc_repr_sl_thold_4 when bolton_enable='1' else
                             pc_pc_repr_sl_thold_4;

pc_pc_abst_sl_thold_4_int      <= bo_pc_abst_sl_thold_4 when bolton_enable='1' else pc_pc_abst_sl_thold_4;
bo_pc_abst_sl_thold_4_int      <= bo_pc_pc_abst_sl_thold_4 when bolton_enable='1' else pc_pc_abst_sl_thold_4;
pc_pc_abst_slp_sl_thold_4_int  <= bo_pc_abst_sl_thold_4 when bolton_enable='1' else pc_pc_abst_slp_sl_thold_4;

pc_pc_regf_sl_thold_4_int      <= pc_pc_regf_sl_thold_4;
pc_pc_regf_slp_sl_thold_4_int  <= pc_pc_regf_slp_sl_thold_4;

pc_pc_ary_nsl_thold_4_int      <= bo_pc_ary_nsl_thold_4 when bolton_enable='1' else pc_pc_ary_nsl_thold_4;
pc_pc_ary_slp_nsl_thold_4_int  <= bo_pc_ary_nsl_thold_4 when bolton_enable='1' else pc_pc_ary_slp_nsl_thold_4;

pc_pc_bolt_sl_thold_4_int      <= bo_pc_bolt_sl_thold_4 when bolton_enable='1' else pc_pc_abst_sl_thold_4;


pc_iu_gptr_sl_thold_4       <= pc_pc_gptr_sl_thold_4;
pc_iu_time_sl_thold_4       <= pc_pc_time_sl_thold_4_int;
pc_iu_repr_sl_thold_4       <= pc_pc_repr_sl_thold_4_int;
pc_iu_abst_sl_thold_4       <= pc_pc_abst_sl_thold_4_int;
pc_iu_abst_slp_sl_thold_4   <= pc_pc_abst_slp_sl_thold_4_int;
pc_iu_bolt_sl_thold_4       <= pc_pc_bolt_sl_thold_4_int;
pc_iu_regf_slp_sl_thold_4   <= pc_pc_regf_slp_sl_thold_4_int;
pc_iu_func_sl_thold_4       <= pc_pc_func_sl_thold_4_int(1);
pc_iu_func_slp_sl_thold_4   <= pc_pc_func_slp_sl_thold_4_int(1);
pc_iu_cfg_sl_thold_4        <= pc_pc_cfg_sl_thold_4;
pc_iu_cfg_slp_sl_thold_4    <= pc_pc_cfg_slp_sl_thold_4;
pc_iu_func_nsl_thold_4      <= pc_pc_func_nsl_thold_4_int;
pc_iu_func_slp_nsl_thold_4  <= pc_pc_func_slp_nsl_thold_4_int;
pc_iu_ary_nsl_thold_4       <= pc_pc_ary_nsl_thold_4_int;
pc_iu_ary_slp_nsl_thold_4   <= pc_pc_ary_slp_nsl_thold_4_int;
pc_iu_sg_4                  <= pc_pc_sg_4_int(1);
pc_iu_fce_4                 <= pc_pc_fce_4(1);


xu_func_stg4to3: tri_plat   
   generic map( width => 14, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_func_sl_thold_4_int(0),
             din( 1) => pc_pc_func_sl_thold_4_int(0),
             din( 2) => pc_pc_func_sl_thold_4_int(0),
             din( 3) => pc_pc_func_sl_thold_4_int(0),
             din( 4) => pc_pc_func_sl_thold_4_int(0),
             din( 5) => pc_pc_func_slp_sl_thold_4_int(0),
             din( 6) => pc_pc_func_slp_sl_thold_4_int(0),
             din( 7) => pc_pc_func_slp_sl_thold_4_int(0),
             din( 8) => pc_pc_func_slp_sl_thold_4_int(0),
             din( 9) => pc_pc_func_slp_sl_thold_4_int(0),
             din(10) => pc_pc_cfg_sl_thold_4,
             din(11) => pc_pc_cfg_slp_sl_thold_4,
             din(12) => pc_pc_func_nsl_thold_4_int,
             din(13) => pc_pc_func_slp_nsl_thold_4_int,
             q( 0)   => pc_xu_func_sl_thold_3(0),
             q( 1)   => pc_xu_func_sl_thold_3(1),
             q( 2)   => pc_xu_func_sl_thold_3(2),
             q( 3)   => pc_xu_func_sl_thold_3(3),
             q( 4)   => pc_xu_func_sl_thold_3(4),
             q( 5)   => pc_xu_func_slp_sl_thold_3(0),
             q( 6)   => pc_xu_func_slp_sl_thold_3(1),
             q( 7)   => pc_xu_func_slp_sl_thold_3(2),
             q( 8)   => pc_xu_func_slp_sl_thold_3(3),
             q( 9)   => pc_xu_func_slp_sl_thold_3(4),
             q(10)   => pc_xu_cfg_sl_thold_3,
             q(11)   => pc_xu_cfg_slp_sl_thold_3,
             q(12)   => pc_xu_func_nsl_thold_3,
             q(13)   => pc_xu_func_slp_nsl_thold_3
           ); 

xu_ctrl_stg4to3: tri_plat   
   generic map( width => 8, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_gptr_sl_thold_4,
             din( 1) => pc_pc_sg_4_int(0),
             din( 2) => pc_pc_sg_4_int(0),
             din( 3) => pc_pc_sg_4_int(0),
             din( 4) => pc_pc_sg_4_int(0),
             din( 5) => pc_pc_sg_4_int(0),
             din( 6) => pc_pc_fce_4(0),
             din( 7) => pc_pc_fce_4(0),
             q( 0)   => pc_xu_gptr_sl_thold_3,
             q( 1)   => pc_xu_sg_3(0),
             q( 2)   => pc_xu_sg_3(1),
             q( 3)   => pc_xu_sg_3(2),
             q( 4)   => pc_xu_sg_3(3),
             q( 5)   => pc_xu_sg_3(4),
             q( 6)   => pc_xu_fce_3(0),     
             q( 7)   => pc_xu_fce_3(1)     
           ); 

xu_arry_stg4to3: tri_plat   
   generic map( width => 9, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_time_sl_thold_4_int,
             din( 1) => pc_pc_repr_sl_thold_4_int,
             din( 2) => pc_pc_abst_sl_thold_4_int,
             din( 3) => pc_pc_abst_slp_sl_thold_4_int,
             din( 4) => pc_pc_bolt_sl_thold_4_int,
             din( 5) => pc_pc_regf_sl_thold_4_int,
             din( 6) => pc_pc_regf_slp_sl_thold_4_int,
             din( 7) => pc_pc_ary_nsl_thold_4_int,
             din( 8) => pc_pc_ary_slp_nsl_thold_4_int,
             q( 0)   => pc_xu_time_sl_thold_3,
             q( 1)   => pc_xu_repr_sl_thold_3,
             q( 2)   => pc_xu_abst_sl_thold_3,
             q( 3)   => pc_xu_abst_slp_sl_thold_3,
             q( 4)   => pc_xu_bolt_sl_thold_3,
             q( 5)   => pc_xu_regf_sl_thold_3,
             q( 6)   => pc_xu_regf_slp_sl_thold_3,
             q( 7)   => pc_xu_ary_nsl_thold_3,
             q( 8)   => pc_xu_ary_slp_nsl_thold_3
           ); 


bx_ctrls_stg4to3: tri_plat   
   generic map( width => 10, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_func_sl_thold_4_int(0),
             din( 1) => pc_pc_func_slp_sl_thold_4_int(0),
             din( 2) => pc_pc_gptr_sl_thold_4,
             din( 3) => pc_pc_time_sl_thold_4_int,
             din( 4) => pc_pc_repr_sl_thold_4_int,
             din( 5) => pc_pc_abst_sl_thold_4_int,
             din( 6) => pc_pc_bolt_sl_thold_4_int,
             din( 7) => pc_pc_ary_nsl_thold_4_int,
             din( 8) => pc_pc_ary_slp_nsl_thold_4_int,
             din( 9) => pc_pc_sg_4_int(0),
             q( 0)   => pc_bx_func_sl_thold_3,
             q( 1)   => pc_bx_func_slp_sl_thold_3,
             q( 2)   => pc_bx_gptr_sl_thold_3,
             q( 3)   => pc_bx_time_sl_thold_3,
             q( 4)   => pc_bx_repr_sl_thold_3,
             q( 5)   => pc_bx_abst_sl_thold_3,
             q( 6)   => pc_bx_bolt_sl_thold_3,
             q( 7)   => pc_bx_ary_nsl_thold_3,
             q( 8)   => pc_bx_ary_slp_nsl_thold_3,
             q( 9)   => pc_bx_sg_3
           ); 


fu_func_stg4to3: tri_plat   
   generic map( width => 8, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_func_sl_thold_4_int(1),
             din( 1) => pc_pc_func_sl_thold_4_int(1),
             din( 2) => pc_pc_func_slp_sl_thold_4_int(1),
             din( 3) => pc_pc_func_slp_sl_thold_4_int(1),
             din( 4) => pc_pc_cfg_sl_thold_4,
             din( 5) => pc_pc_cfg_slp_sl_thold_4,
             din( 6) => pc_pc_func_nsl_thold_4_int,
             din( 7) => pc_pc_func_slp_nsl_thold_4_int,
             q( 0)   => pc_fu_func_sl_thold_3(0),
             q( 1)   => pc_fu_func_sl_thold_3(1),
             q( 2)   => pc_fu_func_slp_sl_thold_3(0),
             q( 3)   => pc_fu_func_slp_sl_thold_3(1),
             q( 4)   => pc_fu_cfg_sl_thold_3,
             q( 5)   => pc_fu_cfg_slp_sl_thold_3,
             q( 6)   => pc_fu_func_nsl_thold_3,
             q( 7)   => pc_fu_func_slp_nsl_thold_3
           ); 

fu_ctrl_stg4to3: tri_plat   
   generic map( width => 4, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_gptr_sl_thold_4,
             din( 1) => pc_pc_sg_4_int(1),
             din( 2) => pc_pc_sg_4_int(1),
             din( 3) => pc_pc_fce_4(1),
             q( 0)   => pc_fu_gptr_sl_thold_3,
             q( 1)   => pc_fu_sg_3(0),
             q( 2)   => pc_fu_sg_3(1),
             q( 3)   => pc_fu_fce_3     
           ); 

fu_arry_stg4to3: tri_plat   
   generic map( width => 7, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_time_sl_thold_4_int,
             din( 1) => pc_pc_repr_sl_thold_4_int,
             din( 2) => pc_pc_abst_sl_thold_4_int,
             din( 3) => pc_pc_abst_slp_sl_thold_4_int,
             din( 4) => pc_pc_bolt_sl_thold_4_int,
             din( 5) => pc_pc_ary_nsl_thold_4_int,
             din( 6) => pc_pc_ary_slp_nsl_thold_4_int,
             q( 0)   => pc_fu_time_sl_thold_3,
             q( 1)   => pc_fu_repr_sl_thold_3,
             q( 2)   => pc_fu_abst_sl_thold_3,
             q( 3)   => pc_fu_abst_slp_sl_thold_3,
             q( 4)   => pc_fu_bolt_sl_thold_3,
             q( 5)   => pc_fu_ary_nsl_thold_3,
             q( 6)   => pc_fu_ary_slp_nsl_thold_3
           ); 


pc_func_stg4to3: tri_plat   
   generic map( width => 4, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_func_sl_thold_4_int(1),
             din( 1) => pc_pc_func_slp_sl_thold_4_int(1),
             din( 2) => pc_pc_cfg_sl_thold_4,
             din( 3) => pc_pc_cfg_slp_sl_thold_4,
             q( 0)   => pc_pc_func_sl_thold_3,
             q( 1)   => pc_pc_func_slp_sl_thold_3,
             q( 2)   => pc_pc_cfg_sl_thold_3,
             q( 3)   => pc_pc_cfg_slp_sl_thold_3
           );

pc_ctrl_stg4to3: tri_plat   
   generic map( width => 4, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din( 0) => pc_pc_gptr_sl_thold_4,
             din( 1) => bo_pc_abst_sl_thold_4_int,
             din( 2) => pc_pc_bolt_sl_thold_4_int,
             din( 3) => pc_pc_sg_4_int(1),
             q( 0)   => pc_pc_gptr_sl_thold_3,
             q( 1)   => pc_pc_abst_sl_thold_3,
             q( 2)   => pc_pc_bolt_sl_thold_3,
             q( 3)   => pc_pc_sg_3
           );


func_3_2: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_func_sl_thold_3,
             q(0)    => pc_pc_func_sl_thold_2
           );
func_2_1: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_func_sl_thold_2,
             q(0)    => pc_pc_func_sl_thold_1
           );
func_1_0: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_func_sl_thold_1,
             q(0)    => pc_pc_func_sl_thold_0
           );

func_slp_3_2: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_func_slp_sl_thold_3,
             q(0)    => pc_pc_func_slp_sl_thold_2
           );
func_slp_2_1: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_func_slp_sl_thold_2,
             q(0)    => pc_pc_func_slp_sl_thold_1
           );
func_slp_1_0: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_func_slp_sl_thold_1,
             q(0)    => pc_pc_func_slp_sl_thold_0
           );

cfg_3_2: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_cfg_sl_thold_3,
             q(0)    => pc_pc_cfg_sl_thold_2
           );
cfg_2_1: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_cfg_sl_thold_2,
             q(0)    => pc_pc_cfg_sl_thold_1
           );
cfg_1_0: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_cfg_sl_thold_1,
             q(0)    => pc_pc_cfg_sl_thold_0
           );

cfg_slp_3_2: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_cfg_slp_sl_thold_3,
             q(0)    => pc_pc_cfg_slp_sl_thold_2
           );
cfg_slp_2_1: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_cfg_slp_sl_thold_2,
             q(0)    => pc_pc_cfg_slp_sl_thold_1
           );
cfg_slp_1_0: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_cfg_slp_sl_thold_1,
             q(0)    => pc_pc_cfg_slp_sl_thold_0
           );

abst_3_2: tri_plat   
   generic map( width => 2, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_abst_sl_thold_3,
             din(1)  => pc_pc_bolt_sl_thold_3,
             q(0)    => pc_pc_abst_sl_thold_2,
             q(1)    => pc_pc_bolt_sl_thold_2
           );
abst_2_1: tri_plat   
   generic map( width => 2, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_abst_sl_thold_2,
             din(1)  => pc_pc_bolt_sl_thold_2,
             q(0)    => pc_pc_abst_sl_thold_1,
             q(1)    => pc_pc_bolt_sl_thold_1
           );
abst_1_0: tri_plat   
   generic map( width => 2, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_abst_sl_thold_1,
             din(1)  => pc_pc_bolt_sl_thold_1,
             q(0)    => pc_pc_abst_sl_thold_0,
             q(1)    => pc_pc_bolt_sl_thold_0
           );

gptr_3_2: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_gptr_sl_thold_3,
             q(0)    => pc_pc_gptr_sl_thold_2
           );
gptr_2_1: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_gptr_sl_thold_2,
             q(0)    => pc_pc_gptr_sl_thold_1
           );
gptr_1_0: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_gptr_sl_thold_1,
             q(0)    => pc_pc_gptr_sl_thold_0
           );

sg_3_2: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_sg_3,
             q(0)    => pc_pc_sg_2
           );
sg_2_1: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_sg_2,
             q(0)    => pc_pc_sg_1
           );
sg_1_0: tri_plat   
   generic map( width => 1, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => pc_pc_ccflush_out_dc,
             din(0)  => pc_pc_sg_1,
             q(0)    => pc_pc_sg_0
           );


end pcq_clks_stg;

