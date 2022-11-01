------------------------------------------------------------------------------------------------
--                                        DEADLINE-DESIGN                                     --
--                                    www.deadline-design.com                                 --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This software representation and its inclusive documentation are provided AS-IS and with   --
-- all faults; is without warranty expressed or implied, including but not limited to,        --
-- warranties of merchantability or fitness for a particular purpose.                         --
--                                                                                            --
-- All trademarks are the property of their respective owners.                                --
--                                                                                            --
-- CONTACT      : support@deadline-design.com                                                 --
--                                                                                            --
-- DESIGN UNITS : gray_counter_TSTR(testbench1)                                               --
--                                                                                            --
-- FILE NAME    : gray_counter_TSTR.vhd                                                       --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide a very simplistic testbench   --
--                for the pgray_counter_TSTR(dynamic) design unit.                            --
--                                                                                            --
-- NOTE         : This testbench does utilize certain elements contained within the           --
--                D_D_pkg PACKAGE (D_D_pkg.vhd). Be sure to compile the package into the      --
--                DEADLINE LIBRARY prior to compiling this testbench into the DEADLINE        --
--                LIBRARY.                                                                    --
--                                                                                            --
--                This testbench does utilize the gray_count_bit(ver1) primitive              --
--                (gray_count_bit.vhd). Be sure to compile the primitive into the             --
--                DEADLINE LIBRARY prior to compiling this testbench into the                 --
--                DEADLINE LIBRARY.                                                           --
--                                                                                            --
--                This testbench does utilize the gray_counter(ver1) counter                  --
--                (gray_counter.vhd). Be sure to compile the peripheral into the              --
--                DEADLINE LIBRARY prior to compiling this testbench into the                 --
--                DEADLINE LIBRARY.                                                           --
--                                                                                            --
-- LIMITATIONS  : N/A.                                                                        --
--                                                                                            --
-- ERRORS       : No known errors.                                                            --
--                                                                                            --
-- GENERIC                                                                                    --
-- DECLARATIONS : N/A.                                                                        --
--                                                                                            --
-- PORT                                                                                       --
-- DECLARATIONS : N/A.                                                                        --
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                      MODULE HISTORY                                        --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                                                                            --
-- VERSION  AUTHOR     DATE       COMMENTS                                                    --
--   0.0     D-D     09 Feb 22    - Created.                                                  --
--                                                                                            --
--           D-D     01 Nov 22    - Titleblock refinements.                                   --
--                                - Adjustments to accommodate revised gray_counter COMPONENT.--
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                    LIBRARY UTILIZATION(S)                                  --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
  LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;
  
  LIBRARY DEADLINE;
  USE DEADLINE.ALL;
  USE DEADLINE.D_D_pkg.ALL;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                  ENTITY and ARCHITECTURE(S)                                --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
ENTITY gray_counter_TSTR IS
END gray_counter_TSTR;

ARCHITECTURE testbench1 OF gray_counter_TSTR IS
  ------------------------------
  -- COMPONENT DECLARATION(S) --
  ------------------------------
  COMPONENT gray_counter IS
  GENERIC (
           CLOCK_POLARITY : STD_LOGIC := '1';
           WIDTH          : INTEGER := 2
          );
  PORT    (
           i_reset        : IN  STD_LOGIC;
           i_clock        : IN  STD_LOGIC;
           i_count_enable : IN  STD_LOGIC;
           o_gray_count   : OUT STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0)
          );
  END COMPONENT;
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT tSYSCLKPER         : TIME := 20 nS;
  CONSTANT GRAY_COUNTER_WIDTH : INTEGER := 6;
  -------------
  -- SIGNALS --
  -------------
  SIGNAL sys_reset      : STD_LOGIC := '1';
  SIGNAL sys_enable     : STD_LOGIC := '0';
  SIGNAL sys_clock      : STD_LOGIC := '0';
  SIGNAL sys_gray_count : STD_LOGIC_VECTOR((GRAY_COUNTER_WIDTH-1) DOWNTO 0);
BEGIN

  SYSCLKGEN: sys_clock <= NOT(sys_clock) AFTER tSYSCLKPER/2;

  STIM: PROCESS
        BEGIN
           WAIT FOR tSYSCLKPER * GRAY_COUNTER_WIDTH;     -- Wait
           WAIT UNTIL FALLING_EDGE(sys_clock);
           sys_reset <= '0';                             -- De-assert reset

           WAIT FOR tSYSCLKPER * GRAY_COUNTER_WIDTH;     -- Wait
           WAIT UNTIL FALLING_EDGE(sys_clock);
           sys_enable <= '1';                            -- Assert count enable

           WAIT FOR  tSYSCLKPER * 4 *(2**(GRAY_COUNTER_WIDTH+1)); -- Wait (cycle through 4X's)

           WAIT FOR tSYSCLKPER * GRAY_COUNTER_WIDTH;     -- Wait
           WAIT UNTIL FALLING_EDGE(sys_clock);
           sys_enable <= '0';                            -- De-assert count enable

           WAIT FOR tSYSCLKPER * GRAY_COUNTER_WIDTH;     -- Wait
           WAIT UNTIL FALLING_EDGE(sys_clock);
           sys_reset <= '1';                             -- Assert reset

           WAIT FOR tSYSCLKPER * GRAY_COUNTER_WIDTH;     -- Wait

           --------------------
           -- END SIMULATION --
           --------------------
           ASSERT (FALSE)
           REPORT "END OF SIMULATION"
           SEVERITY FAILURE;
        END PROCESS;

------------------------------------------------------------------------------------------------
--                                  GRAY COUNTER MODULES UNDER TEST                           --
------------------------------------------------------------------------------------------------
  GRAYCNTUT: gray_counter GENERIC MAP (
                                       CLOCK_POLARITY => '1',
                                       WIDTH          => GRAY_COUNTER_WIDTH
                                      )
                             PORT MAP (
                                       i_reset        => sys_reset,
                                       i_clock        => sys_clock,
                                       i_count_enable => sys_enable,
                                       o_gray_count   => sys_gray_count
                                      );

END testbench1;

-------------------------------------------- END OF CODE ---------------------------------------
