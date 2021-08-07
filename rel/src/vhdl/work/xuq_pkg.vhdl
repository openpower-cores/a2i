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

--  Description:  XU Package
--
library ieee;
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
