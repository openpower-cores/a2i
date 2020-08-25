-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--  Description: Generic Local FIR Component
--
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;


---------------------------------------------------------------------

entity pcq_local_fir2 is
 generic(width                : positive := 1;        -- this must be >=1 and <=64
         expand_type          : integer  := 2;        -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
         impl_lxstop_mchk     : boolean  := false;    -- generate local checkstop /machine check output
         use_recov_reset      : boolean  := false;    -- this adds a reset feature without the second wof register.
         fir_init             : std_ulogic_vector := "0";  -- init value for fir register; length = width !
         fir_mask_init        : std_ulogic_vector := "0";  -- init value for fir mask register; length = width !
         fir_mask_par_init    : std_ulogic_vector := "0";  -- init value for fir mask register even parity
         fir_action0_init     : std_ulogic_vector := "0";  -- init value for fir action0 register; length = width !
         fir_action0_par_init : std_ulogic_vector := "0";  -- init value for fir action0 register even parity
         fir_action1_init     : std_ulogic_vector := "0";  -- init value for fir action1 register; length = width !
         fir_action1_par_init : std_ulogic_vector := "0"); -- init value for fir action1 register even parity
  port
--  Global lines for clocking and scan control
    ( nclk                    : in  clk_logic
    ; vd                      : inout power_logic
    ; gd                      : inout power_logic
    ; lcb_clkoff_dc_b         : in  std_ulogic --from lcb_cntl external to component
    ; lcb_mpw1_dc_b           : in  std_ulogic --from lcb_cntl external to component
    ; lcb_mpw2_dc_b           : in  std_ulogic --from lcb_cntl external to component
    ; lcb_delay_lclkr_dc      : in  std_ulogic --from lcb_cntl external to component
    ; lcb_act_dis_dc          : in  std_ulogic --from lcb_cntl external to component
    ; lcb_sg_0                : in  std_ulogic 
    ; lcb_func_slp_sl_thold_0 : in  std_ulogic := '0'
    ; lcb_cfg_slp_sl_thold_0  : in  std_ulogic := '0'
    ; mode_scan_siv           : in  std_ulogic_vector(0 to 3*(width+1)+width-1) -- scan vector in
    ; mode_scan_sov           : out std_ulogic_vector(0 to 3*(width+1)+width-1) -- scan vector out
    ; func_scan_siv           : in  std_ulogic_vector(0 to 4)
    ; func_scan_sov           : out std_ulogic_vector(0 to 4)
 -- External interface
    ; sys_xstop_in            : in  std_ulogic := '0'               -- freeze FIR on system checkstop from chip GEM
    ; error_in                : in  std_ulogic_vector(0 to width-1) -- needs to be directly off a latch for timing
    ; xstop_err               : out std_ulogic                      -- checkstop   output to Global FIR
    ; recov_err               : out std_ulogic                      -- recoverable output to Global FIR
    ; lxstop_mchk             : out std_ulogic                      -- use ONLY if impl_lxstop_mchk = true
    ; trace_error             : out std_ulogic                      -- connect to error_input of closest trdata macro
    ; recov_reset             : in  std_ulogic := '0'               -- only needed if use_recov_reset = true
    ; fir_out                 : out std_ulogic_vector(0 to width-1) -- output of current FIR state if needed
    ; act0_out                : out std_ulogic_vector(0 to width-1) -- output of current FIR Act0 state if needed
    ; act1_out                : out std_ulogic_vector(0 to width-1) -- output of current FIR Act1 state if needed
    ; mask_out                : out std_ulogic_vector(0 to width-1) -- output of current FIR Mask state if needed
    ; sc_parity_error_inject  : in  std_ulogic                      -- Force parity error
 -- SCOM register connections
    ; sc_active               : in  std_ulogic
    ; sc_wr_q                 : in  std_ulogic
    ; sc_addr_v               : in  std_ulogic_vector(0 to 8)
    ; sc_wdata                : in  std_ulogic_vector(0 to width-1)
    ; sc_wparity              : in  std_ulogic
    ; sc_rdata                : out std_ulogic_vector(0 to width-1)
    ; fir_parity_check        : out std_ulogic_vector(0 to 2)       -- Action0, Action1, Mask reg parity checks
    );



