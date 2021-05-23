-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode).
-- Additional rights, including the right to physically implement a softcore
-- that is compliant with the required sections of the Power ISA
-- Specification, will be available at no cost via the OpenPOWER Foundation.
-- This README will be updated with additional information when OpenPOWER's
-- license is available.

library ieee; use ieee.std_logic_1164.all ;
library ibm;
  use ibm.std_ulogic_support.all;
  use ibm.std_ulogic_function_support.all;
  use ibm.std_ulogic_ao_support.all;
  use ibm.std_ulogic_mux_support.all;
library support; use support.power_logic_pkg.all;

ENTITY c_prism_bthmx IS
    GENERIC ( btr : string := "BTHMX_X1_A12TH"  );
    PORT(
     X      : IN  STD_ULOGIC;
     SNEG   : IN  STD_ULOGIC; -- DO NOT FLIP THE INPUT (ADD)
     SX     : IN  STD_ULOGIC; -- SHIFT BY 1
     SX2    : IN  STD_ULOGIC; -- SHIFT BY 2
     RIGHT  : IN  STD_ULOGIC; -- BIT FROM THE RIGHT (LSB)
     LEFT   : OUT STD_ULOGIC; -- BIT FROM THE LEFT
     Q      : OUT STD_ULOGIC; -- FINAL OUTPUT
     vd     : inout power_logic;
     gd     : inout power_logic
  );

-- synopsys translate_off


   -- The following will be used by synthesis for unrolling the vector:
   -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
   --ATTRIBUTE PIN_BIT_INFORMATION of c_prism_bthmx : entity is
   --  (
   --    1 => ("   ","X       ","SAME","PIN_BIT_SCALAR"),
   --    2 => ("   ","SNEG    ","SAME","PIN_BIT_SCALAR"),
   --    3 => ("   ","SX      ","SAME","PIN_BIT_SCALAR"),
   --    4 => ("   ","SX2     ","SAME","PIN_BIT_SCALAR"),
   --    5 => ("   ","RIGHT   ","SAME","PIN_BIT_SCALAR"),
   --    6 => ("   ","LEFT    ","SAME","PIN_BIT_SCALAR"),
   --    7 => ("   ","Q       ","SAME","PIN_BIT_SCALAR"),
   --    8 => ("   ","VDD     ","SAME","PIN_BIT_SCALAR"),
   --    9 => ("   ","VSS     ","SAME","PIN_BIT_SCALAR")
   --    );
-- synopsys translate_on
END                               c_prism_bthmx;

ARCHITECTURE c_prism_bthmx OF c_prism_bthmx IS

   SIGNAL CENTER :STD_ULOGIC;
   SIGNAL XN     :STD_ULOGIC;
   SIGNAL SPOS   :STD_ULOGIC;


BEGIN

   XN <= NOT X;

   SPOS <= NOT SNEG;

   CENTER <= NOT( ( XN AND SPOS ) OR
                  ( X  AND SNEG )   );

   LEFT <= CENTER; -- OUTPUT


   Q <= ( CENTER AND  SX  ) OR
        ( RIGHT  AND  SX2 ) ;


END;
