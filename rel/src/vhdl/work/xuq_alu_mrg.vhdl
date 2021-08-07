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

--  Description:  XU Rotate/Logical/ALU merge Unit
--
library work,ieee,ibm,support,tri;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;

entity xuq_alu_mrg is
   generic(
      expand_type : integer := 2);
   port (
      nclk                             : in  clk_logic;
      vdd                              : inout power_logic;
      gnd                              : inout power_logic;
      d_mode_dc                        : in  std_ulogic;
      delay_lclkr_dc                   : in  std_ulogic;
      mpw1_dc_b                        : in  std_ulogic;
      mpw2_dc_b                        : in  std_ulogic;
      func_sl_force : in  std_ulogic;
      func_sl_thold_0_b                : in  std_ulogic;
      sg_0                             : in  std_ulogic;
      scan_in                          : in  std_ulogic;
      scan_out                         : out std_ulogic;

      rf1_act                          : in  std_ulogic;
      ex1_act                          : in  std_ulogic;

      dec_alu_rf1_zm_ins               : in  std_ulogic ;
      dec_alu_rf1_mb_ins               : in  std_ulogic_vector(0 to 5);
      dec_alu_rf1_me_ins_b             : in  std_ulogic_vector(0 to 5);
      dec_alu_rf1_sh_amt               : in  std_ulogic_vector(0 to 5);
      dec_alu_rf1_sh_right             : in  std_ulogic;
      dec_alu_rf1_sh_word              : in  std_ulogic;


      dec_alu_rf1_use_rb_amt_hi        : in  std_ulogic;
      dec_alu_rf1_use_rb_amt_lo        : in  std_ulogic;
      dec_alu_rf1_use_me_rb_hi         : in  std_ulogic;
      dec_alu_rf1_use_me_rb_lo         : in  std_ulogic;
      dec_alu_rf1_use_mb_rb_hi         : in  std_ulogic;
      dec_alu_rf1_use_mb_rb_lo         : in  std_ulogic;
      dec_alu_rf1_use_me_ins_hi        : in  std_ulogic;
      dec_alu_rf1_use_me_ins_lo        : in  std_ulogic;
      dec_alu_rf1_use_mb_ins_hi        : in  std_ulogic;
      dec_alu_rf1_use_mb_ins_lo        : in  std_ulogic;

      dec_alu_rf1_chk_shov_wd          : in  std_ulogic;
      dec_alu_rf1_chk_shov_dw          : in  std_ulogic;
      dec_alu_rf1_mb_gt_me             : in  std_ulogic;

      dec_alu_rf1_cmp_byt              : in  std_ulogic;

      dec_alu_rf1_sgnxtd_byte          : in  std_ulogic;
      dec_alu_rf1_sgnxtd_half          : in  std_ulogic;
      dec_alu_rf1_sgnxtd_wd            : in  std_ulogic;
      dec_alu_rf1_sra_wd               : in  std_ulogic;
      dec_alu_rf1_sra_dw               : in  std_ulogic;

      byp_alu_rf1_isel_fcn             : in  std_ulogic_vector(0 to 3);
      dec_alu_rf1_log_fcn              : in  std_ulogic_vector(0 to 3);
      dec_alu_rf1_sel_rot_log          : in  std_ulogic;

      byp_alu_ex1_rs0_b                : in  std_ulogic_vector(0 to 63); --rb/ra
      byp_alu_ex1_rs1_b                : in  std_ulogic_vector(0 to 63); --rs
      add_mrg_ex1_add_rt               : in  std_ulogic_vector(0 to 63);
      mrg_add_ex2_rt                   : out std_ulogic_vector(0 to 63);
      alu_byp_ex1_log_rt               : out std_ulogic_vector(0 to 63);

      ex2_mrg_xer_ca                   : out std_ulogic

    );
-- synopsys translate_off
-- synopsys translate_on

end xuq_alu_mrg;

architecture xuq_alu_mrg of xuq_alu_mrg is

