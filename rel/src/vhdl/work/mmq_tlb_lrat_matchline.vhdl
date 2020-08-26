-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--********************************************************************
--*
--* TITLE: MMU TLB LRAT Match Line Logic for Functional Model
--*
--* NAME: mmq_tlb_lrat_matchline
--*

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL ;
LIBRARY IBM;
USE ibm.std_ulogic_support.ALL;
USE ibm.std_ulogic_function_support.ALL;
library support;
use support.power_logic_pkg.all;

------------------------------------------------------------------------
-- Entity
------------------------------------------------------------------------

entity mmq_tlb_lrat_matchline is
  generic (real_addr_width      : integer := 42;
             lpid_width           : integer := 8;
             lrat_maxsize_log2    : integer := 40;  -- 1T largest pgsize
             lrat_minsize_log2    : integer := 20;  -- 1M smallest pgsize
             have_xbit            : integer := 1;
             num_pgsizes          : integer := 8;
             have_cmpmask         : integer := 1;
             cmpmask_width        : integer := 7); 

port( -- @{default:nclk}@
    vdd                              : inout power_logic;
    gnd                              : inout power_logic;
    addr_in                          : in std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
    addr_enable                      : in std_ulogic;
    entry_size                       : in std_ulogic_vector(0 to 3);
    entry_cmpmask                    : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_xbit                       : in std_ulogic;
    entry_xbitmask                   : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_lpn                        : in std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2-1);
    entry_lpid                       : in std_ulogic_vector(0 to lpid_width-1);
    comp_lpid                        : in std_ulogic_vector(0 to lpid_width-1);
    lpid_enable                      : in std_ulogic;
    entry_v                          : in std_ulogic;

    match                            : out std_ulogic;

    dbg_addr_match       : out  std_ulogic;
    dbg_lpid_match       : out  std_ulogic
    
);

  -- synopsys translate_off
  -- synopsys translate_on

end mmq_tlb_lrat_matchline;

architecture mmq_tlb_lrat_matchline of mmq_tlb_lrat_matchline is

------------------------------------------------------------------------
-- Signals
------------------------------------------------------------------------

  signal entry_lpn_b             : std_ulogic_vector(64-lrat_maxsize_log2 to 64-lrat_minsize_log2-1);
  signal function_24_43     : std_ulogic;
  signal function_26_43     : std_ulogic;
  signal function_30_43     : std_ulogic;
  signal function_32_43     : std_ulogic;
  signal function_34_43     : std_ulogic;
  signal function_36_43     : std_ulogic;
  signal function_40_43     : std_ulogic;
  signal pgsize_eq_16M  : std_ulogic;  -- PS7
  signal pgsize_eq_256M : std_ulogic;  -- PS9
  signal pgsize_eq_1G   : std_ulogic; -- PS10
  signal pgsize_eq_4G   : std_ulogic; -- PS11
  signal pgsize_eq_16G  : std_ulogic; -- PS12
  signal pgsize_eq_256G : std_ulogic; -- PS14
  signal pgsize_eq_1T   : std_ulogic; -- PS15
  signal pgsize_gte_16M  : std_ulogic;  -- PS7
  signal pgsize_gte_256M : std_ulogic;  -- PS9
  signal pgsize_gte_1G   : std_ulogic; -- PS10
  signal pgsize_gte_4G   : std_ulogic; -- PS11
  signal pgsize_gte_16G  : std_ulogic; -- PS12
  signal pgsize_gte_256G : std_ulogic; -- PS14
  signal pgsize_gte_1T   : std_ulogic; -- PS15
  
  signal comp_or_24_25      : std_ulogic;
  signal comp_or_26_29      : std_ulogic;
  signal comp_or_30_31      : std_ulogic;
  signal comp_or_32_33      : std_ulogic;
  signal comp_or_34_35      : std_ulogic;
  signal comp_or_36_39      : std_ulogic;
  signal comp_or_40_43      : std_ulogic;
  
  signal match_line         : std_ulogic_vector(64-real_addr_width to 64-lrat_minsize_log2+lpid_width-1);
  signal addr_match         : std_ulogic;
  signal lpid_match         : std_ulogic;

