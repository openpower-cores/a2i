-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,ibm,support,tri,work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_alu_div is
    generic(
        expand_type                     : integer := 2;
        regsize                         : integer := 64);
    port(
        nclk                            : in clk_logic;

        vdd                             : inout power_logic;
        gnd                             : inout power_logic;

        d_mode_dc                       : in std_ulogic;
        delay_lclkr_dc                  : in std_ulogic;
        mpw1_dc_b                       : in std_ulogic;
        mpw2_dc_b                       : in std_ulogic;
        func_sl_force : in std_ulogic;
        func_sl_thold_0_b               : in std_ulogic;
        sg_0                            : in std_ulogic;
        scan_in                         : in std_ulogic;
        scan_out                        : out std_ulogic;

        fxa_fxb_rf1_div_ctr             : in std_ulogic_vector(0 to 7);
        dec_alu_rf1_div_val             : in std_ulogic;
        dec_alu_rf1_div_sign            : in std_ulogic;                            
        dec_alu_rf1_div_size            : in std_ulogic;                            
        dec_alu_rf1_div_extd            : in std_ulogic;                            
        dec_alu_rf1_div_recform         : in std_ulogic;
        dec_alu_rf1_xer_ov_update       : in std_ulogic;

        byp_alu_ex1_divsrc_0            : in std_ulogic_vector(64-regsize to 63);   
        byp_alu_ex1_divsrc_1            : in std_ulogic_vector(64-regsize to 63);   

        fxa_fxb_ex1_hold_ctr_flush      : in std_ulogic;

        alu_dec_div_need_hole           : out std_ulogic;
        alu_byp_ex3_div_rt              : out std_ulogic_vector(64-regsize to 63);
        alu_ex2_div_done                : out std_ulogic;

        ex3_div_xer_ov                  : out std_ulogic;
        ex3_div_xer_ov_update           : out std_ulogic;

        alu_byp_ex3_cr_div              : out std_ulogic_vector(0 to 4);

        ex2_spr_msr_cm                  : in std_ulogic
    );
-- synopsys translate_off

-- synopsys translate_on
end xuq_alu_div;

