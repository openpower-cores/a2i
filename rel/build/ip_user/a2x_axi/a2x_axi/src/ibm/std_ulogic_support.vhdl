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
library ieee, ibm ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

package std_ulogic_support is

  type base_t is ( bin, oct, dec, hex );

  -------------------------------------------------------------------
  -- Overloaded Relational Operator that can return std_ulogic
  -------------------------------------------------------------------
  function "="    ( l,r : integer ) return std_ulogic;
  function "/="   ( l,r : integer ) return std_ulogic;
  function ">"    ( l,r : integer ) return std_ulogic;
  function ">="   ( l,r : integer ) return std_ulogic;
  function "<"    ( l,r : integer ) return std_ulogic;
  function "<="   ( l,r : integer ) return std_ulogic;

  function "="    ( l,r : std_ulogic ) return std_ulogic;
  function "/="   ( l,r : std_ulogic ) return std_ulogic;
  function ">"    ( l,r : std_ulogic ) return std_ulogic;
  function ">="   ( l,r : std_ulogic ) return std_ulogic;
  function "<"    ( l,r : std_ulogic ) return std_ulogic;
  function "<="   ( l,r : std_ulogic ) return std_ulogic;

  function "="    ( l, r : std_ulogic_vector ) return std_ulogic;
  function "/="   ( l, r : std_ulogic_vector ) return std_ulogic;
  function ">"    ( l, r : std_ulogic_vector ) return std_ulogic;
  function ">="   ( l, r : std_ulogic_vector ) return std_ulogic;
  function "<"    ( l, r : std_ulogic_vector ) return std_ulogic;
  function "<="   ( l, r : std_ulogic_vector ) return std_ulogic;
-- synopsys translate_off
  attribute like_builtin of "="  :function is true;
  attribute like_builtin of "/=" :function is true;
  attribute like_builtin of ">"  :function is true;
  attribute like_builtin of ">=" :function is true;
  attribute like_builtin of "<"  :function is true;
  attribute like_builtin of "<=" :function is true;
-- Synopsys translate_on
  -------------------------------------------------------------------
  -- Relational Functions that can return Boolean
  -------------------------------------------------------------------
  function eq( l,r : std_ulogic ) return boolean;
  function ne( l,r : std_ulogic ) return boolean;
  function gt( l,r : std_ulogic ) return boolean;
  function ge( l,r : std_ulogic ) return boolean;
  function lt( l,r : std_ulogic ) return boolean;
  function le( l,r : std_ulogic ) return boolean;

  -------------------------------------------------------------------
  -- Relational Functions that can return std_ulogic
  -------------------------------------------------------------------

  function eq( l,r : std_ulogic ) return std_ulogic;
  function ne( l,r : std_ulogic ) return std_ulogic;
  function gt( l,r : std_ulogic ) return std_ulogic;
  function ge( l,r : std_ulogic ) return std_ulogic;
  function lt( l,r : std_ulogic ) return std_ulogic;
  function le( l,r : std_ulogic ) return std_ulogic;

  -------------------------------------------------------------------
  -- Vectorized Relational Functions
  -------------------------------------------------------------------

  function eq( l,r : std_ulogic_vector ) return boolean;
  function ne( l,r : std_ulogic_vector ) return boolean;
  function gt( l,r : std_ulogic_vector ) return boolean;
  function ge( l,r : std_ulogic_vector ) return boolean;
  function lt( l,r : std_ulogic_vector ) return boolean;
  function le( l,r : std_ulogic_vector ) return boolean;

  function eq( l,r : std_ulogic_vector ) return std_ulogic;
  function ne( l,r : std_ulogic_vector ) return std_ulogic;
  function gt( l,r : std_ulogic_vector ) return std_ulogic;
  function ge( l,r : std_ulogic_vector ) return std_ulogic;
  function lt( l,r : std_ulogic_vector ) return std_ulogic;
  function le( l,r : std_ulogic_vector ) return std_ulogic;
-- Synopsys translate_off
  attribute functionality of eq : function is "=";
  attribute functionality of ne : function is "/=";
  attribute functionality of gt : function is ">";
  attribute functionality of ge : function is ">=";
  attribute functionality of lt : function is "<";
  attribute functionality of le : function is "<=";

  attribute dc_allow of eq : function is true;
  attribute dc_allow of ne : function is true;
-- Synopsys translate_on

  -------------------------------------------------------------------
  -- Type Conversion Functions
  -------------------------------------------------------------------

  -- Boolean conversion to other types
  function tconv( b : boolean          ) return  bit;
  function tconv( b : boolean          ) return  std_ulogic;
-- Synopsys translate_off
  function tconv( b : boolean          ) return  string;
-- Synopsys translate_on

  -- Bit to other types
  function tconv( b : bit        ) return  boolean;
  function tconv( b : bit        ) return  integer;
  function tconv( b : bit        ) return  std_ulogic;
-- Synopsys translate_off
  function tconv( b : bit        ) return  character;
  function tconv( b : bit        ) return  string;
-- Synopsys translate_on

  -- Bit_vector to other types
  function tconv( b : bit_vector ) return  integer;
  function tconv( b : bit_vector ) return  std_ulogic_vector;
--  function tconv( b : bit_vector ) return  std_logic_vector;
-- synopsys translate_off
  function tconv( b : bit_vector ) return  string;
  function tconv( b : bit_vector; base : base_t  ) return  string;
-- synopsys translate_on

  -- Integer conversion to other types
  function tconv( n : integer; w: positive ) return bit_vector ;
  function tconv( n : integer; w: positive ) return std_ulogic_vector ;
-- synopsys translate_off
  function tconv( n : integer; w: positive ) return string  ;
  function tconv( n : integer              ) return string  ;
-- synopsys translate_on

-- Synopsys translate_off
  -- String conversion to other types
  function tconv( s : string                ) return integer ;
  function tconv( s : string; base : base_t ) return integer ;
  function tconv( s : string                ) return bit ;
  function tconv( s : string                ) return bit_vector ;
  function tconv( s : string; base : base_t ) return bit_vector ;
  function tconv( s : string                ) return std_ulogic ;
  function tconv( s : string                ) return std_ulogic_vector ;
  function tconv( s : string; base : base_t ) return std_ulogic_vector ;
-- Synopsys translate_on

  -- Std_uLogic to other types
  function tconv( s : std_ulogic       ) return  boolean;
  function tconv( s : std_ulogic       ) return  bit;
  function tconv( s : std_ulogic       ) return  integer;
  function tconv( s : std_ulogic       ) return  std_ulogic_vector;
-- synopsys translate_off
  function tconv( s : std_ulogic       ) return  character;
  function tconv( s : std_ulogic       ) return  string;
-- synopsys translate_on

  -- std_ulogic_vector to other types
  function tconv( s : std_ulogic_vector ) return  bit_vector;
  function tconv( s : std_ulogic_vector ) return  std_logic_vector;
  function tconv( s : std_ulogic_vector ) return  integer;
  function tconv( s : std_ulogic_vector ) return  std_ulogic;
-- synopsys translate_off
  function tconv( s : std_ulogic_vector ) return  string;
  function tconv( s : std_ulogic_vector; base : base_t ) return  string;
-- synopsys translate_on

  -- std_logic_vector to other types
--  function tconv( s : std_logic_vector ) return  bit_vector;
--  function tconv( s : std_logic_vector ) return  std_ulogic_vector;
--  function tconv( s : std_logic_vector ) return  integer;
-- synopsys translate_off
--  function tconv( s : std_logic_vector ) return  string;
--  function tconv( s : std_logic_vector; base : base_t ) return  string;
-- synopsys translate_on

-- synopsys translate_off
  function hexstring( d : std_ulogic_vector ) return string ;
  function octstring( d : std_ulogic_vector ) return string ;
  function bitstring( d : std_ulogic_vector ) return string ;
-- synopsys translate_on

  -------------------------------------------------------------------
  -- HIS ATTRIBUTEs for Type Conversion Functions
  -------------------------------------------------------------------
-- Synopsys translate_off
  attribute type_convert of tconv : function is true;

  -------------------------------------------------------------------
  -- synthesis ATTRIBUTEs for Type Conversion Functions
  -------------------------------------------------------------------

  attribute btr_name         of tconv  : function is "PASS";
  attribute pin_bit_information of tconv : function is
           (1 => ("   ","A0      ","INCR","PIN_BIT_SCALAR"),
            2 => ("   ","10      ","INCR","PIN_BIT_SCALAR"));
-- Synopsys translate_on

  --============================================================================
  -- Match Functions
  --============================================================================

  function std_match (l, r: std_ulogic) return std_ulogic;
  function std_match (l, r: std_ulogic_vector) return std_ulogic;

-- Synopsys translate_off
  attribute functionality of std_match : function is "=";
  attribute dc_allow      of std_match : function is true;
-- Synopsys translate_on
--==============================================================
  -- Shift and Rotate Functions
--==============================================================
 
  -- Id: S.1
  function shift_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: Performs a shift-left on an std_ulogic_vector vector COUNT times.
  --         The vacated positions are filled with '0'.
  --         The COUNT leftmost elements are lost.

  -- Id: S.2
  function shift_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: Performs a shift-right on an std_ulogic_vector vector COUNT times.
  --         The vacated positions are filled with '0'.
  --         The COUNT rightmost elements are lost.

  -- Id: S.5
  function rotate_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: Performs a rotate-left of an std_ulogic_vector vector COUNT times.

  -- Id: S.6
  function rotate_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: Performs a rotate-right of an std_ulogic_vector vector COUNT times.
  
  -- Id: S.9
  function "sll" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: SHIFT_LEFT(ARG, COUNT)
 
  -- Id: S.11
  function "srl" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: SHIFT_RIGHT(ARG, COUNT)

  -- Id: S.13
  function "rol" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: ROTATE_LEFT(ARG, COUNT)
  
  -- Id: S.15
  function "ror" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG'LENGTH-1 downto 0)
  -- Result: ROTATE_RIGHT(ARG, COUNT)
  --===========================================================
  --End shift and rotate functions.............................
  --===========================================================
end std_ulogic_support ;

package body std_ulogic_support is

  -------------------------------------------------------------------
  -- Look Up tables for operator overloading
  -------------------------------------------------------------------
  -- Types used for overloaded operator lookup tables
  -------------------------------------------------------------------

