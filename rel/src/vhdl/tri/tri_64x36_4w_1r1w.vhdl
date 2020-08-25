-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee; use ieee.std_logic_1164.all ;
library ibm; use ibm.std_ulogic_support.all ;
             use ibm.std_ulogic_function_support.all;
library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_64x36_4w_1r1w is
  generic (addressable_ports : positive := 64;  -- number of addressable register in this array
           addressbus_width : positive := 6;    -- width of the bus to address all ports (2^addressbus_width >= addressable_ports)
           port_bitwidth : positive := 36;      -- bitwidth of ports
           ways : positive := 4;                -- number of ways
           expand_type : integer := 1);         -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
  port (
  -- POWER PINS
    gnd                         : inout power_logic;
    vdd                         : inout power_logic;
    vcs                         : inout power_logic;
  -- CLOCK and CLOCKCONTROL ports
    nclk                        : in clk_logic;
    rd_act                      : in std_ulogic;
    wr_act                      : in std_ulogic;
    sg_0                        : in std_ulogic;
    abst_sl_thold_0             : in std_ulogic;
    ary_nsl_thold_0             : in std_ulogic;
    time_sl_thold_0             : in std_ulogic;
    repr_sl_thold_0             : in std_ulogic;
    clkoff_dc_b                 : in std_ulogic;
    ccflush_dc                  : in std_ulogic;
    scan_dis_dc_b               : in std_ulogic;
    scan_diag_dc                : in std_ulogic;
    d_mode_dc                   : in std_ulogic;
    mpw1_dc_b                   : in std_ulogic_vector(0 to 4);
    mpw2_dc_b                   : in std_ulogic;
    delay_lclkr_dc              : in std_ulogic_vector(0 to 4);
   -- ABIST
    wr_abst_act                 : in std_ulogic;
    rd0_abst_act                : in std_ulogic;
    abist_di                    : in std_ulogic_vector(0 to 3);
    abist_bw_odd                : in std_ulogic;
    abist_bw_even               : in std_ulogic;
    abist_wr_adr                : in std_ulogic_vector(0 to 5);
    abist_rd0_adr               : in std_ulogic_vector(0 to 5);
    tc_lbist_ary_wrt_thru_dc    : in std_ulogic;
    abist_ena_1                 : in std_ulogic;
    abist_g8t_rd0_comp_ena      : in std_ulogic;
    abist_raw_dc_b              : in std_ulogic;
    obs0_abist_cmp              : in std_ulogic_vector(0 to 3);
  -- Scan
    abst_scan_in                : in std_ulogic_vector(0 to 1);
    time_scan_in                : in std_ulogic;
    repr_scan_in                : in std_ulogic;
    abst_scan_out               : out std_ulogic_vector(0 to 1);
    time_scan_out               : out std_ulogic;
    repr_scan_out               : out std_ulogic;
  -- BOLT-ON
    lcb_bolt_sl_thold_0         : in std_ulogic;
    pc_bo_enable_2              : in std_ulogic; -- general bolt-on enable
    pc_bo_reset                 : in std_ulogic; -- reset
    pc_bo_unload                : in std_ulogic; -- unload sticky bits
    pc_bo_repair                : in std_ulogic; -- execute sticky bit decode
    pc_bo_shdata                : in std_ulogic; -- shift data for timing write and diag loop
    pc_bo_select                : in std_ulogic_vector(0 to 1); -- select for mask and hier writes
    bo_pc_failout               : out std_ulogic_vector(0 to 1); -- fail/no-fix reg
    bo_pc_diagloop              : out std_ulogic_vector(0 to 1);
    tri_lcb_mpw1_dc_b           : in  std_ulogic;
    tri_lcb_mpw2_dc_b           : in  std_ulogic;
    tri_lcb_delay_lclkr_dc      : in  std_ulogic;
    tri_lcb_clkoff_dc_b         : in  std_ulogic;
    tri_lcb_act_dis_dc          : in  std_ulogic;
  -- Write Ports
    wr_way                      : in std_ulogic_vector (0 to (ways-1));
    wr_addr                     : in std_ulogic_vector (0 to (addressbus_width-1));
    data_in                     : in std_ulogic_vector (0 to (port_bitwidth*ways-1));
  -- Read Ports
    rd_addr                     : in std_ulogic_vector(0 to (addressbus_width-1));
    data_out                    : out std_ulogic_vector(0 to (port_bitwidth*ways-1))
);

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_64x36_4w_1r1w;

