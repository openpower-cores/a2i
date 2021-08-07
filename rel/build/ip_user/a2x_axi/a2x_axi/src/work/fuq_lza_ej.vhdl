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


entity fuq_lza_ej is port(
     effsub      :in  std_ulogic;
     sum         :in  std_ulogic_vector(0 to 162);
     car         :in  std_ulogic_vector(53 to 162);  
     lzo_b       :in  std_ulogic_vector(0 to 162);
     edge        :out std_ulogic_vector(0 to 162)
 );
END                                 fuq_lza_ej;


ARCHITECTURE fuq_lza_ej  OF fuq_lza_ej  IS

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

  signal x0, x1, x2 :std_ulogic_vector(0 to 52); 
  signal x1_b, ej_b :std_ulogic_vector(0 to 52);   
  signal g_b, z, p, g, z_b, p_b :std_ulogic_vector(53 to 162);
  signal sum_52_b :std_ulogic;
  signal lzo_54 :std_ulogic;
  signal gz, zg, gg, zz :std_ulogic_vector(55 to 162);
  signal e0_b, e1_b :std_ulogic_vector(53 to 162);
  signal e2_b : std_ulogic_vector(54 to 54);
  signal unused :std_ulogic ;

 





BEGIN

unused <= g(54) or z_b(53) or z_b(162) or p_b(161) or p_b(162) ;


  x0(0 to 52) <= tidn & effsub & sum(0 to 50); 
  x1(0 to 52) <=        effsub & sum(0 to 51); 
  x2(0 to 52) <=                 sum(0 to 52); 
  

  xb_00:   x1_b(0 to 52)   <= not x1(0 to 52) ;
  ejx_00:  ej_b(0 to 52)   <= not( x1_b(0 to 52) and ( x0(0 to 52) or x2(0 to 52) ) ); 
  ej_00:   edge(0 to 52)   <= not( ej_b(0 to 52) and lzo_b(0 to 52) );


  glo_53:   g_b(53)   <= not( sum(53) and car(53) );
  zhi_53:   z  (53)   <= not( sum(53) or  car(53) ); 
  phi_53:   p  (53)   <=    ( sum(53) xor car(53) );

  ghi_53:   g  (53)   <= not( g_b(53) );
  zlo_53:   z_b(53)   <= not( z  (53) );
  plo_53:   p_b(53)   <= not( p  (53) );
  s52_53:   sum_52_b  <= not( sum(52) );

  e0_53:    e0_b(53)  <= not( sum(51)   and sum_52_b              );
  e1_53:    e1_b(53)  <= not(               sum_52_b and g(53)    );
  ej_53:    edge(53)  <= not( lzo_b(53) and e0_b(53) and e1_b(53) ); 



  glo_54:   g_b(54)   <= not( sum(54) and car(54) );
  zhi_54:   z  (54)   <= not( sum(54) or  car(54) ); 
  phi_54:   p  (54)   <=    ( sum(54) xor car(54) );

  ghi_54:   g  (54)   <= not( g_b(54) );
  zlo_54:   z_b(54)   <= not( z  (54) );
  plo_54:   p_b(54)   <= not( p  (54) );

  zb_54:    lzo_54    <= not lzo_b(54);

  e0_54:    e0_b(54)  <= not(  sum_52_b  and p(53)    and z_b(54)    ); 
  e1_54:    e1_b(54)  <= not(  sum(52)   and p(53)    and g_b(54)    ); 
  e2_54:    e2_b(54)  <= not( (sum(52)   and z(53) )  or  lzo_54     );
  ej_54:    edge(54)  <= not(  e0_b(54)  and e1_b(54)  and e2_b(54)  ); 


  glo_55:   g_b(55)   <= not( sum(55) and car(55) );
  zhi_55:   z  (55)   <= not( sum(55) or  car(55) ); 
  phi_55:   p  (55)   <=    ( sum(55) xor car(55) );

  ghi_55:   g  (55)   <= not( g_b(55) );
  zlo_55:   z_b(55)   <= not( z  (55) );
  plo_55:   p_b(55)   <= not( p  (55) );

  gz_55:    gz(55)    <= not( g_b(54) or z(55) );
  zg_55:    zg(55)    <= not( z_b(54) or g(55) );
  gg_55:    gg(55)    <= not( g_b(54) or g(55) );
  zz_55:    zz(55)    <= not( z_b(54) or z(55) );

  e1_55:    e1_b(55)  <= not( p_b(53)  and ( gz(55) or     zg(55) ) ); 
  e0_55:    e0_b(55)  <= not( p  (53)  and ( gg(55) or     zz(55) ) ); 
  ej_55:    edge(55)  <= not( e0_b(55) and e1_b(55) and lzo_b(55) ); 


  glo_56:   g_b(56 to 162)   <= not( sum(56 to 162) and car(56 to 162) );
  zhi_56:   z  (56 to 162)   <= not( sum(56 to 162) or  car(56 to 162) ); 
  phi_56:   p  (56 to 162)   <=    ( sum(56 to 162) xor car(56 to 162) );

  ghi_56:   g  (56 to 162)   <= not( g_b(56 to 162) );
  zlo_56:   z_b(56 to 162)   <= not( z  (56 to 162) );
  plo_56:   p_b(56 to 162)   <= not( p  (56 to 162) );

  gz_56:    gz(56 to 162)    <= not( g_b(55 to 161) or z(56 to 162) );
  zg_56:    zg(56 to 162)    <= not( z_b(55 to 161) or g(56 to 162) );
  gg_56:    gg(56 to 162)    <= not( g_b(55 to 161) or g(56 to 162) );
  zz_56:    zz(56 to 162)    <= not( z_b(55 to 161) or z(56 to 162) );

  e1_56:    e1_b(56 to 162)  <= not( p  (54 to 160) and ( gz(56 to 162) or zg(56 to 162) ) );
  e0_56:    e0_b(56 to 162)  <= not( p_b(54 to 160) and ( gg(56 to 162) or zz(56 to 162) ) ); 
  ej_56:    edge(56 to 162)  <= not( e0_b(56 to 162) and e1_b(56 to 162) and lzo_b(56 to 162) ); 


END; 







