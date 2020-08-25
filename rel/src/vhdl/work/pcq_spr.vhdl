-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--  Description: Pervasive Core SPRs and slowSPR Interface
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


entity pcq_spr is
generic(regmode     : integer := 6;
        expand_type : integer := 2 ); -- 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     -- pervasive signals
     scan_dis_dc_b              : in  std_ulogic;
     lcb_clkoff_dc_b            : in  std_ulogic;
     lcb_mpw1_dc_b              : in  std_ulogic;
     lcb_mpw2_dc_b              : in  std_ulogic;
     lcb_delay_lclkr_dc         : in  std_ulogic;
     lcb_act_dis_dc             : in  std_ulogic;
     pc_pc_func_sl_thold_0      : in  std_ulogic;
     pc_pc_sg_0                 : in  std_ulogic;
     func_scan_in               : in  std_ulogic;
     func_scan_out              : out std_ulogic;
     -- slowSPR Interface
     slowspr_val_in             : in  std_ulogic;
     slowspr_rw_in              : in  std_ulogic;
     slowspr_etid_in            : in  std_ulogic_vector(0 to 1);
     slowspr_addr_in            : in  std_ulogic_vector(0 to 9);
     slowspr_data_in            : in  std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_in            : in  std_ulogic;
     slowspr_val_out            : out std_ulogic;
     slowspr_rw_out             : out std_ulogic;
     slowspr_etid_out           : out std_ulogic_vector(0 to 1);
     slowspr_addr_out           : out std_ulogic_vector(0 to 9);
     slowspr_data_out           : out std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_out           : out std_ulogic;
     -- register outputs
     sp_rg_trace_bus_enable     : out std_ulogic;
     pc_fu_instr_trace_mode     : out std_ulogic;
     pc_fu_instr_trace_tid      : out std_ulogic_vector(0 to 1);
     pc_xu_instr_trace_mode     : out std_ulogic;
     pc_xu_instr_trace_tid      : out std_ulogic_vector(0 to 1);
     pc_fu_event_count_mode     : out std_ulogic_vector(0 to 2);
     pc_iu_event_count_mode     : out std_ulogic_vector(0 to 2);
     pc_mm_event_count_mode     : out std_ulogic_vector(0 to 2);
     pc_xu_event_count_mode     : out std_ulogic_vector(0 to 2);
     pc_fu_event_mux_ctrls      : out std_ulogic_vector(0 to 31);
     pc_iu_event_mux_ctrls      : out std_ulogic_vector(0 to 47); 
     pc_mm_event_mux_ctrls      : out std_ulogic_vector(0 to 39);
     pc_xu_event_mux_ctrls      : out std_ulogic_vector(0 to 47);
     pc_xu_lsu_event_mux_ctrls  : out std_ulogic_vector(0 to 47);
     sp_db_event_mux_ctrls      : out std_ulogic_vector(0 to 23);
     pc_fu_event_bus_enable     : out std_ulogic;
     pc_iu_event_bus_enable     : out std_ulogic;
     pc_rp_event_bus_enable     : out std_ulogic;
     pc_xu_event_bus_enable     : out std_ulogic;
     sp_db_event_bus_enable     : out std_ulogic;
     -- Trace/Trigger Signals
     dbg_spr                    : out   std_ulogic_vector(0 to 46)
);

-- synopsys translate_off


-- synopsys translate_on
end pcq_spr;


architecture pcq_spr of pcq_spr is
--=====================================================================
-- Signal Declarations
--=====================================================================
-- Scan Ring Constants:
-- Register sizes
constant cesr_size              : positive :=  32;
constant aesr_size              : positive :=  32;
constant iesr1_size             : positive :=  24;
constant iesr2_size             : positive :=  24;
constant mesr1_size             : positive :=  20;
constant mesr2_size             : positive :=  20;
constant xesr1_size             : positive :=  24;
constant xesr2_size             : positive :=  24;
constant xesr3_size             : positive :=  24;
constant xesr4_size             : positive :=  24;
constant pc_data_size           : positive :=  2**regmode;

