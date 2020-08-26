-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU XER Bypass Unit
--
library ieee,ibm,support,tri,work;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;
use work.xuq_pkg.all;

entity xuq_byp_xer is
    generic (
        threads                             : integer := 4;
        expand_type                         : integer := 2;
        regsize                             : integer := 64);
    port (
        -- Clocks
        nclk                                : in clk_logic;

        -- Power
        vdd                                 : inout power_logic;
        gnd                                 : inout power_logic;
        
        trace_bus_enable                    : in std_ulogic;

        -- Pervasive
        d_mode_dc                           : in std_ulogic;
        delay_lclkr_dc                      : in std_ulogic;
        mpw1_dc_b                           : in std_ulogic;
        mpw2_dc_b                           : in std_ulogic;
        func_sl_force : in std_ulogic;
        func_sl_thold_0_b                   : in std_ulogic;
        func_slp_sl_force : in std_ulogic;
        func_slp_sl_thold_0_b               : in std_ulogic;
        sg_0                                : in std_ulogic;
        scan_in                             : in std_ulogic;
        scan_out                            : out std_ulogic;

        -- Used bit signals
        dec_byp_rf1_ca_used                 : in std_ulogic;
        dec_byp_rf1_ov_used                 : in std_ulogic;

        -- Bypass Inputs
        rf1_tid                             : in std_ulogic_vector(0 to threads-1);
        ex5_tid                             : in std_ulogic_vector(0 to threads-1);

        -- Valid
        dec_byp_ex3_val                     : in std_ulogic_vector(0 to threads-1);
        dec_byp_rf1_byp_val                 : in std_ulogic_vector(2 to 3);

        -- Flushes
        xu_ex3_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex4_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex5_flush                        : in std_ulogic_vector(0 to threads-1);

        -- mfxer
        byp_ex5_xer_rt                      : out std_ulogic_vector(54 to 63);

        -- Valids
        alu_ex2_div_done                    : in std_ulogic;
        alu_ex4_mul_done                    : in std_ulogic;

        -- XER Inputs
        alu_byp_ex2_xer                     : in std_ulogic_vector(0 to 3);                 -- 0: OV bit  1: CA bit  2: OV Update  3: CA Update
        alu_byp_ex5_xer_mul                 : in std_ulogic_vector(0 to 3);                 -- 0: OV bit  1: CA bit  2: OV Update  3: CA Update
        alu_byp_ex3_xer_div                 : in std_ulogic_vector(0 to 3);                 -- 0: OV bit  1: CA bit  2: OV Update  3: CA Update
        spr_byp_ex4_is_mtxer                : in std_ulogic_vector(0 to threads-1);
        byp_ex5_mtcrxer                     : in std_ulogic_vector(32 to 63);

        -- Outputs
        byp_xer_si                          : out std_ulogic_vector(0 to 7*threads-1);
        byp_xer_so                          : out std_ulogic_vector(0 to threads-1);
        xer_cr_ex1_xer_ov_in_pipe           : out std_ulogic;
        xer_cr_ex2_xer_ov_in_pipe           : out std_ulogic;
        xer_cr_ex3_xer_ov_in_pipe           : out std_ulogic;
        xer_cr_ex5_xer_ov_in_pipe           : out std_ulogic;
        byp_dec_rf1_xer_ca                  : out std_ulogic;
        
        xer_debug                           : out std_ulogic_vector(22 to 87)
    );

-- synopsys translate_off

