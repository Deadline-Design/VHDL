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
-- DESIGN UNITS : D_D_pkg                                                                     --
--                                                                                            --
-- FILE NAME    : D_D_pkg.vhd                                                                 --
--                                                                                            --
-- PURPOSE      : The purpose of this design unit is provide a location for commonly used     --
--                CONSTANTS, TYPES, ATTRIBUTES, FUNCTIONS, etc. which may be utilized across  --
--                various VHDL design unit(s).                                                --
--                                                                                            --
-- NOTE         : N/A.                                                                        --
--                                     GENERIC DECLARATIONS                                   --
--                                                                                            --
--                                      PORT DECLARATIONS                                     --
--                                                                                            --
-- LIMITATIONS  : N/A.                                                                        --
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
--           D-D     01 Feb 22    - Added INIT ATTRIBUTE.                                     --
--                                - Added FUNCTION hex_string_to_std_logic_vector()           --
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
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                            PACKAGE                                         --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

PACKAGE D_D_pkg IS
  ---------------------------------------
  -- IMPLEMENTATION RELATED ATTRIBUTES --
  ---------------------------------------
  ATTRIBUTE IOB                  : STRING;  -- Xilinx attribute
  ATTRIBUTE SHREG_EXTRACT        : STRING;  -- Xilinx attribute
  ATTRIBUTE SRL_STYLE            : STRING;  -- Xilinx attribute
  ATTRIBUTE opt_mode             : STRING;  -- Xilinx attribute
  ATTRIBUTE opt_level            : STRING;  -- Xilinx attribute
  ATTRIBUTE register_balancing   : STRING;  -- Xilinx attribute
  ATTRIBUTE register_duplication : STRING;  -- Xilinx attribute
  ATTRIBUTE RAM_STYLE            : STRING;  -- Xilinx attribute
  ATTRIBUTE ROM_STYLE            : STRING;  -- Xilinx attribute
  ATTRIBUTE DONT_TOUCH           : BOOLEAN; -- Xilinx attribute
  ATTRIBUTE INIT                 : STRING;  -- Xilinx attribute
  ---------------
  -- FUNCTIONS --
  ---------------
  FUNCTION find_next_mult_of_16(input:INTEGER) RETURN INTEGER;
  FUNCTION find_bit_width(input:INTEGER) RETURN INTEGER;
  FUNCTION boolean_to_std_logic(input: BOOLEAN) RETURN STD_LOGIC;
  FUNCTION boolean_to_integer(input: BOOLEAN) RETURN INTEGER;
  FUNCTION min_int_A_B(A,B:INTEGER) RETURN INTEGER;
  FUNCTION max_int_A_B(A,B:INTEGER) RETURN INTEGER;
  FUNCTION hex_string_to_std_logic_vector(init:STRING;width:INTEGER) RETURN STD_LOGIC_VECTOR;
  FUNCTION SRLEn_gen_hex_INIT_string(init:CHARACTER;width:INTEGER) RETURN STRING;
  ---------------
  -- CONSTANTS --
  ---------------
  CONSTANT SRLE16_MAX_DEPTH   : INTEGER := 16; -- Xilinx SRLE16 max-depth
  CONSTANT SRLE32_MAX_DEPTH   : INTEGER := 32; -- Xilinx SRLE32 max-depth
END D_D_pkg;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--                                              BODY                                          --
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
PACKAGE BODY D_D_pkg IS
------------------------------------------------------------------------------------------------
--                                BOOLEAN TO STD_LOGIC CONVERSION                             --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function converts a BOOLEAN input (TRUE/FALSE) into a STD_LOGIC value ('1'/'0').      --
-- It is used for example in selecting a clock polarity.                                      --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION boolean_to_std_logic(input: BOOLEAN) return STD_LOGIC IS
VARIABLE x : STD_LOGIC;
BEGIN
   IF (input = TRUE)
   THEN x := '1';
   ELSE x := '0';
   END IF;
   RETURN x;
END FUNCTION boolean_to_std_logic;

------------------------------------------------------------------------------------------------
--                                      BOOLEAN TO INTEGER                                    --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function converts a BOOLEAN input (TRUE/FALSE) into an INTEGER (1/0).                 --
-- It is used for example in selecting a clock latency values.                                --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION boolean_to_integer(input: BOOLEAN) return INTEGER IS
VARIABLE x : INTEGER := 0;
BEGIN
   IF (input = TRUE)
   THEN x := 1;
   END IF;
   RETURN x;
END FUNCTION boolean_to_integer;

------------------------------------------------------------------------------------------------
--                                         FIND BIT WIDTH                                     --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function provides a simple mechanism to identify the width (number of bit positions)  --
-- needed to support the input (in integer form).                                             --
--                                                                                            --
-- It is not intended for direct synthesis.                                                   --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION find_bit_width(input:INTEGER) return INTEGER IS
VARIABLE temp : INTEGER := input;
VARIABLE y    : INTEGER := 1;
BEGIN
   WHILE (temp > 1) LOOP
      temp := temp/2;
      y  := y + 1;
   END LOOP;
   RETURN y;
END FUNCTION find_bit_width;

------------------------------------------------------------------------------------------------
--                                     FINE NEXT MULTIPLE OF 16                               --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function provides a simple mechanism to identify the next largest multiple of 16      --
-- integer greater than or equal to the input.                                                --
--                                                                                            --
-- It is not intended for direct synthesis.                                                   --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION find_next_mult_of_16(input:INTEGER) return INTEGER IS
VARIABLE temp : INTEGER := input;
VARIABLE y    : INTEGER := 16;
BEGIN
   WHILE (temp > y) LOOP
      y:= y+16;
   END LOOP;
   RETURN y;
