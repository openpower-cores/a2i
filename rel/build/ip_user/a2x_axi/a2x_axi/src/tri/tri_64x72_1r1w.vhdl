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

library ieee,ibm,support,tri;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_64x72_1r1w is
generic(
   expand_type                         : integer :=  1;
   regsize                             : integer := 64);
port (
   vdd                                 : INOUT power_logic; 
   vcs                                 : INOUT power_logic; 
   gnd                                 : INOUT power_logic; 

   nclk                                : in clk_logic;
   sg_0                                : in  std_ulogic;
   abst_sl_thold_0                     : in  std_ulogic;
   ary_nsl_thold_0                     : in  std_ulogic;
   time_sl_thold_0                     : in  std_ulogic;
   repr_sl_thold_0                     : in  std_ulogic;

   rd0_act                             : in std_ulogic;
   rd0_adr                             : in std_ulogic_vector(0 to 5);  
   do0                                 : out std_ulogic_vector(64-regsize to 72-(64/regsize));

   wr_act                              : in std_ulogic;
   wr_adr                              : in std_ulogic_vector(0 to 5);
   di                                  : in std_ulogic_vector(64-regsize to 72-(64/regsize));

   abst_scan_in                        : in  std_ulogic;
   abst_scan_out                       : out std_ulogic;
   time_scan_in                        : in  std_ulogic;
   time_scan_out                       : out std_ulogic;
   repr_scan_in                        : in  std_ulogic;
   repr_scan_out                       : out std_ulogic;
   
   scan_dis_dc_b                       : in  std_ulogic;
   scan_diag_dc                        : in  std_ulogic;
   ccflush_dc                          : in  std_ulogic;
   clkoff_dc_b                         : in  std_ulogic;
   d_mode_dc                           : in  std_ulogic;
   mpw1_dc_b                           : in  std_ulogic_vector(0 to 4);
   mpw2_dc_b                           : in  std_ulogic;
   delay_lclkr_dc                      : in  std_ulogic_vector(0 to 4);

   lcb_bolt_sl_thold_0                 : in  std_ulogic;
   pc_bo_enable_2                      : in  std_ulogic; 
   pc_bo_reset                         : in  std_ulogic; 
   pc_bo_unload                        : in  std_ulogic; 
   pc_bo_repair                        : in  std_ulogic; 
   pc_bo_shdata                        : in  std_ulogic; 
   pc_bo_select                        : in  std_ulogic; 
   bo_pc_failout                       : out std_ulogic; 
   bo_pc_diagloop                      : out std_ulogic;
   tri_lcb_mpw1_dc_b                   : in  std_ulogic;
   tri_lcb_mpw2_dc_b                   : in  std_ulogic;
   tri_lcb_delay_lclkr_dc              : in  std_ulogic;
   tri_lcb_clkoff_dc_b                 : in  std_ulogic;
   tri_lcb_act_dis_dc                  : in  std_ulogic;

   abist_di                            : in  std_ulogic_vector(0 to 3);
   abist_bw_odd                        : in  std_ulogic;
   abist_bw_even                       : in  std_ulogic;
   abist_wr_adr                        : in  std_ulogic_vector(0 to 5);
   wr_abst_act                         : in  std_ulogic;
   abist_rd0_adr                       : in  std_ulogic_vector(0 to 5);
   rd0_abst_act                        : in  std_ulogic;
   tc_lbist_ary_wrt_thru_dc            : in  std_ulogic;
   abist_ena_1                         : in  std_ulogic;
   abist_g8t_rd0_comp_ena              : in  std_ulogic;
   abist_raw_dc_b                      : in  std_ulogic;
   obs0_abist_cmp                      : in  std_ulogic_vector(0 to 3)
   );

-- synopsys translate_off
-- synopsys translate_on


end entity tri_64x72_1r1w;
architecture tri_64x72_1r1w of tri_64x72_1r1w is

begin

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

