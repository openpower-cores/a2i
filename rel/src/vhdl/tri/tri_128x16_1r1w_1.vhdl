-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee;  use ieee.std_logic_1164.all;
library support; 
                 use support.power_logic_pkg.all;
library ibm; 
             use ibm.std_ulogic_support.all ;
             use ibm.std_ulogic_function_support.all;
library tri; use tri.tri_latches_pkg.all;

entity tri_128x16_1r1w_1 is
  generic (addressable_ports : positive := 128; 
           addressbus_width : positive := 7;    
           port_bitwidth : positive := 16;      
           ways : positive := 1;                
           expand_type : integer := 1);         
port (
    vdd                          : INOUT power_logic; 
    vcs                          : INOUT power_logic; 
    gnd                          : INOUT power_logic; 
  
    nclk                         : IN clk_logic;

    rd_act                             : IN std_ulogic;
    wr_act            		       : IN std_ulogic;

    lcb_d_mode_dc                : IN std_ulogic;
    lcb_clkoff_dc_b              : IN std_ulogic;
    lcb_mpw1_dc_b                : IN std_ulogic_vector(0 TO 4);
    lcb_mpw2_dc_b                : IN std_ulogic;		
    lcb_delay_lclkr_dc           : IN std_ulogic_vector(0 TO 4);		

    ccflush_dc                   : IN  std_ulogic;
    scan_dis_dc_b                : IN  std_ulogic;		
    scan_diag_dc                 : IN  std_ulogic;
    func_scan_in         : IN std_ulogic;
    func_scan_out        : OUT std_ulogic;

    lcb_sg_0              : IN std_ulogic;
    lcb_sl_thold_0_b      : IN std_ulogic;
    lcb_time_sl_thold_0        : IN std_ulogic;
    lcb_abst_sl_thold_0        : IN std_ulogic;
    lcb_ary_nsl_thold_0        : IN std_ulogic;
    lcb_repr_sl_thold_0        : IN std_ulogic;
    time_scan_in         : IN std_ulogic;
    time_scan_out        : OUT std_ulogic;
    abst_scan_in         : IN std_ulogic;
    abst_scan_out        : OUT std_ulogic;
    repr_scan_in         : IN std_ulogic;
    repr_scan_out        : OUT std_ulogic;

    abist_di                     : IN std_ulogic_vector(0 TO 3);
    abist_bw_odd                 : IN std_ulogic;
    abist_bw_even                : IN std_ulogic;
    abist_wr_adr                 : IN std_ulogic_vector(0 TO 6);
    wr_abst_act                  : IN std_ulogic;
    abist_rd0_adr                : IN std_ulogic_vector(0 TO 6);
    rd0_abst_act                 : IN std_ulogic;
    tc_lbist_ary_wrt_thru_dc     : IN std_ulogic;
    abist_ena_1                  : IN std_ulogic;
    abist_g8t_rd0_comp_ena       : IN std_ulogic;
    abist_raw_dc_b               : IN std_ulogic;
    obs0_abist_cmp               : IN std_ulogic_vector(0 TO 3);

    lcb_bolt_sl_thold_0         : in    std_ulogic;
    pc_bo_enable_2              : in    std_ulogic; 
    pc_bo_reset                 : in    std_ulogic; 
    pc_bo_unload                : in    std_ulogic; 
    pc_bo_repair                : in    std_ulogic; 
    pc_bo_shdata                : in    std_ulogic; 
    pc_bo_select                : in    std_ulogic; 
    bo_pc_failout               : out   std_ulogic; 
    bo_pc_diagloop              : out   std_ulogic;
    tri_lcb_mpw1_dc_b           : in    std_ulogic;
    tri_lcb_mpw2_dc_b           : in    std_ulogic;
    tri_lcb_delay_lclkr_dc      : in    std_ulogic;
    tri_lcb_clkoff_dc_b         : in    std_ulogic;
    tri_lcb_act_dis_dc          : in    std_ulogic;

    bw                           : IN std_ulogic_vector( 0 TO 15 );  
    wr_adr                       : IN std_ulogic_vector( 0 TO 6 );
    rd_adr                       : IN std_ulogic_vector( 0 TO 6 );  
    di                		 : IN std_ulogic_vector( 0 TO 15 );
    do                        : OUT std_ulogic_vector( 0 TO 15 )
		
   );

  -- synopsys translate_off
  -- synopsys translate_on