end pcq_local_fir2;


architecture pcq_local_fir2 of pcq_local_fir2 is
   -- Clocks
   signal func_d1clk            : std_ulogic;
   signal func_d2clk            : std_ulogic;
   signal func_lclk             : clk_logic;
   signal mode_d1clk            : std_ulogic;
   signal mode_d2clk            : std_ulogic;
   signal mode_lclk             : clk_logic;
   signal scom_mode_d1clk       : std_ulogic;
   signal scom_mode_d2clk       : std_ulogic;
   signal scom_mode_lclk        : clk_logic;
   signal func_thold_b          : std_ulogic;
   signal func_force            : std_ulogic;
   signal mode_thold_b          : std_ulogic;
   signal mode_force            : std_ulogic;
   -- FIR regs
   signal data_ones             : std_ulogic_vector(0 to width-1);
   signal or_fir                : std_ulogic_vector(0 to width-1);
   signal and_fir               : std_ulogic_vector(0 to width-1);
   signal or_mask               : std_ulogic_vector(0 to width-1);
   signal and_mask              : std_ulogic_vector(0 to width-1);
   signal fir_mask_in           : std_ulogic_vector(0 to width-1);
   signal fir_mask_lt           : std_ulogic_vector(0 to width-1);
   signal masked                : std_ulogic_vector(0 to width-1);
   signal fir_mask_par_in       : std_ulogic;
   signal fir_mask_par_lt       : std_ulogic;
   signal fir_mask_par_err      : std_ulogic;
   signal fir_action0_in        : std_ulogic_vector(0 to width-1);
   signal fir_action0_lt        : std_ulogic_vector(0 to width-1);
   signal fir_action0_par_in    : std_ulogic;
   signal fir_action0_par_lt    : std_ulogic;
   signal fir_action0_par_err   : std_ulogic;
   signal fir_action1_in        : std_ulogic_vector(0 to width-1);
   signal fir_action1_lt        : std_ulogic_vector(0 to width-1);
   signal fir_action1_par_in    : std_ulogic;
   signal fir_action1_par_lt    : std_ulogic;
   signal fir_action1_par_err   : std_ulogic;
   signal fir_reset             : std_ulogic_vector(0 to width-1);
   signal error_input           : std_ulogic_vector(0 to width-1);
   signal fir_error_in_reef     : std_ulogic_vector(0 to width-1);
   signal fir_in                : std_ulogic_vector(0 to width-1);
   signal fir_lt                : std_ulogic_vector(0 to width-1);
   signal block_fir             : std_ulogic;
   signal or_fir_load           : std_ulogic;
   signal and_fir_ones          : std_ulogic;
   signal and_fir_load          : std_ulogic;
   signal or_mask_load          : std_ulogic;
   signal and_mask_ones         : std_ulogic;
   signal and_mask_load         : std_ulogic;
   -- Error report
   signal sys_xstop_lt          : std_ulogic;
   signal recov_in              : std_ulogic;
   signal recov_lt              : std_ulogic;
   signal xstop_in              : std_ulogic;
   signal xstop_lt              : std_ulogic;
   signal trace_error_in        : std_ulogic;
   signal trace_error_lt        : std_ulogic;
   -- Other
   signal tieup                 : std_ulogic;
   -- Scan chain hookups
   signal mode_si, mode_so      : std_ulogic_vector(0 to 3*(width+1)+width-1);
   signal func_si, func_so      : std_ulogic_vector(0 to 4);
   signal unused_signals        : std_ulogic;


begin
  tieup  <= '1';
  data_ones  <= (others => '1');
unused_signals  <= or_reduce(recov_reset & sc_addr_v(5));

