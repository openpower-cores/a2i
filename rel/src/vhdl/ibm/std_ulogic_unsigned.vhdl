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

--***************************************************************************
-- Copyright 2020 International Business Machines
--
-- Licensed under the Apache License, Version 2.0 (the “License”);
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- The patent license granted to you in Section 3 of the License, as applied
-- to the “Work,” hereby includes implementations of the Work in physical form.
--
-- Unless required by applicable law or agreed to in writing, the reference design
-- distributed under the License is distributed on an “AS IS” BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
--***************************************************************************
library IEEE, IBM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IBM.std_ulogic_support.all;

package std_ulogic_unsigned is

    function "+"(l: std_ulogic_vector; 	r: std_ulogic_vector) return std_ulogic_vector;
    function "+"(l: std_ulogic_vector; 	r: integer)          return std_ulogic_vector;
    function "+"(l: integer; 		r: std_ulogic_vector) return std_ulogic_vector;
    function "+"(l: std_ulogic_vector;	r: std_ulogic)        return std_ulogic_vector;
    function "+"(l: std_ulogic; 		r: std_ulogic_vector) return std_ulogic_vector;

    function "-"(l: std_ulogic_vector; 	r: std_ulogic_vector) return std_ulogic_vector;
    function "-"(l: std_ulogic_vector; 	r: integer)          return std_ulogic_vector;
    function "-"(l: integer; 		r: std_ulogic_vector) return std_ulogic_vector;
    function "-"(l: std_ulogic_vector; 	r: std_ulogic)        return std_ulogic_vector;
    function "-"(l: std_ulogic; 		r: std_ulogic_vector) return std_ulogic_vector;

    function "+"(l: std_ulogic_vector)                        return std_ulogic_vector;

    function "*"(l: std_ulogic_vector; 	r: std_ulogic_vector) return std_ulogic_vector;

  function "=" ( l : natural;          r : std_ulogic_vector) return boolean;
  function "/="( l : natural;          r : std_ulogic_vector) return boolean;
  function "<" ( l : natural;          r : std_ulogic_vector) return boolean;
  function "<="( l : natural;          r : std_ulogic_vector) return boolean;
  function ">" ( l : natural;          r : std_ulogic_vector) return boolean;
  function ">="( l : natural;          r : std_ulogic_vector) return boolean;

  function "=" ( l : std_ulogic_vector; r : natural)          return boolean;
  function "/="( l : std_ulogic_vector; r : natural)          return boolean;
  function "<" ( l : std_ulogic_vector; r : natural)          return boolean;
  function "<="( l : std_ulogic_vector; r : natural)          return boolean;
  function ">" ( l : std_ulogic_vector; r : natural)          return boolean;
  function ">="( l : std_ulogic_vector; r : natural)          return boolean;
  
  function "=" ( l : natural;          r : std_ulogic_vector) return std_ulogic;
  function "/="( l : natural;          r : std_ulogic_vector) return std_ulogic;
  function "<" ( l : natural;          r : std_ulogic_vector) return std_ulogic;
  function "<="( l : natural;          r : std_ulogic_vector) return std_ulogic;
  function ">" ( l : natural;          r : std_ulogic_vector) return std_ulogic;
  function ">="( l : natural;          r : std_ulogic_vector) return std_ulogic;

  function "=" ( l : std_ulogic_vector; r : natural)          return std_ulogic;
  function "/="( l : std_ulogic_vector; r : natural)          return std_ulogic;
  function "<" ( l : std_ulogic_vector; r : natural)          return std_ulogic;
  function "<="( l : std_ulogic_vector; r : natural)          return std_ulogic;
  function ">" ( l : std_ulogic_vector; r : natural)          return std_ulogic;
  function ">="( l : std_ulogic_vector; r : natural)          return std_ulogic;

  function to_integer( d : std_ulogic_vector ) return natural;
  -- synopsys translate_off
  attribute type_convert        of to_integer : function is true;
  attribute btr_name            of to_integer : function is "PASS";
  attribute pin_bit_information of to_integer : function is
           (1 => ("   ","A0      ","INCR","PIN_BIT_SCALAR"),
            2 => ("   ","10      ","INCR","PIN_BIT_SCALAR"));
  -- synopsys translate_on
  
  -- synopsys translate_off
  function to_std_ulogic_vector( d : natural; w : positive ) return std_ulogic_vector;
  attribute type_convert        of to_std_ulogic_vector : function is true;
  attribute btr_name            of to_std_ulogic_vector : function is "PASS";
  attribute pin_bit_information of to_std_ulogic_vector : function is
           (1 => ("   ","A0      ","INCR","PIN_BIT_SCALAR"),
            2 => ("   ","10      ","INCR","PIN_BIT_SCALAR"));
  -- synopsys translate_on
  