-- Latches
signal ex1_mb_ins_q                                : std_ulogic_vector(0 to 5);  -- input=>dec_alu_rf1_mb_ins           ,act=>rf1_act    -- ins_mb
signal ex1_me_ins_b_q                              : std_ulogic_vector(0 to 5);  -- input=>dec_alu_rf1_me_ins_b         ,act=>rf1_act    -- ins_me_b
signal ex1_sh_amt_q                                : std_ulogic_vector(0 to 5);  -- input=>dec_alu_rf1_sh_amt           ,act=>rf1_act    -- ins_amt
signal ex1_sh_right_q,        rf1_sh_right         : std_ulogic_vector(0 to 2);  -- input=>dec_alu_rf1_sh_rgt           ,act=>rf1_act    -- ins_rgt
signal ex1_sh_word_q,         rf1_sh_word          : std_ulogic_vector(0 to 1);  -- input=>dec_alu_rf1_sh_word          ,act=>rf1_act    -- ins_word
signal ex1_zm_ins_q                                : std_ulogic;                 -- input=>dec_alu_rf1_zm_ins           ,act=>rf1_act    -- ins_word_dly
signal ex1_chk_shov_wd_q                           : std_ulogic;                 -- input=>dec_alu_rf1_chk_shov_wd      ,act=>rf1_act    -- ins_zm
signal ex1_chk_shov_dw_q                           : std_ulogic;                 -- input=>dec_alu_rf1_chk_shov_dw      ,act=>rf1_act    -- chk_shov_wd
signal ex1_use_sh_amt_hi_q,   rf1_use_sh_amt_hi    : std_ulogic;                 --                                      act=>rf1_act    -- chk_shov_dw
signal ex1_use_sh_amt_lo_q,   rf1_use_sh_amt_lo    : std_ulogic;                 --                                      act=>rf1_act    -- use_ins_amt_din(0)
signal ex1_use_rb_amt_hi_q                         : std_ulogic;                 -- input=>dec_alu_rf1_use_rb_amt_hi    ,act=>rf1_act    -- use_ins_amt_din(1)
signal ex1_use_rb_amt_lo_q                         : std_ulogic;                 -- input=>dec_alu_rf1_use_rb_amt_lo    ,act=>rf1_act    -- use_rb_amt_din(0)
signal ex1_use_me_rb_hi_q                          : std_ulogic;                 -- input=>dec_alu_rf1_use_me_rb_hi     ,act=>rf1_act    -- use_rb_amt_din(1)
signal ex1_use_me_rb_lo_q                          : std_ulogic;                 -- input=>dec_alu_rf1_use_me_rb_lo     ,act=>rf1_act    -- use_mb_i(0)
signal ex1_use_mb_rb_hi_q                          : std_ulogic;                 -- input=>dec_alu_rf1_use_mb_rb_hi     ,act=>rf1_act    -- use_mb_i(1)
signal ex1_use_mb_rb_lo_q                          : std_ulogic;                 -- input=>dec_alu_rf1_use_mb_rb_lo     ,act=>rf1_act    -- use_me_i(0)
signal ex1_use_me_ins_hi_q                         : std_ulogic;                 -- input=>dec_alu_rf1_use_me_ins_hi    ,act=>rf1_act    -- use_me_i(1)
signal ex1_use_me_ins_lo_q                         : std_ulogic;                 -- input=>dec_alu_rf1_use_me_ins_lo    ,act=>rf1_act    -- use_ins_mb_i(0)
signal ex1_use_mb_ins_hi_q                         : std_ulogic;                 -- input=>dec_alu_rf1_use_mb_ins_hi    ,act=>rf1_act    -- use_ins_mb_i(1)
signal ex1_use_mb_ins_lo_q                         : std_ulogic;                 -- input=>dec_alu_rf1_use_mb_ins_lo    ,act=>rf1_act    -- use_ins_me_i(0)
signal ex1_mb_gt_me_q                              : std_ulogic;                 -- input=>dec_alu_rf1_mb_gt_me         ,act=>rf1_act    -- use_ins_me_i(1)
signal ex1_cmp_byte_q                              : std_ulogic;                 -- input=>dec_alu_rf1_cmp_byt          ,act=>rf1_act    -- mb_gt_me
signal ex1_sgnxtd_byte_q                           : std_ulogic;                 -- input=>dec_alu_rf1_sgnxtd_byte      ,act=>rf1_act    -- ins_cmp_byt_i
signal ex1_sgnxtd_half_q                           : std_ulogic;                 -- input=>dec_alu_rf1_sgnxtd_half      ,act=>rf1_act    -- ins_xtd_byte_i
signal ex1_sgnxtd_wd_q                             : std_ulogic;                 -- input=>dec_alu_rf1_sgnxtd_wd        ,act=>rf1_act    -- ins_xtd_half_i
signal ex1_sra_wd_q                                : std_ulogic;                 -- input=>dec_alu_rf1_sra_wd           ,act=>rf1_act    -- ins_xtd_wd_i
signal ex1_sra_dw_q                                : std_ulogic;                 -- input=>dec_alu_rf1_sra_dw           ,act=>rf1_act    -- ins_sra_wd_i
signal ex1_log_fcn_q,        rf1_log_fcn           : std_ulogic_vector(0 to 3);  -- input=>rf1_log_fcn                  ,act=>rf1_act    -- ins_sra_dw_i
signal ex1_sel_rot_log_q                           : std_ulogic;                 -- input=>dec_alu_rf1_sel_rot_log      ,act=>rf1_act    -- ins_log_fcn_i
signal ex2_sh_word_q                               : std_ulogic;                 -- input=>ex1_sh_word_q(1)             ,act=>ex1_act    -- ins_sel_mrg_i
signal ex2_rotate_b_q,       ex1_result            : std_ulogic_vector(0 to 63); --                                      act=>ex1_act
signal ex2_result_b_q,       ex1_rotate            : std_ulogic_vector(0 to 63); --                                      act=>ex1_act
signal ex2_mask_b_q,         ex1_mask              : std_ulogic_vector(0 to 63); --                                      act=>ex1_act
signal ex2_sra_se_q,         ex1_sra_se_b          : std_ulogic_vector(0 to 0);  --                                      act=>ex1_act
signal dummy_q                                     : std_ulogic_vector(0 to 0);
-- Scanchains
constant ex1_mb_ins_offset                         : integer := 0;
constant ex1_me_ins_b_offset                       : integer := ex1_mb_ins_offset              + ex1_mb_ins_q'length;
constant ex1_sh_amt_offset                         : integer := ex1_me_ins_b_offset            + ex1_me_ins_b_q'length;
constant ex1_sh_right_offset                       : integer := ex1_sh_amt_offset              + ex1_sh_amt_q'length;
constant ex1_sh_word_offset                        : integer := ex1_sh_right_offset            + ex1_sh_right_q'length;
constant ex1_zm_ins_offset                         : integer := ex1_sh_word_offset             + ex1_sh_word_q'length;
constant ex1_chk_shov_wd_offset                    : integer := ex1_zm_ins_offset              + 1;
constant ex1_chk_shov_dw_offset                    : integer := ex1_chk_shov_wd_offset         + 1;
constant ex1_use_sh_amt_hi_offset                  : integer := ex1_chk_shov_dw_offset         + 1;
constant ex1_use_sh_amt_lo_offset                  : integer := ex1_use_sh_amt_hi_offset       + 1;
constant ex1_use_rb_amt_hi_offset                  : integer := ex1_use_sh_amt_lo_offset       + 1;
constant ex1_use_rb_amt_lo_offset                  : integer := ex1_use_rb_amt_hi_offset       + 1;
constant ex1_use_me_rb_hi_offset                   : integer := ex1_use_rb_amt_lo_offset       + 1;
constant ex1_use_me_rb_lo_offset                   : integer := ex1_use_me_rb_hi_offset        + 1;
constant ex1_use_mb_rb_hi_offset                   : integer := ex1_use_me_rb_lo_offset        + 1;
constant ex1_use_mb_rb_lo_offset                   : integer := ex1_use_mb_rb_hi_offset        + 1;
constant ex1_use_me_ins_hi_offset                  : integer := ex1_use_mb_rb_lo_offset        + 1;
constant ex1_use_me_ins_lo_offset                  : integer := ex1_use_me_ins_hi_offset       + 1;
constant ex1_use_mb_ins_hi_offset                  : integer := ex1_use_me_ins_lo_offset       + 1;
constant ex1_use_mb_ins_lo_offset                  : integer := ex1_use_mb_ins_hi_offset       + 1;
constant ex1_mb_gt_me_offset                       : integer := ex1_use_mb_ins_lo_offset       + 1;
constant ex1_cmp_byte_offset                       : integer := ex1_mb_gt_me_offset            + 1;
constant ex1_sgnxtd_byte_offset                    : integer := ex1_cmp_byte_offset            + 1;
constant ex1_sgnxtd_half_offset                    : integer := ex1_sgnxtd_byte_offset         + 1;
constant ex1_sgnxtd_wd_offset                      : integer := ex1_sgnxtd_half_offset         + 1;
constant ex1_sra_wd_offset                         : integer := ex1_sgnxtd_wd_offset           + 1;
constant ex1_sra_dw_offset                         : integer := ex1_sra_wd_offset              + 1;
constant ex1_log_fcn_offset                        : integer := ex1_sra_dw_offset              + 1;
constant ex1_sel_rot_log_offset                    : integer := ex1_log_fcn_offset             + ex1_log_fcn_q'length;
constant ex2_sh_word_offset                        : integer := ex1_sel_rot_log_offset         + 1;
constant ex2_rotate_b_offset                       : integer := ex2_sh_word_offset             + 1;
constant ex2_result_b_offset                       : integer := ex2_rotate_b_offset            + ex2_rotate_b_q'length;
constant ex2_mask_b_offset                         : integer := ex2_result_b_offset            + ex2_result_b_q'length;
constant ex2_sra_se_offset                         : integer := ex2_mask_b_offset              + ex2_mask_b_q'length;
constant dummy_offset                              : integer := ex2_sra_se_offset              + ex2_sra_se_q'length;
constant scan_right                                : integer := dummy_offset                   + dummy_q'length;
signal siv                                         : std_ulogic_vector(0 to scan_right-1);
signal sov                                         : std_ulogic_vector(0 to scan_right-1);
signal tidn                                              : std_ulogic;
signal rot_lclk_int                                      : clk_logic;
signal rot_d1clk_int, rot_d2clk_int                      : std_ulogic;
signal ex1_zm                                            : std_ulogic;
signal ex1_use_sh_amt,  ex1_use_rb_amt                   : std_ulogic_vector(0 to 5);   
signal ex1_use_me_rb,   ex1_use_mb_rb                    : std_ulogic_vector(0 to 5);   
signal ex1_use_me_ins,  ex1_use_mb_ins                   : std_ulogic_vector(0 to 5);   
signal ex1_sh_amt0_b,   ex1_sh_amt1_b,    ex1_sh_amt     : std_ulogic_vector(0 to 5);
signal ex1_mb0_b,       ex1_mb1_b,        ex1_mb         : std_ulogic_vector(0 to 5);
signal ex1_me0,         ex1_me1,          ex1_me_b       : std_ulogic_vector(0 to 5);
signal ex1_mask_b,      ex1_insert                       : std_ulogic_vector(0 to 63);
signal ex1_sel_add                                       : std_ulogic;
signal ex1_msk_rot_b,   ex1_msk_ins_b,    ex1_msk_rot    : std_ulogic_vector(0 to 63);
signal ex1_msk_ins                                       : std_ulogic_vector(0 to 63);
signal ex1_result_0_b,  ex1_result_1_b,   ex1_result_2_b : std_ulogic_vector(0 to 63);
signal ca_root_b                                         : std_ulogic_vector(0 to 63);
signal ca_or_hi, ca_or_lo                                : std_ulogic;
signal ex1_act_unqiue                                    : std_ulogic;
signal ex1_ins_rs0, ex1_ins_rs1, ex1_rot_rs0             : std_ulogic_vector(0 to 63);
signal ex1_rot_rs1                                       : std_ulogic_vector(57 to 63);
signal ex2_result_q,    ex2_rotate_q                     : std_ulogic_vector(0 to 63);


