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
library ibm;  use ibm.std_ulogic_support.all ;
             use ibm.std_ulogic_function_support.all;
library support; use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;

-- pragma translate_off
-- pragma translate_on

entity tri_32x35_8w_1r1w is
  generic (addressable_ports : positive := 32; 
           addressbus_width : positive := 5;   
           port_bitwidth : positive := 35;     
           ways : positive := 8;                
           expand_type : integer := 1);         
  port (
    gnd               : inout power_logic;
    vdd               : inout power_logic;
    vcs               : inout power_logic;
    nclk              : in clk_logic;
    rd0_act           : in std_ulogic;
    sg_0              : in std_ulogic;
    abst_slp_sl_thold_0 : in std_ulogic;
    ary_slp_nsl_thold_0 : in std_ulogic;
    time_sl_thold_0   : in std_ulogic;
    repr_sl_thold_0   : in std_ulogic;
    clkoff_dc_b       : in std_ulogic;
    ccflush_dc        : in std_ulogic;
    scan_dis_dc_b     : in std_ulogic;
    scan_diag_dc      : in std_ulogic;
    d_mode_dc         : in std_ulogic;
    mpw1_dc_b         : in std_ulogic_vector(0 to 4);
    mpw2_dc_b         : in std_ulogic;
    delay_lclkr_dc    : in std_ulogic_vector(0 to 4);
    wr_abst_act       : in std_ulogic;
    rd0_abst_act      : in std_ulogic;
    abist_di          : in std_ulogic_vector(0 to 3);
    abist_bw_odd      : in std_ulogic;
    abist_bw_even     : in std_ulogic;
    abist_wr_adr      : in std_ulogic_vector(0 to 4);
    abist_rd0_adr     : in std_ulogic_vector(0 to 4);
    tc_lbist_ary_wrt_thru_dc    : in std_ulogic;
    abist_ena_1                 : in std_ulogic;
    abist_g8t_rd0_comp_ena      : in std_ulogic;
    abist_raw_dc_b              : in std_ulogic;
    obs0_abist_cmp              : in std_ulogic_vector(0 to 3);
    abst_scan_in      : in std_ulogic;
    time_scan_in      : in std_ulogic;
    repr_scan_in      : in std_ulogic;
    abst_scan_out     : out std_ulogic;
    time_scan_out     : out std_ulogic;
    repr_scan_out     : out std_ulogic;
    lcb_bolt_sl_thold_0         : in std_ulogic;
    pc_bo_enable_2              : in std_ulogic; 
    pc_bo_reset                 : in std_ulogic; 
    pc_bo_unload                : in std_ulogic; 
    pc_bo_repair                : in std_ulogic; 
    pc_bo_shdata                : in std_ulogic; 
    pc_bo_select                : in std_ulogic_vector(0 to 3); 
    bo_pc_failout               : out std_ulogic_vector(0 to 3); 
    bo_pc_diagloop              : out std_ulogic_vector(0 to 3);
    tri_lcb_mpw1_dc_b           : in  std_ulogic;
    tri_lcb_mpw2_dc_b           : in  std_ulogic;
    tri_lcb_delay_lclkr_dc      : in  std_ulogic;
    tri_lcb_clkoff_dc_b         : in  std_ulogic;
    tri_lcb_act_dis_dc          : in  std_ulogic;
    write_enable      : in std_ulogic_vector (0 to ((port_bitwidth*ways-1)/(port_bitwidth*2)));
    way               : in std_ulogic_vector (0 to (ways-1));
    addr_wr           : in std_ulogic_vector (0 to (addressbus_width-1));
    data_in           : in std_ulogic_vector (0 to (port_bitwidth-1));
    addr_rd_01        : in std_ulogic_vector (0 to (addressbus_width-1));
    addr_rd_23        : in std_ulogic_vector (0 to (addressbus_width-1));
    addr_rd_45        : in std_ulogic_vector (0 to (addressbus_width-1));
    addr_rd_67        : in std_ulogic_vector (0 to (addressbus_width-1));
    data_out          : out std_ulogic_vector(0 to (port_bitwidth*ways-1))
);

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_32x35_8w_1r1w;