-- Synopsys synthesis_off
  type std_ulogic_to_character_type is array( std_ulogic ) of character;

  constant std_ulogic_to_character : std_ulogic_to_character_type :=
    ( 'U','X','0','1','Z','W','L','H','-');

  type stdlogic_2d is array ( std_ulogic, std_ulogic ) of std_ulogic;
  type b_stdlogic_2d is array ( std_ulogic, std_ulogic ) of boolean;
-- Synopsys synthesis_on
  -------------------------------------------------------------------
  -- Logic operation lookup tables
  -------------------------------------------------------------------
-- Synopsys synthesis_off
  -- LessThan Logic Operator

  constant lt_table : stdlogic_2D := (
  -- RHS    U    X    0    1    Z    W    L    H    -        |
  -- LHS  ---------------------------------------------------+---
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ), -- | U
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | X
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ), -- | 0
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | 1
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | Z
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | W
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ), -- | L
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | H
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | -
         others=>(others=>'-')
  );

  constant b_lt_table : b_stdlogic_2D := (
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( '1'=>true, 'H'=>true, others=>false ),
     '1'=>( others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( '1'=>true, 'H'=>true, others=>false ),
     'H'=>( others=>false ),
     '-'=>( others=>false ),
     others=>( others=>false )
  );

  -- LessThanorEqual Logic Operator

  constant le_table : stdlogic_2D := (
  -- RHS    U    X    0    1    Z    W    L    H    -        |
  -- LHS  ---------------------------------------------------+---
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ), -- | U
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | X
         ( 'U', 'X', '1', '1', 'X', 'X', '1', '1', 'X' ), -- | 0
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | 1
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | Z
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | W
         ( 'U', 'X', '1', '1', 'X', 'X', '0', '1', 'X' ), -- | L
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | H
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | -
        others=>(others=>'-')
  );

  constant b_le_table : b_stdlogic_2D := (
  -- RHS => -          0          U          X          1          Z          W          L          H
  -- LHS   --------------------------------------------------------------------------------------------------
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     '1'=>( '1'=>true, 'H'=>true, others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     'H'=>( '1'=>true, 'H'=>true, others=>false ),
     '-'=>( others=>false ),
     others=>( others=>false )
  );

  -- GreaterThan Logic Operator

  constant gt_table : stdlogic_2D := (
  -- RHS    U    X    0    1    Z    W    L    H    -        |
  -- LHS  ---------------------------------------------------+---
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ), -- | U
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | X
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | 0
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | 1
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | Z
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | W
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | L
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | H
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | -
         others=>(others=>'-')
  );

  constant b_gt_table : b_stdlogic_2D := (
  -- LHS => ( RHS )
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( others=>false ),
     '1'=>( '0'=>true, 'L'=>true, others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( others=>false ),
     'H'=>( '0'=>true, 'L'=>true, others=>false ),
     '-'=>( others=>false ),
  others=>(others=>false));

  -- GreaterThanorEqual Logic Operator

  constant ge_table : stdlogic_2D := (
  -- RHS    U    X    0    1    Z    W    L    H    -        |
  -- LHS  ---------------------------------------------------+---
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ), -- | U
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | X
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | 0
         ( 'U', 'X', '1', '1', 'X', 'X', '1', '1', 'X' ), -- | 1
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | Z
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | W
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | L
         ( 'U', 'X', '1', '1', 'X', 'X', '1', '1', 'X' ), -- | H
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | -
         others=>(others=>'-')
  );

  constant b_ge_table : b_stdlogic_2D := (
  -- RHS => -          0          U          X          1          Z          W          L          H
  -- LHS   --------------------------------------------------------------------------------------------------
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( '0'=>true, 'L'=>true, others=>false ),
     '1'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( '0'=>true, 'L'=>true,  others=>false ),
     'H'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     '-'=>( others=>false ),
     others=>( others=>false )
  );
-- Synopsys synthesis_on

  -------------------------------------------------------------------
  -- Relational Functions returning Boolean
  -------------------------------------------------------------------

  function eq( l,r : std_ulogic ) return boolean is
  begin
      return std_match( l, r );
  end eq;

  function ne( l,r : std_ulogic ) return boolean is
  begin
      return not( std_match( l, r ) );
  end ne;

  function gt( l,r : std_ulogic ) return boolean is
      variable result : boolean;
      -- pragma built_in SYN_GT
  begin
      -- Synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := b_gt_table( l, r );
      -- Synopsys translate_on
      return result;
  end gt;

  function ge( l,r : std_ulogic ) return boolean is
      variable result : boolean;
      -- pragma built_in SYN_GEQ
  begin
      -- synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := b_ge_table( l, r );
      -- synopsys translate_on
      return result;
  end ge;

  function lt( l,r : std_ulogic ) return boolean is
      variable result : boolean;
      -- pragma built_in SYN_LT
  begin
      -- synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := b_lt_table( l, r );
      -- synopsys translate_on
      return result;
  end lt;

  function le( l,r : std_ulogic ) return boolean is
      variable result : boolean;
      -- pragma built_in SYN_LEQ
  begin
      -- synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := b_le_table( l, r );
      -- synopsys translate_on
      return result;
  end le;

  -------------------------------------------------------------------
  -- Relational Functions returning std_ulogic
  -------------------------------------------------------------------

  function eq( l,r : std_ulogic ) return std_ulogic is
  begin
      return std_match( l, r );
  end eq;

  function ne( l,r : std_ulogic ) return std_ulogic is
  begin
      return not std_match( l, r ) ;
  end ne;

  function gt( l,r : std_ulogic ) return std_ulogic is
      variable result : std_ulogic;
      -- pragma built_in SYN_GT
  begin
      -- Synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := gt_table( l, r );
      -- synopsys translate_on
      return result;
  end gt;

  function ge( l,r : std_ulogic ) return std_ulogic is
      variable result : std_ulogic;
      -- pragma built_in SYN_GEQ
  begin
      -- Synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := ge_table( l, r );
      -- Synopsys translate_on
      return result;
  end ge;

  function lt( l,r : std_ulogic ) return std_ulogic is
      variable result : std_ulogic;
      -- pragma built_in SYN_LT
  begin
      -- Synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := lt_table( l, r );
      -- Synopsys translate_on
      return result;
  end lt;

  function le( l,r : std_ulogic ) return std_ulogic is
      variable result : std_ulogic;
      -- pragma built_in SYN_LEQ
  begin
      -- Synopsys translate_off
      assert ( l /= '-' ) and ( r /= '-' )
        report "Invalid dont_care in relational function"
        severity error;
      result := le_table( l, r );
      -- Synopsys translate_on
      return result;
  end le;

  --
  -- utility function get rid of most meta values
  --
  function to_x01d( d : std_ulogic ) return std_ulogic is
  -- pragma built_in SYN_FEED_THRU
    variable result : std_ulogic;
  begin
    -- Synopsys translate_off
    case d is
      when '0' | 'L' => result := '0';
      when '1' | 'H' => result := '1';
      when '-'      => result := '-';
      when others   => result := 'X';
    end case;
    -- Synopsys translate_on
    return result;
  end to_x01d;

  -------------------------------------------------------------------
  -- Vectored Relational Functions returning Boolean
  -------------------------------------------------------------------
  function eq( l,r : std_ulogic_vector)  return boolean  is
      variable result        : boolean ;
  begin
    result := std_match(l,r);
    return result;
  end eq;

  ---------------------------------------------------------------------
  function ne( l,r : std_ulogic_vector)  return boolean  is
      variable result        : boolean ;
  begin
    result := not std_match(l,r);
    return result;
  end ne;

  -------------------------------------------------------------------
  function gt( l,r : std_ulogic_vector)  return boolean  is
      variable result        : boolean ;
  begin
    result := unsigned(l) > unsigned(r);
    return result;
  end gt;

  -------------------------------------------------------------------
  function ge( l,r : std_ulogic_vector)  return boolean  is
      variable result        : boolean ;
  begin
    result := unsigned(l) >= unsigned(r);
    return result;
  end ge;

  -------------------------------------------------------------------
  function lt( l,r : std_ulogic_vector)  return boolean  is
      variable result        : boolean ;
  begin
    result := unsigned(l) < unsigned(r);
    return result;
  end lt;

  -------------------------------------------------------------------
  function le( l,r : std_ulogic_vector)  return boolean is
      variable result        : boolean ;
  begin
    result := unsigned(l) <= unsigned(r);
    return result;
  end le;

  -------------------------------------------------------------------
  -- vectored relational functions returning std_ulogic
  -------------------------------------------------------------------
  function eq( l,r : std_ulogic_vector)  return std_ulogic  is
      variable result        : std_ulogic ;
  begin
    result := std_match( l, r ) ; 
    --result := (l ?= r);
    return result;
  end eq;
  ---------------------------------------------------------------------
  function ne( l,r : std_ulogic_vector)  return std_ulogic  is
      variable result        :std_ulogic ;
  begin
    result := not std_match( l, r ) ;
    --result := not (l ?= r);
    return result;
  end ne;

  -------------------------------------------------------------------
  function gt( l,r : std_ulogic_vector)  return std_ulogic is
      variable result        : boolean ;
      -- pragma built_in SYN_GT
  begin
    result := unsigned(l) > unsigned(r);
    if (result = true ) then
       return '1' ;
    else 
       return '0'; 
    end if ;
  end gt;

  -------------------------------------------------------------------
  function ge( l,r : std_ulogic_vector)  return std_ulogic is
      variable result        : boolean ;
      -- pragma built_in SYN_GEQ
  begin
    result := unsigned(l) >= unsigned(r);
    if (result = true ) then
       return '1' ;
    else 
       return '0'; 
    end if ;
  end ge;

  -------------------------------------------------------------------
  function lt( l,r : std_ulogic_vector)  return std_ulogic is
      variable result        : boolean ;
      -- pragma built_in SYN_LT
  begin
    result := unsigned(l) < unsigned(r);
    if (result = true ) then
       return '1' ;
    else 
       return '0'; 
    end if ;
  end lt;

  -------------------------------------------------------------------
  function le( l,r : std_ulogic_vector)  return std_ulogic is
      variable result        : boolean ;
      -- pragma built_in SYN_LEQ
  begin
    result := unsigned(l) <= unsigned(r);
    if (result = true ) then
       return '1' ;
    else 
       return '0'; 
    end if ;
  end le;

  -------------------------------------------------------------------
  -- Type Conversion Functions
  -------------------------------------------------------------------
  -------------------------------------------------------------------
  -- Boolean Conversions
  -------------------------------------------------------------------
  function tconv  ( b : boolean ) return bit is
  -- pragma built_in SYN_FEED_THRU
  begin
      case b is
          when false  => return('0');
          when true   => return('1');
      end case;
  end tconv ;

