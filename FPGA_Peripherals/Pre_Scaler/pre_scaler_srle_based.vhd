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
-- DESIGN UNITS : pre_scaler_srle_based(dynamic)                                              --
--                                                                                            --
-- FILE NAME    : pre_scaler_srle_based_.vhd                                                  --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide a minimal footprint yet       --
--                somewhat flexible multi-use clock enable tick based clock pre-scaler.       --
--                Every attempt is made at inferring functionality as opposed to              --
--                instantiating functionality to permit easier portability.                   --
--                                                                                            --
-- NOTE         : This design unit utilizes the LUT based shift register primitive where      --
--                possible for a more efficient footprint. The primitive can be found in      --
--                various Xilinx FPGA families.                                               --
--                                                                                            --
--                This design unit does utilize certain elements contained within the         --
--                D_D_pkg PACKAGE (D_D_pkg.vhd). Be sure to compile the package into the      --
--                DEADLINE LIBRARY prior to compiling this design unit into the DEADLINE      --
--                LIBRARY.                                                                    --
--                                                                                            --
--                This design unit does utilize the srle(dynamic) primitive (srle.vhd).       --
--                Be sure to compile the primitive into the DEADLINE LIBRARY prior to         --
--                compiling this design unit into the DEADLINE LIBRARY.                       --
--                                                                                            --
--                                     GENERIC DECLARATIONS                                   --
--                                                                                            --
--                  PRE_SCALE_SRL_DEPTH - Pre-scale divider LUT based SRL depth.              --
--                                        Ideally this should be 16 or 32 to permit single    --
--                                        primitive instantion. However a multiple of 16      --
--                                        that is greater than 32 is possible.                --
--                                                                                            --
--                  PRE_SCALE_SRL_INIT  - Pre-scale LUT based SRL initialization string.      --
--                                                                                            --
--                                      PORT DECLARATIONS                                     --
--                                                                                            --
--                  i_clock               - Global clock input.                               --
--                                                                                            --
--                  i_enable              - Pre-scaler module enable input.                   --
--                                                                                            --
--                  i_pre_scale_div       - Pre-scale divide clock enable tick rate input.    --
--                                          The divide rate is i_pre_scale_div + 1.           --
--                                          It may be set statically, or can be dynamic       --
--                                          (so long as it is properly flushed prior to the   --
--                                          dynamic change.                                   --
--                                                                                            --
--                  o_pre_scale_rate_tick - Pre-scale divided clock enable tick output.       --
--                                                                                            --
-- LIMITATIONS    : The SRL LUT shift register is permanently clock enabled. This permits a   --
--                  simpler meachanism for flushing when the pre-scaler module is disabled.   --
--                                                                                            --
--                  In order to properly flush the SRL based shift registers, i_enable must   --
--                  be de-asserted for no less thant pre_scale_srl_depth + 1 clock cycles.    --
--                                                                                            --
--                  If i_pre_scale_div is utilized(adjusted) dynamically, be sure to first    --
--                  flush the SRL LUT shift register using i_enable, prior to making the      --
--                  change and re-asserting i_enable.                                         --
--                                                                                            --
--                  Ensure that the PRE_SCALE_SRL_DEPTH GENERIC value is a multiple of 16 so  --
--                  that it is compatible with SRL LUT based shift register depths.           --
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
--           D-D     01 Feb 22    - Incorporated revised srle(dynamic) COMPONENT.             --
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
ENTITY pre_scaler_srle_based IS
GENERIC (
         PRE_SCALE_SRL_DEPTH : INTEGER := 16;
         PRE_SCALE_SRL_INIT  : STRING  := SRLEn_gen_hex_INIT_string('0',16)
        );
PORT    (
         i_clock               : IN  STD_LOGIC;
         i_enable              : IN  STD_LOGIC;
         i_pre_scale_div       : IN  STD_LOGIC_VECTOR((find_bit_width(PRE_SCALE_SRL_DEPTH-1)-1) DOWNTO 0);
         o_pre_scale_rate_tick : OUT STD_LOGIC
        );
END pre_scaler_srle_based;

ARCHITECTURE dynamic OF pre_scaler_srle_based IS
  ------------------------------
  -- COMPONENT DECLARATION(S) --
  ------------------------------
  COMPONENT srle IS
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
  END COMPONENT;
  ---------------
  -- CONSTANTS --
  ---------------
  -------------
  -- SIGNALS --
  -------------
  SIGNAL enable_dly          : STD_LOGIC; -- Pre-scaler enable delay
  SIGNAL srl_pre_scale       : STD_LOGIC; -- Pre-scaler SRL output
  SIGNAL srl_pre_scale_token : STD_LOGIC; -- Pre-scaler SRL input token
  ----------------
  -- ATTRIBUTES --
  ----------------
BEGIN
------------------------------------------------------------------------------------------------
--                                PRE-SCALER RATE GENERATION                                  --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- i_enable when de-asserted should be de-asserted for a minimum of clocks equal to the       --
-- pre_scale_srl_depth + 1 to ensure proper flushing. When asserted, the pre-scaler is active --
-- and output clock enable ticks are generated at the divide rate of the input clock.         --
--                                                                                            --
-- i_pre_scale_div is the clock divider value. Specifically the divider rate is equal to      --
-- i_pre_scale_div + 1. If i_pre_scale_div is to be utilized dynamically, it is important to  --
-- flush the SRL based shift register prior to making any change to the divider value.        --
-- i_enable should be de-asserted long enough to flush the SRL based shift register, then     --
-- i_pre_scale_div may be changed, followed by re-asserting i_enable to commence generation of--
-- the pre-scaler rate tick/pulses at the new divider value rate.                             --
--                                                                                            --
-- srl_pre_scale_token is a simple gate which permits the SRL based shift register to be      --
-- flushed when the pre-scaler is disabled and also permits it to be loaded with a single     --
-- initial '1' pulse when i_enable transitions from de-asserted to asserted.                  --
--                                                                                            --
-- o_pre_scale_rate_tick is a simple single clock wide pulse (or tick) with a rate at the     --
-- pre-scaler divide rate as set by i_pre_scale_div. De-assertion of i_enable is utilized to  --
-- synchronously put o_pre_scale_rate_tick in the inactive reset state and thereby stop       --
-- output/generation of pre-scaler rate tick/pulses.                                          --
--                                                                                            --
------------------------------------------------------------------------------------------------
  ---------------------------------
  -- PRE-SCALER RATE TICK OUTPUT --
  ---------------------------------
  PRESCALEOUT: PROCESS(i_clock)
               BEGIN
                  IF RISING_EDGE(i_clock)
                  THEN IF (i_enable = '0')
                       THEN o_pre_scale_rate_tick <= '0';
                       ELSE o_pre_scale_rate_tick <= srl_pre_scale;
                       END IF;
                  END IF;
               END PROCESS;
  --------------------------------------------------------
  -- ONE CLOCK ENABLE DELAY FOR DEASSERT EDGE DETECTION --
  --------------------------------------------------------
  PRESCALEENADLY: PROCESS(i_clock)
                  BEGIN
                     IF RISING_EDGE(i_clock)
                     THEN enable_dly <= i_enable;
                     END IF;
                  END PROCESS;
  -----------------------------------
  -- PRE-SCALE DIVIDER INPUT TOKEN --
  -----------------------------------
  PRESCALETOKEN: srl_pre_scale_token <= ((srl_pre_scale AND enable_dly) OR -- Normal loopback
                                         (i_enable AND NOT(enable_dly)));  -- Initial token
  ------------------------------------------------
  -- PRE-SCALE DIVIDER SRL BASED SHIFT REGISTER --
  ------------------------------------------------
  PRESCALEGEN: srle GENERIC MAP (
                                 CLOCK_POL_RISING => TRUE,
                                 SRLDEPTH         => PRE_SCALE_SRL_DEPTH,
                                 SRLTYPE          => "srl",
                                 SRLINIT          => PRE_SCALE_SRL_INIT
                                )
                       PORT MAP (
                                 i_clock        => i_clock,
                                 i_clock_enable => '1',
                                 i_tap_sel      => i_pre_scale_div,
                                 i_data         => srl_pre_scale_token,
                                 o_data         => srl_pre_scale
                                );
END dynamic;
-------------------------------------------- END OF CODE ---------------------------------------
