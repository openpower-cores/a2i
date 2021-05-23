-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode).
-- Additional rights, including the right to physically implement a softcore
-- that is compliant with the required sections of the Power ISA
-- Specification, will be available at no cost via the OpenPOWER Foundation.
-- This README will be updated with additional information when OpenPOWER's
-- license is available.


library ieee; use ieee.std_logic_1164.all ;
library support;
library ibm;
  use ibm.std_ulogic_support.all;
  use ibm.std_ulogic_function_support.all;
  use ibm.std_ulogic_ao_support.all;
  use ibm.std_ulogic_mux_support.all;
  use support.power_logic_pkg.all;

ENTITY c_prism_csa42 IS
  GENERIC ( btr : string := "CSA42_A2_A12TH" );
  PORT(
   A       : IN  std_ulogic;
   B       : IN  std_ulogic;
   C       : IN  std_ulogic;
   D       : IN  std_ulogic;
   KI      : IN  std_ulogic;
   KO      : OUT std_ulogic;
   CAR     : OUT std_ulogic;
   SUM     : OUT std_ulogic;
   vd      : inout power_logic;
   gd      : inout power_logic
  );

-- synopsys translate_off


  -- The following will be used by synthesis for unrolling the vector:
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --ATTRIBUTE PIN_BIT_INFORMATION of c_prism_csa42 : entity is
  --  (
  --    1  => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --    2  => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --    3  => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --    4  => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --    5  => ("   ","KI      ","SAME","PIN_BIT_SCALAR"),
  --    6  => ("   ","KO      ","SAME","PIN_BIT_SCALAR"),
  --    7  => ("   ","CAR     ","SAME","PIN_BIT_SCALAR"),
  --    8  => ("   ","SUM     ","SAME","PIN_BIT_SCALAR"),
  --    9  => ("   ","VDD     ","SAME","PIN_BIT_SCALAR"),
  --    10 => ("   ","VSS     ","SAME","PIN_BIT_SCALAR")
  --    );
-- synopsys translate_on
END                              c_prism_csa42;

ARCHITECTURE c_prism_csa42 OF c_prism_csa42 IS

 signal s1 : std_ulogic;

BEGIN

  s1    <= b  XOR c  XOR d ;
  sum   <= s1 XOR a  XOR ki;

  car   <= (s1 AND a ) OR
           (s1 AND ki) OR
           (a  AND ki);

  ko   <= (b  AND c ) OR
          (b  AND d ) OR
          (c  AND d );


END;