begin

tidn <= '0';

rf1_sh_right         <= (0 to 2=>dec_alu_rf1_sh_right);
rf1_sh_word          <= (0 to 1=>dec_alu_rf1_sh_word);
rf1_use_sh_amt_hi    <= not dec_alu_rf1_use_rb_amt_hi;
rf1_use_sh_amt_lo    <= not dec_alu_rf1_use_rb_amt_lo;

---------------------------------------------------------------------
-- Source Buffering
---------------------------------------------------------------------
u_rot_s0_pass:    ex1_ins_rs0       <= not byp_alu_ex1_rs0_b;
u_rot_s1_pass:    ex1_ins_rs1       <= not byp_alu_ex1_rs1_b;
u_rot_s0:         ex1_rot_rs0       <= not byp_alu_ex1_rs0_b;
u_rot_s1:         ex1_rot_rs1       <= not byp_alu_ex1_rs1_b(57 to 63);

---------------------------------------------------------------------
-- Rotator / merge control generation
---------------------------------------------------------------------
ex1_use_sh_amt <= ex1_use_sh_amt_hi_q & (1 to 5=>ex1_use_sh_amt_lo_q);
ex1_use_rb_amt <= ex1_use_rb_amt_hi_q & (1 to 5=>ex1_use_rb_amt_lo_q);
ex1_use_me_rb  <= ex1_use_me_rb_hi_q  & (1 to 5=>ex1_use_me_rb_lo_q);
ex1_use_mb_rb  <= ex1_use_mb_rb_hi_q  & (1 to 5=>ex1_use_mb_rb_lo_q);
ex1_use_me_ins <= ex1_use_me_ins_hi_q & (1 to 5=>ex1_use_me_ins_lo_q);
ex1_use_mb_ins <= ex1_use_mb_ins_hi_q & (1 to 5=>ex1_use_mb_ins_lo_q);

