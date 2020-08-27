-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

--********************************************************************
--* TITLE: Memory Management Unit Special Purpose Registers
--* NAME: mmq_spr.vhdl
--*********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ibm;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_support.all;
library support;
use support.power_logic_pkg.all;

library tri;
use tri.tri_latches_pkg.all;
entity mmq_spr is
  generic(pid_width          : integer := 14;
            lpid_width         : integer := 8;
            epn_width          : integer := 52;
            thdid_width        : integer := 4;
            class_width        : integer := 2;
            extclass_width     : integer := 2;
            mmucr0_width       : integer := 20;
            mmucr1_width       : integer := 32;
            mmucr2_width       : integer := 32;
            mmucr3_width       : integer := 15;
            spr_ctl_width      : integer := 3;
            spr_etid_width     : integer := 2;
            spr_addr_width     : integer := 10;
            spr_data_width     : integer := 64;
            real_addr_width    : integer := 42;
            bcfg_mmucr1_value   : integer := 201326592;  
            bcfg_mmucr2_value   : integer := 685361; 
            bcfg_mmucr3_value   : integer := 15;     
            bcfg_mmucfg_value   : integer := 3;      
            bcfg_tlb0cfg_value  : integer := 7;      
           mmq_spr_cswitch_0to3 : integer := 0;     
          expand_tlb_type       : integer := 2;     
          expand_type           : integer := 2 );   
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;


     tc_ccflush_dc             : in std_ulogic;
     tc_scan_dis_dc_b          : in std_ulogic;
     tc_scan_diag_dc           : in std_ulogic;
     tc_lbist_en_dc            : in std_ulogic; 

     lcb_d_mode_dc              : in std_ulogic;
     lcb_clkoff_dc_b            : in std_ulogic;
     lcb_act_dis_dc             : in std_ulogic;
     lcb_mpw1_dc_b              : in std_ulogic_vector(0 to 4);
     lcb_mpw2_dc_b              : in std_ulogic;
     lcb_delay_lclkr_dc         : in std_ulogic_vector(0 to 4);

     ac_func_scan_in          :in     std_ulogic_vector(0 to 1);
     ac_func_scan_out         :out    std_ulogic_vector(0 to 1);
     ac_bcfg_scan_in          :in     std_ulogic;
     ac_bcfg_scan_out         :out    std_ulogic;

     pc_sg_2                : in     std_ulogic;
     pc_func_sl_thold_2     : in     std_ulogic;
     pc_func_slp_sl_thold_2 : in     std_ulogic;
     pc_func_slp_nsl_thold_2  : in   std_ulogic;
     pc_cfg_sl_thold_2      : in     std_ulogic;
     pc_cfg_slp_sl_thold_2  : in     std_ulogic;
     pc_fce_2               : in     std_ulogic;
     xu_mm_ccr2_notlb_b   : in     std_ulogic;
     mmucr2_act_override  : in     std_ulogic_vector(5 to 6);
     tlb_delayed_act      : in std_ulogic_vector(29 to 32);

     mm_iu_ierat_pid0           : out std_ulogic_vector(0 to pid_width-1);
     mm_iu_ierat_pid1           : out std_ulogic_vector(0 to pid_width-1);
     mm_iu_ierat_pid2           : out std_ulogic_vector(0 to pid_width-1);
     mm_iu_ierat_pid3           : out std_ulogic_vector(0 to pid_width-1);
     mm_iu_ierat_mmucr0_0         : out std_ulogic_vector(0 to 19);
     mm_iu_ierat_mmucr0_1         : out std_ulogic_vector(0 to 19);
     mm_iu_ierat_mmucr0_2         : out std_ulogic_vector(0 to 19);
     mm_iu_ierat_mmucr0_3         : out std_ulogic_vector(0 to 19);
     iu_mm_ierat_mmucr0          : in std_ulogic_vector(0 to 17);
     iu_mm_ierat_mmucr0_we       : in std_ulogic_vector(0 to thdid_width-1);
     mm_iu_ierat_mmucr1          : out std_ulogic_vector(0 to 8);  
     iu_mm_ierat_mmucr1          : in std_ulogic_vector(0 to 3); 
     iu_mm_ierat_mmucr1_we       : in std_ulogic; 

     mm_xu_derat_pid0           : out std_ulogic_vector(0 to pid_width-1);
     mm_xu_derat_pid1           : out std_ulogic_vector(0 to pid_width-1);
     mm_xu_derat_pid2           : out std_ulogic_vector(0 to pid_width-1);
     mm_xu_derat_pid3           : out std_ulogic_vector(0 to pid_width-1);
     mm_xu_derat_mmucr0_0         : out std_ulogic_vector(0 to 19);
     mm_xu_derat_mmucr0_1         : out std_ulogic_vector(0 to 19);
     mm_xu_derat_mmucr0_2         : out std_ulogic_vector(0 to 19);
     mm_xu_derat_mmucr0_3         : out std_ulogic_vector(0 to 19);
     xu_mm_derat_mmucr0          : in std_ulogic_vector(0 to 17);
     xu_mm_derat_mmucr0_we       : in std_ulogic_vector(0 to thdid_width-1);
     mm_xu_derat_mmucr1          : out std_ulogic_vector(0 to 9); 
     xu_mm_derat_mmucr1          : in std_ulogic_vector(0 to 4); 
     xu_mm_derat_mmucr1_we       : in std_ulogic;

     pid0           : out std_ulogic_vector(0 to pid_width-1);
     pid1           : out std_ulogic_vector(0 to pid_width-1);
     pid2           : out std_ulogic_vector(0 to pid_width-1);
     pid3           : out std_ulogic_vector(0 to pid_width-1);
     mmucr0_0         : out std_ulogic_vector(0 to mmucr0_width-1);
     mmucr0_1         : out std_ulogic_vector(0 to mmucr0_width-1);
     mmucr0_2         : out std_ulogic_vector(0 to mmucr0_width-1);
     mmucr0_3         : out std_ulogic_vector(0 to mmucr0_width-1);
     mmucr1          : out std_ulogic_vector(0 to mmucr1_width-1); 
     mmucr2          : out std_ulogic_vector(0 to mmucr2_width-1); 
     mmucr3_0         : out std_ulogic_vector(64-mmucr3_width to 63); 
     mmucr3_1         : out std_ulogic_vector(64-mmucr3_width to 63); 
     mmucr3_2         : out std_ulogic_vector(64-mmucr3_width to 63); 
     mmucr3_3         : out std_ulogic_vector(64-mmucr3_width to 63); 
     mmucfg_lrat       : out std_ulogic;
     mmucfg_twc        : out std_ulogic;
     tlb0cfg_pt         : out std_ulogic;
     tlb0cfg_ind        : out std_ulogic;
     tlb0cfg_gtwe       : out std_ulogic;

     mas0_0_atsel           : out std_ulogic;  
     mas0_0_esel            : out std_ulogic_vector(0 to 2);  
     mas0_0_hes             : out std_ulogic;  
     mas0_0_wq              : out std_ulogic_vector(0 to 1); 
     mas1_0_v               : out std_ulogic;  
     mas1_0_iprot           : out std_ulogic;  
     mas1_0_tid             : out std_ulogic_vector(0 to 13);  
     mas1_0_ind             : out std_ulogic;  
     mas1_0_ts              : out std_ulogic;  
     mas1_0_tsize           : out std_ulogic_vector(0 to 3);  
     mas2_0_epn             : out std_ulogic_vector(0 to 51); 
     mas2_0_wimge           : out std_ulogic_vector(0 to 4);  
     mas3_0_rpnl            : out std_ulogic_vector(32 to 52); 
     mas3_0_ubits           : out std_ulogic_vector(0 to 3); 
     mas3_0_usxwr           : out std_ulogic_vector(0 to 5);  
     mas5_0_sgs             : out std_ulogic;  
     mas5_0_slpid           : out std_ulogic_vector(0 to 7);  
     mas6_0_spid            : out std_ulogic_vector(0 to 13);  
     mas6_0_isize           : out std_ulogic_vector(0 to 3);  
     mas6_0_sind            : out std_ulogic;  
     mas6_0_sas             : out std_ulogic;  
     mas7_0_rpnu            : out std_ulogic_vector(22 to 31);  
     mas8_0_tgs             : out std_ulogic;  
     mas8_0_vf              : out std_ulogic;  
     mas8_0_tlpid           : out std_ulogic_vector(0 to 7);
     mas0_1_atsel           : out std_ulogic;  
     mas0_1_esel            : out std_ulogic_vector(0 to 2);  
     mas0_1_hes             : out std_ulogic;  
     mas0_1_wq              : out std_ulogic_vector(0 to 1); 
     mas1_1_v               : out std_ulogic;  
     mas1_1_iprot           : out std_ulogic;  
     mas1_1_tid             : out std_ulogic_vector(0 to 13);  
     mas1_1_ind             : out std_ulogic;  
     mas1_1_ts              : out std_ulogic;  
     mas1_1_tsize           : out std_ulogic_vector(0 to 3);  
     mas2_1_epn             : out std_ulogic_vector(0 to 51); 
     mas2_1_wimge           : out std_ulogic_vector(0 to 4);  
     mas3_1_rpnl            : out std_ulogic_vector(32 to 52); 
     mas3_1_ubits           : out std_ulogic_vector(0 to 3); 
     mas3_1_usxwr           : out std_ulogic_vector(0 to 5);  
     mas5_1_sgs             : out std_ulogic;  
     mas5_1_slpid           : out std_ulogic_vector(0 to 7);  
     mas6_1_spid            : out std_ulogic_vector(0 to 13);  
     mas6_1_isize           : out std_ulogic_vector(0 to 3);  
     mas6_1_sind            : out std_ulogic;  
     mas6_1_sas             : out std_ulogic;  
     mas7_1_rpnu            : out std_ulogic_vector(22 to 31);  
     mas8_1_tgs             : out std_ulogic;  
     mas8_1_vf              : out std_ulogic;  
     mas8_1_tlpid           : out std_ulogic_vector(0 to 7);
     mas0_2_atsel           : out std_ulogic;  
     mas0_2_esel            : out std_ulogic_vector(0 to 2);  
     mas0_2_hes             : out std_ulogic;  
     mas0_2_wq              : out std_ulogic_vector(0 to 1); 
     mas1_2_v               : out std_ulogic;  
     mas1_2_iprot           : out std_ulogic;  
     mas1_2_tid             : out std_ulogic_vector(0 to 13);  
     mas1_2_ind             : out std_ulogic;  
     mas1_2_ts              : out std_ulogic;  
     mas1_2_tsize           : out std_ulogic_vector(0 to 3);  
     mas2_2_epn             : out std_ulogic_vector(0 to 51); 
     mas2_2_wimge           : out std_ulogic_vector(0 to 4);  
     mas3_2_rpnl            : out std_ulogic_vector(32 to 52); 
     mas3_2_ubits           : out std_ulogic_vector(0 to 3); 
     mas3_2_usxwr           : out std_ulogic_vector(0 to 5);  
     mas5_2_sgs             : out std_ulogic;  
     mas5_2_slpid           : out std_ulogic_vector(0 to 7);  
     mas6_2_spid            : out std_ulogic_vector(0 to 13);  
     mas6_2_isize           : out std_ulogic_vector(0 to 3);  
     mas6_2_sind            : out std_ulogic;  
     mas6_2_sas             : out std_ulogic;  
     mas7_2_rpnu            : out std_ulogic_vector(22 to 31);  
     mas8_2_tgs             : out std_ulogic;  
     mas8_2_vf              : out std_ulogic;  
     mas8_2_tlpid           : out std_ulogic_vector(0 to 7);
     mas0_3_atsel           : out std_ulogic;  
     mas0_3_esel            : out std_ulogic_vector(0 to 2);  
     mas0_3_hes             : out std_ulogic;  
     mas0_3_wq              : out std_ulogic_vector(0 to 1); 
     mas1_3_v               : out std_ulogic;  
     mas1_3_iprot           : out std_ulogic;  
     mas1_3_tid             : out std_ulogic_vector(0 to 13);  
     mas1_3_ind             : out std_ulogic;  
     mas1_3_ts              : out std_ulogic;  
     mas1_3_tsize           : out std_ulogic_vector(0 to 3);  
     mas2_3_epn             : out std_ulogic_vector(0 to 51); 
     mas2_3_wimge           : out std_ulogic_vector(0 to 4);  
     mas3_3_rpnl            : out std_ulogic_vector(32 to 52); 
     mas3_3_ubits           : out std_ulogic_vector(0 to 3); 
     mas3_3_usxwr           : out std_ulogic_vector(0 to 5);  
     mas5_3_sgs             : out std_ulogic;  
     mas5_3_slpid           : out std_ulogic_vector(0 to 7);  
     mas6_3_spid            : out std_ulogic_vector(0 to 13);  
     mas6_3_isize           : out std_ulogic_vector(0 to 3);  
     mas6_3_sind            : out std_ulogic;  
     mas6_3_sas             : out std_ulogic;  
     mas7_3_rpnu            : out std_ulogic_vector(22 to 31);  
     mas8_3_tgs             : out std_ulogic;  
     mas8_3_vf              : out std_ulogic;  
     mas8_3_tlpid           : out std_ulogic_vector(0 to 7);
     tlb_mas0_esel          : in std_ulogic_vector(0 to 2);  
     tlb_mas1_v             : in std_ulogic;  
     tlb_mas1_iprot         : in std_ulogic;  
     tlb_mas1_tid           : in std_ulogic_vector(0 to pid_width-1);  
     tlb_mas1_tid_error     : in std_ulogic_vector(0 to pid_width-1);  
     tlb_mas1_ind           : in std_ulogic;  
     tlb_mas1_ts            : in std_ulogic;  
     tlb_mas1_ts_error      : in std_ulogic;  
     tlb_mas1_tsize         : in std_ulogic_vector(0 to 3);  
     tlb_mas2_epn           : in std_ulogic_vector(0 to epn_width-1); 
     tlb_mas2_epn_error     : in std_ulogic_vector(0 to epn_width-1); 
     tlb_mas2_wimge         : in std_ulogic_vector(0 to 4);  
     tlb_mas3_rpnl          : in std_ulogic_vector(32 to 51); 
     tlb_mas3_ubits         : in std_ulogic_vector(0 to 3); 
     tlb_mas3_usxwr         : in std_ulogic_vector(0 to 5);  
     tlb_mas6_spid          : in std_ulogic_vector(0 to pid_width-1);  
     tlb_mas6_isize         : in std_ulogic_vector(0 to 3);  
     tlb_mas6_sind          : in std_ulogic;  
     tlb_mas6_sas           : in std_ulogic;  
     tlb_mas7_rpnu          : in std_ulogic_vector(22 to 31);  
     tlb_mas8_tgs           : in std_ulogic;  
     tlb_mas8_vf            : in std_ulogic;  
     tlb_mas8_tlpid         : in std_ulogic_vector(0 to 7);

     tlb_mmucr1_een         : in std_ulogic_vector(0 to 8); 
     tlb_mmucr1_we          : in std_ulogic; 
     tlb_mmucr3_thdid       : in std_ulogic_vector(0 to thdid_width-1);
     tlb_mmucr3_resvattr    : in std_ulogic;
     tlb_mmucr3_wlc         : in std_ulogic_vector(0 to 1);
     tlb_mmucr3_class       : in std_ulogic_vector(0 to class_width-1);
     tlb_mmucr3_extclass    : in std_ulogic_vector(0 to extclass_width-1);
     tlb_mmucr3_rc          : in std_ulogic_vector(0 to 1);
     tlb_mmucr3_x           : in std_ulogic;
     tlb_mas_tlbre          : in std_ulogic;  
     tlb_mas_tlbsx_hit      : in std_ulogic;  
     tlb_mas_tlbsx_miss     : in std_ulogic;  
     tlb_mas_dtlb_error     : in std_ulogic;  
     tlb_mas_itlb_error     : in std_ulogic;  
     tlb_mas_thdid          : in std_ulogic_vector(0 to thdid_width-1);  

     mmucsr0_tlb0fi            : out std_ulogic;
     mmq_inval_tlb0fi_done     : in std_ulogic;

     lrat_mmucr3_x          : in std_ulogic; 
     lrat_mas0_esel         : in std_ulogic_vector(0 to 2);  
     lrat_mas1_v            : in std_ulogic;  
     lrat_mas1_tsize        : in std_ulogic_vector(0 to 3);  
     lrat_mas2_epn          : in std_ulogic_vector(0 to 51); 
     lrat_mas3_rpnl         : in std_ulogic_vector(32 to 51); 
     lrat_mas7_rpnu         : in std_ulogic_vector(22 to 31);
     lrat_mas8_tlpid        : in std_ulogic_vector(0 to lpid_width-1);
     lrat_mas_tlbre         : in std_ulogic;
     lrat_mas_tlbsx_hit     : in std_ulogic;
     lrat_mas_tlbsx_miss    : in std_ulogic;
     lrat_mas_thdid         : in std_ulogic_vector(0 to thdid_width-1);
     lrat_tag4_hit_entry    : in std_ulogic_vector(0 to 2);

     tlb_lper_lpn         : in std_ulogic_vector(64-real_addr_width to 51);
     tlb_lper_lps         : in std_ulogic_vector(60 to 63);
     tlb_lper_we          : in std_ulogic_vector(0 to thdid_width-1);

     lpidr                      : out std_ulogic_vector(0 to lpid_width-1);
     ac_an_lpar_id              : out std_ulogic_vector(0 to lpid_width-1);

     spr_dbg_match_64b           : out std_ulogic;  
     spr_dbg_match_any_mmu       : out std_ulogic;
     spr_dbg_match_any_mas       : out std_ulogic;
     spr_dbg_match_pid           : out std_ulogic;
     spr_dbg_match_lpidr         : out std_ulogic;
     spr_dbg_match_mmucr0        : out std_ulogic;
     spr_dbg_match_mmucr1        : out std_ulogic;
     spr_dbg_match_mmucr2        : out std_ulogic;
     spr_dbg_match_mmucr3        : out std_ulogic;

     spr_dbg_match_mmucsr0       : out std_ulogic;  
     spr_dbg_match_mmucfg        : out std_ulogic;  
     spr_dbg_match_tlb0cfg       : out std_ulogic;  
     spr_dbg_match_tlb0ps        : out std_ulogic;  
     spr_dbg_match_lratcfg       : out std_ulogic;  
     spr_dbg_match_lratps        : out std_ulogic;  
     spr_dbg_match_eptcfg        : out std_ulogic;  
     spr_dbg_match_lper          : out std_ulogic;  
     spr_dbg_match_lperu         : out std_ulogic;  

     spr_dbg_match_mas0          : out std_ulogic;  
     spr_dbg_match_mas1          : out std_ulogic;  
     spr_dbg_match_mas2          : out std_ulogic; 
     spr_dbg_match_mas2u         : out std_ulogic; 
     spr_dbg_match_mas3          : out std_ulogic;  
     spr_dbg_match_mas4          : out std_ulogic;  
     spr_dbg_match_mas5          : out std_ulogic;  
     spr_dbg_match_mas6          : out std_ulogic;  
     spr_dbg_match_mas7          : out std_ulogic;  
     spr_dbg_match_mas8          : out std_ulogic;  
     spr_dbg_match_mas01_64b     : out std_ulogic;  
     spr_dbg_match_mas56_64b     : out std_ulogic;  
     spr_dbg_match_mas73_64b     : out std_ulogic;  
     spr_dbg_match_mas81_64b     : out std_ulogic;  

     spr_dbg_slowspr_val_int         : out std_ulogic;  
     spr_dbg_slowspr_rw_int          : out std_ulogic;
     spr_dbg_slowspr_etid_int        : out std_ulogic_vector(0 to 1);
     spr_dbg_slowspr_addr_int        : out std_ulogic_vector(0 to 9);
     spr_dbg_slowspr_val_out         : out std_ulogic; 
     spr_dbg_slowspr_done_out        : out std_ulogic;  
     spr_dbg_slowspr_data_out        : out std_ulogic_vector(64-spr_data_width to 63);

     xu_mm_slowspr_val           : in std_ulogic;
     xu_mm_slowspr_rw            : in std_ulogic;
     xu_mm_slowspr_etid          : in std_ulogic_vector(0 to 1);
     xu_mm_slowspr_addr          : in std_ulogic_vector(0 to 9);
     xu_mm_slowspr_data          : in std_ulogic_vector(64-spr_data_width to 63);
     xu_mm_slowspr_done          : in std_ulogic;

     mm_iu_slowspr_val           : out std_ulogic;
     mm_iu_slowspr_rw            : out std_ulogic;
     mm_iu_slowspr_etid          : out std_ulogic_vector(0 to 1);
     mm_iu_slowspr_addr          : out std_ulogic_vector(0 to 9);
     mm_iu_slowspr_data          : out std_ulogic_vector(64-spr_data_width to 63);
     mm_iu_slowspr_done          : out std_ulogic


);
end mmq_spr;
architecture mmq_spr of mmq_spr is
constant Spr_Addr_PID : std_ulogic_vector(0 to 9) := "0000110000";
constant Spr_Addr_LPID : std_ulogic_vector(0 to 9) := "0101010010";
constant Spr_Addr_MMUCR0 : std_ulogic_vector(0 to 9) := "1111111100";
constant Spr_Addr_MMUCR1 : std_ulogic_vector(0 to 9) := "1111111101";
constant Spr_Addr_MMUCR2 : std_ulogic_vector(0 to 9) := "1111111110";
constant Spr_Addr_MMUCR3 : std_ulogic_vector(0 to 9) := "1111111111";
constant Spr_RW_Write : std_ulogic := '0';
constant Spr_RW_Read : std_ulogic := '1';
constant Spr_Addr_MAS0          : std_ulogic_vector(0 to 9) := "1001110000";
constant Spr_Addr_MAS1          : std_ulogic_vector(0 to 9) := "1001110001";
constant Spr_Addr_MAS2          : std_ulogic_vector(0 to 9) := "1001110010";
constant Spr_Addr_MAS2U         : std_ulogic_vector(0 to 9) := "1001110111";
constant Spr_Addr_MAS3          : std_ulogic_vector(0 to 9) := "1001110011";
constant Spr_Addr_MAS4          : std_ulogic_vector(0 to 9) := "1001110100";
constant Spr_Addr_MAS5          : std_ulogic_vector(0 to 9) := "0101010011";
constant Spr_Addr_MAS6          : std_ulogic_vector(0 to 9) := "1001110110";
constant Spr_Addr_MAS7          : std_ulogic_vector(0 to 9) := "1110110000";
constant Spr_Addr_MAS8          : std_ulogic_vector(0 to 9) := "0101010101";
constant Spr_Addr_MAS56_64b     : std_ulogic_vector(0 to 9) := "0101011100";
constant Spr_Addr_MAS81_64b     : std_ulogic_vector(0 to 9) := "0101011101";
constant Spr_Addr_MAS73_64b     : std_ulogic_vector(0 to 9) := "0101110100";
constant Spr_Addr_MAS01_64b     : std_ulogic_vector(0 to 9) := "0101110101";
constant Spr_Addr_MMUCFG        : std_ulogic_vector(0 to 9) := "1111110111";
constant Spr_Addr_MMUCSR0       : std_ulogic_vector(0 to 9) := "1111110100";
constant Spr_Addr_TLB0CFG       : std_ulogic_vector(0 to 9) := "1010110000";
constant Spr_Addr_TLB0PS        : std_ulogic_vector(0 to 9) := "0101011000";
constant Spr_Addr_LRATCFG       : std_ulogic_vector(0 to 9) := "0101010110";
constant Spr_Addr_LRATPS        : std_ulogic_vector(0 to 9) := "0101010111";
constant Spr_Addr_EPTCFG        : std_ulogic_vector(0 to 9) := "0101011110";
constant Spr_Addr_LPER          : std_ulogic_vector(0 to 9) := "0000111000";
constant Spr_Addr_LPERU         : std_ulogic_vector(0 to 9) := "0000111001";
-- MMUCFG: 32:35 resv, 36:39 LPIDSIZE=0x8, 40:46 RASIZE=0x2a, 47 LRAT bcfg, 48 TWC bcfg,
--         49:52 resv, 53:57 PIDSIZE=0xd, 58:59 resv, 60:61 NTLBS=0b00, 62:63 MAVN=0b01
constant Spr_Data_MMUCFG        : std_ulogic_vector(32 to 63) := "00001000010101011000001101000001";
-- TLB0CFG: 32:39 ASSOC=0x04, 40:44 resv, 45 PT bcfg, 46 IND bcfg, 47 GTWE bcfg,
--          48 IPROT=1, 49 resv, 50 HES=1, 51 resv, 52:63 NENTRY=0x200
constant Spr_Data_TLB0CFG       : std_ulogic_vector(32 to 63) := "00000100000000001010001000000000";
-- TLB0PS: 32:63 PS31-PS0=0x0010_4444 (PS20, PS14, PS10, PS6, PS2 = 1, others = 0)
constant Spr_Data_TLB0PS        : std_ulogic_vector(32 to 63) := "00000000000100000100010001000100";
-- LRATCFG: 32:39 ASSOC=0x00, 40:46 LASIZE=0x2a, 47:49 resv, 50 LPID=1, 51 resv, 52:63 NENTRY=0x008
constant Spr_Data_LRATCFG       : std_ulogic_vector(32 to 63) := "00000000010101000010000000001000";
-- LRATPS: 32:63 PS31-PS0=0x5154_4400 (PS30, PS28, PS24, PS22, PS20, PS18, PS14, PS10 = 1, others = 0)
constant Spr_Data_LRATPS        : std_ulogic_vector(32 to 63) := "01010001010101000100010000000000";
-- EPTCFG: 32:43 resv,  44:48 PS1=0x12, 49:53 SPS1=0x06, 54:58 PS0=0x0a, 59:63 SPS0=0x02
constant Spr_Data_EPTCFG       : std_ulogic_vector(32 to 63) := "00000000000010010001100101000010";
-- latches scan chain constants
constant spr_ctl_in_offset             : natural := 0;
constant spr_etid_in_offset            : natural := spr_ctl_in_offset + spr_ctl_width;
constant spr_addr_in_offset            : natural := spr_etid_in_offset + spr_etid_width;
constant spr_data_in_offset            : natural := spr_addr_in_offset + spr_addr_width;
constant spr_ctl_int_offset             : natural := spr_data_in_offset + spr_data_width;
constant spr_etid_int_offset            : natural := spr_ctl_int_offset + spr_ctl_width;
constant spr_addr_int_offset            : natural := spr_etid_int_offset + spr_etid_width;
constant spr_data_int_offset            : natural := spr_addr_int_offset + spr_addr_width;
constant spr_ctl_out_offset             : natural := spr_data_int_offset + spr_data_width;
constant spr_etid_out_offset            : natural := spr_ctl_out_offset + spr_ctl_width;
constant spr_addr_out_offset            : natural := spr_etid_out_offset + spr_etid_width;
constant spr_data_out_offset            : natural := spr_addr_out_offset + spr_addr_width;
constant spr_match_any_mmu_offset       : natural := spr_data_out_offset + spr_data_width;
constant spr_match_pid0_offset           : natural := spr_match_any_mmu_offset + 1;
constant spr_match_pid1_offset           : natural := spr_match_pid0_offset + 1;
constant spr_match_pid2_offset           : natural := spr_match_pid1_offset + 1;
constant spr_match_pid3_offset           : natural := spr_match_pid2_offset + 1;
constant spr_match_mmucr0_0_offset           : natural := spr_match_pid3_offset + 1;
constant spr_match_mmucr0_1_offset           : natural := spr_match_mmucr0_0_offset + 1;
constant spr_match_mmucr0_2_offset           : natural := spr_match_mmucr0_1_offset + 1;
constant spr_match_mmucr0_3_offset           : natural := spr_match_mmucr0_2_offset + 1;
constant spr_match_mmucr1_offset           : natural := spr_match_mmucr0_3_offset + 1;
constant spr_match_mmucr2_offset           : natural := spr_match_mmucr1_offset + 1;
constant spr_match_mmucr3_0_offset           : natural := spr_match_mmucr2_offset + 1;
constant spr_match_mmucr3_1_offset           : natural := spr_match_mmucr3_0_offset + 1;
constant spr_match_mmucr3_2_offset           : natural := spr_match_mmucr3_1_offset + 1;
constant spr_match_mmucr3_3_offset           : natural := spr_match_mmucr3_2_offset + 1;
constant spr_match_lpidr_offset             : natural := spr_match_mmucr3_3_offset + 1;
constant pid0_offset               : natural := spr_match_lpidr_offset + 1;
constant pid1_offset               : natural := pid0_offset + pid_width;
constant pid2_offset               : natural := pid1_offset + pid_width;
constant pid3_offset               : natural := pid2_offset + pid_width;
constant mmucr0_0_offset            : natural := pid3_offset + pid_width;
constant mmucr0_1_offset            : natural := mmucr0_0_offset + mmucr0_width;
constant mmucr0_2_offset            : natural := mmucr0_1_offset + mmucr0_width;
constant mmucr0_3_offset            : natural := mmucr0_2_offset + mmucr0_width;
constant lpidr_offset               : natural := mmucr0_3_offset + mmucr0_width;
constant spare_a_offset             : natural := lpidr_offset + lpid_width;
constant spr_mmu_act_offset         : natural := spare_a_offset + 32;
constant spr_val_act_offset         : natural := spr_mmu_act_offset + thdid_width +1;
constant cswitch_offset             : natural := spr_val_act_offset + 4;
constant scan_right_0               : natural := cswitch_offset + 4 -1;
-- MAS register constants
constant spr_match_mmucsr0_offset           : natural := 0;
constant spr_match_mmucfg_offset            : natural := spr_match_mmucsr0_offset + 1;
constant spr_match_tlb0cfg_offset           : natural := spr_match_mmucfg_offset + 1;
constant spr_match_tlb0ps_offset          : natural := spr_match_tlb0cfg_offset + 1;
constant spr_match_lratcfg_offset         : natural := spr_match_tlb0ps_offset + 1;
constant spr_match_lratps_offset          : natural := spr_match_lratcfg_offset + 1;
constant spr_match_eptcfg_offset          : natural := spr_match_lratps_offset + 1;
constant spr_match_lper_0_offset          : natural := spr_match_eptcfg_offset + 1;
constant spr_match_lper_1_offset          : natural := spr_match_lper_0_offset + 1;
constant spr_match_lper_2_offset          : natural := spr_match_lper_1_offset + 1;
constant spr_match_lper_3_offset          : natural := spr_match_lper_2_offset + 1;
constant spr_match_lperu_0_offset          : natural := spr_match_lper_3_offset + 1;
constant spr_match_lperu_1_offset          : natural := spr_match_lperu_0_offset + 1;
constant spr_match_lperu_2_offset          : natural := spr_match_lperu_1_offset + 1;
constant spr_match_lperu_3_offset          : natural := spr_match_lperu_2_offset + 1;
constant spr_match_mas0_0_offset           : natural := spr_match_lperu_3_offset + 1;
constant spr_match_mas1_0_offset           : natural := spr_match_mas0_0_offset + 1;
constant spr_match_mas2_0_offset           : natural := spr_match_mas1_0_offset + 1;
constant spr_match_mas2u_0_offset          : natural := spr_match_mas2_0_offset + 1;
constant spr_match_mas3_0_offset           : natural := spr_match_mas2u_0_offset + 1;
constant spr_match_mas4_0_offset           : natural := spr_match_mas3_0_offset + 1;
constant spr_match_mas5_0_offset           : natural := spr_match_mas4_0_offset + 1;
constant spr_match_mas6_0_offset           : natural := spr_match_mas5_0_offset + 1;
constant spr_match_mas7_0_offset           : natural := spr_match_mas6_0_offset + 1;
constant spr_match_mas8_0_offset           : natural := spr_match_mas7_0_offset + 1;
constant spr_match_mas01_64b_0_offset           : natural := spr_match_mas8_0_offset + 1;
constant spr_match_mas56_64b_0_offset           : natural := spr_match_mas01_64b_0_offset + 1;
constant spr_match_mas73_64b_0_offset           : natural := spr_match_mas56_64b_0_offset + 1;
constant spr_match_mas81_64b_0_offset           : natural := spr_match_mas73_64b_0_offset + 1;
constant spr_match_mas0_1_offset             : natural := spr_match_mas81_64b_0_offset     + 1;
constant spr_match_mas1_1_offset             : natural := spr_match_mas0_1_offset   + 1;
constant spr_match_mas2_1_offset             : natural := spr_match_mas1_1_offset   + 1;
constant spr_match_mas2u_1_offset            : natural := spr_match_mas2_1_offset   + 1;
constant spr_match_mas3_1_offset             : natural := spr_match_mas2u_1_offset   + 1;
constant spr_match_mas4_1_offset             : natural := spr_match_mas3_1_offset   + 1;
constant spr_match_mas5_1_offset             : natural := spr_match_mas4_1_offset   + 1;
constant spr_match_mas6_1_offset             : natural := spr_match_mas5_1_offset   + 1;
constant spr_match_mas7_1_offset             : natural := spr_match_mas6_1_offset   + 1;
constant spr_match_mas8_1_offset             : natural := spr_match_mas7_1_offset   + 1;
constant spr_match_mas01_64b_1_offset             : natural := spr_match_mas8_1_offset   + 1;
constant spr_match_mas56_64b_1_offset             : natural := spr_match_mas01_64b_1_offset   + 1;
constant spr_match_mas73_64b_1_offset             : natural := spr_match_mas56_64b_1_offset   + 1;
constant spr_match_mas81_64b_1_offset             : natural := spr_match_mas73_64b_1_offset   + 1;
constant spr_match_mas0_2_offset             : natural := spr_match_mas81_64b_1_offset     + 1;
constant spr_match_mas1_2_offset             : natural := spr_match_mas0_2_offset   + 1;
constant spr_match_mas2_2_offset             : natural := spr_match_mas1_2_offset   + 1;
constant spr_match_mas2u_2_offset            : natural := spr_match_mas2_2_offset   + 1;
constant spr_match_mas3_2_offset             : natural := spr_match_mas2u_2_offset   + 1;
constant spr_match_mas4_2_offset             : natural := spr_match_mas3_2_offset   + 1;
constant spr_match_mas5_2_offset             : natural := spr_match_mas4_2_offset   + 1;
constant spr_match_mas6_2_offset             : natural := spr_match_mas5_2_offset   + 1;
constant spr_match_mas7_2_offset             : natural := spr_match_mas6_2_offset   + 1;
constant spr_match_mas8_2_offset             : natural := spr_match_mas7_2_offset   + 1;
constant spr_match_mas01_64b_2_offset             : natural := spr_match_mas8_2_offset   + 1;
constant spr_match_mas56_64b_2_offset             : natural := spr_match_mas01_64b_2_offset   + 1;
constant spr_match_mas73_64b_2_offset             : natural := spr_match_mas56_64b_2_offset   + 1;
constant spr_match_mas81_64b_2_offset             : natural := spr_match_mas73_64b_2_offset   + 1;
constant spr_match_mas0_3_offset             : natural := spr_match_mas81_64b_2_offset     + 1;
constant spr_match_mas1_3_offset             : natural := spr_match_mas0_3_offset   + 1;
constant spr_match_mas2_3_offset             : natural := spr_match_mas1_3_offset   + 1;
constant spr_match_mas2u_3_offset            : natural := spr_match_mas2_3_offset   + 1;
constant spr_match_mas3_3_offset             : natural := spr_match_mas2u_3_offset   + 1;
constant spr_match_mas4_3_offset             : natural := spr_match_mas3_3_offset   + 1;
constant spr_match_mas5_3_offset             : natural := spr_match_mas4_3_offset   + 1;
constant spr_match_mas6_3_offset             : natural := spr_match_mas5_3_offset   + 1;
constant spr_match_mas7_3_offset             : natural := spr_match_mas6_3_offset   + 1;
constant spr_match_mas8_3_offset             : natural := spr_match_mas7_3_offset   + 1;
constant spr_match_mas01_64b_3_offset             : natural := spr_match_mas8_3_offset   + 1;
constant spr_match_mas56_64b_3_offset             : natural := spr_match_mas01_64b_3_offset   + 1;
constant spr_match_mas73_64b_3_offset             : natural := spr_match_mas56_64b_3_offset   + 1;
constant spr_match_mas81_64b_3_offset             : natural := spr_match_mas73_64b_3_offset   + 1;
constant spr_match_64b_offset           : natural := spr_match_mas81_64b_3_offset + 1;
constant spr_addr_in_clone_offset       : natural := spr_match_64b_offset + 1;
constant spr_mas_data_out_offset        : natural := spr_addr_in_clone_offset + spr_addr_width;
constant spr_match_any_mas_offset       : natural := spr_mas_data_out_offset + spr_data_width;
constant mas0_0_atsel_offset         : natural := spr_match_any_mas_offset + 1;
constant mas0_0_esel_offset          : natural := mas0_0_atsel_offset + 1;
constant mas0_0_hes_offset           : natural := mas0_0_esel_offset + 3;
constant mas0_0_wq_offset            : natural := mas0_0_hes_offset + 1;
constant mas1_0_v_offset             : natural := mas0_0_wq_offset + 2;
constant mas1_0_iprot_offset         : natural := mas1_0_v_offset + 1;
constant mas1_0_tid_offset           : natural := mas1_0_iprot_offset + 1;
constant mas1_0_ind_offset           : natural := mas1_0_tid_offset + 14;
constant mas1_0_ts_offset            : natural := mas1_0_ind_offset + 1;
constant mas1_0_tsize_offset         : natural := mas1_0_ts_offset + 1;
constant mas2_0_epn_offset           : natural := mas1_0_tsize_offset + 4;
constant mas2_0_wimge_offset         : natural := mas2_0_epn_offset + 52+spr_data_width-64;
constant mas3_0_rpnl_offset          : natural := mas2_0_wimge_offset + 5;
constant mas3_0_ubits_offset         : natural := mas3_0_rpnl_offset + 21;
constant mas3_0_usxwr_offset         : natural := mas3_0_ubits_offset + 4;
constant mas5_0_sgs_offset           : natural := mas3_0_usxwr_offset + 6;
constant mas5_0_slpid_offset         : natural := mas5_0_sgs_offset + 1;
constant mas6_0_spid_offset          : natural := mas5_0_slpid_offset + 8;
constant mas6_0_isize_offset         : natural := mas6_0_spid_offset + 14;
constant mas6_0_sind_offset          : natural := mas6_0_isize_offset + 4;
constant mas6_0_sas_offset           : natural := mas6_0_sind_offset + 1;
constant mas7_0_rpnu_offset          : natural := mas6_0_sas_offset + 1;
constant mas8_0_tgs_offset           : natural := mas7_0_rpnu_offset + 10;
constant mas8_0_vf_offset            : natural := mas8_0_tgs_offset + 1;
constant mas8_0_tlpid_offset         : natural := mas8_0_vf_offset + 1;
constant mas0_1_atsel_offset           : natural := mas8_0_tlpid_offset     + 8;
constant mas0_1_esel_offset            : natural := mas0_1_atsel_offset   + 1;
constant mas0_1_hes_offset             : natural := mas0_1_esel_offset   + 3;
constant mas0_1_wq_offset              : natural := mas0_1_hes_offset   + 1;
constant mas1_1_v_offset               : natural := mas0_1_wq_offset   + 2;
constant mas1_1_iprot_offset           : natural := mas1_1_v_offset   + 1;
constant mas1_1_tid_offset             : natural := mas1_1_iprot_offset   + 1;
constant mas1_1_ind_offset             : natural := mas1_1_tid_offset   + 14;
constant mas1_1_ts_offset              : natural := mas1_1_ind_offset   + 1;
constant mas1_1_tsize_offset           : natural := mas1_1_ts_offset   + 1;
constant mas2_1_epn_offset             : natural := mas1_1_tsize_offset   + 4;
constant mas2_1_wimge_offset           : natural := mas2_1_epn_offset   + 52+spr_data_width-64;
constant mas3_1_rpnl_offset            : natural := mas2_1_wimge_offset   + 5;
constant mas3_1_ubits_offset           : natural := mas3_1_rpnl_offset   + 21;
constant mas3_1_usxwr_offset           : natural := mas3_1_ubits_offset   + 4;
constant mas5_1_sgs_offset             : natural := mas3_1_usxwr_offset   + 6;
constant mas5_1_slpid_offset           : natural := mas5_1_sgs_offset   + 1;
constant mas6_1_spid_offset            : natural := mas5_1_slpid_offset   + 8;
constant mas6_1_isize_offset           : natural := mas6_1_spid_offset   + 14;
constant mas6_1_sind_offset            : natural := mas6_1_isize_offset   + 4;
constant mas6_1_sas_offset             : natural := mas6_1_sind_offset   + 1;
constant mas7_1_rpnu_offset            : natural := mas6_1_sas_offset   + 1;
constant mas8_1_tgs_offset             : natural := mas7_1_rpnu_offset   + 10;
constant mas8_1_vf_offset              : natural := mas8_1_tgs_offset   + 1;
constant mas8_1_tlpid_offset           : natural := mas8_1_vf_offset   + 1;
constant mas0_2_atsel_offset           : natural := mas8_1_tlpid_offset     + 8;
constant mas0_2_esel_offset            : natural := mas0_2_atsel_offset   + 1;
constant mas0_2_hes_offset             : natural := mas0_2_esel_offset   + 3;
constant mas0_2_wq_offset              : natural := mas0_2_hes_offset   + 1;
constant mas1_2_v_offset               : natural := mas0_2_wq_offset   + 2;
constant mas1_2_iprot_offset           : natural := mas1_2_v_offset   + 1;
constant mas1_2_tid_offset             : natural := mas1_2_iprot_offset   + 1;
constant mas1_2_ind_offset             : natural := mas1_2_tid_offset   + 14;
constant mas1_2_ts_offset              : natural := mas1_2_ind_offset   + 1;
constant mas1_2_tsize_offset           : natural := mas1_2_ts_offset   + 1;
constant mas2_2_epn_offset             : natural := mas1_2_tsize_offset   + 4;
constant mas2_2_wimge_offset           : natural := mas2_2_epn_offset   + 52+spr_data_width-64;
constant mas3_2_rpnl_offset            : natural := mas2_2_wimge_offset   + 5;
constant mas3_2_ubits_offset           : natural := mas3_2_rpnl_offset   + 21;
constant mas3_2_usxwr_offset           : natural := mas3_2_ubits_offset   + 4;
constant mas5_2_sgs_offset             : natural := mas3_2_usxwr_offset   + 6;
constant mas5_2_slpid_offset           : natural := mas5_2_sgs_offset   + 1;
constant mas6_2_spid_offset            : natural := mas5_2_slpid_offset   + 8;
constant mas6_2_isize_offset           : natural := mas6_2_spid_offset   + 14;
constant mas6_2_sind_offset            : natural := mas6_2_isize_offset   + 4;
constant mas6_2_sas_offset             : natural := mas6_2_sind_offset   + 1;
constant mas7_2_rpnu_offset            : natural := mas6_2_sas_offset   + 1;
constant mas8_2_tgs_offset             : natural := mas7_2_rpnu_offset   + 10;
constant mas8_2_vf_offset              : natural := mas8_2_tgs_offset   + 1;
constant mas8_2_tlpid_offset           : natural := mas8_2_vf_offset   + 1;
constant mas0_3_atsel_offset           : natural := mas8_2_tlpid_offset     + 8;
constant mas0_3_esel_offset            : natural := mas0_3_atsel_offset   + 1;
constant mas0_3_hes_offset             : natural := mas0_3_esel_offset   + 3;
constant mas0_3_wq_offset              : natural := mas0_3_hes_offset   + 1;
constant mas1_3_v_offset               : natural := mas0_3_wq_offset   + 2;
constant mas1_3_iprot_offset           : natural := mas1_3_v_offset   + 1;
constant mas1_3_tid_offset             : natural := mas1_3_iprot_offset   + 1;
constant mas1_3_ind_offset             : natural := mas1_3_tid_offset   + 14;
constant mas1_3_ts_offset              : natural := mas1_3_ind_offset   + 1;
constant mas1_3_tsize_offset           : natural := mas1_3_ts_offset   + 1;
constant mas2_3_epn_offset             : natural := mas1_3_tsize_offset   + 4;
constant mas2_3_wimge_offset           : natural := mas2_3_epn_offset   + 52+spr_data_width-64;
constant mas3_3_rpnl_offset            : natural := mas2_3_wimge_offset   + 5;
constant mas3_3_ubits_offset           : natural := mas3_3_rpnl_offset   + 21;
constant mas3_3_usxwr_offset           : natural := mas3_3_ubits_offset   + 4;
constant mas5_3_sgs_offset             : natural := mas3_3_usxwr_offset   + 6;
constant mas5_3_slpid_offset           : natural := mas5_3_sgs_offset   + 1;
constant mas6_3_spid_offset            : natural := mas5_3_slpid_offset   + 8;
constant mas6_3_isize_offset           : natural := mas6_3_spid_offset   + 14;
constant mas6_3_sind_offset            : natural := mas6_3_isize_offset   + 4;
constant mas6_3_sas_offset             : natural := mas6_3_sind_offset   + 1;
constant mas7_3_rpnu_offset            : natural := mas6_3_sas_offset   + 1;
constant mas8_3_tgs_offset             : natural := mas7_3_rpnu_offset   + 10;
constant mas8_3_vf_offset              : natural := mas8_3_tgs_offset   + 1;
constant mas8_3_tlpid_offset           : natural := mas8_3_vf_offset   + 1;
constant mmucsr0_tlb0fi_offset     : natural := mas8_3_tlpid_offset + 8;
constant scan_right_a                 : natural := mmucsr0_tlb0fi_offset + 1;
constant lper_0_alpn_offset      : natural := scan_right_a;
constant lper_0_lps_offset       : natural := lper_0_alpn_offset + real_addr_width-12;
constant lper_1_alpn_offset        : natural := lper_0_lps_offset     + 4;
constant lper_1_lps_offset         : natural := lper_1_alpn_offset   + real_addr_width-12;
constant lper_2_alpn_offset        : natural := lper_1_lps_offset     + 4;
constant lper_2_lps_offset         : natural := lper_2_alpn_offset   + real_addr_width-12;
constant lper_3_alpn_offset        : natural := lper_2_lps_offset     + 4;
constant lper_3_lps_offset         : natural := lper_3_alpn_offset   + real_addr_width-12;
constant spare_b_offset               : natural := lper_3_lps_offset + 4;
constant cat_emf_act_offset         : natural := spare_b_offset + 64;
constant scan_right_1                 : natural := cat_emf_act_offset + thdid_width -1;
-- boot config scan bits
constant mmucfg_offset              : natural := 0;
constant tlb0cfg_offset             : natural := mmucfg_offset + 2;
constant mmucr1_offset              : natural := tlb0cfg_offset + 3;
constant mmucr2_offset              : natural := mmucr1_offset + mmucr1_width;
constant mmucr3_0_offset            : natural := mmucr2_offset + mmucr2_width;
constant mmucr3_1_offset            : natural := mmucr3_0_offset + mmucr3_width;
constant mmucr3_2_offset            : natural := mmucr3_1_offset + mmucr3_width;
constant mmucr3_3_offset            : natural := mmucr3_2_offset + mmucr3_width;
constant mas4_0_indd_offset         : natural := mmucr3_3_offset + mmucr3_width;
constant mas4_0_tsized_offset       : natural := mas4_0_indd_offset + 1;
constant mas4_0_wimged_offset       : natural := mas4_0_tsized_offset + 4;
constant mas4_1_indd_offset         : natural := mas4_0_wimged_offset + 5;
constant mas4_1_tsized_offset       : natural := mas4_1_indd_offset + 1;
constant mas4_1_wimged_offset       : natural := mas4_1_tsized_offset + 4;
constant mas4_2_indd_offset         : natural := mas4_1_wimged_offset + 5;
constant mas4_2_tsized_offset       : natural := mas4_2_indd_offset + 1;
constant mas4_2_wimged_offset       : natural := mas4_2_tsized_offset + 4;
constant mas4_3_indd_offset         : natural := mas4_2_wimged_offset + 5;
constant mas4_3_tsized_offset       : natural := mas4_3_indd_offset + 1;
constant mas4_3_wimged_offset       : natural := mas4_3_tsized_offset + 4;
constant bcfg_spare_offset          : natural := mas4_3_wimged_offset + 5;
constant boot_scan_right            : natural := bcfg_spare_offset + 16 - 1;
signal spr_match_any_mmu, spr_match_any_mmu_q       : std_ulogic;
signal spr_match_pid0, spr_match_pid0_q           : std_ulogic;
signal spr_match_pid1, spr_match_pid1_q           : std_ulogic;
signal spr_match_pid2, spr_match_pid2_q           : std_ulogic;
signal spr_match_pid3, spr_match_pid3_q           : std_ulogic;
signal spr_match_mmucr0_0, spr_match_mmucr0_0_q           : std_ulogic;
signal spr_match_mmucr0_1, spr_match_mmucr0_1_q           : std_ulogic;
signal spr_match_mmucr0_2, spr_match_mmucr0_2_q           : std_ulogic;
signal spr_match_mmucr0_3, spr_match_mmucr0_3_q           : std_ulogic;
signal spr_match_mmucr1, spr_match_mmucr1_q           : std_ulogic;
signal spr_match_mmucr2, spr_match_mmucr2_q           : std_ulogic;
signal spr_match_mmucr3_0, spr_match_mmucr3_0_q           : std_ulogic;
signal spr_match_mmucr3_1, spr_match_mmucr3_1_q           : std_ulogic;
signal spr_match_mmucr3_2, spr_match_mmucr3_2_q           : std_ulogic;
signal spr_match_mmucr3_3, spr_match_mmucr3_3_q           : std_ulogic;
signal spr_match_lpidr, spr_match_lpidr_q             : std_ulogic;
signal spr_match_mmucsr0, spr_match_mmucsr0_q           : std_ulogic;
signal spr_match_mmucfg, spr_match_mmucfg_q            : std_ulogic;
signal spr_match_tlb0cfg, spr_match_tlb0cfg_q           : std_ulogic;
signal spr_match_tlb0ps, spr_match_tlb0ps_q          : std_ulogic;
signal spr_match_lratcfg, spr_match_lratcfg_q           : std_ulogic;
signal spr_match_lratps, spr_match_lratps_q          : std_ulogic;
signal spr_match_eptcfg, spr_match_eptcfg_q          : std_ulogic;
signal spr_match_lper_0, spr_match_lper_0_q          : std_ulogic;
signal spr_match_lper_1, spr_match_lper_1_q          : std_ulogic;
signal spr_match_lper_2, spr_match_lper_2_q          : std_ulogic;
signal spr_match_lper_3, spr_match_lper_3_q          : std_ulogic;
signal spr_match_lperu_0, spr_match_lperu_0_q          : std_ulogic;
signal spr_match_lperu_1, spr_match_lperu_1_q          : std_ulogic;
signal spr_match_lperu_2, spr_match_lperu_2_q          : std_ulogic;
signal spr_match_lperu_3, spr_match_lperu_3_q          : std_ulogic;
signal spr_match_mas0_0,   spr_match_mas0_0_q             : std_ulogic;
signal spr_match_mas1_0,   spr_match_mas1_0_q             : std_ulogic;
signal spr_match_mas2_0,   spr_match_mas2_0_q             : std_ulogic;
signal spr_match_mas2u_0,   spr_match_mas2u_0_q             : std_ulogic;
signal spr_match_mas3_0,   spr_match_mas3_0_q             : std_ulogic;
signal spr_match_mas4_0,   spr_match_mas4_0_q             : std_ulogic;
signal spr_match_mas5_0,   spr_match_mas5_0_q             : std_ulogic;
signal spr_match_mas6_0,   spr_match_mas6_0_q             : std_ulogic;
signal spr_match_mas7_0,   spr_match_mas7_0_q             : std_ulogic;
signal spr_match_mas8_0,   spr_match_mas8_0_q             : std_ulogic;
signal spr_match_mas01_64b_0,   spr_match_mas01_64b_0_q             : std_ulogic;
signal spr_match_mas56_64b_0,   spr_match_mas56_64b_0_q             : std_ulogic;
signal spr_match_mas73_64b_0,   spr_match_mas73_64b_0_q             : std_ulogic;
signal spr_match_mas81_64b_0,   spr_match_mas81_64b_0_q             : std_ulogic;
signal spr_match_mas0_1,   spr_match_mas0_1_q             : std_ulogic;
signal spr_match_mas1_1,   spr_match_mas1_1_q             : std_ulogic;
signal spr_match_mas2_1,   spr_match_mas2_1_q             : std_ulogic;
signal spr_match_mas2u_1,   spr_match_mas2u_1_q             : std_ulogic;
signal spr_match_mas3_1,   spr_match_mas3_1_q             : std_ulogic;
signal spr_match_mas4_1,   spr_match_mas4_1_q             : std_ulogic;
signal spr_match_mas5_1,   spr_match_mas5_1_q             : std_ulogic;
signal spr_match_mas6_1,   spr_match_mas6_1_q             : std_ulogic;
signal spr_match_mas7_1,   spr_match_mas7_1_q             : std_ulogic;
signal spr_match_mas8_1,   spr_match_mas8_1_q             : std_ulogic;
signal spr_match_mas01_64b_1,   spr_match_mas01_64b_1_q             : std_ulogic;
signal spr_match_mas56_64b_1,   spr_match_mas56_64b_1_q             : std_ulogic;
signal spr_match_mas73_64b_1,   spr_match_mas73_64b_1_q             : std_ulogic;
signal spr_match_mas81_64b_1,   spr_match_mas81_64b_1_q             : std_ulogic;
signal spr_match_mas0_2,   spr_match_mas0_2_q             : std_ulogic;
signal spr_match_mas1_2,   spr_match_mas1_2_q             : std_ulogic;
signal spr_match_mas2_2,   spr_match_mas2_2_q             : std_ulogic;
signal spr_match_mas2u_2,   spr_match_mas2u_2_q             : std_ulogic;
signal spr_match_mas3_2,   spr_match_mas3_2_q             : std_ulogic;
signal spr_match_mas4_2,   spr_match_mas4_2_q             : std_ulogic;
signal spr_match_mas5_2,   spr_match_mas5_2_q             : std_ulogic;
signal spr_match_mas6_2,   spr_match_mas6_2_q             : std_ulogic;
signal spr_match_mas7_2,   spr_match_mas7_2_q             : std_ulogic;
signal spr_match_mas8_2,   spr_match_mas8_2_q             : std_ulogic;
signal spr_match_mas01_64b_2,   spr_match_mas01_64b_2_q             : std_ulogic;
signal spr_match_mas56_64b_2,   spr_match_mas56_64b_2_q             : std_ulogic;
signal spr_match_mas73_64b_2,   spr_match_mas73_64b_2_q             : std_ulogic;
signal spr_match_mas81_64b_2,   spr_match_mas81_64b_2_q             : std_ulogic;
signal spr_match_mas0_3,   spr_match_mas0_3_q             : std_ulogic;
signal spr_match_mas1_3,   spr_match_mas1_3_q             : std_ulogic;
signal spr_match_mas2_3,   spr_match_mas2_3_q             : std_ulogic;
signal spr_match_mas2u_3,   spr_match_mas2u_3_q             : std_ulogic;
signal spr_match_mas3_3,   spr_match_mas3_3_q             : std_ulogic;
signal spr_match_mas4_3,   spr_match_mas4_3_q             : std_ulogic;
signal spr_match_mas5_3,   spr_match_mas5_3_q             : std_ulogic;
signal spr_match_mas6_3,   spr_match_mas6_3_q             : std_ulogic;
signal spr_match_mas7_3,   spr_match_mas7_3_q             : std_ulogic;
signal spr_match_mas8_3,   spr_match_mas8_3_q             : std_ulogic;
signal spr_match_mas01_64b_3,   spr_match_mas01_64b_3_q             : std_ulogic;
signal spr_match_mas56_64b_3,   spr_match_mas56_64b_3_q             : std_ulogic;
signal spr_match_mas73_64b_3,   spr_match_mas73_64b_3_q             : std_ulogic;
signal spr_match_mas81_64b_3,   spr_match_mas81_64b_3_q             : std_ulogic;
signal spr_mas_data_out, spr_mas_data_out_q         : std_ulogic_vector(64-spr_data_width to 63);
signal spr_match_any_mas, spr_match_any_mas_q       : std_ulogic;
signal spr_match_mas2_64b   : std_ulogic;
signal spr_match_mas01_64b  : std_ulogic;
signal spr_match_mas56_64b  : std_ulogic;
signal spr_match_mas73_64b  : std_ulogic;
signal spr_match_mas81_64b  : std_ulogic;
signal spr_match_64b, spr_match_64b_q        : std_ulogic;
-- added input latches for timing with adding numerous mas regs
signal spr_ctl_in_d, spr_ctl_in_q           : std_ulogic_vector(0 to spr_ctl_width-1);
signal spr_etid_in_d, spr_etid_in_q         : std_ulogic_vector(0 to spr_etid_width-1);
signal spr_addr_in_d, spr_addr_in_q         : std_ulogic_vector(0 to spr_addr_width-1);
signal spr_data_in_d, spr_data_in_q         : std_ulogic_vector(64-spr_data_width to 63);
signal spr_addr_in_clone_d, spr_addr_in_clone_q         : std_ulogic_vector(0 to spr_addr_width-1);
signal spr_ctl_int_d, spr_ctl_int_q           : std_ulogic_vector(0 to spr_ctl_width-1);
signal spr_etid_int_d, spr_etid_int_q         : std_ulogic_vector(0 to spr_etid_width-1);
signal spr_addr_int_d, spr_addr_int_q         : std_ulogic_vector(0 to spr_addr_width-1);
signal spr_data_int_d, spr_data_int_q         : std_ulogic_vector(64-spr_data_width to 63);
signal spr_ctl_out_d, spr_ctl_out_q           : std_ulogic_vector(0 to spr_ctl_width-1);
signal spr_etid_out_d, spr_etid_out_q         : std_ulogic_vector(0 to spr_etid_width-1);
signal spr_addr_out_d, spr_addr_out_q         : std_ulogic_vector(0 to spr_addr_width-1);
signal spr_data_out_d, spr_data_out_q         : std_ulogic_vector(64-spr_data_width to 63);
signal pid0_d,   pid0_q    : std_ulogic_vector(0 to pid_width-1);
signal mmucr0_0_d,   mmucr0_0_q    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr3_0_d,   mmucr3_0_q    : std_ulogic_vector(64-mmucr3_width to 63);
signal pid1_d,   pid1_q    : std_ulogic_vector(0 to pid_width-1);
signal mmucr0_1_d,   mmucr0_1_q    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr3_1_d,   mmucr3_1_q    : std_ulogic_vector(64-mmucr3_width to 63);
signal pid2_d,   pid2_q    : std_ulogic_vector(0 to pid_width-1);
signal mmucr0_2_d,   mmucr0_2_q    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr3_2_d,   mmucr3_2_q    : std_ulogic_vector(64-mmucr3_width to 63);
signal pid3_d,   pid3_q    : std_ulogic_vector(0 to pid_width-1);
signal mmucr0_3_d,   mmucr0_3_q    : std_ulogic_vector(0 to mmucr0_width-1);
signal mmucr3_3_d,   mmucr3_3_q    : std_ulogic_vector(64-mmucr3_width to 63);
signal mmucr1_d, mmucr1_q  : std_ulogic_vector(0 to mmucr1_width-1);
signal mmucr2_d, mmucr2_q  : std_ulogic_vector(0 to mmucr2_width-1);
signal lpidr_d, lpidr_q  : std_ulogic_vector(0 to lpid_width-1);
signal mas0_0_atsel_d,   mas0_0_atsel_q           : std_ulogic;
signal mas0_0_esel_d,   mas0_0_esel_q             : std_ulogic_vector(0 to 2);
signal mas0_0_hes_d,   mas0_0_hes_q               : std_ulogic;
signal mas0_0_wq_d,   mas0_0_wq_q                 : std_ulogic_vector(0 to 1);
signal mas1_0_v_d,   mas1_0_v_q                   : std_ulogic;
signal mas1_0_iprot_d,   mas1_0_iprot_q           : std_ulogic;
signal mas1_0_tid_d,   mas1_0_tid_q               : std_ulogic_vector(0 to 13);
signal mas1_0_ind_d,   mas1_0_ind_q               : std_ulogic;
signal mas1_0_ts_d,   mas1_0_ts_q                 : std_ulogic;
signal mas1_0_tsize_d,   mas1_0_tsize_q           : std_ulogic_vector(0 to 3);
signal mas2_0_epn_d,   mas2_0_epn_q               : std_ulogic_vector(64-spr_data_width to 51);
signal mas2_0_wimge_d,   mas2_0_wimge_q           : std_ulogic_vector(0 to 4);
signal mas3_0_rpnl_d,   mas3_0_rpnl_q             : std_ulogic_vector(32 to 52);
signal mas3_0_ubits_d,   mas3_0_ubits_q           : std_ulogic_vector(0 to 3);
signal mas3_0_usxwr_d,   mas3_0_usxwr_q           : std_ulogic_vector(0 to 5);
signal mas4_0_indd_d,   mas4_0_indd_q             : std_ulogic;
signal mas4_0_tsized_d,   mas4_0_tsized_q         : std_ulogic_vector(0 to 3);
signal mas4_0_wimged_d,   mas4_0_wimged_q         : std_ulogic_vector(0 to 4);
signal mas5_0_sgs_d,   mas5_0_sgs_q               : std_ulogic;
signal mas5_0_slpid_d,   mas5_0_slpid_q           : std_ulogic_vector(0 to 7);
signal mas6_0_spid_d,   mas6_0_spid_q             : std_ulogic_vector(0 to 13);
signal mas6_0_isize_d,   mas6_0_isize_q           : std_ulogic_vector(0 to 3);
signal mas6_0_sind_d,   mas6_0_sind_q               : std_ulogic;
signal mas6_0_sas_d,   mas6_0_sas_q               : std_ulogic;
signal mas7_0_rpnu_d,   mas7_0_rpnu_q             : std_ulogic_vector(22 to 31);
signal mas8_0_tgs_d,   mas8_0_tgs_q               : std_ulogic;
signal mas8_0_vf_d,   mas8_0_vf_q                 : std_ulogic;
signal mas8_0_tlpid_d,   mas8_0_tlpid_q           : std_ulogic_vector(0 to 7);
signal mas0_1_atsel_d,   mas0_1_atsel_q           : std_ulogic;
signal mas0_1_esel_d,   mas0_1_esel_q             : std_ulogic_vector(0 to 2);
signal mas0_1_hes_d,   mas0_1_hes_q               : std_ulogic;
signal mas0_1_wq_d,   mas0_1_wq_q                 : std_ulogic_vector(0 to 1);
signal mas1_1_v_d,   mas1_1_v_q                   : std_ulogic;
signal mas1_1_iprot_d,   mas1_1_iprot_q           : std_ulogic;
signal mas1_1_tid_d,   mas1_1_tid_q               : std_ulogic_vector(0 to 13);
signal mas1_1_ind_d,   mas1_1_ind_q               : std_ulogic;
signal mas1_1_ts_d,   mas1_1_ts_q                 : std_ulogic;
signal mas1_1_tsize_d,   mas1_1_tsize_q           : std_ulogic_vector(0 to 3);
signal mas2_1_epn_d,   mas2_1_epn_q               : std_ulogic_vector(64-spr_data_width to 51);
signal mas2_1_wimge_d,   mas2_1_wimge_q           : std_ulogic_vector(0 to 4);
signal mas3_1_rpnl_d,   mas3_1_rpnl_q             : std_ulogic_vector(32 to 52);
signal mas3_1_ubits_d,   mas3_1_ubits_q           : std_ulogic_vector(0 to 3);
signal mas3_1_usxwr_d,   mas3_1_usxwr_q           : std_ulogic_vector(0 to 5);
signal mas4_1_indd_d,   mas4_1_indd_q             : std_ulogic;
signal mas4_1_tsized_d,   mas4_1_tsized_q         : std_ulogic_vector(0 to 3);
signal mas4_1_wimged_d,   mas4_1_wimged_q         : std_ulogic_vector(0 to 4);
signal mas5_1_sgs_d,   mas5_1_sgs_q               : std_ulogic;
signal mas5_1_slpid_d,   mas5_1_slpid_q           : std_ulogic_vector(0 to 7);
signal mas6_1_spid_d,   mas6_1_spid_q             : std_ulogic_vector(0 to 13);
signal mas6_1_isize_d,   mas6_1_isize_q           : std_ulogic_vector(0 to 3);
signal mas6_1_sind_d,   mas6_1_sind_q               : std_ulogic;
signal mas6_1_sas_d,   mas6_1_sas_q               : std_ulogic;
signal mas7_1_rpnu_d,   mas7_1_rpnu_q             : std_ulogic_vector(22 to 31);
signal mas8_1_tgs_d,   mas8_1_tgs_q               : std_ulogic;
signal mas8_1_vf_d,   mas8_1_vf_q                 : std_ulogic;
signal mas8_1_tlpid_d,   mas8_1_tlpid_q           : std_ulogic_vector(0 to 7);
signal mas0_2_atsel_d,   mas0_2_atsel_q           : std_ulogic;
signal mas0_2_esel_d,   mas0_2_esel_q             : std_ulogic_vector(0 to 2);
signal mas0_2_hes_d,   mas0_2_hes_q               : std_ulogic;
signal mas0_2_wq_d,   mas0_2_wq_q                 : std_ulogic_vector(0 to 1);
signal mas1_2_v_d,   mas1_2_v_q                   : std_ulogic;
signal mas1_2_iprot_d,   mas1_2_iprot_q           : std_ulogic;
signal mas1_2_tid_d,   mas1_2_tid_q               : std_ulogic_vector(0 to 13);
signal mas1_2_ind_d,   mas1_2_ind_q               : std_ulogic;
signal mas1_2_ts_d,   mas1_2_ts_q                 : std_ulogic;
signal mas1_2_tsize_d,   mas1_2_tsize_q           : std_ulogic_vector(0 to 3);
signal mas2_2_epn_d,   mas2_2_epn_q               : std_ulogic_vector(64-spr_data_width to 51);
signal mas2_2_wimge_d,   mas2_2_wimge_q           : std_ulogic_vector(0 to 4);
signal mas3_2_rpnl_d,   mas3_2_rpnl_q             : std_ulogic_vector(32 to 52);
signal mas3_2_ubits_d,   mas3_2_ubits_q           : std_ulogic_vector(0 to 3);
signal mas3_2_usxwr_d,   mas3_2_usxwr_q           : std_ulogic_vector(0 to 5);
signal mas4_2_indd_d,   mas4_2_indd_q             : std_ulogic;
signal mas4_2_tsized_d,   mas4_2_tsized_q         : std_ulogic_vector(0 to 3);
signal mas4_2_wimged_d,   mas4_2_wimged_q         : std_ulogic_vector(0 to 4);
signal mas5_2_sgs_d,   mas5_2_sgs_q               : std_ulogic;
signal mas5_2_slpid_d,   mas5_2_slpid_q           : std_ulogic_vector(0 to 7);
signal mas6_2_spid_d,   mas6_2_spid_q             : std_ulogic_vector(0 to 13);
signal mas6_2_isize_d,   mas6_2_isize_q           : std_ulogic_vector(0 to 3);
signal mas6_2_sind_d,   mas6_2_sind_q               : std_ulogic;
signal mas6_2_sas_d,   mas6_2_sas_q               : std_ulogic;
signal mas7_2_rpnu_d,   mas7_2_rpnu_q             : std_ulogic_vector(22 to 31);
signal mas8_2_tgs_d,   mas8_2_tgs_q               : std_ulogic;
signal mas8_2_vf_d,   mas8_2_vf_q                 : std_ulogic;
signal mas8_2_tlpid_d,   mas8_2_tlpid_q           : std_ulogic_vector(0 to 7);
signal mas0_3_atsel_d,   mas0_3_atsel_q           : std_ulogic;
signal mas0_3_esel_d,   mas0_3_esel_q             : std_ulogic_vector(0 to 2);
signal mas0_3_hes_d,   mas0_3_hes_q               : std_ulogic;
signal mas0_3_wq_d,   mas0_3_wq_q                 : std_ulogic_vector(0 to 1);
signal mas1_3_v_d,   mas1_3_v_q                   : std_ulogic;
signal mas1_3_iprot_d,   mas1_3_iprot_q           : std_ulogic;
signal mas1_3_tid_d,   mas1_3_tid_q               : std_ulogic_vector(0 to 13);
signal mas1_3_ind_d,   mas1_3_ind_q               : std_ulogic;
signal mas1_3_ts_d,   mas1_3_ts_q                 : std_ulogic;
signal mas1_3_tsize_d,   mas1_3_tsize_q           : std_ulogic_vector(0 to 3);
signal mas2_3_epn_d,   mas2_3_epn_q               : std_ulogic_vector(64-spr_data_width to 51);
signal mas2_3_wimge_d,   mas2_3_wimge_q           : std_ulogic_vector(0 to 4);
signal mas3_3_rpnl_d,   mas3_3_rpnl_q             : std_ulogic_vector(32 to 52);
signal mas3_3_ubits_d,   mas3_3_ubits_q           : std_ulogic_vector(0 to 3);
signal mas3_3_usxwr_d,   mas3_3_usxwr_q           : std_ulogic_vector(0 to 5);
signal mas4_3_indd_d,   mas4_3_indd_q             : std_ulogic;
signal mas4_3_tsized_d,   mas4_3_tsized_q         : std_ulogic_vector(0 to 3);
signal mas4_3_wimged_d,   mas4_3_wimged_q         : std_ulogic_vector(0 to 4);
signal mas5_3_sgs_d,   mas5_3_sgs_q               : std_ulogic;
signal mas5_3_slpid_d,   mas5_3_slpid_q           : std_ulogic_vector(0 to 7);
signal mas6_3_spid_d,   mas6_3_spid_q             : std_ulogic_vector(0 to 13);
signal mas6_3_isize_d,   mas6_3_isize_q           : std_ulogic_vector(0 to 3);
signal mas6_3_sind_d,   mas6_3_sind_q               : std_ulogic;
signal mas6_3_sas_d,   mas6_3_sas_q               : std_ulogic;
signal mas7_3_rpnu_d,   mas7_3_rpnu_q             : std_ulogic_vector(22 to 31);
signal mas8_3_tgs_d,   mas8_3_tgs_q               : std_ulogic;
signal mas8_3_vf_d,   mas8_3_vf_q                 : std_ulogic;
signal mas8_3_tlpid_d,   mas8_3_tlpid_q           : std_ulogic_vector(0 to 7);
signal mmucsr0_tlb0fi_d, mmucsr0_tlb0fi_q : std_ulogic;
signal lper_0_alpn_d,   lper_0_alpn_q             : std_ulogic_vector(64-real_addr_width to 51);
signal lper_0_lps_d,   lper_0_lps_q               : std_ulogic_vector(60 to 63);
signal lper_1_alpn_d,   lper_1_alpn_q             : std_ulogic_vector(64-real_addr_width to 51);
signal lper_1_lps_d,   lper_1_lps_q               : std_ulogic_vector(60 to 63);
signal lper_2_alpn_d,   lper_2_alpn_q             : std_ulogic_vector(64-real_addr_width to 51);
signal lper_2_lps_d,   lper_2_lps_q               : std_ulogic_vector(60 to 63);
signal lper_3_alpn_d,   lper_3_alpn_q             : std_ulogic_vector(64-real_addr_width to 51);
signal lper_3_lps_d,   lper_3_lps_q               : std_ulogic_vector(60 to 63);
-- timing nsl's
signal iu_mm_ierat_mmucr0_q          : std_ulogic_vector(0 to 17);
signal iu_mm_ierat_mmucr0_we_q       : std_ulogic_vector(0 to thdid_width-1);
signal iu_mm_ierat_mmucr1_q          : std_ulogic_vector(0 to 3);
signal iu_mm_ierat_mmucr1_we_q       : std_ulogic;
signal xu_mm_derat_mmucr0_q          : std_ulogic_vector(0 to 17);
signal xu_mm_derat_mmucr0_we_q       : std_ulogic_vector(0 to thdid_width-1);
signal xu_mm_derat_mmucr1_q          : std_ulogic_vector(0 to 4);
signal xu_mm_derat_mmucr1_we_q       : std_ulogic;
signal spare_a_q : std_ulogic_vector(0 to 31);
signal spare_b_q : std_ulogic_vector(0 to 63);
signal unused_dc  :  std_ulogic_vector(0 to 13);
-- synopsys translate_off
-- synopsys translate_on
-- Pervasive
signal pc_sg_1         : std_ulogic;
signal pc_sg_0         : std_ulogic;
signal pc_fce_1        : std_ulogic;
signal pc_fce_0        : std_ulogic;
signal pc_func_sl_thold_1        : std_ulogic;
signal pc_func_sl_thold_0        : std_ulogic;
signal pc_func_sl_thold_0_b      : std_ulogic;
signal pc_func_slp_sl_thold_1    : std_ulogic;
signal pc_func_slp_sl_thold_0    : std_ulogic;
signal pc_func_slp_sl_thold_0_b  : std_ulogic;
signal pc_func_sl_force     : std_ulogic;
signal pc_func_slp_sl_force : std_ulogic;
signal pc_cfg_sl_thold_1        : std_ulogic;
signal pc_cfg_sl_thold_0        : std_ulogic;
signal pc_cfg_sl_thold_0_b : std_ulogic;
signal pc_cfg_slp_sl_thold_1        : std_ulogic;
signal pc_cfg_slp_sl_thold_0        : std_ulogic;
signal pc_cfg_slp_sl_thold_0_b : std_ulogic;
signal pc_cfg_sl_force : std_ulogic;
signal pc_cfg_slp_sl_force : std_ulogic;
signal pc_func_slp_nsl_thold_1   : std_ulogic;
signal pc_func_slp_nsl_thold_0   : std_ulogic;
signal pc_func_slp_nsl_thold_0_b : std_ulogic;
signal pc_func_slp_nsl_force     : std_ulogic;
signal lcb_dclk  : std_ulogic;
signal lcb_lclk   : clk_logic;
signal siv_0                      : std_ulogic_vector(0 to scan_right_0);
signal sov_0                      : std_ulogic_vector(0 to scan_right_0);
signal siv_1                      : std_ulogic_vector(0 to scan_right_1);
signal sov_1                      : std_ulogic_vector(0 to scan_right_1);
signal bsiv                     : std_ulogic_vector(0 to boot_scan_right);
signal bsov                     : std_ulogic_vector(0 to boot_scan_right);
signal mmucfg_q, mmucfg_q_b : std_ulogic_vector(47 to 48);
signal tlb0cfg_q, tlb0cfg_q_b : std_ulogic_vector(45 to 47);
signal bcfg_spare_q, bcfg_spare_q_b : std_ulogic_vector(0 to 15);
signal cat_emf_act_d, cat_emf_act_q : std_ulogic_vector(0 to thdid_width-1);
signal spr_mmu_act_d, spr_mmu_act_q : std_ulogic_vector(0 to thdid_width);
signal spr_val_act_d, spr_val_act_q : std_ulogic_vector(0 to 3);
signal spr_val_act, spr_match_act, spr_match_mas_act, spr_mas_data_out_act     : std_ulogic;
signal cswitch_q  : std_ulogic_vector(0 to 3);
signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;
begin
tidn <= '0';
tiup <= '1';
cat_emf_act_d(0)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "00")) or mmucr2_act_override(6) or (tlb_delayed_act(29+0)   and xu_mm_ccr2_notlb_b);
spr_mmu_act_d(0)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "00")) or mmucr2_act_override(5);
cat_emf_act_d(1)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "01")) or mmucr2_act_override(6) or (tlb_delayed_act(29+1)   and xu_mm_ccr2_notlb_b);
spr_mmu_act_d(1)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "01")) or mmucr2_act_override(5);
cat_emf_act_d(2)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "10")) or mmucr2_act_override(6) or (tlb_delayed_act(29+2)   and xu_mm_ccr2_notlb_b);
spr_mmu_act_d(2)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "10")) or mmucr2_act_override(5);
cat_emf_act_d(3)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "11")) or mmucr2_act_override(6) or (tlb_delayed_act(29+3)   and xu_mm_ccr2_notlb_b);
spr_mmu_act_d(3)   <= (spr_match_any_mmu and Eq(spr_etid_in_q, "11")) or mmucr2_act_override(5);
spr_mmu_act_d(thdid_width) <= spr_match_any_mmu or mmucr2_act_override(5);
spr_val_act_d(0) <= xu_mm_slowspr_val;
spr_val_act_d(1) <= spr_val_act_q(0);
spr_val_act_d(2) <= spr_val_act_q(1);
spr_val_act_d(3) <= spr_val_act_q(2);
spr_val_act <= spr_val_act_q(0) or spr_val_act_q(1) or spr_val_act_q(2) or spr_val_act_q(3) or mmucr2_act_override(5);
spr_match_act <= spr_val_act_q(0) or spr_val_act_q(1) or mmucr2_act_override(5);
spr_match_mas_act <= spr_val_act_q(0) or spr_val_act_q(1) or mmucr2_act_override(6);
spr_mas_data_out_act <= spr_val_act_q(0) or mmucr2_act_override(6);
-----------------------------------------------------------------------
-- slow spr 
-----------------------------------------------------------------------
-- input latches for spr access
spr_ctl_in_d(0)  <= xu_mm_slowspr_val;
spr_ctl_in_d(1)  <= xu_mm_slowspr_rw;
spr_ctl_in_d(2)  <= xu_mm_slowspr_done;
spr_etid_in_d <= xu_mm_slowspr_etid;
spr_addr_in_d <= xu_mm_slowspr_addr;
spr_addr_in_clone_d <= xu_mm_slowspr_addr;
spr_data_in_d <= xu_mm_slowspr_data;
-- internal select latches for spr access
spr_ctl_int_d  <= spr_ctl_in_q;
spr_etid_int_d <= spr_etid_in_q;
spr_addr_int_d <= spr_addr_in_q;
spr_data_int_d <= spr_data_in_q;
spr_match_any_mmu <= ( spr_ctl_in_q(0) and (Eq(spr_addr_in_q, Spr_Addr_PID) or Eq(spr_addr_in_q, Spr_Addr_MMUCR0) or
                                   Eq(spr_addr_in_q, Spr_Addr_MMUCR1) or Eq(spr_addr_in_q, Spr_Addr_MMUCR2) or   
                                   Eq(spr_addr_in_q, Spr_Addr_MMUCR3) or Eq(spr_addr_in_q, Spr_Addr_LPID) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MAS0) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS1) or 
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MAS2) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS3) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MAS4) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS5) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MAS6) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS7) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MAS8) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS2U) or 
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MAS01_64b) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS56_64b) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MAS73_64b) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS81_64b) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_MMUCFG) or Eq(spr_addr_in_clone_q, Spr_Addr_MMUCSR0) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_TLB0CFG) or Eq(spr_addr_in_clone_q, Spr_Addr_TLB0PS) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_LRATCFG) or Eq(spr_addr_in_clone_q, Spr_Addr_LRATPS) or
                                   Eq(spr_addr_in_clone_q, Spr_Addr_EPTCFG) or Eq(spr_addr_in_clone_q, Spr_Addr_LPER) or 
                                   Eq(spr_addr_in_clone_q, Spr_Addr_LPERU)) );
