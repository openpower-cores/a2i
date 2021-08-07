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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package a2x_pkg is 

attribute dont_touch : string;

constant c_ld_queue_size : integer := 4;   
constant c_ld_queue_bits : integer := 2;    
constant c_st_queue_size : integer := 16;
constant c_st_queue_bits : integer := 4;
constant c_max_pointer : integer := 2;

-- A2L2 ttypes
constant IFETCH    : std_logic_vector(0 to 5) := "000000";
constant IFETCHPRE : std_logic_vector(0 to 5) := "000001";
constant LOAD      : std_logic_vector(0 to 5) := "001000";
constant STORE     : std_logic_vector(0 to 5) := "100000";

constant LARX      : std_logic_vector(0 to 5) := "001001";
constant LARXHINT  : std_logic_vector(0 to 5) := "001011";
constant STCX      : std_logic_vector(0 to 5) := "101011";

constant LWSYNC    : std_logic_vector(0 to 5) := "101010";
constant HWSYNC    : std_logic_vector(0 to 5) := "101011";
constant MBAR      : std_logic_vector(0 to 5) := "110010";
constant TLBSYNC   : std_logic_vector(0 to 5) := "111010";

constant DCBI      : std_logic_vector(0 to 5) := "111111";


function or_reduce(slv: in std_logic_vector) return std_logic;
function and_reduce(slv: in std_logic_vector) return std_logic;
function inc(a: in std_logic_vector) return std_logic_vector;
function inc(a: in std_logic_vector; b: in integer) return std_logic_vector;
function dec(a: in std_logic_vector) return std_logic_vector;
function eq(a: in std_logic_vector; b: in integer) return boolean;
function eq(a: in std_logic_vector; b: in integer) return std_logic;
function eq(a: in std_logic_vector; b: in std_logic_vector) return boolean;
function eq(a: in std_logic_vector; b: in std_logic_vector) return std_logic;
function ne(a: in std_logic_vector; b: in integer) return boolean;
function ne(a: in std_logic_vector; b: in integer) return std_logic;
function ne(a: in std_logic_vector; b: in std_logic_vector) return boolean;
function ne(a: in std_logic_vector; b: in std_logic_vector) return std_logic;
function gt(a: in std_logic_vector; b: in integer) return boolean;
function gt(a: in std_logic_vector; b: in std_logic_vector) return boolean;
function gt(a: in std_logic_vector; b: in std_logic_vector) return std_logic;
function nz(a: in std_logic_vector) return boolean;
function nz(a: in std_logic_vector) return std_logic;
function b(a: in boolean) return std_logic;
function b(a: in std_logic) return boolean;

function clog2(n : in integer) return integer;            
function conv_integer(a: in std_logic_vector) return integer; 
function max(a: in integer; b: in integer) return integer;

function right_one(a: in std_logic_vector) return std_logic_vector;
function gate_and(a: in std_logic; b: in std_logic_vector) return std_logic_vector;
function rotl(a: in std_logic_vector; b: in integer) return std_logic_vector;
function rotl(a: in std_logic_vector; b: in std_logic_vector) return std_logic_vector;
function rotr(a: in std_logic_vector; b: in integer) return std_logic_vector;
function rotr(a: in std_logic_vector; b: in std_logic_vector) return std_logic_vector;
function enc(a: in std_logic_vector) return std_logic_vector;
function enc(a: in std_logic_vector; b: in integer) return std_logic_vector;

subtype RADDR is std_logic_vector(64-42 to 63);
subtype LINEADDR is std_logic_vector(64-42 to 59);

type A2L2REQUEST is record
	valid                      : std_logic;                       
   sent                       : std_logic;                       
   data                       : std_logic;                       
	dseq                       : std_logic_vector(0 to 2);        
   endian                     : std_logic;
   tag                        : std_logic_vector(0 to 4);
   len                        : std_logic_vector(0 to 2);
   ra                         : RADDR;   
   thread                     : std_logic_vector(0 to 1);
   spec                       : std_logic;   
   ditc                       : std_logic;
   ttype                      : std_logic_vector(0 to 5);
   user                       : std_logic_vector(0 to 3);
   wimg                       : std_logic_vector(0 to 3);
   hwsync                     : std_logic;
