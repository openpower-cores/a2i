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
--* TITLE: MMU TLB Match Line Logic for Functional Model
--*
--* NAME: mmq_tlb_matchline
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

entity mmq_tlb_matchline is
  generic (have_xbit : integer := 1;
             num_pgsizes : integer := 5;
             have_cmpmask : integer := 1;
             cmpmask_width : integer := 5); 

port( -- @{default:nclk}@
    vdd                              : inout power_logic;
    gnd                              : inout power_logic;
    addr_in                          : in std_ulogic_vector(0 to 51);
    addr_enable                      : in std_ulogic_vector(0 to 8);
    comp_pgsize                      : in std_ulogic_vector(0 to 3);
    pgsize_enable                    : in std_ulogic;
    entry_size                       : in std_ulogic_vector(0 to 3);
    entry_cmpmask                    : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_xbit                       : in std_ulogic;
    entry_xbitmask                   : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_epn                        : in std_ulogic_vector(0 to 51);
    comp_class                       : in std_ulogic_vector(0 to 1);
    entry_class                      : in std_ulogic_vector(0 to 1);
    class_enable                     : in std_ulogic;
    comp_extclass                    : in std_ulogic_vector(0 to 1);
    entry_extclass                   : in std_ulogic_vector(0 to 1);
    extclass_enable                  : in std_ulogic_vector(0 to 1);
    comp_state                       : in std_ulogic_vector(0 to 1);
    entry_gs                         : in std_ulogic;
    entry_ts                         : in std_ulogic;
    state_enable                     : in std_ulogic_vector(0 to 1);
    entry_thdid                      : in std_ulogic_vector(0 to 3);
    comp_thdid                       : in std_ulogic_vector(0 to 3);
    thdid_enable                     : in std_ulogic;
    entry_pid                        : in std_ulogic_vector(0 to 13);
    comp_pid                         : in std_ulogic_vector(0 to 13);
    pid_enable                       : in std_ulogic;
    entry_lpid                       : in std_ulogic_vector(0 to 7);
    comp_lpid                        : in std_ulogic_vector(0 to 7);
    lpid_enable                      : in std_ulogic;
    entry_ind                        : in std_ulogic;
    comp_ind                         : in std_ulogic;
    ind_enable                       : in std_ulogic;
    entry_iprot                      : in std_ulogic;
    comp_iprot                       : in std_ulogic;
    iprot_enable                     : in std_ulogic;
    entry_v                          : in std_ulogic;
    comp_invalidate                  : in std_ulogic;

    match                            : out std_ulogic;

    dbg_addr_match       : out  std_ulogic;
    dbg_pgsize_match     : out  std_ulogic;
    dbg_class_match      : out  std_ulogic;
    dbg_extclass_match   : out  std_ulogic;
    dbg_state_match      : out  std_ulogic;
    dbg_thdid_match      : out  std_ulogic;
    dbg_pid_match        : out  std_ulogic;
    dbg_lpid_match       : out  std_ulogic;
    dbg_ind_match        : out  std_ulogic;
    dbg_iprot_match      : out  std_ulogic

);

  -- synopsys translate_off
  -- synopsys translate_on

end mmq_tlb_matchline;

architecture mmq_tlb_matchline of mmq_tlb_matchline is

