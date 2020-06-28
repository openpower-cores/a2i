-- terminate yet another rare xil bug 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reverserator_64 is
	port (
		parkavenue : in  std_logic_vector(0 to 63);
		skidrowwww : out std_logic_vector(63 downto 0)
	);
end reverserator_64;

architecture reverserator_64 of reverserator_64 is
begin

   skidrowwww <= parkavenue;
   
end reverserator_64;

