--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:56:40 10/16/2017
-- Design Name:   
-- Module Name:   /home/smishash/ProgSources/MIPI_CSI2_TX/simulation/test_MIPI_TX.vhd
-- Project Name:  testISE
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: csi_rx_4lane
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
use work.Common.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_MIPI_TX IS
END test_MIPI_TX;
 
ARCHITECTURE behavior OF test_MIPI_TX IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT csi_rx_4lane
    PORT(
         ref_clock_in : IN  std_logic; --IDELAY reference clock (nominally 200MHz)
         pixel_clock_in : IN  std_logic;
         byte_clock_out : OUT  std_logic;
         enable : IN  std_logic;
         reset : IN  std_logic;
         video_valid : OUT  std_logic;
         dphy_clk : IN  std_logic_vector(1 downto 0);
         dphy_d0 : IN  std_logic_vector(1 downto 0);
         dphy_d1 : IN  std_logic_vector(1 downto 0);
         dphy_d2 : IN  std_logic_vector(1 downto 0);
         dphy_d3 : IN  std_logic_vector(1 downto 0);
         video_hsync : OUT  std_logic;
         video_vsync : OUT  std_logic;
         video_den : OUT  std_logic;
         video_line_start : OUT  std_logic;
         video_odd_line : OUT  std_logic;
         video_data : OUT  std_logic_vector(19 downto 0);
         video_prev_line_data : OUT  std_logic_vector(19 downto 0)
        );
    END COMPONENT;
    
    --frame sending routine
        COMPONENT transmit_frame
    PORT(
         clk : IN  std_logic;
         clk_lp : IN  std_logic;
         rst : IN  std_logic;
         bytes_per_line : IN  std_logic_vector(15 downto 0);
         lines_per_frame : IN  std_logic_vector(15 downto 0);
         vc_num : IN  std_logic_vector(1 downto 0);
         data_type : IN   packet_type_t; --data type - YUV,RGB,RAW etc    
         frame_data_in : IN  std_logic_vector(7 downto 0);
      	frame_number : in std_logic_vector(15 downto 0);
         start_frame_transmission : IN  std_logic;
         hs_data_out : OUT  std_logic_vector(7 downto 0);
         lp_data_out : OUT  std_logic_vector(1 downto 0);
         hs_data_valid : OUT  std_logic;
         is_hs_mode : OUT  std_logic;
         ready_for_data_in_next_cycle : out std_logic; --goest high one clock cycle before ready 
                                                       --to get data
         line_sending_finished : out std_logic; --goes high when finished one line transmission, 
                                               -- hs_data_out is still valid (last byte)                                                   
         frame_sending_finished : out std_logic --goes high once frame sending is complete             
        );
    END COMPONENT;
    
    
    COMPONENT simple_serializer
    PORT(
         clk : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic;
         gate : IN  std_logic
        );
    END COMPONENT;

   --Inputs
   signal ref_clock_in : std_logic := '0'; --IDELAY reference clock (nominally 200MHz)
   signal pixel_clock_in : std_logic := '0';
   signal enable : std_logic := '0';
   signal reset : std_logic := '0';
   --DSI signals, signal 1 is P and signal 0 is N
   signal dphy_clk : std_logic_vector(1 downto 0) := (others => '0');
   signal dphy_d0 : std_logic_vector(1 downto 0) := (others => '0');
   signal dphy_d1 : std_logic_vector(1 downto 0) := (others => '0');
   signal dphy_d2 : std_logic_vector(1 downto 0) := (others => '0');
   signal dphy_d3 : std_logic_vector(1 downto 0) := (others => '0');
   --single_ended
   signal dphy_clk_se : std_logic  := '0'; -- _se = "single_ended"
   signal dphy_d0_se : std_logic  := '0';  -- _se = "single_ended"
   signal dphy_d1_se : std_logic  := '0';  -- _se = "single_ended"
   signal dphy_d2_se : std_logic  := '0';  -- _se = "single_ended"
   signal dphy_d3_se : std_logic  := '0';  -- _se = "single_ended"
   

 	--Outputs
   signal byte_clock_out : std_logic;
   signal video_valid : std_logic;
   signal video_hsync : std_logic;
   signal video_vsync : std_logic;
   signal video_den : std_logic;
   signal video_line_start : std_logic;
   signal video_odd_line : std_logic;
   signal video_data : std_logic_vector(19 downto 0);
   signal video_prev_line_data : std_logic_vector(19 downto 0);

   
   --*******frame sending related**************
      --Inputs
   signal clk : std_logic := '0';
   signal clk_lp : std_logic := '0';
   signal rst : std_logic := '0';
   signal bytes_per_line : std_logic_vector(15 downto 0) := x"0018"; --24 dec = length of crc_arr1 and crc_arr2 --:= (others => '0');
   signal lines_per_frame : std_logic_vector(15 downto 0) := x"0003"; --(others => '1');
   signal vc_num : std_logic_vector(1 downto 0) := (others => '0');
   signal data_type :  packet_type_t := RGB888; --data type - YUV,RGB,RAW etc    
   signal frame_data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal frame_number : std_logic_vector(15 downto 0) := (others => '1');
   signal start_frame_transmission : std_logic := '0';

 	--Outputs
   signal hs_data_out : std_logic_vector(7 downto 0);
   signal lp_data_out : std_logic_vector(1 downto 0);
   signal hs_data_valid : std_logic;
   signal is_hs_mode : std_logic;
   signal ready_for_data_in_next_cycle : std_logic;
   signal line_sending_finished : std_logic;
   signal frame_sending_finished : std_logic;
   
   -- Clock period definitions
   constant clk_period : time := 8 ns;
   constant clk_lp_period : time := 8 ns;
   constant dphy_clk_period : time := 2 ns; --500 Mhz
   constant ddr_clk_period : time := 1 ns; --1 Ghz  
   constant ref_clock_period : time := 5 ns; --200 Mhz
   constant pixel_clock_period : time := 100 ns; --250 Mhz
   
      --helpers
   signal ddr_dphy_clock : std_logic := '0';  -- ddr clock for serializer, x2 the rate of dphy_clk_se
   signal hs_dphy_serialized : std_logic := '0'; --serialized stream of HS data
   
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: csi_rx_4lane PORT MAP (
          ref_clock_in => ref_clock_in,
          pixel_clock_in => pixel_clock_in,
          byte_clock_out => byte_clock_out,
          enable => enable,
          reset => reset,
          video_valid => video_valid,
          dphy_clk => dphy_clk,
          dphy_d0 => dphy_d0,
          dphy_d1 => dphy_d1,
          dphy_d2 => dphy_d2,
          dphy_d3 => dphy_d3,
          video_hsync => video_hsync,
          video_vsync => video_vsync,
          video_den => video_den,
          video_line_start => video_line_start,
          video_odd_line => video_odd_line,
          video_data => video_data,
          video_prev_line_data => video_prev_line_data
        );


	-- Instantiate the Unit Under Test (UUT)
   uut_frame: transmit_frame PORT MAP (
          clk => clk,
          clk_lp => clk_lp,
          rst => rst,
          bytes_per_line => bytes_per_line,
          lines_per_frame => lines_per_frame,
          vc_num => vc_num,
          data_type => data_type,
          frame_data_in => frame_data_in,
          frame_number => frame_number,
          start_frame_transmission => start_frame_transmission,
          hs_data_out => hs_data_out,
          lp_data_out => lp_data_out,
          hs_data_valid => hs_data_valid,
          is_hs_mode => is_hs_mode,
          ready_for_data_in_next_cycle => ready_for_data_in_next_cycle,
          line_sending_finished => line_sending_finished,
          frame_sending_finished => frame_sending_finished
        );

     inst_simple_serializer : simple_serializer PORT MAP (
          clk => ddr_dphy_clock,
          data_in => hs_data_out,
          data_out => hs_dphy_serialized,
          gate => hs_data_valid
        );

   -- Clock process definitions
   ref_clock_process :process
   begin
		ref_clock_in <= '0';
		wait for ref_clock_period/2;
		ref_clock_in <= '1';
		wait for ref_clock_period/2;
   end process;
   
   dphy_clock_process :process
   begin
		dphy_clk_se <= '0';
		wait for dphy_clk_period/2;
		dphy_clk_se <= '1';
		wait for dphy_clk_period/2;
   end process;
   
   ddr_clk_process : process
   begin
		ddr_dphy_clock <= '1';
		wait for ddr_clk_period/2;
		ddr_dphy_clock <= '0';
		wait for ddr_clk_period/2;
   end process;
   
   pixel_clock_process :process
   begin
		--pixel_clock_in <= '0';
		wait for pixel_clock_period/2;
		--pixel_clock_in <= '1';
		wait for pixel_clock_period/2;
   end process;
 
