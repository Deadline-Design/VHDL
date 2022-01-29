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
-- DESIGN UNITS : srlce(dynamic)                                                              --
--                                                                                            --
-- FILE NAME    : srlce.vhd                                                                   --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide a generic depth and clock     --
--                edge definable LUT based shift register with additional max tap output      --
--                primitive that is inferred.                                                 --
--                                                                                            --
-- NOTE         : LUT based shift register primitives can be found in various Xilinx FPGA     --
--                families.                                                                   --
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
--                SRLINIT          - Initial value of SRL shift register. Typically all 0.    --
--                                   This emulates the initial value loaded during FPGA       --
--                                   configuration. It also helps avoid the all 'U's initial  --
--                                   state for simulation that would otherwise occur with     --
--                                   an unitialized SRL shift register.                       --
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
--                o_data         - Data output. As selected by i_tap_sel.                     --
--                                                                                            --
--                o_data_depth   - Data output. Maximum depth tap selected.                   --
--                                 Typicaly used for cascading, no output register capability --
--                                 within LUT.                                                --
--                                                                                            --
-- LIMITATIONS  : Current SRLCE primitives supported are SRLC16E and SRLC32E.                 --
--                                                                                            --
--                SRLDEPTH is the maximum depth of the actual SRL primitive. It does not      --
--                account for cases where the SRL has a flop input side or output side.       --
--                                                                                            --
--                Using an SRLTYPE other than "srl" when i_tap_sel is dynamic can result in   --
--                a synthesized design that behaves different than that simulated.            --
--                                                                                            --
--                SRLCE primitives have no reset mechanism outside of an initial state loaded --
--                when the FPGA is configured. Instead the equivalent of a reset is achieved  --
--                by creating a reset of sufficient duration and with the clock active so     --
--                that the SRLCE may be flushed and if desired loaded. The circuitry to       --
--                handle this is application dependent and so not provided within this design --
--                unit.                                                                       --
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
--   0.0     D-D     29 Jan 22    Created.                                                    --
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
  USE DEADLINE.D_D_pkg.ALL;

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                  ENTITY and ARCHITECTURE(S)                                --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

ENTITY srlce IS
GENERIC (
         CLOCK_POL_RISING : BOOLEAN := TRUE;
         SRLDEPTH         : INTEGER := 16;
         SRLTYPE          : STRING  := "srl";
         SRLINIT          : INTEGER := 0
        );
PORT    (
         i_clock        : IN  STD_LOGIC;
         i_clock_enable : IN  STD_LOGIC;
         i_tap_sel      : IN  STD_LOGIC_VECTOR((find_bit_width(SRLDEPTH-1)-1) DOWNTO 0);
         i_data         : IN  STD_LOGIC;
         o_data         : OUT STD_LOGIC;
         o_data_depth   : OUT STD_LOGIC
        );
END srlce;

ARCHITECTURE dynamic OF srlce IS
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT CLOCK_POLARITY : STD_LOGIC := boolean_to_std_logic(CLOCK_POL_RISING);
  -------------
  -- SIGNALS --
  -------------
  SIGNAL srl_shift_register : STD_LOGIC_VECTOR((DEPTH-1) DOWNTO 0) := CONV_STD_LOGIC_VECTOR(SRLINIT,SRLDEPTH);
  ----------------
  -- ATTRIBUTES --
  ----------------
  ATTRIBUTE SHREG_EXTRACT OF srl_shift_register : SIGNAL IS "yes";
  ATTRIBUTE SRL_STYLE OF srl_shift_register     : SIGNAL IS SRLTYPE;
BEGIN
  -----------------------
  -- VALID DEPTH CHECK --
  -----------------------
  ASSERT ((SRLDEPTH = 16) OR (SRLDEPTH = 32))
  REPORT "INVALID SRL DEPTH"
  SEVERITY FAILURE;
  ---------------------------
  -- VALID SRL STYLE CHECK --
  ---------------------------
  ASSERT ((SRLTYPE = "srl") OR (SRLTYPE = "reg_srl_reg") OR
          (SRLTYPE = "reg_srl") OR (SRLTYPE = "srl_reg"))
  REPORT "INVALID SRL STYLE"
  SEVERITY FAILURE;
  --------------------------
  -- VALID SRL INIT CHECK --
  --------------------------
  ASSERT ((SRLINIT >= 0) AND (SRLINIT < ((2**SRLDEPTH)-1)))
  REPORT "INVALID SRL INITIALIZATION VALUE"
  SEVERITY FAILURE;
  ----------------------
  -- SHIFT TAP OUTPUT --
  ----------------------
  SRLDYNOUT: o_data <= srl_shift_register(CONV_INTEGER(i_tap_sel));
  --------------------------
  -- MAX DEPTH TAP OUTPUT --
  --------------------------
  SRLMAXOUT: o_data_depth <= srl_shift_regster(depth-1);
  ------------------------------
  -- LUT BASED SHIFT REGISTER --
  ------------------------------
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
