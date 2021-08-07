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


library ieee; use ieee.std_logic_1164.all ;
library ibm; use ibm.std_ulogic_support.all ;
             use ibm.std_ulogic_function_support.all;
library support; use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;

entity tri_512x288_9 is
  generic (addressable_ports : positive := 512; 
           addressbus_width : positive := 6;    
           port_bitwidth : positive := 288;     
           bit_write_type : positive := 9;  
           ways : positive := 1;        
           expand_type : integer := 1);         
  port (
    gnd               : inout power_logic;
    vdd               : inout power_logic;
    vcs               : inout power_logic;
    nclk              : in clk_logic;
    act               : in std_ulogic;
    sg_0              : in std_ulogic;
    sg_1              : in std_ulogic;
    ary_nsl_thold_0   : in std_ulogic;
    abst_sl_thold_0   : in std_ulogic;
    time_sl_thold_0   : in std_ulogic;
    repr_sl_thold_0   : in std_ulogic;
    clkoff_dc_b       : in std_ulogic;
    ccflush_dc        : in std_ulogic;
    scan_dis_dc_b     : in std_ulogic;
    scan_diag_dc      : in std_ulogic;
    d_mode_dc         : in std_ulogic;
    act_dis_dc        : in std_ulogic;
    lcb_delay_lclkr_np_dc       : in std_ulogic;
    ctrl_lcb_delay_lclkr_np_dc  : in std_ulogic;
    dibw_lcb_delay_lclkr_np_dc  : in std_ulogic;
    ctrl_lcb_mpw1_np_dc_b       : in std_ulogic;
    dibw_lcb_mpw1_np_dc_b       : in std_ulogic;
    lcb_mpw1_pp_dc_b            : in std_ulogic;
    lcb_mpw1_2_pp_dc_b          : in std_ulogic;
    aodo_lcb_delay_lclkr_dc     : in std_ulogic;
    aodo_lcb_mpw1_dc_b          : in std_ulogic;
    aodo_lcb_mpw2_dc_b          : in std_ulogic;
    bitw_abist                  : in std_ulogic_vector(0 to 1);
    tc_lbist_ary_wrt_thru_dc    : in std_ulogic;
    abist_en_1                  : in std_ulogic;
    din_abist                   : in std_ulogic_vector(0 to 3);
    abist_cmp_en                : in std_ulogic;
    abist_raw_b_dc              : in std_ulogic;
    data_cmp_abist              : in std_ulogic_vector(0 to 3);
    addr_abist                  : in std_ulogic_vector(0 to 8);
    r_wb_abist                  : in std_ulogic;
    abst_scan_in      : in std_ulogic_vector(0 to 1);
    time_scan_in      : in std_ulogic;
    repr_scan_in      : in std_ulogic;
    abst_scan_out     : out std_ulogic_vector(0 to 1);
    time_scan_out     : out std_ulogic;
    repr_scan_out     : out std_ulogic;
    lcb_bolt_sl_thold_0         : in std_ulogic; 
    pc_bo_enable_2              : in std_ulogic; 
    pc_bo_reset                 : in std_ulogic; 
    pc_bo_unload                : in std_ulogic;
    pc_bo_repair                : in std_ulogic; 
    pc_bo_shdata                : in std_ulogic; 
    pc_bo_select                : in std_ulogic_vector(0 to 1); 
    bo_pc_failout               : out std_ulogic_vector(0 to 1); 
    bo_pc_diagloop              : out std_ulogic_vector(0 to 1);
    tri_lcb_mpw1_dc_b           : in  std_ulogic;
    tri_lcb_mpw2_dc_b           : in  std_ulogic;
    tri_lcb_delay_lclkr_dc      : in  std_ulogic;
    tri_lcb_clkoff_dc_b         : in  std_ulogic;
    tri_lcb_act_dis_dc          : in  std_ulogic;
    write_enable      : in std_ulogic;
    bw                : in std_ulogic_vector (0 to (port_bitwidth-1));
    arr_up_addr       : in std_ulogic_vector (0 to 2);
    addr              : in std_ulogic_vector (0 to (addressbus_width-1));
    data_in           : in std_ulogic_vector (0 to (port_bitwidth-1));
    data_out          : out std_ulogic_vector(0 to (port_bitwidth*ways-1))
);

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_512x288_9;

