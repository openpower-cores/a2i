-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--  Description: Pervasive Core LCB Staging
--
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_clks_stg is
generic(expand_type             : integer := 2          -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
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
-- Thold + control from bolton frontend
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
--  --Thold + control outputs to the units
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


-- Other units use ccflush signal gated for power-savings operation
   pc_xu_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_bx_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_iu_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_fu_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_mm_ccflush_dc <= pc_pc_ccflush_out_dc;
   pc_pc_ccflush_dc <= pc_pc_ccflush_out_dc;


--=====================================================================
-- Gate in bolt-on thold/sg controls when bolt-on ABIST enabled
--=====================================================================
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


--=====================================================================
-- LCB control signals staged/redriven to other units
--=====================================================================
-- IU and MMU thold/SG/FCE exits PCQ at level 4.
-- The Level 4 to level 3 staging has been moved to the IU RP unit for timing.
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


-- Start of XU thold/SG/FCE staging (level 4 to level 3)
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


-- Start of BX thold/SG/FCE staging (level 4 to level 3)
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


-- Start of FU thold/SG/FCE staging (level 4 to level 3)
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


-- Start of PC thold/SG staging (level 4 to level 3)
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
-- End of thold/SG/FCE staging (level 4 to level 3)


--=====================================================================
-- thold/SG staging (level 3 to level 0) for PC units
--=====================================================================
------------------------------------------------------
-- FUNC (RUN)
------------------------------------------------------
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

------------------------------------------------------
-- FUNC (SLEEP)
------------------------------------------------------
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

------------------------------------------------------
-- CFG (RUN)
------------------------------------------------------
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

------------------------------------------------------
-- CFG (SLEEP)
------------------------------------------------------
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

------------------------------------------------------
-- ABST
------------------------------------------------------
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

------------------------------------------------------
-- GPTR
------------------------------------------------------
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

------------------------------------------------------
-- SG
------------------------------------------------------
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
