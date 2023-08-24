# binaries
GAME_ID         := slps_018.30
GAME            := sakura
EXEC		:= SLPS_018.30

# compilers
CC              := ./bin/cc1-psx-26 -quiet

CROSS           := mips-linux-gnu-
AS              := $(CROSS)as
LD              := $(CROSS)ld
CPP             := $(CROSS)cpp
OBJCOPY         := $(CROSS)objcopy

AS_FLAGS        := -Iinclude -march=r3000 -mtune=r3000 -no-pad-sections -Os

CPP_FLAGS       = -undef -lang-c -Wall -fno-builtin -fsigned-char-Iinclude
CPP_FLAGS       += -Dmips -D__GNUC__=2 -D__OPTIMIZE__ -D__mips__ -D__mips -Dpsx -D__psx__ -D__psx -D_PSYQ -D__EXTENSIONS__ -D_MIPSEL -D_LANGUAGE_C -DLANGUAGE_C

CC_FLAGS        := -O2 -mips1 -mno-abicalls 

CHECK_WARNINGS  := -Wall -Wextra -Wno-format-security -Wno-unknown-pragmas -Wno-unused-parameter -Wno-unused-variable -Wno-missing-braces -Wno-int-conversion
CC_CHECK        := $(MODERN_GCC) -fsyntax-only -std=gnu90 -m32 $(CHECK_WARNINGS) $(CPP_FLAGS)

SDATA_LIMIT     := -G4
AS_SDATA_LIMIT  := -G0

# directories
ASM_DIR         := asm
SRC_DIR         := src
INCLUDE_DIR     := include
BUILD_DIR       := build
CONFIG_DIR      := config
TOOLS_DIR       := tools
DUMP_DIR	:= dump

#files
MAIN_ASM_DIRS   := $(ASM_DIR) $(ASM_DIR)/data
MAIN_SRC_DIR   := $(SRC_DIR)

MAIN_DIRS := $(MAIN_ASM_DIRS)
MAIN_DIRS += $(MAIN_SRC_DIR)

MAIN_S_FILES    := $(foreach dir,    $(MAIN_ASM_DIRS),     $(wildcard $(dir)/*.s)) \
                    $(foreach dir,    $(MAIN_ASM_DIRS),     $(wildcard $(dir)/**/*.s))
MAIN_C_FILES    := $(foreach dir,    $(MAIN_SRC_DIR),     $(wildcard $(dir)/*.c)) \
                    $(foreach dir,    $(MAIN_SRC_DIR),     $(wildcard $(dir)/**/*.c))
MAIN_O_FILES    := $(foreach file,    $(MAIN_S_FILES),     $(BUILD_DIR)/$(file).o) \
                    $(foreach file,    $(MAIN_C_FILES),     $(BUILD_DIR)/$(file).o)
MAIN_TARGET     := $(BUILD_DIR)/$(GAME_ID)

# tools
PYTHON          := python3
SPLAT_DIR       := $(TOOLS_DIR)/splat
SPLAT_APP       := $(SPLAT_DIR)/split.py
SPLAT           := $(PYTHON) $(SPLAT_APP)
ASMDIFFER_DIR   := $(TOOLS_DIR)/asm-differ
ASMDIFFER_APP   := $(ASMDIFFER_DIR)/diff.py
MASPSX_DIR      := $(TOOLS_DIR)/maspsx
MASPSX_APP      := $(MASPSX_DIR)/maspsx.py
MASPSX          := $(PYTHON) $(MASPSX_APP)
MASPSX_ARGS     := --expand-div --no-macro-inc

# macros
define list_src_files
		$(foreach dir, $(ASM_DIR),         $(wildcard $(dir)/**.s))
		$(foreach dir, $(ASM_DIR)/data,    $(wildcard $(dir)/**.s))
		$(foreach dir, $(SRC_DIR),         $(wildcard $(dir)/**.c))
endef

define list_o_files
		$(foreach file, $(call list_src_files), $(BUILD_DIR)/$(file).o)
endef

define link
		$(LD) -o $(2) \
			-Map $(BUILD_DIR)/$(1).map \
			-T $(1).ld \
			-T $(CONFIG_DIR)/symbols_addrs.$(1).txt \
			--no-check-sections \
			-nostdlib \
			-s
endef

# recipes
all: build check
build: sakura
clean:
		rm -rf build asm
format:
		clang-format -i $$(find $(SRC_DIR)/ -type f -name "*.c")
		clang-format -i $$(find $(INCLUDE_DIR)/ -type f -name "*.h")
check:
		sha1sum --check $(DUMP_DIR)/$(EXEC).sha
expected: check
		rm -rf expected/build
		cp -r build expected/build

$(GAME_ID).elf: $(MAIN_O_FILES)
		$(LD) -o $@ \
		-Map $(MAIN_TARGET).map \
		-T $(GAME).ld \
		-T $(CONFIG_DIR)/symbols_addrs.sakura1.txt \
		--no-check-sections \
		-nostdlib \
		-s

sakura: $(BUILD_DIR)/$(EXEC)
$(BUILD_DIR)/$(EXEC): $(BUILD_DIR)/$(EXEC).elf
		$(OBJCOPY) -O binary $(BUILD_DIR)/$(EXEC).elf $@
$(BUILD_DIR)/$(EXEC).elf: $(call list_o_files)
		$(call link,sakura1,$@)

dirs:
	$(foreach dir,$(MAIN_DIRS) ,$(shell mkdir -p $(BUILD_DIR)/$(dir)))

extract: dirs
		$(SPLAT) $(CONFIG_DIR)/$(GAME_ID).yaml

$(BUILD_DIR)/%.s.o: %.s
	$(AS) -Iinclude -march=r3000 -mtune=r3000 -no-pad-sections -Os -o $@ $<

$(BUILD_DIR)/%.bin.o: %.bin
	$(LD) -r -b binary -o -Map %.map $@ $<

$(BUILD_DIR)/%.c.o: %.c $(MASPSX_APP)
	@$(CC_CHECK) $<
	$(CPP) $(CPP_FLAGS) $< | $(CC) $(CC_FLAGS) $(SDATA_LIMIT) | $(MASPSX) $(MASPSX_ARGS) | $(AS) $(AS_SDATA_LIMIT) -o $@

SHELL = /bin/bash -e -o pipefail

.PHONY: all, clean, format, check, expected
.PHONY: sakura
.PHONY: extract
.PHONY: require-tools, update-dependencies