ex1_zm         <= (ex1_zm_ins_q                         ) or     -- instr does not use the rotator (dont care if adder used)
                  (ex1_chk_shov_wd_q and ex1_rot_rs1(58)) or     --       word shift with amount from RB <amount shifts out all the bits>
                  (ex1_chk_shov_dw_q and ex1_rot_rs1(57));       -- doubleword shift with amount from RB <amount shifts out all the bits>


u_shamt0:      ex1_sh_amt0_b     <= ex1_rot_rs1(58 to 63)     nand ex1_use_rb_amt;
u_shamt1:      ex1_sh_amt1_b     <= ex1_sh_amt_q              nand ex1_use_sh_amt;

u_shamt:       ex1_sh_amt        <= ex1_sh_amt0_b nand ex1_sh_amt1_b;


u_mbamt0:      ex1_mb0_b         <= ex1_rot_rs1(58 to 63)     nand ex1_use_mb_rb;
u_mbamt1:      ex1_mb1_b         <= ex1_mb_ins_q              nand ex1_use_mb_ins;

u_mbamt:       ex1_mb            <= ex1_mb0_b nand ex1_mb1_b;


u_meamt0:      ex1_me0           <= ex1_rot_rs1(58 to 63)     nand ex1_use_me_rb;
u_meamt1:      ex1_me1           <= ex1_me_ins_b_q            nand ex1_use_me_ins;

