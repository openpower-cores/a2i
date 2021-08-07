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

--********************************************************************
--*
--* TITLE: I-ERAT CAM Match Line Logic for Functional Model
--*
--* NAME: tri_cam_16x143_1r1w1c_matchline
--*

library ieee;
use ieee.std_logic_1164.all ;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;

------------------------------------------------------------------------
-- Entity
------------------------------------------------------------------------

entity tri_cam_16x143_1r1w1c_matchline is
  generic (have_xbit : integer := 1;
             num_pgsizes : integer := 5;
             have_cmpmask         : integer := 1;
             cmpmask_width        : integer := 4);

port( -- @{default:nclk}@
    addr_in                          : in std_ulogic_vector(0 to 51);
    addr_enable                      : in std_ulogic_vector(0 to 1);
    comp_pgsize                      : in std_ulogic_vector(0 to 2);
    pgsize_enable                    : in std_ulogic;
    entry_size                       : in std_ulogic_vector(0 to 2);
    entry_cmpmask                    : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_xbit                       : in std_ulogic;
    entry_xbitmask                   : in std_ulogic_vector(0 to cmpmask_width-1);
    entry_epn                        : in std_ulogic_vector(0 to 51);
    comp_class                       : in std_ulogic_vector(0 to 1);
    entry_class                      : in std_ulogic_vector(0 to 1);
    class_enable                     : in std_ulogic_vector(0 to 2);
    comp_extclass                    : in std_ulogic_vector(0 to 1);
    entry_extclass                   : in std_ulogic_vector(0 to 1);
    extclass_enable                  : in std_ulogic_vector(0 to 1);
    comp_state                       : in std_ulogic_vector(0 to 1);
    entry_hv                         : in std_ulogic;
    entry_ds                         : in std_ulogic;
    state_enable                     : in std_ulogic_vector(0 to 1);
    entry_thdid                      : in std_ulogic_vector(0 to 3);
    comp_thdid                       : in std_ulogic_vector(0 to 3);
    thdid_enable                     : in std_ulogic_vector(0 to 1);
    entry_pid                        : in std_ulogic_vector(0 to 7);
    comp_pid                         : in std_ulogic_vector(0 to 7);
    pid_enable                       : in std_ulogic;
    entry_v                          : in std_ulogic;
    comp_invalidate                  : in std_ulogic;

    match                            : out std_ulogic
);

  -- synopsys translate_off
  -- synopsys translate_on

end tri_cam_16x143_1r1w1c_matchline;

architecture tri_cam_16x143_1r1w1c_matchline of tri_cam_16x143_1r1w1c_matchline is


------------------------------------------------------------------------
-- Signals
------------------------------------------------------------------------

  signal entry_epn_b             : std_ulogic_vector(34 to 51);
  signal function_50_51     : std_ulogic;
  signal function_48_51     : std_ulogic;
  signal function_46_51     : std_ulogic;
  signal function_44_51     : std_ulogic;
  signal function_40_51     : std_ulogic;
  signal function_36_51     : std_ulogic;
  signal function_34_51     : std_ulogic;
  signal pgsize_eq_16K  : std_ulogic;
  signal pgsize_eq_64K  : std_ulogic;
  signal pgsize_eq_256K : std_ulogic;
  signal pgsize_eq_1M   : std_ulogic;
  signal pgsize_eq_16M  : std_ulogic;
  signal pgsize_eq_256M : std_ulogic;
  signal pgsize_eq_1G   : std_ulogic;
  signal pgsize_gte_16K  : std_ulogic;
  signal pgsize_gte_64K  : std_ulogic;
  signal pgsize_gte_256K : std_ulogic;
  signal pgsize_gte_1M   : std_ulogic;
  signal pgsize_gte_16M  : std_ulogic;
  signal pgsize_gte_256M : std_ulogic;
  signal pgsize_gte_1G   : std_ulogic;
  signal comp_or_34_35      : std_ulogic;
  signal comp_or_34_39      : std_ulogic;
  signal comp_or_36_39      : std_ulogic;
  signal comp_or_40_43      : std_ulogic;
  signal comp_or_44_45      : std_ulogic;
  signal comp_or_44_47      : std_ulogic;
  signal comp_or_46_47      : std_ulogic;
  signal comp_or_48_49      : std_ulogic;
  signal comp_or_48_51      : std_ulogic;
  signal comp_or_50_51      : std_ulogic;
  signal match_line         : std_ulogic_vector(0 to 72);
  signal pgsize_match       : std_ulogic;
  signal addr_match         : std_ulogic;
  signal class_match        : std_ulogic;
  signal extclass_match     : std_ulogic;
  signal state_match        : std_ulogic;
  signal thdid_match        : std_ulogic;
  signal pid_match          : std_ulogic;

