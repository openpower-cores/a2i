-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.




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

entity mmq_perv is
generic(expand_type : integer := 2 ); 
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     pc_mm_sg_3                 : in  std_ulogic_vector(0 to 1);
     pc_mm_func_sl_thold_3      : in  std_ulogic_vector(0 to 1);
     pc_mm_func_slp_sl_thold_3  : in  std_ulogic_vector(0 to 1);
     pc_mm_gptr_sl_thold_3      : in  std_ulogic;
     pc_mm_fce_3                : in  std_ulogic;

     pc_mm_time_sl_thold_3       : in   std_ulogic;
     pc_mm_repr_sl_thold_3       : in   std_ulogic;
     pc_mm_abst_sl_thold_3       : in   std_ulogic;
     pc_mm_abst_slp_sl_thold_3   : in   std_ulogic;
     pc_mm_cfg_sl_thold_3        : in   std_ulogic;
     pc_mm_cfg_slp_sl_thold_3    : in   std_ulogic;
     pc_mm_func_nsl_thold_3      : in   std_ulogic;
     pc_mm_func_slp_nsl_thold_3  : in   std_ulogic;
     pc_mm_ary_nsl_thold_3       : in   std_ulogic;
     pc_mm_ary_slp_nsl_thold_3   : in   std_ulogic;
     
     tc_ac_ccflush_dc           : in  std_ulogic;
     tc_scan_diag_dc            : in  std_ulogic;
     tc_ac_scan_dis_dc_b        : in  std_ulogic;
     
     pc_sg_0                    : out std_ulogic_vector(0 to 1);
     pc_sg_1                    : out std_ulogic_vector(0 to 1);
     pc_sg_2                    : out std_ulogic_vector(0 to 1);
     pc_func_sl_thold_2         : out std_ulogic_vector(0 to 1);
     pc_func_slp_sl_thold_2     : out std_ulogic_vector(0 to 1);
     pc_func_slp_nsl_thold_2    : out   std_ulogic;
     pc_cfg_sl_thold_2          : out std_ulogic;
     pc_cfg_slp_sl_thold_2      : out std_ulogic;
     pc_fce_2                   : out std_ulogic;
     
     pc_time_sl_thold_0      : out std_ulogic;
     pc_repr_sl_thold_0      : out std_ulogic;
     pc_abst_sl_thold_0      : out std_ulogic;
     pc_abst_slp_sl_thold_0  : out std_ulogic;
     pc_ary_nsl_thold_0      : out std_ulogic;
     pc_ary_slp_nsl_thold_0  : out std_ulogic;
     pc_func_sl_thold_0         : out std_ulogic_vector(0 to 1);
     pc_func_sl_thold_0_b       : out std_ulogic_vector(0 to 1);
     pc_func_slp_sl_thold_0     : out std_ulogic_vector(0 to 1);
     pc_func_slp_sl_thold_0_b   : out std_ulogic_vector(0 to 1);
     
     lcb_clkoff_dc_b            : out std_ulogic;
     lcb_act_dis_dc             : out std_ulogic;
     lcb_d_mode_dc              : out std_ulogic;
     lcb_delay_lclkr_dc         : out std_ulogic_vector(0 to 4);
     lcb_mpw1_dc_b              : out std_ulogic_vector(0 to 4);
     lcb_mpw2_dc_b              : out std_ulogic;
     g6t_gptr_lcb_clkoff_dc_b            : out std_ulogic;
     g6t_gptr_lcb_act_dis_dc             : out std_ulogic;
     g6t_gptr_lcb_d_mode_dc              : out std_ulogic;
     g6t_gptr_lcb_delay_lclkr_dc         : out std_ulogic_vector(0 to 4);
     g6t_gptr_lcb_mpw1_dc_b              : out std_ulogic_vector(0 to 4);
     g6t_gptr_lcb_mpw2_dc_b              : out std_ulogic;
     g8t_gptr_lcb_clkoff_dc_b            : out std_ulogic;
     g8t_gptr_lcb_act_dis_dc             : out std_ulogic;
     g8t_gptr_lcb_d_mode_dc              : out std_ulogic;
     g8t_gptr_lcb_delay_lclkr_dc         : out std_ulogic_vector(0 to 4);
     g8t_gptr_lcb_mpw1_dc_b              : out std_ulogic_vector(0 to 4);
     g8t_gptr_lcb_mpw2_dc_b              : out std_ulogic;
 

     pc_mm_abist_dcomp_g6t_2r    : in   std_ulogic_vector(0 to 3);
     pc_mm_abist_di_0            : in   std_ulogic_vector(0 to 3);
     pc_mm_abist_di_g6t_2r       : in   std_ulogic_vector(0 to 3);
     pc_mm_abist_ena_dc          : in   std_ulogic;
     pc_mm_abist_g6t_r_wb        : in   std_ulogic;
     pc_mm_abist_g8t1p_renb_0    : in   std_ulogic;
     pc_mm_abist_g8t_bw_0        : in   std_ulogic;
     pc_mm_abist_g8t_bw_1        : in   std_ulogic;
     pc_mm_abist_g8t_dcomp       : in   std_ulogic_vector(0 to 3);
     pc_mm_abist_g8t_wenb        : in   std_ulogic;
     pc_mm_abist_raddr_0         : in   std_ulogic_vector(0 to 9);
     pc_mm_abist_waddr_0         : in   std_ulogic_vector(0 to 9);
     pc_mm_abist_wl128_comp_ena  : in   std_ulogic;

     pc_mm_abist_g8t_wenb_q        : out   std_ulogic;
     pc_mm_abist_g8t1p_renb_0_q    : out   std_ulogic;
     pc_mm_abist_di_0_q            : out   std_ulogic_vector(0 to 3);
     pc_mm_abist_g8t_bw_1_q        : out   std_ulogic;
     pc_mm_abist_g8t_bw_0_q        : out   std_ulogic;
     pc_mm_abist_waddr_0_q         : out   std_ulogic_vector(0 to 9);
     pc_mm_abist_raddr_0_q         : out   std_ulogic_vector(0 to 9);
     pc_mm_abist_wl128_comp_ena_q  : out   std_ulogic;
     pc_mm_abist_g8t_dcomp_q       : out   std_ulogic_vector(0 to 3);
     pc_mm_abist_dcomp_g6t_2r_q    : out   std_ulogic_vector(0 to 3);
     pc_mm_abist_di_g6t_2r_q       : out   std_ulogic_vector(0 to 3);
     pc_mm_abist_g6t_r_wb_q        : out   std_ulogic;

     pc_mm_bolt_sl_thold_3          : in    std_ulogic;
     pc_mm_bo_enable_3              : in    std_ulogic; 
     pc_mm_bolt_sl_thold_0          : out    std_ulogic;
     pc_mm_bo_enable_2              : out    std_ulogic; 

     gptr_scan_in          : in  std_ulogic;
     gptr_scan_out         : out std_ulogic;

     time_scan_in          : in  std_ulogic;
     time_scan_in_int      : out std_ulogic;
     time_scan_out_int     : in  std_ulogic;
     time_scan_out         : out std_ulogic;

     func_scan_in          : in  std_ulogic_vector(0 to 9);
     func_scan_in_int      : out std_ulogic_vector(0 to 9);
     func_scan_out_int     : in  std_ulogic_vector(0 to 9);
     func_scan_out         : out std_ulogic_vector(0 to 9);

     repr_scan_in          : in  std_ulogic;
     repr_scan_in_int      : out std_ulogic;
     repr_scan_out_int     : in  std_ulogic;
     repr_scan_out         : out std_ulogic;

     abst_scan_in          : in  std_ulogic_vector(0 to 1);
     abst_scan_in_int      : out std_ulogic_vector(0 to 1);
     abst_scan_out_int     : in  std_ulogic_vector(0 to 1);
     abst_scan_out         : out std_ulogic_vector(0 to 1);

     bcfg_scan_in          : in  std_ulogic; 
     bcfg_scan_in_int      : out std_ulogic;
     bcfg_scan_out_int     : in  std_ulogic;
     bcfg_scan_out         : out std_ulogic;

     ccfg_scan_in          : in  std_ulogic;  
     ccfg_scan_in_int      : out std_ulogic;
     ccfg_scan_out_int     : in  std_ulogic;
     ccfg_scan_out         : out std_ulogic;

     dcfg_scan_in          : in  std_ulogic; 
     dcfg_scan_in_int      : out std_ulogic;
     dcfg_scan_out_int     : in  std_ulogic;
     dcfg_scan_out         : out std_ulogic

);