------------------------------------------------------------------------
-- Signals
------------------------------------------------------------------------

  signal entry_epn_b             : std_ulogic_vector(30 to 51);
  signal function_50_51     : std_ulogic;
  signal function_48_51     : std_ulogic;
  signal function_46_51     : std_ulogic;
  signal function_44_51     : std_ulogic;
  signal function_40_51     : std_ulogic;
  signal function_36_51     : std_ulogic;
  signal function_34_51     : std_ulogic;
  signal pgsize_gte_16K  : std_ulogic;
  signal pgsize_gte_64K  : std_ulogic;
  signal pgsize_gte_256K : std_ulogic;
  signal pgsize_gte_1M   : std_ulogic;
  signal pgsize_gte_16M  : std_ulogic;
  signal pgsize_gte_256M : std_ulogic;
  signal pgsize_gte_1G   : std_ulogic;
  signal pgsize_eq_16K  : std_ulogic;
  signal pgsize_eq_64K  : std_ulogic;
  signal pgsize_eq_256K : std_ulogic;
  signal pgsize_eq_1M   : std_ulogic;
  signal pgsize_eq_16M  : std_ulogic;
  signal pgsize_eq_256M : std_ulogic;
  signal pgsize_eq_1G   : std_ulogic;
  signal comp_or_34_35      : std_ulogic;
  signal comp_or_36_39      : std_ulogic;
  signal comp_or_40_43      : std_ulogic;
  signal comp_or_44_45      : std_ulogic;
  signal comp_or_44_47      : std_ulogic;
  signal comp_or_46_47      : std_ulogic;
  signal comp_or_48_49      : std_ulogic;
  signal comp_or_48_51      : std_ulogic;
  signal comp_or_50_51      : std_ulogic;
  signal match_line         : std_ulogic_vector(0 to 85);
  signal pgsize_match       : std_ulogic;
  signal addr_match         : std_ulogic;
  signal class_match        : std_ulogic;
  signal extclass_match     : std_ulogic;
  signal state_match        : std_ulogic;
  signal thdid_match        : std_ulogic;
  signal pid_match          : std_ulogic;
  signal lpid_match         : std_ulogic;
  signal ind_match          : std_ulogic;
  signal iprot_match        : std_ulogic;
  signal addr_match_xbit_contrib        : std_ulogic;
  signal addr_match_lsb_contrib         : std_ulogic;
  signal addr_match_msb_contrib         : std_ulogic;

  signal unused_dc          : std_ulogic_vector(0 to 4);
-- synopsys translate_off
-- synopsys translate_on

begin

  match_line(0 to 85) <= not(
      (entry_epn(0 to 51) & entry_size(0 to 3) & entry_class(0 to 1) & entry_extclass(0 to 1) & entry_gs & entry_ts & entry_pid(0 to 13) & entry_lpid(0 to 7) & entry_ind & entry_iprot) xor
        (addr_in(0 to 51) & comp_pgsize(0 to 3) & comp_class(0 to 1) & comp_extclass(0 to 1) & comp_state(0 to 1) & comp_pid(0 to 13) & comp_lpid(0 to 7) & comp_ind & comp_iprot)
                               );

numpgsz8 : if num_pgsizes = 8 generate

  entry_epn_b(30 to 51) <= not(entry_epn(30 to 51));

  unused_dc <= (others => '0'); 

gen_nocmpmask80 : if have_cmpmask = 0 generate
  pgsize_gte_1G   <= (    entry_size(0)  and not(entry_size(1))  and      entry_size(2) and not(entry_size(3)) );
  pgsize_gte_256M <= (    entry_size(0)  and not(entry_size(1))  and not(entry_size(2)) and   entry_size(3) ) or
                      pgsize_gte_1G;
  pgsize_gte_16M  <= (not(entry_size(0))  and     entry_size(1) and      entry_size(2)  and     entry_size(3) ) or
                      pgsize_gte_256M;
  pgsize_gte_1M   <= (not(entry_size(0))  and     entry_size(1) and not(entry_size(2)) and     entry_size(3) ) or
                      pgsize_gte_16M;
  pgsize_gte_256K <= (not(entry_size(0)) and      entry_size(1) and not(entry_size(2)) and not(entry_size(3)) ) or
                      pgsize_gte_1M;
  pgsize_gte_64K  <= (not(entry_size(0)) and not(entry_size(1)) and     entry_size(2) and      entry_size(3) ) or
                      pgsize_gte_256K;
  pgsize_gte_16K  <= (not(entry_size(0)) and not(entry_size(1)) and     entry_size(2) and not(entry_size(3)) ) or
                      pgsize_gte_64K;
end generate gen_nocmpmask80;

gen_cmpmask80 : if have_cmpmask = 1 generate
--  size           entry_cmpmask: 0123456
--    1GB                         1111111
--  256MB                         0111111
--   16MB                         0011111
--    1MB                         0001111
--  256KB                         0000111
--   64KB                         0000011
--   16KB                         0000001
--    4KB                         0000000
  pgsize_gte_1G   <= entry_cmpmask(0);
  pgsize_gte_256M <= entry_cmpmask(1);
  pgsize_gte_16M  <= entry_cmpmask(2);
  pgsize_gte_1M   <= entry_cmpmask(3);
  pgsize_gte_256K <= entry_cmpmask(4);
  pgsize_gte_64K  <= entry_cmpmask(5);
  pgsize_gte_16K  <= entry_cmpmask(6);

