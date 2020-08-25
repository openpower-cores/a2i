-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--  Description: Pervasive Core LCB Controls
--
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_clks is
generic(expand_type             : integer := 2          -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
);         
port(
    vdd                         : inout power_logic;
    gnd                         : inout power_logic;
    nclk                        : in    clk_logic;
    rtim_sl_thold_6             : in    std_ulogic;
    func_sl_thold_6             : in    std_ulogic;
    func_nsl_thold_6            : in    std_ulogic;
    ary_nsl_thold_6             : in    std_ulogic;
    sg_6                        : in    std_ulogic;
    fce_6                       : in    std_ulogic;
    gsd_test_enable_dc          : in    std_ulogic;
    gsd_test_acmode_dc          : in    std_ulogic;
    ccflush_dc                  : in    std_ulogic;
    ccenable_dc                 : in    std_ulogic;
    scan_type_dc                : in    std_ulogic_vector(0 to 8);
    lbist_en_dc                 : in    std_ulogic;
    lbist_ip_dc                 : in    std_ulogic;
    rg_ck_fast_xstop            : in    std_ulogic;
    ct_ck_pm_ccflush_disable    : in    std_ulogic;
    ct_ck_pm_raise_tholds       : in    std_ulogic;
-- Thold + control from bolton frontend
    bolton_enable_dc            : in    std_ulogic;
    bolton_enable_sync          : in    std_ulogic;
    bolton_ccflush              : in    std_ulogic;
    bolton_fcshdata             : in    std_ulogic;
    bolton_fcreset              : in    std_ulogic;
    bc_cntlclk_sync             : in    std_ulogic;
    bo_pc_abst_sl_thold_6       : in    std_ulogic;
    bo_pc_pc_abst_sl_thold_6    : in    std_ulogic;
    bo_pc_ary_nsl_thold_6       : in    std_ulogic;
    bo_pc_func_sl_thold_6       : in    std_ulogic;
    bo_pc_time_sl_thold_6       : in    std_ulogic;
    bo_pc_repr_sl_thold_6       : in    std_ulogic;
    bo_pc_sg_6                  : in    std_ulogic;
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
    pc_pc_bolt_sl_thold_6       : out   std_ulogic;
    pc_pc_bolt_sl_thold_0       : out   std_ulogic;
    pc_pc_func_sl_thold_0       : out   std_ulogic;
    pc_pc_func_slp_sl_thold_0   : out   std_ulogic;
    pc_pc_cfg_sl_thold_0        : out   std_ulogic;
    pc_pc_cfg_slp_sl_thold_0    : out   std_ulogic;
    pc_pc_sg_0                  : out   std_ulogic;
--  --Trace/Trigger Signals
    dbg_clks_ctrls              : out   std_ulogic_vector(0 to 13)
);


-- synopsys translate_off

-- synopsys translate_on
end pcq_clks;

