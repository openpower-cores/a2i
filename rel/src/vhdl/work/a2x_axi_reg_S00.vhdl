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

entity a2x_axi_reg_S00 is
	generic (


		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
        
        reg_cmd_00  : in  std_logic_vector(1 downto 0);
        reg_cmd_01  : in  std_logic_vector(1 downto 0);
        reg_cmd_02  : in  std_logic_vector(1 downto 0);
        reg_cmd_03  : in  std_logic_vector(1 downto 0);
        reg_cmd_04  : in  std_logic_vector(1 downto 0);
        reg_cmd_05  : in  std_logic_vector(1 downto 0);
        reg_cmd_06  : in  std_logic_vector(1 downto 0);
        reg_cmd_07  : in  std_logic_vector(1 downto 0);
        reg_cmd_08  : in  std_logic_vector(1 downto 0);
        reg_cmd_09  : in  std_logic_vector(1 downto 0);
        reg_cmd_0A  : in  std_logic_vector(1 downto 0);
        reg_cmd_0B  : in  std_logic_vector(1 downto 0);
        reg_cmd_0C  : in  std_logic_vector(1 downto 0);
        reg_cmd_0D  : in  std_logic_vector(1 downto 0);
        reg_cmd_0E  : in  std_logic_vector(1 downto 0);
        reg_cmd_0F  : in  std_logic_vector(1 downto 0);      
        reg_in_00  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_01  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_02  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_03  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_04  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_05  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_06  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_07  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_08  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_09  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0A  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0B  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0C  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0D  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0E  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0F  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_00 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_01 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_02 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_03 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_04 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_05 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_06 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_07 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_08 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_09 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0A : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0B : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0C : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0D : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0E : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0F : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);


		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
	);
end a2x_axi_reg_S00;

architecture arch_imp of a2x_axi_reg_S00 is

	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;
	signal slv_reg0, slv_reg0_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1, slv_reg1_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2, slv_reg2_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3, slv_reg3_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4, slv_reg4_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg5, slv_reg5_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg6, slv_reg6_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg7, slv_reg7_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg8, slv_reg8_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg9, slv_reg9_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg10, slv_reg10_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg11, slv_reg11_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg12, slv_reg12_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg13, slv_reg13_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg14, slv_reg14_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg15, slv_reg15_d	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en	: std_logic;