--  size          entry_xbitmask: 0123456
--    1GB                         1000000
--  256MB                         0100000
--   16MB                         0010000
--    1MB                         0001000
--  256KB                         0000100
--   64KB                         0000010
--   16KB                         0000001
--    4KB                         0000000
  pgsize_eq_1G   <= entry_xbitmask(0);
  pgsize_eq_256M <= entry_xbitmask(1);
  pgsize_eq_16M  <= entry_xbitmask(2);
  pgsize_eq_1M   <= entry_xbitmask(3);
  pgsize_eq_256K <= entry_xbitmask(4);
  pgsize_eq_64K  <= entry_xbitmask(5);
  pgsize_eq_16K  <= entry_xbitmask(6);
end generate gen_cmpmask80;

gen_noxbit80 : if have_xbit = 0 generate
  function_34_51 <= '0';
  function_36_51 <= '0';
  function_40_51 <= '0';
  function_44_51 <= '0';
  function_46_51 <= '0';
  function_48_51 <= '0';
  function_50_51 <= '0';
end generate gen_noxbit80;
 
gen_xbit80 : if have_xbit /= 0 generate

  -- 1G
  function_34_51 <= not(entry_xbit) or
                    not(pgsize_eq_1G) or
                    or_reduce(entry_epn_b(34 to 51) and addr_in(34 to 51));
  function_36_51 <= not(entry_xbit) or
                    not(pgsize_eq_256M) or
                    or_reduce(entry_epn_b(36 to 51) and addr_in(36 to 51));
  function_40_51 <= not(entry_xbit) or
                    not(pgsize_eq_16M) or
                    or_reduce(entry_epn_b(40 to 51) and addr_in(40 to 51));
  function_44_51 <= not(entry_xbit) or
                    not(pgsize_eq_1M) or
                    or_reduce(entry_epn_b(44 to 51) and addr_in(44 to 51));
  function_46_51 <= not(entry_xbit) or
                    not(pgsize_eq_256K) or
                    or_reduce(entry_epn_b(46 to 51) and addr_in(46 to 51));
  function_48_51 <= not(entry_xbit) or
                    not(pgsize_eq_64K) or
                    or_reduce(entry_epn_b(48 to 51) and addr_in(48 to 51));
  function_50_51 <= not(entry_xbit) or
                    not(pgsize_eq_16K) or
                    or_reduce(entry_epn_b(50 to 51) and addr_in(50 to 51));
end generate gen_xbit80; 
                    

  comp_or_50_51 <=  and_reduce(match_line(50 to 51)) or pgsize_gte_16K;
  comp_or_48_49 <=  and_reduce(match_line(48 to 49)) or pgsize_gte_64K;
  comp_or_46_47 <=  and_reduce(match_line(46 to 47)) or pgsize_gte_256K;
  comp_or_44_45 <=  and_reduce(match_line(44 to 45)) or pgsize_gte_1M;
  comp_or_40_43 <=  and_reduce(match_line(40 to 43)) or pgsize_gte_16M;
  comp_or_36_39 <=  and_reduce(match_line(36 to 39)) or pgsize_gte_256M;
  comp_or_34_35 <=  and_reduce(match_line(34 to 35)) or pgsize_gte_1G; 

gen_noxbit81 : if have_xbit = 0 generate
  addr_match <=  ( comp_or_34_35  and               --  Ignore functions based on page size
                    comp_or_36_39  and
                    comp_or_40_43  and
                    comp_or_44_45  and
                    comp_or_46_47  and
                    comp_or_48_49  and
                    (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) 
                  ) or  --  Regular compare largest page size
                    not(addr_enable(8));                    --  Include address as part of compare,
                                                           --  should never ignore for regular compare/read.
                                                           -- Could ignore for compare/invalidate
  addr_match_xbit_contrib <=  '0';
                    
  addr_match_lsb_contrib <=  ( comp_or_34_35  and               --  Ignore functions based on page size
                                comp_or_36_39  and               
                                comp_or_40_43  and
                                comp_or_44_45  and
                                comp_or_46_47  and
                                comp_or_48_49  and
                                comp_or_50_51);
                                
  addr_match_msb_contrib <=  (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) ;

end generate gen_noxbit81;
 
