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
use ieee.numeric_std.all;

entity a2x_axi_reg is
	generic (



		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6;

		C_S_AXI_INTR_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_INTR_ADDR_WIDTH	: integer	:= 5;
		C_NUM_OF_INTR	: integer	:= 1;
		C_INTR_SENSITIVITY	: std_logic_vector	:= x"FFFFFFFF";
		C_INTR_ACTIVE_STATE	: std_logic_vector	:= x"FFFFFFFF";
		C_IRQ_SENSITIVITY	: integer	:= 1;
		C_IRQ_ACTIVE_STATE	: integer	:= 1
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
        reg_in_00  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_01  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_02  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_03  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_04  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_05  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_06  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_07  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_08  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_09  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0A  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0B  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0C  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0D  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0E  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_in_0F  : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_00 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_01 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_02 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_03 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_04 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_05 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_06 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_07 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_08 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_09 : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0A : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0B : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0C : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0D : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0E : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        reg_out_0F : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);



		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;

		s_axi_intr_aclk	: in std_logic;
		s_axi_intr_aresetn	: in std_logic;
		s_axi_intr_awaddr	: in std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0);
		s_axi_intr_awprot	: in std_logic_vector(2 downto 0);
		s_axi_intr_awvalid	: in std_logic;
		s_axi_intr_awready	: out std_logic;
		s_axi_intr_wdata	: in std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
		s_axi_intr_wstrb	: in std_logic_vector((C_S_AXI_INTR_DATA_WIDTH/8)-1 downto 0);
		s_axi_intr_wvalid	: in std_logic;
		s_axi_intr_wready	: out std_logic;
		s_axi_intr_bresp	: out std_logic_vector(1 downto 0);
		s_axi_intr_bvalid	: out std_logic;
		s_axi_intr_bready	: in std_logic;
		s_axi_intr_araddr	: in std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0);
		s_axi_intr_arprot	: in std_logic_vector(2 downto 0);
		s_axi_intr_arvalid	: in std_logic;
		s_axi_intr_arready	: out std_logic;
		s_axi_intr_rdata	: out std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
		s_axi_intr_rresp	: out std_logic_vector(1 downto 0);
		s_axi_intr_rvalid	: out std_logic;
		s_axi_intr_rready	: in std_logic;
		irq	: out std_logic
	);
end a2x_axi_reg;

architecture a2x_axi_reg of a2x_axi_reg is

	component a2x_axi_reg_S00 is
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
	end component a2x_axi_reg_S00;

	component a2x_axi_intr is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5;
		C_NUM_OF_INTR	: integer	:= 1;
		C_INTR_SENSITIVITY	: std_logic_vector	:= x"FFFFFFFF";
		C_INTR_ACTIVE_STATE	: std_logic_vector	:= x"FFFFFFFF";
		C_IRQ_SENSITIVITY	: integer	:= 1;
		C_IRQ_ACTIVE_STATE	: integer	:= 1
		);
		port (
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
		S_AXI_RREADY	: in std_logic;
		irq	: out std_logic
		);
	end component a2x_axi_intr;

begin