-- synopsys translate_off

-- synopsys translate_on

end mmq_perv;
architecture mmq_perv of mmq_perv is

signal tidn  : std_logic;
signal tiup  : std_logic;

signal pc_func_sl_thold_2_int        : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_thold_2_int    : std_ulogic_vector(0 to 1);
signal pc_sg_2_int                   : std_ulogic_vector(0 to 1);
signal pc_gptr_sl_thold_2_int        : std_ulogic;
signal pc_fce_2_int                  : std_ulogic;
signal pc_time_sl_thold_2_int        : std_ulogic;
signal pc_repr_sl_thold_2_int        : std_ulogic;
signal pc_abst_sl_thold_2_int        : std_ulogic;
signal pc_abst_slp_sl_thold_2_int    : std_ulogic;
signal pc_cfg_sl_thold_2_int         : std_ulogic;
signal pc_cfg_slp_sl_thold_2_int     : std_ulogic;
signal pc_func_nsl_thold_2_int       : std_ulogic;
signal pc_func_slp_nsl_thold_2_int   : std_ulogic;
signal pc_ary_nsl_thold_2_int        : std_ulogic;
signal pc_ary_slp_nsl_thold_2_int    : std_ulogic;
signal pc_mm_bolt_sl_thold_2_int     : std_ulogic;

