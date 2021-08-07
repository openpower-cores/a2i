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


-- this is used in the agen  ... for this byte (half the bits go to ERAT through this macro, others go to DIR from different macro

entity xuq_agen_locae is port(
     addr_sel   :in  std_ulogic ; -- includes "AND mode64" for bits 0 to 31
     addr_nsel  :in  std_ulogic ; -- includes "AND mode64" for bits 0 to 31
     addr       :in  std_ulogic_vector(0 to 3) ;
     x_b        :in  std_ulogic_vector(0 to 7) ; -- after xor
     y_b        :in  std_ulogic_vector(0 to 7) ;
     sum_0      :out std_ulogic_vector(0 to 3) ;
     sum_1      :out std_ulogic_vector(0 to 3) 
 );


END                                 xuq_agen_locae;


ARCHITECTURE xuq_agen_locae  OF xuq_agen_locae  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';


    signal x     :std_ulogic_vector(0 to 7);
    signal y     :std_ulogic_vector(0 to 7);
    signal g01_b :std_ulogic_vector(1 to 7);
    signal t01_b :std_ulogic_vector(1 to 7);
    signal p01   :std_ulogic_vector(0 to 3);
    signal p01_b :std_ulogic_vector(0 to 3);


 signal  g08_b  :std_ulogic_vector(1 to 4);
 signal  g08    :std_ulogic_vector(1 to 4);
 signal  g04_b  :std_ulogic_vector(1 to 7);
 signal  g02    :std_ulogic_vector(1 to 7);
 signal  t02    :std_ulogic_vector(1 to 7);
 signal  t04_b  :std_ulogic_vector(1 to 7);
 signal  t08    :std_ulogic_vector(1 to 4);
 signal  t08_b  :std_ulogic_vector(1 to 4);


  signal h01, h01_b :std_ulogic_vector(0 to 3);


BEGIN


  --####################################################################
  --# inverter at top to drive to bit location
  --####################################################################

    u_xi: x(0 to 7) <= not x_b(0 to 7) ; -- maybe should be fat wire
    u_yi: y(0 to 7) <= not y_b(0 to 7) ; -- maybe should be fat wire

  --####################################################################
  --# pgt
  --####################################################################

    u_g01:    g01_b(1 to 7) <= not( x(1 to 7) and  y(1 to 7) );
    u_t01:    t01_b(1 to 7) <= not( x(1 to 7) or   y(1 to 7) );
    u_p01b:   p01_b(0 to 3) <= not( x(0 to 3) xor  y(0 to 3) );
    u_p01:    p01  (0 to 3) <= not( p01_b(0 to 3) );

  --####################################################################
  --# local carry
  --####################################################################

  u_g02_1: g02(1) <= not( g01_b(1) and ( t01_b(1) or  g01_b(2) ) ) ;
  u_g02_2: g02(2) <= not( g01_b(2) and ( t01_b(2) or  g01_b(3) ) ) ;
  u_g02_3: g02(3) <= not( g01_b(3) and ( t01_b(3) or  g01_b(4) ) ) ;
  u_g02_4: g02(4) <= not( g01_b(4) and ( t01_b(4) or  g01_b(5) ) ) ;
  u_g02_5: g02(5) <= not( g01_b(5) and ( t01_b(5) or  g01_b(6) ) ) ;
  u_g02_6: g02(6) <= not( g01_b(6) and ( t01_b(6) or  g01_b(7) ) ) ;--final--
  u_g02_7: g02(7) <= not( g01_b(7)                               ) ;

  u_t02_1: t02(1) <= not(                t01_b(1) or  t01_b(2)   ) ;
  u_t02_2: t02(2) <= not(                t01_b(2) or  t01_b(3)   ) ;
  u_t02_3: t02(3) <= not(                t01_b(3) or  t01_b(4)   ) ;
  u_t02_4: t02(4) <= not(                t01_b(4) or  t01_b(5)   ) ;
  u_t02_5: t02(5) <= not(                t01_b(5) or  t01_b(6)   ) ;
  u_t02_6: t02(6) <= not( g01_b(6) and ( t01_b(6) or  t01_b(7) ) ) ;--final--
  u_t02_7: t02(7) <= not(                t01_b(7)                ) ;



  u_g04_1: g04_b(1) <= not( g02(1) or  ( t02(1) and g02(3) ) ) ;
  u_g04_2: g04_b(2) <= not( g02(2) or  ( t02(2) and g02(4) ) ) ;
  u_g04_3: g04_b(3) <= not( g02(3) or  ( t02(3) and g02(5) ) ) ;
  u_g04_4: g04_b(4) <= not( g02(4) or  ( t02(4) and g02(6) ) ) ;--final--
  u_g04_5: g04_b(5) <= not( g02(5) or  ( t02(5) and g02(7) ) ) ;--final--
  u_g04_6: g04_b(6) <= not( g02(6)                           ) ;
  u_g04_7: g04_b(7) <= not( g02(7)                           ) ;

  u_t04_1: t04_b(1) <= not(              t02(1) and t02(3)   ) ;
  u_t04_2: t04_b(2) <= not(              t02(2) and t02(4)   ) ;
  u_t04_3: t04_b(3) <= not(              t02(3) and t02(5)   ) ;
  u_t04_4: t04_b(4) <= not( g02(4) or  ( t02(4) and t02(6) ) ) ;--final--
  u_t04_5: t04_b(5) <= not( g02(5) or  ( t02(5) and t02(7) ) ) ;--final--
  u_t04_6: t04_b(6) <= not(              t02(6)              ) ;
  u_t04_7: t04_b(7) <= not(              t02(7)              ) ;



  u_g08_1: g08(1) <= not( g04_b(1) and ( t04_b(1) or  g04_b(5) ) ) ;--final--
  u_g08_2: g08(2) <= not( g04_b(2) and ( t04_b(2) or  g04_b(6) ) ) ;--final--
  u_g08_3: g08(3) <= not( g04_b(3) and ( t04_b(3) or  g04_b(7) ) ) ;--final--
  u_g08_4: g08(4) <= not( g04_b(4)                               ) ;

  u_t08_1: t08(1) <= not( g04_b(1) and ( t04_b(1) or  t04_b(5) ) ) ;--final--
  u_t08_2: t08(2) <= not( g04_b(2) and ( t04_b(2) or  t04_b(6) ) ) ;--final--
  u_t08_3: t08(3) <= not( g04_b(3) and ( t04_b(3) or  t04_b(7) ) ) ;--final--
  u_t08_4: t08(4) <= not(                t04_b(4)                ) ;




  --####################################################################
  --# conditional sums  // may need to make NON-xor implementation
  --####################################################################

    u_g08i_1: g08_b(1) <= not g08(1) ;
    u_g08i_2: g08_b(2) <= not g08(2) ;
    u_g08i_3: g08_b(3) <= not g08(3) ;
    u_g08i_4: g08_b(4) <= not g08(4) ;

    u_t08i_1: t08_b(1) <= not t08(1) ;
    u_t08i_2: t08_b(2) <= not t08(2) ;
    u_t08i_3: t08_b(3) <= not t08(3) ;
    u_t08i_4: t08_b(4) <= not t08(4) ;



    u_h01:  h01  (0 to 3) <= not( (p01_b(0 to 3) and (0 to 3=> addr_nsel)  ) or
                                  (addr (0 to 3) and (0 to 3=> addr_sel )  ) );

    u_h01b: h01_b(0 to 3) <= not( (p01  (0 to 3) and (0 to 3=> addr_nsel)  ) or
                                  (addr (0 to 3) and (0 to 3=> addr_sel )  ) );


    u_sum_0_0: sum_0(0) <= not(  ( h01(0) and  g08(1) ) or  ( h01_b(0) and  g08_b(1) )   ); --output--
    u_sum_0_1: sum_0(1) <= not(  ( h01(1) and  g08(2) ) or  ( h01_b(1) and  g08_b(2) )   ); --output--
    u_sum_0_2: sum_0(2) <= not(  ( h01(2) and  g08(3) ) or  ( h01_b(2) and  g08_b(3) )   ); --output--
    u_sum_0_3: sum_0(3) <= not(  ( h01(3) and  g08(4) ) or  ( h01_b(3) and  g08_b(4) )   ); --output--
                                    
                                    
    u_sum_1_0: sum_1(0) <= not(  ( h01(0) and  t08(1) ) or  ( h01_b(0) and  t08_b(1) )   ); --output--
    u_sum_1_1: sum_1(1) <= not(  ( h01(1) and  t08(2) ) or  ( h01_b(1) and  t08_b(2) )   ); --output--
    u_sum_1_2: sum_1(2) <= not(  ( h01(2) and  t08(3) ) or  ( h01_b(2) and  t08_b(3) )   ); --output--
    u_sum_1_3: sum_1(3) <= not(  ( h01(3) and  t08(4) ) or  ( h01_b(3) and  t08_b(4) )   ); --output--
                                    
                                    


END; -- ARCH xuq_agen_locae
