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


--********************************************************************
--*
--* TITLE: Performance event mux
--*
--* NAME: iuq_perf.vhdl
--*
--*********************************************************************


library ieee;
use ieee.std_logic_1164.all;

library ibm,clib;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;

library support;
use support.power_logic_pkg.all;

library tri;
use tri.tri_latches_pkg.all;

library work;
use work.iuq_pkg.all;

entity iuq_perf is
generic(expand_type             : integer := 2 );
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     pc_iu_func_sl_thold_2      : in std_ulogic;
     pc_iu_sg_2                 : in std_ulogic;
     clkoff_b                   : in std_ulogic;
     act_dis                    : in std_ulogic;
     tc_ac_ccflush_dc           : in std_ulogic;
     d_mode                     : in std_ulogic;
     delay_lclkr                : in std_ulogic;
     mpw1_b                     : in std_ulogic;
     mpw2_b                     : in std_ulogic;
     scan_in                    : in std_ulogic;
     scan_out                   : out std_ulogic;

     xu_iu_msr_gs               : in std_ulogic_vector(0 to 3);
     xu_iu_msr_pr               : in std_ulogic_vector(0 to 3);

     ic_perf_event_t0           : in std_ulogic_vector(0 to 6);
     ic_perf_event_t1           : in std_ulogic_vector(0 to 6);
     ic_perf_event_t2           : in std_ulogic_vector(0 to 6);
     ic_perf_event_t3           : in std_ulogic_vector(0 to 6);
     ic_perf_event              : in std_ulogic_vector(0 to 1);

     ib_perf_event_t0           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t1           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t2           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t3           : in std_ulogic_vector(0 to 1);

     fdep_perf_event_t0         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t1         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t2         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t3         : in std_ulogic_vector(0 to 11);

     fiss_perf_event_t0         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t1         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t2         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t3         : in std_ulogic_vector(0 to 7);

     pc_iu_event_mux_ctrls     : in std_ulogic_vector(0 to 47);
     pc_iu_event_count_mode     : in std_ulogic_vector(0 to 2);
     pc_iu_event_bus_enable     : in  std_ulogic;

     iu_pc_event_data           : out std_ulogic_vector(0 to 7)

);
  -- synopsys translate_off


  -- synopsys translate_on
end iuq_perf;


architecture iuq_perf of iuq_perf is

constant event_data_offset      : natural := 0;
constant event_count_mode_offset: natural := event_data_offset + 8;
constant xu_iu_msr_gs_offset    : natural := event_count_mode_offset + 3;
constant xu_iu_msr_pr_offset    : natural := xu_iu_msr_gs_offset + 4;
constant event_bus_enable_offset: natural := xu_iu_msr_pr_offset + 4;
constant event_mux_ctrls_offset : natural := event_bus_enable_offset + 1;
constant scan_right             : natural := event_mux_ctrls_offset + 48-1;

signal event_data_d             : std_ulogic_vector(0 to 7);
signal event_data_q             : std_ulogic_vector(0 to 7);

signal t0_events                : std_ulogic_vector(0 to 31);
signal t1_events                : std_ulogic_vector(0 to 31);
signal t2_events                : std_ulogic_vector(0 to 31);
signal t3_events                : std_ulogic_vector(0 to 31);

signal xu_iu_msr_gs_d           : std_ulogic_vector(0 to 3);
signal xu_iu_msr_gs_q           : std_ulogic_vector(0 to 3);
signal xu_iu_msr_pr_d           : std_ulogic_vector(0 to 3);
signal xu_iu_msr_pr_q           : std_ulogic_vector(0 to 3);
signal event_count_mode_d       : std_ulogic_vector(0 to 2);
signal event_count_mode_q       : std_ulogic_vector(0 to 2);

signal event_en                 : std_ulogic_vector(0 to 3);

signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);

signal tiup                     : std_ulogic;

signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;

signal event_bus_enable_d                   : std_ulogic;
signal event_bus_enable_q                   : std_ulogic;
signal event_mux_ctrls_d                    : std_ulogic_vector(0 to 47);
signal event_mux_ctrls_q                    : std_ulogic_vector(0 to 47);

begin

-----------------------------------------------------------------------
-- Logic
-----------------------------------------------------------------------

tiup <= '1';

----------------------------------------------------
-- t* event list
----------------------------------------------------
-- 0    IL1 miss cycles
-- 1    IL1 reloads dropped
-- 2    reload collisions
-- 3    iu0 redirect
-- 4    ierat miss
-- 5    icache fetch
-- 6    instructions fetched
-- 7    reserved
-- 8    l2 back invalidates icache
-- 9    l2 back invalidates icache hits
-- 10   ibuff empty
-- 11   ibuff flush
-- 12   is1 stall
-- 13   is2 stall
-- 14   barrier stall
-- 15   slowspr stall
-----
-- 16   raw dep hit
-- 17   waw dep hit
-- 18   sync dep hit
-- 19   spr dep hit
-- 20   axu dep hit
-- 21   fxu dep hit
-- 22   axu/fxu dep hit
-- 23   reserved
-- 24   2 instr issue
-- 25   axu priority loss
-- 26   fxu priority loss
-- 27   axu issue
-- 28   fxu issue
-- 29   total issue
-- 30   instruction match issue
-- 31   reserved
----------------------------------------------------