--******************************************************
--* Check width inputs
--******************************************************
  assert (fir_action0_init'length = width)
  report "fir_action0_init width error, fir_action0_init must be same width as the component instantiation"
  severity error;

  assert (fir_action1_init'length = width)
  report "fir_action1_init width error, fir_action1_init must be same width as the component instantiation"
  severity error; 

  assert (fir_mask_init'length = width)
  report "fir_mask_init width error, fir_mask_init must be same width as the component instantiation"
  severity error;

-- This will cause the compile to fail if the wrong width is entered.
  verify_action0: if (fir_action0_init'length /= width) generate
    fir_in(0 to 95) <= fir_lt(0 to width);
  end generate verify_action0;

  verify_action1: if (fir_action1_init'length /= width) generate
    fir_in(0 to 95) <= fir_lt(0 to width);
  end generate verify_action1;

  verify_action2: if (fir_mask_init'length /= width) generate   
    fir_in(0 to 95) <= fir_lt(0 to width);
  end generate verify_action2;


--******************************************************
--* LCB driver, LCB and Register Instantiations
--******************************************************
-- functional ring regs; NOT power managed
   func_lcbor: entity tri.tri_lcbor
      generic map (expand_type => expand_type )
      port map( clkoff_b => lcb_clkoff_dc_b,
                thold    => lcb_func_slp_sl_thold_0,
                sg       => lcb_sg_0,
                act_dis  => lcb_act_dis_dc,
                forcee => func_force,
                thold_b  => func_thold_b
              );

   func_lcb: entity tri.tri_lcbnd
      generic map (expand_type => expand_type )
      port map( act         => tieup,           -- not power saved
                vd          => vd,
                gd          => gd,
                delay_lclkr => lcb_delay_lclkr_dc,
                mpw1_b      => lcb_mpw1_dc_b,
                mpw2_b      => lcb_mpw2_dc_b,
                nclk        => nclk,
                forcee => func_force,
                sg          => lcb_sg_0,
                thold_b     => func_thold_b,
                d1clk       => func_d1clk,
                d2clk       => func_d2clk,
                lclk        => func_lclk
              );


-- config ring regs; NOT power managed
   mode_lcbor: entity tri.tri_lcbor
      generic map (expand_type => expand_type )
      port map( clkoff_b => lcb_clkoff_dc_b,
                thold    => lcb_cfg_slp_sl_thold_0,
                sg       => lcb_sg_0,
                act_dis  => lcb_act_dis_dc,
                forcee => mode_force,
                thold_b  => mode_thold_b
              );

   mode_lcb: entity tri.tri_lcbnd
      generic map (expand_type => expand_type )
      port map( act         => tieup,         -- not power saved
                vd          => vd,
                gd          => gd,
                delay_lclkr => lcb_delay_lclkr_dc,
                mpw1_b      => lcb_mpw1_dc_b,
                mpw2_b      => lcb_mpw2_dc_b,
                nclk        => nclk,
                forcee => mode_force,
                sg          => lcb_sg_0,
                thold_b     => mode_thold_b,
                d1clk       => mode_d1clk,
                d2clk       => mode_d2clk,
                lclk        => mode_lclk
              );

   scom_mode_lcb: entity tri.tri_lcbnd
      generic map (expand_type => expand_type )
      port map( act         => sc_active,       -- active during scom access
                vd          => vd,
                gd          => gd,
                delay_lclkr => lcb_delay_lclkr_dc,
                mpw1_b      => lcb_mpw1_dc_b,
                mpw2_b      => lcb_mpw2_dc_b,
                nclk        => nclk,
                forcee => mode_force,
                sg          => lcb_sg_0,
                thold_b     => mode_thold_b,
                d1clk       => scom_mode_d1clk,
                d2clk       => scom_mode_d2clk,
                lclk        => scom_mode_lclk
              );

----------------------------------------------------------------------
-- Mode Registers
----------------------------------------------------------------------
  fir_action0 : entity tri.tri_nlat_scan
    generic map( width => width, init => fir_action0_init, expand_type => expand_type )
    port map
     ( vd        => vd
     , gd        => gd
     , d1clk     => scom_mode_d1clk
     , d2clk     => scom_mode_d2clk
     , lclk      => scom_mode_lclk
     , scan_in   => mode_si(0 to width-1)
     , scan_out  => mode_so(0 to width-1)
     , din       => fir_action0_in
     , q         => fir_action0_lt
     );

  fir_action0_par : entity tri.tri_nlat_scan
    generic map( width => 1, init => fir_action0_par_init, expand_type => expand_type )
    port map
     ( vd        => vd
     , gd        => gd
     , d1clk     => scom_mode_d1clk
     , d2clk     => scom_mode_d2clk
     , lclk      => scom_mode_lclk
     , scan_in   => mode_si(width to width)
     , scan_out  => mode_so(width to width)
     , din(0)    => fir_action0_par_in
     , q(0)      => fir_action0_par_lt
     );

  fir_action1 : entity tri.tri_nlat_scan
    generic map( width => width, init => fir_action1_init, expand_type => expand_type )
    port map
     ( vd        => vd
     , gd        => gd
     , d1clk     => scom_mode_d1clk
     , d2clk     => scom_mode_d2clk
     , lclk      => scom_mode_lclk
     , scan_in   => mode_si(width+1 to 2*width)
     , scan_out  => mode_so(width+1 to 2*width)
     , din       => fir_action1_in
     , q         => fir_action1_lt
     );

  fir_action1_par : entity tri.tri_nlat_scan
    generic map( width => 1, init => fir_action1_par_init, expand_type => expand_type )
    port map
     ( vd        => vd
     , gd        => gd
     , d1clk     => scom_mode_d1clk
     , d2clk     => scom_mode_d2clk
     , lclk      => scom_mode_lclk
     , scan_in   => mode_si(2*width+1 to 2*width+1)
     , scan_out  => mode_so(2*width+1 to 2*width+1)
     , din(0)    => fir_action1_par_in
     , q(0)      => fir_action1_par_lt
     );


  fir_mask : ENTITY tri.tri_nlat_scan
    GENERIC MAP( width => width, init => fir_mask_init, expand_type => expand_type )
    port map
     ( vd        => vd
     , gd        => gd
     , d1clk     => scom_mode_d1clk
     , d2clk     => scom_mode_d2clk
     , lclk      => scom_mode_lclk
     , scan_in   => mode_si(2*width+2 to 3*width+1)
     , scan_out  => mode_so(2*width+2 to 3*width+1)
     , din       => fir_mask_in
     , q         => fir_mask_lt
     );

  fir_mask_par  : entity tri.tri_nlat_scan
    generic map( width => 1, init => fir_mask_par_init, expand_type => expand_type )
    port map
     ( vd        => vd
     , gd        => gd
     , d1clk     => scom_mode_d1clk
     , d2clk     => scom_mode_d2clk
     , lclk      => scom_mode_lclk
     , scan_in   => mode_si(3*width+2 to 3*width+2)
     , scan_out  => mode_so(3*width+2 to 3*width+2)
     , din(0)    => fir_mask_par_in
     , q(0)      => fir_mask_par_lt
     );

  fir : entity tri.tri_nlat_scan
    generic map( width => width, init => fir_init, expand_type => expand_type )
    port map
     ( vd       => vd
     , gd       => gd
     , d1clk    => mode_d1clk
     , d2clk    => mode_d2clk
     , lclk     => mode_lclk
     , scan_in  => mode_si(3*width+3 to 4*width+2)
     , scan_out => mode_so(3*width+3 to 4*width+2)
     , din      => fir_in
     , q        => fir_lt
     );


----------------------------------------------------------------------
-- Func Registers with no power savings
----------------------------------------------------------------------
  sys_xstop : entity tri.tri_nlat
    generic map( width => 1, init => "0", expand_type => expand_type )
    port map
     ( vd       => vd
     , gd       => gd
     , d1clk    => func_d1clk
     , d2clk    => func_d2clk
     , lclk     => func_lclk
     , scan_in  => func_si(1)
     , scan_out => func_so(1)
     , din(0)   => sys_xstop_in
     , q(0)     => sys_xstop_lt
     );

  recov : entity tri.tri_nlat
    generic map( width => 1, init => "0", expand_type => expand_type )
    port map
     ( vd       => vd
     , gd       => gd
     , d1clk    => func_d1clk
     , d2clk    => func_d2clk
     , lclk     => func_lclk
     , scan_in  => func_si(2)
     , scan_out => func_so(2)
     , din(0)   => recov_in
     , q(0)     => recov_lt
     );

  xstop : entity tri.tri_nlat
    generic map( width => 1, init => "0", expand_type => expand_type )
    port map
     ( vd       => vd
     , gd       => gd
     , d1clk    => func_d1clk
     , d2clk    => func_d2clk
     , lclk     => func_lclk
     , scan_in  => func_si(3)
     , scan_out => func_so(3)
     , din(0)   => xstop_in
     , q(0)     => xstop_lt
     );

  trace_err : entity tri.tri_nlat
    generic map( width => 1, init => "0", expand_type => expand_type )
    port map
     ( vd       => vd
     , gd       => gd
     , d1clk    => func_d1clk
     , d2clk    => func_d2clk
     , lclk     => func_lclk
     , scan_in  => func_si(4)
     , scan_out => func_so(4)
     , din(0)   => trace_error_in
     , q(0)     => trace_error_lt
     );


--******************************************************
--* Optional Recovery Reset
--******************************************************
   use_recov_reset_yes: if (use_recov_reset = true) generate
    fir_reset     <= NOT gate_AND(recov_reset, NOT fir_action0_lt AND fir_action1_lt); 
   end generate use_recov_reset_yes;

   use_recov_reset_no: if (use_recov_reset = false) generate
    fir_reset     <= (others => '1') ;
   end generate use_recov_reset_no;


--******************************************************
--* FIR
--******************************************************
   -- write to x'0' to write FIR directly
   -- write to x'1' to And-Mask FIR
   -- write to x'2' to Or-Mask FIR
   or_fir_load  <=     (sc_addr_v(0) or sc_addr_v(2)) and sc_wr_q;
   and_fir_ones <= not((sc_addr_v(0) or sc_addr_v(1)) and sc_wr_q);
   and_fir_load <=                      sc_addr_v(1)  and sc_wr_q;

   or_fir  <= gate_and( or_fir_load, sc_wdata);

   and_fir <= gate_and(and_fir_load, sc_wdata) or
              gate_and(and_fir_ones, data_ones   );

   fir_in  <= gate_and(not block_fir, error_input) or or_fir or (fir_lt and and_fir and fir_reset);


   fir_error_in_reef  <= error_in; -- does a signal rename for the reef tool
   error_input        <= fir_error_in_reef;


--******************************************************
--* FIR Mask
--******************************************************
   -- write to x'6' to write FIR-MASK directly
   -- write to x'7' to And-Mask FIR-MASK
   -- write to x'8' to Or-Mask FIR-MASK
   or_mask_load     <=     (sc_addr_v(6) or sc_addr_v(8)) and sc_wr_q;
   and_mask_ones    <= not((sc_addr_v(6) or sc_addr_v(7)) and sc_wr_q);
   and_mask_load    <=                      sc_addr_v(7)  and sc_wr_q;

   or_mask          <= gate_and( or_mask_load, sc_wdata);
   and_mask         <= gate_and(and_mask_load, sc_wdata) or gate_and(and_mask_ones, data_ones);

   fir_mask_in      <= or_mask or (fir_mask_lt and and_mask);
   fir_mask_par_in  <= parity_gen_even(fir_mask_in) when (gate_and(sc_wr_q, or_reduce(sc_addr_v(6 to 8))))='1' else
                       fir_mask_par_lt;

   fir_mask_par_err <= (xor_reduce(fir_mask_lt) xor fir_mask_par_lt)  or
                       (sc_wr_q and or_reduce(sc_addr_v(6 to 8)) and sc_parity_error_inject);

   masked           <= fir_mask_lt;


--******************************************************
--* Action Registers
--******************************************************
   -- write to x'3' to write FIR-Action0 directly
   fir_action0_in      <= sc_wdata when (sc_addr_v(3) and sc_wr_q) = '1' else  fir_action0_lt;
   fir_action0_par_in  <= sc_wparity when (sc_addr_v(3) and sc_wr_q) = '1' else  fir_action0_par_lt;
   fir_action0_par_err <= xor_reduce(fir_action0_lt) xor fir_action0_par_lt;

   -- write to x'4' to write FIR-Action1 directly
   fir_action1_in      <= sc_wdata when (sc_addr_v(4) and sc_wr_q) = '1' else  fir_action1_lt;
   fir_action1_par_in  <= sc_wparity when (sc_addr_v(4) and sc_wr_q) = '1' else  fir_action1_par_lt;
   fir_action1_par_err <= xor_reduce(fir_action1_lt) xor fir_action1_par_lt;


--******************************************************
--* Summary
--******************************************************
   xstop_in     <= or_reduce(fir_lt and     fir_action0_lt and not fir_action1_lt and not masked); -- fir_action = 10
   recov_in     <= or_reduce(fir_lt and not fir_action0_lt and     fir_action1_lt and not masked); -- fir_action = 01

   block_fir    <= xstop_lt or sys_xstop_lt;

   xstop_err    <= xstop_lt;
   recov_err    <= recov_lt;
   trace_error  <= trace_error_lt;

   fir_out  <= fir_lt;
   act0_out <= fir_action0_lt;
   act1_out <= fir_action1_lt;
   mask_out <= fir_mask_lt;

   fir_parity_check    <= fir_action0_par_err & fir_action1_par_err & fir_mask_par_err;



--******************************************************
--* SCOM read logic
--******************************************************
   sc_rdata   <= gate_and(sc_addr_v(0), fir_lt        ) or
                 gate_and(sc_addr_v(3), fir_action0_lt) or
                 gate_and(sc_addr_v(4), fir_action1_lt) or 
                 gate_and(sc_addr_v(6), fir_mask_lt   ) ;


--******************************************************
--* Optional MCHK Enable Register and Output
--******************************************************
  mchkgen: if (impl_lxstop_mchk = true) generate
   yes: block
   signal lxstop_mchk_in         : std_ulogic;
   signal lxstop_mchk_lt         : std_ulogic;
   begin

   lxstop_mchk_in <= or_reduce(fir_lt and fir_action0_lt and fir_action1_lt and not masked); -- fir_action = 11
   lxstop_mchk    <= lxstop_mchk_lt;

   trace_error_in <= xstop_in or recov_in or lxstop_mchk_in;

   mchk  : entity tri.tri_nlat
    generic map( width => 1, init => "0", expand_type => expand_type )
    port map
     ( d1clk    => func_d1clk
     , vd       => vd
     , gd       => gd
     , lclk     => func_lclk
     , d2clk    => func_d2clk
     , scan_in  => func_si(0)
     , scan_out => func_so(0)
     , din(0)   => lxstop_mchk_in
     , q(0)     => lxstop_mchk_lt
     );
   end block yes;
  end generate mchkgen;

  nomchk: if (impl_lxstop_mchk = false) generate
    trace_error_in   <= xstop_in or recov_in;
    lxstop_mchk      <= '0';
    func_so(0) <= func_si(0);
  end generate nomchk;


--******************************************************
-- Scan Chain Connections
--******************************************************
  mode_si <= mode_scan_siv;
  mode_scan_sov <= mode_so;

  func_si <= func_scan_siv;
  func_scan_sov <= func_so;


-----------------------------------------------------------------------
end pcq_local_fir2;
