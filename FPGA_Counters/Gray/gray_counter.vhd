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
-- DESIGN UNITS : gray_counter(ver1)                                                          --
--                                                                                            --
-- FILE NAME    : gray_counter.vhd                                                            --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide a gray counter that supports  --
--                GENERIC selectable counter WIDTH.                                           --
--                                                                                            --
-- NOTE         : Port signal name prefixes denote direction. As applicable:                  --
--                'i_' for input, 'o_' for output, and 'io_' for bidirectional.               --
--                                                                                            --
--                Port signal direction type BUFFER is avoided as some establishments frown   --
--                upon its use.                                                               --
--                                                                                            --
--                The design unit is based from a paper in Proceedings of the Student FEI     --
--                2000, Brno 2000, "Gray counter in VHDL" by Ivo Viscor                       --
--                                                                                            --
--                This design unit does utilize certain elements contained within the         --
--                D_D_pkg PACKAGE (D_D_pkg.vhd). Be sure to compile the package into the      --
--                DEADLINE LIBRARY prior to compiling this design unit into the DEADLINE      --
--                LIBRARY.                                                                    --
--                                                                                            --
--                This design unit does utilize the gray_count_bit(ver1) primitive            --
--                (gray_count_bit.vhd). Be sure to compile the primitive into the             --
--                DEADLINE LIBRARY prior to compiling this design unit into the               --
--                DEADLINE LIBRARY.                                                           --
--                                                                                            --
-- LIMITATIONS  : Minimum GENERIC WIDTH supported is 2.                                       --
--                                                                                            --
--                The Z cascading can have impact on performance.                             --
--                                                                                            --
-- ERRORS       : No known errors.                                                            --
--                                                                                            --
-- GENERIC                                                                                    --
-- DECLARATIONS :                                                                             --
--                                                                                            --
--                CLOCK_POLARITY   - Selector '1'(RISING)/'0'(FALLING) for clock polarity.    --
--                                                                                            --
--                WIDTH            - Gray counter width.                                      --
--                                                                                            --
-- PORT                                                                                       --
-- DECLARATIONS :                                                                             --
--                                                                                            --
--                i_reset        - (Synchronous) reset.                                       --
--                                                                                            --
--                i_clock        - Clock.                                                     --
--                                                                                            --
--                i_count_enable - Count enable.                                              --
--                                                                                            --
--                o_gray_count   - Gray counter count.                                        --
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                      REVISION LIST                                         --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                                                                            --
-- VERSION  AUTHOR     DATE       COMMENTS                                                    --
--   0.0     D-D     09 Feb 22    - Created.                                                  --
--                                                                                            --
--           D-D     01 Nov 22    - Titleblock refinements.                                   --
--                                - Adjustments to accommodate revised gray_count_bit         --
--                                  COMPONENT.                                                --
--                                - Changed CLOCK_POL_RISING BOOLEAN GENERIC to               --
--                                  CLOCK_POLARITY STD_LOGIC GENERIC. Removed CLOCK_POLARITY  --
--                                  CONSTANT.                                                 --
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                    LIBRARY UTILIZATION                                     --
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

ENTITY gray_counter IS
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
END gray_counter;

ARCHITECTURE ver1 OF gray_counter IS
  ------------------------------
  -- COMPONENT DECLARATION(S) --
  ------------------------------
  COMPONENT gray_count_bit IS
  GENERIC (
           CLOCK_POLARITY : STD_LOGIC := '1';
           BIT_IS_LSb     : BOOLEAN := TRUE;
           BIT_IS_MSb     : BOOLEAN := FALSE
          );
  PORT    (
           i_reset        : IN  STD_LOGIC;
           i_clock        : IN  STD_LOGIC;
           i_count_enable : IN  STD_LOGIC;
           i_q            : IN  STD_LOGIC;
           i_z            : IN  STD_LOGIC;
           o_q            : OUT STD_LOGIC;
           o_z            : OUT STD_LOGIC
          );
  END COMPONENT;
  ---------------
  -- CONSTANTS --
  ---------------
  -------------
  -- SIGNALS --
  -------------
  SIGNAL q_bits : STD_LOGIC_VECTOR(WIDTH DOWNTO 0);
  SIGNAL z_bits : STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0);
  ----------------
  -- ATTRIBUTES --
  ----------------
BEGIN
  ------------------------------------
  -- VALID GRAY COUNTER WIDTH CHECK --
  ------------------------------------
  ASSERT (WIDTH >= 2)
  REPORT " INSUFFICIENT GRAY COUNTER WIDTH"
  SEVERITY FAILURE;
  -------------------------------
  -- GRAY COUNTER COUNT OUTPUT --
  -------------------------------
  GRAYCNTROUT: o_gray_count <= q_bits(WIDTH DOWNTO 1);
  ---------------------------------------------------------------------
  -- TOGGLE FLIP FLOP (NOT USED AS ACTUAL PART OF GRAY COUNT OUTPUT) --
  ---------------------------------------------------------------------
  GRAYCNTTOGGLR: gray_count_bit GENERIC MAP (
                                             CLOCK_POLARITY => CLOCK_POLARITY,
                                             BIT_IS_LSb     => TRUE,
                                             BIT_IS_MSb     => FALSE
                                            )
                                   PORT MAP (
                                             i_reset        => i_reset,
                                             i_clock        => i_clock,
                                             i_count_enable => i_count_enable,
                                             i_q            => '0',
                                             i_z            => '1',
                                             o_q            => q_bits(0),
                                             o_z            => z_bits(0)
                                            );
  ------------------
  -- GRAY COUNTER --
  ------------------
  GRAYCNTR: FOR index IN 1 TO (WIDTH-1) GENERATE
  GRAYCNTRi:   gray_count_bit GENERIC MAP (
                                           CLOCK_POLARITY => CLOCK_POLARITY,
                                           BIT_IS_LSb     => FALSE,
                                           BIT_IS_MSb     => FALSE
                                          )
                                 PORT MAP (
                                           i_reset        => i_reset,
                                           i_clock        => i_clock,
                                           i_count_enable => i_count_enable,
                                           i_q            => q_bits(index-1),
                                           i_z            => z_bits(index-1),
                                           o_q            => q_bits(index),
                                           o_z            => z_bits(index)
                                          );
            END GENERATE;
  GRAYCNTRMSb: gray_count_bit GENERIC MAP (
                                           CLOCK_POLARITY => CLOCK_POLARITY,
                                           BIT_IS_LSb     => FALSE,
                                           BIT_IS_MSb     => TRUE
                                          )
                                 PORT MAP (
                                           i_reset        => i_reset,
                                           i_clock        => i_clock,
                                           i_count_enable => i_count_enable,
                                           i_q            => q_bits(WIDTH-1),
                                           i_z            => z_bits(WIDTH-1),
                                           o_q            => q_bits(WIDTH),
                                           o_z            => OPEN
                                          );
END ver1;
-------------------------------------------- END OF CODE ---------------------------------------
