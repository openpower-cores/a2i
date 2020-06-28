-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    use ieee.numeric_std.all;
LIBRARY ibm;        
                    use ibm.std_ulogic_support.all;
                    use ibm.std_ulogic_function_support.all;
LIBRARY support;   
                    use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity xuq_alu_or3232 is  generic(expand_type: integer := 2 );   port (

        d            :in  std_ulogic_vector(0 to 63) ;
        or_hi_b      :out std_ulogic ;
        or_lo_b      :out std_ulogic  
);

-- synopsys translate_off
-- synopsys translate_on
end xuq_alu_or3232;

architecture xuq_alu_or3232 of xuq_alu_or3232 is
   constant tiup                       : std_ulogic := '1';
   constant tidn                       : std_ulogic := '0';

   signal or_lv1_b :std_ulogic_vector(0 to 31) ;
   signal or_lv2   :std_ulogic_vector(0 to 15) ;
   signal or_lv3_b :std_ulogic_vector(0 to  7) ;
   signal or_lv4   :std_ulogic_vector(0 to  3) ;
   signal or_lv5_b :std_ulogic_vector(0 to  1) ;








begin


 
 u_or_00:    or_lv1_b( 0) <= not( d          ( 0) or  d          ( 1) );
 u_or_02:    or_lv1_b( 1) <= not( d          ( 2) or  d          ( 3) );
 u_or_04:    or_lv1_b( 2) <= not( d          ( 4) or  d          ( 5) );
 u_or_06:    or_lv1_b( 3) <= not( d          ( 6) or  d          ( 7) );
 u_or_08:    or_lv1_b( 4) <= not( d          ( 8) or  d          ( 9) );
 u_or_10:    or_lv1_b( 5) <= not( d          (10) or  d          (11) );
 u_or_12:    or_lv1_b( 6) <= not( d          (12) or  d          (13) );
 u_or_14:    or_lv1_b( 7) <= not( d          (14) or  d          (15) );
 u_or_16:    or_lv1_b( 8) <= not( d          (16) or  d          (17) );
 u_or_18:    or_lv1_b( 9) <= not( d          (18) or  d          (19) );
 u_or_20:    or_lv1_b(10) <= not( d          (20) or  d          (21) );
 u_or_22:    or_lv1_b(11) <= not( d          (22) or  d          (23) );
 u_or_24:    or_lv1_b(12) <= not( d          (24) or  d          (25) );
 u_or_26:    or_lv1_b(13) <= not( d          (26) or  d          (27) );
 u_or_28:    or_lv1_b(14) <= not( d          (28) or  d          (29) );
 u_or_30:    or_lv1_b(15) <= not( d          (30) or  d          (31) );
 u_or_32:    or_lv1_b(16) <= not( d          (32) or  d          (33) );
 u_or_34:    or_lv1_b(17) <= not( d          (34) or  d          (35) );
 u_or_36:    or_lv1_b(18) <= not( d          (36) or  d          (37) );
 u_or_38:    or_lv1_b(19) <= not( d          (38) or  d          (39) );
 u_or_40:    or_lv1_b(20) <= not( d          (40) or  d          (41) );
 u_or_42:    or_lv1_b(21) <= not( d          (42) or  d          (43) );
 u_or_44:    or_lv1_b(22) <= not( d          (44) or  d          (45) );
 u_or_46:    or_lv1_b(23) <= not( d          (46) or  d          (47) );
 u_or_48:    or_lv1_b(24) <= not( d          (48) or  d          (49) );
 u_or_50:    or_lv1_b(25) <= not( d          (50) or  d          (51) );
 u_or_52:    or_lv1_b(26) <= not( d          (52) or  d          (53) );
 u_or_54:    or_lv1_b(27) <= not( d          (54) or  d          (55) );
 u_or_56:    or_lv1_b(28) <= not( d          (56) or  d          (57) );
 u_or_58:    or_lv1_b(29) <= not( d          (58) or  d          (59) );
 u_or_60:    or_lv1_b(30) <= not( d          (60) or  d          (61) ); 
 u_or_62:    or_lv1_b(31) <= not( d          (62) or  d          (63) );   

 u_or_01:    or_lv2  ( 0) <= not(    or_lv1_b( 0) and    or_lv1_b( 1) );
 u_or_05:    or_lv2  ( 1) <= not(    or_lv1_b( 2) and    or_lv1_b( 3) );
 u_or_09:    or_lv2  ( 2) <= not(    or_lv1_b( 4) and    or_lv1_b( 5) );
 u_or_13:    or_lv2  ( 3) <= not(    or_lv1_b( 6) and    or_lv1_b( 7) );
 u_or_17:    or_lv2  ( 4) <= not(    or_lv1_b( 8) and    or_lv1_b( 9) );
 u_or_21:    or_lv2  ( 5) <= not(    or_lv1_b(10) and    or_lv1_b(11) );
 u_or_25:    or_lv2  ( 6) <= not(    or_lv1_b(12) and    or_lv1_b(13) );
 u_or_29:    or_lv2  ( 7) <= not(    or_lv1_b(14) and    or_lv1_b(15) );
 u_or_33:    or_lv2  ( 8) <= not(    or_lv1_b(16) and    or_lv1_b(17) );
 u_or_37:    or_lv2  ( 9) <= not(    or_lv1_b(18) and    or_lv1_b(19) );
 u_or_41:    or_lv2  (10) <= not(    or_lv1_b(20) and    or_lv1_b(21) );
 u_or_45:    or_lv2  (11) <= not(    or_lv1_b(22) and    or_lv1_b(23) );
 u_or_49:    or_lv2  (12) <= not(    or_lv1_b(24) and    or_lv1_b(25) );
 u_or_53:    or_lv2  (13) <= not(    or_lv1_b(26) and    or_lv1_b(27) );
 u_or_57:    or_lv2  (14) <= not(    or_lv1_b(28) and    or_lv1_b(29) );
 u_or_61:    or_lv2  (15) <= not(    or_lv1_b(30) and    or_lv1_b(31) );

 u_or_03:    or_lv3_b( 0) <= not(    or_lv2  ( 0) or     or_lv2  ( 1) );
 u_or_11:    or_lv3_b( 1) <= not(    or_lv2  ( 2) or     or_lv2  ( 3) );
 u_or_19:    or_lv3_b( 2) <= not(    or_lv2  ( 4) or     or_lv2  ( 5) );
 u_or_27:    or_lv3_b( 3) <= not(    or_lv2  ( 6) or     or_lv2  ( 7) );
 u_or_35:    or_lv3_b( 4) <= not(    or_lv2  ( 8) or     or_lv2  ( 9) );
 u_or_43:    or_lv3_b( 5) <= not(    or_lv2  (10) or     or_lv2  (11) );
 u_or_51:    or_lv3_b( 6) <= not(    or_lv2  (12) or     or_lv2  (13) );
 u_or_59:    or_lv3_b( 7) <= not(    or_lv2  (14) or     or_lv2  (15) );

 u_or_07:    or_lv4  ( 0) <= not(    or_lv3_b( 0) and    or_lv3_b( 1) );
 u_or_23:    or_lv4  ( 1) <= not(    or_lv3_b( 2) and    or_lv3_b( 3) );
 u_or_39:    or_lv4  ( 2) <= not(    or_lv3_b( 4) and    or_lv3_b( 5) );
 u_or_55:    or_lv4  ( 3) <= not(    or_lv3_b( 6) and    or_lv3_b( 7) );

 u_or_15:    or_lv5_b( 0) <= not(    or_lv4  ( 0) or     or_lv4  ( 1) );
 u_or_47:    or_lv5_b( 1) <= not(    or_lv4  ( 2) or     or_lv4  ( 3) );

 or_hi_b <=    or_lv5_b(0); 
 or_lo_b <=    or_lv5_b(1); 

end architecture xuq_alu_or3232;
