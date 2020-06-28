-- terminate yet another rare xil bug 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reverserator_4 is
	port (
		innnie : in  std_logic_vector(0 to 3);
		outtie : out std_logic_vector(3 downto 0)
	);
end reverserator_4;

architecture reverserator_4 of reverserator_4 is
begin

   outtie <= innnie;

end reverserator_4;