begin

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	           axi_awready <= '1';
	           aw_en <= '0';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	           aw_en <= '1';
	           axi_awready <= '0';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;


	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 


	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      slv_reg0 <= (others => '0');
	      slv_reg1 <= (others => '0');
	      slv_reg2 <= (others => '0');
	      slv_reg3 <= (others => '0');
	      slv_reg4 <= (others => '0');
	      slv_reg5 <= (others => '0');
	      slv_reg6 <= (others => '0');
	      slv_reg7 <= (others => '0');
	      slv_reg8 <= (others => '0');
	      slv_reg9 <= (others => '0');
	      slv_reg10 <= (others => '0');
	      slv_reg11 <= (others => '0');
	      slv_reg12 <= (others => '0');
	      slv_reg13 <= (others => '0');
	      slv_reg14 <= (others => '0');
	      slv_reg15 <= (others => '0');
	    else
	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr is
	          when b"0000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg10(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg11(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg12(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg13(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg14(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                slv_reg15(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when others =>
	            slv_reg0 <= slv_reg0_d;
	            slv_reg1 <= slv_reg1_d;
	            slv_reg2 <= slv_reg2_d;
	            slv_reg3 <= slv_reg3_d;
	            slv_reg4 <= slv_reg4_d;
	            slv_reg5 <= slv_reg5_d;
	            slv_reg6 <= slv_reg6_d;
	            slv_reg7 <= slv_reg7_d;
	            slv_reg8 <= slv_reg8_d;
	            slv_reg9 <= slv_reg9_d;
	            slv_reg10 <= slv_reg10_d;
	            slv_reg11 <= slv_reg11_d;
	            slv_reg12 <= slv_reg12_d;
	            slv_reg13 <= slv_reg13_d;
	            slv_reg14 <= slv_reg14_d;
	            slv_reg15 <= slv_reg15_d;
	        end case;
	      end if;
	    end if;
	  end if;                   
	end process; 


	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; 
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   
	        axi_bvalid <= '0';                                 
	      end if;
	    end if;
	  end if;                   
	end process; 


	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        axi_arready <= '1';
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; 
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, slv_reg10, slv_reg11, slv_reg12, slv_reg13, slv_reg14, slv_reg15, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	    case loc_addr is
	      when b"0000" =>
	        reg_data_out <= slv_reg0;
	      when b"0001" =>
	        reg_data_out <= slv_reg1;
	      when b"0010" =>
	        reg_data_out <= slv_reg2;
	      when b"0011" =>
	        reg_data_out <= slv_reg3;
	      when b"0100" =>
	        reg_data_out <= slv_reg4;
	      when b"0101" =>
	        reg_data_out <= slv_reg5;
	      when b"0110" =>
	        reg_data_out <= slv_reg6;
	      when b"0111" =>
	        reg_data_out <= slv_reg7;
	      when b"1000" =>
	        reg_data_out <= slv_reg8;
	      when b"1001" =>
	        reg_data_out <= slv_reg9;
	      when b"1010" =>
	        reg_data_out <= slv_reg10;
	      when b"1011" =>
	        reg_data_out <= slv_reg11;
	      when b"1100" =>
	        reg_data_out <= slv_reg12;
	      when b"1101" =>
	        reg_data_out <= slv_reg13;
	      when b"1110" =>
	        reg_data_out <= slv_reg14;
	      when b"1111" =>
	        case slv_reg15 is
	          when x"00000000" => reg_data_out <= x"02000048";
	          when others      => reg_data_out <= x"00000000";
	        end case;
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	end process; 

	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	          axi_rdata <= reg_data_out;     
	      end if;   
	    end if;
	  end if;
	end process;



	with reg_cmd_00 select
	   slv_reg0_d <= slv_reg0                   when "00",
	                 slv_reg0 or reg_in_00      when "01",
	                 slv_reg0 and not reg_in_00 when "10",
	                 reg_in_00                  when others; 

	with reg_cmd_01 select
	   slv_reg1_d <= slv_reg1                   when "00",
	                 slv_reg1 or reg_in_01      when "01",
	                 slv_reg1 and not reg_in_01 when "10",
	                 reg_in_01                  when others; 
 
	with reg_cmd_02 select
	   slv_reg2_d <= slv_reg2                   when "00",
	                 slv_reg2 or reg_in_02      when "01",
	                 slv_reg2 and not reg_in_02 when "10",
	                 reg_in_02                  when others; 
 
	with reg_cmd_03 select
	   slv_reg3_d <= slv_reg3                   when "00",
	                 slv_reg3 or reg_in_03      when "01",
	                 slv_reg3 and not reg_in_03 when "10",
	                 reg_in_03                  when others; 
 
	with reg_cmd_04 select
	   slv_reg4_d <= slv_reg4                   when "00",
	                 slv_reg4 or reg_in_04      when "01",
	                 slv_reg4 and not reg_in_04 when "10",
	                 reg_in_04                  when others; 
 
	with reg_cmd_05 select
	   slv_reg5_d <= slv_reg5                   when "00",
	                 slv_reg5 or reg_in_05      when "01",
	                 slv_reg5 and not reg_in_05 when "10",
	                 reg_in_05                  when others; 
 
	with reg_cmd_06 select
	   slv_reg6_d <= slv_reg6                   when "00",
	                 slv_reg6 or reg_in_06      when "01",
	                 slv_reg6 and not reg_in_06 when "10",
	                 reg_in_06                  when others; 
 
	with reg_cmd_07 select
	   slv_reg7_d <= slv_reg7                   when "00",
	                 slv_reg7 or reg_in_07      when "01",
	                 slv_reg7 and not reg_in_07 when "10",
	                 reg_in_07                  when others; 
 
	with reg_cmd_08 select
	   slv_reg8_d <= slv_reg8                   when "00",
	                 slv_reg8 or reg_in_08      when "01",
	                 slv_reg8 and not reg_in_08 when "10",
	                 reg_in_08                  when others; 
 
	with reg_cmd_09 select
	   slv_reg9_d <= slv_reg9                   when "00",
	                 slv_reg9 or reg_in_09      when "01",
	                 slv_reg9 and not reg_in_09 when "10",
	                 reg_in_09                  when others; 
 
	with reg_cmd_0A select
	   slv_reg10_d <= slv_reg10                   when "00",
	                  slv_reg10 or reg_in_0A      when "01",
	                  slv_reg10 and not reg_in_0A when "10",
	                  reg_in_0A                  when others; 
 
	with reg_cmd_0B select
	   slv_reg11_d <= slv_reg11                   when "00",
	                  slv_reg11 or reg_in_0B      when "01",
	                  slv_reg11 and not reg_in_0B when "10",
	                  reg_in_0B                  when others; 
 
	with reg_cmd_0C select
	   slv_reg12_d <= slv_reg12                   when "00",
	                  slv_reg12 or reg_in_0C      when "01",
	                  slv_reg12 and not reg_in_0C when "10",
	                  reg_in_0C                  when others; 
 
	with reg_cmd_0D select
	   slv_reg13_d <= slv_reg13                   when "00",
	                  slv_reg13 or reg_in_0D      when "01",
	                  slv_reg13 and not reg_in_0D when "10",
	                  reg_in_0D                  when others; 
 
	with reg_cmd_0E select
	   slv_reg14_d <= slv_reg14                   when "00",
	                  slv_reg14 or reg_in_0E      when "01",
	                  slv_reg14 and not reg_in_0E when "10",
	                  reg_in_0E                  when others; 
 
	with reg_cmd_0F select
	   slv_reg15_d <= slv_reg15                   when "00",
	                  slv_reg15 or reg_in_0F      when "01",
	                  slv_reg15 and not reg_in_0F when "10",
	                  reg_in_0F                  when others; 
 
 

end arch_imp;
