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


entity iuq_dbg is
generic(expand_type             : integer := 2 );
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     pc_iu_func_slp_sl_thold_2  : in std_ulogic;
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

     fiss_dbg_data              : in std_ulogic_vector(0 to 87);
     fdep_dbg_data              : in std_ulogic_vector(0 to 87);
     ib_dbg_data                : in std_ulogic_vector(0 to 63);
     bp_dbg_data0               : in std_ulogic_vector(0 to 87);
     bp_dbg_data1               : in std_ulogic_vector(0 to 87);
     fu_iss_dbg_data            : in std_ulogic_vector(0 to 23);
     axu_dbg_data_t0            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t1            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t2            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t3            : in std_ulogic_vector(0 to 37);
     bht_dbg_data               : in std_ulogic_vector(0 to 31);

     pc_iu_trace_bus_enable     : in  std_ulogic;
     pc_iu_debug_mux_ctrls      : in  std_ulogic_vector(0 to 15);

     debug_data_in              : in  std_ulogic_vector(0 to 87);
     trace_triggers_in          : in  std_ulogic_vector(0 to 11);

     debug_data_out             : out std_ulogic_vector(0 to 87);
     trace_triggers_out         : out std_ulogic_vector(0 to 11)
);

  -- synopsys translate_off


  -- synopsys translate_on
end iuq_dbg;


architecture iuq_dbg of iuq_dbg is

signal trigger_data_out_d       : std_ulogic_vector(0 to 11);
signal trigger_data_out_q       : std_ulogic_vector(0 to 11);
signal trace_data_out_d         : std_ulogic_vector(0 to 87);
signal trace_data_out_q         : std_ulogic_vector(0 to 87);

constant trigger_data_out_offset: natural := 0;
constant trace_data_out_offset  : natural := trigger_data_out_offset        + trigger_data_out_q'length;
constant trace_bus_enable_offset: natural := trace_data_out_offset          + trace_data_out_q'length;
constant debug_mux_ctrls_offset : natural := trace_bus_enable_offset        + 1;
constant scan_right             : natural := debug_mux_ctrls_offset         + 16-1;





signal dbg_group0         : std_ulogic_vector(0 to 87);
signal dbg_group1         : std_ulogic_vector(0 to 87);
signal dbg_group2         : std_ulogic_vector(0 to 87);
signal dbg_group3         : std_ulogic_vector(0 to 87);
signal dbg_group4         : std_ulogic_vector(0 to 87);
signal dbg_group5         : std_ulogic_vector(0 to 87);
signal dbg_group6         : std_ulogic_vector(0 to 87);
signal dbg_group7         : std_ulogic_vector(0 to 87);

signal trg_group0         : std_ulogic_vector(0 to 11);
signal trg_group1         : std_ulogic_vector(0 to 11);
signal trg_group2         : std_ulogic_vector(0 to 11);
signal trg_group3         : std_ulogic_vector(0 to 11);

signal siv                : std_ulogic_vector(0 to scan_right);
signal sov                : std_ulogic_vector(0 to scan_right);

signal tiup                     : std_ulogic;

signal pc_iu_func_slp_sl_thold_1        : std_ulogic;
signal pc_iu_func_slp_sl_thold_0        : std_ulogic;
signal pc_iu_func_slp_sl_thold_0_b      : std_ulogic;
signal pc_iu_sg_1                       : std_ulogic;
signal pc_iu_sg_0                       : std_ulogic;
signal forcee                            : std_ulogic;

signal trace_bus_enable_d               : std_ulogic;
signal trace_bus_enable_q               : std_ulogic;
signal debug_mux_ctrls_d                : std_ulogic_vector(0 to 15);
signal debug_mux_ctrls_q                : std_ulogic_vector(0 to 15);

begin


tiup <= '1';









dbg_group0              <= bp_dbg_data0(0 to 87);
dbg_group1              <= bp_dbg_data1(0 to 87); 
dbg_group2              <= ib_dbg_data(0 to 63) & fu_iss_dbg_data(0 to 23); 
dbg_group3              <= fdep_dbg_data(0 to 87); 
dbg_group4              <= fiss_dbg_data(0 to 87); 
dbg_group5(0 to 75)     <= axu_dbg_data_t0(0 to 37) & axu_dbg_data_t1(0 to 37); 
dbg_group6(0 to 75)     <= axu_dbg_data_t2(0 to 37) & axu_dbg_data_t3(0 to 37); 
dbg_group7(0 to 31)     <= bht_dbg_data(0 to 31);