-- start of func scan chain ordering
constant slowspr_val_offset     : natural := 0;
constant slowspr_rw_offset      : natural := slowspr_val_offset  + 1;
constant slowspr_etid_offset    : natural := slowspr_rw_offset   + 1;
constant slowspr_addr_offset    : natural := slowspr_etid_offset + 2;
constant slowspr_data_offset    : natural := slowspr_addr_offset + 10;
constant slowspr_done_offset    : natural := slowspr_data_offset + 2**regmode;
constant pc_val_offset          : natural := slowspr_done_offset + 1;
constant pc_rw_offset           : natural := pc_val_offset  + 1;
constant pc_etid_offset         : natural := pc_rw_offset   + 1;
constant pc_addr_offset         : natural := pc_etid_offset + 2;
constant pc_data_offset         : natural := pc_addr_offset + 10;
constant pc_done_offset         : natural := pc_data_offset + 2**regmode;
constant cesr_offset            : natural := pc_done_offset + 1;
constant aesr_offset            : natural := cesr_offset  + cesr_size;
constant iesr1_offset           : natural := aesr_offset  + aesr_size;
constant iesr2_offset           : natural := iesr1_offset + iesr1_size;
constant mesr1_offset           : natural := iesr2_offset + iesr2_size;
constant mesr2_offset           : natural := mesr1_offset + mesr1_size;
constant xesr1_offset           : natural := mesr2_offset + mesr2_size;
constant xesr2_offset           : natural := xesr1_offset + xesr1_size;
constant xesr3_offset           : natural := xesr2_offset + xesr2_size;
constant xesr4_offset           : natural := xesr3_offset + xesr3_size;
constant func_right             : natural := xesr4_offset + xesr4_size - 1;
-- end of func scan chain ordering

constant CESR_MASK              : std_ulogic_vector(32 to 63) := "11111111111111111111111111111111";
constant EVENTMUX_32_MASK       : std_ulogic_vector(32 to 63) := "11111111111111111111111111111111";
constant EVENTMUX_64_MASK       : std_ulogic_vector(32 to 63) := "11111111111111111111000000000000";
constant EVENTMUX_128_MASK      : std_ulogic_vector(32 to 63) := "11111111111111111111111100000000";

----------------------------
-- signals
----------------------------
signal slowspr_val_d    : std_ulogic;
signal slowspr_val_l2   : std_ulogic;
signal slowspr_rw_d     : std_ulogic;
signal slowspr_rw_l2    : std_ulogic;
signal slowspr_etid_d   : std_ulogic_vector(0 to 1);
signal slowspr_etid_l2  : std_ulogic_vector(0 to 1);
signal slowspr_addr_d   : std_ulogic_vector(0 to 9);
signal slowspr_addr_l2  : std_ulogic_vector(0 to 9);
signal slowspr_data_d   : std_ulogic_vector(64-(2**regmode) to 63);
signal slowspr_data_l2  : std_ulogic_vector(64-(2**regmode) to 63);
signal slowspr_done_d   : std_ulogic;
signal slowspr_done_l2  : std_ulogic;

signal pc_val_d         : std_ulogic;
signal pc_val_l2        : std_ulogic;
signal pc_rw_d          : std_ulogic;
signal pc_rw_l2         : std_ulogic;
signal pc_etid_d        : std_ulogic_vector(0 to 1);
signal pc_etid_l2       : std_ulogic_vector(0 to 1);
signal pc_addr_d        : std_ulogic_vector(0 to 9);
signal pc_addr_l2       : std_ulogic_vector(0 to 9);
signal pc_done_d        : std_ulogic;
signal pc_done_l2       : std_ulogic;
signal pc_data_d        : std_ulogic_vector(64-(2**regmode) to 63);
signal pc_data_l2       : std_ulogic_vector(64-(2**regmode) to 63);
signal pc_done_int      : std_ulogic;
signal pc_data_int      : std_ulogic_vector(64-(2**regmode) to 63);
signal pc_reg_data      : std_ulogic_vector(32 to 63);

signal cesr_sel         : std_ulogic;
signal cesr_wren        : std_ulogic;
signal cesr_rden        : std_ulogic;
signal cesr_d           : std_ulogic_vector(32 to 32+cesr_size-1);
signal cesr_l2          : std_ulogic_vector(32 to 32+cesr_size-1);
signal cesr_out         : std_ulogic_vector(32 to 63);

