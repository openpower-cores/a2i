-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU ECC Check Macro
--
library ieee,ibm,support;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use work.xuq_pkg.all;

entity xuq_eccchk is 
generic(
   regsize                 :     integer := 32);
port(
   din                     : in  std_ulogic_vector(0 to regsize-1);
   EnCorr                  : in  std_ulogic;
   NSyn                    : in  std_ulogic_vector(0 to 8-(64/regsize));
   Corrd                   : out std_ulogic_vector(0 to regsize-1);
   SBE                     : out std_ulogic;
   UE                      : out std_ulogic
   );

-- synopsys translate_off
-- synopsys translate_on

end xuq_eccchk;
architecture xuq_eccchk of xuq_eccchk is 
begin
ecc64 : if regsize = 64 generate

   signal Syn                 : std_ulogic_vector(0 to 7);     -- syndrome bits inverted
   signal DcdD                : std_ulogic_vector(0 to 71);    -- decode data bits
   signal Synzero             : std_ulogic;
   signal SBE_int             : std_ulogic;
   signal A0to1               : std_ulogic_vector(0 to 3);
   signal A2to3               : std_ulogic_vector(0 to 3);
   signal A4to5               : std_ulogic_vector(0 to 3);
   signal A6to7               : std_ulogic_vector(0 to 2);

   begin

   -- ====================================================================
   -- 64 Data Bits, 8 Check bits
   -- Single bit error correction, Double bit error detection
   -- ====================================================================
   --                        ECC Matrix Description
   -- ====================================================================
   -- Syn 0   111011010011101001100101101101001100101101001011001101001110100110000000
   -- Syn 1   110110101011010101010101011010101010101010101010101010101101010101000000
   -- Syn 2   101101100110110011001100110110011001100110011001100110011011001100100000
   -- Syn 3   011100011110001111000011110001111000011110000111100001111000111100010000
   -- Syn 4   000011111110000000111111110000000111111110000000011111111000000000001000
   -- Syn 5   000000000001111111111111110000000000000001111111111111111000000000000100
   -- Syn 6   000000000000000000000000001111111111111111111111111111111000000000000010
   -- Syn 7   000000000000000000000000000000000000000000000000000000000111111100000001

   Syn      <= not NSyn(0 to 7);

   A0to1(0) <=  not (NSyn(0) and NSyn(1) and EnCorr);
   A0to1(1) <=  not (NSyn(0) and  Syn(1) and EnCorr);
   A0to1(2) <=  not ( Syn(0) and NSyn(1) and EnCorr);
   A0to1(3) <=  not ( Syn(0) and  Syn(1) and EnCorr);

   A2to3(0) <=  not (NSyn(2) and NSyn(3));
   A2to3(1) <=  not (NSyn(2) and  Syn(3));
   A2to3(2) <=  not ( Syn(2) and NSyn(3));
   A2to3(3) <=  not ( Syn(2) and  Syn(3));

   A4to5(0) <=  not (NSyn(4) and NSyn(5));
   A4to5(1) <=  not (NSyn(4) and  Syn(5));
   A4to5(2) <=  not ( Syn(4) and NSyn(5));
   A4to5(3) <=  not ( Syn(4) and  Syn(5));

   A6to7(0) <=  not (NSyn(6) and NSyn(7));
   A6to7(1) <=  not (NSyn(6) and  Syn(7));
   A6to7(2) <=  not ( Syn(6) and NSyn(7));

   DcdD( 0) <= not (A0to1(3) or A2to3(2) or A4to5(0) or A6to7(0)); -- 11 10 00 00
   DcdD( 1) <= not (A0to1(3) or A2to3(1) or A4to5(0) or A6to7(0)); -- 11 01 00 00
   DcdD( 2) <= not (A0to1(2) or A2to3(3) or A4to5(0) or A6to7(0)); -- 10 11 00 00
   DcdD( 3) <= not (A0to1(1) or A2to3(3) or A4to5(0) or A6to7(0)); -- 01 11 00 00
   DcdD( 4) <= not (A0to1(3) or A2to3(0) or A4to5(2) or A6to7(0)); -- 11 00 10 00
   DcdD( 5) <= not (A0to1(2) or A2to3(2) or A4to5(2) or A6to7(0)); -- 10 10 10 00
   DcdD( 6) <= not (A0to1(1) or A2to3(2) or A4to5(2) or A6to7(0)); -- 01 10 10 00
   DcdD( 7) <= not (A0to1(2) or A2to3(1) or A4to5(2) or A6to7(0)); -- 10 01 10 00
   DcdD( 8) <= not (A0to1(1) or A2to3(1) or A4to5(2) or A6to7(0)); -- 01 01 10 00
   DcdD( 9) <= not (A0to1(0) or A2to3(3) or A4to5(2) or A6to7(0)); -- 00 11 10 00
   DcdD(10) <= not (A0to1(3) or A2to3(3) or A4to5(2) or A6to7(0)); -- 11 11 10 00
   DcdD(11) <= not (A0to1(3) or A2to3(0) or A4to5(1) or A6to7(0)); -- 11 00 01 00
   DcdD(12) <= not (A0to1(2) or A2to3(2) or A4to5(1) or A6to7(0)); -- 10 10 01 00
   DcdD(13) <= not (A0to1(1) or A2to3(2) or A4to5(1) or A6to7(0)); -- 01 10 01 00
   DcdD(14) <= not (A0to1(2) or A2to3(1) or A4to5(1) or A6to7(0)); -- 10 01 01 00
   DcdD(15) <= not (A0to1(1) or A2to3(1) or A4to5(1) or A6to7(0)); -- 01 01 01 00
   DcdD(16) <= not (A0to1(0) or A2to3(3) or A4to5(1) or A6to7(0)); -- 00 11 01 00
   DcdD(17) <= not (A0to1(3) or A2to3(3) or A4to5(1) or A6to7(0)); -- 11 11 01 00
   DcdD(18) <= not (A0to1(2) or A2to3(0) or A4to5(3) or A6to7(0)); -- 10 00 11 00
   DcdD(19) <= not (A0to1(1) or A2to3(0) or A4to5(3) or A6to7(0)); -- 01 00 11 00
   DcdD(20) <= not (A0to1(0) or A2to3(2) or A4to5(3) or A6to7(0)); -- 00 10 11 00
   DcdD(21) <= not (A0to1(3) or A2to3(2) or A4to5(3) or A6to7(0)); -- 11 10 11 00
   DcdD(22) <= not (A0to1(0) or A2to3(1) or A4to5(3) or A6to7(0)); -- 00 01 11 00
   DcdD(23) <= not (A0to1(3) or A2to3(1) or A4to5(3) or A6to7(0)); -- 11 01 11 00
   DcdD(24) <= not (A0to1(2) or A2to3(3) or A4to5(3) or A6to7(0)); -- 10 11 11 00
   DcdD(25) <= not (A0to1(1) or A2to3(3) or A4to5(3) or A6to7(0)); -- 01 11 11 00
   DcdD(26) <= not (A0to1(3) or A2to3(0) or A4to5(0) or A6to7(2)); -- 11 00 00 10
   DcdD(27) <= not (A0to1(2) or A2to3(2) or A4to5(0) or A6to7(2)); -- 10 10 00 10
   DcdD(28) <= not (A0to1(1) or A2to3(2) or A4to5(0) or A6to7(2)); -- 01 10 00 10
   DcdD(29) <= not (A0to1(2) or A2to3(1) or A4to5(0) or A6to7(2)); -- 10 01 00 10
   DcdD(30) <= not (A0to1(1) or A2to3(1) or A4to5(0) or A6to7(2)); -- 01 01 00 10
   DcdD(31) <= not (A0to1(0) or A2to3(3) or A4to5(0) or A6to7(2)); -- 00 11 00 10
   DcdD(32) <= not (A0to1(3) or A2to3(3) or A4to5(0) or A6to7(2)); -- 11 11 00 10
   DcdD(33) <= not (A0to1(2) or A2to3(0) or A4to5(2) or A6to7(2)); -- 10 00 10 10
   DcdD(34) <= not (A0to1(1) or A2to3(0) or A4to5(2) or A6to7(2)); -- 01 00 10 10
   DcdD(35) <= not (A0to1(0) or A2to3(2) or A4to5(2) or A6to7(2)); -- 00 10 10 10
   DcdD(36) <= not (A0to1(3) or A2to3(2) or A4to5(2) or A6to7(2)); -- 11 10 10 10
   DcdD(37) <= not (A0to1(0) or A2to3(1) or A4to5(2) or A6to7(2)); -- 00 01 10 10
   DcdD(38) <= not (A0to1(3) or A2to3(1) or A4to5(2) or A6to7(2)); -- 11 01 10 10
   DcdD(39) <= not (A0to1(2) or A2to3(3) or A4to5(2) or A6to7(2)); -- 10 11 10 10
   DcdD(40) <= not (A0to1(1) or A2to3(3) or A4to5(2) or A6to7(2)); -- 01 11 10 10
   DcdD(41) <= not (A0to1(2) or A2to3(0) or A4to5(1) or A6to7(2)); -- 10 00 01 10
   DcdD(42) <= not (A0to1(1) or A2to3(0) or A4to5(1) or A6to7(2)); -- 01 00 01 10
   DcdD(43) <= not (A0to1(0) or A2to3(2) or A4to5(1) or A6to7(2)); -- 00 10 01 10
   DcdD(44) <= not (A0to1(3) or A2to3(2) or A4to5(1) or A6to7(2)); -- 11 10 01 10
   DcdD(45) <= not (A0to1(0) or A2to3(1) or A4to5(1) or A6to7(2)); -- 00 01 01 10
   DcdD(46) <= not (A0to1(3) or A2to3(1) or A4to5(1) or A6to7(2)); -- 11 01 01 10
   DcdD(47) <= not (A0to1(2) or A2to3(3) or A4to5(1) or A6to7(2)); -- 10 11 01 10
   DcdD(48) <= not (A0to1(1) or A2to3(3) or A4to5(1) or A6to7(2)); -- 01 11 01 10
   DcdD(49) <= not (A0to1(0) or A2to3(0) or A4to5(3) or A6to7(2)); -- 00 00 11 10
   DcdD(50) <= not (A0to1(3) or A2to3(0) or A4to5(3) or A6to7(2)); -- 11 00 11 10
   DcdD(51) <= not (A0to1(2) or A2to3(2) or A4to5(3) or A6to7(2)); -- 10 10 11 10
   DcdD(52) <= not (A0to1(1) or A2to3(2) or A4to5(3) or A6to7(2)); -- 01 10 11 10
   DcdD(53) <= not (A0to1(2) or A2to3(1) or A4to5(3) or A6to7(2)); -- 10 01 11 10
   DcdD(54) <= not (A0to1(1) or A2to3(1) or A4to5(3) or A6to7(2)); -- 01 01 11 10
   DcdD(55) <= not (A0to1(0) or A2to3(3) or A4to5(3) or A6to7(2)); -- 00 11 11 10
   DcdD(56) <= not (A0to1(3) or A2to3(3) or A4to5(3) or A6to7(2)); -- 11 11 11 10
   DcdD(57) <= not (A0to1(3) or A2to3(0) or A4to5(0) or A6to7(1)); -- 11 00 00 01
   DcdD(58) <= not (A0to1(2) or A2to3(2) or A4to5(0) or A6to7(1)); -- 10 10 00 01
   DcdD(59) <= not (A0to1(1) or A2to3(2) or A4to5(0) or A6to7(1)); -- 01 10 00 01
   DcdD(60) <= not (A0to1(2) or A2to3(1) or A4to5(0) or A6to7(1)); -- 10 01 00 01
   DcdD(61) <= not (A0to1(1) or A2to3(1) or A4to5(0) or A6to7(1)); -- 01 01 00 01
   DcdD(62) <= not (A0to1(0) or A2to3(3) or A4to5(0) or A6to7(1)); -- 00 11 00 01
   DcdD(63) <= not (A0to1(3) or A2to3(3) or A4to5(0) or A6to7(1)); -- 11 11 00 01
   DcdD(64) <= not (A0to1(2) or A2to3(0) or A4to5(0) or A6to7(0)); -- 10 00 00 00
   DcdD(65) <= not (A0to1(1) or A2to3(0) or A4to5(0) or A6to7(0)); -- 01 00 00 00
   DcdD(66) <= not (A0to1(0) or A2to3(2) or A4to5(0) or A6to7(0)); -- 00 10 00 00
   DcdD(67) <= not (A0to1(0) or A2to3(1) or A4to5(0) or A6to7(0)); -- 00 01 00 00
   DcdD(68) <= not (A0to1(0) or A2to3(0) or A4to5(2) or A6to7(0)); -- 00 00 10 00
   DcdD(69) <= not (A0to1(0) or A2to3(0) or A4to5(1) or A6to7(0)); -- 00 00 01 00
   DcdD(70) <= not (A0to1(0) or A2to3(0) or A4to5(0) or A6to7(2)); -- 00 00 00 10
   DcdD(71) <= not (A0to1(0) or A2to3(0) or A4to5(0) or A6to7(1)); -- 00 00 00 01
   Synzero  <= not (A0to1(0) or A2to3(0) or A4to5(0) or A6to7(0)); -- 00 00 00 00

   CorrD(0 to 63) <= Din(0 to 63) xor DcdD(0 to 63);

   SBE_int        <= '1' when DcdD(0 to 71) /= (0 to 71=>'0') else '0';
   SBE            <= SBE_int;
   UE             <= (not SBE_int) and ((not Synzero)) and EnCorr;

