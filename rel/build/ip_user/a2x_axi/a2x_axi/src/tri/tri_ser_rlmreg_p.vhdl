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

library ieee,ibm,support,tri;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;

entity tri_ser_rlmreg_p is
generic (
   width             : positive range 1 to 65536 := 1 ;
   offset            : natural  range 0 to 65535 := 0 ;
   init              : integer := 0;
   ibuf              : boolean := false;
   dualscan          : string  := "";
   needs_sreset      : integer := 1 ;
   expand_type       : integer := 1 );
port (
   vd                : inout power_logic;
   gd                : inout power_logic;
   nclk              : in  clk_logic;
   act               : in  std_ulogic := '1';
   forcee             : in  std_ulogic := '0';
   thold_b           : in  std_ulogic := '1';
   d_mode            : in  std_ulogic := '0';
   sg                : in  std_ulogic := '0';
   delay_lclkr       : in  std_ulogic := '0';
   mpw1_b            : in  std_ulogic := '1';
   mpw2_b            : in  std_ulogic := '1';
   scin              : in  std_ulogic_vector(offset to offset+width-1);
   din               : in  std_ulogic_vector(offset to offset+width-1);
   scout             : out std_ulogic_vector(offset to offset+width-1);
   dout              : out std_ulogic_vector(offset to offset+width-1));

  -- synopsys translate_off
  -- synopsys translate_on

end entity tri_ser_rlmreg_p;

architecture tri_ser_rlmreg_p of tri_ser_rlmreg_p is

signal dout_b, act_buf, act_buf_b, dout_buf  : std_ulogic_vector(offset to offset+width-1);

begin
   
act_buf     <= (others=>act);
act_buf_b   <= (others=>not(act));
dout_buf    <= not dout_b;
dout        <= dout_buf;

tri_ser_rlmreg_p : entity tri.tri_aoi22_nlats_wlcb(tri_aoi22_nlats_wlcb)
  generic map (
            width   => width,
            offset  => offset,
            init    => init,
            ibuf    => ibuf,
            dualscan=> dualscan,
            expand_type => expand_type,
            needs_sreset => needs_sreset)
  port map (nclk    => nclk, vd => vd, gd => gd,
            act     => act,
            forcee   => forcee,
            d_mode  => d_mode, delay_lclkr => delay_lclkr,
            mpw1_b  => mpw1_b, mpw2_b  => mpw2_b,
            thold_b => thold_b,
            sg      => sg,
            scin    => scin,
            scout   => scout,
            A1      => din,
            A2      => act_buf,
            B1      => dout_buf,
            B2      => act_buf_b,
            QB      => dout_b);

end tri_ser_rlmreg_p;
