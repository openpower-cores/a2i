-- © IBM Corp. 2020
-- Licensed under the Apache License, Version 2.0 (the "License"), as modified by
-- the terms below; you may not use the files in this repository except in
-- compliance with the License as modified.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
--
-- Modified Terms:
--
--    1) For the purpose of the patent license granted to you in Section 3 of the
--    License, the "Work" hereby includes implementations of the work of authorship
--    in physical form.
--
--    2) Notwithstanding any terms to the contrary in the License, any licenses
--    necessary for implementation of the Work that are available from OpenPOWER
--    via the Power ISA End User License Agreement (EULA) are explicitly excluded
--    hereunder, and may be obtained from OpenPOWER under the terms and conditions
--    of the EULA.  
--
-- Unless required by applicable law or agreed to in writing, the reference design
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
-- for the specific language governing permissions and limitations under the License.
-- 
-- Additional rights, including the ability to physically implement a softcore that
-- is compliant with the required sections of the Power ISA Specification, are
-- available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
-- obtained (along with the Power ISA) here: https://openpowerfoundation.org. 




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


entity fuq_gst_inc19 is
  port(
     a   :in  std_ulogic_vector(1 to 19);

     o   :out std_ulogic_vector(1 to 19)   

 );




end fuq_gst_inc19;

architecture fuq_gst_inc19 of fuq_gst_inc19 is

 signal a_sum                       :std_ulogic_vector(01 to 19);  
 signal a_cout_b                    :std_ulogic_vector(02 to 19);  
 signal g2_b, g4, g8_b, g16         :std_ulogic_vector(02 to 19);

 

begin



g2_b(19) <= not( a(19)           );
g2_b(18) <= not( a(18) and a(19) );
g2_b(17) <= not( a(17) and a(18) );
g2_b(16) <= not( a(16) and a(17) );
g2_b(15) <= not( a(15) and a(16) );
g2_b(14) <= not( a(14) and a(15) );
g2_b(13) <= not( a(13) and a(14) );
g2_b(12) <= not( a(12) and a(13) );
g2_b(11) <= not( a(11) and a(12) );
g2_b(10) <= not( a(10) and a(11) );
g2_b( 9) <= not( a( 9) and a(10) );
g2_b( 8) <= not( a( 8) and a( 9) );
g2_b( 7) <= not( a( 7) and a( 8) );
g2_b( 6) <= not( a( 6) and a( 7) );
g2_b( 5) <= not( a( 5) and a( 6) );
g2_b( 4) <= not( a( 4) and a( 5) );
g2_b( 3) <= not( a( 3) and a( 4) );
g2_b( 2) <= not( a( 2) and a( 3) );


g4(19) <= not( g2_b(19) ) ;
g4(18) <= not( g2_b(18) ) ;
g4(17) <= not( g2_b(17) or g2_b(19) ) ;
g4(16) <= not( g2_b(16) or g2_b(18) ) ;
g4(15) <= not( g2_b(15) or g2_b(17) ) ;
g4(14) <= not( g2_b(14) or g2_b(16) ) ;
g4(13) <= not( g2_b(13) or g2_b(15) ) ;
g4(12) <= not( g2_b(12) or g2_b(14) ) ;
g4(11) <= not( g2_b(11) or g2_b(13) ) ;
g4(10) <= not( g2_b(10) or g2_b(12) ) ;
g4( 9) <= not( g2_b( 9) or g2_b(11) ) ;
g4( 8) <= not( g2_b( 8) or g2_b(10) ) ;
g4( 7) <= not( g2_b( 7) or g2_b( 9) ) ;
g4( 6) <= not( g2_b( 6) or g2_b( 8) ) ;
g4( 5) <= not( g2_b( 5) or g2_b( 7) ) ;
g4( 4) <= not( g2_b( 4) or g2_b( 6) ) ;
g4( 3) <= not( g2_b( 3) or g2_b( 5) ) ;
g4( 2) <= not( g2_b( 2) or g2_b( 4) ) ;


g8_b(19) <=  not( g4(19) ) ;
g8_b(18) <=  not( g4(18) ) ;
g8_b(17) <=  not( g4(17) ) ;
g8_b(16) <=  not( g4(16) ) ;
g8_b(15) <=  not( g4(15) and g4(19) ) ;
g8_b(14) <=  not( g4(14) and g4(18) ) ;
g8_b(13) <=  not( g4(13) and g4(17) ) ;
g8_b(12) <=  not( g4(12) and g4(16) ) ;
g8_b(11) <=  not( g4(11) and g4(15) ) ;
g8_b(10) <=  not( g4(10) and g4(14) ) ;
g8_b( 9) <=  not( g4( 9) and g4(13) ) ;
g8_b( 8) <=  not( g4( 8) and g4(12) ) ;
g8_b( 7) <=  not( g4( 7) and g4(11) ) ;
g8_b( 6) <=  not( g4( 6) and g4(10) ) ;
g8_b( 5) <=  not( g4( 5) and g4( 9) ) ;
g8_b( 4) <=  not( g4( 4) and g4( 8) ) ;
g8_b( 3) <=  not( g4( 3) and g4( 7) ) ;
g8_b( 2) <=  not( g4( 2) and g4( 6) ) ;

g16(19) <= not( g8_b(19) );
g16(18) <= not( g8_b(18) );
g16(17) <= not( g8_b(17) );
g16(16) <= not( g8_b(16) );
g16(15) <= not( g8_b(15) );
g16(14) <= not( g8_b(14) );
g16(13) <= not( g8_b(13) );
g16(12) <= not( g8_b(12) );
g16(11) <= not( g8_b(11) or g8_b(19) ) ;
g16(10) <= not( g8_b(10) or g8_b(18) ) ;
g16( 9) <= not( g8_b( 9) or g8_b(17) ) ;
g16( 8) <= not( g8_b( 8) or g8_b(16) ) ;
g16( 7) <= not( g8_b( 7) or g8_b(15) ) ;
g16( 6) <= not( g8_b( 6) or g8_b(14) ) ;
g16( 5) <= not( g8_b( 5) or g8_b(13) ) ;
g16( 4) <= not( g8_b( 4) or g8_b(12) ) ;
g16( 3) <= not( g8_b( 3) or g8_b(11) ) ;
g16( 2) <= not( g8_b( 2) or g8_b(10) ) ;

a_cout_b(19) <= not( g16(19) );
a_cout_b(18) <= not( g16(18) );
a_cout_b(17) <= not( g16(17) );
a_cout_b(16) <= not( g16(16) );
a_cout_b(15) <= not( g16(15) );
a_cout_b(14) <= not( g16(14) );
a_cout_b(13) <= not( g16(13) );
a_cout_b(12) <= not( g16(12) );
a_cout_b(11) <= not( g16(11) );
a_cout_b(10) <= not( g16(10) );
a_cout_b( 9) <= not( g16( 9) );
a_cout_b( 8) <= not( g16( 8) );
a_cout_b( 7) <= not( g16( 7) );
a_cout_b( 6) <= not( g16( 6) );
a_cout_b( 5) <= not( g16( 5) );
a_cout_b( 4) <= not( g16( 4) );
a_cout_b( 3) <= not( g16( 3) and g16(19) );
a_cout_b( 2) <= not( g16( 2) and g16(18) );
              


a_sum(1 to 18) <= a(1 to 18);
a_sum(19) <= not a(19);


o(01 to 18) <= not( a_sum(01 to 18) xor a_cout_b(02 to 19) ); 
o(19)       <= a_sum(19);                                     


end fuq_gst_inc19; 

