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

--
--  Description: Pervasive Core Thread Controls
--
--*****************************************************************************

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

entity pcq_ctrl is
generic(expand_type             : integer := 2          -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
);         
port(
    vdd                         : inout power_logic;
    gnd                         : inout power_logic;
    nclk                        : in    clk_logic;
    scan_dis_dc_b               : in    std_ulogic;
    lcb_clkoff_dc_b             : in    std_ulogic;
    lcb_mpw1_dc_b               : in    std_ulogic;
    lcb_mpw2_dc_b               : in    std_ulogic;
    lcb_delay_lclkr_dc          : in    std_ulogic;
    lcb_act_dis_dc              : in    std_ulogic;
    pc_pc_func_slp_sl_thold_0   : in    std_ulogic;
    pc_pc_sg_0                  : in    std_ulogic;
    func_scan_in                : in    std_ulogic;
    func_scan_out               : out   std_ulogic;
-- Reset Related
    an_ac_reset_1_complete      : in    std_ulogic;
    an_ac_reset_2_complete      : in    std_ulogic;
    an_ac_reset_3_complete      : in    std_ulogic;
    an_ac_reset_wd_complete     : in    std_ulogic;
    pc_xu_reset_1_cmplt         : out   std_ulogic;  
    pc_xu_reset_2_cmplt         : out   std_ulogic;  
    pc_xu_reset_3_cmplt         : out   std_ulogic;  
    pc_xu_reset_wd_cmplt        : out   std_ulogic;  
    pc_xu_init_reset            : out   std_ulogic;  
    pc_iu_init_reset            : out   std_ulogic;
    ct_rg_hold_during_init      : out   std_ulogic;
-- Power Management
    ct_rg_power_managed         : out   std_ulogic_vector(0 to 3);
    ct_rg_pm_thread_stop        : out   std_ulogic_vector(0 to 3);  
    an_ac_pm_thread_stop        : in    std_ulogic_vector(0 to 3); 
    ac_an_power_managed         : out   std_ulogic;
    ac_an_rvwinkle_mode         : out   std_ulogic;
    ct_ck_pm_ccflush_disable    : out   std_ulogic;
    ct_ck_pm_raise_tholds       : out   std_ulogic;
    rg_ct_dis_pwr_savings       : in    std_ulogic;
    xu_pc_spr_ccr0_pme          : in    std_ulogic_vector(0 to 1);
    xu_pc_spr_ccr0_we           : in    std_ulogic_vector(0 to 3);
-- Trace/Trigger Signals
    dbg_ctrls                   : out   std_ulogic_vector(0 to 36)
);
-- synopsys translate_off


-- synopsys translate_on
end pcq_ctrl;

architecture pcq_ctrl of pcq_ctrl is
--=====================================================================
-- Signal Declarations
--=====================================================================
constant initactive_size        : positive := 1;
constant resetsm_size           : positive := 5;
constant initerat_size          : positive := 1;
constant pmstate_size           : positive := 14;
constant sprccr0_size           : positive := 6;
constant pmstop_size            : positive := 4;
constant resetstat_size         : positive := 4;
constant sparectrl_size         : positive := 6;

-----------------------------------------------------------------------
-- Scan Ring Ordering:
-- start of func scan chain ordering
constant initactive_offset      : natural := 0;
constant resetsm_offset         : natural := initactive_offset + initactive_size;
constant initerat_offset        : natural := resetsm_offset + resetsm_size;
constant pmstate_offset         : natural := initerat_offset + initerat_size;
constant sprccr0_offset         : natural := pmstate_offset + pmstate_size;
constant pmstop_offset          : natural := sprccr0_offset + sprccr0_size;
constant resetstat_offset       : natural := pmstop_offset + pmstop_size;
constant sparectrl_offset       : natural := resetstat_offset + resetstat_size;
constant func_right             : natural := sparectrl_offset + sparectrl_size - 1;
-- end of func scan chain ordering