signal clk,             clk2x             : std_ulogic;
signal addra,           addrb             : std_ulogic_vector(0 to 8);
signal wea,             web               : std_ulogic;
signal bdo                                : std_logic_vector(0 to 71);
signal bdi                                : std_ulogic_vector(0 to 71);
signal sreset                             : std_ulogic;
signal tidn                               : std_ulogic_vector(0 to 71);
signal reset_q                            : std_ulogic;
signal gate_fq,         gate_d            : std_ulogic;
signal bdo_d,           bdo_fq            : std_ulogic_vector(64-regsize to 72-(64/regsize));

signal toggle_d     : std_ulogic;
signal toggle_q     : std_ulogic;
signal toggle2x_d   : std_ulogic;
signal toggle2x_q   : std_ulogic;

signal unused             : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on

begin

tidn  <= (others=>'0');
clk   <= nclk.clk;
clk2x <= nclk.clk2x;
sreset<= nclk.sreset;

rlatch: process (clk) begin
    if(rising_edge(clk)) then
      reset_q              <= sreset after 10 ps;
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
      bdo_fq   <= bdo_d;
   end if;
end process;

toggle_d   <= not toggle_q;
toggle2x_d <= toggle_q;

gate_d <= not(toggle_q xor toggle2x_q);






in32 : if regsize = 32 generate
   bdi         <= tidn(0 to 31) & di(32 to 63) & di(64 to 70) & tidn(71);
end generate;
in64 : if regsize = 64 generate
   bdi         <= di(0 to 71);
end generate;

bdo_d       <= std_ulogic_vector(bdo(64-regsize to 72-(64/regsize)));
do0         <= bdo_fq;

wea         <= (wr_act and gate_fq) after 10 ps;
web         <= (wr_act and gate_fq) after 10 ps;

with gate_fq select
   addra    <= ("00" & wr_adr  & '0') after 10 ps  when '1',
               ("00" & rd0_adr & '0') after 10 ps when others;

with gate_fq select
   addrb    <= ("00" & wr_adr  & '1') after 10 ps when '1',
               ("00" & rd0_adr & '1') after 10 ps when others;

bram0a : ramb16_s36_s36
-- pragma translate_off
generic map(
   sim_collision_check => "none")
-- pragma translate_on
port map(
                  clka  => clk2x,
	               clkb  => clk2x,
	               ssra  => sreset,
	               ssrb  => sreset,
	               addra => std_logic_vector(addra),
	               addrb => std_logic_vector(addrb),
	               dia   => std_logic_vector(bdi(00 to 31)),
	               dib   => std_logic_vector(bdi(32 to 63)),
	               dipa  => std_logic_vector(bdi(64 to 67)),
	               dipb  => std_logic_vector(bdi(68 to 71)),
                  doa   => bdo(00 to 31),
                  dob   => bdo(32 to 63),
                  dopa  => bdo(64 to 67),
                  dopb  => bdo(68 to 71),
	               ena   => '1',
	               enb   => '1',
	               wea   => wea,
	               web   => web
	               );
                  

abst_scan_out  <= abst_scan_in;
time_scan_out  <= time_scan_in;
repr_scan_out  <= repr_scan_in;

bo_pc_failout <= '0';
bo_pc_diagloop <= '0';

unused <= or_reduce( sg_0 & abst_sl_thold_0 & ary_nsl_thold_0 & time_sl_thold_0 & repr_sl_thold_0
                     & scan_dis_dc_b & scan_diag_dc & ccflush_dc
                     & clkoff_dc_b & d_mode_dc & mpw1_dc_b & mpw2_dc_b
                     & delay_lclkr_dc & abist_di
                     & abist_bw_odd & abist_bw_even & abist_wr_adr & abist_rd0_adr
                     & wr_abst_act & rd0_abst_act
                     & tc_lbist_ary_wrt_thru_dc & abist_ena_1 & abist_g8t_rd0_comp_ena
                     & abist_raw_dc_b & obs0_abist_cmp & rd0_act & tidn
                     & lcb_bolt_sl_thold_0 & pc_bo_enable_2 & pc_bo_reset
                     & pc_bo_unload & pc_bo_repair & pc_bo_shdata & pc_bo_select
                     & tri_lcb_mpw1_dc_b & tri_lcb_mpw2_dc_b & tri_lcb_delay_lclkr_dc
                     & tri_lcb_clkoff_dc_b & tri_lcb_act_dis_dc );


end generate;

end architecture tri_64x72_1r1w;