architecture tri_512x288_9 of tri_512x288_9 is




constant ramb_base_addr  : integer := 11;

begin  

  -- synopsys translate_off
  um: if expand_type = 0 generate
      signal tiup               : std_ulogic;
      signal tidn               : std_ulogic;

      signal addr_l2            : std_ulogic_vector(0 TO addressbus_width-1);
      signal bw_l2              : std_ulogic_vector(0 TO bw'right);
      signal write_enable_d     : std_ulogic;
      signal write_enable_l2    : std_ulogic;
      signal data_in_l2         : std_ulogic_vector(0 to port_bitwidth-1);
      signal array_d            : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
      signal array_l2           : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
  begin
      tiup <= '1';
      tidn <= '0';

      addr_latch: tri_rlmreg_p
        generic map (width => addr'length, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => addr,
                  dout        => addr_l2 );

      bw_latch: tri_rlmreg_p
        generic map (width => bw'length, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => bw,
                  dout        => bw_l2 );

      write_enable_latch: tri_rlmlatch_p
        generic map (init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => tiup,
                  scin        => tidn,
                  scout       => open,
                  din         => write_enable_d,
                  dout        => write_enable_l2 );

      data_in_latch: tri_rlmreg_p
        generic map (width => port_bitwidth, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => data_in,
                  dout        => data_in_l2 );

      array_latch: tri_rlmreg_p
        generic map (width => addressable_ports*port_bitwidth*ways, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => tiup,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => array_d,
                  dout        => array_l2 );

      write_enable_d <= act and write_enable;

      ww: for w in 0 to ways-1 generate
      begin
        wy: for y in 0 to addressable_ports-1 generate
        begin
          wx: for x in 0 to port_bitwidth-1 generate
          begin
            array_d(y*port_bitwidth*ways+w*port_bitwidth+x) <=
                   data_in_l2(x)  when (( write_enable_l2 and addr_l2 = tconv(y, addressbus_width) and bw_l2(x/bit_write_type) ) = '1')
              else array_l2(y*port_bitwidth*ways+w*port_bitwidth+x);

          end generate wx;
        end generate wy;
      end generate ww;

      data_out <= array_l2( tconv(addr_l2)*port_bitwidth*ways to tconv(addr_l2)*port_bitwidth*ways+port_bitwidth*ways-1 );

      abst_scan_out <= (others=>'0');
      time_scan_out <= tidn;
      repr_scan_out <= tidn;

      bo_pc_failout <= (others=>'0');
      bo_pc_diagloop <= (others=>'0');
  end generate um;
  -- synopsys translate_on

  a: if expand_type = 1 generate
      component RAMB16_S9_S9
      -- pragma translate_off
	generic
	(
		SIM_COLLISION_CHECK : string := "none"); 
      -- pragma translate_on
	port
	(
		DOA : out std_logic_vector(7 downto 0);
		DOB : out std_logic_vector(7 downto 0);
		DOPA : out std_logic_vector(0 downto 0);
		DOPB : out std_logic_vector(0 downto 0);
		ADDRA : in std_logic_vector(10 downto 0);
		ADDRB : in std_logic_vector(10 downto 0);
		CLKA : in std_ulogic;
		CLKB : in std_ulogic;
		DIA : in std_logic_vector(7 downto 0);
		DIB : in std_logic_vector(7 downto 0);
		DIPA : in std_logic_vector(0 downto 0);
		DIPB : in std_logic_vector(0 downto 0);
		ENA : in std_ulogic;
		ENB : in std_ulogic;
		SSRA : in std_ulogic;
		SSRB : in std_ulogic;
		WEA : in std_ulogic;
		WEB : in std_ulogic
	);
      end component;

      -- pragma translate_off
      -- pragma translate_on

      constant addresswidth     : integer := addressbus_width+3+1;
      signal arr_data_in        : std_logic_vector(0 to 287);
      signal ramb_data_in       : std_logic_vector(0 to 255);
      signal ramb_parity_in     : std_logic_vector(0 to 31);
      signal ramb_uh_addr       : std_ulogic_vector(0 to 10);
      signal ramb_lh_addr       : std_ulogic_vector(0 to 10);
      signal uh_addr            : std_ulogic_vector(0 to addresswidth-1);
      signal lh_addr            : std_ulogic_vector(0 to addresswidth-1);
      signal ramb_data_out      : std_logic_vector(0 to 255);
      signal ramb_parity_out    : std_logic_vector(0 to 31);

      signal tidn               : std_ulogic;
      signal wrt_en_wAH         : std_ulogic_vector(0 to 31);
      signal bitWrt             : std_ulogic_vector(0 to 31);
      signal rdDataOut          : std_ulogic_vector(0 to 255);
      signal rdParityOut        : std_ulogic_vector(0 to 31);

      signal unused             : std_ulogic;
      -- synopsys translate_off
      -- synopsys translate_on
  begin

      tidn <= '0';

      arr_data_in   <= tconv(data_in);

      dWFixUp : for t in 0 to 31 generate begin
            ramb_data_in((8*t) to (8*t)+7) <= arr_data_in(t+0)   & arr_data_in(t+32)  & arr_data_in(t+64)  & arr_data_in(t+96) &
                                              arr_data_in(t+144) & arr_data_in(t+176) & arr_data_in(t+208) & arr_data_in(t+240);
            ramb_parity_in(t)              <= arr_data_in(t+128+(128*(t/16)));
            bitWrt(t)                      <= bw(t);
      end generate dWFixUp;

      wrtEn_gen : for t in 0 to 31 generate begin
            wrt_en_wAH(t) <= write_enable and bitWrt(t);
      end generate wrtEn_gen;

      uh_addr <= arr_up_addr & addr & '0';
      lh_addr <= arr_up_addr & addr & '1';

      rambAddrCalc : for t in 0 to ramb_base_addr-1 generate begin
            R0 : if(t < ramb_base_addr-addresswidth) generate begin
                  ramb_uh_addr(t) <= '0';
                  ramb_lh_addr(t) <= '0';
                 end generate;
            R1 : if(t >= ramb_base_addr-addresswidth) generate begin
                  ramb_uh_addr(t) <= uh_addr(t-(ramb_base_addr-addresswidth));
                  ramb_lh_addr(t) <= lh_addr(t-(ramb_base_addr-addresswidth));
                 end generate;
      end generate rambAddrCalc;     

      dRFixUp : for t in 0 to 31 generate begin
            data_out(t+0)                <= rdDataOut((t*8)+0);
            data_out(t+32)               <= rdDataOut((t*8)+1);
            data_out(t+64)               <= rdDataOut((t*8)+2);
            data_out(t+96)               <= rdDataOut((t*8)+3);
            data_out(t+144)              <= rdDataOut((t*8)+4);
            data_out(t+176)              <= rdDataOut((t*8)+5);
            data_out(t+208)              <= rdDataOut((t*8)+6);
            data_out(t+240)              <= rdDataOut((t*8)+7);
            data_out(t+128+(128*(t/16))) <= rdParityOut(t);
      end generate dRFixUp;

      rdDataOut   <= tconv(ramb_data_out);
      rdParityOut <= tconv(ramb_parity_out);

      arr0: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(0 to 7),
              DOB   => ramb_data_out(128 to 135),
              DOPA  => ramb_parity_out(0 to 0),
              DOPB  => ramb_parity_out(16 to 16),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(0 to 7),
              DIB   => ramb_data_in(128 to 135),
              DIPA  => ramb_parity_in(0 to 0),
              DIPB  => ramb_parity_in(16 to 16),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(0),
              WEB   => wrt_en_wAH(16)
	    );

      arr1: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(8 to 15),
              DOB   => ramb_data_out(136 to 143),
              DOPA  => ramb_parity_out(1 to 1),
              DOPB  => ramb_parity_out(17 to 17),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(8 to 15),
              DIB   => ramb_data_in(136 to 143),
              DIPA  => ramb_parity_in(1 to 1),
              DIPB  => ramb_parity_in(17 to 17),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(1),
              WEB   => wrt_en_wAH(17)
	    );

      arr2: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(16 to 23),
              DOB   => ramb_data_out(144 to 151),
              DOPA  => ramb_parity_out(2 to 2),
              DOPB  => ramb_parity_out(18 to 18),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(16 to 23),
              DIB   => ramb_data_in(144 to 151),
              DIPA  => ramb_parity_in(2 to 2),
              DIPB  => ramb_parity_in(18 to 18),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(2),
              WEB   => wrt_en_wAH(18)
	    );

      arr3: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(24 to 31),
              DOB   => ramb_data_out(152 to 159),
              DOPA  => ramb_parity_out(3 to 3),
              DOPB  => ramb_parity_out(19 to 19),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(24 to 31),
              DIB   => ramb_data_in(152 to 159),
              DIPA  => ramb_parity_in(3 to 3),
              DIPB  => ramb_parity_in(19 to 19),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(3),
              WEB   => wrt_en_wAH(19)
	    );

      arr4: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(32 to 39),
              DOB   => ramb_data_out(160 to 167),
              DOPA  => ramb_parity_out(4 to 4),
              DOPB  => ramb_parity_out(20 to 20),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(32 to 39),
              DIB   => ramb_data_in(160 to 167),
              DIPA  => ramb_parity_in(4 to 4),
              DIPB  => ramb_parity_in(20 to 20),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(4),
              WEB   => wrt_en_wAH(20)
	    );

      arr5: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(40 to 47),
              DOB   => ramb_data_out(168 to 175),
              DOPA  => ramb_parity_out(5 to 5),
              DOPB  => ramb_parity_out(21 to 21),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(40 to 47),
              DIB   => ramb_data_in(168 to 175),
              DIPA  => ramb_parity_in(5 to 5),
              DIPB  => ramb_parity_in(21 to 21),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(5),
              WEB   => wrt_en_wAH(21)
	    );

      arr6: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(48 to 55),
              DOB   => ramb_data_out(176 to 183),
              DOPA  => ramb_parity_out(6 to 6),
              DOPB  => ramb_parity_out(22 to 22),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(48 to 55),
              DIB   => ramb_data_in(176 to 183),
              DIPA  => ramb_parity_in(6 to 6),
              DIPB  => ramb_parity_in(22 to 22),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(6),
              WEB   => wrt_en_wAH(22)
	    );

      arr7: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(56 to 63),
              DOB   => ramb_data_out(184 to 191),
              DOPA  => ramb_parity_out(7 to 7),
              DOPB  => ramb_parity_out(23 to 23),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(56 to 63),
              DIB   => ramb_data_in(184 to 191),
              DIPA  => ramb_parity_in(7 to 7),
              DIPB  => ramb_parity_in(23 to 23),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(7),
              WEB   => wrt_en_wAH(23)
	    );

      arr8: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(64 to 71),
              DOB   => ramb_data_out(192 to 199),
              DOPA  => ramb_parity_out(8 to 8),
              DOPB  => ramb_parity_out(24 to 24),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(64 to 71),
              DIB   => ramb_data_in(192 to 199),
              DIPA  => ramb_parity_in(8 to 8),
              DIPB  => ramb_parity_in(24 to 24),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(8),
              WEB   => wrt_en_wAH(24)
	    );

      arr9: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(72 to 79),
              DOB   => ramb_data_out(200 to 207),
              DOPA  => ramb_parity_out(9 to 9),
              DOPB  => ramb_parity_out(25 to 25),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(72 to 79),
              DIB   => ramb_data_in(200 to 207),
              DIPA  => ramb_parity_in(9 to 9),
              DIPB  => ramb_parity_in(25 to 25),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(9),
              WEB   => wrt_en_wAH(25)
	    );

      arrA: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(80 to 87),
              DOB   => ramb_data_out(208 to 215),
              DOPA  => ramb_parity_out(10 to 10),
              DOPB  => ramb_parity_out(26 to 26),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(80 to 87),
              DIB   => ramb_data_in(208 to 215),
              DIPA  => ramb_parity_in(10 to 10),
              DIPB  => ramb_parity_in(26 to 26),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(10),
              WEB   => wrt_en_wAH(26)
	    );

      arrB: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(88 to 95),
              DOB   => ramb_data_out(216 to 223),
              DOPA  => ramb_parity_out(11 to 11),
              DOPB  => ramb_parity_out(27 to 27),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(88 to 95),
              DIB   => ramb_data_in(216 to 223),
              DIPA  => ramb_parity_in(11 to 11),
              DIPB  => ramb_parity_in(27 to 27),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(11),
              WEB   => wrt_en_wAH(27)
	    );

      arrC: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(96 to 103),
              DOB   => ramb_data_out(224 to 231),
              DOPA  => ramb_parity_out(12 to 12),
              DOPB  => ramb_parity_out(28 to 28),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(96 to 103),
              DIB   => ramb_data_in(224 to 231),
              DIPA  => ramb_parity_in(12 to 12),
              DIPB  => ramb_parity_in(28 to 28),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(12),
              WEB   => wrt_en_wAH(28)
	    );

      arrD: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(104 to 111),
              DOB   => ramb_data_out(232 to 239),
              DOPA  => ramb_parity_out(13 to 13),
              DOPB  => ramb_parity_out(29 to 29),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(104 to 111),
              DIB   => ramb_data_in(232 to 239),
              DIPA  => ramb_parity_in(13 to 13),
              DIPB  => ramb_parity_in(29 to 29),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(13),
              WEB   => wrt_en_wAH(29)
	    );

      arrE: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(112 to 119),
              DOB   => ramb_data_out(240 to 247),
              DOPA  => ramb_parity_out(14 to 14),
              DOPB  => ramb_parity_out(30 to 30),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(112 to 119),
              DIB   => ramb_data_in(240 to 247),
              DIPA  => ramb_parity_in(14 to 14),
              DIPB  => ramb_parity_in(30 to 30),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(14),
              WEB   => wrt_en_wAH(30)
	    );

      arrF: RAMB16_S9_S9
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
              DOA   => ramb_data_out(120 to 127),
              DOB   => ramb_data_out(248 to 255),
              DOPA  => ramb_parity_out(15 to 15),
              DOPB  => ramb_parity_out(31 to 31),
              ADDRA => tconv(ramb_uh_addr),
              ADDRB => tconv(ramb_lh_addr),
              CLKA  => nclk.clk,
              CLKB  => nclk.clk,
              DIA   => ramb_data_in(120 to 127),
              DIB   => ramb_data_in(248 to 255),
              DIPA  => ramb_parity_in(15 to 15),
              DIPB  => ramb_parity_in(31 to 31),
              ENA   => act,
              ENB   => act,
              SSRA  => nclk.sreset,
              SSRB  => nclk.sreset,
              WEA   => wrt_en_wAH(15),
              WEB   => wrt_en_wAH(31)
	    );

      abst_scan_out <= (others=>'0');
      time_scan_out <= tidn;
      repr_scan_out <= tidn;

      bo_pc_failout <= (others=>'0');
      bo_pc_diagloop <= (others=>'0');

      unused <= or_reduce( bw(32 to port_bitwidth-1)
                       & clkoff_dc_b & ccflush_dc & scan_dis_dc_b & scan_diag_dc & d_mode_dc & act_dis_dc
                       & bitw_abist & sg_0 & sg_1
                       & abst_sl_thold_0 & repr_sl_thold_0 
                       & time_sl_thold_0 & ary_nsl_thold_0 & tc_lbist_ary_wrt_thru_dc 
                       & abist_en_1 & din_abist & abist_cmp_en & abist_raw_b_dc & data_cmp_abist 
                       & addr_abist & r_wb_abist & abst_scan_in & time_scan_in & repr_scan_in
                       & lcb_delay_lclkr_np_dc & ctrl_lcb_delay_lclkr_np_dc & dibw_lcb_delay_lclkr_np_dc
                       & ctrl_lcb_mpw1_np_dc_b & dibw_lcb_mpw1_np_dc_b & lcb_mpw1_pp_dc_b & lcb_mpw1_2_pp_dc_b
                       & aodo_lcb_delay_lclkr_dc & aodo_lcb_mpw1_dc_b & aodo_lcb_mpw2_dc_b
                       & lcb_bolt_sl_thold_0 & pc_bo_enable_2 & pc_bo_reset
                       & pc_bo_unload & pc_bo_repair & pc_bo_shdata & pc_bo_select
                       & tri_lcb_mpw1_dc_b & tri_lcb_mpw2_dc_b & tri_lcb_delay_lclkr_dc
                       & tri_lcb_clkoff_dc_b & tri_lcb_act_dis_dc );

  end generate a;


end tri_512x288_9;

