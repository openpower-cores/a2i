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

library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;

entity xuq_cpl_spr is
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

   dcfg_sl_force : in  std_ulogic;
   dcfg_sl_thold_0_b                : in  std_ulogic;
   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   func_nsl_force : in  std_ulogic;
   func_nsl_thold_0_b               : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;
   dcfg_scan_in                     : in  std_ulogic;
   dcfg_scan_out                    : out std_ulogic;

   spr_bit_act                      : in  std_ulogic;
   exx_act                          : in  std_ulogic_vector(1 to 4);
   ex1_instr                        : in  std_ulogic_vector(11 to 20);
   ex2_tid                          : in  std_ulogic_vector(0 to threads-1);
   ex1_is_mfspr                     : in  std_ulogic;
   ex1_is_mtspr                     : in  std_ulogic;
   ex4_lr_update                    : in  std_ulogic;
   ex4_ctr_dec_update               : in  std_ulogic;

   ex2_ifar                         : in  std_ulogic_vector(0 to eff_ifar*threads-1);

   ex5_val                          : in  std_ulogic_vector(0 to threads-1);
   ex5_spr_wd                       : in  std_ulogic_vector(64-regsize to 63);
   ex5_cia_p1                       : in  std_ulogic_vector(62-eff_ifar to 61);

   ex2_mtiar                        : out std_ulogic;

   cpl_byp_ex3_spr_rt               : out std_ulogic_vector(64-regsize to 63);
   

   ex3_iac1_cmpr                    : out std_ulogic_vector(0 to threads-1);
   ex3_iac2_cmpr                    : out std_ulogic_vector(0 to threads-1);
   ex3_iac3_cmpr                    : out std_ulogic_vector(0 to threads-1);
   ex3_iac4_cmpr                    : out std_ulogic_vector(0 to threads-1);

   spr_cpl_iac1_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac2_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac3_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac4_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr1_iac12m                 : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr1_iac34m                 : in  std_ulogic_vector(0 to threads-1);
   spr_iar                          : in  std_ulogic_vector(0 to eff_ifar*threads-1);
   spr_msr_cm                       : in  std_ulogic_vector(0 to threads-1);
	spr_givpr                        : out std_ulogic_vector(0 to eff_ifar-10-1);
	spr_ivpr                         : out std_ulogic_vector(0 to eff_ifar-10-1);
	spr_xucr3_hold1_dly              : out std_ulogic_vector(0 to 3);
	spr_xucr3_cm_hold_dly            : out std_ulogic_vector(0 to 3);
	spr_xucr3_stop_dly               : out std_ulogic_vector(0 to 3);
	spr_xucr3_hold0_dly              : out std_ulogic_vector(0 to 3);
	spr_xucr3_csi_dly                : out std_ulogic_vector(0 to 3);
	spr_xucr3_int_dly                : out std_ulogic_vector(0 to 3);
	spr_xucr3_asyncblk_dly           : out std_ulogic_vector(0 to 3);
	spr_xucr3_flush_dly              : out std_ulogic_vector(0 to 3);
	spr_xucr4_mmu_mchk               : out std_ulogic;
	spr_xucr4_mddmh                  : out std_ulogic;
	spr_xucr4_div_barr_thres         : out std_ulogic_vector(0 to 7);
	spr_xucr4_div_bar_dis            : out std_ulogic;
	spr_xucr4_lsu_bar_dis            : out std_ulogic;
	spr_xucr4_barr_dly               : out std_ulogic_vector(0 to 3);
	spr_ctr                          : out std_ulogic_vector(0 to (regsize)*threads-1);
	spr_lr                           : out std_ulogic_vector(0 to (regsize)*threads-1);

   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_cpl_spr;
architecture xuq_cpl_spr of xuq_cpl_spr is


signal siv                             : std_ulogic_vector(0 to threads);
signal sov                             : std_ulogic_vector(0 to threads);
signal cspr_tspr_ex5_is_mtspr          : std_ulogic;
signal cspr_tspr_ex5_instr             : std_ulogic_vector(11 to 20);
signal cspr_tspr_ex2_instr             : std_ulogic_vector(11 to 20);
signal tspr_cspr_ex2_tspr_rt           : std_ulogic_vector(0 to regsize*threads-1);

begin