architecture tri_32x35_8w_1r1w of tri_32x35_8w_1r1w is

constant wga_base_width : integer := 70;
constant wga_base_addr  : integer := 5;
constant wga_width_mult : integer := (port_bitwidth*ways-1)/wga_base_width + 1;
constant ramb_base_width : integer := 36;
constant ramb_base_addr  : integer := 9;
constant ramb_width_mult : integer := (port_bitwidth-1)/ramb_base_width + 1;  




begin  

  -- synopsys translate_off
  um: if expand_type = 0 generate
      signal tiup               : std_ulogic;
      signal tidn               : std_ulogic;

      signal addr_rd_l2         : std_ulogic_vector (0 TO addressbus_width-1);
      signal addr_wr_l2         : std_ulogic_vector (0 TO addressbus_width-1);
      signal way_l2             : std_ulogic_vector (0 TO way'right);
      signal write_enable_d     : std_ulogic_vector(0 to wga_width_mult-1);
      signal write_enable_l2    : std_ulogic_vector(0 to wga_width_mult-1);
      signal data_in_l2         : std_ulogic_vector(0 to port_bitwidth-1);
      signal array_d            : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
      signal array_l2           : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
      signal act                : std_ulogic;
  begin
      tiup <= '1';
      tidn <= '0';

      act <= or_reduce(write_enable) or rd0_act;

      addr_rd_latch: tri_rlmreg_p
        generic map (width => addr_rd_01'length, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => addr_rd_01,
                  dout        => addr_rd_l2 );

      addr_wr_latch: tri_rlmreg_p
        generic map (width => addr_wr'length, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => addr_wr,
                  dout        => addr_wr_l2 );

      way_latch: tri_rlmreg_p
        generic map (width => way'length, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => way,
                  dout        => way_l2 );

      write_enable_latch: tri_rlmreg_p
        generic map (width => wga_width_mult, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => write_enable_d,
                  dout        => write_enable_l2 );

      data_in_latch: tri_rlmreg_p
        generic map (width => port_bitwidth, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => data_in,
                  dout        => data_in_l2 );

      array_latch: tri_rlmreg_p
        generic map (width => addressable_ports*port_bitwidth*ways, init => 0, expand_type => expand_type)
        port map (nclk        => nclk,
                  act         => tiup,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => array_d,
                  dout        => array_l2 );

      write_enable_d <= write_enable;

      ww: for w in 0 to ways-1 generate
      begin
        wy: for y in 0 to addressable_ports-1 generate
        begin
          wx: for x in 0 to port_bitwidth-1 generate
          begin
            array_d(y*port_bitwidth*ways+w*port_bitwidth+x) <=
                   data_in_l2(x)  when (( or_reduce(write_enable_l2) and addr_wr_l2 = tconv(y, addressbus_width) and 
                                          way_l2(w)) = '1')
              else array_l2(y*port_bitwidth*ways+w*port_bitwidth+x);

          end generate wx;
        end generate wy;
      end generate ww;

      data_out <= array_l2( tconv(addr_rd_l2)*port_bitwidth*ways to tconv(addr_rd_l2)*port_bitwidth*ways+port_bitwidth*ways-1 );

      abst_scan_out <= tidn;
      time_scan_out <= tidn;
      repr_scan_out <= tidn;

      bo_pc_failout <= "0000";
      bo_pc_diagloop <= "0000";
  end generate um;
  -- synopsys translate_on

  a: if expand_type = 1 generate
      component RAMB16_S36_S36
        -- pragma translate_off
	generic(
		SIM_COLLISION_CHECK : string := "none"); 
        -- pragma translate_on
	port(
		DOA : out std_logic_vector(31 downto 0);
		DOB : out std_logic_vector(31 downto 0);
		DOPA : out std_logic_vector(3 downto 0);
		DOPB : out std_logic_vector(3 downto 0);
		ADDRA : in std_logic_vector(8 downto 0);
		ADDRB : in std_logic_vector(8 downto 0);
		CLKA : in std_ulogic;
		CLKB : in std_ulogic;
		DIA : in std_logic_vector(31 downto 0);
		DIB : in std_logic_vector(31 downto 0);
		DIPA : in std_logic_vector(3 downto 0);
		DIPB : in std_logic_vector(3 downto 0);
		ENA : in std_ulogic;
		ENB : in std_ulogic;
		SSRA : in std_ulogic;
		SSRB : in std_ulogic;
		WEA : in std_ulogic;
		WEB : in std_ulogic);
      end component;

      -- pragma translate_off
      -- pragma translate_on

      signal array_wr_data      : std_logic_vector(0 to port_bitwidth - 1);
      signal ramb_data_in       : std_logic_vector(0 to 35);
      signal ramb_data_outA     : std_logic_vector(0 to 35);
      signal ramb_data_outB     : std_logic_vector(0 to 35);
      signal ramb_data_outC     : std_logic_vector(0 to 35);
      signal ramb_data_outD     : std_logic_vector(0 to 35);
      signal ramb_data_outE     : std_logic_vector(0 to 35);
      signal ramb_data_outF     : std_logic_vector(0 to 35);
      signal ramb_data_outG     : std_logic_vector(0 to 35);
      signal ramb_data_outH     : std_logic_vector(0 to 35);
      signal ramb_addr_wr       : std_logic_vector(0 to ramb_base_addr - 1);
      signal ramb_addr_rd       : std_logic_vector(0 to ramb_base_addr - 1);
      signal data_outA          : std_ulogic_vector(0 to 35);
      signal data_outB          : std_ulogic_vector(0 to 35);
      signal data_outC          : std_ulogic_vector(0 to 35);
      signal data_outD          : std_ulogic_vector(0 to 35);
      signal data_outE          : std_ulogic_vector(0 to 35);
      signal data_outF          : std_ulogic_vector(0 to 35);
      signal data_outG          : std_ulogic_vector(0 to 35);
      signal data_outH          : std_ulogic_vector(0 to 35);

      signal rd_addr            : std_ulogic_vector(0 to ramb_base_addr - 1);
      signal wr_addr            : std_ulogic_vector(0 to ramb_base_addr - 1);
      signal write_enable_wA    : std_ulogic;
      signal write_enable_wB    : std_ulogic;
      signal write_enable_wC    : std_ulogic;
      signal write_enable_wD    : std_ulogic;
      signal write_enable_wE    : std_ulogic;
      signal write_enable_wF    : std_ulogic;
      signal write_enable_wG    : std_ulogic;
      signal write_enable_wH    : std_ulogic;
      signal tidn               : std_logic_vector(0 to 35);
      signal act                : std_ulogic;
      signal wen                : std_ulogic;
      signal unused             : std_ulogic;
      -- synopsys translate_off
      -- synopsys translate_on
  begin

      tidn <= (others=>'0');

      wen <= or_reduce(write_enable);
      act <= rd0_act or wen;

      array_wr_data <= tconv(data_in);
      addr_calc : for t in 0 to 35 generate begin
            R0 : if(t < 35 - (port_bitwidth-1))  generate begin ramb_data_in(t) <= '0';                                       end generate;
            R1 : if(t >= 35 - (port_bitwidth-1)) generate begin ramb_data_in(t) <= array_wr_data(t-(35-(port_bitwidth-1)));   end generate;
      end generate addr_calc;

      write_enable_wA <= wen and way(0);
      write_enable_wB <= wen and way(1);
      write_enable_wC <= wen and way(2);
      write_enable_wD <= wen and way(3);
      write_enable_wE <= wen and way(4);
      write_enable_wF <= wen and way(5);
      write_enable_wG <= wen and way(6);
      write_enable_wH <= wen and way(7);      

      rambAddrCalc : for t in 0 to ramb_base_addr-1 generate begin
            R0 : if(t < ramb_base_addr-addressbus_width) generate begin
                  rd_addr(t) <= '0';
                  wr_addr(t) <= '0';
                 end generate;
            R1 : if(t >= ramb_base_addr-addressbus_width) generate begin
                  rd_addr(t) <= addr_rd_01(t-(ramb_base_addr-addressbus_width));
                  wr_addr(t) <= addr_wr(t-(ramb_base_addr-addressbus_width));
                 end generate;
      end generate rambAddrCalc;

      ramb_addr_wr <= tconv(wr_addr);
      ramb_addr_rd <= tconv(rd_addr);

      data_outA <= tconv(ramb_data_outA);
      data_outB <= tconv(ramb_data_outB);
      data_outC <= tconv(ramb_data_outC);
      data_outD <= tconv(ramb_data_outD);
      data_outE <= tconv(ramb_data_outE);
      data_outF <= tconv(ramb_data_outF);
      data_outG <= tconv(ramb_data_outG);
      data_outH <= tconv(ramb_data_outH);

      data_out <= data_outA((35-(port_bitwidth-1)) to 35) & data_outB((35-(port_bitwidth-1)) to 35) &
                  data_outC((35-(port_bitwidth-1)) to 35) & data_outD((35-(port_bitwidth-1)) to 35) &
                  data_outE((35-(port_bitwidth-1)) to 35) & data_outF((35-(port_bitwidth-1)) to 35) &
                  data_outG((35-(port_bitwidth-1)) to 35) & data_outH((35-(port_bitwidth-1)) to 35);

      arr0_A: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outA(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outA(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wA
	  );

      arr1_B: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outB(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outB(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wB
	  );

      arr2_C: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outC(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outC(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wC
	  );

      arr3_D: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outD(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outD(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wD
	  );

      arr4_E: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outE(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outE(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wE
	  );

      arr5_F: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outF(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outF(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wF
	  );

      arr6_G: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outG(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outG(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wG
	  );

      arr7_H: RAMB16_S36_S36
          -- pragma translate_off
          generic map(
                      sim_collision_check => "none")
          -- pragma translate_on
          port map(
             DOA   => ramb_data_outH(0 to 31),
             DOB   => open,
             DOPA  => ramb_data_outH(32 to 35),
             DOPB  => open,
             ADDRA => ramb_addr_rd,
             ADDRB => ramb_addr_wr,
             CLKA  => nclk.clk,
             CLKB  => nclk.clk,
             DIA   => tidn(0 to 31),
             DIB   => ramb_data_in(0 to 31),
             DIPA  => tidn(32 to 35),
             DIPB  => ramb_data_in(32 to 35),
             ENA   => act,
             ENB   => act,
             SSRA  => nclk.sreset,
             SSRB  => nclk.sreset,
             WEA   => tidn(0),
             WEB   => write_enable_wH
	  );

      abst_scan_out <= tidn(0);
      time_scan_out <= tidn(0);
      repr_scan_out <= tidn(0);

      bo_pc_failout <= "0000";
      bo_pc_diagloop <= "0000";

      unused <= or_reduce( data_outA(0) & data_outB(0) & data_outC(0) & data_outD(0)
                           & data_outE(0) & data_outF(0) & data_outG(0) & data_outH(0)
                           & sg_0 & abst_slp_sl_thold_0 & ary_slp_nsl_thold_0
                           & time_sl_thold_0 & repr_sl_thold_0 & clkoff_dc_b & ccflush_dc
                           & scan_dis_dc_b & scan_diag_dc & d_mode_dc & mpw1_dc_b & mpw2_dc_b
                           & delay_lclkr_dc & wr_abst_act & rd0_abst_act & abist_di
                           & abist_bw_odd & abist_bw_even & abist_wr_adr & abist_rd0_adr
                           & tc_lbist_ary_wrt_thru_dc & abist_ena_1 & abist_g8t_rd0_comp_ena
                           & abist_raw_dc_b & obs0_abist_cmp & abst_scan_in & time_scan_in
                           & repr_scan_in & addr_rd_23 & addr_rd_45 & addr_rd_67
                           & lcb_bolt_sl_thold_0 & pc_bo_enable_2 & pc_bo_reset
                           & pc_bo_unload & pc_bo_repair & pc_bo_shdata & pc_bo_select
                           & tri_lcb_mpw1_dc_b & tri_lcb_mpw2_dc_b & tri_lcb_delay_lclkr_dc
                           & tri_lcb_clkoff_dc_b & tri_lcb_act_dis_dc );
  end generate a;

end tri_32x35_8w_1r1w;