xu_iu_msr_gs_d          <= xu_iu_msr_gs;
xu_iu_msr_pr_d          <= xu_iu_msr_pr;
event_count_mode_d      <= pc_iu_event_count_mode;


event_en(0 to 3)        <= gate(    xu_iu_msr_pr_q(0 to 3)                               , event_count_mode_q(0)) or -- User
                           gate(not xu_iu_msr_pr_q(0 to 3) and     xu_iu_msr_gs_q(0 to 3), event_count_mode_q(1)) or -- Guest Supervisor
                           gate(not xu_iu_msr_pr_q(0 to 3) and not xu_iu_msr_gs_q(0 to 3), event_count_mode_q(2));   -- Hypervisor


t0_events(0 to 31)      <= gate(
                           ic_perf_event_t0(0 to 6) & '0' &
                           ic_perf_event(0 to 1) &
                           ib_perf_event_t0(0 to 1) &
                           fdep_perf_event_t0(0 to 11) &
                           fiss_perf_event_t0(0 to 7),
                           event_en(0));

t1_events(0 to 31)      <= gate(
                           ic_perf_event_t1(0 to 6) & '0' &
                           ic_perf_event(0 to 1) &
                           ib_perf_event_t1(0 to 1) &
                           fdep_perf_event_t1(0 to 11) &
                           fiss_perf_event_t1(0 to 7),
                           event_en(1));

t2_events(0 to 31)      <= gate(
                           ic_perf_event_t2(0 to 6) & '0' &
                           ic_perf_event(0 to 1) &
                           ib_perf_event_t2(0 to 1) &
                           fdep_perf_event_t2(0 to 11) &
                           fiss_perf_event_t2(0 to 7),
                           event_en(2));

t3_events(0 to 31)      <= gate(
                           ic_perf_event_t3(0 to 6) & '0' &
                           ic_perf_event(0 to 1) &
                           ib_perf_event_t3(0 to 1) &
                           fdep_perf_event_t3(0 to 11) &
                           fiss_perf_event_t3(0 to 7),
                           event_en(3));


event_mux1: entity clib.c_event_mux
  generic map ( events_in => 128 )
  port map(vd                   => vdd,
           gd                   => gnd,

           t0_events            => t0_events(0 to 31),
           t1_events            => t1_events(0 to 31),
           t2_events            => t2_events(0 to 31),
           t3_events            => t3_events(0 to 31),

           select_bits          => event_mux_ctrls_q(0 to 47),
           event_bits           => event_data_d(0 to 7)
);


iu_pc_event_data                <= event_data_q(0 to 7);


-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
event_bus_enable_d <= pc_iu_event_bus_enable;
event_mux_ctrls_d  <= pc_iu_event_mux_ctrls;     

event_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_bus_enable_offset),
            scout   => sov(event_bus_enable_offset),
            din     => event_bus_enable_d,
            dout    => event_bus_enable_q);

event_mux_ctrls_reg: tri_rlmreg_p
  generic map (width => event_mux_ctrls_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_mux_ctrls_offset to event_mux_ctrls_offset + event_mux_ctrls_q'length-1),
            scout   => sov(event_mux_ctrls_offset to event_mux_ctrls_offset + event_mux_ctrls_q'length-1),
            din     => event_mux_ctrls_d,
            dout    => event_mux_ctrls_q);

event_data_reg: tri_rlmreg_p
  generic map (width => event_data_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_data_offset to event_data_offset + event_data_q'length-1),
            scout   => sov(event_data_offset to event_data_offset + event_data_q'length-1),
            din     => event_data_d,
            dout    => event_data_q);

event_count_mode_reg: tri_rlmreg_p
  generic map (width => event_count_mode_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_count_mode_offset to event_count_mode_offset + event_count_mode_q'length-1),
            scout   => sov(event_count_mode_offset to event_count_mode_offset + event_count_mode_q'length-1),
            din     => event_count_mode_d,
            dout    => event_count_mode_q);

xu_iu_msr_gs_reg: tri_rlmreg_p
  generic map (width => xu_iu_msr_gs_q'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => event_bus_enable_q,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_msr_gs_offset to xu_iu_msr_gs_offset + xu_iu_msr_gs_q'length-1),
            scout       => sov(xu_iu_msr_gs_offset to xu_iu_msr_gs_offset + xu_iu_msr_gs_q'length-1),
            din         => xu_iu_msr_gs_d,
            dout        => xu_iu_msr_gs_q);

xu_iu_msr_pr_reg: tri_rlmreg_p
  generic map (width => xu_iu_msr_pr_q'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => event_bus_enable_q,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_msr_pr_offset to xu_iu_msr_pr_offset + xu_iu_msr_pr_q'length-1),
            scout       => sov(xu_iu_msr_pr_offset to xu_iu_msr_pr_offset + xu_iu_msr_pr_q'length-1),
            din         => xu_iu_msr_pr_d,
            dout        => xu_iu_msr_pr_q);  


-------------------------------------------------
-- pervasive
-------------------------------------------------

perv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_sg_1);

perv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_sg_0);

perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);

-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);


end iuq_perf;
