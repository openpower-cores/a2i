-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee;
use ieee.std_logic_1164.all;

package iuq_pkg is
  subtype EFF_IFAR      is std_ulogic_vector( 0 to 61);
  subtype REAL_IFAR     is std_ulogic_vector(22 to 61);
  subtype EFF_DATA_ADD  is std_ulogic_vector( 0 to 61);
  subtype REAL_DATA_ADD is std_ulogic_vector(18 to 61);

  function ib(x : std_ulogic) return boolean;

  function barrel_left(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector;
  function barrel_right(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector;
  function pri_enc(a : std_ulogic_vector) return std_ulogic_vector;
  function shift_left(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector;
  function shift_right(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector;
  function mask_left(a : std_ulogic_vector ) return std_ulogic_vector;
  function mask_right(a : std_ulogic_vector ) return std_ulogic_vector;

  function shift_leftx1B(a : std_ulogic_vector; s: std_ulogic_vector) return std_ulogic_vector;
  function shift_rightx1B(a : std_ulogic_vector; s: std_ulogic_vector) return std_ulogic_vector;

  procedure zeros(signal x : out std_ulogic);
  procedure zeros(signal x : out std_ulogic_vector);

  function encode_4to2( a : std_ulogic_vector(0 to 3) ) return std_ulogic_vector;
  function encode_8to3( a : std_ulogic_vector(0 to 7) ) return std_ulogic_vector;
  function encode_16to4(a : std_ulogic_vector(0 to 15)) return std_ulogic_vector;

   type PPC_INSTR is record
      vld                 : std_ulogic;
      instr               : std_ulogic_vector(0 to 31);

      ta                  : std_ulogic_vector(0 to 6);
      ta_vld              : std_ulogic;
      ta_typ              : std_ulogic_vector(0 to 1);

      s1                  : std_ulogic_vector(0 to 6);
      s1_vld              : std_ulogic;
      s1_typ              : std_ulogic_vector(0 to 1);

      s2                  : std_ulogic_vector(0 to 6);
      s2_vld              : std_ulogic;
      s2_typ              : std_ulogic_vector(0 to 1);

      s3                  : std_ulogic_vector(0 to 6);
      s3_vld              : std_ulogic;
      s3_typ              : std_ulogic_vector(0 to 1);

      isFxuIssue          : std_ulogic;
      isVsuIssue          : std_ulogic;

      EX4_exit		  : std_ulogic;
      EX7_exit            : std_ulogic;

      isLWARX   	  : std_ulogic;
      isSTWCX        	  : std_ulogic;
      is_vcrs      	  : std_ulogic;

      pred_update         : std_ulogic;
      pred_taken_cnt      : std_ulogic_vector(0 to 1);

      isINVALID_OP        : std_ulogic;
      isATTN		  : std_ulogic;

      UpdatesLR           : std_ulogic;
      UpdatesCR           : std_ulogic;
      UpdatesCTR          : std_ulogic;
      UsesLR              : std_ulogic;
      UsesCR              : std_ulogic;
      UsesCTR             : std_ulogic;

      is_st               : std_ulogic;
      is_ld               : std_ulogic;
      ibat_err            : std_ulogic;

      tid                 : std_ulogic_vector(0 to 3);

      ifar                : EFF_IFAR;
      bta                 : EFF_IFAR;

   end record;

   function TO_STLV ( x : PPC_INSTR ) return std_ulogic_vector;
   function TO_PPCI ( x : std_ulogic_vector(0 to 97+2*EFF_IFAR'length) ) return PPC_INSTR;


end iuq_pkg;

package body iuq_pkg is

  function ib(x : std_ulogic) return boolean
  is
  begin
    return(x = '1');
  end ib;


   function barrel_left(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector
   is
      variable result : std_ulogic_vector(a'left to a'right);
      variable i : integer := 0;
   begin

      result := a;
      for i in s'left to s'right loop
         if s(i) = '1' then
            exit;
         end if;
         result := result(result'left+1 to result'right)&result(result'left);
      end loop;

      return( result );
   end barrel_left;

   function barrel_right(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector
   is
      variable result : std_ulogic_vector(a'left to a'right);
   begin

      result := a;
      for i in a'left to a'right loop
         if s(i) = '1' then
            exit;
         end if;
         result := result(result'right) & result(result'left to result'right-1);
      end loop;

      return( result );
   end barrel_right;


   function pri_enc(a : std_ulogic_vector) return std_ulogic_vector
   is
      variable result : std_ulogic_vector(a'left to a'right);
   begin
      result := (others => '0');

      for i in a'left to a'right loop
         if a(i) = '1' then
            result(i) := '1';
            exit;
         end if;
      end loop;

      return( result );
   end pri_enc;

   function shift_left(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector is
      variable result : std_ulogic_vector(a'left to a'right);
   begin
      result := a;
      for i in s'left to s'right loop
         if s(i) = '1' then
            exit;
         end if;
         result := result( result'left+1 to result'right)&'0';
      end loop;
      return(result);
   end shift_left;

   function shift_right(a : std_ulogic_vector; s : std_ulogic_vector) return std_ulogic_vector is
      variable result : std_ulogic_vector(a'left to a'right);
   begin
      result := a;
      for i in s'left to s'right loop
         if s(i) = '1' then
            exit;
         end if;
         result := '0'&result(result'left to result'right-1);
      end loop;
      return(result);
   end shift_right;

   function mask_left(a : std_ulogic_vector ) return std_ulogic_vector is
      variable result : std_ulogic_vector(a'left to a'right);
      variable flag : integer := 0;
   begin
      for i in a'right downto a'left loop
         if ((a(i) = '1') or (flag = 1)) then
            result(i) := '1';
            flag := 1;
         else
            result(i) := a(i);
         end if;
      end loop;
      return( result );
   end mask_left;

   function mask_right(a : std_ulogic_vector ) return std_ulogic_vector is
      variable result : std_ulogic_vector(a'left to a'right);
      variable flag : integer := 0;
   begin
      for i in a'left to a'right loop
         if ((a(i) = '1') or (flag = 1)) then
            result(i) := '1';
            flag := 1;
         else
            result(i) := a(i);
         end if;
      end loop;
      return( result );
   end mask_right;

   function encode_4to2( a : std_ulogic_vector(0 to 3) ) return std_ulogic_vector is
      variable result : std_ulogic_vector(0 to 1);
   begin
      case a is
         when "1000" => result := "00";
         when "0100" => result := "01";
         when "0010" => result := "10";
         when "0001" => result := "11";
         when others => result := "00";
      end case;
      return(result);
   end encode_4to2;

   function encode_8to3( a : std_ulogic_vector(0 to 7) ) return std_ulogic_vector is
      variable result : std_ulogic_vector(0 to 2);
   begin
      case a is
         when "10000000" => result := "000";
         when "01000000" => result := "001";
         when "00100000" => result := "010";
         when "00010000" => result := "011";
         when "00001000" => result := "100";
         when "00000100" => result := "101";
         when "00000010" => result := "110";
         when "00000001" => result := "111";
         when others => result := "000";
      end case;
      return(result);
   end encode_8to3;

   function encode_16to4(a : std_ulogic_vector(0 to 15)) return std_ulogic_vector is
      variable result : std_ulogic_vector(0 to 3);
   begin
      case a is
         when "1000000000000000" => result := "0000";
         when "0100000000000000" => result := "0001";
         when "0010000000000000" => result := "0010";
         when "0001000000000000" => result := "0011";
         when "0000100000000000" => result := "0100";
         when "0000010000000000" => result := "0101";
         when "0000001000000000" => result := "0110";
         when "0000000100000000" => result := "0111";
         when "0000000010000000" => result := "1000";
         when "0000000001000000" => result := "1001";
         when "0000000000100000" => result := "1010";
         when "0000000000010000" => result := "1011";
         when "0000000000001000" => result := "1100";
         when "0000000000000100" => result := "1101";
         when "0000000000000010" => result := "1110";
         when "0000000000000001" => result := "1111";
         when others => result := "0000";
      end case;
      return(result);
   end encode_16to4;

   function shift_leftx1B(a : std_ulogic_vector; s: std_ulogic_vector) return std_ulogic_vector is
      variable result : std_ulogic_vector(a'left to a'right);
   begin
      result := a;
      for i in s'left to s'right loop
         if s(i) = '1' then
            exit;
         end if;
         result := result( result'left+8 to result'right)&"00000000";
      end loop;
      return(result);
   end shift_leftx1B;

   function shift_rightx1B(a : std_ulogic_vector; s: std_ulogic_vector) return std_ulogic_vector is
         variable result : std_ulogic_vector(a'left to a'right);
   begin
      result := a;
      for i in s'left to s'right loop
         if s(i) = '1' then
            exit;
         end if;
         result := "00000000"&result(result'left to result'right-8);
      end loop;
      return(result);
   end shift_rightx1B;




	  	function TO_STLV ( x : PPC_INSTR ) return std_ulogic_vector
	  	is
	    	variable result : std_ulogic_vector(0 to 97+2*EFF_IFAR'length);
	   	begin
	      	result :=   x.vld             &
	                    x.instr           &
	                    x.ta              &
	                    x.ta_vld          &
	                    x.ta_typ          &
	                    x.s1              &
	                    x.s1_vld          &
	                    x.s1_typ          &
	                    x.s2              &
	                    x.s2_vld          &
	                    x.s2_typ          &
	                    x.s3              &
	                    x.s3_vld          &
	                    x.s3_typ          &
	                    x.isFxuIssue      &
	                    x.isVsuIssue      &
	                    x.EX4_exit        &
	                    x.EX7_exit        &
	                    x.isLWARX         &
	                    x.isSTWCX         &
	                    x.is_vcrs         &
	                    x.pred_update     &
	                    x.pred_taken_cnt  &
	                    x.isINVALID_OP    &
	                    x.isATTN          &
	                    x.UpdatesLR       &
	                    x.UpdatesCR       &
	                    x.UpdatesCTR      &
	                    x.UsesLR          &
	                    x.UsesCR          &
	                    x.UsesCTR         &
	                    x.is_st           &
	                    x.is_ld           &
                            x.ibat_err        &
	                    x.tid             &
	                    x.ifar            &
	                    x.bta
	                    ;

	      	return result;
	   	end TO_STLV;

	function TO_PPCI ( x : std_ulogic_vector(0 to 97+2*EFF_IFAR'length) ) return PPC_INSTR is
   		variable result : PPC_INSTR;
	begin

        result.vld                 := x(0);
        result.instr               := x(1 to 32);
        result.ta                  := x(33 to 39);
        result.ta_vld              := x(40);
        result.ta_typ              := x(41 to 42);
        result.s1                  := x(43 to 49);
        result.s1_vld              := x(50);
        result.s1_typ              := x(51 to 52);
        result.s2                  := x(53 to 59);
        result.s2_vld              := x(60);
        result.s2_typ              := x(61 to 62);
        result.s3                  := x(63 to 69);
        result.s3_vld              := x(70);
        result.s3_typ              := x(71 to 72);
        result.isFxuIssue          := x(73);
        result.isVsuIssue          := x(74);
        result.EX4_exit            := x(75);
        result.EX7_exit            := x(76);
        result.isLWARX             := x(77);
	result.isSTWCX        	   := x(78);
	result.is_vcrs      	   := x(79);
        result.pred_update         := x(80);
        result.pred_taken_cnt      := x(81 to 82);
        result.isINVALID_OP        := x(83);
        result.isATTN		   := x(84);
        result.UpdatesLR           := x(85);
        result.UpdatesCR           := x(86);
        result.UpdatesCTR          := x(87);
        result.UsesLR              := x(88);
        result.UsesCR              := x(89);
        result.UsesCTR             := x(90);
        result.is_st               := x(91);
        result.is_ld               := x(92);
        result.ibat_err            := x(93);
        result.tid                 := x(94 to 97);
        result.ifar                := x(98 to 97+EFF_IFAR'length);
        result.bta                 := x(98+EFF_IFAR'length to 97+2*EFF_IFAR'length);

        return result;
	end TO_PPCI;

procedure zeros(signal x : out std_ulogic)
  is
  begin
    x <= '0';
  end zeros;

procedure zeros(signal x : out std_ulogic_vector)
  is
  begin
    for i in x'range loop
      x(i) <= '0';
    end loop;
  end zeros;


end iuq_pkg;