end entity tri_128x16_1r1w_1;

architecture tri_128x16_1r1w_1 of tri_128x16_1r1w_1 is

begin

  -- synopsys translate_off
  um: if expand_type = 0 generate

     constant rd_addr_offset       :  natural := 0;
     constant wr_addr_offset       :  natural := rd_addr_offset + addressbus_width;
     constant write_enable_offset  :  natural := wr_addr_offset + addressbus_width;
     constant data_in_offset       :  natural := write_enable_offset + port_bitwidth;
     constant data_out_offset      :  natural := data_in_offset + port_bitwidth;
     constant array_offset         :  natural := data_out_offset + port_bitwidth;
     constant scan_right           :  natural := array_offset + addressable_ports*port_bitwidth*ways - 1;

      signal tiup               : std_ulogic;
      signal tidn               : std_ulogic;

      signal rd_addr_l2            : std_ulogic_vector (0 TO addressbus_width-1);
      signal wr_addr_l2            : std_ulogic_vector (0 TO addressbus_width-1);
      signal write_enable_d     : std_ulogic_vector(0 to port_bitwidth-1);
      signal write_enable_l2    : std_ulogic_vector(0 to port_bitwidth-1);
      signal data_in_l2         : std_ulogic_vector(0 to port_bitwidth-1);
      signal data_out_d          : std_ulogic_vector(0 to port_bitwidth-1);
      signal data_out_l2         : std_ulogic_vector(0 to port_bitwidth-1);
      signal array_d            : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
      signal array_l2           : std_ulogic_vector(0 to addressable_ports*port_bitwidth*ways-1);
      signal siv                      : std_ulogic_vector(0 to scan_right);
      signal sov                      : std_ulogic_vector(0 to scan_right);
  begin
      tiup <= '1';
      tidn <= '0';

      rd_addr_latch: tri_rlmreg_p
        generic map (width => rd_adr'length, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => rd_act,
                  scin        => siv(rd_addr_offset to rd_addr_offset+rd_addr_l2'length-1),
                  scout       => sov(rd_addr_offset to rd_addr_offset+rd_addr_l2'length-1),
                  din         => rd_adr,
                  dout        => rd_addr_l2 );

      wr_addr_latch: tri_rlmreg_p
        generic map (width => wr_adr'length, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => wr_act,
                  scin        => siv(wr_addr_offset to wr_addr_offset+wr_addr_l2'length-1),
                  scout       => sov(wr_addr_offset to wr_addr_offset+wr_addr_l2'length-1),
                  din         => wr_adr,
                  dout        => wr_addr_l2 );



      write_enable_latch: tri_rlmreg_p
        generic map (width => port_bitwidth, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => wr_act,
                  scin        => siv(write_enable_offset to write_enable_offset+write_enable_l2'length-1),
                  scout       => sov(write_enable_offset to write_enable_offset+write_enable_l2'length-1),
                  din         => write_enable_d,
                  dout        => write_enable_l2 );

      data_in_latch: tri_rlmreg_p
        generic map (width => port_bitwidth, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => wr_act,
                  scin        => siv(data_in_offset to data_in_offset+data_in_l2'length-1),
                  scout       => sov(data_in_offset to data_in_offset+data_in_l2'length-1),
                  din         => di,
                  dout        => data_in_l2 );

      data_out_latch: tri_rlmreg_p
        generic map (width => port_bitwidth, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => wr_act,
                  scin        => siv(data_out_offset to data_out_offset+data_out_l2'length-1),
                  scout       => sov(data_out_offset to data_out_offset+data_out_l2'length-1),
                  din         => data_out_d,
                  dout        => data_out_l2 );

      array_latch: tri_rlmreg_p
        generic map (width => addressable_ports*port_bitwidth*ways, init => 0, expand_type => expand_type)
        port map (vd          => vdd,
                  gd          => gnd,
                  nclk        => nclk,
                  act         => tiup,
                  scin        => siv(array_offset to array_offset+array_l2'length-1),
                  scout       => sov(array_offset to array_offset+array_l2'length-1),
                  din         => array_d,
                  dout        => array_l2 );

      write_enable_d <= bw when wr_act='1' else (others => '0');

      ww: for w in 0 to ways-1 generate
      begin
        wy: for y in 0 to addressable_ports-1 generate
        begin
          wx: for x in 0 to port_bitwidth-1 generate
          begin
            array_d(y*port_bitwidth*ways+w*port_bitwidth+x) <=
                   data_in_l2(x)  when ( write_enable_l2(x)='1' and wr_addr_l2 = tconv(y, addressbus_width)) 
              else array_l2(y*port_bitwidth*ways+w*port_bitwidth+x);

          end generate wx;
        end generate wy;
      end generate ww;

      data_out_d(0) <= array_l2( tconv(rd_addr_l2)*port_bitwidth);
      data_out_d(1) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+1);
      data_out_d(2) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+2);
      data_out_d(3) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+3);
      data_out_d(4) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+4);
      data_out_d(5) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+5);
      data_out_d(6) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+6);
      data_out_d(7) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+7);
      data_out_d(8) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+8);
      data_out_d(9) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+9);
      data_out_d(10) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+10);
      data_out_d(11) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+11);
      data_out_d(12) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+12);
      data_out_d(13) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+13);
      data_out_d(14) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+14);
      data_out_d(15) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+15);

      do(0) <= array_l2( tconv(rd_addr_l2)*port_bitwidth);
      do(1) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+1);
      do(2) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+2);
      do(3) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+3);
      do(4) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+4);
      do(5) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+5);
      do(6) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+6);
      do(7) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+7);
      do(8) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+8);
      do(9) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+9);
      do(10) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+10);
      do(11) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+11);
      do(12) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+12);
      do(13) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+13);
      do(14) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+14);
      do(15) <= array_l2( tconv(rd_addr_l2)*port_bitwidth+15);

  siv(0 to scan_right) <= sov(1 to scan_right) & func_scan_in;
  func_scan_out <= sov(0);
  
  time_scan_out <= time_scan_in;
  abst_scan_out <= abst_scan_in;
  repr_scan_out <= repr_scan_in;

  bo_pc_failout  <= '0';
  bo_pc_diagloop <= '0';

  end generate um;
  -- synopsys translate_on


