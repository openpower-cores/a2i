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

package xuq_pkg is
   subtype s1                                   is std_ulogic;
   subtype s2                                   is std_ulogic_vector(0 to 1);
   subtype s3                                   is std_ulogic_vector(0 to 2);
   subtype s4                                   is std_ulogic_vector(0 to 3);
   subtype s5                                   is std_ulogic_vector(0 to 4);
   subtype s6                                   is std_ulogic_vector(0 to 5);
   subtype s7                                   is std_ulogic_vector(0 to 6);

   function fanout(in0  : std_ulogic;        size : natural) return std_ulogic_vector;
   function fanout(in0  : std_ulogic_vector; size : natural) return std_ulogic_vector;
   function encode( input  : std_ulogic_vector) return  std_ulogic_vector;
   function or_reduce_t(in0   : std_ulogic_vector; threads : integer) return std_ulogic_vector;
   function mux_t(in0   : std_ulogic_vector; gate : std_ulogic_vector) return std_ulogic_vector;
   procedure mark_unused(input : std_ulogic);
   procedure mark_unused(input : std_ulogic_vector);
   
   
end xuq_pkg;

package body xuq_pkg is 

   procedure mark_unused(input : std_ulogic) is
      variable unused : std_ulogic;
   --  synopsys translate_off
   --  synopsys translate_on
   begin
      unused := input;
   end mark_unused;

   procedure mark_unused(input : std_ulogic_vector) is
      variable unused : std_ulogic_vector(input'range);
   --  synopsys translate_off
   --  synopsys translate_on
   begin
      unused := input;
   end mark_unused;


   function fanout(in0  : std_ulogic_vector; size : natural) return std_ulogic_vector is
         variable result     : std_ulogic_vector(0 to size-1);
         variable fan        : natural;
      begin
         fan := in0'length;
         for i in 0 to size-1 loop
            result(i)   := in0(i mod fan);
         end loop;
      return result;
   end fanout;

   function fanout(in0  : std_ulogic; size : natural) return std_ulogic_vector is
         variable result     : std_ulogic_vector(0 to size-1);
      begin
         result := (others=>in0);
      return result;
   end fanout;


   function mux_t(in0   : std_ulogic_vector; gate : std_ulogic_vector) return std_ulogic_vector  is
      variable in1        : std_ulogic_vector(0 to in0'length-1);
      variable result     : std_ulogic_vector(0 to in0'length/gate'length-1);
   begin
      
      in1      := in0;
      result   := (others=>'0');
      for i in 0 to result'length-1 loop
         for t in 0 to gate'length-1 loop
            result(i) := result(i) or (in1(i+t*result'length) and gate(t));
         end loop;
      end loop;
      return result;
  end mux_t;

   function or_reduce_t(in0   : std_ulogic_vector; threads : integer) return std_ulogic_vector  is
      variable in1        : std_ulogic_vector(0 to in0'length-1);
      variable result     : std_ulogic_vector(0 to in0'length/threads-1);
   begin
      in1      := in0;
      result   := (others=>'0');
      for i in 0 to result'length-1 loop
         for t in 0 to threads-1 loop
            result(i) := result(i) or in1(i+t*result'length);
         end loop;
      end loop;
      return result;
  end or_reduce_t;


   function encode( input  : std_ulogic_vector) return  std_ulogic_vector is
      variable result : std_ulogic_vector(3 downto 0);
   begin  
      if    (input'length = 1) then
         return("0");
      elsif (input'length = 2) then
         return(input(input'right to input'right));
      elsif (input'length = 4) then
         case s4'(input) is
            when "0001" => result := "0011";
            when "0010" => result := "0010";
            when "0100" => result := "0001";
            when others => result := "0000";
         end case;
         return(result(1 downto 0));
      else
         assert (TRUE)
            report "Length field is too large"
            severity error;
         return("X");
      end if;
   end;
   
end xuq_pkg;

