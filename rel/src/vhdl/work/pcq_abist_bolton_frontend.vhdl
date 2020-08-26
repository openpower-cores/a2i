-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--
--  Description: Pervasive ABIST ASIC Bolt-On
--
--*****************************************************************************

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

entity pcq_abist_bolton_frontend is
  generic(
    expand_type  :       integer := 2;  -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    num_backends :       integer := 44);
  port(
    vdd          : inout power_logic;
    gnd          : inout power_logic;
    nclk         : in    clk_logic;

-- BISTCNTL interface
    bcreset     : in std_ulogic;
    bcdata      : in std_ulogic;
    bcshcntl    : in std_ulogic;
    bcshdata    : in std_ulogic;
    bcexe       : in std_ulogic;
    bcsysrepair                 : in    std_ulogic;
    bo_enable   : in std_ulogic;
    bo_go       : in std_ulogic;

-- daisy chain
    donein       : in  std_ulogic;
    sdin         : in  std_ulogic;
    doneout      : out std_ulogic;
    sdout        : out std_ulogic;
    diagloop_out : out std_ulogic;
    waitin       : in  std_ulogic;
    failin       : in  std_ulogic;
    waitout      : out std_ulogic;
    failout      : out std_ulogic;

-- abist engine
    abist_done           : in  std_ulogic;  -- bist engine done
    abist_start_test_int : out std_ulogic;  -- start bist
    abist_start_test     : in  std_ulogic;  -- start bist
    abist_si             : out std_ulogic;  -- to SI of bist engine (reg write)
    abist_mode_dc        : in  std_ulogic;
    abist_mode_dc_int    : out std_ulogic;

-- back ends
    bo_unload  : out std_ulogic;
    bo_load    : out std_ulogic;
    bo_repair  : out std_ulogic;   -- load repair reg
    bo_reset   : out std_ulogic;   -- reset backends
    bo_shdata  : out std_ulogic;  -- shift data for timing and signature write and diag loop
    bo_select  : out std_ulogic_vector(0 to num_backends-1);  -- select for mask and hier writes
    bo_fail    : in  std_ulogic_vector(0 to num_backends-1);  -- fail/no-fix
    bo_diagout : in  std_ulogic_vector(0 to num_backends-1);  -- to diag mux

-- thold / scan
    lbist_ac_mode_dc   : in  std_ulogic;
    ck_bo_sl_thold_6   : in  std_ulogic;
    ck_bo_sl_thold_0   : in  std_ulogic;  -- local thold
    ck_bo_sg_0         : in  std_ulogic;  -- local scan gate
    lcb_mpw1_dc_b      : in  std_ulogic;
    lcb_mpw2_dc_b      : in  std_ulogic;
    lcb_delay_lclkr_dc : in  std_ulogic;
    lcb_clkoff_dc_b    : in  std_ulogic;
    lcb_act_dis_dc     : in  std_ulogic;
    scan_in            : in  std_ulogic;  -- scan in for frontend regs
    scan_out           : out std_ulogic;  -- scan out for frontend regs

-- top level thold / sg outputs, may be again overrided in leaves
    bo_pc_abst_sl_thold_6    : out std_ulogic;   -- thold to abist registers
    bo_pc_pc_abst_sl_thold_6 : out std_ulogic;   -- thold to bist engine
    bo_pc_ary_nsl_thold_6    : out std_ulogic;   -- thold to arrays
    bo_pc_func_sl_thold_6    : out std_ulogic;   -- thold to staging latches
    bo_pc_time_sl_thold_6    : out std_ulogic;   -- thold to timing regs
    bo_pc_repr_sl_thold_6    : out std_ulogic;   -- thold to repair regs
    bo_pc_sg_6               : out std_ulogic);  -- scan enable to all registers,
                                   -- actual shifting controlled by tholds

-- synopsys translate_off


-- synopsys translate_on
end pcq_abist_bolton_frontend;

