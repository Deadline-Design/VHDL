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
-- DESIGN UNITS : asym_bram(full)                                                             --
--                                                                                            --
-- FILE NAME    : asym_bram.vhd                                                               --
--                                                                                            --
-- PURPOSE      : The purpose of this module is to provide an inferrable dual ported BRAM     --
--                memory primitive that supports asymetric data widths for both sides.        --
--                                                                                            --
-- NOTE         : BRAM primitives can be found in various Xilinx FPGA families.               --
--                                                                                            --
--                The module is based from a similar example module in the Xilinx User Guide, --
--                UG901, "Vivado Design Suite User Guide Synthesis".                          --
--                                                                                            --
--                This design unit does utilize certain elements contained within the         --
--                D_D_pkg PACKAGE (D_D_pkg.vhd). Be sure to compile the package into the      --
--                DEADLINE LIBRARY prior to compiling this design unit into the DEADLINE      --
--                LIBRARY.                                                                    --
--                                                                                            --
--                The ARCHITECTURE name, full, is referring to both sides each have full      --
--                read/write access to the shared memory.                                     --
--                                                                                            --
--                                     GENERIC DECLARATIONS                                   --
--                                                                                            --
--                WIDTHA         - A-SIDE data I/O width selection.                           --
--                                 1,2,4,8,16,32 supported. WIDTHA must always be <= WIDTHB.  --
--                                                                                            --
--                DEPTHA         - A-SIDE memory depth selection.                             --
--                                 DEPTHA must always be >= DEPTHB.                           --
--                                                                                            --
--                WIDTHB         - B-SIDE data I/O width selection.                           --
--                                 1,2,4,8,16,32 supported. WIDTHA must always be <= WIDTHB.  --
--                                                                                            --
--                DEPTHB         - B-SIDE memory depth selection.                             --
--                                 DEPTHA must always be >= DEPTHB.                           --
--                                                                                            --
--                USES_OUTREG    - Output register on data outputs selection.                 --
--                                                                                            --
--                USES_INIT_FILE - Memory initialization using a file selection.              --
--                                                                                            --
--                INIT_FILENAME  - Filename of file used to initialize memory (if applicable).--
--                                                                                            --
--                                      PORT DECLARATIONS                                     --
--                                                                                            --
--                i_clkA  - BRAM A-SIDE clock input.                                          --
--                                                                                            --
--                i_clkB  - BRAM B-SIDE clock input.                                          --
--                                                                                            --
--                i_enA   - BRAM A-SIDE enable input.                                         --
--                                                                                            --
--                i_enB   - BRAM B-SIDE enable input.                                         --
--                                                                                            --
--                i_weA   - BRAM A-SIDE write enable input.                                   --
--                                                                                            --
--                i_weB   - BRAM B-SIDE write enable input.                                   --
--                                                                                            --
--                i_rstA  - BRAM A-SIDE output register (synchronous) reset input.            --
--                                                                                            --
--                i_rstB  - BRAM B-SIDE output register (synchronous) reset input.            --
--                                                                                            --
--                i_addrA - BRAM A-SIDE address input.                                        --
--                                                                                            --
--                i_addrB - BRAM B-SIDE address input.                                        --
--                                                                                            --
--                i_diA   - BRAM A-SIDE data input.                                           --
--                                                                                            --
--                i_diB   - BRAM B-SIDE data input.                                           --
--                                                                                            --
--                o_doA   - BRAM A-SIDE data output.                                          --
--                                                                                            --
--                o_doB   - BRAM B-SIDE data output.                                          --
--                                                                                            --
-- LIMITATIONS  : ver1:                                                                       --
--                                                                                            --
--                At this time, only a single write enable for each side is supported.        --
--                Inidividual byte write enables are not supported.                           --
--                                                                                            --
--                At this time, data parity bits for each side are not supported.             --
--                                                                                            --
--                At this time, optional data output register selection applies to both sides.--
--                                                                                            --
--                At this time, WIDTHA x DEPTHA must equal WIDTHB x DEPTHB.                   --
--                                                                                            --
--                At this time, only READ before WRITE accessess are supported.               --
--                                                                                            --
--                The source for any of the inputs (if utilized) should be synchronous AND    --
--                also be synchronously reset. An asynchronous reset source will generate a   --
--                warning during the implementation phase for Xilinx targets.                 --
--                                                                                            --
--                The shared memory is created based upon the port with minimum width and     --
--                maximum depth. Due to this, and the manner in which the BRAM is inferred,   --
--                the A-side MUST be the side with minimum width and maximum depth. Doing     --
--                otherwise will produce a synthese failure because of mismatched port widths.--
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
--   0.0     D-D     25 Jan 22    - Created.                                                  --
--                                                                                            --
--           D-D     27 Jan 22    - Changed asym_dp_bram from a SIGNAL TYPE to a              --
--                                  SHARED VARIABLE. When a SIGNAL, and both sides use        --
--                                  then same clock, 'X's get written into asym_dp_bram.      --
--                                  The SHARED VARIABLE gets around this due to VARIABLE      --
--                                  behaving different than SIGNAL at the 'EVENT level.       --
--                                                                                            --
--           D-D     02 Feb 22    - Added synchronous reset capability to port output         --
--                                  registers (when utilized).                                --
--                                                                                            --
--           D-D     12 Oct 22    - Identified a limitation for which a work-around or        --
--                                  change/modification was not found despite multiple        --
--                                  attempts (synthesis would fail reporting an invalid BRAM  --
--                                  description/inference. DEPTH A MUST always be >= DEPTH B  --
--                                  and WIDTH A MUST always be <= WIDTH B. An assertion is    --
--                                  being added to catch this and fail if it is not the case. --
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
  USE STD.TEXTIO.ALL;
  
  LIBRARY DEADLINE;
  USE DEADLINE.ALL;
  USE DEADLINE.D_D_pkg.ALL;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                  ENTITY and ARCHITECTURE(S)                                --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
ENTITY asym_bram IS
GENERIC (
         WIDTHA         : INTEGER := 1;
         DEPTHA         : INTEGER := 16384;
         WIDTHB         : INTEGER := 32;
         DEPTHB         : INTEGER := 512;
         USES_OUTREG    : BOOLEAN := TRUE;
         USES_INIT_FILE : BOOLEAN := FALSE;
         INIT_FILENAME  : STRING   := ""
        );
PORT    (
         i_clkA  : IN  STD_LOGIC;
         i_clkB  : IN  STD_LOGIC;
         i_enA   : IN  STD_LOGIC;
         i_enB   : IN  STD_LOGIC;
         i_weA   : IN  STD_LOGIC;
         i_weB   : IN  STD_LOGIC;
         i_rstA  : IN  STD_LOGIC;
         i_rstB  : IN  STD_LOGIC;
         i_addrA : IN  STD_LOGIC_VECTOR((find_bit_width(DEPTHA-1) - 1) DOWNTO 0);
         i_addrB : IN  STD_LOGIC_VECTOR((find_bit_width(DEPTHB-1) - 1) DOWNTO 0);
         i_diA   : IN  STD_LOGIC_VECTOR((WIDTHA - 1) DOWNTO 0);
         i_diB   : IN  STD_LOGIC_VECTOR((WIDTHB - 1) DOWNTO 0);
         o_doA   : OUT STD_LOGIC_VECTOR((WIDTHA - 1) DOWNTO 0);
         o_doB   : OUT STD_LOGIC_VECTOR((WIDTHB - 1) DOWNTO 0)
        );
END asym_bram;

ARCHITECTURE full OF asym_bram IS
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT LATENTS    : INTEGER := 1 + boolean_to_integer(USES_OUTREG);
  CONSTANT minWIDTH   : INTEGER := min_int_A_B(WIDTHA, WIDTHB);
  CONSTANT maxWIDTH   : INTEGER := max_int_A_B(WIDTHA, WIDTHB);
  CONSTANT maxDEPTH   : INTEGER := max_int_A_B(DEPTHA, DEPTHB);
  CONSTANT WIDTHRATIO : INTEGER := maxWIDTH / minWIDTH;
  -----------
  -- TYPES --
  -----------
  -- Array size should always be configured by whichever side depth setting is
  -- largest.
  TYPE BRAMType IS ARRAY(0 TO (maxDEPTH - 1)) OF STD_LOGIC_VECTOR((minWIDTH) - 1 DOWNTO 0);
  ---------------
  -- FUNCTIONS --
  ---------------
  IMPURE FUNCTION MEMinit (mem_depth:INTEGER;mem_width:INTEGER;MEMinit_filename:String)RETURN BRAMType IS
  FILE MEMinit_File            : TEXT;
  VARIABLE MEMinit_file_status : FILE_OPEN_STATUS;
  VARIABLE MEMinit_File_Line   : LINE;
  VARIABLE MEMinit_vectors     : BRAMType;
  VARIABLE MEMinit_read_value  : BIT_VECTOR((mem_width-1) DOWNTO 0);
  VARIABLE MEMinit_index       : INTEGER := 0;
  BEGIN
     IF (USES_INIT_FILE )
     THEN -----------------------------------
          -- USE FILE TO INITIALIZE MEMORY --
          -----------------------------------
          FILE_OPEN (MEMinit_file_status,MEMinit_File,MEMinit_filename,read_mode);
          IF (MEMinit_file_status = OPEN_OK)
          THEN -----------------------------
               -- SUCCESSFUL FILE OPENING --
               -----------------------------
               WHILE (NOT(ENDFILE(MEMinit_file))) LOOP
                  IF (MEMinit_index = mem_depth)
                  THEN EXIT;
                  ELSE READLINE(MEMinit_File, MEMinit_File_Line);
                       READ(MEMinit_File_Line,MEMinit_read_value);
                       MEMinit_vectors(MEMinit_index) := TO_STDLOGICVECTOR(MEMinit_read_value);
                       READ(MEMinit_File_Line,MEMinit_read_value);
                       MEMinit_vectors(MEMinit_index+1) := TO_STDLOGICVECTOR(MEMinit_read_value);
                  END IF;
                  MEMinit_index := MEMinit_index + 2;
               END LOOP;
               WHILE (MEMinit_index < mem_depth) LOOP
                  MEMinit_vectors(MEMinit_index) := (OTHERS => '0');
                  MEMinit_index := MEMinit_index + 1;
               END LOOP;
          ELSE -------------------------------
               -- UNSUCCESSFUL FILE OPENING --
               -------------------------------
               REPORT "CANNOT OPEN MEMORY INITIALIZATION FILE"
               SEVERITY FAILURE;
          END IF;
          FILE_CLOSE(MEMinit_file);
     ELSE -------------------------------------------------
          -- USE DEFAULT ALL ZEROES TO INITIALIZE MEMORY --
          -------------------------------------------------
          MEMinit_vectors := (OTHERS => (OTHERS => '0'));
     END IF;
     RETURN MEMinit_vectors;
  END FUNCTION MEMinit;
  -------------
  -- SIGNALS --
  -------------
  SHARED VARIABLE asym_dp_bram : BRAMType := MEMinit(maxDEPTH,minWIDTH,INIT_FILENAME);
--SIGNAL asym_dp_bram : BRAMType := MEMinit(maxDEPTH,minWIDTH,INIT_FILENAME);
  SIGNAL readA        : STD_LOGIC_VECTOR((WIDTHA - 1) DOWNTO 0); -- := (OTHERS => '0');
  SIGNAL readB        : STD_LOGIC_VECTOR((WIDTHB - 1) DOWNTO 0); -- := (OTHERS => '0');
  SIGNAL regA         : STD_LOGIC_VECTOR((WIDTHA - 1) DOWNTO 0); -- := (OTHERS => '0');
  SIGNAL regB         : STD_LOGIC_VECTOR((WIDTHB - 1) DOWNTO 0); -- := (OTHERS => '0');
  ----------------
  -- ATTRIBUTES --
  ----------------
BEGIN
  ---------------------------------------------
  -- A-SIDE/B-SIDE DEPTH x WIDTH MATCH CHECK --
  ---------------------------------------------
  ASSERT ((DEPTHA*WIDTHA) = (DEPTHB*WIDTHB))
  REPORT "A-SIDE DEPTH x WIDTH / B-SIDE DEPTH x WIDTH MISMATCH"
  SEVERITY FAILURE;
  --------------------------------------------
  -- minWIDTH CORRESPONDS TO maxDEPTH CHECK --
  --------------------------------------------
  ASSERT (((maxDEPTH = DEPTHA) AND (minWIDTH = WIDTHA)) OR ((maxDEPTH = DEPTHB) AND (minWIDTH = WIDTHB)))
  REPORT "minWIDTH DOES NOT CORRESPOND TO SIDE THAT IS maxDEPTH"
  SEVERITY FAILURE;
  -------------------------------------------------------
  -- minWIDTH and maxDEPTH CORRESPONDS TO A-SIDE CHECK --
  -------------------------------------------------------
  ASSERT ((maxDEPTH = DEPTHA) AND (minWIDTH = WIDTHA))
  REPORT "minWIDTH AND maxDEPTH DO NOT CORRESPOND TO A-SIDE"
  SEVERITY FAILURE;
  -----------------------------------------------------------
  -- SYNCHRONOUS OUTPUT WITH NO ADDITIONAL OUTPUT REGISTER --
  -----------------------------------------------------------
  LATENT1: IF (LATENTS = 1) GENERATE
              PROCESS(i_clkA)
              BEGIN
                 IF RISING_EDGE(i_clkA)
                 THEN IF (i_enA = '1')
                      THEN readA <= asym_dp_bram(conv_integer(i_addrA));
                           IF (i_weA = '1')
                           THEN asym_dp_bram(conv_integer(i_addrA)) := i_diA;
--                              asym_dp_bram(conv_integer(i_addrA)) <= i_diA;
                           END IF;
                      END IF;
                 END IF;
              END PROCESS;
              PROCESS(i_clkB)
              BEGIN
                 IF RISING_EDGE(i_clkB)
                 THEN FOR index IN 0 TO (WIDTHRATIO - 1) LOOP
                         IF (i_enB = '1')
                         THEN readB(((index + 1) * minWIDTH - 1) DOWNTO (index * minWIDTH)) <= asym_dp_bram(CONV_INTEGER(i_addrB & CONV_STD_LOGIC_VECTOR(index,find_bit_width(WIDTHRATIO-1))));
                              IF (i_weB = '1')
                              THEN asym_dp_bram(CONV_INTEGER(i_addrB & CONV_STD_LOGIC_VECTOR(index,find_bit_width(WIDTHRATIO-1)))) := i_diB(((index + 1) * minWIDTH - 1) DOWNTO (index * minWIDTH));
--                                 asym_dp_bram(CONV_INTEGER(i_addrB & CONV_STD_LOGIC_VECTOR(index,find_bit_width(WIDTHRATIO-1)))) <= i_diB(((index + 1) * minWIDTH - 1) DOWNTO (index * minWIDTH));
                              END IF;
                         END IF;
                      END LOOP;
                 END IF;
              END PROCESS;
              o_doA <= readA; --regA;
              o_doB <= readB; --regB;
           END GENERATE;
  --------------------------------------------------------
  -- SYNCHRONOUS OUTPUT WITH ADDITIONAL OUTPUT REGISTER --
  --------------------------------------------------------
  LATENT2: IF (LATENTS = 2) GENERATE
              PROCESS(i_clkA)
              BEGIN
                 IF RISING_EDGE(i_clkA)
                 THEN IF (i_enA = '1')
                      THEN readA <= asym_dp_bram(conv_integer(i_addrA));
                           IF (i_weA = '1')
                           THEN asym_dp_bram(conv_integer(i_addrA)) := i_diA;
--                              asym_dp_bram(conv_integer(i_addrA)) <= i_diA;
                           END IF;
                      END IF;
                      IF (i_rstA = '1')
                      THEN regA <= (OTHERS => '0');
                      ELSE regA <= readA;
                      END IF;
                 END IF;
              END PROCESS;
              PROCESS(i_clkB)
              BEGIN
                 IF RISING_EDGE(i_clkB)
                 THEN FOR index IN 0 TO (WIDTHRATIO - 1) LOOP
                         IF (i_enB = '1')
                         THEN readB(((index + 1) * minWIDTH - 1) DOWNTO (index * minWIDTH)) <= asym_dp_bram(CONV_INTEGER(i_addrB & CONV_STD_LOGIC_VECTOR(index,find_bit_width(WIDTHRATIO-1))));
                              IF (i_weB = '1')
                              THEN asym_dp_bram(CONV_INTEGER(i_addrB & CONV_STD_LOGIC_VECTOR(index,find_bit_width(WIDTHRATIO-1)))) := i_diB(((index + 1) * minWIDTH - 1) DOWNTO (index * minWIDTH));
--                                 asym_dp_bram(CONV_INTEGER(i_addrB & CONV_STD_LOGIC_VECTOR(index,find_bit_width(WIDTHRATIO-1)))) <= i_diB(((index + 1) * minWIDTH - 1) DOWNTO (index * minWIDTH));
                              END IF;
                         END IF;
                      END LOOP;
                      IF (i_rstB = '1')
                      THEN regB <= (OTHERS => '0');
                      ELSE regB <= readB;
                      END IF;
                 END IF;
              END PROCESS;
              o_doA <= regA;
              o_doB <= regB;
           END GENERATE;
END full;
-------------------------------------------- END OF CODE ---------------------------------------
