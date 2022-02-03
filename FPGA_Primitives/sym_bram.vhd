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
-- DESIGN UNITS : sym_bram(full)                                                              --
--                                                                                            --
-- FILE NAME    : sym_bram.vhd                                                                --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is to provide an an inferrable dual ported  --
--                BRAM memory primitive that supports symetric data widths for both sides.    --
--                                                                                            --
-- NOTE         : BRAM primitives can be found in various Xilinx FPGA families.               --
--                                                                                            --
--                The design unit is based from a similar example design unit in the Xilinx   --
--                User Guide, UG901, "Vivado Design Suite User Guide Synthesis".              --
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
--                WIDTH          - A/B-SIDE data I/O width selection.                         --
--                                 1,2,4,8,16,32 supported.                                   --
--                                                                                            --
--                DEPTH          - A/B-SIDE memory depth selection.                           --
--                                 DEPTHA x WIDTHA.                                           --
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
-- LIMITATIONS  : At this time, only a single write enable for each side is supported.        --
--                Inidividual byte write enables are not supported.                           --
--                                                                                            --
--                At this time, data parity bits for each side are not supported.             --
--                                                                                            --
--                At this time, optional data output register selection applies to both sides.--
--                                                                                            --
--                At this time, only READ before WRITE accessess are supported.               --
--                                                                                            --
--                The source for any of the inputs (if utilized) should be synchronous AND    --
--                also be synchronously reset. An asynchronous reset source will generate a   --
--                warning during the implementation phase for Xilinx targets.                 --
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
--           D-D     27 Jan 22    - Changed dp_bram from a SIGNAL TYPE to a                   --
--                                  SHARED VARIABLE. When a SIGNAL, and both sides use        --
--                                  then same clock, 'X's get written into dp_bram.           --
--                                  The SHARED VARIABLE gets around this due to VARIABLE      --
--                                  behaving different than SIGNAL at the 'EVENT level.       --
--                                                                                            --
--           D-D     03 Feb 22    - Added synchronous reset capability to port output         --
--                                  registers (when utilized).                                --
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
ENTITY sym_bram IS
GENERIC (
         DEPTH          : INTEGER := 16384;
         WIDTH          : INTEGER := 32;
         USES_OUTREG    : BOOLEAN := TRUE;
         USES_INIT_FILE : BOOLEAN := FALSE;
         INIT_FILENAME  : STRING  := ""
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
         i_addrA : IN  STD_LOGIC_VECTOR((find_bit_width(DEPTH-1) - 1) DOWNTO 0);
         i_addrB : IN  STD_LOGIC_VECTOR((find_bit_width(DEPTH-1) - 1) DOWNTO 0);
         i_diA   : IN  STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
         i_diB   : IN  STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
         o_doA   : OUT STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
         o_doB   : OUT STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0)
        );
END sym_bram;

ARCHITECTURE full OF sym_bram IS
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT LATENTS    : INTEGER := 1 + boolean_to_integer(USES_OUTREG);
  -----------
  -- TYPES --
  -----------
  -- Array size should always be configured by whichever side depth setting is
  -- largest.
  TYPE BRAMType IS ARRAY(0 TO (DEPTH - 1)) OF STD_LOGIC_VECTOR((WIDTH) - 1 DOWNTO 0);
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
  SHARED VARIABLE dp_bram : BRAMType := MEMinit(DEPTH,WIDTH,INIT_FILENAME);
--SIGNAL dp_bram : BRAMType := MEMinit(DEPTH,WIDTH,INIT_FILENAME);
  SIGNAL readA   : STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
  SIGNAL readB   : STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
  SIGNAL regA    : STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
  SIGNAL regB    : STD_LOGIC_VECTOR((WIDTH - 1) DOWNTO 0);
  ----------------
  -- ATTRIBUTES --
  ----------------
BEGIN
  -----------------------------------------------------------
  -- SYNCHRONOUS OUTPUT WITH NO ADDITIONAL OUTPUT REGISTER --
  -----------------------------------------------------------
  LATENT1: IF (LATENTS = 1) GENERATE
              PROCESS(i_clkA)
              BEGIN
                 IF RISING_EDGE(i_clkA)
                 THEN IF (i_enA = '1')
                      THEN readA <= dp_bram(conv_integer(i_addrA));
                           IF (i_weA = '1')
                           THEN dp_bram(conv_integer(i_addrA)) := i_diA;
--                              dp_bram(conv_integer(i_addrA)) <= i_diA;
                           END IF;
                      END IF;
                 END IF;
              END PROCESS;
              PROCESS(i_clkB)
              BEGIN
                 IF RISING_EDGE(i_clkB)
                 THEN IF (i_enB = '1')
                      THEN readB <= dp_bram(CONV_INTEGER(i_addrB));
                           IF (i_weB = '1')
                           THEN dp_bram(CONV_INTEGER(i_addrB)) := i_diB;
--                              dp_bram(CONV_INTEGER(i_addrB)) <= i_diB;
                           END IF;
                      END IF;
                 END IF;
              END PROCESS;
              o_doA <= readA;
              o_doB <= readB;
           END GENERATE;
  --------------------------------------------------------
  -- SYNCHRONOUS OUTPUT WITH ADDITIONAL OUTPUT REGISTER --
  --------------------------------------------------------
  LATENT2: IF (LATENTS = 2) GENERATE
              PROCESS(i_clkA)
              BEGIN
                 IF RISING_EDGE(i_clkA)
                 THEN IF (i_enA = '1')
                      THEN readA <= dp_bram(conv_integer(i_addrA));
                           IF (i_weA = '1')
                           THEN dp_bram(conv_integer(i_addrA)) := i_diA;
--                              dp_bram(conv_integer(i_addrA)) <= i_diA;
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
                 THEN IF (i_enB = '1')
                      THEN readB <= dp_bram(CONV_INTEGER(i_addrB));
                           IF (i_weB = '1')
                           THEN dp_bram(CONV_INTEGER(i_addrB)) := i_diB;
--                              dp_bram(CONV_INTEGER(i_addrB)) <= i_diB;
                           END IF;
                      END IF;
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