signal unused_dc  :  std_ulogic;  
-- synopsys translate_off
-- synopsys translate_on

begin

  match_line(64-real_addr_width to 64-lrat_minsize_log2+lpid_width-1) <= not(
      (entry_lpn(64-real_addr_width to 64-lrat_minsize_log2-1) & entry_lpid(0 to lpid_width-1)) xor
        (addr_in(64-real_addr_width to 64-lrat_minsize_log2-1) & comp_lpid(0 to lpid_width-1))
                               );

numpgsz8 : if num_pgsizes = 8 generate

  entry_lpn_b(64-lrat_maxsize_log2 to 64-lrat_minsize_log2-1) <= not(entry_lpn(64-lrat_maxsize_log2 to 64-lrat_minsize_log2-1));


gen_nocmpmask80 : if have_cmpmask = 0 generate
  pgsize_eq_16M  <= '1' when (entry_size="0111")  -- PS7
                   else '0'; 
  pgsize_eq_256M <= '1' when (entry_size="1001")  -- PS9
                   else '0'; 
  pgsize_eq_1G   <= '1' when (entry_size="1010")  -- PS10
                   else '0'; 
  pgsize_eq_4G   <= '1' when (entry_size="1011")  -- PS11
                   else '0'; 
  pgsize_eq_16G  <= '1' when (entry_size="1100")  -- PS12
                   else '0'; 
  pgsize_eq_256G <= '1' when (entry_size="1110")  -- PS14
                   else '0'; 
  pgsize_eq_1T   <= '1' when (entry_size="1111")  -- PS15
                   else '0'; 

  pgsize_gte_16M  <= '1' when (entry_size="0111"  or  -- PS7 or larger
                              pgsize_gte_256M='1')
                   else '0'; 
  pgsize_gte_256M <= '1' when (entry_size="1001"  or  -- PS9 or larger
                              pgsize_gte_1G='1')
                   else '0'; 
  pgsize_gte_1G   <= '1' when (entry_size="1010"  or  -- PS10 or larger
                              pgsize_gte_4G='1')
                   else '0'; 
  pgsize_gte_4G   <= '1' when (entry_size="1011"  or  -- PS11 or larger
                              pgsize_gte_16G='1')
                   else '0'; 
  pgsize_gte_16G  <= '1' when (entry_size="1100"  or  -- PS12 or larger
                              pgsize_gte_256G='1')
                   else '0'; 
  pgsize_gte_256G <= '1' when (entry_size="1110"  or  -- PS14 or larger
                              pgsize_gte_1T='1')
                   else '0'; 
  pgsize_gte_1T   <= '1' when (entry_size="1111")  -- PS15
                   else '0'; 
                   
end generate gen_nocmpmask80;

gen_cmpmask80 : if have_cmpmask = 1 generate
--  size           entry_cmpmask: 0123456
--    1TB                         1111111
--  256GB                         0111111
--   16GB                         0011111
--    4GB                         0001111
--    1GB                         0000111
--  256MB                         0000011
--   16MB                         0000001
--    1MB                         0000000
  pgsize_gte_1T   <= entry_cmpmask(0);
  pgsize_gte_256G <= entry_cmpmask(1);
  pgsize_gte_16G  <= entry_cmpmask(2);
  pgsize_gte_4G   <= entry_cmpmask(3);
  pgsize_gte_1G   <= entry_cmpmask(4);
  pgsize_gte_256M <= entry_cmpmask(5);
  pgsize_gte_16M  <= entry_cmpmask(6);

