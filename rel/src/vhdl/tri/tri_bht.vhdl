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

library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;

library support;
use support.power_logic_pkg.all;

library tri;
use tri.tri_latches_pkg.all;


entity tri_bht is
generic(expand_type : integer := 1 ); -- 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
port(
     -- power pins
     gnd                        : inout power_logic;
     vdd                        : inout power_logic;
     vcs                        : inout power_logic;

     -- clock and clockcontrol ports
     nclk                       : in  clk_logic; 
     pc_iu_func_sl_thold_2      : in  std_ulogic;
     pc_iu_sg_2                 : in  std_ulogic;
     pc_iu_time_sl_thold_2      : in  std_ulogic;
     pc_iu_abst_sl_thold_2      : in  std_ulogic;
     pc_iu_ary_nsl_thold_2      : in  std_ulogic;
     pc_iu_repr_sl_thold_2      : in  std_ulogic;
     pc_iu_bolt_sl_thold_2      : in  std_ulogic;
     tc_ac_ccflush_dc           : in  std_ulogic;
     tc_ac_scan_dis_dc_b        : in  std_ulogic;
     clkoff_b                   : in  std_ulogic;
     scan_diag_dc               : in  std_ulogic;
     act_dis                    : in  std_ulogic;
     d_mode                     : in  std_ulogic;
     delay_lclkr                : in  std_ulogic;
     mpw1_b                     : in  std_ulogic;
     mpw2_b                     : in  std_ulogic;
     g8t_clkoff_b               : in  std_ulogic;
     g8t_d_mode                 : in  std_ulogic;
     g8t_delay_lclkr            : in  std_ulogic_vector(0 to 4);
     g8t_mpw1_b                 : in  std_ulogic_vector(0 to 4);
     g8t_mpw2_b                 : in  std_ulogic;
     func_scan_in               : in  std_ulogic;
     time_scan_in               : in  std_ulogic;
     abst_scan_in               : in  std_ulogic;
     repr_scan_in               : in  std_ulogic;
     func_scan_out              : out std_ulogic;
     time_scan_out              : out std_ulogic;
     abst_scan_out              : out std_ulogic;
     repr_scan_out              : out std_ulogic;

     pc_iu_abist_di_0           : in  std_ulogic_vector(0 to 3);
     pc_iu_abist_g8t_bw_1       : in  std_ulogic;
     pc_iu_abist_g8t_bw_0       : in  std_ulogic;
     pc_iu_abist_waddr_0        : in  std_ulogic_vector(3 to 9);
     pc_iu_abist_g8t_wenb       : in  std_ulogic;
     pc_iu_abist_raddr_0        : in  std_ulogic_vector(3 to 9);
     pc_iu_abist_g8t1p_renb_0   : in  std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc: in  std_ulogic;
     pc_iu_abist_ena_dc         : in  std_ulogic;
     pc_iu_abist_wl128_comp_ena : in  std_ulogic;
     pc_iu_abist_raw_dc_b       : in  std_ulogic;
     pc_iu_abist_g8t_dcomp      : in  std_ulogic_vector(0 to 3);

     -- BOLT-ON
     pc_iu_bo_enable_2          : in  std_ulogic; -- general bolt-on enable
     pc_iu_bo_reset             : in  std_ulogic; -- reset
     pc_iu_bo_unload            : in  std_ulogic; -- unload sticky bits
     pc_iu_bo_repair            : in  std_ulogic; -- execute sticky bit decode
     pc_iu_bo_shdata            : in  std_ulogic; -- shift data for timing write and diag loop
     pc_iu_bo_select            : in  std_ulogic; -- select for mask and hier writes
     iu_pc_bo_fail              : out std_ulogic; -- fail/no-fix reg
     iu_pc_bo_diagout           : out std_ulogic;

     -- ports
     r_act                      : in  std_ulogic;
     w_act                      : in  std_ulogic_vector(0 to 3);
     r_addr                     : in  std_ulogic_vector(0 to 7);
     w_addr                     : in  std_ulogic_vector(0 to 7);
     data_in                    : in  std_ulogic_vector(0 to 1);
     data_out0                  : out std_ulogic_vector(0 to 1);
     data_out1                  : out std_ulogic_vector(0 to 1);
     data_out2                  : out std_ulogic_vector(0 to 1);
     data_out3                  : out std_ulogic_vector(0 to 1)

);

