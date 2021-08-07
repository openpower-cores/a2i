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



library ieee; use ieee.std_logic_1164.all ; 
library ibm; 

  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 


entity fuq_loc8inc is  port(
     x           :in  std_ulogic_vector(0 to 7);
     ci          :in  std_ulogic;
     ci_b        :in  std_ulogic;
     co_b        :out std_ulogic;
     s0          :out std_ulogic_vector(0 to 7);
     s1          :out std_ulogic_vector(0 to 7)
);
END                                 fuq_loc8inc;

ARCHITECTURE fuq_loc8inc OF fuq_loc8inc IS


  signal  x_if_ci, x_b, x_p :std_ulogic_vector(0 to 7);
  signal  g2_6t7_b :std_ulogic;
  signal  g2_4t5_b :std_ulogic;
  signal  g2_2t3_b :std_ulogic;
  signal  g2_0t1_b :std_ulogic;
  signal  g4_4t7   :std_ulogic;
  signal  g4_0t3   :std_ulogic;
  signal  t2_6t7   :std_ulogic;
  signal  t2_4t5   :std_ulogic;
  signal  t2_2t3   :std_ulogic;
  signal  t4_6t7_b :std_ulogic;
  signal  t4_4t7_b :std_ulogic;
  signal  t4_2t5_b :std_ulogic;
  signal  t8_6t7   :std_ulogic;
  signal  t8_4t7   :std_ulogic;
  signal  t8_2t7   :std_ulogic;
  signal  t8_7t7_b :std_ulogic;
  signal  t8_6t7_b :std_ulogic;
  signal  t8_5t7_b :std_ulogic;
  signal  t8_4t7_b :std_ulogic;
  signal  t8_3t7_b :std_ulogic;
  signal  t8_2t7_b :std_ulogic;
  signal  t8_1t7_b :std_ulogic;
  signal s1x_b, s1y_b, s0_b :std_ulogic_vector(0 to 7);



  --  i0_b0    i1_b0   i2_b0   i3_b0   i4_b0   i5_b0   i6_b0   i7_b0   <=== buffer inputs
  --  i0_b1    i1_b1   i2_b1   i3_b1   i4_b1   i5_b1   i6_b1   i7_b1   <=== buffer inputs
  --  i0_g2    i0_g4   i2_g2   i0_g8   i4_g2   i4_g4   i6_g2   skip    <=== global chain
  --  skip     skip    i2_t4   i2_t2   i4_t4   i4_t2   i6_t4   i6_t2   <=== local carry
  --  skip     skip    i2_t8x  skip    i4_t8x  skip    i6_t8x  skip    <=== local carry
  --  skip     i1_t8   i2_t8   i3_t8   i4_t8   i5_t8   i6_t8   i7_t8   <=== local carry
  --  i0_if    i1_if   i2_if   i3_if   i4_if   i5_if   i6_if   i7_if   <=== local carry
  --  i0_s1x   i1_s1x  i2_s1x  i3_s1x  i4_s1x  i5_s1x  i6_s1x  i7_s1x  <=== carry select
  --  i0_s1y   i1_s1y  i2_s1y  i3_s1y  i4_s1y  i5_s1y  i6_s1y  i7_s1y  <=== carry select
  --  i0_s1    i1_s1   i2_s1   i3_s1   i4_s1   i5_s1   i6_s1   i7_s1   <=== carry select
  --  i0_s0b   i1_s0b  i2_s0b  i3_s0b  i4_s0b  i5_s0b  i6_s0b  i7_s0b  <=== carry select
  --  i0_s0    i1_s0   i2_s0   i3_s0   i4_s0   i5_s0   i6_s0   i7_s0   <=== carry select

  --FOLDED

  --  i0_b0    i2_b0   i4_b0   i6_b0   skip  skip  skip  skip <=== buffer inputs
  --  i1_b0    i3_b0   i5_b0   i7_b0   skip  skip  skip  skip <=== buffer inputs
  --  i0_b1    i2_b1   i4_b1   i6_b1   skip  skip  skip  skip <=== buffer inputs
  --  i1_b1    i3_b1   i5_b1   i7_b1   skip  skip  skip  skip <=== buffer inputs
  --  i0_g2    i2_g2   i4_g2   i6_g2   skip  skip  skip  skip <=== global chain
  --  i0_g4    i0_g8   i4_g4   skip    skip  skip  skip  skip <=== global chain
  --  skip     i2_t2   i4_t2   i6_t2   skip  skip  skip  skip <=== local carry
  --  skip     i2_t4   i4_t4   i6_t4   skip  skip  skip  skip <=== local carry
  --  skip     i2_t8x  i4_t8x  i6_t8x  skip  skip  skip  skip <=== local carry
  --  skip     i2_t8   i4_t8   i6_t8   skip  skip  skip  skip <=== local carry
  --  i1_t8    i3_t8   i5_t8   i7_t8   skip  skip  skip  skip <=== local carry
  --  i0_if    i2_if   i4_if   i6_if   skip  skip  skip  skip <=== local carry
  --  i1_if    i3_if   i5_if   i7_if   skip  skip  skip  skip <=== local carry
  --  i0_s1x   i2_s1x  i4_s1x  i6_s1x  skip  skip  skip  skip <=== carry select
  --  i1_s1x   i3_s1x  i5_s1x  i7_s1x  skip  skip  skip  skip <=== carry select
  --  i0_s1y   i2_s1y  i4_s1y  i6_s1y  skip  skip  skip  skip <=== carry select
  --  i1_s1y   i3_s1y  i5_s1y  i7_s1y  skip  skip  skip  skip <=== carry select
  --  i0_s1    i2_s1   i4_s1   i6_s1   skip  skip  skip  skip <=== carry select
  --  i1_s1    i3_s1   i5_s1   i7_s1   skip  skip  skip  skip <=== carry select
  --  i0_s0b   i2_s0b  i4_s0b  i6_s0b  skip  skip  skip  skip <=== carry select
  --  i1_s0b   i3_s0b  i5_s0b  i7_s0b  skip  skip  skip  skip <=== carry select
  --  i0_s0    i2_s0   i4_s0   i6_s0   skip  skip  skip  skip <=== carry select
  --  i1_s0    i3_s0   i5_s0   i7_s0   skip  skip  skip  skip <=== carry select

 





