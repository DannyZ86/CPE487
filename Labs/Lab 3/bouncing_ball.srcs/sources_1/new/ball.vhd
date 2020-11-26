library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ball is 
    port( 
        v_sync      : in std_logic;
        pixel_row   : in std_logic_vector(10 downto 0);
        pixel_col   : in std_logic_vector(10 downto 0);
        red         : out std_logic;
        green       : out std_logic;
        blue        :out std_logic
        );
end ball;

ARCHITECTURE Behavioral OF ball IS
	CONSTANT size  : INTEGER := 12;
	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	-- current ball position - intitialized to center of screen
	SIGNAL ball_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL ball_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current ball motion - initialized to +4 pixels/frame
	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
BEGIN
	red <= NOT ball_on; -- color setup for red ball on white background
	green <= NOT ball_on;
	blue  <= '1';
	-- process to draw ball current pixel address is covered by ball position
	bdraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
	BEGIN
		IF ((((CONV_INTEGER(pixel_col)-CONV_INTEGER(ball_x))*
		(CONV_INTEGER(pixel_col)-CONV_INTEGER(ball_x)))+
		((CONV_INTEGER(pixel_row)-CONV_INTEGER(ball_y))*
		(CONV_INTEGER(pixel_row)-CONV_INTEGER(ball_y)))) <= (size*size)) THEN
--		IF (pixel_col >= ball_x - size) AND
--		 (pixel_col <= ball_x + size) AND
--			 (pixel_row >= ball_y - size) AND
--			 (pixel_row <= ball_y + size) THEN
				ball_on <= '1';
		ELSE
			ball_on <= '0';
		END IF;
		END PROCESS;
		-- process to move ball once every frame (i.e. once every vsync pulse)
		mball : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF ball_y + size >= 600 THEN
				ball_y_motion <= "11111111100";
				ball_x_motion <= "11111111100";
			ELSIF ball_y <= size THEN
				ball_y_motion <= "00000000100"; -- +4 pixels
				ball_x_motion <= "00000000100";
			END IF;
			ball_y <= ball_y + ball_y_motion; -- compute next ball position
			ball_x <= ball_x + ball_x_motion;
		END PROCESS;
END Behavioral;