architecture pcq_abist_bolton_frontend of pcq_abist_bolton_frontend is
--=====================================================================
-- Types and Constants
--=====================================================================

  subtype Rstate is integer range 0 to 13;
  subtype Tstate is std_ulogic_vector(Rstate);
  subtype Renum is integer range 0 to 11;
  subtype Tenum is std_ulogic_vector(Renum);
  subtype Rinstruction is integer range 0 to 19;
  subtype Tinstruction is std_ulogic_vector(Rinstruction);
  subtype Rmode is integer range Rinstruction'right-19 to Rinstruction'right-17;
  subtype Tmode is std_ulogic_vector(Rmode);

  constant Rkind       : integer := Rinstruction'right-16;
  constant Rloop       : integer := Rinstruction'right-10;
  constant Raccumulate : integer := Rinstruction'right-7;
  constant RFARR       : integer := Rinstruction'right-1;
  constant Rmfctmode   : integer := Rinstruction'right;

  subtype Tkind is std_ulogic;
  subtype Raddr is integer range Rinstruction'right-15 to Rinstruction'right-4;
  subtype Taddr is std_ulogic_vector(Raddr);
  subtype Rw_addr is integer range Rinstruction'right-3 to Rinstruction'right;
  subtype Tw_addr is std_ulogic_vector(0 to 3);
  subtype Rr_addr is integer range Rinstruction'right-7 to Rinstruction'right;
  subtype Tr_addr is std_ulogic_vector(0 to 7);
  subtype Tshuttle is std_ulogic_vector(bo_fail'range);
  subtype Tmemmask is Tshuttle;
  subtype Tcounter is std_ulogic_vector(0 to 11);
  subtype Tdiagptr is std_ulogic_vector(0 to 7);

  constant Rdiagptr_enable   : integer := 0;  -- bit set to 0: diag rotate disabled, no arrays selected during hierarchical writes
  constant Rdiagptr_override : integer := 7;  -- bit set to 0: bits 1-7 select array for diag/hierarchical write; bit set to 1: all arrays selected for hier. write

  subtype  Rbackend_select is integer range 1 to 6;
  subtype  Tdiagdecr is std_ulogic_vector(0 to 31);
  subtype  Rdiagdecr is integer range Tdiagdecr'right-29 to Tdiagdecr'right;
  constant Rdiagdecr_enable : integer := Tdiagdecr'right-30;
  constant Rdiagdecr_evs    : integer := Tdiagdecr'right-31;

  constant type_num          : std_ulogic_vector(0 to 11) := X"129";  
  constant fareg_length      : Tcounter                   := X"020";
  constant max_sticky_length : Tcounter                   := X"240";
  constant warmup_length     : Tcounter                   := X"010";

  constant scan_offset_0  : integer := 0;
  constant scan_offset_1  : integer := scan_offset_0 + 7;
  constant scan_offset_2  : integer := scan_offset_1 + 3;
  constant scan_offset_3  : integer := scan_offset_2 + Tstate'length + 3;
  constant scan_offset_4  : integer := scan_offset_3 + Tenum'length;
  constant scan_offset_5  : integer := scan_offset_4 + Tinstruction'length;
  constant scan_offset_6  : integer := scan_offset_5 + Tshuttle'length;
  constant scan_offset_7  : integer := scan_offset_6 + Tcounter'length;
  constant scan_offset_8  : integer := scan_offset_7 + Tdiagptr'length;
  constant scan_offset_9  : integer := scan_offset_8 + 1;
  constant scan_offset_10 : integer := scan_offset_9 + Tmemmask'length;
  constant scan_offset_11 : integer := scan_offset_10 + 1;
  constant scan_offset_12 : integer := scan_offset_11 + Tdiagdecr'length;
  constant scan_offset_13 : integer := scan_offset_12 + 2;
  constant scan_offset_14 : integer := scan_offset_13 + bo_fail'length;
  subtype  Tint_scan is std_ulogic_vector(0 to scan_offset_14-1);

  type     sul_bool is array(boolean) of std_ulogic;
  constant pos : sul_bool := (
    false => '0' ,
    true  => '1');

--=====================================================================
-- State Machine Constants
--=====================================================================
  constant SC_IDLE         : integer := 0;
  constant SC_ENUM         : integer := 1;
  constant SC_WRITE        : integer := 2;
  constant SC_READ         : integer := 3;
  constant SC_IRLOAD       : integer := 4;
  constant SC_DIAGROT      : integer := 5;
  constant SC_0            : integer := 6;
  constant SC_1            : integer := 7;
  constant SC_2            : integer := 8;
  constant SC_3PRE         : integer := 9;
  constant SC_3            : integer := 10;
  constant SC_4            : integer := 11;
  constant SC_RUNBST       : integer := 12;
  constant SC_CLEAR        : integer := 13;
  constant SM_IDLE         : Tstate  := "10000000000000";
  constant SM_ENUM         : Tstate  := "01000000000000";
  constant SM_WRITE        : Tstate  := "00100000000000";
  constant SM_READ         : Tstate  := "00010000000000";
  constant SM_IRLOAD       : Tstate  := "00001000000000";
  constant SM_DIAGROT      : Tstate  := "00000100000000";
  constant SM_0            : Tstate  := "00000010000000";
  constant SM_1            : Tstate  := "00000001000000";
  constant SM_2            : Tstate  := "00000000100000";
  constant SM_3PRE         : Tstate  := "00000000010000";
  constant SM_3            : Tstate  := "00000000001000";
  constant SM_4            : Tstate  := "00000000000100";
  constant SM_RUNBST       : Tstate  := "00000000000010";
  constant SM_CLEAR        : Tstate  := "00000000000001";
  constant MODE_RUN        : Tmode   := "000";
  constant MODE_ENUM       : Tmode   := "001";
  constant MODE_READ       : Tmode   := "010";
  constant MODE_WRITE      : Tmode   := "011";
  constant ADDR_BISTMASK   : Tw_addr := X"0";   -- control reg 0
  constant ADDR_MEMMASK    : Tw_addr := X"1";   -- control reg 1
  constant ADDR_DIAGPTR    : Tw_addr := X"2";   -- control reg 2
  constant ADDR_RBISTMASK  : Tr_addr := X"00";  -- read control reg 0
  constant ADDR_RMEMMASK   : Tr_addr := X"01";  -- read control reg 1
  constant ADDR_RDIAGPTR   : Tr_addr := X"02";  -- read control reg 2
  constant ADDR_ABIST      : Tw_addr := X"B";   -- control reg B
  constant ADDR_TIMING     : Tw_addr := X"C";   -- control reg C
  constant ADDR_SIGNATURE  : Tw_addr := X"D";   -- control reg D
  constant ADDR_DIAGCOUNT  : Tw_addr := X"E";   -- control reg E
  constant ADDR_RDIAGCOUNT : Tr_addr := X"0E";  -- read control reg E
  constant ADDR_TYPE       : Tr_addr := X"10";  -- status reg 0
  constant ADDR_ENUM       : Tr_addr := X"11";  -- status reg 1
  constant ADDR_BISTDONE   : Tr_addr := X"12";  -- status reg 2
  constant ADDR_WAIT       : Tr_addr := X"13";  -- status reg 3
  constant ADDR_FAIL       : Tr_addr := X"14";  -- status reg 4


--=====================================================================
-- Signal Declarations
--=====================================================================

  signal state_q, state_d                                         : Tstate;
  signal instruction_d, instruction_q                             : Tinstruction;
  signal shift_instruction, shift_write                           : std_ulogic;
  signal shuttle_select, shuttle_d, shuttle_q                     : Tshuttle;
  signal shift_shuttle                                            : std_ulogic;
--
  signal enum_d, enum_q                                           : Tenum;
  signal clear_enum, count_enum                                   : std_ulogic;
  signal mode                                                     : Tmode;
  signal kind                                                     : Tkind;
  signal addr                                                     : Taddr;
  signal w_reg_addr                                               : Tw_addr;
  signal r_reg_addr                                               : Tr_addr;
  signal reg_select                                               : std_ulogic;
  signal s_idle, s_enum, s_write, s_read, s_irload,
    s_diagrot, s_0, s_1, s_2, s_3pre, s_3, s_4, s_runbst, s_clear : std_ulogic;
  signal s_3pre_delayed, s_3_delayed, s_4_delayed : std_ulogic;
  signal bistmask_d, bistmask_q, shift_bistmask   : std_ulogic;
  signal bistdone_q, bistdone_d                   : std_ulogic;
  signal memmask_d, memmask_q                     : Tmemmask;
  signal shift_memmask                            : std_ulogic;

  signal done_d, done_q, wait_d, wait_q, fail_d, fail_q                                      : std_ulogic;
  signal bcshctrl_ff, bcdata_ff, bcshdata_ff, bcexe_ff, bcreset_ff, bo_go_ff, bcsysrepair_ff : std_ulogic;
  signal write_signature, write_timing                                                       : std_ulogic;
  signal int_scan_in, int_scan_out                                                           : Tint_scan;
  signal ck_bo_sl_thold_0_b                                                                  : std_ulogic;
  signal force_func                                                                          : std_ulogic;
  signal count_d, count_q                                                                    : Tcounter;
  signal count_done                                                                          : std_ulogic;

  signal diagptr_q, diagptr_d             : Tdiagptr;
  signal shift_diagptr                    : std_ulogic;
  signal diagmux_and                      : std_ulogic_vector(bo_diagout'range);
  signal bo_select_int                    : std_ulogic_vector(bo_select'range);
  signal sg_int                           : std_ulogic;
  signal diagdecr_q, diagdecr_d           : Tdiagdecr;
  signal shift_diagcount, diagdecr_zero   : std_ulogic;
  signal diagloop_out_d, diagloop_out_int : std_ulogic;
  signal write_abist_q, write_abist_d     : std_ulogic;
  signal bo_fail_ff, bo_fail_pre          : std_ulogic_vector(0 to num_backends-1);

begin

  sg_int <= '0' when bo_enable = '1' else ck_bo_sg_0;

--=====================================================================
-- Shuttle and Diagloop
--=====================================================================
  shift_shuttle <= bcshdata_ff and ((s_idle and pos(mode = MODE_READ)) or (s_idle and pos(mode = MODE_RUN)) or s_diagrot or s_read) and bo_enable;

  shuttle : process (bistdone_q, bistmask_q, bo_fail_ff, diagdecr_q, diagptr_q,
                     enum_q, memmask_q, r_reg_addr) is
  begin
    shuttle_select <= (others => '0');
    case r_reg_addr is
      when ADDR_RBISTMASK => shuttle_select(Tshuttle'right)                                   <= bistmask_q;
      when ADDR_RMEMMASK  => shuttle_select                                                   <= memmask_q;
      when ADDR_RDIAGPTR  => shuttle_select(Tshuttle'right-diagptr_q'right to Tshuttle'right) <= diagptr_q;
      when ADDR_RDIAGCOUNT=> shuttle_select(Tshuttle'right-Tdiagdecr'right to Tshuttle'right) <= diagdecr_q;
      when ADDR_TYPE      => shuttle_select(Tshuttle'right-type_num'right to Tshuttle'right)  <= type_num;
      when ADDR_ENUM      => shuttle_select(Tshuttle'right-Tenum'right to Tshuttle'right)     <= enum_q;
      when ADDR_BISTDONE  => shuttle_select(Tshuttle'right)                                   <= bistdone_q;
      when ADDR_FAIL      => shuttle_select                                                   <= bo_fail_ff;
      when others         => null;
    end case;
  end process;

  shuttle_d <= shuttle_q(1 to shuttle_q'right) & sdin when (shift_shuttle and not s_diagrot) = '1' else
               shuttle_q(1 to shuttle_q'right) & diagloop_out_int when (shift_shuttle and s_diagrot) = '1'
               else shuttle_select;
  sdout <= shuttle_q(shuttle_d'left);

  diagmux : for i in bo_diagout'range generate
  begin
    diagmux_and(i) <= bo_diagout(i) and bo_select_int(i);
  end generate;
  diagloop_out_int <= or_reduce(diagmux_and) and diagptr_q(Rdiagptr_enable) and s_diagrot;
  diagloop_out_d   <= diagloop_out_int and not lbist_ac_mode_dc;

--=====================================================================
-- Instruction register & universal registers
--=====================================================================
  shift_instruction <= bcshctrl_ff and (s_idle or s_irload) and bo_enable;
  instruction_d     <= instruction_q(1 to instruction_q'right) & bcdata_ff;
  abist_si          <= bcdata_ff and not bcreset_ff;
  shift_write       <= ((s_idle and pos(mode = MODE_WRITE)) or s_write) and bcshdata_ff and bo_enable;
  shift_diagptr     <= shift_write and reg_select and pos(w_reg_addr = ADDR_DIAGPTR) and bo_enable;
  diagptr_d         <= diagptr_q(1 to diagptr_q'right) & bcdata_ff;

  shift_diagcount <= shift_write and reg_select and pos(w_reg_addr = ADDR_DIAGCOUNT) and bo_enable;
  diagdecr_d      <= diagdecr_q(1 to diagdecr_q'right) & bcdata_ff
                when shift_diagcount = '1'                                 else
                diagdecr_q(diagdecr_q'left to Rdiagdecr'left-1) & (diagdecr_q(Rdiagdecr) - 1)
                when s_runbst = '1' and diagdecr_q(Rdiagdecr_enable) = '1' else
                diagdecr_q;
  diagdecr_zero   <= pos(diagdecr_q(Rdiagdecr) = 0) and diagdecr_q(Rdiagdecr_enable);

  shift_bistmask <= shift_write and reg_select and pos(w_reg_addr = ADDR_BISTMASK) and bo_enable;
  bistmask_d     <= bcdata_ff;

  shift_memmask <= shift_write and reg_select and pos(w_reg_addr = ADDR_MEMMASK) and bo_enable;
  memmask_d     <= memmask_q(1 to memmask_q'right) & bcdata_ff;

  write_timing    <= shift_write and reg_select and pos(w_reg_addr = ADDR_TIMING);
  write_signature <= shift_write and reg_select and pos(w_reg_addr = ADDR_SIGNATURE);
  write_abist_d   <= shift_write and reg_select and pos(w_reg_addr = ADDR_ABIST) and not lbist_ac_mode_dc;

--=====================================================================
-- Backend selection from diagptr
--=====================================================================
  bo_select_decoder : for i in bo_select'range generate
  begin
    bo_select_int(i) <= (diagptr_q(Rdiagptr_override) or pos(diagptr_q(Rbackend_select) = i))
                        and diagptr_q(Rdiagptr_enable);
  end generate;
  bo_select          <= (others => '0') when lbist_ac_mode_dc = '1' else bo_select_int when (shift_write and reg_select) = '1' else not memmask_q;

  bo_repair   <= s_4 and not lbist_ac_mode_dc;
  bo_unload   <= (s_3 or s_3pre) and not lbist_ac_mode_dc;
  bo_reset    <= bcreset_ff or s_clear or (s_runbst and abist_done) or (s_3pre and count_done) or (s_3 and count_done) or lbist_ac_mode_dc;  -- reset fail/nofix bits during warmup, reset counters at end of a state
  bo_shdata   <= '0'             when lbist_ac_mode_dc = '1' else shuttle_d(shuttle_d'left) when s_diagrot = '1' else bcdata_ff and not bcreset_ff;
  bo_load     <= (write_signature) and not lbist_ac_mode_dc;
  bo_fail_pre <= (others => '0') when lbist_ac_mode_dc = '1' else bo_fail;

--=====================================================================
-- Counters
--=====================================================================
  count_done <= pos(count_q = X"000");
  bistdone_d <= '0' when s_0 = '1' or s_clear = '1' else '1' when (s_4 = '1' and count_done = '1') or diagdecr_zero = '1' else bistdone_q;

--=====================================================================
-- Enumeration counter
--=====================================================================
  clear_enum <= s_idle and bcexe_ff and pos(mode = MODE_ENUM);
  count_enum <= s_enum;
  enum_d     <= (others => '0') when clear_enum = '1' else enum_q + 1 when count_enum = '1' else enum_q;

--=====================================================================
-- Daisy Chain FFs
--=====================================================================
  done_d <= donein and (bistmask_q or bistdone_q or (s_idle and pos(mode = MODE_ENUM)) or s_enum);
  wait_d <= waitin and bistdone_q and diagdecr_q(Rdiagdecr_evs);
  fail_d <= failin or (not bistmask_q and s_idle and or_reduce(bo_fail_ff and memmask_q));

--=====================================================================
-- Thold/SG Decoder
--=====================================================================
  bo_pc_abst_sl_thold_6 <= ck_bo_sl_thold_6 when (bcreset_ff or s_3_delayed or s_clear)='1' 
                           else '0' when (s_1 or s_2 or s_runbst)='1' and diagdecr_zero='0' 
			   else '1';
  bo_pc_ary_nsl_thold_6 <= not(bcreset_ff or s_2 or s_runbst);
  bo_pc_func_sl_thold_6 <= not(s_0 or s_1 or s_2 or s_runbst);
  bo_pc_time_sl_thold_6 <= ck_bo_sl_thold_6 when (write_timing)='1' else '1'; -- not during reset
  bo_pc_repr_sl_thold_6 <= ck_bo_sl_thold_6 when (s_4_delayed or s_3pre_delayed)='1' else '1'; -- not during reset
  
  bo_pc_sg_6 <= bcreset_ff or write_abist_q or write_timing or s_4_delayed or s_3_delayed or s_3pre_delayed or s_clear;
  abist_start_test_int <= s_runbst and not abist_done when bo_enable='1' else abist_start_test;
  bo_pc_pc_abst_sl_thold_6 <= ck_bo_sl_thold_6 when write_abist_q='1' else '0' when (s_1 or s_2 or bcreset_ff or s_runbst)='1' else '1';
  abist_mode_dc_int <= s_0 or s_1 or s_2 or s_runbst when bo_enable='1' else abist_mode_dc;

--=====================================================================
-- State Transitions
--=====================================================================
  trans : process (abist_done, bcexe_ff, bcreset_ff, bcshctrl_ff, bcshdata_ff,
                   bo_go_ff, count_done, count_q, diagdecr_q(Rdiagdecr_evs), diagdecr_zero,
                   done_q, instruction_q(Raccumulate), instruction_q(RFARR),
                   instruction_q(Rloop), mode, state_q, bcsysrepair_ff) is
  begin
    state_d <= state_q;
    count_d <= count_q - 1;
    case state_q is
	when SM_IDLE => 
	    if (bcshctrl_ff = '1') then 
		state_d <= SM_IRLOAD;
	    else
		case mode is
		when MODE_ENUM => if bcexe_ff = '1' then state_d <= SM_ENUM; end if;
		when MODE_READ => if bcshdata_ff = '1' then state_d <= SM_READ; end if;
		when MODE_WRITE => if bcshdata_ff = '1' then state_d <= SM_WRITE; end if;
		when MODE_RUN => 
		    if bo_go_ff = '1' then 
                        if instruction_q(Raccumulate)='1' then
			    state_d <= SM_0;
			    count_d <= warmup_length;
			else
			    state_d <= SM_CLEAR;
			    count_d <= max_sticky_length;
			end if;
		    elsif bcshdata_ff = '1' then 
			state_d <= SM_DIAGROT; 
		    end if;
		when others => null;
		end case;
	    end if;
	when SM_IRLOAD => 
	    if (bcshctrl_ff = '0') then 
		state_d <= SM_IDLE;
	    end if;
	when SM_ENUM => 
	    if (done_q = '1') then 
		state_d <= SM_IDLE;
	    end if;
	when SM_READ => 
	    if (bcshdata_ff = '0') then 
		state_d <= SM_IDLE;
	    end if;
	when SM_WRITE => 
	    if (bcshdata_ff = '0') then 
		state_d <= SM_IDLE;
	    end if;
	when SM_DIAGROT => 
	    if (bcshdata_ff = '0') then 
		state_d <= SM_IDLE;
	    end if;
	when SM_CLEAR => 
	    if (count_done = '1') then
		state_d <= SM_0;
		count_d <= warmup_length;
	    end if;
	when SM_0 => 
	    if (count_done = '1') then
		state_d <= SM_1;
		count_d <= warmup_length;
	    end if;
	when SM_1 => 
	    if (count_done = '1') then
		state_d <= SM_2;
	    end if;
	when SM_2 => 
	    if (bcexe_ff = '1') then 
		state_d <= SM_RUNBST;
	    end if;
	when SM_RUNBST => 
	    if (abist_done = '1') then 
		state_d <= SM_3PRE;
	    end if;
	    if diagdecr_zero = '1' then
		state_d <= SM_IDLE;
            end if; 
	    count_d <= fareg_length;
	when SM_3PRE => 
	    if (count_done = '1') then 
		state_d <= SM_3;
		count_d <= max_sticky_length;
	    end if;
	when SM_3 => 
	    if (count_done = '1') then 
		if (diagdecr_q(Rdiagdecr_evs) = '0' or instruction_q(RFARR)='1' or bcsysrepair_ff='1') then
		    state_d <= SM_4;
		else
		    state_d <= SM_IDLE;
		end if;
		count_d <= fareg_length;
	    end if;
	when SM_4 => 
	    if (count_done = '1') then 
                if instruction_q(Rloop) = '1' then
		    state_d <= SM_0;
                else 
		    state_d <= SM_IDLE;
		end if;
	    end if;
	when others => state_d <= SM_IDLE;
    end case;
    if bcreset_ff = '1' then
      state_d <= SM_IDLE;
    end if;
  end process;

--=====================================================================
-- Latches
--=====================================================================
input_reg: entity tri.tri_boltreg_p  
  generic map (width => scan_offset_1 - scan_offset_0, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_0 to scan_offset_1-1),
            scout   => int_scan_out(scan_offset_0 to scan_offset_1-1),
            din(0)  => bcdata,
            din(1)  => bcshcntl,
            din(2)  => bcshdata,
            din(3)  => bcexe,
	    din(4)  => bcreset,
	    din(5)  => bo_go,
	    din(6)  => bcsysrepair,
            dout(0) => bcdata_ff,
            dout(1) => bcshctrl_ff,
            dout(2) => bcshdata_ff,
            dout(3) => bcexe_ff,
	    dout(4) => bcreset_ff,
	    dout(5) => bo_go_ff,
	    dout(6) => bcsysrepair_ff);

daisy_reg: entity tri.tri_boltreg_p  
  generic map (width => scan_offset_2 - scan_offset_1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_1 to scan_offset_2-1),
            scout   => int_scan_out(scan_offset_1 to scan_offset_2-1),
            din(0)  => done_d,
            din(1)  => wait_d,
            din(2)  => fail_d,
            dout(0) => done_q,
            dout(1) => wait_q,
            dout(2) => fail_q );

doneout <= done_q;
waitout <= wait_q;
failout <= fail_q;

state_reg: entity tri.tri_boltreg_p  
  generic map (width => scan_offset_3 - scan_offset_2, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_2 to scan_offset_3-1),
            scout   => int_scan_out(scan_offset_2 to scan_offset_3-1),
            din(Tstate'range)      => state_d,
	    din(Tstate'right + 1)  => s_3pre,
	    din(Tstate'right + 2)  => s_3,
	    din(Tstate'right + 3)  => s_4,
            dout(Tstate'range)     => state_q,
	    dout(Tstate'right + 1) => s_3pre_delayed,
	    dout(Tstate'right + 2) => s_3_delayed,
	    dout(Tstate'right + 3) => s_4_delayed);

    s_idle <= state_q(SC_IDLE);
    s_enum <= state_q(SC_ENUM);
    s_write <= state_q(SC_WRITE);
    s_read <= state_q(SC_READ);
    s_irload <= state_q(SC_IRLOAD);
    s_diagrot <= state_q(SC_DIAGROT);
    s_0 <= state_q(SC_0);
    s_1 <= state_q(SC_1);
    s_2 <= state_q(SC_2);
    s_3pre <= state_q(SC_3PRE);
    s_3 <= state_q(SC_3);
    s_4 <= state_q(SC_4);
    s_runbst <= state_q(SC_RUNBST);
    s_clear <= state_q(SC_CLEAR);

enum_reg: entity tri.tri_boltreg_p  
  generic map (width => enum_d'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_3 to scan_offset_4-1),
            scout   => int_scan_out(scan_offset_3 to scan_offset_4-1),
            din     => enum_d,
            dout    => enum_q );

instr_reg: entity tri.tri_boltreg_p  
  generic map (width => instruction_d'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => shift_instruction,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_4 to scan_offset_5-1),
            scout   => int_scan_out(scan_offset_4 to scan_offset_5-1),
            din     => instruction_d,
            dout    => instruction_q );

mode <= instruction_q(Rmode);
kind <= instruction_q(Rkind);
addr <= instruction_q(Raddr);
w_reg_addr <= instruction_q(Rw_addr);
r_reg_addr <= instruction_q(Rr_addr);
reg_select <= '1' when addr = X"000" or (kind = '1' and addr = type_num) or (kind = '0' and addr = enum_q) else '0';

shuttle_reg: entity tri.tri_boltreg_p  
  generic map (width => shuttle_d'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_5 to scan_offset_6-1),
            scout   => int_scan_out(scan_offset_5 to scan_offset_6-1),
            din     => shuttle_d,
            dout    => shuttle_q );

count_reg: entity tri.tri_boltreg_p  
  generic map (width => count_d'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_6 to scan_offset_7-1),
            scout   => int_scan_out(scan_offset_6 to scan_offset_7-1),
            din     => count_d,
            dout    => count_q );

diagptr_reg: entity tri.tri_boltreg_p  
  generic map (width => diagptr_d'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => shift_diagptr,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_7 to scan_offset_8-1),
            scout   => int_scan_out(scan_offset_7 to scan_offset_8-1),
            din     => diagptr_d,
            dout    => diagptr_q );

bistmask_reg: entity tri.tri_boltreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => shift_bistmask,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_8 to scan_offset_9-1),
            scout   => int_scan_out(scan_offset_8 to scan_offset_9-1),
            din(0)     => bistmask_d,
            dout(0)    => bistmask_q );

memmask_reg: entity tri.tri_boltreg_p  
  generic map (width => memmask_d'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => shift_memmask,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_9 to scan_offset_10-1),
            scout   => int_scan_out(scan_offset_9 to scan_offset_10-1),
            din     => memmask_d,
            dout    => memmask_q );

bistdone_reg: entity tri.tri_boltreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_10 to scan_offset_11-1),
            scout   => int_scan_out(scan_offset_10 to scan_offset_11-1),
            din(0)     => bistdone_d,
            dout(0)    => bistdone_q );

diagdecr_reg: entity tri.tri_boltreg_p  
  generic map (width => diagdecr_d'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_11 to scan_offset_12-1),
            scout   => int_scan_out(scan_offset_11 to scan_offset_12-1),
            din     => diagdecr_d,
            dout    => diagdecr_q );

out_reg: entity tri.tri_boltreg_p
  generic map (width => scan_offset_13 - scan_offset_12, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_12 to scan_offset_13-1),
            scout   => int_scan_out(scan_offset_12 to scan_offset_13-1),
            din(0)  => diagloop_out_d,
            din(1)  => write_abist_d,
            dout(0) => diagloop_out,
            dout(1) => write_abist_q );

fail_reg: entity tri.tri_boltreg_p
  generic map (width => scan_offset_14 - scan_offset_13, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => bo_enable,
            thold_b => ck_bo_sl_thold_0_b,
            sg      => sg_int,
            forcee => force_func,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => int_scan_in(scan_offset_13 to scan_offset_14-1),
            scout   => int_scan_out(scan_offset_13 to scan_offset_14-1),
            din     => bo_fail_pre,
            dout    => bo_fail_ff );


int_scan_in(0) <= scan_in and not bo_enable;
int_scan_in(1 to int_scan_in'right) <= int_scan_out(0 to int_scan_out'right-1);
scan_out <= int_scan_out(int_scan_out'right);

--=====================================================================
-- Thold/SG Staging
--=====================================================================
lcbor_func: entity tri.tri_lcbor
generic map (expand_type => expand_type )
port map (
    clkoff_b => lcb_clkoff_dc_b,
    thold    => ck_bo_sl_thold_0,
    sg       => sg_int,
    act_dis  => lcb_act_dis_dc,
    forcee => force_func,
    thold_b  => ck_bo_sl_thold_0_b );

-----------------------------------------------------------------------
end pcq_abist_bolton_frontend;
