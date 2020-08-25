-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--********************************************************************
--*
--* TITLE: Instruction Unit Repower
--*
--* NAME: iuq_rp.vhdl
--*
--*********************************************************************


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

entity iuq_rp is
generic(expand_type : integer := 2 ); -- 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     scan_diag_dc               : in  std_ulogic;
     scan_dis_dc_b              : in  std_ulogic; 
     -- node thold+clock controls going to pcq
     an_ac_ccflush_dc           : in  std_ulogic;
     rtim_sl_thold_7            : in  std_ulogic;
     func_sl_thold_7            : in  std_ulogic;
     func_nsl_thold_7           : in  std_ulogic;
     ary_nsl_thold_7            : in  std_ulogic;
     sg_7                       : in  std_ulogic;
     fce_7                      : in  std_ulogic;
     rtim_sl_thold_6            : out std_ulogic;     
     func_sl_thold_6            : out std_ulogic;     
     func_nsl_thold_6           : out std_ulogic;    
     ary_nsl_thold_6            : out std_ulogic;     
     sg_6                       : out std_ulogic;                
     fce_6                      : out std_ulogic;               
     -- node inputs going to pcq
     an_ac_scom_dch             : in  std_ulogic;
     an_ac_scom_cch             : in  std_ulogic;
     an_ac_checkstop            : in  std_ulogic;
     an_ac_debug_stop           : in  std_ulogic;
     an_ac_pm_thread_stop       : in  std_ulogic_vector(0 to 3); 
     an_ac_reset_1_complete     : in  std_ulogic;
     an_ac_reset_2_complete     : in  std_ulogic;
     an_ac_reset_3_complete     : in  std_ulogic;
     an_ac_reset_wd_complete    : in  std_ulogic;
     an_ac_abist_start_test     : in  std_ulogic;
     ac_rp_trace_to_perfcntr    : in  std_ulogic_vector(0 to 7); 
     rp_pc_scom_dch_q           : out std_ulogic;
     rp_pc_scom_cch_q           : out std_ulogic;
     rp_pc_checkstop_q          : out std_ulogic;
     rp_pc_debug_stop_q         : out std_ulogic;
     rp_pc_pm_thread_stop_q     : out std_ulogic_vector(0 to 3); 
     rp_pc_reset_1_complete_q   : out std_ulogic;
     rp_pc_reset_2_complete_q   : out std_ulogic;
     rp_pc_reset_3_complete_q   : out std_ulogic;
     rp_pc_reset_wd_complete_q  : out std_ulogic;
     rp_pc_abist_start_test_q   : out std_ulogic;
     rp_pc_trace_to_perfcntr_q  : out std_ulogic_vector(0 to 7); 
     -- pcq outputs going to node
     pc_rp_scom_dch             : in  std_ulogic;
     pc_rp_scom_cch             : in  std_ulogic;
     pc_rp_special_attn         : in  std_ulogic_vector(0 to 3);
     pc_rp_checkstop            : in  std_ulogic_vector(0 to 2);
     pc_rp_local_checkstop      : in  std_ulogic_vector(0 to 2);
     pc_rp_recov_err            : in  std_ulogic_vector(0 to 2);
     pc_rp_trace_error          : in  std_ulogic;
     pc_rp_event_bus_enable     : in  std_ulogic;
     pc_rp_event_bus            : in  std_ulogic_vector(0 to 7);
     pc_rp_fu_bypass_events     : in  std_ulogic_vector(0 to 7);
     pc_rp_iu_bypass_events     : in  std_ulogic_vector(0 to 7);
     pc_rp_mm_bypass_events     : in  std_ulogic_vector(0 to 7);
     pc_rp_lsu_bypass_events    : in  std_ulogic_vector(0 to 7);
     pc_rp_pm_thread_running    : in  std_ulogic_vector(0 to 3);
     pc_rp_power_managed        : in  std_ulogic;
     pc_rp_rvwinkle_mode        : in  std_ulogic;
     ac_an_scom_dch_q           : out std_ulogic;
     ac_an_scom_cch_q           : out std_ulogic;
     ac_an_special_attn_q       : out std_ulogic_vector(0 to 3);
     ac_an_checkstop_q          : out std_ulogic_vector(0 to 2);
     ac_an_local_checkstop_q    : out std_ulogic_vector(0 to 2);
     ac_an_recov_err_q          : out std_ulogic_vector(0 to 2);
     ac_an_trace_error_q        : out std_ulogic;
     rp_mm_event_bus_enable_q   : out std_ulogic;
     ac_an_event_bus_q          : out std_ulogic_vector(0 to 7);
     ac_an_fu_bypass_events_q   : out std_ulogic_vector(0 to 7);
     ac_an_iu_bypass_events_q   : out std_ulogic_vector(0 to 7);
     ac_an_mm_bypass_events_q   : out std_ulogic_vector(0 to 7);
     ac_an_lsu_bypass_events_q  : out std_ulogic_vector(0 to 7);
     ac_an_pm_thread_running_q  : out std_ulogic_vector(0 to 3);
     ac_an_power_managed_q      : out std_ulogic;
     ac_an_rvwinkle_mode_q      : out std_ulogic;



     -- scan_in/out signals being repowered
     pc_func_scan_in            : in  std_ulogic_vector(0 to 1);
     pc_func_scan_in_q          : out std_ulogic_vector(0 to 1);
     pc_func_scan_out           : in  std_ulogic;
     pc_func_scan_out_q         : out std_ulogic;
     pc_bcfg_scan_in            : in  std_ulogic; 
     pc_bcfg_scan_in_q          : out std_ulogic;
     pc_dcfg_scan_in            : in  std_ulogic; 
     pc_dcfg_scan_in_q          : out std_ulogic;
     pc_bcfg_scan_out           : in  std_ulogic;
     pc_bcfg_scan_out_q         : out std_ulogic;
     pc_ccfg_scan_out           : in  std_ulogic;
     pc_ccfg_scan_out_q         : out std_ulogic;
     pc_dcfg_scan_out           : in  std_ulogic;
     pc_dcfg_scan_out_q         : out std_ulogic;
     --
     fu_abst_scan_in            : in  std_ulogic;
     fu_abst_scan_in_q          : out std_ulogic;
     fu_abst_scan_out           : in  std_ulogic;
     fu_abst_scan_out_q         : out std_ulogic;
     fu_ccfg_scan_out           : in  std_ulogic;
     fu_ccfg_scan_out_q         : out std_ulogic;
     fu_bcfg_scan_out           : in  std_ulogic;
     fu_bcfg_scan_out_q         : out std_ulogic;
     fu_dcfg_scan_out           : in  std_ulogic;
     fu_dcfg_scan_out_q         : out std_ulogic;
     fu_func_scan_in            : in  std_ulogic_vector(0 to 3);
     fu_func_scan_in_q          : out std_ulogic_vector(0 to 3);
     fu_func_scan_out           : in  std_ulogic_vector(0 to 3);
     fu_func_scan_out_q         : out std_ulogic_vector(0 to 3);
     --
     bx_abst_scan_in            : in  std_ulogic;
     bx_abst_scan_in_q          : out std_ulogic;
     bx_abst_scan_out           : in  std_ulogic;
     bx_abst_scan_out_q         : out std_ulogic;
     bx_func_scan_in            : in  std_ulogic_vector(0 to 1);
     bx_func_scan_in_q          : out std_ulogic_vector(0 to 1);
     bx_func_scan_out           : in  std_ulogic_vector(0 to 1);
     bx_func_scan_out_q         : out std_ulogic_vector(0 to 1);
     --
     iu_func_scan_in            : in  std_ulogic_vector(0 to 8);
     iu_func_scan_in_q          : out std_ulogic_vector(0 to 8);
     iu_func_scan_out           : in  std_ulogic_vector(0 to 9);
     iu_func_scan_out_q         : out std_ulogic_vector(0 to 9);
     iu_bcfg_scan_in            : in  std_ulogic; 
     iu_bcfg_scan_in_q          : out std_ulogic;
     --
     spare_func_scan_in         : in  std_ulogic_vector(0 to 3);
     spare_func_scan_in_q       : out std_ulogic_vector(0 to 3);
     spare_func_scan_out        : in  std_ulogic_vector(0 to 3);
     spare_func_scan_out_q      : out std_ulogic_vector(0 to 3);

     -- BG repower
     bg_an_ac_func_scan_sn      : in  std_ulogic_vector(60 to 69);
     bg_an_ac_abst_scan_sn      : in  std_ulogic_vector(10 to 11);
     bg_an_ac_func_scan_sn_q    : out std_ulogic_vector(60 to 69);
     bg_an_ac_abst_scan_sn_q    : out std_ulogic_vector(10 to 11);

     bg_ac_an_func_scan_ns      : in  std_ulogic_vector(60 to 69);
     bg_ac_an_abst_scan_ns      : in  std_ulogic_vector(10 to 11);
     bg_ac_an_func_scan_ns_q    : out std_ulogic_vector(60 to 69);
     bg_ac_an_abst_scan_ns_q    : out std_ulogic_vector(10 to 11);

     bg_pc_l1p_abist_di_0       : in  std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t1p_renb_0  : in  std_ulogic;
     bg_pc_l1p_abist_g8t_bw_0   : in  std_ulogic;
     bg_pc_l1p_abist_g8t_bw_1   : in  std_ulogic;
     bg_pc_l1p_abist_g8t_dcomp  : in  std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t_wenb   : in  std_ulogic;
     bg_pc_l1p_abist_raddr_0    : in  std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_waddr_0    : in  std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_wl128_comp_ena : in  std_ulogic;
     bg_pc_l1p_abist_wl32_comp_ena  : in  std_ulogic;
     bg_pc_l1p_abist_di_0_q     : out std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t1p_renb_0_q  : out std_ulogic;
     bg_pc_l1p_abist_g8t_bw_0_q : out std_ulogic;
     bg_pc_l1p_abist_g8t_bw_1_q : out std_ulogic;
     bg_pc_l1p_abist_g8t_dcomp_q: out std_ulogic_vector(0 to 3);
     bg_pc_l1p_abist_g8t_wenb_q : out std_ulogic;
     bg_pc_l1p_abist_raddr_0_q  : out std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_waddr_0_q  : out std_ulogic_vector(0 to 9);
     bg_pc_l1p_abist_wl128_comp_ena_q : out std_ulogic;
     bg_pc_l1p_abist_wl32_comp_ena_q  : out std_ulogic;

     bg_pc_l1p_gptr_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_time_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_repr_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_abst_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_func_sl_thold_3  : in  std_ulogic_vector(0 to 1);
     bg_pc_l1p_func_slp_sl_thold_3 : in  std_ulogic;
     bg_pc_l1p_bolt_sl_thold_3  : in  std_ulogic;
     bg_pc_l1p_ary_nsl_thold_3  : in  std_ulogic;
     bg_pc_l1p_sg_3             : in  std_ulogic_vector(0 to 1);
     bg_pc_l1p_fce_3            : in  std_ulogic;
     bg_pc_l1p_bo_enable_3      : in  std_ulogic;
     bg_pc_l1p_gptr_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_time_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_repr_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_abst_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_func_sl_thold_2  : out std_ulogic_vector(0 to 1);
     bg_pc_l1p_func_slp_sl_thold_2 : out std_ulogic;
     bg_pc_l1p_bolt_sl_thold_2  : out std_ulogic;
     bg_pc_l1p_ary_nsl_thold_2  : out std_ulogic;
     bg_pc_l1p_sg_2             : out std_ulogic_vector(0 to 1);
     bg_pc_l1p_fce_2            : out std_ulogic;
     bg_pc_l1p_bo_enable_2      : out std_ulogic;

     -- Misc bolton signals
     pc_mm_bo_enable_4          : in  std_ulogic;
     pc_iu_bo_enable_4          : in  std_ulogic;
     pc_mm_bo_enable_3          : out std_ulogic;
     pc_iu_bo_enable_3          : out std_ulogic;
     -- IU+MMU thold/sg/fce 4to3 PLAT staging
     pc_iu_gptr_sl_thold_4      : in  std_ulogic;
     pc_iu_time_sl_thold_4      : in  std_ulogic;
     pc_iu_repr_sl_thold_4      : in  std_ulogic;
     pc_iu_abst_sl_thold_4      : in  std_ulogic;
     pc_iu_abst_slp_sl_thold_4  : in  std_ulogic;
     pc_iu_bolt_sl_thold_4      : in  std_ulogic;
     pc_iu_regf_slp_sl_thold_4  : in  std_ulogic;
     pc_iu_func_sl_thold_4      : in  std_ulogic;
     pc_iu_func_slp_sl_thold_4  : in  std_ulogic;
     pc_iu_cfg_sl_thold_4       : in  std_ulogic;
     pc_iu_cfg_slp_sl_thold_4   : in  std_ulogic;
     pc_iu_func_nsl_thold_4     : in  std_ulogic;
     pc_iu_func_slp_nsl_thold_4 : in  std_ulogic;
     pc_iu_ary_nsl_thold_4      : in  std_ulogic;
     pc_iu_ary_slp_nsl_thold_4  : in  std_ulogic;
     pc_iu_sg_4                 : in  std_ulogic;
     pc_iu_fce_4                : in  std_ulogic;
     pc_iu_gptr_sl_thold_3      : out std_ulogic;
     pc_iu_time_sl_thold_3      : out std_ulogic;
     pc_iu_repr_sl_thold_3      : out std_ulogic;
     pc_iu_abst_sl_thold_3      : out std_ulogic;
     pc_iu_abst_slp_sl_thold_3  : out std_ulogic;
     pc_iu_bolt_sl_thold_3      : out std_ulogic;
     pc_iu_regf_slp_sl_thold_3  : out std_ulogic;
     pc_iu_func_sl_thold_3      : out std_ulogic_vector(0 to 3);
     pc_iu_func_slp_sl_thold_3  : out std_ulogic;
     pc_iu_cfg_sl_thold_3       : out std_ulogic;
     pc_iu_cfg_slp_sl_thold_3   : out std_ulogic;
     pc_iu_func_slp_nsl_thold_3 : out std_ulogic;
     pc_iu_ary_nsl_thold_3      : out std_ulogic;
     pc_iu_ary_slp_nsl_thold_3  : out std_ulogic;
     pc_iu_sg_3                 : out std_ulogic_vector(0 to 3);
     pc_iu_fce_3                : out std_ulogic;
     pc_mm_gptr_sl_thold_3      : out std_ulogic;
     pc_mm_time_sl_thold_3      : out std_ulogic;
     pc_mm_repr_sl_thold_3      : out std_ulogic;
     pc_mm_abst_sl_thold_3      : out std_ulogic;
     pc_mm_abst_slp_sl_thold_3  : out std_ulogic;
     pc_mm_bolt_sl_thold_3      : out std_ulogic;
     pc_mm_func_sl_thold_3      : out std_ulogic_vector(0 to 1);
     pc_mm_func_slp_sl_thold_3  : out std_ulogic_vector(0 to 1);
     pc_mm_cfg_sl_thold_3       : out std_ulogic;
     pc_mm_cfg_slp_sl_thold_3   : out std_ulogic;
     pc_mm_func_nsl_thold_3     : out std_ulogic;
     pc_mm_func_slp_nsl_thold_3 : out std_ulogic;
     pc_mm_ary_nsl_thold_3      : out std_ulogic;
     pc_mm_ary_slp_nsl_thold_3  : out std_ulogic;
     pc_mm_sg_3                 : out std_ulogic_vector(0 to 1);
     pc_mm_fce_3                : out std_ulogic;

     -- tholds and scan chains
     sg_2                       : in  std_ulogic;       
     func_sl_thold_2            : in  std_ulogic;     
     func_slp_sl_thold_2        : in  std_ulogic;     
     abst_sl_thold_2            : in  std_ulogic;       
     abst_scan_in               : in  std_ulogic;
     func_scan_in               : in  std_ulogic;
     gptr_scan_in               : in  std_ulogic;
     abst_scan_out              : out std_ulogic;
     func_scan_out              : out std_ulogic;
     gptr_scan_out              : out std_ulogic
);