u_meamt:       ex1_me_b          <= ex1_me0 nand ex1_me1;


---------------------------------------------------------------------
-- Mask unit
---------------------------------------------------------------------
msk: entity work.xuq_alu_mask(xuq_alu_mask)
   generic map (expand_type => expand_type)
   port map(
      mb                   => ex1_mb,
      me_b                 => ex1_me_b,
      zm                   => ex1_zm,
      mb_gt_me             => ex1_mb_gt_me_q,
      mask                 => ex1_mask);

---------------------------------------------------------------------
-- Insert data (includes logicals, sign extend, cmpb)
---------------------------------------------------------------------
rf1_log_fcn    <= dec_alu_rf1_log_fcn or byp_alu_rf1_isel_fcn;

ins: entity work.xuq_alu_ins(xuq_alu_ins)
   generic map (expand_type => expand_type)
   port map(
      ins_log_fcn          => ex1_log_fcn_q,
      ins_cmp_byt          => ex1_cmp_byte_q,
      ins_sra_dw           => ex1_sra_dw_q,
      ins_sra_wd           => ex1_sra_wd_q,
      ins_xtd_byte         => ex1_sgnxtd_byte_q, 
      ins_xtd_half         => ex1_sgnxtd_half_q, 
      ins_xtd_wd           => ex1_sgnxtd_wd_q,   
      data0_i              => ex1_ins_rs0,
      data1_i              => ex1_ins_rs1,
      mrg_byp_log          => alu_byp_ex1_log_rt,
      res_ins              => ex1_insert );

---------------------------------------------------------------------
-- Rotate unit
---------------------------------------------------------------------
rol64: entity work.xuq_alu_rol64(xuq_alu_rol64)
   generic map (expand_type => expand_type)
   port map(
      word                 => ex1_sh_word_q,
      right                => ex1_sh_right_q,
      amt                  => ex1_sh_amt,
      data_i               => ex1_rot_rs0,
      res_rot              => ex1_rotate);
      

---------------------------------------------------------------------
-- Final muxing
---------------------------------------------------------------------
u_msk_inv:     ex1_mask_b        <= not ex1_mask;
u_seladd:      ex1_sel_add       <= not ex1_sel_rot_log_q;

u_selrotb:     ex1_msk_rot_b     <= ex1_mask   nand (0 to 63=> ex1_sel_rot_log_q);
u_selinsb:     ex1_msk_ins_b     <= ex1_mask_b nand (0 to 63=> ex1_sel_rot_log_q);

u_selrot:      ex1_msk_rot       <= not ex1_msk_rot_b;
u_selins:      ex1_msk_ins       <= not ex1_msk_ins_b;