end generate;
ecc32 : if regsize = 32 generate

   signal Syn                 : std_ulogic_vector(0 to 6);     -- syndrome bits inverted
   signal DcdD                : std_ulogic_vector(0 to 38);    -- decode data bits
   signal Synzero             : std_ulogic;
   signal SBE_int             : std_ulogic;
   signal A0to1               : std_ulogic_vector(0 to 3);
   signal A2to3               : std_ulogic_vector(0 to 3);
   signal A4to6               : std_ulogic_vector(0 to 7);

   begin

   -- ====================================================================
   -- 32 Data Bits, 7 Check bits
   -- Single bit error correction, Double bit error detection
   -- ====================================================================
   --                        ECC Matrix Description
   -- ====================================================================
   -- Syn 0   111011010011101001100101101101001000000
   -- Syn 1   110110101011010101010101011010100100000
   -- Syn 2   101101100110110011001100110110010010000
   -- Syn 3   011100011110001111000011110001110001000
   -- Syn 4   000011111110000000111111110000000000100
   -- Syn 5   000000000001111111111111110000000000010
   -- Syn 6   000000000000000000000000001111110000001

   Syn <= not NSyn(0 to 6);

   A0to1(0) <=  not (NSyn(0) and NSyn(1) and EnCorr);
   A0to1(1) <=  not (NSyn(0) and  Syn(1) and EnCorr);
   A0to1(2) <=  not ( Syn(0) and NSyn(1) and EnCorr);
   A0to1(3) <=  not ( Syn(0) and  Syn(1) and EnCorr);

   A2to3(0) <=  not (NSyn(2) and NSyn(3));
   A2to3(1) <=  not (NSyn(2) and  Syn(3));
   A2to3(2) <=  not ( Syn(2) and NSyn(3));
   A2to3(3) <=  not ( Syn(2) and  Syn(3));

   A4to6(0) <=  not (NSyn(4) and NSyn(5) and NSyn(6));
   A4to6(1) <=  not (NSyn(4) and NSyn(5) and  Syn(6));
   A4to6(2) <=  not (NSyn(4) and  Syn(5) and NSyn(6));
   A4to6(3) <=  not (NSyn(4) and  Syn(5) and  Syn(6));
   A4to6(4) <=  not ( Syn(4) and NSyn(5) and NSyn(6));
   A4to6(5) <=  not ( Syn(4) and NSyn(5) and  Syn(6));
   A4to6(6) <=  not ( Syn(4) and  Syn(5) and NSyn(6));
   A4to6(7) <=  not ( Syn(4) and  Syn(5) and  Syn(6));

   DcdD( 0) <= not (A0to1(3) or A2to3(2) or A4to6(0)); -- 11 10 000
   DcdD( 1) <= not (A0to1(3) or A2to3(1) or A4to6(0)); -- 11 01 000
   DcdD( 2) <= not (A0to1(2) or A2to3(3) or A4to6(0)); -- 10 11 000
   DcdD( 3) <= not (A0to1(1) or A2to3(3) or A4to6(0)); -- 01 11 000
   DcdD( 4) <= not (A0to1(3) or A2to3(0) or A4to6(4)); -- 11 00 100
   DcdD( 5) <= not (A0to1(2) or A2to3(2) or A4to6(4)); -- 10 10 100
   DcdD( 6) <= not (A0to1(1) or A2to3(2) or A4to6(4)); -- 01 10 100
   DcdD( 7) <= not (A0to1(2) or A2to3(1) or A4to6(4)); -- 10 01 100
   DcdD( 8) <= not (A0to1(1) or A2to3(1) or A4to6(4)); -- 01 01 100
   DcdD( 9) <= not (A0to1(0) or A2to3(3) or A4to6(4)); -- 00 11 100
   DcdD(10) <= not (A0to1(3) or A2to3(3) or A4to6(4)); -- 11 11 100
   DcdD(11) <= not (A0to1(3) or A2to3(0) or A4to6(2)); -- 11 00 010
   DcdD(12) <= not (A0to1(2) or A2to3(2) or A4to6(2)); -- 10 10 010
   DcdD(13) <= not (A0to1(1) or A2to3(2) or A4to6(2)); -- 01 10 010
   DcdD(14) <= not (A0to1(2) or A2to3(1) or A4to6(2)); -- 10 01 010
   DcdD(15) <= not (A0to1(1) or A2to3(1) or A4to6(2)); -- 01 01 010
   DcdD(16) <= not (A0to1(0) or A2to3(3) or A4to6(2)); -- 00 11 010
   DcdD(17) <= not (A0to1(3) or A2to3(3) or A4to6(2)); -- 11 11 010
   DcdD(18) <= not (A0to1(2) or A2to3(0) or A4to6(6)); -- 10 00 110
   DcdD(19) <= not (A0to1(1) or A2to3(0) or A4to6(6)); -- 01 00 110
   DcdD(20) <= not (A0to1(0) or A2to3(2) or A4to6(6)); -- 00 10 110
   DcdD(21) <= not (A0to1(3) or A2to3(2) or A4to6(6)); -- 11 10 110
   DcdD(22) <= not (A0to1(0) or A2to3(1) or A4to6(6)); -- 00 01 110
   DcdD(23) <= not (A0to1(3) or A2to3(1) or A4to6(6)); -- 11 01 110
   DcdD(24) <= not (A0to1(2) or A2to3(3) or A4to6(6)); -- 10 11 110
   DcdD(25) <= not (A0to1(1) or A2to3(3) or A4to6(6)); -- 01 11 110
   DcdD(26) <= not (A0to1(3) or A2to3(0) or A4to6(1)); -- 11 00 001
   DcdD(27) <= not (A0to1(2) or A2to3(2) or A4to6(1)); -- 10 10 001
   DcdD(28) <= not (A0to1(1) or A2to3(2) or A4to6(1)); -- 01 10 001
   DcdD(29) <= not (A0to1(2) or A2to3(1) or A4to6(1)); -- 10 01 001
   DcdD(30) <= not (A0to1(1) or A2to3(1) or A4to6(1)); -- 01 01 001
   DcdD(31) <= not (A0to1(0) or A2to3(3) or A4to6(1)); -- 00 11 001
   DcdD(32) <= not (A0to1(2) or A2to3(0) or A4to6(0)); -- 10 00 000
   DcdD(33) <= not (A0to1(1) or A2to3(0) or A4to6(0)); -- 01 00 000
   DcdD(34) <= not (A0to1(0) or A2to3(2) or A4to6(0)); -- 00 10 000
   DcdD(35) <= not (A0to1(0) or A2to3(1) or A4to6(0)); -- 00 01 000
   DcdD(36) <= not (A0to1(0) or A2to3(0) or A4to6(4)); -- 00 00 100
   DcdD(37) <= not (A0to1(0) or A2to3(0) or A4to6(2)); -- 00 00 010
   DcdD(38) <= not (A0to1(0) or A2to3(0) or A4to6(1)); -- 00 00 001
   Synzero <=  not (A0to1(0) or A2to3(0) or A4to6(0)); -- 00 00 000

   CorrD(0 to 31) <= Din(0 to 31) xor DcdD(0 to 31);

   SBE_int        <= '1' when DcdD(0 to 38) /= (0 to 38=>'0') else '0';
   SBE            <= SBE_int;
   UE             <= (not SBE_int) and ((not Synzero)) and EnCorr;
   
   mark_unused(A4to6(3));
   mark_unused(A4to6(5));
   mark_unused(A4to6(7));

end generate;

end xuq_eccchk;