architecture pcq_clks of pcq_clks is
signal rtim_sl_thold_5             : std_ulogic;     
signal func_sl_thold_5             : std_ulogic;     
signal func_nsl_thold_5            : std_ulogic;    
signal ary_nsl_thold_5             : std_ulogic;     
signal sg_5                        : std_ulogic;                
signal fce_5                       : std_ulogic;               
signal pc_pc_ccflush_out_dc        : std_ulogic;
signal pc_pc_gptr_sl_thold_4       : std_ulogic;
signal pc_pc_time_sl_thold_4       : std_ulogic;
signal pc_pc_repr_sl_thold_4       : std_ulogic;
signal pc_pc_abst_sl_thold_4       : std_ulogic;
signal pc_pc_abst_slp_sl_thold_4   : std_ulogic;
signal pc_pc_regf_sl_thold_4       : std_ulogic;
signal pc_pc_regf_slp_sl_thold_4   : std_ulogic;
signal pc_pc_func_sl_thold_4       : std_ulogic_vector(0 to 1);
signal pc_pc_func_slp_sl_thold_4   : std_ulogic_vector(0 to 1);
signal pc_pc_cfg_sl_thold_4        : std_ulogic;
signal pc_pc_cfg_slp_sl_thold_4    : std_ulogic;
signal pc_pc_func_nsl_thold_4      : std_ulogic;
signal pc_pc_func_slp_nsl_thold_4  : std_ulogic;
signal pc_pc_ary_nsl_thold_4       : std_ulogic;
signal pc_pc_ary_slp_nsl_thold_4   : std_ulogic;
signal pc_pc_rtim_sl_thold_4       : std_ulogic;
signal pc_pc_sg_4                  : std_ulogic_vector(0 to 1);
signal pc_pc_fce_4                 : std_ulogic_vector(0 to 1);
signal bo_pc_sg_5                  : std_ulogic;                
signal bo_pc_bolt_sl_thold_6       : std_ulogic;
signal bo_pc_abst_sl_thold_5       : std_ulogic;
signal bo_pc_pc_abst_sl_thold_5    : std_ulogic;
signal bo_pc_bolt_sl_thold_5       : std_ulogic;
signal bo_pc_ary_nsl_thold_5       : std_ulogic;
signal bo_pc_func_sl_thold_5       : std_ulogic;
signal bo_pc_time_sl_thold_5       : std_ulogic;
signal bo_pc_repr_sl_thold_5       : std_ulogic;
signal bo_pc_sg_4                  : std_ulogic;
signal bo_pc_abst_sl_thold_4       : std_ulogic;
signal bo_pc_pc_abst_sl_thold_4    : std_ulogic;
signal bo_pc_bolt_sl_thold_4       : std_ulogic;
signal bo_pc_ary_nsl_thold_4       : std_ulogic;
signal bo_pc_func_sl_thold_4       : std_ulogic;
signal bo_pc_time_sl_thold_4       : std_ulogic;
signal bo_pc_repr_sl_thold_4       : std_ulogic;
signal bc_cntlclk_sync_2           : std_ulogic;
signal bc_cntlclk_sync_3           : std_ulogic;
signal ccflush_dc_int              : std_ulogic;



begin

ccflush_dc_int <= ccflush_dc or (bolton_enable_dc and bolton_ccflush);

clkctrl : entity work.pcq_clks_ctrl
generic map (expand_type        => expand_type)         
port map(
    vdd                         =>  vdd,                       
    gnd                         =>  gnd,                      
    nclk                        =>  nclk,                      
    rtim_sl_thold_5             =>  rtim_sl_thold_5,     
    func_sl_thold_5             =>  func_sl_thold_5,     
    func_nsl_thold_5            =>  func_nsl_thold_5,    
    ary_nsl_thold_5             =>  ary_nsl_thold_5,     
    sg_5                        =>  sg_5,                
    fce_5                       =>  fce_5,               
    gsd_test_enable_dc          =>  gsd_test_enable_dc,
    gsd_test_acmode_dc          =>  gsd_test_acmode_dc,
    ccflush_dc                  =>  ccflush_dc_int,          
    ccenable_dc                 =>  ccenable_dc,         
    scan_type_dc                =>  scan_type_dc,        
    lbist_en_dc                 =>  lbist_en_dc,     
    lbist_ip_dc                 =>  lbist_ip_dc,    
    rg_ck_fast_xstop            =>  rg_ck_fast_xstop,
    ct_ck_pm_ccflush_disable    =>  ct_ck_pm_ccflush_disable,
    ct_ck_pm_raise_tholds       =>  ct_ck_pm_raise_tholds,       
--  --Thold + control outputs to the units
    pc_pc_ccflush_out_dc        =>  pc_pc_ccflush_out_dc,
    pc_pc_gptr_sl_thold_4       =>  pc_pc_gptr_sl_thold_4,     
    pc_pc_time_sl_thold_4       =>  pc_pc_time_sl_thold_4,     
    pc_pc_repr_sl_thold_4       =>  pc_pc_repr_sl_thold_4,     
    pc_pc_cfg_sl_thold_4        =>  pc_pc_cfg_sl_thold_4,      
    pc_pc_cfg_slp_sl_thold_4    =>  pc_pc_cfg_slp_sl_thold_4,  
    pc_pc_abst_sl_thold_4       =>  pc_pc_abst_sl_thold_4,     
    pc_pc_abst_slp_sl_thold_4   =>  pc_pc_abst_slp_sl_thold_4, 
    pc_pc_regf_sl_thold_4       =>  pc_pc_regf_sl_thold_4,     
    pc_pc_regf_slp_sl_thold_4   =>  pc_pc_regf_slp_sl_thold_4, 
    pc_pc_func_sl_thold_4       =>  pc_pc_func_sl_thold_4,     
    pc_pc_func_slp_sl_thold_4   =>  pc_pc_func_slp_sl_thold_4, 
    pc_pc_func_nsl_thold_4      =>  pc_pc_func_nsl_thold_4,    
    pc_pc_func_slp_nsl_thold_4  =>  pc_pc_func_slp_nsl_thold_4,
    pc_pc_ary_nsl_thold_4       =>  pc_pc_ary_nsl_thold_4,     
    pc_pc_ary_slp_nsl_thold_4   =>  pc_pc_ary_slp_nsl_thold_4, 
    pc_pc_rtim_sl_thold_4       =>  pc_pc_rtim_sl_thold_4,
    pc_pc_sg_4                  =>  pc_pc_sg_4,                
    pc_pc_fce_4                 =>  pc_pc_fce_4               
);

