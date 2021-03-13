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
library ibm,ieee ;
use ieee.std_logic_1164.all ;
use ibm.std_ulogic_support.all;

package std_ulogic_mux_support is

  -- Multiplexor/Selector Functions
  function mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of mux_2to1 : function is "VHDL-MUX" ;
  attribute recursive_synthesis of mux_2to1 : function is true;
  attribute pin_bit_information of mux_2to1 : function is
    (1 => ("   ","S0      ","DECR","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     4 => ("   ","PASS    ","    ","              "),
     5 => ("   ","PASS    ","    ","              "),
     6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of mux_4to1 : function is "VHDL-MUX" ;
  attribute recursive_synthesis of mux_4to1 : function is true;
  attribute pin_bit_information of mux_4to1 : function is
    (1 => ("   ","S1      ","DECR","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     4 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     6 => ("   ","PASS    ","    ","              "),
     7 => ("   ","PASS    ","    ","              "),
     8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of mux_8to1 : function is "VHDL-MUX" ;
  attribute recursive_synthesis of mux_8to1 : function is true;
  attribute pin_bit_information of mux_8to1 : function is
    (1 => ("   ","S2      ","DECR","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     4 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     6 => ("   ","D4      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","D5      ","SAME","PIN_BIT_VECTOR"),
     8 => ("   ","D6      ","SAME","PIN_BIT_VECTOR"),
     9 => ("   ","D7      ","SAME","PIN_BIT_VECTOR"),
     10 => ("   ","PASS    ","    ","              "),
     11 => ("   ","PASS    ","    ","              "),
     12 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function not_mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function not_mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of not_mux_2to1 : function is "VHDL-MUX" ;
  attribute recursive_synthesis of not_mux_2to1 : function is true;
  attribute pin_bit_information of not_mux_2to1 : function is
    (1 => ("   ","S0      ","DECR","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     4 => ("   ","PASS    ","    ","              "),
     5 => ("   ","PASS    ","    ","              "),
     6 => ("   ","INV     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function not_mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function not_mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of not_mux_4to1 : function is "VHDL-MUX" ;
  attribute recursive_synthesis of not_mux_4to1 : function is true;
  attribute pin_bit_information of not_mux_4to1 : function is
    (1 => ("   ","S1      ","DECR","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     4 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     6 => ("   ","PASS    ","    ","              "),
     7 => ("   ","PASS    ","    ","              "),
     8 => ("   ","INV     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function not_mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function not_mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of not_mux_8to1 : function is "VHDL-MUX" ;
  attribute recursive_synthesis of not_mux_8to1 : function is true;
  attribute pin_bit_information of not_mux_8to1 : function is
    (1 => ("   ","S2      ","DECR","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     4 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     6 => ("   ","D4      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","D5      ","SAME","PIN_BIT_VECTOR"),
     8 => ("   ","D6      ","SAME","PIN_BIT_VECTOR"),
     9 => ("   ","D7      ","SAME","PIN_BIT_VECTOR"),
     10 => ("   ","PASS    ","    ","              "),
     11 => ("   ","PASS    ","    ","              "),
     12 => ("   ","INV     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  -- Primitive selector input functions
  function select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of select_1of2 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of select_1of2 : function is true;
  attribute pin_bit_information of select_1of2 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","PASS    ","    ","              "),
     6 => ("   ","PASS    ","    ","              "),
     7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of select_1of3 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of select_1of3 : function is true;
  attribute pin_bit_information of select_1of3 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","S2      ","SAME","PIN_BIT_SCALAR"),
     6 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","PASS    ","    ","              "),
     8 => ("   ","PASS    ","    ","              "),
     9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of select_1of4 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of select_1of4 : function is true;
  attribute pin_bit_information of select_1of4 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","S2      ","SAME","PIN_BIT_SCALAR"),
     6 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","S3      ","SAME","PIN_BIT_SCALAR"),
     8 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     9 => ("   ","PASS    ","    ","              "),
     10 => ("   ","PASS    ","    ","              "),
     11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic ;
     gate4 : std_ulogic ;
     in4   : std_ulogic ;
     gate5 : std_ulogic ;
     in5   : std_ulogic ;
     gate6 : std_ulogic ;
     in6   : std_ulogic ;
     gate7 : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector ;
     gate4 : std_ulogic ;
     in4   : std_ulogic_vector ;
     gate5 : std_ulogic ;
     in5   : std_ulogic_vector ;
     gate6 : std_ulogic ;
     in6   : std_ulogic_vector ;
     gate7 : std_ulogic ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of select_1of8 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of select_1of8 : function is true;
  attribute pin_bit_information of select_1of8 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","S2      ","SAME","PIN_BIT_SCALAR"),
     6 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","S3      ","SAME","PIN_BIT_SCALAR"),
     8 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     9 => ("   ","S4      ","SAME","PIN_BIT_SCALAR"),
     10 => ("   ","D4      ","SAME","PIN_BIT_VECTOR"),
     11 => ("   ","S5      ","SAME","PIN_BIT_SCALAR"),
     12 => ("   ","D5      ","SAME","PIN_BIT_VECTOR"),
     13 => ("   ","S6      ","SAME","PIN_BIT_SCALAR"),
     14 => ("   ","D6      ","SAME","PIN_BIT_VECTOR"),
     15 => ("   ","S7      ","SAME","PIN_BIT_SCALAR"),
     16 => ("   ","D7      ","SAME","PIN_BIT_VECTOR"),
     17 => ("   ","PASS    ","    ","              "),
     18 => ("   ","PASS    ","    ","              "),
     19 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function not_select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function not_select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of not_select_1of2 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of not_select_1of2 : function is true;
  attribute pin_bit_information of not_select_1of2 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","PASS    ","    ","              "),
     6 => ("   ","PASS    ","    ","              "),
     7 => ("   ","INV     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function not_select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function not_select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of not_select_1of3 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of not_select_1of3 : function is true;
  attribute PIN_BIT_INFORMATION of not_select_1of3 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","S2      ","SAME","PIN_BIT_SCALAR"),
     6 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","PASS    ","    ","              "),
     8 => ("   ","PASS    ","    ","              "),
     9 => ("   ","INV     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function not_select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function not_select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of not_select_1of4 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of not_select_1of4 : function is true;
  attribute pin_bit_information of not_select_1of4 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","S2      ","SAME","PIN_BIT_SCALAR"),
     6 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","S3      ","SAME","PIN_BIT_SCALAR"),
     8 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     9 => ("   ","PASS    ","    ","              "),
     10 => ("   ","PASS    ","    ","              "),
     11 => ("   ","INV     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function not_select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic ;
     gate4 : std_ulogic ;
     in4   : std_ulogic ;
     gate5 : std_ulogic ;
     in5   : std_ulogic ;
     gate6 : std_ulogic ;
     in6   : std_ulogic ;
     gate7 : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;

  function not_select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector ;
     gate4 : std_ulogic ;
     in4   : std_ulogic_vector ;
     gate5 : std_ulogic ;
     in5   : std_ulogic_vector ;
     gate6 : std_ulogic ;
     in6   : std_ulogic_vector ;
     gate7 : std_ulogic ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of not_select_1of8 : function is "VHDL-SELECT" ;
  attribute recursive_synthesis of not_select_1of8 : function is true;
  attribute pin_bit_information of not_select_1of8 : function is
    (1 => ("   ","S0      ","SAME","PIN_BIT_SCALAR"),
     2 => ("   ","D0      ","SAME","PIN_BIT_VECTOR"),
     3 => ("   ","S1      ","SAME","PIN_BIT_SCALAR"),
     4 => ("   ","D1      ","SAME","PIN_BIT_VECTOR"),
     5 => ("   ","S2      ","SAME","PIN_BIT_SCALAR"),
     6 => ("   ","D2      ","SAME","PIN_BIT_VECTOR"),
     7 => ("   ","S3      ","SAME","PIN_BIT_SCALAR"),
     8 => ("   ","D3      ","SAME","PIN_BIT_VECTOR"),
     9 => ("   ","S4      ","SAME","PIN_BIT_SCALAR"),
     10 => ("   ","D4      ","SAME","PIN_BIT_VECTOR"),
     11 => ("   ","S5      ","SAME","PIN_BIT_SCALAR"),
     12 => ("   ","D5      ","SAME","PIN_BIT_VECTOR"),
     13 => ("   ","S6      ","SAME","PIN_BIT_SCALAR"),
     14 => ("   ","D6      ","SAME","PIN_BIT_VECTOR"),
     15 => ("   ","S7      ","SAME","PIN_BIT_SCALAR"),
     16 => ("   ","D7      ","SAME","PIN_BIT_VECTOR"),
     17 => ("   ","PASS    ","    ","              "),
     18 => ("   ","PASS    ","    ","              "),
     19 => ("   ","INV     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

end std_ulogic_mux_support;

package body std_ulogic_mux_support is

  -- Multiplexor/Selector Functions
  function mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic;
  begin
    case  code is
      when '0'    => result := in0;
      when '1'    => result := in1;
      when others => result := 'X';
    end case;
    return result;
  end mux_2to1 ;

  function mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    case  code is
      when '0'    => result := in0;
      when '1'    => result := in1;
      when others => result := (others => 'X');
    end case;
    return result;
  end mux_2to1 ;

  function mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic;
  begin
    case  code is
      when "00"   => result := in0;
      when "01"   => result := in1;
      when "10"   => result := in2;
      when "11"   => result := in3;
      when others => result := 'X';
    end case;
    return result;
  end mux_4to1 ;

  function mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    case  code is
      when "00"   => result := in0;
      when "01"   => result := in1;
      when "10"   => result := in2;
      when "11"   => result := in3;
      when others => result := (others => 'X');
    end case;
    return result;
  end mux_4to1 ;

  function mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic;
  begin
    case  code is
      when "000"  => result := in0;
      when "001"  => result := in1;
      when "010"  => result := in2;
      when "011"  => result := in3;
      when "100"  => result := in4;
      when "101"  => result := in5;
      when "110"  => result := in6;
      when "111"  => result := in7;
      when others => result := 'X';
    end case;
    return result;
  end mux_8to1 ;

  function mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    case  code is
      when "000"  => result := in0;
      when "001"  => result := in1;
      when "010"  => result := in2;
      when "011"  => result := in3;
      when "100"  => result := in4;
      when "101"  => result := in5;
      when "110"  => result := in6;
      when "111"  => result := in7;
      when others => result := (others => 'X');
    end case;
    return result;
  end mux_8to1 ;

  -- Inverted Multiplexor Selector/Functions
  function not_mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic;
  begin
    case  code is
      when '0'    => result := not in0;
      when '1'    => result := not in1;
      when others => result := 'X';
    end case;
    return result;
  end not_mux_2to1 ;

  function not_mux_2to1
    (code  : std_ulogic ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    case  code is
      when '0'    => result := not in0;
      when '1'    => result := not in1;
      when others => result := (others => 'X');
    end case;
    return result;
  end not_mux_2to1 ;

  function not_mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic;
  begin
    case  code is
      when "00"   => result := not in0;
      when "01"   => result := not in1;
      when "10"   => result := not in2;
      when "11"   => result := not in3;
      when others => result := 'X';
    end case;
    return result;
  end not_mux_4to1 ;

  function not_mux_4to1
    (code  : std_ulogic_vector(0 to 1) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    case  code is
      when "00"   => result := not in0;
      when "01"   => result := not in1;
      when "10"   => result := not in2;
      when "11"   => result := not in3;
      when others => result := (others => 'X');
    end case;
    return result;
  end not_mux_4to1 ;

  function not_mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic;
  begin
    case  code is
      when "000"  => result := not in0;
      when "001"  => result := not in1;
      when "010"  => result := not in2;
      when "011"  => result := not in3;
      when "100"  => result := not in4;
      when "101"  => result := not in5;
      when "110"  => result := not in6;
      when "111"  => result := not in7;
      when others => result := 'X';
    end case;
    return result;
  end not_mux_8to1 ;

  function not_mux_8to1
    (code  : std_ulogic_vector(0 to 2) ;
     in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    case  code is
      when "000"  => result := not in0;
      when "001"  => result := not in1;
      when "010"  => result := not in2;
      when "011"  => result := not in3;
      when "100"  => result := not in4;
      when "101"  => result := not in5;
      when "110"  => result := not in6;
      when "111"  => result := not in7;
      when others => result := (others => 'X');
    end case;
    return result;
  end not_mux_8to1 ;

  -- Vectored primitive selector input functions
  function select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result :=  ( gate0 and in0 ) or
	       ( gate1 and in1 );
    return result ;
  end select_1of2 ;

  function select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
  begin
    result :=  ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	       ( ( 0 to in1'length-1 => gate1 ) and in1 );
    return result ;
  end select_1of2 ;

  function select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result := ( gate0 and in0 ) or
	      ( gate1 and in1 ) or
	      ( gate2 and in2 ) ;
    return result ;
  end select_1of3 ;

  function select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result :=  ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	       ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	       ( ( 0 to in1'length-1 => gate2 ) and in2 );
    return result ;
  end select_1of3 ;

  function select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result := ( gate0 and in0 ) or
	      ( gate1 and in1 ) or
	      ( gate2 and in2 ) or
	      ( gate3 and in3 );
    return result ;
  end select_1of4 ;

  function select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result :=  ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	       ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	       ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
	       ( ( 0 to in3'length-1 => gate3 ) and in3 ) ;
    return result ;
  end select_1of4 ;

  function select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic ;
     gate4 : std_ulogic ;
     in4   : std_ulogic ;
     gate5 : std_ulogic ;
     in5   : std_ulogic ;
     gate6 : std_ulogic ;
     in6   : std_ulogic ;
     gate7 : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result := ( gate0 and in0 ) or
	      ( gate1 and in1 ) or
	      ( gate2 and in2 ) or
	      ( gate3 and in3 ) or
	      ( gate4 and in4 ) or
	      ( gate5 and in5 ) or
	      ( gate6 and in6 ) or
	      ( gate7 and in7 ) ;
    return result ;
  end select_1of8 ;

  function select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector ;
     gate4 : std_ulogic ;
     in4   : std_ulogic_vector ;
     gate5 : std_ulogic ;
     in5   : std_ulogic_vector ;
     gate6 : std_ulogic ;
     in6   : std_ulogic_vector ;
     gate7 : std_ulogic ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result :=  ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	       ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	       ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
	       ( ( 0 to in3'length-1 => gate3 ) and in3 ) or
	       ( ( 0 to in4'length-1 => gate4 ) and in4 ) or
	       ( ( 0 to in5'length-1 => gate5 ) and in5 ) or
	       ( ( 0 to in6'length-1 => gate6 ) and in6 ) or
	       ( ( 0 to in7'length-1 => gate7 ) and in7 ) ;
    return result ;
  end select_1of8 ;

  function not_select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result :=  not( ( gate0 and in0 ) or
		    ( gate1 and in1 ) ) ;
    return result ;
  end not_select_1of2 ;

  function not_select_1of2
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result :=  not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		    ( ( 0 to in1'length-1 => gate1 ) and in1 ) ) ;
    return result ;
  end not_select_1of2 ;

  function not_select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result :=  not( ( gate0 and in0 ) or
		    ( gate1 and in1 ) or
		    ( gate2 and in2 ) ) ;
    return result ;
  end not_select_1of3 ;

  function not_select_1of3
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result :=  not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		    ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		    ( ( 0 to in1'length-1 => gate2 ) and in2 ) ) ;
    return result ;
  end not_select_1of3 ;

  function not_select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result :=  not( ( gate0 and in0 ) or
		    ( gate1 and in1 ) or
		    ( gate2 and in2 ) or
		    ( gate3 and in3 ) ) ;
    return result ;
  end not_select_1of4 ;

  function not_select_1of4
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result :=  not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		    ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		    ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
		    ( ( 0 to in3'length-1 => gate3 ) and in3 ) ) ;
    return result ;
  end not_select_1of4 ;

  function not_select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic ;
     in3   : std_ulogic ;
     gate4 : std_ulogic ;
     in4   : std_ulogic ;
     gate5 : std_ulogic ;
     in5   : std_ulogic ;
     gate6 : std_ulogic ;
     in6   : std_ulogic ;
     gate7 : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic ;
  begin
    result :=  not( ( gate0 and in0 ) or
		    ( gate1 and in1 ) or
		    ( gate2 and in2 ) or
		    ( gate3 and in3 ) or
		    ( gate4 and in4 ) or
		    ( gate5 and in5 ) or
		    ( gate6 and in6 ) or
		    ( gate7 and in7 ) ) ;
    return result ;
  end not_select_1of8 ;

  function not_select_1of8
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic ;
     in3   : std_ulogic_vector ;
     gate4 : std_ulogic ;
     in4   : std_ulogic_vector ;
     gate5 : std_ulogic ;
     in5   : std_ulogic_vector ;
     gate6 : std_ulogic ;
     in6   : std_ulogic_vector ;
     gate7 : std_ulogic ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector
  is
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result :=  not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		    ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		    ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
		    ( ( 0 to in3'length-1 => gate3 ) and in3 ) or
		    ( ( 0 to in4'length-1 => gate4 ) and in4 ) or
		    ( ( 0 to in5'length-1 => gate5 ) and in5 ) or
		    ( ( 0 to in6'length-1 => gate6 ) and in6 ) or
		    ( ( 0 to in7'length-1 => gate7 ) and in7 ) ) ;
    return result ;
  end not_select_1of8 ;

end std_ulogic_mux_support;