-----------------------------------------------------------------------
-- Reset State Machine:
constant ResSM_Idle             : std_ulogic_vector(0 to 4) := "00000";
constant ResSM_Start            : std_ulogic_vector(0 to 4) := "00001";
constant ResSM_InitErat         : std_ulogic_vector(0 to 4) := "00111";
constant ResSM_Return           : std_ulogic_vector(0 to 4) := "10111";

-----------------------------------------------------------------------
-- Basic/Misc signals
signal tiup                             : std_ulogic;
signal func_siv, func_sov               : std_ulogic_vector(0 to func_right);
signal pc_pc_func_slp_sl_thold_0_b      : std_ulogic;
signal force_funcslp                    : std_ulogic;
-- Reset Signals
signal resetsm_active                   : std_ulogic;
signal resetsm_act_ctrl                 : std_ulogic;
-- Power management Signals
signal spr_ccr0_pme_q                   : std_ulogic_vector(0 to 1);
signal spr_ccr0_we_q                    : std_ulogic_vector(0 to 3);
signal pm_sleep_enable                  : std_ulogic;
signal pm_rvw_enable                    : std_ulogic;
signal thread_stopped                   : std_ulogic_vector(0 to 3);
-- Latch definitions begin
signal resetsm_d, resetsm_q             : std_ulogic_vector(0 to resetsm_size-1);
signal init_active_d, init_active_q     : std_ulogic;
signal initerat_d, initerat_q           : std_ulogic;
signal pmstate_d, pmstate_q             : std_ulogic_vector(0 to 3);
signal pmstate_all_d, pmstate_all_q     : std_ulogic;
signal pmclkctrl_dly_d, pmclkctrl_dly_q : std_ulogic_vector(0 to 7);
signal rvwinkled_d, rvwinkled_q         : std_ulogic;
signal pmstop_q                         : std_ulogic_vector(0 to pmstop_size-1);
signal reset_complete_q                 : std_ulogic_vector(0 to resetstat_size-1);
signal pm_ccflush_disable_int           : std_ulogic;
signal pm_raise_tholds_int              : std_ulogic;       
signal spare_ctrl_wrapped_q             : std_ulogic_vector(0 to sparectrl_size-1);


begin


tiup <= '1';


--=====================================================================
-- Reset State Machine
--=====================================================================
   -- Counter used to generate reset control pulses.
   -- Starts when clocks start because init_active_q inits to 1.
   -- Keeps counting until init_active_q is reset, then returns to Idle state.
   resetsm_d  <= (others=>'0')  when (resetsm_q=ResSM_Idle  and init_active_q='0') else
                 ResSM_Start    when (resetsm_q=ResSM_Idle  and init_active_q='1') else
                 ResSM_Idle     when  init_active_q='0'  else  
                 resetsm_q + "00001";

   resetsm_active    <= or_reduce(resetsm_q);
   resetsm_act_ctrl  <= init_active_q or resetsm_active;
   
   -- The initerat latch controls the init_reset signals to IU and XU.
   -- Goes active when ResSM=8. Goes inactive 16 clock cycles later when ResSM returns to Idle.
   initerat_d  <= '0' when resetsm_q=ResSM_Idle      else
                  '0' when resetsm_q=ResSM_Return    else
                  '1' when resetsm_q=ResSM_InitErat  else
                  initerat_q;
 
   -- init_active_q initializes to '1'; cleared when Reset_SM count completes (ResSM >= 24).
   init_active_d <= '0' when resetsm_q(0 to 1)="11" else init_active_q;


--=====================================================================
-- Power Management Latches
--=====================================================================
   -- XU signals indicate when power-savings is enabled (sleep or rvw modes), and which
   -- threads are stopped.
   -- The pmstate latch tracks which threads are stopped when either power-savings mode
   -- is enabled.  The rvwinkled latch only when pm_rvw_enable is set.
   -- If all threads are stopped when power-savings is enabled, then signals to the
   -- clock control macro will initiate power savings actions.  These controls force
   -- ccflush_dc inactive to ensure all PLATs are clocking.  After a delay period, the
   -- run tholds will be raised to stop clocks.
   -- When coming out of power-savings, the tholds will be disabled prior to deactivating
   -- ccflush_dc.
   pm_sleep_enable <= not spr_ccr0_pme_q(0) and spr_ccr0_pme_q(1);

   pm_rvw_enable   <= spr_ccr0_pme_q(0) and not spr_ccr0_pme_q(1);

   thread_stopped  <= spr_ccr0_we_q;



   pmstate_d      <= gate_and((pm_sleep_enable or pm_rvw_enable) and not resetsm_active,
                               thread_stopped(0 to 3));

   pmstate_all_d  <= and_reduce(pmstate_q);

   pmclkctrl_dly_d(0 to 7) <= pmstate_all_q & pmclkctrl_dly_q(0 to 6);

   rvwinkled_d    <= pmclkctrl_dly_q(6) and pm_rvw_enable;


