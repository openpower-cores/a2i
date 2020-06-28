-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;

entity xuq_lsu_data_st is
generic(expand_type     : integer := 2;         
        regmode         : integer := 6;                 
        l_endian_m      : integer := 1);        
port(

     ex2_stg_act                :in  std_ulogic;
     ex3_stg_act                :in  std_ulogic;
     rel2_stg_act               :in  std_ulogic;
     rel3_stg_act               :in  std_ulogic;
     rel2_ex2_stg_act           :in  std_ulogic;
     rel3_ex3_stg_act           :in  std_ulogic;

     rel_data_rot_sel           :in  std_ulogic;
     ldq_rel_rot_sel            :in  std_ulogic_vector(0 to 4);
     ldq_rel_op_size            :in  std_ulogic_vector(0 to 5);
     ldq_rel_le_mode            :in  std_ulogic;
     ldq_rel_algebraic          :in  std_ulogic;
     ldq_rel_data_val           :in  std_ulogic_vector(0 to 15);        
     rel_alg_bit                :in  std_ulogic;

     ex2_opsize                 :in  std_ulogic_vector(0 to 5);
     ex2_rot_sel                :in  std_ulogic_vector(0 to 4);
     ex2_rot_sel_le             :in  std_ulogic_vector(0 to 3);
     ex2_rot_addr               :in  std_ulogic_vector(1 to 5);
     ex4_le_mode_sel            :in  std_ulogic_vector(0 to 15);
     ex4_be_mode_sel            :in  std_ulogic_vector(0 to 15);

     rel_ex3_data               :in  std_ulogic_vector(0 to 255);
     rel_ex3_par_gen            :in  std_ulogic_vector(0 to 31);

     rel_256ld_data             :out std_ulogic_vector(0 to 255);
     rel_64ld_data              :out std_ulogic_vector(64-(2**regmode) to 63);
     rel_xu_ld_par              :out std_ulogic_vector(0 to 7);
     ex4_256st_data             :out std_ulogic_vector(0 to 255);
     ex3_byte_en                :out std_ulogic_vector(0 to 31);
     ex4_parity_gen             :out std_ulogic_vector(0 to 31);
     rel_axu_le_mode            :out std_ulogic;
     rel_dvc_byte_mask          :out std_ulogic_vector((64-(2**regmode))/8 to 7);

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_sl_thold_0_b          :in  std_ulogic;
     func_sl_force              :in  std_ulogic;
     func_nsl_thold_0_b         :in  std_ulogic;
     func_nsl_force             :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_in                    :in  std_ulogic;
     scan_out                   :out std_ulogic
   );
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_data_st;
architecture xuq_lsu_data_st of xuq_lsu_data_st is


constant ex3_byte_en_offset             :natural := 0;
constant rel_opsize_offset              :natural := ex3_byte_en_offset + 32;
constant rel_xu_le_mode_offset          :natural := rel_opsize_offset + 6;
constant rel_algebraic_offset           :natural := rel_xu_le_mode_offset + 1;
constant ex4_wrt_data_offset            :natural := rel_algebraic_offset + 1;
constant ex4_wrt_data_le_offset         :natural := ex4_wrt_data_offset + 256;
constant rel_256ld_data_offset          :natural := ex4_wrt_data_le_offset + 256;
constant rel_dvc_byte_mask_offset       :natural := rel_256ld_data_offset + 256;
constant ex4_parity_gen_offset          :natural := rel_dvc_byte_mask_offset + (2**regmode)/8;
constant ex4_parity_gen_le_offset       :natural := ex4_parity_gen_offset + 32;
constant my_spare_latches_offset        :natural := ex4_parity_gen_le_offset + 32;
constant scan_right                     :natural := my_spare_latches_offset + 12 - 1;