-- synopsys translate_off


-- synopsys translate_on

end iuq_rp;
----
architecture iuq_rp of iuq_rp is

-- ABIST Scan Ring
constant abst_size                      : positive := 1;
constant abst_bg_size                   : positive := 34;
-- start of abist scan chain ordering
constant abst_offset                    : natural := 0;
constant abst_bg_offset                 : natural := abst_offset + abst_size;
constant abst_right                     : natural := abst_bg_offset + abst_bg_size - 1;
-- end of abist scan chain ordering

-- FUNC Scan Ring
constant perf_size                      : positive := 40;
constant func1_size                     : positive := 12;
constant func2_size                     : positive := 31;
-- start of func scan chain ordering
constant perf_offset                    : natural := 0;
constant func1_offset                   : natural := perf_offset + perf_size;
constant func2_offset                   : natural := func1_offset + func1_size;
constant func_right                     : natural := func2_offset + func2_size - 1;
-- end of func scan chain ordering

signal abst_siv, abst_sov               : std_ulogic_vector(0 to abst_right);
signal func_siv, func_sov               : std_ulogic_vector(0 to func_right);

signal slat_force                       : std_ulogic;
signal func_slat_thold_b                : std_ulogic;
signal func_slat_d2clk                  : std_ulogic;
signal func_slat_lclk                   : clk_logic;
signal abst_slat_thold_b                : std_ulogic;
signal abst_slat_d2clk                  : std_ulogic;
signal abst_slat_lclk                   : clk_logic;
signal cfg_slat_thold_b                 : std_ulogic;
signal cfg_slat_d2clk                   : std_ulogic;
signal cfg_slat_lclk                    : clk_logic;