architecture xuq_alu_div of xuq_alu_div is
   constant msb                                          : integer := 64-regsize; 
   subtype s2                                            is std_ulogic_vector(0 to 1);
   signal                      ex1_div_ctr_q             : std_ulogic_vector(0 to 7);
   signal                      ex1_div_val_q             : std_ulogic;
   signal                      ex1_div_sign_q            : std_ulogic;
   signal                      ex1_div_size_q            : std_ulogic;
   signal                      ex1_div_extd_q            : std_ulogic;
   signal                      ex1_div_recform_q         : std_ulogic;
   signal                      ex1_xer_ov_update_q       : std_ulogic;
   signal                      ex2_div_val_q             : std_ulogic;
   signal ex1_cycle_act,       ex2_cycle_act_q           : std_ulogic;
   signal ex2_cycles_d,        ex2_cycles_q              : std_ulogic_vector(0 to 7);
   signal ex2_denom_d,         ex2_denom_q               : std_ulogic_vector(msb to 63);
   signal ex2_numer_d,         ex2_numer_q               : std_ulogic_vector(msb to 64);
   signal ex2_dmask_d,         ex2_dmask_q               : std_ulogic_vector(msb to 63);
   signal                      ex2_div_ovf_q             : std_ulogic;
   signal                      ex2_xer_ov_update_q       : std_ulogic;
   signal                      ex2_div_recform_q         : std_ulogic;
   signal                      ex2_div_size_q            : std_ulogic;
   signal                      ex2_div_sign_q            : std_ulogic;
   signal                      ex2_div_extd_q            : std_ulogic;
   signal                      ex2_2s_rslt_q             : std_ulogic;
   signal                      ex2_div_done_q            : std_ulogic;
   signal                      ex3_div_val_q             : std_ulogic;
   signal ex3_cycle_watch_d,   ex3_cycle_watch_q         : std_ulogic;
   signal ex3_quot_watch_d,    ex3_quot_watch_q          : std_ulogic;
   signal ex3_div_ovf_d,       ex3_div_ovf_q             : std_ulogic;
   signal                      ex3_xer_ov_update_q       : std_ulogic;
   signal                      ex3_div_done_q            : std_ulogic;
   signal ex3_quotient_d,      ex3_quotient_q            : std_ulogic_vector(msb to 63);
   signal                      ex3_div_recform_q         : std_ulogic;
   signal                      ex3_div_size_q            : std_ulogic;
   signal                      ex3_2s_rslt_q             : std_ulogic;
   signal ex3_div_rt_d,        ex3_div_rt_q              : std_ulogic_vector(msb to 63);
   signal ex2_numer_eq_zero_q, ex2_numer_eq_zero_d       : std_ulogic;   
   signal ex2_div_ovf_cond3,   ex3_div_ovf_cond3_q       : std_ulogic;
   signal                      ex3_spr_msr_cm_q          : std_ulogic;
   signal need_hole_q,         need_hole_d               : std_ulogic;
   constant ex1_div_ctr_offset                           : integer := 0;
   constant ex1_div_val_offset                           : integer := ex1_div_ctr_offset                 + ex1_div_ctr_q'length;
   constant ex1_div_sign_offset                          : integer := ex1_div_val_offset                 + 1;
   constant ex1_div_size_offset                          : integer := ex1_div_sign_offset                + 1;
   constant ex1_div_extd_offset                          : integer := ex1_div_size_offset                + 1;
   constant ex1_div_recform_offset                       : integer := ex1_div_extd_offset                + 1;
   constant ex1_xer_ov_update_offset                     : integer := ex1_div_recform_offset             + 1;
   constant ex2_div_val_offset                           : integer := ex1_xer_ov_update_offset           + 1;
   constant ex2_cycle_act_offset                         : integer := ex2_div_val_offset                 + 1;
   constant ex2_cycles_offset                            : integer := ex2_cycle_act_offset               + 1;
   constant ex2_denom_offset                             : integer := ex2_cycles_offset                  + ex2_cycles_q'length;
   constant ex2_numer_offset                             : integer := ex2_denom_offset                   + ex2_denom_q'length;
   constant ex2_dmask_offset                             : integer := ex2_numer_offset                   + ex2_numer_q'length;
   constant ex2_div_ovf_offset                           : integer := ex2_dmask_offset                   + ex2_dmask_q'length;
   constant ex2_xer_ov_update_offset                     : integer := ex2_div_ovf_offset                 + 1;
   constant ex2_div_recform_offset                       : integer := ex2_xer_ov_update_offset           + 1;
   constant ex2_div_size_offset                          : integer := ex2_div_recform_offset             + 1;
   constant ex2_div_sign_offset                          : integer := ex2_div_size_offset                + 1;
   constant ex2_div_extd_offset                          : integer := ex2_div_sign_offset                + 1;
   constant ex2_2s_rslt_offset                           : integer := ex2_div_extd_offset                + 1;
   constant ex2_div_done_offset                          : integer := ex2_2s_rslt_offset                 + 1;
   constant ex3_div_val_offset                           : integer := ex2_div_done_offset                + 1;
   constant ex3_cycle_watch_offset                       : integer := ex3_div_val_offset                 + 1;
   constant ex3_quot_watch_offset                        : integer := ex3_cycle_watch_offset             + 1;
   constant ex3_div_ovf_offset                           : integer := ex3_quot_watch_offset              + 1;
   constant ex3_xer_ov_update_offset                     : integer := ex3_div_ovf_offset                 + 1;
   constant ex3_div_done_offset                          : integer := ex3_xer_ov_update_offset           + 1;
   constant ex3_quotient_offset                          : integer := ex3_div_done_offset                + 1;
   constant ex3_div_recform_offset                       : integer := ex3_quotient_offset                + ex3_quotient_q'length;
   constant ex3_div_size_offset                          : integer := ex3_div_recform_offset             + 1;
   constant ex3_2s_rslt_offset                           : integer := ex3_div_size_offset                + 1;
   constant ex3_div_rt_offset                            : integer := ex3_2s_rslt_offset                 + 1;
   constant ex2_numer_eq_zero_offset                     : integer := ex3_div_rt_offset                  + ex3_div_rt_q'length;
   constant ex3_div_ovf_cond3_offset                     : integer := ex2_numer_eq_zero_offset           + 1;
   constant ex3_spr_msr_cm_offset                        : integer := ex3_div_ovf_cond3_offset           + 1;
   constant need_hole_offset                             : integer := ex3_spr_msr_cm_offset              + 1;
   constant scan_right                                   : integer := need_hole_offset                   + 1;
   signal sov,siv                                        : std_ulogic_vector(0 to scan_right-1);
   signal ex2_denom_shift                                : std_ulogic_vector(msb to 63);
   signal ex2_denom_shift_ctrl                           : std_ulogic;
   signal ex2_sub_or_restore                             : std_ulogic_vector(msb to 64);
   signal ex2_sub_or_restore_ctrl                        : std_ulogic_vector(0 to 1);
   signal ex2_sub_rslt_shift                             : std_ulogic_vector(msb to 64);
   signal ex2_numer_shift                                : std_ulogic_vector(msb to 64);    
   signal ex1_denom                                      : std_ulogic_vector(msb to 63);
   signal ex1_numer                                      : std_ulogic_vector(msb to 63);
   signal mask                                           : std_ulogic_vector(msb to 63);
   signal ex2_sub_rslt                                   : std_ulogic_vector(msb to 64);
   signal ex1_div_done                                   : std_ulogic;
   signal ex1_num_cmp0_lo_nomsb, ex1_num_cmp0_hi_nomsb   : std_ulogic;
   signal ex1_num_cmp0_lo,       ex1_num_cmp0_hi         : std_ulogic;
   signal ex1_den_cmp0_lo,       ex1_den_cmp0_hi         : std_ulogic;
   signal ex1_den_cmp1_lo,       ex1_den_cmp1_hi         : std_ulogic;
   signal ex3_qot_cmp0_lo,       ex3_qot_cmp0_hi         : std_ulogic;
   signal ex1_div_ovf_cond1_wd,  ex1_div_ovf_cond1_dw    : std_ulogic;
   signal ex1_div_ovf_cond1                              : std_ulogic;
   signal ex1_div_ovf_cond2                              : std_ulogic;
   signal ex2_div_ovf_cond4                              : std_ulogic;
   signal ex2_rslt_sign                                  : std_ulogic;
   signal ex2_den_eq_num,        ex2_den_gte_num         : std_ulogic;
   signal ex1_div_ovf                                    : std_ulogic;
   signal ex1_divsrc_0,          ex1_divsrc_0_2s         : std_ulogic_vector(msb to 63);
   signal ex1_divsrc_1,          ex1_divsrc_1_2s         : std_ulogic_vector(msb to 63);
   signal ex1_2s_rslt                                    : std_ulogic;
   signal ex1_src0_sign,         ex1_src1_sign           : std_ulogic;
   signal ex1_div_cnt_done                               : std_ulogic;
   signal ex3_cmp0_undef                                 : std_ulogic;
   signal ex3_cmp0_eq                                    : std_ulogic;
   signal ex3_cmp0_gt                                    : std_ulogic;
   signal ex3_cmp0_lt                                    : std_ulogic;
   signal ex3_quotient_2s                                : std_ulogic_vector(msb to 63);
   signal ex2_cycles_din                                 : std_ulogic_vector(0 to 7);
   signal ex2_cycles_gt_64,     ex2_cycles_gt_32         : std_ulogic;
   signal ex3_lt                                         : std_ulogic;
   signal ex2_quot_pushbit                               : std_ulogic;
   signal ex2_denom_rot                                  : std_ulogic_vector(msb to 63);
   signal ex3_div_rt                                     : std_ulogic_vector(msb to 63);
   signal ex2_numer_act, ex2_denom_act                   : std_ulogic;
   signal tiup, tidn                                     : std_ulogic;
   