--single-ended to differential 
dphy_clk(1) <= dphy_clk_se;
dphy_clk(0) <= not dphy_clk_se;
 
dphy_d0(1) <= dphy_d0_se;
dphy_d0(0) <= not dphy_d0_se;

dphy_d1(1) <= dphy_d1_se;
dphy_d1(0) <= not dphy_d1_se;

dphy_d2(1) <= dphy_d2_se;
dphy_d2(0) <= not dphy_d2_se;

dphy_d3(1) <= dphy_d3_se;
dphy_d3(0) <= not dphy_d3_se;


dphy_d0_se <= hs_dphy_serialized;
dphy_d1_se <= hs_dphy_serialized;
dphy_d2_se <= hs_dphy_serialized;
dphy_d3_se <= hs_dphy_serialized;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for  ddr_clk_period*20;
   	 wait for  ddr_clk_period/2;
      
      reset <= '0';
      
      --wait for ref_clock_period*5;
      
      enable <= '1';
      

      wait for ref_clock_period*10;

      -- insert stimulus here 

      wait;
   end process;
   
--***********Frame sending related*********
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   clk_lp_process :process
   begin
		clk_lp <= '0';
		wait for clk_lp_period/2;
		clk_lp <= '1';
		wait for clk_lp_period/2;
   end process;
 

   -- Stimulus process
   stim_proc_frame: process
   begin		
		wait for  ddr_clk_period*20;
		      
		--reset
	   rst <= '1';
   	wait for ddr_clk_period*5;    
   	rst <= '0';
   
   	wait for ddr_clk_period*20;
   	wait for  ddr_clk_period/2;

 		--trigger frame transmission 
      start_frame_transmission <= '1';
      wait for clk_period;
      start_frame_transmission <= '0';

      wait;
   end process;   

END;