signal gptr_sl_thold_3_int              : std_ulogic;      
signal cfg_sl_thold_3_int               : std_ulogic;
signal gptr_sl_thold_2                  : std_ulogic;      
signal cfg_sl_thold_2                   : std_ulogic;
signal sg_1                             : std_ulogic;
signal func_sl_thold_1                  : std_ulogic;      
signal func_slp_sl_thold_1              : std_ulogic;      
signal gptr_sl_thold_1                  : std_ulogic;      
signal abst_sl_thold_1                  : std_ulogic;       
signal cfg_sl_thold_1                   : std_ulogic;       
signal sg_0                             : std_ulogic;       
signal func_sl_thold_0                  : std_ulogic;      
signal func_sl_thold_0_b                : std_ulogic;       
signal force_func                       : std_ulogic;
signal func_slp_sl_thold_0              : std_ulogic;      
signal func_slp_sl_thold_0_b            : std_ulogic;      
signal force_func_slp                   : std_ulogic;
signal gptr_sl_thold_0                  : std_ulogic;      
signal abst_sl_thold_0                  : std_ulogic;       
signal abst_sl_thold_0_b                : std_ulogic;       
signal force_abst                       : std_ulogic;
signal cfg_sl_thold_0                   : std_ulogic;

signal clkoff_b                         : std_ulogic;
signal act_dis                          : std_ulogic;
signal d_mode                           : std_ulogic;
signal delay_lclkr                      : std_ulogic_vector(0 to 4);
signal mpw1_b                           : std_ulogic_vector(0 to 4);
signal mpw2_b                           : std_ulogic;

