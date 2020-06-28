-- terminate yet another rare xil bug 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reverserator_3 is
	port (
		outdoor : in  std_logic_vector(0 to 2);
		inndoor : out std_logic_vector(2 downto 0)
	);
end reverserator_3;

architecture reverserator_3 of reverserator_3 is
begin

   inndoor <= outdoor;

end reverserator_3;

