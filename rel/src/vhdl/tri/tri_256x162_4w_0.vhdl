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

entity tri_256x162_4w_0 is
  generic (addressable_ports : positive := 256; -- number of addressable register in this array
           addressbus_width : positive := 8;    -- width of the bus to address all ports (2^addressbus_width >= addressable_ports)
           port_bitwidth : positive := 162;     -- bitwidth of ports
           ways : positive := 4;                -- number of ways
           expand_type : integer := 1);         -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
  port (
  -- POWER PINS
    gnd               : inout power_logic;
    vdd               : inout power_logic;
    vcs               : inout power_logic;
  -- CLOCK and CLOCKCONTROL ports
    nclk                        : in  clk_logic;
    ccflush_dc                  : in  std_ulogic;
    lcb_clkoff_dc_b             : in  std_ulogic;
    lcb_d_mode_dc               : in  std_ulogic;
    lcb_act_dis_dc              : in  std_ulogic;
    lcb_ary_nsl_thold_0         : in  std_ulogic;
    lcb_sg_1                    : in  std_ulogic;
    lcb_abst_sl_thold_0         : in  std_ulogic;
    scan_diag_dc                : in  std_ulogic;
    scan_dis_dc_b               : in  std_ulogic;
    abst_scan_in                : in  std_ulogic_vector(0 to 1);
    abst_scan_out               : out std_ulogic_vector(0 to 1);
    lcb_delay_lclkr_np_dc       : in  std_ulogic;
    ctrl_lcb_delay_lclkr_np_dc  : in  std_ulogic;
    dibw_lcb_delay_lclkr_np_dc  : in  std_ulogic;
    ctrl_lcb_mpw1_np_dc_b       : in  std_ulogic;
    dibw_lcb_mpw1_np_dc_b       : in  std_ulogic;
    lcb_mpw1_pp_dc_b            : in  std_ulogic;
    lcb_mpw1_2_pp_dc_b          : in  std_ulogic;
    aodo_lcb_delay_lclkr_dc     : in  std_ulogic;
    aodo_lcb_mpw1_dc_b          : in  std_ulogic;
    aodo_lcb_mpw2_dc_b          : in  std_ulogic;
    -- Timing Scan Chain Pins
    lcb_time_sg_0               : in    std_ulogic;
    lcb_time_sl_thold_0         : in    std_ulogic;
    time_scan_in                : in    std_ulogic;
    time_scan_out               : out   std_ulogic;
    bitw_abist                  : in    std_ulogic_vector(0 to 1);
    -- REDUNDANCY PINS
    lcb_repr_sl_thold_0         : in    std_ulogic;
    lcb_repr_sg_0               : in    std_ulogic;
    repr_scan_in                : in    std_ulogic;
    repr_scan_out               : out   std_ulogic;
    -- DATA I/O RELATED PINS:
    tc_lbist_ary_wrt_thru_dc    : in    std_ulogic;
    abist_en_1                  : in    std_ulogic;
    din_abist                   : in    std_ulogic_vector(0 to 3);
    abist_cmp_en                : in    std_ulogic;
    abist_raw_b_dc              : in    std_ulogic;
    data_cmp_abist              : in    std_ulogic_vector(0 to 3);
    addr_abist                  : in    std_ulogic_vector(0 to (addressbus_width-1));
    r_wb_abist                  : in    std_ulogic;
    write_thru_en_dc            : in    std_ulogic;
  -- BOLT-ON
    lcb_bolt_sl_thold_0         : in    std_ulogic; -- thold for any regs inside backend
    pc_bo_enable_2              : in    std_ulogic; -- general bolt-on enable, probably DC
    pc_bo_reset                 : in    std_ulogic; -- execute sticky bit decode
    pc_bo_unload                : in    std_ulogic;
    pc_bo_repair                : in    std_ulogic; -- load repair reg
    pc_bo_shdata                : in    std_ulogic; -- shift data for timing write
    pc_bo_select                : in    std_ulogic_vector(0 to 1); -- select for mask and hier writes
    bo_pc_failout               : out   std_ulogic_vector(0 to 1); -- fail/no-fix reg
    bo_pc_diagloop              : out   std_ulogic_vector(0 to 1);
    tri_lcb_mpw1_dc_b           : in    std_ulogic;
    tri_lcb_mpw2_dc_b           : in    std_ulogic;
    tri_lcb_delay_lclkr_dc      : in    std_ulogic;
    tri_lcb_clkoff_dc_b         : in    std_ulogic;
    tri_lcb_act_dis_dc          : in    std_ulogic;
  -- FUNCTIONAL PORTS
    read_act          : in std_ulogic;
    write_enable      : in std_ulogic;
    write_way         : in std_ulogic_vector (0 to (ways-1));
    addr              : in std_ulogic_vector (0 to (addressbus_width-1));
    data_in           : in std_ulogic_vector (0 to (port_bitwidth-1));
    data_out          : out std_ulogic_vector(0 to (port_bitwidth*ways-1))
);

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_256x162_4w_0;

