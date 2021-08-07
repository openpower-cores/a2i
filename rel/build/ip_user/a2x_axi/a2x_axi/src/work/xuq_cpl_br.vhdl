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
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_cpl_br is
generic(
   expand_type                      :     integer :=  2;
   threads                          :     integer :=  4;
   eff_ifar                         :     integer := 62;
    uc_ifar                         :     integer := 21;
   regsize                          :     integer := 64);
port(
   nclk                             : in  clk_logic;

   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   func_sl_force : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;

   rf1_act                          : in  std_ulogic;
   ex1_act                          : in  std_ulogic;
   
   rf1_tid                          : in  std_ulogic_vector(0 to threads-1);
   ex1_tid                          : in  std_ulogic_vector(0 to threads-1);
   ex1_xu_val                       : in  std_ulogic_vector(0 to threads-1);

   dec_cpl_rf1_ifar                 : in  std_ulogic_vector(62-eff_ifar to 61);
   ex1_xu_ifar                      : out std_ulogic_vector(62-eff_ifar to 61);

   dec_cpl_rf1_pred_taken_cnt       : in  std_ulogic;
   dec_cpl_rf1_instr                : in  std_ulogic_vector(0 to 31);

   byp_cpl_ex1_cr_bit               : in  std_ulogic;
   spr_lr                           : in  std_ulogic_vector(0 to regsize*threads-1);
   spr_ctr                          : in  std_ulogic_vector(0 to regsize*threads-1);

   ex2_br_flush                     : out std_ulogic_vector(0 to threads-1);
   ex2_br_flush_ifar                : out std_ulogic_vector(62-eff_ifar to 61);
   
   ex1_branch                       : out std_ulogic;
   ex1_br_mispred                   : out std_ulogic;
   ex1_br_taken                     : out std_ulogic;
   ex1_br_update                    : out std_ulogic;
   ex1_is_bcctr                     : out std_ulogic;
   ex1_is_bclr                      : out std_ulogic;
   ex1_lr_update                    : out std_ulogic;
   ex1_ctr_dec_update               : out std_ulogic;
   ex1_instr                        : out std_ulogic_vector(0 to 31);
   
   spr_msr_cm                       : in  std_ulogic_vector(0 to threads-1);
   
   br_debug                         : out std_ulogic_vector(0 to 11);

   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);


end xuq_cpl_br;
architecture xuq_cpl_br of xuq_cpl_br is

signal ex1_instr_q                                    : std_ulogic_vector(0 to 31);             
signal ex1_is_b_q                                     : std_ulogic;                             
signal ex1_is_bcctr_q                                 : std_ulogic;                             
signal ex1_is_bclr_q                                  : std_ulogic;                             
signal ex1_ctr_ok_q,          ex1_ctr_ok_d            : std_ulogic;                             
signal ex1_pred_taken_cnt_q                           : std_ulogic;                             
signal ex1_is_branch_cond_q,  ex1_is_branch_cond_d    : std_ulogic;                             
signal ex1_xu_ifar_q                                  : std_ulogic_vector(62-eff_ifar to 61);   
signal ex2_br_flush_q,        ex2_br_flush_d          : std_ulogic_vector(0 to threads-1);
signal ex2_br_flush_ifar_q,   ex2_br_flush_ifar_d     : std_ulogic_vector(62-eff_ifar to 61);   
constant ex1_instr_offset                          : integer := 0;
constant ex1_is_b_offset                           : integer := ex1_instr_offset               + ex1_instr_q'length;
constant ex1_is_bcctr_offset                       : integer := ex1_is_b_offset                + 1;
constant ex1_is_bclr_offset                        : integer := ex1_is_bcctr_offset            + 1;
constant ex1_ctr_ok_offset                         : integer := ex1_is_bclr_offset             + 1;
constant ex1_pred_taken_cnt_offset                 : integer := ex1_ctr_ok_offset              + 1;
constant ex1_is_branch_cond_offset                 : integer := ex1_pred_taken_cnt_offset      + 1;
constant ex1_ifar_offset                           : integer := ex1_is_branch_cond_offset      + 1;
constant ex2_br_flush_offset                       : integer := ex1_ifar_offset                + ex1_xu_ifar_q'length;
constant ex2_br_flush_ifar_offset                  : integer := ex2_br_flush_offset            + ex2_br_flush_q'length;
constant scan_right                                : integer := ex2_br_flush_ifar_offset       + ex2_br_flush_ifar_q'length;
signal siv                                         : std_ulogic_vector(0 to scan_right-1);
signal sov                                         : std_ulogic_vector(0 to scan_right-1);
signal tiup                                        : std_ulogic;
signal rf1_ctr                                     : std_ulogic_vector(64-regsize to 63);
signal rf1_instr                                   : std_ulogic_vector(0 to 31);
signal rf1_msr_cm                                  : std_ulogic;
signal rf1_opcode_is_19                            : boolean;
signal rf1_is_b,rf1_is_bc,rf1_is_bcctr,rf1_is_bclr : std_ulogic;
signal rf1_ctr_low_zero, rf1_ctr_hi_zero           : std_ulogic;
signal rf1_ctr_zero, rf1_ctr_one, rf1_ctr_one_b    : std_ulogic;
signal ex1_br_mispred_int,ex1_bcctr_flush          : std_ulogic;
signal ex1_imm,ex1_cia                             : std_ulogic_vector(62-eff_ifar to 61);
signal ex1_br_t_trgt,ex1_br_nt_trgt,ex1_br_imm_trgt: std_ulogic_vector(62-eff_ifar to 61);
signal ex1_br_flush_ifar                           : std_ulogic_vector(62-eff_ifar to 61);
signal ex1_lr,ex1_ctr                              : std_ulogic_vector(64-regsize to 63);
signal ex1_taken                                   : std_ulogic;

