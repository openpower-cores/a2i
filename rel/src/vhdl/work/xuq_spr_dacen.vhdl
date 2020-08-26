-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU SPR - DAC Enable Component
--

library ieee;
use ieee.std_logic_1164.all;

entity xuq_spr_dacen is
generic(
   threads                          :     integer := 4);
port(
   spr_msr_pr                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_ds                       : in  std_ulogic_vector(0 to threads-1);

   spr_dbcr0_dac                    : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr_dac_us                  : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr_dac_er                  : in  std_ulogic_vector(0 to 2*threads-1);
   
   val                              : in  std_ulogic_vector(0 to threads-1);
   load                             : in  std_ulogic;   
   store                            : in  std_ulogic;
   
   dacr_en                          : out std_ulogic_vector(0 to threads-1);
   dacw_en                          : out std_ulogic_vector(0 to threads-1)
);

--  synopsys translate_off
--  synopsys translate_on

end xuq_spr_dacen;
architecture xuq_spr_dacen of xuq_spr_dacen is

-- Signals
signal dac_ld_en,dac_st_en    : std_ulogic_vector(0 to threads-1);
signal dac_us_en,dac_er_en    : std_ulogic_vector(0 to threads-1);

begin

dacen_gen : for t in 0 to threads-1 generate

   dac_ld_en(t)   <=      spr_dbcr0_dac(0+2*t)   and  load;
   dac_st_en(t)   <=      spr_dbcr0_dac(1+2*t)   and  store;

   dac_us_en(t)   <= (not spr_dbcr_dac_us(0+2*t) and not spr_dbcr_dac_us(1+2*t)) or
                     (    spr_dbcr_dac_us(0+2*t) and    (spr_dbcr_dac_us(1+2*t) xnor spr_msr_pr(t)));

   dac_er_en(t)   <= (not spr_dbcr_dac_er(0+2*t) and not spr_dbcr_dac_er(1+2*t)) or
                     (    spr_dbcr_dac_er(0+2*t) and    (spr_dbcr_dac_er(1+2*t) xnor spr_msr_ds(t)));

   dacr_en(t)     <= val(t) and dac_ld_en(t) and dac_us_en(t) and dac_er_en(t);
   dacw_en(t)     <= val(t) and dac_st_en(t) and dac_us_en(t) and dac_er_en(t);

end generate;

end architecture xuq_spr_dacen;