begin

  match_line(0 to 72) <= not((entry_epn(0 to 51) & entry_size(0 to 2) & entry_class(0 to 1) & entry_extclass(0 to 1) & entry_hv & entry_ds & entry_pid(0 to 7) & entry_thdid(0 to 3)) xor
                             (addr_in(0 to 51) & comp_pgsize(0 to 2) & comp_class(0 to 1) & comp_extclass(0 to 1) & comp_state(0 to 1) & comp_pid(0 to 7) & comp_thdid(0 to 3))
                            );

numpgsz8 : if num_pgsizes = 8 generate

  entry_epn_b(34 to 51) <= not(entry_epn(34 to 51));


gen_nocmpmask80 : if have_cmpmask = 0 generate
  pgsize_eq_1G   <= (    entry_size(0)  and     entry_size(1)  and     entry_size(2) );
  pgsize_eq_256M <= (    entry_size(0)  and     entry_size(1)  and not(entry_size(2)));
  pgsize_eq_16M  <= (    entry_size(0)  and not(entry_size(1)) and     entry_size(2) );
  pgsize_eq_1M   <= (    entry_size(0)  and not(entry_size(1)) and not(entry_size(2)));
  pgsize_eq_256K <= (not(entry_size(0)) and     entry_size(1)  and     entry_size(2) );
  pgsize_eq_64K  <= (not(entry_size(0)) and     entry_size(1)  and not(entry_size(2)));
  pgsize_eq_16K  <= (not(entry_size(0)) and not(entry_size(1)) and     entry_size(2) );

  pgsize_gte_1G   <= (    entry_size(0)  and     entry_size(1)  and     entry_size(2) );
  pgsize_gte_256M <= (    entry_size(0)  and     entry_size(1)  and not(entry_size(2))) or
                      pgsize_gte_1G;
  pgsize_gte_16M  <= (    entry_size(0)  and not(entry_size(1)) and     entry_size(2) ) or
                      pgsize_gte_256M;
  pgsize_gte_1M   <= (    entry_size(0)  and not(entry_size(1)) and not(entry_size(2))) or
                      pgsize_gte_16M;
  pgsize_gte_256K <= (not(entry_size(0)) and     entry_size(1)  and     entry_size(2) ) or
                      pgsize_gte_1M;
  pgsize_gte_64K  <= (not(entry_size(0)) and     entry_size(1)  and not(entry_size(2))) or
                      pgsize_gte_256K;
  pgsize_gte_16K  <= (not(entry_size(0)) and not(entry_size(1)) and     entry_size(2) ) or
                      pgsize_gte_64K;

end generate gen_nocmpmask80;