signal event_bus_enable_int             : std_ulogic;
signal unused                           : std_ulogic;

-- synopsys translate_off
-- synopsys translate_on

begin

-- Outputs
rp_mm_event_bus_enable_q   <=  event_bus_enable_int;
pc_iu_gptr_sl_thold_3      <=  gptr_sl_thold_3_int;
pc_iu_cfg_sl_thold_3       <=  cfg_sl_thold_3_int;



-- ----------------------------------
perv_3to2_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd           => vdd,
            gd           => gnd,
            nclk         => nclk,
            flush        => an_ac_ccflush_dc,
            din(0)       => gptr_sl_thold_3_int,
            din(1)       => cfg_sl_thold_3_int,
            q(0)         => gptr_sl_thold_2,
            q(1)         => cfg_sl_thold_2);

perv_2to1_reg: tri_plat
  generic map (width => 6, expand_type => expand_type)
  port map (vd           => vdd,
            gd           => gnd,
            nclk         => nclk,
            flush        => an_ac_ccflush_dc,
            din(0)       => func_sl_thold_2,
            din(1)       => func_slp_sl_thold_2,
            din(2)       => gptr_sl_thold_2,
            din(3)       => abst_sl_thold_2,
            din(4)       => cfg_sl_thold_2,
            din(5)       => sg_2,
            q(0)         => func_sl_thold_1,
            q(1)         => func_slp_sl_thold_1,
            q(2)         => gptr_sl_thold_1,
            q(3)         => abst_sl_thold_1,
            q(4)         => cfg_sl_thold_1,
            q(5)         => sg_1);

perv_1to0_reg: tri_plat
  generic map (width => 6, expand_type => expand_type)
  port map (vd           => vdd,
            gd           => gnd,
            nclk         => nclk,
            flush        => an_ac_ccflush_dc,
            din(0)       => func_sl_thold_1,
            din(1)       => func_slp_sl_thold_1,
            din(2)       => gptr_sl_thold_1,
            din(3)       => abst_sl_thold_1,
            din(4)       => cfg_sl_thold_1,
            din(5)       => sg_1,
            q(0)         => func_sl_thold_0,
            q(1)         => func_slp_sl_thold_0,
            q(2)         => gptr_sl_thold_0,
            q(3)         => abst_sl_thold_0,
            q(4)         => cfg_sl_thold_0,
            q(5)         => sg_0);


perv_lcbcntl: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
  port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0,
            nclk           => nclk,
            scan_in        => gptr_scan_in,
            scan_diag_dc   => scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => clkoff_b,
            delay_lclkr_dc => delay_lclkr(0 to 4),
            act_dis_dc     => act_dis,
            d_mode_dc      => d_mode,
            mpw1_dc_b      => mpw1_b(0 to 4),
            mpw2_dc_b      => mpw2_b,
            scan_out       => gptr_scan_out);

unused <= or_reduce(delay_lclkr(1 to 4) &
                    d_mode &
                    mpw1_b(1 to 4) );

abst_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => abst_sl_thold_0,
            sg          => sg_0,
            act_dis     => act_dis,
            forcee => force_abst,
            thold_b     => abst_sl_thold_0_b);

func_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => func_sl_thold_0,
            sg          => sg_0,
            act_dis     => act_dis,
            forcee => force_func,
            thold_b     => func_sl_thold_0_b);

func_slp_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => func_slp_sl_thold_0,
            sg          => sg_0,
            act_dis     => act_dis,
            forcee => force_func_slp,
            thold_b     => func_slp_sl_thold_0_b);


-- LCBs for scan only staging latches
slat_force   <= sg_0;
func_slat_thold_b <= NOT func_sl_thold_0;
abst_slat_thold_b <= NOT abst_sl_thold_0;
cfg_slat_thold_b  <= NOT cfg_sl_thold_0;

lcbs_func: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr(0),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => func_slat_thold_b,
      dclk        => func_slat_d2clk,
      lclk        => func_slat_lclk );