gen_xbit81 : if have_xbit /= 0 generate
  addr_match <=  ( function_50_51 and               --  Exclusion functions
                    function_48_51 and
                    function_46_51 and
                    function_44_51 and
                    function_40_51 and
                    function_36_51 and
                    function_34_51 and
                    comp_or_34_35  and               --  Ignore functions based on page size
                    comp_or_36_39  and
                    comp_or_40_43  and
                    comp_or_44_45  and
                    comp_or_46_47  and
                    comp_or_48_49  and
                    comp_or_50_51  and
                    (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) 
                  ) or  --  Regular compare largest page size
                    not(addr_enable(8));                    --  Include address as part of compare,
                                                           --  should never ignore for regular compare/read.
                                                           -- Could ignore for compare/invalidate

  addr_match_xbit_contrib <=  ( function_50_51 and               --  Exclusion functions
                    function_48_51 and
                    function_46_51 and
                    function_44_51 and
                    function_40_51 and
                    function_36_51 and
                    function_34_51 );
                    
  addr_match_lsb_contrib <=  ( comp_or_34_35  and               --  Ignore functions based on page size
                                comp_or_36_39  and               
                                comp_or_40_43  and
                                comp_or_44_45  and
                                comp_or_46_47  and
                                comp_or_48_49  and
                                comp_or_50_51);
                                
  addr_match_msb_contrib <=  (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) ;

end generate gen_xbit81; 

end generate numpgsz8; -- numpgsz8: num_pgsizes = 8


numpgsz5 : if num_pgsizes = 5 generate

  -- tie off unused signals
  function_50_51 <= '0';
  function_46_51 <= '0';
  pgsize_gte_16K <= '0';
  pgsize_gte_256K <= '0';
  pgsize_eq_16K <= '0';
  pgsize_eq_256K <= '0';
  comp_or_44_45 <= '0';
  comp_or_46_47 <= '0';
  comp_or_48_49 <= '0';
  comp_or_50_51 <= '0';
  
  entry_epn_b(30 to 51) <= not(entry_epn(30 to 51));

unused_dc(0) <= (pgsize_gte_16K and pgsize_gte_256K and pgsize_eq_16K and pgsize_eq_256K);
unused_dc(1) <=  (function_50_51 and function_46_51);
unused_dc(2) <=  (comp_or_44_45 and comp_or_46_47 and comp_or_48_49 and comp_or_50_51);
unused_dc(3) <=  or_reduce(entry_epn_b(30 to 33));
unused_dc(4) <= addr_match_xbit_contrib and addr_match_lsb_contrib and addr_match_msb_contrib;

gen_nocmpmask50 : if have_cmpmask = 0 generate
  -- 1010
  pgsize_gte_1G  <= (  entry_size(0)  and not(entry_size(1))  and   entry_size(2) and not(entry_size(3)) );

  -- 1001, large indirect entry size
  pgsize_gte_256M <= (    entry_size(0)  and not(entry_size(1))  and not(entry_size(2)) and   entry_size(3) ) or
                      pgsize_gte_1G;
  -- 0111
  pgsize_gte_16M  <= (not(entry_size(0))  and    entry_size(1)  and    entry_size(2) and  entry_size(3)) or
                      pgsize_gte_256M;
  -- 0101
  pgsize_gte_1M   <= (not(entry_size(0))  and entry_size(1) and not(entry_size(2)) and  entry_size(3)) or
                      pgsize_gte_16M;
  -- 0011
  pgsize_gte_64K  <= (not(entry_size(0)) and not(entry_size(1)) and  entry_size(2) and  entry_size(3)) or
                      pgsize_gte_1M;

  -- 1010
  pgsize_eq_1G  <= (  entry_size(0)  and not(entry_size(1))  and   entry_size(2) and not(entry_size(3)) );
  -- 1001, large indirect entry size
  pgsize_eq_256M <= (    entry_size(0)  and not(entry_size(1))  and not(entry_size(2)) and   entry_size(3) );
  -- 0111
  pgsize_eq_16M  <= ( not(entry_size(0))  and    entry_size(1)  and    entry_size(2) and  entry_size(3) );
  -- 0101
  pgsize_eq_1M   <= ( not(entry_size(0))  and entry_size(1) and not(entry_size(2)) and  entry_size(3) );
  -- 0011
  pgsize_eq_64K  <= ( not(entry_size(0)) and not(entry_size(1)) and  entry_size(2) and  entry_size(3) );