u_res_din0:    ex1_result_0_b    <= ex1_rotate nand ex1_msk_rot;
u_res_din1:    ex1_result_1_b    <= ex1_insert nand ex1_msk_ins;
u_res_din2:    ex1_result_2_b    <= add_mrg_ex1_add_rt nand (0 to 63=> ex1_sel_add);
u_res_din:     ex1_result        <= not(ex1_result_0_b and ex1_result_1_b and ex1_result_2_b);

u_res_q:       ex2_result_q      <= not ex2_result_b_q;

mrg_add_ex2_rt <= ex2_result_q;

---------------------------------------------------------------------
-- CA Generation
---------------------------------------------------------------------
caor: entity work.xuq_alu_caor(xuq_alu_caor)
   generic map (expand_type => expand_type)
   port map(
      ca_root_b            => ca_root_b,
      ca_or_hi             => ca_or_hi,
      ca_or_lo             => ca_or_lo);

u_rot_inv:  ex2_rotate_q   <= not ex2_rotate_b_q;
u_ca_root:  ca_root_b      <= not(ex2_rotate_q and ex2_mask_b_q);

ex1_sra_se_b(0)<= not((ex1_ins_rs0(0)  and not ex1_sh_word_q(0)) or
                      (ex1_ins_rs0(32) and     ex1_sh_word_q(0)));

ex2_mrg_xer_ca <= ( ca_or_lo              and ex2_sra_se_q(0)  and     ex2_sh_word_q) or
                  ((ca_or_lo or ca_or_hi) and ex2_sra_se_q(0)  and not ex2_sh_word_q);
                  

-- To generate a unique LCB for placement
ex1_act_unqiue <= ex1_act or dummy_q(0);

---------------------------------------------------------------------
-- Latch Instances
---------------------------------------------------------------------
ex1_mb_ins_latch : tri_rlmreg_p
  generic map (width => ex1_mb_ins_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_mb_ins_offset to ex1_mb_ins_offset + ex1_mb_ins_q'length-1),
            scout   => sov(ex1_mb_ins_offset to ex1_mb_ins_offset + ex1_mb_ins_q'length-1),
            din     => dec_alu_rf1_mb_ins,
            dout    => ex1_mb_ins_q);
ex1_me_ins_b_latch : tri_rlmreg_p
  generic map (width => ex1_me_ins_b_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_me_ins_b_offset to ex1_me_ins_b_offset + ex1_me_ins_b_q'length-1),
            scout   => sov(ex1_me_ins_b_offset to ex1_me_ins_b_offset + ex1_me_ins_b_q'length-1),
            din     => dec_alu_rf1_me_ins_b,
            dout    => ex1_me_ins_b_q);
ex1_sh_amt_latch : tri_rlmreg_p
  generic map (width => ex1_sh_amt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sh_amt_offset to ex1_sh_amt_offset + ex1_sh_amt_q'length-1),
            scout   => sov(ex1_sh_amt_offset to ex1_sh_amt_offset + ex1_sh_amt_q'length-1),
            din     => dec_alu_rf1_sh_amt,
            dout    => ex1_sh_amt_q);
ex1_sh_right_latch : tri_rlmreg_p
  generic map (width => ex1_sh_right_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sh_right_offset to ex1_sh_right_offset + ex1_sh_right_q'length-1),
            scout   => sov(ex1_sh_right_offset to ex1_sh_right_offset + ex1_sh_right_q'length-1),
            din     => rf1_sh_right,
            dout    => ex1_sh_right_q);
ex1_sh_word_latch : tri_rlmreg_p
  generic map (width => ex1_sh_word_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sh_word_offset to ex1_sh_word_offset + ex1_sh_word_q'length-1),
            scout   => sov(ex1_sh_word_offset to ex1_sh_word_offset + ex1_sh_word_q'length-1),
            din     => rf1_sh_word,
            dout    => ex1_sh_word_q);
ex1_zm_ins_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_zm_ins_offset),
            scout   => sov(ex1_zm_ins_offset),
            din     => dec_alu_rf1_zm_ins,
            dout    => ex1_zm_ins_q);
ex1_chk_shov_wd_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_chk_shov_wd_offset),
            scout   => sov(ex1_chk_shov_wd_offset),
            din     => dec_alu_rf1_chk_shov_wd,
            dout    => ex1_chk_shov_wd_q);
ex1_chk_shov_dw_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_chk_shov_dw_offset),
            scout   => sov(ex1_chk_shov_dw_offset),
            din     => dec_alu_rf1_chk_shov_dw,
            dout    => ex1_chk_shov_dw_q);