signal op_size                  :std_ulogic_vector(0 to 5);
signal op_sel                   :std_ulogic_vector(0 to 15);
signal be10_en                  :std_ulogic_vector(0 to 31);
signal beC840_en                :std_ulogic_vector(0 to 31);
signal be3210_en                :std_ulogic_vector(0 to 31);
signal byte_en                  :std_ulogic_vector(0 to 31);
signal ex3_byte_en_d            :std_ulogic_vector(0 to 31);
signal ex3_byte_en_q            :std_ulogic_vector(0 to 31);
signal rot_addr                 :std_ulogic_vector(1 to 5);
signal data256_rot              :std_ulogic_vector(0 to 255);
signal data256_rot_le           :std_ulogic_vector(0 to 255);
signal rot_sel                  :std_ulogic_vector(0 to 4);
signal rot_sel_le               :std_ulogic_vector(0 to 3);
signal rel_upd_gpr              :std_ulogic;
signal rel_rot_sel              :std_ulogic_vector(0 to 4);
signal rel_le_mode              :std_ulogic;
signal rel_opsize_d             :std_ulogic_vector(0 to 5);
signal rel_opsize_q             :std_ulogic_vector(0 to 5);
signal rel_xu_le_mode_d         :std_ulogic;
signal rel_xu_le_mode_q         :std_ulogic;
signal rel_xu_opsize            :std_ulogic_vector(0 to 5);
signal rel_xu_algebraic         :std_ulogic;
signal optype_mask              :std_ulogic_vector(0 to 255);
signal bittype_mask             :std_ulogic_vector(0 to 31);
signal rel_msk_data             :std_ulogic_vector(0 to 255);
signal rel_algebraic_d          :std_ulogic;
signal rel_algebraic_q          :std_ulogic;
signal lh_algebraic             :std_ulogic;
signal lw_algebraic             :std_ulogic;
signal lh_algebraic_msk         :std_ulogic_vector(0 to 47);
signal lw_algebraic_msk         :std_ulogic_vector(0 to 47);
signal algebraic_msk            :std_ulogic_vector(0 to 47);
signal algebraic_msk_data       :std_ulogic_vector(0 to 255);
signal rel_parity_gen           :std_ulogic_vector(0 to 7);
signal rel_xu_data              :std_ulogic_vector(0 to 255);
signal rotate_select            :std_ulogic_vector(0 to 4);
signal rotate_sel1              :std_ulogic_vector(0 to 3);
signal rotate_sel2              :std_ulogic_vector(0 to 3);
signal rotate_sel3              :std_ulogic_vector(0 to 3);
signal le_rotate_sel2           :std_ulogic_vector(0 to 3);
signal le_rotate_sel3           :std_ulogic_vector(0 to 3);
signal rel_xu_rot_sel1          :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel1_d        :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel1_q        :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel2          :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel2_d        :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel2_q        :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel3          :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel3_d        :std_ulogic_vector(0 to 63);
signal rel_xu_rot_sel3_q        :std_ulogic_vector(0 to 63);
signal le_xu_rot_sel2           :std_ulogic_vector(0 to 63);
signal le_xu_rot_sel2_d         :std_ulogic_vector(0 to 63);
signal le_xu_rot_sel2_q         :std_ulogic_vector(0 to 63);
signal le_xu_rot_sel3           :std_ulogic_vector(0 to 63);
signal le_xu_rot_sel3_d         :std_ulogic_vector(0 to 63);
signal le_xu_rot_sel3_q         :std_ulogic_vector(0 to 63);
signal le_mode_select           :std_ulogic;
signal reload_algbit            :std_ulogic;
signal lvl1_sel                 :std_ulogic_vector(0 to 1);
signal lvl2_sel                 :std_ulogic_vector(0 to 1);
signal lvl3_sel                 :std_ulogic_vector(0 to 1);
signal le_lvl2_sel              :std_ulogic_vector(0 to 1);
signal le_lvl3_sel              :std_ulogic_vector(0 to 1);
signal rel_xu_par_gen           :std_ulogic_vector(0 to 31);
signal pgrot3210                :std_ulogic_vector(0 to 31);
signal pgrotC840                :std_ulogic_vector(0 to 31);
signal pgrot10                  :std_ulogic_vector(0 to 31);
signal ex3_par_rot              :std_ulogic_vector(0 to 31);
signal rel_swzl_data            :std_ulogic_vector(0 to 255);
signal rel_val_data             :std_ulogic_vector(0 to 15);
signal ex3_parity_gen           :std_ulogic_vector(0 to 31);
signal ex4_parity_gen_d         :std_ulogic_vector(0 to 31);
signal ex4_parity_gen_q         :std_ulogic_vector(0 to 31);
signal ex4_parity_gen_le_d      :std_ulogic_vector(0 to 31);
signal ex4_parity_gen_le_q      :std_ulogic_vector(0 to 31);
signal rel_256ld_data_d         :std_ulogic_vector(0 to 255);
signal rel_256ld_data_q         :std_ulogic_vector(0 to 255);
signal ex3_wrt_data             :std_ulogic_vector(0 to 255);
signal ex4_wrt_data_d           :std_ulogic_vector(0 to 255);
signal ex4_wrt_data_q           :std_ulogic_vector(0 to 255);
signal ex4_wrt_data_le_d        :std_ulogic_vector(0 to 255);
signal ex4_wrt_data_le_q        :std_ulogic_vector(0 to 255);
signal le_xu_par_gen            :std_ulogic_vector(0 to 31);
signal le_pgrotC840             :std_ulogic_vector(0 to 31);
signal le_pgrot3210             :std_ulogic_vector(0 to 31);
signal ex3_par_rot_le           :std_ulogic_vector(0 to 31);
signal rel_byte_mask            :std_ulogic_vector(0 to 7);
signal rel_dvc_byte_mask_d      :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal rel_dvc_byte_mask_q      :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal my_spare0_lclk           :clk_logic;
signal my_spare0_d1clk          :std_ulogic;
signal my_spare0_d2clk          :std_ulogic;
signal my_spare_latches_d       :std_ulogic_vector(0 to 11);
signal my_spare_latches_q       :std_ulogic_vector(0 to 11);