-- pragma translate_off


-- pragma translate_on

end tri_bht;
architecture tri_bht of tri_bht is

----------------------------
-- constants
----------------------------

constant data_in_offset                 : natural := 0;
constant w_act_offset                   : natural := data_in_offset     + 2;
constant r_act_offset                   : natural := w_act_offset       + 4;
constant w_addr_offset                  : natural := r_act_offset       + 1;
constant r_addr_offset                  : natural := w_addr_offset      + 8;
constant data_out_offset                : natural := r_addr_offset      + 8;
constant array_offset                   : natural := data_out_offset    + 8;
constant scan_right                     : natural := array_offset       + 1 - 1;

constant INIT_MASK                      : std_ulogic_vector(0 to 1) := "10";

----------------------------
-- signals
----------------------------

signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_time_sl_thold_1    : std_ulogic;
signal pc_iu_time_sl_thold_0    : std_ulogic;
signal pc_iu_ary_nsl_thold_1    : std_ulogic;
signal pc_iu_ary_nsl_thold_0    : std_ulogic;
signal pc_iu_abst_sl_thold_1    : std_ulogic;
signal pc_iu_abst_sl_thold_0    : std_ulogic;
signal pc_iu_repr_sl_thold_1    : std_ulogic;
signal pc_iu_repr_sl_thold_0    : std_ulogic;
signal pc_iu_bolt_sl_thold_1    : std_ulogic;
signal pc_iu_bolt_sl_thold_0    : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;

signal siv              : std_ulogic_vector(0 to scan_right);
signal sov              : std_ulogic_vector(0 to scan_right);

signal tiup             : std_ulogic;

signal data_out_d       : std_ulogic_vector(0 to 7);
signal data_out_q       : std_ulogic_vector(0 to 7);

signal ary_w_en         : std_ulogic;
signal ary_w_addr       : std_ulogic_vector(0 to 6);
signal ary_w_sel        : std_ulogic_vector(0 to 15);
signal ary_w_data       : std_ulogic_vector(0 to 15);

signal ary_r_en         : std_ulogic;
signal ary_r_addr       : std_ulogic_vector(0 to 6);
signal ary_r_data       : std_ulogic_vector(0 to 15);

signal data_out         : std_ulogic_vector(0 to 7);
signal write_thru       : std_ulogic_vector(0 to 3);

signal data_in_d        : std_ulogic_vector(0 to 1);
signal data_in_q        : std_ulogic_vector(0 to 1);
signal w_act_d          : std_ulogic_vector(0 to 3);
signal w_act_q          : std_ulogic_vector(0 to 3);
signal r_act_d          : std_ulogic;
signal r_act_q          : std_ulogic;
signal w_addr_d         : std_ulogic_vector(0 to 7);
signal w_addr_q         : std_ulogic_vector(0 to 7);
signal r_addr_d         : std_ulogic_vector(0 to 7);
signal r_addr_q         : std_ulogic_vector(0 to 7);


begin


tiup    <= '1';


data_out0(0 to 1)       <= data_out_q(0 to 1);
data_out1(0 to 1)       <= data_out_q(2 to 3);
data_out2(0 to 1)       <= data_out_q(4 to 5);
data_out3(0 to 1)       <= data_out_q(6 to 7);


ary_w_en                <= or_reduce(w_act(0 to 3)) and not ((w_addr(1 to 7) = r_addr(1 to 7)) and r_act = '1');

ary_w_addr(0 to 6)      <= w_addr(1 to 7);

ary_w_sel(0)            <= w_act(0) and w_addr(0) = '0';
ary_w_sel(1)            <= w_act(0) and w_addr(0) = '0';
ary_w_sel(2)            <= w_act(1) and w_addr(0) = '0';
ary_w_sel(3)            <= w_act(1) and w_addr(0) = '0';
ary_w_sel(4)            <= w_act(2) and w_addr(0) = '0';
ary_w_sel(5)            <= w_act(2) and w_addr(0) = '0';
ary_w_sel(6)            <= w_act(3) and w_addr(0) = '0';
ary_w_sel(7)            <= w_act(3) and w_addr(0) = '0';
ary_w_sel(8)            <= w_act(0) and w_addr(0) = '1';
ary_w_sel(9)            <= w_act(0) and w_addr(0) = '1';
ary_w_sel(10)           <= w_act(1) and w_addr(0) = '1';
ary_w_sel(11)           <= w_act(1) and w_addr(0) = '1';
ary_w_sel(12)           <= w_act(2) and w_addr(0) = '1';
ary_w_sel(13)           <= w_act(2) and w_addr(0) = '1';
ary_w_sel(14)           <= w_act(3) and w_addr(0) = '1';
ary_w_sel(15)           <= w_act(3) and w_addr(0) = '1';