end record;

type A2L2STOREDATA is record
   data                       : std_logic_vector(0 to 127);
   be                         : std_logic_vector(0 to 15);   
end record;
	
type A2L2RELOAD is record
   coming                     : std_logic;	
   valid                      : std_logic;
   tag                        : std_logic_vector(0 to 4);
   data                       : std_logic_vector(0 to 127);
   ee                         : std_logic;
   ue                         : std_logic;
   qw                         : std_logic_vector(57 to 59);
   crit                       : std_logic;
   dump                       : std_logic;
end record;

type A2L2STATUS is record
   ld_pop                     : std_logic;
   st_pop                     : std_logic;
   st_pop_thrd                : std_logic_vector(0 to 2);
   gather                     : std_logic;      
   res_valid                  : std_logic_vector(0 to 3);
   stcx_complete              : std_logic_vector(0 to 3);
   stcx_pass                  : std_logic_vector(0 to 3);
   sync_ack                   : std_logic_vector(0 to 3);	
end record;	

type A2L2RESV is record
   valid                      : std_logic;
   ra                         : LINEADDR;
end record;
	
type LOADQUEUE is array(0 to c_ld_queue_size-1) of A2L2REQUEST;
type LOADDATAQUEUE is array(0 to 63) of std_logic_vector(0 to 31);   
type LOADQUEUEDEP is array(0 to c_ld_queue_size-1) of std_logic_vector(0 to c_st_queue_bits);   -- 0: valid
type STOREQUEUE is array(0 to c_st_queue_size-1) of A2L2REQUEST;	
type STOREDATAQUEUE is array(0 to c_st_queue_size-1) of A2L2STOREDATA;
type STOREQUEUEDEP is array(0 to c_st_queue_size-1) of std_logic_vector(0 to c_ld_queue_bits);  -- 0: valid
type RESVARRAY is array(0 to 3) of A2L2RESV;

function address_check(a: in A2L2REQUEST; b: in A2L2REQUEST) return std_logic;

function mux_queue(a: in LOADQUEUE; b: in std_logic_vector) return A2L2REQUEST;
function mux_queue(a: in LOADDATAQUEUE; b: in integer) return std_logic_vector;
function mux_queue(a: in LOADDATAQUEUE; b: in std_logic_vector) return std_logic_vector;
function mux_queue(a: in LOADQUEUEDEP; b: in std_logic_vector) return std_logic_vector;
function mux_queue(a: in STOREQUEUE; b: in std_logic_vector) return A2L2REQUEST;
function mux_queue(a: in STOREDATAQUEUE; b: in std_logic_vector) return A2L2STOREDATA;
function mux_queue(a: in STOREQUEUEDEP; b: in std_logic_vector) return std_logic_vector;

end a2x_pkg;

package body a2x_pkg is 

----------------------------------------------------------------------
-- Functions

function or_reduce(slv: in std_logic_vector) return std_logic is
  variable res: std_logic := '0';
begin
  for i in slv'range loop
    res := res or slv(i);
  end loop;
  return res;
end function;

function and_reduce(slv: in std_logic_vector) return std_logic is
  variable res: std_logic := '1';
begin
  for i in slv'range loop
    res := res and slv(i);
  end loop;
  return res;
end function;