signal tiup                     :std_ulogic;
signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);

begin

tiup <= '1';

rel_upd_gpr <= rel_data_rot_sel;

rel_opsize_d    <= ldq_rel_op_size;
rel_algebraic_d <= ldq_rel_algebraic;

rel_rot_sel <= ldq_rel_rot_sel;
rel_le_mode <= ldq_rel_le_mode;

op_size    <= ex2_opsize;
rot_sel    <= ex2_rot_sel;
rot_sel_le <= ex2_rot_sel_le;
rot_addr   <= ex2_rot_addr;

rel_xu_data    <= rel_ex3_data;
rel_xu_par_gen <= rel_ex3_par_gen;
reload_algbit  <= rel_alg_bit;

rel_val_data <= ldq_rel_data_val;

with rel_upd_gpr select
    rotate_select <=     rot_sel when '0',
                     rel_rot_sel when others;

with rel_upd_gpr select
    le_mode_select <=         '0' when '0',
                      rel_le_mode when others;

lvl1_sel <= le_mode_select & rotate_select(0);
lvl2_sel <= rotate_select(1 to 2);
lvl3_sel <= rotate_select(3 to 4);

with lvl1_sel select
    rotate_sel1 <= "1000" when "00",
                   "0100" when "01",
                   "0010" when "10",
                   "0001" when others;

with lvl2_sel select
    rotate_sel2 <= "1000" when "00",
                   "0100" when "01",
                   "0010" when "10",
                   "0001" when others;

with lvl3_sel select
    rotate_sel3 <= "1000" when "00",
                   "0100" when "01",
                   "0010" when "10",
                   "0001" when others;

rel_xu_le_mode_d  <= le_mode_select;

selGen : for sel in 0 to 15 generate begin
      rel_xu_rot_sel1_d(4*sel to (4*sel)+3) <= rotate_sel1;
      rel_xu_rot_sel2_d(4*sel to (4*sel)+3) <= rotate_sel2;
      rel_xu_rot_sel3_d(4*sel to (4*sel)+3) <= rotate_sel3;