-- synopsys translate_on
end xuq_byp_xer;
architecture xuq_byp_xer of xuq_byp_xer is
    constant tiup                                       : std_ulogic := '1';
    constant tidn                                       : std_ulogic := '0';
    subtype s2                                          is std_ulogic_vector(0 to 1);

    -- Signals
    signal ex2_xer                                      : std_ulogic_vector(0 to 3);
    signal ex3_xer                                      : std_ulogic_vector(0 to 3);
    signal ex4_xer                                      : std_ulogic_vector(0 to 3);
    signal ex5_xer                                      : std_ulogic_vector(0 to 3);
    signal ex3_val                                      : std_ulogic_vector(0 to threads-1);
    signal ex4_val                                      : std_ulogic_vector(0 to threads-1);
    signal ex5_val                                      : std_ulogic_vector(0 to threads-1);
    signal xer_out                                      : std_ulogic_vector(0 to 10*threads-1);
    signal rf1_byp_val                                  : std_ulogic_vector(4 to 5);
    signal rf1_byp_val_ov                               : std_ulogic_vector(2 to 5);
    signal rf1_byp_ov_pri                               : std_ulogic_vector(2 to 6);
    signal rf1_byp_val_ca                               : std_ulogic_vector(2 to 5);
    signal rf1_byp_ca_pri                               : std_ulogic_vector(2 to 6);
    signal xer_ex5_mux                                  : std_ulogic_vector(54 to 63);
    signal xer_rf1_mux                                  : std_ulogic_vector(54 to 63);
    signal rf1_ov_byp_from_reg                          : std_ulogic;
    signal rf1_ov                                       : std_ulogic;
    signal rf1_ca                                       : std_ulogic;
    signal rf1_xer_ov_in_pipe                           : std_ulogic;

    -- Latches
    signal                      ex3_xer_q               : std_ulogic_vector(0 to 3);
    signal                      ex4_xer_q               : std_ulogic_vector(0 to 3);
    signal                      ex5_xer_q               : std_ulogic_vector(0 to 3);
    signal                      ex4_val_q               : std_ulogic_vector(0 to threads-1);
    signal                      ex5_val_q               : std_ulogic_vector(0 to threads-1);
    signal                      ex1_xer_ov_bypassed_q   : std_ulogic;
    signal                      ex2_xer_ov_bypassed_q   : std_ulogic;
    signal                      ex3_xer_ov_bypassed_q   : std_ulogic;
    signal                      ex4_xer_ov_bypassed_q   : std_ulogic;
    signal                      ex5_xer_ov_bypassed_q   : std_ulogic;
    signal                      ex1_ov_byp_from_reg_q   : std_ulogic;
    signal                      ex2_ov_byp_from_reg_q   : std_ulogic;
    signal                      ex3_ov_byp_from_reg_q   : std_ulogic;
    signal                      ex4_ov_byp_from_reg_q   : std_ulogic;
    signal                      ex5_ov_byp_from_reg_q   : std_ulogic;
    signal                      ex1_xer_ov_in_pipe_q    : std_ulogic;
    signal                      ex2_xer_ov_in_pipe_q    : std_ulogic;
    signal                      ex3_xer_ov_in_pipe_q    : std_ulogic;
    signal                      ex4_xer_ov_in_pipe_q    : std_ulogic;
    signal                      ex5_xer_ov_in_pipe_q    : std_ulogic;
    signal                      ex5_is_mtxer_q          : std_ulogic_vector(0 to threads-1);   -- spr_byp_ex4_is_mtxer
    signal ex3_div_done_q                               : std_ulogic;    -- input=>alu_ex2_div_done
    signal ex5_mul_done_q                               : std_ulogic;    -- input=>alu_ex4_mul_done
    signal debug_q,             debug_d                 : std_ulogic_vector(0 to 31); -- input=>debug_d,   act=>trace_bus_enable,      sleep=>Y,   needs_sreset=>0

    -- Scanchains
    constant ex3_xer_offset                             : integer := 0;
    constant ex4_xer_offset                             : integer := ex3_xer_offset                 + ex3_xer_q'length;
    constant ex5_xer_offset                             : integer := ex4_xer_offset                 + ex4_xer_q'length;
    constant ex4_val_offset                             : integer := ex5_xer_offset                 + ex5_xer_q'length;
    constant ex5_val_offset                             : integer := ex4_val_offset                 + ex4_val_q'length;
    constant ex1_xer_ov_bypassed_offset                 : integer := ex5_val_offset                 + ex5_val_q'length;
    constant ex2_xer_ov_bypassed_offset                 : integer := ex1_xer_ov_bypassed_offset     + 1;
    constant ex3_xer_ov_bypassed_offset                 : integer := ex2_xer_ov_bypassed_offset     + 1;
    constant ex4_xer_ov_bypassed_offset                 : integer := ex3_xer_ov_bypassed_offset     + 1;
    constant ex5_xer_ov_bypassed_offset                 : integer := ex4_xer_ov_bypassed_offset     + 1;
    constant ex1_ov_byp_from_reg_offset                 : integer := ex5_xer_ov_bypassed_offset     + 1;
    constant ex2_ov_byp_from_reg_offset                 : integer := ex1_ov_byp_from_reg_offset     + 1;
    constant ex3_ov_byp_from_reg_offset                 : integer := ex2_ov_byp_from_reg_offset     + 1;
    constant ex4_ov_byp_from_reg_offset                 : integer := ex3_ov_byp_from_reg_offset     + 1;
    constant ex5_ov_byp_from_reg_offset                 : integer := ex4_ov_byp_from_reg_offset     + 1;
    constant ex1_xer_ov_in_pipe_offset                  : integer := ex5_ov_byp_from_reg_offset     + 1;
    constant ex2_xer_ov_in_pipe_offset                  : integer := ex1_xer_ov_in_pipe_offset      + 1;
    constant ex3_xer_ov_in_pipe_offset                  : integer := ex2_xer_ov_in_pipe_offset      + 1;
    constant ex4_xer_ov_in_pipe_offset                  : integer := ex3_xer_ov_in_pipe_offset      + 1;
    constant ex5_xer_ov_in_pipe_offset                  : integer := ex4_xer_ov_in_pipe_offset      + 1;
    constant ex5_is_mtxer_offset                        : integer := ex5_xer_ov_in_pipe_offset      + 1;
    constant xer_offset                                 : integer := ex5_is_mtxer_offset            + ex5_is_mtxer_q'length;
    constant ex3_div_done_offset                        : integer := xer_offset                     + 10*threads;
    constant ex5_mul_done_offset                        : integer := ex3_div_done_offset            + 1;
    constant debug_offset                               : integer := ex5_mul_done_offset            + 1;
    constant scan_right                                 : integer := debug_offset                   + debug_q'length;
    signal siv                                          : std_ulogic_vector(0 to scan_right-1);
    signal sov                                          : std_ulogic_vector(0 to scan_right-1);