-- Synopsys translate_off
  function tconv  ( b : boolean ) return string is
  begin
     case b is
        when false  => return("FALSE");
        when true   => return("TRUE");
    end case;
  end tconv ;
-- Synopsys translate_on

  function tconv  ( b : boolean ) return std_ulogic is
  -- pragma built_in SYN_FEED_THRU
  begin
      case b is
          when false  => return('0');
          when true   => return('1');
      end case;
  end tconv ;

  -------------------------------------------------------------------
  -- Bit Conversions
  -------------------------------------------------------------------
  function tconv  ( b : bit ) return boolean is
  -- pragma built_in SYN_FEED_THRU
  begin
      case b is
          when '0' => return(false);
          when '1' => return(true);
      end case;
  end tconv ;

-- Synopsys translate_off
  function tconv  ( b : bit ) return character is
  begin
     case b is
        when '0' => return('0');
        when '1' => return('1');
    end case;
  end tconv ;

  function tconv  ( b : bit ) return string is
  begin
     case b is
        when '0' => return("0");
        when '1' => return("1");
    end case;
  end tconv ;
-- Synopsys translate_on

  function tconv  ( b : bit ) return integer is
  -- pragma built_in SYN_UNSIGNED_TO_INTEGER
  begin
     case b is
        when '0' => return(0);
        when '1' => return(1);
    end case;
  end tconv ;

  function tconv  ( b : bit ) return std_ulogic is
  -- pragma built_in SYN_FEED_THRU
  begin
      case b is
          when '0' => return('0');
          when '1' => return('1');
      end case;
  end tconv ;

  -------------------------------------------------------------------
  -- Bit_vector Conversions
  -------------------------------------------------------------------
  function tconv  ( b : bit_vector ) return integer is
     variable int_result : integer ;
     variable int_exp    : integer ;
     variable new_value  : bit_vector(1 to b'length);
  -- pragma built_in SYN_UNSIGNED_TO_INTEGER
  begin
  -- Synopsys translate_off
     int_result := 0;  
     int_exp    := 0;  
     new_value  := b;  
     for i in new_value'length to 1 loop
        if b(i)='1' then
           int_result := int_result + (2**int_exp);
        end if;
        int_exp := int_exp + 1;
     end loop;
  -- synopsys translate_on
     return int_result;
  end tconv ;

-- Synopsys translate_off
  function tconv  ( b : bit_vector ) return string is
     alias sv : bit_vector ( 1 to b'length ) is b;
     variable result : string ( 1 to b'length );
  begin
     result := (others => '0');
     for i in result'range loop
        case sv(i) is
           when '0' => result(i) := '0';
           when '1' => result(i) := '1';
        end case;
     end loop;
     return result;
  end tconv ;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( b : bit_vector; base : base_t ) return string is
     alias sv : bit_vector ( 1 to b'length ) is b;
     variable result : string ( 1 to b'length );
     variable start : positive;
     variable extra : natural;
     variable resultlength : positive;
     subtype bv is bit_vector( 1 to 1 );
     subtype qv is bit_vector( 1 to 2 );
     subtype ov is bit_vector( 1 to 3 );
     subtype hv is bit_vector( 1 to 4 );
  begin
     case base is
       when bin =>
         resultlength := sv'length;
         start := 1;
         for i in start to resultlength loop
            case sv( i ) is
               when '0' => result( i ) := '0';
               when '1' => result( i ) := '1';
            end case;
         end loop;

       when oct =>
         extra := sv'length rem ov'length;
         case extra is
           when 0 =>
             resultlength := b'length/ov'length;
             start := 1;
           when 1 =>
             resultlength := ( b'length/ov'length ) + 1;
             start := 2;
             case sv( 1 ) is
               when '0' => result( 1 ) := '0';
               when '1' => result( 1 ) := '1';
             end case;
           when 2 =>
             resultlength := ( b'length/ov'length ) + 1;
             start := 2;
             case qv'( sv( 1 to 2 ) ) is
               when "00" => result( 1 ) := '0';
               when "01" => result( 1 ) := '1';
               when "10" => result( 1 ) := '2';
               when "11" => result( 1 ) := '3';
             end case;
           when others =>
             assert false report "TCONV fatal condition" severity failure;
         end case;

         for i in 0 to resultLength - start loop
            case ov'( SV( (ov'length*i)+(extra+1) to (ov'length*i)+(extra+3) ) ) is
               when "000" => result( i+start ) := '0';
               when "001" => result( i+start ) := '1';
               when "010" => result( i+start ) := '2';
               when "011" => result( i+start ) := '3';
               when "100" => result( i+start ) := '4';
               when "101" => result( i+start ) := '5';
               when "110" => result( i+start ) := '6';
               when "111" => result( i+start ) := '7';
               when others => result( i+start ) := '.';
            end case;
         end loop;

       when hex =>
         extra := b'length rem hv'length;
         case extra is
           when 0 =>
             resultLength := b'length/hv'length;
             start := 1;
           when 1 =>
             resultLength := ( b'length/hv'length ) + 1;
             start := 2;
             case sv( 1 ) is
               when '0' => result( 1 ) := '0';
               when '1' => result( 1 ) := '1';
             end case;
           when 2 =>
             resultLength := ( b'length/hv'length ) + 1;
             start := 2;
             case qv'( sv( 1 to 2 ) ) is
               when "00" => result( 1 ) := '0';
               when "01" => result( 1 ) := '1';
               when "10" => result( 1 ) := '2';
               when "11" => result( 1 ) := '3';
             end case;
           when 3 =>
             resultLength := ( b'length/hv'length ) + 1;
             start := 2;
             case ov'( sv( 1 to 3 ) ) is
               when o"0" => result( 1 ) := '0';
               when o"1" => result( 1 ) := '1';
               when o"2" => result( 1 ) := '2';
               when o"3" => result( 1 ) := '3';
               when o"4" => result( 1 ) := '4';
               when o"5" => result( 1 ) := '5';
               when o"6" => result( 1 ) := '6';
               when o"7" => result( 1 ) := '7';
             end case;
           when others =>
             assert false report "TCONV fatal condition" severity failure;
         end case;

         for i in 0 to resultLength - start loop
            case hv'( SV( (hv'length*i)+(extra+1) to (hv'length*i)+(extra+4) ) ) is
               when "0000" => result( i+start ) := '0';
               when "0001" => result( i+start ) := '1';
               when "0010" => result( i+start ) := '2';
               when "0011" => result( i+start ) := '3';
               when "0100" => result( i+start ) := '4';
               when "0101" => result( i+start ) := '5';
               when "0110" => result( i+start ) := '6';
               when "0111" => result( i+start ) := '7';
               when "1000" => result( i+start ) := '8';
               when "1001" => result( i+start ) := '9';
               when "1010" => result( i+start ) := 'A';
               when "1011" => result( i+start ) := 'B';
               when "1100" => result( i+start ) := 'C';
               when "1101" => result( i+start ) := 'D';
               when "1110" => result( i+start ) := 'E';
               when "1111" => result( i+start ) := 'F';
               when others => result( i+start ) := '.';
            end case;
         end loop;

      when others =>
        assert false report "Unsupported base passed." severity warning;

    end case;

    return result( 1 to resultLength );
  end tconv ;
-- Synopsys translate_on

  function tconv  ( b : bit_vector ) return std_ulogic_vector is
      alias sv : bit_vector ( 1 to b'length ) is b;
      variable result : std_ulogic_vector ( 1 to b'length );
  -- pragma built_in SYN_FEED_THRU
  begin
      for i in result'range loop
          case sv(i) is
              when '0' => result(i) := '0';
              when '1' => result(i) := '1';
          end case;
      end loop;
      return result;
  end tconv ;

  --function tconv  ( b : bit_vector ) return std_logic_vector is
  --    alias sv : bit_vector ( 1 to b'length ) is b;
  --    variable result : std_logic_vector ( 1 to b'length );
  ---- pragma built_in SYN_FEED_THRU
  --begin
  --    for i in result'range loop
  --        case sv(i) is
  --            when '0' => result(i) := '0';
  --            when '1' => result(i) := '1';
  --        end case;
  --    end loop;
  --    return result;
  --end tconv ;

  -------------------------------------------------------------------
  -- Integer conversion to other types
  -------------------------------------------------------------------
  function tconv  ( n  : integer;w  : positive) return bit_vector is
    variable result : bit_vector(w-1 downto 0) ;
    variable ib     : integer;
    variable test   : integer;
    -- pragma built_in SYN_INTEGER_TO_UNSIGNED  
  begin
    if n < 0 then
      result := (others => '0');
    else
      ib := n;
      result := (others => '0');
      for i in result'reverse_range loop
        exit when ib = 0;
        test := ib rem 2;
        if test = 1 then
          result(i) := '1';
        else
          result(i) := '0';
        end if;
        ib := ib / 2;
      end loop;
    end if;
    -- synopsys translate_off
    assert n >= 0
      report "tconv: n < 0 is not permitted"
      severity warning;
    assert ib = 0
      report "tconv: integer overflows requested result width"
      severity warning;
    -- synopsys translate_on
    return result;
  end tconv;

  function tconv  ( n  : integer; w  : positive) return std_ulogic_vector is
    variable result : std_ulogic_vector(w-1 downto 0) ;
    variable ib     : integer;
    variable test   : integer;
    -- pragma built_in SYN_INTEGER_TO_UNSIGNED
  begin
    if n < 0 then
      result := (others => 'X');
    else
      ib := n;
      result := (others => '0');
      for i in result'reverse_range loop
        exit when ib = 0;
        test := ib rem 2;
        if test = 1 then
          result(i) := '1';
        else
          result(i) := '0';
        end if;
        ib := ib / 2;
      end loop;
    end if;
    -- Synopsys translate_off
    assert n >= 0
      report "tconv: n < 0 is not permitted"
      severity warning;
    assert ib = 0
      report "tconv: integer overflows requested result width"
      severity warning;
    -- Synopsys translate_on
    return result;
  end tconv;

-- Synopsys translate_off
  function tconv  ( n : integer; w : positive ) return string is
     subtype digit is integer range 0 to 9;
     variable result : string( 1 to w ) ;
     variable ib     : integer;
     variable msd    : integer;
     variable sign   : character := '-';
     variable test   : digit;
  begin
     ib := abs n;
     for i in result'reverse_range loop
        test := ib rem 10;

        case test is
           when 0 => result(i) := '0';
           when 1 => result(i) := '1';
           when 2 => result(i) := '2';
           when 3 => result(i) := '3';
           when 4 => result(i) := '4';
           when 5 => result(i) := '5';
           when 6 => result(i) := '6';
           when 7 => result(i) := '7';
           when 8 => result(i) := '8';
           when 9 => result(i) := '9';
        end case;

        ib := ib / 10;

        exit when ib = 0;
     end loop;

     if ib < 0 then
       result(1) := sign;
     end if;

     assert
       not( ( ( ib < 0 ) and ( ( abs ib ) > ( 10**(w-1) - 1 ) ) ) or
            ( ( ib >= 0 ) and ( ib       > ( 10**w     - 1 ) ) ) )
       report "tconv: integer overflows requested result width"
       severity warning;

     return result;
  end tconv;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( n : integer) return string is
     subtype digit is integer range 0 to 9;
     variable result : string( 1 to 10 ) ;
     variable ib     : integer;
     variable msd    : integer;
     variable sign   : character := '-';
     variable test   : digit;
  begin
     ib := abs n ;
     for i in result'reverse_range loop
        test := ib rem 10;
        case test is
           when 0 => result(i) := '0';
           when 1 => result(i) := '1';
           when 2 => result(i) := '2';
           when 3 => result(i) := '3';
           when 4 => result(i) := '4';
           when 5 => result(i) := '5';
           when 6 => result(i) := '6';
           when 7 => result(i) := '7';
           when 8 => result(i) := '8';
           when 9 => result(i) := '9';
        end case;
        ib := ib / 10;
        if ib = 0 then
           msd := i;
           exit;
        end if;
     end loop;
     if ib < 0 then
        return sign & result(msd to 10);
     else
        return result(msd to 10);
     end if;
  end tconv;
-- Synopsys translate_on

  -------------------------------------------------------------------
  -- String conversion to other types
  -------------------------------------------------------------------
-- Synopsys translate_off
  function TConv  ( s : string ) return integer is
    variable result : integer ; 
    alias si : string( s'length downto 1 ) is s;
    variable invalid : boolean ;
  begin
    invalid := false ;
    for i in si'range loop
      case si( i ) is
        when '0'    => null;
        when '1'    => result := result + 10 ** ( i - 1 ) ;
        when '2'    => result := result + 2 * 10 ** ( i - 1 ) ;
        when '3'    => result := result + 3 * 10 ** ( i - 1 ) ;
        when '4'    => result := result + 4 * 10 ** ( i - 1 ) ;
        when '5'    => result := result + 5 * 10 ** ( i - 1 ) ;
        when '6'    => result := result + 6 * 10 ** ( i - 1 ) ;
        when '7'    => result := result + 7 * 10 ** ( i - 1 ) ;
        when '8'    => result := result + 8 * 10 ** ( i - 1 ) ;
        when '9'    => result := result + 9 * 10 ** ( i - 1 ) ;
        when others => invalid := true;
      end case;
    end loop;
    assert not invalid
      report "String contained characters other than 0 thru 9" &
             "; treating invalid characters as 0's"
      severity warning;
    return result;
  end tconv;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : string; base : base_t ) return integer is
     alias sv : string ( s'length downto 1 ) is s;
     variable result : integer ;
     variable invalid : boolean ;
     variable vc_len : integer ;
     variable validchars : string(1 to 20) := "0 thru 9 or A thru F";
  begin
     invalid := false ;
     case base is
       when bin =>
         vc_len := 6;
         validchars(1 to 6) := "0 or 1";
         for i in sv'range loop
            case sv( i ) is
               when '0'    => null;
               when '1'    => result := result + 2 ** ( i - 1 ) ;
               when others => invalid := true;
            end case;
         end loop;

       when oct =>
         vc_len := 8;
         validchars(1 to 8) := "0 thru 7";
         for i in sv'range loop
            case sv( i ) is
               when '0'    => null;
               when '1'    => result := result + 8 ** ( i - 1 ) ;
               when '2'    => result := result + 2 * 8 ** ( i - 1 ) ;
               when '3'    => result := result + 3 * 8 ** ( i - 1 ) ;
               when '4'    => result := result + 4 * 8 ** ( i - 1 ) ;
               when '5'    => result := result + 5 * 8 ** ( i - 1 ) ;
               when '6'    => result := result + 6 * 8 ** ( i - 1 ) ;
               when '7'    => result := result + 7 * 8 ** ( i - 1 ) ;
               when others => invalid := true;
            end case;
         end loop;

       when dec =>
         vc_len := 8;
         validchars(1 to 8) := "0 thru 9";
         for i in sv'range loop
            case sv( i ) is
               when '0'    => null;
               when '1'    => result := result + 10 ** ( i - 1 ) ;
               when '2'    => result := result + 2 * 10 ** ( i - 1 ) ;
               when '3'    => result := result + 3 * 10 ** ( i - 1 ) ;
               when '4'    => result := result + 4 * 10 ** ( i - 1 ) ;
               when '5'    => result := result + 5 * 10 ** ( i - 1 ) ;
               when '6'    => result := result + 6 * 10 ** ( i - 1 ) ;
               when '7'    => result := result + 7 * 10 ** ( i - 1 ) ;
               when '8'    => result := result + 8 * 10 ** ( i - 1 ) ;
               when '9'    => result := result + 9 * 10 ** ( i - 1 ) ;
               when others => invalid := true;
            end case;
         end loop;

       when hex =>
         for i in sv'range loop
            case sv( i ) is
               when '0'    => null;
               when '1'    => result := result + 16 ** ( i - 1 ) ;
               when '2'    => result := result + 2 * 16 ** ( i - 1 ) ;
               when '3'    => result := result + 3 * 16 ** ( i - 1 ) ;
               when '4'    => result := result + 4 * 16 ** ( i - 1 ) ;
               when '5'    => result := result + 5 * 16 ** ( i - 1 ) ;
               when '6'    => result := result + 6 * 16 ** ( i - 1 ) ;
               when '7'    => result := result + 7 * 16 ** ( i - 1 ) ;
               when '8'    => result := result + 8 * 16 ** ( i - 1 ) ;
               when '9'    => result := result + 9 * 16 ** ( i - 1 ) ;
               when 'A' | 'a'  => result := result + 10 * 16 ** ( i - 1 ) ;
               when 'B' | 'b'  => result := result + 11 * 16 ** ( i - 1 ) ;
               when 'C' | 'c'  => result := result + 12 * 16 ** ( i - 1 ) ;
               when 'D' | 'd'  => result := result + 13 * 16 ** ( i - 1 ) ;
               when 'E' | 'e'  => result := result + 14 * 16 ** ( i - 1 ) ;
               when 'F' | 'f'  => result := result + 15 * 16 ** ( i - 1 ) ;
               when others => invalid := true;
            end case;
         end loop;

       when others =>
         assert false report "Unsupported base passed." severity warning;

     end case;

     assert not invalid
       report "String contained characters other than " &
         validchars(1 to vc_len) & "; treating invalid characters as 0's"
       severity warning;

     return result;
  end;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : string ) return bit is
    variable result : bit;
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    assert s'length = 1
      report "String conversion to bit longer that 1 character"
      severity warning;
    case si(1) is
      when '0' => result := '0';
      when '1' => result := '1';
      when others =>
        invalid := true;
        result := '0';
    end case;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
             "treating invalid characters as 0's"
      severity warning;
    return result;
  end tconv;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : string ) return bit_vector is
    variable result : bit_vector( 1 to s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    for i in si'range loop
      case si(i) is
        when '0' => result( i ) := '0';
        when '1' => result( i ) := '1';
        when others =>
          invalid := true;
          result( i ) := '0';
      end case;
    end loop;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
             "treating invalid characters as 0's"
      severity warning;
    return result( 1 to result'length );
  end tconv;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : string; base : base_t ) return bit_vector is
    variable result : bit_vector( 1 to 4*s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    case base is
      when bin =>
        for i in si'range loop
          case si(i) is
            when '0' => result( i ) := '0';
            when '1' => result( i ) := '1';
            when others =>
              invalid := true;
              result( i ) := '0';
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 or 1; " &
                 "treated invalid characters as 0's"
          severity warning;
        return result(1 to s'length) ;

      when oct =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (3*i)-2 to 3*i ) := o"0";
            when '1' => result( (3*i)-2 to 3*i ) := o"1";
            when '2' => result( (3*i)-2 to 3*i ) := o"2";
            when '3' => result( (3*i)-2 to 3*i ) := o"3";
            when '4' => result( (3*i)-2 to 3*i ) := o"4";
            when '5' => result( (3*i)-2 to 3*i ) := o"5";
            when '6' => result( (3*i)-2 to 3*i ) := o"6";
            when '7' => result( (3*i)-2 to 3*i ) := o"7";
            when others =>
              invalid := true;
              result( (3*i)-2 to 3*i ) := o"0";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 7; " &
                 "treated invalid characters as 0's"
          severity warning;
        return result( 1 to 3*s'length );

      when hex =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (4*i)-3 to 4*i ) := x"0";
            when '1' => result( (4*i)-3 to 4*i ) := x"1";
            when '2' => result( (4*i)-3 to 4*i ) := x"2";
            when '3' => result( (4*i)-3 to 4*i ) := x"3";
            when '4' => result( (4*i)-3 to 4*i ) := x"4";
            when '5' => result( (4*i)-3 to 4*i ) := x"5";
            when '6' => result( (4*i)-3 to 4*i ) := x"6";
            when '7' => result( (4*i)-3 to 4*i ) := x"7";
            when '8' => result( (4*i)-3 to 4*i ) := x"8";
            when '9' => result( (4*i)-3 to 4*i ) := x"9";
            when 'A' | 'a' => result( (4*i)-3 to 4*i ) := x"A";
            when 'B' | 'b' => result( (4*i)-3 to 4*i ) := x"B";
            when 'C' | 'c' => result( (4*i)-3 to 4*i ) := x"C";
            when 'D' | 'd' => result( (4*i)-3 to 4*i ) := x"D";
            when 'E' | 'e' => result( (4*i)-3 to 4*i ) := x"E";
            when 'F' | 'f' => result( (4*i)-3 to 4*i ) := x"F";
            when others =>
              invalid := true;
              result( (4*i)-3 to 4*i ) := x"0";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 9 or " &
                 "A through F; " &
                 "treated invalid characters as 0's"
          severity warning;
        return result( 1 to 4*s'length );

      when others =>
        assert false report "Unsupported base passed." severity warning;
        return result ;

    end case;
  end tconv;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : string ) return std_ulogic is
    variable result : std_ulogic;
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    assert s'length = 1
      report "String conversion to bit longer that 1 character"
      severity warning;
    case si(1) is
      when '0' => result := '0';
      when '1' => result := '1';
      when others =>
        invalid := true;
        result := 'X';
    end case;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
             "treating invalid characters as X's"
      severity warning;
    return result;
  end tconv;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : string ) return std_ulogic_vector is
    variable result : std_ulogic_vector( 1 to s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    for i in si'range loop
      case si(i) is
        when '0' => result( i ) := '0';
        when '1' => result( i ) := '1';
        when others =>
          invalid := true;
          result( i ) := 'X';
      end case;
    end loop;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
             "treating invalid characters as X's"
      severity warning;
    return result( 1 to result'length );
  end tconv;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : string; base : base_t ) return std_ulogic_vector is
    variable result : std_ulogic_vector( 1 to 4*s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    case base is
      when bin =>
        for i in si'range loop
          case si(i) is
            when '0' => result( i ) := '0';
            when '1' => result( i ) := '1';
            when others =>
              invalid := true;
              result( i ) := '0';
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 or 1; " &
                 "treated invalid characters as 0's"
          severity warning;
        return result(1 to s'length) ;

      when oct =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (3*i)-2 to 3*i ) := "000";
            when '1' => result( (3*i)-2 to 3*i ) := "001";
            when '2' => result( (3*i)-2 to 3*i ) := "010";
            when '3' => result( (3*i)-2 to 3*i ) := "011";
            when '4' => result( (3*i)-2 to 3*i ) := "100";
            when '5' => result( (3*i)-2 to 3*i ) := "101";
            when '6' => result( (3*i)-2 to 3*i ) := "110";
            when '7' => result( (3*i)-2 to 3*i ) := "111";
            when others =>
              invalid := true;
              result( (3*i)-2 to 3*i ) := "XXX";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 7; " &
                 "treated invalid characters as X's"
          severity warning;
        return result( 1 to 3*s'length );

      when hex =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (4*i)-3 to 4*i ) := "0000";
            when '1' => result( (4*i)-3 to 4*i ) := "0001";
            when '2' => result( (4*i)-3 to 4*i ) := "0010";
            when '3' => result( (4*i)-3 to 4*i ) := "0011";
            when '4' => result( (4*i)-3 to 4*i ) := "0100";
            when '5' => result( (4*i)-3 to 4*i ) := "0101";
            when '6' => result( (4*i)-3 to 4*i ) := "0110";
            when '7' => result( (4*i)-3 to 4*i ) := "0111";
            when '8' => result( (4*i)-3 to 4*i ) := "1000";
            when '9' => result( (4*i)-3 to 4*i ) := "1001";
            when 'A' | 'a' => result( (4*i)-3 to 4*i ) := "1010";
            when 'B' | 'b' => result( (4*i)-3 to 4*i ) := "1011";
            when 'C' | 'c' => result( (4*i)-3 to 4*i ) := "1100";
            when 'D' | 'd' => result( (4*i)-3 to 4*i ) := "1101";
            when 'E' | 'e' => result( (4*i)-3 to 4*i ) := "1110";
            when 'F' | 'f' => result( (4*i)-3 to 4*i ) := "1111";
            when others =>
              invalid := true;
              result( (4*i)-3 to 4*i ) := "XXXX";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 9 or " &
                 "A through F; " &
                 "treated invalid characters as X's"
          severity warning;
        return result( 1 to 4*s'length );

      when others =>
        assert false report "Unsupported base passed." severity warning;
        return result ;

    end case;
  end tconv;
-- Synopsys translate_on

  -------------------------------------------------------------------
  -- Std_uLogic Conversions
  -------------------------------------------------------------------
  function tconv  ( s : std_ulogic ) return boolean is
  -- pragma built_in SYN_FEED_THRU
  begin
      case s is
          when '0' => return(false);
          when '1' => return(true);
          when 'L' => return(false);
          when 'H' => return(true);
          when others => return(false);
      end case;
  end;

  function tconv  ( s : std_ulogic ) return bit is
  -- pragma built_in SYN_FEED_THRU
  begin
      case s is
          when '0' => return('0');
          when '1' => return('1');
          when 'L' => return('0');
          when 'H' => return('1');
          when others => return('0');
      end case;
  end;

-- Synopsys translate_off 
  function tconv  ( s : std_ulogic ) return character is
  begin
     case s is
        when '0' => return('0');
        when 'L' => return('L');
        when '1' => return('1');
        when 'H' => return('H');
        when 'U' => return('U');
        when 'W' => return('W');
        when '-' => return('-');
        when 'Z' => return('Z');
        when others => return('X');
     end case;
  end;
-- Synopsys translate_on 

-- Synopsys translate_off 
  function tconv  ( s : std_ulogic ) return string is
  begin
     case s is
        when '0' => return("0");
        when 'L' => return("L");
        when '1' => return("1");
        when 'H' => return("H");
        when 'U' => return("U");
        when 'W' => return("W");
        when '-' => return("-");
        when 'Z' => return("Z");
        when others => return("X");
     end case;
  end;
-- Synopsys translate_on 

  function tconv  ( s : std_ulogic ) return integer is
  -- pragma built_in SYN_UNSIGNED_TO_INTEGER
  begin
     case s is
        when '0' => return(0);
        when 'L' => return(0);
        when '1' => return(1);
        when 'H' => return(1);
        when 'U' => return(0);
        when 'W' => return(0);
        when '-' => return(0);
        when 'Z' => return(0);
        when others => return(0);
     end case;
  end;

  function tconv  ( s : std_ulogic ) return std_ulogic_vector is
  -- pragma built_in SYN_FEED_THRU
  begin
     case s is
        when '0' => return("0");
        when 'L' => return("L");
        when '1' => return("1");
        when 'H' => return("H");
        when 'U' => return("U");
        when 'W' => return("W");
        when '-' => return("-");
        when 'Z' => return("Z");
        when others => return("X");
     end case;
  end;

  -------------------------------------------------------------------
  -- std_ulogic_vector Conversions
  -------------------------------------------------------------------
  function tconv  ( s : std_ulogic_vector ) return bit_vector is
      alias sv : std_ulogic_vector ( 1 to s'length ) is s;
      variable result : bit_vector ( 1 to s'length ) ;
  -- pragma built_in SYN_FEED_THRU
  begin
      for i in result'range loop
          case sv(i) is
              when '0' => result(i) := '0';
              when '1' => result(i) := '1';
              when 'L' => result(i) := '0';
              when 'H' => result(i) := '1';
              when others => result(i) := '0';
          end case;
      end loop;
      return result;
  end;

  function tconv  ( s : std_ulogic_vector ) return std_logic_vector is
    alias sv : std_ulogic_vector ( 1 to s'length ) is s;
    variable result : std_logic_vector ( 1 to s'length ) := (others => 'X');
  -- pragma built_in SYN_FEED_THRU
  begin
    for i in result'range loop
      case sv(i) is
        when '0' => result(i) := '0';
        when '1' => result(i) := '1';
        when 'L' => result(i) := '0';
        when 'H' => result(i) := '1';
        when 'W' => result(i) := 'W';
        when '-' => result(i) := '-';
        when 'U' => result(i) := 'U';
        when 'X' => result(i) := 'X';
        when 'Z' => result(i) := 'Z';
      end case;
    end loop;
    return result;
  end;

  function tconv  ( s : std_ulogic_vector ) return integer is
     variable int_result : integer ;
     variable int_exp    : integer ;
     variable new_value  : std_ulogic_vector(1 to s'length) ;
     variable invalid    : boolean ;
  -- pragma built_in SYN_UNSIGNED_TO_INTEGER
  begin
  -- Synopsys translate_off
     int_result := 0;
     int_exp    := 0;
     invalid    := false ;
     new_value  := s ;
     for i in new_value'length downto 1 loop 
        case new_value(i) is
           when '1' => int_result := int_result + (2**int_exp);
           when '0' => null;
           when others =>
              invalid := true;
        end case;
        int_exp := int_exp + 1;
     end loop;
     assert not invalid
       report "The std_ulogic_Vector input contained values " &
              "other than '0' and '1'.  They were treated as zeroes."
       severity warning;
  -- Synopsys translate_on
     return int_result;
  end tconv ;

-- Synopsys translate_off
  function tconv  ( s : std_ulogic_vector ) return string is
      alias sv : std_ulogic_vector ( 1 to s'length ) is s;
      variable result : string ( 1 to s'length ) := (others => 'X');
  begin
      for i in result'range loop
          case sv(i) is
              when '0' => result(i) := '0';
              when 'L' => result(i) := 'L';
              when '1' => result(i) := '1';
              when 'H' => result(i) := 'H';
              when 'U' => result(i) := 'U';
              when '-' => result(i) := '-';
              when 'W' => result(i) := 'W';
              when 'Z' => result(i) := 'Z';
              when others => result(i) := 'X';
          end case;
      end loop;
      return result;
  end;
-- Synopsys translate_on

-- Synopsys translate_off
  function tconv  ( s : std_ulogic_vector; base : base_t ) return string is
     alias sv : std_ulogic_vector ( 1 to s'length ) is s;
     variable result : string ( 1 to s'length );
     variable start : positive;
     variable extra : natural;
     variable resultLength : positive;
     subtype bv is std_ulogic_vector( 1 to 1 );
     subtype qv is std_ulogic_vector( 1 to 2 );
     subtype ov is std_ulogic_vector( 1 to 3 );
     subtype hv is std_ulogic_vector( 1 to 4 );
  begin
     case base is
       when bin =>
         resultLength := sv'length;
         start := 1;
         for i in start to resultLength loop
            case sv( i ) is
               when '0' => result( i ) := '0';
               when '1' => result( i ) := '1';
               when 'X' => result( i ) := 'X';
               when 'L' => result( i ) := 'L';
               when 'H' => result( i ) := 'H';
               when 'W' => result( i ) := 'W';
               when '-' => result( i ) := '-';
               when 'U' => result( i ) := 'U';
               when 'Z' => result( i ) := 'Z';
            end case;
         end loop;

       when oct =>
         extra := sv'length rem ov'length;
         case extra is
           when 0 =>
             resultLength := s'length/ov'length;
             start := 1;
           when 1 =>
             resultLength := ( s'length/ov'length ) + 1;
             start := 2;
             case sv( 1 ) is
               when '0' => result( 1 ) := '0';
               when '1' => result( 1 ) := '1';
               when '-' => result( 1 ) := '-';
               when 'X' => result( 1 ) := 'X';
               when 'U' => result( 1 ) := 'U';
               when 'Z' => result( 1 ) := 'Z';
               when others => result( 1 ) := '.';
             end case;
           when 2 =>
             resultLength := ( s'length/ov'length ) + 1;
             start := 2;
             case qv'( sv( 1 to 2 ) ) is
               when "00" => result( 1 ) := '0';
               when "01" => result( 1 ) := '1';
               when "10" => result( 1 ) := '2';
               when "11" => result( 1 ) := '3';
               when "--" => result( 1 ) := '-';
               when "XX" => result( 1 ) := 'X';
               when "UU" => result( 1 ) := 'U';
               when "ZZ" => result( 1 ) := 'Z';
               when others => result( 1 ) := '.';
             end case;
           when others =>
             assert false report "TCONV fatal condition" severity failure;
         end case;

         for i in 0 to resultLength - start loop
            case ov'( SV( (ov'length*i)+(extra+1) to (ov'length*i)+(extra+3) ) ) is
               when "000" => result( i+start ) := '0';
               when "001" => result( i+start ) := '1';
               when "010" => result( i+start ) := '2';
               when "011" => result( i+start ) := '3';
               when "100" => result( i+start ) := '4';
               when "101" => result( i+start ) := '5';
               when "110" => result( i+start ) := '6';
               when "111" => result( i+start ) := '7';
               when "---" => result( i+start ) := '-';
               when "XXX" => result( i+start ) := 'X';
               when "UUU" => result( i+start ) := 'U';
               when "ZZZ" => result( i+start ) := 'Z';
               when others => result( i+start ) := '.';
            end case;
         end loop;

       when hex =>
         extra := s'length rem hv'length;
         case extra is
           when 0 =>
             resultLength := s'length/hv'length;
             start := 1;
           when 1 =>
             resultLength := ( s'length/hv'length ) + 1;
             start := 2;
             case sv( 1 ) is
               when '0' => result( 1 ) := '0';
               when '1' => result( 1 ) := '1';
               when '-' => result( 1 ) := '-';
               when 'X' => result( 1 ) := 'X';
               when 'U' => result( 1 ) := 'U';
               when 'Z' => result( 1 ) := 'Z';
               when others => result( 1 ) := '.';
             end case;
           when 2 =>
             resultLength := ( s'length/hv'length ) + 1;
             start := 2;
             case qv'( sv( 1 to 2 ) ) is
               when "00" => result( 1 ) := '0';
               when "01" => result( 1 ) := '1';
               when "10" => result( 1 ) := '2';
               when "11" => result( 1 ) := '3';
               when "--" => result( 1 ) := '-';
               when "XX" => result( 1 ) := 'X';
               when "UU" => result( 1 ) := 'U';
               when "ZZ" => result( 1 ) := 'Z';
               when others => result( 1 ) := '.';
             end case;
           when 3 =>
             resultLength := ( s'length/hv'length ) + 1;
             start := 2;
             case ov'( sv( 1 to 3 ) ) is
               when "000" => result( 1 ) := '0';
               when "001" => result( 1 ) := '1';
               when "010" => result( 1 ) := '2';
               when "011" => result( 1 ) := '3';
               when "100" => result( 1 ) := '4';
               when "101" => result( 1 ) := '5';
               when "110" => result( 1 ) := '6';
               when "111" => result( 1 ) := '7';
               when "---" => result( 1 ) := '-';
               when "XXX" => result( 1 ) := 'X';
               when "UUU" => result( 1 ) := 'U';
               when "ZZZ" => result( 1 ) := 'Z';
               when others => result( 1 ) := '.';
             end case;
           when others =>
             assert false report "TCONV fatal condition" severity failure;
         end case;

         for i in 0 to resultLength - start loop
            case hv'( SV( (hv'length*i)+(extra+1) to (hv'length*i)+(extra+4) ) ) is
               when "0000" => result( i+start ) := '0';
               when "0001" => result( i+start ) := '1';
               when "0010" => result( i+start ) := '2';
               when "0011" => result( i+start ) := '3';
               when "0100" => result( i+start ) := '4';
               when "0101" => result( i+start ) := '5';
               when "0110" => result( i+start ) := '6';
               when "0111" => result( i+start ) := '7';
               when "1000" => result( i+start ) := '8';
               when "1001" => result( i+start ) := '9';
               when "1010" => result( i+start ) := 'A';
               when "1011" => result( i+start ) := 'B';
               when "1100" => result( i+start ) := 'C';
               when "1101" => result( i+start ) := 'D';
               when "1110" => result( i+start ) := 'E';
               when "1111" => result( i+start ) := 'F';
               when "----" => result( i+start ) := '-';
               when "XXXX" => result( i+start ) := 'X';
               when "UUUU" => result( i+start ) := 'U';
               when "ZZZZ" => result( i+start ) := 'Z';
               when others => result( i+start ) := '.';
            end case;
         end loop;

      when others =>
        assert false report "Unsupported base passed." severity warning;
     end case;
     return result( 1 to resultLength );
  end;
-- Synopsys translate_on

  function tconv  ( s : std_ulogic_vector ) return std_ulogic is
    alias sv : std_ulogic_vector( 1 to s'length ) is s;
    variable result : std_ulogic;
    -- pragma built_in SYN_FEED_THRU
  begin
    case sv(s'length) is
      when '0' => return('0');
      when 'L' => return('L');
      when '1' => return('1');
      when 'H' => return('H');
      when 'U' => return('U');
      when 'W' => return('W');
      when '-' => return('-');
      when 'Z' => return('Z');
      when others => return('X');
    end case;
  end;

  -------------------------------------------------------------------
  -- std_logic_vector Conversions
  -------------------------------------------------------------------
  --function tconv  ( s : std_logic_vector ) return bit_vector is
  --  alias sv : std_logic_vector ( 1 to s'length ) is s;
  --  variable result : bit_vector ( 1 to s'length ) := (others => '0');
  ---- pragma built_in SYN_FEED_THRU
  --begin
  --  for i in result'range loop
  --    case sv(i) is
  --      when '0' => result(i) := '0';
  --      when '1' => result(i) := '1';
  --      when 'L' => result(i) := '0';
  --      when 'H' => result(i) := '1';
  --      when others => result(i) := '0';
  --    end case;
  --  end loop;
  --  return result;
  --end;

  --function tconv  ( s : std_logic_vector ) return std_ulogic_vector is
  --  alias sv : std_logic_vector ( 1 to s'length ) is s;
  --  variable result : std_ulogic_vector ( 1 to s'length ) := (others => 'X');
  ---- pragma built_in SYN_FEED_THRU
  --begin
  --  for i in result'range loop
  --    case sv(i) is
  --      when '0' => result(i) := '0';
  --      when '1' => result(i) := '1';
  --      when 'L' => result(i) := '0';
  --      when 'H' => result(i) := '1';
  --      when 'W' => result(i) := 'W';
  --      when '-' => result(i) := '-';
  --      when 'U' => result(i) := 'U';
  --      when 'X' => result(i) := 'X';
  --      when 'Z' => result(i) := 'Z';
  --    end case;
  --  end loop;
  --  return result;
  --end;

  --function tconv  ( s : std_logic_vector ) return integer is
  --  variable int_result : integer := 0;
  --  variable int_exp    : integer := 0;
  --  alias    new_value  : std_logic_vector(1 to s'length) is s ;
  --  variable invalid : boolean := false;
  ---- pragma built_in SYN_UNSIGNED_TO_INTEGER
  --begin
  ---- Synopsys translate_off
  --  for i in new_value'length downto 1 loop
  --    case new_value(i) is
  --      when '1' => int_result := int_result + (2**int_exp);
  --      when '0' => null;
  --      when others =>
  --        invalid := true;
  --    end case;
  --    int_exp := int_exp + 1;
  --  end loop;
  --  assert not invalid
  --    report "The std_logic_Vector input contained values " &
  --    "other than '0' and '1'.  They were treated as zeroes."
  --    severity warning;
  ---- Synopsys translate_on
  --  return int_result;
  --end tconv ;

-- Synopsys translate_off
  --function tconv  ( s : std_logic_vector ) return string is
  --  alias sv : std_logic_vector ( 1 to s'length ) is s;
  --  variable result : string ( 1 to s'length ) := (others => 'X');
  --begin
  --  for i in result'range loop
  --    case sv(i) is
  --      when '0' => result(i) := '0';
  --      when 'L' => result(i) := 'L';
  --      when '1' => result(i) := '1';
  --      when 'H' => result(i) := 'H';
  --      when 'U' => result(i) := 'U';
  --      when '-' => result(i) := '-';
  --      when 'W' => result(i) := 'W';
  --      when 'Z' => result(i) := 'Z';
  --      when others => result(i) := 'X';
  --    end case;
  --  end loop;
  --  return result;
  --end;
-- Synopsys translate_on

-- Synopsys translate_off
  --function tconv  ( s : std_logic_vector; base : base_t ) return string is
  --  alias sv : std_logic_vector ( 1 to s'length ) is s;
  --  variable result : string ( 1 to s'length );
  --  variable start : positive;
  --  variable extra : natural;
  --  variable resultlength : positive;
  --  subtype bv is std_logic_vector( 1 to 1 );
  --  subtype qv is std_logic_vector( 1 to 2 );
  --  subtype ov is std_logic_vector( 1 to 3 );
  --  subtype hv is std_logic_vector( 1 to 4 );
  --begin
  --  case base is
  --    when bin =>
  --      resultLength := sv'length;
  --      start := 1;
  --      for i in start to resultLength loop
  --        case sv( i ) is
  --          when '0' => result( i ) := '0';
  --          when '1' => result( i ) := '1';
  --          when 'X' => result( i ) := 'X';
  --          when 'L' => result( i ) := 'L';
  --          when 'H' => result( i ) := 'H';
  --          when 'W' => result( i ) := 'W';
  --          when '-' => result( i ) := '-';
  --          when 'U' => result( i ) := 'U';
  --          when 'Z' => result( i ) := 'Z';
  --        end case;
  --      end loop;

  --    when oct =>
  --      extra := sv'length rem ov'length;
  --      case extra is
  --        when 0 =>
  --          resultLength := s'length/ov'length;
  --          start := 1;
  --        when 1 =>
  --          resultLength := ( s'length/ov'length ) + 1;
  --          start := 2;
  --          case sv( 1 ) is
  --            when '0' => result( 1 ) := '0';
  --            when '1' => result( 1 ) := '1';
  --            when '-' => result( 1 ) := '-';
  --            when 'X' => result( 1 ) := 'X';
  --            when 'U' => result( 1 ) := 'U';
  --            when 'Z' => result( 1 ) := 'Z';
  --            when others => result( 1 ) := '.';
  --          end case;
  --        when 2 =>
  --          resultLength := ( s'length/ov'length ) + 1;
  --          start := 2;
  --          case qv'( sv( 1 to 2 ) ) is
  --            when "00" => result( 1 ) := '0';
  --            when "01" => result( 1 ) := '1';
  --            when "10" => result( 1 ) := '2';
  --            when "11" => result( 1 ) := '3';
  --            when "--" => result( 1 ) := '-';
  --            when "XX" => result( 1 ) := 'X';
  --            when "UU" => result( 1 ) := 'U';
  --            when "ZZ" => result( 1 ) := 'Z';
  --            when others => result( 1 ) := '.';
  --          end case;
  --        when others =>
  --          assert false report "TCONV fatal condition" severity failure;
  --      end case;

  --      for i in 0 to resultLength - start loop
  --        case ov'( sv( (ov'length*i)+(extra+1) to (ov'length*i)+(extra+3) ) ) is
  --          when "000" => result( i+start ) := '0';
  --          when "001" => result( i+start ) := '1';
  --          when "010" => result( i+start ) := '2';
  --          when "011" => result( i+start ) := '3';
  --          when "100" => result( i+start ) := '4';
  --          when "101" => result( i+start ) := '5';
  --          when "110" => result( i+start ) := '6';
  --          when "111" => result( i+start ) := '7';
  --          when "---" => result( i+start ) := '-';
  --          when "XXX" => result( i+start ) := 'X';
  --          when "UUU" => result( i+start ) := 'U';
  --          when "ZZZ" => result( i+start ) := 'Z';
  --          when others => result( i+start ) := '.';
  --        end case;
  --      end loop;

  --    when hex =>
  --      extra := s'length rem hv'length;
  --      case extra is
  --        when 0 =>
  --          resultLength := s'length/hv'length;
  --          start := 1;
  --        when 1 =>
  --          resultLength := ( s'length/hv'length ) + 1;
  --          start := 2;
  --          case sv( 1 ) is
  --            when '0' => result( 1 ) := '0';
  --            when '1' => result( 1 ) := '1';
  --            when '-' => result( 1 ) := '-';
  --            when 'X' => result( 1 ) := 'X';
  --            when 'U' => result( 1 ) := 'U';
  --            when 'Z' => result( 1 ) := 'Z';
  --            when others => result( 1 ) := '.';
  --          end case;
  --        when 2 =>
  --          resultLength := ( s'length/hv'length ) + 1;
  --          start := 2;
  --          case qv'( sv( 1 to 2 ) ) is
  --            when "00" => result( 1 ) := '0';
  --            when "01" => result( 1 ) := '1';
  --            when "10" => result( 1 ) := '2';
  --            when "11" => result( 1 ) := '3';
  --            when "--" => result( 1 ) := '-';
  --            when "XX" => result( 1 ) := 'X';
  --            when "UU" => result( 1 ) := 'U';
  --            when "ZZ" => result( 1 ) := 'Z';
  --            when others => result( 1 ) := '.';
  --          end case;
  --        when 3 =>
  --          resultLength := ( s'length/hv'length ) + 1;
  --          start := 2;
  --          case ov'( sv( 1 to 3 ) ) is
  --            when "000" => result( 1 ) := '0';
  --            when "001" => result( 1 ) := '1';
  --            when "010" => result( 1 ) := '2';
  --            when "011" => result( 1 ) := '3';
  --            when "100" => result( 1 ) := '4';
  --            when "101" => result( 1 ) := '5';
  --            when "110" => result( 1 ) := '6';
  --            when "111" => result( 1 ) := '7';
  --            when "---" => result( 1 ) := '-';
  --            when "XXX" => result( 1 ) := 'X';
  --            when "UUU" => result( 1 ) := 'U';
  --            when "ZZZ" => result( 1 ) := 'Z';
  --            when others => result( 1 ) := '.';
  --          end case;
  --        when others =>
  --          assert false report "TCONV fatal condition" severity failure;
  --      end case;

  --      for i in 0 to resultLength - start loop
  --        case hv'( SV( (hv'length*i)+(extra+1) to (hv'length*i)+(extra+4) ) ) is
  --          when "0000" => result( i+start ) := '0';
  --          when "0001" => result( i+start ) := '1';
  --          when "0010" => result( i+start ) := '2';
  --          when "0011" => result( i+start ) := '3';
  --          when "0100" => result( i+start ) := '4';
  --          when "0101" => result( i+start ) := '5';
  --          when "0110" => result( i+start ) := '6';
  --          when "0111" => result( i+start ) := '7';
  --          when "1000" => result( i+start ) := '8';
  --          when "1001" => result( i+start ) := '9';
  --          when "1010" => result( i+start ) := 'A';
  --          when "1011" => result( i+start ) := 'B';
  --          when "1100" => result( i+start ) := 'C';
  --          when "1101" => result( i+start ) := 'D';
  --          when "1110" => result( i+start ) := 'E';
  --          when "1111" => result( i+start ) := 'F';
  --          when "----" => result( i+start ) := '-';
  --          when "XXXX" => result( i+start ) := 'X';
  --          when "UUUU" => result( i+start ) := 'U';
  --          when "ZZZZ" => result( i+start ) := 'Z';
  --          when others => result( i+start ) := '.';
  --        end case;
  --      end loop;

  --    when others =>
  --      assert false report "Unsupported base passed." severity warning;
  --  end case;
  --  return result( 1 to resultLength );
  --end;
-- Synopsys translate_on

-- Synopsys translate_off
  function hexstring( d : std_ulogic_vector ) return string is
    variable nd :
      Std_Ulogic_vector( 0 to ((d'length + (4 - (d'length mod 4))) - 1) ) := ( others => '0' );
    variable r : string(1 to (nd'length/4));
    variable hexsize   : integer;
    variable offset    : integer;
    subtype iv4 is Std_Ulogic_vector(1 to 4);
  begin

    offset := d'length mod 4;

    if offset = 0 then
      hexsize := d'length / 4;
      nd( 0 to d'length - 1 ) := d;
    else
      hexsize := nd'length / 4;
      nd( ( nd'left + (4 - offset) ) to nd'right ) := d;
    end if;

    for i in 0 to hexsize - 1 loop

      case iv4( nd( ( i * 4 ) to ( ( i * 4 ) + 3 ) ) ) is
        when "0000"    => r(i + 1) := '0';
        when "0001"    => r(i + 1) := '1';
        when "0010"    => r(i + 1) := '2';
        when "0011"    => r(i + 1) := '3';
        when "0100"    => r(i + 1) := '4';
        when "0101"    => r(i + 1) := '5';
        when "0110"    => r(i + 1) := '6';
        when "0111"    => r(i + 1) := '7';
        when "1000"    => r(i + 1) := '8';
        when "1001"    => r(i + 1) := '9';
        when "1010"    => r(i + 1) := 'A';
        when "1011"    => r(i + 1) := 'B';
        when "1100"    => r(i + 1) := 'C';
        when "1101"    => r(i + 1) := 'D';
        when "1110"    => r(i + 1) := 'E';
        when "1111"    => r(i + 1) := 'F';
        when "----"    => r(i + 1) := '-';
        when "XXXX"    => r(i + 1) := 'X';
        when "UUUU"    => r(i + 1) := 'U';
        when "ZZZZ"    => r(i + 1) := 'Z';
        when others    => r(i + 1) := '.';
      end case;

    end loop;

    return r(1 to hexsize);
  end hexstring;
-- Synopsys translate_on

-- Synopsys translate_off
  function octstring( d : std_ulogic_vector ) return string is
    variable nd :
      Std_Ulogic_vector( 0 to ((d'length + (3 - (d'length mod 3))) - 1) ) := ( others => '0' );
    variable offset    : integer;
    variable r : string(1 to (nd'length/3));
    variable octsize   : integer;
    subtype iv3 is Std_Ulogic_vector(1 to 3);
  begin

    offset := d'length mod 3;

    if offset = 0 then
      octsize := d'length / 3;
      nd( 0 to d'length - 1 ) := d;
    else
      octsize := nd'length / 3;
      nd( ( nd'left + (3 - offset) ) to nd'right ) := d;
    end if;

    for i in 0 to octsize - 1 loop

      case iv3( nd( ( i * 3 ) to ( ( i * 3 ) + 2 ) ) ) is
        when "000"    => r(i + 1) := '0';
        when "001"    => r(i + 1) := '1';
        when "010"    => r(i + 1) := '2';
        when "011"    => r(i + 1) := '3';
        when "100"    => r(i + 1) := '4';
        when "101"    => r(i + 1) := '5';
        when "110"    => r(i + 1) := '6';
        when "111"    => r(i + 1) := '7';
        when "---"    => r(i + 1) := '-';
        when "XXX"    => r(i + 1) := 'X';
        when "UUU"    => r(i + 1) := 'U';
        when "ZZZ"    => r(i + 1) := 'Z';
        when others    => r(i + 1) := '.';
      end case;

    end loop;

    return r;
  end octstring;
-- Synopsys translate_on

-- Synopsys translate_off
  function bitstring( d : std_ulogic_vector ) return string is
    variable nd :
      Std_Ulogic_vector(0 to ( d'length - 1 ) ) := ( others => '0' );
    variable r : string(1 to (nd'length));
  begin
    nd := d;
    for i in nd'range loop
      r(i + 1) := std_ulogic_to_character( nd(i) );
    end loop;
    return r;
  end bitstring;
-- Synopsys translate_on

  -------------------------------------------------------------------
  -- Std_Match functions
  -------------------------------------------------------------------
  constant no_warning: boolean := false; -- default to emit warnings

  -- Id: M.1a
  function std_match (l, r: std_ulogic) return std_ulogic is
  begin
    if (l ?= r) then    
       return '1' ;
    else
       return '0' ;
    end if ;
  end std_match;

  -- Id: M.4b
  function std_match (l, r: std_ulogic_vector) return std_ulogic is
    variable result : boolean ;
  begin
    if (l ?= r) then    
       return '1' ;
    else 
       return '0' ;
    end if;
  end std_match;

  -------------------------------------------------------------------
  -- Overloaded Relational Operators returning std_ulogic
  -------------------------------------------------------------------
  function "="  ( l,r : integer ) return std_ulogic is
      -- pragma built_in SYN_EQL
  begin
      if (l - r) = 0 then
         return ('1');
      else
         return ('0');
      end if ;
  end "=";

  function "/=" ( l,r : integer ) return std_ulogic is
      -- pragma built_in SYN_NEQ
  begin
      if (l - r) = 0 then
         return ('0');
      else
         return ('1');
      end if ;
  end "/=";

  function ">"  ( l,r : integer ) return std_ulogic is
      -- pragma built_in SYN_GT
  begin
      if (l - r) > 0 then
         return ('1');
      else
         return ('0');
      end if ;
  end ">";

  function ">="  ( l,r : integer ) return std_ulogic is
      -- pragma built_in SYN_GEQ
  begin
      if (l - r) >= 0 then
         return ('1');
      else
         return ('0');
      end if ;
  end ">=";

  function "<"  ( l,r : integer ) return std_ulogic is
      -- pragma built_in SYN_LT
  begin
      if (r - l) > 0 then
         return ('1');
      else
         return ('0');
      end if ;
  end "<";

  function "<=" ( l,r : integer ) return std_ulogic is
      -- pragma built_in SYN_LEQ
  begin
      if (r - l) >= 0 then
         return ('1');
      else
         return ('0');
      end if ;
  end "<=";

  -------------------------------------------------------------------
  -- Overloaded Relational Operators returning STD_uLogic
  -------------------------------------------------------------------
  function "="  ( l,r : std_ulogic ) return std_ulogic is
      -- pragma built_in SYN_EQL
  begin
      return ( tconv( l = r ) );
  end "=";

  function "/=" ( l,r : std_ulogic ) return std_ulogic is
      -- pragma built_in SYN_NEQ
  begin
      return ( tconv( l /= r ) );
  end "/=";

  function ">"  ( l,r : std_ulogic ) return std_ulogic is
      -- pragma built_in SYN_GT
  begin
      return ( tconv( l > r ) );
  end ">";

  function ">="  ( l,r : std_ulogic ) return std_ulogic is
      -- pragma built_in SYN_GEQ
  begin
      return ( tconv( l >= r ) );
  end ">=";

  function "<"  ( l,r : std_ulogic ) return std_ulogic is
      -- pragma built_in SYN_LT
  begin
      return ( tconv( l < r ) );
  end "<";

  function "<=" ( l,r : std_ulogic ) return std_ulogic is
      -- pragma built_in SYN_LEQ
  begin
      return ( tconv( l <= r ) );
  end "<=";

  -------------------------------------------------------------------
  -- Overloaded Relational Operators returning STD_uLogic
  -------------------------------------------------------------------

  function "=" ( l,r : std_ulogic_vector)  return std_ulogic is
      -- pragma built_in SYN_EQL
  begin
  -- Synopsys translate_off
    if l'length /= r'length then
      assert false
        report "The bit lengths of the two inputs to the = " &
               "operator are unequal. "
        severity error;
        return '0' ;
    end if ;
  -- Synopsys translate_on
    return ( tconv( l = r ) );
  end "=";

  -------------------------------------------------------------------
  function "/=" ( l,r : std_ulogic_vector)  return std_ulogic is
      -- pragma built_in SYN_NEQ
  begin
  -- Synopsys translate_off
    if l'length /= r'length then
      assert false
        report "The bit lengths of the two inputs to the /= " &
               "operator are unequal. "
        severity error;
        return '0' ;
    end if ;
  -- Synopsys translate_on
    return ( tconv( l /= r ) );
  end "/=";

  -------------------------------------------------------------------
  function ">" ( l,r : std_ulogic_vector)  return std_ulogic is
      -- pragma built_in SYN_GT
  begin
  -- Synopsys translate_off
    if l'length /= r'length then
      assert false
        report "The bit lengths of the two inputs to the > " &
               "operator are unequal. "
        severity error;
        return '0' ;
    end if ;
  -- Synopsys translate_on
    return ( tconv( l > r ) );
  end ">";

  -------------------------------------------------------------------
  function ">=" ( l,r : std_ulogic_vector)  return std_ulogic is
      -- pragma built_in SYN_GEQ
  begin
  -- Synopsys translate_off
    if l'length /= r'length then
      assert false
        report "The bit lengths of the two inputs to the >= " &
               "operator are unequal. "
        severity error;
        return '0' ;
    end if ;
  -- Synopsys translate_on
    return ( tconv( l >= r ) );
  end ">=";

  -------------------------------------------------------------------
  function "<" ( l,r : std_ulogic_vector)  return std_ulogic is
      -- pragma built_in SYN_LT
  begin
  -- Synopsys translate_off
    if l'length /= r'length then
      assert false
        report "The bit lengths of the two inputs to the < " &
               "operator are unequal. "
        severity error;
        return '0' ;
    end if ;
  -- Synopsys translate_on
    return ( tconv( l < r ) );
  end "<";

  -------------------------------------------------------------------
  function "<=" ( l,r : std_ulogic_vector)  return std_ulogic is
      -- pragma built_in SYN_LEQ
  begin
  -- Synopsys translate_off
    if l'length /= r'length then
      assert false
        report "The bit lengths of the two inputs to the <= " &
               "operator are unequal. "
        severity error;
        return '0' ;
    end if ;
  -- Synopsys translate_on
    return ( tconv( l <= r ) );
  end "<=";

--==============================================================
  -- Shift and Rotate Functions
--==============================================================
----------Local Subprograms - shift/rotate ops-------------------
  -- Synopsys translate_off
  constant NAU: std_ulogic_vector(0 downto 1) := (others => '0');
  -- Synopsys translate_on

  function xsll (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
      is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0)  ;
    -- pragma built_in SYN_SLLU
  begin
    result := (others => '0');
    if count <= arg_l then
      result(arg_l downto count) := xarg(arg_l-count downto 0);
    end if;
    return result;
  end xsll;

  function xsrl (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
      is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0) ;
    -- pragma built_in SYN_SRLU
  begin
    result := (others => '0');
    if count <= arg_l then
      result(arg_l-count downto 0) := xarg(arg_l downto count);
    end if;
    return result;
  end xsrl;

  function xsra (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
      is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0);
    variable xcount: natural  ;
    -- pragma built_in SYN_SHR
  begin
    xcount := count;
    if ((arg'length <= 1) or (xcount = 0)) then return arg;
    else
      if (xcount > arg_l) then xcount := arg_l;
      end if;
      result(arg_l-xcount downto 0) := xarg(arg_l downto xcount);
      result(arg_l downto (arg_l - xcount + 1)) := (others => xarg(arg_l));
    end if;
    return result;
  end xsra;

  function xrol (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
      is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0) ; 
    variable countm: integer;
    -- pragma built_in SYN_ROLU
  begin
    result := xarg;
    countm := count mod (arg_l + 1);
    if countm /= 0 then
      result(arg_l downto countm) := xarg(arg_l-countm downto 0);
      result(countm-1 downto 0) := xarg(arg_l downto arg_l-countm+1);
    end if;
    return result;
  end xrol;

  function xror (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
      is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0) ;
    variable countm: integer;
    -- pragma built_in SYN_RORU
  begin
    countm := count mod (arg_l + 1);
    result := xarg;
    if countm /= 0 then
      result(arg_l-countm downto 0) := xarg(arg_l downto countm);
      result(arg_l downto arg_l-countm+1) := xarg(countm-1 downto 0);
    end if;
    return result;
  end xror;

--===================================================================

  -- Id: S.1
  function shift_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
    -- pragma built_in SYN_SLLU
  begin
  -- Synopsys translate_off
    if (arg'length < 1) then return NAU;
    end if;
  -- Synopsys translate_on
    return std_ulogic_vector( xsll( std_ulogic_vector(arg), count ) );
  end shift_left;

  -- Id: S.2
  function shift_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
    -- pragma built_in SYN_SRLU
  begin
  -- Synopsys translate_off
    if (arg'length < 1) then return NAU;
    end if;
  -- Synopsys translate_on
    return std_ulogic_vector( xsrl( std_ulogic_vector(arg), count ) );
  end shift_right;

 
  -- Id: S.5
  function rotate_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
    -- pragma built_in SYN_ROLU
  begin
  -- Synopsys translate_off
    if (arg'length < 1) then return NAU;
    end if;
  -- Synopsys translate_on
    return std_ulogic_vector( xrol( std_ulogic_vector(arg), count ) );
  end rotate_left;

  -- Id: S.6
  function rotate_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
    -- pragma built_in SYN_RORU
  begin
  -- Synopsys translate_off
    if (arg'length < 1) then return NAU;
    end if;
  -- Synopsys translate_on
    return std_ulogic_vector( xror( std_ulogic_vector(arg), count ) );
  end rotate_right;

  -- Id: S.9
  function "sll" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
    -- pragma built_in SYN_SLL
  begin
    if (count >= 0) then
      return shift_left(arg, count);
    else
      return shift_right(arg, -count);
    end if;
  end "sll";

  -- Id: S.11
  function "srl" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
    -- pragma built_in SYN_SRL
  begin
    if (count >= 0) then
      return shift_right(arg, count);
    else
      return shift_left(arg, -count);
    end if;
  end "srl";

  -- Id: S.13
  function "rol" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
    -- pragma built_in SYN_ROL
  begin
    if (count >= 0) then
      return rotate_left(arg, count);
    else
      return rotate_right(arg, -count);
    end if;
  end "rol";

  -- Id: S.15
  function "ror" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
    -- pragma built_in SYN_ROR
  begin
    if (count >= 0) then
      return rotate_right(arg, count);
    else
      return rotate_left(arg, -count);
    end if;
  end "ror";

--==============================================================
  --End Shift and Rotate Functions
--============================================================== 

end std_ulogic_support ;