end generate selGen;

rel_xu_rot_sel1  <= rel_xu_rot_sel1_q;
rel_xu_rot_sel2  <= rel_xu_rot_sel2_q;
rel_xu_rot_sel3  <= rel_xu_rot_sel3_q;
rel_xu_opsize    <= rel_opsize_q;
rel_xu_algebraic <= rel_algebraic_q;

le_lvl2_sel <= rot_sel_le(0 to 1);
le_lvl3_sel <= rot_sel_le(2 to 3);

with le_lvl2_sel select
    le_rotate_sel2 <= "1000" when "00",
                      "0100" when "01",
                      "0010" when "10",
                      "0001" when others;

with le_lvl3_sel select
    le_rotate_sel3 <= "1000" when "00",
                      "0100" when "01",
                      "0010" when "10",
                      "0001" when others;

leSelGen : for sel in 0 to 15 generate begin
      le_xu_rot_sel2_d(4*sel to (4*sel)+3) <= le_rotate_sel2;
      le_xu_rot_sel3_d(4*sel to (4*sel)+3) <= le_rotate_sel3;
end generate leSelGen;

le_xu_rot_sel2  <= le_xu_rot_sel2_q;
le_xu_rot_sel3  <= le_xu_rot_sel3_q;


pglvl1rot: for byte in 0 to 31 generate
signal muxIn    :std_ulogic_vector(0 to 3);
signal muxSel   :std_ulogic_vector(0 to 3);
begin
      muxIn  <= rel_xu_par_gen(byte)      & rel_xu_par_gen((16+byte) mod 32) &
                rel_xu_par_gen(31 - byte) & rel_xu_par_gen(31 - ((16+byte) mod 32));
      muxSel <= rel_xu_rot_sel1(4*(byte/16) to (4*(byte/16))+3);
         
      mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
        port map ( vdd => vdd,
                   gnd => gnd,
                   d0  => muxIn(0),
                   d1  => muxIn(1),
                   d2  => muxIn(2),
                   d3  => muxIn(3),
                   s0  => muxSel(0),
                   s1  => muxSel(1),
                   s2  => muxSel(2),
                   s3  => muxSel(3),
                    y  => pgrot10(byte));
end generate pglvl1rot;

pglvl2rot: for byte in 0 to 31 generate
signal muxIn    :std_ulogic_vector(0 to 3);
signal muxSel   :std_ulogic_vector(0 to 3);
begin
      muxIn  <= pgrot10(byte)            & pgrot10((4+byte) mod 32) &
                pgrot10((8+byte) mod 32) & pgrot10((12+byte) mod 32);
      muxSel <= rel_xu_rot_sel2(4*(byte/16) to (4*(byte/16))+3);
         
      mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
        port map (vdd => vdd,
                  gnd => gnd,
                  d0  => muxIn(0),
                  d1  => muxIn(1),
                  d2  => muxIn(2),
                  d3  => muxIn(3),
                  s0  => muxSel(0),
                  s1  => muxSel(1),
                  s2  => muxSel(2),
                  s3  => muxSel(3),
                   y  => pgrotC840(byte));
end generate pglvl2rot;

pglvl3rot: for byte in 0 to 31 generate
signal muxIn    :std_ulogic_vector(0 to 3);
signal muxSel   :std_ulogic_vector(0 to 3);
begin
      muxIn  <= pgrotC840(byte)            & pgrotC840((1+byte) mod 32) &
                pgrotC840((2+byte) mod 32) & pgrotC840((3+byte) mod 32);
      muxSel <= rel_xu_rot_sel3(4*(byte/16) to (4*(byte/16))+3);
         
      mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
        port map ( vdd => vdd,
                   gnd => gnd,
                   d0  => muxIn(0),
                   d1  => muxIn(1),
                   d2  => muxIn(2),
                   d3  => muxIn(3),
                   s0  => muxSel(0),
                   s1  => muxSel(1),
                   s2  => muxSel(2),
                   s3  => muxSel(3),
                    y  => pgrot3210(byte));