signal pc_func_sl_thold_1_int        : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_thold_1_int    : std_ulogic_vector(0 to 1);
signal pc_sg_1_int                   : std_ulogic_vector(0 to 1);
signal pc_gptr_sl_thold_1_int        : std_ulogic;
signal pc_fce_1_int                  : std_ulogic;
signal pc_time_sl_thold_1_int        : std_ulogic;
signal pc_repr_sl_thold_1_int        : std_ulogic;
signal pc_abst_sl_thold_1_int        : std_ulogic;
signal pc_abst_slp_sl_thold_1_int    : std_ulogic;
signal pc_cfg_sl_thold_1_int         : std_ulogic;
signal pc_cfg_slp_sl_thold_1_int     : std_ulogic;
signal pc_func_nsl_thold_1_int       : std_ulogic;
signal pc_func_slp_nsl_thold_1_int   : std_ulogic;
signal pc_ary_nsl_thold_1_int        : std_ulogic;
signal pc_ary_slp_nsl_thold_1_int    : std_ulogic;
signal pc_mm_bolt_sl_thold_1_int     : std_ulogic;

signal pc_func_sl_thold_0_int        : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_thold_0_int    : std_ulogic_vector(0 to 1);
signal pc_sg_0_int                   : std_ulogic_vector(0 to 1);
signal pc_gptr_sl_thold_0_int        : std_ulogic;
signal pc_fce_0_int                  : std_ulogic;
signal pc_time_sl_thold_0_int        : std_ulogic;
signal pc_repr_sl_thold_0_int        : std_ulogic;
signal pc_abst_sl_thold_0_int        : std_ulogic;
signal pc_abst_slp_sl_thold_0_int    : std_ulogic;
signal pc_cfg_sl_thold_0_int         : std_ulogic;
signal pc_cfg_slp_sl_thold_0_int     : std_ulogic;
signal pc_func_nsl_thold_0_int       : std_ulogic;
signal pc_func_slp_nsl_thold_0_int   : std_ulogic;
signal pc_ary_nsl_thold_0_int        : std_ulogic;
signal pc_ary_slp_nsl_thold_0_int    : std_ulogic;

signal pc_func_sl_thold_0_b_int      : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_thold_0_b_int  : std_ulogic_vector(0 to 1);
signal pc_func_slp_sl_force_int      : std_ulogic_vector(0 to 1);
signal pc_func_sl_force_int          : std_ulogic_vector(0 to 1);

signal abst_scan_in_q           :std_ulogic_vector(0 to 1);
signal abst_scan_out_q          :std_ulogic_vector(0 to 1);
signal time_scan_in_q           :std_ulogic;
signal time_scan_out_q          :std_ulogic;
signal repr_scan_in_q           :std_ulogic;
signal repr_scan_out_q          :std_ulogic;
signal gptr_scan_in_q           :std_ulogic;
signal gptr_scan_out_int        :std_ulogic;
signal gptr_scan_out_q          :std_ulogic;
signal gptr_scan_lcbctrl        :std_ulogic_vector(0 to 1);
signal bcfg_scan_in_q           :std_ulogic;
signal bcfg_scan_out_q          :std_ulogic;
signal ccfg_scan_in_q           :std_ulogic;
signal ccfg_scan_out_q          :std_ulogic;
signal dcfg_scan_in_q           :std_ulogic;
signal dcfg_scan_out_q          :std_ulogic;
signal func_scan_in_q           :std_ulogic_vector(0 to 9);
signal func_scan_out_q          :std_ulogic_vector(0 to 9);

signal slat_force               :std_ulogic_vector(0 to 1);
signal abst_slat_thold_b        :std_ulogic;
signal abst_slat_d2clk          :std_ulogic;
signal abst_slat_lclk           :clk_logic;
signal time_slat_thold_b        :std_ulogic;
signal time_slat_d2clk          :std_ulogic;
signal time_slat_lclk           :clk_logic;
signal repr_slat_thold_b        :std_ulogic;
signal repr_slat_d2clk          :std_ulogic;
signal repr_slat_lclk           :clk_logic;
signal gptr_slat_thold_b        :std_ulogic;
signal gptr_slat_d2clk          :std_ulogic;
signal gptr_slat_lclk           :clk_logic;
signal bcfg_slat_thold_b        :std_ulogic;
signal bcfg_slat_d2clk          :std_ulogic;
signal bcfg_slat_lclk           :clk_logic;
signal ccfg_slat_thold_b        :std_ulogic;
signal ccfg_slat_d2clk          :std_ulogic;
signal ccfg_slat_lclk           :clk_logic;
signal dcfg_slat_thold_b        :std_ulogic;
signal dcfg_slat_d2clk          :std_ulogic;
signal dcfg_slat_lclk           :clk_logic;
signal func_slat_thold_b        :std_ulogic;
signal func_slat_d2clk          :std_ulogic;
signal func_slat_lclk           :clk_logic;