begin


tiup <= '1';
tidn <= '0';

with ex1_div_val_q select
   ex2_cycles_din    <= ex1_div_ctr_q                                    when '1',
                        std_ulogic_vector(unsigned(ex2_cycles_q) - 1)    when others;

ex2_cycles_d         <= gate(ex2_cycles_din,not(fxa_fxb_ex1_hold_ctr_flush));

ex1_cycle_act        <= ex1_div_val_q or (ex2_cycle_act_q and or_reduce(ex2_cycles_q));

ex1_div_cnt_done     <= '1' when ex2_cycles_q = "00000001" else '0';

ex1_div_done         <= ex1_div_cnt_done and not fxa_fxb_ex1_hold_ctr_flush;

alu_ex2_div_done     <= ex2_div_done_q;

ex1_divsrc_0_2s      <= std_ulogic_vector(unsigned(not byp_alu_ex1_divsrc_0) + 1);
ex1_divsrc_1_2s      <= std_ulogic_vector(unsigned(not byp_alu_ex1_divsrc_1) + 1);

div_64b_2scomp : if regsize = 64 generate
   with ex1_div_size_q select
      ex1_2s_rslt    <= (byp_alu_ex1_divsrc_0(0)  xor byp_alu_ex1_divsrc_1(0) ) and ex1_div_sign_q    when '1',
                        (byp_alu_ex1_divsrc_0(32) xor byp_alu_ex1_divsrc_1(32)) and ex1_div_sign_q    when others;

   with ex1_div_size_q select
      ex1_src0_sign   <= byp_alu_ex1_divsrc_0(0)  when '1',
                         byp_alu_ex1_divsrc_0(32) when others;

   with ex1_div_size_q select
      ex1_src1_sign  <=  byp_alu_ex1_divsrc_1(0)  when '1',
                         byp_alu_ex1_divsrc_1(32) when others;
