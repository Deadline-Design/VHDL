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
-- DESIGN UNITS : srle(dynamic)                                                               --
--                                                                                            --
-- FILE NAME    : srle.vhd                                                                    --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide a generic depth and clock     --
--                edge definable LUT based shift register primitive that is inferred.         --
--                                                                                            --
-- NOTE         : LUT based shift register primitives can be found in various Xilinx FPGA     --
--                families.                                                                   --
--                                                                                            --
--                LUT based shift registers shift in LSb first.                               --
--                                                                                            --
--                The design unit is based from a similar example design unit in the Xilinx   --
--                User Guide, UG901, "Vivado Design Suite User Guide Synthesis".              --
--                                                                                            --
--                This design unit does utilize certain elements contained within the         --
--                D_D_pkg PACKAGE (D_D_pkg.vhd). Be sure to compile the package into the      --
--                DEADLINE LIBRARY prior to compiling this design unit into the DEADLINE      --
--                LIBRARY.                                                                    --
--                                                                                            --
--                                     GENERIC DECLARATIONS                                   --
--                                                                                            --
--                CLOCK_POL_RISING - Clock polarity rising (TRUE) or falling (FALSE).         --
--                                                                                            --
--                SRLDEPTH         - SRL (maximum) depth. 16 or 32 supported.                 --
--                                                                                            --
--                SRLTYPE          - SRL arrangement. SRL, REG->SRL, SRL->REG, REG->SRL->REG. --
--                                                                                            --
--                SRLINIT          - (hex) string of values to initialize SRL with.           --
--                                                                                            --
--                                      PORT DECLARATIONS                                     --
--                                                                                            --
--                i_clock        - Global clock input.                                        --
--                                                                                            --
--                i_clock_enable - Clock enable/shift enable input.                           --
--                                                                                            --
--                i_tap_sel      - Data output tap select input.                              --
--                                                                                            --
--                i_data         - Data input.                                                --
--                                                                                            --
--                o_data         - Data output.                                               --
--                                                                                            --
-- LIMITATIONS  : Current SRLE primitives supported are SRL16E and SRL32E.                    --
--                                                                                            --
--                SRLDEPTH is the maximum depth of the actual SRL primitive. It does not      --
--                account for cases where the SRL has a flop input side or output side.       --
--                                                                                            --
--                Using an SRLTYPE other than "srl" when i_tap_sel is dynamic can result in   --
--                a synthesized design that behaves different than that simulated.            --
--                                                                                            --
--                SRLE primitives have no reset mechanism outside of an initial state loaded  --
--                when the FPGA is configured. Instead the equivalent of a reset is achieved  --
--                by creating a reset of sufficient duration and with the clock active so     --
--                that the SRLE may be flushed and if desired loaded. The circuitry to handle --
--                this is application dependent and so not provided within this design unit.  --
--                                                                                            --
-- ERRORS       : No known errors.                                                            --
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                      REVISION LIST                                         --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                                                                            --
-- VERSION  AUTHOR     DATE       COMMENTS                                                    --
--   0.0     D-D     29 Jan 22    - Created.                                                  --
--                                                                                            --
--           D-D     01 Feb 22    - Changed SRLINIT GENERIC from INTEGER to STRING. The       --
--                                  maximum INTEGER supported by VHDL is 2^31-1 and makes it  --
--                                  unsuitable for some cases. A string of values gets        --
--                                  converted and utilized instead for the initial value of   --
--                                  the LUT based shift register.                             --
--                                - Added an INIT ATTRIBUTE to the LUT based shift register   --
--                                  LABEL. This permits the tools to recognize the desired    --
--                                  initial value during synthesis & implementation.          --
--                                - Changed the valid depth check ASSERT statement to simply  --
--                                  check depth is a multiple of 16.                          --
--                                - Added a valid INIT string size check                      --
--                                  (to equal SRL DEPTH X 4) ASSERT statement.                --
--                                                                                            --
--           D-D      08 Feb 22   - Corrected valid init string size check REPORT, X 4 should --
--                                  be on the init string.                                    --
--                                                                                            --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                    LIBRARY UTILIZATION                                     --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
  LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;
  USE IEEE.STD_LOGIC_ARITH.ALL;
  USE IEEE.STD_LOGIC_UNSIGNED.ALL;
  
  LIBRARY DEADLINE;
  USE DEADLINE.ALL;
  USE DEADLINE.D_D_pkg.ALL;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                  ENTITY and ARCHITECTURE(S)                                --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