signal pc_abst_sl_thold_0_b    : std_ulogic;
signal pc_abst_sl_force        : std_ulogic;
signal lcb_delay_lclkr_dc_int  : std_ulogic_vector(0 to 4);
signal lcb_d_mode_dc_int       : std_ulogic;
signal lcb_mpw1_dc_b_int       : std_ulogic_vector(0 to 4);
signal lcb_mpw2_dc_b_int       : std_ulogic;
signal lcb_clkoff_dc_b_int     : std_ulogic;

signal abist_siv                :std_ulogic_vector(0 to 41);
signal abist_sov                :std_ulogic_vector(0 to 41);

signal unused_dc  :  std_ulogic_vector(0 to 5);  
-- synopsys translate_off
-- synopsys translate_on

begin

tidn <= '0';
tiup <= '1';

perv_3to2_reg: tri_plat
  generic map (width => 20, expand_type => expand_type)
  port map (vd         => vdd,
            gd           => gnd,
            nclk         => nclk,
            flush        => tc_ac_ccflush_dc,
            din(0 to 1) => pc_mm_func_sl_thold_3(0 to 1),
            din(2 to 3) => pc_mm_func_slp_sl_thold_3(0 to 1),
            din(4 to 5) => pc_mm_sg_3(0 to 1),
            din(6)       => pc_mm_gptr_sl_thold_3,
            din(7)       => pc_mm_fce_3,
            din(8)       => pc_mm_time_sl_thold_3,
            din(9)       => pc_mm_repr_sl_thold_3,
            din(10)      => pc_mm_abst_sl_thold_3,
            din(11)      => pc_mm_abst_slp_sl_thold_3,
            din(12)      => pc_mm_cfg_sl_thold_3,
            din(13)      => pc_mm_cfg_slp_sl_thold_3,
            din(14)      => pc_mm_func_nsl_thold_3,
            din(15)      => pc_mm_func_slp_nsl_thold_3,
            din(16)      => pc_mm_ary_nsl_thold_3,
            din(17)      => pc_mm_ary_slp_nsl_thold_3,
            din(18)      => pc_mm_bolt_sl_thold_3,
            din(19)      => pc_mm_bo_enable_3,
            q(0 to 1)   => pc_func_sl_thold_2_int(0 to 1),
            q(2 to 3)   => pc_func_slp_sl_thold_2_int(0 to 1),
            q(4 to 5)   => pc_sg_2_int(0 to 1),
            q(6)         => pc_gptr_sl_thold_2_int,
            q(7)         => pc_fce_2_int,            
            q(8)         => pc_time_sl_thold_2_int,
            q(9)         => pc_repr_sl_thold_2_int,
            q(10)        => pc_abst_sl_thold_2_int,
            q(11)        => pc_abst_slp_sl_thold_2_int,
            q(12)        => pc_cfg_sl_thold_2_int,
            q(13)        => pc_cfg_slp_sl_thold_2_int,
            q(14)        => pc_func_nsl_thold_2_int,
            q(15)        => pc_func_slp_nsl_thold_2_int,
            q(16)        => pc_ary_nsl_thold_2_int,
            q(17)        => pc_ary_slp_nsl_thold_2_int,
            q(18)        => pc_mm_bolt_sl_thold_2_int,
            q(19)        => pc_mm_bo_enable_2);
            

perv_2to1_reg: tri_plat
  generic map (width => 19, expand_type => expand_type)
  port map (vd         => vdd,
            gd           => gnd,
            nclk         => nclk,
            flush        => tc_ac_ccflush_dc,
            din(0 to 1) => pc_func_sl_thold_2_int(0 to 1),
            din(2 to 3) => pc_func_slp_sl_thold_2_int(0 to 1),
            din(4 to 5) => pc_sg_2_int(0 to 1),
            din(6)       => pc_gptr_sl_thold_2_int,
            din(7)       => pc_fce_2_int,
            din(8)       => pc_time_sl_thold_2_int,
            din(9)       => pc_repr_sl_thold_2_int,
            din(10)      => pc_abst_sl_thold_2_int,
            din(11)      => pc_abst_slp_sl_thold_2_int,
            din(12)      => pc_cfg_sl_thold_2_int,
            din(13)      => pc_cfg_slp_sl_thold_2_int,
            din(14)      => pc_func_nsl_thold_2_int,
            din(15)      => pc_func_slp_nsl_thold_2_int,
            din(16)      => pc_ary_nsl_thold_2_int,
            din(17)      => pc_ary_slp_nsl_thold_2_int,
            din(18)      => pc_mm_bolt_sl_thold_2_int,
            q(0 to 1)   => pc_func_sl_thold_1_int(0 to 1),
            q(2 to 3)   => pc_func_slp_sl_thold_1_int(0 to 1),
            q(4 to 5)   => pc_sg_1_int(0 to 1),
            q(6)         => pc_gptr_sl_thold_1_int,
            q(7)         => pc_fce_1_int,            
            q(8)         => pc_time_sl_thold_1_int,
            q(9)         => pc_repr_sl_thold_1_int,
            q(10)        => pc_abst_sl_thold_1_int,
            q(11)        => pc_abst_slp_sl_thold_1_int,
            q(12)        => pc_cfg_sl_thold_1_int,
            q(13)        => pc_cfg_slp_sl_thold_1_int,
            q(14)        => pc_func_nsl_thold_1_int,
            q(15)        => pc_func_slp_nsl_thold_1_int,
            q(16)        => pc_ary_nsl_thold_1_int,
            q(17)        => pc_ary_slp_nsl_thold_1_int,            
            q(18)        => pc_mm_bolt_sl_thold_1_int);