--=====================================================================
-- Outputs
--=====================================================================
   -- Used as part of thread stop signal to XU.
   -- Keeps threads stopped until after the Reset SM completes count.
   ct_rg_hold_during_init  <= init_active_q;

   -- Init pulse to IU and XU to force initialization of I/D-ERATs.
   -- IU also holds instruction fetch until init signal released.
   pc_iu_init_reset  <= initerat_q;
   pc_xu_init_reset  <= initerat_q;

   -- Software initiated reset status to XU for DBSR[MRR] and TSR[WRS]
   pc_xu_reset_1_cmplt  <= reset_complete_q(0);  
   pc_xu_reset_2_cmplt  <= reset_complete_q(1);  
   pc_xu_reset_3_cmplt  <= reset_complete_q(2);  
   pc_xu_reset_wd_cmplt <= reset_complete_q(3);  

   -- To THRCTL[Tx_PM]; indicates core power-managed due to external input.
   ct_rg_pm_thread_stop <= pmstop_q;

   -- To THRCTL[Tx_PM]; indicates core power-managed via software actions.
   ct_rg_power_managed  <= pmstate_q;

   -- Core in rvwinkle power-savings state. L2 can prepare for Chiplet power-down.
   ac_an_rvwinkle_mode  <= rvwinkled_q;
   -- Core in power-savings state due to any combination of power-savings instructions
   ac_an_power_managed  <= pmclkctrl_dly_q(7);

   -- Goes to clock controls to disable plat flush controls
   pm_ccflush_disable_int   <= pmstate_all_q or pmclkctrl_dly_q(7);
   ct_ck_pm_ccflush_disable <= pm_ccflush_disable_int and not rg_ct_dis_pwr_savings;
   -- Goes to clock controls to activate run tholds
   pm_raise_tholds_int      <= pmstate_all_q and pmclkctrl_dly_q(7);
   ct_ck_pm_raise_tholds    <= pm_raise_tholds_int and not rg_ct_dis_pwr_savings; 


--=====================================================================
-- Trace/Trigger Signals
--=====================================================================
   dbg_ctrls      <= init_active_q              & --  0
                     resetsm_q(0 to 4)          & --  1:5
                     initerat_q                 & --  6
                     reset_complete_q(0 to 3)   & --  7:10
                     pmstop_q(0 to 3)           & -- 11:14
                     pmstate_q(0 to 3)          & -- 15:18
                     rvwinkled_q                & -- 19
                     spr_ccr0_pme_q(0 to 1)     & -- 20:21
                     spr_ccr0_we_q(0 to 3)      & -- 22:25
                     pmclkctrl_dly_q(0 to 7)    & -- 26:33
                     rg_ct_dis_pwr_savings      & -- 34
                     pm_ccflush_disable_int     & -- 35
                     pm_raise_tholds_int        ; -- 36


--=====================================================================
-- Latches
--=====================================================================
-- func ring registers start
initactive: tri_rlmlatch_p
  generic map (init => 1, expand_type => expand_type)
  port map (vd       => vdd,
            gd       => gnd,
            nclk     => nclk,
            act      => tiup,
            thold_b  => pc_pc_func_slp_sl_thold_0_b,
            sg       => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b   => lcb_mpw1_dc_b,
            mpw2_b   => lcb_mpw2_dc_b,
            scin     => func_siv(initactive_offset),
            scout    => func_sov(initactive_offset),
            din      => init_active_d,
            dout     => init_active_q);