a2x_axi_reg_S00_inst : a2x_axi_reg_S00
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
        reg_cmd_00  => reg_cmd_00,
        reg_cmd_01  => reg_cmd_01,
        reg_cmd_02  => reg_cmd_02,
        reg_cmd_03  => reg_cmd_03,
        reg_cmd_04  => reg_cmd_04,
        reg_cmd_05  => reg_cmd_05,
        reg_cmd_06  => reg_cmd_06,
        reg_cmd_07  => reg_cmd_07,
        reg_cmd_08  => reg_cmd_08,
        reg_cmd_09  => reg_cmd_09,
        reg_cmd_0A  => reg_cmd_0A,
        reg_cmd_0B  => reg_cmd_0B,
        reg_cmd_0C  => reg_cmd_0C,
        reg_cmd_0D  => reg_cmd_0D,
        reg_cmd_0E  => reg_cmd_0E,
        reg_cmd_0F  => reg_cmd_0F,     
        reg_in_00   => reg_in_00,
        reg_in_01   => reg_in_01, 
        reg_in_02   => reg_in_02, 
        reg_in_03   => reg_in_03, 
        reg_in_04   => reg_in_04, 
        reg_in_05   => reg_in_05, 
        reg_in_06   => reg_in_06, 
        reg_in_07   => reg_in_07, 
        reg_in_08   => reg_in_08, 
        reg_in_09   => reg_in_09, 
        reg_in_0A   => reg_in_0A, 
        reg_in_0B   => reg_in_0B, 
        reg_in_0C   => reg_in_0C, 
        reg_in_0D   => reg_in_0D, 
        reg_in_0E   => reg_in_0E, 
        reg_in_0F   => reg_in_0F, 
        reg_out_00  => reg_out_00, 
        reg_out_01  => reg_out_01, 
        reg_out_02  => reg_out_02, 
        reg_out_03  => reg_out_03, 
        reg_out_04  => reg_out_04, 
        reg_out_05  => reg_out_05, 
        reg_out_06  => reg_out_06, 
        reg_out_07  => reg_out_07, 
        reg_out_08  => reg_out_08, 
        reg_out_09  => reg_out_09, 
        reg_out_0A  => reg_out_0A, 
        reg_out_0B  => reg_out_0B, 
        reg_out_0C  => reg_out_0C, 
        reg_out_0D  => reg_out_0D, 
        reg_out_0E  => reg_out_0E, 
        reg_out_0F  => reg_out_0F,       
		  S_AXI_ACLK => s00_axi_aclk,
        S_AXI_ARESETN => s00_axi_aresetn,
		  S_AXI_AWADDR	=> s00_axi_awaddr,
		  S_AXI_AWPROT	=> s00_axi_awprot,
		  S_AXI_AWVALID => s00_axi_awvalid,
		  S_AXI_AWREADY => s00_axi_awready,
		  S_AXI_WDATA	=> s00_axi_wdata,
		  S_AXI_WSTRB	=> s00_axi_wstrb,
		  S_AXI_WVALID	=> s00_axi_wvalid,
		  S_AXI_WREADY	=> s00_axi_wready,
		  S_AXI_BRESP	=> s00_axi_bresp,
		  S_AXI_BVALID	=> s00_axi_bvalid,
		  S_AXI_BREADY	=> s00_axi_bready,
		  S_AXI_ARADDR	=> s00_axi_araddr,
		  S_AXI_ARPROT	=> s00_axi_arprot,
		  S_AXI_ARVALID	=> s00_axi_arvalid,
		  S_AXI_ARREADY	=> s00_axi_arready,
		  S_AXI_RDATA	=> s00_axi_rdata,
		  S_AXI_RRESP	=> s00_axi_rresp,
		  S_AXI_RVALID	=> s00_axi_rvalid,
		  S_AXI_RREADY	=> s00_axi_rready
	);

a2x_axi_intr_inst : a2x_axi_intr
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_INTR_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_INTR_ADDR_WIDTH,
		C_NUM_OF_INTR	=> C_NUM_OF_INTR,
		C_INTR_SENSITIVITY	=> C_INTR_SENSITIVITY,
		C_INTR_ACTIVE_STATE	=> C_INTR_ACTIVE_STATE,
		C_IRQ_SENSITIVITY	=> C_IRQ_SENSITIVITY,
		C_IRQ_ACTIVE_STATE	=> C_IRQ_ACTIVE_STATE
	)
	port map (
		S_AXI_ACLK	=> s_axi_intr_aclk,
		S_AXI_ARESETN	=> s_axi_intr_aresetn,
		S_AXI_AWADDR	=> s_axi_intr_awaddr,
		S_AXI_AWPROT	=> s_axi_intr_awprot,
		S_AXI_AWVALID	=> s_axi_intr_awvalid,
		S_AXI_AWREADY	=> s_axi_intr_awready,
		S_AXI_WDATA	=> s_axi_intr_wdata,
		S_AXI_WSTRB	=> s_axi_intr_wstrb,
		S_AXI_WVALID	=> s_axi_intr_wvalid,
		S_AXI_WREADY	=> s_axi_intr_wready,
		S_AXI_BRESP	=> s_axi_intr_bresp,
		S_AXI_BVALID	=> s_axi_intr_bvalid,
		S_AXI_BREADY	=> s_axi_intr_bready,
		S_AXI_ARADDR	=> s_axi_intr_araddr,
		S_AXI_ARPROT	=> s_axi_intr_arprot,
		S_AXI_ARVALID	=> s_axi_intr_arvalid,
		S_AXI_ARREADY	=> s_axi_intr_arready,
		S_AXI_RDATA	=> s_axi_intr_rdata,
		S_AXI_RRESP	=> s_axi_intr_rresp,
		S_AXI_RVALID	=> s_axi_intr_rvalid,
		S_AXI_RREADY	=> s_axi_intr_rready,
		irq	=> irq
	);



end a2x_axi_reg;