ENTITY srle IS
GENERIC (
         CLOCK_POL_RISING : BOOLEAN := TRUE;
         SRLDEPTH         : INTEGER := 16;
         SRLTYPE          : STRING  := "srl";
         SRLINIT          : STRING  := "0000"
        );
PORT    (
         i_clock        : IN  STD_LOGIC;
         i_clock_enable : IN  STD_LOGIC;
         i_tap_sel      : IN  STD_LOGIC_VECTOR((find_bit_width(SRLDEPTH-1)-1) DOWNTO 0);
         i_data         : IN  STD_LOGIC;
         o_data         : OUT STD_LOGIC
        );
END srle;

ARCHITECTURE dynamic OF srle IS
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT CLOCK_POLARITY : STD_LOGIC := boolean_to_std_logic(CLOCK_POL_RISING);
  -------------
  -- SIGNALS --
  -------------
  SIGNAL srl_shift_register : STD_LOGIC_VECTOR((SRLDEPTH-1) DOWNTO 0) := hex_string_to_std_logic_vector(SRLINIT,SRLDEPTH);
  ----------------
  -- ATTRIBUTES --
  ----------------
  ATTRIBUTE SHREG_EXTRACT OF srl_shift_register : SIGNAL IS "yes";
  ATTRIBUTE SRL_STYLE OF srl_shift_register     : SIGNAL IS SRLTYPE;
  ATTRIBUTE INIT OF DYNAMICSRL                  : LABEL IS  SRLINIT;
BEGIN
  ----------------------------------
  -- VALID INIT STRING SIZE CHECK --
  ----------------------------------
  ASSERT ((SRLINIT'HIGH*4) = SRLDEPTH)
  REPORT "SRL INIT STRING LENGTH X 4 DOES NOT MATCH SRL DEPTH"
  SEVERITY FAILURE;
  -----------------------
  -- VALID DEPTH CHECK --
  -----------------------
  ASSERT ((SRLDEPTH MOD 16)=0)
  REPORT "SRL DEPTH NOT A MULTIPLE OF 16"
  SEVERITY FAILURE;
  ---------------------------
  -- VALID SRL STYLE CHECK --
  ---------------------------
  ASSERT ((SRLTYPE = "srl") OR (SRLTYPE = "reg_srl_reg") OR
          (SRLTYPE = "reg_srl") OR (SRLTYPE = "srl_reg"))
  REPORT "INVALID SRL STYLE"
  SEVERITY FAILURE;
  ----------------------
  -- SHIFT TAP OUTPUT --
  ----------------------
  SRLDYNOUT: o_data <= srl_shift_register(CONV_INTEGER(i_tap_sel));
  ---------------------------------------------------
  -- LUT BASED SHIFT REGISTER (SHIFT IN LSb FIRST) --
  ---------------------------------------------------
  DYNAMICSRL: PROCESS(i_clock)
              BEGIN
                 IF ((i_clock'EVENT) AND (i_clock = CLOCK_POLARITY))
                 THEN IF (i_clock_enable = '1')
                      THEN srl_shift_register <= srl_shift_register((SRLDEPTH-2) DOWNTO 0) & i_data;
                      END IF;
                 END IF;
              END PROCESS;

END dynamic;
-------------------------------------------- END OF CODE ---------------------------------------