perv_1to0_reg: tri_plat
  generic map (width => 19, expand_type => expand_type)
  port map (vd         => vdd,
            gd           => gnd,
            nclk         => nclk,
            flush        => tc_ac_ccflush_dc,
            din(0 to 1) => pc_func_sl_thold_1_int(0 to 1),
            din(2 to 3) => pc_func_slp_sl_thold_1_int(0 to 1),
            din(4 to 5) => pc_sg_1_int(0 to 1),
            din(6)       => pc_gptr_sl_thold_1_int,
            din(7)       => pc_fce_1_int,
            din(8)       => pc_time_sl_thold_1_int,
            din(9)       => pc_repr_sl_thold_1_int,
            din(10)      => pc_abst_sl_thold_1_int,
            din(11)      => pc_abst_slp_sl_thold_1_int,
            din(12)      => pc_cfg_sl_thold_1_int,
            din(13)      => pc_cfg_slp_sl_thold_1_int,
            din(14)      => pc_func_nsl_thold_1_int,
            din(15)      => pc_func_slp_nsl_thold_1_int,
            din(16)      => pc_ary_nsl_thold_1_int,
            din(17)      => pc_ary_slp_nsl_thold_1_int,
            din(18)      => pc_mm_bolt_sl_thold_1_int,
            q(0 to 1)   => pc_func_sl_thold_0_int(0 to 1),
            q(2 to 3)   => pc_func_slp_sl_thold_0_int(0 to 1),
            q(4 to 5)   => pc_sg_0_int(0 to 1),
            q(6)         => pc_gptr_sl_thold_0_int,
            q(7)         => pc_fce_0_int,            
            q(8)         => pc_time_sl_thold_0_int,
            q(9)         => pc_repr_sl_thold_0_int,
            q(10)        => pc_abst_sl_thold_0_int,
            q(11)        => pc_abst_slp_sl_thold_0_int,
            q(12)        => pc_cfg_sl_thold_0_int,
            q(13)        => pc_cfg_slp_sl_thold_0_int,
            q(14)        => pc_func_nsl_thold_0_int,
            q(15)        => pc_func_slp_nsl_thold_0_int,
            q(16)        => pc_ary_nsl_thold_0_int,
            q(17)        => pc_ary_slp_nsl_thold_0_int,            
            q(18)        => pc_mm_bolt_sl_thold_0);


pc_time_sl_thold_0       <= pc_time_sl_thold_0_int;
pc_abst_sl_thold_0       <= pc_abst_sl_thold_0_int;
pc_abst_slp_sl_thold_0   <= pc_abst_slp_sl_thold_0_int;
pc_repr_sl_thold_0       <= pc_repr_sl_thold_0_int;
pc_ary_nsl_thold_0       <= pc_ary_nsl_thold_0_int;
pc_ary_slp_nsl_thold_0   <= pc_ary_slp_nsl_thold_0_int;

pc_func_sl_thold_0         <= pc_func_sl_thold_0_int;
pc_func_sl_thold_0_b       <= pc_func_sl_thold_0_b_int;
pc_func_slp_sl_thold_0     <= pc_func_slp_sl_thold_0_int;
pc_func_slp_sl_thold_0_b   <= pc_func_slp_sl_thold_0_b_int;

pc_sg_0                  <= pc_sg_0_int;
pc_sg_1                  <= pc_sg_1_int;
pc_sg_2                  <= pc_sg_2_int;

pc_func_sl_thold_2       <= pc_func_sl_thold_2_int;
pc_func_slp_sl_thold_2   <= pc_func_slp_sl_thold_2_int;
pc_func_slp_nsl_thold_2  <= pc_func_slp_nsl_thold_2_int;
pc_cfg_sl_thold_2        <= pc_cfg_sl_thold_2_int;
pc_cfg_slp_sl_thold_2    <= pc_cfg_slp_sl_thold_2_int;
pc_fce_2                 <= pc_fce_2_int;