function inc(a: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a'length-1);
begin
  res := std_logic_vector(unsigned(a) + 1);
  return res;
end function;

function inc(a: in std_logic_vector; b: in integer) return std_logic_vector is
  variable res: std_logic_vector(0 to a'length-1);
begin
  res := std_logic_vector(unsigned(a) + b);
  return res;
end function;

function dec(a: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a'length-1);
begin
  res := std_logic_vector(unsigned(a) - 1);
  return res;
end function;

function eq(a: in std_logic_vector; b: in integer) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) = b;
  return res;
end function;

function eq(a: in std_logic_vector; b: in integer) return std_logic is
  variable res: std_logic;
begin
  if unsigned(a) = b then
   res := '1';
  else
   res := '0';
  end if;
  return res;
end function;

function eq(a: in std_logic_vector; b: in std_logic_vector) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) = unsigned(b);
  return res;
end function;

function eq(a: in std_logic_vector; b: in std_logic_vector) return std_logic is
  variable res: std_logic;
begin
  if unsigned(a) = unsigned(b) then
    res := '1';
  else
    res := '0';
  end if;
  return res;
end function;

function ne(a: in std_logic_vector; b: in integer) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) /= b;
  return res;
end function;

function ne(a: in std_logic_vector; b: in integer) return std_logic is
  variable res: std_logic;
begin
  if unsigned(a) /= b then
   res := '1';
  else
   res := '0';
  end if;
  return res;
end function;

function ne(a: in std_logic_vector; b: in std_logic_vector) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) /= unsigned(b);
  return res;
end function;

function ne(a: in std_logic_vector; b: in std_logic_vector) return std_logic is
  variable res: std_logic;
begin
  if unsigned(a) /= unsigned(b) then
    res := '1';
  else
    res := '0';
  end if;
  return res;
end function;

function gt(a: in std_logic_vector; b: in integer) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) > b;
  return res;
end function;

function gt(a: in std_logic_vector; b: in std_logic_vector) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) > unsigned(b);
  return res;
end function;

function gt(a: in std_logic_vector; b: in std_logic_vector) return std_logic is
  variable res: std_logic;
begin
  if unsigned(a) > unsigned(b) then
    res := '1';
  else
    res := '0';
  end if;
  return res;
end function;

function nz(a: in std_logic_vector) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) /= 0;
  return res;
end function;

function nz(a: in std_logic_vector) return std_logic is
  variable res: std_logic;
begin
  if unsigned(a) /= 0 then
    res := '1';
  else
    res := '0';
  end if;
  return res;
end function;

function b(a: in boolean) return std_logic is
  variable res: std_logic;
begin
  if a then
    res := '1';
  else
    res := '0';
  end if;
  return res;
end function;

function b(a: in std_logic) return boolean is
  variable res: boolean;
begin
  if a = '1' then
    res := true;
  else
    res := false;
  end if;
  return res;
end function;