ary_w_data(0 to 15)     <= (data_in(0 to 1) xor INIT_MASK(0 to 1)) &
                           (data_in(0 to 1) xor INIT_MASK(0 to 1)) &
                           (data_in(0 to 1) xor INIT_MASK(0 to 1)) &
                           (data_in(0 to 1) xor INIT_MASK(0 to 1)) &
                           (data_in(0 to 1) xor INIT_MASK(0 to 1)) &
                           (data_in(0 to 1) xor INIT_MASK(0 to 1)) &
                           (data_in(0 to 1) xor INIT_MASK(0 to 1)) &
                           (data_in(0 to 1) xor INIT_MASK(0 to 1)) ;

ary_r_en                <= r_act;

ary_r_addr(0 to 6)      <= r_addr(1 to 7);

data_out(0 to 7)        <= gate(ary_r_data(0 to 7)  xor (INIT_MASK(0 to 1) & INIT_MASK(0 to 1) & INIT_MASK(0 to 1) & INIT_MASK(0 to 1)), r_addr_q(0) = '0') or
                           gate(ary_r_data(8 to 15) xor (INIT_MASK(0 to 1) & INIT_MASK(0 to 1) & INIT_MASK(0 to 1) & INIT_MASK(0 to 1)), r_addr_q(0) = '1') ;

--write through support

data_in_d(0 to 1)       <= data_in(0 to 1);
w_act_d(0 to 3)         <= w_act(0 to 3);
r_act_d                 <= r_act;
w_addr_d(0 to 7)        <= w_addr(0 to 7);
r_addr_d(0 to 7)        <= r_addr(0 to 7);

write_thru(0 to 3)      <= w_act_q(0 to 3) when (w_addr_q(0 to 7) = r_addr_q(0 to 7)) and r_act_q = '1' else "0000";

data_out_d(0 to 1)      <= data_in_q(0 to 1) when write_thru(0) = '1' else
                           data_out(0 to 1);
data_out_d(2 to 3)      <= data_in_q(0 to 1) when write_thru(1) = '1' else
                           data_out(2 to 3);
data_out_d(4 to 5)      <= data_in_q(0 to 1) when write_thru(2) = '1' else
                           data_out(4 to 5);
data_out_d(6 to 7)      <= data_in_q(0 to 1) when write_thru(3) = '1' else
                           data_out(6 to 7);

-------------------------------------------------
-- array
-------------------------------------------------