end generate gen_nocmpmask50;

gen_cmpmask50 : if have_cmpmask = 1 generate
--  size           entry_cmpmask: 01234
--    1GB                         11111
--  256MB                         01111
--   16MB                         00111
--    1MB                         00011
--   64KB                         00001
--    4KB                         00000
  pgsize_gte_1G   <= entry_cmpmask(0);
  pgsize_gte_256M <= entry_cmpmask(1);
  pgsize_gte_16M  <= entry_cmpmask(2);
  pgsize_gte_1M   <= entry_cmpmask(3);
  pgsize_gte_64K  <= entry_cmpmask(4);

--  size          entry_xbitmask: 01234
--    1GB                         10000
--  256MB                         01000
--   16MB                         00100
--    1MB                         00010
--   64KB                         00001
--    4KB                         00000
  pgsize_eq_1G   <= entry_xbitmask(0);
  pgsize_eq_256M <= entry_xbitmask(1);
  pgsize_eq_16M  <= entry_xbitmask(2);
  pgsize_eq_1M   <= entry_xbitmask(3);
  pgsize_eq_64K  <= entry_xbitmask(4);
end generate gen_cmpmask50;


gen_noxbit50 : if have_xbit = 0 generate
  function_34_51 <= '0';
  function_36_51 <= '0';
  function_40_51 <= '0';
  function_44_51 <= '0';
  function_48_51 <= '0';
end generate gen_noxbit50;
 
gen_xbit50 : if have_xbit /= 0 generate
  -- 1G
  function_34_51 <= not(entry_xbit) or
                    not(pgsize_eq_1G) or
                    or_reduce(entry_epn_b(34 to 51) and addr_in(34 to 51));
  -- 256M
  function_36_51 <= not(entry_xbit) or
                    not(pgsize_eq_256M) or
                    or_reduce(entry_epn_b(36 to 51) and addr_in(36 to 51));
  -- 16M
  function_40_51 <= not(entry_xbit) or
                    not(pgsize_eq_16M) or
                    or_reduce(entry_epn_b(40 to 51) and addr_in(40 to 51));
  -- 1M
  function_44_51 <= not(entry_xbit) or
                    not(pgsize_eq_1M) or
                    or_reduce(entry_epn_b(44 to 51) and addr_in(44 to 51));
  -- 64K
  function_48_51 <= not(entry_xbit) or
                    not(pgsize_eq_64K) or
                    or_reduce(entry_epn_b(48 to 51) and addr_in(48 to 51));
end generate gen_xbit50;

  comp_or_48_51 <=  and_reduce(match_line(48 to 51)) or pgsize_gte_64K;
  comp_or_44_47 <=  and_reduce(match_line(44 to 47)) or pgsize_gte_1M;
  comp_or_40_43 <=  and_reduce(match_line(40 to 43)) or pgsize_gte_16M;
  comp_or_36_39 <=  and_reduce(match_line(36 to 39)) or pgsize_gte_256M;
  comp_or_34_35 <=  and_reduce(match_line(34 to 35)) or pgsize_gte_1G; -- glorp

gen_noxbit51 : if have_xbit = 0 generate
  addr_match <=  ( comp_or_34_35  and               --  Ignore functions based on page size
                    comp_or_36_39  and               
                    comp_or_40_43  and
                    comp_or_44_47  and
                    comp_or_48_51  and
                    (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) 
                  ) or                                       --  Regular compare largest page size
                    not(addr_enable(8));                   --  Include address as part of compare,
                                                           --  should never ignore for regular compare/read.
                                                          -- Could ignore for compare/invalidate
  addr_match_xbit_contrib <=  '0';
                    
  addr_match_lsb_contrib <=  ( comp_or_34_35  and               --  Ignore functions based on page size
                                comp_or_36_39  and               
                                comp_or_40_43  and
                                comp_or_44_47  and
                                comp_or_48_51);
                                
  addr_match_msb_contrib <=  (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) ;

end generate gen_noxbit51;