a : if expand_type = 1 generate

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



signal clk,clk2x                          : std_ulogic;
signal b0addra,         b0addrb           : std_ulogic_vector(0 to 8);
signal wea,             web               : std_ulogic;
signal wren_a              : std_ulogic;
signal reset_q                            : std_ulogic;
signal gate_fq,         gate_d            : std_ulogic;
signal r_data_out_1_d,  r_data_out_1_fq   : std_ulogic_vector(0 to 35);
signal w_data_in_0                        : std_ulogic_vector(0 to 35);

signal r_data_out_0_bram                  : std_logic_vector(0 to 35);
signal r_data_out_1_bram                  : std_logic_vector(0 to 35);

signal toggle_d     : std_ulogic;
signal toggle_q     : std_ulogic;
signal toggle2x_d   : std_ulogic;
signal toggle2x_q   : std_ulogic;

signal unused             : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on

begin

clk   <= nclk.clk;
clk2x <= nclk.clk2x;

rlatch: process (clk) begin
    if(rising_edge(clk)) then
      reset_q              <= nclk.sreset;
    end if;
end process;


tlatch: process (nclk.clk,reset_q)
begin
   if(rising_edge(nclk.clk)) then
      if (reset_q = '1') then
         toggle_q  <= '1';
      else
         toggle_q  <= toggle_d;
      end if;
    end if;
end process;

flatch: process (nclk.clk2x)
begin
   if(rising_edge(nclk.clk2x)) then
      toggle2x_q <= toggle2x_d;
      gate_fq  <= gate_d;
      r_data_out_1_fq   <= r_data_out_1_d;
   end if;
end process;

toggle_d   <= not toggle_q;
toggle2x_d <= toggle_q;

gate_d <= not(toggle_q xor toggle2x_q);





b0addra(2 to 8)   <= wr_adr;
b0addrb(2 to 8)   <= rd_adr;

b0addra(0 to 1) <= "00";
b0addrb(0 to 1) <= "00";



