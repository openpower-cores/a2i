-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


-- *!****************************************************************
-- *! FILENAME    : c_scom_addr_decode.vhdl
-- *! TITLE       :
-- *! DESCRIPTION : Generic SCOM address decoder
-- *!
-- *!****************************************************************

library ieee,ibm,clib,support;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;

entity c_scom_addr_decode is
   generic( satid_nobits  : positive := 5        -- should not be set by user
          -- Set the following 3 vectors to generate an SCOM address
          --  HEX  >>>>>                              "0000000000000000111111111111111122222222222222223333333333333333"
          --  ADDR >>>>>                              "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
          --
          --  DEC  >>>>>                              "0000000000111111111122222222223333333333444444444455555555556666"
          --  ADDR >>>>>                              "0123456789012345678901234567890123456789012345678901234567890123"
          ; use_addr           : std_ulogic_vector := "1"
          ; addr_is_rdable     : std_ulogic_vector := "1"
          ; addr_is_wrable     : std_ulogic_vector := "1"
          );
   port( sc_addr     : in  std_ulogic_vector(0 to 11-satid_nobits-1) -- binary coded scom address
       ; scaddr_dec  : out std_ulogic_vector(0 to use_addr'length-1) -- one hot coded scom address; not latched
       ; sc_req      : in  std_ulogic                                -- scom request
       ; sc_r_nw     : in  std_ulogic                                -- read / not write bit
       ; scaddr_nvld : out std_ulogic                                -- scom address not valid; not latched
       ; sc_wr_nvld  : out std_ulogic                                -- scom write not allowed; not latched
       ; sc_rd_nvld  : out std_ulogic                                -- scom read  not allowed; not latched
       ; vd : inout power_logic
       ; gd : inout power_logic
       );

end c_scom_addr_decode;



architecture c_scom_addr_decode of c_scom_addr_decode is
   signal address : std_ulogic_vector(0 to use_addr'length-1);
begin
   decode_it : for i in 0 to use_addr'length-1 generate
      address(i) <= ((sc_addr = tconv(i,sc_addr'length)) and (use_addr(i)='1'));
   end generate decode_it;

   scaddr_dec  <= address;
   scaddr_nvld <= sc_req and not or_reduce(address);
   sc_wr_nvld  <= not or_reduce(address and addr_is_wrable) and sc_req and not sc_r_nw;
   sc_rd_nvld  <= not or_reduce(address and addr_is_rdable) and sc_req and     sc_r_nw;
end c_scom_addr_decode;
