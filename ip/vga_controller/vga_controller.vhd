-- Function: VGA Controller
-- Resolutions: 640x480 --- 1920x1080
-- INSTRUCTIONS: For changing the resolution, comment the generic mapping at
-- the entity level for the actual resolution,
-- and uncomment the generic mapping for the desired resolution.
-- NOTE: It is important to wire this component with the specified input clock,
-- when an instance is created on a higher level.

library IEEE;
use IEEE.std_logic_1164.all;


entity vga_controller is
---- Map for a 1920x1200 diplay -- Refresh rate: 60 Hz 
-- Ideal pixel clock: 193.16 MHz
--  generic(
--    h_pulse  :  INTEGER   := 208;   --horiztonal sync pulse width in pixels
--    h_bp     :  INTEGER   := 336;   --horiztonal back porch width in pixels
--    h_pixels :  INTEGER   := 1920;  --horiztonal display width in pixels
--    h_fp     :  INTEGER   := 128;   --horiztonal front porch width in pixels
--    h_pol    :  STD_LOGIC := '0';   --horizontal sync pulse polarity
--    v_pulse  :  INTEGER   := 3;     --vertical sync pulse width in rows
--    v_bp     :  INTEGER   := 38;    --vertical back porch width in rows
--    v_pixels :  INTEGER   := 1200;  --vertical display width in rows
--    v_fp     :  INTEGER   := 1;     --vertical front porch width in rows
--    v_pol    :  STD_LOGIC := '1');  --vertical sync pulse polarity

---- Map for a 640x480 diplay -- Refresh rate: 60 Hz 
-- Ideal pixel clock: 25.175 MHz
  generic(
    h_pulse  :  INTEGER   := 96;   --horizontal sync pulse width in pixels
    h_bp     :  INTEGER   := 48;   --horizontal back porch width in pixels
    h_pixels :  INTEGER   := 640;  --horizontal display width in pixels
    h_fp     :  INTEGER   := 16;   --horizontal front porch width in pixels
    h_pol    :  STD_LOGIC := '0';   --horizontal sync pulse polarity
    v_pulse  :  INTEGER   := 2;     --vertical sync pulse width in rows
    v_bp     :  INTEGER   := 33;    --vertical back porch width in rows
    v_pixels :  INTEGER   := 480;  --vertical display width in rows
    v_fp     :  INTEGER   := 10;     --vertical front porch width in rows
    v_pol    :  STD_LOGIC := '0');  --vertical sync pulse polarity
  port(
    pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode
    reset_n   :  IN   STD_LOGIC;  --active low asycnchronous reset
    h_sync    :  OUT  STD_LOGIC;  --horizontal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
    disp_ena  :  OUT  STD_LOGIC;  --display enable ('1'=display, '0'=blanking)
    column    :  OUT  INTEGER;    --horizontal pixel coordinate
    row       :  OUT  INTEGER;    --vertical pixel coordinate
    n_blank   :  OUT  STD_LOGIC;  --direct blacking output to DAC
    n_sync    :  OUT  STD_LOGIC; --sync-on-green output to DAC
    data_req  :  OUT  STD_LOGIC);
end vga_controller;



architecture behavior of vga_controller is
  --total number of pixel clocks in a row and total number of rows in frame.
  constant  h_period  :  INTEGER := h_pulse + h_bp + h_pixels + h_fp;  
  constant  v_period  :  INTEGER := v_pulse + v_bp + v_pixels + v_fp;  
begin

  n_blank <= '1';  --no direct blanking
  n_sync <= '0';   --no sync on green
  
  -- The statements below will be evaluated any time there is a change in the 
  -- sensitivity list (pixel_clk or reset_n).
  process(pixel_clk, reset_n)
    --horizontal counter (columns) and vertical counter (rows).
    variable h_count  :  INTEGER RANGE 0 TO h_period - 1 := 0;  
    variable v_count  :  INTEGER RANGE 0 TO v_period - 1 := 0;  

  begin
    if(reset_n = '0') then  --reset asserted
      h_count := 0;         --reset horizontal counter
      v_count := 0;         --reset vertical counter
      h_sync <= NOT h_pol;  --deassert horizontal sync
      v_sync <= NOT v_pol;  --deassert vertical sync
      disp_ena <= '0';      --disable display
      data_req <= '0';      --disable request
      column <= 0;          --reset column pixel coordinate
      row <= 0;             --reset row pixel coordinate

    elsif(pixel_clk'event AND pixel_clk = '1') then
      --counters
      if(h_count < h_period - 1) then		--horizontal counter (pixels)
        h_count := h_count + 1;
      else
        h_count := 0;
        if(v_count < v_period - 1) then	--veritcal counter (rows)
          v_count := v_count + 1;
        else
          v_count := 0;
        end if;
      end if;

      --horizontal sync signal
      if(h_count < h_pixels + h_fp OR h_count > h_pixels + h_fp + h_pulse) then
        h_sync <= NOT h_pol;    --deassert horiztonal sync pulse
      else
        h_sync <= h_pol;        --assert horiztonal sync pulse
      end if;
      
      --vertical sync signal
      if(v_count < v_pixels + v_fp OR v_count > v_pixels + v_fp + v_pulse) then
        v_sync <= NOT v_pol;    --deassert vertical sync pulse
      else
        v_sync <= v_pol;        --assert vertical sync pulse
      end if;
      
      --set pixel coordinates
      if(h_count < h_pixels) then  --horiztonal display time
        column <= h_count;         --set horiztonal pixel coordinate
      end if;
      if(v_count < v_pixels) then  --vertical display time
        row <= v_count;            --set vertical pixel coordinate
      end if;

      --set display enable output
      if(h_count < h_pixels AND v_count < v_pixels) then  --display time
        disp_ena <= '1';                                  --enable display
      else                                                --blanking time
        disp_ena <= '0';                                  --disable display
      end if;

      --set data request value
      if (h_count < h_pixels - 2) AND (h_count >= h_period - 3)
          AND (v_count < v_pixels)
        then  
        data_req <= '1';                                  
      else                                                
        data_req <= '0';                                  
      end if;

    end if;
  end process;

end behavior;