begin



tiup <= '1';

rf1_instr      <= dec_cpl_rf1_instr;


rf1_opcode_is_19  <=                                  rf1_instr( 0 to  5)  = "010011";                
rf1_is_b          <= '1' when                         rf1_instr( 0 to  5)  = "010010"     else '0';   
rf1_is_bc         <= '1' when                         rf1_instr( 0 to  5)  = "010000"     else '0';   
rf1_is_bcctr      <= '1' when rf1_opcode_is_19  and   rf1_instr(21 to 30)  = "1000010000" else '0';   
rf1_is_bclr       <= '1' when rf1_opcode_is_19  and   rf1_instr(21 to 30)  = "0000010000" else '0';   

rf1_msr_cm                 <= or_reduce(spr_msr_cm and rf1_tid);
rf1_ctr                    <= mux_t(spr_ctr,rf1_tid);
rf1_ctr_low_zero           <= not or_reduce(rf1_ctr(32 to 62));
xuq_cpl_ctr_cmp_0 : if regsize >  32 generate
   rf1_ctr_hi_zero         <= not or_reduce(rf1_ctr(64-regsize to 31));
end generate;
xuq_cpl_ctr_cmp_1 : if regsize <= 32 generate
   rf1_ctr_hi_zero         <= '1';
end generate;
rf1_ctr_zero               <= rf1_ctr_low_zero and (rf1_ctr_hi_zero or not rf1_msr_cm);
rf1_ctr_one                <= rf1_ctr_zero and rf1_ctr(63);
rf1_ctr_one_b              <= not rf1_ctr_one;

ex1_ctr_ok_d               <=  rf1_instr(8)   or (rf1_ctr_one_b      xor  rf1_instr(9));
ex1_taken                  <= (ex1_instr_q(6) or (byp_cpl_ex1_cr_bit xnor ex1_instr_q(7))) and ex1_ctr_ok_q;
                              
ex1_is_branch_cond_d       <= rf1_is_bc or rf1_is_bclr or rf1_is_bcctr;

ex1_cia                    <= ex1_xu_ifar_q and not (62-eff_ifar to 61=>ex1_instr_q(30));

ex1_imm(62-eff_ifar to 37) <= (others=>ex1_imm(38));

with ex1_is_b_q select
   ex1_imm(38 to 47)       <= ex1_instr_q( 6 to 15)      when '1',
                              (38 to 47=>ex1_imm(48))    when others;

ex1_imm(48 to 61)          <= ex1_instr_q(16 to 29);

ex1_br_nt_trgt             <= std_ulogic_vector(unsigned(ex1_xu_ifar_q) + 1);

ex1_br_imm_trgt            <= std_ulogic_vector(unsigned(ex1_cia)       + unsigned(ex1_imm));

ex1_lr                     <= mux_t(spr_lr,ex1_tid);
ex1_ctr                    <= mux_t(spr_ctr,ex1_tid);

with s2'(ex1_is_bcctr_q & ex1_is_bclr_q) select
   ex1_br_t_trgt           <= ex1_ctr(64-regsize to 61)           when "10",
                              ex1_lr(64-regsize to 61)            when "01",
                              ex1_br_imm_trgt                     when others;
                              
with (ex1_is_b_q or ex1_taken) select
   ex1_br_flush_ifar       <= ex1_br_t_trgt     when '1',
                              ex1_br_nt_trgt    when others;
                              
ex2_br_flush_ifar_d        <= ex1_br_flush_ifar;
                              