lcbs_abst: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr(0),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => abst_slat_thold_b,
      dclk        => abst_slat_d2clk,
      lclk        => abst_slat_lclk );

lcbs_cfg: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr(0),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => cfg_slat_thold_b,
      dclk        => cfg_slat_d2clk,
      lclk        => cfg_slat_lclk );

-- Stages pcq clock control inputs
pcq_lvl7to6: tri_plat
   generic map( width => 6, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => an_ac_ccflush_dc,
             din( 0) => rtim_sl_thold_7,
             din( 1) => func_sl_thold_7,
             din( 2) => func_nsl_thold_7,
             din( 3) => ary_nsl_thold_7,
             din( 4) => sg_7,
             din( 5) => fce_7,
             q( 0)   => rtim_sl_thold_6,
             q( 1)   => func_sl_thold_6,
             q( 2)   => func_nsl_thold_6,
             q( 3)   => ary_nsl_thold_6,
             q( 4)   => sg_6,
             q( 5)   => fce_6
           ); 


-- Stages bg clock control inputs
bg_lvl3to2: tri_plat
   generic map( width => 13, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => an_ac_ccflush_dc,
             din( 0) => bg_pc_l1p_gptr_sl_thold_3,
             din( 1) => bg_pc_l1p_time_sl_thold_3,
             din( 2) => bg_pc_l1p_repr_sl_thold_3,
             din( 3) => bg_pc_l1p_abst_sl_thold_3,
             din( 4) => bg_pc_l1p_func_sl_thold_3(0),
             din( 5) => bg_pc_l1p_func_sl_thold_3(1),
             din( 6) => bg_pc_l1p_func_slp_sl_thold_3,
             din( 7) => bg_pc_l1p_bolt_sl_thold_3,
             din( 8) => bg_pc_l1p_ary_nsl_thold_3,
             din( 9) => bg_pc_l1p_sg_3(0),
             din(10) => bg_pc_l1p_sg_3(1),
             din(11) => bg_pc_l1p_fce_3,
             din(12) => bg_pc_l1p_bo_enable_3,
             q( 0)   => bg_pc_l1p_gptr_sl_thold_2,
             q( 1)   => bg_pc_l1p_time_sl_thold_2,
             q( 2)   => bg_pc_l1p_repr_sl_thold_2,
             q( 3)   => bg_pc_l1p_abst_sl_thold_2,
             q( 4)   => bg_pc_l1p_func_sl_thold_2(0),
             q( 5)   => bg_pc_l1p_func_sl_thold_2(1),
             q( 6)   => bg_pc_l1p_func_slp_sl_thold_2,
             q( 7)   => bg_pc_l1p_bolt_sl_thold_2,
             q( 8)   => bg_pc_l1p_ary_nsl_thold_2,
             q( 9)   => bg_pc_l1p_sg_2(0),
             q(10)   => bg_pc_l1p_sg_2(1),
             q(11)   => bg_pc_l1p_fce_2,
             q(12)   => bg_pc_l1p_bo_enable_2
           ); 
-- Staging latches for scan_in/out signals on abist rings
fu_abst_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => abst_slat_d2clk,
              lclk  => abst_slat_lclk,
              scan_in(0)   => fu_abst_scan_in,
              scan_in(1)   => fu_abst_scan_out,
              scan_out(0)  => fu_abst_scan_in_q,
              scan_out(1)  => fu_abst_scan_out_q );

bx_abst_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => abst_slat_d2clk,
              lclk  => abst_slat_lclk,
              scan_in(0)   => bx_abst_scan_in,
              scan_in(1)   => bx_abst_scan_out,
              scan_out(0)  => bx_abst_scan_in_q,
              scan_out(1)  => bx_abst_scan_out_q );

bg_abst_stg: tri_slat_scan  
   generic map (width => 4, init => "0000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => abst_slat_d2clk,
              lclk  => abst_slat_lclk,
              scan_in(0 to 1)   => bg_an_ac_abst_scan_sn(10 to 11),
              scan_in(2 to 3)   => bg_ac_an_abst_scan_ns(10 to 11),
              scan_out(0 to 1)  => bg_an_ac_abst_scan_sn_q(10 to 11),
              scan_out(2 to 3)  => bg_ac_an_abst_scan_ns_q(10 to 11) );

-- Staging latches for scan_in/out signals on func rings
pc_func_stg: tri_slat_scan  
   generic map (width => 3, init => "000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => func_slat_d2clk,
              lclk  => func_slat_lclk,
              scan_in(0 to 1) => pc_func_scan_in(0 to 1),
              scan_in(2)  => pc_func_scan_out,
              scan_out(0 to 1)=> pc_func_scan_in_q(0 to 1),
              scan_out(2) => pc_func_scan_out_q );

fu_func_stg: tri_slat_scan  
   generic map (width => 8, init => "00000000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => func_slat_d2clk,
              lclk  => func_slat_lclk,
              scan_in(0 to 3)   => fu_func_scan_in(0 to 3),
              scan_in(4 to 7)   => fu_func_scan_out(0 to 3),
              scan_out(0 to 3)  => fu_func_scan_in_q(0 to 3),
              scan_out(4 to 7)  => fu_func_scan_out_q(0 to 3) );

bx_func_stg: tri_slat_scan  
   generic map (width => 4, init => "0000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => func_slat_d2clk,
              lclk  => func_slat_lclk,
              scan_in(0 to 1)   => bx_func_scan_in(0 to 1),
              scan_in(2 to 3)   => bx_func_scan_out(0 to 1),
              scan_out(0 to 1)  => bx_func_scan_in_q(0 to 1),
              scan_out(2 to 3)  => bx_func_scan_out_q(0 to 1) );