--  size          entry_xbitmask: 0123456
--    1TB                         1000000
--  256GB                         0100000
--   16GB                         0010000
--    4GB                         0001000
--    1GB                         0000100
--  256MB                         0000010
--   16MB                         0000001
--    1MB                         0000000
  pgsize_eq_1T   <= entry_xbitmask(0);
  pgsize_eq_256G <= entry_xbitmask(1);
  pgsize_eq_16G  <= entry_xbitmask(2);
  pgsize_eq_4G   <= entry_xbitmask(3);
  pgsize_eq_1G   <= entry_xbitmask(4);
  pgsize_eq_256M <= entry_xbitmask(5);
  pgsize_eq_16M  <= entry_xbitmask(6);
end generate gen_cmpmask80;



gen_noxbit80 : if have_xbit = 0 generate
  function_24_43 <= '0';
  function_26_43 <= '0';
  function_30_43 <= '0';
  function_32_43 <= '0';
  function_34_43 <= '0';
  function_36_43 <= '0';
  function_40_43 <= '0';
end generate gen_noxbit80;
 
gen_xbit80 : if (have_xbit /= 0 and real_addr_width=42) generate
  function_24_43 <= not(entry_xbit) or
                    not(pgsize_eq_1T) or
                    or_reduce(entry_lpn_b(24 to 43) and addr_in(24 to 43));
  function_26_43 <= not(entry_xbit) or
                    not(pgsize_eq_256G) or
                    or_reduce(entry_lpn_b(26 to 43) and addr_in(26 to 43));
  function_30_43 <= not(entry_xbit) or
                    not(pgsize_eq_16G) or
                    or_reduce(entry_lpn_b(30 to 43) and addr_in(30 to 43));
  function_32_43 <= not(entry_xbit) or
                    not(pgsize_eq_4G) or
                    or_reduce(entry_lpn_b(32 to 43) and addr_in(32 to 43));
  function_34_43 <= not(entry_xbit) or
                    not(pgsize_eq_1G) or
                    or_reduce(entry_lpn_b(34 to 43) and addr_in(34 to 43));
  function_36_43 <= not(entry_xbit) or
                    not(pgsize_eq_256M) or
                    or_reduce(entry_lpn_b(36 to 43) and addr_in(36 to 43));
  function_40_43 <= not(entry_xbit) or
                    not(pgsize_eq_16M) or
                    or_reduce(entry_lpn_b(40 to 43) and addr_in(40 to 43));
end generate gen_xbit80; 
                    
gen_xbit81 : if (have_xbit /= 0 and real_addr_width=32) generate
  function_24_43 <= '1';
  function_26_43 <= '1';
  function_30_43 <= '1';
  function_32_43 <= '1';
  function_34_43 <= not(entry_xbit) or
                    not(pgsize_eq_1G) or
                    or_reduce(entry_lpn_b(34 to 43) and addr_in(34 to 43));
  function_36_43 <= not(entry_xbit) or
                    not(pgsize_eq_256M) or
                    or_reduce(entry_lpn_b(36 to 43) and addr_in(36 to 43));
  function_40_43 <= not(entry_xbit) or
                    not(pgsize_eq_16M) or
                    or_reduce(entry_lpn_b(40 to 43) and addr_in(40 to 43));
end generate gen_xbit81; 
                    
gen_comp80 : if real_addr_width=42 generate
  comp_or_24_25 <=  and_reduce(match_line(24 to 25)) or pgsize_gte_1T;
  comp_or_26_29 <=  and_reduce(match_line(26 to 29)) or pgsize_gte_256G;
  comp_or_30_31 <=  and_reduce(match_line(30 to 31)) or pgsize_gte_16G;
  comp_or_32_33 <=  and_reduce(match_line(32 to 33)) or pgsize_gte_4G;
  comp_or_34_35 <=  and_reduce(match_line(34 to 35)) or pgsize_gte_1G;
  comp_or_36_39 <=  and_reduce(match_line(36 to 39)) or pgsize_gte_256M;
  comp_or_40_43 <=  and_reduce(match_line(40 to 43)) or pgsize_gte_16M;
end generate gen_comp80; 