end generate;
div_32b_2scomp : if regsize = 32 generate
   ex1_2s_rslt       <= (byp_alu_ex1_divsrc_0(32) xor byp_alu_ex1_divsrc_1(32)) and ex1_div_sign_q;
   ex1_src0_sign     <=  byp_alu_ex1_divsrc_0(32);
   ex1_src1_sign     <=  byp_alu_ex1_divsrc_1(32);
end generate;


with (ex1_div_sign_q and ex1_src0_sign) select
   ex1_divsrc_0      <= ex1_divsrc_0_2s            when '1',
                        byp_alu_ex1_divsrc_0       when others;

with (ex1_div_sign_q and ex1_src1_sign) select
   ex1_divsrc_1      <= ex1_divsrc_1_2s            when '1',
                        byp_alu_ex1_divsrc_1       when others;


div_setup_64b : if regsize = 64 generate

   with ex1_div_size_q select
      ex1_denom(0  to 31)  <= ex1_divsrc_1(0  to 31)      when '1',
                              ex1_divsrc_1(32 to 63)      when others;
                              
      ex1_denom(32 to 63)  <= gate(ex1_divsrc_1(32 to 63),ex1_div_size_q);

                       
   with ex1_div_size_q select
      ex1_numer(0  to 31)  <= ex1_divsrc_0(0  to 31)      when '1',
                              ex1_divsrc_0(32 to 63)      when others;
                              
      ex1_numer(32 to 63)  <= gate(ex1_divsrc_0(32 to 63),ex1_div_size_q);
                       
                       
   mask              <= (0 to 31=>tiup) & (32 to 63=>ex1_div_size_q);
   
   
   with ex1_div_size_q select
      ex2_denom_rot(0)  <= ex2_denom_q(63)               when '1',
                           ex2_denom_q(31)               when others;
                           
   ex2_denom_rot(1 to 31)  <=      ex2_denom_q(msb to 30);
   ex2_denom_rot(32 to 63) <= gate(ex2_denom_q(31 to 62),ex2_div_size_q);
        
end generate;
div_setup_32b : if regsize = 32 generate

   ex1_denom         <= ex1_divsrc_1;     
   ex1_numer         <= ex1_divsrc_0;
   
   mask              <= (32 to 63=>tiup);
   
   ex2_denom_rot     <= ex2_denom_q(63) & ex2_denom_q(msb to 62);
     
end generate;

with ex1_div_val_q select
   ex2_denom_d       <= ex1_denom         when '1',
                        ex2_denom_shift   when others;

with ex1_div_val_q select
   ex2_dmask_d       <= mask                                            when '1',
                        '0' & ex2_dmask_q(msb to 62)                    when others;
                        
ex2_denom_shift_ctrl    <= or_reduce(ex2_denom_q and ex2_dmask_q);


with ex2_denom_shift_ctrl select
   ex2_denom_shift      <= ex2_denom_rot                                when '1',
                           ex2_denom_q                                  when others;
                           
ex2_denom_act        <= ex1_div_val_q or ex2_denom_shift_ctrl;

with ex1_div_val_q select
   ex2_numer_d          <= '0' & ex1_numer            when '1',
                           ex2_sub_or_restore         when others;