spr_match_pid0 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_q, Spr_Addr_PID));
spr_match_pid1 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_q, Spr_Addr_PID));
spr_match_pid2 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_q, Spr_Addr_PID));
spr_match_pid3 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_q, Spr_Addr_PID));
spr_match_mmucr0_0 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_q, Spr_Addr_MMUCR0));
spr_match_mmucr0_1 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_q, Spr_Addr_MMUCR0));
spr_match_mmucr0_2 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_q, Spr_Addr_MMUCR0));
spr_match_mmucr0_3 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_q, Spr_Addr_MMUCR0));
spr_match_mmucr1 <= (spr_ctl_in_q(0) and Eq(spr_addr_in_q, Spr_Addr_MMUCR1));
spr_match_mmucr2 <= (spr_ctl_in_q(0) and Eq(spr_addr_in_q, Spr_Addr_MMUCR2));
spr_match_mmucr3_0 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_q, Spr_Addr_MMUCR3));
spr_match_mmucr3_1 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_q, Spr_Addr_MMUCR3));
spr_match_mmucr3_2 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_q, Spr_Addr_MMUCR3));
spr_match_mmucr3_3 <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_q, Spr_Addr_MMUCR3));
spr_match_lpidr <= (spr_ctl_in_q(0) and Eq(spr_addr_in_q, Spr_Addr_LPID));
spr_match_mmucsr0   <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_MMUCSR0));
spr_match_mmucfg    <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_MMUCFG));
spr_match_tlb0cfg   <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_TLB0CFG));
spr_match_tlb0ps    <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_TLB0PS));
spr_match_lratcfg   <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_LRATCFG));
spr_match_lratps    <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_LRATPS));
spr_match_eptcfg    <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_EPTCFG));
spr_match_lper_0    <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_LPER));
spr_match_lperu_0   <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_LPERU));
spr_match_lper_1    <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_LPER));
spr_match_lperu_1   <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_LPERU));
spr_match_lper_2    <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_LPER));
spr_match_lperu_2   <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_LPERU));
spr_match_lper_3    <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_LPER));
spr_match_lperu_3   <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_LPERU));
spr_match_any_mas  <= ( spr_ctl_in_q(0) and (Eq(spr_addr_in_clone_q, Spr_Addr_MAS0) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS1) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS2) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS2U) or
                     Eq(spr_addr_in_clone_q, Spr_Addr_MAS3) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS4) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS5) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS6) or
                     Eq(spr_addr_in_clone_q, Spr_Addr_MAS7) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS8) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS01_64b) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS56_64b) or
                     Eq(spr_addr_in_clone_q, Spr_Addr_MAS73_64b) or Eq(spr_addr_in_clone_q, Spr_Addr_MAS81_64b)) );