clkstg : entity work.pcq_clks_stg
generic map (expand_type        => expand_type)         
port map(
    vdd                         =>  vdd,                       
    gnd                         =>  gnd,                      
    nclk                        =>  nclk,                      
    pc_pc_ccflush_out_dc        =>  pc_pc_ccflush_out_dc, 
    pc_pc_gptr_sl_thold_4       =>  pc_pc_gptr_sl_thold_4,     
    pc_pc_time_sl_thold_4       =>  pc_pc_time_sl_thold_4,     
    pc_pc_repr_sl_thold_4       =>  pc_pc_repr_sl_thold_4,     
    pc_pc_cfg_sl_thold_4        =>  pc_pc_cfg_sl_thold_4,      
    pc_pc_cfg_slp_sl_thold_4    =>  pc_pc_cfg_slp_sl_thold_4,  
    pc_pc_abst_sl_thold_4       =>  pc_pc_abst_sl_thold_4,     
    pc_pc_abst_slp_sl_thold_4   =>  pc_pc_abst_slp_sl_thold_4, 
    pc_pc_regf_sl_thold_4       =>  pc_pc_regf_sl_thold_4,     
    pc_pc_regf_slp_sl_thold_4   =>  pc_pc_regf_slp_sl_thold_4, 
    pc_pc_func_sl_thold_4       =>  pc_pc_func_sl_thold_4,     
    pc_pc_func_slp_sl_thold_4   =>  pc_pc_func_slp_sl_thold_4, 
    pc_pc_func_nsl_thold_4      =>  pc_pc_func_nsl_thold_4,    
    pc_pc_func_slp_nsl_thold_4  =>  pc_pc_func_slp_nsl_thold_4,
    pc_pc_ary_nsl_thold_4       =>  pc_pc_ary_nsl_thold_4,     
    pc_pc_ary_slp_nsl_thold_4   =>  pc_pc_ary_slp_nsl_thold_4, 
    pc_pc_rtim_sl_thold_4       =>  pc_pc_rtim_sl_thold_4,
    pc_pc_sg_4                  =>  pc_pc_sg_4,                
    pc_pc_fce_4                 =>  pc_pc_fce_4,               
-- Thold + control from bolton frontend
    bolton_enable               =>  bolton_enable_sync,
    bolton_fcshdata             =>  bolton_fcshdata,
    bolton_fcreset              =>  bolton_fcreset,
    bo_pc_abst_sl_thold_4       =>  bo_pc_abst_sl_thold_4,
    bo_pc_pc_abst_sl_thold_4    =>  bo_pc_pc_abst_sl_thold_4,
    bo_pc_bolt_sl_thold_4       =>  bo_pc_bolt_sl_thold_4,
    bo_pc_ary_nsl_thold_4       =>  bo_pc_ary_nsl_thold_4,
    bo_pc_func_sl_thold_4       =>  bo_pc_func_sl_thold_4,
    bo_pc_time_sl_thold_4       =>  bo_pc_time_sl_thold_4,
    bo_pc_repr_sl_thold_4       =>  bo_pc_repr_sl_thold_4,
    bo_pc_sg_4                  =>  bo_pc_sg_4,
--  --Thold + control outputs to the units
    pc_xu_ccflush_dc            =>  pc_xu_ccflush_dc,          
    pc_xu_gptr_sl_thold_3       =>  pc_xu_gptr_sl_thold_3,     
    pc_xu_time_sl_thold_3       =>  pc_xu_time_sl_thold_3,     
    pc_xu_repr_sl_thold_3       =>  pc_xu_repr_sl_thold_3,     
    pc_xu_abst_sl_thold_3       =>  pc_xu_abst_sl_thold_3,     
    pc_xu_abst_slp_sl_thold_3   =>  pc_xu_abst_slp_sl_thold_3, 
    pc_xu_bolt_sl_thold_3       =>  pc_xu_bolt_sl_thold_3,     
    pc_xu_regf_sl_thold_3       =>  pc_xu_regf_sl_thold_3,     
    pc_xu_regf_slp_sl_thold_3   =>  pc_xu_regf_slp_sl_thold_3, 
    pc_xu_func_sl_thold_3       =>  pc_xu_func_sl_thold_3,     
    pc_xu_func_slp_sl_thold_3   =>  pc_xu_func_slp_sl_thold_3, 
    pc_xu_cfg_sl_thold_3        =>  pc_xu_cfg_sl_thold_3,      
    pc_xu_cfg_slp_sl_thold_3    =>  pc_xu_cfg_slp_sl_thold_3,  
    pc_xu_func_nsl_thold_3      =>  pc_xu_func_nsl_thold_3,    
    pc_xu_func_slp_nsl_thold_3  =>  pc_xu_func_slp_nsl_thold_3,
    pc_xu_ary_nsl_thold_3       =>  pc_xu_ary_nsl_thold_3,     
    pc_xu_ary_slp_nsl_thold_3   =>  pc_xu_ary_slp_nsl_thold_3, 
    pc_xu_sg_3                  =>  pc_xu_sg_3,                
    pc_xu_fce_3                 =>  pc_xu_fce_3,               
    pc_bx_ccflush_dc            =>  pc_bx_ccflush_dc,      
    pc_bx_func_sl_thold_3       =>  pc_bx_func_sl_thold_3, 
    pc_bx_func_slp_sl_thold_3   =>  pc_bx_func_slp_sl_thold_3,
    pc_bx_gptr_sl_thold_3       =>  pc_bx_gptr_sl_thold_3, 
    pc_bx_time_sl_thold_3       =>  pc_bx_time_sl_thold_3, 
    pc_bx_repr_sl_thold_3       =>  pc_bx_repr_sl_thold_3, 
    pc_bx_abst_sl_thold_3       =>  pc_bx_abst_sl_thold_3, 
    pc_bx_bolt_sl_thold_3       =>  pc_bx_bolt_sl_thold_3,     
    pc_bx_ary_nsl_thold_3       =>  pc_bx_ary_nsl_thold_3, 
    pc_bx_ary_slp_nsl_thold_3   =>  pc_bx_ary_slp_nsl_thold_3,    
    pc_bx_sg_3                  =>  pc_bx_sg_3,            
    pc_mm_ccflush_dc            =>  pc_mm_ccflush_dc,          
    pc_iu_ccflush_dc            =>  pc_iu_ccflush_dc,          
    pc_iu_gptr_sl_thold_4       =>  pc_iu_gptr_sl_thold_4,     
    pc_iu_time_sl_thold_4       =>  pc_iu_time_sl_thold_4,     
    pc_iu_repr_sl_thold_4       =>  pc_iu_repr_sl_thold_4,     
    pc_iu_abst_sl_thold_4       =>  pc_iu_abst_sl_thold_4,     
    pc_iu_abst_slp_sl_thold_4   =>  pc_iu_abst_slp_sl_thold_4, 
    pc_iu_bolt_sl_thold_4       =>  pc_iu_bolt_sl_thold_4,     
    pc_iu_regf_slp_sl_thold_4   =>  pc_iu_regf_slp_sl_thold_4, 
    pc_iu_func_sl_thold_4       =>  pc_iu_func_sl_thold_4,     
    pc_iu_func_slp_sl_thold_4   =>  pc_iu_func_slp_sl_thold_4, 
    pc_iu_cfg_sl_thold_4        =>  pc_iu_cfg_sl_thold_4,      
    pc_iu_cfg_slp_sl_thold_4    =>  pc_iu_cfg_slp_sl_thold_4,  
    pc_iu_func_nsl_thold_4      =>  pc_iu_func_nsl_thold_4,    
    pc_iu_func_slp_nsl_thold_4  =>  pc_iu_func_slp_nsl_thold_4,
    pc_iu_ary_nsl_thold_4       =>  pc_iu_ary_nsl_thold_4,     
    pc_iu_ary_slp_nsl_thold_4   =>  pc_iu_ary_slp_nsl_thold_4, 
    pc_iu_sg_4                  =>  pc_iu_sg_4,                
    pc_iu_fce_4                 =>  pc_iu_fce_4,               
    pc_fu_ccflush_dc            =>  pc_fu_ccflush_dc,          
    pc_fu_gptr_sl_thold_3       =>  pc_fu_gptr_sl_thold_3,     
    pc_fu_time_sl_thold_3       =>  pc_fu_time_sl_thold_3,     
    pc_fu_repr_sl_thold_3       =>  pc_fu_repr_sl_thold_3,     
    pc_fu_abst_sl_thold_3       =>  pc_fu_abst_sl_thold_3,     
    pc_fu_abst_slp_sl_thold_3   =>  pc_fu_abst_slp_sl_thold_3, 
    pc_fu_bolt_sl_thold_3       =>  pc_fu_bolt_sl_thold_3,     
    pc_fu_func_sl_thold_3       =>  pc_fu_func_sl_thold_3,     
    pc_fu_func_slp_sl_thold_3   =>  pc_fu_func_slp_sl_thold_3, 
    pc_fu_cfg_sl_thold_3        =>  pc_fu_cfg_sl_thold_3,      
    pc_fu_cfg_slp_sl_thold_3    =>  pc_fu_cfg_slp_sl_thold_3,  
    pc_fu_func_nsl_thold_3      =>  pc_fu_func_nsl_thold_3,    
    pc_fu_func_slp_nsl_thold_3  =>  pc_fu_func_slp_nsl_thold_3,
    pc_fu_ary_nsl_thold_3       =>  pc_fu_ary_nsl_thold_3,     
    pc_fu_ary_slp_nsl_thold_3   =>  pc_fu_ary_slp_nsl_thold_3, 
    pc_fu_sg_3                  =>  pc_fu_sg_3,                
    pc_fu_fce_3                 =>  pc_fu_fce_3,               
    pc_pc_ccflush_dc            =>  pc_pc_ccflush_dc,
    pc_pc_gptr_sl_thold_0       =>  pc_pc_gptr_sl_thold_0,     
    pc_pc_abst_sl_thold_0       =>  pc_pc_abst_sl_thold_0, 
    pc_pc_bolt_sl_thold_0       =>  pc_pc_bolt_sl_thold_0, 
    pc_pc_func_sl_thold_0       =>  pc_pc_func_sl_thold_0,     
    pc_pc_func_slp_sl_thold_0   =>  pc_pc_func_slp_sl_thold_0, 
    pc_pc_cfg_sl_thold_0        =>  pc_pc_cfg_sl_thold_0,     
    pc_pc_cfg_slp_sl_thold_0    =>  pc_pc_cfg_slp_sl_thold_0, 
    pc_pc_sg_0                  =>  pc_pc_sg_0                
);