architecture tri_256x162_4w_0 of tri_256x162_4w_0 is

constant wga_base_width : integer := 324;
constant wga_width_mult : integer := (port_bitwidth*ways-1)/wga_base_width + 1;
constant ramb_base_width : integer := 36;
constant ramb_base_addr  : integer := 9;
constant ramb_width_mult : integer := (port_bitwidth-1)/ramb_base_width + 1;  


type RAMB_DATA_ARRAY is array (natural range <>) of std_logic_vector(0 to (ramb_base_width*ramb_width_mult - 1));


begin  -- tri_256x162_4w_0

  -- synopsys translate_off
  um: if expand_type = 0 generate
      signal tiup               : std_ulogic;
      signal tidn               : std_ulogic;

      signal act                : std_ulogic;
      signal addr_l2            : std_ulogic_vector (0 TO addressbus_width-1);
      signal write_way_l2       : std_ulogic_vector (0 TO write_way'right);
      signal write_enable_d     : std_ulogic;
      signal write_enable_l2    : std_ulogic;
      signal data_in_l2         : std_ulogic_vector(0 to port_bitwidth-1);
      signal array_d            : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
      signal array_l2           : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
  begin
      tiup <= '1';
      tidn <= '0';

      act <= read_act or or_reduce(write_way);

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

      write_way_latch: tri_rlmreg_p
        generic map (width => write_way'length, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => act,
                  scin        => (others => '0'),
                  scout       => open,
                  din         => write_way,
                  dout        => write_way_l2 );

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
                   data_in_l2(x)  when (( write_enable_l2 and addr_l2 = tconv(y, addressbus_width) and 
                                          write_way_l2(w)) = '1')
              else array_l2(y*port_bitwidth*ways+w*port_bitwidth+x);

          end generate wx;
        end generate wy;
      end generate ww;

      data_out <= array_l2( tconv(addr_l2)*port_bitwidth*ways to tconv(addr_l2)*port_bitwidth*ways+port_bitwidth*ways-1 );

      abst_scan_out     <= "00";
      time_scan_out     <= '0';
      repr_scan_out     <= '0';

      bo_pc_failout     <= "00";
      bo_pc_diagloop    <= "00";

  end generate um;
  -- synopsys translate_on


  a: if expand_type = 1 generate
      component RAMB16_S36_S36
        -- pragma translate_off
	generic(
		SIM_COLLISION_CHECK : string := "none"); -- all, none, warning_only, GENERATE_X_ONLY
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

      signal ramb_data_in       : std_logic_vector(0 to (ramb_base_width*ramb_width_mult - 1));
      signal ramb_data_out      : RAMB_DATA_ARRAY(0 to ways-1);
      signal ramb_addr          : std_logic_vector(0 to ramb_base_addr - 1);

      signal act                : std_ulogic_vector(0 to ways-1);
      signal write              : std_ulogic_vector(0 to ways-1);
      signal tidn               : std_ulogic;
      signal unused             : std_ulogic;
      -- synopsys translate_off
      -- synopsys translate_on
  begin

      tidn <= '0';

      add0: if (addressbus_width < ramb_base_addr) generate
      begin
        ramb_addr(0 to (ramb_base_addr-addressbus_width-1)) <= (others => '0');
        ramb_addr(ramb_base_addr-addressbus_width to ramb_base_addr-1) <= tconv( addr );
      end generate;
      add1: if (addressbus_width >= ramb_base_addr) generate
      begin
        ramb_addr <= tconv( addr(addressbus_width-ramb_base_addr to addressbus_width-1) );
      end generate;

      din: for i in ramb_data_in'range generate
      begin
        R0: if(i <  port_bitwidth) generate begin ramb_data_in(i) <= data_in(i); end generate;
        R1: if(i >= port_bitwidth) generate begin ramb_data_in(i) <= '0'; end generate;
      end generate;

      aw: for w in 0 to ways-1 generate begin
        act(w) <= read_act or write_way(w);
        write(w) <= write_enable and write_way(w);

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
		ADDRA => ramb_addr,
		ADDRB => ramb_addr,
		CLKA  => nclk.clk,
		CLKB  => tidn,
		DIA   => ramb_data_in(x*ramb_base_width to x*ramb_base_width+31),
		DIB   => ramb_data_in(x*ramb_base_width to x*ramb_base_width+31),
		DIPA  => ramb_data_in(x*ramb_base_width+32 to x*ramb_base_width+35),
		DIPB  => ramb_data_in(x*ramb_base_width+32 to x*ramb_base_width+35),
		ENA   => act(w),
		ENB   => tidn,
		SSRA  => nclk.sreset,
		SSRB  => tidn,
		WEA   => write(w),
		WEB   => tidn
	  );

        end generate ax;

        data_out(w*port_bitwidth to ((w+1)*port_bitwidth)-1 ) <= tconv( ramb_data_out(w)(0 to port_bitwidth-1) );

      end generate aw;

      abst_scan_out     <= "00";
      time_scan_out     <= '0';
      repr_scan_out     <= '0';

      bo_pc_failout     <= "00";
      bo_pc_diagloop    <= "00";

      unused <= or_reduce( std_ulogic_vector(ramb_data_out(0)(port_bitwidth to ramb_base_width*ramb_width_mult - 1))
                       & std_ulogic_vector(ramb_data_out(1)(port_bitwidth to ramb_base_width*ramb_width_mult - 1))
                       & std_ulogic_vector(ramb_data_out(2)(port_bitwidth to ramb_base_width*ramb_width_mult - 1))
                       & std_ulogic_vector(ramb_data_out(3)(port_bitwidth to ramb_base_width*ramb_width_mult - 1))
                       & ccflush_dc & lcb_clkoff_dc_b & lcb_d_mode_dc & lcb_act_dis_dc
                       & scan_dis_dc_b & scan_diag_dc & bitw_abist
                       & lcb_sg_1 & lcb_time_sg_0 & lcb_repr_sg_0
                       & lcb_abst_sl_thold_0 & lcb_repr_sl_thold_0 
                       & lcb_time_sl_thold_0 & lcb_ary_nsl_thold_0 & tc_lbist_ary_wrt_thru_dc 
                       & abist_en_1 & din_abist & abist_cmp_en & abist_raw_b_dc & data_cmp_abist 
                       & addr_abist & r_wb_abist & write_thru_en_dc & abst_scan_in & time_scan_in & repr_scan_in
                       & lcb_delay_lclkr_np_dc & ctrl_lcb_delay_lclkr_np_dc & dibw_lcb_delay_lclkr_np_dc
                       & ctrl_lcb_mpw1_np_dc_b & dibw_lcb_mpw1_np_dc_b & lcb_mpw1_pp_dc_b & lcb_mpw1_2_pp_dc_b
                       & aodo_lcb_delay_lclkr_dc & aodo_lcb_mpw1_dc_b & aodo_lcb_mpw2_dc_b
                       & lcb_bolt_sl_thold_0 & pc_bo_enable_2 & pc_bo_reset
                       & pc_bo_unload & pc_bo_repair & pc_bo_shdata & pc_bo_select
                       & tri_lcb_mpw1_dc_b & tri_lcb_mpw2_dc_b & tri_lcb_delay_lclkr_dc
                       & tri_lcb_clkoff_dc_b & tri_lcb_act_dis_dc );

  end generate a;

end tri_256x162_4w_0;
