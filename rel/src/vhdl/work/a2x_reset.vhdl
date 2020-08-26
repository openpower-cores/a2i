-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

-- both resets are negative-active!

entity a2x_reset is
  port (
        clk               : in  std_logic;
        reset_in          : in  std_logic;
        reset             : out std_logic
  );                       
end a2x_reset;              
                           
architecture a2x_reset of a2x_reset is
   constant reset_period   : integer := 32;
   signal reset_in_q : std_logic := '0';
   signal reset_q : std_logic := '0';
   signal counter_q : std_logic_vector(0 to 31) := x"00000000";

function inc(a: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a'length-1);
begin
  res := std_logic_vector(unsigned(a) + 1);
  return res;
end function;
function eq(a: in std_logic_vector; b: in integer) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) = b;
  return res;
end function;
function leq(a: in std_logic_vector; b: in integer) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) <= b;
  return res;
end function;

begin

   FF: process (clk) begin
  
   if (rising_edge(clk)) then
   
      reset_in_q <= reset_in;
      
      if (reset_in_q = '1' and reset_in = '0') then   -- edge-trigger hi->lo
         counter_q <= (others => '0');
	   elsif (leq(counter_q, reset_period)) then     -- reset period
         counter_q <= inc(counter_q);	
	      reset_q <= '0';
	   else                                            -- normal
         counter_q <= counter_q;	
	      reset_q <= '1';
	   end if;
   
   end if;
  
  end process;     
  
  reset <= reset_q;  

end architecture a2x_reset;