end generate pglvl3rot;

ex3_par_rot <= pgrot3210;


ParSwap : for bit in 0 to 31 generate begin
      le_xu_par_gen(bit) <= rel_xu_par_gen(31-bit);
end generate ParSwap;

lePglvl2rot: for byte in 0 to 31 generate
signal muxIn    :std_ulogic_vector(0 to 3);
signal muxSel   :std_ulogic_vector(0 to 3);
begin
      muxIn  <= le_xu_par_gen(byte)            & le_xu_par_gen((4+byte) mod 32) &
                le_xu_par_gen((8+byte) mod 32) & le_xu_par_gen((12+byte) mod 32);
      muxSel <= le_xu_rot_sel2(4*(byte/16) to (4*(byte/16))+3);
         
      mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
        port map (vdd => vdd,
                  gnd => gnd,
                  d0  => muxIn(0),
                  d1  => muxIn(1),
                  d2  => muxIn(2),
                  d3  => muxIn(3),
                  s0  => muxSel(0),
                  s1  => muxSel(1),
                  s2  => muxSel(2),
                  s3  => muxSel(3),
                   y  => le_pgrotC840(byte));
end generate lePglvl2rot;

lePglvl3rot: for byte in 0 to 31 generate
signal muxIn    :std_ulogic_vector(0 to 3);
signal muxSel   :std_ulogic_vector(0 to 3);
begin
      muxIn  <= le_pgrotC840(byte)            & le_pgrotC840((1+byte) mod 32) &
                le_pgrotC840((2+byte) mod 32) & le_pgrotC840((3+byte) mod 32);
      muxSel <= le_xu_rot_sel3(4*(byte/16) to (4*(byte/16))+3);
         
      mux4sel: entity work.xuq_lsu_mux41(xuq_lsu_mux41)
        port map ( vdd => vdd,
                   gnd => gnd,
                   d0  => muxIn(0),
                   d1  => muxIn(1),
                   d2  => muxIn(2),
                   d3  => muxIn(3),
                   s0  => muxSel(0),
                   s1  => muxSel(1),
                   s2  => muxSel(2),
                   s3  => muxSel(3),
                    y  => le_pgrot3210(byte));
end generate lePglvl3rot;

ex3_par_rot_le <= le_pgrot3210;


op_sel(0) <= op_size(1) or op_size(2) or op_size(3) or op_size(4) or op_size(5);
op_sel(1) <= op_size(1) or op_size(2) or op_size(3) or op_size(4);
op_sel(2) <= op_size(1) or op_size(2) or op_size(3);
op_sel(3) <= op_size(1) or op_size(2) or op_size(3);
op_sel(4) <= op_size(1) or op_size(2);
op_sel(5) <= op_size(1) or op_size(2);
op_sel(6) <= op_size(1) or op_size(2);
op_sel(7) <= op_size(1) or op_size(2);
op_sel(8) <= op_size(1);
op_sel(9) <= op_size(1);
op_sel(10) <= op_size(1);
op_sel(11) <= op_size(1);
op_sel(12) <= op_size(1);
op_sel(13) <= op_size(1);
op_sel(14) <= op_size(1);
op_sel(15) <= op_size(1);

with rot_addr(1) select
    be10_en <= op_sel(0 to 15) & x"0000" when '0',
               x"0000" & op_sel(0 to 15) when others;

with rot_addr(2 to 3) select
    beC840_en <=          be10_en(0 to 31) when "00",
                   x"0" & be10_en(0 to 27) when "01",
                  x"00" & be10_en(0 to 23) when "10",
                 x"000" & be10_en(0 to 19) when others;

with rot_addr(4 to 5) select
    be3210_en <=         beC840_en(0 to 31) when "00",
                   '0' & beC840_en(0 to 30) when "01",
                  "00" & beC840_en(0 to 29) when "10",
                 "000" & beC840_en(0 to 28) when others;

ben_gen : for t in 0 to 31 generate begin
      byte_en(t) <= op_size(0) or be3210_en(t);