spr_match_mas0_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS0));
spr_match_mas1_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS1));
spr_match_mas2_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2));
spr_match_mas2u_0            <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2U));
spr_match_mas3_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS3));
spr_match_mas4_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS4));
spr_match_mas5_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS5));
spr_match_mas6_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS6));
spr_match_mas7_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS7));
spr_match_mas8_0             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS8));
spr_match_mas01_64b_0        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS01_64b));
spr_match_mas56_64b_0        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS56_64b));
spr_match_mas73_64b_0        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS73_64b));
spr_match_mas81_64b_0        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "00") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS81_64b));
spr_match_mas0_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS0));
spr_match_mas1_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS1));
spr_match_mas2_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2));
spr_match_mas2u_1            <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2U));
spr_match_mas3_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS3));
spr_match_mas4_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS4));
spr_match_mas5_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS5));
spr_match_mas6_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS6));
spr_match_mas7_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS7));
spr_match_mas8_1             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS8));
spr_match_mas01_64b_1        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS01_64b));
spr_match_mas56_64b_1        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS56_64b));
spr_match_mas73_64b_1        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS73_64b));
spr_match_mas81_64b_1        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "01") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS81_64b));
spr_match_mas0_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS0));
spr_match_mas1_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS1));
spr_match_mas2_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2));
spr_match_mas2u_2            <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2U));
spr_match_mas3_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS3));
spr_match_mas4_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS4));
spr_match_mas5_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS5));
spr_match_mas6_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS6));
spr_match_mas7_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS7));
spr_match_mas8_2             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS8));
spr_match_mas01_64b_2        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS01_64b));
spr_match_mas56_64b_2        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS56_64b));
spr_match_mas73_64b_2        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS73_64b));
spr_match_mas81_64b_2        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "10") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS81_64b));
spr_match_mas0_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS0));
spr_match_mas1_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS1));
spr_match_mas2_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2));
spr_match_mas2u_3            <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2U));
spr_match_mas3_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS3));
spr_match_mas4_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS4));
spr_match_mas5_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS5));
spr_match_mas6_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS6));
spr_match_mas7_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS7));
spr_match_mas8_3             <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS8));
spr_match_mas01_64b_3        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS01_64b));
spr_match_mas56_64b_3        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS56_64b));
spr_match_mas73_64b_3        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS73_64b));
spr_match_mas81_64b_3        <= (spr_ctl_in_q(0) and Eq(spr_etid_in_q, "11") and Eq(spr_addr_in_clone_q, Spr_Addr_MAS81_64b));
spr_match_mas2_64b       <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_MAS2));
spr_match_mas01_64b      <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_MAS01_64b));
spr_match_mas56_64b      <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_MAS56_64b));
spr_match_mas73_64b      <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_MAS73_64b));
spr_match_mas81_64b      <= (spr_ctl_in_q(0) and Eq(spr_addr_in_clone_q, Spr_Addr_MAS81_64b));
spr_match_64b <= spr_match_mas2_64b or spr_match_mas01_64b or spr_match_mas56_64b or spr_match_mas73_64b or spr_match_mas81_64b;
pid0_d       <= spr_data_int_q(64-pid_width to 63) when (spr_match_pid0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) else pid0_q;
pid1_d       <= spr_data_int_q(64-pid_width to 63) when (spr_match_pid1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) else pid1_q;
pid2_d       <= spr_data_int_q(64-pid_width to 63) when (spr_match_pid2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) else pid2_q;
pid3_d       <= spr_data_int_q(64-pid_width to 63) when (spr_match_pid3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) else pid3_q;
-- mmucr0: 0-ExtClass, 1-TID_NZ, 2:3-GS/TS, 4:5-TLBSel, 6:19-TID
mmucr0_0_d    <= spr_data_int_q(32) & or_reduce(spr_data_int_q(50 to 63)) & spr_data_int_q(34 to 37) & spr_data_int_q(50 to 63) 
                  when (spr_match_mmucr0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_0_q(6   to 7) & xu_mm_derat_mmucr0_q(6 to 17) 
                  when xu_mm_derat_mmucr0_we_q(0)='1'   and mmucr1_q(14 to 15)="01"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 5) & mmucr0_0_q(8   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(0)='1'   and mmucr1_q(14 to 15)="10"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 17) 
                  when xu_mm_derat_mmucr0_we_q(0)='1'   and mmucr1_q(14 to 15)="11"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_0_q(6   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(0)='1'
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & mmucr0_0_q(6   to 7) & iu_mm_ierat_mmucr0_q(6 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(0)='1'   and mmucr1_q(12 to 13)="01"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 5) & mmucr0_0_q(8   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(0)='1'   and mmucr1_q(12 to 13)="10"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(0)='1'   and mmucr1_q(12 to 13)="11"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "10" & mmucr0_0_q(6   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(0)='1'
         else mmucr0_0_q;
mmucr0_1_d    <= spr_data_int_q(32) & or_reduce(spr_data_int_q(50 to 63)) & spr_data_int_q(34 to 37) & spr_data_int_q(50 to 63) 
                  when (spr_match_mmucr0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_1_q(6   to 7) & xu_mm_derat_mmucr0_q(6 to 17) 
                  when xu_mm_derat_mmucr0_we_q(1)='1'   and mmucr1_q(14 to 15)="01"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 5) & mmucr0_1_q(8   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(1)='1'   and mmucr1_q(14 to 15)="10"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 17) 
                  when xu_mm_derat_mmucr0_we_q(1)='1'   and mmucr1_q(14 to 15)="11"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_1_q(6   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(1)='1'
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & mmucr0_1_q(6   to 7) & iu_mm_ierat_mmucr0_q(6 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(1)='1'   and mmucr1_q(12 to 13)="01"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 5) & mmucr0_1_q(8   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(1)='1'   and mmucr1_q(12 to 13)="10"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(1)='1'   and mmucr1_q(12 to 13)="11"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "10" & mmucr0_1_q(6   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(1)='1'
         else mmucr0_1_q;
mmucr0_2_d    <= spr_data_int_q(32) & or_reduce(spr_data_int_q(50 to 63)) & spr_data_int_q(34 to 37) & spr_data_int_q(50 to 63) 
                  when (spr_match_mmucr0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_2_q(6   to 7) & xu_mm_derat_mmucr0_q(6 to 17) 
                  when xu_mm_derat_mmucr0_we_q(2)='1'   and mmucr1_q(14 to 15)="01"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 5) & mmucr0_2_q(8   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(2)='1'   and mmucr1_q(14 to 15)="10"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 17) 
                  when xu_mm_derat_mmucr0_we_q(2)='1'   and mmucr1_q(14 to 15)="11"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_2_q(6   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(2)='1'
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & mmucr0_2_q(6   to 7) & iu_mm_ierat_mmucr0_q(6 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(2)='1'   and mmucr1_q(12 to 13)="01"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 5) & mmucr0_2_q(8   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(2)='1'   and mmucr1_q(12 to 13)="10"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(2)='1'   and mmucr1_q(12 to 13)="11"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "10" & mmucr0_2_q(6   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(2)='1'
         else mmucr0_2_q;
mmucr0_3_d    <= spr_data_int_q(32) & or_reduce(spr_data_int_q(50 to 63)) & spr_data_int_q(34 to 37) & spr_data_int_q(50 to 63) 
                  when (spr_match_mmucr0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_3_q(6   to 7) & xu_mm_derat_mmucr0_q(6 to 17) 
                  when xu_mm_derat_mmucr0_we_q(3)='1'   and mmucr1_q(14 to 15)="01"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 5) & mmucr0_3_q(8   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(3)='1'   and mmucr1_q(14 to 15)="10"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & xu_mm_derat_mmucr0_q(4 to 17) 
                  when xu_mm_derat_mmucr0_we_q(3)='1'   and mmucr1_q(14 to 15)="11"  
         else xu_mm_derat_mmucr0_q(0 to 3) & "11" & mmucr0_3_q(6   to 11) & xu_mm_derat_mmucr0_q(10 to 17) 
                  when xu_mm_derat_mmucr0_we_q(3)='1'
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & mmucr0_3_q(6   to 7) & iu_mm_ierat_mmucr0_q(6 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(3)='1'   and mmucr1_q(12 to 13)="01"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 5) & mmucr0_3_q(8   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(3)='1'   and mmucr1_q(12 to 13)="10"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "11" & iu_mm_ierat_mmucr0_q(4 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(3)='1'   and mmucr1_q(12 to 13)="11"  
         else iu_mm_ierat_mmucr0_q(0 to 3) & "10" & mmucr0_3_q(6   to 11) & iu_mm_ierat_mmucr0_q(10 to 17) 
                  when iu_mm_ierat_mmucr0_we_q(3)='1'
         else mmucr0_3_q;
-- mmucr1: 0-IRRE, 1-DRRE, 2-REE, 3-CEE,
--         4-Disable any context sync inst from invalidating extclass=0 erat entries,
--         5-Disable isync inst from invalidating extclass=0 erat entries,
--         6:7-IPEI, 8:9-DPEI, 10:11-TPEI, 12:13-ICTID/ITTID, 14:15-DCTID/DTTID,
--         16-DCCD, 17-TLBWE_BINV, 18-TLBI_MSB, 19-TLBI_REJ,
--         20-IERRDET, 21-DERRDET, 22-TERRDET, 23:31-EEN
--    2) mmucr1: merge EEN bits into single field, seperate I/D/T ERRDET bits
--    3) mmucr1: add ICTID, ITTID, DCTID, DTTID, TLBI_REJ, and TLBI_MSB bits
mmucr1_d(0 to 16)    <= spr_data_int_q(32 to 48) when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Write) else mmucr1_q(0 to 16);
mmucr1_d(17)          <= (spr_data_int_q(49) and not cswitch_q(1))  when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Write) else mmucr1_q(17);
mmucr1_d(18 to 19)   <= spr_data_int_q(50 to 51) when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Write) else mmucr1_q(18 to 19);
mmucr1_d(20) <= '0' when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Read and cswitch_q(0)='0')
           else spr_data_int_q(52) when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Write and cswitch_q(0)='1') 
           else '1' when (iu_mm_ierat_mmucr1_we_q='1' and xu_mm_derat_mmucr1_we_q='0'  and tlb_mmucr1_we='0' and mmucr1_q(20 to 22)="000")
           else mmucr1_q(20);
mmucr1_d(21) <= '0' when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Read and cswitch_q(0)='0')
           else spr_data_int_q(53) when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Write and cswitch_q(0)='1') 
           else '1' when (xu_mm_derat_mmucr1_we_q='1' and tlb_mmucr1_we='0' and mmucr1_q(20 to 22)="000")
           else mmucr1_q(21);
mmucr1_d(22) <= '0' when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Read and cswitch_q(0)='0')
           else spr_data_int_q(54) when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Write and cswitch_q(0)='1') 
           else '1' when (tlb_mmucr1_we='1' and mmucr1_q(20 to 22)="000")
           else mmucr1_q(22);
mmucr1_d(23 to 31)    <= (others => '0') when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Read and cswitch_q(0)='0')
                     else spr_data_int_q(55 to 63) when (spr_match_mmucr1_q='1' and spr_ctl_int_q(1)=Spr_RW_Write and cswitch_q(0)='1') 
                     else tlb_mmucr1_een when (tlb_mmucr1_we='1' and mmucr1_q(20 to 22)="000") 
                     else "0000" & xu_mm_derat_mmucr1_q when (xu_mm_derat_mmucr1_we_q='1' and mmucr1_q(20 to 22)="000")
                     else "00000" & iu_mm_ierat_mmucr1_q when (iu_mm_ierat_mmucr1_we_q='1' and mmucr1_q(20 to 22)="000") 
                     else mmucr1_q(23 to 31);
