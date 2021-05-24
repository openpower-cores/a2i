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

package std_ulogic_function_support is
  --  Subtypes used for constraining return values in package
  subtype std_return_2 is std_ulogic_vector(0 to 1);
  subtype std_return_4 is std_ulogic_vector(0 to 3);
  subtype std_return_8 is std_ulogic_vector(0 to 7);
  subtype std_return_16 is std_ulogic_vector(0 to 15);
  subtype std_return_32 is std_ulogic_vector(0 to 31);
  subtype std_return_64 is std_ulogic_vector(0 to 63);
  --  Test Case Evaluation Attributes
  -- These attributes are used to control the generation of TCE tests
  -- within the VHDL code.
  -- Valid on PORT, SIGNAL and LABEL .

  -- Used to turn task model generation on or off.  The attribute is applied
  -- to a label.  If on a block it turns off generation for the whole block.
  -- If on a statement it is for that statement alone.
  -- The string specifies which task  statement alone.
  -- attribute TCE_ON  of : label is "T,LTP,STP,DLTP,LST,STC,ASSRT,CMBN | ALL" ;
  attribute tce_on      : string;
  attribute tce_off     : string;
  attribute tce_last    : string;
  attribute tce_reset   : string;
  attribute tce_all_off : string;
  attribute tce_ignore  : string;
  -- The string specifies which task  statement alone.
  attribute tce_assertion   : string;
  attribute tce_combination : string;
  attribute tce_seqcond     : string;

  --  Global Signals
  -- Synopsys translate_off
  signal audit_bit_dump    : std_ulogic ;
  signal assertion_summary : boolean    ;
  signal assertion_clock   : std_ulogic ;
  -- Synopsys translate_on

  -- Synopsys translate_off
  component assertion
    generic( counted : boolean := false;
             Delay : natural := 0;
             Duration : natural := 0);
    port(
      assert_in  : in  std_ulogic  ;
      sample     : in  std_ulogic  ;
      assert_out : out std_ulogic
      );
  end component;
  -- Synopsys translate_on

  --  Function Declarations and Attributes
  --  Gate Function
  function gate
    (in0   : std_ulogic_vector;
     cond  : std_ulogic       )
    return std_ulogic_vector ;
  -- Synopsys translate_off
  attribute btr_name            of gate : function is "AND" ;
  attribute recursive_synthesis of gate : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   3 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  --  Dot Functions
  function dot_and
    (in0   : std_ulogic_vector       )
    return std_ulogic               ;
  -- Synopsys translate_off
  attribute btr_name            of dot_and : function is "VHDL-DOTA" ;
  attribute recursive_synthesis of dot_and : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of dot_and : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function dot_or
    (in0   : std_ulogic_vector          )
    return std_ulogic                  ;
  -- synopsys translate_off
  attribute btr_name            of dot_or     : function is "VHDL-DOTO" ;
  attribute recursive_synthesis of dot_or     : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of dot_or     : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function clock_tree_dot
    (in0   : std_ulogic_vector       )
    return std_ulogic               ;

  function clock_tree_dot
    (in0   : bit_vector             )
    return bit                     ;
  -- Synopsys translate_off
  attribute btr_name            of clock_tree_dot : function is "VHDL-CDOT" ;
  attribute recursive_synthesis of clock_tree_dot : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of clock_tree_dot : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  --  Generic Terminator
  procedure terminator
    (in0   : in std_ulogic
     -- synopsys translate_off
      ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     );

  procedure terminator
    (in0   : in std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     );
  -- synopsys translate_off
  attribute btr_name            of terminator : procedure is "TERMINATOR";
  attribute recursive_synthesis of terminator : procedure is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of terminator : procedure is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "));
  -- Synopsys translate_on

  --  Generic Delay
  function delay
    (in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic               ;

  function delay
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector        ;
  -- synopsys translate_off
  attribute btr_name            of delay : function is "IDENT" ;
  attribute recursive_synthesis of delay : function is true ;
  attribute block_data          of delay : function is
    "SUB_FUNC=/DELAY/LOGIC_STYLE=/DIRECT/" ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of delay : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  --  Generic Buffer
  function buff
    (in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic               ;

  function buff
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector        ;
  -- synopsys translate_off
  attribute btr_name            of buff : function is "IDENT" ;
  attribute recursive_synthesis of buff : function is true ;
  attribute block_data          of buff  : function is
    "LOGIC_STYLE=/DIRECT/" ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of buff : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Invert single bit
  function invert
    (in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- inverter vectored
  function invert
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of invert : function is "NOT" ;
  attribute recursive_synthesis of invert : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of invert : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Compare single bit
  function compare
    (in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- compare multi-bit
  function compare
    (in0   : std_ulogic_vector;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- synopsys translate_off
  attribute btr_name            of compare : function is "VHDL-COMPARE" ;
  attribute recursive_synthesis of compare : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of compare : function is
  --  (1 => ("   ","A0      ","INCR","PIN_BIT_SCALAR"),
  --   2 => ("   ","M0      ","INCR","PIN_BIT_SCALAR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","EQ      ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  --  Parity Functions
  --  General XOR_Tree Building Parity Function
  function parity
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic               ;
  -- synopsys translate_off
  attribute btr_name            of parity : function is "XOR" ;
  attribute recursive_synthesis of parity : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of parity : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on
  function parity_map
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic               ;

  -- synopsys translate_off
  attribute btr_name            of parity_map : function is "XOR" ;
  attribute recursive_synthesis of parity_map : function is true ;
  attribute block_data          of parity_map : function is
    "LOGIC_STYLE=/DIRECT/" ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of parity_map : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  -- Parity gneration/checking functions
  function parity_gen_odd
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic               ;

  -- synopsys translate_off
  attribute btr_name          of parity_gen_odd : function is "XNOR" ;
  attribute recursive_synthesis of parity_gen_odd : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of parity_gen_odd : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function parity_gen_even
    (in0   : std_ulogic_vector
     -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- Synopsys translate_on
     )
    return std_ulogic               ;
  -- Synopsys translate_off
  attribute btr_name          of parity_gen_even : function is "XOR" ;
  attribute recursive_synthesis of parity_gen_even : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of parity_gen_even : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function is_parity_odd
    (in0   : std_ulogic_vector
     -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- Synopsys translate_on
     )
    return std_ulogic               ;
  -- Synopsys translate_off
  attribute btr_name          of is_parity_odd : function is "XOR" ;
  attribute recursive_synthesis of is_parity_odd : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of is_parity_odd : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function is_parity_even
    (in0   : std_ulogic_vector
     -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- Synopsys translate_on
     )
    return std_ulogic               ;
  -- Synopsys translate_off
  attribute btr_name          of is_parity_even : function is "XNOR" ;
  attribute recursive_synthesis of is_parity_even : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of is_parity_even : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  --  Full Adder
  procedure full_add
    (add_1 : in  std_ulogic     ;
     add_2 : in  std_ulogic     ;
     cryin : in  std_ulogic     ;
     signal sum   : out std_ulogic     ;
     signal carry : out std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     );
  procedure full_add
    (add_1 : in  std_ulogic_vector ;
     add_2 : in  std_ulogic_vector ;
     cryin : in  std_ulogic_vector ;
     signal sum   : out std_ulogic_vector ;
     signal carry : out std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     );
  -- synopsys translate_off
  attribute btr_name            of full_add : procedure is "VHDL-FA";
  attribute recursive_synthesis of full_add : procedure is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of full_add : procedure is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","CIN     ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","SUM     ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","COUT    ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "));
  -- Synopsys translate_on

  --  Ripple Adder function
  procedure ripple_adder
    (add_1 : in  std_ulogic_vector ;
     add_2 : in  std_ulogic_vector ;
     signal   sum   : out std_ulogic_vector ;
     signal   carry : out std_ulogic ) ;

  procedure ripple_adder
    (add_1 : in  std_ulogic_vector ;
     add_2 : in  std_ulogic_vector ;
     signal   sum   : out std_ulogic_vector );

  --  Generic Tie Blocks
  function tie_0
    -- synopsys translate_off
    (btr   : in string                 :=""
     ;blkdata  : in string              :=""
     )
    -- synopsys translate_on
    return std_ulogic    ;
  -- synopsys translate_off
  attribute btr_name            of tie_0 : function is "VHDL-TIDN" ;
  attribute recursive_synthesis of tie_0 : function is true ;
  attribute block_data          of tie_0 : function is
    "LOGIC_STYLE=/DIRECT/" ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of tie_0 : function is
  --  (1 => ("   ","PASS    ","    ","              "),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","ZERO    ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function vector_tie_0
    (width : integer        := 1
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector          ;
  -- synopsys translate_off
  attribute btr_name            of vector_tie_0 : function is "VHDL-TIDN" ;
  attribute recursive_synthesis of vector_tie_0 : function is true ;
  attribute block_data          of vector_tie_0 : function is
    "LOGIC_STYLE=/DIRECT/" ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of vector_tie_0 : function is
  --  (1 => ("   ","IGNR    ","    ","              "),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","ZERO    ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function tie_1
    -- synopsys translate_off
    (btr   : in string                 :=""
     ;blkdata  : in string              :=""
     )
    -- synopsys translate_on
    return std_ulogic                 ;
  -- synopsys translate_off
  attribute btr_name            of tie_1    : function is "VHDL-TIUP" ;
  attribute recursive_synthesis of tie_1    : function is true ;
  attribute block_data          of tie_1    : function is
    "LOGIC_STYLE=/DIRECT/" ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of tie_1 : function is
  --  (1 => ("   ","PASS    ","    ","              "),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","ONE     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function vector_tie_1
    (width : integer        := 1
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector          ;
  -- synopsys translate_off
  attribute btr_name            of vector_tie_1 : function is "VHDL-TIUP" ;
  attribute recursive_synthesis of vector_tie_1 : function is true ;
  attribute block_data          of vector_tie_1 : function is
    "LOGIC_STYLE=/DIRECT/" ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of vector_tie_1 : function is
  --  (1 => ("   ","IGNR    ","    ","              "),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","ONE     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function reverse
    (arg: std_ulogic_vector)
    return std_ulogic_vector ;

  function and_reduce
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- synopsys translate_off
  attribute btr_name            of and_reduce : function is "AND" ;
  attribute recursive_synthesis of and_reduce : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_reduce : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function or_reduce
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- synopsys translate_off
  attribute btr_name            of or_reduce : function is "OR" ;
  attribute recursive_synthesis of or_reduce : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_reduce : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function nand_reduce
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- synopsys translate_off
  attribute btr_name            of nand_reduce : function is "NAND" ;
  attribute recursive_synthesis of nand_reduce : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_reduce : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function nor_reduce
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- synopsys translate_off
  attribute btr_name            of nor_reduce : function is "NOR" ;
  attribute recursive_synthesis of nor_reduce : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_reduce : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function xor_reduce
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- synopsys translate_off
  attribute btr_name            of xor_reduce : function is "XOR" ;
  attribute recursive_synthesis of xor_reduce : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of xor_reduce : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function xnor_reduce
    (in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- synopsys translate_off
  attribute btr_name            of xnor_reduce : function is "XNOR" ;
  attribute recursive_synthesis of xnor_reduce : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of xnor_reduce : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","OUT     ","SAME","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  -- Vector of gating bits gating a single vector of data bits
  function gate_and
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  function gate_and
    (gate  : std_ulogic ;
     in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function gate_and
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of gate_and : function is "AND" ;
  attribute recursive_synthesis of gate_and : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_and : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function gate_or
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  function gate_or
    (gate  : std_ulogic ;
     in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function gate_or
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of gate_or : function is "OR" ;
  attribute recursive_synthesis of gate_or : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_or : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function gate_nand
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  function gate_nand
    (gate  : std_ulogic ;
     in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function gate_nand
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of gate_nand : function is "NAND" ;
  attribute recursive_synthesis of gate_nand : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_nand : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function gate_nor
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  function gate_nor
    (gate  : std_ulogic ;
     in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function gate_nor
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of gate_nor : function is "NOR" ;
  attribute recursive_synthesis of gate_nor : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_nor : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function gate_xor
    (gate  : std_ulogic ;
     in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function gate_xor
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of gate_xor : function is "XOR" ;
  attribute recursive_synthesis of gate_xor : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_xor : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function gate_xnor
    (gate  : std_ulogic ;
     in0   : std_ulogic
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function gate_xnor
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of gate_xnor : function is "XNOR" ;
  attribute recursive_synthesis of gate_xnor : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_xnor : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Vectored primitive <gate> 2 input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function and_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function and_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of and_2 : function is "AND" ;
  attribute recursive_synthesis of and_2 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_2 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function or_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function or_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of or_2 : function is "OR" ;
  attribute recursive_synthesis of or_2 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_2 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nand_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nand_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nand_2 : function is "NAND" ;
  attribute recursive_synthesis of nand_2 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_2 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nor_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nor_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nor_2 : function is "NOR" ;
  attribute recursive_synthesis of nor_2 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_2 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function xor_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function xor_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of xor_2 : function is "XOR" ;
  attribute recursive_synthesis of xor_2 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of xor_2 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function xnor_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function xnor_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of xnor_2 : function is "XNOR" ;
  attribute recursive_synthesis of xnor_2 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of xnor_2 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Vectored primitive <gate> 3 input functions
  -- Single bit case
  function and_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  -- multiple vectors logically <gate>ed bitwise
  function and_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of and_3 : function is "AND" ;
  attribute recursive_synthesis of and_3 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_3 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function or_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function or_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of or_3 : function is "OR" ;
  attribute recursive_synthesis of or_3 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_3 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nand_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nand_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nand_3 : function is "NAND" ;
  attribute recursive_synthesis of nand_3 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_3 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nor_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nor_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nor_3 : function is "NOR" ;
  attribute recursive_synthesis of nor_3 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_3 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function xor_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function xor_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of xor_3 : function is "XOR" ;
  attribute recursive_synthesis of xor_3 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of xor_3 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function xnor_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function xnor_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of xnor_3 : function is "XNOR" ;
  attribute recursive_synthesis of xnor_3 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of xnor_3 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Vectored primitive <gate> 4 input functions
  -- Single bit case
  function and_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function and_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of and_4 : function is "AND" ;
  attribute recursive_synthesis of and_4 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_4 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function or_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function or_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of or_4 : function is "OR" ;
  attribute recursive_synthesis of or_4 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_4 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nand_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nand_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nand_4 : function is "NAND" ;
  attribute recursive_synthesis of nand_4 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_4 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nor_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nor_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nor_4 : function is "NOR" ;
  attribute recursive_synthesis of nor_4 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_4 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Vectored primitive <gate> 5 input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function and_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function and_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of and_5 : function is "AND" ;
  attribute recursive_synthesis of and_5 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_5 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function or_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function or_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of or_5 : function is "OR" ;
  attribute recursive_synthesis of or_5 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_5 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nand_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nand_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nand_5 : function is "NAND" ;
  attribute recursive_synthesis of nand_5 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_5 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nor_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nor_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nor_5 : function is "NOR" ;
  attribute recursive_synthesis of nor_5 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_5 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Vectored primitive <gate> 6 input functions
  -- Single bit case
  function and_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function and_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of and_6 : function is "AND" ;
  attribute recursive_synthesis of and_6 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_6 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function or_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function or_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of or_6 : function is "OR" ;
  attribute recursive_synthesis of or_6 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_6 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nand_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nand_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nand_6 : function is "NAND" ;
  attribute recursive_synthesis of nand_6 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_6 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nor_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nor_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nor_6 : function is "NOR" ;
  attribute recursive_synthesis of nor_6 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_6 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Vectored primitive <gate> 7 input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function and_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function and_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of and_7 : function is "AND" ;
  attribute recursive_synthesis of and_7 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_7 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function or_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function or_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of or_7 : function is "OR" ;
  attribute recursive_synthesis of or_7 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_7 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nand_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nand_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nand_7 : function is "NAND" ;
  attribute recursive_synthesis of nand_7 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_7 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nor_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nor_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nor_7 : function is "NOR" ;
  attribute recursive_synthesis of nor_7 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_7 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  -- Vectored primitive <gate> 8 input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function and_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function and_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of and_8 : function is "AND" ;
  attribute recursive_synthesis of and_8 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of and_8 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function or_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function or_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of or_8 : function is "OR" ;
  attribute recursive_synthesis of or_8 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of or_8 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nand_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nand_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nand_8 : function is "NAND" ;
  attribute recursive_synthesis of nand_8 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nand_8 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function nor_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic ;
  function nor_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name            of nor_8 : function is "NOR" ;
  attribute recursive_synthesis of nor_8 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of nor_8 : function is
  --  (1 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","IN      ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- Synopsys translate_on

  function decode( code  : std_ulogic_vector ) return  std_ulogic_vector;
  -- Synopsys translate_off
  attribute functionality of decode: function is "DECODER";
  -- Synopsys translate_on

  function decode_2to4
    (code  : std_ulogic_vector(0 to 1)
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return  std_return_4 ;
  -- synopsys translate_off
  attribute btr_name            of decode_2to4 : function is "VHDL-DECODE";
  attribute recursive_synthesis of decode_2to4 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of decode_2to4 : function is
  --  (1 => ("   ","D1      ","DECR","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","F0      ","INCR","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function decode_3to8
    (code  : std_ulogic_vector(0 to 2)
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return  std_return_8 ;
  -- synopsys translate_off
  attribute btr_name            of decode_3to8 : function is "VHDL-DECODE";
  attribute recursive_synthesis of decode_3to8 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of decode_3to8 : function is
  --  (1 => ("   ","D2      ","DECR","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","F0      ","INCR","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function decode_4to16
    (code  : std_ulogic_vector(0 to 3)
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return  std_return_16 ;
  -- synopsys translate_off
  attribute btr_name            of decode_4to16 : function is "VHDL-DECODE";
  attribute recursive_synthesis of decode_4to16 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of decode_4to16 : function is
  --  (1 => ("   ","D3      ","DECR","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","F0      ","INCR","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function decode_5to32
    (code  : std_ulogic_vector(0 to 4)
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return  std_return_32 ;
  -- synopsys translate_off
  attribute btr_name            of decode_5to32 : function is "VHDL-DECODE";
  attribute recursive_synthesis of decode_5to32 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of decode_5to32 : function is
  --  (1 => ("   ","D4      ","DECR","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","F0      ","INCR","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

  function decode_6to64
    (code  : std_ulogic_vector(0 to 5)
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return  std_return_64 ;
  -- synopsys translate_off
  attribute btr_name            of decode_6to64 : function is "VHDL-DECODE";
  attribute recursive_synthesis of decode_6to64 : function is true ;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of decode_6to64 : function is
  --  (1 => ("   ","D5      ","DECR","PIN_BIT_SCALAR"),
  --   2 => ("   ","PASS    ","    ","              "),
  --   3 => ("   ","PASS    ","    ","              "),
  --   4 => ("   ","F0      ","INCR","PIN_BIT_SCALAR"));
  -- Synopsys translate_on

end std_ulogic_function_support;

package body std_ulogic_function_support is
  --  Function Declarations and Attributes
  --  Gate Function
  function gate
    (in0   : std_ulogic_vector;
     cond  : std_ulogic      )
    return std_ulogic_vector
  is
    variable result : std_ulogic_vector (0 to in0'length-1);
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    result := in0 and vec_length'(0 to in0'length-1 => cond) ;
    return result;
  end gate;

  -- This function  everses the range direction.
  function reverse (arg: std_ulogic_vector)
    return std_ulogic_vector
  is
    variable d, result : std_ulogic_vector(0 to arg'length-1);
  begin
    d := arg;
    for i in 0 to d'length-1 loop
      result(result'right - i) := d(i);
    end loop;
    return result;
  end reverse;

  --  Generic Terminator
  procedure terminator
    (in0     : in std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
  is
    variable result     : std_ulogic ;
  -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
  -- Synopsys translate_on
  begin
    result := in0 ;
  end terminator ;

  procedure terminator
    (in0     : in std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1);
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 ;
  end terminator ;

  --  Generic Delay
  function delay
    (in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    -- initialize variable attribute values
    result  := in0;
    return result;
  end delay ;

  function delay
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := in0;
    return result;
  end delay ;

  function buff
    (in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := in0;
    return result;
  end buff  ;

  function buff
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := in0;
    return result;
  end buff  ;

-- inverter single bit
  function invert
    (in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := not in0;
    return result;
  end invert ;

  -- inverter vectored
  function invert
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := not in0;
    return result;
  end invert ;

  -- Comparator
  function compare
    (in0   : std_ulogic ;
     in1   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := in0 = in1 ;
    return result;
  end compare ;

-- comparator mult-bit
  function compare
    (in0   : std_ulogic_vector;
     in1   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := in0 = in1 ;
    return result;
  end compare ;

  --  General XOR_Tree Building Parity Function
  function parity
    (In0   : std_ulogic_vector
  -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
  -- Synopsys translate_on
     )
    return Std_uLogic
  is
    -- Synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- Synopsys translate_on
    variable result : std_ulogic;
  begin
    result := in0(in0'low);
    for i in in0'low+1 to in0'high loop
      result := in0(i) xor result ;
    end loop;
    return result;
  end parity ;

  --  Specific Size Parity Block Map Function
  function parity_map
    (In0   : std_ulogic_vector
     -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- Synopsys translate_on
     )
    return std_ulogic
  is
    -- Synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- Synopsys translate_on
    variable result : std_ulogic;
  begin
    result := in0(in0'low);
    for i in in0'low+1 to in0'high loop
      result := in0(i) xor result ;
    end loop;
    return result;
  end parity_map ;

-- Parity gneration/checking functions
  function parity_gen_odd
    (in0   : std_ulogic_vector
  -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
  -- Synopsys translate_on
     )
    return std_ulogic
  is
    -- Synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- Synopsys translate_on
    variable result : std_ulogic;
  begin
    result := in0(in0'low);
    for i in in0'low+1 to in0'high loop
      result := in0(i) xor result ;
    end loop;
    return not result;
  end parity_gen_odd ;

  function parity_gen_even
    (in0   : std_ulogic_vector
  -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
  -- Synopsys translate_on
     )
    return std_ulogic
  is
    -- Synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- Synopsys translate_on
    variable result : std_ulogic;
  begin
    result := in0(in0'low);
    for i in in0'low+1 to in0'high loop
      result := in0(i) xor result ;
    end loop;
    return result;
  end parity_gen_even ;

  function is_parity_odd
    (in0   : std_ulogic_vector
  -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
  -- Synopsys translate_on
     )
    return std_ulogic
  is
    -- Synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- Synopsys translate_on
    variable result : std_ulogic;
  begin
    result := in0(in0'low);
    for i in in0'low+1 to in0'high loop
      result := in0(i) xor result ;
    end loop;
    return result;
  end is_parity_odd ;

  function is_parity_even
    (in0   : std_ulogic_vector
     -- Synopsys translate_off
     ;btr   : in String                 :=""
     ;blkdata  : in String              :=""
     -- Synopsys translate_on
     )
    return std_ulogic
  is
    -- Synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- Synopsys translate_on
    variable result : std_ulogic;
  begin
    result := in0(in0'low);
    for i in in0'low+1 to in0'high loop
      result := in0(i) xor result ;
    end loop;
    return not result;
  end is_parity_even ;

  function and_reduce
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0(in0'left) ;
    for i in in0'range loop
      result := result and   in0(i);
    end loop;
    result :=       result ;
    return result;
  end and_reduce    ;

  function or_reduce
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0(in0'left) ;
    for i in in0'range loop
      result := result or    in0(i);
    end loop;
    result :=       result ;
    return result;
  end or_reduce     ;

  function nand_reduce
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0(in0'left) ;
    for i in in0'range loop
      result := result and   in0(i);
    end loop;
    result := not   result ;
    return result;
  end nand_reduce   ;

  function nor_reduce
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0(in0'left) ;
    for i in in0'range loop
      result := result or    in0(i);
    end loop;
    result := not   result ;
    return result;
  end nor_reduce    ;

  function xor_reduce
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := '0' ;
    for i in in0'range loop
      result := result xor   in0(i);
    end loop;
    result :=       result ;
    return result ;
  end xor_reduce    ;

  function xnor_reduce
    (in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := '0' ;
    for i in in0'range loop
      result := result xor   in0(i);
    end loop;
    result := not   result ;
    return result ;
  end xnor_reduce   ;

  function  gate_and
    (gate  : std_ulogic ;
     in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := gate and   in0 ;
    return result;
  end gate_and;

  function gate_and
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result  : std_ulogic_vector(0 to in0'length-1);
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    result := in0 and vec_length'(0 to in0'length-1 => gate) ;
    return result;
  end gate_and;

  function  gate_or
    (gate  : std_ulogic ;
     in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := gate or    in0 ;
    return result;
  end gate_or;

  function gate_or
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    result := in0 or vec_length'(0 to in0'length-1 => gate) ;
    return result;
  end gate_or;

  function  gate_nand
    (gate  : std_ulogic ;
     in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := gate nand  in0 ;
    return result;
  end gate_nand;

  function gate_nand
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    result := in0 nand vec_length'( 0 to in0'length-1 => gate );
    return result;
  end gate_nand;

  function  gate_nor
    (gate  : std_ulogic ;
     in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result : std_ulogic;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := gate nor   in0 ;
    return result;
  end gate_nor;

  function gate_nor
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    result := in0 nor vec_length'(0 to in0'length-1 => gate) ;
    return result;
  end gate_nor;

  function  gate_xor
    (gate  : std_ulogic ;
     in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := gate xor   in0 ;
    return result;
  end gate_xor;

  function gate_xor
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result : std_ulogic_vector(0 to in0'length-1);
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    result := in0 xor vec_length'(0 to in0'length-1 => gate) ;
    return result;
  end gate_xor;

  function  gate_xnor
    (gate  : std_ulogic ;
     in0   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := gate =     in0 ;
    return result;
  end gate_xnor;

  function gate_xnor
    (gate  : std_ulogic ;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    result := not( in0 xor vec_length'(0 to in0'length-1 => gate) ) ;
    return result;
  end gate_xnor;

  function gate_and
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
    variable gate_int   : std_ulogic ;
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    gate_int := gate(gate'low) ;
    for i in gate'low+1 to gate'high loop
      gate_int  := gate_int and gate(i);
    end loop;
    result := in0 and vec_length'(0 to in0'length-1 => gate_int) ;
    return result ;
  end gate_and;

  function gate_or
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
    variable gate_int   : std_ulogic ;
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    gate_int := gate(gate'low) ;
    for i in gate'low+1 to gate'high loop
      gate_int  := gate_int or gate(i);
    end loop;
    result := in0 or vec_length'(0 to in0'length-1 => gate_int) ;
    return result ;
  end gate_or;

  function gate_nand
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
    variable gate_int   : std_ulogic ;
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    gate_int := gate(gate'low) ;
    for i in gate'low+1 to gate'high loop
      gate_int  := gate_int and gate(i);
    end loop;
    result := in0 and vec_length'(0 to in0'length-1 => gate_int) ;
    result := not result ;
    return result;
  end gate_nand;

  function gate_nor
    (gate  : std_ulogic_vector;
     in0   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector(0 to in0'length-1);
    variable gate_int   : std_ulogic ;
    subtype vec_length is std_ulogic_vector(0 to in0'length-1);
  begin
    gate_int := gate(gate'low) ;
    for i in gate'low+1 to gate'high loop
      gate_int  := gate_int or gate(i);
    end loop;
    result := in0 or vec_length'(0 to in0'length-1 => gate_int) ;
    result := not result ;
    return result ;
  end gate_nor;

  function xor_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 xor in1 ;
    return result ;
  end xor_2    ;

  function xor_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 xor in1;
    return result ;
  end xor_2    ;

  function xor_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result :=       (in0 xor   in1 xor   in2) ;
    return result ;
  end xor_3    ;

  function xor_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 xor in1 xor in2 ;
    return result ;
  end xor_3    ;

  function xnor_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 xor in1 ) ;
    return result ;
  end xnor_2   ;

  function xnor_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
  -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
  -- synopsys translate_on
  begin
    result := not( in0 xor in1 ) ;
    return result ;
  end xnor_2   ;

  function xnor_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 xor in1 xor in2 ) ;
    return result ;
  end xnor_3   ;

  function xnor_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 xor in1 xor in2 ) ;
    return result ;
  end xnor_3   ;

  function and_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
  -- synopsys translate_on
  begin
    result := in0 and in1 ;
    return result ;
  end and_2    ;

  function and_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 ;
    return result ;
  end and_2    ;

  function and_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 ;
    return result ;
  end and_3    ;

  function and_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 ;
    return result ;
  end and_3    ;

  function and_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 ;
    return result ;
  end and_4    ;

  function and_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 ;
    return result ;
  end and_4    ;

  function and_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4 ;
    return result ;
  end and_5    ;

  function and_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4;
    return result ;
  end and_5    ;

  function and_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4 and in5 ;
    return result ;
  end and_6    ;

  function and_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4 and in5 ;
    return result ;
  end and_6    ;

  function and_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4 and in5 and in6 ;
    return result ;
  end and_7    ;

  function and_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4 and in5 and in6 ;
    return result ;
  end and_7    ;

  function and_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4 and in5 and in6 and in7 ;
    return result ;
  end and_8    ;

  function and_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    variable block_data : string(1 to 1) ;
    -- synopsys translate_off
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 and in1 and in2 and in3 and in4 and in5 and in6 and in7 ;
    return result ;
  end and_8    ;

  function or_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 ;
    return result ;
  end or_2     ;

  function or_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 ;
    return result ;
  end or_2     ;

  function or_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 ;
    return result ;
  end or_3     ;

  function or_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 ;
    return result ;
  end or_3     ;

  function or_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 ;
    return result ;
  end or_4     ;

  function or_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 ;
    return result ;
  end or_4     ;

  function or_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 ;
    return result ;
  end or_5     ;

  function or_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 ;
    return result ;
  end or_5     ;

  function or_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 or in5 ;
    return result ;
  end or_6     ;

  function or_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 or in5 ;
    return result ;
  end or_6     ;

  function or_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 or in5 or in6 ;
    return result ;
  end or_7     ;

  function or_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 or in5 or in6 ;
    return result ;
  end or_7     ;

  function or_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 ;
    return result ;
  end or_8     ;

  function or_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 ;
    return result ;
  end or_8     ;

  function nand_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 ) ;
    return result ;
  end nand_2   ;

  function nand_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 ) ;
    return result ;
  end nand_2   ;

  function nand_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 ) ;
    return result ;
  end nand_3   ;

  function nand_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 ) ;
    return result ;
  end nand_3   ;

  function nand_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 ) ;
    return result ;
  end nand_4   ;

  function nand_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 ) ;
    return result ;
  end nand_4   ;

  function nand_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 ) ;
    return result ;
  end nand_5   ;

  function nand_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 ) ;
    return result ;
  end nand_5   ;

  function nand_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 and in5 ) ;
    return result ;
  end nand_6   ;

  function nand_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 and in5 ) ;
    return result ;
  end nand_6   ;

  function nand_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 and in5 and in6) ;
    return result ;
  end nand_7   ;

  function nand_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 and in5 and in6) ;
    return result ;
  end nand_7   ;

  function nand_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 and in5 and in6 and in7 ) ;
    return result ;
  end nand_8   ;

  function nand_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
  -- synopsys translate_on
  begin
    result := not( in0 and in1 and in2 and in3 and in4 and in5 and in6 and in7 ) ;
    return result ;
  end nand_8   ;

  function nor_2
    (in0   : std_ulogic ;
     in1   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 ) ;
    return result ;
  end nor_2    ;

  function nor_2
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 ) ;
    return result ;
  end nor_2    ;

  function nor_3
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 ) ;
    return result ;
  end nor_3    ;

  function nor_3
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1) ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 ) ;
    return result ;
  end nor_3    ;

  function nor_4
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 ) ;
    return result ;
  end nor_4    ;

  function nor_4
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1) ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 ) ;
    return result ;
  end nor_4    ;

  function nor_5
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 ) ;
    return result ;
  end nor_5    ;

  function nor_5
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 ) ;
    return result ;
  end nor_5    ;

  function nor_6
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 or in5 ) ;
    return result ;
  end nor_6    ;

  function nor_6
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 or in5 ) ;
    return result ;
  end nor_6    ;

  function nor_7
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 or in5 or in6 ) ;
    return result ;
  end nor_7    ;

  function nor_7
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 or in5 or in6 ) ;
    return result ;
  end nor_7    ;

  function nor_8
    (in0   : std_ulogic ;
     in1   : std_ulogic ;
     in2   : std_ulogic ;
     in3   : std_ulogic ;
     in4   : std_ulogic ;
     in5   : std_ulogic ;
     in6   : std_ulogic ;
     in7   : std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic
  is
    variable result     : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 ) ;
    return result ;
  end nor_8    ;

  function nor_8
    (in0   : std_ulogic_vector ;
     in1   : std_ulogic_vector ;
     in2   : std_ulogic_vector ;
     in3   : std_ulogic_vector ;
     in4   : std_ulogic_vector ;
     in5   : std_ulogic_vector ;
     in6   : std_ulogic_vector ;
     in7   : std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
     return std_ulogic_vector
  is
    variable result     : std_ulogic_vector (0 to in0'length-1);
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
  -- synopsys translate_on
  begin
    result := not( in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 ) ;
    return result ;
  end nor_8    ;

  function tie_0
  -- synopsys translate_off
     (btr   : in string                 :="";
      blkdata  : in string              :=""
     )
  -- synopsys translate_on
    return std_ulogic
  is
    variable result : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := '0';
    return result;
  end tie_0;

  function vector_tie_0
    (width : integer        := 1
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return std_ulogic_vector
  is
    variable result : std_ulogic_vector(0 to width-1) ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    for i in 0 to width-1 loop
      result(i) := '0';
    end loop;
    return result;
  end vector_tie_0;

  function tie_1
  -- synopsys translate_off
    (btr   : in string                 :=""
     ;blkdata  : in string              :=""
     )
  -- synopsys translate_on
    return std_ulogic
  is
    variable result : std_ulogic ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    result  := '1';
    return result;
  end tie_1;

  function vector_tie_1
    (width : integer        := 1
     -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
     -- synopsys translate_on
     )
    return std_ulogic_vector
  is
    variable result : std_ulogic_vector(0 to width-1) ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    for i in 0 to width-1 loop
      result(i) := '1';
    end loop;
    return result;
  end vector_tie_1;

  function decode( code  : std_ulogic_vector ) return  std_ulogic_vector is
    variable result : std_ulogic_vector(0 to (2**(code'length)-1)) := (others => '0');
  begin
    result := (others => '0');
    result( tconv( code ) ) := '1';
    for i in code'low to code'high loop
      if code(i) = 'U' then
        result := (others => 'U');
      end if;
    end loop;
    for i in code'low to code'high loop
      if code(i) = 'X' then
        result := (others => 'X');
      end if;
    end loop;
    return result;
  end decode;

  function decode_2to4
    (code  : std_ulogic_vector(0 to 1)
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return  std_return_4
  is
    variable result : std_ulogic_vector(0 to 3) ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    case  code is
      when "00"  => result := "1000";
      when "01"  => result := "0100";
      when "10"  => result := "0010";
      when "11"  => result := "0001";
      when others => result := "XXXX";
    end case;
    return result;
  end decode_2to4;

  function decode_3to8
    (code  : std_ulogic_vector(0 to 2)
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return  std_return_8
  is
    variable result : std_ulogic_vector(0 to 7) ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    case  code is
      when "000"  => result := "10000000";
      when "001"  => result := "01000000";
      when "010"  => result := "00100000";
      when "011"  => result := "00010000";
      when "100"  => result := "00001000";
      when "101"  => result := "00000100";
      when "110"  => result := "00000010";
      when "111"  => result := "00000001";
      when others => result := "XXXXXXXX";
    end case;
    return result;
  end decode_3to8;

  function decode_4to16
    (code  : std_ulogic_vector(0 to 3)
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return  std_return_16
  is
    variable result : std_ulogic_vector(0 to 15) ;
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    case  code is
      when "0000"  => result := "1000000000000000";
      when "0001"  => result := "0100000000000000";
      when "0010"  => result := "0010000000000000";
      when "0011"  => result := "0001000000000000";
      when "0100"  => result := "0000100000000000";
      when "0101"  => result := "0000010000000000";
      when "0110"  => result := "0000001000000000";
      when "0111"  => result := "0000000100000000";
      when "1000"  => result := "0000000010000000";
      when "1001"  => result := "0000000001000000";
      when "1010"  => result := "0000000000100000";
      when "1011"  => result := "0000000000010000";
      when "1100"  => result := "0000000000001000";
      when "1101"  => result := "0000000000000100";
      when "1110"  => result := "0000000000000010";
      when "1111"  => result := "0000000000000001";
      when others  => result := "XXXXXXXXXXXXXXXX";
    end case;
    return result;
  end decode_4to16;

  function decode_5to32
    (code  : std_ulogic_vector(0 to 4)
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return  std_return_32
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result : std_ulogic_vector(0 to 31) ;
  begin
    case  code is
      when "00000"  => result := "10000000000000000000000000000000";
      when "00001"  => result := "01000000000000000000000000000000";
      when "00010"  => result := "00100000000000000000000000000000";
      when "00011"  => result := "00010000000000000000000000000000";
      when "00100"  => result := "00001000000000000000000000000000";
      when "00101"  => result := "00000100000000000000000000000000";
      when "00110"  => result := "00000010000000000000000000000000";
      when "00111"  => result := "00000001000000000000000000000000";
      when "01000"  => result := "00000000100000000000000000000000";
      when "01001"  => result := "00000000010000000000000000000000";
      when "01010"  => result := "00000000001000000000000000000000";
      when "01011"  => result := "00000000000100000000000000000000";
      when "01100"  => result := "00000000000010000000000000000000";
      when "01101"  => result := "00000000000001000000000000000000";
      when "01110"  => result := "00000000000000100000000000000000";
      when "01111"  => result := "00000000000000010000000000000000";
      when "10000"  => result := "00000000000000001000000000000000";
      when "10001"  => result := "00000000000000000100000000000000";
      when "10010"  => result := "00000000000000000010000000000000";
      when "10011"  => result := "00000000000000000001000000000000";
      when "10100"  => result := "00000000000000000000100000000000";
      when "10101"  => result := "00000000000000000000010000000000";
      when "10110"  => result := "00000000000000000000001000000000";
      when "10111"  => result := "00000000000000000000000100000000";
      when "11000"  => result := "00000000000000000000000010000000";
      when "11001"  => result := "00000000000000000000000001000000";
      when "11010"  => result := "00000000000000000000000000100000";
      when "11011"  => result := "00000000000000000000000000010000";
      when "11100"  => result := "00000000000000000000000000001000";
      when "11101"  => result := "00000000000000000000000000000100";
      when "11110"  => result := "00000000000000000000000000000010";
      when "11111"  => result := "00000000000000000000000000000001";
      when others   => result := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    end case;
    return result;
  end decode_5to32;

  function decode_6to64
    (code  : std_ulogic_vector(0 to 5)
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
    return  std_return_64
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
    variable result : std_ulogic_vector(0 to 63) ;
  begin
    case  code is
      when "000000" => result := "1000000000000000000000000000000000000000000000000000000000000000";
      when "000001" => result := "0100000000000000000000000000000000000000000000000000000000000000";
      when "000010" => result := "0010000000000000000000000000000000000000000000000000000000000000";
      when "000011" => result := "0001000000000000000000000000000000000000000000000000000000000000";
      when "000100" => result := "0000100000000000000000000000000000000000000000000000000000000000";
      when "000101" => result := "0000010000000000000000000000000000000000000000000000000000000000";
      when "000110" => result := "0000001000000000000000000000000000000000000000000000000000000000";
      when "000111" => result := "0000000100000000000000000000000000000000000000000000000000000000";
      when "001000" => result := "0000000010000000000000000000000000000000000000000000000000000000";
      when "001001" => result := "0000000001000000000000000000000000000000000000000000000000000000";
      when "001010" => result := "0000000000100000000000000000000000000000000000000000000000000000";
      when "001011" => result := "0000000000010000000000000000000000000000000000000000000000000000";
      when "001100" => result := "0000000000001000000000000000000000000000000000000000000000000000";
      when "001101" => result := "0000000000000100000000000000000000000000000000000000000000000000";
      when "001110" => result := "0000000000000010000000000000000000000000000000000000000000000000";
      when "001111" => result := "0000000000000001000000000000000000000000000000000000000000000000";
      when "010000" => result := "0000000000000000100000000000000000000000000000000000000000000000";
      when "010001" => result := "0000000000000000010000000000000000000000000000000000000000000000";
      when "010010" => result := "0000000000000000001000000000000000000000000000000000000000000000";
      when "010011" => result := "0000000000000000000100000000000000000000000000000000000000000000";
      when "010100" => result := "0000000000000000000010000000000000000000000000000000000000000000";
      when "010101" => result := "0000000000000000000001000000000000000000000000000000000000000000";
      when "010110" => result := "0000000000000000000000100000000000000000000000000000000000000000";
      when "010111" => result := "0000000000000000000000010000000000000000000000000000000000000000";
      when "011000" => result := "0000000000000000000000001000000000000000000000000000000000000000";
      when "011001" => result := "0000000000000000000000000100000000000000000000000000000000000000";
      when "011010" => result := "0000000000000000000000000010000000000000000000000000000000000000";
      when "011011" => result := "0000000000000000000000000001000000000000000000000000000000000000";
      when "011100" => result := "0000000000000000000000000000100000000000000000000000000000000000";
      when "011101" => result := "0000000000000000000000000000010000000000000000000000000000000000";
      when "011110" => result := "0000000000000000000000000000001000000000000000000000000000000000";
      when "011111" => result := "0000000000000000000000000000000100000000000000000000000000000000";
      when "100000" => result := "0000000000000000000000000000000010000000000000000000000000000000";
      when "100001" => result := "0000000000000000000000000000000001000000000000000000000000000000";
      when "100010" => result := "0000000000000000000000000000000000100000000000000000000000000000";
      when "100011" => result := "0000000000000000000000000000000000010000000000000000000000000000";
      when "100100" => result := "0000000000000000000000000000000000001000000000000000000000000000";
      when "100101" => result := "0000000000000000000000000000000000000100000000000000000000000000";
      when "100110" => result := "0000000000000000000000000000000000000010000000000000000000000000";
      when "100111" => result := "0000000000000000000000000000000000000001000000000000000000000000";
      when "101000" => result := "0000000000000000000000000000000000000000100000000000000000000000";
      when "101001" => result := "0000000000000000000000000000000000000000010000000000000000000000";
      when "101010" => result := "0000000000000000000000000000000000000000001000000000000000000000";
      when "101011" => result := "0000000000000000000000000000000000000000000100000000000000000000";
      when "101100" => result := "0000000000000000000000000000000000000000000010000000000000000000";
      when "101101" => result := "0000000000000000000000000000000000000000000001000000000000000000";
      when "101110" => result := "0000000000000000000000000000000000000000000000100000000000000000";
      when "101111" => result := "0000000000000000000000000000000000000000000000010000000000000000";
      when "110000" => result := "0000000000000000000000000000000000000000000000001000000000000000";
      when "110001" => result := "0000000000000000000000000000000000000000000000000100000000000000";
      when "110010" => result := "0000000000000000000000000000000000000000000000000010000000000000";
      when "110011" => result := "0000000000000000000000000000000000000000000000000001000000000000";
      when "110100" => result := "0000000000000000000000000000000000000000000000000000100000000000";
      when "110101" => result := "0000000000000000000000000000000000000000000000000000010000000000";
      when "110110" => result := "0000000000000000000000000000000000000000000000000000001000000000";
      when "110111" => result := "0000000000000000000000000000000000000000000000000000000100000000";
      when "111000" => result := "0000000000000000000000000000000000000000000000000000000010000000";
      when "111001" => result := "0000000000000000000000000000000000000000000000000000000001000000";
      when "111010" => result := "0000000000000000000000000000000000000000000000000000000000100000";
      when "111011" => result := "0000000000000000000000000000000000000000000000000000000000010000";
      when "111100" => result := "0000000000000000000000000000000000000000000000000000000000001000";
      when "111101" => result := "0000000000000000000000000000000000000000000000000000000000000100";
      when "111110" => result := "0000000000000000000000000000000000000000000000000000000000000010";
      when "111111" => result := "0000000000000000000000000000000000000000000000000000000000000001";
      when others   => result := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    end case;
    return result;
  end decode_6to64;

--  full adder function
  procedure full_add
    (add_1 : in  std_ulogic     ;
     add_2 : in  std_ulogic     ;
     cryin : in  std_ulogic     ;
     signal sum   : out std_ulogic     ;
     signal carry : out std_ulogic
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
  is
    -- synopsys translate_off
    variable block_data : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    sum    <= add_1 xor add_2 xor  cryin;
    carry  <= (add_1 and add_2) or
              (add_1 and cryin) or
              (add_2 and cryin);
  end full_add;

  procedure full_add
    (add_1 : in  std_ulogic_vector ;
     add_2 : in  std_ulogic_vector ;
     cryin : in  std_ulogic_vector ;
     signal sum   : out std_ulogic_vector ;
     signal carry : out std_ulogic_vector
  -- synopsys translate_off
     ;btr   : in string                 :=""
     ;blkdata  : in string              :=""
  -- synopsys translate_on
     )
  is
    variable sum_result     : std_ulogic_vector(sum'range) ;
    variable carry_result   : std_ulogic_vector(carry'range) ;
    -- synopsys translate_off
    variable block_data     : string(1 to 1) ;
    attribute dynamic_block_data of block_data : variable is
      "CUE_BTR=/" & btr & "/" &
      blkdata ;
    -- synopsys translate_on
  begin
    -- synopsys translate_off
    assert (add_1'length = add_2'length)
      report "Addends of Full_Add are not the same length."
      severity error;
    assert (add_1'length = cryin'length) and (add_2'length = cryin'length)
      report "Addends of Full_Add are not the same length as the CryIn."
      severity error;
    -- synopsys translate_on
    sum_result   :=  add_1 xor add_2 xor  cryin;
    carry_result := (add_1 and add_2) or
                    (add_1 and cryin) or
                    (add_2 and cryin);
    sum   <= sum_result   ;
    carry <= carry_result ;
  end full_add;

  --  Ripple adder function
  procedure ripple_adder
    (       add_1 : in  std_ulogic_vector ;
            add_2 : in  std_ulogic_vector ;
            signal   sum   : out std_ulogic_vector ;
            signal   carry : out std_ulogic )
  is
    -- Synopsys translate_off
    attribute unroll_loop : boolean;
    attribute unroll_loop of ripple : label is true;
    -- Synopsys translate_on
    variable a     : std_ulogic_vector(1 to add_1'length) ;
    variable b     : std_ulogic_vector(1 to add_2'length) ;
    variable c     : std_ulogic_vector(0 to add_1'length) ;
    variable result : std_ulogic_vector(1 to add_1'length) ;
  begin
    a := add_1;
    b := add_2;
    c(c'right) := '0' ;
    ripple:for i in result'right downto 1 loop
      c(i-1) := ( c(i) and a(i) ) or
                ( c(i) and b(i) ) or
                ( a(i) and b(i) ) ;
      result(i) := a(i) xor b(i) xor c(i) ;
    end loop ;
    sum   <= result ;
    carry <= c(c'left) ;
  end ripple_adder ;

  procedure ripple_adder
    (       add_1 : in  std_ulogic_vector ;
            add_2 : in  std_ulogic_vector ;
            signal   sum   : out std_ulogic_vector )
  is
    -- Synopsys translate_off
    attribute unroll_loop : boolean;
    attribute unroll_loop of ripple : label is true;
    -- Synopsys translate_on
    variable a     : std_ulogic_vector(1 to add_1'length) ;
    variable b     : std_ulogic_vector(1 to add_2'length) ;
    variable c     : std_ulogic_vector(1 to add_1'length) ;
    variable result : std_ulogic_vector(1 to add_1'length) ;
  begin
    a := add_1;
    b := add_2;
    c(c'right) := '0' ;
    ripple:for i in result'right downto 2 loop
      c(i-1) := ( c(i) and a(i) ) or
                ( c(i) and b(i) ) or
                ( a(i) and b(i) ) ;
      result(i) := a(i) xor b(i) xor c(i) ;
    end loop ;
    result(1) := a(1) xor b(1) xor c(1) ;
    sum   <= result ;
  end ripple_adder ;

  --  Dot Functions
  function dot_and
    (in0   : std_ulogic_vector              )
    return  std_ulogic
  is
    variable result     : std_ulogic ;
  begin
    result := '1';
    for i in in0'range loop
      result  := in0(i) and result ;
    end loop ;
    return result;
  end dot_and   ;

  function dot_or
    (in0   : std_ulogic_vector              )
    return  std_ulogic
  is
    variable result  : std_ulogic  ;
  begin
    result := '0';
    for i in in0'range loop
      result  := in0(i) or result ;
    end loop ;
    return result;
  end dot_or    ;

  function clock_tree_dot
    (in0   : std_ulogic_vector              )
    return  std_ulogic
  is
    variable result  : std_ulogic  ;
  begin
    result := '1';
    for i in in0'range loop
      result  := in0(i) and result ;
    end loop ;
    return result;
  end clock_tree_dot   ;

  function clock_tree_dot
    (in0   : bit_vector                     )
    return  bit
  is
    variable result  : bit  ;
  begin
    result := '1';
    for i in in0'range loop
      result  := in0(i) and result ;
    end loop ;
    return result;
  end clock_tree_dot   ;

end std_ulogic_function_support;