BEGIN

  i0_b0: x_b(0) <= not x(0);
  i1_b0: x_b(1) <= not x(1);
  i2_b0: x_b(2) <= not x(2);
  i3_b0: x_b(3) <= not x(3);
  i4_b0: x_b(4) <= not x(4);
  i5_b0: x_b(5) <= not x(5);
  i6_b0: x_b(6) <= not x(6);
  i7_b0: x_b(7) <= not x(7);

  i0_b1: x_p(0) <= not x_b(0);
  i1_b1: x_p(1) <= not x_b(1);
  i2_b1: x_p(2) <= not x_b(2);
  i3_b1: x_p(3) <= not x_b(3);
  i4_b1: x_p(4) <= not x_b(4);
  i5_b1: x_p(5) <= not x_b(5);
  i6_b1: x_p(6) <= not x_b(6);
  i7_b1: x_p(7) <= not x_b(7);

  ----------------------------------------------

  i0_g2: g2_0t1_b <= not( x(0)     and x(1) );  --0--
  i2_g2: g2_2t3_b <= not( x(2)     and x(3) );  --2--
  i4_g2: g2_4t5_b <= not( x(4)     and x(5) );  --4--
  i6_g2: g2_6t7_b <= not( x(6)     and x(7) );  --6--

  i0_g4: g4_0t3   <= not( g2_0t1_b or  g2_2t3_b );--1--
  i4_g4: g4_4t7   <= not( g2_4t5_b or  g2_6t7_b );--5--

  i0_g8: co_b     <= not( g4_0t3   and g4_4t7 ); --3-- ; --output

  ---------------------------------------------

  i2_t2: t2_2t3   <= not( x_b(2)     or  x_b(3) );--2--
  i4_t2: t2_4t5   <= not( x_b(4)     or  x_b(5) );--4--
  i6_t2: t2_6t7   <= not( x_b(6)     or  x_b(7) );--6--

  i2_t4: t4_2t5_b <= not( t2_2t3     and t2_4t5 );--3--
  i4_t4: t4_4t7_b <= not( t2_4t5     and t2_6t7 );--5--
  i6_t4: t4_6t7_b <= not( t2_6t7                );--7--

  i2_t8x: t8_2t7   <= not( t4_2t5_b or  t4_6t7_b );--3--
  i4_t8x: t8_4t7   <= not( t4_4t7_b );             --5--
  i6_t8x: t8_6t7   <= not( t4_6t7_b );             --7--


  i1_t8: t8_1t7_b <= not( t8_2t7 and x_p(1) ); --1--
  i2_t8: t8_2t7_b <= not( t8_2t7            ); --2--
  i3_t8: t8_3t7_b <= not( t8_4t7 and x_p(3) ); --3--
  i4_t8: t8_4t7_b <= not( t8_4t7            ); --4--
  i5_t8: t8_5t7_b <= not( t8_6t7 and x_p(5) ); --5--
  i6_t8: t8_6t7_b <= not( t8_6t7            ); --6--
  i7_t8: t8_7t7_b <= not(            x_p(7) ); --7--


  --------------------------------------

  i0_if: x_if_ci(0) <= not (x_p(0) xor t8_1t7_b) ;
  i1_if: x_if_ci(1) <= not (x_p(1) xor t8_2t7_b) ;
  i2_if: x_if_ci(2) <= not (x_p(2) xor t8_3t7_b) ;
  i3_if: x_if_ci(3) <= not (x_p(3) xor t8_4t7_b) ;
  i4_if: x_if_ci(4) <= not (x_p(4) xor t8_5t7_b) ;
  i5_if: x_if_ci(5) <= not (x_p(5) xor t8_6t7_b) ;
  i6_if: x_if_ci(6) <= not (x_p(6) xor t8_7t7_b) ;
  i7_if: x_if_ci(7) <= not (x_p(7)             ) ;



  i0_s1x: s1x_b(0) <= not( x_p(0) and ci_b ) ;
  i1_s1x: s1x_b(1) <= not( x_p(1) and ci_b ) ;
  i2_s1x: s1x_b(2) <= not( x_p(2) and ci_b ) ;
  i3_s1x: s1x_b(3) <= not( x_p(3) and ci_b ) ;
  i4_s1x: s1x_b(4) <= not( x_p(4) and ci_b ) ;
  i5_s1x: s1x_b(5) <= not( x_p(5) and ci_b ) ;
  i6_s1x: s1x_b(6) <= not( x_p(6) and ci_b ) ;
  i7_s1x: s1x_b(7) <= not( x_p(7) and ci_b ) ;

  i0_s1y: s1y_b(0) <= not( x_if_ci(0) and  ci ) ; 
  i1_s1y: s1y_b(1) <= not( x_if_ci(1) and  ci ) ; 
  i2_s1y: s1y_b(2) <= not( x_if_ci(2) and  ci ) ; 
  i3_s1y: s1y_b(3) <= not( x_if_ci(3) and  ci ) ; 
  i4_s1y: s1y_b(4) <= not( x_if_ci(4) and  ci ) ; 
  i5_s1y: s1y_b(5) <= not( x_if_ci(5) and  ci ) ; 
  i6_s1y: s1y_b(6) <= not( x_if_ci(6) and  ci ) ; 
  i7_s1y: s1y_b(7) <= not( x_if_ci(7) and  ci ) ; 

  i0_s1: s1(0) <= not( s1x_b(0) and s1y_b(0) ); --output
  i1_s1: s1(1) <= not( s1x_b(1) and s1y_b(1) ); --output
  i2_s1: s1(2) <= not( s1x_b(2) and s1y_b(2) ); --output
  i3_s1: s1(3) <= not( s1x_b(3) and s1y_b(3) ); --output
  i4_s1: s1(4) <= not( s1x_b(4) and s1y_b(4) ); --output
  i5_s1: s1(5) <= not( s1x_b(5) and s1y_b(5) ); --output
  i6_s1: s1(6) <= not( s1x_b(6) and s1y_b(6) ); --output
  i7_s1: s1(7) <= not( s1x_b(7) and s1y_b(7) ); --output

  i0_s0b: s0_b(0) <=  not x_p(0) ; 
  i1_s0b: s0_b(1) <=  not x_p(1) ; 
  i2_s0b: s0_b(2) <=  not x_p(2) ; 
  i3_s0b: s0_b(3) <=  not x_p(3) ; 
  i4_s0b: s0_b(4) <=  not x_p(4) ; 
  i5_s0b: s0_b(5) <=  not x_p(5) ; 
  i6_s0b: s0_b(6) <=  not x_p(6) ; 
  i7_s0b: s0_b(7) <=  not x_p(7) ; 

  i0_s0: s0(0) <=  not s0_b(0) ; -- output
  i1_s0: s0(1) <=  not s0_b(1) ; -- output
  i2_s0: s0(2) <=  not s0_b(2) ; -- output
  i3_s0: s0(3) <=  not s0_b(3) ; -- output
  i4_s0: s0(4) <=  not s0_b(4) ; -- output
  i5_s0: s0(5) <=  not s0_b(5) ; -- output
  i6_s0: s0(6) <=  not s0_b(6) ; -- output
  i7_s0: s0(7) <=  not s0_b(7) ; -- output



END; -- ARCH fuq_loc8inc