-- mmucr2:
mmucr2_d(0 to 31)    <= spr_data_int_q(32 to 63) when (spr_match_mmucr2_q='1' and spr_ctl_int_q(1)=Spr_RW_Write) else mmucr2_q(0 to 31);
-- mmucr3:
mmucr3_0_d      <= spr_data_int_q(64-mmucr3_width to 63) when (spr_match_mmucr3_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
              else tlb_mmucr3_x & tlb_mmucr3_rc & tlb_mmucr3_extclass & tlb_mmucr3_class & tlb_mmucr3_wlc & tlb_mmucr3_resvattr & '0' & tlb_mmucr3_thdid
                      when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
              else lrat_mmucr3_x & "00" & '0'      & '0' & "00" & "00"      & '0' & '0' & "1111"
                      when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
              else mmucr3_0_q;
mmucr3_1_d      <= spr_data_int_q(64-mmucr3_width to 63) when (spr_match_mmucr3_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
              else tlb_mmucr3_x & tlb_mmucr3_rc & tlb_mmucr3_extclass & tlb_mmucr3_class & tlb_mmucr3_wlc & tlb_mmucr3_resvattr & '0' & tlb_mmucr3_thdid
                      when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
              else lrat_mmucr3_x & "00" & '0'      & '0' & "00" & "00"      & '0' & '0' & "1111"
                      when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
              else mmucr3_1_q;
mmucr3_2_d      <= spr_data_int_q(64-mmucr3_width to 63) when (spr_match_mmucr3_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
              else tlb_mmucr3_x & tlb_mmucr3_rc & tlb_mmucr3_extclass & tlb_mmucr3_class & tlb_mmucr3_wlc & tlb_mmucr3_resvattr & '0' & tlb_mmucr3_thdid
                      when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
              else lrat_mmucr3_x & "00" & '0'      & '0' & "00" & "00"      & '0' & '0' & "1111"
                      when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
              else mmucr3_2_q;
mmucr3_3_d      <= spr_data_int_q(64-mmucr3_width to 63) when (spr_match_mmucr3_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
              else tlb_mmucr3_x & tlb_mmucr3_rc & tlb_mmucr3_extclass & tlb_mmucr3_class & tlb_mmucr3_wlc & tlb_mmucr3_resvattr & '0' & tlb_mmucr3_thdid
                      when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
              else lrat_mmucr3_x & "00" & '0'      & '0' & "00" & "00"      & '0' & '0' & "1111"
                      when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
              else mmucr3_3_q;
lpidr_d <= spr_data_int_q(64-lpid_width to 63) when (spr_match_lpidr_q='1' and spr_ctl_int_q(1)=Spr_RW_Write) else lpidr_q;
mmucsr0_tlb0fi_d   <= '1' when (mmucsr0_tlb0fi_q='0' and spr_match_mmucsr0_q='1' and spr_ctl_int_q(1)=Spr_RW_Write and spr_data_int_q(61)='1') 
                 else '0' when mmq_inval_tlb0fi_done='1'
                 else mmucsr0_tlb0fi_q;
lper_0_alpn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_lper_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lpn(32 to 51) when tlb_lper_we(0)='1'
                          else lper_0_alpn_q(32   to 51);
gen64_lper_0_alpn:   if spr_data_width = 64 generate
lper_0_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width to 31) 
                                                  when (spr_match_lper_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(0)='1'
                                          else lper_0_alpn_q(64-real_addr_width   to 31);
end generate gen64_lper_0_alpn;
gen32_lper_0_alpn:   if spr_data_width = 32 generate
lper_0_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(0)='1'
                                          else lper_0_alpn_q(64-real_addr_width   to 31);
end generate gen32_lper_0_alpn;
lper_0_lps_d                <= spr_data_int_q(60 to 63) when (spr_match_lper_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lps(60 to 63) when tlb_lper_we(0)='1'
                          else lper_0_lps_q;
lper_1_alpn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_lper_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lpn(32 to 51) when tlb_lper_we(1)='1'
                          else lper_1_alpn_q(32   to 51);
gen64_lper_1_alpn:   if spr_data_width = 64 generate
lper_1_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width to 31) 
                                                  when (spr_match_lper_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(1)='1'
                                          else lper_1_alpn_q(64-real_addr_width   to 31);
end generate gen64_lper_1_alpn;
gen32_lper_1_alpn:   if spr_data_width = 32 generate
lper_1_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(1)='1'
                                          else lper_1_alpn_q(64-real_addr_width   to 31);
end generate gen32_lper_1_alpn;
lper_1_lps_d                <= spr_data_int_q(60 to 63) when (spr_match_lper_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lps(60 to 63) when tlb_lper_we(1)='1'
                          else lper_1_lps_q;
lper_2_alpn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_lper_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lpn(32 to 51) when tlb_lper_we(2)='1'
                          else lper_2_alpn_q(32   to 51);
gen64_lper_2_alpn:   if spr_data_width = 64 generate
lper_2_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width to 31) 
                                                  when (spr_match_lper_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(2)='1'
                                          else lper_2_alpn_q(64-real_addr_width   to 31);
end generate gen64_lper_2_alpn;
gen32_lper_2_alpn:   if spr_data_width = 32 generate
lper_2_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(2)='1'
                                          else lper_2_alpn_q(64-real_addr_width   to 31);
end generate gen32_lper_2_alpn;
lper_2_lps_d                <= spr_data_int_q(60 to 63) when (spr_match_lper_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lps(60 to 63) when tlb_lper_we(2)='1'
                          else lper_2_lps_q;
lper_3_alpn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_lper_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lpn(32 to 51) when tlb_lper_we(3)='1'
                          else lper_3_alpn_q(32   to 51);
gen64_lper_3_alpn:   if spr_data_width = 64 generate
lper_3_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width to 31) 
                                                  when (spr_match_lper_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(3)='1'
                                          else lper_3_alpn_q(64-real_addr_width   to 31);
end generate gen64_lper_3_alpn;
gen32_lper_3_alpn:   if spr_data_width = 32 generate
lper_3_alpn_d(64-real_addr_width   to 31)  <= spr_data_int_q(64-real_addr_width+32 to 63) 
                                                  when (spr_match_lperu_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                                          else tlb_lper_lpn(64-real_addr_width to 31) when tlb_lper_we(3)='1'
                                          else lper_3_alpn_q(64-real_addr_width   to 31);
end generate gen32_lper_3_alpn;
lper_3_lps_d                <= spr_data_int_q(60 to 63) when (spr_match_lper_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                          else tlb_lper_lps(60 to 63) when tlb_lper_we(3)='1'
                          else lper_3_lps_q;
mas1_0_v_d             <= spr_data_int_q(32) when ((spr_match_mas1_0_q='1'   or spr_match_mas01_64b_0_q='1'   or spr_match_mas81_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when (tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(0)='1')   
                     else '1' when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_v when (tlb_mas_tlbre='1' and tlb_mas_thdid(0)='1')
                     else '0' when (lrat_mas_tlbsx_miss='1' and lrat_mas_thdid(0)='1')   
                     else '1' when (lrat_mas_tlbsx_hit='1' and lrat_mas_thdid(0)='1')   
                     else lrat_mas1_v when (lrat_mas_tlbre='1' and lrat_mas_thdid(0)='1')
                     else mas1_0_v_q;
mas1_0_iprot_d         <= spr_data_int_q(33) when ((spr_match_mas1_0_q='1'   or spr_match_mas01_64b_0_q='1'   or spr_match_mas81_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_iprot when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas1_0_iprot_q;
mas1_0_tid_d           <= spr_data_int_q(34 to 47) when ((spr_match_mas1_0_q='1'   or spr_match_mas01_64b_0_q='1'   or spr_match_mas81_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_0_spid_q      when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_tid_error when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_tid       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas1_0_tid_q;
mas1_0_ind_d           <= spr_data_int_q(50) when ((spr_match_mas1_0_q='1'   or spr_match_mas01_64b_0_q='1'   or spr_match_mas81_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_indd_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_ind when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas1_0_ind_q;
mas1_0_ts_d            <= spr_data_int_q(51) when ((spr_match_mas1_0_q='1'   or spr_match_mas01_64b_0_q='1'   or spr_match_mas81_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_0_sas_q    when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_ts_error  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_ts when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas1_0_ts_q;
mas1_0_tsize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas1_0_q='1'   or spr_match_mas01_64b_0_q='1'   or spr_match_mas81_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_tsized_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas1_tsize when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else lrat_mas1_tsize when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas1_0_tsize_q;
mas2_0_epn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_mas2_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                         else tlb_mas2_epn_error(32 to 51) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                         else tlb_mas2_epn(32 to 51)       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                         else lrat_mas2_epn(32 to 51)       when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                         else mas2_0_epn_q(32   to 51);
mas2_0_wimge_d         <= spr_data_int_q(59 to 63) when (spr_match_mas2_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_wimged_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas2_wimge when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas2_0_wimge_q;
mas3_0_rpnl_d          <= spr_data_int_q(32 to 52) 
                         when ((spr_match_mas3_0_q='1'   or spr_match_mas73_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas3_rpnl & (tlb_mas3_usxwr(5) and tlb_mas1_ind) 
                         when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else lrat_mas3_rpnl & '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas3_0_rpnl_q;
mas3_0_ubits_d         <= spr_data_int_q(54 to 57) when ((spr_match_mas3_0_q='1'   or spr_match_mas73_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas3_ubits when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas3_0_ubits_q;
mas3_0_usxwr_d         <= spr_data_int_q(58 to 63) when ((spr_match_mas3_0_q='1'   or spr_match_mas73_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')
                     else (tlb_mas3_usxwr(0 to 4) & (tlb_mas3_usxwr(5) and not tlb_mas1_ind)) when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas3_0_usxwr_q;
mas4_0_indd_d          <= spr_data_int_q(48) when (spr_match_mas4_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_indd_q;
mas4_0_tsized_d        <= spr_data_int_q(52 to 55) when (spr_match_mas4_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_tsized_q;
mas4_0_wimged_d        <= spr_data_int_q(59 to 63) when (spr_match_mas4_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_wimged_q;
mas6_0_spid_d          <= spr_data_int_q(34 to 47) when ((spr_match_mas6_0_q='1'   or spr_match_mas56_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_spid  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else mas6_0_spid_q;
mas6_0_isize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas6_0_q='1'   or spr_match_mas56_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_tsized_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else mas6_0_isize_q;
mas6_0_sind_d          <= spr_data_int_q(62) when ((spr_match_mas6_0_q='1'   or spr_match_mas56_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_0_indd_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else mas6_0_sind_q;
mas6_0_sas_d           <= spr_data_int_q(63) when ((spr_match_mas6_0_q='1'   or spr_match_mas56_64b_0_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_sas  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else mas6_0_sas_q;
mas1_1_v_d             <= spr_data_int_q(32) when ((spr_match_mas1_1_q='1'   or spr_match_mas01_64b_1_q='1'   or spr_match_mas81_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when (tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(1)='1')   
                     else '1' when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_v when (tlb_mas_tlbre='1' and tlb_mas_thdid(1)='1')
                     else '0' when (lrat_mas_tlbsx_miss='1' and lrat_mas_thdid(1)='1')   
                     else '1' when (lrat_mas_tlbsx_hit='1' and lrat_mas_thdid(1)='1')   
                     else lrat_mas1_v when (lrat_mas_tlbre='1' and lrat_mas_thdid(1)='1')
                     else mas1_1_v_q;
mas1_1_iprot_d         <= spr_data_int_q(33) when ((spr_match_mas1_1_q='1'   or spr_match_mas01_64b_1_q='1'   or spr_match_mas81_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_iprot when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas1_1_iprot_q;
mas1_1_tid_d           <= spr_data_int_q(34 to 47) when ((spr_match_mas1_1_q='1'   or spr_match_mas01_64b_1_q='1'   or spr_match_mas81_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_1_spid_q      when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_tid_error when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_tid       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas1_1_tid_q;
mas1_1_ind_d           <= spr_data_int_q(50) when ((spr_match_mas1_1_q='1'   or spr_match_mas01_64b_1_q='1'   or spr_match_mas81_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_indd_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_ind when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas1_1_ind_q;
mas1_1_ts_d            <= spr_data_int_q(51) when ((spr_match_mas1_1_q='1'   or spr_match_mas01_64b_1_q='1'   or spr_match_mas81_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_1_sas_q    when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_ts_error  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_ts when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas1_1_ts_q;
mas1_1_tsize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas1_1_q='1'   or spr_match_mas01_64b_1_q='1'   or spr_match_mas81_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_tsized_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas1_tsize when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else lrat_mas1_tsize when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas1_1_tsize_q;
mas2_1_epn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_mas2_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                         else tlb_mas2_epn_error(32 to 51) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                         else tlb_mas2_epn(32 to 51)       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                         else lrat_mas2_epn(32 to 51)       when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                         else mas2_1_epn_q(32   to 51);
mas2_1_wimge_d         <= spr_data_int_q(59 to 63) when (spr_match_mas2_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_wimged_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas2_wimge when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas2_1_wimge_q;
mas3_1_rpnl_d          <= spr_data_int_q(32 to 52) 
                         when ((spr_match_mas3_1_q='1'   or spr_match_mas73_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas3_rpnl & (tlb_mas3_usxwr(5) and tlb_mas1_ind) 
                         when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else lrat_mas3_rpnl & '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas3_1_rpnl_q;
mas3_1_ubits_d         <= spr_data_int_q(54 to 57) when ((spr_match_mas3_1_q='1'   or spr_match_mas73_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas3_ubits when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas3_1_ubits_q;
mas3_1_usxwr_d         <= spr_data_int_q(58 to 63) when ((spr_match_mas3_1_q='1'   or spr_match_mas73_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')
                     else (tlb_mas3_usxwr(0 to 4) & (tlb_mas3_usxwr(5) and not tlb_mas1_ind)) when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas3_1_usxwr_q;
mas4_1_indd_d          <= spr_data_int_q(48) when (spr_match_mas4_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_indd_q;
mas4_1_tsized_d        <= spr_data_int_q(52 to 55) when (spr_match_mas4_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_tsized_q;
mas4_1_wimged_d        <= spr_data_int_q(59 to 63) when (spr_match_mas4_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_wimged_q;
mas6_1_spid_d          <= spr_data_int_q(34 to 47) when ((spr_match_mas6_1_q='1'   or spr_match_mas56_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_spid  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else mas6_1_spid_q;
mas6_1_isize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas6_1_q='1'   or spr_match_mas56_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_tsized_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else mas6_1_isize_q;
mas6_1_sind_d          <= spr_data_int_q(62) when ((spr_match_mas6_1_q='1'   or spr_match_mas56_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_1_indd_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else mas6_1_sind_q;
mas6_1_sas_d           <= spr_data_int_q(63) when ((spr_match_mas6_1_q='1'   or spr_match_mas56_64b_1_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_sas  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else mas6_1_sas_q;
mas1_2_v_d             <= spr_data_int_q(32) when ((spr_match_mas1_2_q='1'   or spr_match_mas01_64b_2_q='1'   or spr_match_mas81_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when (tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(2)='1')   
                     else '1' when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_v when (tlb_mas_tlbre='1' and tlb_mas_thdid(2)='1')
                     else '0' when (lrat_mas_tlbsx_miss='1' and lrat_mas_thdid(2)='1')   
                     else '1' when (lrat_mas_tlbsx_hit='1' and lrat_mas_thdid(2)='1')   
                     else lrat_mas1_v when (lrat_mas_tlbre='1' and lrat_mas_thdid(2)='1')
                     else mas1_2_v_q;
mas1_2_iprot_d         <= spr_data_int_q(33) when ((spr_match_mas1_2_q='1'   or spr_match_mas01_64b_2_q='1'   or spr_match_mas81_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_iprot when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas1_2_iprot_q;
mas1_2_tid_d           <= spr_data_int_q(34 to 47) when ((spr_match_mas1_2_q='1'   or spr_match_mas01_64b_2_q='1'   or spr_match_mas81_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_2_spid_q      when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_tid_error when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_tid       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas1_2_tid_q;
mas1_2_ind_d           <= spr_data_int_q(50) when ((spr_match_mas1_2_q='1'   or spr_match_mas01_64b_2_q='1'   or spr_match_mas81_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_indd_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_ind when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas1_2_ind_q;
mas1_2_ts_d            <= spr_data_int_q(51) when ((spr_match_mas1_2_q='1'   or spr_match_mas01_64b_2_q='1'   or spr_match_mas81_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_2_sas_q    when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_ts_error  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_ts when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas1_2_ts_q;
mas1_2_tsize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas1_2_q='1'   or spr_match_mas01_64b_2_q='1'   or spr_match_mas81_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_tsized_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas1_tsize when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else lrat_mas1_tsize when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas1_2_tsize_q;
mas2_2_epn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_mas2_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                         else tlb_mas2_epn_error(32 to 51) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                         else tlb_mas2_epn(32 to 51)       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                         else lrat_mas2_epn(32 to 51)       when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                         else mas2_2_epn_q(32   to 51);
mas2_2_wimge_d         <= spr_data_int_q(59 to 63) when (spr_match_mas2_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_wimged_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas2_wimge when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas2_2_wimge_q;
mas3_2_rpnl_d          <= spr_data_int_q(32 to 52) 
                         when ((spr_match_mas3_2_q='1'   or spr_match_mas73_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas3_rpnl & (tlb_mas3_usxwr(5) and tlb_mas1_ind) 
                         when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else lrat_mas3_rpnl & '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas3_2_rpnl_q;
mas3_2_ubits_d         <= spr_data_int_q(54 to 57) when ((spr_match_mas3_2_q='1'   or spr_match_mas73_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas3_ubits when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas3_2_ubits_q;
mas3_2_usxwr_d         <= spr_data_int_q(58 to 63) when ((spr_match_mas3_2_q='1'   or spr_match_mas73_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')
                     else (tlb_mas3_usxwr(0 to 4) & (tlb_mas3_usxwr(5) and not tlb_mas1_ind)) when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas3_2_usxwr_q;
mas4_2_indd_d          <= spr_data_int_q(48) when (spr_match_mas4_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_indd_q;
mas4_2_tsized_d        <= spr_data_int_q(52 to 55) when (spr_match_mas4_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_tsized_q;
mas4_2_wimged_d        <= spr_data_int_q(59 to 63) when (spr_match_mas4_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_wimged_q;
mas6_2_spid_d          <= spr_data_int_q(34 to 47) when ((spr_match_mas6_2_q='1'   or spr_match_mas56_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_spid  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else mas6_2_spid_q;
mas6_2_isize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas6_2_q='1'   or spr_match_mas56_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_tsized_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else mas6_2_isize_q;
mas6_2_sind_d          <= spr_data_int_q(62) when ((spr_match_mas6_2_q='1'   or spr_match_mas56_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_2_indd_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else mas6_2_sind_q;
mas6_2_sas_d           <= spr_data_int_q(63) when ((spr_match_mas6_2_q='1'   or spr_match_mas56_64b_2_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_sas  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else mas6_2_sas_q;
mas1_3_v_d             <= spr_data_int_q(32) when ((spr_match_mas1_3_q='1'   or spr_match_mas01_64b_3_q='1'   or spr_match_mas81_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when (tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(3)='1')   
                     else '1' when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_v when (tlb_mas_tlbre='1' and tlb_mas_thdid(3)='1')
                     else '0' when (lrat_mas_tlbsx_miss='1' and lrat_mas_thdid(3)='1')   
                     else '1' when (lrat_mas_tlbsx_hit='1' and lrat_mas_thdid(3)='1')   
                     else lrat_mas1_v when (lrat_mas_tlbre='1' and lrat_mas_thdid(3)='1')
                     else mas1_3_v_q;
mas1_3_iprot_d         <= spr_data_int_q(33) when ((spr_match_mas1_3_q='1'   or spr_match_mas01_64b_3_q='1'   or spr_match_mas81_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_iprot when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas1_3_iprot_q;
mas1_3_tid_d           <= spr_data_int_q(34 to 47) when ((spr_match_mas1_3_q='1'   or spr_match_mas01_64b_3_q='1'   or spr_match_mas81_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_3_spid_q      when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_tid_error when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_tid       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas1_3_tid_q;
mas1_3_ind_d           <= spr_data_int_q(50) when ((spr_match_mas1_3_q='1'   or spr_match_mas01_64b_3_q='1'   or spr_match_mas81_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_indd_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_ind when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas1_3_ind_q;
mas1_3_ts_d            <= spr_data_int_q(51) when ((spr_match_mas1_3_q='1'   or spr_match_mas01_64b_3_q='1'   or spr_match_mas81_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas6_3_sas_q    when ( tlb_mas_tlbsx_miss='1' and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_ts_error  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_ts when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas1_3_ts_q;
mas1_3_tsize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas1_3_q='1'   or spr_match_mas01_64b_3_q='1'   or spr_match_mas81_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_tsized_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas1_tsize when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else lrat_mas1_tsize when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas1_3_tsize_q;
mas2_3_epn_d(32   to 51)  <= spr_data_int_q(32 to 51) when (spr_match_mas2_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                         else tlb_mas2_epn_error(32 to 51) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                         else tlb_mas2_epn(32 to 51)       when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                         else lrat_mas2_epn(32 to 51)       when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                         else mas2_3_epn_q(32   to 51);
mas2_3_wimge_d         <= spr_data_int_q(59 to 63) when (spr_match_mas2_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_wimged_q    when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas2_wimge when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas2_3_wimge_q;
mas3_3_rpnl_d          <= spr_data_int_q(32 to 52) 
                         when ((spr_match_mas3_3_q='1'   or spr_match_mas73_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas3_rpnl & (tlb_mas3_usxwr(5) and tlb_mas1_ind) 
                         when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else lrat_mas3_rpnl & '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas3_3_rpnl_q;
mas3_3_ubits_d         <= spr_data_int_q(54 to 57) when ((spr_match_mas3_3_q='1'   or spr_match_mas73_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas3_ubits when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas3_3_ubits_q;
mas3_3_usxwr_d         <= spr_data_int_q(58 to 63) when ((spr_match_mas3_3_q='1'   or spr_match_mas73_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')
                     else (tlb_mas3_usxwr(0 to 4) & (tlb_mas3_usxwr(5) and not tlb_mas1_ind)) when ((tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else (others => '0') when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas3_3_usxwr_q;
mas4_3_indd_d          <= spr_data_int_q(48) when (spr_match_mas4_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_indd_q;
mas4_3_tsized_d        <= spr_data_int_q(52 to 55) when (spr_match_mas4_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_tsized_q;
mas4_3_wimged_d        <= spr_data_int_q(59 to 63) when (spr_match_mas4_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_wimged_q;
mas6_3_spid_d          <= spr_data_int_q(34 to 47) when ((spr_match_mas6_3_q='1'   or spr_match_mas56_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_spid  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else mas6_3_spid_q;
mas6_3_isize_d         <= spr_data_int_q(52 to 55) when ((spr_match_mas6_3_q='1'   or spr_match_mas56_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_tsized_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else mas6_3_isize_q;
mas6_3_sind_d          <= spr_data_int_q(62) when ((spr_match_mas6_3_q='1'   or spr_match_mas56_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas4_3_indd_q    when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else mas6_3_sind_q;
mas6_3_sas_d           <= spr_data_int_q(63) when ((spr_match_mas6_3_q='1'   or spr_match_mas56_64b_3_q='1')   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas6_sas  when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else mas6_3_sas_q;
gen32_mas_d: if spr_data_width = 32 generate
mas0_0_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(0)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(0)='1')   
                     else mas0_0_atsel_q;
mas0_0_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(0)='1')
                    else (others => '0') when ((tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                                       tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(0)='1')   
                    else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(0)='1')
                    else mas0_0_esel_q;
mas0_0_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                      else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(0)='1')
                     else mas0_0_hes_q;
mas0_0_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(0)='1')
                    else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(0)='1')
                    else mas0_0_wq_q;
mas5_0_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_0_sgs_q;
mas5_0_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_0_slpid_q;
mas7_0_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')
                     else mas7_0_rpnu_q;
mas8_0_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)  
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas8_0_tgs_q;
mas8_0_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)   
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas8_0_vf_q;
mas8_0_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)    
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')
                     else mas8_0_tlpid_q;
mas0_1_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(1)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(1)='1')   
                     else mas0_1_atsel_q;
mas0_1_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(1)='1')
                    else (others => '0') when ((tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                                       tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(1)='1')   
                    else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(1)='1')
                    else mas0_1_esel_q;
mas0_1_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                      else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(1)='1')
                     else mas0_1_hes_q;
mas0_1_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(1)='1')
                    else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(1)='1')
                    else mas0_1_wq_q;
mas5_1_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_1_sgs_q;
mas5_1_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_1_slpid_q;
mas7_1_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')
                     else mas7_1_rpnu_q;
mas8_1_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)  
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas8_1_tgs_q;
mas8_1_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)   
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas8_1_vf_q;
mas8_1_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)    
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')
                     else mas8_1_tlpid_q;
mas0_2_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(2)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(2)='1')   
                     else mas0_2_atsel_q;
mas0_2_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(2)='1')
                    else (others => '0') when ((tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                                       tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(2)='1')   
                    else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(2)='1')
                    else mas0_2_esel_q;
mas0_2_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                      else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(2)='1')
                     else mas0_2_hes_q;
mas0_2_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(2)='1')
                    else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(2)='1')
                    else mas0_2_wq_q;
mas5_2_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_2_sgs_q;
mas5_2_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_2_slpid_q;
mas7_2_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')
                     else mas7_2_rpnu_q;
mas8_2_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)  
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas8_2_tgs_q;
mas8_2_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)   
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas8_2_vf_q;
mas8_2_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)    
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')
                     else mas8_2_tlpid_q;
mas0_3_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(3)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(3)='1')   
                     else mas0_3_atsel_q;
mas0_3_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(3)='1')
                    else (others => '0') when ((tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                                       tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(3)='1')   
                    else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(3)='1')
                    else mas0_3_esel_q;
mas0_3_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                      else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(3)='1')
                     else mas0_3_hes_q;
mas0_3_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                    else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(3)='1')
                    else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(3)='1')
                    else mas0_3_wq_q;
mas5_3_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_3_sgs_q;
mas5_3_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_3_slpid_q;
mas7_3_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')
                     else mas7_3_rpnu_q;
mas8_3_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)  
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas8_3_tgs_q;
mas8_3_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)   
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas8_3_vf_q;
mas8_3_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)    
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')
                     else mas8_3_tlpid_q;
end generate gen32_mas_d;
gen64_mas_d: if spr_data_width = 64 generate
mas0_0_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas01_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(0)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(0)='1')   
                     else mas0_0_atsel_q;
mas0_0_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(13 to 15) when (spr_match_mas01_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(0)='1')
                     else (others => '0') when ((tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' 
                                                        or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(0)='1')
                     else mas0_0_esel_q;
mas0_0_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(17) when (spr_match_mas01_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(0)='1')
                     else mas0_0_hes_q;
mas0_0_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(18 to 19) when (spr_match_mas01_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(0)='1')
                     else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(0)='1')
                     else mas0_0_wq_q;
mas2_0_epn_d(0   to 31)   <= spr_data_int_q(32 to 63) when (spr_match_mas2u_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0 to 31) when (spr_match_mas2_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas2_epn_error(0 to 31) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else tlb_mas2_epn(0 to 31)        when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')   
                     else lrat_mas2_epn(0 to 31) when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')
                     else mas2_0_epn_q(0   to 31);
mas5_0_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas56_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_0_sgs_q;
mas5_0_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas56_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_0_slpid_q;
mas7_0_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(0)='1')   
                     else spr_data_int_q(22 to 31) when (spr_match_mas73_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')
                     else mas7_0_rpnu_q;
mas8_0_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas81_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas8_0_tgs_q;
mas8_0_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(1) when (spr_match_mas81_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')   
                     else mas8_0_vf_q;
mas8_0_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas81_64b_0_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(0)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(0)='1')
                     else mas8_0_tlpid_q;
mas0_1_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas01_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(1)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(1)='1')   
                     else mas0_1_atsel_q;
mas0_1_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(13 to 15) when (spr_match_mas01_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(1)='1')
                     else (others => '0') when ((tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' 
                                                        or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(1)='1')
                     else mas0_1_esel_q;
mas0_1_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(17) when (spr_match_mas01_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(1)='1')
                     else mas0_1_hes_q;
mas0_1_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(18 to 19) when (spr_match_mas01_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(1)='1')
                     else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(1)='1')
                     else mas0_1_wq_q;
mas2_1_epn_d(0   to 31)   <= spr_data_int_q(32 to 63) when (spr_match_mas2u_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0 to 31) when (spr_match_mas2_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas2_epn_error(0 to 31) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else tlb_mas2_epn(0 to 31)        when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')   
                     else lrat_mas2_epn(0 to 31) when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')
                     else mas2_1_epn_q(0   to 31);
mas5_1_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas56_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_1_sgs_q;
mas5_1_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas56_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_1_slpid_q;
mas7_1_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(1)='1')   
                     else spr_data_int_q(22 to 31) when (spr_match_mas73_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')
                     else mas7_1_rpnu_q;
mas8_1_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas81_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas8_1_tgs_q;
mas8_1_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(1) when (spr_match_mas81_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')   
                     else mas8_1_vf_q;
mas8_1_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas81_64b_1_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(1)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(1)='1')
                     else mas8_1_tlpid_q;
mas0_2_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas01_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(2)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(2)='1')   
                     else mas0_2_atsel_q;
mas0_2_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(13 to 15) when (spr_match_mas01_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(2)='1')
                     else (others => '0') when ((tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' 
                                                        or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(2)='1')
                     else mas0_2_esel_q;
mas0_2_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(17) when (spr_match_mas01_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(2)='1')
                     else mas0_2_hes_q;
mas0_2_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(18 to 19) when (spr_match_mas01_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(2)='1')
                     else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(2)='1')
                     else mas0_2_wq_q;
mas2_2_epn_d(0   to 31)   <= spr_data_int_q(32 to 63) when (spr_match_mas2u_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0 to 31) when (spr_match_mas2_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas2_epn_error(0 to 31) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else tlb_mas2_epn(0 to 31)        when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')   
                     else lrat_mas2_epn(0 to 31) when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')
                     else mas2_2_epn_q(0   to 31);
mas5_2_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas56_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_2_sgs_q;
mas5_2_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas56_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_2_slpid_q;
mas7_2_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(2)='1')   
                     else spr_data_int_q(22 to 31) when (spr_match_mas73_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')
                     else mas7_2_rpnu_q;
mas8_2_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas81_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas8_2_tgs_q;
mas8_2_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(1) when (spr_match_mas81_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')   
                     else mas8_2_vf_q;
mas8_2_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas81_64b_2_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(2)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(2)='1')
                     else mas8_2_tlpid_q;
mas0_3_atsel_d         <= spr_data_int_q(32) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas01_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write)
                     else '0' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(3)='1')   
                     else '1' when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(3)='1')   
                     else mas0_3_atsel_q;
mas0_3_esel_d          <= spr_data_int_q(45 to 47) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(13 to 15) when (spr_match_mas01_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas0_esel when ( (tlb_mas_tlbsx_hit='1') and tlb_mas_thdid(3)='1')
                     else (others => '0') when ((tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' 
                                                        or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else lrat_mas0_esel when ( (lrat_mas_tlbsx_hit='1') and lrat_mas_thdid(3)='1')
                     else mas0_3_esel_q;
mas0_3_hes_d           <= spr_data_int_q(49) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(17) when (spr_match_mas01_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else '1' when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(3)='1')
                     else mas0_3_hes_q;
mas0_3_wq_d            <= spr_data_int_q(50 to 51) when (spr_match_mas0_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(18 to 19) when (spr_match_mas01_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else "01" when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1' or 
                                          tlb_mas_tlbsx_hit='1' or tlb_mas_tlbsx_miss='1') and tlb_mas_thdid(3)='1')
                     else "00" when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbsx_miss='1') and lrat_mas_thdid(3)='1')
                     else mas0_3_wq_q;
mas2_3_epn_d(0   to 31)   <= spr_data_int_q(32 to 63) when (spr_match_mas2u_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0 to 31) when (spr_match_mas2_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas2_epn_error(0 to 31) when ( (tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else tlb_mas2_epn(0 to 31)        when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')   
                     else lrat_mas2_epn(0 to 31) when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')
                     else mas2_3_epn_q(0   to 31);
mas5_3_sgs_d           <= spr_data_int_q(32) when (spr_match_mas5_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas56_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_3_sgs_q;
mas5_3_slpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas5_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas56_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else mas5_3_slpid_q;
mas7_3_rpnu_d          <= spr_data_int_q(54 to 63) when (spr_match_mas7_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else (others => '0')  when ( (tlb_mas_tlbsx_miss='1' or tlb_mas_dtlb_error='1' or tlb_mas_itlb_error='1') and tlb_mas_thdid(3)='1')   
                     else spr_data_int_q(22 to 31) when (spr_match_mas73_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas7_rpnu when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else lrat_mas7_rpnu when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')
                     else mas7_3_rpnu_q;
mas8_3_tgs_d           <= spr_data_int_q(32) when (spr_match_mas8_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(0) when (spr_match_mas81_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tgs when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas8_3_tgs_q;
mas8_3_vf_d            <= spr_data_int_q(33) when (spr_match_mas8_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(1) when (spr_match_mas81_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_vf when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else '0' when ((lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')   
                     else mas8_3_vf_q;
mas8_3_tlpid_d         <= spr_data_int_q(56 to 63) when (spr_match_mas8_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else spr_data_int_q(24 to 31) when (spr_match_mas81_64b_3_q='1'   and spr_ctl_int_q(1)=Spr_RW_Write) 
                     else tlb_mas8_tlpid when ( (tlb_mas_tlbsx_hit='1' or tlb_mas_tlbre='1') and tlb_mas_thdid(3)='1')
                     else lrat_mas8_tlpid when ( (lrat_mas_tlbsx_hit='1' or lrat_mas_tlbre='1') and lrat_mas_thdid(3)='1')
                     else mas8_3_tlpid_q;
end generate gen64_mas_d;
-- 0: val, 1: rw, 2: done
spr_ctl_out_d(0)  <= spr_ctl_int_q(0);
spr_ctl_out_d(1)  <= spr_ctl_int_q(1);
spr_ctl_out_d(2)  <= spr_ctl_int_q(2) or spr_match_any_mmu_q;
spr_etid_out_d <= spr_etid_int_q;
spr_addr_out_d <= spr_addr_int_q;
spr_data_out_d(32 to 63) <=
 ( ((32 to 63-pid_width => '0') & pid0_q) and (32 to 63 => (spr_match_pid0_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-pid_width => '0') & pid1_q) and (32 to 63 => (spr_match_pid1_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-pid_width => '0') & pid2_q) and (32 to 63 => (spr_match_pid2_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-pid_width => '0') & pid3_q) and (32 to 63 => (spr_match_pid3_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 55 => '0') & lpidr_q) and (32 to 63 => (spr_match_lpidr_q and spr_ctl_int_q(1))) ) or
 ( (mmucr0_0_q(0 to 5) & (38 to 49 => '0') & mmucr0_0_q(6 to 19)) and (32 to 63 => (spr_match_mmucr0_0_q and spr_ctl_int_q(1))) ) or
 ( (mmucr0_1_q(0 to 5) & (38 to 49 => '0') & mmucr0_1_q(6 to 19)) and (32 to 63 => (spr_match_mmucr0_1_q and spr_ctl_int_q(1))) ) or
 ( (mmucr0_2_q(0 to 5) & (38 to 49 => '0') & mmucr0_2_q(6 to 19)) and (32 to 63 => (spr_match_mmucr0_2_q and spr_ctl_int_q(1))) ) or
 ( (mmucr0_3_q(0 to 5) & (38 to 49 => '0') & mmucr0_3_q(6 to 19)) and (32 to 63 => (spr_match_mmucr0_3_q and spr_ctl_int_q(1))) ) or
 (  mmucr1_q and (32 to 63 => (spr_match_mmucr1_q and spr_ctl_int_q(1))) ) or
 (  mmucr2_q and (32 to 63 => (spr_match_mmucr2_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-mmucr3_width => '0') & mmucr3_0_q(64-mmucr3_width to 58) & '0' & mmucr3_0_q(60 to 63)) and (32 to 63 => (spr_match_mmucr3_0_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-mmucr3_width => '0') & mmucr3_1_q(64-mmucr3_width to 58) & '0' & mmucr3_1_q(60 to 63)) and (32 to 63 => (spr_match_mmucr3_1_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-mmucr3_width => '0') & mmucr3_2_q(64-mmucr3_width to 58) & '0' & mmucr3_2_q(60 to 63)) and (32 to 63 => (spr_match_mmucr3_2_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-mmucr3_width => '0') & mmucr3_3_q(64-mmucr3_width to 58) & '0' & mmucr3_3_q(60 to 63)) and (32 to 63 => (spr_match_mmucr3_3_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 60 => '0') & mmucsr0_tlb0fi_q & "00") and (32 to 63 => (spr_match_mmucsr0_q and spr_ctl_int_q(1))) ) or
 ( (Spr_Data_MMUCFG(32 to 46) & mmucfg_q(47 to 48) & Spr_Data_MMUCFG(49 to 63)) and (32 to 63 => (spr_match_mmucfg_q and spr_ctl_int_q(1))) ) or
 ( (Spr_Data_TLB0CFG(32 to 44) & tlb0cfg_q(45 to 47) & Spr_Data_TLB0CFG(48 to 63)) and (32 to 63 => (spr_match_tlb0cfg_q and spr_ctl_int_q(1))) ) or
 ( (Spr_Data_TLB0PS) and (32 to 63 => (spr_match_tlb0ps_q and spr_ctl_int_q(1))) ) or
 ( (Spr_Data_LRATCFG) and (32 to 63 => (spr_match_lratcfg_q and spr_ctl_int_q(1))) ) or
 ( (Spr_Data_LRATPS) and (32 to 63 => (spr_match_lratps_q and spr_ctl_int_q(1))) ) or
 ( (Spr_Data_EPTCFG) and (32 to 63 => (spr_match_eptcfg_q and spr_ctl_int_q(1))) ) or
 ( (lper_0_alpn_q(32 to 51) & (52 to 59 => '0') & lper_0_lps_q(60 to 63)) and (32 to 63 => (spr_match_lper_0_q and spr_ctl_int_q(1))) ) or
 ( (lper_1_alpn_q(32 to 51) & (52 to 59 => '0') & lper_1_lps_q(60 to 63)) and (32 to 63 => (spr_match_lper_1_q and spr_ctl_int_q(1))) ) or
 ( (lper_2_alpn_q(32 to 51) & (52 to 59 => '0') & lper_2_lps_q(60 to 63)) and (32 to 63 => (spr_match_lper_2_q and spr_ctl_int_q(1))) ) or
 ( (lper_3_alpn_q(32 to 51) & (52 to 59 => '0') & lper_3_lps_q(60 to 63)) and (32 to 63 => (spr_match_lper_3_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-real_addr_width+32 => '0') & lper_0_alpn_q(64-real_addr_width to 31)) and (32 to 63 => (spr_match_lperu_0_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-real_addr_width+32 => '0') & lper_1_alpn_q(64-real_addr_width to 31)) and (32 to 63 => (spr_match_lperu_1_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-real_addr_width+32 => '0') & lper_2_alpn_q(64-real_addr_width to 31)) and (32 to 63 => (spr_match_lperu_2_q and spr_ctl_int_q(1))) ) or
 ( ((32 to 63-real_addr_width+32 => '0') & lper_3_alpn_q(64-real_addr_width to 31)) and (32 to 63 => (spr_match_lperu_3_q and spr_ctl_int_q(1))) ) or
 ( (spr_mas_data_out_q(32 to 63)) and (32 to 63 => (spr_match_any_mas_q and spr_ctl_int_q(1))) ) or
 ( spr_data_int_q(32 to 63) and (32 to 63 => not spr_match_any_mmu_q) );
spr_mas_data_out(32 to 63) <=  
             ( (mas0_0_atsel_q   & (33 to 44 => '0') & mas0_0_esel_q   & '0' & mas0_0_hes_q   & mas0_0_wq_q   & (52 to 63 => '0'))
                 and (32 to 63 => spr_match_mas0_0)   ) or    
             ( (mas1_0_v_q   & mas1_0_iprot_q   & mas1_0_tid_q   & "00" & mas1_0_ind_q   & mas1_0_ts_q   & mas1_0_tsize_q   & "00000000")
                 and (32 to 63 => (spr_match_mas1_0   or spr_match_mas01_64b_0   or spr_match_mas81_64b_0))   ) or    
             ( (mas2_0_epn_q(32   to 51) & "0000000" & mas2_0_wimge_q)
                 and (32 to 63 => spr_match_mas2_0)   ) or
             ( (mas2_0_epn_q(0   to 31) )
                 and (32 to 63 => spr_match_mas2u_0)   ) or
             ( (mas3_0_rpnl_q   & '0' & mas3_0_ubits_q   & mas3_0_usxwr_q)
                 and (32 to 63 => (spr_match_mas3_0   or spr_match_mas73_64b_0))   ) or
             ( ((32 to 47 => '0') & mas4_0_indd_q   & "000" & mas4_0_tsized_q   & "000" & mas4_0_wimged_q)
                 and (32 to 63 => spr_match_mas4_0)   ) or
             ( (mas5_0_sgs_q   & (33 to 55 => '0') & mas5_0_slpid_q)
                 and (32 to 63 => spr_match_mas5_0)   ) or
             ( ("00" &  mas6_0_spid_q    & "0000" & mas6_0_isize_q   & "000000" & mas6_0_sind_q   & mas6_0_sas_q)
                 and (32 to 63 => (spr_match_mas6_0   or spr_match_mas56_64b_0))   ) or
             ( ((32 to 53 => '0') & mas7_0_rpnu_q)
                 and (32 to 63 => spr_match_mas7_0)   ) or
             ( (mas8_0_tgs_q   & mas8_0_vf_q   & (34 to 55 => '0') & mas8_0_tlpid_q)   
                 and (32 to 63 => spr_match_mas8_0)   ) or
             ( (mas0_1_atsel_q   & (33 to 44 => '0') & mas0_1_esel_q   & '0' & mas0_1_hes_q   & mas0_1_wq_q   & (52 to 63 => '0'))
                 and (32 to 63 => spr_match_mas0_1)   ) or    
             ( (mas1_1_v_q   & mas1_1_iprot_q   & mas1_1_tid_q   & "00" & mas1_1_ind_q   & mas1_1_ts_q   & mas1_1_tsize_q   & "00000000")
                 and (32 to 63 => (spr_match_mas1_1   or spr_match_mas01_64b_1   or spr_match_mas81_64b_1))   ) or    
             ( (mas2_1_epn_q(32   to 51) & "0000000" & mas2_1_wimge_q)
                 and (32 to 63 => spr_match_mas2_1)   ) or
             ( (mas2_1_epn_q(0   to 31) )
                 and (32 to 63 => spr_match_mas2u_1)   ) or
             ( (mas3_1_rpnl_q   & '0' & mas3_1_ubits_q   & mas3_1_usxwr_q)
                 and (32 to 63 => (spr_match_mas3_1   or spr_match_mas73_64b_1))   ) or
             ( ((32 to 47 => '0') & mas4_1_indd_q   & "000" & mas4_1_tsized_q   & "000" & mas4_1_wimged_q)
                 and (32 to 63 => spr_match_mas4_1)   ) or
             ( (mas5_1_sgs_q   & (33 to 55 => '0') & mas5_1_slpid_q)
                 and (32 to 63 => spr_match_mas5_1)   ) or
             ( ("00" &  mas6_1_spid_q    & "0000" & mas6_1_isize_q   & "000000" & mas6_1_sind_q   & mas6_1_sas_q)
                 and (32 to 63 => (spr_match_mas6_1   or spr_match_mas56_64b_1))   ) or
             ( ((32 to 53 => '0') & mas7_1_rpnu_q)
                 and (32 to 63 => spr_match_mas7_1)   ) or
             ( (mas8_1_tgs_q   & mas8_1_vf_q   & (34 to 55 => '0') & mas8_1_tlpid_q)   
                 and (32 to 63 => spr_match_mas8_1)   ) or
             ( (mas0_2_atsel_q   & (33 to 44 => '0') & mas0_2_esel_q   & '0' & mas0_2_hes_q   & mas0_2_wq_q   & (52 to 63 => '0'))
                 and (32 to 63 => spr_match_mas0_2)   ) or    
             ( (mas1_2_v_q   & mas1_2_iprot_q   & mas1_2_tid_q   & "00" & mas1_2_ind_q   & mas1_2_ts_q   & mas1_2_tsize_q   & "00000000")
                 and (32 to 63 => (spr_match_mas1_2   or spr_match_mas01_64b_2   or spr_match_mas81_64b_2))   ) or    
             ( (mas2_2_epn_q(32   to 51) & "0000000" & mas2_2_wimge_q)
                 and (32 to 63 => spr_match_mas2_2)   ) or
             ( (mas2_2_epn_q(0   to 31) )
                 and (32 to 63 => spr_match_mas2u_2)   ) or
             ( (mas3_2_rpnl_q   & '0' & mas3_2_ubits_q   & mas3_2_usxwr_q)
                 and (32 to 63 => (spr_match_mas3_2   or spr_match_mas73_64b_2))   ) or
             ( ((32 to 47 => '0') & mas4_2_indd_q   & "000" & mas4_2_tsized_q   & "000" & mas4_2_wimged_q)
                 and (32 to 63 => spr_match_mas4_2)   ) or
             ( (mas5_2_sgs_q   & (33 to 55 => '0') & mas5_2_slpid_q)
                 and (32 to 63 => spr_match_mas5_2)   ) or
             ( ("00" &  mas6_2_spid_q    & "0000" & mas6_2_isize_q   & "000000" & mas6_2_sind_q   & mas6_2_sas_q)
                 and (32 to 63 => (spr_match_mas6_2   or spr_match_mas56_64b_2))   ) or
             ( ((32 to 53 => '0') & mas7_2_rpnu_q)
                 and (32 to 63 => spr_match_mas7_2)   ) or
             ( (mas8_2_tgs_q   & mas8_2_vf_q   & (34 to 55 => '0') & mas8_2_tlpid_q)   
                 and (32 to 63 => spr_match_mas8_2)   ) or
             ( (mas0_3_atsel_q & (33 to 44 => '0') & mas0_3_esel_q & '0' & mas0_3_hes_q & mas0_3_wq_q & (52 to 63 => '0'))
                 and (32 to 63 => spr_match_mas0_3) ) or    
             ( (mas1_3_v_q & mas1_3_iprot_q & mas1_3_tid_q & "00" & mas1_3_ind_q & mas1_3_ts_q & mas1_3_tsize_q & "00000000")
                 and (32 to 63 => (spr_match_mas1_3 or spr_match_mas01_64b_3 or spr_match_mas81_64b_3)) ) or    
             ( (mas2_3_epn_q(32 to 51) & "0000000" & mas2_3_wimge_q)
                 and (32 to 63 => spr_match_mas2_3) ) or
             ( (mas2_3_epn_q(0 to 31) )
                 and (32 to 63 => spr_match_mas2u_3) ) or
             ( (mas3_3_rpnl_q & '0' & mas3_3_ubits_q & mas3_3_usxwr_q)
                 and (32 to 63 => (spr_match_mas3_3 or spr_match_mas73_64b_3)) ) or
             ( ((32 to 47 => '0') & mas4_3_indd_q & "000" & mas4_3_tsized_q & "000" & mas4_3_wimged_q)
                 and (32 to 63 => spr_match_mas4_3) ) or
             ( (mas5_3_sgs_q & (33 to 55 => '0') & mas5_3_slpid_q)
                 and (32 to 63 => spr_match_mas5_3) ) or
             ( ("00" &  mas6_3_spid_q  & "0000" & mas6_3_isize_q & "000000" & mas6_3_sind_q & mas6_3_sas_q)
                 and (32 to 63 => (spr_match_mas6_3 or spr_match_mas56_64b_3)) ) or
             ( ((32 to 53 => '0') & mas7_3_rpnu_q)
                 and (32 to 63 => spr_match_mas7_3) ) or
             ( (mas8_3_tgs_q & mas8_3_vf_q & (34 to 55 => '0') & mas8_3_tlpid_q) 
                 and (32 to 63 => spr_match_mas8_3) );
gen64_spr_data: if spr_data_width = 64 generate
spr_mas_data_out(0 to 31) <=  
             ( mas2_0_epn_q(0   to 31)
                 and (0 to 31 => spr_match_mas2_0)   ) or
             ( (mas0_0_atsel_q   & (1 to 12 => '0') & mas0_0_esel_q   & '0' & mas0_0_hes_q   & mas0_0_wq_q   & (20 to 31 => '0'))
                 and (0 to 31 => spr_match_mas01_64b_0)   )  or   
             ( (mas5_0_sgs_q   & (1 to 23 => '0') & mas5_0_slpid_q)
                 and (0 to 31 => spr_match_mas56_64b_0)   ) or
             ( ((0 to 21 => '0') & mas7_0_rpnu_q)
                 and (0 to 31 => spr_match_mas73_64b_0)   ) or
             ( (mas8_0_tgs_q   & mas8_0_vf_q   & (34 to 55 => '0') & mas8_0_tlpid_q)   
                 and (0 to 31 => spr_match_mas81_64b_0)   ) or
             ( mas2_1_epn_q(0   to 31)
                 and (0 to 31 => spr_match_mas2_1)   ) or
             ( (mas0_1_atsel_q   & (1 to 12 => '0') & mas0_1_esel_q   & '0' & mas0_1_hes_q   & mas0_1_wq_q   & (20 to 31 => '0'))
                 and (0 to 31 => spr_match_mas01_64b_1)   )  or   
             ( (mas5_1_sgs_q   & (1 to 23 => '0') & mas5_1_slpid_q)
                 and (0 to 31 => spr_match_mas56_64b_1)   ) or
             ( ((0 to 21 => '0') & mas7_1_rpnu_q)
                 and (0 to 31 => spr_match_mas73_64b_1)   ) or
             ( (mas8_1_tgs_q   & mas8_1_vf_q   & (34 to 55 => '0') & mas8_1_tlpid_q)   
                 and (0 to 31 => spr_match_mas81_64b_1)   ) or
             ( mas2_2_epn_q(0   to 31)
                 and (0 to 31 => spr_match_mas2_2)   ) or
             ( (mas0_2_atsel_q   & (1 to 12 => '0') & mas0_2_esel_q   & '0' & mas0_2_hes_q   & mas0_2_wq_q   & (20 to 31 => '0'))
                 and (0 to 31 => spr_match_mas01_64b_2)   )  or   
             ( (mas5_2_sgs_q   & (1 to 23 => '0') & mas5_2_slpid_q)
                 and (0 to 31 => spr_match_mas56_64b_2)   ) or
             ( ((0 to 21 => '0') & mas7_2_rpnu_q)
                 and (0 to 31 => spr_match_mas73_64b_2)   ) or
             ( (mas8_2_tgs_q   & mas8_2_vf_q   & (34 to 55 => '0') & mas8_2_tlpid_q)   
                 and (0 to 31 => spr_match_mas81_64b_2)   ) or
             ( mas2_3_epn_q(0 to 31)
                 and (0 to 31 => spr_match_mas2_3) ) or
             ( (mas0_3_atsel_q & (1 to 12 => '0') & mas0_3_esel_q & '0' & mas0_3_hes_q & mas0_3_wq_q & (20 to 31 => '0'))
                 and (0 to 31 => spr_match_mas01_64b_3) )  or   
             ( (mas5_3_sgs_q & (1 to 23 => '0') & mas5_3_slpid_q)
                 and (0 to 31 => spr_match_mas56_64b_3) ) or
             ( ((0 to 21 => '0') & mas7_3_rpnu_q)
                 and (0 to 31 => spr_match_mas73_64b_3) ) or
             ( (mas8_3_tgs_q & mas8_3_vf_q & (34 to 55 => '0') & mas8_3_tlpid_q) 
                 and (0 to 31 => spr_match_mas81_64b_3) );
spr_data_out_d(0 to 31) <= ( ((0 to 63-real_addr_width => '0') & lper_0_alpn_q(64-real_addr_width to 31)) 
                                 and (0 to 31 => (spr_match_lper_0_q and spr_ctl_int_q(1))) ) or 
                             ( ((0 to 63-real_addr_width => '0') & lper_1_alpn_q(64-real_addr_width to 31)) 
                                 and (0 to 31 => (spr_match_lper_1_q and spr_ctl_int_q(1))) ) or 
                             ( ((0 to 63-real_addr_width => '0') & lper_2_alpn_q(64-real_addr_width to 31)) 
                                 and (0 to 31 => (spr_match_lper_2_q and spr_ctl_int_q(1))) ) or 
                             ( ((0 to 63-real_addr_width => '0') & lper_3_alpn_q(64-real_addr_width to 31)) 
                                 and (0 to 31 => (spr_match_lper_3_q and spr_ctl_int_q(1))) ) or 
                             ( spr_mas_data_out_q(0 to 31) and (0 to 31 => (spr_match_any_mas_q and spr_ctl_int_q(1))) ) or
                             ( spr_data_int_q(0 to 31) and (0 to 31 => (not(spr_match_any_mmu_q) or not(spr_ctl_int_q(1)))) );
end generate gen64_spr_data;
mm_iu_slowspr_val           <= spr_ctl_out_q(0);
mm_iu_slowspr_rw            <= spr_ctl_out_q(1);
mm_iu_slowspr_etid          <= spr_etid_out_q;
mm_iu_slowspr_addr          <= spr_addr_out_q;
mm_iu_slowspr_data          <= spr_data_out_q;
mm_iu_slowspr_done          <= spr_ctl_out_q(2);
mm_iu_ierat_pid0          <= pid0_q;
mm_iu_ierat_pid1          <= pid1_q;
mm_iu_ierat_pid2          <= pid2_q;
mm_iu_ierat_pid3          <= pid3_q;
mm_iu_ierat_mmucr0_0          <= mmucr0_0_q;
mm_iu_ierat_mmucr0_1          <= mmucr0_1_q;
mm_iu_ierat_mmucr0_2          <= mmucr0_2_q;
mm_iu_ierat_mmucr0_3          <= mmucr0_3_q;
mm_iu_ierat_mmucr1    <= mmucr1_q(0) & mmucr1_q(2 to 5) & mmucr1_q(6 to 7) & mmucr1_q(12 to 13);
mm_xu_derat_pid0        <= pid0_q;
mm_xu_derat_pid1        <= pid1_q;
mm_xu_derat_pid2        <= pid2_q;
mm_xu_derat_pid3        <= pid3_q;
mm_xu_derat_mmucr0_0         <= mmucr0_0_q;
mm_xu_derat_mmucr0_1         <= mmucr0_1_q;
mm_xu_derat_mmucr0_2         <= mmucr0_2_q;
mm_xu_derat_mmucr0_3         <= mmucr0_3_q;
mm_xu_derat_mmucr1    <= mmucr1_q(1) & mmucr1_q(2 to 5) & mmucr1_q(8 to 9) & mmucr1_q(14 to 16);
-- mmucr1: 0-IRRE, 1-DRRE, 2-REE, 3-CEE,
--         4-Disable any context sync inst from invalidating extclass=0 erat entries,
--         5-Disable isync inst from invalidating extclass=0 erat entries,
--         6:7-IPEI, 8:9-DPEI, 10:11-TPEI, 12:13-ICTID/ITTID, 14:15-DCTID/DTTID,
--         16-DCCD, 17-TLBWE_BINV, 18-TLBI_MSB, 19-TLBI_REJ,
--         20-IERRDET, 21-DERRDET, 22-TERRDET, 23:31-EEN
pid0           <= pid0_q;
pid1           <= pid1_q;
pid2           <= pid2_q;
pid3           <= pid3_q;
mmucr0_0       <= mmucr0_0_q;
mmucr0_1       <= mmucr0_1_q;
mmucr0_2       <= mmucr0_2_q;
mmucr0_3       <= mmucr0_3_q;
mmucr1         <= mmucr1_q;
mmucr2         <= mmucr2_q;
mmucr3_0       <= mmucr3_0_q;
mmucr3_1       <= mmucr3_1_q;
mmucr3_2       <= mmucr3_2_q;
mmucr3_3       <= mmucr3_3_q;
lpidr          <= lpidr_q;
ac_an_lpar_id  <= lpidr_q;
mmucfg_lrat        <= mmucfg_q(47);
mmucfg_twc         <= mmucfg_q(48);
tlb0cfg_pt         <= tlb0cfg_q(45);
tlb0cfg_ind        <= tlb0cfg_q(46);
tlb0cfg_gtwe       <= tlb0cfg_q(47);
mas0_0_atsel     <= mas0_0_atsel_q;
mas0_0_esel     <= mas0_0_esel_q;
mas0_0_hes     <= mas0_0_hes_q;
mas0_0_wq     <= mas0_0_wq_q;
mas1_0_v     <= mas1_0_v_q;
mas1_0_iprot     <= mas1_0_iprot_q;
mas1_0_tid     <= mas1_0_tid_q;
mas1_0_ind     <= mas1_0_ind_q;
mas1_0_ts     <= mas1_0_ts_q;
mas1_0_tsize     <= mas1_0_tsize_q;
gen32_mas2_0_epn:   if spr_data_width = 32 generate
mas2_0_epn(0   to 31)   <=(others => '0');
mas2_0_epn(32   to 51)   <= mas2_0_epn_q(32   to 51);
end generate gen32_mas2_0_epn;
gen64_mas2_0_epn:   if spr_data_width = 64 generate
mas2_0_epn     <= mas2_0_epn_q;
end generate gen64_mas2_0_epn;
mas2_0_wimge     <= mas2_0_wimge_q;
mas3_0_rpnl     <= mas3_0_rpnl_q;
mas3_0_ubits     <= mas3_0_ubits_q;
mas3_0_usxwr     <= mas3_0_usxwr_q;
mas5_0_sgs     <= mas5_0_sgs_q;
mas5_0_slpid     <= mas5_0_slpid_q;
mas6_0_spid     <= mas6_0_spid_q;
mas6_0_isize     <= mas6_0_isize_q;
mas6_0_sind     <= mas6_0_sind_q;
mas6_0_sas     <= mas6_0_sas_q;
mas7_0_rpnu     <= mas7_0_rpnu_q;
mas8_0_tgs     <= mas8_0_tgs_q;
mas8_0_vf     <= mas8_0_vf_q;
mas8_0_tlpid     <= mas8_0_tlpid_q;
mas0_1_atsel     <= mas0_1_atsel_q;
mas0_1_esel     <= mas0_1_esel_q;
mas0_1_hes     <= mas0_1_hes_q;
mas0_1_wq     <= mas0_1_wq_q;
mas1_1_v     <= mas1_1_v_q;
mas1_1_iprot     <= mas1_1_iprot_q;
mas1_1_tid     <= mas1_1_tid_q;
mas1_1_ind     <= mas1_1_ind_q;
mas1_1_ts     <= mas1_1_ts_q;
mas1_1_tsize     <= mas1_1_tsize_q;
gen32_mas2_1_epn:   if spr_data_width = 32 generate
mas2_1_epn(0   to 31)   <=(others => '0');
mas2_1_epn(32   to 51)   <= mas2_1_epn_q(32   to 51);
end generate gen32_mas2_1_epn;
gen64_mas2_1_epn:   if spr_data_width = 64 generate
mas2_1_epn     <= mas2_1_epn_q;
end generate gen64_mas2_1_epn;
mas2_1_wimge     <= mas2_1_wimge_q;
mas3_1_rpnl     <= mas3_1_rpnl_q;
mas3_1_ubits     <= mas3_1_ubits_q;
mas3_1_usxwr     <= mas3_1_usxwr_q;
mas5_1_sgs     <= mas5_1_sgs_q;
mas5_1_slpid     <= mas5_1_slpid_q;
mas6_1_spid     <= mas6_1_spid_q;
mas6_1_isize     <= mas6_1_isize_q;
mas6_1_sind     <= mas6_1_sind_q;
mas6_1_sas     <= mas6_1_sas_q;
mas7_1_rpnu     <= mas7_1_rpnu_q;
mas8_1_tgs     <= mas8_1_tgs_q;
mas8_1_vf     <= mas8_1_vf_q;
mas8_1_tlpid     <= mas8_1_tlpid_q;
mas0_2_atsel     <= mas0_2_atsel_q;
mas0_2_esel     <= mas0_2_esel_q;
mas0_2_hes     <= mas0_2_hes_q;
mas0_2_wq     <= mas0_2_wq_q;
mas1_2_v     <= mas1_2_v_q;
mas1_2_iprot     <= mas1_2_iprot_q;
mas1_2_tid     <= mas1_2_tid_q;
mas1_2_ind     <= mas1_2_ind_q;
mas1_2_ts     <= mas1_2_ts_q;
mas1_2_tsize     <= mas1_2_tsize_q;
gen32_mas2_2_epn:   if spr_data_width = 32 generate
mas2_2_epn(0   to 31)   <=(others => '0');
mas2_2_epn(32   to 51)   <= mas2_2_epn_q(32   to 51);
end generate gen32_mas2_2_epn;
gen64_mas2_2_epn:   if spr_data_width = 64 generate
mas2_2_epn     <= mas2_2_epn_q;
end generate gen64_mas2_2_epn;
mas2_2_wimge     <= mas2_2_wimge_q;
mas3_2_rpnl     <= mas3_2_rpnl_q;
mas3_2_ubits     <= mas3_2_ubits_q;
mas3_2_usxwr     <= mas3_2_usxwr_q;
mas5_2_sgs     <= mas5_2_sgs_q;
mas5_2_slpid     <= mas5_2_slpid_q;
mas6_2_spid     <= mas6_2_spid_q;
mas6_2_isize     <= mas6_2_isize_q;
mas6_2_sind     <= mas6_2_sind_q;
mas6_2_sas     <= mas6_2_sas_q;
mas7_2_rpnu     <= mas7_2_rpnu_q;
mas8_2_tgs     <= mas8_2_tgs_q;
mas8_2_vf     <= mas8_2_vf_q;
mas8_2_tlpid     <= mas8_2_tlpid_q;
mas0_3_atsel     <= mas0_3_atsel_q;
mas0_3_esel     <= mas0_3_esel_q;
mas0_3_hes     <= mas0_3_hes_q;
mas0_3_wq     <= mas0_3_wq_q;
mas1_3_v     <= mas1_3_v_q;
mas1_3_iprot     <= mas1_3_iprot_q;
mas1_3_tid     <= mas1_3_tid_q;
mas1_3_ind     <= mas1_3_ind_q;
mas1_3_ts     <= mas1_3_ts_q;
mas1_3_tsize     <= mas1_3_tsize_q;
gen32_mas2_3_epn:   if spr_data_width = 32 generate
mas2_3_epn(0   to 31)   <=(others => '0');
mas2_3_epn(32   to 51)   <= mas2_3_epn_q(32   to 51);
end generate gen32_mas2_3_epn;
gen64_mas2_3_epn:   if spr_data_width = 64 generate
mas2_3_epn     <= mas2_3_epn_q;
end generate gen64_mas2_3_epn;
mas2_3_wimge     <= mas2_3_wimge_q;
mas3_3_rpnl     <= mas3_3_rpnl_q;
mas3_3_ubits     <= mas3_3_ubits_q;
mas3_3_usxwr     <= mas3_3_usxwr_q;
mas5_3_sgs     <= mas5_3_sgs_q;
mas5_3_slpid     <= mas5_3_slpid_q;
mas6_3_spid     <= mas6_3_spid_q;
mas6_3_isize     <= mas6_3_isize_q;
mas6_3_sind     <= mas6_3_sind_q;
mas6_3_sas     <= mas6_3_sas_q;
mas7_3_rpnu     <= mas7_3_rpnu_q;
mas8_3_tgs     <= mas8_3_tgs_q;
mas8_3_vf     <= mas8_3_vf_q;
mas8_3_tlpid     <= mas8_3_tlpid_q;
mmucsr0_tlb0fi <= mmucsr0_tlb0fi_q;
-- debug output formation
spr_dbg_slowspr_val_int         <= spr_ctl_int_q(0);
spr_dbg_slowspr_rw_int          <= spr_ctl_int_q(1);
spr_dbg_slowspr_etid_int        <= spr_etid_int_q;
spr_dbg_slowspr_addr_int        <= spr_addr_int_q;
spr_dbg_slowspr_val_out         <= spr_ctl_out_q(0);
spr_dbg_slowspr_done_out        <= spr_ctl_out_q(2);
spr_dbg_slowspr_data_out        <= spr_data_out_q;
spr_dbg_match_64b <= spr_match_64b_q;
spr_dbg_match_any_mmu <= spr_match_any_mmu_q;
spr_dbg_match_any_mas <= spr_match_any_mas_q;
spr_dbg_match_pid    <= spr_match_pid0_q or spr_match_pid1_q or spr_match_pid2_q or spr_match_pid3_q;
spr_dbg_match_mmucr0 <= spr_match_mmucr0_0_q or spr_match_mmucr0_1_q or spr_match_mmucr0_2_q or spr_match_mmucr0_3_q;
spr_dbg_match_mmucr1 <= spr_match_mmucr1_q;
spr_dbg_match_mmucr2 <= spr_match_mmucr2_q;
spr_dbg_match_mmucr3 <= spr_match_mmucr3_0_q or spr_match_mmucr3_1_q or spr_match_mmucr3_2_q or spr_match_mmucr3_3_q;
spr_dbg_match_lpidr  <= spr_match_lpidr_q;
spr_dbg_match_mmucsr0 <= spr_match_mmucsr0_q;
spr_dbg_match_mmucfg <= spr_match_mmucfg_q;
spr_dbg_match_tlb0cfg <= spr_match_tlb0cfg_q;
spr_dbg_match_tlb0ps <= spr_match_tlb0ps_q;
spr_dbg_match_lratcfg <= spr_match_lratcfg;
spr_dbg_match_lratps <= spr_match_lratps_q;
spr_dbg_match_eptcfg <= spr_match_eptcfg_q;
spr_dbg_match_lper <= spr_match_lper_0_q or spr_match_lper_1_q or spr_match_lper_2_q or spr_match_lper_3_q;
spr_dbg_match_lperu <= spr_match_lperu_0_q or spr_match_lperu_1_q or spr_match_lperu_2_q or spr_match_lperu_3_q;
spr_dbg_match_mas0  <= spr_match_mas0_0_q or spr_match_mas0_1_q or spr_match_mas0_2_q or spr_match_mas0_3_q;
spr_dbg_match_mas1  <= spr_match_mas1_0_q or spr_match_mas1_1_q or spr_match_mas1_2_q or spr_match_mas1_3_q;
spr_dbg_match_mas2  <= spr_match_mas2_0_q or spr_match_mas2_1_q or spr_match_mas2_2_q or spr_match_mas2_3_q;
spr_dbg_match_mas2u <= spr_match_mas2u_0_q or spr_match_mas2u_1_q or spr_match_mas2u_2_q or spr_match_mas2u_3_q;
spr_dbg_match_mas3 <= spr_match_mas3_0_q or spr_match_mas3_1_q or spr_match_mas3_2_q or spr_match_mas3_3_q;
spr_dbg_match_mas4 <= spr_match_mas4_0_q or spr_match_mas4_1_q or spr_match_mas4_2_q or spr_match_mas4_3_q;
spr_dbg_match_mas5 <= spr_match_mas5_0_q or spr_match_mas5_1_q or spr_match_mas5_2_q or spr_match_mas5_3_q;
spr_dbg_match_mas6 <= spr_match_mas6_0_q or spr_match_mas6_1_q or spr_match_mas6_2_q or spr_match_mas6_3_q;
spr_dbg_match_mas7 <= spr_match_mas7_0_q or spr_match_mas7_1_q or spr_match_mas7_2_q or spr_match_mas7_3_q;
spr_dbg_match_mas8 <= spr_match_mas8_0_q or spr_match_mas8_1_q or spr_match_mas8_2_q or spr_match_mas8_3_q;
spr_dbg_match_mas01_64b <= spr_match_mas01_64b_0_q or spr_match_mas01_64b_1_q or spr_match_mas01_64b_2_q or spr_match_mas01_64b_3_q;
spr_dbg_match_mas56_64b <= spr_match_mas56_64b_0_q or spr_match_mas56_64b_1_q or spr_match_mas56_64b_2_q or spr_match_mas56_64b_3_q;
spr_dbg_match_mas73_64b <= spr_match_mas73_64b_0_q or spr_match_mas73_64b_1_q or spr_match_mas73_64b_2_q or spr_match_mas73_64b_3_q;
spr_dbg_match_mas81_64b <= spr_match_mas81_64b_0_q or spr_match_mas81_64b_1_q or spr_match_mas81_64b_2_q or spr_match_mas81_64b_3_q;
unused_dc(0) <= or_reduce(LCB_DELAY_LCLKR_DC(1 TO 4));
unused_dc(1) <= or_reduce(LCB_MPW1_DC_B(1 TO 4));
unused_dc(2) <= PC_FUNC_SL_FORCE;
unused_dc(3) <= PC_FUNC_SL_THOLD_0_B;
unused_dc(4) <= TC_SCAN_DIS_DC_B;
unused_dc(5) <= TC_SCAN_DIAG_DC;
unused_dc(6) <= TC_LBIST_EN_DC;
unused_dc(7) <= or_reduce(MMUCFG_Q_B);
unused_dc(8) <= or_reduce(TLB0CFG_Q_B);
unused_dc(9) <= or_reduce(TLB_MAS6_ISIZE);
unused_dc(10) <= TLB_MAS6_SIND;
unused_dc(11) <= or_reduce(LRAT_TAG4_HIT_ENTRY);
unused_dc(12) <= or_reduce(bcfg_spare_q);
unused_dc(13) <= or_reduce(bcfg_spare_q_b);
--------------------------------------------------
-- latches
--------------------------------------------------
-- slow spr daisy-chain latches
spr_ctl_in_latch: tri_rlmreg_p
  generic map (width => spr_ctl_in_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_ctl_in_offset to spr_ctl_in_offset+spr_ctl_in_q'length-1),
            scout   => sov_0(spr_ctl_in_offset to spr_ctl_in_offset+spr_ctl_in_q'length-1),
            din     => spr_ctl_in_d(0 to spr_ctl_width-1),
            dout    => spr_ctl_in_q(0 to spr_ctl_width-1)  );
spr_etid_in_latch: tri_rlmreg_p
  generic map (width => spr_etid_in_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_etid_in_offset to spr_etid_in_offset+spr_etid_in_q'length-1),
            scout   => sov_0(spr_etid_in_offset to spr_etid_in_offset+spr_etid_in_q'length-1),
            din     => spr_etid_in_d(0 to spr_etid_width-1),
            dout    => spr_etid_in_q(0 to spr_etid_width-1)  );
spr_addr_in_latch: tri_rlmreg_p
  generic map (width => spr_addr_in_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_addr_in_offset to spr_addr_in_offset+spr_addr_in_q'length-1),
            scout   => sov_0(spr_addr_in_offset to spr_addr_in_offset+spr_addr_in_q'length-1),
            din     => spr_addr_in_d(0 to spr_addr_width-1),
            dout    => spr_addr_in_q(0 to spr_addr_width-1)  );
spr_addr_in_clone_latch: tri_rlmreg_p
  generic map (width => spr_addr_in_clone_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_addr_in_clone_offset to spr_addr_in_clone_offset+spr_addr_in_clone_q'length-1),
            scout   => sov_1(spr_addr_in_clone_offset to spr_addr_in_clone_offset+spr_addr_in_clone_q'length-1),
            din     => spr_addr_in_clone_d(0 to spr_addr_width-1),
            dout    => spr_addr_in_clone_q(0 to spr_addr_width-1)  );
spr_data_in_latch: tri_rlmreg_p
  generic map (width => spr_data_in_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_data_in_offset to spr_data_in_offset+spr_data_in_q'length-1),
            scout   => sov_0(spr_data_in_offset to spr_data_in_offset+spr_data_in_q'length-1),
            din     => spr_data_in_d(64-spr_data_width to 63),
            dout    => spr_data_in_q(64-spr_data_width to 63)  );
-- these are the spr internal select stage latches below
spr_ctl_int_latch: tri_rlmreg_p
  generic map (width => spr_ctl_int_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_ctl_int_offset to spr_ctl_int_offset+spr_ctl_int_q'length-1),
            scout   => sov_0(spr_ctl_int_offset to spr_ctl_int_offset+spr_ctl_int_q'length-1),
            din     => spr_ctl_int_d(0 to spr_ctl_width-1),
            dout    => spr_ctl_int_q(0 to spr_ctl_width-1)  );
spr_etid_int_latch: tri_rlmreg_p
  generic map (width => spr_etid_int_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_etid_int_offset to spr_etid_int_offset+spr_etid_int_q'length-1),
            scout   => sov_0(spr_etid_int_offset to spr_etid_int_offset+spr_etid_int_q'length-1),
            din     => spr_etid_int_d(0 to spr_etid_width-1),
            dout    => spr_etid_int_q(0 to spr_etid_width-1)  );
spr_addr_int_latch: tri_rlmreg_p
  generic map (width => spr_addr_int_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_addr_int_offset to spr_addr_int_offset+spr_addr_int_q'length-1),
            scout   => sov_0(spr_addr_int_offset to spr_addr_int_offset+spr_addr_int_q'length-1),
            din     => spr_addr_int_d(0 to spr_addr_width-1),
            dout    => spr_addr_int_q(0 to spr_addr_width-1)  );
spr_data_int_latch: tri_rlmreg_p
  generic map (width => spr_data_int_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_data_int_offset to spr_data_int_offset+spr_data_int_q'length-1),
            scout   => sov_0(spr_data_int_offset to spr_data_int_offset+spr_data_int_q'length-1),
            din     => spr_data_int_d(64-spr_data_width to 63),
            dout    => spr_data_int_q(64-spr_data_width to 63)  );
-- these are the spr out latches below
spr_ctl_out_latch: tri_rlmreg_p
  generic map (width => spr_ctl_out_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_ctl_out_offset to spr_ctl_out_offset+spr_ctl_out_q'length-1),
            scout   => sov_0(spr_ctl_out_offset to spr_ctl_out_offset+spr_ctl_out_q'length-1),
            din     => spr_ctl_out_d(0 to spr_ctl_width-1),
            dout    => spr_ctl_out_q(0 to spr_ctl_width-1)  );
spr_etid_out_latch: tri_rlmreg_p
  generic map (width => spr_etid_out_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_etid_out_offset to spr_etid_out_offset+spr_etid_out_q'length-1),
            scout   => sov_0(spr_etid_out_offset to spr_etid_out_offset+spr_etid_out_q'length-1),
            din     => spr_etid_out_d(0 to spr_etid_width-1),
            dout    => spr_etid_out_q(0 to spr_etid_width-1)  );
spr_addr_out_latch: tri_rlmreg_p
  generic map (width => spr_addr_out_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_addr_out_offset to spr_addr_out_offset+spr_addr_out_q'length-1),
            scout   => sov_0(spr_addr_out_offset to spr_addr_out_offset+spr_addr_out_q'length-1),
            din     => spr_addr_out_d(0 to spr_addr_width-1),
            dout    => spr_addr_out_q(0 to spr_addr_width-1)  );
spr_data_out_latch: tri_rlmreg_p
  generic map (width => spr_data_out_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_val_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_data_out_offset to spr_data_out_offset+spr_data_out_q'length-1),
            scout   => sov_0(spr_data_out_offset to spr_data_out_offset+spr_data_out_q'length-1),
            din     => spr_data_out_d(64-spr_data_width to 63),
            dout    => spr_data_out_q(64-spr_data_width to 63)  );
-- spr decode match latches for timing
spr_match_any_mmu_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_any_mmu_offset),
            scout   => sov_0(spr_match_any_mmu_offset),
            din     => spr_match_any_mmu,
            dout    => spr_match_any_mmu_q);
spr_match_pid0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_pid0_offset),
            scout   => sov_0(spr_match_pid0_offset),
            din     => spr_match_pid0,
            dout    => spr_match_pid0_q);
spr_match_pid1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_pid1_offset),
            scout   => sov_0(spr_match_pid1_offset),
            din     => spr_match_pid1,
            dout    => spr_match_pid1_q);
spr_match_pid2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_pid2_offset),
            scout   => sov_0(spr_match_pid2_offset),
            din     => spr_match_pid2,
            dout    => spr_match_pid2_q);
spr_match_pid3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_pid3_offset),
            scout   => sov_0(spr_match_pid3_offset),
            din     => spr_match_pid3,
            dout    => spr_match_pid3_q);
spr_match_mmucr0_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr0_0_offset),
            scout   => sov_0(spr_match_mmucr0_0_offset),
            din     => spr_match_mmucr0_0,
            dout    => spr_match_mmucr0_0_q);
spr_match_mmucr0_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr0_1_offset),
            scout   => sov_0(spr_match_mmucr0_1_offset),
            din     => spr_match_mmucr0_1,
            dout    => spr_match_mmucr0_1_q);
spr_match_mmucr0_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr0_2_offset),
            scout   => sov_0(spr_match_mmucr0_2_offset),
            din     => spr_match_mmucr0_2,
            dout    => spr_match_mmucr0_2_q);
spr_match_mmucr0_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr0_3_offset),
            scout   => sov_0(spr_match_mmucr0_3_offset),
            din     => spr_match_mmucr0_3,
            dout    => spr_match_mmucr0_3_q);
spr_match_mmucr1_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr1_offset),
            scout   => sov_0(spr_match_mmucr1_offset),
            din     => spr_match_mmucr1,
            dout    => spr_match_mmucr1_q);
spr_match_mmucr2_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr2_offset),
            scout   => sov_0(spr_match_mmucr2_offset),
            din     => spr_match_mmucr2,
            dout    => spr_match_mmucr2_q);
spr_match_mmucr3_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr3_0_offset),
            scout   => sov_0(spr_match_mmucr3_0_offset),
            din     => spr_match_mmucr3_0,
            dout    => spr_match_mmucr3_0_q);
spr_match_mmucr3_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr3_1_offset),
            scout   => sov_0(spr_match_mmucr3_1_offset),
            din     => spr_match_mmucr3_1,
            dout    => spr_match_mmucr3_1_q);
spr_match_mmucr3_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr3_2_offset),
            scout   => sov_0(spr_match_mmucr3_2_offset),
            din     => spr_match_mmucr3_2,
            dout    => spr_match_mmucr3_2_q);
spr_match_mmucr3_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_mmucr3_3_offset),
            scout   => sov_0(spr_match_mmucr3_3_offset),
            din     => spr_match_mmucr3_3,
            dout    => spr_match_mmucr3_3_q);
spr_match_lpidr_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_match_lpidr_offset),
            scout   => sov_0(spr_match_lpidr_offset),
            din     => spr_match_lpidr,
            dout    => spr_match_lpidr_q);
spr_match_mmucsr0_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mmucsr0_offset),
            scout   => sov_1(spr_match_mmucsr0_offset),
            din     => spr_match_mmucsr0,
            dout    => spr_match_mmucsr0_q);
spr_match_mmucfg_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mmucfg_offset),
            scout   => sov_1(spr_match_mmucfg_offset),
            din     => spr_match_mmucfg,
            dout    => spr_match_mmucfg_q);
spr_match_tlb0cfg_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_tlb0cfg_offset),
            scout   => sov_1(spr_match_tlb0cfg_offset),
            din     => spr_match_tlb0cfg,
            dout    => spr_match_tlb0cfg_q);
spr_match_tlb0ps_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_tlb0ps_offset),
            scout   => sov_1(spr_match_tlb0ps_offset),
            din     => spr_match_tlb0ps,
            dout    => spr_match_tlb0ps_q);
spr_match_lratcfg_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lratcfg_offset),
            scout   => sov_1(spr_match_lratcfg_offset),
            din     => spr_match_lratcfg,
            dout    => spr_match_lratcfg_q);
spr_match_lratps_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lratps_offset),
            scout   => sov_1(spr_match_lratps_offset),
            din     => spr_match_lratps,
            dout    => spr_match_lratps_q);
spr_match_eptcfg_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_eptcfg_offset),
            scout   => sov_1(spr_match_eptcfg_offset),
            din     => spr_match_eptcfg,
            dout    => spr_match_eptcfg_q);
spr_match_lper_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lper_0_offset),
            scout   => sov_1(spr_match_lper_0_offset),
            din     => spr_match_lper_0,
            dout    => spr_match_lper_0_q);
spr_match_lper_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lper_1_offset),
            scout   => sov_1(spr_match_lper_1_offset),
            din     => spr_match_lper_1,
            dout    => spr_match_lper_1_q);
spr_match_lper_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lper_2_offset),
            scout   => sov_1(spr_match_lper_2_offset),
            din     => spr_match_lper_2,
            dout    => spr_match_lper_2_q);
spr_match_lper_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lper_3_offset),
            scout   => sov_1(spr_match_lper_3_offset),
            din     => spr_match_lper_3,
            dout    => spr_match_lper_3_q);
spr_match_lperu_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lperu_0_offset),
            scout   => sov_1(spr_match_lperu_0_offset),
            din     => spr_match_lperu_0,
            dout    => spr_match_lperu_0_q);
spr_match_lperu_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lperu_1_offset),
            scout   => sov_1(spr_match_lperu_1_offset),
            din     => spr_match_lperu_1,
            dout    => spr_match_lperu_1_q);
spr_match_lperu_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lperu_2_offset),
            scout   => sov_1(spr_match_lperu_2_offset),
            din     => spr_match_lperu_2,
            dout    => spr_match_lperu_2_q);
spr_match_lperu_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_lperu_3_offset),
            scout   => sov_1(spr_match_lperu_3_offset),
            din     => spr_match_lperu_3,
            dout    => spr_match_lperu_3_q);
spr_match_mas0_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas0_0_offset),
            scout   => sov_1(spr_match_mas0_0_offset),
            din     => spr_match_mas0_0,
            dout    => spr_match_mas0_0_q);
spr_match_mas0_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas0_1_offset),
            scout   => sov_1(spr_match_mas0_1_offset),
            din     => spr_match_mas0_1,
            dout    => spr_match_mas0_1_q);
spr_match_mas0_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas0_2_offset),
            scout   => sov_1(spr_match_mas0_2_offset),
            din     => spr_match_mas0_2,
            dout    => spr_match_mas0_2_q);
spr_match_mas0_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas0_3_offset),
            scout   => sov_1(spr_match_mas0_3_offset),
            din     => spr_match_mas0_3,
            dout    => spr_match_mas0_3_q);
spr_match_mas1_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas1_0_offset),
            scout   => sov_1(spr_match_mas1_0_offset),
            din     => spr_match_mas1_0,
            dout    => spr_match_mas1_0_q);
spr_match_mas1_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas1_1_offset),
            scout   => sov_1(spr_match_mas1_1_offset),
            din     => spr_match_mas1_1,
            dout    => spr_match_mas1_1_q);
spr_match_mas1_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas1_2_offset),
            scout   => sov_1(spr_match_mas1_2_offset),
            din     => spr_match_mas1_2,
            dout    => spr_match_mas1_2_q);
spr_match_mas1_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas1_3_offset),
            scout   => sov_1(spr_match_mas1_3_offset),
            din     => spr_match_mas1_3,
            dout    => spr_match_mas1_3_q);
spr_match_mas2_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2_0_offset),
            scout   => sov_1(spr_match_mas2_0_offset),
            din     => spr_match_mas2_0,
            dout    => spr_match_mas2_0_q);
spr_match_mas2_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2_1_offset),
            scout   => sov_1(spr_match_mas2_1_offset),
            din     => spr_match_mas2_1,
            dout    => spr_match_mas2_1_q);
spr_match_mas2_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2_2_offset),
            scout   => sov_1(spr_match_mas2_2_offset),
            din     => spr_match_mas2_2,
            dout    => spr_match_mas2_2_q);
spr_match_mas2_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2_3_offset),
            scout   => sov_1(spr_match_mas2_3_offset),
            din     => spr_match_mas2_3,
            dout    => spr_match_mas2_3_q);
spr_match_mas3_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas3_0_offset),
            scout   => sov_1(spr_match_mas3_0_offset),
            din     => spr_match_mas3_0,
            dout    => spr_match_mas3_0_q);
spr_match_mas3_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas3_1_offset),
            scout   => sov_1(spr_match_mas3_1_offset),
            din     => spr_match_mas3_1,
            dout    => spr_match_mas3_1_q);
spr_match_mas3_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas3_2_offset),
            scout   => sov_1(spr_match_mas3_2_offset),
            din     => spr_match_mas3_2,
            dout    => spr_match_mas3_2_q);
spr_match_mas3_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas3_3_offset),
            scout   => sov_1(spr_match_mas3_3_offset),
            din     => spr_match_mas3_3,
            dout    => spr_match_mas3_3_q);
spr_match_mas4_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas4_0_offset),
            scout   => sov_1(spr_match_mas4_0_offset),
            din     => spr_match_mas4_0,
            dout    => spr_match_mas4_0_q);
spr_match_mas4_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas4_1_offset),
            scout   => sov_1(spr_match_mas4_1_offset),
            din     => spr_match_mas4_1,
            dout    => spr_match_mas4_1_q);
spr_match_mas4_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas4_2_offset),
            scout   => sov_1(spr_match_mas4_2_offset),
            din     => spr_match_mas4_2,
            dout    => spr_match_mas4_2_q);
spr_match_mas4_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas4_3_offset),
            scout   => sov_1(spr_match_mas4_3_offset),
            din     => spr_match_mas4_3,
            dout    => spr_match_mas4_3_q);
spr_match_mas5_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas5_0_offset),
            scout   => sov_1(spr_match_mas5_0_offset),
            din     => spr_match_mas5_0,
            dout    => spr_match_mas5_0_q);
spr_match_mas5_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas5_1_offset),
            scout   => sov_1(spr_match_mas5_1_offset),
            din     => spr_match_mas5_1,
            dout    => spr_match_mas5_1_q);
spr_match_mas5_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas5_2_offset),
            scout   => sov_1(spr_match_mas5_2_offset),
            din     => spr_match_mas5_2,
            dout    => spr_match_mas5_2_q);
spr_match_mas5_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas5_3_offset),
            scout   => sov_1(spr_match_mas5_3_offset),
            din     => spr_match_mas5_3,
            dout    => spr_match_mas5_3_q);