lcb_clkoff_dc_b     <= lcb_clkoff_dc_b_int;
lcb_d_mode_dc       <= lcb_d_mode_dc_int;
lcb_delay_lclkr_dc  <= lcb_delay_lclkr_dc_int;
lcb_mpw1_dc_b       <= lcb_mpw1_dc_b_int;
lcb_mpw2_dc_b       <= lcb_mpw2_dc_b_int;




perv_lcbctrl: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_sg_0_int(0),
            nclk           => nclk,
            scan_in        => gptr_scan_in_q,
            scan_diag_dc   => tc_scan_diag_dc,
            thold          => pc_gptr_sl_thold_0_int,
            clkoff_dc_b    => lcb_clkoff_dc_b_int,
            delay_lclkr_dc => lcb_delay_lclkr_dc_int(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => lcb_d_mode_dc_int,
            mpw1_dc_b      => lcb_mpw1_dc_b_int(0 to 4),
            mpw2_dc_b      => lcb_mpw2_dc_b_int,
            scan_out       => gptr_scan_lcbctrl(0));

perv_g6t_gptr_lcbctrl: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_sg_0_int(1),
            nclk           => nclk,
            scan_in        => gptr_scan_lcbctrl(0),
            scan_diag_dc   => tc_scan_diag_dc,
            thold          => pc_gptr_sl_thold_0_int,
            clkoff_dc_b    => g6t_gptr_lcb_clkoff_dc_b,
            delay_lclkr_dc => g6t_gptr_lcb_delay_lclkr_dc(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => g6t_gptr_lcb_d_mode_dc,
            mpw1_dc_b      => g6t_gptr_lcb_mpw1_dc_b(0 to 4),
            mpw2_dc_b      => g6t_gptr_lcb_mpw2_dc_b,
            scan_out       => gptr_scan_lcbctrl(1));

perv_g8t_gptr_lcbctrl: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => pc_sg_0_int(1),
            nclk           => nclk,
            scan_in        => gptr_scan_lcbctrl(1),
            scan_diag_dc   => tc_scan_diag_dc,
            thold          => pc_gptr_sl_thold_0_int,
            clkoff_dc_b    => g8t_gptr_lcb_clkoff_dc_b,
            delay_lclkr_dc => g8t_gptr_lcb_delay_lclkr_dc(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => g8t_gptr_lcb_d_mode_dc,
            mpw1_dc_b      => g8t_gptr_lcb_mpw1_dc_b(0 to 4),
            mpw2_dc_b      => g8t_gptr_lcb_mpw2_dc_b,
            scan_out       => gptr_scan_out_int);

lcb_act_dis_dc <= '0';
g8t_gptr_lcb_act_dis_dc <= '0';
g6t_gptr_lcb_act_dis_dc <= '0';

time_scan_in_int <= time_scan_in_q;
repr_scan_in_int <= repr_scan_in_q;
func_scan_in_int <= func_scan_in_q;
bcfg_scan_in_int <= bcfg_scan_in_q;
ccfg_scan_in_int <= ccfg_scan_in_q;
dcfg_scan_in_int <= dcfg_scan_in_q;

time_scan_out   <= time_scan_out_q and tc_ac_scan_dis_dc_b;
gptr_scan_out   <= gptr_scan_out_q and tc_ac_scan_dis_dc_b;
repr_scan_out   <= repr_scan_out_q and tc_ac_scan_dis_dc_b;
func_scan_out   <= func_scan_out_q and (0 to 9 => tc_ac_scan_dis_dc_b);
abst_scan_out   <= abst_scan_out_q and (0 to 1 => tc_ac_scan_dis_dc_b);
bcfg_scan_out   <= bcfg_scan_out_q and tc_ac_scan_dis_dc_b;
ccfg_scan_out   <= ccfg_scan_out_q and tc_ac_scan_dis_dc_b;
dcfg_scan_out   <= dcfg_scan_out_q and tc_ac_scan_dis_dc_b;

slat_force        <= pc_sg_0_int;
abst_slat_thold_b <= NOT pc_abst_sl_thold_0_int;
time_slat_thold_b <= NOT pc_time_sl_thold_0_int;
repr_slat_thold_b <= NOT pc_repr_sl_thold_0_int;
gptr_slat_thold_b <= NOT pc_gptr_sl_thold_0_int;
bcfg_slat_thold_b <= NOT pc_cfg_sl_thold_0_int;
ccfg_slat_thold_b <= NOT pc_cfg_sl_thold_0_int;
dcfg_slat_thold_b <= NOT pc_cfg_sl_thold_0_int;
func_slat_thold_b <= NOT pc_func_sl_thold_0_int(0);