xu_cpl_spr_cspr : entity work.xuq_cpl_spr_cspr(xuq_cpl_spr_cspr)
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
   dcfg_sl_force => dcfg_sl_force,
   dcfg_sl_thold_0_b                => dcfg_sl_thold_0_b,
   func_sl_force => func_sl_force,
   func_sl_thold_0_b                => func_sl_thold_0_b,
   func_nsl_force => func_nsl_force,
   func_nsl_thold_0_b               => func_nsl_thold_0_b,
   sg_0                             => sg_0,
   scan_in                          => siv(threads),
   scan_out                         => sov(threads),
   dcfg_scan_in                     => dcfg_scan_in,
   dcfg_scan_out                    => dcfg_scan_out,
   spr_bit_act                      => spr_bit_act,
   exx_act                          => exx_act,
   ex1_instr                        => ex1_instr,
   ex2_tid                          => ex2_tid,
   ex1_is_mfspr                     => ex1_is_mfspr,
   ex1_is_mtspr                     => ex1_is_mtspr,
   ex2_ifar                         => ex2_ifar,
   ex5_valid                        => ex5_val,
   ex5_spr_wd                       => ex5_spr_wd,
   ex2_mtiar                        => ex2_mtiar,
   cspr_tspr_ex5_is_mtspr           => cspr_tspr_ex5_is_mtspr,
   cspr_tspr_ex5_instr              => cspr_tspr_ex5_instr,
   cspr_tspr_ex2_instr              => cspr_tspr_ex2_instr,
   tspr_cspr_ex2_tspr_rt            => tspr_cspr_ex2_tspr_rt,
   cpl_byp_ex3_spr_rt               => cpl_byp_ex3_spr_rt,
   ex3_iac1_cmpr                    => ex3_iac1_cmpr,
   ex3_iac2_cmpr                    => ex3_iac2_cmpr,
   ex3_iac3_cmpr                    => ex3_iac3_cmpr,
   ex3_iac4_cmpr                    => ex3_iac4_cmpr,
   spr_cpl_iac1_en                  => spr_cpl_iac1_en,
   spr_cpl_iac2_en                  => spr_cpl_iac2_en,
   spr_cpl_iac3_en                  => spr_cpl_iac3_en,
   spr_cpl_iac4_en                  => spr_cpl_iac4_en,
   spr_dbcr1_iac12m                 => spr_dbcr1_iac12m,
   spr_dbcr1_iac34m                 => spr_dbcr1_iac34m,
   spr_msr_cm                       => spr_msr_cm,
	spr_givpr                        => spr_givpr,
	spr_ivpr                         => spr_ivpr,
	spr_xucr3_hold1_dly              => spr_xucr3_hold1_dly,
	spr_xucr3_cm_hold_dly            => spr_xucr3_cm_hold_dly,
	spr_xucr3_stop_dly               => spr_xucr3_stop_dly,
	spr_xucr3_hold0_dly              => spr_xucr3_hold0_dly,
	spr_xucr3_csi_dly                => spr_xucr3_csi_dly,
	spr_xucr3_int_dly                => spr_xucr3_int_dly,
	spr_xucr3_asyncblk_dly           => spr_xucr3_asyncblk_dly,
	spr_xucr3_flush_dly              => spr_xucr3_flush_dly,
	spr_xucr4_mmu_mchk               => spr_xucr4_mmu_mchk,
	spr_xucr4_mddmh                  => spr_xucr4_mddmh,
	spr_xucr4_div_barr_thres         => spr_xucr4_div_barr_thres,
	spr_xucr4_div_bar_dis            => spr_xucr4_div_bar_dis,
	spr_xucr4_lsu_bar_dis            => spr_xucr4_lsu_bar_dis,
	spr_xucr4_barr_dly               => spr_xucr4_barr_dly,
   vdd                              => vdd,
   gnd                              => gnd
);

thread : for t in 0 to threads-1 generate
xu_cpl_spr_tspr : entity work.xuq_cpl_spr_tspr(xuq_cpl_spr_tspr)
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
   cspr_tspr_ex2_instr              => cspr_tspr_ex2_instr,
   tspr_cspr_ex2_tspr_rt            => tspr_cspr_ex2_tspr_rt(regsize*t to regsize*(t+1)-1),
   ex5_val                          => ex5_val(t),
   cspr_tspr_ex5_is_mtspr           => cspr_tspr_ex5_is_mtspr,
   cspr_tspr_ex5_instr              => cspr_tspr_ex5_instr,
   ex5_spr_wd                       => ex5_spr_wd,
   ex5_cia_p1                       => ex5_cia_p1,
   ex4_lr_update                    => ex4_lr_update,
   ex4_ctr_dec_update               => ex4_ctr_dec_update,
   spr_iar                          => spr_iar(eff_ifar*t to eff_ifar*(t+1)-1),
	spr_ctr                          => spr_ctr((regsize)*t to (regsize)*(t+1)-1),
	spr_lr                           => spr_lr((regsize)*t to (regsize)*(t+1)-1),
   vdd                              => vdd,
   gnd                              => gnd
);
end generate;

siv(0 to threads)                   <= sov(1 to threads)      & scan_in;
scan_out                            <= sov(0);


end architecture xuq_cpl_spr;