ex2_numer_act        <= ex1_div_val_q or ex1_cycle_act;

ex2_sub_rslt   <= std_ulogic_vector(unsigned(ex2_numer_q) - unsigned('0' & ex2_denom_q));



ex2_sub_rslt_shift      <= ex2_sub_rslt(msb+1  to 64) & '0';
ex2_numer_shift         <= ex2_numer_q(msb+1 to 64)   & ex2_numer_q(msb);


ex2_sub_or_restore_ctrl <= (not ex2_denom_shift_ctrl) & ex2_sub_rslt(msb);

with ex2_sub_or_restore_ctrl select
   ex2_sub_or_restore   <= ex2_sub_rslt_shift   when "10",
                           ex2_numer_shift      when "11",
                           ex2_numer_q          when others;

ex2_quot_pushbit        <= not ex2_denom_shift_ctrl and not ex2_sub_rslt(msb);

with ex2_div_val_q select
   ex3_quotient_d       <= (msb to 63=>tidn)                               when '1',
                           ex3_quotient_q(msb+1 to 63) & ex2_quot_pushbit  when others;

ex3_quotient_2s         <= std_ulogic_vector(unsigned(not ex3_quotient_q) + 1);

need_hole_d             <= '1' when ex2_cycles_q = "00000111" else '0';
alu_dec_div_need_hole   <= need_hole_q;

with ex3_2s_rslt_q select
   ex3_div_rt_d         <= ex3_quotient_2s      when '1',
                           ex3_quotient_q       when others;

with ex2_div_size_q select
   ex2_rslt_sign       <= ex3_div_rt_d(msb)     when '1',
                          ex3_div_rt_d(32)      when others;

div_rslt_64b : if regsize = 64 generate    
   ex3_div_rt(0  to 31)    <= gate(ex3_div_rt_q(0  to 31),not(ex3_div_ovf_q or not ex3_div_size_q));
end generate;
   ex3_div_rt(32 to 63)    <= gate(ex3_div_rt_q(32 to 63),not(ex3_div_ovf_q));

alu_byp_ex3_div_rt         <= ex3_div_rt;



   ex1_num_cmp0_lo_nomsb   <= not or_reduce(byp_alu_ex1_divsrc_0(33 to 63));
   ex1_den_cmp0_lo         <= not or_reduce(byp_alu_ex1_divsrc_1(32 to 63));
   ex1_den_cmp1_lo         <=    and_reduce(byp_alu_ex1_divsrc_1(32 to 63));
   ex3_qot_cmp0_lo         <= not or_reduce(ex3_div_rt_q(32 to 63));
   ex1_num_cmp0_lo         <= not byp_alu_ex1_divsrc_0(32) and ex1_num_cmp0_lo_nomsb;
   ex1_div_ovf_cond1_wd    <=     byp_alu_ex1_divsrc_0(32) and ex1_num_cmp0_lo_nomsb and ex1_den_cmp1_lo;

div_64b_oflow : if regsize = 64 generate

   ex1_num_cmp0_hi_nomsb   <= not or_reduce(byp_alu_ex1_divsrc_0(1  to 31));
   ex1_den_cmp0_hi         <= not or_reduce(byp_alu_ex1_divsrc_1(0  to 31));
   ex1_den_cmp1_hi         <=    and_reduce(byp_alu_ex1_divsrc_1(0  to 31));
   ex3_qot_cmp0_hi         <= not or_reduce(ex3_div_rt_q(0 to 31));
   ex1_num_cmp0_hi         <= not byp_alu_ex1_divsrc_0(0)  and ex1_num_cmp0_hi_nomsb;
   ex1_div_ovf_cond1_dw    <=     byp_alu_ex1_divsrc_0(0)  and ex1_num_cmp0_hi_nomsb and 
                              not byp_alu_ex1_divsrc_0(32) and ex1_num_cmp0_lo_nomsb and ex1_den_cmp1_lo and ex1_den_cmp1_hi;

end generate;
div_32b_oflow : if regsize = 32 generate
   
   ex1_num_cmp0_hi_nomsb   <= '1';
   ex1_den_cmp0_hi         <= '1';
   ex1_den_cmp1_hi         <= '1';
   ex1_div_ovf_cond1_dw    <= '1';
   ex1_num_cmp0_hi         <= '1';
   ex3_qot_cmp0_hi         <= '1';
   
