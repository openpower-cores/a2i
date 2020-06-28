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


entity xuq_agen_csmuxe is port(
     sum_0      :in  std_ulogic_vector(0 to 3) ; 
     sum_1      :in  std_ulogic_vector(0 to 3) ;
     ci_b       :in  std_ulogic ;
     sum        :out std_ulogic_vector(0 to 3)
 );


END                                 xuq_agen_csmuxe;


ARCHITECTURE xuq_agen_csmuxe  OF xuq_agen_csmuxe  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

 signal sum0_b, sum1_b :std_ulogic_vector(0 to 3);
 signal int_ci, int_ci_t, int_ci_b :std_ulogic;








BEGIN

 u_ci:  int_ci   <= not ci_b;
 u_cit: int_ci_t <= not ci_b;
 u_cib: int_ci_b <= not int_ci_t;

 u_sum0_0: sum0_b(0) <= not( sum_0(0) and int_ci_b );
 u_sum0_1: sum0_b(1) <= not( sum_0(1) and int_ci_b );
 u_sum0_2: sum0_b(2) <= not( sum_0(2) and int_ci_b );
 u_sum0_3: sum0_b(3) <= not( sum_0(3) and int_ci_b );

 u_sum1_0: sum1_b(0) <= not( sum_1(0) and int_ci   );
 u_sum1_1: sum1_b(1) <= not( sum_1(1) and int_ci   );
 u_sum1_2: sum1_b(2) <= not( sum_1(2) and int_ci   );
 u_sum1_3: sum1_b(3) <= not( sum_1(3) and int_ci   );

 u_sum_0: sum(0) <= not( sum0_b(0) and sum1_b(0) );
 u_sum_1: sum(1) <= not( sum0_b(1) and sum1_b(1) );
 u_sum_2: sum(2) <= not( sum0_b(2) and sum1_b(2) );
 u_sum_3: sum(3) <= not( sum0_b(3) and sum1_b(3) );


END; 

