-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU Merge Or-Reduce Component
--
LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    use ieee.numeric_std.all;
LIBRARY ibm;        
                    use ibm.std_ulogic_support.all;
                    use ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity xuq_alu_caor is  generic(expand_type: integer := 2 );   port (

        ca_root_b       :in  std_ulogic_vector(0 to 63) ;--data
        ca_or_hi        :out std_ulogic ;-- upper 32 ORed together
        ca_or_lo        :out std_ulogic  -- lower 32 ORed together
);

-- synopsys translate_off
-- synopsys translate_on
end xuq_alu_caor;

architecture xuq_alu_caor of xuq_alu_caor is
   constant tiup                       : std_ulogic := '1';
   constant tidn                       : std_ulogic := '0';


   signal ca_or_lv1   :std_ulogic_vector(0 to 31) ;
   signal ca_or_lv2_b :std_ulogic_vector(0 to 15) ;
   signal ca_or_lv3   :std_ulogic_vector(0 to  7) ;
   signal ca_or_lv4_b :std_ulogic_vector(0 to  3) ;
   signal ca_or_lv5   :std_ulogic_vector(0 to  1) ;


begin


 u_ca_or_00: ca_or_lv1  ( 0) <= not( ca_root_b  ( 0) and ca_root_b  ( 1) );
 u_ca_or_02: ca_or_lv1  ( 1) <= not( ca_root_b  ( 2) and ca_root_b  ( 3) );
 u_ca_or_04: ca_or_lv1  ( 2) <= not( ca_root_b  ( 4) and ca_root_b  ( 5) );
 u_ca_or_06: ca_or_lv1  ( 3) <= not( ca_root_b  ( 6) and ca_root_b  ( 7) );
 u_ca_or_08: ca_or_lv1  ( 4) <= not( ca_root_b  ( 8) and ca_root_b  ( 9) );
 u_ca_or_10: ca_or_lv1  ( 5) <= not( ca_root_b  (10) and ca_root_b  (11) );
 u_ca_or_12: ca_or_lv1  ( 6) <= not( ca_root_b  (12) and ca_root_b  (13) );
 u_ca_or_14: ca_or_lv1  ( 7) <= not( ca_root_b  (14) and ca_root_b  (15) );
 u_ca_or_16: ca_or_lv1  ( 8) <= not( ca_root_b  (16) and ca_root_b  (17) );
 u_ca_or_18: ca_or_lv1  ( 9) <= not( ca_root_b  (18) and ca_root_b  (19) );
 u_ca_or_20: ca_or_lv1  (10) <= not( ca_root_b  (20) and ca_root_b  (21) );
 u_ca_or_22: ca_or_lv1  (11) <= not( ca_root_b  (22) and ca_root_b  (23) );
 u_ca_or_24: ca_or_lv1  (12) <= not( ca_root_b  (24) and ca_root_b  (25) );
 u_ca_or_26: ca_or_lv1  (13) <= not( ca_root_b  (26) and ca_root_b  (27) );
 u_ca_or_28: ca_or_lv1  (14) <= not( ca_root_b  (28) and ca_root_b  (29) );
 u_ca_or_30: ca_or_lv1  (15) <= not( ca_root_b  (30) and ca_root_b  (31) );
 u_ca_or_32: ca_or_lv1  (16) <= not( ca_root_b  (32) and ca_root_b  (33) );
 u_ca_or_34: ca_or_lv1  (17) <= not( ca_root_b  (34) and ca_root_b  (35) );
 u_ca_or_36: ca_or_lv1  (18) <= not( ca_root_b  (36) and ca_root_b  (37) );
 u_ca_or_38: ca_or_lv1  (19) <= not( ca_root_b  (38) and ca_root_b  (39) );
 u_ca_or_40: ca_or_lv1  (20) <= not( ca_root_b  (40) and ca_root_b  (41) );
 u_ca_or_42: ca_or_lv1  (21) <= not( ca_root_b  (42) and ca_root_b  (43) );
 u_ca_or_44: ca_or_lv1  (22) <= not( ca_root_b  (44) and ca_root_b  (45) );
 u_ca_or_46: ca_or_lv1  (23) <= not( ca_root_b  (46) and ca_root_b  (47) );
 u_ca_or_48: ca_or_lv1  (24) <= not( ca_root_b  (48) and ca_root_b  (49) );
 u_ca_or_50: ca_or_lv1  (25) <= not( ca_root_b  (50) and ca_root_b  (51) );
 u_ca_or_52: ca_or_lv1  (26) <= not( ca_root_b  (52) and ca_root_b  (53) );
 u_ca_or_54: ca_or_lv1  (27) <= not( ca_root_b  (54) and ca_root_b  (55) );
 u_ca_or_56: ca_or_lv1  (28) <= not( ca_root_b  (56) and ca_root_b  (57) );
 u_ca_or_58: ca_or_lv1  (29) <= not( ca_root_b  (58) and ca_root_b  (59) );
 u_ca_or_60: ca_or_lv1  (30) <= not( ca_root_b  (60) and ca_root_b  (61) ); 
 u_ca_or_62: ca_or_lv1  (31) <= not( ca_root_b  (62) and ca_root_b  (63) );   

 u_ca_or_01: ca_or_lv2_b( 0) <= not( ca_or_lv1  ( 0) or  ca_or_lv1  ( 1) );
 u_ca_or_05: ca_or_lv2_b( 1) <= not( ca_or_lv1  ( 2) or  ca_or_lv1  ( 3) );
 u_ca_or_09: ca_or_lv2_b( 2) <= not( ca_or_lv1  ( 4) or  ca_or_lv1  ( 5) );
 u_ca_or_13: ca_or_lv2_b( 3) <= not( ca_or_lv1  ( 6) or  ca_or_lv1  ( 7) );
 u_ca_or_17: ca_or_lv2_b( 4) <= not( ca_or_lv1  ( 8) or  ca_or_lv1  ( 9) );
 u_ca_or_21: ca_or_lv2_b( 5) <= not( ca_or_lv1  (10) or  ca_or_lv1  (11) );
 u_ca_or_25: ca_or_lv2_b( 6) <= not( ca_or_lv1  (12) or  ca_or_lv1  (13) );
 u_ca_or_29: ca_or_lv2_b( 7) <= not( ca_or_lv1  (14) or  ca_or_lv1  (15) );
 u_ca_or_33: ca_or_lv2_b( 8) <= not( ca_or_lv1  (16) or  ca_or_lv1  (17) );
 u_ca_or_37: ca_or_lv2_b( 9) <= not( ca_or_lv1  (18) or  ca_or_lv1  (19) );
 u_ca_or_41: ca_or_lv2_b(10) <= not( ca_or_lv1  (20) or  ca_or_lv1  (21) );
 u_ca_or_45: ca_or_lv2_b(11) <= not( ca_or_lv1  (22) or  ca_or_lv1  (23) );
 u_ca_or_49: ca_or_lv2_b(12) <= not( ca_or_lv1  (24) or  ca_or_lv1  (25) );
 u_ca_or_53: ca_or_lv2_b(13) <= not( ca_or_lv1  (26) or  ca_or_lv1  (27) );
 u_ca_or_57: ca_or_lv2_b(14) <= not( ca_or_lv1  (28) or  ca_or_lv1  (29) );
 u_ca_or_61: ca_or_lv2_b(15) <= not( ca_or_lv1  (30) or  ca_or_lv1  (31) );

 u_ca_or_03: ca_or_lv3  ( 0) <= not( ca_or_lv2_b( 0) and ca_or_lv2_b( 1) );
 u_ca_or_11: ca_or_lv3  ( 1) <= not( ca_or_lv2_b( 2) and ca_or_lv2_b( 3) );
 u_ca_or_19: ca_or_lv3  ( 2) <= not( ca_or_lv2_b( 4) and ca_or_lv2_b( 5) );
 u_ca_or_27: ca_or_lv3  ( 3) <= not( ca_or_lv2_b( 6) and ca_or_lv2_b( 7) );
 u_ca_or_35: ca_or_lv3  ( 4) <= not( ca_or_lv2_b( 8) and ca_or_lv2_b( 9) );
 u_ca_or_43: ca_or_lv3  ( 5) <= not( ca_or_lv2_b(10) and ca_or_lv2_b(11) );
 u_ca_or_51: ca_or_lv3  ( 6) <= not( ca_or_lv2_b(12) and ca_or_lv2_b(13) );
 u_ca_or_59: ca_or_lv3  ( 7) <= not( ca_or_lv2_b(14) and ca_or_lv2_b(15) );

 u_ca_or_07: ca_or_lv4_b( 0) <= not( ca_or_lv3  ( 0) or  ca_or_lv3  ( 1) );
 u_ca_or_23: ca_or_lv4_b( 1) <= not( ca_or_lv3  ( 2) or  ca_or_lv3  ( 3) );
 u_ca_or_39: ca_or_lv4_b( 2) <= not( ca_or_lv3  ( 4) or  ca_or_lv3  ( 5) );
 u_ca_or_55: ca_or_lv4_b( 3) <= not( ca_or_lv3  ( 6) or  ca_or_lv3  ( 7) );

 u_ca_or_15: ca_or_lv5  ( 0) <= not( ca_or_lv4_b( 0) and ca_or_lv4_b( 1) );
 u_ca_or_47: ca_or_lv5  ( 1) <= not( ca_or_lv4_b( 2) and ca_or_lv4_b( 3) );

  ca_or_hi <= ca_or_lv5(0); -- rename
  ca_or_lo <= ca_or_lv5(1); -- rename

end architecture xuq_alu_caor;