begin

    ---------------------------------------------------------------------
    -- Valids
    ---------------------------------------------------------------------
    ex3_val         <= dec_byp_ex3_val and not xu_ex3_flush;
    ex4_val         <= ex4_val_q       and not xu_ex4_flush;
    ex5_val         <= ex5_val_q       and not xu_ex5_flush;

    ---------------------------------------------------------------------
    -- XER pipeline input
    ---------------------------------------------------------------------
        ex2_xer     <= alu_byp_ex2_xer;

    with ex3_div_done_q select
        ex3_xer     <= alu_byp_ex3_xer_div      when '1',
                       ex3_xer_q                when others;

    ex4_xer         <= ex4_xer_q;

    with ex5_mul_done_q select
        ex5_xer     <= alu_byp_ex5_xer_mul      when '1',
                       ex5_xer_q                when others;

    ---------------------------------------------------------------------
    -- MFXER
    ---------------------------------------------------------------------
    xer_ex5_mux     <= mux_t(xer_out,ex5_tid);
    byp_ex5_xer_rt  <= (xer_ex5_mux(54) or (ex5_xer_ov_bypassed_q and not ex5_ov_byp_from_reg_q)) &    -- SO bit
                       (xer_ex5_mux(55) or  ex5_xer_ov_bypassed_q) &                                   -- OV bit
                       xer_ex5_mux(56 to 63);

    ---------------------------------------------------------------------
    -- Bypass valids
    ---------------------------------------------------------------------
    rf1_byp_val(4)      <= '1' when rf1_tid = ex4_val_q else '0';
    rf1_byp_val(5)      <= '1' when rf1_tid = ex5_val_q else '0';

    ---------------------------------------------------------------------
    -- Bypass control (OV)
    ---------------------------------------------------------------------
    rf1_byp_val_ov(2)   <= ex2_xer(2) and dec_byp_rf1_byp_val(2) and dec_byp_rf1_ov_used;   -- OV bit in EX2 is valid, TID is valid, OV bit is used in RF1 instr
    rf1_byp_val_ov(3)   <= ex3_xer(2) and dec_byp_rf1_byp_val(3) and dec_byp_rf1_ov_used;   -- OV bit in EX3 is valid, TID is valid, OV bit is used in RF1 instr
    rf1_byp_val_ov(4)   <= ex4_xer(2) and rf1_byp_val(4)         and dec_byp_rf1_ov_used;   -- OV bit in EX4 is valid, TID is valid, OV bit is used in RF1 instr
    rf1_byp_val_ov(5)   <= ex5_xer(2) and rf1_byp_val(5)         and dec_byp_rf1_ov_used;   -- OV bit in EX5 is valid, TID is valid, OV bit is used in RF1 instr

    -- Prioritization
    rf1_byp_ov_pri(2)   <=                                           rf1_byp_val_ov(2);
    rf1_byp_ov_pri(3)   <= not           rf1_byp_val_ov(2)       and rf1_byp_val_ov(3);
    rf1_byp_ov_pri(4)   <= not or_reduce(rf1_byp_val_ov(2 to 3)) and rf1_byp_val_ov(4);
    rf1_byp_ov_pri(5)   <= not or_reduce(rf1_byp_val_ov(2 to 4)) and rf1_byp_val_ov(5);
    rf1_byp_ov_pri(6)   <= not or_reduce(rf1_byp_val_ov(2 to 5));
    
    ---------------------------------------------------------------------
    -- Bypass control (CA)
    ---------------------------------------------------------------------
    rf1_byp_val_ca(2)   <= ex2_xer(3) and dec_byp_rf1_byp_val(2) and dec_byp_rf1_ca_used;   -- CA bit in EX2 is valid, TID is valid, CA bit is used in RF1 instr
    rf1_byp_val_ca(3)   <= ex3_xer(3) and dec_byp_rf1_byp_val(3) and dec_byp_rf1_ca_used;   -- CA bit in EX3 is valid, TID is valid, CA bit is used in RF1 instr
    rf1_byp_val_ca(4)   <= ex4_xer(3) and rf1_byp_val(4)         and dec_byp_rf1_ca_used;   -- CA bit in EX4 is valid, TID is valid, CA bit is used in RF1 instr
    rf1_byp_val_ca(5)   <= ex5_xer(3) and rf1_byp_val(5)         and dec_byp_rf1_ca_used;   -- CA bit in EX5 is valid, TID is valid, CA bit is used in RF1 instr

    -- Prioritization
    rf1_byp_ca_pri(2)   <=                                           rf1_byp_val_ca(2);
    rf1_byp_ca_pri(3)   <= not           rf1_byp_val_ca(2)       and rf1_byp_val_ca(3);
    rf1_byp_ca_pri(4)   <= not or_reduce(rf1_byp_val_ca(2 to 3)) and rf1_byp_val_ca(4);
    rf1_byp_ca_pri(5)   <= not or_reduce(rf1_byp_val_ca(2 to 4)) and rf1_byp_val_ca(5);
    rf1_byp_ca_pri(6)   <= not or_reduce(rf1_byp_val_ca(2 to 5));
    
    ---------------------------------------------------------------------
    -- RF1 Source Selection
    ---------------------------------------------------------------------
    rf1_ov                      <= (ex2_xer(0)      and rf1_byp_ov_pri(2)) or
                                   (ex3_xer(0)      and rf1_byp_ov_pri(3)) or
                                   (ex4_xer(0)      and rf1_byp_ov_pri(4)) or
                                   (ex5_xer(0)      and rf1_byp_ov_pri(5)) or
                                   (xer_rf1_mux(55) and rf1_byp_ov_pri(6));

    rf1_ca                      <= (ex2_xer(1)      and rf1_byp_ca_pri(2)) or
                                   (ex3_xer(1)      and rf1_byp_ca_pri(3)) or
                                   (ex4_xer(1)      and rf1_byp_ca_pri(4)) or
                                   (ex5_xer(1)      and rf1_byp_ca_pri(5)) or
                                   (xer_rf1_mux(56) and rf1_byp_ca_pri(6));

    xer_rf1_mux             <= mux_t(xer_out,rf1_tid);
    rf1_ov_byp_from_reg     <= rf1_byp_ov_pri(6);

    ---------------------------------------------------------------------
    -- XER Writeback
    ---------------------------------------------------------------------
    xuq_byp_xer_gen : for t in 0 to threads-1 generate
        signal xer_d,           xer_q                   : std_ulogic_vector(54 to 63);
        signal ex5_mtxer_we                             : std_ulogic;
        signal ex5_ca_we                                : std_ulogic;
        signal ex5_ov_we                                : std_ulogic;
        signal ex5_so_sel                               : std_ulogic_vector(0 to 2);
        signal ex5_ov_sel                               : std_ulogic_vector(0 to 2);
        signal ex5_ca_sel                               : std_ulogic_vector(0 to 2);
    begin
        ex5_mtxer_we    <= ex5_val(t) and ex5_is_mtxer_q(t);
        ex5_ov_we       <= ex5_val(t) and ex5_xer(2);
        ex5_ca_we       <= ex5_val(t) and ex5_xer(3);

        ex5_so_sel(0 to 1) <= ex5_mtxer_we & (ex5_ov_we and ex5_xer(0));
        ex5_so_sel(2)      <= not (ex5_so_sel(0) or ex5_so_sel(1));
        
        ex5_ov_sel(0 to 1) <= ex5_mtxer_we & ex5_ov_we;
        ex5_ov_sel(2)      <= not (ex5_ov_sel(0) or ex5_ov_sel(1));
        
        ex5_ca_sel(0 to 1) <= ex5_mtxer_we & ex5_ca_we;
        ex5_ca_sel(2)      <= not (ex5_ca_sel(0) or ex5_ca_sel(1));

        -- SO Bit
        xer_d(54)       <= (byp_ex5_mtcrxer(32) and ex5_so_sel(0)) or
                           (                        ex5_so_sel(1)) or
                           (xer_q(54)           and ex5_so_sel(2));
        -- OV Bit
        xer_d(55)       <= (byp_ex5_mtcrxer(33) and ex5_ov_sel(0)) or
                           (ex5_xer(0)          and ex5_ov_sel(1)) or
                           (xer_q(55)           and ex5_ov_sel(2));
        -- CA Bit
        xer_d(56)       <= (byp_ex5_mtcrxer(34) and ex5_ca_sel(0)) or
                           (ex5_xer(1)          and ex5_ca_sel(1)) or
                           (xer_q(56)           and ex5_ca_sel(2));
        -- SI
        xer_d(57 to 63) <= byp_ex5_mtcrxer(57 to 63)     when ex5_mtxer_we = '1' else
                           xer_q(57 to 63);

        -- XER Output
        xer_out(t*10 to t*10+9)     <= xer_q;
        byp_xer_si(t*7 to t*7+6)    <= xer_q(57 to 63);
        byp_xer_so(t)               <= xer_q(54);

        ---------------------------------------------------------------------
        -- XER Latch
        ---------------------------------------------------------------------
        xer_latch : tri_rlmreg_p
            generic map (width => xer_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                      scin          => siv(xer_offset + xer_q'length*t to xer_offset + xer_q'length*(t+1)-1),
                      scout         => sov(xer_offset + xer_q'length*t to xer_offset + xer_q'length*(t+1)-1),
                      din           => xer_d,
                      dout          => xer_q);
    end generate;

    ---------------------------------------------------------------------
    -- XER output (threadwise)
    ---------------------------------------------------------------------
    byp_dec_rf1_xer_ca  <= rf1_ca;

    rf1_xer_ov_in_pipe          <= (ex2_xer(0) and ex2_xer(2) and dec_byp_rf1_byp_val(2)) or
                                   (ex3_xer(0) and ex3_xer(2) and dec_byp_rf1_byp_val(3)) or
                                   (ex4_xer(0) and ex4_xer(2) and rf1_byp_val(4)        ) or
                                   (ex5_xer(0) and ex5_xer(2) and rf1_byp_val(5)        );
                                   
    xer_cr_ex1_xer_ov_in_pipe   <= ex1_xer_ov_in_pipe_q;
    xer_cr_ex2_xer_ov_in_pipe   <= ex2_xer_ov_in_pipe_q;
    xer_cr_ex3_xer_ov_in_pipe   <= ex3_xer_ov_in_pipe_q;
    xer_cr_ex5_xer_ov_in_pipe   <= ex5_xer_ov_in_pipe_q;
    
    mark_unused(xer_rf1_mux(54));          
    mark_unused(xer_rf1_mux(57 to 63));
    mark_unused(byp_ex5_mtcrxer(35 to 56));

    ---------------------------------------------------------------------
    -- Debug
    ---------------------------------------------------------------------
    debug_d(0 to 31)             <= ex5_val                    &
                                    dec_byp_rf1_ov_used        &
                                    dec_byp_rf1_ca_used        &
                                    rf1_byp_ov_pri(2 to 6)     &
                                    rf1_byp_ca_pri(2 to 6)     &
                                    ex2_xer(0 to 3)            &
                                    ex3_xer(0 to 3)            &
                                    ex4_xer(0 to 3)            &
                                    ex5_xer(0 to 3);
                                    
                                    
    xer_debug(22 to 87)          <= debug_q                    &
                                    ex3_div_done_q             &
                                    ex5_mul_done_q             &
                                    ex5_is_mtxer_q(0 to 3)     &
                                    ex1_xer_ov_bypassed_q      &
                                    ex2_xer_ov_bypassed_q      &
                                    ex3_xer_ov_bypassed_q      &
                                    ex4_xer_ov_bypassed_q      &
                                    ex5_xer_ov_bypassed_q      &
                                    ex1_ov_byp_from_reg_q      &
                                    ex2_ov_byp_from_reg_q      &
                                    ex3_ov_byp_from_reg_q      &
                                    ex4_ov_byp_from_reg_q      &
                                    ex5_ov_byp_from_reg_q      &
                                    ex1_xer_ov_in_pipe_q       &
                                    ex2_xer_ov_in_pipe_q       &
                                    ex3_xer_ov_in_pipe_q       &
                                    ex4_xer_ov_in_pipe_q       &
                                    ex5_xer_ov_in_pipe_q       &
                                    xer_out( 7 to  9)          &
                                    xer_out(17 to 19)          &
                                    xer_out(27 to 29)          &
                                    xer_out(37 to 39)          &
                                    '0';

    ---------------------------------------------------------------------
    -- Latch Instances
    ---------------------------------------------------------------------
    ex3_xer_latch : tri_rlmreg_p
        generic map (width => ex3_xer_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex3_xer_offset to ex3_xer_offset + ex3_xer_q'length-1),
                  scout         => sov(ex3_xer_offset to ex3_xer_offset + ex3_xer_q'length-1),
                  din           => ex2_xer,
                  dout          => ex3_xer_q);
    ex4_xer_latch : tri_rlmreg_p
        generic map (width => ex4_xer_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex4_xer_offset to ex4_xer_offset + ex4_xer_q'length-1),
                  scout         => sov(ex4_xer_offset to ex4_xer_offset + ex4_xer_q'length-1),
                  din           => ex3_xer,
                  dout          => ex4_xer_q);
    ex5_xer_latch : tri_rlmreg_p
        generic map (width => ex5_xer_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex5_xer_offset to ex5_xer_offset + ex5_xer_q'length-1),
                  scout         => sov(ex5_xer_offset to ex5_xer_offset + ex5_xer_q'length-1),
                  din           => ex4_xer,
                  dout          => ex5_xer_q);
    ex4_val_latch : tri_rlmreg_p
        generic map (width => ex4_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex4_val_offset to ex4_val_offset + ex4_val_q'length-1),
                  scout         => sov(ex4_val_offset to ex4_val_offset + ex4_val_q'length-1),
                  din           => ex3_val,
                  dout          => ex4_val_q);
    ex5_val_latch : tri_rlmreg_p
        generic map (width => ex5_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
                  scin          => siv(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
                  scout         => sov(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
                  din           => ex4_val,
                  dout          => ex5_val_q);
    ex1_xer_ov_bypassed_latch : tri_rlmlatch_p
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
                  scin          => siv(ex1_xer_ov_bypassed_offset),
                  scout         => sov(ex1_xer_ov_bypassed_offset),
                  din           => rf1_ov,
                  dout          => ex1_xer_ov_bypassed_q);
    ex2_xer_ov_bypassed_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_xer_ov_bypassed_offset),
                  scout         => sov(ex2_xer_ov_bypassed_offset),
                  din           => ex1_xer_ov_bypassed_q,
                  dout          => ex2_xer_ov_bypassed_q);
    ex3_xer_ov_bypassed_latch : tri_rlmlatch_p
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
                  scin          => siv(ex3_xer_ov_bypassed_offset),
                  scout         => sov(ex3_xer_ov_bypassed_offset),
                  din           => ex2_xer_ov_bypassed_q,
                  dout          => ex3_xer_ov_bypassed_q);
    ex4_xer_ov_bypassed_latch : tri_rlmlatch_p
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
                  scin          => siv(ex4_xer_ov_bypassed_offset),
                  scout         => sov(ex4_xer_ov_bypassed_offset),
                  din           => ex3_xer_ov_bypassed_q,
                  dout          => ex4_xer_ov_bypassed_q);
    ex5_xer_ov_bypassed_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_xer_ov_bypassed_offset),
                  scout         => sov(ex5_xer_ov_bypassed_offset),
                  din           => ex4_xer_ov_bypassed_q,
                  dout          => ex5_xer_ov_bypassed_q);
    ex1_ov_byp_from_reg_latch : tri_rlmlatch_p
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
                  scin          => siv(ex1_ov_byp_from_reg_offset),
                  scout         => sov(ex1_ov_byp_from_reg_offset),
                  din           => rf1_ov_byp_from_reg,
                  dout          => ex1_ov_byp_from_reg_q);
    ex2_ov_byp_from_reg_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_ov_byp_from_reg_offset),
                  scout         => sov(ex2_ov_byp_from_reg_offset),
                  din           => ex1_ov_byp_from_reg_q,
                  dout          => ex2_ov_byp_from_reg_q);
    ex3_ov_byp_from_reg_latch : tri_rlmlatch_p
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
                  scin          => siv(ex3_ov_byp_from_reg_offset),
                  scout         => sov(ex3_ov_byp_from_reg_offset),
                  din           => ex2_ov_byp_from_reg_q,
                  dout          => ex3_ov_byp_from_reg_q);
    ex4_ov_byp_from_reg_latch : tri_rlmlatch_p
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
                  scin          => siv(ex4_ov_byp_from_reg_offset),
                  scout         => sov(ex4_ov_byp_from_reg_offset),
                  din           => ex3_ov_byp_from_reg_q,
                  dout          => ex4_ov_byp_from_reg_q);
    ex5_ov_byp_from_reg_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_ov_byp_from_reg_offset),
                  scout         => sov(ex5_ov_byp_from_reg_offset),
                  din           => ex4_ov_byp_from_reg_q,
                  dout          => ex5_ov_byp_from_reg_q);
    ex1_xer_ov_in_pipe_latch : tri_rlmlatch_p
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
                  scin          => siv(ex1_xer_ov_in_pipe_offset),
                  scout         => sov(ex1_xer_ov_in_pipe_offset),
                  din           => rf1_xer_ov_in_pipe,
                  dout          => ex1_xer_ov_in_pipe_q);
    ex2_xer_ov_in_pipe_latch : tri_rlmlatch_p
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
                  scin          => siv(ex2_xer_ov_in_pipe_offset),
                  scout         => sov(ex2_xer_ov_in_pipe_offset),
                  din           => ex1_xer_ov_in_pipe_q,
                  dout          => ex2_xer_ov_in_pipe_q);
    ex3_xer_ov_in_pipe_latch : tri_rlmlatch_p
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
                  scin          => siv(ex3_xer_ov_in_pipe_offset),
                  scout         => sov(ex3_xer_ov_in_pipe_offset),
                  din           => ex2_xer_ov_in_pipe_q,
                  dout          => ex3_xer_ov_in_pipe_q);
    ex4_xer_ov_in_pipe_latch : tri_rlmlatch_p
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
                  scin          => siv(ex4_xer_ov_in_pipe_offset),
                  scout         => sov(ex4_xer_ov_in_pipe_offset),
                  din           => ex3_xer_ov_in_pipe_q,
                  dout          => ex4_xer_ov_in_pipe_q);
    ex5_xer_ov_in_pipe_latch : tri_rlmlatch_p
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
                  scin          => siv(ex5_xer_ov_in_pipe_offset),
                  scout         => sov(ex5_xer_ov_in_pipe_offset),
                  din           => ex4_xer_ov_in_pipe_q,
                  dout          => ex5_xer_ov_in_pipe_q);
     ex5_is_mtxer_latch : tri_rlmreg_p
       generic map (width => ex5_is_mtxer_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
       port map (nclk           => nclk, vd => vdd, gd => gnd,
                 act            => tiup,
                 forcee => func_sl_force,
                 d_mode         => d_mode_dc, delay_lclkr => delay_lclkr_dc,
                 mpw1_b         => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
                 thold_b        => func_sl_thold_0_b,
                 sg             => sg_0,
                 scin           => siv(ex5_is_mtxer_offset to ex5_is_mtxer_offset+ex5_is_mtxer_q'length-1),
                 scout          => sov(ex5_is_mtxer_offset to ex5_is_mtxer_offset+ex5_is_mtxer_q'length-1),
                 din            => spr_byp_ex4_is_mtxer,
                 dout           => ex5_is_mtxer_q);
      ex3_div_done_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk    => nclk, vd => vdd, gd => gnd,
                  act     => tiup,
                  forcee => func_sl_force,
                  d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
                  mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
                  thold_b => func_sl_thold_0_b,
                  sg      => sg_0,
                  scin    => siv(ex3_div_done_offset),
                  scout   => sov(ex3_div_done_offset),
                  din     => alu_ex2_div_done,
                  dout    => ex3_div_done_q);
      ex5_mul_done_latch : tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
        port map (nclk    => nclk, vd => vdd, gd => gnd,
                  act     => tiup,
                  forcee => func_sl_force,
                  d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
                  mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
                  thold_b => func_sl_thold_0_b,
                  sg      => sg_0,
                  scin    => siv(ex5_mul_done_offset),
                  scout   => sov(ex5_mul_done_offset),
                  din     => alu_ex4_mul_done,
                  dout    => ex5_mul_done_q);
   debug_latch : tri_rlmreg_p
     generic map (width => debug_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => trace_bus_enable,
               forcee => func_slp_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_slp_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(debug_offset to debug_offset + debug_q'length-1),
               scout   => sov(debug_offset to debug_offset + debug_q'length-1),
               din     => debug_d,
               dout    => debug_q);

    siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
    scan_out             <= sov(0);

end architecture xuq_byp_xer;