ex1_br_mispred_int         <= ex1_is_branch_cond_q and (ex1_taken xor ex1_pred_taken_cnt_q);
ex1_bcctr_flush            <= ex1_is_bcctr_q       and  ex1_taken;

ex2_br_flush_d             <= ex1_xu_val and (0 to threads-1=>(ex1_br_mispred_int or ex1_bcctr_flush));

ex2_br_flush_ifar          <= ex2_br_flush_ifar_q;
ex2_br_flush               <= ex2_br_flush_q;

ex1_xu_ifar                <= ex1_xu_ifar_q;
ex1_branch                 <= ex1_is_branch_cond_q or ex1_is_b_q;
ex1_br_mispred             <= ex1_br_mispred_int;
ex1_br_taken               <= (ex1_taken and ex1_is_branch_cond_q) or ex1_is_b_q;
ex1_br_update              <= ex1_is_b_q or (ex1_is_branch_cond_q and ex1_taken);
ex1_is_bcctr               <= ex1_is_bcctr_q;
ex1_is_bclr                <= ex1_is_bclr_q;
ex1_ctr_dec_update         <= ex1_is_branch_cond_q and not ex1_instr_q(8); 
ex1_lr_update              <= (ex1_is_branch_cond_q or ex1_is_b_q) and ex1_instr_q(31);
ex1_instr                  <= ex1_instr_q;

mark_unused(ex1_lr(62 to 63));
mark_unused(ex1_ctr(62 to 63));

br_debug                   <= rf1_msr_cm & rf1_ctr_low_zero & rf1_ctr_hi_zero & rf1_ctr_one & ex1_ctr_ok_q & ex1_taken & ex1_pred_taken_cnt_q & byp_cpl_ex1_cr_bit & ex2_br_flush_q;
                  
ex1_instr_latch : tri_rlmreg_p
  generic map (width => ex1_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
            scout   => sov(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
            din     => rf1_instr,
            dout    => ex1_instr_q);
ex1_is_b_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_b_offset),
            scout   => sov(ex1_is_b_offset),
            din     => rf1_is_b,
            dout    => ex1_is_b_q);
ex1_is_bcctr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_bcctr_offset),
            scout   => sov(ex1_is_bcctr_offset),
            din     => rf1_is_bcctr,
            dout    => ex1_is_bcctr_q);
ex1_is_bclr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_bclr_offset),
            scout   => sov(ex1_is_bclr_offset),
            din     => rf1_is_bclr,
            dout    => ex1_is_bclr_q);
ex1_ctr_ok_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_ctr_ok_offset),
            scout   => sov(ex1_ctr_ok_offset),
            din     => ex1_ctr_ok_d,
            dout    => ex1_ctr_ok_q);
ex1_pred_taken_cnt_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_pred_taken_cnt_offset),
            scout   => sov(ex1_pred_taken_cnt_offset),
            din     => dec_cpl_rf1_pred_taken_cnt,
            dout    => ex1_pred_taken_cnt_q);
ex1_is_branch_cond_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_branch_cond_offset),
            scout   => sov(ex1_is_branch_cond_offset),
            din     => ex1_is_branch_cond_d,
            dout    => ex1_is_branch_cond_q);
ex1_ifar_latch : tri_rlmreg_p
  generic map (width => ex1_xu_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_ifar_offset to ex1_ifar_offset + ex1_xu_ifar_q'length-1),
            scout   => sov(ex1_ifar_offset to ex1_ifar_offset + ex1_xu_ifar_q'length-1),
            din     => dec_cpl_rf1_ifar,
            dout    => ex1_xu_ifar_q);
ex2_br_flush_latch : tri_rlmreg_p
  generic map (width => ex2_br_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_br_flush_offset to ex2_br_flush_offset + ex2_br_flush_q'length-1),
            scout   => sov(ex2_br_flush_offset to ex2_br_flush_offset + ex2_br_flush_q'length-1),
            din     => ex2_br_flush_d,
            dout    => ex2_br_flush_q);
ex2_br_flush_ifar_latch : tri_rlmreg_p
  generic map (width => ex2_br_flush_ifar_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_br_flush_ifar_offset to ex2_br_flush_ifar_offset + ex2_br_flush_ifar_q'length-1),
            scout   => sov(ex2_br_flush_ifar_offset to ex2_br_flush_ifar_offset + ex2_br_flush_ifar_q'length-1),
            din     => ex2_br_flush_ifar_d,
            dout    => ex2_br_flush_ifar_q);

siv(0 to scan_right-1)        <= sov(1 to scan_right-1) & scan_in;
scan_out                      <= sov(0);


end architecture xuq_cpl_br;