resetsm: tri_rlmreg_p  
  generic map (width => resetsm_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => resetsm_act_ctrl,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(resetsm_offset to resetsm_offset + resetsm_size-1),
            scout   => func_sov(resetsm_offset to resetsm_offset + resetsm_size-1),
            din     => resetsm_d,
            dout    => resetsm_q );

initerat: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd       => vdd,
            gd       => gnd,
            nclk     => nclk,
            act      => resetsm_active,
            thold_b  => pc_pc_func_slp_sl_thold_0_b,
            sg       => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b   => lcb_mpw1_dc_b,
            mpw2_b   => lcb_mpw2_dc_b,
            scin     => func_siv(initerat_offset),
            scout    => func_sov(initerat_offset),
            din      => initerat_d,
            dout     => initerat_q );

pmstate: tri_rlmreg_p  
  generic map (width => pmstate_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(pmstate_offset to pmstate_offset + pmstate_size-1),
            scout   => func_sov(pmstate_offset to pmstate_offset + pmstate_size-1),
            din(0 to 3)   => pmstate_d,
            din(4)        => pmstate_all_d,
            din(5)        => rvwinkled_d,
            din(6 to 13)  => pmclkctrl_dly_d,
            dout(0 to 3)  => pmstate_q,
            dout(4)       => pmstate_all_q,
            dout(5)       => rvwinkled_q,
            dout(6 to 13) => pmclkctrl_dly_q );

sprccr0: tri_rlmreg_p  
  generic map (width => sprccr0_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(sprccr0_offset to sprccr0_offset + sprccr0_size-1),
            scout   => func_sov(sprccr0_offset to sprccr0_offset + sprccr0_size-1),
            din(0 to 1)  => xu_pc_spr_ccr0_pme,
            din(2 to 5)  => xu_pc_spr_ccr0_we,
            dout(0 to 1) => spr_ccr0_pme_q,
            dout(2 to 5) => spr_ccr0_we_q );

pmstop: tri_rlmreg_p  
  generic map (width => pmstop_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(pmstop_offset to pmstop_offset + pmstop_size-1),
            scout   => func_sov(pmstop_offset to pmstop_offset + pmstop_size-1),
            din     => an_ac_pm_thread_stop,
            dout    => pmstop_q );

resetstat: tri_rlmreg_p  
  generic map (width => resetstat_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(resetstat_offset to resetstat_offset + resetstat_size-1),
            scout   => func_sov(resetstat_offset to resetstat_offset + resetstat_size-1),
            din(0)  => an_ac_reset_1_complete,
            din(1)  => an_ac_reset_2_complete,
            din(2)  => an_ac_reset_3_complete,
            din(3)  => an_ac_reset_wd_complete,
            dout    => reset_complete_q );

sparectrl: tri_rlmreg_p  
  generic map (width => sparectrl_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_pc_func_slp_sl_thold_0_b,
            sg      => pc_pc_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(sparectrl_offset to sparectrl_offset + sparectrl_size-1),
            scout   => func_sov(sparectrl_offset to sparectrl_offset + sparectrl_size-1),
            din     => spare_ctrl_wrapped_q,
            dout    => spare_ctrl_wrapped_q );
-- func ring registers end


--=====================================================================
-- Thold/SG Staging
--=====================================================================
-- func_slp lcbor
lcbor_funcslp: tri_lcbor
generic map (expand_type => expand_type )
port map (
    clkoff_b => lcb_clkoff_dc_b,
    thold    => pc_pc_func_slp_sl_thold_0,
    sg       => pc_pc_sg_0,
    act_dis  => lcb_act_dis_dc,
    forcee => force_funcslp,
    thold_b  => pc_pc_func_slp_sl_thold_0_b );


--=====================================================================
-- Scan Connections
--=====================================================================
-- Func ring
func_siv(0 TO func_right) <=  func_scan_in & func_sov(0 to func_right-1);
func_scan_out  <=  func_sov(func_right) and scan_dis_dc_b;


-----------------------------------------------------------------------
end pcq_ctrl;