gen_comp81 : if real_addr_width=32 generate
  comp_or_24_25 <=  '1';
  comp_or_26_29 <=  '1';
  comp_or_30_31 <=  '1';
  comp_or_32_33 <=  '1';
  comp_or_34_35 <=  and_reduce(match_line(34 to 35)) or pgsize_gte_1G;
  comp_or_36_39 <=  and_reduce(match_line(36 to 39)) or pgsize_gte_256M;
  comp_or_40_43 <=  and_reduce(match_line(40 to 43)) or pgsize_gte_16M;
end generate gen_comp81; 

gen_noxbit81 : if (have_xbit = 0 and real_addr_width=42) generate
  addr_match <=    ( and_reduce(match_line(22 to 23)) and 
                    comp_or_24_25  and               --  Ignore functions based on page size
                    comp_or_26_29  and
                    comp_or_30_31  and
                    comp_or_32_33  and
                    comp_or_34_35  and
                    comp_or_36_39  and
                    comp_or_40_43 ) or  --  Regular compare largest page size
                    not(addr_enable);   --  Include address as part of compare,
                                          --  should never ignore for regular compare/read.
                                           -- Could ignore for compare/invalidate
end generate gen_noxbit81;
 
gen_noxbit82 : if (have_xbit = 0 and real_addr_width=32) generate
  addr_match <=    ( and_reduce(match_line(32 to 33)) and 
                    comp_or_34_35  and --  Ignore functions based on page size
                    comp_or_36_39  and
                    comp_or_40_43 ) or  --  Regular compare largest page size
                    not(addr_enable);   --  Include address as part of compare,
                                          --  should never ignore for regular compare/read.
                                           -- Could ignore for compare/invalidate
end generate gen_noxbit82;
 
gen_xbit82 : if (have_xbit /= 0 and real_addr_width=42) generate
  addr_match <=  (and_reduce(match_line(22 to 23)) and 
                    comp_or_24_25  and               --  Ignore functions based on page size
                    comp_or_26_29  and
                    comp_or_30_31  and
                    comp_or_32_33  and
                    comp_or_34_35  and
                    comp_or_36_39  and
                    comp_or_40_43  and
                    function_24_43 and               --  Exclusion functions
                    function_26_43 and
                    function_30_43 and
                    function_32_43 and
                    function_34_43 and
                    function_36_43 and
                    function_40_43) or  --  Regular compare largest page size
                    not(addr_enable);  --  Include address as part of compare,
                                         --  should never ignore for regular compare/read.
                                         -- Could ignore for compare/invalidate
end generate gen_xbit82; 

gen_xbit83 : if (have_xbit /= 0 and real_addr_width=32) generate
  addr_match <=  (and_reduce(match_line(32 to 33)) and 
                    comp_or_34_35  and          --  Ignore functions based on page size
                    comp_or_36_39  and
                    comp_or_40_43  and
                    function_34_43 and          --  Exclusion functions
                    function_36_43 and
                    function_40_43) or  --  Regular compare largest page size
                    not(addr_enable);  --  Include address as part of compare,
                                         --  should never ignore for regular compare/read.
                                         -- Could ignore for compare/invalidate
end generate gen_xbit83; 

end generate numpgsz8; -- numpgsz8: num_pgsizes = 8


  -- entry_lpid=0 ignores lpid match for translation, not invalidation
  lpid_match <=     and_reduce(match_line(64-lrat_minsize_log2 to 64-lrat_minsize_log2+lpid_width-1)) or
                    not(or_reduce(entry_lpid(0 to 7))) or  
                    not(lpid_enable);              

  match <=          addr_match and                       --  Address compare
                    lpid_match and                       --  LPID compare
                    entry_v;                             --  Valid

    -- debug outputs
    dbg_addr_match       <= addr_match;  -- out  std_ulogic;
    dbg_lpid_match       <= lpid_match;  -- out  std_ulogic;

gen_unused0 : if have_cmpmask = 0 generate
  unused_dc <= '0';
end generate gen_unused0;
gen_unused1 : if have_cmpmask = 1 generate
  unused_dc <= or_reduce(entry_size);
end generate gen_unused1;

end mmq_tlb_lrat_matchline;
