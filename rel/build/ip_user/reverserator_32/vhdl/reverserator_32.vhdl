-- terminate yet another rare xil bug 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reverserator_32 is
	port (
		hell    : in  std_logic_vector(0 to 31);
		cowboys : out std_logic_vector(31 downto 0)
	);
end reverserator_32;

architecture reverserator_32 of reverserator_32 is
begin

   cowboys <= hell;

end reverserator_32;

