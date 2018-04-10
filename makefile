# Alpe
# Makefile setup template for ARM architecture, HF

############################################################################
# Settings for toolchain
TOOLCHAIN_PREFIX = arm-none-eabi-
TOOLCHAIN_C_COMPILER   = $(TOOLCHAIN_PREFIX)gcc
TOOLCHAIN_SIZE   = $(TOOLCHAIN_PREFIX)size
TOOLCHAIN_COPY   = $(TOOLCHAIN_PREFIX)objcopy
TOOLCHAIN_ASM   = $(TOOLCHAIN_PREFIX)gcc -x assembler-with-cpp
############################################################################

############################################################################
# Settings Assembly startup & Linker file
STARTUP  = startup_project.S
LINKER_SCRIPT = linker_project.ld
############################################################################

############################################################################
# Settings for global C defines
DEFINES = -D__FPU_PRESENT
############################################################################

############################################################################
# Settings for user C sources
SRC	= ./src/main.c
SRC	+= ./src/system.c

############################################################################
# Settings for user library sources	[OPTIONAL]

 
############################################################################

############################################################################
# Settings for CMSIS Library sources [OPTIONAL]
#SRC	+= ./Libraries/DSP_Lib/Source/CommonTables/arm_common_tables.c
#SRC	+= ./Libraries/DSP_Lib/Source/BasicMathFunctions/arm_mult_f32.c
#SRC	+= ./Libraries/DSP_Lib/Source/BasicMathFunctions/arm_sub_f32.c
#SRC	+= ./Libraries/DSP_Lib/Source/BasicMathFunctions/arm_add_f32.c
#SRC	+= ./Libraries/DSP_Lib/Source/BasicMathFunctions/arm_offset_f32.c
#SRC	+= ./Libraries/DSP_Lib/Source/ControllerFunctions/arm_sin_cos_f32.c
#SRC	+= ./Libraries/DSP_Lib/Source/StatisticsFunctions/arm_power_f32.c
#SRC	+= ./Libraries/DSP_Lib/Source/StatisticsFunctions/arm_rms_f32.c
#SRC	+= ./Libraries/DSP_Lib/Source/SupportFunctions/arm_q31_to_q15.c
#SRC	+= ./Libraries/DSP_Lib/Source/SupportFunctions/arm_q15_to_q31.c


############################################################################

############################################################################
# Settings for MCU HAL/BSP Library sources [OPTIONAL]
HAL_BSP_LIBDIR = ./Libraries/HAL_BSP/src/

SRC	+= $(HAL_BSP_LIBDIR)acmp.c
SRC	+= $(HAL_BSP_LIBDIR)bccu.c
SRC	+= $(HAL_BSP_LIBDIR)common.c
SRC	+= $(HAL_BSP_LIBDIR)dma.c
SRC	+= $(HAL_BSP_LIBDIR)ebu.c
SRC	+= $(HAL_BSP_LIBDIR)eru.c
SRC	+= $(HAL_BSP_LIBDIR)eth_mac.c
SRC	+= $(HAL_BSP_LIBDIR)gpio.c
SRC	+= $(HAL_BSP_LIBDIR)hrpwm.c
SRC	+= $(HAL_BSP_LIBDIR)i2c.c
SRC	+= $(HAL_BSP_LIBDIR)ledts.c
SRC	+= $(HAL_BSP_LIBDIR)math.c
SRC	+= $(HAL_BSP_LIBDIR)pau.c
SRC	+= $(HAL_BSP_LIBDIR)prng.c
SRC	+= $(HAL_BSP_LIBDIR)rtc.c
SRC	+= $(HAL_BSP_LIBDIR)spi.c
SRC	+= $(HAL_BSP_LIBDIR)uart.c
SRC	+= $(HAL_BSP_LIBDIR)usbd.c
SRC	+= $(HAL_BSP_LIBDIR)wdt.c
############################################################################






############################################################################
# Include directories
INCLUDE_DIR  += ./inc
INCLUDE_DIR  += ./Libraries/BSP_HAL/inc
INCLUDE_DIR  += ./Libraries/Include

INCLUDE_DIR  += ./flash/inc
INCLUDE_DIR  += ./adc/inc
INCLUDE_DIR  += ./eth/inc

############################################################################

############################################################################
# Precompiled Libraries like .a [OPTIONAL]
#PRECOMPILED_LIBRARY_DIR = 
#PRECOMPILED_LIBRARY_DIR += 
############################################################################

############################################################################
INCLUDE_DIRS  = $(patsubst %,-I%, $(INCLUDE_DIR))
PRECOMPILED_LIBRARY_DIRS  = $(patsubst %,-L%, $(PRECOMPILED_LIBRARY_DIR))
############################################################################

############################################################################
# Settings for output
OUT_NAME = project
HEX  = $(TOOLCHAIN_COPY) -O ihex
BIN  = $(TOOLCHAIN_COPY) -O binary -S
OBJECTS  = $(STARTUP:.S=.o) $(SRC:.c=.o)
############################################################################

############################################################################
# Settings for MCU
MCU_FAMILY  = cortex-m4
MCU_FLAGS = -mcpu=$(MCU_FAMILY) -mfpu=fpv4-sp-d16 -mfloat-abi=hard

OPTIMIZATION = -O0
C_COMPILER_FLAGS = $(MCU_FLAGS) $(OPTIMIZATION) -g -gdwarf-2 -mthumb   -fomit-frame-pointer -Wall -Wstrict-prototypes -fverbose-asm -Wa,-ahlms=$(<:.c=.lst) $(DEFINES)
ASM_FLAGS = $(MCU_FLAGS) -g -gdwarf-2 -mthumb  -Wa,-amhls=$(<:.S=.lst)
LINKER_FLAGS = $(MCU_FLAGS) -lm -g -gdwarf-2 -mthumb -nostartfiles -lgcc -T$(LINKER_SCRIPT) -Wl,-Map=$(OUT_NAME).map,--cref,--no-warn-mismatch $(PRECOMPILED_LIBRARY_DIRS) 
############################################################################



############################################################################
# Makefile rules

all: $(OBJECTS) $(OUT_NAME).elf $(OUT_NAME).hex $(OUT_NAME).bin $(OUT_NAME).size

%.o: %.c
	$(TOOLCHAIN_C_COMPILER) -c $(C_COMPILER_FLAGS) -I . $(INCLUDE_DIRS) $< -o $@

%.o: %.S
	$(TOOLCHAIN_ASM) -c $(ASM_FLAGS) $< -o $@
	
%elf: $(OBJECTS)
	$(TOOLCHAIN_C_COMPILER) $(OBJECTS) $(LINKER_FLAGS) $(PRECOMPILED_LIBRARY_DIRS) -o $@

%hex: %elf
	$(HEX) $< $@
	
%bin: %elf
	$(BIN)  $< $@

%size: %size
	$(TOOLCHAIN_SIZE) --format=berkeley $(OUT_NAME).elf
	
clean:
	-rm -rf $(OBJECTS)
	-rm -rf $(OUT_NAME).elf
	-rm -rf $(OUT_NAME).map
	-rm -rf $(OUT_NAME).hex
	-rm -rf $(OUT_NAME).bin
	-rm -rf $(OUT_NAME).siz
	-rm -rf $(STARTUP).lst	
	-rm -rf $(SRC:.c=.lst)
	-rm -rf $(ASRC:.s=.lst)
############################################################################