spr_match_mas6_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas6_0_offset),
            scout   => sov_1(spr_match_mas6_0_offset),
            din     => spr_match_mas6_0,
            dout    => spr_match_mas6_0_q);
spr_match_mas6_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas6_1_offset),
            scout   => sov_1(spr_match_mas6_1_offset),
            din     => spr_match_mas6_1,
            dout    => spr_match_mas6_1_q);
spr_match_mas6_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas6_2_offset),
            scout   => sov_1(spr_match_mas6_2_offset),
            din     => spr_match_mas6_2,
            dout    => spr_match_mas6_2_q);
spr_match_mas6_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas6_3_offset),
            scout   => sov_1(spr_match_mas6_3_offset),
            din     => spr_match_mas6_3,
            dout    => spr_match_mas6_3_q);
spr_match_mas7_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas7_0_offset),
            scout   => sov_1(spr_match_mas7_0_offset),
            din     => spr_match_mas7_0,
            dout    => spr_match_mas7_0_q);
spr_match_mas7_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas7_1_offset),
            scout   => sov_1(spr_match_mas7_1_offset),
            din     => spr_match_mas7_1,
            dout    => spr_match_mas7_1_q);
spr_match_mas7_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas7_2_offset),
            scout   => sov_1(spr_match_mas7_2_offset),
            din     => spr_match_mas7_2,
            dout    => spr_match_mas7_2_q);