bht0: entity tri.tri_128x16_1r1w_1
  generic map ( expand_type => expand_type )
  port map(
           gnd                          => gnd,
           vdd                          => vdd,
           vcs                          => vcs,
           nclk                         => nclk,

           rd_act                       => ary_r_en,              
           wr_act                       => ary_w_en,		    

           lcb_d_mode_dc                => g8t_d_mode,           
           lcb_clkoff_dc_b              => g8t_clkoff_b,      
           lcb_mpw1_dc_b                => g8t_mpw1_b, 
           lcb_mpw2_dc_b                => g8t_mpw2_b,                  
           lcb_delay_lclkr_dc           => g8t_delay_lclkr,
           ccflush_dc                   => tc_ac_ccflush_dc,
           scan_dis_dc_b                => tc_ac_scan_dis_dc_b,
           scan_diag_dc                 => scan_diag_dc,
           func_scan_in                 => siv(array_offset),
           func_scan_out                => sov(array_offset),

           lcb_sg_0                     => pc_iu_sg_0,                      
           lcb_sl_thold_0_b             => pc_iu_func_sl_thold_0_b,     
           lcb_time_sl_thold_0          => pc_iu_time_sl_thold_0,
           lcb_abst_sl_thold_0          => pc_iu_abst_sl_thold_0,
           lcb_ary_nsl_thold_0          => pc_iu_ary_nsl_thold_0,
           lcb_repr_sl_thold_0          => pc_iu_repr_sl_thold_0,
           time_scan_in                 => time_scan_in,
           time_scan_out                => time_scan_out,
           abst_scan_in                 => abst_scan_in,
           abst_scan_out                => abst_scan_out,
           repr_scan_in                 => repr_scan_in,
           repr_scan_out                => repr_scan_out,

           abist_di                     => pc_iu_abist_di_0,
           abist_bw_odd                 => pc_iu_abist_g8t_bw_1,
           abist_bw_even                => pc_iu_abist_g8t_bw_0,
           abist_wr_adr                 => pc_iu_abist_waddr_0,
           wr_abst_act                  => pc_iu_abist_g8t_wenb,
           abist_rd0_adr                => pc_iu_abist_raddr_0,
           rd0_abst_act                 => pc_iu_abist_g8t1p_renb_0,
           tc_lbist_ary_wrt_thru_dc     => an_ac_lbist_ary_wrt_thru_dc,
           abist_ena_1                  => pc_iu_abist_ena_dc,        
           abist_g8t_rd0_comp_ena       => pc_iu_abist_wl128_comp_ena,
           abist_raw_dc_b               => pc_iu_abist_raw_dc_b,
           obs0_abist_cmp               => pc_iu_abist_g8t_dcomp,

           lcb_bolt_sl_thold_0          => pc_iu_bolt_sl_thold_0,
           pc_bo_enable_2               => pc_iu_bo_enable_2,
           pc_bo_reset                  => pc_iu_bo_reset,
           pc_bo_unload                 => pc_iu_bo_unload,
           pc_bo_repair                 => pc_iu_bo_repair,
           pc_bo_shdata                 => pc_iu_bo_shdata,
           pc_bo_select                 => pc_iu_bo_select,
           bo_pc_failout                => iu_pc_bo_fail,
           bo_pc_diagloop               => iu_pc_bo_diagout,

           tri_lcb_mpw1_dc_b            => mpw1_b,
           tri_lcb_mpw2_dc_b            => mpw2_b,
           tri_lcb_delay_lclkr_dc       => delay_lclkr,
           tri_lcb_clkoff_dc_b          => clkoff_b,
           tri_lcb_act_dis_dc           => act_dis,

           bw                           => ary_w_sel,     
           wr_adr                       => ary_w_addr,     
           rd_adr                       => ary_r_addr,     
           di                           => ary_w_data,     
           do                           => ary_r_data
);



-------------------------------------------------
-- latches
-------------------------------------------------