end generate ben_gen;

ex3_byte_en_d <= byte_en;


l1dcrotl0 : entity work.xuq_lsu_data_rot32_lu(xuq_lsu_data_rot32_lu)
generic map(l_endian_m  => l_endian_m)
port map (

     vdd                        => vdd,
     gnd                        => gnd,

     rot_sel1                   => rel_xu_rot_sel1(0 to 31),
     rot_sel2                   => rel_xu_rot_sel2(0 to 31),
     rot_sel3                   => rel_xu_rot_sel3(0 to 31),
     rot_sel2_le                => le_xu_rot_sel2(0 to 31),
     rot_sel3_le                => le_xu_rot_sel3(0 to 31),
     rot_data                   => rel_xu_data(0 to 127),

     data256_rot_le             => data256_rot_le(0 to 127),
     data256_rot                => data256_rot(0 to 127)
);

l1dcrotl1 : entity work.xuq_lsu_data_rot32_lu(xuq_lsu_data_rot32_lu)
generic map(l_endian_m  => l_endian_m)
port map (

     vdd                        => vdd,
     gnd                        => gnd,

     rot_sel1                   => rel_xu_rot_sel1(32 to 63),
     rot_sel2                   => rel_xu_rot_sel2(32 to 63),
     rot_sel3                   => rel_xu_rot_sel3(32 to 63),
     rot_sel2_le                => le_xu_rot_sel2(32 to 63),
     rot_sel3_le                => le_xu_rot_sel3(32 to 63),
     rot_data                   => rel_xu_data(128 to 255),

     data256_rot_le             => data256_rot_le(128 to 255),
     data256_rot                => data256_rot(128 to 255)
);



with rel_xu_opsize(2 to 5) select
    rel_byte_mask <= x"01" when "0001",
                     x"03" when "0010",
                     x"0F" when "0100",
                     x"FF" when others;

rel_dvc_byte_mask_d <= rel_byte_mask((64-(2**regmode))/8 to 7);

with rel_xu_opsize select
    bittype_mask <= x"00000001" when "000001",
                    x"00000003" when "000010",
                    x"0000000F" when "000100",
                    x"000000FF" when "001000",
                    x"0000FFFF" when "010000",
                    x"FFFFFFFF" when others;

maskGen : for bit in 0 to 7 generate begin
      optype_mask(bit*32 to (bit*32)+31) <= bittype_mask;
end generate maskGen;

rel_msk_data <= data256_rot and optype_mask;

lh_algebraic     <= rel_xu_opsize(4) and rel_xu_algebraic;
lw_algebraic     <= rel_xu_opsize(3) and rel_xu_algebraic;
lh_algebraic_msk <= (0 to 47 => reload_algbit);
lw_algebraic_msk <= (0 to 31 => reload_algbit) & x"0000";
algebraic_msk    <= gate(lh_algebraic_msk,lh_algebraic) or gate(lw_algebraic_msk,lw_algebraic);

rel256data : for t in 0 to 31 generate begin      
      rel_swzl_data(t*8 to (t*8)+7) <= rel_msk_data(t)     & rel_msk_data(t+32)  & rel_msk_data(t+64)  & rel_msk_data(t+96) &
                                       rel_msk_data(t+128) & rel_msk_data(t+160) & rel_msk_data(t+192) & rel_msk_data(t+224);    
end generate rel256data;

algebraic_msk_data <= rel_swzl_data(0 to 191) & (rel_swzl_data(192 to 239) or algebraic_msk) & rel_swzl_data(240 to 255);
rel_256ld_data_d   <= algebraic_msk_data;


ex4_wrt_data_le_d   <= data256_rot_le;
ex4_parity_gen_le_d <= ex3_par_rot_le;

ex3_wrt_data   <= data256_rot;
ex3_parity_gen <= ex3_par_rot;

