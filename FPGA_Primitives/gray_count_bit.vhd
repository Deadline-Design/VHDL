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
-- DESIGN UNITS : gray_count_bit(ver1)                                                        --
--                                                                                            --
-- FILE NAME    : gray_count_bit.vhd                                                          --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide a single gray counter bit     --
--                primitive that is easily cascadable for GENERIC width gray counters.        --
--                                                                                            --
-- NOTE         : The design unit is based from a paper in Proceedings of the Student FEI     --
--                2000, Brno 2000, "Gray counter in VHDL" by Ivo Viscor                       --
--                                                                                            --
-- LIMITATIONS  : Port signal name prefixes denote direction. As applicable:                  --
--                'i_' for input, 'o_' for output, and 'io_' for bidirectional.               --
--                                                                                            --
--                Port signal direction type BUFFER is avoided as some establishments frown   --
--                upon its use.                                                               --
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
--                BIT_IS_LSb       - Gray counter bit is LSb. Used to support the LSb being   --
--                                   reset to '1' as opposed to '0' for all other bits and    --
--                                   simply unconditionally toggle (so long as count is       --
--                                   enabled).                                                --
--                                                                                            --
--                BIT_IS_MSb       - Gray counter bit is MSb. Used to support the MSb being   --
--                                   fed back and OR'd with the adjacent lower count bit.     --
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
--                i_q            - Q from adjacent lower bit.                                 --
--                                                                                            --
--                i_z            - Z from adjacent lower bit.                                 --
--                                                                                            --
--                o_q            - Q (gray count) (when not LSb).                             --
--                                                                                            --
--                o_z            - Cascade Z.                                                 --
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
ENTITY gray_count_bit IS
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
END gray_count_bit;

ARCHITECTURE ver1 OF gray_count_bit IS
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT RESET_VALUE    : STD_LOGIC := boolean_to_std_logic(BIT_IS_LSb);
  -------------
  -- SIGNALS --
  -------------
  SIGNAL toggle_flop : STD_LOGIC;
  ----------------
  -- ATTRIBUTES --
  ----------------
BEGIN
  -------------------------------------------------------
  -- CHECK BIT_IS_LSb AND BIT_IS_MSb ARE NOT BOTH TRUE --
  -------------------------------------------------------
  ASSERT (NOT(BIT_IS_LSb AND BIT_IS_MSb))
  REPORT "BIT_IS_LSb AND BIT_IS_MSb CANNOT BOTH BE SET TRUE"
  SEVERITY FAILURE;
  ------------------
  -- Q-BIT OUTPUT --
  ------------------
  NEWQ: o_q <= toggle_flop;
  ------------------
  -- Z-BIT OUTPUT --
  ------------------
  NEWZ: o_z <= (i_z AND NOT(i_q));
  ----------------------
  -- TOGGLE FLIP FLOP --
  ----------------------
  TFF: PROCESS(i_clock)
       BEGIN
          IF ((i_clock'EVENT) AND (i_clock = CLOCK_POLARITY))
          THEN IF (i_reset = '1')
               THEN toggle_flop <= RESET_VALUE;
               ELSIF (i_count_enable = '1')
                  THEN IF (BIT_IS_LSb = TRUE)
                       THEN toggle_flop <= NOT(toggle_flop);
                       ELSIF (BIT_IS_MSb = TRUE)
                       THEN IF (((i_q = '1') OR (toggle_flop = '1')) AND (i_z = '1'))
                            THEN toggle_flop <= NOT(toggle_flop);
                            END IF;
                       ELSE IF ((i_q = '1') AND (i_z = '1'))
                            THEN toggle_flop <= NOT(toggle_flop);
                            END IF;
                       END IF;
               END IF;
          END IF;
       END PROCESS;

END ver1;
-------------------------------------------- END OF CODE ---------------------------------------