signal aesr_sel         : std_ulogic;
signal aesr_wren        : std_ulogic;
signal aesr_rden        : std_ulogic;
signal aesr_d           : std_ulogic_vector(32 to 32+aesr_size-1);
signal aesr_l2          : std_ulogic_vector(32 to 32+aesr_size-1);
signal aesr_out         : std_ulogic_vector(32 to 63);

signal iesr1_sel        : std_ulogic;
signal iesr1_wren       : std_ulogic;
signal iesr1_rden       : std_ulogic;
signal iesr1_d          : std_ulogic_vector(32 to 32+iesr1_size-1);
signal iesr1_l2         : std_ulogic_vector(32 to 32+iesr1_size-1);
signal iesr1_out        : std_ulogic_vector(32 to 63);

signal iesr2_sel        : std_ulogic;
signal iesr2_wren       : std_ulogic;
signal iesr2_rden       : std_ulogic;
signal iesr2_d          : std_ulogic_vector(32 to 32+iesr2_size-1);
signal iesr2_l2         : std_ulogic_vector(32 to 32+iesr2_size-1);
signal iesr2_out        : std_ulogic_vector(32 to 63);

signal mesr1_sel        : std_ulogic;
signal mesr1_wren       : std_ulogic;
signal mesr1_rden       : std_ulogic;
signal mesr1_d          : std_ulogic_vector(32 to 32+mesr1_size-1);
signal mesr1_l2         : std_ulogic_vector(32 to 32+mesr1_size-1);
signal mesr1_out        : std_ulogic_vector(32 to 63);

signal mesr2_sel        : std_ulogic;
signal mesr2_wren       : std_ulogic;
signal mesr2_rden       : std_ulogic;
signal mesr2_d          : std_ulogic_vector(32 to 32+mesr2_size-1);
signal mesr2_l2         : std_ulogic_vector(32 to 32+mesr2_size-1);
signal mesr2_out        : std_ulogic_vector(32 to 63);

signal xesr1_sel        : std_ulogic;
signal xesr1_wren       : std_ulogic;
signal xesr1_rden       : std_ulogic;
signal xesr1_d          : std_ulogic_vector(32 to 32+xesr1_size-1);
signal xesr1_l2         : std_ulogic_vector(32 to 32+xesr1_size-1);
signal xesr1_out        : std_ulogic_vector(32 to 63);

signal xesr2_sel        : std_ulogic;
signal xesr2_wren       : std_ulogic;
signal xesr2_rden       : std_ulogic;
signal xesr2_d          : std_ulogic_vector(32 to 32+xesr2_size-1);
signal xesr2_l2         : std_ulogic_vector(32 to 32+xesr2_size-1);
signal xesr2_out        : std_ulogic_vector(32 to 63);

signal xesr3_sel        : std_ulogic;
signal xesr3_wren       : std_ulogic;
signal xesr3_rden       : std_ulogic;
signal xesr3_d          : std_ulogic_vector(32 to 32+xesr3_size-1);
signal xesr3_l2         : std_ulogic_vector(32 to 32+xesr3_size-1);
signal xesr3_out        : std_ulogic_vector(32 to 63);

signal xesr4_sel        : std_ulogic;
signal xesr4_wren       : std_ulogic;
signal xesr4_rden       : std_ulogic;
signal xesr4_d          : std_ulogic_vector(32 to 32+xesr4_size-1);
signal xesr4_l2         : std_ulogic_vector(32 to 32+xesr4_size-1);
signal xesr4_out        : std_ulogic_vector(32 to 63);

-- misc, pervasive signals
signal tiup                     : std_ulogic;
signal pc_pc_func_sl_thold_0_b  : std_ulogic;
signal force_func               : std_ulogic;
signal func_siv                 : std_ulogic_vector(0 to func_right);
signal func_sov                 : std_ulogic_vector(0 to func_right);


begin

tiup    <= '1';

-------------------------------------------------
-- latches
-------------------------------------------------
slowspr_val_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(slowspr_val_offset),
            scout       => func_sov(slowspr_val_offset),
            din         => slowspr_val_d,
            dout        => slowspr_val_l2);