wren_a <= '1' when bw /= "0000000000000000" else '0';
wea         <= wren_a and not(gate_fq); 
web         <= '0';
w_data_in_0(0) <= di(0) when bw(0)='1' else r_data_out_0_bram(0);
w_data_in_0(1) <= di(1) when bw(1)='1' else r_data_out_0_bram(1);
w_data_in_0(2) <= di(2) when bw(2)='1' else r_data_out_0_bram(2);
w_data_in_0(3) <= di(3) when bw(3)='1' else r_data_out_0_bram(3);
w_data_in_0(4) <= di(4) when bw(4)='1' else r_data_out_0_bram(4);
w_data_in_0(5) <= di(5) when bw(5)='1' else r_data_out_0_bram(5);
w_data_in_0(6) <= di(6) when bw(6)='1' else r_data_out_0_bram(6);
w_data_in_0(7) <= di(7) when bw(7)='1' else r_data_out_0_bram(7);
w_data_in_0(8) <= di(8) when bw(8)='1' else r_data_out_0_bram(8);
w_data_in_0(9) <= di(9) when bw(9)='1' else r_data_out_0_bram(9);
w_data_in_0(10) <= di(10) when bw(10)='1' else r_data_out_0_bram(10);
w_data_in_0(11) <= di(11) when bw(11)='1' else r_data_out_0_bram(11);
w_data_in_0(12) <= di(12) when bw(12)='1' else r_data_out_0_bram(12);
w_data_in_0(13) <= di(13) when bw(13)='1' else r_data_out_0_bram(13);
w_data_in_0(14) <= di(14) when bw(14)='1' else r_data_out_0_bram(14);
w_data_in_0(15) <= di(15) when bw(15)='1' else r_data_out_0_bram(15);
w_data_in_0(16 to 35) <= (others => '0');

r_data_out_1_d <= std_ulogic_vector(r_data_out_1_bram);

bram0a : ramb16_s36_s36
-- pragma translate_off
generic map(
   sim_collision_check => "none")
-- pragma translate_on
port map(
                       clka  => clk2x,
	               clkb  => clk2x,
	               ssra  => reset_q,
	               ssrb  => reset_q,
	               addra => std_logic_vector(b0addra),
	               addrb => std_logic_vector(b0addrb),
	               dia   => std_logic_vector(w_data_in_0(0 to 31)),
	               dib   => (others => '0'),
                       doa   => r_data_out_0_bram(0 to 31),
                       dob   => r_data_out_1_bram(0 to 31),
                       dopa  => r_data_out_0_bram(32 to 35),
                       dopb  => r_data_out_1_bram(32 to 35),
	               dipa  => std_logic_vector(w_data_in_0(32 to 35)),
	               dipb  => (others => '0'),
	               ena   => '1',
	               enb   => '1',
	               wea   => wea,
	               web   => web
	               );


do   <= r_data_out_1_fq(0 to 15);

func_scan_out <= func_scan_in;
time_scan_out <= time_scan_in;
abst_scan_out <= abst_scan_in;
repr_scan_out <= repr_scan_in;

bo_pc_failout  <= '0';
bo_pc_diagloop <= '0';

unused <= or_reduce( std_ulogic_vector(r_data_out_0_bram(16 to 35)) & rd_act & wr_act
                       & lcb_d_mode_dc & lcb_clkoff_dc_b & lcb_mpw1_dc_b & lcb_mpw2_dc_b
                       & lcb_delay_lclkr_dc & ccflush_dc & scan_dis_dc_b & scan_diag_dc
                       & lcb_sg_0 & lcb_sl_thold_0_b & lcb_time_sl_thold_0 & lcb_abst_sl_thold_0
                       & lcb_ary_nsl_thold_0 & lcb_repr_sl_thold_0 & abist_di & abist_bw_odd
                       & abist_bw_even & abist_wr_adr & wr_abst_act & abist_rd0_adr & rd0_abst_act
                       & tc_lbist_ary_wrt_thru_dc & abist_ena_1 & abist_g8t_rd0_comp_ena
                       & abist_raw_dc_b & obs0_abist_cmp & lcb_bolt_sl_thold_0 & pc_bo_enable_2
                       & pc_bo_reset & pc_bo_unload & pc_bo_repair & pc_bo_shdata & pc_bo_select
                       & tri_lcb_mpw1_dc_b & tri_lcb_mpw2_dc_b & tri_lcb_delay_lclkr_dc
                       & tri_lcb_clkoff_dc_b & tri_lcb_act_dis_dc );

end generate a;


end architecture tri_128x16_1r1w_1;


