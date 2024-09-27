OUTPUT_ARCH(h8300)
ENTRY(INTHANDLER_COMMON)

SECTIONS {

    .text 0 : {
        *(.text*)
    }

    .bss 0x8000 (NOLOAD) : {
        *(.bss)
    }
}