gen_cmpmask80 : if have_cmpmask = 1 generate
--  size           entry_cmpmask: 0123456
--    1GB                         0000000
--  256MB                         1000000
--   16MB                         1100000
--    1MB                         1110000
--  256KB                         1111000
--   64KB                         1111100
--   16KB                         1111110
--    4KB                         1111111
  pgsize_gte_1G   <= not entry_cmpmask(0);
  pgsize_gte_256M <= not entry_cmpmask(1);
  pgsize_gte_16M  <= not entry_cmpmask(2);
  pgsize_gte_1M   <= not entry_cmpmask(3);
  pgsize_gte_256K <= not entry_cmpmask(4);
  pgsize_gte_64K  <= not entry_cmpmask(5);
  pgsize_gte_16K  <= not entry_cmpmask(6);

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
  addr_match <=    (comp_or_34_35  and               --  Ignore functions based on page size
                    comp_or_36_39  and
                    comp_or_40_43  and
                    comp_or_44_45  and
                    comp_or_46_47  and
                    comp_or_48_49  and
                    comp_or_50_51  and
                    and_reduce(match_line(31 to 33)) and     --  Regular compare largest page size
                    (and_reduce(match_line(0 to 30)) or not(addr_enable(1)))) or  -- ignored part of epn
                    not(addr_enable(0));                    --  Include address as part of compare,
                                                           --  should never ignore for regular compare/read.
                                                           -- Could ignore for compare/invalidate
end generate gen_noxbit81;
 
gen_xbit81 : if have_xbit /= 0 generate
  addr_match <=    (function_50_51 and               --  Exclusion functions
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
                    and_reduce(match_line(31 to 33)) and     --  Regular compare largest page size
                    (and_reduce(match_line(0 to 30)) or not(addr_enable(1)))) or  -- ignored part of epn
                    not(addr_enable(0));                    --  Include address as part of compare,
                                                           --  should never ignore for regular compare/read.
                                                           -- Could ignore for compare/invalidate
end generate gen_xbit81; 

end generate numpgsz8; -- numpgsz8: num_pgsizes = 8


numpgsz5 : if num_pgsizes = 5 generate

  -- tie off unused signals
  function_50_51 <= '0';
  function_46_51 <= '0';
  function_36_51 <= '0';
  pgsize_eq_16K <= '0';
  pgsize_eq_256K <= '0';
  pgsize_eq_256M <= '0';
  pgsize_gte_16K <= '0';
  pgsize_gte_256K <= '0';
  pgsize_gte_256M <= '0';
  comp_or_34_35 <= '0';
  comp_or_36_39 <= '0';
  comp_or_44_45 <= '0';
  comp_or_46_47 <= '0';
  comp_or_48_49 <= '0';
  comp_or_50_51 <= '0';
  
  entry_epn_b(34 to 51) <= not(entry_epn(34 to 51));


gen_nocmpmask50 : if have_cmpmask = 0 generate
  -- 110
  pgsize_eq_1G   <= (    entry_size(0)  and     entry_size(1)  and  not(entry_size(2)) );
  -- 111
  pgsize_eq_16M   <= (    entry_size(0)  and    entry_size(1)  and     entry_size(2) );
  -- 101
  pgsize_eq_1M    <= (    entry_size(0)  and not(entry_size(1)) and   entry_size(2));
  -- 011
  pgsize_eq_64K   <= (not(entry_size(0)) and     entry_size(1)  and   entry_size(2));
  

  pgsize_gte_1G  <= (    entry_size(0)  and     entry_size(1)  and  not(entry_size(2)) );

  pgsize_gte_16M  <= (    entry_size(0)  and    entry_size(1)  and     entry_size(2) ) or
                      pgsize_gte_1G;
  pgsize_gte_1M   <= (    entry_size(0)  and not(entry_size(1)) and   entry_size(2)) or
                      pgsize_gte_16M;
  pgsize_gte_64K  <= (not(entry_size(0)) and     entry_size(1)  and   entry_size(2)) or
                      pgsize_gte_1M;
end generate gen_nocmpmask50;

gen_cmpmask50 : if have_cmpmask = 1 generate
--  size           entry_cmpmask: 0123
--    1GB                         0000
--   16MB                         1000
--    1MB                         1100
--   64KB                         1110
--    4KB                         1111
  pgsize_gte_1G   <= not entry_cmpmask(0);
  pgsize_gte_16M  <= not entry_cmpmask(1);
  pgsize_gte_1M   <= not entry_cmpmask(2);
  pgsize_gte_64K  <= not entry_cmpmask(3);