END FUNCTION find_next_mult_of_16;

------------------------------------------------------------------------------------------------
--                                   FIND MINIMUM OF TWO INTEGERS                             --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function provides a simple mechanism to find the lessor (or minimum) of two integers  --
-- A, B.                                                                                      --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION min_int_A_B(A,B:INTEGER) return INTEGER IS
VARIABLE temp : INTEGER := A;
BEGIN
   IF (B < temp)
   THEN temp := B;
   END IF;
   RETURN temp;
END FUNCTION min_int_A_B;

------------------------------------------------------------------------------------------------
--                                   FIND MINIMUM OF TWO INTEGERS                             --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function provides a simple mechanism to find the greater (or maximum) of two integers --
-- A, B.                                                                                      --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION max_int_A_B(A,B:INTEGER) return INTEGER IS
VARIABLE temp : INTEGER := A;
BEGIN
   IF (B > temp)
   THEN temp := B;
   END IF;
   RETURN temp;
END FUNCTION max_int_A_B;

------------------------------------------------------------------------------------------------
--                            CONVERT HEX STRING TO STD_LOGIC_VECTOR                          --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function provides simple converstion of a (hex)string to a std_logic_vector           --
-- equivalent value.                                                                          --
--                                                                                            --
-- The hex string must only contain valid hex characters: 0-9,A-F,a-f. If an invalid character--
-- is encountered, the function simply returns all zeroes.                                    --
--                                                                                            --
-- Supports the width being less than the length(init)*4.                                     --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION hex_string_to_std_logic_vector(init:STRING;width:INTEGER) RETURN STD_LOGIC_VECTOR IS
VARIABLE init_vector : STD_LOGIC_VECTOR((max_int_A_B(width,(init'HIGH*4))-1) DOWNTO 0) := (OTHERS => '0');
VARIABLE init_char   : CHARACTER := '0';
VARIABLE init_int    : INTEGER   := 0;
BEGIN
   FOR index IN (init'HIGH) DOWNTO 1 LOOP
      init_char := init(index);
      CASE init_char IS
      WHEN '0' => init_int := 0;
      WHEN '1' => init_int := 1;
      WHEN '2' => init_int := 2;
      WHEN '3' => init_int := 3;
      WHEN '4' => init_int := 4;
      WHEN '5' => init_int := 5;
      WHEN '6' => init_int := 6;
      WHEN '7' => init_int := 7;
      WHEN '8' => init_int := 8;
      WHEN '9' => init_int := 9;
      WHEN 'A'|'a' => init_int := 10;
      WHEN 'B'|'b' => init_int := 11;
      WHEN 'C'|'c' => init_int := 12;
      WHEN 'D'|'d' => init_int := 13;
      WHEN 'E'|'e' => init_int := 14;
      WHEN 'F'|'f' => init_int := 15;
      WHEN OTHERS  => init_vector := (OTHERS => '0');
                      RETURN init_vector((width-1) DOWNTO 0);
      END CASE;
      init_vector((((init'HIGH-index)*4)+3) DOWNTO ((init'HIGH-index)*4)) := CONV_STD_LOGIC_VECTOR(init_int,4);
   END LOOP;
   RETURN init_vector((width-1) DOWNTO 0);
END FUNCTION hex_string_to_std_logic_vector;

------------------------------------------------------------------------------------------------
--                            CONVERT HEX STRING TO STD_LOGIC_VECTOR                          --
------------------------------------------------------------------------------------------------
--                                                                                            --
-- This function generates a hex string for an SRLE INIT string.                              --
--                                                                                            --
-- The the init character must be any valid hex character: 0-9,A-F,a-f. If the init           --
-- character is invalid it returns all zeroes.                                                --
--                                                                                            --
-- The width must be a multiple of 16 for SRLE INITs and will ASSERT FAILURE if not.          --
--                                                                                            --
------------------------------------------------------------------------------------------------
FUNCTION SRLEn_gen_hex_INIT_string(init:CHARACTER;width:INTEGER) RETURN STRING IS
VARIABLE init_size   : INTEGER := width/4;
VARIABLE init_string : STRING(1 TO init_size);
BEGIN
   ASSERT ((width MOD 16) = 0)
   REPORT "INPUT WIDTH IS NOT A MULTIPLE OF 16"
   SEVERITY FAILURE;
   FOR index IN 1 TO init_size LOOP
      CASE init IS
      WHEN '0' => init_string(index) := init;
      WHEN '1' => init_string(index) := init;
      WHEN '2' => init_string(index) := init;
      WHEN '3' => init_string(index) := init;
      WHEN '4' => init_string(index) := init;
      WHEN '5' => init_string(index) := init;
      WHEN '6' => init_string(index) := init;
      WHEN '7' => init_string(index) := init;
      WHEN '8' => init_string(index) := init;
      WHEN '9' => init_string(index) := init;
      WHEN 'A'|'a' => init_string(index) := 'A';
      WHEN 'B'|'b' => init_string(index) := 'B';
      WHEN 'C'|'c' => init_string(index) := 'C';
      WHEN 'D'|'d' => init_string(index) := 'D';
      WHEN 'E'|'e' => init_string(index) := 'E';
      WHEN 'F'|'f' => init_string(index) := 'F';
      WHEN OTHERS  => init_string(index) := '0'; 
      END CASE;
   END LOOP;
   RETURN init_string;
END FUNCTION SRLEn_gen_hex_INIT_string;

END;
-------------------------------------------- END OF CODE ---------------------------------------