-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



library ieee, ibm, support;

use ieee.std_logic_1164.all;
use ibm.std_ulogic_support.all;

entity iuq_bd is
port(
     instruction                : in  std_ulogic_vector(0 to 31);
     branch_decode              : out std_ulogic_vector(0 to 3);

     bp_bc_en                   : in  std_ulogic;
     bp_bclr_en                 : in  std_ulogic;
     bp_bcctr_en                : in  std_ulogic;
     bp_sw_en                   : in  std_ulogic
);

-- synopsys translate_off
-- synopsys translate_on
end iuq_bd;
architecture iuq_bd of iuq_bd is

signal b                        : std_ulogic;
signal bc                       : std_ulogic;
signal bclr                     : std_ulogic;
signal bcctr                    : std_ulogic;
signal br_val                   : std_ulogic;

signal bo                       : std_ulogic_vector(0 to 4);
signal hint                     : std_ulogic;
signal hint_val                 : std_ulogic;

signal unused_instruction       : std_ulogic_vector(0 to 10);

begin

unused_instruction <= instruction(11 to 20) & instruction(31);

b                               <=                 instruction(0 to 5) = "010010";
bc                              <= bp_bc_en    and instruction(0 to 5) = "010000";
bclr                            <= bp_bclr_en  and instruction(0 to 5) = "010011" and instruction(21 to 30) = "0000010000";
bcctr                           <= bp_bcctr_en and instruction(0 to 5) = "010011" and instruction(21 to 30) = "1000010000";

br_val                          <= b or bc or bclr or bcctr;

bo(0 to 4)                      <= instruction(6 to 10);


hint_val                        <= (bo(0) and bo(2)) or (bp_sw_en and ((bo(0) = '0' and bo(2) = '1' and bo(3) = '1') or
                                                                       (bo(0) = '1' and bo(2) = '0' and bo(1) = '1')));

hint                            <= (bo(0) and bo(2)) or bo(4);

branch_decode(0 to 3)           <= br_val & b & hint_val & hint;

end iuq_bd;