wrtData : for t in 0 to 7 generate begin
      ex4_wrt_data_d(t*32 to (t*32)+31) <= gate(rel_xu_data(t*32 to (t*32)+31),rel_val_data(t)) or gate(ex3_wrt_data(t*32 to (t*32)+31),rel_val_data(t+8));      
end generate wrtData;

wrtPar : for t in 0 to 31 generate begin
      ex4_parity_gen_d(t) <= (rel_xu_par_gen(t) and rel_val_data(t mod 8)) or (ex3_parity_gen(t) and rel_val_data((t mod 8)+8));
end generate wrtPar;

leSel : for t in 0 to 15 generate begin 
      ex4_256st_data(t*16 to (t*16)+15) <= gate(ex4_wrt_data_le_q(t*16 to (t*16)+15), ex4_le_mode_sel(t)) or gate(ex4_wrt_data_q(t*16 to (t*16)+15), ex4_be_mode_sel(t));
      ex4_parity_gen(t*2 to (t*2)+1)    <= gate(ex4_parity_gen_le_q(t*2 to (t*2)+1),  ex4_le_mode_sel(t)) or gate(ex4_parity_gen_q(t*2 to (t*2)+1),  ex4_be_mode_sel(t));
end generate leSel;

relpar_gen : for t in 0 to 7 generate begin
      R0 : if (t < (2**regmode)/8) generate begin
            rel_parity_gen(t) <= xor_reduce(rel_256ld_data_q((t*8)+256-(2**regmode) to (t*8)+256-(2**regmode)+7));
      end generate;
      R1 : if( t >= (2**regmode)/8) generate begin rel_parity_gen(t) <= '0'; end generate;
end generate relpar_gen;

my_spare_latches_d     <= not my_spare_latches_q;

ex3_byte_en       <= ex3_byte_en_q;
rel_256ld_data    <= rel_256ld_data_q;
rel_64ld_data     <= rel_256ld_data_q(256-(2**regmode) to 255);
rel_xu_ld_par     <= rel_parity_gen;
rel_axu_le_mode   <= rel_xu_le_mode_q;
rel_dvc_byte_mask <= rel_dvc_byte_mask_q;



ex3_byte_en_reg: tri_rlmreg_p
  generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_byte_en_offset to ex3_byte_en_offset + ex3_byte_en_d'length-1),
            scout   => sov(ex3_byte_en_offset to ex3_byte_en_offset + ex3_byte_en_d'length-1),
            din     => ex3_byte_en_d,
            dout    => ex3_byte_en_q);

rel_opsize_reg: tri_rlmreg_p
  generic map (width => 6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_opsize_offset to rel_opsize_offset + rel_opsize_d'length-1),
            scout   => sov(rel_opsize_offset to rel_opsize_offset + rel_opsize_d'length-1),
            din     => rel_opsize_d,
            dout    => rel_opsize_q);

rel_xu_le_mode_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_xu_le_mode_offset),
            scout   => sov(rel_xu_le_mode_offset),
            din     => rel_xu_le_mode_d,
            dout    => rel_xu_le_mode_q);

rel_algebraic_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_algebraic_offset),
            scout   => sov(rel_algebraic_offset),
            din     => rel_algebraic_d,
            dout    => rel_algebraic_q);

