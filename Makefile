TARGET := h8rom.bin
ORIG_ROM := 64DD_Dev_H8_3294_970717.rom
BUILD_DIR := build

CPP := cpp

CROSS := h8300-none-elf-

AS      := $(CROSS)as
LD      := $(CROSS)ld
OBJCOPY := $(CROSS)objcopy

ROM := $(BUILD_DIR)/$(TARGET)
ELF := $(ROM:.bin=.elf)
MAP := $(ROM:.bin=.map)

CPPFLAGS :=
ASFLAGS :=
LDFLAGS :=

SRC_DIRS := $(shell find src -type d)
S_FILES  := $(foreach d,$(SRC_DIRS),$(wildcard $d/*.s))
O_FILES  := $(foreach f,$(S_FILES:.s=.o),$(BUILD_DIR)/$f)

# Create build directories
$(shell mkdir -p $(foreach d,$(SRC_DIRS),$(BUILD_DIR)/$d))

.PHONY: all check clean
all: check

clean:
	$(RM) -r $(BUILD_DIR)

check: $(ROM)
	@cmp $(ROM) $(ORIG_ROM) && echo "$(ROM) OK"

$(ROM): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(ELF): $(O_FILES) h8.ld
	$(LD) $(LDFLAGS) -T h8.ld $(O_FILES) -Map $(MAP) -o $@

$(BUILD_DIR)/%.o: %.s
	$(CPP) -undef $(CPPFLAGS) $< | $(AS) $(ASFLAGS) -o $@
