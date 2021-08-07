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

--  Description:  XU SPR - Wrapper
--
library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;

entity xuq_fxu_spr is
generic(
   hvmode                           :     integer := 1;
   a2mode                           :     integer := 1;
   expand_type                      :     integer := 2;
   threads                          :     integer := 4;
   regsize                          :     integer := 64;
   eff_ifar                         :     integer := 62);
port(
   nclk                             : in  clk_logic;
   
   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;

   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   func_nsl_force : in  std_ulogic;
   func_nsl_thold_0_b               : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;

   -- Decode
   ex1_tid                          : in  std_ulogic_vector(0 to threads-1);
   ex1_instr                        : in  std_ulogic_vector(11 to 20);
   dec_spr_ex1_is_mfspr             : in  std_ulogic;
   dec_spr_ex1_is_mtspr             : in  std_ulogic;

   -- Write Interface
   ex6_val                          : in  std_ulogic_vector(0 to threads-1);
   ex6_spr_wd                       : in  std_ulogic_vector(64-regsize to 63);

   -- Read Data
   fspr_byp_ex3_spr_rt              : out std_ulogic_vector(64-regsize to 63);
   mux_spr_ex2_rt                   : in std_ulogic_vector(64-regsize to 63);

   ex2_is_any_load_dac              : in  std_ulogic;
   ex2_is_any_store_dac             : in  std_ulogic;

   -- DAC
   xu_lsu_ex4_dvc1_en               : out std_ulogic;
   xu_lsu_ex4_dvc2_en               : out std_ulogic;
   -- For Stores only, not gated by dvc*_en
   lsu_xu_ex2_dvc1_st_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_ex2_dvc2_st_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   -- For load hits only, gated by dvc*_en
   lsu_xu_ex8_dvc1_ld_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_ex8_dvc2_ld_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   -- For reloads only, all signals are gated by dvc*_en
   lsu_xu_rel_dvc1_en               : in  std_ulogic;
   lsu_xu_rel_dvc2_en               : in  std_ulogic;
   lsu_xu_rel_dvc_thrd_id           : in  std_ulogic_vector(0 to 3);
   lsu_xu_rel_dvc1_cmp              : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_rel_dvc2_cmp              : in  std_ulogic_vector(8-regsize/8 to 7);       

   fxu_cpl_ex3_dac1r_cmpr_async     : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2r_cmpr_async     : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac1r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac3r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac4r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac1w_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2w_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac3w_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac4w_cmpr           : out std_ulogic_vector(0 to threads-1);
   
   -- SPRs
   spr_bit_act                      : in  std_ulogic;
   spr_msr_pr                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_ds                       : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr0_dac1                   : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr0_dac2                   : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr0_dac3                   : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr0_dac4                   : in  std_ulogic_vector(0 to 2*threads-1);

	spr_dbcr3_ivc                    : out std_ulogic_vector(0 to threads-1);

   -- Power
   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_fxu_spr;
architecture xuq_fxu_spr of xuq_fxu_spr is


signal siv                             : std_ulogic_vector(0 to threads);
signal sov                             : std_ulogic_vector(0 to threads);
-- Signals
signal cspr_tspr_ex6_is_mtspr          : std_ulogic;
signal cspr_tspr_ex6_instr             : std_ulogic_vector(11 to 20);
signal cspr_tspr_ex2_instr             : std_ulogic_vector(11 to 20);
signal tspr_cspr_ex2_tspr_rt           : std_ulogic_vector(0 to regsize*threads-1);
signal tspr_cspr_dbcr2_dac1us          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr2_dac1er          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr2_dac2us          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr2_dac2er          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr3_dac3us          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr3_dac3er          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr3_dac4us          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr3_dac4er          : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr2_dac12m          : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_dbcr3_dac34m          : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_dbcr2_dvc1m           : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr2_dvc2m           : std_ulogic_vector(0 to 2*threads-1);
signal tspr_cspr_dbcr2_dvc1be          : std_ulogic_vector(0 to 8*threads-1);
signal tspr_cspr_dbcr2_dvc2be          : std_ulogic_vector(0 to 8*threads-1);

begin


xu_fxu_spr_cspr : entity work.xuq_fxu_spr_cspr(xuq_fxu_spr_cspr)
generic map(
   hvmode                           => hvmode,
   a2mode                           => a2mode,
   expand_type                      => expand_type,
   threads                          => threads,
   regsize                          => regsize,
   eff_ifar                         => eff_ifar)
port map(
   nclk                             => nclk,
   d_mode_dc                        => d_mode_dc,
   delay_lclkr_dc                   => delay_lclkr_dc,
   mpw1_dc_b                        => mpw1_dc_b,
   mpw2_dc_b                        => mpw2_dc_b,
   func_sl_force => func_sl_force,
   func_sl_thold_0_b                => func_sl_thold_0_b,
   func_nsl_force => func_nsl_force,
   func_nsl_thold_0_b               => func_nsl_thold_0_b,
   sg_0                             => sg_0,
   scan_in                          => siv(threads),
   scan_out                         => sov(threads),
   -- Decode
   ex1_instr                        => ex1_instr,
   ex1_tid                          => ex1_tid,
   dec_spr_ex1_is_mfspr             => dec_spr_ex1_is_mfspr,
   dec_spr_ex1_is_mtspr             => dec_spr_ex1_is_mtspr,
   -- Write Interface
   ex6_valid                        => ex6_val,
   ex6_spr_wd                       => ex6_spr_wd,
   -- SPRT Interface
   cspr_tspr_ex6_is_mtspr           => cspr_tspr_ex6_is_mtspr,
   cspr_tspr_ex6_instr              => cspr_tspr_ex6_instr,
   cspr_tspr_ex2_instr              => cspr_tspr_ex2_instr,
   -- Read Data
   tspr_cspr_ex2_tspr_rt            => tspr_cspr_ex2_tspr_rt,
   fspr_byp_ex3_spr_rt              => fspr_byp_ex3_spr_rt,
   mux_spr_ex2_rt                   => mux_spr_ex2_rt,
   ex2_is_any_load_dac              => ex2_is_any_load_dac,
   ex2_is_any_store_dac             => ex2_is_any_store_dac,
   -- DAC
   xu_lsu_ex4_dvc1_en               => xu_lsu_ex4_dvc1_en,
   xu_lsu_ex4_dvc2_en               => xu_lsu_ex4_dvc2_en,
   lsu_xu_ex2_dvc1_st_cmp           => lsu_xu_ex2_dvc1_st_cmp,
   lsu_xu_ex2_dvc2_st_cmp           => lsu_xu_ex2_dvc2_st_cmp,
   lsu_xu_ex8_dvc1_ld_cmp           => lsu_xu_ex8_dvc1_ld_cmp,
   lsu_xu_ex8_dvc2_ld_cmp           => lsu_xu_ex8_dvc2_ld_cmp,
   lsu_xu_rel_dvc1_en               => lsu_xu_rel_dvc1_en,
   lsu_xu_rel_dvc2_en               => lsu_xu_rel_dvc2_en,
   lsu_xu_rel_dvc_thrd_id           => lsu_xu_rel_dvc_thrd_id,
   lsu_xu_rel_dvc1_cmp              => lsu_xu_rel_dvc1_cmp,
   lsu_xu_rel_dvc2_cmp              => lsu_xu_rel_dvc2_cmp,
   fxu_cpl_ex3_dac1r_cmpr_async     => fxu_cpl_ex3_dac1r_cmpr_async,
   fxu_cpl_ex3_dac2r_cmpr_async     => fxu_cpl_ex3_dac2r_cmpr_async,
   fxu_cpl_ex3_dac1r_cmpr           => fxu_cpl_ex3_dac1r_cmpr,
   fxu_cpl_ex3_dac2r_cmpr           => fxu_cpl_ex3_dac2r_cmpr,
   fxu_cpl_ex3_dac3r_cmpr           => fxu_cpl_ex3_dac3r_cmpr,
   fxu_cpl_ex3_dac4r_cmpr           => fxu_cpl_ex3_dac4r_cmpr,
   fxu_cpl_ex3_dac1w_cmpr           => fxu_cpl_ex3_dac1w_cmpr,
   fxu_cpl_ex3_dac2w_cmpr           => fxu_cpl_ex3_dac2w_cmpr,
   fxu_cpl_ex3_dac3w_cmpr           => fxu_cpl_ex3_dac3w_cmpr,
   fxu_cpl_ex3_dac4w_cmpr           => fxu_cpl_ex3_dac4w_cmpr,
   -- SPRs
   spr_bit_act                      => spr_bit_act,
   spr_msr_pr                       => spr_msr_pr,
   spr_msr_ds                       => spr_msr_ds,
   spr_dbcr0_dac1                   => spr_dbcr0_dac1,
   spr_dbcr0_dac2                   => spr_dbcr0_dac2,
   spr_dbcr0_dac3                   => spr_dbcr0_dac3,
   spr_dbcr0_dac4                   => spr_dbcr0_dac4,
   tspr_cspr_dbcr2_dac1us           => tspr_cspr_dbcr2_dac1us,
   tspr_cspr_dbcr2_dac1er           => tspr_cspr_dbcr2_dac1er,
   tspr_cspr_dbcr2_dac2us           => tspr_cspr_dbcr2_dac2us,
   tspr_cspr_dbcr2_dac2er           => tspr_cspr_dbcr2_dac2er,
   tspr_cspr_dbcr3_dac3us           => tspr_cspr_dbcr3_dac3us,
   tspr_cspr_dbcr3_dac3er           => tspr_cspr_dbcr3_dac3er,
   tspr_cspr_dbcr3_dac4us           => tspr_cspr_dbcr3_dac4us,
   tspr_cspr_dbcr3_dac4er           => tspr_cspr_dbcr3_dac4er,
   tspr_cspr_dbcr2_dac12m           => tspr_cspr_dbcr2_dac12m,
   tspr_cspr_dbcr3_dac34m           => tspr_cspr_dbcr3_dac34m,
   tspr_cspr_dbcr2_dvc1m            => tspr_cspr_dbcr2_dvc1m,
   tspr_cspr_dbcr2_dvc2m            => tspr_cspr_dbcr2_dvc2m,
   tspr_cspr_dbcr2_dvc1be           => tspr_cspr_dbcr2_dvc1be,
   tspr_cspr_dbcr2_dvc2be           => tspr_cspr_dbcr2_dvc2be,

   -- Power
   vdd                              => vdd,
   gnd                              => gnd
);

thread : for t in 0 to threads-1 generate
xu_fxu_spr_tspr : entity work.xuq_fxu_spr_tspr(xuq_fxu_spr_tspr)
generic map(
   hvmode                           => hvmode,
   a2mode                           => a2mode,
   expand_type                      => expand_type,
   regsize                          => regsize,
   eff_ifar                         => eff_ifar)
port map(
   nclk                             => nclk,
   d_mode_dc                        => d_mode_dc,
   delay_lclkr_dc                   => delay_lclkr_dc,
   mpw1_dc_b                        => mpw1_dc_b,
   mpw2_dc_b                        => mpw2_dc_b,
   func_sl_force => func_sl_force,
   func_sl_thold_0_b                => func_sl_thold_0_b,
   sg_0                             => sg_0,
   scan_in                          => siv(t),
   scan_out                         => sov(t),
   -- Read Interface
   cspr_tspr_ex2_instr              => cspr_tspr_ex2_instr,
   tspr_cspr_ex2_tspr_rt            => tspr_cspr_ex2_tspr_rt(regsize*t to regsize*(t+1)-1),
   -- Write Interface
   ex6_val                          => ex6_val(t),
   cspr_tspr_ex6_is_mtspr           => cspr_tspr_ex6_is_mtspr,
   cspr_tspr_ex6_instr              => cspr_tspr_ex6_instr,
   ex6_spr_wd                       => ex6_spr_wd,
   -- SPRs
   tspr_cspr_dbcr2_dac1us           => tspr_cspr_dbcr2_dac1us(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr2_dac1er           => tspr_cspr_dbcr2_dac1er(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr2_dac2us           => tspr_cspr_dbcr2_dac2us(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr2_dac2er           => tspr_cspr_dbcr2_dac2er(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr3_dac3us           => tspr_cspr_dbcr3_dac3us(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr3_dac3er           => tspr_cspr_dbcr3_dac3er(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr3_dac4us           => tspr_cspr_dbcr3_dac4us(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr3_dac4er           => tspr_cspr_dbcr3_dac4er(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr2_dac12m           => tspr_cspr_dbcr2_dac12m(t),
   tspr_cspr_dbcr3_dac34m           => tspr_cspr_dbcr3_dac34m(t),
   tspr_cspr_dbcr2_dvc1m            => tspr_cspr_dbcr2_dvc1m(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr2_dvc2m            => tspr_cspr_dbcr2_dvc2m(2*t to 2*(t+1)-1),
   tspr_cspr_dbcr2_dvc1be           => tspr_cspr_dbcr2_dvc1be(8*t to 8*(t+1)-1),
   tspr_cspr_dbcr2_dvc2be           => tspr_cspr_dbcr2_dvc2be(8*t to 8*(t+1)-1),
	spr_dbcr3_ivc                    => spr_dbcr3_ivc(t),
   -- Power
   vdd                              => vdd,
   gnd                              => gnd
);
end generate;

siv(0 to threads)                   <= sov(1 to threads)      & scan_in;
scan_out                            <= sov(0);

end architecture xuq_fxu_spr;

