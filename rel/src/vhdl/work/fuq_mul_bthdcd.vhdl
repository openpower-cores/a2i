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

entity fuq_mul_bthdcd is
  port(
    i0    : in  std_ulogic;
    i1    : in  std_ulogic;
    i2    : in  std_ulogic;
    s_neg : out std_ulogic;
    s_x   : out std_ulogic;
    s_x2  : out std_ulogic);





end fuq_mul_bthdcd;

architecture fuq_mul_bthdcd of fuq_mul_bthdcd is


 signal s_add    :std_ulogic;
 signal sx1_a0_b :std_ulogic; 
 signal sx1_a1_b :std_ulogic; 
 signal sx1_t    :std_ulogic; 
 signal sx1_i    :std_ulogic; 
 signal sx2_a0_b :std_ulogic; 
 signal sx2_a1_b :std_ulogic; 
 signal sx2_t    :std_ulogic; 
 signal sx2_i    :std_ulogic;
 signal i0_b, i1_b, i2_b :std_ulogic;









begin
-- i0:2      booth recode table
----------------------------------
-- 000  add  sh1=0 sh2=0  sub_adj=0
-- 001  add  sh1=1 sh2=0  sub_adj=0
-- 010  add  sh1=1 sh2=0  sub_adj=0
-- 011  add  sh1=0 sh2=1  sub_adj=0
-- 100  sub  sh1=0 sh2=1  sub_adj=1
-- 101  sub  sh1=1 sh2=0  sub_adj=1
-- 110  sub  sh1=1 sh2=0  sub_adj=1
-- 111  sub  sh1=0 sh2=0  sub_adj=0

-- logically correct
------------------------------------
--  s_neg <= (i0);
--  s_x   <= (       not i1 and     i2) or (           i1 and not i2);
--  s_x2  <= (i0 and not i1 and not i2) or (not i0 and i1 and     i2);


u_0i: i0_b <= not( i0 );
u_1i: i1_b <= not( i1 );
u_2i: i2_b <= not( i2 );


u_add: s_add <= not( i0 );
u_sub: s_neg <= not( s_add );

u_sx1_a0: sx1_a0_b <= not(          i1_b and i2   ) ;
u_sx1_a1: sx1_a1_b <= not(          i1   and i2_b ) ;
u_sx1_t:  sx1_t    <= not( sx1_a0_b and sx1_a1_b  ) ;   
u_sx1_i:  sx1_i    <= not( sx1_t );
u_sx1_ii: s_x      <= not( sx1_i );

u_sx2_a0: sx2_a0_b <= not( i0   and i1_b and i2_b ) ;
u_sx2_a1: sx2_a1_b <= not( i0_b and i1   and i2   ) ;
u_sx2_t:  sx2_t    <= not( sx2_a0_b and sx2_a1_b  ) ;   
u_sx2_i:  sx2_i    <= not( sx2_t );
u_sx2_ii: s_x2     <= not( sx2_i );

end;