slowspr_rw_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => slowspr_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(slowspr_rw_offset),
            scout       => func_sov(slowspr_rw_offset),
            din         => slowspr_rw_d,
            dout        => slowspr_rw_l2);

slowspr_etid_reg: tri_rlmreg_p
  generic map (width => slowspr_etid_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => slowspr_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(slowspr_etid_offset to slowspr_etid_offset + slowspr_etid_l2'length-1),
            scout       => func_sov(slowspr_etid_offset to slowspr_etid_offset + slowspr_etid_l2'length-1),
            din         => slowspr_etid_d,
            dout        => slowspr_etid_l2);

slowspr_addr_reg: tri_rlmreg_p
  generic map (width => slowspr_addr_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => slowspr_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(slowspr_addr_offset to slowspr_addr_offset + slowspr_addr_l2'length-1),
            scout       => func_sov(slowspr_addr_offset to slowspr_addr_offset + slowspr_addr_l2'length-1),
            din         => slowspr_addr_d,
            dout        => slowspr_addr_l2);

slowspr_data_reg: tri_rlmreg_p
  generic map (width => slowspr_data_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => slowspr_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(slowspr_data_offset to slowspr_data_offset + slowspr_data_l2'length-1),
            scout       => func_sov(slowspr_data_offset to slowspr_data_offset + slowspr_data_l2'length-1),
            din         => slowspr_data_d,
            dout        => slowspr_data_l2);

slowspr_done_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => slowspr_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(slowspr_done_offset),
            scout       => func_sov(slowspr_done_offset),
            din         => slowspr_done_d,
            dout        => slowspr_done_l2);

pc_val_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(pc_val_offset),
            scout       => func_sov(pc_val_offset),
            din         => pc_val_d,
            dout        => pc_val_l2);

pc_rw_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => pc_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(pc_rw_offset),
            scout       => func_sov(pc_rw_offset),
            din         => pc_rw_d,
            dout        => pc_rw_l2);

pc_etid_reg: tri_rlmreg_p
  generic map (width => pc_etid_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => pc_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(pc_etid_offset to pc_etid_offset + pc_etid_l2'length-1),
            scout       => func_sov(pc_etid_offset to pc_etid_offset + pc_etid_l2'length-1),
            din         => pc_etid_d,
            dout        => pc_etid_l2);

pc_addr_reg: tri_rlmreg_p
  generic map (width => pc_addr_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => pc_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(pc_addr_offset to pc_addr_offset + pc_addr_l2'length-1),
            scout       => func_sov(pc_addr_offset to pc_addr_offset + pc_addr_l2'length-1),
            din         => pc_addr_d,
            dout        => pc_addr_l2);

pc_data_reg: tri_rlmreg_p 
  generic map (width => pc_data_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => pc_val_d,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(pc_data_offset to pc_data_offset + pc_data_size-1),
            scout       => func_sov(pc_data_offset to pc_data_offset + pc_data_size-1),
            din         => pc_data_d,
            dout        => pc_data_l2);

pc_done_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(pc_done_offset),
            scout       => func_sov(pc_done_offset),
            din         => pc_done_d,
            dout        => pc_done_l2);

cesr_reg: tri_ser_rlmreg_p 
  generic map (width => cesr_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => cesr_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(cesr_offset to cesr_offset + cesr_size-1),
            scout       => func_sov(cesr_offset to cesr_offset + cesr_size-1),
            din         => cesr_d,
            dout        => cesr_l2);

aesr_reg: tri_ser_rlmreg_p 
  generic map (width => aesr_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => aesr_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(aesr_offset to aesr_offset + aesr_size-1),
            scout       => func_sov(aesr_offset to aesr_offset + aesr_size-1),
            din         => aesr_d,
            dout        => aesr_l2);

iesr1_reg: tri_ser_rlmreg_p 
  generic map (width => iesr1_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iesr1_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(iesr1_offset to iesr1_offset + iesr1_size-1),
            scout       => func_sov(iesr1_offset to iesr1_offset + iesr1_size-1),
            din         => iesr1_d,
            dout        => iesr1_l2);

iesr2_reg: tri_ser_rlmreg_p 
  generic map (width => iesr2_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iesr2_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(iesr2_offset to iesr2_offset + iesr2_size-1),
            scout       => func_sov(iesr2_offset to iesr2_offset + iesr2_size-1),
            din         => iesr2_d,
            dout        => iesr2_l2);

mesr1_reg: tri_ser_rlmreg_p 
  generic map (width => mesr1_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => mesr1_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(mesr1_offset to mesr1_offset + mesr1_size-1),
            scout       => func_sov(mesr1_offset to mesr1_offset + mesr1_size-1),
            din         => mesr1_d,
            dout        => mesr1_l2);

mesr2_reg: tri_ser_rlmreg_p 
  generic map (width => mesr2_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => mesr2_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(mesr2_offset to mesr2_offset + mesr2_size-1),
            scout       => func_sov(mesr2_offset to mesr2_offset + mesr2_size-1),
            din         => mesr2_d,
            dout        => mesr2_l2);

xesr1_reg: tri_ser_rlmreg_p 
  generic map (width => xesr1_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => xesr1_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(xesr1_offset to xesr1_offset + xesr1_size-1),
            scout       => func_sov(xesr1_offset to xesr1_offset + xesr1_size-1),
            din         => xesr1_d,
            dout        => xesr1_l2);

xesr2_reg: tri_ser_rlmreg_p 
  generic map (width => xesr2_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => xesr2_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(xesr2_offset to xesr2_offset + xesr2_size-1),
            scout       => func_sov(xesr2_offset to xesr2_offset + xesr2_size-1),
            din         => xesr2_d,
            dout        => xesr2_l2);

xesr3_reg: tri_ser_rlmreg_p 
  generic map (width => xesr3_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => xesr3_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(xesr3_offset to xesr3_offset + xesr3_size-1),
            scout       => func_sov(xesr3_offset to xesr3_offset + xesr3_size-1),
            din         => xesr3_d,
            dout        => xesr3_l2);

xesr4_reg: tri_ser_rlmreg_p 
  generic map (width => xesr4_size, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => xesr4_wren,
            thold_b     => pc_pc_func_sl_thold_0_b,
            sg          => pc_pc_sg_0,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b      => lcb_mpw1_dc_b,
            mpw2_b      => lcb_mpw2_dc_b,
            scin        => func_siv(xesr4_offset to xesr4_offset + xesr4_size-1),
            scout       => func_sov(xesr4_offset to xesr4_offset + xesr4_size-1),
            din         => xesr4_d,
            dout        => xesr4_l2);

-------------------------------------------------
-- inputs + staging
-------------------------------------------------
slowspr_val_d   <= slowspr_val_in;
slowspr_rw_d    <= slowspr_rw_in;
slowspr_etid_d  <= slowspr_etid_in;
slowspr_addr_d  <= slowspr_addr_in;
slowspr_data_d  <= slowspr_data_in;
slowspr_done_d  <= slowspr_done_in;

pc_val_d        <= slowspr_val_l2;
pc_rw_d         <= slowspr_rw_l2;
pc_etid_d       <= slowspr_etid_l2;
pc_addr_d       <= slowspr_addr_l2;
pc_data_d       <= slowspr_data_l2 or pc_data_int;
pc_done_d       <= slowspr_done_l2 or pc_done_int;


-------------------------------------------------
-- outputs
-------------------------------------------------
slowspr_val_out   <= pc_val_l2;
slowspr_rw_out    <= pc_rw_l2;
slowspr_etid_out  <= pc_etid_l2;
slowspr_addr_out  <= pc_addr_l2;
slowspr_data_out  <= pc_data_l2;
slowspr_done_out  <= pc_done_l2;

-- Event Select Controls
sp_rg_trace_bus_enable    <= cesr_out(36);

pc_fu_instr_trace_mode    <= cesr_out(37);
pc_fu_instr_trace_tid     <= cesr_out(38 to 39);
pc_xu_instr_trace_mode    <= cesr_out(37);
pc_xu_instr_trace_tid     <= cesr_out(38 to 39);

pc_fu_event_count_mode    <= cesr_out(33 to 35);
pc_iu_event_count_mode    <= cesr_out(33 to 35);
pc_mm_event_count_mode    <= cesr_out(33 to 35);
pc_xu_event_count_mode    <= cesr_out(33 to 35);

pc_fu_event_bus_enable    <= cesr_out(32);
pc_iu_event_bus_enable    <= cesr_out(32);
pc_rp_event_bus_enable    <= cesr_out(32);
pc_xu_event_bus_enable    <= cesr_out(32);
sp_db_event_bus_enable    <= cesr_out(32);

pc_fu_event_mux_ctrls     <= aesr_out(32 to 63);
pc_iu_event_mux_ctrls     <= iesr1_out(32 to 55) & iesr2_out(32 to 55);
pc_mm_event_mux_ctrls     <= mesr1_out(32 to 51) & mesr2_out(32 to 51);
pc_xu_event_mux_ctrls     <= xesr1_out(32 to 55) & xesr2_out(32 to 55);
pc_xu_lsu_event_mux_ctrls <= xesr3_out(32 to 55) & xesr4_out(32 to 55);
sp_db_event_mux_ctrls     <= cesr_out(40 to 63);


-------------------------------------------------
-- register select
-------------------------------------------------
cesr_sel     <= slowspr_val_l2 and slowspr_addr_l2 = "1110010000";   -- 912
aesr_sel     <= slowspr_val_l2 and slowspr_addr_l2 = "1110010001";   -- 913
iesr1_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110010010";   -- 914
iesr2_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110010011";   -- 915
mesr1_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110010100";   -- 916
mesr2_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110010101";   -- 917
xesr1_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110010110";   -- 918
xesr2_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110010111";   -- 919
xesr3_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110011000";   -- 920
xesr4_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110011001";   -- 921

pc_done_int  <= cesr_sel  or aesr_sel  or iesr1_sel or iesr2_sel or
                mesr1_sel or mesr2_sel or xesr1_sel or xesr2_sel or
                xesr3_sel or xesr4_sel;


-------------------------------------------------
-- register write
-------------------------------------------------
cesr_wren    <=  cesr_sel   and  slowspr_rw_l2 = '0';
aesr_wren    <=  aesr_sel   and  slowspr_rw_l2 = '0';
iesr1_wren   <=  iesr1_sel  and  slowspr_rw_l2 = '0';
iesr2_wren   <=  iesr2_sel  and  slowspr_rw_l2 = '0';
mesr1_wren   <=  mesr1_sel  and  slowspr_rw_l2 = '0';
mesr2_wren   <=  mesr2_sel  and  slowspr_rw_l2 = '0';
xesr1_wren   <=  xesr1_sel  and  slowspr_rw_l2 = '0';
xesr2_wren   <=  xesr2_sel  and  slowspr_rw_l2 = '0';
xesr3_wren   <=  xesr3_sel  and  slowspr_rw_l2 = '0';
xesr4_wren   <=  xesr4_sel  and  slowspr_rw_l2 = '0';

cesr_d       <=  CESR_MASK(32 to 32+cesr_size-1)           and  slowspr_data_l2(32 to 32+cesr_size-1);
aesr_d       <=  EVENTMUX_32_MASK(32 to 32+aesr_size-1)    and  slowspr_data_l2(32 to 32+aesr_size-1);
iesr1_d      <=  EVENTMUX_128_MASK(32 to 32+iesr1_size-1)  and  slowspr_data_l2(32 to 32+iesr1_size-1);
iesr2_d      <=  EVENTMUX_128_MASK(32 to 32+iesr2_size-1)  and  slowspr_data_l2(32 to 32+iesr2_size-1);
mesr1_d      <=  EVENTMUX_64_MASK(32 to 32+mesr1_size-1)   and  slowspr_data_l2(32 to 32+mesr1_size-1);
mesr2_d      <=  EVENTMUX_64_MASK(32 to 32+mesr2_size-1)   and  slowspr_data_l2(32 to 32+mesr2_size-1);
xesr1_d      <=  EVENTMUX_128_MASK(32 to 32+xesr1_size-1)  and  slowspr_data_l2(32 to 32+xesr1_size-1);
xesr2_d      <=  EVENTMUX_128_MASK(32 to 32+xesr2_size-1)  and  slowspr_data_l2(32 to 32+xesr2_size-1);
xesr3_d      <=  EVENTMUX_128_MASK(32 to 32+xesr3_size-1)  and  slowspr_data_l2(32 to 32+xesr3_size-1);
xesr4_d      <=  EVENTMUX_128_MASK(32 to 32+xesr4_size-1)  and  slowspr_data_l2(32 to 32+xesr4_size-1);


-------------------------------------------------
-- register read
-------------------------------------------------
cesr_rden    <=  cesr_sel     and  slowspr_rw_l2 = '1';
aesr_rden    <=  aesr_sel     and  slowspr_rw_l2 = '1';
iesr1_rden   <=  iesr1_sel    and  slowspr_rw_l2 = '1';
iesr2_rden   <=  iesr2_sel    and  slowspr_rw_l2 = '1';
mesr1_rden   <=  mesr1_sel    and  slowspr_rw_l2 = '1';
mesr2_rden   <=  mesr2_sel    and  slowspr_rw_l2 = '1';
xesr1_rden   <=  xesr1_sel    and  slowspr_rw_l2 = '1';
xesr2_rden   <=  xesr2_sel    and  slowspr_rw_l2 = '1';
xesr3_rden   <=  xesr3_sel    and  slowspr_rw_l2 = '1';
xesr4_rden   <=  xesr4_sel    and  slowspr_rw_l2 = '1';

cesr_out(32 to 63)   <= cesr_l2;                
aesr_out(32 to 63)   <= aesr_l2;
iesr1_out(32 to 63)  <= iesr1_l2  & (32+iesr1_size to 63 => '0');
iesr2_out(32 to 63)  <= iesr2_l2  & (32+iesr2_size to 63 => '0');
mesr1_out(32 to 63)  <= mesr1_l2  & (32+mesr1_size to 63 => '0');
mesr2_out(32 to 63)  <= mesr2_l2  & (32+mesr2_size to 63 => '0');
xesr1_out(32 to 63)  <= xesr1_l2  & (32+xesr1_size to 63 => '0');
xesr2_out(32 to 63)  <= xesr2_l2  & (32+xesr2_size to 63 => '0');
xesr3_out(32 to 63)  <= xesr3_l2  & (32+xesr3_size to 63 => '0');
xesr4_out(32 to 63)  <= xesr4_l2  & (32+xesr4_size to 63 => '0');

pc_reg_data(32 to 63)  <= cesr_out     when cesr_rden     = '1' else
                          aesr_out     when aesr_rden     = '1' else
                          iesr1_out    when iesr1_rden    = '1' else
                          iesr2_out    when iesr2_rden    = '1' else
                          mesr1_out    when mesr1_rden    = '1' else
                          mesr2_out    when mesr2_rden    = '1' else
                          xesr1_out    when xesr1_rden    = '1' else
                          xesr2_out    when xesr2_rden    = '1' else
                          xesr3_out    when xesr3_rden    = '1' else
                          xesr4_out    when xesr4_rden    = '1' else
                          (others => '0');


r64: if (regmode > 5) generate begin
pc_data_int(0 to 31)    <= (others => '0');
end generate;
pc_data_int(32 to 63)   <= pc_reg_data(32 to 63);


--=====================================================================
-- Trace/Trigger Signals
--=====================================================================
   dbg_spr      <=     slowspr_val_l2                   & --    0
                       slowspr_rw_l2                    & --    1
                       slowspr_etid_l2(0 to 1)          & --  2:3
                       slowspr_addr_l2(0 to 9)          & --  4:13
                       slowspr_data_l2(32 to 63)        & -- 14:45
                       pc_done_l2                       ; -- 46


--=====================================================================
-- Thold/SG Staging
--=====================================================================
-- func_slp lcbor
lcbor_funcslp: tri_lcbor
generic map (expand_type => expand_type )
port map (
    clkoff_b => lcb_clkoff_dc_b,
    thold    => pc_pc_func_sl_thold_0,
    sg       => pc_pc_sg_0,
    act_dis  => lcb_act_dis_dc,
    forcee => force_func,
    thold_b  => pc_pc_func_sl_thold_0_b );


--=====================================================================
-- Scan Connections
--=====================================================================
-- Func ring
func_siv(0 TO func_right) <=  func_scan_in & func_sov(0 to func_right-1);
func_scan_out  <=  func_sov(func_right) and scan_dis_dc_b;


-----------------------------------------------------------------------
end pcq_spr;