ex1_use_sh_amt_hi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_sh_amt_hi_offset),
            scout   => sov(ex1_use_sh_amt_hi_offset),
            din     => rf1_use_sh_amt_hi,
            dout    => ex1_use_sh_amt_hi_q);
ex1_use_sh_amt_lo_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_sh_amt_lo_offset),
            scout   => sov(ex1_use_sh_amt_lo_offset),
            din     => rf1_use_sh_amt_lo,
            dout    => ex1_use_sh_amt_lo_q);
ex1_use_rb_amt_hi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_rb_amt_hi_offset),
            scout   => sov(ex1_use_rb_amt_hi_offset),
            din     => dec_alu_rf1_use_rb_amt_hi,
            dout    => ex1_use_rb_amt_hi_q);
ex1_use_rb_amt_lo_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_rb_amt_lo_offset),
            scout   => sov(ex1_use_rb_amt_lo_offset),
            din     => dec_alu_rf1_use_rb_amt_lo,
            dout    => ex1_use_rb_amt_lo_q);
ex1_use_me_rb_hi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_me_rb_hi_offset),
            scout   => sov(ex1_use_me_rb_hi_offset),
            din     => dec_alu_rf1_use_me_rb_hi,
            dout    => ex1_use_me_rb_hi_q);
ex1_use_me_rb_lo_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_me_rb_lo_offset),
            scout   => sov(ex1_use_me_rb_lo_offset),
            din     => dec_alu_rf1_use_me_rb_lo,
            dout    => ex1_use_me_rb_lo_q);
ex1_use_mb_rb_hi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_mb_rb_hi_offset),
            scout   => sov(ex1_use_mb_rb_hi_offset),
            din     => dec_alu_rf1_use_mb_rb_hi,
            dout    => ex1_use_mb_rb_hi_q);
ex1_use_mb_rb_lo_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_mb_rb_lo_offset),
            scout   => sov(ex1_use_mb_rb_lo_offset),
            din     => dec_alu_rf1_use_mb_rb_lo,
            dout    => ex1_use_mb_rb_lo_q);
ex1_use_me_ins_hi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_me_ins_hi_offset),
            scout   => sov(ex1_use_me_ins_hi_offset),
            din     => dec_alu_rf1_use_me_ins_hi,
            dout    => ex1_use_me_ins_hi_q);
ex1_use_me_ins_lo_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_me_ins_lo_offset),
            scout   => sov(ex1_use_me_ins_lo_offset),
            din     => dec_alu_rf1_use_me_ins_lo,
            dout    => ex1_use_me_ins_lo_q);
ex1_use_mb_ins_hi_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_mb_ins_hi_offset),
            scout   => sov(ex1_use_mb_ins_hi_offset),
            din     => dec_alu_rf1_use_mb_ins_hi,
            dout    => ex1_use_mb_ins_hi_q);
ex1_use_mb_ins_lo_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_mb_ins_lo_offset),
            scout   => sov(ex1_use_mb_ins_lo_offset),
            din     => dec_alu_rf1_use_mb_ins_lo,
            dout    => ex1_use_mb_ins_lo_q);
ex1_mb_gt_me_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_mb_gt_me_offset),
            scout   => sov(ex1_mb_gt_me_offset),
            din     => dec_alu_rf1_mb_gt_me,
            dout    => ex1_mb_gt_me_q);
ex1_cmp_byte_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cmp_byte_offset),
            scout   => sov(ex1_cmp_byte_offset),
            din     => dec_alu_rf1_cmp_byt,
            dout    => ex1_cmp_byte_q);
ex1_sgnxtd_byte_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sgnxtd_byte_offset),
            scout   => sov(ex1_sgnxtd_byte_offset),
            din     => dec_alu_rf1_sgnxtd_byte,
            dout    => ex1_sgnxtd_byte_q);
ex1_sgnxtd_half_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sgnxtd_half_offset),
            scout   => sov(ex1_sgnxtd_half_offset),
            din     => dec_alu_rf1_sgnxtd_half,
            dout    => ex1_sgnxtd_half_q);
ex1_sgnxtd_wd_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sgnxtd_wd_offset),
            scout   => sov(ex1_sgnxtd_wd_offset),
            din     => dec_alu_rf1_sgnxtd_wd,
            dout    => ex1_sgnxtd_wd_q);
