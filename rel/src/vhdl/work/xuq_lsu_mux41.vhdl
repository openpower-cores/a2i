-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee; use ieee.std_logic_1164.all;
library support; 
                 use support.power_logic_pkg.all;

entity xuq_lsu_mux41 is
  port (
        vdd             :inout power_logic;
        gnd             :inout power_logic;
        D0              :in  std_ulogic;
        D1              :in  std_ulogic;
        D2              :in  std_ulogic;
        D3              :in  std_ulogic; 
        S0              :in  std_ulogic;
        S1              :in  std_ulogic;
        S2              :in  std_ulogic;
        S3              :in  std_ulogic; 
        Y               :out std_ulogic
  );



end entity xuq_lsu_mux41;

architecture xuq_lsu_mux41 of xuq_lsu_mux41 is

signal y0_b     :std_ulogic;
signal y1_b     :std_ulogic;


begin

u_y0: y0_b <= not( (D0 and S0) or (D1 and S1) );
u_y1: y1_b <= not( (D2 and S2) or (D3 and S3) );
u_y:  Y    <= not(y0_b and y1_b);

end xuq_lsu_mux41;