ex4_wrt_data_reg: tri_rlmreg_p
  generic map (width => 256, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_wrt_data_offset to ex4_wrt_data_offset + ex4_wrt_data_d'length-1),
            scout   => sov(ex4_wrt_data_offset to ex4_wrt_data_offset + ex4_wrt_data_d'length-1),
            din     => ex4_wrt_data_d,
            dout    => ex4_wrt_data_q);

ex4_wrt_data_le_reg: tri_rlmreg_p
  generic map (width => 256, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_wrt_data_le_offset to ex4_wrt_data_le_offset + ex4_wrt_data_le_d'length-1),
            scout   => sov(ex4_wrt_data_le_offset to ex4_wrt_data_le_offset + ex4_wrt_data_le_d'length-1),
            din     => ex4_wrt_data_le_d,
            dout    => ex4_wrt_data_le_q);

rel_256ld_data_reg: tri_rlmreg_p
  generic map (width => 256, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_256ld_data_offset to rel_256ld_data_offset + rel_256ld_data_d'length-1),
            scout   => sov(rel_256ld_data_offset to rel_256ld_data_offset + rel_256ld_data_d'length-1),
            din     => rel_256ld_data_d,
            dout    => rel_256ld_data_q);

rel_dvc_byte_mask_reg: tri_rlmreg_p
  generic map (width => (2**regmode)/8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_dvc_byte_mask_offset to rel_dvc_byte_mask_offset + rel_dvc_byte_mask_d'length-1),
            scout   => sov(rel_dvc_byte_mask_offset to rel_dvc_byte_mask_offset + rel_dvc_byte_mask_d'length-1),
            din     => rel_dvc_byte_mask_d,
            dout    => rel_dvc_byte_mask_q);

ex4_parity_gen_reg: tri_rlmreg_p
  generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_parity_gen_offset to ex4_parity_gen_offset + ex4_parity_gen_d'length-1),
            scout   => sov(ex4_parity_gen_offset to ex4_parity_gen_offset + ex4_parity_gen_d'length-1),
            din     => ex4_parity_gen_d,
            dout    => ex4_parity_gen_q);

ex4_parity_gen_le_reg: tri_rlmreg_p
  generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_parity_gen_le_offset to ex4_parity_gen_le_offset + ex4_parity_gen_le_d'length-1),
            scout   => sov(ex4_parity_gen_le_offset to ex4_parity_gen_le_offset + ex4_parity_gen_le_d'length-1),
            din     => ex4_parity_gen_le_d,
            dout    => ex4_parity_gen_le_q);

my_spare0_lcb : entity tri.tri_lcbnd(tri_lcbnd)
generic map (expand_type => expand_type)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            lclk    => my_spare0_lclk);
my_spare_latches_reg: entity tri.tri_inv_nlats(tri_inv_nlats)
generic map (width => 12, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            lclk    => my_spare0_lclk,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            scanin  => siv(my_spare_latches_offset to  my_spare_latches_offset + my_spare_latches_d'length-1),
            scanout => sov(my_spare_latches_offset to  my_spare_latches_offset + my_spare_latches_d'length-1),
            d       => my_spare_latches_d,
            qb      => my_spare_latches_q);


rel_xu_rot_sel1_0reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_xu_rot_sel1_d(0 to 31),
            dout    => rel_xu_rot_sel1_q(0 to 31));

rel_xu_rot_sel1_1reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_xu_rot_sel1_d(32 to 63),
            dout    => rel_xu_rot_sel1_q(32 to 63));

rel_xu_rot_sel2_0reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_xu_rot_sel2_d(0 to 31),
            dout    => rel_xu_rot_sel2_q(0 to 31));

rel_xu_rot_sel2_1reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_xu_rot_sel2_d(32 to 63),
            dout    => rel_xu_rot_sel2_q(32 to 63));

rel_xu_rot_sel3_0reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_xu_rot_sel3_d(0 to 31),
            dout    => rel_xu_rot_sel3_q(0 to 31));

rel_xu_rot_sel3_1reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_xu_rot_sel3_d(32 to 63),
            dout    => rel_xu_rot_sel3_q(32 to 63));

le_xu_rot_sel2_0reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => le_xu_rot_sel2_d(0 to 31),
            dout    => le_xu_rot_sel2_q(0 to 31));

le_xu_rot_sel2_1reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => le_xu_rot_sel2_d(32 to 63),
            dout    => le_xu_rot_sel2_q(32 to 63));

le_xu_rot_sel3_0reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => le_xu_rot_sel3_d(0 to 31),
            dout    => le_xu_rot_sel3_q(0 to 31));

le_xu_rot_sel3_1reg: tri_regk
  generic map (width => 32, init => 286331153, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => le_xu_rot_sel3_d(32 to 63),
            dout    => le_xu_rot_sel3_q(32 to 63));

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);

end xuq_lsu_data_st;