ex1_sra_wd_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sra_wd_offset),
            scout   => sov(ex1_sra_wd_offset),
            din     => dec_alu_rf1_sra_wd,
            dout    => ex1_sra_wd_q);
ex1_sra_dw_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sra_dw_offset),
            scout   => sov(ex1_sra_dw_offset),
            din     => dec_alu_rf1_sra_dw,
            dout    => ex1_sra_dw_q);
ex1_log_fcn_latch : tri_rlmreg_p
  generic map (width => ex1_log_fcn_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_log_fcn_offset to ex1_log_fcn_offset + ex1_log_fcn_q'length-1),
            scout   => sov(ex1_log_fcn_offset to ex1_log_fcn_offset + ex1_log_fcn_q'length-1),
            din     => rf1_log_fcn,
            dout    => ex1_log_fcn_q);
ex1_sel_rot_log_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_sel_rot_log_offset),
            scout   => sov(ex1_sel_rot_log_offset),
            din     => dec_alu_rf1_sel_rot_log,
            dout    => ex1_sel_rot_log_q);
ex2_sh_word_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_sh_word_offset),
            scout   => sov(ex2_sh_word_offset),
            din     => ex1_sh_word_q(1),
            dout    => ex2_sh_word_q);
---------------------------------------------------------------------
-- Placed Latches
---------------------------------------------------------------------
ex2_mrg_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => ex1_act_unqiue,
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => rot_lclk_int,
            d1clk       => rot_d1clk_int,
            d2clk       => rot_d2clk_int);

rot_lat : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => ex2_rotate_b_q'length, expand_type => expand_type, btr => "NLI0001_X1_A12TH", init=>(ex2_rotate_b_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => rot_lclk_int,
            D1CLK   => rot_d1clk_int,
            D2CLK   => rot_d2clk_int,
            SCANIN  => siv(ex2_rotate_b_offset to ex2_rotate_b_offset + ex2_rotate_b_q'length-1),
            SCANOUT => sov(ex2_rotate_b_offset to ex2_rotate_b_offset + ex2_rotate_b_q'length-1),
            D       => ex1_rotate,
            QB      => ex2_rotate_b_q);
res_lat : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => ex2_result_b_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(ex2_result_b_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => rot_lclk_int,
            D1CLK   => rot_d1clk_int,
            D2CLK   => rot_d2clk_int,
            SCANIN  => siv(ex2_result_b_offset to ex2_result_b_offset + ex2_result_b_q'length-1),
            SCANOUT => sov(ex2_result_b_offset to ex2_result_b_offset + ex2_result_b_q'length-1),
            D       => ex1_result,
            QB      => ex2_result_b_q);
msk_lat : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => ex2_mask_b_q'length, expand_type => expand_type, btr => "NLI0001_X1_A12TH", init=>(ex2_mask_b_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => rot_lclk_int,
            D1CLK   => rot_d1clk_int,
            D2CLK   => rot_d2clk_int,
            SCANIN  => siv(ex2_mask_b_offset to ex2_mask_b_offset + ex2_mask_b_q'length-1),
            SCANOUT => sov(ex2_mask_b_offset to ex2_mask_b_offset + ex2_mask_b_q'length-1),
            D       => ex1_mask,
            QB      => ex2_mask_b_q);
---------------------------------------------------------------------
-- End Placed Latches
---------------------------------------------------------------------
ex2_sra_se_latch : entity tri.tri_inv_nlats_wlcb(tri_inv_nlats_wlcb)
  generic map (width => ex2_sra_se_q'length, init => 0, expand_type => expand_type, needs_sreset => 1, btr => "NLI0001_X1_A12TH")
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_sra_se_offset to ex2_sra_se_offset + ex2_sra_se_q'length-1),
            scout   => sov(ex2_sra_se_offset to ex2_sra_se_offset + ex2_sra_se_q'length-1),
            D       => ex1_sra_se_b,
            QB      => ex2_sra_se_q);

dummy_latch : tri_rlmreg_p
  generic map (width => dummy_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tidn,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dummy_offset to dummy_offset + dummy_q'length-1),
            scout   => sov(dummy_offset to dummy_offset + dummy_q'length-1),
            din     => dummy_q,
            dout    => dummy_q);
            
siv(0 to scan_right-1)        <= sov(1 to scan_right-1) & scan_in;
scan_out                      <= sov(0);


end architecture xuq_alu_mrg;