end std_ulogic_unsigned;

package body std_ulogic_unsigned is

    function maximum(L, R: INTEGER) return INTEGER is
    begin
        if L > R then
            return L;
        else
            return R;
        end if;
    end;

    function "+"(L: STD_ULOGIC_VECTOR; R: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        constant length : INTEGER := maximum(L'length, R'length);
        variable result : UNSIGNED(length-1 downto 0);
        -- pragma label_applies_to plus
    begin
        result  := UNSIGNED(L) + UNSIGNED(R);  -- pragma label plus
        return   std_ulogic_vector(result);
    end;

    function "+"(L: STD_ULOGIC_VECTOR; R: INTEGER) return STD_ULOGIC_VECTOR is
       variable result  : STD_ULOGIC_VECTOR (L'range);
        -- pragma label_applies_to plus
    begin
        result := std_ulogic_vector( UNSIGNED(L) + R ); -- pragma label plus
        return  result ;
    end;

    function "+"(L: INTEGER; R: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (R'range);
        -- pragma label_applies_to plus
    begin
        result := std_ulogic_vector( L + UNSIGNED(R) ); -- pragma label plus
        return  result;
    end;

    function "+"(L: STD_ULOGIC_VECTOR; R: STD_ULOGIC) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (L'range);
        -- pragma label_applies_to plus
    begin
        if R = '1' then
           result := std_ulogic_vector( UNSIGNED(L) + 1 );
        else
           result := L;
        end if; 
        return result ;
    end;

    function "+"(L: STD_ULOGIC; R: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (R'range);
        -- pragma label_applies_to plus
    begin
        if L = '1' then
           result := std_ulogic_vector( UNSIGNED(R) + 1 );
        else
           result := R;
        end if; 
        return result ;
    end;

    function "+"(L: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (L'range);
        -- pragma label_applies_to plus
    begin
        result := L;
        return result ;
    end;

    function "-"(L: STD_ULOGIC_VECTOR; R: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        constant length: INTEGER := maximum(L'length, R'length);
        variable result  : STD_ULOGIC_VECTOR (length-1 downto 0);
        -- pragma label_applies_to minus
    begin
        result := std_ulogic_vector( UNSIGNED(L) - UNSIGNED(R) ); -- pragma label minus
        return  result ;
    end;

    function "-"(L: STD_ULOGIC_VECTOR; R: INTEGER) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (L'range);
        -- pragma label_applies_to minus
    begin
        result  := std_ulogic_vector( UNSIGNED(L) - R ); -- pragma label minus
        return  result ;
    end;

    function "-"(L: INTEGER; R: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (R'range);
        -- pragma label_applies_to minus
    begin
        result  := std_ulogic_vector( L - UNSIGNED(R) ); -- pragma label minus
        return   result ;
    end;

    function "-"(L: STD_ULOGIC_VECTOR; R: STD_ULOGIC) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (L'range);
        -- pragma label_applies_to minus
    begin
        if R = '1' then
           result  := std_ulogic_vector( UNSIGNED(L) - 1 );
        else
           result  := L;
        end if;
        return  result ;
    end;

    function "-"(L: STD_ULOGIC; R: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        variable result  : STD_ULOGIC_VECTOR (R'range);
        -- pragma label_applies_to minus
    begin
        if L = '1' then
           result  := std_ulogic_vector( 1 - UNSIGNED(R) );
        else
           result  := std_ulogic_vector( 0 - UNSIGNED(R) );
        end if;
        return  result ;
    end;

    function "*"(L: STD_ULOGIC_VECTOR; R: STD_ULOGIC_VECTOR) return STD_ULOGIC_VECTOR is
        constant length: INTEGER := maximum(L'length, R'length);
        variable result  : STD_ULOGIC_VECTOR ((L'length+R'length-1) downto 0);
        -- pragma label_applies_to mult
    begin
        result := std_ulogic_vector( UNSIGNED(L) * UNSIGNED(R) ); -- pragma label mult
        return result ;
    end;

  function "=" ( l : natural;          r : std_ulogic_vector) return boolean is
  begin
    return l = unsigned(r);
  end "=";
  
  function "/="( l : natural;          r : std_ulogic_vector) return boolean is
  begin
    return l /= unsigned(r);
  end "/=";
  
  function "<" ( l : natural;          r : std_ulogic_vector) return boolean is
  begin
    return l < unsigned(r);
  end "<";
  
  function "<="( l : natural;          r : std_ulogic_vector) return boolean is
  begin
    return l <= unsigned(r);
  end "<=";
  
  function ">" ( l : natural;          r : std_ulogic_vector) return boolean is
  begin
    return l > unsigned(r);
  end ">";
  
  function ">="( l : natural;          r : std_ulogic_vector) return boolean is
  begin
    return l >= unsigned(r);
  end ">=";
  
  function "=" ( l : std_ulogic_vector; r : natural)          return boolean is
  begin
    return unsigned(l) = r;
  end "=";
  
  function "/="( l : std_ulogic_vector; r : natural)          return boolean is
  begin
    return unsigned(l) /= r;
  end "/=";
  
  function "<" ( l : std_ulogic_vector; r : natural)          return boolean is
  begin
    return unsigned(l) < r;
  end "<";
  
  function "<="( l : std_ulogic_vector; r : natural)          return boolean is
  begin
    return unsigned(l) <= r;
  end "<=";
  
  function ">" ( l : std_ulogic_vector; r : natural)          return boolean is
  begin
    return unsigned(l) > r;
  end ">";
  
  function ">="( l : std_ulogic_vector; r : natural)          return boolean is
  begin
    return unsigned(l) >= r;
  end ">=";
  
  function "=" ( l : natural;          r : std_ulogic_vector) return std_ulogic is
  begin
    return tconv( l = unsigned(r) );
  end "=";
  
  function "/="( l : natural;          r : std_ulogic_vector) return std_ulogic is
  begin
    return tconv( l /= unsigned(r) );
  end "/=";
  
  function "<" ( l : natural;          r : std_ulogic_vector) return std_ulogic is
  begin
    return tconv( l < unsigned(r) );
  end "<";
  
  function "<="( l : natural;          r : std_ulogic_vector) return std_ulogic is
  begin
    return tconv( l <= unsigned(r) );
  end "<=";
  
  function ">" ( l : natural;          r : std_ulogic_vector) return std_ulogic is
  begin
    return tconv( l > unsigned(r) );
  end ">";
  
  function ">="( l : natural;          r : std_ulogic_vector) return std_ulogic is
  begin
    return tconv( l >= unsigned(r) );
  end ">=";
  
  function "=" ( l : std_ulogic_vector; r : natural)          return std_ulogic is
  begin
    return tconv( unsigned(l) = r );
  end "=";
  
  function "/="( l : std_ulogic_vector; r : natural)          return std_ulogic is
  begin
    return tconv( unsigned(l) /= r );
  end "/=";
  
  function "<" ( l : std_ulogic_vector; r : natural)          return std_ulogic is
  begin
    return tconv( unsigned(l) < r );
  end "<";
  
  function "<="( l : std_ulogic_vector; r : natural)          return std_ulogic is
  begin
    return tconv( unsigned(l) <= r );
  end "<=";
  
  function ">" ( l : std_ulogic_vector; r : natural)          return std_ulogic is
  begin
    return tconv( unsigned(l) > r );
  end ">";
  
  function ">="( l : std_ulogic_vector; r : natural)          return std_ulogic is
  begin
    return tconv( unsigned(l) >= r );
  end ">=";
  
  function to_integer( d : std_ulogic_vector ) return natural is
  begin
    return tconv( d );
  end to_integer;
  
  function to_std_ulogic_vector( d : natural; w : positive ) return std_ulogic_vector is
  begin
    return tconv( d, w );
  end to_std_ulogic_vector;
  
end std_ulogic_unsigned;
