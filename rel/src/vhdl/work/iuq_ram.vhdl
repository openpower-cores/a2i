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

library work;
use work.iuq_pkg.all;

entity iuq_ram is
generic(expand_type : integer := 2 ); -- 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
port(
     pc_iu_ram_instr            : in  std_ulogic_vector(0 to 31);
     pc_iu_ram_instr_ext        : in  std_ulogic_vector(0 to 3);
     pc_iu_ram_force_cmplt      : in  std_ulogic;

     xu_iu_ram_issue            : in  std_ulogic_vector(0 to 3);

     rm_ib_iu4_val              : out std_ulogic_vector(0 to 3);
     rm_ib_iu4_force_ram        : out std_ulogic;
     rm_ib_iu4_instr            : out std_ulogic_vector(0 to 35);

     --pervasive
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     pc_iu_sg_2                 : in  std_ulogic;
     pc_iu_func_sl_thold_2      : in  std_ulogic;
     clkoff_b                   : in  std_ulogic;
     act_dis                    : in  std_ulogic;
     tc_ac_ccflush_dc           : in  std_ulogic;
     d_mode                     : in  std_ulogic;
     delay_lclkr                : in  std_ulogic;
     mpw1_b                     : in  std_ulogic;
     mpw2_b                     : in  std_ulogic;
     scan_in                    : in  std_ulogic;
     scan_out                   : out std_ulogic

);

-- synopsys translate_off


-- synopsys translate_on

end iuq_ram;
----
architecture iuq_ram of iuq_ram is

----------------------------
-- constants
----------------------------

--scan chain
constant ram_val_offset         : natural := 0;
constant ram_iss_offset         : natural := ram_val_offset     + 4;
constant ram_instr_offset       : natural := ram_iss_offset     + 4;
constant ram_force_offset       : natural := ram_instr_offset   + 36;
constant scan_right             : natural := ram_force_offset   + 1-1;

----------------------------
-- signals
----------------------------

signal tiup                     : std_ulogic;

signal ram_valid                : std_ulogic;

signal ram_iss_d                : std_ulogic_vector(0 to 3);
signal ram_iss_q                : std_ulogic_vector(0 to 3);
signal ram_val_d                : std_ulogic_vector(0 to 3);
signal ram_val_q                : std_ulogic_vector(0 to 3);
signal ram_instr_d              : std_ulogic_vector(0 to 35);
signal ram_instr_q              : std_ulogic_vector(0 to 35);
signal ram_force_d              : std_ulogic;
signal ram_force_q              : std_ulogic;

signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;

signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);

begin

tiup    <= '1';

-------------------------------------------------
-- logic
-------------------------------------------------




ram_iss_d       <= xu_iu_ram_issue;
ram_val_d       <= ram_iss_q and not ram_iss_d; --detect falling edge of ram issue
ram_valid       <= or_reduce(ram_iss_q);


ram_instr_d     <= pc_iu_ram_instr & pc_iu_ram_instr_ext;
ram_force_d     <= pc_iu_ram_force_cmplt;

-------------------------------------------------
-- outputs
-------------------------------------------------

rm_ib_iu4_val           <= ram_val_q;
rm_ib_iu4_instr         <= ram_instr_q;
rm_ib_iu4_force_ram     <= ram_force_q;

-------------------------------------------------
-- latches
-------------------------------------------------

ram_iss_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type)
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
            scin        => siv(ram_iss_offset to ram_iss_offset+3),
            scout       => sov(ram_iss_offset to ram_iss_offset+3),
            din         => ram_iss_d(0 to 3),
            dout        => ram_iss_q(0 to 3));

ram_val_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type)
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
            scin        => siv(ram_val_offset to ram_val_offset+3),
            scout       => sov(ram_val_offset to ram_val_offset+3),
            din         => ram_val_d(0 to 3),
            dout        => ram_val_q(0 to 3));


ram_instr_reg: tri_rlmreg_p
  generic map (width => 36, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ram_valid,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee       => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(ram_instr_offset to ram_instr_offset+35),
            scout       => sov(ram_instr_offset to ram_instr_offset+35),
            din         => ram_instr_d(0 to 35),
            dout        => ram_instr_q(0 to 35));

ram_force_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ram_valid,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee       => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(ram_force_offset),
            scout       => sov(ram_force_offset),
            din         => ram_force_d,
            dout        => ram_force_q);


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
            forcee       => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);


-------------------------------------------------
-- scan
-------------------------------------------------

siv(0 to scan_right)    <= scan_in & sov(0 to scan_right-1);
scan_out                <= sov(scan_right);


end iuq_ram;