iu_func_stg: tri_slat_scan  
   generic map (width => 19, init => "0000000000000000000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => func_slat_d2clk,
              lclk  => func_slat_lclk,
              scan_in(0 to 8)   => iu_func_scan_in(0 to 8),
              scan_in(9 to 18)  => iu_func_scan_out(0 to 9),
              scan_out(0 to 8)  => iu_func_scan_in_q(0 to 8),
              scan_out(9 to 18) => iu_func_scan_out_q(0 to 9) );

spare_func_stg: tri_slat_scan  
   generic map (width => 8, init => "00000000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => func_slat_d2clk,
              lclk  => func_slat_lclk,
              scan_in(0 to 3)   => spare_func_scan_in(0 to 3),
              scan_in(4 to 7)   => spare_func_scan_out(0 to 3),
              scan_out(0 to 3)  => spare_func_scan_in_q(0 to 3),
              scan_out(4 to 7)  => spare_func_scan_out_q(0 to 3) );

bg_func_stg: tri_slat_scan  
   generic map (width => 20, init => "00000000000000000000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => func_slat_d2clk,
              lclk  => func_slat_lclk,
              scan_in(0 to 9)   => bg_an_ac_func_scan_sn(60 to 69),
              scan_in(10 to 19) => bg_ac_an_func_scan_ns(60 to 69),
              scan_out(0 to 9)  => bg_an_ac_func_scan_sn_q(60 to 69),
              scan_out(10 to 19)=> bg_ac_an_func_scan_ns_q(60 to 69) );

-- Staging latches for scan_in/out signals on config rings
pc_cfg_stg: tri_slat_scan  
   generic map (width => 5, init => "00000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => cfg_slat_d2clk,
              lclk  => cfg_slat_lclk,
              scan_in(0)   => pc_bcfg_scan_in,
              scan_in(1)   => pc_dcfg_scan_in,
              scan_in(2)   => pc_bcfg_scan_out,
              scan_in(3)   => pc_ccfg_scan_out,
              scan_in(4)   => pc_dcfg_scan_out,
              scan_out(0)  => pc_bcfg_scan_in_q,
              scan_out(1)  => pc_dcfg_scan_in_q,
              scan_out(2)  => pc_bcfg_scan_out_q,
              scan_out(3)  => pc_ccfg_scan_out_q,
              scan_out(4)  => pc_dcfg_scan_out_q );

fu_cfg_stg: tri_slat_scan  
   generic map (width => 3, init => "000", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => cfg_slat_d2clk,
              lclk  => cfg_slat_lclk,
              scan_in(0)   => fu_bcfg_scan_out,
              scan_in(1)   => fu_ccfg_scan_out,
              scan_in(2)   => fu_dcfg_scan_out,
              scan_out(0)  => fu_bcfg_scan_out_q,
              scan_out(1)  => fu_ccfg_scan_out_q,
              scan_out(2)  => fu_dcfg_scan_out_q );

iu_cfg_stg: tri_slat_scan  
   generic map (width => 1, init => "0", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => cfg_slat_d2clk,
              lclk  => cfg_slat_lclk,
              scan_in(0)   => iu_bcfg_scan_in,
              scan_out(0)  => iu_bcfg_scan_in_q );

-- Misc staging latches on abist ring
abist_staging: tri_rlmreg_p  
   generic map (width => abst_size, init => 0, expand_type => expand_type)
   port map ( vd       => vdd,
              gd       => gnd,
              nclk     => nclk,
              act      => '1',
              thold_b  => abst_sl_thold_0_b,
              sg       => sg_0,
              forcee => force_abst,
              delay_lclkr => delay_lclkr(0),
              mpw1_b   => mpw1_b(0),
              mpw2_b   => mpw2_b,
              scin     => abst_siv(abst_offset to abst_offset + abst_size-1),
              scout    => abst_sov(abst_offset to abst_offset + abst_size-1),
              din(0)   => an_ac_abist_start_test,
              dout(0)  => rp_pc_abist_start_test_q );

abist_bg_staging: tri_rlmreg_p  
   generic map (width => abst_bg_size, init => 0, expand_type => expand_type)
   port map ( vd       => vdd,
              gd       => gnd,
              nclk     => nclk,
              act      => '1',
              thold_b  => abst_sl_thold_0_b,
              sg       => sg_0,
              forcee => force_abst,
              delay_lclkr => delay_lclkr(0),
              mpw1_b   => mpw1_b(0),
              mpw2_b   => mpw2_b,
              scin     => abst_siv(abst_bg_offset to abst_bg_offset + abst_bg_size-1),
              scout    => abst_sov(abst_bg_offset to abst_bg_offset + abst_bg_size-1),
              din( 0 to  3) => bg_pc_l1p_abist_di_0,
              din( 4)       => bg_pc_l1p_abist_g8t1p_renb_0,
              din( 5)       => bg_pc_l1p_abist_g8t_bw_0,
              din( 6)       => bg_pc_l1p_abist_g8t_bw_1,
              din( 7 to 10) => bg_pc_l1p_abist_g8t_dcomp,
              din(11)       => bg_pc_l1p_abist_g8t_wenb,
              din(12 to 21) => bg_pc_l1p_abist_raddr_0,
              din(22 to 31) => bg_pc_l1p_abist_waddr_0,
              din(32)       => bg_pc_l1p_abist_wl128_comp_ena,
              din(33)       => bg_pc_l1p_abist_wl32_comp_ena,
              dout( 0 to  3) => bg_pc_l1p_abist_di_0_q,
              dout( 4)       => bg_pc_l1p_abist_g8t1p_renb_0_q,
              dout( 5)       => bg_pc_l1p_abist_g8t_bw_0_q,
              dout( 6)       => bg_pc_l1p_abist_g8t_bw_1_q,
              dout( 7 to 10) => bg_pc_l1p_abist_g8t_dcomp_q,
              dout(11)       => bg_pc_l1p_abist_g8t_wenb_q,
              dout(12 to 21) => bg_pc_l1p_abist_raddr_0_q,
              dout(22 to 31) => bg_pc_l1p_abist_waddr_0_q,
              dout(32)       => bg_pc_l1p_abist_wl128_comp_ena_q,
              dout(33)       => bg_pc_l1p_abist_wl32_comp_ena_q );