perv_lcbs_abst: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc_int(0),
      nclk        => nclk,
      forcee => slat_force(1),
      thold_b     => abst_slat_thold_b,
      dclk        => abst_slat_d2clk,
      lclk        => abst_slat_lclk );

perv_abst_stg: tri_slat_scan  
   generic map (width => 4, init => "0000", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => abst_slat_d2clk,
              lclk        => abst_slat_lclk,
              scan_in(0 to 1)  => abst_scan_in,
              scan_in(2 to 3)  => abst_scan_out_int,
              scan_out(0 to 1) => abst_scan_in_q,
              scan_out(2 to 3) => abst_scan_out_q );

perv_lcbs_time: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc_int(0),
      nclk        => nclk,
      forcee => slat_force(1),
      thold_b     => time_slat_thold_b,
      dclk        => time_slat_d2clk,
      lclk        => time_slat_lclk );

perv_time_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => time_slat_d2clk,
              lclk        => time_slat_lclk,
              scan_in(0)  => time_scan_in,
              scan_in(1)  => time_scan_out_int,
              scan_out(0) => time_scan_in_q,
              scan_out(1) => time_scan_out_q );

perv_lcbs_repr: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc_int(0),
      nclk        => nclk,
      forcee => slat_force(1),
      thold_b     => repr_slat_thold_b,
      dclk        => repr_slat_d2clk,
      lclk        => repr_slat_lclk );

perv_repr_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => repr_slat_d2clk,
              lclk        => repr_slat_lclk,
              scan_in(0)  => repr_scan_in,
              scan_in(1)  => repr_scan_out_int,
              scan_out(0) => repr_scan_in_q,
              scan_out(1) => repr_scan_out_q );

perv_lcbs_gptr: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => tiup,
      nclk        => nclk,
      forcee => slat_force(0),
      thold_b     => gptr_slat_thold_b,
      dclk        => gptr_slat_d2clk,
      lclk        => gptr_slat_lclk );

perv_gptr_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => gptr_slat_d2clk,
              lclk        => gptr_slat_lclk,
              scan_in(0)  => gptr_scan_in,
              scan_in(1)  => gptr_scan_out_int,
              scan_out(0) => gptr_scan_in_q,
              scan_out(1) => gptr_scan_out_q );

perv_lcbs_bcfg: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc_int(0),
      nclk        => nclk,
      forcee => slat_force(0),
      thold_b     => bcfg_slat_thold_b,
      dclk        => bcfg_slat_d2clk,
      lclk        => bcfg_slat_lclk );

perv_bcfg_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => bcfg_slat_d2clk,
              lclk        => bcfg_slat_lclk,
              scan_in(0)  => bcfg_scan_in,
              scan_in(1)  => bcfg_scan_out_int,
              scan_out(0) => bcfg_scan_in_q,
              scan_out(1) => bcfg_scan_out_q );

perv_lcbs_ccfg: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc_int(0),
      nclk        => nclk,
      forcee => slat_force(0),
      thold_b     => ccfg_slat_thold_b,
      dclk        => ccfg_slat_d2clk,
      lclk        => ccfg_slat_lclk );

perv_ccfg_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => ccfg_slat_d2clk,
              lclk        => ccfg_slat_lclk,
              scan_in(0)  => ccfg_scan_in,
              scan_in(1)  => ccfg_scan_out_int,
              scan_out(0) => ccfg_scan_in_q,
              scan_out(1) => ccfg_scan_out_q );

perv_lcbs_dcfg: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc_int(0),
      nclk        => nclk,
      forcee => slat_force(0),
      thold_b     => dcfg_slat_thold_b,
      dclk        => dcfg_slat_d2clk,
      lclk        => dcfg_slat_lclk );

perv_dcfg_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => dcfg_slat_d2clk,
              lclk        => dcfg_slat_lclk,
              scan_in(0)  => dcfg_scan_in,
              scan_in(1)  => dcfg_scan_out_int,
              scan_out(0) => dcfg_scan_in_q,
              scan_out(1) => dcfg_scan_out_q );

perv_lcbs_func: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc_int(0),
      nclk        => nclk,
      forcee => slat_force(0),
      thold_b     => func_slat_thold_b,
      dclk        => func_slat_d2clk,
      lclk        => func_slat_lclk );

perv_func_stg: tri_slat_scan  
   generic map (width => 20, init => "00000000000000000000", expand_type => expand_type)
   port map ( vd               => vdd,
              gd                 => gnd,
              dclk               => func_slat_d2clk,
              lclk               => func_slat_lclk,
              scan_in(0 to 9)   => func_scan_in,
              scan_in(10 to 19)  => func_scan_out_int,
              scan_out(0 to 9)   => func_scan_in_q,
              scan_out(10 to 19) => func_scan_out_q );