end generate;   

   
with ex1_div_size_q select
   ex1_div_ovf_cond1       <= ex1_div_ovf_cond1_dw       when '1',
                              ex1_div_ovf_cond1_wd       when others;
                              
ex1_div_ovf_cond2       <= ex1_den_cmp0_lo and (ex1_den_cmp0_hi or not ex1_div_size_q);

ex1_div_ovf             <= (ex1_div_ovf_cond1 and ex1_div_sign_q) or
                            ex1_div_ovf_cond2;

ex2_den_eq_num          <= and_reduce(ex2_denom_q xnor ex2_numer_q(msb+1 to 64));
ex2_den_gte_num         <= not(ex2_sub_rslt(msb)) or ex2_den_eq_num;
ex2_div_ovf_cond3       <= ex2_den_gte_num and not ex2_div_sign_q and ex2_div_extd_q;

ex2_cycles_gt_64        <= '1' when (unsigned(ex2_cycles_q) > 64) else '0';
ex2_cycles_gt_32        <= '1' when (unsigned(ex2_cycles_q) > 32) else '0';

with ex2_div_size_q select
   ex3_cycle_watch_d    <= ex2_cycles_gt_64     when '1',
                           ex2_cycles_gt_32     when others;

ex3_quot_watch_d        <= (ex3_quot_watch_q or (ex3_cycle_watch_q and ex3_quotient_q(63))) and not ex3_div_val_q;

ex2_numer_eq_zero_d     <= ex1_num_cmp0_lo and (ex1_num_cmp0_hi or not ex1_div_size_q);

ex2_div_ovf_cond4       <= ex3_quot_watch_q or                                               
                         ((ex2_rslt_sign xor ex2_2s_rslt_q) and not ex2_numer_eq_zero_q) or  
                         ( ex2_rslt_sign                    and     ex2_numer_eq_zero_q);    

ex3_div_ovf_d           <= ex2_div_ovf_q or ex3_div_ovf_cond3_q or (ex2_div_ovf_cond4 and (ex2_div_sign_q and ex2_div_extd_q));

ex3_div_xer_ov_update   <= ex3_xer_ov_update_q and ex3_div_done_q;
ex3_div_xer_ov          <= ex3_div_ovf_q;

ex3_cmp0_undef          <=     ex3_div_ovf_q or                      
                          (not ex3_div_size_q and ex3_spr_msr_cm_q); 

with ex3_spr_msr_cm_q select
   ex3_lt               <= ex3_div_rt_q(msb)            when '1',
                           ex3_div_rt_q(32)             when others;

ex3_cmp0_eq             <= (ex3_qot_cmp0_lo and 
                           (ex3_qot_cmp0_hi or not ex3_spr_msr_cm_q)) and not ex3_cmp0_undef;

ex3_cmp0_lt             <=     ex3_lt and not ex3_cmp0_eq and not ex3_cmp0_undef;
ex3_cmp0_gt             <= not ex3_lt and not ex3_cmp0_eq and not ex3_cmp0_undef;