bolton_thold_gen: tri_plat
   generic map( width => 2, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => ccflush_dc_int,
	        din( 0) => bc_cntlclk_sync,
	        din( 1) => bc_cntlclk_sync_2,
	        q( 0)   => bc_cntlclk_sync_2,
	        q( 1)   => bc_cntlclk_sync_3
           ); 

bo_pc_bolt_sl_thold_6 <= not bolton_ccflush and not (bc_cntlclk_sync_2 and (bc_cntlclk_sync_2 xor bc_cntlclk_sync_3)) ;
pc_pc_bolt_sl_thold_6 <= bo_pc_bolt_sl_thold_6;

lvl6to5_plat: tri_plat
   generic map( width => 14, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => ccflush_dc_int,
             din( 0) => rtim_sl_thold_6,
             din( 1) => func_sl_thold_6,
             din( 2) => func_nsl_thold_6,
             din( 3) => ary_nsl_thold_6,
             din( 4) => sg_6,
             din( 5) => fce_6,
             din( 6) => bo_pc_sg_6,
	        din( 7) => bo_pc_bolt_sl_thold_6,
	        din( 8) => bo_pc_abst_sl_thold_6,
	        din( 9) => bo_pc_pc_abst_sl_thold_6,
	        din(10) => bo_pc_ary_nsl_thold_6,
	        din(11) => bo_pc_func_sl_thold_6,
	        din(12) => bo_pc_time_sl_thold_6,
	        din(13) => bo_pc_repr_sl_thold_6,
             q( 0)   => rtim_sl_thold_5,
             q( 1)   => func_sl_thold_5,
             q( 2)   => func_nsl_thold_5,
             q( 3)   => ary_nsl_thold_5,
             q( 4)   => sg_5,
             q( 5)   => fce_5,
             q( 6)   => bo_pc_sg_5,
	        q( 7)   => bo_pc_bolt_sl_thold_5,
	        q( 8)   => bo_pc_abst_sl_thold_5,
	        q( 9)   => bo_pc_pc_abst_sl_thold_5,
	        q(10)   => bo_pc_ary_nsl_thold_5,
	        q(11)   => bo_pc_func_sl_thold_5,
	        q(12)   => bo_pc_time_sl_thold_5,
	        q(13)   => bo_pc_repr_sl_thold_5
           ); 