-- Misc staging latches on func ring
perf_staging: tri_rlmreg_p  
   generic map (width => perf_size, init => 0, expand_type => expand_type)
   port map ( vd       => vdd,
              gd       => gnd,
              nclk     => nclk,
              act      => event_bus_enable_int,
              thold_b  => func_sl_thold_0_b,
              sg       => sg_0,
              forcee => force_func,
              delay_lclkr => delay_lclkr(0),
              mpw1_b   => mpw1_b(0),
              mpw2_b   => mpw2_b,
              scin     => func_siv(perf_offset to perf_offset + perf_size-1),
              scout    => func_sov(perf_offset to perf_offset + perf_size-1),
              din(0  to  7) => pc_rp_event_bus,
              din(8  to 15) => pc_rp_fu_bypass_events,
              din(16 to 23) => pc_rp_iu_bypass_events,
              din(24 to 31) => pc_rp_mm_bypass_events,
              din(32 to 39) => pc_rp_lsu_bypass_events,

              dout(0  to  7) => ac_an_event_bus_q,
              dout(8  to 15) => ac_an_fu_bypass_events_q,
              dout(16 to 23) => ac_an_iu_bypass_events_q,
              dout(24 to 31) => ac_an_mm_bypass_events_q,
              dout(32 to 39) => ac_an_lsu_bypass_events_q  );


func_staging: tri_rlmreg_p  
   generic map (width => func1_size, init => 0, expand_type => expand_type)
   port map ( vd       => vdd,
              gd       => gnd,
              nclk     => nclk,
              act      => '1',
              thold_b  => func_sl_thold_0_b,
              sg       => sg_0,
              forcee => force_func,
              delay_lclkr => delay_lclkr(0),
              mpw1_b   => mpw1_b(0),
              mpw2_b   => mpw2_b,
              scin     => func_siv(func1_offset to func1_offset + func1_size-1),
              scout    => func_sov(func1_offset to func1_offset + func1_size-1),
              din(0)   => an_ac_reset_1_complete,
              din(1)   => an_ac_reset_2_complete,
              din(2)   => an_ac_reset_3_complete,
              din(3)   => an_ac_reset_wd_complete,
              din(4 to 11)=> ac_rp_trace_to_perfcntr,

              dout(0)  => rp_pc_reset_1_complete_q,
              dout(1)  => rp_pc_reset_2_complete_q,
              dout(2)  => rp_pc_reset_3_complete_q,
              dout(3)  => rp_pc_reset_wd_complete_q,
              dout(4 to 11)=> rp_pc_trace_to_perfcntr_q );

func_slp_staging: tri_rlmreg_p  
   generic map (width => func2_size, init => 0, expand_type => expand_type)
   port map ( vd       => vdd,
              gd       => gnd,
              nclk     => nclk,
              act      => '1',
              thold_b  => func_slp_sl_thold_0_b,
              sg       => sg_0,
              forcee => force_func_slp,
              delay_lclkr => delay_lclkr(0),
              mpw1_b   => mpw1_b(0),
              mpw2_b   => mpw2_b,
              scin     => func_siv(func2_offset to func2_offset + func2_size-1),
              scout    => func_sov(func2_offset to func2_offset + func2_size-1),
              din(0)   => an_ac_scom_dch,
              din(1)   => an_ac_scom_cch,
              din(2)   => an_ac_checkstop,
              din(3)   => an_ac_debug_stop,
              din(4 to 7) => an_ac_pm_thread_stop,
              din(8)  => pc_rp_scom_dch,
              din(9)  => pc_rp_scom_cch,
              din(10 to 13) => pc_rp_special_attn,
              din(14 to 16) => pc_rp_checkstop,
              din(17 to 19) => pc_rp_local_checkstop,
              din(20 to 22) => pc_rp_recov_err,
              din(23 to 26) => pc_rp_pm_thread_running,
              din(27)  => pc_rp_power_managed,
              din(28)  => pc_rp_rvwinkle_mode,
              din(29)  => pc_rp_event_bus_enable,
              din(30)  => pc_rp_trace_error,

              dout(0)  => rp_pc_scom_dch_q,
              dout(1)  => rp_pc_scom_cch_q,
              dout(2)  => rp_pc_checkstop_q,
              dout(3)  => rp_pc_debug_stop_q,
              dout(4 to 7) => rp_pc_pm_thread_stop_q,
              dout(8) => ac_an_scom_dch_q,
              dout(9) => ac_an_scom_cch_q,
              dout(10 to 13) => ac_an_special_attn_q,
              dout(14 to 16) => ac_an_checkstop_q,
              dout(17 to 19) => ac_an_local_checkstop_q,
              dout(20 to 22) => ac_an_recov_err_q,
              dout(23 to 26) => ac_an_pm_thread_running_q,
              dout(27)  => ac_an_power_managed_q,
              dout(28)  => ac_an_rvwinkle_mode_q,
              dout(29)  => event_bus_enable_int,
              dout(30)  => ac_an_trace_error_q );


-- Misc bolton signals
iu_bo_enab_4_3: tri_plat
  generic map (width => 1, expand_type => expand_type)
  port map (vd        => vdd,
            gd        => gnd,
            nclk      => nclk,
            flush     => an_ac_ccflush_dc,
            din(0)    => pc_iu_bo_enable_4,
            q(0)      => pc_iu_bo_enable_3);

mm_bo_enab_4_3: tri_plat
  generic map (width => 1, expand_type => expand_type)
  port map (vd        => vdd,
            gd        => gnd,
            nclk      => nclk,
            flush     => an_ac_ccflush_dc,
            din(0)    => pc_mm_bo_enable_4,
            q(0)      => pc_mm_bo_enable_3 );