gen_xbit51 : if have_xbit /= 0 generate
  addr_match <=  ( function_48_51 and
                    function_44_51 and
                    function_40_51 and
                    function_36_51 and
                    function_34_51 and
                    comp_or_34_35  and               --  Ignore functions based on page size
                    comp_or_36_39  and               
                    comp_or_40_43  and
                    comp_or_44_47  and
                    comp_or_48_51  and
                    (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) 
                  ) or                                       --  Regular compare largest page size
                    not(addr_enable(8));                   --  Include address as part of compare,
                                                            --  should never ignore for regular compare/read.
                                                           -- Could ignore for compare/invalidate

  addr_match_xbit_contrib <=  ( function_48_51 and        --  Exclusion functions
                                 function_44_51 and
                                 function_40_51 and
                                 function_36_51 and
                                 function_34_51 );
                    
  addr_match_lsb_contrib <=  ( comp_or_34_35  and               --  Ignore functions based on page size
                                comp_or_36_39  and               
                                comp_or_40_43  and
                                comp_or_44_47  and
                                comp_or_48_51);
                                
  addr_match_msb_contrib <=  (and_reduce(match_line(0 to 12)) or not(addr_enable(0))) and 
                    (and_reduce(match_line(13 to 14)) or not(addr_enable(1))) and 
                    (and_reduce(match_line(15 to 16)) or not(addr_enable(2))) and 
                    (and_reduce(match_line(17 to 18)) or not(addr_enable(3))) and 
                    (and_reduce(match_line(19 to 22)) or not(addr_enable(4))) and 
                    (and_reduce(match_line(23 to 26)) or not(addr_enable(5))) and 
                    (and_reduce(match_line(27 to 30)) or not(addr_enable(6))) and 
                    (and_reduce(match_line(31 to 33)) or not(addr_enable(7))) ;

end generate gen_xbit51;

end generate numpgsz5; -- numpgsz5: num_pgsizes = 5


  pgsize_match <=   and_reduce(match_line(52 to 55)) or
                    not(pgsize_enable);

  class_match  <=   and_reduce(match_line(56 to 57)) or
                    not(class_enable);

  extclass_match <= (match_line(58) or
                     not(extclass_enable(0))) and
                    (match_line(59) or
                     not(extclass_enable(1)));


  state_match <=    (match_line(60) or
                     not(state_enable(0))) and
                    (match_line(61) or
                     not(state_enable(1)));

  thdid_match <=    or_reduce(entry_thdid(0 to 3) and comp_thdid(0 to 3)) or
                    not(thdid_enable);
                    
  -- entry_pid=0 ignores pid match for translation, not invalidation
  pid_match <=      and_reduce(match_line(62 to 75)) or
                    (not(or_reduce(entry_pid(0 to 13))) and not comp_invalidate) or  
                    not(pid_enable);                         

  -- entry_lpid=0 ignores lpid match for translation, not invalidation
  lpid_match <=     and_reduce(match_line(76 to 83)) or
                    (not(or_reduce(entry_lpid(0 to 7))) and not comp_invalidate) or  
                    not(lpid_enable);              

  ind_match <=      match_line(84) or
                    not(ind_enable);

  iprot_match <=    match_line(85) or
                    not(iprot_enable);

  match <=          addr_match and                       --  Address compare
                    pgsize_match and                     --  Size compare
                    class_match and                      --  Class compare
                    extclass_match and                   --  ExtClass compare
                    state_match and                      --  State compare
                    thdid_match and                      --  ThdID compare
                    pid_match and                        --  PID compare
                    lpid_match and                       --  LPID compare
                    ind_match and                        --  indirect compare
                    iprot_match and                      --  inval prot compare
                    entry_v;                             --  Valid

    -- debug outputs
    dbg_addr_match       <= addr_match;  -- out  std_ulogic;
    dbg_pgsize_match     <= pgsize_match;  -- out  std_ulogic;
    dbg_class_match      <= class_match;  -- out  std_ulogic;
    dbg_extclass_match   <= extclass_match;  -- out  std_ulogic;
    dbg_state_match      <= state_match;  -- out  std_ulogic;
    dbg_thdid_match      <= thdid_match;  -- out  std_ulogic;
    dbg_pid_match        <= pid_match;  -- out  std_ulogic;
    dbg_lpid_match       <= lpid_match;  -- out  std_ulogic;
    dbg_ind_match        <= ind_match;  -- out  std_ulogic;
    dbg_iprot_match      <= iprot_match;  -- out  std_ulogic

end mmq_tlb_matchline;
