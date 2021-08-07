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

-- *!****************************************************************
-- *! FILENAME    : tri_serial_scom2.vhdl
-- *! DESCRIPTION : SCOM Satellite
-- *!               Only supports 1:1 ratio
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;
library ibm; 
             use ibm.std_ulogic_support.all;
             use ibm.std_ulogic_function_support.all;
             use ibm.std_ulogic_unsigned.all;
library support;
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;

entity tri_serial_scom2 is

  generic (
           width              : positive := 64;    -- 64 is the maximum allowed
           internal_addr_decode: boolean := false;
           use_addr           : std_ulogic_vector := "1000000000000000000000000000000000000000000000000000000000000000";
           addr_is_rdable     : std_ulogic_vector := "1000000000000000000000000000000000000000000000000000000000000000";
           addr_is_wrable     : std_ulogic_vector := "1000000000000000000000000000000000000000000000000000000000000000";
           pipeline_addr_v    : std_ulogic_vector := "0000000000000000000000000000000000000000000000000000000000000000";
           pipeline_paritychk : boolean  := false; -- pipeline parcheck for timing
           satid_nobits       : positive := 4;     -- should not be set by user
           regid_nobits       : positive := 6;
           ringid_nobits      : positive := 3;
           expand_type        : integer := 1 );    -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)

  port (
        -- clock, scan and misc interfaces
        nclk                 : in  clk_logic;
        vd                   : inout power_logic;
        gd                   : inout power_logic;
        scom_func_thold      : in  std_ulogic;
        sg                   : in  std_ulogic;
        act_dis_dc           : in  std_ulogic;
        clkoff_dc_b          : in  std_ulogic;
        mpw1_dc_b            : in  std_ulogic;
        mpw2_dc_b            : in  std_ulogic;
        d_mode_dc            : in  std_ulogic;
        delay_lclkr_dc       : in  std_ulogic;

        --! scan chain should evaluate to 0:176 for WIDTH=64 and 6 regid_nobits (=64 SCOM addresses)
        --! scan chain vector is longer than number of latches being used
        --! scan chain should evaluate to 0:176 for WIDTH=64 and 6 regid_nobits (=64 SCOM addresses)
        --! scan chain vector is longer than number of latches being used
        --! due to vhdl generics formulation and shortings
        func_scan_in         : in  std_ulogic_vector(0 to
                             (((width+15)/16)*16)+2*(((((width+15)/16)*16)-1)/16+1)+(2**regid_nobits)+40 );
        --                   |                  |
        --                   data_shifter
        --                                          |  par_nobits                 |
        func_scan_out        : out std_ulogic_vector(0 to
                             (((width+15)/16)*16)+2*(((((width+15)/16)*16)-1)/16+1)+(2**regid_nobits)+40 );


        -- for mask slat inside of c_err_rpt
        dcfg_scan_dclk       : in  std_ulogic;
        dcfg_scan_lclk       : in  clk_logic;

        --! for nlats inside of c_err_rpt
        dcfg_d1clk           : in  std_ulogic; -- needed for one bit only, always or scom_local_act clocked dcfg
        dcfg_d2clk           : in  std_ulogic; -- needed for one bit only, always or scom_local_act clocked dcfg
        dcfg_lclk            : in  clk_logic; -- needed for one bit only, always or scom_local_act clocked dcfg

        -- contains mask slat and hold nlat of c_err_rpt
        dcfg_scan_in         : in  std_ulogic_vector(0 to 1);
        dcfg_scan_out        : out std_ulogic_vector(0 to 1);

        -- denotes SCOM sat active if set to '1', can be used for local clock gating
        scom_local_act       : out std_ulogic;

        -----------------------------------------------------------------------
        -- SCOM Interface
        -----------------------------------------------------------------------
        -- SCOM satellite ID tied to a specific pattern
        sat_id               : in std_ulogic_vector(0 to satid_nobits-1);

        -- SCOM Data Channel input (carry both address and data)
        scom_dch_in          : in  std_ulogic;

        -- SCOM Control Channel input
        scom_cch_in          : in  std_ulogic;

        -- SCOM Data Channel output
        scom_dch_out         : out std_ulogic;

        -- SCOM Control Channel output
        scom_cch_out         : out std_ulogic;

        -----------------------------------------------------------------------
        -- Interface between SCOM satellite and internal macro logic
        -----------------------------------------------------------------------
        -- denotes a request if asserted to '1', level
        sc_req               : out std_ulogic;

        -- acknowledge a pending request with sc_ack_info+sc_rdata+sc_rparity
        -- being valid
        sc_ack               : in  std_ulogic;

        -- acknowledge information
        -- 0: '1' if access violation, otherwise '0'
        -- 1: '1' if register address invalid
        sc_ack_info          : in  std_ulogic_vector(0 to 1);

        -- '1' if read access, '0' write access
        sc_r_nw              : out std_ulogic;

        -- Register address, default 6 bits for up to 64 register addresses
        sc_addr              : out std_ulogic_vector(0 to regid_nobits-1);

        -- one-hot address, valid only if INTERNAL_ADDR_DECODE=TRUE, else zeros
        addr_v               : out std_ulogic_vector(0 to use_addr'high);

        -- Read data delivered by macro logic as response to a read request
        sc_rdata             : in  std_ulogic_vector(0 to width-1);

        -- Write data delivered from SCOM satellite for a write request
        sc_wdata             : out std_ulogic_vector(0 to width-1);

        -- Write data parity bit over sc_wdata, optional usage
        sc_wparity           : out std_ulogic;

        -----------------------------------------------------------------------
        -- parity error of fsm state vector, wire to next local fir
        scom_err             : out std_ulogic;

        -- reset fsm (optional), tie to '0' if unused
        fsm_reset            : in  std_ulogic

        );
  -- synopsys translate_off

  -- synopsys translate_on

end tri_serial_scom2;

architecture tri_serial_scom2 of tri_serial_scom2 is

begin  -- tri_serial_scom2

  a: if expand_type /= 2 generate
     constant state_width : positive := 5 ;
     constant i_width     : positive := (((width+15)/16)*16);  -- width adjusted to 16-bit boundary
     constant par_nobits  : positive := (i_width-1)/16+1;
     constant reg_nobits  : positive := regid_nobits;  -- 6
     constant satid_regid_nobits : positive := satid_nobits + regid_nobits;  -- 4 + 6 = 10
     constant rw_bit_index       : positive := satid_regid_nobits + 1;  -- 11
     constant parbit_index       : positive := rw_bit_index + 1;  -- 12
     constant head_width         : positive := parbit_index + 1;
     constant head_init          : std_ulogic_vector( 0 to head_width-1) := "0000000000000";

                                                                     --0123Parity
     constant idle         : std_ulogic_vector(0 to state_width-1) := "00000";  -- 0  = x00
     constant rec_head     : std_ulogic_vector(0 to state_width-1) := "00011";  -- 1  = x03
     constant check_before : std_ulogic_vector(0 to state_width-1) := "00101";  -- 2  = x05
     constant rec_wdata    : std_ulogic_vector(0 to state_width-1) := "00110";  -- 3  = x06
     constant rec_wpar     : std_ulogic_vector(0 to state_width-1) := "01001";  -- 4  = x09
     constant exe_cmd      : std_ulogic_vector(0 to state_width-1) := "01010";  -- 5  = x0A
     constant filler0      : std_ulogic_vector(0 to state_width-1) := "01100";  -- 6  = x0C
     constant filler1      : std_ulogic_vector(0 to state_width-1) := "01111";  -- 7  = x0F
     constant gen_ulinfo   : std_ulogic_vector(0 to state_width-1) := "10001";  -- 8  = x11
     constant send_ulinfo  : std_ulogic_vector(0 to state_width-1) := "10010";  -- 9  = x12
     constant send_rdata   : std_ulogic_vector(0 to state_width-1) := "10100";  -- 10 = x14
     constant send_0       : std_ulogic_vector(0 to state_width-1) := "10111";  -- 11 = x17
     constant send_1       : std_ulogic_vector(0 to state_width-1) := "11000";  -- 12 = x18
     constant check_wpar   : std_ulogic_vector(0 to state_width-1) := "11011";  -- 13 = x1B
                                                                                -- 14 = x1D
     constant not_selected : std_ulogic_vector(0 to state_width-1) := "11110";  -- 15 = x1E

     constant eof_wdata : positive := parbit_index-1+64; -- here max width, it is 64
     constant eof_wpar : positive := eof_wdata + 4;

     constant eof_wdata_n : positive := parbit_index-1+ i_width;
     constant eof_wpar_m  : positive := eof_wdata + par_nobits;


     signal is_idle        : std_ulogic;
     signal is_rec_head    : std_ulogic;
     signal is_check_before: std_ulogic;
     signal is_rec_wdata   : std_ulogic;
     signal is_rec_wpar    : std_ulogic;
     signal is_exe_cmd     : std_ulogic;
     signal is_gen_ulinfo  : std_ulogic;
     signal is_send_ulinfo : std_ulogic;
     signal is_send_rdata  : std_ulogic;
     signal is_send_0      : std_ulogic;
     signal is_send_1      : std_ulogic;
     signal is_filler_0    : std_ulogic;
     signal is_filler_1    : std_ulogic;

     signal next_state, state_in, state_lt : std_ulogic_vector(0 to state_width-1);

     signal dch_lt : std_ulogic;
     signal cch_in, cch_lt : std_ulogic_vector(0 to 1);

     signal reset                                                     : std_ulogic;
     signal got_head, gor_eofwdata, got_eofwpar, sent_rdata, got_ulhead, do_send_par
            ,cntgtheadpluswidth, cntgteofwdataplusparity                      : std_ulogic;
     signal p0_err, any_ack_error, match                              : std_ulogic;
     signal p0_err_in, p0_err_lt                                      : std_ulogic;
     signal do_write, do_read                                         : std_ulogic;
     signal enable_cnt                                                : std_ulogic;
     signal cnt_in, cnt_lt                                            : std_ulogic_vector(0 to 6);
     signal head_in, head_lt                                          : std_ulogic_vector(0 to head_width-1);
     signal tail_in, tail_lt                                          : std_ulogic_vector(0 to 4);
     signal sc_ack_info_in, sc_ack_info_lt                            : std_ulogic_vector(0 to 1);
     signal head_mux                                                  : std_ulogic;

     signal data_shifter_in, data_shifter_lt         : std_ulogic_vector(0 to i_width-1);
     signal data_shifter_lt_tmp : std_ulogic_vector(0 to 63);

     signal datapar_shifter_in, datapar_shifter_lt   : std_ulogic_vector(0 to par_nobits-1);
     signal data_mux, par_mux                        : std_ulogic;
     signal dch_out_internal_in, dch_out_internal_lt : std_ulogic;
     signal parity_satid_regaddr_in                  : std_ulogic;
     signal parity_satid_regaddr_lt                  : std_ulogic;
     signal func_force                               : std_ulogic;
     signal func_thold_b, d1clk, d2clk               : std_ulogic;
     signal lclk                                     : clk_logic;
     signal local_act, local_act_int                 : std_ulogic;
     signal scom_err_in, scom_err_lt                 : std_ulogic;
     signal scom_local_act_in, scom_local_act_lt     : std_ulogic;

     signal wpar_err                  : std_ulogic;
     signal wpar_err_in, wpar_err_lt  : std_ulogic;
     signal par_data_in, par_data_lt  : std_ulogic_vector(0 to par_nobits-1);
     signal sc_rparity : std_ulogic_vector(0 to par_nobits-1);

     signal read_valid, write_valid           : std_ulogic;
     signal dec_addr_in,  dec_addr_q          : std_ulogic_vector(use_addr'range);
     signal addr_nvld                         : std_ulogic;
     signal write_nvld, read_nvld             : std_ulogic;
     signal state_par_error                   : std_ulogic;
     signal sat_id_net                        : std_ulogic_vector(0 to satid_nobits-1);

     signal unused                            : std_ulogic_vector(0 to 1);

     -- signal renaming and mapping to make it visible internally for debug
     signal scom_cch_in_int           : std_ulogic;
     signal scom_dch_in_int           : std_ulogic;
     signal scom_cch_input_in, scom_cch_input_lt   : std_ulogic;
     signal scom_dch_input_in, scom_dch_input_lt   : std_ulogic;


     signal func_scan_temp   : std_ulogic;
     signal func_scan_temp_1 : std_ulogic;
     signal func_scan_temp_2 : std_ulogic;
     signal func_scan_temp_3 : std_ulogic;
     signal func_scan_temp_4 : std_ulogic;

     signal spare_latch1_in, spare_latch1_lt   : std_ulogic;
     signal spare_latch2_in, spare_latch2_lt   : std_ulogic;

     signal unused_signals : std_ulogic;



  begin
   assert (or_reduce(use_addr)='1')
     report "pcb if component must use at least one address, generic use_addr is all zeroes"
     severity error;

   assert (use_addr'length<=2**reg_nobits)
     report "use_addr is larger than 2^reg_nobits"
     severity error;


   assert (i_width > 0)
     report "has to be in the range of 1..64"
     severity error;

   assert (i_width < 65)
     report "has to be in the range of 1..64"
     severity error;



  lcbor_func: entity tri.tri_lcbor(tri_lcbor)
    generic map ( expand_type => expand_type )
    port map (
        clkoff_b  =>  clkoff_dc_b,
        thold     =>  scom_func_thold,
        sg        =>  sg,
        act_dis   =>  act_dis_dc,
        forcee     =>  func_force,
        thold_b   =>  func_thold_b );


  lcb_func: entity tri.tri_lcbnd(tri_lcbnd)
    generic map ( expand_type => expand_type )
    port map (
        vd          => vd,
        gd          => gd,
        act         => local_act_int,
        delay_lclkr => delay_lclkr_dc,
        mpw1_b      => mpw1_dc_b,
        mpw2_b      => mpw2_dc_b,
        nclk        => nclk,
        forcee       => func_force,
        sg          => sg,
        thold_b     => func_thold_b,
        ----------------------------
        d1clk       => d1clk,
        d2clk       => d2clk,
        lclk        => lclk
        );

-------------------------------------------------------------------------------
   parity_err : entity tri.tri_err_rpt(tri_err_rpt)
      generic map (
                 width           => 1     -- use to bundle error reporting checkers of the same exact type
               , inline          => false -- make hold latch be inline
               , mask_reset_value=> "0"   -- do not report address and data parity errors by default
                                                     -- since already reported to PCB through error reply
               , needs_sreset    => 1
               , expand_type => expand_type )
      port map ( vd             => vd,
                 gd             => gd,
                 err_d1clk      => dcfg_d1clk,
                 err_d2clk      => dcfg_d2clk,
                 err_lclk       => dcfg_lclk,
                 err_scan_in    => dcfg_scan_in (0 to 0),
                 err_scan_out   => dcfg_scan_out(0 to 0),
                 mode_dclk      => dcfg_scan_dclk,
                 mode_lclk      => dcfg_scan_lclk,
                 mode_scan_in   => dcfg_scan_in (1 to 1),
                 mode_scan_out  => dcfg_scan_out(1 to 1),

                 err_in (0)     => state_par_error,
                 err_out(0)     => scom_err_in
               );

   scom_err <= scom_err_lt;    -- drive this output with a latch

-------------------------------------------------------------------------------

-- fill spares of scan vector
   func_scan_out(state_width + i_width + 2*par_nobits+head_width+22+(2**regid_nobits) to func_scan_out'high) <=
     func_scan_in(state_width + i_width + 2*par_nobits+head_width+22+(2**regid_nobits) to func_scan_out'high) ;

-------------------------------------------------------------------------------

  sat_id_net <= sat_id;
  -- input lathes on cch and dch:
  scom_cch_input_in <= scom_cch_in;
  scom_cch_in_int <= scom_cch_input_lt;
  scom_dch_input_in <= scom_dch_in;
  scom_dch_in_int <= scom_dch_input_lt;



  cch_in    <= scom_cch_in_int & cch_lt(0);

  reset     <= (cch_lt(0) and not scom_cch_in_int)   -- with falling edge of scom_cch_in / scom_cch_in_int
               or fsm_reset                          -- or with fsm_reset
               or scom_err_lt;

  local_act <= or_reduce(scom_cch_input_in & cch_lt);  -- active with scom_cch_in and as long as cch_lt

  local_act_int <= local_act or scom_local_act_lt;

  scom_local_act_in <= local_act;       -- drive this output with a latch
  scom_local_act <= scom_local_act_lt;

  scom_cch_out <= cch_lt(0);

  dch_out_internal_in <= head_lt(0)            when is_send_ulinfo='1' else
                         '0'                   when is_send_0    ='1' else
                         '1'                   when is_send_1    ='1' else
                         data_shifter_lt(0)    when (is_send_rdata and not do_send_par)='1' else
                         datapar_shifter_lt(0) when (is_send_rdata and     do_send_par)='1' else
                         dch_lt;

  scom_dch_out <= dch_out_internal_lt;

-- copy the internal signals to ports
   sc_req  <= is_exe_cmd;
   sc_addr <= head_lt(satid_nobits+1 to satid_regid_nobits);
   sc_r_nw <= head_lt(rw_bit_index);

-- copy the result of the deserializer to the output, take care of the fact that data shifter is multiple of 16 and not all is used as output
   copy2sc_wdata: if width<64 generate
     copy2sc_wdata_loop_1: for i in 0 to width-1 generate
       sc_wdata(i) <= data_shifter_lt(i);
     end generate copy2sc_wdata_loop_1;


   end generate copy2sc_wdata;

   copy2sc_wdata_all: if width=64 generate
     sc_wdata     <= data_shifter_lt;
   end generate copy2sc_wdata_all;


   sc_wparity <= xor_reduce(datapar_shifter_lt);

-------------------------------------------------------------------------------
   -- FSM: serial => parallel => serial state machine
   --
   fsm_transition: process (state_lt, got_head, gor_eofwdata, got_eofwpar,
                            got_ulhead, sent_rdata, p0_err, any_ack_error,
                            match, do_write, do_read,
                            cch_lt(0), dch_lt, sc_ack, wpar_err, read_nvld)

      begin
        next_state <= state_lt;
        case state_lt is
          when idle             => if dch_lt='1' then
                                      next_state <= rec_head;
                                   end if;

          when rec_head         => if (got_head)='1' then
                                     next_state <= check_before;
                                   end if;

          when check_before     => if match='0' then
                                     next_state <= not_selected;
                                   elsif ( (read_nvld or p0_err) and do_read)='1' then
                                     next_state <= filler0;
                                   elsif (not p0_err and not read_nvld and do_read)='1'  then
                                     next_state <= exe_cmd;
                                   else
                                     next_state <= rec_wdata;
                                   end if;

          when rec_wdata        => if gor_eofwdata='1' then
                                     next_state <= rec_wpar;
                                   end if;

          when rec_wpar         => if (got_eofwpar and not p0_err)='1' then
                                     next_state <= check_wpar;
                                   elsif (got_eofwpar and p0_err)='1' then
                                     next_state <= filler0;
                                   end if;

          when check_wpar       => if wpar_err='0' then
                                     next_state <= exe_cmd;
                                   else
                                     next_state <= filler1;
                                   end if;

          when exe_cmd          => if sc_ack='1' then
                                     next_state <= filler1;
                                   end if;

          when filler0          => next_state <= filler1;

          when filler1          => next_state <= gen_ulinfo;

          when gen_ulinfo       => next_state <= send_ulinfo;

          when send_ulinfo      => if (got_ulhead and (do_write or (do_read and any_ack_error)))='1' then
                                     next_state <= send_0;
                                   elsif (got_ulhead and do_read)='1' then  
                                     next_state <= send_rdata;
                                   end if;

          when send_rdata       => if sent_rdata='1' then
                                     next_state <= send_0;
                                   end if;

          when send_0           => next_state <= send_1;

          when send_1           => next_state <= idle;

          when not_selected     => if cch_lt(0)='0' then
                                     next_state <= idle;
                                   end if;

          when others          => next_state <= idle;

        end case;

      end process fsm_transition;

      state_in <= state_lt when local_act='0' else
                  idle     when reset='1' else
                  next_state;

      state_par_error <= xor_reduce(state_lt);

-------------------------------------------------------------------------------
      is_idle         <= (state_lt=idle);
      is_rec_head     <= (state_lt=rec_head);
      is_check_before <= (state_lt=check_before);
      is_rec_wdata    <= (state_lt=rec_wdata);
      is_rec_wpar     <= (state_lt=rec_wpar);
      is_exe_cmd      <= (state_lt=exe_cmd);
      is_gen_ulinfo   <= (state_lt=gen_ulinfo);
      is_send_ulinfo  <= (state_lt=send_ulinfo);
      is_send_rdata   <= (state_lt=send_rdata);
      is_send_0       <= (state_lt=send_0);
      is_send_1       <= (state_lt=send_1);
      is_filler_0     <= (state_lt=filler0);
      is_filler_1     <= (state_lt=filler1);

-------------------------------------------------------------------------------
      enable_cnt <= is_rec_head
                    or is_check_before
                    or is_rec_wdata
                    or is_rec_wpar
                    or is_send_ulinfo
                    or is_send_rdata
                    or is_send_0
                    or is_send_1
                    ;
      cnt_in <= (others=>'0')      when ((is_idle or is_gen_ulinfo) = '1') else
                cnt_lt + "0000001" when (enable_cnt = '1') else
                cnt_lt;

      got_head <= (cnt_lt = (1+satid_nobits+regid_nobits));

      got_ulhead <= (cnt_lt = (1+satid_nobits+regid_nobits+4));

      gor_eofwdata         <= (cnt_lt = eof_wdata);
      got_eofwpar          <= (cnt_lt = eof_wpar);

      sent_rdata           <= (cnt_lt=tconv(83,7));

      cntgtheadpluswidth   <= (cnt_lt > eof_wdata_n);
      cntgteofwdataplusparity <= (cnt_lt > eof_wpar_m);

      do_send_par         <= (cnt_lt > 79); -- 78 bits = 15 ulhead + 64 data

-------------------------------------------------------------------------------
      -- shift downlink command (for this or any subsequent satellite) or uplink response (from previous satellite)
      head_in(head_width-2 to head_width-1) <= head_lt(head_width-1) & dch_lt when (is_rec_head or (is_idle and dch_lt))='1' else
                           head_lt(head_width-2 to head_width-1);

      head_in(0 to satid_regid_nobits)  <= head_lt(1 to satid_regid_nobits) & head_mux when (is_rec_head or is_send_ulinfo)='1' else
                           head_lt(0 to satid_regid_nobits);

      head_mux <= head_lt(rw_bit_index) when is_rec_head='1' else
                  tail_lt(0);


      -- calculate parity P0 of uplink frame
      tail_in(4) <= xor_reduce ( parity_satid_regaddr_lt & tail_lt(0) & (wpar_err and do_write) & sc_ack_info_lt(0 to 1))
                                                                    when is_gen_ulinfo='1'and (internal_addr_decode=false) else
                    xor_reduce ( parity_satid_regaddr_lt & tail_lt(0) & (wpar_err and do_write) & (write_nvld or read_nvld) & addr_nvld )
                                                                    when is_gen_ulinfo='1'and (internal_addr_decode=true)
                    else tail_lt(4);



      -- copy sampled ack_info coming from logic
      tail_in(2 to 3) <= sc_ack_info_lt(0 to 1)  when is_gen_ulinfo='1' and internal_addr_decode=false else
                         (write_nvld or read_nvld) & addr_nvld when is_gen_ulinfo='1' and internal_addr_decode=true else
                         tail_lt(3 to 4)              when is_send_ulinfo='1' else -- shift out
                         tail_lt(2 to 3);



      -- Write Data Parity error
      tail_in(1)      <= (wpar_err and do_write)   when is_gen_ulinfo='1' else -- parity error on write operation
                         tail_lt(2) when is_send_ulinfo='1' else  -- shift out
                         tail_lt(1);

      -- parity check of of downlink P0 yields error
      tail_in(0)      <= not p0_err     when is_check_before='1' else -- set to '1' if a downlink parity error is detected by satellite, otherwise '0'
                         tail_lt(1) when is_send_ulinfo='1' else  -- shift out
                         tail_lt(0);

      -- sample and hold ack_info, one spare bit
      sc_ack_info_in <= sc_ack_info when (is_exe_cmd and sc_ack)='1' else
                        "00" when is_idle='1' else
                        sc_ack_info_lt;

-------------------------------------------------------------------------------

      do_write <= not do_read;
      do_read  <= head_lt(rw_bit_index);
      match    <= (head_lt(1 to satid_nobits)=sat_id_net);

      -- if downlink parity error then set p0_err
      p0_err_in <= '0' when (is_idle = '1') else
                   p0_err_lt xor head_in(parbit_index) when (is_rec_head = '1') else
                   p0_err_lt ;
      p0_err <= p0_err_lt;
      -- p0_err   <= gate_and(is_check_before, xor_reduce (head_lt(1 to parbit_index)));
      -------------------------------------------------------------------------
      parity_satid_regaddr_in   <= xor_reduce (sat_id_net & head_lt(satid_nobits+1 to satid_regid_nobits)); 

      any_ack_error <= or_reduce(sc_ack_info_lt);

-------------------------------------------------------------------------------

      data_mux <= dch_lt when (is_check_before or is_rec_wdata)='1' else
                  '0';

      data_shifter_in_1: if (width = i_width) generate
      data_shifter_in <= data_shifter_lt(1 to i_width-1) & data_mux when (is_check_before or
                                                                         (is_rec_wdata and not cntgtheadpluswidth) or
                                                                          is_send_rdata)='1' else
                         (sc_rdata(0 to width-1)) when (is_exe_cmd and sc_ack and do_read)='1' else
                         data_shifter_lt;
      end generate data_shifter_in_1; 

      data_shifter_in_2: if (width < i_width) generate
      data_shifter_in <= data_shifter_lt(1 to i_width-1) & data_mux when (is_check_before or
                                                                         (is_rec_wdata and not cntgtheadpluswidth) or
                                                                          is_send_rdata)='1' else
                         (sc_rdata(0 to width-1) & (width to i_width-1 =>'0')) when (is_exe_cmd and sc_ack and do_read)='1' else
                         data_shifter_lt;
      end generate data_shifter_in_2; 
-------------------------------------------------------------------------------
      -- parity handling
      par_mux <= dch_lt when (is_rec_wpar)='1' else
                 '0';

      -- receiving parity: shift when receiving write data parity
      -- sending parity of read data: shift when sending read data parity
      -- latch generated parity of read data when read data is accepted
      datapar_shifter_in <= datapar_shifter_lt(1 to par_nobits-1) & par_mux when ((is_rec_wpar and not cntgteofwdataplusparity)or
                                                                                  (is_send_rdata and do_send_par))='1' else
                            sc_rparity when (is_filler_1 ='1') else  -- 1.33
                            datapar_shifter_lt;


      data_shifter_move_1: if (width = i_width) generate  
         data_shifter_lt_tmp (0 to width-1) <= data_shifter_lt;
         data_shifter_padding_1: if width < 64 generate
            data_shifter_lt_tmp(width to 63) <= (others=>'0');
         end generate data_shifter_padding_1;
      end generate data_shifter_move_1;

      data_shifter_move_2: if (width < i_width) generate
          data_shifter_lt_tmp(0 to width-1) <= data_shifter_lt(0 to width-1);
          data_shifter_lt_tmp(width to i_width-1) <= data_shifter_lt(width to i_width-1);
          data_shifter_padding_1: if i_width < 64 generate
             data_shifter_lt_tmp(i_width to 63) <= (others=>'0');
          end generate data_shifter_padding_1;
      end generate data_shifter_move_2;
-------------------------------------------------------------------------------

      wdata_par_check: for i in 0 to par_nobits-1 generate
        par_data_in(i) <= xor_reduce(data_shifter_lt_tmp(16*i to 16*(i+1)-1));
      end generate wdata_par_check;

      wdata_par_check_pipe: if pipeline_paritychk=true generate
        state: entity tri.tri_nlat_scan(tri_nlat_scan)
          generic map( width => par_nobits,
                       needs_sreset => 1,
                       expand_type => expand_type )
          port map
          (   d1clk     => d1clk
            , vd        => vd
            , gd        => gd
            , lclk      => lclk
            , d2clk     => d2clk
            , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+22 to state_width+i_width+2*par_nobits+head_width+21)
            , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+22 to state_width+i_width+2*par_nobits+head_width+21)
            , din       => par_data_in
            , q         => par_data_lt
            );
      end generate wdata_par_check_pipe;

      wdata_par_check_nopipe: if pipeline_paritychk=false generate
        par_data_lt <= par_data_in;
        func_scan_out(state_width+i_width+par_nobits+head_width+22 to state_width+i_width+2*par_nobits+head_width+21)
          <= func_scan_in (state_width+i_width+par_nobits+head_width+22 to state_width+i_width+2*par_nobits+head_width+21);

      end generate wdata_par_check_nopipe;

      wpar_err_in   <= or_reduce(par_data_in xor datapar_shifter_in); 
      wpar_err <= wpar_err_lt;

-------------------------------------------------------------------------------
      rdata_parity_gen: for i in 0 to par_nobits-1 generate
        sc_rparity(i) <= xor_reduce(data_shifter_lt_tmp(16*i to 16*(i+1)-1));
      end generate rdata_parity_gen;
-------------------------------------------------------------------------------
   -------------------------------------------------------------------
   -- address decoding section
   -- Generate onehot Address (binary to one-hot)
   -------------------------------------------------------------------

   internal_addr_decoding: if internal_addr_decode=true generate
     --------------------------------------------------------------------------
     foralladdresses : for i in use_addr'range generate
       ------------------------------------------------------------------------
       addr_bit_set : if (use_addr(i) = '1') generate
         dec_addr_in(i) <= (head_lt(satid_nobits+1 to satid_regid_nobits) = tconv(i, reg_nobits));

         -- generate latch to hold addr_v only if required
         latch_for_onehot : if pipeline_addr_v(i) = '1' generate
           dec_addr       : entity tri.tri_nlat(tri_nlat)
             generic map( width  => 1,
                          needs_sreset => 1,
                          expand_type => expand_type)
             port map ( d1clk    => d1clk,
                        vd       => vd,
                        gd       => gd,
                        d2clk    => d2clk,
                        lclk     => lclk,
                        scan_in  => func_scan_in(state_width+i_width+2*par_nobits+head_width+22 +i),
                        din(0)   => dec_addr_in(i),
                        q(0)     => dec_addr_q(i),
                        scan_out => func_scan_out(state_width+i_width+2*par_nobits+head_width+22 +i) );
         end generate latch_for_onehot;

         -- otherwise no latch
         no_latch_for_onehot : if pipeline_addr_v(i) = '0' generate
           func_scan_out(state_width+i_width+2*par_nobits+head_width+22 +i) <= func_scan_in(state_width+i_width+2*par_nobits+head_width+22 +i);
           dec_addr_q(i) <= dec_addr_in(i);
         end generate no_latch_for_onehot;

       end generate addr_bit_set;
       ------------------------------------------------------------------------
       addr_bit_notset : if (use_addr(i) /= '1') generate  -- do not generate hardware for unused addresses
         func_scan_out(state_width+i_width+2*par_nobits+head_width+22+i) <= func_scan_in(state_width+i_width+2*par_nobits+head_width+22 +i);
         dec_addr_in(i)                                     <= '0';
         dec_addr_q(i)                                      <= dec_addr_in(i);
       end generate addr_bit_notset;
     end generate foralladdresses;
     --------------------------------------------------------------------------
   -- check writable and/or readable, 1.45: dec_addr_q changed to dec_addr_in
   read_valid    <=  or_reduce(dec_addr_in and addr_is_rdable);
   write_valid   <=  or_reduce(dec_addr_in and addr_is_wrable);
   addr_nvld     <=  not or_reduce(dec_addr_in);
   write_nvld    <= (not write_valid and not addr_nvld) and do_write;
   read_nvld     <= (not read_valid  and not addr_nvld) and do_read;

   unused <= "00";
   end generate internal_addr_decoding;


   external_addr_decoding: if internal_addr_decode=false generate
     foralladdresses : for i in use_addr'range generate
         func_scan_out(state_width+i_width+2*par_nobits+head_width+22+i) <= func_scan_in(state_width+i_width+2*par_nobits+head_width+22 +i);
         dec_addr_in(i)                                     <= '0';
         dec_addr_q(i)                                      <= dec_addr_in(i);
     end generate foralladdresses;
   read_valid <= '1';-- suppressing wrong error generation
   write_valid<= '1';-- suppressing wrong error generation
   addr_nvld <= '0';
   write_nvld <= '0';
   read_nvld  <= '0';

   unused <= write_valid & read_valid;
   end generate external_addr_decoding;



   short_unused_addr_range: for i in use_addr'high+1 to 63 generate
     func_scan_out(state_width+i_width+2*par_nobits+head_width+22+i) <= func_scan_in(state_width+i_width+2*par_nobits+head_width+22+i);
   end generate short_unused_addr_range;

   addr_v <= dec_addr_q(0 to use_addr'high);

-------------------------------------------------------------------------------

    state: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => state_width, init => idle, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (0 to state_width-1)
     , scan_out  => func_scan_out(0 to state_width-1)
     , din       => state_in
     , q         => state_lt
     );

    counter: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => 7, init => "0000000", needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width to state_width+6)
     , scan_out  => func_scan_out(state_width to state_width+6)
     , din       => cnt_in
     , q         => cnt_lt
     );

    data_shifter: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => i_width, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+7 to state_width+i_width+6)
     , scan_out  => func_scan_out(state_width+7 to state_width+i_width+6)
     , din       => data_shifter_in
     , q         => data_shifter_lt
     );

    datapar_shifter: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => par_nobits, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+7 to state_width+i_width+par_nobits+6)
     , scan_out  => func_scan_out(state_width+i_width+7 to state_width+i_width+par_nobits+6)
     , din       => datapar_shifter_in
     , q         => datapar_shifter_lt
     );

    head_lat: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => head_width, init => head_init, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+7 to state_width+i_width+par_nobits+head_width+6)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+7 to state_width+i_width+par_nobits+head_width+6)
     , din       => head_in
     , q         => head_lt
     );

    tail_lat: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => 5, init => "00000", needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk,
     vd        => vd,
     gd        => gd,
     lclk      => lclk,
     d2clk     => d2clk,
     scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+7 to state_width+i_width+par_nobits+head_width+11),
     scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+7 to state_width+i_width+par_nobits+head_width+11),
     din       => tail_in,
     q         => tail_lt
     );

    dch_inlatch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+12)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+12)
     , din(0)    => scom_dch_in_int
     , q(0)      => dch_lt
     );


    ack_info: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => 2, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+13 to state_width+i_width+par_nobits+head_width+14)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+13 to state_width+i_width+par_nobits+head_width+14)
     , din       => sc_ack_info_in
     , q         => sc_ack_info_lt
     );

    dch_outlatch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+15)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+15)
     , din(0)    => dch_out_internal_in
     , q(0)      => dch_out_internal_lt
     );

    cch_latches: entity tri.tri_nlat_scan(tri_nlat_scan)
    generic map( width => 2, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+16 to state_width+i_width+par_nobits+head_width+17)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+16 to state_width+i_width+par_nobits+head_width+17)
     , din       => cch_in
     , q         => cch_lt
     );

    scom_err_latch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+18)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+18)
     , din(0)    => scom_err_in
     , q(0)      => scom_err_lt
     );

    scom_local_act_latch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+19)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+19)
     , din(0)    => scom_local_act_in
     , q(0)      => scom_local_act_lt
     );

    spare_latch1: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in (state_width+i_width+par_nobits+head_width+20)
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+20)
     , din(0)    => spare_latch1_in
     , q(0)      => spare_latch1_lt
     );

    spare_latch2: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_in(state_width+i_width+par_nobits+head_width+21)
     , scan_out  => func_scan_temp
     , din(0)    => spare_latch2_in
     , q(0)      => spare_latch2_lt
     );

    scom_cch_input_latch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_temp
     , scan_out  => func_scan_temp_1
     , din(0)    => scom_cch_input_in
     , q(0)      => scom_cch_input_lt
     );

    scom_dch_input_latch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_temp_1
     , scan_out  => func_scan_temp_2
     , din(0)    => scom_dch_input_in
     , q(0)      => scom_dch_input_lt
     );

    parity_reg1: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_temp_2
     , scan_out  => func_scan_temp_3
     , din(0)    => parity_satid_regaddr_in
     , q(0)      => parity_satid_regaddr_lt
     );

    p0_err_latch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_temp_3
     , scan_out  => func_scan_temp_4
     , din(0)    => p0_err_in
     , q(0)      => p0_err_lt
     );

    wpar_err_latch: entity tri.tri_nlat(tri_nlat)
    generic map( width => 1, needs_sreset => 1, expand_type => expand_type )
    port map
     ( d1clk     => d1clk
     , vd        => vd
     , gd        => gd
     , lclk      => lclk
     , d2clk     => d2clk
     , scan_in   => func_scan_temp_4
     , scan_out  => func_scan_out(state_width+i_width+par_nobits+head_width+21)
     , din(0)    => wpar_err_in
     , q(0)      => wpar_err_lt
     );

-------------------------------------------------------------------------------
   unused_signals <= or_reduce ( is_filler_0 & is_filler_1
                     & spare_latch1_lt
                     & spare_latch2_lt
                     & par_data_lt
                     & d_mode_dc ) ;
   
   spare_latch1_in <= '0';
   spare_latch2_in <= '0';


  end generate a;

end tri_serial_scom2;