-- IU+MMU thold/sg/fce 4to3 PLAT staging
iu_thold_stg4to3: tri_plat   
   generic map( width => 22, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => an_ac_ccflush_dc,
             din( 0) => pc_iu_gptr_sl_thold_4,
             din( 1) => pc_iu_time_sl_thold_4,
             din( 2) => pc_iu_repr_sl_thold_4,
             din( 3) => pc_iu_abst_sl_thold_4,
             din( 4) => pc_iu_abst_slp_sl_thold_4,
             din( 5) => pc_iu_bolt_sl_thold_4,
             din( 6) => pc_iu_regf_slp_sl_thold_4,
             din( 7) => pc_iu_func_sl_thold_4,
             din( 8) => pc_iu_func_sl_thold_4,
             din( 9) => pc_iu_func_sl_thold_4,
             din(10) => pc_iu_func_sl_thold_4,
             din(11) => pc_iu_func_slp_sl_thold_4,
             din(12) => pc_iu_cfg_sl_thold_4,
             din(13) => pc_iu_cfg_slp_sl_thold_4,
             din(14) => pc_iu_func_slp_nsl_thold_4,
             din(15) => pc_iu_ary_nsl_thold_4,
             din(16) => pc_iu_ary_slp_nsl_thold_4,
             din(17) => pc_iu_sg_4,
             din(18) => pc_iu_sg_4,
             din(19) => pc_iu_sg_4,
             din(20) => pc_iu_sg_4,
             din(21) => pc_iu_fce_4,
             q( 0)   => gptr_sl_thold_3_int,
             q( 1)   => pc_iu_time_sl_thold_3,
             q( 2)   => pc_iu_repr_sl_thold_3,
             q( 3)   => pc_iu_abst_sl_thold_3,
             q( 4)   => pc_iu_abst_slp_sl_thold_3,
             q( 5)   => pc_iu_bolt_sl_thold_3,
             q( 6)   => pc_iu_regf_slp_sl_thold_3,
             q( 7)   => pc_iu_func_sl_thold_3(0),
             q( 8)   => pc_iu_func_sl_thold_3(1),
             q( 9)   => pc_iu_func_sl_thold_3(2),
             q(10)   => pc_iu_func_sl_thold_3(3),
             q(11)   => pc_iu_func_slp_sl_thold_3,
             q(12)   => cfg_sl_thold_3_int,
             q(13)   => pc_iu_cfg_slp_sl_thold_3,
             q(14)   => pc_iu_func_slp_nsl_thold_3,
             q(15)   => pc_iu_ary_nsl_thold_3,
             q(16)   => pc_iu_ary_slp_nsl_thold_3,
             q(17)   => pc_iu_sg_3(0),
             q(18)   => pc_iu_sg_3(1),
             q(19)   => pc_iu_sg_3(2),
             q(20)   => pc_iu_sg_3(3),
             q(21)   => pc_iu_fce_3
          ); 


mm_thold_stg4to3: tri_plat   
   generic map( width => 19, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => an_ac_ccflush_dc,
             din( 0) => pc_iu_gptr_sl_thold_4,
             din( 1) => pc_iu_time_sl_thold_4,
             din( 2) => pc_iu_repr_sl_thold_4,
             din( 3) => pc_iu_abst_sl_thold_4,
             din( 4) => pc_iu_abst_slp_sl_thold_4,
             din( 5) => pc_iu_bolt_sl_thold_4,
             din( 6) => pc_iu_func_sl_thold_4,
             din( 7) => pc_iu_func_sl_thold_4,
             din( 8) => pc_iu_func_slp_sl_thold_4,
             din( 9) => pc_iu_func_slp_sl_thold_4,
             din(10) => pc_iu_cfg_sl_thold_4,
             din(11) => pc_iu_cfg_slp_sl_thold_4,
             din(12) => pc_iu_func_nsl_thold_4,
             din(13) => pc_iu_func_slp_nsl_thold_4,
             din(14) => pc_iu_ary_nsl_thold_4,
             din(15) => pc_iu_ary_slp_nsl_thold_4,
             din(16) => pc_iu_sg_4,
             din(17) => pc_iu_sg_4,
             din(18) => pc_iu_fce_4,
             q( 0)   => pc_mm_gptr_sl_thold_3,
             q( 1)   => pc_mm_time_sl_thold_3,
             q( 2)   => pc_mm_repr_sl_thold_3,
             q( 3)   => pc_mm_abst_sl_thold_3,
             q( 4)   => pc_mm_abst_slp_sl_thold_3,
             q( 5)   => pc_mm_bolt_sl_thold_3,
             q( 6)   => pc_mm_func_sl_thold_3(0),
             q( 7)   => pc_mm_func_sl_thold_3(1),
             q( 8)   => pc_mm_func_slp_sl_thold_3(0),
             q( 9)   => pc_mm_func_slp_sl_thold_3(1),
             q(10)   => pc_mm_cfg_sl_thold_3,
             q(11)   => pc_mm_cfg_slp_sl_thold_3,
             q(12)   => pc_mm_func_nsl_thold_3,
             q(13)   => pc_mm_func_slp_nsl_thold_3,
             q(14)   => pc_mm_ary_nsl_thold_3,
             q(15)   => pc_mm_ary_slp_nsl_thold_3,
             q(16)   => pc_mm_sg_3(0),
             q(17)   => pc_mm_sg_3(1),
             q(18)   => pc_mm_fce_3
          ); 

-- Scan Ring Connections
-- abist ring
abst_siv(0 TO abst_right) <=  abst_scan_in & abst_sov(0 to abst_right-1);
abst_scan_out  <=  abst_sov(abst_right) and scan_dis_dc_b;

--func ring
func_siv(0 TO func_right) <=  func_scan_in & func_sov(0 to func_right-1);
func_scan_out <=  func_sov(func_right) and scan_dis_dc_b;

end iuq_rp;