spr_match_mas7_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas7_3_offset),
            scout   => sov_1(spr_match_mas7_3_offset),
            din     => spr_match_mas7_3,
            dout    => spr_match_mas7_3_q);
spr_match_mas8_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas8_0_offset),
            scout   => sov_1(spr_match_mas8_0_offset),
            din     => spr_match_mas8_0,
            dout    => spr_match_mas8_0_q);
spr_match_mas8_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas8_1_offset),
            scout   => sov_1(spr_match_mas8_1_offset),
            din     => spr_match_mas8_1,
            dout    => spr_match_mas8_1_q);
spr_match_mas8_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas8_2_offset),
            scout   => sov_1(spr_match_mas8_2_offset),
            din     => spr_match_mas8_2,
            dout    => spr_match_mas8_2_q);
spr_match_mas8_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas8_3_offset),
            scout   => sov_1(spr_match_mas8_3_offset),
            din     => spr_match_mas8_3,
            dout    => spr_match_mas8_3_q);
spr_match_mas2u_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2u_0_offset),
            scout   => sov_1(spr_match_mas2u_0_offset),
            din     => spr_match_mas2u_0,
            dout    => spr_match_mas2u_0_q);
spr_match_mas2u_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2u_1_offset),
            scout   => sov_1(spr_match_mas2u_1_offset),
            din     => spr_match_mas2u_1,
            dout    => spr_match_mas2u_1_q);
spr_match_mas2u_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2u_2_offset),
            scout   => sov_1(spr_match_mas2u_2_offset),
            din     => spr_match_mas2u_2,
            dout    => spr_match_mas2u_2_q);
spr_match_mas2u_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas2u_3_offset),
            scout   => sov_1(spr_match_mas2u_3_offset),
            din     => spr_match_mas2u_3,
            dout    => spr_match_mas2u_3_q);
spr_match_mas01_64b_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas01_64b_0_offset),
            scout   => sov_1(spr_match_mas01_64b_0_offset),
            din     => spr_match_mas01_64b_0,
            dout    => spr_match_mas01_64b_0_q);
spr_match_mas01_64b_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas01_64b_1_offset),
            scout   => sov_1(spr_match_mas01_64b_1_offset),
            din     => spr_match_mas01_64b_1,
            dout    => spr_match_mas01_64b_1_q);
spr_match_mas01_64b_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas01_64b_2_offset),
            scout   => sov_1(spr_match_mas01_64b_2_offset),
            din     => spr_match_mas01_64b_2,
            dout    => spr_match_mas01_64b_2_q);
spr_match_mas01_64b_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas01_64b_3_offset),
            scout   => sov_1(spr_match_mas01_64b_3_offset),
            din     => spr_match_mas01_64b_3,
            dout    => spr_match_mas01_64b_3_q);
spr_match_mas56_64b_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas56_64b_0_offset),
            scout   => sov_1(spr_match_mas56_64b_0_offset),
            din     => spr_match_mas56_64b_0,
            dout    => spr_match_mas56_64b_0_q);
spr_match_mas56_64b_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas56_64b_1_offset),
            scout   => sov_1(spr_match_mas56_64b_1_offset),
            din     => spr_match_mas56_64b_1,
            dout    => spr_match_mas56_64b_1_q);
spr_match_mas56_64b_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas56_64b_2_offset),
            scout   => sov_1(spr_match_mas56_64b_2_offset),
            din     => spr_match_mas56_64b_2,
            dout    => spr_match_mas56_64b_2_q);
spr_match_mas56_64b_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas56_64b_3_offset),
            scout   => sov_1(spr_match_mas56_64b_3_offset),
            din     => spr_match_mas56_64b_3,
            dout    => spr_match_mas56_64b_3_q);
spr_match_mas73_64b_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas73_64b_0_offset),
            scout   => sov_1(spr_match_mas73_64b_0_offset),
            din     => spr_match_mas73_64b_0,
            dout    => spr_match_mas73_64b_0_q);
spr_match_mas73_64b_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas73_64b_1_offset),
            scout   => sov_1(spr_match_mas73_64b_1_offset),
            din     => spr_match_mas73_64b_1,
            dout    => spr_match_mas73_64b_1_q);
spr_match_mas73_64b_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas73_64b_2_offset),
            scout   => sov_1(spr_match_mas73_64b_2_offset),
            din     => spr_match_mas73_64b_2,
            dout    => spr_match_mas73_64b_2_q);
spr_match_mas73_64b_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas73_64b_3_offset),
            scout   => sov_1(spr_match_mas73_64b_3_offset),
            din     => spr_match_mas73_64b_3,
            dout    => spr_match_mas73_64b_3_q);
spr_match_mas81_64b_0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas81_64b_0_offset),
            scout   => sov_1(spr_match_mas81_64b_0_offset),
            din     => spr_match_mas81_64b_0,
            dout    => spr_match_mas81_64b_0_q);
spr_match_mas81_64b_1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas81_64b_1_offset),
            scout   => sov_1(spr_match_mas81_64b_1_offset),
            din     => spr_match_mas81_64b_1,
            dout    => spr_match_mas81_64b_1_q);
spr_match_mas81_64b_2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas81_64b_2_offset),
            scout   => sov_1(spr_match_mas81_64b_2_offset),
            din     => spr_match_mas81_64b_2,
            dout    => spr_match_mas81_64b_2_q);
spr_match_mas81_64b_3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_mas81_64b_3_offset),
            scout   => sov_1(spr_match_mas81_64b_3_offset),
            din     => spr_match_mas81_64b_3,
            dout    => spr_match_mas81_64b_3_q);
spr_match_64b_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_64b_offset),
            scout   => sov_1(spr_match_64b_offset),
            din     => spr_match_64b,
            dout    => spr_match_64b_q);
-- internal mas data output register
spr_mas_data_out_latch: tri_rlmreg_p
  generic map (width => spr_mas_data_out_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_mas_data_out_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_mas_data_out_offset to spr_mas_data_out_offset+spr_mas_data_out_q'length-1),
            scout   => sov_1(spr_mas_data_out_offset to spr_mas_data_out_offset+spr_mas_data_out_q'length-1),
            din     => spr_mas_data_out(64-spr_data_width to 63),
            dout    => spr_mas_data_out_q(64-spr_data_width to 63)  );
spr_match_any_mas_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_match_mas_act,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spr_match_any_mas_offset),
            scout   => sov_1(spr_match_any_mas_offset),
            din     => spr_match_any_mas,
            dout    => spr_match_any_mas_q);
