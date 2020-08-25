-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



--//############################################################################
--//#####  FUQ_GEST_loa.VHDL                                           #########
--//#####  side pipe for graphics estimates                            #########
--//#####  flogefp, fexptefp                                           #########
--//#####                                                              #########
--//############################################################################


library ieee; 
  use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 
library support; 
use support.power_logic_pkg.all;

library tri; use tri.tri_latches_pkg.all;


entity fuq_gst_loa is
  port(
     a   :in  std_ulogic_vector(1 to 19);

     shamt   :out std_ulogic_vector(0 to 4)   

 );


  
end fuq_gst_loa;

architecture fuq_gst_loa of fuq_gst_loa is

   signal unused :std_ulogic;

begin

   unused <= a(19) ;

--@@ ESPRESSO TABLE START @@
-- ##################################################################################################

-- ##################################################################################################
-- .i 19
-- .o 5
-- .ilb a(01) a(02) a(03) a(04) a(05) a(06) a(07) a(08) a(09) a(10) a(11) a(12) a(13) a(14) a(15) a(16) a(17) a(18) a(19)
-- .ob  shamt(0) shamt(1) shamt(2) shamt(3) shamt(4)

-- .type fr
--//#######################
--
-- 0000000000000000001     10011
-- 000000000000000001-     10010
-- 00000000000000001--     10001
-- 0000000000000001---     10000
-- 000000000000001----     01111
-- 00000000000001-----     01110
-- 0000000000001------     01101
-- 000000000001-------     01100
-- 00000000001--------     01011
-- 0000000001---------     01010
-- 000000001----------     01001
-- 00000001-----------     01000
-- 0000001------------     00111
-- 000001-------------     00110
-- 00001--------------     00101
-- 0001---------------     00100
-- 001----------------     00011
-- 01-----------------     00010
-- 1------------------     00001
-- 0000000000000000000     00000


-- ###############################################################################
-- .e
--@@ ESPRESSO TABLE END @@

--@@ ESPRESSO LOGIC START @@
-- logic generated on: Tue Dec  4 13:14:17 2007
shamt(0) <= (not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
		 and not a(08) and not a(09) and not a(10) and not a(11) and not a(12) and not a(13)
		 and not a(14) and not a(15) and  a(19)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and not a(08) and not a(09) and not a(10) and not a(11) and not a(12) and not a(13) and not a(14)
	 and not a(15) and  a(18)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and not a(08) and not a(09) and not a(10) and not a(11) and not a(12) and not a(13) and not a(14)
	 and not a(15) and  a(17)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and not a(08) and not a(09) and not a(10) and not a(11) and not a(12) and not a(13) and not a(14)
	 and not a(15) and  a(16));

shamt(1) <= (not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(15)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(14)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(13)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(12)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(11)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(10)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(09)) or
	(not a(01) and not a(02) and not a(03) and not a(04) and not a(05) and not a(06) and not a(07)
	 and  a(08));

shamt(2) <= (not a(01) and not a(02) and not a(03) and not a(08) and not a(09) and not a(10) and not a(11)
	 and  a(15)) or
	(not a(01) and not a(02) and not a(03) and not a(08) and not a(09) and not a(10) and not a(11)
	 and  a(14)) or
	(not a(01) and not a(02) and not a(03) and not a(08) and not a(09) and not a(10) and not a(11)
	 and  a(13)) or
	(not a(01) and not a(02) and not a(03) and not a(08) and not a(09) and not a(10) and not a(11)
	 and  a(12)) or
	(not a(01) and not a(02) and not a(03) and  a(07)) or
	(not a(01) and not a(02) and not a(03) and  a(06)) or
	(not a(01) and not a(02) and not a(03) and  a(05)) or
	(not a(01) and not a(02) and not a(03) and  a(04));

shamt(3) <= (not a(01) and not a(04) and not a(05) and not a(08) and not a(09) and not a(12) and not a(13)
	 and not a(16) and not a(17) and  a(19)) or
	(not a(01) and not a(04) and not a(05) and not a(08) and not a(09) and not a(12) and not a(13)
	 and not a(16) and not a(17) and  a(18)) or
	(not a(01) and not a(04) and not a(05) and not a(08) and not a(09) and not a(12) and not a(13)
	 and  a(15)) or
	(not a(01) and not a(04) and not a(05) and not a(08) and not a(09) and not a(12) and not a(13)
	 and  a(14)) or
	(not a(01) and not a(04) and not a(05) and not a(08) and not a(09) and  a(11)) or
	(not a(01) and not a(04) and not a(05) and not a(08) and not a(09) and  a(10)) or
	(not a(01) and not a(04) and not a(05) and  a(07)) or
	(not a(01) and not a(04) and not a(05) and  a(06)) or
	(not a(01) and  a(03)) or
	(not a(01) and  a(02));

shamt(4) <= (not a(02) and not a(04) and not a(06) and not a(08) and not a(10) and not a(12) and not a(14)
	 and not a(16) and not a(18) and  a(19)) or
	(not a(02) and not a(04) and not a(06) and not a(08) and not a(10) and not a(12) and not a(14)
	 and not a(16) and  a(17)) or
	(not a(02) and not a(04) and not a(06) and not a(08) and not a(10) and not a(12) and not a(14)
	 and  a(15)) or
	(not a(02) and not a(04) and not a(06) and not a(08) and not a(10) and not a(12) and  a(13)) or
	(not a(02) and not a(04) and not a(06) and not a(08) and not a(10) and  a(11)) or
	(not a(02) and not a(04) and not a(06) and not a(08) and  a(09)) or
	(not a(02) and not a(04) and not a(06) and  a(07)) or
	(not a(02) and not a(04) and  a(05)) or
	(not a(02) and  a(03)) or
	( a(01));

--@@ ESPRESSO LOGIC END @@










end fuq_gst_loa;