dbg_group5(76 to 87)    <= (others => '0'); 
dbg_group6(76 to 87)    <= (others => '0'); 
dbg_group7(32 to 87)    <= (others => '0'); 

trg_group0              <= ib_dbg_data(0)  & ib_dbg_data( 4 to  5) & 
                           ib_dbg_data(16) & ib_dbg_data(20 to 21) & 
                           ib_dbg_data(32) & ib_dbg_data(36 to 37) & 
                           ib_dbg_data(48) & ib_dbg_data(52 to 53) ; 

trg_group1              <= fiss_dbg_data(0 to 7) &      
                           fiss_dbg_data(44 to 45) &    
                           bp_dbg_data0(84 to 85);      

trg_group2              <= fdep_dbg_data(14) & fdep_dbg_data(36) & fdep_dbg_data(58) & fdep_dbg_data(80) & 
                           bht_dbg_data(27 to 31) &     
                           bp_dbg_data1(84 to 86) ;     

trg_group3              <= axu_dbg_data_t0(10) & 
                           axu_dbg_data_t1(10) & 
                           axu_dbg_data_t2(10) & 
                           axu_dbg_data_t3(10) & 
                           axu_dbg_data_t0(21) & 
                           axu_dbg_data_t1(21) & 
                           axu_dbg_data_t2(21) & 
                           axu_dbg_data_t3(21) & 
                           fu_iss_dbg_data(20) & 
                           fu_iss_dbg_data(21) & 
                           fu_iss_dbg_data(22) & 
                           fu_iss_dbg_data(23) ; 
                           

dbg_mux0: entity clib.c_debug_mux8
  port map(
     vd              => vdd,
     gd              => gnd,

     select_bits     => debug_mux_ctrls_q,
     trace_data_in   => debug_data_in,
     trigger_data_in => trace_triggers_in,
                      
     dbg_group0      => dbg_group0,
     dbg_group1      => dbg_group1,
     dbg_group2      => dbg_group2,
     dbg_group3      => dbg_group3,
     dbg_group4      => dbg_group4,
     dbg_group5      => dbg_group5,
     dbg_group6      => dbg_group6,
     dbg_group7      => dbg_group7,
                      
     trg_group0      => trg_group0,
     trg_group1      => trg_group1,
     trg_group2      => trg_group2,
     trg_group3      => trg_group3,
                      
     trace_data_out  => trace_data_out_d,
     trigger_data_out=> trigger_data_out_d
);

trace_triggers_out      <= trigger_data_out_q;
debug_data_out          <= trace_data_out_q;

trace_bus_enable_d <= pc_iu_trace_bus_enable;
debug_mux_ctrls_d  <= pc_iu_debug_mux_ctrls;

trace_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => trace_bus_enable_d,
            dout    => trace_bus_enable_q);

debug_mux_ctrls_reg: tri_rlmreg_p
  generic map (width => debug_mux_ctrls_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            scout   => sov(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            din     => debug_mux_ctrls_d,
            dout    => debug_mux_ctrls_q);

trigger_data_reg: tri_rlmreg_p
  generic map (width => trigger_data_out_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            scout   => sov(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            din     => trigger_data_out_d,
            dout    => trigger_data_out_q);

trace_data_reg: tri_rlmreg_p
  generic map (width => trace_data_out_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trace_data_out_offset to trace_data_out_offset + trace_data_out_q'length-1),
            scout   => sov(trace_data_out_offset to trace_data_out_offset + trace_data_out_q'length-1),
            din     => trace_data_out_d,
            dout    => trace_data_out_q);


perv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_slp_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            q(0)        => pc_iu_func_slp_sl_thold_1,
            q(1)        => pc_iu_sg_1);

perv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_slp_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            q(0)        => pc_iu_func_slp_sl_thold_0,
            q(1)        => pc_iu_sg_0);

perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_slp_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => forcee,
            thold_b     => pc_iu_func_slp_sl_thold_0_b);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);


end iuq_dbg;
