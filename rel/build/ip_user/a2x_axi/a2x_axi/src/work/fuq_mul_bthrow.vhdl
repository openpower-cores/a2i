-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


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
    s_neg   : in  std_ulogic;                  
    s_x     : in  std_ulogic;                  
    s_x2    : in  std_ulogic;                  
    hot_one : out std_ulogic;                  
    q       : out std_ulogic_vector(0 to 54)); 


end fuq_mul_bthrow;  

architecture fuq_mul_bthrow of fuq_mul_bthrow is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

  signal left     : std_ulogic_vector(0 to 54);
  signal unused   : std_ulogic;





begin

 unused <= left(0) ; 

  u00 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => tidn ,  
      RIGHT => left(1) ,  
      LEFT  => left(0) ,  
      Q     => q(0));  

  u01 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(0) ,  
      RIGHT => left(2) ,  
      LEFT  => left(1) ,  
      Q     => q(1));  

  u02 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(1) ,  
      RIGHT => left(3) ,  
      LEFT  => left(2) ,  
      Q     => q(2));  

  u03 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(2) ,  
      RIGHT => left(4) ,  
      LEFT  => left(3) ,  
      Q     => q(3));  

  u04 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(3) ,  
      RIGHT => left(5) ,  
      LEFT  => left(4) ,  
      Q     => q(4));  

  u05 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(4) ,  
      RIGHT => left(6) ,  
      LEFT  => left(5) ,  
      Q     => q(5));  

  u06 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(5) ,  
      RIGHT => left(7) ,  
      LEFT  => left(6) ,  
      Q     => q(6));  

  u07 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(6) ,  
      RIGHT => left(8) ,  
      LEFT  => left(7) ,  
      Q     => q(7));  

  u08 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(7) ,  
      RIGHT => left(9) ,  
      LEFT  => left(8) ,  
      Q     => q(8));  

  u09 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(8) ,  
      RIGHT => left(10) ,  
      LEFT  => left(9) ,  
      Q     => q(9));  

  u10 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(9) ,  
      RIGHT => left(11) ,  
      LEFT  => left(10) ,  
      Q     => q(10));  

  u11 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(10) ,  
      RIGHT => left(12) ,  
      LEFT  => left(11) ,  
      Q     => q(11));  

  u12 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(11) ,  
      RIGHT => left(13) ,  
      LEFT  => left(12) ,  
      Q     => q(12));  

  u13 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(12) ,  
      RIGHT => left(14) ,  
      LEFT  => left(13) ,  
      Q     => q(13));  

  u14 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(13) ,  
      RIGHT => left(15) ,  
      LEFT  => left(14) ,  
      Q     => q(14));  

  u15 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(14) ,  
      RIGHT => left(16) ,  
      LEFT  => left(15) ,  
      Q     => q(15));  

  u16 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(15) ,  
      RIGHT => left(17) ,  
      LEFT  => left(16) ,  
      Q     => q(16));  

  u17 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(16) ,  
      RIGHT => left(18) ,  
      LEFT  => left(17) ,  
      Q     => q(17));  

  u18 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(17) ,  
      RIGHT => left(19) ,  
      LEFT  => left(18) ,  
      Q     => q(18));  

  u19 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(18) ,  
      RIGHT => left(20) ,  
      LEFT  => left(19) ,  
      Q     => q(19));  

  u20 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(19) ,  
      RIGHT => left(21) ,  
      LEFT  => left(20) ,  
      Q     => q(20));  

  u21 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(20) ,  
      RIGHT => left(22) ,  
      LEFT  => left(21) ,  
      Q     => q(21));  

  u22 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(21) ,  
      RIGHT => left(23) ,  
      LEFT  => left(22) ,  
      Q     => q(22));  

  u23 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(22) ,  
      RIGHT => left(24) ,  
      LEFT  => left(23) ,  
      Q     => q(23));  

  u24 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(23) ,  
      RIGHT => left(25) ,  
      LEFT  => left(24) ,  
      Q     => q(24));  

  u25 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(24) ,  
      RIGHT => left(26) ,  
      LEFT  => left(25) ,  
      Q     => q(25));  

  u26 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(25) ,  
      RIGHT => left(27) ,  
      LEFT  => left(26) ,  
      Q     => q(26));  

  u27 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(26) ,  
      RIGHT => left(28) ,  
      LEFT  => left(27) ,  
      Q     => q(27));  

  u28 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(27) ,  
      RIGHT => left(29) ,  
      LEFT  => left(28) ,  
      Q     => q(28));  

  u29 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(28) ,  
      RIGHT => left(30) ,  
      LEFT  => left(29) ,  
      Q     => q(29));  

  u30 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(29) ,  
      RIGHT => left(31) ,  
      LEFT  => left(30) ,  
      Q     => q(30));  

  u31 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(30) ,  
      RIGHT => left(32) ,  
      LEFT  => left(31) ,  
      Q     => q(31));  

  u32 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(31) ,  
      RIGHT => left(33) ,  
      LEFT  => left(32) ,  
      Q     => q(32));  

  u33 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(32) ,  
      RIGHT => left(34) ,  
      LEFT  => left(33) ,  
      Q     => q(33));  

  u34 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(33) ,  
      RIGHT => left(35) ,  
      LEFT  => left(34) ,  
      Q     => q(34));  

  u35 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(34) ,  
      RIGHT => left(36) ,  
      LEFT  => left(35) ,  
      Q     => q(35));  

  u36 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(35) ,  
      RIGHT => left(37) ,  
      LEFT  => left(36) ,  
      Q     => q(36));  

  u37 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(36) ,  
      RIGHT => left(38) ,  
      LEFT  => left(37) ,  
      Q     => q(37));  

  u38 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(37) ,  
      RIGHT => left(39) ,  
      LEFT  => left(38) ,  
      Q     => q(38));  

  u39 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(38) ,  
      RIGHT => left(40) ,  
      LEFT  => left(39) ,  
      Q     => q(39));  

  u40 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(39) ,  
      RIGHT => left(41) ,  
      LEFT  => left(40) ,  
      Q     => q(40));  

  u41 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(40) ,  
      RIGHT => left(42) ,  
      LEFT  => left(41) ,  
      Q     => q(41));  

  u42 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(41) ,  
      RIGHT => left(43) ,  
      LEFT  => left(42) ,  
      Q     => q(42));  

  u43 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(42) ,  
      RIGHT => left(44) ,  
      LEFT  => left(43) ,  
      Q     => q(43));  

  u44 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(43) ,  
      RIGHT => left(45) ,  
      LEFT  => left(44) ,  
      Q     => q(44));  

  u45 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(44) ,  
      RIGHT => left(46) ,  
      LEFT  => left(45) ,  
      Q     => q(45));  

  u46 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(45) ,  
      RIGHT => left(47) ,  
      LEFT  => left(46) ,  
      Q     => q(46));  

  u47 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(46) ,  
      RIGHT => left(48) ,  
      LEFT  => left(47) ,  
      Q     => q(47));  

  u48 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(47) ,  
      RIGHT => left(49) ,  
      LEFT  => left(48) ,  
      Q     => q(48));  

  u49 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(48) ,  
      RIGHT => left(50) ,  
      LEFT  => left(49) ,  
      Q     => q(49));  

  u50 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(49) ,  
      RIGHT => left(51) ,  
      LEFT  => left(50) ,  
      Q     => q(50));  

  u51 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(50) ,  
      RIGHT => left(52) ,  
      LEFT  => left(51) ,  
      Q     => q(51));  

  u52 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(51) ,  
      RIGHT => left(53) ,  
      LEFT  => left(52) ,  
      Q     => q(52));  

  u53 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(52) ,  
      RIGHT => left(54) ,  
      LEFT  => left(53) ,  
      Q     => q(53));  

  u54 : entity work.fuq_mul_bthmux(fuq_mul_bthmux)     port map(
      SNEG  => s_neg ,  
      SX    => s_x ,  
      SX2   => s_x2 ,  
      X     => x(53) ,  
      RIGHT => s_neg ,  
      LEFT  => left(54) ,  
      Q     => q(54));  



  u55: hot_one <=    ( s_neg and (s_x or s_x2) );

end;  










