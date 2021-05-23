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

package std_ulogic_ao_support is
  -- =============================================================
  -- 2 input Port AO/OA Gates
  -- =============================================================
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function gate_ao_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_2x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_2x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_2x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_2x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","PASS    ","    ","              "),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_2x2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_2x2
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
  attribute btr_name   of gate_ao_2x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_2x2
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
  attribute btr_name   of gate_aoi_2x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_2x2
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
  attribute btr_name   of gate_oa_2x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x2
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_2x2
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
  attribute btr_name   of gate_oai_2x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  -- =============================================================
  -- 2x3 input Port AO/OA Gates
  -- =============================================================
  -- Vectored primitive <gate> input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function gate_ao_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_2x1x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x1x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_2x1x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x1x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_2x1x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x1x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_2x1x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x1x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_2x2x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x2x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_2x2x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x2x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_2x2x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x2x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_2x2x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x2x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_2x2x2
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
  function gate_ao_2x2x2
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
  attribute btr_name   of gate_ao_2x2x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x2x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x2x2
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
  function gate_aoi_2x2x2
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
  attribute btr_name   of gate_aoi_2x2x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x2x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x2x2
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
  function gate_oa_2x2x2
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
  attribute btr_name   of gate_oa_2x2x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x2x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x2x2
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
  function gate_oai_2x2x2
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
  attribute btr_name   of gate_oai_2x2x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x2x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  -- =============================================================
  -- 2x4 input Port AO/OA Gates
  -- =============================================================
  -- Vectored primitive <gate> input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function gate_ao_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_2x1x1x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x1x1x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_2x1x1x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x1x1x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_2x1x1x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x1x1x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_2x1x1x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x1x1x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x1x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x1x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_2x2x1x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x2x1x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_2x2x1x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x2x1x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_2x2x1x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x2x1x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_2x2x1x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x2x1x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x2x1x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x2x1x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_2x2x2x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x2x2x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_2x2x2x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x2x2x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_2x2x2x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x2x2x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_2x2x2x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x2x2x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x2x2x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x2x2x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_2x2x2x2
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
  function gate_ao_2x2x2x2
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
  attribute btr_name   of gate_ao_2x2x2x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_2x2x2x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_2x2x2x2
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
  function gate_aoi_2x2x2x2
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
  attribute btr_name   of gate_aoi_2x2x2x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_2x2x2x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_2x2x2x2
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
  function gate_oa_2x2x2x2
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
  attribute btr_name   of gate_oa_2x2x2x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_2x2x2x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_2x2x2x2
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
  function gate_oai_2x2x2x2
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
  attribute btr_name   of gate_oai_2x2x2x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_SCALAR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_2x2x2x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_2x2x2x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_2x2x2x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","C       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","D       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  -- =============================================================
  -- 3 input Port AO/OA Gates
  -- =============================================================
  -- Vectored primitive <gate> input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function gate_ao_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_3x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_3x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_3x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_3x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_3x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_3x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_3x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_3x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_3x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_3x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","PASS    ","    ","              "),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_3x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_3x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_3x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_3x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_3x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_3x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_3x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_3x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_3x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_3x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_3x3 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_3x3 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_3x3 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_3x3 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_3x3 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_3x3 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_3x3 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_3x3 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_3x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_3x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  -- =============================================================
  -- 4 input Port AO/OA Gates
  -- =============================================================
  -- Vectored primitive <gate> input functions
  -- Single bit case
  -- Multiple vectors logically <gate>ed bitwise
  function gate_ao_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_4x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_4x1 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_4x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_4x1 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_4x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_4x1 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_4x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_4x1 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_4x1 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_4x1 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","PASS    ","    ","              "),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_4x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_4x2 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_4x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_4x2 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_4x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_4x2 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_4x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_4x2 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_4x2 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_4x2 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","PASS    ","    ","              "),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_4x3 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_4x3 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_4x3 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_4x3 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_4x3 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_4x3 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_4x3 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_4x3 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_4x3 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_4x3 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","PASS    ","    ","              "),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_ao_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_ao_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_ao_4x4 : function is "VHDL-AO" ;
  attribute recursive_synthesis of gate_ao_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_ao_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function ao_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function ao_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of ao_4x4 : function is "VHDL-AO" ;
  attribute recursive_synthesis of ao_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of ao_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_aoi_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_aoi_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_aoi_4x4 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of gate_aoi_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_aoi_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function aoi_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function aoi_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of aoi_4x4 : function is "VHDL-AOI" ;
  attribute recursive_synthesis of aoi_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of aoi_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oa_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oa_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oa_4x4 : function is "VHDL-OA" ;
  attribute recursive_synthesis of gate_oa_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oa_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oa_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oa_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oa_4x4 : function is "VHDL-OA" ;
  attribute recursive_synthesis of oa_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oa_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function gate_oai_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function gate_oai_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of gate_oai_4x4 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of gate_oai_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of gate_oai_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

  function oai_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic ;
  function oai_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
     -- synopsys translate_off
     ;btr   : string := ""
     ;blkdata : string := ""
     -- synopsys translate_on
     ) return std_ulogic_vector ;
  -- synopsys translate_off
  attribute btr_name   of oai_4x4 : function is "VHDL-OAI" ;
  attribute recursive_synthesis of oai_4x4 : function is true;
  -- FIXME: GHDL with LLVM backend crashes here (see https://github.com/ghdl/ghdl/issues/1772)
  --attribute pin_bit_information of oai_4x4 : function is
  --  (1 => ("   ","A       ","SAME","PIN_BIT_SCALAR"),
  --   2 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   3 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   4 => ("   ","A       ","SAME","PIN_BIT_VECTOR"),
  --   5 => ("   ","B       ","SAME","PIN_BIT_SCALAR"),
  --   6 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   7 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   8 => ("   ","B       ","SAME","PIN_BIT_VECTOR"),
  --   9 => ("   ","PASS    ","    ","              "),
  --   10 => ("   ","PASS    ","    ","              "),
  --   11 => ("   ","OUT     ","SAME","PIN_BIT_VECTOR"));
  -- synopsys translate_on

end std_ulogic_ao_support;

package body std_ulogic_ao_support is
  -- =============================================================
  -- 2 input port ao/oa gates
  -- =============================================================
  function gate_ao_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
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
    result :=  ( gate0 and in0 ) or gate1 ;
    return result ;
  end gate_ao_2x1 ;

  function gate_ao_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
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
    result :=   ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		( 0 to in0'length-1 => gate1 ) ;
    return result ;
  end gate_ao_2x1 ;

  function ao_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
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
    result :=   ( in0a and in0b ) or in1a;
    return result ;
  end ao_2x1 ;

  function ao_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result :=   ( in0a and in0b ) or in1a;
    return result ;
  end ao_2x1 ;

  function gate_aoi_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
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
    result := not (  ( gate0 and in0 ) or gate1 );
    return result ;
  end gate_aoi_2x1 ;

  function gate_aoi_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
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
    result := not ( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		    ( 0 to in0'length-1 => gate1 ) );
    return result ;
  end gate_aoi_2x1 ;

  function aoi_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( in0a and in0b ) or in1a ) ;
    return result ;
  end aoi_2x1 ;

  function aoi_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b ) or in1a ) ;
    return result ;
  end aoi_2x1 ;

  function gate_oa_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
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
    result := ( gate0 or in0 ) and gate1 ;
    return result ;
  end gate_oa_2x1 ;

  function gate_oa_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( 0 to in0'length-1 => gate1 ) ;
    return result ;
  end gate_oa_2x1 ;

  function oa_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( in0a or in0b ) and in1a ;
    return result ;
  end oa_2x1 ;

  function oa_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b ) and in1a ;
    return result ;
  end oa_2x1 ;

  function gate_oai_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic
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
    result := not( ( gate0 or in0 ) and gate1 ) ;
    return result ;
  end gate_oai_2x1 ;

  function gate_oai_2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		   ( 0 to in0'length-1 => gate1 ) ) ;
    return result ;
  end gate_oai_2x1 ;

  function oai_2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( in0a or in0b ) and in1a ) ;
    return result ;
  end oai_2x1 ;

  function oai_2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b ) and in1a ) ;
    return result ;
  end oai_2x1 ;

  function gate_ao_2x2
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
    result := ( ( gate0 and in0 ) or ( gate1 and in1 ) ) ;
    return result ;
  end gate_ao_2x2 ;

  function gate_ao_2x2
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
    result :=   ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		( ( 0 to in1'length-1 => gate1 ) and in1 ) ;
    return result ;
  end gate_ao_2x2 ;

  function ao_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result :=   ((in0a and in0b) or (in1a and in1b));
    return result ;
  end ao_2x2 ;

  function ao_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result :=   ((in0a and in0b) or (in1a and in1b));
    return result ;
  end ao_2x2 ;

  function gate_aoi_2x2
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
    result := not ((gate0 and in0) or (gate1 and in1));
    return result ;
  end gate_aoi_2x2 ;

  function gate_aoi_2x2
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
    result := not ( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		    ( ( 0 to in0'length-1 => gate1 ) and in1 ) );
    return result ;
  end gate_aoi_2x2 ;

  function aoi_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not ((in0a and in0b) or (in1a and in1b));
    return result ;
  end aoi_2x2 ;

  function aoi_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not ( ( in0a and in0b ) or ( in1a and in1b ) );
    return result ;
  end aoi_2x2 ;

  function gate_oa_2x2
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
    result :=   ((gate0 or in0) and (gate1 or in1));
    return result ;
  end gate_oa_2x2 ;

  function gate_oa_2x2
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
    result :=   ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		( ( 0 to in1'length-1 => gate1 ) or in1 );
    return result ;
  end gate_oa_2x2 ;

  function oa_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result :=   ((in0a or in0b) and (in1a or in1b));
    return result ;
  end oa_2x2 ;

  function oa_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result :=   ( ( in0a or in0b ) and ( in1a or in1b ) );
    return result ;
  end oa_2x2 ;

  function gate_oai_2x2
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
    result := not ((gate0 or in0) and (gate1 or in1));
    return result ;
  end gate_oai_2x2 ;

  function gate_oai_2x2
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
    result := not ( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		    ( ( 0 to in1'length-1 => gate1 ) or in1 ) );
    return result ;
  end gate_oai_2x2 ;

  function oai_2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not ((in0a or in0b) and (in1a or in1b));
    return result ;
  end oai_2x2 ;

  function oai_2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not ( ( in0a or in0b ) and ( in1a or in1b ) );
    return result ;
  end oai_2x2 ;

  -- =============================================================
  -- 3x2 input Port AO/OA Gates
  -- =============================================================

  function gate_ao_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
	      ( gate1 ) or
	      ( gate2 );
    return result ;
  end gate_ao_2x1x1 ;

  function gate_ao_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	      ( 0 to in0'length-1 => gate1 ) or
	      ( 0 to in0'length-1 => gate2 ) ;
    return result ;
  end gate_ao_2x1x1 ;

  function ao_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
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
    result := ( in0a and in0b ) or ( in1a ) or ( in2a ) ;
    return result ;
  end ao_2x1x1 ;

  function ao_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b ) or
	      ( in1a ) or
	      ( in2a ) ;
    return result ;
  end ao_2x1x1 ;

  function gate_aoi_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
    result := not ( ( gate0 and in0 ) or
		    ( gate1 ) or
		    ( gate2 ) );
    return result ;
  end gate_aoi_2x1x1 ;

  function gate_aoi_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		   ( 0 to in0'length-1 => gate1 ) or
		   ( 0 to in0'length-1 => gate2 ) );
    return result ;
  end gate_aoi_2x1x1 ;

  function aoi_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
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
    result := not ((in0a and in0b) or (in1a) or (in2a));
    return result ;
  end aoi_2x1x1 ;

  function aoi_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not ( ( in0a and in0b ) or
		    ( in1a ) or
		    ( in2a ) );
    return result ;
  end aoi_2x1x1 ;

  function gate_oa_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
    variable result : std_ulogic ;
  begin
    result := ( gate0 or in0 ) and
	      ( gate1 ) and
	      ( gate2 );
    return result ;
  end gate_oa_2x1x1 ;

  function gate_oa_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( 0 to in0'length-1 => gate1 ) and
	      ( 0 to in0'length-1 => gate2 ) ;
    return result ;
  end gate_oa_2x1x1 ;

  function oa_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
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
    result := ( ( in0a or in0b ) and ( in1a ) and ( in2a ) );
    return result ;
  end oa_2x1x1 ;

  function oa_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector(0 to in0a'length-1);
  begin
    result := ( ( in0a or in0b ) and
		( in1a ) and
		( in2a ) );
    return result ;
  end oa_2x1x1 ;

  function gate_oai_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
    result := not ( ( gate0 or in0 ) and
		    ( gate1 ) and
		    ( gate2 ) ) ;
    return result ;
  end gate_oai_2x1x1 ;

  function gate_oai_2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic
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
    result := not ( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		    ( 0 to in0'length-1 => gate1 ) and
		    ( 0 to in0'length-1 => gate2 ) ) ;
    return result ;
  end gate_oai_2x1x1 ;

  function oai_2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic
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
    result := not ((in0a or in0b) and (in1a) and (in2a));
    return result ;
  end oai_2x1x1 ;

  function oai_2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not ((in0a    or in0b) and
		   (in1a) and
		   (in2a));
    return result ;
  end oai_2x1x1 ;

  function gate_ao_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
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
	      ( gate2 ) ;
    return result ;
  end gate_ao_2x2x1 ;

  function gate_ao_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	      ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	      ( 0 to in0'length-1 => gate2 ) ;
    return result ;
  end gate_ao_2x2x1 ;

  function ao_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
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
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a ) ;
    return result ;
  end ao_2x2x1 ;

  function ao_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result :=   ((in0a and in0b) or
		 (in1a and in1b) or
		 (in2a));
    return result ;
  end ao_2x2x1 ;

  function gate_aoi_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
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
    result := not( ( gate0 and in0 ) or
		   ( gate1 and in1 ) or
		   ( gate2 ) ) ;
    return result ;
  end gate_aoi_2x2x1 ;

  function gate_aoi_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		   ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		   ( 0 to in0'length-1 => gate2 ) ) ;
    return result ;
  end gate_aoi_2x2x1 ;

  function aoi_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
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
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a ) ) ;
    return result ;
  end aoi_2x2x1 ;

  function aoi_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a ) ) ;
    return result ;
  end aoi_2x2x1 ;

  function gate_oa_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
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
    result := ( gate0 or in0 ) and
	      ( gate1 or in1 ) and
	      ( gate2 ) ;
    return result ;
  end gate_oa_2x2x1 ;

  function gate_oa_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
	      ( 0 to in0'length-1 => gate2 ) ;
    return result ;
  end gate_oa_2x2x1 ;

  function oa_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
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
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a ) ;
    return result ;
  end oa_2x2x1 ;

  function oa_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a ) ;
    return result ;
  end oa_2x2x1 ;

  function gate_oai_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic
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
    result := not( ( gate0 or in0 ) and
		   ( gate1 or in1 ) and
		   ( gate2 ) );
    return result ;
  end gate_oai_2x2x1 ;

  function gate_oai_2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		   ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
		   ( 0 to in0'length-1 => gate2 ) ) ;
    return result ;
  end gate_oai_2x2x1 ;

  function oai_2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic
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
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a ) );
    return result ;
  end oai_2x2x1 ;

  function oai_2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a ) );
    return result ;
  end oai_2x2x1 ;

  function gate_ao_2x2x2
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
  end gate_ao_2x2x2 ;

  function gate_ao_2x2x2
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
    result := ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	      ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	      ( ( 0 to in2'length-1 => gate2 ) and in2 ) ;
    return result ;
  end gate_ao_2x2x2 ;

  function ao_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
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
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a and in2b ) ;
    return result ;
  end ao_2x2x2 ;

  function ao_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a and in2b ) ;
    return result ;
  end ao_2x2x2 ;

  function gate_aoi_2x2x2
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
    result := not( ( gate0 and in0 ) or
		   ( gate1 and in1 ) or
		   ( gate2 and in2 ) );
    return result ;
  end gate_aoi_2x2x2 ;

  function gate_aoi_2x2x2
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		   ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		   ( ( 0 to in2'length-1 => gate2 ) and in2 ) ) ;
    return result ;
  end gate_aoi_2x2x2 ;

  function aoi_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
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
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a and in2b ) );
    return result ;
  end aoi_2x2x2 ;

  function aoi_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a and in2b ) );
    return result ;
  end aoi_2x2x2 ;

  function gate_oa_2x2x2
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
    result := ( gate0 or in0 ) and
	      ( gate1 or in1 ) and
	      ( gate2 or in2 ) ;
    return result ;
  end gate_oa_2x2x2 ;

  function gate_oa_2x2x2
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
	      ( ( 0 to in2'length-1 => gate2 ) or in2 ) ;
    return result ;
  end gate_oa_2x2x2 ;

  function oa_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
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
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a or in2b ) ;
    return result ;
  end oa_2x2x2 ;

  function oa_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a or in2b ) ;
    return result ;
  end oa_2x2x2 ;

  function gate_oai_2x2x2
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
    result := not( ( gate0 or in0 ) and
		   ( gate1 or in1 ) and
		   ( gate2 or in2 ) ) ;
    return result ;
  end gate_oai_2x2x2 ;

  function gate_oai_2x2x2
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		   ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
		   ( ( 0 to in2'length-1 => gate2 ) or in2 ) ) ;
    return result ;
  end gate_oai_2x2x2 ;

  function oai_2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic
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
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a or in2b ) ) ;
    return result ;
  end oai_2x2x2 ;

  function oai_2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a or in2b ) ) ;
    return result ;
  end oai_2x2x2 ;

  -- =============================================================
  -- 4x2 input Port AO/OA Gates
  -- =============================================================

  function gate_ao_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
	      ( gate1 ) or
	      ( gate2 ) or
	      ( gate3 ) ;
    return result ;
  end gate_ao_2x1x1x1 ;

  function gate_ao_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	      ( 0 to in0'length-1 => gate1 ) or
	      ( 0 to in0'length-1 => gate2 ) or
	      ( 0 to in0'length-1 => gate3 ) ;
    return result ;
  end gate_ao_2x1x1x1 ;

  function ao_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := ( in0a and in0b ) or
	      ( in1a ) or
	      ( in2a ) or
	      ( in3a ) ;
    return result ;
  end ao_2x1x1x1 ;

  function ao_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b ) or
	      ( in1a ) or
	      ( in2a ) or
	      ( in3a ) ;
    return result ;
  end ao_2x1x1x1 ;

  function gate_aoi_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( gate0 and in0 ) or
		   ( gate1 ) or
		   ( gate2 ) or
		   ( gate3 ) ) ;
    return result ;
  end gate_aoi_2x1x1x1 ;

  function gate_aoi_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		   ( 0 to in0'length-1 => gate1 ) or
		   ( 0 to in0'length-1 => gate2 ) or
		   ( 0 to in0'length-1 => gate3 ) ) ;
    return result ;
  end gate_aoi_2x1x1x1 ;

  function aoi_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := not( ( in0a and in0b ) or
		   ( in1a ) or
		   ( in2a ) or
		   ( in3a ) ) ;
    return result ;
  end aoi_2x1x1x1 ;

  function aoi_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b ) or
		   ( in1a ) or
		   ( in2a ) or
		   ( in3a ) ) ;
    return result ;
  end aoi_2x1x1x1 ;

  function gate_oa_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := ( gate0 or in0 ) and
	      ( gate1 ) and
	      ( gate2 ) and
	      ( gate3 );
    return result ;
  end gate_oa_2x1x1x1 ;

  function gate_oa_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( 0 to in0'length-1 => gate1 ) and
	      ( 0 to in0'length-1 => gate2 ) and
	      ( 0 to in0'length-1 => gate3 );
    return result ;
  end gate_oa_2x1x1x1 ;

  function oa_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := ( in0a or in0b ) and
	      ( in1a ) and
	      ( in2a ) and
	      ( in3a ) ;
    return result ;
  end oa_2x1x1x1 ;

  function oa_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b ) and
	      ( in1a ) and
	      ( in2a ) and
	      ( in3a ) ;
    return result ;
  end oa_2x1x1x1 ;

  function gate_oai_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( gate0 or in0 ) and
		   ( gate1 ) and
		   ( gate2 ) and
		   ( gate3 ) ) ;
    return result ;
  end gate_oai_2x1x1x1 ;

  function gate_oai_2x1x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		   ( 0 to in0'length-1 => gate1 ) and
		   ( 0 to in0'length-1 => gate2 ) and
		   ( 0 to in0'length-1 => gate3 ) ) ;
    return result ;
  end gate_oai_2x1x1x1 ;

  function oai_2x1x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := not( ( in0a or in0b ) and
		   ( in1a ) and
		   ( in2a ) and
		   ( in3a ) ) ;
    return result ;
  end oai_2x1x1x1 ;

  function oai_2x1x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b ) and
		   ( in1a ) and
		   ( in2a ) and
		   ( in3a ) ) ;
    return result ;
  end oai_2x1x1x1 ;

  function gate_ao_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
	      ( gate2 ) or
	      ( gate3 ) ;
    return result ;
  end gate_ao_2x2x1x1 ;

  function gate_ao_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	      ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	      ( 0 to in0'length-1 => gate2 ) or
	      ( 0 to in0'length-1 => gate3 ) ;
    return result ;
  end gate_ao_2x2x1x1 ;

  function ao_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a ) or
	      ( in3a ) ;
    return result ;
  end ao_2x2x1x1 ;

  function ao_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a ) or
	      ( in3a ) ;
    return result ;
  end ao_2x2x1x1 ;

  function gate_aoi_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( gate0 and in0 ) or
		   ( gate1 and in1 ) or
		   ( gate2 ) or
		   ( gate3 ) ) ;
    return result ;
  end gate_aoi_2x2x1x1 ;

  function gate_aoi_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		   ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		   ( 0 to in0'length-1 => gate2 ) or
		   ( 0 to in0'length-1 => gate3 ) ) ;
    return result ;
  end gate_aoi_2x2x1x1 ;

  function aoi_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a ) or
		   ( in3a ) ) ;
    return result ;
  end aoi_2x2x1x1 ;

  function aoi_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a ) or
		   ( in3a ) ) ;
    return result ;
  end aoi_2x2x1x1 ;

  function gate_oa_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := ( gate0 or in0 ) and
	      ( gate1 or in1 ) and
	      ( gate2 ) and
	      ( gate3 ) ;
    return result ;
  end gate_oa_2x2x1x1 ;

  function gate_oa_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
	      ( 0 to in0'length-1 => gate2 ) and
	      ( 0 to in0'length-1 => gate3 ) ;
    return result ;
  end gate_oa_2x2x1x1 ;

  function oa_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a ) and
	      ( in3a ) ;
    return result ;
  end oa_2x2x1x1 ;

  function oa_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a ) and
	      ( in3a ) ;
    return result ;
  end oa_2x2x1x1 ;

  function gate_oai_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( gate0 or in0 ) and
		   ( gate1 or in1 ) and
		   ( gate2 ) and
		   ( gate3 ) ) ;
    return result ;
  end gate_oai_2x2x1x1 ;

  function gate_oai_2x2x1x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		   ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
		   ( 0 to in0'length-1 => gate2 ) and
		   ( 0 to in0'length-1 => gate3 ) ) ;
    return result ;
  end gate_oai_2x2x1x1 ;

  function oai_2x2x1x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in3a  : std_ulogic
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
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a ) and
		   ( in3a ) ) ;
    return result ;
  end oai_2x2x1x1 ;

  function oai_2x2x1x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a ) and
		   ( in3a ) ) ;
    return result ;
  end oai_2x2x1x1 ;

  function gate_ao_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
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
	      ( gate3 ) ;
    return result ;
  end gate_ao_2x2x2x1 ;

  function gate_ao_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	      ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	      ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
	      ( 0 to in0'length-1 => gate3 ) ;
    return result ;
  end gate_ao_2x2x2x1 ;

  function ao_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
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
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a and in2b ) or
	      ( in3a ) ;
    return result ;
  end ao_2x2x2x1 ;

  function ao_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a and in2b ) or
	      ( in3a ) ;
    return result ;
  end ao_2x2x2x1 ;

  function gate_aoi_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( gate0 and in0 ) or
		   ( gate1 and in1 ) or
		   ( gate2 and in2 ) or
		   ( gate3 ) );
    return result ;
  end gate_aoi_2x2x2x1 ;

  function gate_aoi_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		   ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		   ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
		   ( 0 to in0'length-1 => gate3 ) );
    return result ;
  end gate_aoi_2x2x2x1 ;

  function aoi_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
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
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a and in2b ) or
		   ( in3a ) ) ;
    return result ;
  end aoi_2x2x2x1 ;

  function aoi_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a and in2b ) or
		   ( in3a ) ) ;
    return result ;
  end aoi_2x2x2x1 ;

  function gate_oa_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
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
    result := ( gate0 or in0 ) and
	      ( gate1 or in1 ) and
	      ( gate2 or in2 ) and
	      ( gate3 ) ;
    return result ;
  end gate_oa_2x2x2x1 ;

  function gate_oa_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
	      ( ( 0 to in2'length-1 => gate2 ) or in2 ) and
	      ( 0 to in0'length-1 => gate3 ) ;
    return result ;
  end gate_oa_2x2x2x1 ;

  function oa_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
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
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a or in2b ) and
	      ( in3a ) ;
    return result ;
  end oa_2x2x2x1 ;

  function oa_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a or in2b ) and
	      ( in3a ) ;
    return result ;
  end oa_2x2x2x1 ;

  function gate_oai_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic ;
     gate1 : std_ulogic ;
     in1   : std_ulogic ;
     gate2 : std_ulogic ;
     in2   : std_ulogic ;
     gate3 : std_ulogic
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
    result := not( ( gate0 or in0 ) and
		   ( gate1 or in1 ) and
		   ( gate2 or in2 ) and
		   ( gate3 ) ) ;
    return result ;
  end gate_oai_2x2x2x1 ;

  function gate_oai_2x2x2x1
    (gate0 : std_ulogic ;
     in0   : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1   : std_ulogic_vector ;
     gate2 : std_ulogic ;
     in2   : std_ulogic_vector ;
     gate3 : std_ulogic
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		   ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
		   ( ( 0 to in2'length-1 => gate2 ) or in2 ) and
		   ( 0 to in0'length-1 => gate3 ) ) ;
    return result ;
  end gate_oai_2x2x2x1 ;

  function oai_2x2x2x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic
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
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a or in2b ) and
		   ( in3a ) ) ;
    return result ;
  end oai_2x2x2x1 ;

  function oai_2x2x2x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a or in2b ) and
		   ( in3a ) ) ;
    return result ;
  end oai_2x2x2x1 ;

  function gate_ao_2x2x2x2
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
	      ( gate3 and in3 ) ;
    return result ;
  end gate_ao_2x2x2x2 ;

  function gate_ao_2x2x2x2
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
    result := ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
	      ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
	      ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
	      ( ( 0 to in3'length-1 => gate3 ) and in3 ) ;
    return result ;
  end gate_ao_2x2x2x2 ;

  function ao_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
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
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a and in2b ) or
	      ( in3a and in3b ) ;
    return result ;
  end ao_2x2x2x2 ;

  function ao_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b ) or
	      ( in1a and in1b ) or
	      ( in2a and in2b ) or
	      ( in3a and in3b ) ;
    return result ;
  end ao_2x2x2x2 ;

  function gate_aoi_2x2x2x2
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
    result := not( ( gate0 and in0 ) or
		   ( gate1 and in1 ) or
		   ( gate2 and in2 ) or
		   ( gate3 and in3 ) ) ;
    return result ;
  end gate_aoi_2x2x2x2 ;

  function gate_aoi_2x2x2x2
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
    attribute dynamic_block_data of BLOCK_DATA : variable is
      "CUE_BTR=/" & BTR & "/" &
      BLKDATA ;
    -- synopsys translate_on
    variable result     : std_ulogic_vector (0 to in0'length-1);
  begin
    result := not( ( ( 0 to in0'length-1 => gate0 ) and in0 ) or
		   ( ( 0 to in1'length-1 => gate1 ) and in1 ) or
		   ( ( 0 to in2'length-1 => gate2 ) and in2 ) or
		   ( ( 0 to in3'length-1 => gate3 ) and in3 ) ) ;
    return result ;
  end gate_aoi_2x2x2x2 ;

  function aoi_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
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
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a and in2b ) or
		   ( in3a and in3b ) ) ;
    return result ;
  end aoi_2x2x2x2 ;

  function aoi_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b ) or
		   ( in1a and in1b ) or
		   ( in2a and in2b ) or
		   ( in3a and in3b ) ) ;
    return result ;
  end aoi_2x2x2x2 ;

  function gate_oa_2x2x2x2
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
    result := ( gate0 or in0 ) and
	      ( gate1 or in1 ) and
	      ( gate2 or in2 ) and
	      ( gate3 or in3 ) ;
    return result ;
  end gate_oa_2x2x2x2 ;

  function gate_oa_2x2x2x2
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
    result := ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
	      ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
	      ( ( 0 to in2'length-1 => gate2 ) or in2 ) and
	      ( ( 0 to in3'length-1 => gate3 ) or in3 ) ;
    return result ;
  end gate_oa_2x2x2x2 ;

  function oa_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
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
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a or in2b ) and
	      ( in3a or in3b ) ;
    return result ;
  end oa_2x2x2x2 ;

  function oa_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b ) and
	      ( in1a or in1b ) and
	      ( in2a or in2b ) and
	      ( in3a or in3b ) ;
    return result ;
  end oa_2x2x2x2 ;

  function gate_oai_2x2x2x2
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
    result := not( ( gate0 or in0 ) and
		   ( gate1 or in1 ) and
		   ( gate2 or in2 ) and
		   ( gate3 or in3 ) ) ;
    return result ;
  end gate_oai_2x2x2x2 ;

  function gate_oai_2x2x2x2
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
    result := not( ( ( 0 to in0'length-1 => gate0 ) or in0 ) and
		   ( ( 0 to in1'length-1 => gate1 ) or in1 ) and
		   ( ( 0 to in2'length-1 => gate2 ) or in2 ) and
		   ( ( 0 to in3'length-1 => gate3 ) or in3 ) ) ;
    return result ;
  end gate_oai_2x2x2x2 ;

  function oai_2x2x2x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in2a  : std_ulogic ;
     in2b  : std_ulogic ;
     in3a  : std_ulogic ;
     in3b  : std_ulogic
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
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a or in2b ) and
		   ( in3a or in3b ) ) ;
    return result ;
  end oai_2x2x2x2 ;

  function oai_2x2x2x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in2a  : std_ulogic_vector ;
     in2b  : std_ulogic_vector ;
     in3a  : std_ulogic_vector ;
     in3b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b ) and
		   ( in1a or in1b ) and
		   ( in2a or in2b ) and
		   ( in3a or in3b ) ) ;
    return result ;
  end oai_2x2x2x2 ;

  -- =============================================================
  -- 3 input Port AO/OA Gates
  -- =============================================================

  function gate_ao_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
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
    result := ( gate0 and in0a and in0b) or
	      ( gate1 ) ;
    return result ;
  end gate_ao_3x1 ;

  function gate_ao_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b) or
	      ( 0 to in0a'length-1 => gate1 ) ;
    return result ;
  end gate_ao_3x1 ;

  function ao_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( in0a and in0b and in0c ) or
	      ( in1a ) ;
    return result ;
  end ao_3x1 ;

  function ao_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector( 0 to in0a'length-1 ) ;
  begin
    result := ( in0a and in0b and in0c ) or
	      ( in1a ) ;
    return result ;
  end ao_3x1 ;

  function gate_aoi_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
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
    result := not( ( gate0 and in0a and in0b) or
		   ( gate1 ) ) ;
    return result ;
  end gate_aoi_3x1 ;

  function gate_aoi_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b) or
		   ( 0 to in0a'length-1 => gate1 ) ) ;
    return result ;
  end gate_aoi_3x1 ;

  function aoi_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( in0a and in0b and in0c ) or
		   ( in1a ) );
    return result ;
  end aoi_3x1 ;

  function aoi_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b and in0c ) or
		   ( in1a ) );
    return result ;
  end aoi_3x1 ;

  function gate_oa_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
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
    result := ( gate0 or in0a or in0b ) and
	      ( gate1 ) ;
    return result ;
  end gate_oa_3x1 ;

  function gate_oa_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b ) and
	      ( 0 to in0a'length-1 => gate1 ) ;
    return result ;
  end gate_oa_3x1 ;

  function oa_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( in0a or in0b or in0c ) and
	      ( in1a ) ;
    return result ;
  end oa_3x1 ;

  function oa_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b or in0c ) and
	      ( in1a ) ;
    return result ;
  end oa_3x1 ;

  function gate_oai_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic
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
    result := not( ( gate0 or in0a or in0b ) and
		   ( gate1 ) ) ;
    return result ;
  end gate_oai_3x1 ;

  function gate_oai_3x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b ) and
		   ( 0 to in0a'length-1 => gate1 ) ) ;
    return result ;
  end gate_oai_3x1 ;

  function oai_3x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( in0a or in0b or in0c ) and
		   ( in1a ) );
    return result ;
  end oai_3x1 ;

  function oai_3x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b or in0c ) and
		   ( in1a ) );
    return result ;
  end oai_3x1 ;

  function gate_ao_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( gate0 and in0a and in0b ) or
	      ( gate1 and in1a ) ;
    return result ;
  end gate_ao_3x2 ;

  function gate_ao_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b ) or
	      ( ( 0 to in1a'length-1 => gate1 ) and in1a ) ;
    return result ;
  end gate_ao_3x2 ;

  function ao_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( in0a and in0b and in0c ) or
	      ( in1a and in1b ) ;
    return result ;
  end ao_3x2 ;

  function ao_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b and in0c ) or
	      ( in1a and in1b ) ;
    return result ;
  end ao_3x2 ;

  function gate_aoi_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( gate0 and in0a and in0b ) or
		   ( gate1 and in1a ) ) ;
    return result ;
  end gate_aoi_3x2 ;

  function gate_aoi_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b ) or
		   ( ( 0 to in1a'length-1 => gate1 ) and in1a ) ) ;
    return result ;
  end gate_aoi_3x2 ;

  function aoi_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( in0a and in0b and in0c ) or
		   ( in1a and in1b ) ) ;
    return result ;
  end aoi_3x2 ;

  function aoi_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b and in0c ) or
		   ( in1a and in1b ) ) ;
    return result ;
  end aoi_3x2 ;

  function gate_oa_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( gate0 or in0a or in0b ) and
	      ( gate1 or in1a ) ;
    return result ;
  end gate_oa_3x2 ;

  function gate_oa_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b ) and
	      ( ( 0 to in1a'length-1 => gate1 ) or in1a ) ;
    return result ;
  end gate_oa_3x2 ;

  function oa_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( in0a or in0b or in0c ) and
	      ( in1a or in1b ) ;
    return result ;
  end oa_3x2 ;

  function oa_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b or in0c ) and
	      ( in1a or in1b ) ;
    return result ;
  end oa_3x2 ;

  function gate_oai_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( gate0 or in0a or in0b ) and
		   ( gate1 or in1a ) );
    return result ;
  end gate_oai_3x2 ;

  function gate_oai_3x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b ) and
		   ( ( 0 to in1a'length-1 => gate1 ) or in1a ) );
    return result ;
  end gate_oai_3x2 ;

  function oai_3x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( in0a or in0b or in0c ) and
		   ( in1a or in1b ) );
    return result ;
  end oai_3x2 ;

  function oai_3x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b or in0c ) and
		   ( in1a or in1b ) );
    return result ;
  end oai_3x2 ;

  function gate_ao_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( gate0 and in0a and in0b ) or
	      ( gate1 and in1a and in1b ) ;
    return result ;
  end gate_ao_3x3 ;

  function gate_ao_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b ) or
	      ( ( 0 to in1a'length-1 => gate1 ) and in1a and in1b ) ;
    return result ;
  end gate_ao_3x3 ;

  function ao_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := ( in0a and in0b and in0c ) or
	      ( in1a and in1b and in1c ) ;
    return result ;
  end ao_3x3 ;

  function ao_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b and in0c ) or
	      ( in1a and in1b and in1c ) ;
    return result ;
  end ao_3x3 ;

  function gate_aoi_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( gate0 and in0a and in0b ) or
		   ( gate1 and in1a and in1b ) ) ;
    return result ;
  end gate_aoi_3x3 ;

  function gate_aoi_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length => gate0 ) and in0a and in0b ) or
		   ( ( 0 to in1a'length => gate1 ) and in1a and in1b ) ) ;
    return result ;
  end gate_aoi_3x3 ;

  function aoi_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := not( ( in0a and in0b and in0c ) or
		   ( in1a and in1b and in1c ) );
    return result ;
  end aoi_3x3 ;

  function aoi_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b and in0c ) or
		   ( in1a and in1b and in1c ) );
    return result ;
  end aoi_3x3 ;

  function gate_oa_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( gate0 or in0a or in0b ) and
	      ( gate1 or in1a or in1b ) ;
    return result ;
  end gate_oa_3x3 ;

  function gate_oa_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b ) and
	      ( ( 0 to in1a'length-1 => gate1 ) or in1a or in1b ) ;
    return result ;
  end gate_oa_3x3 ;

  function oa_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := ( in0a or in0b or in0c ) and
	      ( in1a or in1b or in1c ) ;
    return result ;
  end oa_3x3 ;

  function oa_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b or in0c ) and
	      ( in1a or in1b or in1c ) ;
    return result ;
  end oa_3x3 ;

  function gate_oai_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( gate0 or in0a or in0b ) and
		   ( gate1 or in1a or in1b ) ) ;
    return result ;
  end gate_oai_3x3 ;

  function gate_oai_3x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b ) and
		   ( ( 0 to in1a'length-1 => gate1 ) or in1a or in1b ) ) ;
    return result ;
  end gate_oai_3x3 ;

  function oai_3x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := not( ( in0a or in0b or in0c ) and
		   ( in1a or in1b or in1c ) ) ;
    return result ;
  end oai_3x3 ;

  function oai_3x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b or in0c ) and
		   ( in1a or in1b or in1c ) ) ;
    return result ;
  end oai_3x3 ;

  -- =============================================================
  -- 4 input Port AO/OA Gates
  -- =============================================================

  function gate_ao_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
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
    result := ( gate0 and in0a and in0b and in0c ) or
	      ( gate1 ) ;
    return result ;
  end gate_ao_4x1 ;

  function gate_ao_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
	      ( 0 to in0a'length-1 => gate1 ) ;
    return result ;
  end gate_ao_4x1 ;

  function ao_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a ) ;
    return result ;
  end ao_4x1 ;

  function ao_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a ) ;
    return result ;
  end ao_4x1 ;

  function gate_aoi_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
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
    result := not( ( gate0 and in0a and in0b and in0c ) or
		   ( gate1 ) );
    return result ;
  end gate_aoi_4x1 ;

  function gate_aoi_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
		   ( 0 to in0a'length-1 => gate1 ) ) ;
    return result ;
  end gate_aoi_4x1 ;

  function aoi_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a ) ) ;
    return result ;
  end aoi_4x1 ;

  function aoi_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a ) ) ;
    return result ;
  end aoi_4x1 ;

  function gate_oa_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
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
    result := ( gate0 or in0a or in0b or in0c ) and
	      ( gate1 ) ;
    return result ;
  end gate_oa_4x1 ;

  function gate_oa_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
	      ( 0 to in0a'length-1 => gate1 ) ;
    return result ;
  end gate_oa_4x1 ;

  function oa_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a ) ;
    return result ;
  end oa_4x1 ;

  function oa_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a ) ;
    return result ;
  end oa_4x1 ;

  function gate_oai_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic
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
    result := not( ( gate0 or in0a or in0b or in0c ) and
		   ( gate1 ) ) ;
    return result ;
  end gate_oai_4x1 ;

  function gate_oai_4x1
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
		   ( 0 to in0a'length-1 => gate1 ) ) ;
    return result ;
  end gate_oai_4x1 ;

  function oai_4x1
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a ) ) ;
    return result ;
  end oai_4x1 ;

  function oai_4x1
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a ) ) ;
    return result ;
  end oai_4x1 ;

  function gate_ao_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( gate0 and in0a and in0b and in0c ) or
	      ( gate1 and in1a ) ;
    return result ;
  end gate_ao_4x2 ;

  function gate_ao_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
	      ( ( 0 to in1a'length-1 => gate1 ) and in1a ) ;
    return result ;
  end gate_ao_4x2 ;

  function ao_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a and in1b ) ;
    return result ;
  end ao_4x2 ;

  function ao_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a and in1b ) ;
    return result ;
  end ao_4x2 ;

  function gate_aoi_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( gate0 and in0a and in0b and in0c ) or
		   ( gate1 and in1a ) ) ;
    return result ;
  end gate_aoi_4x2 ;

  function gate_aoi_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
		   ( ( 0 to in1a'length-1 => gate1 ) and in1a ) ) ;
    return result ;
  end gate_aoi_4x2 ;

  function aoi_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a and in1b ) ) ;
    return result ;
  end aoi_4x2 ;

  function aoi_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a and in1b ) ) ;
    return result ;
  end aoi_4x2 ;

  function gate_oa_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := ( gate0 or in0a or in0b or in0c ) and
	      ( gate1 or in1a ) ;
    return result ;
  end gate_oa_4x2 ;

  function gate_oa_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
	      ( ( 0 to in1a'length-1 => gate1 ) or in1a ) ;
    return result ;
  end gate_oa_4x2 ;

  function oa_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a or in1b ) ;
    return result ;
  end oa_4x2 ;

  function oa_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a or in1b ) ;
    return result ;
  end oa_4x2 ;

  function gate_oai_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic
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
    result := not( ( gate0 or in0a or in0b or in0c ) and
		   ( gate1 or in1a ) );
    return result ;
  end gate_oai_4x2 ;

  function gate_oai_4x2
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
		   ( ( 0 to in1a'length-1 => gate1 ) or in1a ) );
    return result ;
  end gate_oai_4x2 ;

  function oai_4x2
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a or in1b ) ) ;
    return result ;
  end oai_4x2 ;

  function oai_4x2
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a or in1b ) ) ;
    return result ;
  end oai_4x2 ;

  function gate_ao_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( gate0 and in0a and in0b and in0c ) or
	      ( gate1 and in1a and in1b ) ;
    return result ;
  end gate_ao_4x3 ;

  function gate_ao_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
	      ( ( 0 to in1a'length-1 => gate1 ) and in1a and in1b ) ;
    return result ;
  end gate_ao_4x3 ;

  function ao_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a and in1b and in1c ) ;
    return result ;
  end ao_4x3 ;

  function ao_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a and in1b and in1c ) ;
    return result ;
  end ao_4x3 ;

  function gate_aoi_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( gate0 and in0a and in0b and in0c ) or
		   ( gate1 and in1a and in1b ) ) ;
    return result ;
  end gate_aoi_4x3 ;

  function gate_aoi_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
		   ( ( 0 to in1a'length-1 => gate1 ) and in1a and in1b ) ) ;
    return result ;
  end gate_aoi_4x3 ;

  function aoi_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a and in1b and in1c ) ) ;
    return result ;
  end aoi_4x3 ;

  function aoi_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a and in1b and in1c ) ) ;
    return result ;
  end aoi_4x3 ;

  function gate_oa_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := ( gate0 or in0a or in0b or in0c ) and
	      ( gate1 or in1a or in1b ) ;
    return result ;
  end gate_oa_4x3 ;

  function gate_oa_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
	      ( ( 0 to in1a'length-1 => gate1 ) or in1a or in1b ) ;
    return result ;
  end gate_oa_4x3 ;

  function oa_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a or in1b or in1c ) ;
    return result ;
  end oa_4x3 ;

  function oa_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a or in1b or in1c ) ;
    return result ;
  end oa_4x3 ;

  function gate_oai_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic
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
    result := not( ( gate0 or in0a or in0b or in0c ) and
		   ( gate1 or in1a or in1b ) ) ;
    return result ;
  end gate_oai_4x3 ;

  function gate_oai_4x3
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
		   ( ( 0 to in1a'length-1 => gate1 ) or in1a or in1b ) ) ;
    return result ;
  end gate_oai_4x3 ;

  function oai_4x3
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a or in1b or in1c ) ) ;
    return result ;
  end oai_4x3 ;

  function oai_4x3
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a or in1b or in1c ) ) ;
    return result ;
  end oai_4x3 ;

  function gate_ao_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := ( gate0 and in0a and in0b and in0c ) or
	      ( gate1 and in1a and in1b and in1c ) ;
    return result ;
  end gate_ao_4x4 ;

  function gate_ao_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
	      ( ( 0 to in1a'length-1 => gate1 ) and in1a and in1b and in1c ) ;
    return result ;
  end gate_ao_4x4 ;

  function ao_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
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
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a and in1b and in1c and in1d ) ;
    return result ;
  end ao_4x4 ;

  function ao_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a and in0b and in0c and in0d ) or
	      ( in1a and in1b and in1c and in1d ) ;
    return result ;
  end ao_4x4 ;

  function gate_aoi_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := not( ( gate0 and in0a and in0b and in0c ) or
		   ( gate1 and in1a and in1b and in1c ) ) ;
    return result ;
  end gate_aoi_4x4 ;

  function gate_aoi_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) and in0a and in0b and in0c ) or
		   ( ( 0 to in1a'length-1 => gate1 ) and in1a and in1b and in1c ) ) ;
    return result ;
  end gate_aoi_4x4 ;

  function aoi_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
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
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a and in1b and in1c and in1d ) ) ;
    return result ;
  end aoi_4x4 ;

  function aoi_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a and in0b and in0c and in0d ) or
		   ( in1a and in1b and in1c and in1d ) ) ;
    return result ;
  end aoi_4x4 ;

  function gate_oa_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := ( gate0 or in0a or in0b or in0c ) and
	      ( gate1 or in1a or in1b or in1c ) ;
    return result ;
  end gate_oa_4x4 ;

  function gate_oa_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
	      ( ( 0 to in1a'length-1 => gate1 ) or in1a or in1b or in1c ) ;
    return result ;
  end gate_oa_4x4 ;

  function oa_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
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
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a or in1b or in1c or in1d ) ;
    return result ;
  end oa_4x4 ;

  function oa_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := ( in0a or in0b or in0c or in0d ) and
	      ( in1a or in1b or in1c or in1d ) ;
    return result ;
  end oa_4x4 ;

  function gate_oai_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic
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
    result := not( ( gate0 or in0a or in0b or in0c ) and
		   ( gate1 or in1a or in1b or in1c ) ) ;
    return result ;
  end gate_oai_4x4 ;

  function gate_oai_4x4
    (gate0 : std_ulogic ;
     in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     gate1 : std_ulogic ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( ( 0 to in0a'length-1 => gate0 ) or in0a or in0b or in0c ) and
		   ( ( 0 to in1a'length-1 => gate1 ) or in1a or in1b or in1c ) ) ;
    return result ;
  end gate_oai_4x4 ;

  function oai_4x4
    (in0a  : std_ulogic ;
     in0b  : std_ulogic ;
     in0c  : std_ulogic ;
     in0d  : std_ulogic ;
     in1a  : std_ulogic ;
     in1b  : std_ulogic ;
     in1c  : std_ulogic ;
     in1d  : std_ulogic
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
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a or in1b or in1c or in1d ) ) ;
    return result ;
  end oai_4x4 ;

  function oai_4x4
    (in0a  : std_ulogic_vector ;
     in0b  : std_ulogic_vector ;
     in0c  : std_ulogic_vector ;
     in0d  : std_ulogic_vector ;
     in1a  : std_ulogic_vector ;
     in1b  : std_ulogic_vector ;
     in1c  : std_ulogic_vector ;
     in1d  : std_ulogic_vector
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
    variable result     : std_ulogic_vector (0 to in0a'length-1);
  begin
    result := not( ( in0a or in0b or in0c or in0d ) and
		   ( in1a or in1b or in1c or in1d ) ) ;
    return result ;
  end oai_4x4 ;

end std_ulogic_ao_support;