-- pid spr's
pid0_latch:   tri_rlmreg_p
  generic map (width => pid0_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_mmu_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(pid0_offset   to pid0_offset+pid0_q'length-1),
            scout   => sov_0(pid0_offset   to pid0_offset+pid0_q'length-1),
            din     => pid0_d(0   to pid_width-1),
            dout    => pid0_q(0   to pid_width-1)  );
pid1_latch:   tri_rlmreg_p
  generic map (width => pid1_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_mmu_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(pid1_offset   to pid1_offset+pid1_q'length-1),
            scout   => sov_0(pid1_offset   to pid1_offset+pid1_q'length-1),
            din     => pid1_d(0   to pid_width-1),
            dout    => pid1_q(0   to pid_width-1)  );
pid2_latch:   tri_rlmreg_p
  generic map (width => pid2_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_mmu_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(pid2_offset   to pid2_offset+pid2_q'length-1),
            scout   => sov_0(pid2_offset   to pid2_offset+pid2_q'length-1),
            din     => pid2_d(0   to pid_width-1),
            dout    => pid2_q(0   to pid_width-1)  );
pid3_latch:   tri_rlmreg_p
  generic map (width => pid3_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_mmu_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(pid3_offset   to pid3_offset+pid3_q'length-1),
            scout   => sov_0(pid3_offset   to pid3_offset+pid3_q'length-1),
            din     => pid3_d(0   to pid_width-1),
            dout    => pid3_q(0   to pid_width-1)  );
mmucr0_0_latch:   tri_rlmreg_p
  generic map (width => mmucr0_0_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(mmucr0_0_offset   to mmucr0_0_offset+mmucr0_0_q'length-1),
            scout   => sov_0(mmucr0_0_offset   to mmucr0_0_offset+mmucr0_0_q'length-1),
            din     => mmucr0_0_d(0   to mmucr0_width-1),
            dout    => mmucr0_0_q(0   to mmucr0_width-1)  );
mmucr0_1_latch:   tri_rlmreg_p
  generic map (width => mmucr0_1_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(mmucr0_1_offset   to mmucr0_1_offset+mmucr0_1_q'length-1),
            scout   => sov_0(mmucr0_1_offset   to mmucr0_1_offset+mmucr0_1_q'length-1),
            din     => mmucr0_1_d(0   to mmucr0_width-1),
            dout    => mmucr0_1_q(0   to mmucr0_width-1)  );
mmucr0_2_latch:   tri_rlmreg_p
  generic map (width => mmucr0_2_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(mmucr0_2_offset   to mmucr0_2_offset+mmucr0_2_q'length-1),
            scout   => sov_0(mmucr0_2_offset   to mmucr0_2_offset+mmucr0_2_q'length-1),
            din     => mmucr0_2_d(0   to mmucr0_width-1),
            dout    => mmucr0_2_q(0   to mmucr0_width-1)  );
mmucr0_3_latch:   tri_rlmreg_p
  generic map (width => mmucr0_3_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(mmucr0_3_offset   to mmucr0_3_offset+mmucr0_3_q'length-1),
            scout   => sov_0(mmucr0_3_offset   to mmucr0_3_offset+mmucr0_3_q'length-1),
            din     => mmucr0_3_d(0   to mmucr0_width-1),
            dout    => mmucr0_3_q(0   to mmucr0_width-1)  );
mmucr1_latch: tri_rlmreg_p
  generic map (width => mmucr1_q'length, init => bcfg_mmucr1_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
            scout   => bsov(mmucr1_offset to mmucr1_offset+mmucr1_q'length-1),
            din     => mmucr1_d(0 to mmucr1_width-1),
            dout    => mmucr1_q(0 to mmucr1_width-1)  );
mmucr2_latch: tri_rlmreg_p
  generic map (width => mmucr2_q'length, init => bcfg_mmucr2_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mmucr2_offset to mmucr2_offset+mmucr2_q'length-1),
            scout   => bsov(mmucr2_offset to mmucr2_offset+mmucr2_q'length-1),
            din     => mmucr2_d(0 to mmucr2_width-1),
            dout    => mmucr2_q(0 to mmucr2_width-1)  );
mmucr3_0_latch:   tri_rlmreg_p
  generic map (width => mmucr3_0_q'length,   init => bcfg_mmucr3_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mmucr3_0_offset   to mmucr3_0_offset+mmucr3_0_q'length-1),
            scout   => bsov(mmucr3_0_offset   to mmucr3_0_offset+mmucr3_0_q'length-1),
            din     => mmucr3_0_d(64-mmucr3_width   to 63),
            dout    => mmucr3_0_q(64-mmucr3_width   to 63)  );
mmucr3_1_latch:   tri_rlmreg_p
  generic map (width => mmucr3_1_q'length,   init => bcfg_mmucr3_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mmucr3_1_offset   to mmucr3_1_offset+mmucr3_1_q'length-1),
            scout   => bsov(mmucr3_1_offset   to mmucr3_1_offset+mmucr3_1_q'length-1),
            din     => mmucr3_1_d(64-mmucr3_width   to 63),
            dout    => mmucr3_1_q(64-mmucr3_width   to 63)  );
mmucr3_2_latch:   tri_rlmreg_p
  generic map (width => mmucr3_2_q'length,   init => bcfg_mmucr3_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mmucr3_2_offset   to mmucr3_2_offset+mmucr3_2_q'length-1),
            scout   => bsov(mmucr3_2_offset   to mmucr3_2_offset+mmucr3_2_q'length-1),
            din     => mmucr3_2_d(64-mmucr3_width   to 63),
            dout    => mmucr3_2_q(64-mmucr3_width   to 63)  );
mmucr3_3_latch:   tri_rlmreg_p
  generic map (width => mmucr3_3_q'length,   init => bcfg_mmucr3_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mmucr3_3_offset   to mmucr3_3_offset+mmucr3_3_q'length-1),
            scout   => bsov(mmucr3_3_offset   to mmucr3_3_offset+mmucr3_3_q'length-1),
            din     => mmucr3_3_d(64-mmucr3_width   to 63),
            dout    => mmucr3_3_q(64-mmucr3_width   to 63)  );
lpidr_latch: tri_rlmreg_p
  generic map (width => lpidr_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => spr_mmu_act_q(thdid_width),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(lpidr_offset to lpidr_offset+lpidr_q'length-1),
            scout   => sov_0(lpidr_offset to lpidr_offset+lpidr_q'length-1),
            din     => lpidr_d(0 to lpid_width-1),
            dout    => lpidr_q(0 to lpid_width-1)  );
mas0_0_atsel_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_0_atsel_offset),
            scout   => sov_1(mas0_0_atsel_offset),
            din     => mas0_0_atsel_d,
            dout    => mas0_0_atsel_q);
mas0_0_esel_latch:   tri_rlmreg_p
  generic map (width => mas0_0_esel_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_0_esel_offset   to mas0_0_esel_offset+mas0_0_esel_q'length-1),
            scout   => sov_1(mas0_0_esel_offset   to mas0_0_esel_offset+mas0_0_esel_q'length-1),
            din     => mas0_0_esel_d(0   to mas0_0_esel_d'length-1),
            dout    => mas0_0_esel_q(0   to mas0_0_esel_q'length-1)    );
mas0_0_hes_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_0_hes_offset),
            scout   => sov_1(mas0_0_hes_offset),
            din     => mas0_0_hes_d,
            dout    => mas0_0_hes_q);
mas0_0_wq_latch:   tri_rlmreg_p
  generic map (width => mas0_0_wq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_0_wq_offset   to mas0_0_wq_offset+mas0_0_wq_q'length-1),
            scout   => sov_1(mas0_0_wq_offset   to mas0_0_wq_offset+mas0_0_wq_q'length-1),
            din     => mas0_0_wq_d(0   to mas0_0_wq_d'length-1),
            dout    => mas0_0_wq_q(0   to mas0_0_wq_q'length-1)    );
mas1_0_v_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_0_v_offset),
            scout   => sov_1(mas1_0_v_offset),
            din     => mas1_0_v_d,
            dout    => mas1_0_v_q);
mas1_0_iprot_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_0_iprot_offset),
            scout   => sov_1(mas1_0_iprot_offset),
            din     => mas1_0_iprot_d,
            dout    => mas1_0_iprot_q);
mas1_0_tid_latch:   tri_rlmreg_p
  generic map (width => mas1_0_tid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_0_tid_offset   to mas1_0_tid_offset+mas1_0_tid_q'length-1),
            scout   => sov_1(mas1_0_tid_offset   to mas1_0_tid_offset+mas1_0_tid_q'length-1),
            din     => mas1_0_tid_d(0   to mas1_0_tid_d'length-1),
            dout    => mas1_0_tid_q(0   to mas1_0_tid_q'length-1)    );
mas1_0_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_0_ind_offset),
            scout   => sov_1(mas1_0_ind_offset),
            din     => mas1_0_ind_d,
            dout    => mas1_0_ind_q);
mas1_0_ts_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_0_ts_offset),
            scout   => sov_1(mas1_0_ts_offset),
            din     => mas1_0_ts_d,
            dout    => mas1_0_ts_q);
mas1_0_tsize_latch:   tri_rlmreg_p
  generic map (width => mas1_0_tsize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_0_tsize_offset   to mas1_0_tsize_offset+mas1_0_tsize_q'length-1),
            scout   => sov_1(mas1_0_tsize_offset   to mas1_0_tsize_offset+mas1_0_tsize_q'length-1),
            din     => mas1_0_tsize_d(0   to mas1_0_tsize_d'length-1),
            dout    => mas1_0_tsize_q(0   to mas1_0_tsize_q'length-1)    );
mas2_0_epn_latch:   tri_rlmreg_p
  generic map (width => mas2_0_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_0_epn_offset   to mas2_0_epn_offset+mas2_0_epn_q'length-1),
            scout   => sov_1(mas2_0_epn_offset   to mas2_0_epn_offset+mas2_0_epn_q'length-1),
            din     => mas2_0_epn_d(52-mas2_0_epn_d'length   to 51),
            dout    => mas2_0_epn_q(52-mas2_0_epn_q'length   to 51)  );
mas2_0_wimge_latch:   tri_rlmreg_p
  generic map (width => mas2_0_wimge_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_0_wimge_offset   to mas2_0_wimge_offset+mas2_0_wimge_q'length-1),
            scout   => sov_1(mas2_0_wimge_offset   to mas2_0_wimge_offset+mas2_0_wimge_q'length-1),
            din     => mas2_0_wimge_d(0   to mas2_0_wimge_d'length-1),
            dout    => mas2_0_wimge_q(0   to mas2_0_wimge_q'length-1)    );
mas3_0_rpnl_latch:   tri_rlmreg_p
  generic map (width => mas3_0_rpnl_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_0_rpnl_offset   to mas3_0_rpnl_offset+mas3_0_rpnl_q'length-1),
            scout   => sov_1(mas3_0_rpnl_offset   to mas3_0_rpnl_offset+mas3_0_rpnl_q'length-1),
            din     => mas3_0_rpnl_d(32   to 32+mas3_0_rpnl_d'length-1),
            dout    => mas3_0_rpnl_q(32   to 32+mas3_0_rpnl_q'length-1)    );
mas3_0_ubits_latch:   tri_rlmreg_p
  generic map (width => mas3_0_ubits_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_0_ubits_offset   to mas3_0_ubits_offset+mas3_0_ubits_q'length-1),
            scout   => sov_1(mas3_0_ubits_offset   to mas3_0_ubits_offset+mas3_0_ubits_q'length-1),
            din     => mas3_0_ubits_d(0   to mas3_0_ubits_d'length-1),
            dout    => mas3_0_ubits_q(0   to mas3_0_ubits_q'length-1)    );
mas3_0_usxwr_latch:   tri_rlmreg_p
  generic map (width => mas3_0_usxwr_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_0_usxwr_offset   to mas3_0_usxwr_offset+mas3_0_usxwr_q'length-1),
            scout   => sov_1(mas3_0_usxwr_offset   to mas3_0_usxwr_offset+mas3_0_usxwr_q'length-1),
            din     => mas3_0_usxwr_d(0   to mas3_0_usxwr_d'length-1),
            dout    => mas3_0_usxwr_q(0   to mas3_0_usxwr_q'length-1)    );
mas4_0_indd_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_0_indd_offset),
            scout   => bsov(mas4_0_indd_offset),
            din     => mas4_0_indd_d,
            dout    => mas4_0_indd_q);
mas4_0_tsized_latch:   tri_rlmreg_p
  generic map (width => mas4_0_tsized_q'length,   init => 1, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_0_tsized_offset   to mas4_0_tsized_offset+mas4_0_tsized_q'length-1),
            scout   => bsov(mas4_0_tsized_offset   to mas4_0_tsized_offset+mas4_0_tsized_q'length-1),
            din     => mas4_0_tsized_d(0   to mas4_0_tsized_d'length-1),
            dout    => mas4_0_tsized_q(0   to mas4_0_tsized_q'length-1)    );
mas4_0_wimged_latch:   tri_rlmreg_p
  generic map (width => mas4_0_wimged_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_0_wimged_offset   to mas4_0_wimged_offset+mas4_0_wimged_q'length-1),
            scout   => bsov(mas4_0_wimged_offset   to mas4_0_wimged_offset+mas4_0_wimged_q'length-1),
            din     => mas4_0_wimged_d(0   to mas4_0_wimged_d'length-1),
            dout    => mas4_0_wimged_q(0   to mas4_0_wimged_q'length-1)    );
mas5_0_sgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_0_sgs_offset),
            scout   => sov_1(mas5_0_sgs_offset),
            din     => mas5_0_sgs_d,
            dout    => mas5_0_sgs_q);
mas5_0_slpid_latch:   tri_rlmreg_p
  generic map (width => mas5_0_slpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_0_slpid_offset   to mas5_0_slpid_offset+mas5_0_slpid_q'length-1),
            scout   => sov_1(mas5_0_slpid_offset   to mas5_0_slpid_offset+mas5_0_slpid_q'length-1),
            din     => mas5_0_slpid_d(0   to mas5_0_slpid_d'length-1),
            dout    => mas5_0_slpid_q(0   to mas5_0_slpid_q'length-1)    );
mas6_0_spid_latch:   tri_rlmreg_p
  generic map (width => mas6_0_spid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_0_spid_offset   to mas6_0_spid_offset+mas6_0_spid_q'length-1),
            scout   => sov_1(mas6_0_spid_offset   to mas6_0_spid_offset+mas6_0_spid_q'length-1),
            din     => mas6_0_spid_d(0   to mas6_0_spid_d'length-1),
            dout    => mas6_0_spid_q(0   to mas6_0_spid_q'length-1)    );
mas6_0_isize_latch:   tri_rlmreg_p
  generic map (width => mas6_0_isize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_0_isize_offset   to mas6_0_isize_offset+mas6_0_isize_q'length-1),
            scout   => sov_1(mas6_0_isize_offset   to mas6_0_isize_offset+mas6_0_isize_q'length-1),
            din     => mas6_0_isize_d(0   to mas6_0_isize_d'length-1),
            dout    => mas6_0_isize_q(0   to mas6_0_isize_q'length-1)    );
mas6_0_sind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_0_sind_offset),
            scout   => sov_1(mas6_0_sind_offset),
            din     => mas6_0_sind_d,
            dout    => mas6_0_sind_q);
mas6_0_sas_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_0_sas_offset),
            scout   => sov_1(mas6_0_sas_offset),
            din     => mas6_0_sas_d,
            dout    => mas6_0_sas_q);
mas7_0_rpnu_latch:   tri_rlmreg_p
  generic map (width => mas7_0_rpnu_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas7_0_rpnu_offset   to mas7_0_rpnu_offset+mas7_0_rpnu_q'length-1),
            scout   => sov_1(mas7_0_rpnu_offset   to mas7_0_rpnu_offset+mas7_0_rpnu_q'length-1),
            din     => mas7_0_rpnu_d(22   to 22+mas7_0_rpnu_d'length-1),
            dout    => mas7_0_rpnu_q(22   to 22+mas7_0_rpnu_q'length-1)    );
mas8_0_tgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_0_tgs_offset),
            scout   => sov_1(mas8_0_tgs_offset),
            din     => mas8_0_tgs_d,
            dout    => mas8_0_tgs_q);
mas8_0_vf_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_0_vf_offset),
            scout   => sov_1(mas8_0_vf_offset),
            din     => mas8_0_vf_d,
            dout    => mas8_0_vf_q);
mas8_0_tlpid_latch:   tri_rlmreg_p
  generic map (width => mas8_0_tlpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_0_tlpid_offset   to mas8_0_tlpid_offset+mas8_0_tlpid_q'length-1),
            scout   => sov_1(mas8_0_tlpid_offset   to mas8_0_tlpid_offset+mas8_0_tlpid_q'length-1),
            din     => mas8_0_tlpid_d(0   to mas8_0_tlpid_d'length-1),
            dout    => mas8_0_tlpid_q(0   to mas8_0_tlpid_q'length-1)    );
mas0_1_atsel_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_1_atsel_offset),
            scout   => sov_1(mas0_1_atsel_offset),
            din     => mas0_1_atsel_d,
            dout    => mas0_1_atsel_q);
mas0_1_esel_latch:   tri_rlmreg_p
  generic map (width => mas0_1_esel_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_1_esel_offset   to mas0_1_esel_offset+mas0_1_esel_q'length-1),
            scout   => sov_1(mas0_1_esel_offset   to mas0_1_esel_offset+mas0_1_esel_q'length-1),
            din     => mas0_1_esel_d(0   to mas0_1_esel_d'length-1),
            dout    => mas0_1_esel_q(0   to mas0_1_esel_q'length-1)    );
mas0_1_hes_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_1_hes_offset),
            scout   => sov_1(mas0_1_hes_offset),
            din     => mas0_1_hes_d,
            dout    => mas0_1_hes_q);
mas0_1_wq_latch:   tri_rlmreg_p
  generic map (width => mas0_1_wq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_1_wq_offset   to mas0_1_wq_offset+mas0_1_wq_q'length-1),
            scout   => sov_1(mas0_1_wq_offset   to mas0_1_wq_offset+mas0_1_wq_q'length-1),
            din     => mas0_1_wq_d(0   to mas0_1_wq_d'length-1),
            dout    => mas0_1_wq_q(0   to mas0_1_wq_q'length-1)    );
mas1_1_v_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_1_v_offset),
            scout   => sov_1(mas1_1_v_offset),
            din     => mas1_1_v_d,
            dout    => mas1_1_v_q);
mas1_1_iprot_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_1_iprot_offset),
            scout   => sov_1(mas1_1_iprot_offset),
            din     => mas1_1_iprot_d,
            dout    => mas1_1_iprot_q);
mas1_1_tid_latch:   tri_rlmreg_p
  generic map (width => mas1_1_tid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_1_tid_offset   to mas1_1_tid_offset+mas1_1_tid_q'length-1),
            scout   => sov_1(mas1_1_tid_offset   to mas1_1_tid_offset+mas1_1_tid_q'length-1),
            din     => mas1_1_tid_d(0   to mas1_1_tid_d'length-1),
            dout    => mas1_1_tid_q(0   to mas1_1_tid_q'length-1)    );
mas1_1_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_1_ind_offset),
            scout   => sov_1(mas1_1_ind_offset),
            din     => mas1_1_ind_d,
            dout    => mas1_1_ind_q);
mas1_1_ts_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_1_ts_offset),
            scout   => sov_1(mas1_1_ts_offset),
            din     => mas1_1_ts_d,
            dout    => mas1_1_ts_q);
mas1_1_tsize_latch:   tri_rlmreg_p
  generic map (width => mas1_1_tsize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_1_tsize_offset   to mas1_1_tsize_offset+mas1_1_tsize_q'length-1),
            scout   => sov_1(mas1_1_tsize_offset   to mas1_1_tsize_offset+mas1_1_tsize_q'length-1),
            din     => mas1_1_tsize_d(0   to mas1_1_tsize_d'length-1),
            dout    => mas1_1_tsize_q(0   to mas1_1_tsize_q'length-1)    );
mas2_1_epn_latch:   tri_rlmreg_p
  generic map (width => mas2_1_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_1_epn_offset   to mas2_1_epn_offset+mas2_1_epn_q'length-1),
            scout   => sov_1(mas2_1_epn_offset   to mas2_1_epn_offset+mas2_1_epn_q'length-1),
            din     => mas2_1_epn_d(52-mas2_1_epn_d'length   to 51),
            dout    => mas2_1_epn_q(52-mas2_1_epn_q'length   to 51)  );
mas2_1_wimge_latch:   tri_rlmreg_p
  generic map (width => mas2_1_wimge_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_1_wimge_offset   to mas2_1_wimge_offset+mas2_1_wimge_q'length-1),
            scout   => sov_1(mas2_1_wimge_offset   to mas2_1_wimge_offset+mas2_1_wimge_q'length-1),
            din     => mas2_1_wimge_d(0   to mas2_1_wimge_d'length-1),
            dout    => mas2_1_wimge_q(0   to mas2_1_wimge_q'length-1)    );
mas3_1_rpnl_latch:   tri_rlmreg_p
  generic map (width => mas3_1_rpnl_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_1_rpnl_offset   to mas3_1_rpnl_offset+mas3_1_rpnl_q'length-1),
            scout   => sov_1(mas3_1_rpnl_offset   to mas3_1_rpnl_offset+mas3_1_rpnl_q'length-1),
            din     => mas3_1_rpnl_d(32   to 32+mas3_1_rpnl_d'length-1),
            dout    => mas3_1_rpnl_q(32   to 32+mas3_1_rpnl_q'length-1)    );
mas3_1_ubits_latch:   tri_rlmreg_p
  generic map (width => mas3_1_ubits_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_1_ubits_offset   to mas3_1_ubits_offset+mas3_1_ubits_q'length-1),
            scout   => sov_1(mas3_1_ubits_offset   to mas3_1_ubits_offset+mas3_1_ubits_q'length-1),
            din     => mas3_1_ubits_d(0   to mas3_1_ubits_d'length-1),
            dout    => mas3_1_ubits_q(0   to mas3_1_ubits_q'length-1)    );
mas3_1_usxwr_latch:   tri_rlmreg_p
  generic map (width => mas3_1_usxwr_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_1_usxwr_offset   to mas3_1_usxwr_offset+mas3_1_usxwr_q'length-1),
            scout   => sov_1(mas3_1_usxwr_offset   to mas3_1_usxwr_offset+mas3_1_usxwr_q'length-1),
            din     => mas3_1_usxwr_d(0   to mas3_1_usxwr_d'length-1),
            dout    => mas3_1_usxwr_q(0   to mas3_1_usxwr_q'length-1)    );
mas4_1_indd_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_1_indd_offset),
            scout   => bsov(mas4_1_indd_offset),
            din     => mas4_1_indd_d,
            dout    => mas4_1_indd_q);
mas4_1_tsized_latch:   tri_rlmreg_p
  generic map (width => mas4_1_tsized_q'length,   init => 1, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_1_tsized_offset   to mas4_1_tsized_offset+mas4_1_tsized_q'length-1),
            scout   => bsov(mas4_1_tsized_offset   to mas4_1_tsized_offset+mas4_1_tsized_q'length-1),
            din     => mas4_1_tsized_d(0   to mas4_1_tsized_d'length-1),
            dout    => mas4_1_tsized_q(0   to mas4_1_tsized_q'length-1)    );
mas4_1_wimged_latch:   tri_rlmreg_p
  generic map (width => mas4_1_wimged_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_1_wimged_offset   to mas4_1_wimged_offset+mas4_1_wimged_q'length-1),
            scout   => bsov(mas4_1_wimged_offset   to mas4_1_wimged_offset+mas4_1_wimged_q'length-1),
            din     => mas4_1_wimged_d(0   to mas4_1_wimged_d'length-1),
            dout    => mas4_1_wimged_q(0   to mas4_1_wimged_q'length-1)    );
mas5_1_sgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_1_sgs_offset),
            scout   => sov_1(mas5_1_sgs_offset),
            din     => mas5_1_sgs_d,
            dout    => mas5_1_sgs_q);
mas5_1_slpid_latch:   tri_rlmreg_p
  generic map (width => mas5_1_slpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_1_slpid_offset   to mas5_1_slpid_offset+mas5_1_slpid_q'length-1),
            scout   => sov_1(mas5_1_slpid_offset   to mas5_1_slpid_offset+mas5_1_slpid_q'length-1),
            din     => mas5_1_slpid_d(0   to mas5_1_slpid_d'length-1),
            dout    => mas5_1_slpid_q(0   to mas5_1_slpid_q'length-1)    );
mas6_1_spid_latch:   tri_rlmreg_p
  generic map (width => mas6_1_spid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_1_spid_offset   to mas6_1_spid_offset+mas6_1_spid_q'length-1),
            scout   => sov_1(mas6_1_spid_offset   to mas6_1_spid_offset+mas6_1_spid_q'length-1),
            din     => mas6_1_spid_d(0   to mas6_1_spid_d'length-1),
            dout    => mas6_1_spid_q(0   to mas6_1_spid_q'length-1)    );
mas6_1_isize_latch:   tri_rlmreg_p
  generic map (width => mas6_1_isize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_1_isize_offset   to mas6_1_isize_offset+mas6_1_isize_q'length-1),
            scout   => sov_1(mas6_1_isize_offset   to mas6_1_isize_offset+mas6_1_isize_q'length-1),
            din     => mas6_1_isize_d(0   to mas6_1_isize_d'length-1),
            dout    => mas6_1_isize_q(0   to mas6_1_isize_q'length-1)    );
mas6_1_sind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_1_sind_offset),
            scout   => sov_1(mas6_1_sind_offset),
            din     => mas6_1_sind_d,
            dout    => mas6_1_sind_q);
mas6_1_sas_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_1_sas_offset),
            scout   => sov_1(mas6_1_sas_offset),
            din     => mas6_1_sas_d,
            dout    => mas6_1_sas_q);
mas7_1_rpnu_latch:   tri_rlmreg_p
  generic map (width => mas7_1_rpnu_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas7_1_rpnu_offset   to mas7_1_rpnu_offset+mas7_1_rpnu_q'length-1),
            scout   => sov_1(mas7_1_rpnu_offset   to mas7_1_rpnu_offset+mas7_1_rpnu_q'length-1),
            din     => mas7_1_rpnu_d(22   to 22+mas7_1_rpnu_d'length-1),
            dout    => mas7_1_rpnu_q(22   to 22+mas7_1_rpnu_q'length-1)    );
mas8_1_tgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_1_tgs_offset),
            scout   => sov_1(mas8_1_tgs_offset),
            din     => mas8_1_tgs_d,
            dout    => mas8_1_tgs_q);
mas8_1_vf_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_1_vf_offset),
            scout   => sov_1(mas8_1_vf_offset),
            din     => mas8_1_vf_d,
            dout    => mas8_1_vf_q);
mas8_1_tlpid_latch:   tri_rlmreg_p
  generic map (width => mas8_1_tlpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_1_tlpid_offset   to mas8_1_tlpid_offset+mas8_1_tlpid_q'length-1),
            scout   => sov_1(mas8_1_tlpid_offset   to mas8_1_tlpid_offset+mas8_1_tlpid_q'length-1),
            din     => mas8_1_tlpid_d(0   to mas8_1_tlpid_d'length-1),
            dout    => mas8_1_tlpid_q(0   to mas8_1_tlpid_q'length-1)    );
mas0_2_atsel_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_2_atsel_offset),
            scout   => sov_1(mas0_2_atsel_offset),
            din     => mas0_2_atsel_d,
            dout    => mas0_2_atsel_q);
mas0_2_esel_latch:   tri_rlmreg_p
  generic map (width => mas0_2_esel_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_2_esel_offset   to mas0_2_esel_offset+mas0_2_esel_q'length-1),
            scout   => sov_1(mas0_2_esel_offset   to mas0_2_esel_offset+mas0_2_esel_q'length-1),
            din     => mas0_2_esel_d(0   to mas0_2_esel_d'length-1),
            dout    => mas0_2_esel_q(0   to mas0_2_esel_q'length-1)    );
mas0_2_hes_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_2_hes_offset),
            scout   => sov_1(mas0_2_hes_offset),
            din     => mas0_2_hes_d,
            dout    => mas0_2_hes_q);
mas0_2_wq_latch:   tri_rlmreg_p
  generic map (width => mas0_2_wq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_2_wq_offset   to mas0_2_wq_offset+mas0_2_wq_q'length-1),
            scout   => sov_1(mas0_2_wq_offset   to mas0_2_wq_offset+mas0_2_wq_q'length-1),
            din     => mas0_2_wq_d(0   to mas0_2_wq_d'length-1),
            dout    => mas0_2_wq_q(0   to mas0_2_wq_q'length-1)    );
mas1_2_v_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_2_v_offset),
            scout   => sov_1(mas1_2_v_offset),
            din     => mas1_2_v_d,
            dout    => mas1_2_v_q);
mas1_2_iprot_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_2_iprot_offset),
            scout   => sov_1(mas1_2_iprot_offset),
            din     => mas1_2_iprot_d,
            dout    => mas1_2_iprot_q);
mas1_2_tid_latch:   tri_rlmreg_p
  generic map (width => mas1_2_tid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_2_tid_offset   to mas1_2_tid_offset+mas1_2_tid_q'length-1),
            scout   => sov_1(mas1_2_tid_offset   to mas1_2_tid_offset+mas1_2_tid_q'length-1),
            din     => mas1_2_tid_d(0   to mas1_2_tid_d'length-1),
            dout    => mas1_2_tid_q(0   to mas1_2_tid_q'length-1)    );
mas1_2_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_2_ind_offset),
            scout   => sov_1(mas1_2_ind_offset),
            din     => mas1_2_ind_d,
            dout    => mas1_2_ind_q);
mas1_2_ts_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_2_ts_offset),
            scout   => sov_1(mas1_2_ts_offset),
            din     => mas1_2_ts_d,
            dout    => mas1_2_ts_q);
mas1_2_tsize_latch:   tri_rlmreg_p
  generic map (width => mas1_2_tsize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_2_tsize_offset   to mas1_2_tsize_offset+mas1_2_tsize_q'length-1),
            scout   => sov_1(mas1_2_tsize_offset   to mas1_2_tsize_offset+mas1_2_tsize_q'length-1),
            din     => mas1_2_tsize_d(0   to mas1_2_tsize_d'length-1),
            dout    => mas1_2_tsize_q(0   to mas1_2_tsize_q'length-1)    );
mas2_2_epn_latch:   tri_rlmreg_p
  generic map (width => mas2_2_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_2_epn_offset   to mas2_2_epn_offset+mas2_2_epn_q'length-1),
            scout   => sov_1(mas2_2_epn_offset   to mas2_2_epn_offset+mas2_2_epn_q'length-1),
            din     => mas2_2_epn_d(52-mas2_2_epn_d'length   to 51),
            dout    => mas2_2_epn_q(52-mas2_2_epn_q'length   to 51)  );
mas2_2_wimge_latch:   tri_rlmreg_p
  generic map (width => mas2_2_wimge_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_2_wimge_offset   to mas2_2_wimge_offset+mas2_2_wimge_q'length-1),
            scout   => sov_1(mas2_2_wimge_offset   to mas2_2_wimge_offset+mas2_2_wimge_q'length-1),
            din     => mas2_2_wimge_d(0   to mas2_2_wimge_d'length-1),
            dout    => mas2_2_wimge_q(0   to mas2_2_wimge_q'length-1)    );
mas3_2_rpnl_latch:   tri_rlmreg_p
  generic map (width => mas3_2_rpnl_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_2_rpnl_offset   to mas3_2_rpnl_offset+mas3_2_rpnl_q'length-1),
            scout   => sov_1(mas3_2_rpnl_offset   to mas3_2_rpnl_offset+mas3_2_rpnl_q'length-1),
            din     => mas3_2_rpnl_d(32   to 32+mas3_2_rpnl_d'length-1),
            dout    => mas3_2_rpnl_q(32   to 32+mas3_2_rpnl_q'length-1)    );
mas3_2_ubits_latch:   tri_rlmreg_p
  generic map (width => mas3_2_ubits_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_2_ubits_offset   to mas3_2_ubits_offset+mas3_2_ubits_q'length-1),
            scout   => sov_1(mas3_2_ubits_offset   to mas3_2_ubits_offset+mas3_2_ubits_q'length-1),
            din     => mas3_2_ubits_d(0   to mas3_2_ubits_d'length-1),
            dout    => mas3_2_ubits_q(0   to mas3_2_ubits_q'length-1)    );
mas3_2_usxwr_latch:   tri_rlmreg_p
  generic map (width => mas3_2_usxwr_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_2_usxwr_offset   to mas3_2_usxwr_offset+mas3_2_usxwr_q'length-1),
            scout   => sov_1(mas3_2_usxwr_offset   to mas3_2_usxwr_offset+mas3_2_usxwr_q'length-1),
            din     => mas3_2_usxwr_d(0   to mas3_2_usxwr_d'length-1),
            dout    => mas3_2_usxwr_q(0   to mas3_2_usxwr_q'length-1)    );
mas4_2_indd_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_2_indd_offset),
            scout   => bsov(mas4_2_indd_offset),
            din     => mas4_2_indd_d,
            dout    => mas4_2_indd_q);
mas4_2_tsized_latch:   tri_rlmreg_p
  generic map (width => mas4_2_tsized_q'length,   init => 1, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_2_tsized_offset   to mas4_2_tsized_offset+mas4_2_tsized_q'length-1),
            scout   => bsov(mas4_2_tsized_offset   to mas4_2_tsized_offset+mas4_2_tsized_q'length-1),
            din     => mas4_2_tsized_d(0   to mas4_2_tsized_d'length-1),
            dout    => mas4_2_tsized_q(0   to mas4_2_tsized_q'length-1)    );
mas4_2_wimged_latch:   tri_rlmreg_p
  generic map (width => mas4_2_wimged_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_2_wimged_offset   to mas4_2_wimged_offset+mas4_2_wimged_q'length-1),
            scout   => bsov(mas4_2_wimged_offset   to mas4_2_wimged_offset+mas4_2_wimged_q'length-1),
            din     => mas4_2_wimged_d(0   to mas4_2_wimged_d'length-1),
            dout    => mas4_2_wimged_q(0   to mas4_2_wimged_q'length-1)    );
mas5_2_sgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_2_sgs_offset),
            scout   => sov_1(mas5_2_sgs_offset),
            din     => mas5_2_sgs_d,
            dout    => mas5_2_sgs_q);
mas5_2_slpid_latch:   tri_rlmreg_p
  generic map (width => mas5_2_slpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_2_slpid_offset   to mas5_2_slpid_offset+mas5_2_slpid_q'length-1),
            scout   => sov_1(mas5_2_slpid_offset   to mas5_2_slpid_offset+mas5_2_slpid_q'length-1),
            din     => mas5_2_slpid_d(0   to mas5_2_slpid_d'length-1),
            dout    => mas5_2_slpid_q(0   to mas5_2_slpid_q'length-1)    );
mas6_2_spid_latch:   tri_rlmreg_p
  generic map (width => mas6_2_spid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_2_spid_offset   to mas6_2_spid_offset+mas6_2_spid_q'length-1),
            scout   => sov_1(mas6_2_spid_offset   to mas6_2_spid_offset+mas6_2_spid_q'length-1),
            din     => mas6_2_spid_d(0   to mas6_2_spid_d'length-1),
            dout    => mas6_2_spid_q(0   to mas6_2_spid_q'length-1)    );
mas6_2_isize_latch:   tri_rlmreg_p
  generic map (width => mas6_2_isize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_2_isize_offset   to mas6_2_isize_offset+mas6_2_isize_q'length-1),
            scout   => sov_1(mas6_2_isize_offset   to mas6_2_isize_offset+mas6_2_isize_q'length-1),
            din     => mas6_2_isize_d(0   to mas6_2_isize_d'length-1),
            dout    => mas6_2_isize_q(0   to mas6_2_isize_q'length-1)    );
mas6_2_sind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_2_sind_offset),
            scout   => sov_1(mas6_2_sind_offset),
            din     => mas6_2_sind_d,
            dout    => mas6_2_sind_q);
mas6_2_sas_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_2_sas_offset),
            scout   => sov_1(mas6_2_sas_offset),
            din     => mas6_2_sas_d,
            dout    => mas6_2_sas_q);
mas7_2_rpnu_latch:   tri_rlmreg_p
  generic map (width => mas7_2_rpnu_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas7_2_rpnu_offset   to mas7_2_rpnu_offset+mas7_2_rpnu_q'length-1),
            scout   => sov_1(mas7_2_rpnu_offset   to mas7_2_rpnu_offset+mas7_2_rpnu_q'length-1),
            din     => mas7_2_rpnu_d(22   to 22+mas7_2_rpnu_d'length-1),
            dout    => mas7_2_rpnu_q(22   to 22+mas7_2_rpnu_q'length-1)    );
mas8_2_tgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_2_tgs_offset),
            scout   => sov_1(mas8_2_tgs_offset),
            din     => mas8_2_tgs_d,
            dout    => mas8_2_tgs_q);
mas8_2_vf_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_2_vf_offset),
            scout   => sov_1(mas8_2_vf_offset),
            din     => mas8_2_vf_d,
            dout    => mas8_2_vf_q);
mas8_2_tlpid_latch:   tri_rlmreg_p
  generic map (width => mas8_2_tlpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_2_tlpid_offset   to mas8_2_tlpid_offset+mas8_2_tlpid_q'length-1),
            scout   => sov_1(mas8_2_tlpid_offset   to mas8_2_tlpid_offset+mas8_2_tlpid_q'length-1),
            din     => mas8_2_tlpid_d(0   to mas8_2_tlpid_d'length-1),
            dout    => mas8_2_tlpid_q(0   to mas8_2_tlpid_q'length-1)    );
mas0_3_atsel_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_3_atsel_offset),
            scout   => sov_1(mas0_3_atsel_offset),
            din     => mas0_3_atsel_d,
            dout    => mas0_3_atsel_q);
mas0_3_esel_latch:   tri_rlmreg_p
  generic map (width => mas0_3_esel_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_3_esel_offset   to mas0_3_esel_offset+mas0_3_esel_q'length-1),
            scout   => sov_1(mas0_3_esel_offset   to mas0_3_esel_offset+mas0_3_esel_q'length-1),
            din     => mas0_3_esel_d(0   to mas0_3_esel_d'length-1),
            dout    => mas0_3_esel_q(0   to mas0_3_esel_q'length-1)    );
mas0_3_hes_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_3_hes_offset),
            scout   => sov_1(mas0_3_hes_offset),
            din     => mas0_3_hes_d,
            dout    => mas0_3_hes_q);
mas0_3_wq_latch:   tri_rlmreg_p
  generic map (width => mas0_3_wq_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas0_3_wq_offset   to mas0_3_wq_offset+mas0_3_wq_q'length-1),
            scout   => sov_1(mas0_3_wq_offset   to mas0_3_wq_offset+mas0_3_wq_q'length-1),
            din     => mas0_3_wq_d(0   to mas0_3_wq_d'length-1),
            dout    => mas0_3_wq_q(0   to mas0_3_wq_q'length-1)    );
mas1_3_v_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_3_v_offset),
            scout   => sov_1(mas1_3_v_offset),
            din     => mas1_3_v_d,
            dout    => mas1_3_v_q);
mas1_3_iprot_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_3_iprot_offset),
            scout   => sov_1(mas1_3_iprot_offset),
            din     => mas1_3_iprot_d,
            dout    => mas1_3_iprot_q);
mas1_3_tid_latch:   tri_rlmreg_p
  generic map (width => mas1_3_tid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_3_tid_offset   to mas1_3_tid_offset+mas1_3_tid_q'length-1),
            scout   => sov_1(mas1_3_tid_offset   to mas1_3_tid_offset+mas1_3_tid_q'length-1),
            din     => mas1_3_tid_d(0   to mas1_3_tid_d'length-1),
            dout    => mas1_3_tid_q(0   to mas1_3_tid_q'length-1)    );
mas1_3_ind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_3_ind_offset),
            scout   => sov_1(mas1_3_ind_offset),
            din     => mas1_3_ind_d,
            dout    => mas1_3_ind_q);
mas1_3_ts_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_3_ts_offset),
            scout   => sov_1(mas1_3_ts_offset),
            din     => mas1_3_ts_d,
            dout    => mas1_3_ts_q);
mas1_3_tsize_latch:   tri_rlmreg_p
  generic map (width => mas1_3_tsize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas1_3_tsize_offset   to mas1_3_tsize_offset+mas1_3_tsize_q'length-1),
            scout   => sov_1(mas1_3_tsize_offset   to mas1_3_tsize_offset+mas1_3_tsize_q'length-1),
            din     => mas1_3_tsize_d(0   to mas1_3_tsize_d'length-1),
            dout    => mas1_3_tsize_q(0   to mas1_3_tsize_q'length-1)    );
mas2_3_epn_latch:   tri_rlmreg_p
  generic map (width => mas2_3_epn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_3_epn_offset   to mas2_3_epn_offset+mas2_3_epn_q'length-1),
            scout   => sov_1(mas2_3_epn_offset   to mas2_3_epn_offset+mas2_3_epn_q'length-1),
            din     => mas2_3_epn_d(52-mas2_3_epn_d'length   to 51),
            dout    => mas2_3_epn_q(52-mas2_3_epn_q'length   to 51)  );
mas2_3_wimge_latch:   tri_rlmreg_p
  generic map (width => mas2_3_wimge_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas2_3_wimge_offset   to mas2_3_wimge_offset+mas2_3_wimge_q'length-1),
            scout   => sov_1(mas2_3_wimge_offset   to mas2_3_wimge_offset+mas2_3_wimge_q'length-1),
            din     => mas2_3_wimge_d(0   to mas2_3_wimge_d'length-1),
            dout    => mas2_3_wimge_q(0   to mas2_3_wimge_q'length-1)    );
mas3_3_rpnl_latch:   tri_rlmreg_p
  generic map (width => mas3_3_rpnl_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_3_rpnl_offset   to mas3_3_rpnl_offset+mas3_3_rpnl_q'length-1),
            scout   => sov_1(mas3_3_rpnl_offset   to mas3_3_rpnl_offset+mas3_3_rpnl_q'length-1),
            din     => mas3_3_rpnl_d(32   to 32+mas3_3_rpnl_d'length-1),
            dout    => mas3_3_rpnl_q(32   to 32+mas3_3_rpnl_q'length-1)    );
mas3_3_ubits_latch:   tri_rlmreg_p
  generic map (width => mas3_3_ubits_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_3_ubits_offset   to mas3_3_ubits_offset+mas3_3_ubits_q'length-1),
            scout   => sov_1(mas3_3_ubits_offset   to mas3_3_ubits_offset+mas3_3_ubits_q'length-1),
            din     => mas3_3_ubits_d(0   to mas3_3_ubits_d'length-1),
            dout    => mas3_3_ubits_q(0   to mas3_3_ubits_q'length-1)    );
mas3_3_usxwr_latch:   tri_rlmreg_p
  generic map (width => mas3_3_usxwr_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas3_3_usxwr_offset   to mas3_3_usxwr_offset+mas3_3_usxwr_q'length-1),
            scout   => sov_1(mas3_3_usxwr_offset   to mas3_3_usxwr_offset+mas3_3_usxwr_q'length-1),
            din     => mas3_3_usxwr_d(0   to mas3_3_usxwr_d'length-1),
            dout    => mas3_3_usxwr_q(0   to mas3_3_usxwr_q'length-1)    );
mas4_3_indd_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_3_indd_offset),
            scout   => bsov(mas4_3_indd_offset),
            din     => mas4_3_indd_d,
            dout    => mas4_3_indd_q);
mas4_3_tsized_latch:   tri_rlmreg_p
  generic map (width => mas4_3_tsized_q'length,   init => 1, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_3_tsized_offset   to mas4_3_tsized_offset+mas4_3_tsized_q'length-1),
            scout   => bsov(mas4_3_tsized_offset   to mas4_3_tsized_offset+mas4_3_tsized_q'length-1),
            din     => mas4_3_tsized_d(0   to mas4_3_tsized_d'length-1),
            dout    => mas4_3_tsized_q(0   to mas4_3_tsized_q'length-1)    );
mas4_3_wimged_latch:   tri_rlmreg_p
  generic map (width => mas4_3_wimged_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mas4_3_wimged_offset   to mas4_3_wimged_offset+mas4_3_wimged_q'length-1),
            scout   => bsov(mas4_3_wimged_offset   to mas4_3_wimged_offset+mas4_3_wimged_q'length-1),
            din     => mas4_3_wimged_d(0   to mas4_3_wimged_d'length-1),
            dout    => mas4_3_wimged_q(0   to mas4_3_wimged_q'length-1)    );
mas5_3_sgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_3_sgs_offset),
            scout   => sov_1(mas5_3_sgs_offset),
            din     => mas5_3_sgs_d,
            dout    => mas5_3_sgs_q);
mas5_3_slpid_latch:   tri_rlmreg_p
  generic map (width => mas5_3_slpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas5_3_slpid_offset   to mas5_3_slpid_offset+mas5_3_slpid_q'length-1),
            scout   => sov_1(mas5_3_slpid_offset   to mas5_3_slpid_offset+mas5_3_slpid_q'length-1),
            din     => mas5_3_slpid_d(0   to mas5_3_slpid_d'length-1),
            dout    => mas5_3_slpid_q(0   to mas5_3_slpid_q'length-1)    );
mas6_3_spid_latch:   tri_rlmreg_p
  generic map (width => mas6_3_spid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_3_spid_offset   to mas6_3_spid_offset+mas6_3_spid_q'length-1),
            scout   => sov_1(mas6_3_spid_offset   to mas6_3_spid_offset+mas6_3_spid_q'length-1),
            din     => mas6_3_spid_d(0   to mas6_3_spid_d'length-1),
            dout    => mas6_3_spid_q(0   to mas6_3_spid_q'length-1)    );
mas6_3_isize_latch:   tri_rlmreg_p
  generic map (width => mas6_3_isize_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_3_isize_offset   to mas6_3_isize_offset+mas6_3_isize_q'length-1),
            scout   => sov_1(mas6_3_isize_offset   to mas6_3_isize_offset+mas6_3_isize_q'length-1),
            din     => mas6_3_isize_d(0   to mas6_3_isize_d'length-1),
            dout    => mas6_3_isize_q(0   to mas6_3_isize_q'length-1)    );
mas6_3_sind_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_3_sind_offset),
            scout   => sov_1(mas6_3_sind_offset),
            din     => mas6_3_sind_d,
            dout    => mas6_3_sind_q);
mas6_3_sas_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas6_3_sas_offset),
            scout   => sov_1(mas6_3_sas_offset),
            din     => mas6_3_sas_d,
            dout    => mas6_3_sas_q);
mas7_3_rpnu_latch:   tri_rlmreg_p
  generic map (width => mas7_3_rpnu_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas7_3_rpnu_offset   to mas7_3_rpnu_offset+mas7_3_rpnu_q'length-1),
            scout   => sov_1(mas7_3_rpnu_offset   to mas7_3_rpnu_offset+mas7_3_rpnu_q'length-1),
            din     => mas7_3_rpnu_d(22   to 22+mas7_3_rpnu_d'length-1),
            dout    => mas7_3_rpnu_q(22   to 22+mas7_3_rpnu_q'length-1)    );
mas8_3_tgs_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_3_tgs_offset),
            scout   => sov_1(mas8_3_tgs_offset),
            din     => mas8_3_tgs_d,
            dout    => mas8_3_tgs_q);
mas8_3_vf_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_3_vf_offset),
            scout   => sov_1(mas8_3_vf_offset),
            din     => mas8_3_vf_d,
            dout    => mas8_3_vf_q);
mas8_3_tlpid_latch:   tri_rlmreg_p
  generic map (width => mas8_3_tlpid_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mas8_3_tlpid_offset   to mas8_3_tlpid_offset+mas8_3_tlpid_q'length-1),
            scout   => sov_1(mas8_3_tlpid_offset   to mas8_3_tlpid_offset+mas8_3_tlpid_q'length-1),
            din     => mas8_3_tlpid_d(0   to mas8_3_tlpid_d'length-1),
            dout    => mas8_3_tlpid_q(0   to mas8_3_tlpid_q'length-1)    );
mmucsr0_tlb0fi_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(mmucsr0_tlb0fi_offset),
            scout   => sov_1(mmucsr0_tlb0fi_offset),
            din     => mmucsr0_tlb0fi_d,
            dout    => mmucsr0_tlb0fi_q);
lper_0_alpn_latch:   tri_rlmreg_p
  generic map (width => lper_0_alpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_0_alpn_offset   to lper_0_alpn_offset+lper_0_alpn_q'length-1),
            scout   => sov_1(lper_0_alpn_offset   to lper_0_alpn_offset+lper_0_alpn_q'length-1),
            din     => lper_0_alpn_d,
            dout    => lper_0_alpn_q    );
lper_0_lps_latch:   tri_rlmreg_p
  generic map (width => lper_0_lps_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(0),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_0_lps_offset   to lper_0_lps_offset+lper_0_lps_q'length-1),
            scout   => sov_1(lper_0_lps_offset   to lper_0_lps_offset+lper_0_lps_q'length-1),
            din     => lper_0_lps_d,
            dout    => lper_0_lps_q    );
lper_1_alpn_latch:   tri_rlmreg_p
  generic map (width => lper_1_alpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_1_alpn_offset   to lper_1_alpn_offset+lper_1_alpn_q'length-1),
            scout   => sov_1(lper_1_alpn_offset   to lper_1_alpn_offset+lper_1_alpn_q'length-1),
            din     => lper_1_alpn_d,
            dout    => lper_1_alpn_q    );
lper_1_lps_latch:   tri_rlmreg_p
  generic map (width => lper_1_lps_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(1),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_1_lps_offset   to lper_1_lps_offset+lper_1_lps_q'length-1),
            scout   => sov_1(lper_1_lps_offset   to lper_1_lps_offset+lper_1_lps_q'length-1),
            din     => lper_1_lps_d,
            dout    => lper_1_lps_q    );
lper_2_alpn_latch:   tri_rlmreg_p
  generic map (width => lper_2_alpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_2_alpn_offset   to lper_2_alpn_offset+lper_2_alpn_q'length-1),
            scout   => sov_1(lper_2_alpn_offset   to lper_2_alpn_offset+lper_2_alpn_q'length-1),
            din     => lper_2_alpn_d,
            dout    => lper_2_alpn_q    );
lper_2_lps_latch:   tri_rlmreg_p
  generic map (width => lper_2_lps_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(2),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_2_lps_offset   to lper_2_lps_offset+lper_2_lps_q'length-1),
            scout   => sov_1(lper_2_lps_offset   to lper_2_lps_offset+lper_2_lps_q'length-1),
            din     => lper_2_lps_d,
            dout    => lper_2_lps_q    );
lper_3_alpn_latch:   tri_rlmreg_p
  generic map (width => lper_3_alpn_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_3_alpn_offset   to lper_3_alpn_offset+lper_3_alpn_q'length-1),
            scout   => sov_1(lper_3_alpn_offset   to lper_3_alpn_offset+lper_3_alpn_q'length-1),
            din     => lper_3_alpn_d,
            dout    => lper_3_alpn_q    );
lper_3_lps_latch:   tri_rlmreg_p
  generic map (width => lper_3_lps_q'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => cat_emf_act_q(3),
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(lper_3_lps_offset   to lper_3_lps_offset+lper_3_lps_q'length-1),
            scout   => sov_1(lper_3_lps_offset   to lper_3_lps_offset+lper_3_lps_q'length-1),
            din     => lper_3_lps_d,
            dout    => lper_3_lps_q    );
spr_mmu_act_latch: tri_rlmreg_p
  generic map (width => spr_mmu_act_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_mmu_act_offset to spr_mmu_act_offset+spr_mmu_act_q'length-1),
            scout   => sov_0(spr_mmu_act_offset to spr_mmu_act_offset+spr_mmu_act_q'length-1),
            din     => spr_mmu_act_d,
            dout    => spr_mmu_act_q  );
spr_val_act_latch: tri_rlmreg_p
  generic map (width => spr_val_act_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spr_val_act_offset to spr_val_act_offset+spr_val_act_q'length-1),
            scout   => sov_0(spr_val_act_offset to spr_val_act_offset+spr_val_act_q'length-1),
            din     => spr_val_act_d,
            dout    => spr_val_act_q  );
cswitch_latch: tri_rlmreg_p
  generic map (width => cswitch_q'length, init => mmq_spr_cswitch_0to3, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(cswitch_offset to cswitch_offset+cswitch_q'length-1),
            scout   => sov_0(cswitch_offset to cswitch_offset+cswitch_q'length-1),
            din     => cswitch_q,
            dout    => cswitch_q  );
-- cswitch0: 1=disable side affect of clearing I/D/TERRDET and EEN when reading mmucr1
-- cswitch1: 1=disable mmucr1.tlbwe_binv bit (make it look like it is reserved per dd1)
-- cswitch2: reserved
-- cswitch3: reserved
cat_emf_act_latch: tri_rlmreg_p
  generic map (width => cat_emf_act_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(cat_emf_act_offset to cat_emf_act_offset+cat_emf_act_q'length-1),
            scout   => sov_1(cat_emf_act_offset to cat_emf_act_offset+cat_emf_act_q'length-1),
            din     => cat_emf_act_d,
            dout    => cat_emf_act_q  );
spare_a_latch: tri_rlmreg_p
  generic map (width => spare_a_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            scout   => sov_0(spare_a_offset to spare_a_offset+spare_a_q'length-1),
            din     => spare_a_q,
            dout    => spare_a_q  );
spare_b_latch: tri_rlmreg_p
  generic map (width => spare_b_q'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_func_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_func_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => siv_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            scout   => sov_1(spare_b_offset to spare_b_offset+spare_b_q'length-1),
            din     => spare_b_q,
            dout    => spare_b_q  );
-- non-scannable timing latches
iu_mm_ierat_mmucr0_latch : tri_regk
  generic map (width => iu_mm_ierat_mmucr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => iu_mm_ierat_mmucr0,
            dout    => iu_mm_ierat_mmucr0_q);
iu_mm_ierat_mmucr0_we_latch : tri_regk
  generic map (width => iu_mm_ierat_mmucr0_we_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => iu_mm_ierat_mmucr0_we,
            dout    => iu_mm_ierat_mmucr0_we_q);
iu_mm_ierat_mmucr1_latch : tri_regk
  generic map (width => iu_mm_ierat_mmucr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => iu_mm_ierat_mmucr1,
            dout    => iu_mm_ierat_mmucr1_q);
xu_mm_derat_mmucr0_latch : tri_regk
  generic map (width => xu_mm_derat_mmucr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => xu_mm_derat_mmucr0,
            dout    => xu_mm_derat_mmucr0_q);
xu_mm_derat_mmucr0_we_latch : tri_regk
  generic map (width => xu_mm_derat_mmucr0_we_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => xu_mm_derat_mmucr0_we,
            dout    => xu_mm_derat_mmucr0_we_q);
xu_mm_derat_mmucr1_latch : tri_regk
  generic map (width => xu_mm_derat_mmucr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din     => xu_mm_derat_mmucr1,
            dout    => xu_mm_derat_mmucr1_q);
mm_erat_mmucr1_we_latch : tri_regk
  generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => pc_func_slp_nsl_force,
            d_mode  => lcb_d_mode_dc, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b  => lcb_mpw1_dc_b(0), 
            mpw2_b  => lcb_mpw2_dc_b,
            thold_b => pc_func_slp_nsl_thold_0_b,
            din(0)     => iu_mm_ierat_mmucr1_we,
            din(1)     => xu_mm_derat_mmucr1_we,
            dout(0)    => iu_mm_ierat_mmucr1_we_q,
            dout(1)    => xu_mm_derat_mmucr1_we_q);
--------------------------------------------------
-- scan only latches for boot config
--  mmucr1, mmucr2, and mmucr3 also in boot config
--------------------------------------------------
mpg_bcfg_gen: if expand_type /= 1 generate
mmucfg_47to48_latch: tri_slat_scan
  generic map (width => 2, init => std_ulogic_vector( to_unsigned( bcfg_mmucfg_value, 2 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(mmucfg_offset to mmucfg_offset+1),
            scan_out   => bsov(mmucfg_offset to mmucfg_offset+1),
            q      => mmucfg_q(47 to 48),
            q_b    => mmucfg_q_b(47 to 48)  );
tlb0cfg_45to47_latch: tri_slat_scan
  generic map (width => 3, init => std_ulogic_vector( to_unsigned( bcfg_tlb0cfg_value, 3 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(tlb0cfg_offset to tlb0cfg_offset+2),
            scan_out   => bsov(tlb0cfg_offset to tlb0cfg_offset+2),
            q      => tlb0cfg_q(45 to 47),
            q_b    => tlb0cfg_q_b(45 to 47)  );
bcfg_spare_latch: tri_slat_scan
  generic map (width => 16, init => std_ulogic_vector( to_unsigned( 0, 16 ) ), 
               reset_inverts_scan => true, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            dclk    => lcb_dclk,
            lclk    => lcb_lclk,
            scan_in    => bsiv(bcfg_spare_offset to bcfg_spare_offset+bcfg_spare_q'length-1),
            scan_out   => bsov(bcfg_spare_offset to bcfg_spare_offset+bcfg_spare_q'length-1),
            q      => bcfg_spare_q,
            q_b    => bcfg_spare_q_b  );
end generate mpg_bcfg_gen;
fpga_bcfg_gen: if expand_type = 1 generate
mmucfg_47to48_latch: tri_rlmreg_p
  generic map (width => 2, init => bcfg_mmucfg_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(mmucfg_offset to mmucfg_offset+1),
            scout   => bsov(mmucfg_offset to mmucfg_offset+1),
            din     => mmucfg_q(47 to 48),
            dout    => mmucfg_q(47 to 48)  );
tlb0cfg_45to47_latch: tri_rlmreg_p
  generic map (width => 3, init => bcfg_tlb0cfg_value, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(tlb0cfg_offset to tlb0cfg_offset+2),
            scout   => bsov(tlb0cfg_offset to tlb0cfg_offset+2),
            din     => tlb0cfg_q(45 to 47),
            dout    => tlb0cfg_q(45 to 47)  );
bcfg_spare_latch: tri_rlmreg_p
  generic map (width => 16, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
              gd      => gnd, 
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_cfg_slp_sl_thold_0_b,
            sg      => pc_sg_0,
            forcee => pc_cfg_slp_sl_force,
            delay_lclkr => lcb_delay_lclkr_dc(0),
            mpw1_b      => lcb_mpw1_dc_b(0),
            mpw2_b      => lcb_mpw2_dc_b,
            d_mode      => lcb_d_mode_dc,
            scin    => bsiv(bcfg_spare_offset to bcfg_spare_offset+bcfg_spare_q'length-1),
            scout   => bsov(bcfg_spare_offset to bcfg_spare_offset+bcfg_spare_q'length-1),
            din     => bcfg_spare_q,
            dout    => bcfg_spare_q  );
end generate fpga_bcfg_gen;
-- Latch counts
-- 3319
-- spr_ctl_in_q   3
-- spr_etid_in_q  2
-- spr_addr_in_q  10
-- spr_data_in_q  64          79
-- spr_ctl_int_q   3
-- spr_etid_int_q  2
-- spr_addr_int_q  10
-- spr_data_int_q  64         79
-- spr_ctl_out_q   3
-- spr_etid_out_q  2
-- spr_addr_out_q  10
-- spr_data_out_q  64         79
-- lper_ 0:3 _alpn_q  30 x 4
-- lper_ 0:3 _lps_q    4 x 4  136
-- pid 0:3 _q       14 x 4
-- mmucr0_ 0:3 _q   20 x 4
-- mmucr1_q         32
-- mmucr2_q         32
-- mmucr3_ 0:3 _q   15 x 4
-- lpidr_q          8
-- mmucsr0_tlb0fi_q 1        269
-- mas0_<t>_atsel_q  1 x 4         : std_ulogic;
-- mas0_<t>_esel_q   3 x 4         : std_ulogic_vector(0 to 2);
-- mas0_<t>_hes_q    1 x 4             : std_ulogic;
-- mas0_<t>_wq_q     2 x 4               : std_ulogic_vector(0 to 1);
-- mas1_<t>_v_q      1 x 4                 : std_ulogic;
-- mas1_<t>_iprot_q  1 x 4       : std_ulogic;
-- mas1_<t>_tid_q   14 x 4             : std_ulogic_vector(0 to 13);
-- mas1_<t>_ind_q    1 x 4             : std_ulogic;
-- mas1_<t>_ts_q     1 x 4          : std_ulogic;
-- mas1_<t>_tsize_q  4 x 4         : std_ulogic_vector(0 to 3);
-- mas2_<t>_epn_q   52 x 4          : std_ulogic_vector(64-spr_data_width to 51);
-- mas2_<t>_wimge_q  5 x 4       : std_ulogic_vector(0 to 4);
-- mas3_<t>_rpnl_q  21 x 4         : std_ulogic_vector(32 to 52);
-- mas3_<t>_ubits_q  4 x 4       : std_ulogic_vector(0 to 3);
-- mas3_<t>_usxwr_q  6 x 4         : std_ulogic_vector(0 to 5);
-- mas4_<t>_indd_q   1 x 4           : std_ulogic;
-- mas4_<t>_tsized_q 4 x 4       : std_ulogic_vector(0 to 3);
-- mas4_<t>_wimged_q 5 x 4     : std_ulogic_vector(0 to 4);
-- mas5_<t>_sgs_q    1 x 4         : std_ulogic;
-- mas5_<t>_slpid_q  8 x 4       : std_ulogic_vector(0 to 7);
-- mas6_<t>_spid_q  14 x 4         : std_ulogic_vector(0 to 13);
-- mas6_<t>_isize_q  4 x 4       : std_ulogic_vector(0 to 3);
-- mas6_<t>_sind_q   1 x 4          : std_ulogic;
-- mas6_<t>_sas_q    1 x 4         : std_ulogic;
-- mas7_<t>_rpnu_q  10 x 4        : std_ulogic_vector(22 to 31);
-- mas8_<t>_tgs_q    1 x 4         : std_ulogic;
-- mas8_<t>_vf_q     1 x 4          : std_ulogic;
-- mas8_<t>_tlpid_q  8 x 4       : std_ulogic_vector(0 to 7);
--       subtotal  176 x 4 = 704
----------------------------------------------------------------
-- total                    1346
--------------------------------------------------
--------------------------------------------------
-- thold/sg latches
--------------------------------------------------
perv_2to1_reg: tri_plat
  generic map (width => 7, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
            din(0)      => pc_func_sl_thold_2,
            din(1)      => pc_func_slp_sl_thold_2,
            din(2)      => pc_cfg_sl_thold_2,
            din(3)      => pc_cfg_slp_sl_thold_2,
            din(4)      => pc_func_slp_nsl_thold_2,
            din(5)      => pc_sg_2,
            din(6)      => pc_fce_2,
            q(0)        => pc_func_sl_thold_1,
            q(1)        => pc_func_slp_sl_thold_1,
            q(2)        => pc_cfg_sl_thold_1,
            q(3)        => pc_cfg_slp_sl_thold_1,
            q(4)        => pc_func_slp_nsl_thold_1,
            q(5)        => pc_sg_1,
            q(6)        => pc_fce_1);
perv_1to0_reg: tri_plat
  generic map (width => 7, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ccflush_dc,
            din(0)      => pc_func_sl_thold_1,
            din(1)      => pc_func_slp_sl_thold_1,
            din(2)      => pc_cfg_sl_thold_1,
            din(3)      => pc_cfg_slp_sl_thold_1,
            din(4)      => pc_func_slp_nsl_thold_1,
            din(5)      => pc_sg_1,
            din(6)      => pc_fce_1,
            q(0)        => pc_func_sl_thold_0,
            q(1)        => pc_func_slp_sl_thold_0,
            q(2)        => pc_cfg_sl_thold_0,
            q(3)        => pc_cfg_slp_sl_thold_0,
            q(4)        => pc_func_slp_nsl_thold_0,
            q(5)        => pc_sg_0,
            q(6)        => pc_fce_0);
perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_func_sl_force,
            thold_b     => pc_func_sl_thold_0_b);
perv_lcbor_func_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_slp_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_func_slp_sl_force,
            thold_b     => pc_func_slp_sl_thold_0_b);
perv_lcbor_cfg_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_cfg_slp_sl_thold_0,
            sg          => pc_sg_0,
            act_dis     => lcb_act_dis_dc,
            forcee => pc_cfg_slp_sl_force,
            thold_b     => pc_cfg_slp_sl_thold_0_b);
perv_lcbor_func_slp_nsl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => lcb_clkoff_dc_b,
            thold       => pc_func_slp_nsl_thold_0,
            sg          => pc_fce_0,
            act_dis     => tidn,
            forcee => pc_func_slp_nsl_force,
            thold_b     => pc_func_slp_nsl_thold_0_b);
-- these terms in the absence of another lcbor component
--  that drives the thold_b and force into the bcfg_lcb for slat's
pc_cfg_sl_thold_0_b <= NOT pc_cfg_sl_thold_0;
pc_cfg_sl_force   <= pc_sg_0;
--------------------------------------------------
-- local clock buffer for boot config
--------------------------------------------------
bcfg_lcb: tri_lcbs
  generic map (expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd, 
            delay_lclkr => lcb_delay_lclkr_dc(0),
            nclk        => nclk,
            forcee => pc_cfg_sl_force,
            thold_b     => pc_cfg_sl_thold_0_b,
            dclk        => lcb_dclk,
            lclk        => lcb_lclk  );
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv_0(0 to scan_right_0) <= sov_0(1 to scan_right_0) & ac_func_scan_in(0);
ac_func_scan_out(0) <= sov_0(0);
siv_1(0 to scan_right_1) <= sov_1(1 to scan_right_1) & ac_func_scan_in(1);
ac_func_scan_out(1) <= sov_1(0);
bsiv(0 to boot_scan_right) <= bsov(1 to boot_scan_right) & ac_bcfg_scan_in;
ac_bcfg_scan_out <= bsov(0);
end mmq_spr;