perv_lcbor_func_sl_0: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b_int,
            thold       => pc_func_sl_thold_0_int(0),
            sg          => pc_sg_0_int(0),
            act_dis     => tidn,
            forcee => pc_func_sl_force_int(0),
            thold_b     => pc_func_sl_thold_0_b_int(0));

perv_lcbor_func_sl_1: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b_int,
            thold       => pc_func_sl_thold_0_int(1),
            sg          => pc_sg_0_int(1),
            act_dis     => tidn,
            forcee => pc_func_sl_force_int(1),
            thold_b     => pc_func_sl_thold_0_b_int(1));

perv_lcbor_func_slp_sl_0: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b_int,
            thold       => pc_func_slp_sl_thold_0_int(0),
            sg          => pc_sg_0_int(0),
            act_dis     => tidn,
            forcee => pc_func_slp_sl_force_int(0),
            thold_b     => pc_func_slp_sl_thold_0_b_int(0));

perv_lcbor_func_slp_sl_1: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b_int,
            thold       => pc_func_slp_sl_thold_0_int(1),
            sg          => pc_sg_0_int(1),
            act_dis     => tidn,
            forcee => pc_func_slp_sl_force_int(1),
            thold_b     => pc_func_slp_sl_thold_0_b_int(1));

perv_lcbor_abst_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b_int,
            thold       => pc_abst_sl_thold_0_int,
            sg          => pc_sg_0_int(1),
            act_dis     => tidn,
            forcee => pc_abst_sl_force,
            thold_b     => pc_abst_sl_thold_0_b);




abist_reg: tri_rlmreg_p
  generic map (init => 0, expand_type => expand_type, width => 42, needs_sreset => 0)
  port map (vd             => vdd,
            gd             => gnd,
            nclk           => nclk,
            act            => pc_mm_abist_ena_dc,
            thold_b        => pc_abst_sl_thold_0_b,
            sg             => pc_sg_0_int(1),
            forcee => pc_abst_sl_force,
            delay_lclkr    => lcb_delay_lclkr_dc_int(0),
            mpw1_b         => lcb_mpw1_dc_b_int(0),
            mpw2_b         => lcb_mpw2_dc_b_int,
            d_mode         => lcb_d_mode_dc_int,
            scin           => abist_siv(0 to 41),
            scout          => abist_sov(0 to 41),
            din (0)        => pc_mm_abist_g8t_wenb,
            din (1)        => pc_mm_abist_g8t1p_renb_0,
            din (2  to  5) => pc_mm_abist_di_0,
            din (6)        => pc_mm_abist_g8t_bw_1,
            din (7)        => pc_mm_abist_g8t_bw_0,
            din (8  to 17) => pc_mm_abist_waddr_0,
            din (18 to 27) => pc_mm_abist_raddr_0,
            din (28)       => pc_mm_abist_wl128_comp_ena,
            din (29 to 32) => pc_mm_abist_g8t_dcomp,
            din (33 to 36) => pc_mm_abist_dcomp_g6t_2r,
            din (37 to 40) => pc_mm_abist_di_g6t_2r,
            din (41)       => pc_mm_abist_g6t_r_wb,           
            dout(0)        => pc_mm_abist_g8t_wenb_q,
            dout(1)        => pc_mm_abist_g8t1p_renb_0_q,
            dout(2  to 5)  => pc_mm_abist_di_0_q,
            dout(6)        => pc_mm_abist_g8t_bw_1_q,
            dout(7)        => pc_mm_abist_g8t_bw_0_q,
            dout(8  to 17) => pc_mm_abist_waddr_0_q,
            dout(18 to 27) => pc_mm_abist_raddr_0_q,
            dout(28)       => pc_mm_abist_wl128_comp_ena_q,
            dout(29 to 32) => pc_mm_abist_g8t_dcomp_q,
            dout(33 to 36) => pc_mm_abist_dcomp_g6t_2r_q,
            dout(37 to 40) => pc_mm_abist_di_g6t_2r_q,
            dout(41)       => pc_mm_abist_g6t_r_wb_q);

abist_siv             <= abist_sov(1 to abist_sov'right) & abst_scan_in_q(0);
abst_scan_in_int(0)  <= abist_sov(0);
abst_scan_in_int(1)  <= abst_scan_in_q(1);

unused_dc(0) <= PC_FCE_0_INT;
unused_dc(1) <= PC_CFG_SLP_SL_THOLD_0_INT;
unused_dc(2) <= PC_FUNC_NSL_THOLD_0_INT;
unused_dc(3) <= PC_FUNC_SLP_NSL_THOLD_0_INT;
unused_dc(4) <= or_reduce(PC_FUNC_SL_FORCE_INT);
unused_dc(5) <= or_reduce(PC_FUNC_SLP_SL_FORCE_INT);


end mmq_perv;