function right_one(a: in std_logic_vector) return std_logic_vector is
  variable res : std_logic_vector(0 to a'length - 1);
begin
  for i in a'length - 1 downto 0 loop                        
    if a(i) = '1' then
      res(i) := '1';
      exit;
    end if; 
  end loop;
  return res;
end function;

function rotl(a: in std_logic_vector; b: in integer) return std_logic_vector is
  variable res : std_logic_vector(0 to a'length - 1);
begin
  res := a(b to a'length - 1) & a(0 to b - 1);
  return res;
end function;

function rotl(a: in std_logic_vector; b: in std_logic_vector) return std_logic_vector is
  variable res : std_logic_vector(0 to a'length - 1) := a;
  variable c : integer := conv_integer(b);
  variable i : integer;
begin
  for i in 0 to a'length - 1 loop  
    if (i + c < a'length) then
       res(i) := a(i + c);
    else
       res(i) := a(i + c - a'length);    
    end if;
  end loop;
  return res;
end function;

function rotr(a: in std_logic_vector; b: in integer) return std_logic_vector is
  variable res: std_logic_vector(0 to a'length - 1);
begin
  res := a(a'length - b to a'length - 1) & a(0 to a'length - b - 1);
  return res;
end function;

function rotr(a: in std_logic_vector; b: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a'length - 1);
  variable c : integer := conv_integer(b);
begin
  for i in 0 to a'length - 1 loop  
    if (a'length - c + i < a'length) then
       res(i) := a(a'length - c + i);
    else
       res(i) := a(-c + i);    
    end if;
  end loop;
  return res;
end function;

function gate_and(a: in std_logic; b: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to b'length-1);
begin
  if a = '1' then
     res := b;
  else   
     res := (others => '0');  
  end if;
  return res;
end function;		

function enc(a: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to clog2(a'length)-1) := (others => '0');
begin
  for i in 0 to a'length - 1 loop  
     if (a(i) = '1') then
        res := std_logic_vector(to_unsigned(i, res'length));
        exit;
     end if;
  end loop;
  return res;
end function;		

function enc(a: in std_logic_vector; b: in integer) return std_logic_vector is
  variable res: std_logic_vector(0 to b-1) := (others => '0');
begin
  for i in 0 to a'length - 1 loop  
     if (a(i) = '1') then
        res := std_logic_vector(to_unsigned(i, res'length));
        exit;
     end if;
  end loop;
  return res;
end function;		

function conv_integer(a: in std_logic_vector) return integer is
  variable res: integer;
begin
  res := to_integer(unsigned(a));
  return res; 
end function;

function max(a: in integer; b: in integer) return integer is
  variable res : integer;
begin
  if (a > b) then
     res := a;
  else
     res := b;
  end if;
  return res;
end function;

function mux_queue(a: in LOADQUEUE; b: in std_logic_vector) return A2L2REQUEST is
  variable res: A2L2REQUEST;
begin
  res := a(conv_integer(b));
  return res;
end function;

function mux_queue(a: in LOADDATAQUEUE; b: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a(0)'length-1);
begin
  res := a(conv_integer(b));
  return res;
end function;

function mux_queue(a: in LOADDATAQUEUE; b: in integer) return std_logic_vector is
  variable res: std_logic_vector(0 to a(0)'length-1);
begin
  res := a(b);
  return res;
end function;

function mux_queue(a: in LOADQUEUEDEP; b: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a(0)'length-1);
begin
  res := a(conv_integer(b));
  return res;
end function;


function mux_queue(a: in STOREQUEUE; b: in std_logic_vector) return A2L2REQUEST is
  variable res: A2L2REQUEST;
begin
  res := a(conv_integer(b));
  return res;
end function;

function mux_queue(a: in STOREDATAQUEUE; b: in std_logic_vector) return A2L2STOREDATA is
  variable res: A2L2STOREDATA;
begin
  res := a(conv_integer(b));
  return res;
end function;

function mux_queue(a: in STOREQUEUEDEP; b: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a(0)'length-1);
begin
  res := a(conv_integer(b));
  return res;
end function;

-- compare requests to determine if they overlap
function address_check(a: in A2L2REQUEST; b: in A2L2REQUEST) return std_logic is
  variable res: std_logic := '0';
  variable a_start, a_end, b_start, b_end : unsigned(0 to a.ra'length-1);
begin
   a_start := unsigned(a.ra);
   a_end := unsigned(a.ra) + 64;
   b_start := unsigned(b.ra);
   b_end := unsigned(b.ra) + 64;
   if ((a.valid = '1') and (a.spec = '0') and (b.valid = '1') and (b.spec = '0')) then       
      if ((a_start >= b_start) and (a_start <= b_end)) then
         res := '1';
      elsif ((a_end >= b_start) and (a_end <= b_end)) then
         res := '1';
      end if;
   end if;
   return res;
end function;

function clog2(n : in integer) return integer is            
   variable i : integer;
   variable j : integer := n - 1;
	variable res : integer := 1;                                       
begin                                                                   
   for i in 0 to 31 loop
      if (j > 1) then
         j := j / 2;
         res := res + 1;
      else
         exit;
      end if;
   end loop;
   return res;        	                                              
end;                                                                    
                                                                                    
end a2x_pkg;