architecture tri_64x36_4w_1r1w of tri_64x36_4w_1r1w is

constant wga_base_width : integer := 72;
constant wga_width_mult : integer := (port_bitwidth*ways-1)/wga_base_width + 1;
constant ramb_base_width : integer := 36;
constant ramb_base_addr  : integer := 9;
constant ramb_width_mult : integer := (port_bitwidth-1)/ramb_base_width + 1;  


type RAMB_DATA_ARRAY is array (natural range <>) of std_logic_vector(0 to (ramb_base_width*ramb_width_mult - 1));


begin  -- tri_64x36_4w_1r1w

  -- synopsys translate_off
  um: if expand_type = 0 generate
      signal tiup               : std_ulogic;
      signal tidn               : std_ulogic;

      signal wr_addr_l2         : std_ulogic_vector (0 TO addressbus_width-1);
      signal rd_addr_l2         : std_ulogic_vector (0 TO addressbus_width-1);
      signal way_l2             : std_ulogic_vector (0 TO wr_way'right);
      signal write_enable_l2    : std_ulogic;
      signal data_in_l2         : std_ulogic_vector(0 to port_bitwidth*ways-1);
      signal array_d            : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
      signal array_l2           : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
  begin
      tiup <= '1';
      tidn <= '0';

      wr_addr_latch: tri_rlmreg_p
        generic map (width => wr_addr'length, init => 0, needs_sreset => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => wr_act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => wr_addr,
                  dout        => wr_addr_l2 );

      rd_addr_latch: tri_rlmreg_p
        generic map (width => rd_addr'length, init => 0, needs_sreset => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => rd_act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => rd_addr,
                  dout        => rd_addr_l2 );

      way_latch: tri_rlmreg_p
        generic map (width => wr_way'length, init => 0, needs_sreset => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => wr_act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => wr_way,
                  dout        => way_l2 );

      write_enable_latch: tri_rlmlatch_p
        generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => tiup,
                  scin        => tidn,
                  scout       => open,
                  din         => wr_act,
                  dout        => write_enable_l2 );

      data_in_latch: tri_rlmreg_p
        generic map (width => port_bitwidth*ways, init => 0, needs_sreset => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => wr_act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => data_in,
                  dout        => data_in_l2 );

      array_latch: tri_rlmreg_p
        generic map (width => addressable_ports*port_bitwidth*ways, init => 0, needs_sreset => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => tiup,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => array_d,
                  dout        => array_l2 );

      ww: for w in 0 to ways-1 generate
      begin
        wy: for y in 0 to addressable_ports-1 generate
        begin
          wx: for x in 0 to port_bitwidth-1 generate
          begin
            array_d(y*port_bitwidth*ways+w*port_bitwidth+x) <=
                   data_in_l2(w*port_bitwidth+x)  when (( write_enable_l2 and wr_addr_l2 = tconv(y, addressbus_width) and 
                                          way_l2(w)) = '1')
              else array_l2(y*port_bitwidth*ways+w*port_bitwidth+x);

          end generate wx;
        end generate wy;
      end generate ww;

      data_out <= array_l2( tconv(rd_addr_l2)*port_bitwidth*ways to tconv(rd_addr_l2)*port_bitwidth*ways+port_bitwidth*ways-1 );

      abst_scan_out <= tidn & tidn;
      time_scan_out <= tidn;
      repr_scan_out <= tidn;

      bo_pc_failout <= tidn & tidn;
      bo_pc_diagloop <= tidn & tidn;
  end generate um;
  -- synopsys translate_on


  a: if expand_type = 1 generate
      component RAMB16_S36_S36
      -- pragma translate_off
	generic
	(
		SIM_COLLISION_CHECK : string := "none"); -- all, none, warning_only, GENERATE_X_ONLY
      -- pragma translate_on
	port
	(
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
		WEB : in std_ulogic
	);
      end component;

      -- pragma translate_off
      -- pragma translate_on

      signal ramb_data_in       : RAMB_DATA_ARRAY(wr_way'range);
      signal ramb_data_out      : RAMB_DATA_ARRAY(wr_way'range);
      signal ramb_rd_addr       : std_logic_vector(0 to ramb_base_addr - 1);
      signal ramb_wr_addr       : std_logic_vector(0 to ramb_base_addr - 1);

      signal tidn               : std_ulogic;
      signal unused             : std_ulogic;
      -- synopsys translate_off
      -- synopsys translate_on
  begin

      tidn <= '0';

      add0: if (addressbus_width < ramb_base_addr) generate
      begin
        ramb_rd_addr(0 to (ramb_base_addr-addressbus_width-1)) <= (others => '0');
        ramb_rd_addr(ramb_base_addr-addressbus_width to ramb_base_addr-1) <= tconv( rd_addr );

        ramb_wr_addr(0 to (ramb_base_addr-addressbus_width-1)) <= (others => '0');
        ramb_wr_addr(ramb_base_addr-addressbus_width to ramb_base_addr-1) <= tconv( wr_addr );
      end generate;
      add1: if (addressbus_width >= ramb_base_addr) generate
      begin
        ramb_rd_addr <= tconv( rd_addr(addressbus_width-ramb_base_addr to addressbus_width-1) );
        ramb_wr_addr <= tconv( wr_addr(addressbus_width-ramb_base_addr to addressbus_width-1) );
      end generate;

      dw: for w in wr_way'range generate begin
        din: for i in 0 to (ramb_base_width*ramb_width_mult - 1) generate
        begin
          R0: if(i <  port_bitwidth) generate begin ramb_data_in(w)(i) <= data_in(w*port_bitwidth+i); end generate;
          R1: if(i >= port_bitwidth) generate begin ramb_data_in(w)(i) <= '0'; end generate;
        end generate din;
      end generate dw;

      aw: for w in wr_way'range generate begin
        ax: for x in 0 to (ramb_width_mult - 1) generate begin
          arr: RAMB16_S36_S36
            -- pragma translate_off
            generic map(
            -- all, none, warning_only, generate_x_only
                        sim_collision_check => "none")
            -- pragma translate_on
            port map(
		DOA   => ramb_data_out(w)(x*ramb_base_width to x*ramb_base_width+31),
		DOB   => open,
		DOPA  => ramb_data_out(w)(x*ramb_base_width+32 to x*ramb_base_width+35),
		DOPB  => open,
		ADDRA => ramb_rd_addr,
		ADDRB => ramb_wr_addr,
		CLKA  => nclk.clk,
		CLKB  => nclk.clk,
		DIA   => ramb_data_in(w)(x*ramb_base_width to x*ramb_base_width+31),
		DIB   => ramb_data_in(w)(x*ramb_base_width to x*ramb_base_width+31),
		DIPA  => ramb_data_in(w)(x*ramb_base_width+32 to x*ramb_base_width+35),
		DIPB  => ramb_data_in(w)(x*ramb_base_width+32 to x*ramb_base_width+35),
		ENA   => rd_act,
		ENB   => wr_act,
		SSRA  => nclk.sreset,
		SSRB  => nclk.sreset,
		WEA   => tidn,
		WEB   => wr_way(w)
	  );

        end generate ax;

        data_out(w*port_bitwidth to ((w+1)*port_bitwidth)-1 ) <= tconv( ramb_data_out(w)(0 to port_bitwidth-1) );

      end generate aw;

      abst_scan_out <= tidn & tidn;
      time_scan_out <= tidn;
      repr_scan_out <= tidn;

      bo_pc_failout <= tidn & tidn;
      bo_pc_diagloop <= tidn & tidn;

      unused <= or_reduce( sg_0 & abst_sl_thold_0 & ary_nsl_thold_0
                           & time_sl_thold_0 & repr_sl_thold_0 & clkoff_dc_b & ccflush_dc
                           & scan_dis_dc_b & scan_diag_dc & d_mode_dc & mpw1_dc_b & mpw2_dc_b
                           & delay_lclkr_dc & wr_abst_act & rd0_abst_act & abist_di
                           & abist_bw_odd & abist_bw_even & abist_wr_adr & abist_rd0_adr
                           & tc_lbist_ary_wrt_thru_dc & abist_ena_1 & abist_g8t_rd0_comp_ena
                           & abist_raw_dc_b & obs0_abist_cmp & abst_scan_in & time_scan_in
                           & repr_scan_in & lcb_bolt_sl_thold_0 & pc_bo_enable_2 & pc_bo_reset
                           & pc_bo_unload & pc_bo_repair & pc_bo_shdata & pc_bo_select
                           & tri_lcb_mpw1_dc_b & tri_lcb_mpw2_dc_b & tri_lcb_delay_lclkr_dc
                           & tri_lcb_clkoff_dc_b & tri_lcb_act_dis_dc );
  end generate a;


end tri_64x36_4w_1r1w;
