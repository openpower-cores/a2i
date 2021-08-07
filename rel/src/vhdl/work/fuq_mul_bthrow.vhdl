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


library ieee;
use ieee.std_logic_1164.all;
library ibm;

use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_ao_support.all;
use ibm.std_ulogic_mux_support.all;


entity fuq_mul_bthrow is
  port(
    x       : in  std_ulogic_vector(0 to 53);
    s_neg   : in  std_ulogic;                  -- negate the row
    s_x     : in  std_ulogic;                  -- shift by 1
    s_x2    : in  std_ulogic;                  -- shift by 2
    hot_one : out std_ulogic;                  -- lsb term for row below
    q       : out std_ulogic_vector(0 to 54)); -- final output


end fuq_mul_bthrow;  -- ENTITY

architecture fuq_mul_bthrow of fuq_mul_bthrow is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

  signal left     : std_ulogic_vector(0 to 54);
  signal unused   : std_ulogic;





begin

 unused <= left(0) ; -- dangling pin from edge bit

--//###############################################################
--# A row of the repeated part of the booth_mux row
--//###############################################################
  u00 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => tidn ,  --i--  ********
      RIGHT => left(1) ,  --i--  [n+1]
      LEFT  => left(0) ,  --o--  [n]
      Q     => q(0));  --o--

  u01 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(0) ,  --i--  [n-1]
      RIGHT => left(2) ,  --i--  [n+1]
      LEFT  => left(1) ,  --o--  [n]
      Q     => q(1));  --o--

  u02 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(1) ,  --i--
      RIGHT => left(3) ,  --i--
      LEFT  => left(2) ,  --o--
      Q     => q(2));  --o--

  u03 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(2) ,  --i--
      RIGHT => left(4) ,  --i--
      LEFT  => left(3) ,  --o--
      Q     => q(3));  --o--

  u04 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(3) ,  --i--
      RIGHT => left(5) ,  --i--
      LEFT  => left(4) ,  --o--
      Q     => q(4));  --o--

  u05 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(4) ,  --i--
      RIGHT => left(6) ,  --i--
      LEFT  => left(5) ,  --o--
      Q     => q(5));  --o--

  u06 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(5) ,  --i--
      RIGHT => left(7) ,  --i--
      LEFT  => left(6) ,  --o--
      Q     => q(6));  --o--

  u07 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(6) ,  --i--
      RIGHT => left(8) ,  --i--
      LEFT  => left(7) ,  --o--
      Q     => q(7));  --o--

  u08 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(7) ,  --i--
      RIGHT => left(9) ,  --i--
      LEFT  => left(8) ,  --o--
      Q     => q(8));  --o--

  u09 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(8) ,  --i--
      RIGHT => left(10) ,  --i--
      LEFT  => left(9) ,  --o--
      Q     => q(9));  --o--

  u10 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(9) ,  --i--
      RIGHT => left(11) ,  --i--
      LEFT  => left(10) ,  --o--
      Q     => q(10));  --o--

  u11 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(10) ,  --i--
      RIGHT => left(12) ,  --i--
      LEFT  => left(11) ,  --o--
      Q     => q(11));  --o--

  u12 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(11) ,  --i--
      RIGHT => left(13) ,  --i--
      LEFT  => left(12) ,  --o--
      Q     => q(12));  --o--

  u13 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(12) ,  --i--
      RIGHT => left(14) ,  --i--
      LEFT  => left(13) ,  --o--
      Q     => q(13));  --o--

  u14 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(13) ,  --i--
      RIGHT => left(15) ,  --i--
      LEFT  => left(14) ,  --o--
      Q     => q(14));  --o--

  u15 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(14) ,  --i--
      RIGHT => left(16) ,  --i--
      LEFT  => left(15) ,  --o--
      Q     => q(15));  --o--

  u16 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(15) ,  --i--
      RIGHT => left(17) ,  --i--
      LEFT  => left(16) ,  --o--
      Q     => q(16));  --o--

  u17 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(16) ,  --i--
      RIGHT => left(18) ,  --i--
      LEFT  => left(17) ,  --o--
      Q     => q(17));  --o--

  u18 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(17) ,  --i--
      RIGHT => left(19) ,  --i--
      LEFT  => left(18) ,  --o--
      Q     => q(18));  --o--

  u19 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(18) ,  --i--
      RIGHT => left(20) ,  --i--
      LEFT  => left(19) ,  --o--
      Q     => q(19));  --o--

  u20 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(19) ,  --i--
      RIGHT => left(21) ,  --i--
      LEFT  => left(20) ,  --o--
      Q     => q(20));  --o--

  u21 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(20) ,  --i--
      RIGHT => left(22) ,  --i--
      LEFT  => left(21) ,  --o--
      Q     => q(21));  --o--

  u22 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(21) ,  --i--
      RIGHT => left(23) ,  --i--
      LEFT  => left(22) ,  --o--
      Q     => q(22));  --o--

  u23 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(22) ,  --i--
      RIGHT => left(24) ,  --i--
      LEFT  => left(23) ,  --o--
      Q     => q(23));  --o--

  u24 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(23) ,  --i--
      RIGHT => left(25) ,  --i--
      LEFT  => left(24) ,  --o--
      Q     => q(24));  --o--

  u25 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(24) ,  --i--
      RIGHT => left(26) ,  --i--
      LEFT  => left(25) ,  --o--
      Q     => q(25));  --o--

  u26 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(25) ,  --i--
      RIGHT => left(27) ,  --i--
      LEFT  => left(26) ,  --o--
      Q     => q(26));  --o--

  u27 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(26) ,  --i--
      RIGHT => left(28) ,  --i--
      LEFT  => left(27) ,  --o--
      Q     => q(27));  --o--

  u28 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(27) ,  --i--
      RIGHT => left(29) ,  --i--
      LEFT  => left(28) ,  --o--
      Q     => q(28));  --o--

  u29 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(28) ,  --i--
      RIGHT => left(30) ,  --i--
      LEFT  => left(29) ,  --o--
      Q     => q(29));  --o--

  u30 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(29) ,  --i--
      RIGHT => left(31) ,  --i--
      LEFT  => left(30) ,  --o--
      Q     => q(30));  --o--

  u31 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(30) ,  --i--
      RIGHT => left(32) ,  --i--
      LEFT  => left(31) ,  --o--
      Q     => q(31));  --o--

  u32 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(31) ,  --i--
      RIGHT => left(33) ,  --i--
      LEFT  => left(32) ,  --o--
      Q     => q(32));  --o--

  u33 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(32) ,  --i--
      RIGHT => left(34) ,  --i--
      LEFT  => left(33) ,  --o--
      Q     => q(33));  --o--

  u34 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(33) ,  --i--
      RIGHT => left(35) ,  --i--
      LEFT  => left(34) ,  --o--
      Q     => q(34));  --o--

  u35 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(34) ,  --i--
      RIGHT => left(36) ,  --i--
      LEFT  => left(35) ,  --o--
      Q     => q(35));  --o--

  u36 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(35) ,  --i--
      RIGHT => left(37) ,  --i--
      LEFT  => left(36) ,  --o--
      Q     => q(36));  --o--

  u37 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(36) ,  --i--
      RIGHT => left(38) ,  --i--
      LEFT  => left(37) ,  --o--
      Q     => q(37));  --o--

  u38 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(37) ,  --i--
      RIGHT => left(39) ,  --i--
      LEFT  => left(38) ,  --o--
      Q     => q(38));  --o--

  u39 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(38) ,  --i--
      RIGHT => left(40) ,  --i--
      LEFT  => left(39) ,  --o--
      Q     => q(39));  --o--

  u40 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(39) ,  --i--
      RIGHT => left(41) ,  --i--
      LEFT  => left(40) ,  --o--
      Q     => q(40));  --o--

  u41 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(40) ,  --i--
      RIGHT => left(42) ,  --i--
      LEFT  => left(41) ,  --o--
      Q     => q(41));  --o--

  u42 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(41) ,  --i--
      RIGHT => left(43) ,  --i--
      LEFT  => left(42) ,  --o--
      Q     => q(42));  --o--

  u43 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(42) ,  --i--
      RIGHT => left(44) ,  --i--
      LEFT  => left(43) ,  --o--
      Q     => q(43));  --o--

  u44 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(43) ,  --i--
      RIGHT => left(45) ,  --i--
      LEFT  => left(44) ,  --o--
      Q     => q(44));  --o--

  u45 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(44) ,  --i--
      RIGHT => left(46) ,  --i--
      LEFT  => left(45) ,  --o--
      Q     => q(45));  --o--

  u46 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(45) ,  --i--
      RIGHT => left(47) ,  --i--
      LEFT  => left(46) ,  --o--
      Q     => q(46));  --o--

  u47 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(46) ,  --i--
      RIGHT => left(48) ,  --i--
      LEFT  => left(47) ,  --o--
      Q     => q(47));  --o--

  u48 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(47) ,  --i--
      RIGHT => left(49) ,  --i--
      LEFT  => left(48) ,  --o--
      Q     => q(48));  --o--

  u49 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(48) ,  --i--
      RIGHT => left(50) ,  --i--
      LEFT  => left(49) ,  --o--
      Q     => q(49));  --o--

  u50 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(49) ,  --i--
      RIGHT => left(51) ,  --i--
      LEFT  => left(50) ,  --o--
      Q     => q(50));  --o--

  u51 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(50) ,  --i--
      RIGHT => left(52) ,  --i--
      LEFT  => left(51) ,  --o--
      Q     => q(51));  --o--

  u52 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(51) ,  --i--
      RIGHT => left(53) ,  --i--
      LEFT  => left(52) ,  --o--
      Q     => q(52));  --o--

  u53 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(52) ,  --i--
      RIGHT => left(54) ,  --i--
      LEFT  => left(53) ,  --o--
      Q     => q(53));  --o--

  u54 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  --i--
      SX    => s_x ,  --i--
      SX2   => s_x2 ,  --i--
      X     => x(53) ,  --i--
      RIGHT => s_neg ,  --i--
      LEFT  => left(54) ,  --o--
      Q     => q(54));  --o--

  -- For negate -A = !A + 1 ... this term is the plus 1.
  -- this has same bit weight as LSB, so it jumps down a row to free spot in compressor tree.

  u55: hot_one <=    ( s_neg and (s_x or s_x2) );

end;  -- fuq_mul_bthrow ARCHITECTURE
