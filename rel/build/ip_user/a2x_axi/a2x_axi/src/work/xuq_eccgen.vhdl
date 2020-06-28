-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,ibm,support;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;

entity xuq_eccgen is 
generic(
   regsize                 :     integer := 64);
port(
   din                     : in  std_ulogic_vector(0 to regsize+8-(64/regsize));
   Syn                     : out std_ulogic_vector(0 to 8-(64/regsize))
   );

--  synopsys translate_off
--  synopsys translate_on

end xuq_eccgen;
architecture xuq_eccgen of xuq_eccgen is 
begin
ecc64 : if regsize = 64 generate

   signal e                   : std_ulogic_vector(0 to 71); 
   signal l1term              : std_ulogic_vector(0 to 22);

   begin


   e(0 to 71)  <= din(0 to 71);

   l1term(0)   <= parity_map(e(0)&e(10)&e(17)&e(21)&e(32)&e(36)&e(44)&e(56));
   l1term(1)   <= parity_map(e(22)&e(23)&e(24)&e(25)&e(53)&e(54)&e(55)&e(56));
   l1term(2)   <= parity_map(e(1)&e(4)&e(11)&e(23)&e(26)&e(38)&e(46)&e(50));
   l1term(3)   <= parity_map(e(2)&e(5)&e(12)&e(24)&e(27)&e(39)&e(47)&e(51));
   l1term(4)   <= parity_map(e(3)&e(6)&e(13)&e(25)&e(28)&e(40)&e(48)&e(52));
   l1term(5)   <= parity_map(e(7)&e(8)&e(9)&e(10)&e(37)&e(38)&e(39)&e(40));
   l1term(6)   <= parity_map(e(14)&e(15)&e(16)&e(17)&e(45)&e(46)&e(47)&e(48));
   l1term(7)   <= parity_map(e(18)&e(19)&e(20)&e(21)&e(49)&e(50)&e(51)&e(52));
   l1term(8)   <= parity_map(e(7)&e(14)&e(18)&e(29)&e(33)&e(41)&e(53)&e(57));
   l1term(9)   <= parity_map(e(58)&e(60)&e(63)&e(64));
   l1term(10)  <= parity_map(e(8)&e(15)&e(19)&e(30)&e(34)&e(42)&e(54)&e(57));
   l1term(11)  <= parity_map(e(59)&e(61)&e(63)&e(65));
   l1term(12)  <= parity_map(e(9)&e(16)&e(20)&e(31)&e(35)&e(43)&e(55)&e(58));
   l1term(13)  <= parity_map(e(59)&e(62)&e(63)&e(66));
   l1term(14)  <= parity_map(e(1)&e(2)&e(3)&e(29)&e(30)&e(31)&e(32)&e(60));
   l1term(15)  <= parity_map(e(61)&e(62)&e(63)&e(67));
   l1term(16)  <= parity_map(e(4)&e(5)&e(6)&e(33)&e(34)&e(35)&e(36)&e(68));
   l1term(17)  <= parity_map(e(11)&e(12)&e(13)&e(41)&e(42)&e(43)&e(44)&e(69));
   l1term(18)  <= parity_map(e(26)&e(27)&e(28)&e(29)&e(30)&e(31)&e(32)&e(33));
   l1term(19)  <= parity_map(e(34)&e(35)&e(36)&e(37)&e(38)&e(39)&e(40)&e(41));
   l1term(20)  <= parity_map(e(42)&e(43)&e(44)&e(45)&e(46)&e(47)&e(48)&e(49));
   l1term(21)  <= parity_map(e(50)&e(51)&e(52)&e(53)&e(54)&e(55)&e(56)&e(70));
   l1term(22)  <= parity_map(e(57)&e(58)&e(59)&e(60)&e(61)&e(62)&e(63)&e(71));
   Syn(0)      <= parity_map(l1term(0)&l1term(2)&l1term(3)&l1term(8)&l1term(9));
   Syn(1)      <= parity_map(l1term(0)&l1term(2)&l1term(4)&l1term(10)&l1term(11));
   Syn(2)      <= parity_map(l1term(0)&l1term(3)&l1term(4)&l1term(12)&l1term(13));
   Syn(3)      <= parity_map(l1term(1)&l1term(5)&l1term(6)&l1term(14)&l1term(15));
   Syn(4)      <= parity_map(l1term(1)&l1term(5)&l1term(7)&l1term(16));
   Syn(5)      <= parity_map(l1term(1)&l1term(6)&l1term(7)&l1term(17));
   Syn(6)      <= parity_map(l1term(18)&l1term(19)&l1term(20)&l1term(21));
   Syn(7)      <= l1term(22);

end generate;
ecc32 : if regsize = 32 generate

   signal e                   : std_ulogic_vector(0 to 38); 
   signal l1term              : std_ulogic_vector(0 to 13);

   begin


   e(0 to 38) <= din(0 to 38);

   l1term(0)   <= parity_map(e(0)&e(1)&e(4)&e(10)&e(11)&e(17)&e(21)&e(23));
   l1term(1)   <= parity_map(e(2)&e(3)&e(9)&e(10)&e(16)&e(17)&e(24)&e(25));
   l1term(2)   <= parity_map(e(18)&e(19)&e(20)&e(21)&e(22)&e(23)&e(24)&e(25));
   l1term(3)   <= parity_map(e(2)&e(5)&e(7)&e(12)&e(14)&e(18)&e(24)&e(26));
   l1term(4)   <= parity_map(e(27)&e(29)&e(32));
   l1term(5)   <= parity_map(e(3)&e(6)&e(8)&e(13)&e(15)&e(19)&e(25)&e(26));
   l1term(6)   <= parity_map(e(28)&e(30)&e(33));
   l1term(7)   <= parity_map(e(0)&e(5)&e(6)&e(12)&e(13)&e(20)&e(21)&e(27));
   l1term(8)   <= parity_map(e(28)&e(31)&e(34));
   l1term(9)   <= parity_map(e(1)&e(7)&e(8)&e(14)&e(15)&e(22)&e(23)&e(29));
   l1term(10)  <= parity_map(e(30)&e(31)&e(35));
   l1term(11)  <= parity_map(e(4)&e(5)&e(6)&e(7)&e(8)&e(9)&e(10)&e(36));
   l1term(12)  <= parity_map(e(11)&e(12)&e(13)&e(14)&e(15)&e(16)&e(17)&e(37));
   l1term(13)  <= parity_map(e(26)&e(27)&e(28)&e(29)&e(30)&e(31)&e(38));
   Syn(0)      <= parity_map(l1term(0)&l1term(3)&l1term(4));
   Syn(1)      <= parity_map(l1term(0)&l1term(5)&l1term(6));
   Syn(2)      <= parity_map(l1term(1)&l1term(7)&l1term(8));
   Syn(3)      <= parity_map(l1term(1)&l1term(9)&l1term(10));
   Syn(4)      <= parity_map(l1term(2)&l1term(11));
   Syn(5)      <= parity_map(l1term(2)&l1term(12));
   Syn(6)      <= l1term(13);

end generate;

end xuq_eccgen;
