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

entity a2x_axi_intr is
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
end a2x_axi_intr;

architecture arch_imp of a2x_axi_intr is

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
	signal reg_global_intr_en	:std_logic_vector(0 downto 0);           
	signal reg_intr_en	     :std_logic_vector(C_NUM_OF_INTR-1 downto 0);        
	signal reg_intr_sts	 :std_logic_vector(C_NUM_OF_INTR-1 downto 0);        
	signal reg_intr_ack	 :std_logic_vector(C_NUM_OF_INTR-1 downto 0);        
	signal reg_intr_pending :std_logic_vector(C_NUM_OF_INTR-1 downto 0);        
	                                                                            
	signal intr	 :std_logic_vector(C_NUM_OF_INTR-1 downto 0);                
	signal det_intr :std_logic_vector(C_NUM_OF_INTR-1 downto 0);                
	                                                                            
	signal intr_reg_rden	:std_logic;                                          
	signal intr_reg_wren	:std_logic;                                          
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);    
	signal intr_counter    :std_logic_vector(3 downto 0);                       
	 	                                                                         
	signal intr_all       : std_logic;                                          
	signal intr_ack_all   : std_logic;                                          
	signal s_irq          : std_logic;                                          
	signal intr_all_ff    : std_logic;                                          
	signal intr_ack_all_ff: std_logic;                                          
	signal aw_en	: std_logic;                                                 


	function or_reduction (vec : in std_logic_vector) return std_logic is           
	  variable res_v : std_logic := '0';  
	  begin                                                                         
	  for i in vec'range loop                                                       
	    res_v := res_v or vec(i);                                                   
	  end loop;                                                                     
	  return res_v;                                                                 
	end function;                                                                   
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

	intr_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;
	                                                                                
	gen_intr_reg  : for i in 0 to (C_NUM_OF_INTR - 1) generate                      
	begin                                                                           
	  process (S_AXI_ACLK)                                                          
	  begin                                                                         
	    if rising_edge(S_AXI_ACLK) then                                             
	      if S_AXI_ARESETN = '0' then                                               
	        reg_global_intr_en <= (others => '0');	                               
	      else                                                                      
	        if (intr_reg_wren = '1' and axi_awaddr(4 downto 2) = "000") then      
	          reg_global_intr_en(0) <= S_AXI_WDATA(0);                              
	        end if;                                                                 
	      end if;                                                                   
	    end if;                                                                     
	  end process;                                                                  
	                                                                                
	                                                                                
	  process (S_AXI_ACLK)                                                          
	  begin                                                                         
	    if rising_edge(S_AXI_ACLK) then                                             
	      if S_AXI_ARESETN = '0' then                                               
	        reg_intr_en(i) <= '0';	                                               
	      else                                                                      
	        if (intr_reg_wren = '1' and axi_awaddr(4 downto 2) = "001") then      
	          reg_intr_en(i) <= S_AXI_WDATA(i);                                     
	        end if;                                                                 
	      end if;                                                                   
	    end if;                                                                     
	  end process;                                                                  
	                                                                                
	                                                                                
	  process (S_AXI_ACLK)                                                          
	  begin                                                                         
	    if rising_edge(S_AXI_ACLK) then                                             
	      if (S_AXI_ARESETN = '0' or  reg_intr_ack(i) = '1') then                   
	        reg_intr_sts(i) <= '0';	                                               
	      else                                                                      
	        reg_intr_sts(i) <= det_intr(i);                                         
	      end if;                                                                   
	    end if;                                                                     
	  end process;                                                                  
	                                                                                
	                                                                                
	  process (S_AXI_ACLK)                                                          
	  begin                                                                         
	    if rising_edge(S_AXI_ACLK) then                                             
	      if (S_AXI_ARESETN = '0' or reg_intr_ack(i) = '1') then                    
	        reg_intr_ack(i) <= '0';	                                               
	      else                                                                      
	        if (intr_reg_wren = '1' and axi_awaddr(4 downto 2) = "011") then      
	          reg_intr_ack(i) <= S_AXI_WDATA(i);                                    
	        end if;                                                                 
	      end if;                                                                   
	    end if;                                                                     
	  end process;                                                                  
	                                                                                
	                                                                                
	  process (S_AXI_ACLK)                                                          
	  begin                                                                         
	    if rising_edge(S_AXI_ACLK) then                                             
	      if (S_AXI_ARESETN = '0' or  reg_intr_ack(i) = '1') then                   
	        reg_intr_pending(i) <= '0';	                                           
	      else                                                                      
	          reg_intr_pending(i) <= reg_intr_sts(i) and reg_intr_en(i);            
	      end if;                                                                   
	    end if;                                                                     
	  end process;                                                                  
	                                                                                
	                                                                                
	end generate gen_intr_reg;                                                      

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

	intr_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;      

	RDATA_INTR_NUM_32: if (C_NUM_OF_INTR=32) generate                                   
	  begin                                                                             
	                                                                                    
	process (reg_global_intr_en, reg_intr_en, reg_intr_sts, reg_intr_ack, reg_intr_pending, axi_araddr, S_AXI_ARESETN, intr_reg_rden)
	  variable loc_addr :std_logic_vector(2 downto 0);                                  
	begin                                                                               
	  if S_AXI_ARESETN = '0' then                                                       
	    reg_data_out  <= (others => '0');                                               
	  else                                                                              
	    loc_addr := axi_araddr(4 downto 2);                                             
	    case loc_addr is                                                                
	      when "000" =>                                                               
	        reg_data_out <= x"0000000" & "000" & reg_global_intr_en(0);             
	      when "001" =>                                                               
	        reg_data_out <= reg_intr_en;                                                
	      when "010" =>                                                               
	        reg_data_out <= reg_intr_sts;                                               
	      when "011" =>                                                               
	        reg_data_out <= reg_intr_ack;                                               
	      when "100" =>                                                               
	        reg_data_out <= reg_intr_pending;                                           
	      when others =>                                                                
	        reg_data_out  <= (others => '0');                                           
	    end case;                                                                       
	  end if;                                                                           
	end process;                                                                        
	                                                                                    
	end generate RDATA_INTR_NUM_32;                                                     
	                                                                                    
	RDATA_INTR_NUM_LESS_32: if (C_NUM_OF_INTR/=32) generate                             
	  begin                                                                             
	                                                                                    
	process (reg_global_intr_en, reg_intr_en, reg_intr_sts, reg_intr_ack, reg_intr_pending, axi_araddr, S_AXI_ARESETN, intr_reg_rden)
	  variable loc_addr :std_logic_vector(2 downto 0);                                  
	  variable zero : std_logic_vector (C_S_AXI_DATA_WIDTH-C_NUM_OF_INTR-1 downto 0);   
	begin                                                                               
	  if S_AXI_ARESETN = '0' then                                                       
	    reg_data_out  <= (others => '0');                                               
	    zero := (others=>'0');                                                          
	  else                                                                              
	    zero := (others=>'0');                                                          
	    loc_addr := axi_araddr(4 downto 2);                                             
	    case loc_addr is                                                                
	      when "000" =>                                                               
	        reg_data_out <= x"0000000" & "000" & reg_global_intr_en(0);             
	      when "001" =>                                                               
	        reg_data_out <= zero & reg_intr_en;                                         
	      when "010" =>                                                               
	        reg_data_out <= zero & reg_intr_sts;                                        
	      when "011" =>                                                               
	        reg_data_out <= zero & reg_intr_ack;                                        
	      when "100" =>                                                               
	        reg_data_out <= zero & reg_intr_pending;                                    
	      when others =>                                                                
	        reg_data_out  <= (others => '0');                                           
	    end case;                                                                       
	  end if;                                                                           
	end process;                                                                        
	                                                                                    
	end generate RDATA_INTR_NUM_LESS_32;                                                
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (intr_reg_rden = '1') then
	          axi_rdata <= reg_data_out;     
	      end if;   
	    end if;
	  end if;
	end process;


	process( S_AXI_ACLK ) is                                                     
	  begin                                                                            
	    if (rising_edge (S_AXI_ACLK)) then                                             
	      if ( S_AXI_ARESETN = '0') then                                               
	        intr_counter <= (others => '1');                                           
	      elsif (intr_counter /= x"0") then                                          
	        intr_counter <= std_logic_vector (unsigned(intr_counter) - 1);                                        
	      end if;                                                                      
	    end if;                                                                        
	end process;                                                                       
	                                                                                   
	                                                                                   
	process( S_AXI_ACLK ) is                                                           
	  begin                                                                            
	    if (rising_edge (S_AXI_ACLK)) then                                             
	      if ( S_AXI_ARESETN = '0') then                                               
	        intr <= (others => '0');                                                   
	      else                                                                         
	        if (intr_counter = x"a") then                                            
	          intr <= (others => '1');                                                 
	        else                                                                       
	          intr <= (others => '0');                                                 
	        end if;                                                                    
	      end if;                                                                      
	    end if;                                                                        
	end process;                                                                       
	                                                                                   
	  process (S_AXI_ACLK)                                                             
	    variable temp : std_logic;                                                     
	    begin                                                                          
	      if (rising_edge (S_AXI_ACLK)) then                                           
	        if( S_AXI_ARESETN = '0' or intr_ack_all_ff = '1') then                     
	          intr_all <= '0';                                                         
	        else                                                                       
	          intr_all <= or_reduction(reg_intr_pending);                              
	        end if;                                                                    
	      end if;                                                                      
	  end process;                                                                     
	                                                                                   
	  process (S_AXI_ACLK)                                                             
	    variable temp : std_logic;                                                     
	    begin                                                                          
	      if (rising_edge (S_AXI_ACLK)) then                                           
	        if( S_AXI_ARESETN = '0' or intr_ack_all_ff = '1') then                     
	          intr_ack_all <= '0';                                                     
	        else                                                                       
	          intr_ack_all <= or_reduction(reg_intr_ack);                              
	        end if;                                                                    
	      end if;                                                                      
	  end process;                                                                     
	                                                                                   
	process( S_AXI_ACLK ) is                                                           
	  begin                                                                            
	    if (rising_edge (S_AXI_ACLK)) then                                             
	      if ( S_AXI_ARESETN = '0') then                                               
	        intr_all_ff <= '0';                                                        
	        intr_ack_all_ff <= '0';                                                    
	      else                                                                         
	        intr_all_ff <= intr_all;                                                   
	        intr_ack_all_ff <= intr_ack_all;                                           
	      end if;                                                                      
	   end if;                                                                         
	end process;                                                                       
	                                                                                   
	                                                                                   
	gen_intr_detection  : for i in 0 to (C_NUM_OF_INTR - 1) generate                   
	  signal s_irq_lvl: std_logic;                                                     
	  begin                                                                            
	    gen_intr_level_detect: if (C_INTR_SENSITIVITY(i) = '1') generate               
	    begin                                                                          
	        gen_intr_active_high_detect: if (C_INTR_ACTIVE_STATE(i) = '1') generate    
	        begin                                                                      
	                                                                                   
	          process( S_AXI_ACLK ) is                                                 
	            begin                                                                  
	              if (rising_edge (S_AXI_ACLK)) then                                   
	                if ( S_AXI_ARESETN = '0' or reg_intr_ack(i) = '1') then            
	                  det_intr(i) <= '0';                                              
	                else                                                               
	                  if (intr(i) = '1') then                                          
	                    det_intr(i) <= '1';                                            
	                  end if;                                                          
	               end if;                                                             
	             end if;                                                               
	          end process;                                                             
	        end generate gen_intr_active_high_detect;                                  
	                                                                                   
	        gen_intr_active_low_detect: if (C_INTR_ACTIVE_STATE(i) = '0') generate     
	          process( S_AXI_ACLK ) is                                                 
	            begin                                                                  
	              if (rising_edge (S_AXI_ACLK)) then                                   
	                if ( S_AXI_ARESETN = '0' or reg_intr_ack(i) = '1') then            
	                  det_intr(i) <= '0';                                              
	                else                                                               
	                  if (intr(i) = '0') then                                          
	                    det_intr(i) <= '1';                                            
	                  end if;                                                          
	                end if;                                                            
	              end if;                                                              
	          end process;                                                             
	        end generate gen_intr_active_low_detect;                                   
	                                                                                   
	    end generate gen_intr_level_detect;                                            
	                                                                                   
						                                                                
	    gen_intr_edge_detect: if (C_INTR_SENSITIVITY(i) = '0') generate                
	      signal intr_edge : std_logic_vector (C_NUM_OF_INTR-1 downto 0);              
	      signal intr_ff : std_logic_vector (C_NUM_OF_INTR-1 downto 0);                
	      signal intr_ff2 : std_logic_vector (C_NUM_OF_INTR-1 downto 0);               
	      begin                                                                        
	        gen_intr_rising_edge_detect: if (C_INTR_ACTIVE_STATE(i) = '1') generate    
	        begin                                                                      
	          process( S_AXI_ACLK ) is                                                 
	            begin                                                                  
	              if (rising_edge (S_AXI_ACLK)) then                                   
	                if ( S_AXI_ARESETN = '0' or reg_intr_ack(i) = '1') then            
	                  intr_ff(i) <= '0';                                               
	                  intr_ff2(i) <= '0';                                              
	                else                                                               
	                  intr_ff(i) <= intr(i);                                           
	                  intr_ff2(i) <= intr_ff(i);                                       
	               end if;                                                             
	              end if;                                                              
	          end process;                                                             
	                                                                                   
	          intr_edge(i) <= intr_ff(i) and (not intr_ff2(i));                        
	                                                                                   
	          process( S_AXI_ACLK ) is                                                 
	            begin                                                                  
	             if (rising_edge (S_AXI_ACLK)) then                                    
	               if ( S_AXI_ARESETN = '0' or reg_intr_ack(i) = '1') then             
	                 det_intr(i) <= '0';                                               
	               elsif (intr_edge(i) = '1') then                                     
	                 det_intr(i) <= '1';                                               
	               end if;                                                             
	             end if;                                                               
	           end process;                                                            
	                                                                                   
	        end generate gen_intr_rising_edge_detect;                                  
	                                                                                   
	        gen_intr_falling_edge_detect: if (C_INTR_ACTIVE_STATE(i) = '0') generate   
	        begin                                                                      
	          process( S_AXI_ACLK ) is                                                 
	            begin                                                                  
	              if (rising_edge (S_AXI_ACLK)) then                                   
	                if ( S_AXI_ARESETN = '0' or reg_intr_ack(i) = '1') then            
	                  intr_ff(i) <= '0';                                               
	                  intr_ff2(i) <= '0';                                              
	                else                                                               
	                  intr_ff(i) <= intr(i);                                           
	                  intr_ff2(i) <= intr_ff(i);                                       
	                end if;                                                            
	              end if;                                                              
	          end process;                                                             
	                                                                                   
	          intr_edge(i) <= intr_ff2(i) and (not intr_ff(i));                        
	                                                                                   
	          process( S_AXI_ACLK ) is                                                 
	            begin                                                                  
	              if (rising_edge (S_AXI_ACLK)) then                                   
	                if ( S_AXI_ARESETN = '0' or reg_intr_ack(i) = '1') then            
	                  det_intr(i) <= '0';                                              
	                elsif (intr_edge(i) = '1') then                                    
	                  det_intr(i) <= '1';                                              
	                end if;                                                            
	              end if;                                                              
	          end process;                                                             
	        end generate gen_intr_falling_edge_detect;                                 
	                                                                                   
	    end generate gen_intr_edge_detect;                                             
	                                                                                   
	                                                                                   
	   gen_irq_level: if (C_IRQ_SENSITIVITY = 1) generate                              
	   begin                                                                           
	       irq_level_high: if (C_IRQ_ACTIVE_STATE = 1) generate                        
	       begin                                                                       
	         process( S_AXI_ACLK ) is                                                  
	           begin                                                                   
	             if (rising_edge (S_AXI_ACLK)) then                                    
	               if ( S_AXI_ARESETN = '0' or intr_ack_all = '1') then                
	                 s_irq_lvl <= '0';                                                 
	               elsif (intr_all = '1' and reg_global_intr_en(0) = '1') then         
	                 s_irq_lvl <= '1';                                                 
	              end if;                                                              
	             end if;                                                               
	         end process;                                                              
	                                                                                   
	         s_irq <= s_irq_lvl;                                                       
	       end generate irq_level_high;                                                
	                                                                                   
		                                                                                
	       irq_level_low: if (C_IRQ_ACTIVE_STATE = 0) generate                         
	          process( S_AXI_ACLK ) is                                                 
	            begin                                                                  
	              if (rising_edge (S_AXI_ACLK)) then                                   
	                if ( S_AXI_ARESETN = '0' or intr_ack_all = '1') then               
	                  s_irq_lvl <= '1';                                                
	                elsif (intr_all = '1' and reg_global_intr_en(0) = '1') then        
	                  s_irq_lvl <= '0';                                                
	               end if;                                                             
	             end if;                                                               
	           end process;                                                            
	                                                                                   
	         s_irq <= s_irq_lvl;                                                       
	       end generate irq_level_low;                                                 
	                                                                                   
	   end generate gen_irq_level;                                                     
	                                                                                   
	                                                                                   
	   gen_irq_edge: if (C_IRQ_SENSITIVITY = 0) generate                               
	                                                                                   
	   signal s_irq_lvl_ff:std_logic;                                                  
	   begin                                                                           
	       irq_rising_edge: if (C_IRQ_ACTIVE_STATE = 1) generate                       
	       begin                                                                       
	         process( S_AXI_ACLK ) is                                                  
	           begin                                                                   
	             if (rising_edge (S_AXI_ACLK)) then                                    
	               if ( S_AXI_ARESETN = '0' or intr_ack_all = '1') then                
	                 s_irq_lvl <= '0';                                                 
	                 s_irq_lvl_ff <= '0';                                              
	               elsif (intr_all = '1' and reg_global_intr_en(0) = '1') then         
	                 s_irq_lvl <= '1';                                                 
	                 s_irq_lvl_ff <= s_irq_lvl;                                        
	              end if;                                                              
	            end if;                                                                
	         end process;                                                              
	                                                                                   
	         s_irq <= s_irq_lvl and (not s_irq_lvl_ff);                                
	       end generate irq_rising_edge;                                               
	                                                                                   
	       irq_falling_edge: if (C_IRQ_ACTIVE_STATE = 0) generate                      
	       begin                                                                       
	         process( S_AXI_ACLK ) is                                                  
	           begin                                                                   
	             if (rising_edge (S_AXI_ACLK)) then                                    
	               if ( S_AXI_ARESETN = '0' or intr_ack_all = '1') then                
	                 s_irq_lvl <= '1';                                                 
	                 s_irq_lvl_ff <= '1';                                              
	               elsif (intr_all = '1' and reg_global_intr_en(0) = '1') then         
	                 s_irq_lvl <= '0';                                                 
	                 s_irq_lvl_ff <= s_irq_lvl;                                        
	               end if;                                                             
	             end if;                                                               
	         end process;                                                              
	                                                                                   
	         s_irq <= not (s_irq_lvl_ff and (not s_irq_lvl));                          
	       end generate irq_falling_edge;                                              
	                                                                                   
	   end generate gen_irq_edge;                                                      
	                                                                                   
	   irq <= s_irq;                                                              
	end generate gen_intr_detection;                                                   



end arch_imp;