--  size          entry_xbitmask: 0123
--    1GB                         1000
--   16MB                         0100
--    1MB                         0010
--   64KB                         0001
--    4KB                         0000
  pgsize_eq_1G   <= entry_xbitmask(0);
  pgsize_eq_16M  <= entry_xbitmask(1);
  pgsize_eq_1M   <= entry_xbitmask(2);
  pgsize_eq_64K  <= entry_xbitmask(3);
end generate gen_cmpmask50;

gen_noxbit50 : if have_xbit = 0 generate
  function_34_51 <= '0';
  function_40_51 <= '0';
  function_44_51 <= '0';
  function_48_51 <= '0';
end generate gen_noxbit50;
 
gen_xbit50 : if have_xbit /= 0 generate
  -- 1G
  function_34_51 <= not(entry_xbit) or
                    not(pgsize_eq_1G) or
                    or_reduce(entry_epn_b(34 to 51) and addr_in(34 to 51));
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
  comp_or_34_39 <=  and_reduce(match_line(34 to 39)) or pgsize_gte_1G;

gen_noxbit51 : if have_xbit = 0 generate
  addr_match <=    (comp_or_34_39  and               --  Ignore functions based on page size
                    comp_or_40_43  and
                    comp_or_44_47  and
                    comp_or_48_51  and
                    and_reduce(match_line(31 to 33)) and     --  Regular compare largest page size
                    (and_reduce(match_line(0 to 30)) or not(addr_enable(1)))) or  -- ignored part of epn
                    not(addr_enable(0));                    --  Include address as part of compare,
                                                           --  should never ignore for regular compare/read.
                                                           -- Could ignore for compare/invalidate
end generate gen_noxbit51;

gen_xbit51 : if have_xbit /= 0 generate
  addr_match <=    (function_48_51 and
                    function_44_51 and
                    function_40_51 and
                    function_34_51 and
                    comp_or_34_39  and               --  Ignore functions based on page size
                    comp_or_40_43  and
                    comp_or_44_47  and
                    comp_or_48_51  and
                    and_reduce(match_line(31 to 33)) and     --  Regular compare largest page size
                    (and_reduce(match_line(0 to 30)) or not(addr_enable(1)))) or  -- ignored part of epn
                    not(addr_enable(0));                    --  Include address as part of compare,
                                                           --  should never ignore for regular compare/read.
                                                           -- Could ignore for compare/invalidate
end generate gen_xbit51;

end generate numpgsz5; -- numpgsz5: num_pgsizes = 5


  pgsize_match <=   and_reduce(match_line(52 to 54)) or
                    not(pgsize_enable);

  class_match  <=  (match_line(55) or not(class_enable(0))) and 
                    (match_line(56) or not(class_enable(1))) and 
                    (and_reduce(match_line(55 to 56)) or not(class_enable(2)) or
                      (not(entry_extclass(1)) and not comp_invalidate));   -- pid_nz bit

  extclass_match <= (match_line(57) or not(extclass_enable(0))) and  -- iprot bit
                     (match_line(58) or not(extclass_enable(1)));     -- pid_nz bit

  state_match <=    (match_line(59) or
                     not(state_enable(0))) and
                     (match_line(60) or
                     not(state_enable(1)));

  thdid_match <=   (or_reduce(entry_thdid(0 to 3) and comp_thdid(0 to 3)) or not(thdid_enable(0))) and 
                    (and_reduce(match_line(69 to 72)) or not(thdid_enable(1)) or
                      (not(entry_extclass(1)) and not comp_invalidate));   -- pid_nz bit

  pid_match <=      and_reduce(match_line(61 to 68)) or
                    -- entry_pid=0 ignores pid match for compares,
                    --  but not for invalidates.
                    (not(entry_extclass(1)) and not comp_invalidate) or  -- pid_nz bit
                      not(pid_enable); 

  match <=         addr_match and                       --  Address compare
                    pgsize_match and                     --  Size compare
                    class_match and                      --  Class compare
                    extclass_match and                   --  ExtClass compare
                    state_match and                      --  State compare
                    thdid_match and                      --  ThdID compare
                    pid_match and                        --  PID compare
                    entry_v;                             --  Valid

end tri_cam_16x143_1r1w1c_matchline;