data_in_reg: tri_rlmreg_p
generic map (width => data_in_q'length, init => 0, expand_type => expand_type)
port map (vd          => vdd,
          gd          => gnd,
          nclk        => nclk,
          act         => tiup,
          thold_b     => pc_iu_func_sl_thold_0_b,
          sg          => pc_iu_sg_0,
          forcee       => forcee,
          delay_lclkr => delay_lclkr,
          mpw1_b      => mpw1_b,
          mpw2_b      => mpw2_b,
          d_mode      => d_mode,
          scin        => siv(data_in_offset to data_in_offset + data_in_q'length-1),
          scout       => sov(data_in_offset to data_in_offset + data_in_q'length-1),
          din         => data_in_d,
          dout        => data_in_q);

w_act_reg: tri_rlmreg_p
generic map (width => w_act_q'length, init => 0, expand_type => expand_type)
port map (vd          => vdd,
          gd          => gnd,
          nclk        => nclk,
          act         => tiup,
          thold_b     => pc_iu_func_sl_thold_0_b,
          sg          => pc_iu_sg_0,
          forcee       => forcee,
          delay_lclkr => delay_lclkr,
          mpw1_b      => mpw1_b,
          mpw2_b      => mpw2_b,
          d_mode      => d_mode,
          scin        => siv(w_act_offset to w_act_offset + w_act_q'length-1),
          scout       => sov(w_act_offset to w_act_offset + w_act_q'length-1),
          din         => w_act_d,
          dout        => w_act_q);

r_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type)
port map (vd          => vdd,
          gd          => gnd,
          nclk        => nclk,
          act         => tiup,
          thold_b     => pc_iu_func_sl_thold_0_b,
          sg          => pc_iu_sg_0,
          forcee       => forcee,
          delay_lclkr => delay_lclkr,
          mpw1_b      => mpw1_b,
          mpw2_b      => mpw2_b,
          d_mode      => d_mode,
          scin        => siv(r_act_offset),
          scout       => sov(r_act_offset),
          din         => r_act_d,
          dout        => r_act_q);

w_addr_reg: tri_rlmreg_p
generic map (width => w_addr_q'length, init => 0, expand_type => expand_type)
port map (vd          => vdd,
          gd          => gnd,
          nclk        => nclk,
          act         => tiup,
          thold_b     => pc_iu_func_sl_thold_0_b,
          sg          => pc_iu_sg_0,
          forcee       => forcee,
          delay_lclkr => delay_lclkr,
          mpw1_b      => mpw1_b,
          mpw2_b      => mpw2_b,
          d_mode      => d_mode,
          scin        => siv(w_addr_offset to w_addr_offset + w_addr_q'length-1),
          scout       => sov(w_addr_offset to w_addr_offset + w_addr_q'length-1),
          din         => w_addr_d,
          dout        => w_addr_q);

r_addr_reg: tri_rlmreg_p
generic map (width => r_addr_q'length, init => 0, expand_type => expand_type)
port map (vd          => vdd,
          gd          => gnd,
          nclk        => nclk,
          act         => tiup,
          thold_b     => pc_iu_func_sl_thold_0_b,
          sg          => pc_iu_sg_0,
          forcee       => forcee,
          delay_lclkr => delay_lclkr,
          mpw1_b      => mpw1_b,
          mpw2_b      => mpw2_b,
          d_mode      => d_mode,
          scin        => siv(r_addr_offset to r_addr_offset + r_addr_q'length-1),
          scout       => sov(r_addr_offset to r_addr_offset + r_addr_q'length-1),
          din         => r_addr_d,
          dout        => r_addr_q);


data_out_reg: tri_rlmreg_p
generic map (width => data_out_q'length, init => 0, expand_type => expand_type)
port map (vd          => vdd,
          gd          => gnd,
          nclk        => nclk,
          act         => tiup,
          thold_b     => pc_iu_func_sl_thold_0_b,
          sg          => pc_iu_sg_0,
          forcee       => forcee,
          delay_lclkr => delay_lclkr,
          mpw1_b      => mpw1_b,
          mpw2_b      => mpw2_b,
          d_mode      => d_mode,
          scin        => siv(data_out_offset to data_out_offset + data_out_q'length-1),
          scout       => sov(data_out_offset to data_out_offset + data_out_q'length-1),
          din         => data_out_d,
          dout        => data_out_q);


-------------------------------------------------
-- pervasive
-------------------------------------------------

perv_2to1_reg: tri_plat
  generic map (width => 7, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            din(2)      => pc_iu_time_sl_thold_2,
            din(3)      => pc_iu_abst_sl_thold_2,
            din(4)      => pc_iu_ary_nsl_thold_2,
            din(5)      => pc_iu_repr_sl_thold_2,
            din(6)      => pc_iu_bolt_sl_thold_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_sg_1,
            q(2)        => pc_iu_time_sl_thold_1,
            q(3)        => pc_iu_abst_sl_thold_1,
            q(4)        => pc_iu_ary_nsl_thold_1,
            q(5)        => pc_iu_repr_sl_thold_1,
            q(6)        => pc_iu_bolt_sl_thold_1
);

perv_1to0_reg: tri_plat
  generic map (width => 7, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            din(2)      => pc_iu_time_sl_thold_1,
            din(3)      => pc_iu_abst_sl_thold_1,
            din(4)      => pc_iu_ary_nsl_thold_1,
            din(5)      => pc_iu_repr_sl_thold_1,
            din(6)      => pc_iu_bolt_sl_thold_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_sg_0,
            q(2)        => pc_iu_time_sl_thold_0,
            q(3)        => pc_iu_abst_sl_thold_0,
            q(4)        => pc_iu_ary_nsl_thold_0,
            q(5)        => pc_iu_repr_sl_thold_0,
            q(6)        => pc_iu_bolt_sl_thold_0
);

perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee       => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);


-------------------------------------------------
-- scan
-------------------------------------------------

siv(0 to scan_right)    <= func_scan_in & sov(0 to scan_right-1);
func_scan_out           <= sov(scan_right);


end tri_bht;