lvl5to4_plat: tri_plat
   generic map( width => 8, expand_type => expand_type)
   port map( vd      => vdd,
             gd      => gnd,
             nclk    => nclk,
             flush   => ccflush_dc_int,
             din( 0) => bo_pc_sg_5,
 	        din( 1) => bo_pc_bolt_sl_thold_5,
	        din( 2) => bo_pc_abst_sl_thold_5,
	        din( 3) => bo_pc_pc_abst_sl_thold_5,
	        din( 4) => bo_pc_ary_nsl_thold_5,
	        din( 5) => bo_pc_func_sl_thold_5,
	        din( 6) => bo_pc_time_sl_thold_5,
	        din( 7) => bo_pc_repr_sl_thold_5,
	        q( 0)   => bo_pc_sg_4,
	        q( 1)   => bo_pc_bolt_sl_thold_4,
	        q( 2)   => bo_pc_abst_sl_thold_4,
	        q( 3)   => bo_pc_pc_abst_sl_thold_4,
	        q( 4)   => bo_pc_ary_nsl_thold_4,
	        q( 5)   => bo_pc_func_sl_thold_4,
	        q( 6)   => bo_pc_time_sl_thold_4,
	        q( 7)   => bo_pc_repr_sl_thold_4
           ); 


--=====================================================================
-- Trace/Trigger Signals
--=====================================================================
   dbg_clks_ctrls <= ccenable_dc                  &     -- 0
                     gsd_test_enable_dc           &     -- 1
                     gsd_test_acmode_dc           &     -- 2
                     lbist_en_dc                  &     -- 3
                     lbist_ip_dc                  &     -- 4
                     scan_type_dc(0 to 7)         &     -- 5:12
                     rg_ck_fast_xstop             ;     -- 13
       
end pcq_clks;
