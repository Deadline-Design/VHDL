------------------------------------------------------------------------------------------------
--                                   WWW.DEADLINE-DESIGN.COM                                  --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This software representation and its inclusive documentation are provided AS-IS and with   --
-- all faults; is without warranty expressed or implied, including but not limited to,        --
-- warranties of merchantability or fitness for a particular purpose.                         --
--                                                                                            --
-- All trademarks are the property of their respective owners.                                --
--                                                                                            --
-- DESIGN UNITS : pre_scaler_srle_based_TSTR(testbench1)                                      --
--                                                                                            --
-- FILE NAME    : pre_scaler_srle_based_TSTR.vhd                                              --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide a very simplistic testbench   --
--                for the pre_scaler_srle_based(dynamic) design unit.                         --
--                                                                                            --
-- NOTE         : This testbench does utilize certain elements contained within the           --
--                D_D_pkg PACKAGE (D_D_pkg.vhd). Be sure to compile the package into the      --
--                DEADLINE LIBRARY prior to compiling this testbench into the DEADLINE        --
--                LIBRARY.                                                                    --
--                                                                                            --
--                This testbench does utilize the srle(dynamic) primitive (srle.vhd).         --
--                Be sure to compile the primitive into the DEADLINE LIBRARY prior to         --
--                compiling this testbench into the DEADLINE LIBRARY.                         --
--                                                                                            --
--                This testbench does utilize the pre_scaler_srle_based(dynamic) peripheral   --
--                (pre_scaler_srle_based.vhd). Be sure to compile the peripheral into the     --
--                DEADLINE LIBRARY prior to compiling this testbench into the                 --
--                DEADLINE LIBRARY.                                                           --
--                                                                                            --
-- LIMITATIONS    : N/A.                                                                      --
--                                                                                            --
-- ERRORS         : No known errors.                                                          --
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                      MODULE HISTORY                                        --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                                                                            --
-- VERSION  AUTHOR     DATE       COMMENTS                                                    --
--   0.0     D-D     30 Jan 22    - Created.                                                  --
--                                                                                            --
--           D-D     01 Feb 22    - Incorporated revised pre_scaler_srle_based(dynamic)       --
--                                  COMPONENT.                                                --
--                                                                                            --
--           D-D     04 Feb 22    - Incorporated revised pre_scaler_srle_based(dynamic)       --
--                                  COMPONENT.                                                --
--                                                                                            --
--           D-D     08 Feb 22    - Removed extra space character outside of right -- in      --
--                                  titleblock.                                               --
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                    LIBRARY UTILIZATION(S)                                  --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
  LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;
  USE IEEE.STD_LOGIC_UNSIGNED.ALL;
  
  LIBRARY DEADLINE;
  USE DEADLINE.ALL;
  USE DEADLINE.D_D_pkg.ALL;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                  ENTITY and ARCHITECTURE(S)                                --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
ENTITY pre_scaler_srle_based_TSTR IS
END pre_scaler_srle_based_TSTR;

ARCHITECTURE testbench1 OF pre_scaler_srle_based_TSTR IS
  ------------------------------
  -- COMPONENT DECLARATION(S) --
  ------------------------------
  COMPONENT pre_scaler_srle_based IS
  GENERIC (
           PRE_SCALE_SRL_DEPTH : INTEGER := 16
            );
  PORT    (
           i_clock               : IN  STD_LOGIC;
           i_enable              : IN  STD_LOGIC;
           i_pre_scale_div       : IN  STD_LOGIC_VECTOR((find_bit_width(PRE_SCALE_SRL_DEPTH-1)-1) DOWNTO 0);
           o_pre_scale_rate_tick : OUT STD_LOGIC
          );
  END COMPONENT;
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT tSYSCLKPER           : TIME := 20 nS;
  -------------
  -- SIGNALS --
  -------------
  SIGNAL sys_enable             : STD_LOGIC := '0';
  SIGNAL sys_clock              : STD_LOGIC := '0';
  SIGNAL sys_clock_prescale_div : STD_LOGIC_VECTOR((find_bit_width(SRLE16_MAX_DEPTH-1)-1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL sys_prescale_tick_rate : STD_LOGIC;

BEGIN

  SYSCLKGEN: sys_clock <= NOT(sys_clock) AFTER tSYSCLKPER/2;

  STIM: PROCESS
        BEGIN
           ----------------------------------
           -- INITIAL SRL FLUSHING OF 'U's --
           ----------------------------------
           WAIT FOR tSYSCLKPER * (SRLE16_MAX_DEPTH+1);       -- Wait
           ------------------------------------
           -- LOOP THROUGH POSSIBLE DIVISORS --
           ------------------------------------
           FOR INDEX IN 0 TO (SRLE16_MAX_DEPTH - 1) LOOP
              sys_enable <= '1';
              WAIT FOR (tSYSCLKPER * SRLE16_MAX_DEPTH * 20);        -- Wait to generate at least 20 clock enable ticks
              sys_enable <= '0';
              WAIT FOR tSYSCLKPER * (SRLE16_MAX_DEPTH+1);           -- Wait to flush
              sys_clock_prescale_div <= sys_clock_prescale_div + 1; -- Increment divisor
           END LOOP;
           --------------------
           -- END SIMULATION --
           --------------------
           ASSERT (FALSE)
           REPORT "END OF SIMULATION"
           SEVERITY FAILURE;
        END PROCESS;

------------------------------------------------------------------------------------------------
--                                  PRE-SCALER MODULES UNDER TEST                             --
------------------------------------------------------------------------------------------------
  PRESCALEUT: pre_scaler_srle_based GENERIC MAP (
                                                 PRE_SCALE_SRL_DEPTH => SRLE16_MAX_DEPTH
                                                )
                                       PORT MAP (
                                                 i_clock               => sys_clock,
                                                 i_enable              => sys_enable,
                                                 i_pre_scale_div       => sys_clock_prescale_div,
                                                 o_pre_scale_rate_tick => sys_prescale_tick_rate
                                                ); 

END testbench1;

-------------------------------------------- END OF CODE ---------------------------------------