alu_byp_ex3_cr_div      <= ex3_cmp0_lt & ex3_cmp0_gt & ex3_cmp0_eq & (ex3_div_ovf_q and ex3_xer_ov_update_q) & (ex3_div_recform_q and ex3_div_done_q);

   ex1_div_ctr_latch : tri_rlmreg_p
     generic map (width => ex1_div_ctr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => dec_alu_rf1_div_val,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex1_div_ctr_offset to ex1_div_ctr_offset + ex1_div_ctr_q'length-1),
               scout         => sov(ex1_div_ctr_offset to ex1_div_ctr_offset + ex1_div_ctr_q'length-1),
               din           => fxa_fxb_rf1_div_ctr,
               dout          => ex1_div_ctr_q);
   ex1_div_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex1_div_val_offset),
               scout         => sov(ex1_div_val_offset),
               din           => dec_alu_rf1_div_val,
               dout          => ex1_div_val_q);
   ex1_div_sign_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => dec_alu_rf1_div_val,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex1_div_sign_offset),
               scout         => sov(ex1_div_sign_offset),
               din           => dec_alu_rf1_div_sign,
               dout          => ex1_div_sign_q);
   ex1_div_size_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => dec_alu_rf1_div_val,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex1_div_size_offset),
               scout         => sov(ex1_div_size_offset),
               din           => dec_alu_rf1_div_size,
               dout          => ex1_div_size_q);
   ex1_div_extd_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => dec_alu_rf1_div_val,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex1_div_extd_offset),
               scout         => sov(ex1_div_extd_offset),
               din           => dec_alu_rf1_div_extd,
               dout          => ex1_div_extd_q);
   ex1_div_recform_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => dec_alu_rf1_div_val,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex1_div_recform_offset),
               scout         => sov(ex1_div_recform_offset),
               din           => dec_alu_rf1_div_recform,
               dout          => ex1_div_recform_q);
   ex1_xer_ov_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => dec_alu_rf1_div_val,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex1_xer_ov_update_offset),
               scout         => sov(ex1_xer_ov_update_offset),
               din           => dec_alu_rf1_xer_ov_update,
               dout          => ex1_xer_ov_update_q);
   ex2_div_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_div_val_offset),
               scout         => sov(ex2_div_val_offset),
               din           => ex1_div_val_q,
               dout          => ex2_div_val_q);
   ex2_cycle_act_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_cycle_act_offset),
               scout         => sov(ex2_cycle_act_offset),
               din           => ex1_cycle_act,
               dout          => ex2_cycle_act_q);
   ex2_cycles_latch : tri_rlmreg_p
     generic map (width => ex2_cycles_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex1_cycle_act,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_cycles_offset to ex2_cycles_offset + ex2_cycles_q'length-1),
               scout         => sov(ex2_cycles_offset to ex2_cycles_offset + ex2_cycles_q'length-1),
               din           => ex2_cycles_d,
               dout          => ex2_cycles_q);
   ex2_denom_latch : tri_rlmreg_p
     generic map (width => ex2_denom_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex2_denom_act,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_denom_offset to ex2_denom_offset + ex2_denom_q'length-1),
               scout         => sov(ex2_denom_offset to ex2_denom_offset + ex2_denom_q'length-1),
               din           => ex2_denom_d,
               dout          => ex2_denom_q);
   ex2_numer_latch : tri_rlmreg_p
     generic map (width => ex2_numer_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex2_numer_act,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_numer_offset to ex2_numer_offset + ex2_numer_q'length-1),
               scout         => sov(ex2_numer_offset to ex2_numer_offset + ex2_numer_q'length-1),
               din           => ex2_numer_d,
               dout          => ex2_numer_q);
   ex2_dmask_latch : tri_rlmreg_p
     generic map (width => ex2_dmask_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex2_denom_act,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_dmask_offset to ex2_dmask_offset + ex2_dmask_q'length-1),
               scout         => sov(ex2_dmask_offset to ex2_dmask_offset + ex2_dmask_q'length-1),
               din           => ex2_dmask_d,
               dout          => ex2_dmask_q);
   ex2_div_ovf_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex1_div_val_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_div_ovf_offset),
               scout         => sov(ex2_div_ovf_offset),
               din           => ex1_div_ovf,
               dout          => ex2_div_ovf_q);
   ex2_xer_ov_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_xer_ov_update_offset),
               scout         => sov(ex2_xer_ov_update_offset),
               din           => ex1_xer_ov_update_q,
               dout          => ex2_xer_ov_update_q);
   ex2_div_recform_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_div_recform_offset),
               scout         => sov(ex2_div_recform_offset),
               din           => ex1_div_recform_q,
               dout          => ex2_div_recform_q);
   ex2_div_size_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex1_div_val_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_div_size_offset),
               scout         => sov(ex2_div_size_offset),
               din           => ex1_div_size_q,
               dout          => ex2_div_size_q);
   ex2_div_sign_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex1_div_val_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_div_sign_offset),
               scout         => sov(ex2_div_sign_offset),
               din           => ex1_div_sign_q,
               dout          => ex2_div_sign_q);
   ex2_div_extd_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex1_div_val_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_div_extd_offset),
               scout         => sov(ex2_div_extd_offset),
               din           => ex1_div_extd_q,
               dout          => ex2_div_extd_q);
   ex2_2s_rslt_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex1_div_val_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_2s_rslt_offset),
               scout         => sov(ex2_2s_rslt_offset),
               din           => ex1_2s_rslt,
               dout          => ex2_2s_rslt_q);
   ex2_div_done_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_div_done_offset),
               scout         => sov(ex2_div_done_offset),
               din           => ex1_div_done,
               dout          => ex2_div_done_q);
   ex3_div_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_div_val_offset),
               scout         => sov(ex3_div_val_offset),
               din           => ex2_div_val_q,
               dout          => ex3_div_val_q);
   ex3_cycle_watch_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_cycle_watch_offset),
               scout         => sov(ex3_cycle_watch_offset),
               din           => ex3_cycle_watch_d,
               dout          => ex3_cycle_watch_q);
   ex3_quot_watch_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_quot_watch_offset),
               scout         => sov(ex3_quot_watch_offset),
               din           => ex3_quot_watch_d,
               dout          => ex3_quot_watch_q);
   ex3_div_ovf_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_div_ovf_offset),
               scout         => sov(ex3_div_ovf_offset),
               din           => ex3_div_ovf_d,
               dout          => ex3_div_ovf_q);
   ex3_xer_ov_update_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_xer_ov_update_offset),
               scout         => sov(ex3_xer_ov_update_offset),
               din           => ex2_xer_ov_update_q,
               dout          => ex3_xer_ov_update_q);
   ex3_div_done_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_div_done_offset),
               scout         => sov(ex3_div_done_offset),
               din           => ex2_div_done_q,
               dout          => ex3_div_done_q);
   ex3_quotient_latch : tri_rlmreg_p
     generic map (width => ex3_quotient_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex2_cycle_act_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_quotient_offset to ex3_quotient_offset + ex3_quotient_q'length-1),
               scout         => sov(ex3_quotient_offset to ex3_quotient_offset + ex3_quotient_q'length-1),
               din           => ex3_quotient_d,
               dout          => ex3_quotient_q);
   ex3_div_recform_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_div_recform_offset),
               scout         => sov(ex3_div_recform_offset),
               din           => ex2_div_recform_q,
               dout          => ex3_div_recform_q);
   ex3_div_size_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_div_size_offset),
               scout         => sov(ex3_div_size_offset),
               din           => ex2_div_size_q,
               dout          => ex3_div_size_q);
   ex3_2s_rslt_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_2s_rslt_offset),
               scout         => sov(ex3_2s_rslt_offset),
               din           => ex2_2s_rslt_q,
               dout          => ex3_2s_rslt_q);
   ex3_div_rt_latch : tri_rlmreg_p
     generic map (width => ex3_div_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex2_div_done_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex3_div_rt_offset to ex3_div_rt_offset + ex3_div_rt_q'length-1),
               scout         => sov(ex3_div_rt_offset to ex3_div_rt_offset + ex3_div_rt_q'length-1),
               din           => ex3_div_rt_d,
               dout          => ex3_div_rt_q);
   ex3_div_ovf_cond3_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => ex2_div_val_q,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_div_ovf_cond3_offset),
               scout   => sov(ex3_div_ovf_cond3_offset),
               din     => ex2_div_ovf_cond3,
               dout    => ex3_div_ovf_cond3_q);
   ex3_spr_msr_cm_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_spr_msr_cm_offset),
               scout   => sov(ex3_spr_msr_cm_offset),
               din     => ex2_spr_msr_cm,
               dout    => ex3_spr_msr_cm_q);
   ex2_numer_eq_zero_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => ex1_div_val_q,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(ex2_numer_eq_zero_offset),
               scout         => sov(ex2_numer_eq_zero_offset),
               din           => ex2_numer_eq_zero_d,
               dout          => ex2_numer_eq_zero_q);
   need_hole_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk          => nclk,
               vd            => vdd,
               gd            => gnd,
               act           => tiup,
               forcee => func_sl_force,
               d_mode        => d_mode_dc,
               delay_lclkr   => delay_lclkr_dc,
               mpw1_b        => mpw1_dc_b,
               mpw2_b        => mpw2_dc_b,
               thold_b       => func_sl_thold_0_b,
               sg            => sg_0,
               scin          => siv(need_hole_offset),
               scout         => sov(need_hole_offset),
               din           => need_hole_d,
               dout          => need_hole_q);
    siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
    scan_out <= sov(0);
end architecture xuq_alu_div;
