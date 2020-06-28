-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,ibm;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;

library tri;
use tri.tri_latches_pkg.all;
entity xuq_spr_dvccmp is
generic(
   regsize                          :     integer := 64);
port(
   en                               : in  std_ulogic;
   en00                             : in  std_ulogic := '1';
   cmp                              : in  std_ulogic_vector(8-regsize/8 to 7);
   dvcm                             : in  std_ulogic_vector(0 to 1);
   dvcbe                            : in  std_ulogic_vector(8-regsize/8 to 7);   
   dvc_cmpr                         : out std_ulogic
);


--  synopsys translate_off
--  synopsys translate_on
end xuq_spr_dvccmp;
architecture xuq_spr_dvccmp of xuq_spr_dvccmp is

signal cmp_mask_or,cmp_mask_and     : std_ulogic_vector(8-regsize/8 to 7);
signal cmp_and,cmp_or,cmp_andor     : std_ulogic;

begin

   cmp_mask_or          <= gate((cmp or not dvcbe),or_reduce(dvcbe));
   cmp_mask_and         <=      (cmp and    dvcbe);

   cmp_and              <= and_reduce(cmp_mask_or);

   cmp_or               <=  or_reduce(cmp_mask_and);
   
   cmp_andor_gen32 : if regsize = 32 generate
   cmp_andor            <= (and_reduce(cmp_mask_or(4 to 5)) and or_reduce(dvcbe(4 to 5))) or
                           (and_reduce(cmp_mask_or(6 to 7)) and or_reduce(dvcbe(6 to 7)));
   end generate;
   cmp_andor_gen64 : if regsize = 64 generate
   cmp_andor            <= (and_reduce(cmp_mask_or(0 to 1)) and or_reduce(dvcbe(0 to 1))) or
                           (and_reduce(cmp_mask_or(2 to 3)) and or_reduce(dvcbe(2 to 3))) or
                           (and_reduce(cmp_mask_or(4 to 5)) and or_reduce(dvcbe(4 to 5))) or
                           (and_reduce(cmp_mask_or(6 to 7)) and or_reduce(dvcbe(6 to 7)));
   end generate;

   with dvcm(0 to 1) select
      dvc_cmpr          <= en and en00             when "00",
                           en and cmp_and          when "01",
                           en and cmp_or           when "10",
                           en and cmp_andor        when others;

end architecture xuq_spr_dvccmp;
