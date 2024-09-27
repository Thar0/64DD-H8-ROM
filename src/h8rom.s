/**
 * Memory map (MODE 2):
 * [0000:7FFF]  Mask ROM
 *  [0000:004A] Vector Table
 * [8000:FB80]  External Address Space
 * [FB80:FF7F]  RAM (1024 bytes)
 * [FF80:FF87]  External Address Space
 * [FF88:FFFF]  Registers
 */

/* H8 CCR Register */
#define CCR_I  (1 << 7) // Interrupt mask bit
#define CCR_UI (1 << 6) // User bit or interrupt mask bit
#define CCR_H  (1 << 5) // Half-carry flag
#define CCR_U  (1 << 4) // User bit
#define CCR_N  (1 << 3) // Negative flag
#define CCR_Z  (1 << 2) // Zero flag
#define CCR_V  (1 << 1) // Overflow flag
#define CCR_C  (1 << 0) // Carry flag


/* ASIC_STATUS bits */
#define ASIC_STATUS_DISK_CHANGE         ( 0-0) // 0x00010000
#define ASIC_STATUS_MECHANIC_ERROR      ( 1-0) // 0x00020000
#define ASIC_STATUS_WRITE_PROTECT_ERROR ( 2-0) // 0x00040000
#define ASIC_STATUS_HEAD_RETRACTED      ( 3-0) // 0x00080000
#define ASIC_STATUS_MOTOR_NOT_SPINNING  ( 4-0) // 0x00100000
#define ASIC_STATUS_UNK_BM              ( 5-0) // 0x00200000
#define ASIC_STATUS_RESETTING           ( 6-0) // 0x00400000
#define ASIC_STATUS_BUSY                ( 7-0) // 0x00800000
#define ASIC_STATUS_DISK_PRESENT        ( 8-8) // 0x01000000
#define ASIC_STATUS_MECHANIC_INTR       ( 9-8) // 0x02000000
#define ASIC_STATUS_BM_INTR             (10-8) // 0x04000000
#define ASIC_STATUS_BM_ERROR            (11-8) // 0x08000000
#define ASIC_STATUS_C2_XFER             (12-8) // 0x10000000
#define ASIC_STATUS_DATA_REQ            (14-8) // 0x40000000

/* ERROR_STATUS bits */
#define ERROR_STATUS_0                              ( 0-0) // DIAGNOSTIC_FAIL ?
#define ERROR_STATUS_NO_REFERENCE_POSITION_FOUND    ( 1-0)
#define ERROR_STATUS_DRIVE_NOT_READY                ( 2-0)
#define ERROR_STATUS_NO_SEEK_COMPLETE               ( 3-0)
#define ERROR_STATUS_INVALID_CMD                    ( 4-0)
#define ERROR_STATUS_INVALID_ARG                    ( 5-0)

.macro glabel label
    .global \label
    \label:
.endm

glabel VECTOR_TABLE
    .word INTHANDLER_COMMON /* RESET   */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word INTHANDLER_COMMON /* NMI     */
    .word INTHANDLER_COMMON /* IRQ0    */
    .word INTHANDLER_COMMON /* IRQ1    */
    .word IRQ2_HANDLER      /* IRQ2    */ /* Connected to the SD29L */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word INTHANDLER_COMMON /* ICIA    */
    .word INTHANDLER_COMMON /* ICIB    */
    .word INTHANDLER_COMMON /* ICIC    */
    .word INTHANDLER_COMMON /* ICID    */
    .word OCIA_HANDLER      /* OCIA    */ /* Possibly RTC related? */
    .word INTHANDLER_COMMON /* OCIB    */
    .word INTHANDLER_COMMON /* FOVI    */
    .word INTHANDLER_COMMON /* CMI0A   */
    .word INTHANDLER_COMMON /* CMI0B   */
    .word INTHANDLER_COMMON /* OVI0    */
    .word INTHANDLER_COMMON /* CMI1A   */
    .word INTHANDLER_COMMON /* CMI1B   */
    .word INTHANDLER_COMMON /* OVI1    */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word INTHANDLER_COMMON /* ERI     */
    .word INTHANDLER_COMMON /* RXI     */
    .word INTHANDLER_COMMON /* TXI     */
    .word INTHANDLER_COMMON /* TEI     */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word 0xFFFF            /* -       */
    .word INTHANDLER_COMMON /* ADI     */
    .word INTHANDLER_COMMON /* WOVF    */

glabel UNK_004A
    .word 0x0000
glabel ASIC_VERSION
    .word 0x1102

    .balign 0x10, 0xFF
glabel BANNER
    .ascii "97/07/17"
    .balign 0x10, 0xFF
    .ascii "GS01A02"
    .balign 0x10, 0xFF
    .ascii "(c)ALPS ELECTRIC CO.,LTD.  1996,1997    "
    .balign 0x100, 0xFF

glabel IRQ2_HANDLER
    /* 0100: 6d f0       */ mov.w       r0,@-r7             // r7 = r7 - 2; *r7 = r0
    /* 0102: 6d f1       */ mov.w       r1,@-r7             // r7 = r7 - 2; *r7 = r1
    /* 0104: 6d f2       */ mov.w       r2,@-r7             // r7 = r7 - 2; *r7 = r2
    /* 0106: 6d f3       */ mov.w       r3,@-r7             // r7 = r7 - 2; *r7 = r3
    /* 0108: 6d f5       */ mov.w       r5,@-r7             // r7 = r7 - 2; *r7 = r5
    /* 010a: 7f 03 72 20 */ bclr        #0x2,@DAT_FF03:8    // clear 0x2 at 0x03 ?
    /* 010e: 7e 10 73 20 */ btst        #0x2,@DAT_FF10:8    // test 0x2 at 0x10 ?
    /* 0112: 46 04       */ bne         LBL_0118            // branch based on test
    /* 0114: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_0118:
    /* 0118: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 011c: 47 24       */ beq         LBL_0142
    /* 011e: 6b 00 ff 4c */ mov.w       @DAT_FF4C:16,r0
    /* 0122: 09 40       */ add.w       r4,r0
    /* 0124: 79 03 8b 85 */ mov.w       #0x8b85,r3
    /* 0128: 1d 30       */ cmp.w       r3,r0
    /* 012a: 44 04       */ bcc         LBL_0130
    /* 012c: 6b 80 ff 4c */ mov.w       r0,@DAT_FF4C:16
LBL_0130:
    /* 0130: 7e 11 73 50 */ btst        #0x5,@DAT_FF11:8
    /* 0134: 46 14       */ bne         LBL_014A
    /* 0136: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 013a: c0 08       */ or.b        #0x8,r0h
    /* 013c: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
    /* 0140: 40 08       */ bra         LBL_014A
LBL_0142:
    /* 0142: 79 00 00 00 */ mov.w       #0x0,r0
    /* 0146: 6b 80 ff 4c */ mov.w       r0,@DAT_FF4C:16
LBL_014A:
    /* 014a: 20 00       */ mov.b       @DAT_FF00:8,r0h
    /* 014c: 73 70       */ btst        #0x7,r0h
    /* 014e: 46 04       */ bne         LBL_0154
    /* 0150: 5a 00 06 4c */ jmp         @LBL_064C:24
LBL_0154:
    /* 0154: 73 10       */ btst        #0x1,r0h
    /* 0156: 47 04       */ beq         LBL_015C
    /* 0158: 5a 00 04 8a */ jmp         @LBL_048A:24
LBL_015C:
    /* 015c: 73 20       */ btst        #0x2,r0h
    /* 015e: 47 04       */ beq         LBL_0164
    /* 0160: 5a 00 04 b8 */ jmp         @LBL_04B8:24
LBL_0164:
    /* 0164: 6b 00 fd b8 */ mov.w       @DAT_FDB8:16,r0
    /* 0168: 6b 80 fd d6 */ mov.w       r0,@DAT_FDD6:16
    /* 016c: 6b 03 fd ba */ mov.w       @DAT_FDBA:16,r3
    /* 0170: 11 83       */ shar.b      r3h
    /* 0172: 13 0b       */ rotxr.b     r3l
    /* 0174: 11 83       */ shar.b      r3h
    /* 0176: 13 0b       */ rotxr.b     r3l
    /* 0178: 11 83       */ shar.b      r3h
    /* 017a: 13 0b       */ rotxr.b     r3l
    /* 017c: 0d 31       */ mov.w       r3,r1
    /* 017e: 79 00 00 0c */ mov.w       #0xc,r0
    /* 0182: 09 03       */ add.w       r0,r3
    /* 0184: 6b 83 fd cc */ mov.w       r3,@DAT_FDCC:16
    /* 0188: 19 01       */ sub.w       r0,r1
    /* 018a: 6b 81 fd ce */ mov.w       r1,@DAT_FDCE:16
    /* 018e: 34 04       */ mov.b       r4h,@DAT_FF04:8
    /* 0190: f0 14       */ mov.b       #0x14,r0h
LBL_0192:
    /* 0192: 1a 00       */ dec.b       r0h
    /* 0194: 47 06       */ beq         LBL_019C
    /* 0196: 28 b7       */ mov.b       @REG_P4DR:8,r0l
    /* 0198: e8 01       */ and.b       #0x1,r0l
    /* 019a: 47 f6       */ beq         LBL_0192
LBL_019C:
    /* 019c: 6a 0d 80 07 */ mov.b       @DAT_8007:16,r5l
    /* 01a0: ed 1e       */ and.b       #0x1e,r5l
    /* 01a2: 47 08       */ beq         LBL_01AC
    /* 01a4: 20 28       */ mov.b       @DAT_FF28:8,r0h
    /* 01a6: 3d 28       */ mov.b       r5l,@DAT_FF28:8
    /* 01a8: 1c 0d       */ cmp.b       r0h,r5l
    /* 01aa: 46 0c       */ bne         LBL_01B8
LBL_01AC:
    /* 01ac: 3d 28       */ mov.b       r5l,@DAT_FF28:8
    /* 01ae: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 01b2: ed 07       */ and.b       #0x7,r5l
    /* 01b4: ad 03       */ cmp.b       #0x3,r5l
    /* 01b6: 47 0a       */ beq         LBL_01C2
LBL_01B8:
    /* 01b8: 7f 04 70 60 */ bset        #0x6,@DAT_FF04:8
    /* 01bc: 55 44       */ bsr         LBL_0202
    /* 01be: 5a 00 02 9a */ jmp         @LBL_029A:24
LBL_01C2:
    /* 01c2: 6b 01 80 0a */ mov.w       @DAT_800A:16,r1
    /* 01c6: 6a 0d 80 07 */ mov.b       @DAT_8007:16,r5l
    /* 01ca: ed 1e       */ and.b       #0x1e,r5l
    /* 01cc: 3d 28       */ mov.b       r5l,@DAT_FF28:8
    /* 01ce: f8 28       */ mov.b       #0x28,r0l
    /* 01d0: 38 e8       */ mov.b       r0l,@REG_ADCSR:8
    /* 01d2: e1 07       */ and.b       #0x7,r1h
    /* 01d4: 79 03 07 03 */ mov.w       #0x703,r3
    /* 01d8: 1d 31       */ cmp.w       r3,r1
    /* 01da: 45 06       */ bcs         LBL_01E2
    /* 01dc: 79 03 06 09 */ mov.w       #0x609,r3
    /* 01e0: 19 31       */ sub.w       r3,r1
LBL_01E2:
    /* 01e2: 10 09       */ shll.b      r1l
    /* 01e4: 12 01       */ rotxl.b     r1h
    /* 01e6: 10 09       */ shll.b      r1l
    /* 01e8: 12 01       */ rotxl.b     r1h
    /* 01ea: 6b 81 fd 80 */ mov.w       r1,@DAT_FD80:16
    /* 01ee: 5e 00 0e 24 */ jsr         @FUNC_0E24:24
    /* 01f2: 49 1c       */ bvs         LBL_0210
    /* 01f4: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 01f6: 44 04       */ bcc         LBL_01FC
    /* 01f8: 5a 00 02 94 */ jmp         @LBL_0294:24
LBL_01FC:
    /* 01fc: 7f 0f 72 10 */ bclr        #0x1,@DAT_FF0F:8
    /* 0200: 40 28       */ bra         LBL_022A
LBL_0202:
    /* 0202: 28 20       */ mov.b       @DAT_FF20:8,r0l
    /* 0204: 0a 08       */ inc         r0l
    /* 0206: 38 20       */ mov.b       r0l,@DAT_FF20:8
    /* 0208: a8 03       */ cmp.b       #0x3,r0l
    /* 020a: 42 02       */ bhi         LBL_020E
    /* 020c: 54 70       */ rts
LBL_020E:
    /* 020e: 6d 70       */ mov.w       @r7+,r0
LBL_0210:
    /* 0210: 7f 07 70 20 */ bset        #0x2,@DAT_FF07:8
    /* 0214: 40 04       */ bra         LBL_021A
    /* 0216: 7f 07 70 10 */ bset        #0x1,@DAT_FF07:8
LBL_021A:
    /* 021a: 7f 06 70 00 */ bset        #0x0,@DAT_FF06:8
    /* 021e: 6b 00 fd a4 */ mov.w       @DAT_FDA4:16,r0
    /* 0222: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 0226: 5a 00 04 30 */ jmp         @LBL_0430:24
LBL_022A:
    /* 022a: 2b 2b       */ mov.b       @DAT_FF2B:8,r3l
    /* 022c: 23 37       */ mov.b       @DAT_FF37:8,r3h
LBL_022E:
    /* 022e: 7e e8 73 50 */ btst        #0x5,@REG_ADCSR:8
    /* 0232: 46 fa       */ bne         LBL_022E
    /* 0234: 28 e0       */ mov.b       @REG_ADDRA:8,r0l
    /* 0236: 18 b8       */ sub.b       r3l,r0l
    /* 0238: 73 29       */ btst        #0x2,r1l
    /* 023a: 46 02       */ bne         LBL_023E
    /* 023c: 17 88       */ neg.b       r0l
LBL_023E:
    /* 023e: 4b 0a       */ bmi         LBL_024A
    /* 0240: 50 30       */ mulxu.b     r3h,r0
    /* 0242: a0 10       */ cmp.b       #0x10,r0h
    /* 0244: 43 10       */ bls         LBL_0256
    /* 0246: f8 10       */ mov.b       #0x10,r0l
    /* 0248: 40 0e       */ bra         LBL_0258
LBL_024A:
    /* 024a: 17 88       */ neg.b       r0l
    /* 024c: 50 30       */ mulxu.b     r3h,r0
    /* 024e: a0 10       */ cmp.b       #0x10,r0h
    /* 0250: 43 02       */ bls         LBL_0254
    /* 0252: f0 10       */ mov.b       #0x10,r0h
LBL_0254:
    /* 0254: 17 80       */ neg.b       r0h
LBL_0256:
    /* 0256: 0c 08       */ mov.b       r0h,r0l
LBL_0258:
    /* 0258: 6b 03 fd 86 */ mov.w       @DAT_FD86:16,r3
    /* 025c: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 0260: 47 06       */ beq         LBL_0268
    /* 0262: 17 88       */ neg.b       r0l
    /* 0264: 19 13       */ sub.w       r1,r3
    /* 0266: 40 04       */ bra         LBL_026C
LBL_0268:
    /* 0268: 19 31       */ sub.w       r3,r1
    /* 026a: 0d 13       */ mov.w       r1,r3
LBL_026C:
    /* 026c: 10 8b       */ shal.b      r3l
    /* 026e: 12 03       */ rotxl.b     r3h
    /* 0270: 10 8b       */ shal.b      r3l
    /* 0272: 12 03       */ rotxl.b     r3h
    /* 0274: 10 8b       */ shal.b      r3l
    /* 0276: 12 03       */ rotxl.b     r3h
    /* 0278: f0 00       */ mov.b       #0x0,r0h
    /* 027a: a8 00       */ cmp.b       #0x0,r0l
    /* 027c: 4a 02       */ bpl         LBL_0280
    /* 027e: 17 00       */ not.b       r0h
LBL_0280:
    /* 0280: 09 30       */ add.w       r3,r0
    /* 0282: 6b 80 fd ac */ mov.w       r0,@DAT_FDAC:16
    /* 0286: 4a 6a       */ bpl         LBL_02F2
    /* 0288: 79 03 c8 00 */ mov.w       #0xc800,r3
    /* 028c: 1d 30       */ cmp.w       r3,r0
    /* 028e: 45 62       */ bcs         LBL_02F2
    /* 0290: 5a 00 03 fa */ jmp         @LBL_03FA:24
LBL_0294:
    /* 0294: 7e e8 73 50 */ btst        #0x5,@REG_ADCSR:8
    /* 0298: 46 fa       */ bne         LBL_0294
LBL_029A:
    /* 029a: 7f 0f 70 10 */ bset        #0x1,@DAT_FF0F:8
    /* 029e: 6b 00 fd ae */ mov.w       @DAT_FDAE:16,r0
    /* 02a2: 6b 03 ff 2c */ mov.w       @DAT_FF2C:16,r3
    /* 02a6: 46 0e       */ bne         LBL_02B6
    /* 02a8: 6b 80 fd ac */ mov.w       r0,@DAT_FDAC:16
    /* 02ac: 6b 03 fd 82 */ mov.w       @DAT_FD82:16,r3
    /* 02b0: 6b 83 fd 80 */ mov.w       r3,@DAT_FD80:16
    /* 02b4: 40 3c       */ bra         LBL_02F2
LBL_02B6:
    /* 02b6: 6b 03 fd ba */ mov.w       @DAT_FDBA:16,r3
    /* 02ba: 19 30       */ sub.w       r3,r0
    /* 02bc: 6b 80 fd ac */ mov.w       r0,@DAT_FDAC:16
    /* 02c0: 0d 01       */ mov.w       r0,r1
    /* 02c2: 6b 03 fd 86 */ mov.w       @DAT_FD86:16,r3
    /* 02c6: 1c 41       */ cmp.b       r4h,r1h
    /* 02c8: 4a 0c       */ bpl         LBL_02D6
    /* 02ca: 79 02 c8 00 */ mov.w       #0xc800,r2
    /* 02ce: 1d 21       */ cmp.w       r2,r1
    /* 02d0: 45 04       */ bcs         LBL_02D6
    /* 02d2: 5a 00 03 fa */ jmp         @LBL_03FA:24
LBL_02D6:
    /* 02d6: 11 01       */ shlr.b      r1h
    /* 02d8: 13 09       */ rotxr.b     r1l
    /* 02da: 11 01       */ shlr.b      r1h
    /* 02dc: 13 09       */ rotxr.b     r1l
    /* 02de: 11 01       */ shlr.b      r1h
    /* 02e0: 13 09       */ rotxr.b     r1l
    /* 02e2: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 02e6: 46 04       */ bne         LBL_02EC
    /* 02e8: 09 13       */ add.w       r1,r3
    /* 02ea: 40 02       */ bra         LBL_02EE
LBL_02EC:
    /* 02ec: 19 13       */ sub.w       r1,r3
LBL_02EE:
    /* 02ee: 6b 83 fd 80 */ mov.w       r3,@DAT_FD80:16
LBL_02F2:
    /* 02f2: 5e 00 0c d8 */ jsr         @FUNC_0CD8:24
    /* 02f6: 6b 80 fd d2 */ mov.w       r0,@DAT_FDD2:16
    /* 02fa: 6b 03 fd ca */ mov.w       @DAT_FDCA:16,r3
    /* 02fe: 1d 30       */ cmp.w       r3,r0
    /* 0300: 4d 02       */ blt         LBL_0304
    /* 0302: 0d 30       */ mov.w       r3,r0
LBL_0304:
    /* 0304: 6b 01 fd ac */ mov.w       @DAT_FDAC:16,r1
    /* 0308: 6b 03 fd ae */ mov.w       @DAT_FDAE:16,r3
    /* 030c: 6b 81 fd ae */ mov.w       r1,@DAT_FDAE:16
    /* 0310: 19 13       */ sub.w       r1,r3
    /* 0312: 6b 83 fd ba */ mov.w       r3,@DAT_FDBA:16
    /* 0316: 21 35       */ mov.b       @DAT_FF35:8,r1h
    /* 0318: 19 30       */ sub.w       r3,r0
    /* 031a: 4b 0c       */ bmi         LBL_0328
    /* 031c: 50 10       */ mulxu.b     r1h,r0
    /* 031e: 1c 40       */ cmp.b       r4h,r0h
    /* 0320: 47 18       */ beq         LBL_033A
    /* 0322: 79 00 00 ff */ mov.w       #0xff,r0
    /* 0326: 40 12       */ bra         LBL_033A
LBL_0328:
    /* 0328: 17 88       */ neg.b       r0l
    /* 032a: 50 10       */ mulxu.b     r1h,r0
    /* 032c: 1c 40       */ cmp.b       r4h,r0h
    /* 032e: 47 04       */ beq         LBL_0334
    /* 0330: 79 00 00 ff */ mov.w       #0xff,r0
LBL_0334:
    /* 0334: 17 00       */ not.b       r0h
    /* 0336: 17 08       */ not.b       r0l
    /* 0338: 09 40       */ add.w       r4,r0
LBL_033A:
    /* 033a: 6b 80 fd b8 */ mov.w       r0,@DAT_FDB8:16
    /* 033e: 6b 01 fd d6 */ mov.w       @DAT_FDD6:16,r1
    /* 0342: 09 10       */ add.w       r1,r0
    /* 0344: 11 80       */ shar.b      r0h
    /* 0346: 13 08       */ rotxr.b     r0l
    /* 0348: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 034c: 47 06       */ beq         LBL_0354
    /* 034e: 17 00       */ not.b       r0h
    /* 0350: 17 08       */ not.b       r0l
    /* 0352: 09 40       */ add.w       r4,r0
LBL_0354:
    /* 0354: 6b 03 80 0a */ mov.w       @DAT_800A:16,r3
    /* 0358: e3 60       */ and.b       #0x60,r3h
    /* 035a: a3 60       */ cmp.b       #0x60,r3h
    /* 035c: 46 14       */ bne         LBL_0372
    /* 035e: 6d f0       */ mov.w       r0,@-r7
    /* 0360: 5e 00 10 fe */ jsr         @FUNC_10FE:24
    /* 0364: 6d 70       */ mov.w       @r7+,r0
    /* 0366: 6b 03 fe 36 */ mov.w       @DAT_FE36:16,r3
    /* 036a: 09 30       */ add.w       r3,r0
    /* 036c: 6b 03 fe 38 */ mov.w       @DAT_FE38:16,r3
    /* 0370: 09 30       */ add.w       r3,r0
LBL_0372:
    /* 0372: 6b 03 fd a6 */ mov.w       @DAT_FDA6:16,r3
    /* 0376: 09 30       */ add.w       r3,r0
    /* 0378: 4b 08       */ bmi         LBL_0382
    /* 037a: 1c 40       */ cmp.b       r4h,r0h
    /* 037c: 47 06       */ beq         LBL_0384
    /* 037e: f8 ff       */ mov.b       #0xff,r0l
    /* 0380: 40 02       */ bra         LBL_0384
LBL_0382:
    /* 0382: 0c 48       */ mov.b       r4h,r0l
LBL_0384:
    /* 0384: 0d 05       */ mov.w       r0,r5
    /* 0386: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 038a: 0c 45       */ mov.b       r4h,r5h
    /* 038c: 6b 03 fd a4 */ mov.w       @DAT_FDA4:16,r3
    /* 0390: 19 35       */ sub.w       r3,r5
    /* 0392: 4b 04       */ bmi         LBL_0398
    /* 0394: fb 00       */ mov.b       #0x0,r3l
    /* 0396: 40 02       */ bra         LBL_039A
LBL_0398:
    /* 0398: fb ff       */ mov.b       #0xff,r3l
LBL_039A:
    /* 039a: 6b 01 fd be */ mov.w       @DAT_FDBE:16,r1
    /* 039e: 09 15       */ add.w       r1,r5
    /* 03a0: 6b 85 fd be */ mov.w       r5,@DAT_FDBE:16
    /* 03a4: 6b 03 ff 2c */ mov.w       @DAT_FF2C:16,r3
    /* 03a8: 09 43       */ add.w       r4,r3
    /* 03aa: 6b 83 ff 2c */ mov.w       r3,@DAT_FF2C:16
    /* 03ae: 1d 43       */ cmp.w       r4,r3
    /* 03b0: 47 1c       */ beq         LBL_03CE
    /* 03b2: 79 00 04 00 */ mov.w       #0x400,r0
    /* 03b6: 1d 03       */ cmp.w       r0,r3
    /* 03b8: 4a 0c       */ bpl         LBL_03C6
    /* 03ba: 6b 00 fd ac */ mov.w       @DAT_FDAC:16,r0
    /* 03be: 79 03 00 08 */ mov.w       #0x8,r3
    /* 03c2: 1d 30       */ cmp.w       r3,r0
    /* 03c4: 42 04       */ bhi         LBL_03CA
LBL_03C6:
    /* 03c6: 5a 00 03 fa */ jmp         @LBL_03FA:24
LBL_03CA:
    /* 03ca: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_03CE:
    /* 03ce: 6b 00 fd 8a */ mov.w       @DAT_FD8A:16,r0
    /* 03d2: 79 01 00 04 */ mov.w       #0x4,r1
    /* 03d6: 1d 10       */ cmp.w       r1,r0
    /* 03d8: 43 f0       */ bls         LBL_03CA
    /* 03da: 6b 00 fd 84 */ mov.w       @DAT_FD84:16,r0
    /* 03de: 5e 00 0d ce */ jsr         @FUNC_0DCE:24
    /* 03e2: 6b 80 fd a6 */ mov.w       r0,@DAT_FDA6:16
    /* 03e6: 0c 80       */ mov.b       r0l,r0h
    /* 03e8: 0c 48       */ mov.b       r4h,r0l
    /* 03ea: 6b 80 fd a8 */ mov.w       r0,@DAT_FDA8:16
    /* 03ee: 5a 00 09 fa */ jmp         @LBL_09FA:24

LBL_03F2: // unused?
    /* 03f2: f8 ff       */ mov.b       #0xff,r0l
    /* 03f4: 38 3a       */ mov.b       r0l,@DAT_FF3A:8
    /* 03f6: 5a 00 09 fa */ jmp         @LBL_09FA:24

LBL_03FA:
    /* 03fa: 6b 00 fd ac */ mov.w       @DAT_FDAC:16,r0
    /* 03fe: 10 88       */ shal.b      r0l
    /* 0400: 12 00       */ rotxl.b     r0h
    /* 0402: 10 88       */ shal.b      r0l
    /* 0404: 12 00       */ rotxl.b     r0h
    /* 0406: 79 03 00 00 */ mov.w       #0x0,r3
    /* 040a: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 040e: 47 0c       */ beq         LBL_041C
    /* 0410: 17 00       */ not.b       r0h
    /* 0412: 17 08       */ not.b       r0l
    /* 0414: 09 40       */ add.w       r4,r0
    /* 0416: 17 03       */ not.b       r3h
    /* 0418: 17 0b       */ not.b       r3l
    /* 041a: 09 43       */ add.w       r4,r3
LBL_041C:
    /* 041c: 6b 80 fd b0 */ mov.w       r0,@DAT_FDB0:16
    /* 0420: 6b 83 fd b8 */ mov.w       r3,@DAT_FDB8:16
    /* 0424: 3c 2c       */ mov.b       r4l,@DAT_FF2C:8
    /* 0426: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 0428: f0 40       */ mov.b       #0x40,r0h
    /* 042a: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 042c: 5a 00 09 fa */ jmp         @LBL_09FA:24

LBL_0430:
    /* 0430: 6b 00 fd be */ mov.w       @DAT_FDBE:16,r0
    /* 0434: 4a 06       */ bpl         LBL_043C
    /* 0436: 17 00       */ not.b       r0h
    /* 0438: 17 08       */ not.b       r0l
    /* 043a: 09 40       */ add.w       r4,r0
LBL_043C:
    /* 043c: 79 03 05 80 */ mov.w       #0x580,r3
    /* 0440: 1d 30       */ cmp.w       r3,r0
    /* 0442: 44 1a       */ bcc         LBL_045E
    /* 0444: fb 40       */ mov.b       #0x40,r3l
    /* 0446: 51 b0       */ divxu.b     r3l,r0
    /* 0448: 15 00       */ xor.b       r0h,r0h
    /* 044a: 79 03 00 00 */ mov.w       #0x0,r3
    /* 044e: 1d 30       */ cmp.w       r3,r0
    /* 0450: 46 04       */ bne         LBL_0456
    /* 0452: 5a 00 04 a2 */ jmp         @LBL_04A2:24

LBL_0456:
    /* 0456: 79 03 00 16 */ mov.w       #0x16,r3
    /* 045a: 1d 30       */ cmp.w       r3,r0
    /* 045c: 43 02       */ bls         LBL_0460
LBL_045E:
    /* 045e: f8 16       */ mov.b       #0x16,r0l
LBL_0460:
    /* 0460: 6a 88 fd e2 */ mov.b       r0l,@DAT_FDE2:16
    /* 0464: 7f 00 70 10 */ bset        #0x1,@DAT_FF00:8
    /* 0468: 6b 00 fd be */ mov.w       @DAT_FDBE:16,r0
    /* 046c: 4b 0e       */ bmi         LBL_47C
    /* 046e: f8 40       */ mov.b       #0x40,r0l
    /* 0470: 6a 88 fd c0 */ mov.b       r0l,@DAT_FDC0:16
    /* 0474: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 0478: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_47C:
    /* 047c: f8 c0       */ mov.b       #0xc0,r0l
    /* 047e: 6a 88 fd c0 */ mov.b       r0l,@DAT_FDC0:16
    /* 0482: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 0486: 5a 00 09 fa */ jmp         @LBL_09FA:24

LBL_048A:
    /* 048a: 6a 00 fd e2 */ mov.b       @DAT_FDE2:16,r0h
    /* 048e: 1a 00       */ dec.b       r0h
    /* 0490: 6a 80 fd e2 */ mov.b       r0h,@DAT_FDE2:16
    /* 0494: 4f 0c       */ ble         LBL_04A2
    /* 0496: 6a 08 fd c0 */ mov.b       @DAT_FDC0:16,r0l
    /* 049a: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 049e: 5a 00 09 fa */ jmp         @LBL_09FA:24

LBL_04A2:
    /* 04a2: f8 80       */ mov.b       #0x80,r0l
    /* 04a4: 6a 88 fd c0 */ mov.b       r0l,@DAT_FDC0:16
    /* 04a8: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 04ac: 7f 03 70 40 */ bset        #0x4,@DAT_FF03:8
    /* 04b0: f0 40       */ mov.b       #0x40,r0h
    /* 04b2: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 04b4: 5a 00 09 fa */ jmp         @LBL_09FA:24

LBL_04B8:
    /* 04b8: 6b 00 ff 92 */ mov.w       @REG_FRC:16,r0
    /* 04bc: 79 03 00 6e */ mov.w       #0x6e,r3
    /* 04c0: 09 30       */ add.w       r3,r0
    /* 04c2: 7f 97 70 40 */ bset        #0x4,@REG_TOCR:8
    /* 04c6: 7f 91 72 20 */ bclr        #0x2,@REG_TCSR:8
    /* 04ca: 6b 80 ff 94 */ mov.w       r0,@REG_OCR:16
    /* 04ce: fb 38       */ mov.b       #0x38,r3l
    /* 04d0: 6a 8b 80 19 */ mov.b       r3l,@DAT_8019:16
    /* 04d4: 7e 11 73 00 */ btst        #0x0,@DAT_FF11:8
    /* 04d8: 46 0a       */ bne         LBL_04E4
    /* 04da: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 04de: e0 f7       */ and.b       #0xf7,r0h
    /* 04e0: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
LBL_04E4:
    /* 04e4: 79 00 00 00 */ mov.w       #0x0,r0
    /* 04e8: 6b 80 fd da */ mov.w       r0,@DAT_FDDA:16
    /* 04ec: 6b 80 fd ba */ mov.w       r0,@DAT_FDBA:16
    /* 04f0: 6b 80 fd de */ mov.w       r0,@DAT_FDDE:16
    /* 04f4: 6b 80 fd be */ mov.w       r0,@DAT_FDBE:16
    /* 04f8: 34 2f       */ mov.b       r4h,@DAT_FF2F:8
    /* 04fa: 6a 84 fd e2 */ mov.b       r4h,@DAT_FDE2:16
    /* 04fe: 34 04       */ mov.b       r4h,@DAT_FF04:8
    /* 0500: 34 05       */ mov.b       r4h,@DAT_FF05:8
    /* 0502: 34 0f       */ mov.b       r4h,@DAT_FF0F:8
    /* 0504: 6b 80 ff 2c */ mov.w       r0,@DAT_FF2C:16
    /* 0508: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 050a: 34 34       */ mov.b       r4h,@DAT_FF34:8
    /* 050c: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 050e: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 0512: 20 14       */ mov.b       @DAT_FF14:8,r0h
    /* 0514: 30 13       */ mov.b       r0h,@DAT_FF13:8
    /* 0516: 79 00 70 3f */ mov.w       #0x703f,r0
    /* 051a: 6b 80 fd 8c */ mov.w       r0,@DAT_FD8C:16
    /* 051e: 79 00 00 80 */ mov.w       #0x80,r0
    /* 0522: 6b 80 fd b6 */ mov.w       r0,@DAT_FDB6:16
    /* 0526: 79 00 01 40 */ mov.w       #0x140,r0
    /* 052a: 7e 0c 73 40 */ btst        #0x4,@DAT_FF0C:8
    /* 052e: 47 04       */ beq         LBL_0534
    /* 0530: 79 00 03 20 */ mov.w       #0x320,r0
LBL_0534:
    /* 0534: 6b 80 fd d8 */ mov.w       r0,@DAT_FDD8:16
    /* 0538: 5e 00 0f 14 */ jsr         @FUNC_0F14:24
    /* 053c: 6b 00 fd 88 */ mov.w       @DAT_FD88:16,r0
    /* 0540: 10 08       */ shll.b      r0l
    /* 0542: 12 00       */ rotxl.b     r0h
    /* 0544: 10 08       */ shll.b      r0l
    /* 0546: 12 00       */ rotxl.b     r0h
    /* 0548: 6b 80 fd 86 */ mov.w       r0,@DAT_FD86:16
    /* 054c: 6b 00 fd 88 */ mov.w       @DAT_FD88:16,r0
    /* 0550: 6b 03 fd 84 */ mov.w       @DAT_FD84:16,r3
    /* 0554: 6b 80 fd 84 */ mov.w       r0,@DAT_FD84:16
    /* 0558: 19 30       */ sub.w       r3,r0
    /* 055a: 46 08       */ bne         LBL_0564
    /* 055c: 7f 0d 72 30 */ bclr        #0x3,@DAT_FF0D:8
    /* 0560: 5a 00 06 34 */ jmp         @LBL_0634:24
LBL_0564:
    /* 0564: 4a 0c       */ bpl         LBL_0572
    /* 0566: 7f 01 72 50 */ bclr        #0x5,@DAT_FF01:8
    /* 056a: 17 00       */ not.b       r0h
    /* 056c: 17 08       */ not.b       r0l
    /* 056e: 09 40       */ add.w       r4,r0
    /* 0570: 40 04       */ bra         LBL_0576
LBL_0572:
    /* 0572: 7f 01 70 50 */ bset        #0x5,@DAT_FF01:8
LBL_0576:
    /* 0576: 6b 80 fd 8a */ mov.w       r0,@DAT_FD8A:16
    /* 057a: 1d 40       */ cmp.w       r4,r0
    /* 057c: 42 0c       */ bhi         LBL_058A
    /* 057e: 23 39       */ mov.b       @DAT_FF39:8,r3h
    /* 0580: 2b 1d       */ mov.b       @DAT_FF1D:8,r3l
    /* 0582: 1c 3b       */ cmp.b       r3h,r3l
    /* 0584: 47 04       */ beq         LBL_058A
    /* 0586: 5a 00 06 34 */ jmp         @LBL_0634:24
LBL_058A:
    /* 058a: 0d 01       */ mov.w       r0,r1
    /* 058c: 5e 00 62 40 */ jsr         @FUNC_6240:24
    /* 0590: 0d 10       */ mov.w       r1,r0
    /* 0592: fa 00       */ mov.b       #0x0,r2l
    /* 0594: 10 08       */ shll.b      r0l
    /* 0596: 12 00       */ rotxl.b     r0h
    /* 0598: 10 08       */ shll.b      r0l
    /* 059a: 12 00       */ rotxl.b     r0h
    /* 059c: 10 08       */ shll.b      r0l
    /* 059e: 12 00       */ rotxl.b     r0h
    /* 05a0: 10 08       */ shll.b      r0l
    /* 05a2: 12 00       */ rotxl.b     r0h
    /* 05a4: 10 08       */ shll.b      r0l
    /* 05a6: 12 00       */ rotxl.b     r0h
    /* 05a8: 6b 80 fd ae */ mov.w       r0,@DAT_FDAE:16
    /* 05ac: 79 03 00 08 */ mov.w       #0x8,r3
    /* 05b0: 1d 31       */ cmp.w       r3,r1
    /* 05b2: 44 06       */ bcc         LBL_05BA
    /* 05b4: 79 00 07 c0 */ mov.w       #0x7c0,r0
    /* 05b8: 40 0a       */ bra         LBL_05C4
LBL_05BA:
    /* 05ba: 11 0a       */ shlr.b      r2l
    /* 05bc: 13 00       */ rotxr.b     r0h
    /* 05be: 13 08       */ rotxr.b     r0l
    /* 05c0: 5e 00 0c d8 */ jsr         @FUNC_0CD8:24
LBL_05C4:
    /* 05c4: 79 03 07 c0 */ mov.w       #0x7c0,r3
    /* 05c8: 7e 0c 73 40 */ btst        #0x4,@DAT_FF0C:8
    /* 05cc: 47 04       */ beq         LBL_05D2
    /* 05ce: 79 03 03 80 */ mov.w       #0x380,r3
LBL_05D2:
    /* 05d2: 1d 30       */ cmp.w       r3,r0
    /* 05d4: 43 02       */ bls         LBL_05D8
    /* 05d6: 0d 30       */ mov.w       r3,r0
LBL_05D8:
    /* 05d8: 6b 80 fd ca */ mov.w       r0,@DAT_FDCA:16
    /* 05dc: 6b 00 fd b4 */ mov.w       @DAT_FDB4:16,r0
    /* 05e0: 6b 80 fd b8 */ mov.w       r0,@DAT_FDB8:16
    /* 05e4: 0d 03       */ mov.w       r0,r3
    /* 05e6: 6b 01 fd 8a */ mov.w       @DAT_FD8A:16,r1
    /* 05ea: 79 02 00 80 */ mov.w       #0x80,r2
    /* 05ee: 1d 21       */ cmp.w       r2,r1
    /* 05f0: 43 08       */ bls         LBL_05FA
    /* 05f2: 11 80       */ shar.b      r0h
    /* 05f4: 13 08       */ rotxr.b     r0l
    /* 05f6: 79 03 00 00 */ mov.w       #0x0,r3
LBL_05FA:
    /* 05fa: 6b 83 fd d6 */ mov.w       r3,@DAT_FDD6:16
    /* 05fe: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 0602: 47 06       */ beq         LBL_060A
    /* 0604: 17 00       */ not.b       r0h
    /* 0606: 17 08       */ not.b       r0l
    /* 0608: 09 40       */ add.w       r4,r0
LBL_060A:
    /* 060a: 6b 03 fd a8 */ mov.w       @DAT_FDA8:16,r3
    /* 060e: 0c 3b       */ mov.b       r3h,r3l
    /* 0610: 0c 43       */ mov.b       r4h,r3h
    /* 0612: 6b 83 fd a6 */ mov.w       r3,@DAT_FDA6:16
    /* 0616: 09 30       */ add.w       r3,r0
    /* 0618: 4b 08       */ bmi         LBL_0622
    /* 061a: 1c 40       */ cmp.b       r4h,r0h
    /* 061c: 47 06       */ beq         LBL_0624
    /* 061e: f8 ff       */ mov.b       #0xff,r0l
    /* 0620: 40 02       */ bra         LBL_0624
LBL_0622:
    /* 0622: 0c 48       */ mov.b       r4h,r0l
LBL_0624:
    /* 0624: 7e 91 73 20 */ btst        #0x2,@REG_TCSR:8
    /* 0628: 47 fa       */ beq         LBL_0624
    /* 062a: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 062e: f0 80       */ mov.b       #0x80,r0h
    /* 0630: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 0632: 40 0c       */ bra         LBL_0640
LBL_0634:
    /* 0634: f0 04       */ mov.b       #0x4,r0h
    /* 0636: 30 43       */ mov.b       r0h,@DAT_FF43:8
    /* 0638: f0 40       */ mov.b       #0x40,r0h
    /* 063a: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 063c: f0 08       */ mov.b       #0x8,r0h
    /* 063e: 30 2c       */ mov.b       r0h,@DAT_FF2C:8
LBL_0640:
    /* 0640: 7f 06 72 60 */ bclr        #0x6,@DAT_FF06:8
    /* 0644: 2b 1d       */ mov.b       @DAT_FF1D:8,r3l
    /* 0646: 3b 39       */ mov.b       r3l,@DAT_FF39:8
    /* 0648: 5a 00 09 fa */ jmp         @LBL_09FA:24

LBL_064C:
    /* 064c: 5e 00 0a 22 */ jsr         @FUNC_0A22:24
    /* 0650: 5e 00 0a d2 */ jsr         @FUNC_0AD2:24
    /* 0654: 6b 00 fd b8 */ mov.w       @DAT_FDB8:16,r0
    /* 0658: 6b 80 fd d6 */ mov.w       r0,@DAT_FDD6:16
    /* 065c: 34 04       */ mov.b       r4h,@DAT_FF04:8
    /* 065e: fa 03       */ mov.b       #0x3,r2l
    /* 0660: f0 14       */ mov.b       #0x14,r0h
LBL_0662:
    /* 0662: 1a 00       */ dec.b       r0h
    /* 0664: 47 06       */ beq         LBL_066C
    /* 0666: 28 b7       */ mov.b       @REG_P4DR:8,r0l
    /* 0668: e8 01       */ and.b       #0x1,r0l
    /* 066a: 47 f6       */ beq         LBL_0662
LBL_066C:
    /* 066c: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 0670: ed 07       */ and.b       #0x7,r5l
    /* 0672: ad 03       */ cmp.b       #0x3,r5l
    /* 0674: 47 48       */ beq         LBL_06BE
    /* 0676: ad 04       */ cmp.b       #0x4,r5l
    /* 0678: 47 44       */ beq         LBL_06BE
    /* 067a: 7f 04 70 60 */ bset        #0x6,@DAT_FF04:8
    /* 067e: 28 20       */ mov.b       @DAT_FF20:8,r0l
    /* 0680: 0a 08       */ inc         r0l
    /* 0682: 38 20       */ mov.b       r0l,@DAT_FF20:8
    /* 0684: 1c a8       */ cmp.b       r2l,r0l
    /* 0686: 42 14       */ bhi         LBL_069C
    /* 0688: 79 00 00 00 */ mov.w       #0x0,r0
    /* 068c: 6b 80 fd b8 */ mov.w       r0,@DAT_FDB8:16
    /* 0690: 6b 00 fd a4 */ mov.w       @DAT_FDA4:16,r0
    /* 0694: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 0698: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_069C:
    /* 069c: 7f 07 70 20 */ bset        #0x2,@DAT_FF07:8
    /* 06a0: 7f 03 70 40 */ bset        #0x4,@DAT_FF03:8
    /* 06a4: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 06a8: c0 08       */ or.b        #0x8,r0h
    /* 06aa: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
    /* 06ae: 7f 06 70 00 */ bset        #0x0,@DAT_FF06:8
    /* 06b2: 6b 00 fd a4 */ mov.w       @DAT_FDA4:16,r0
    /* 06b6: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 06ba: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_06BE:
    /* 06be: f8 28       */ mov.b       #0x28,r0l
    /* 06c0: 38 e8       */ mov.b       r0l,@REG_ADCSR:8
    /* 06c2: 6b 01 80 0a */ mov.w       @DAT_800A:16,r1
    /* 06c6: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 06c8: e1 07       */ and.b       #0x7,r1h
    /* 06ca: 79 03 07 03 */ mov.w       #0x703,r3
    /* 06ce: 1d 31       */ cmp.w       r3,r1
    /* 06d0: 45 06       */ bcs         LBL_06D8
    /* 06d2: 79 03 06 09 */ mov.w       #0x609,r3
    /* 06d6: 19 31       */ sub.w       r3,r1
LBL_06D8:
    /* 06d8: 10 09       */ shll.b      r1l
    /* 06da: 12 01       */ rotxl.b     r1h
    /* 06dc: 10 09       */ shll.b      r1l
    /* 06de: 12 01       */ rotxl.b     r1h
    /* 06e0: 6b 81 fd 80 */ mov.w       r1,@DAT_FD80:16
    /* 06e4: 7e 00 73 30 */ btst        #0x3,@DAT_FF00:8
    /* 06e8: 46 20       */ bne         LBL_070A
    /* 06ea: 5e 00 0e 6c */ jsr         @FUNC_0E6C:24
    /* 06ee: 49 ac       */ bvs         LBL_069C
    /* 06f0: 44 18       */ bcc         LBL_070A
    /* 06f2: 7f 04 70 50 */ bset        #0x5,@DAT_FF04:8
    /* 06f6: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 06fa: 46 06       */ bne         LBL_0702
    /* 06fc: 7e 0c 73 40 */ btst        #0x4,@DAT_FF0C:8
    /* 0700: 46 08       */ bne         LBL_070A
LBL_0702:
    /* 0702: 6b 01 fd 86 */ mov.w       @DAT_FD86:16,r1
    /* 0706: 6b 81 fd 80 */ mov.w       r1,@DAT_FD80:16
LBL_070A:
    /* 070a: 7e 10 73 00 */ btst        #0x0,@DAT_FF10:8
    /* 070e: 47 0a       */ beq         LBL_071A
    /* 0710: 6d f1       */ mov.w       r1,@-r7
    /* 0712: 5e 00 40 e0 */ jsr         @FUNC_40E0:24
    /* 0716: 6d 71       */ mov.w       @r7+,r1
    /* 0718: 40 0a       */ bra         LBL_0724
LBL_071A:
    /* 071a: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 071e: e0 60       */ and.b       #0x60,r0h
    /* 0720: a0 60       */ cmp.b       #0x60,r0h
    /* 0722: 47 0e       */ beq         LBL_0732
LBL_0724:
    /* 0724: 79 00 00 00 */ mov.w       #0x0,r0
    /* 0728: 6b 80 fe 36 */ mov.w       r0,@DAT_FE36:16
    /* 072c: 6b 80 fe 38 */ mov.w       r0,@DAT_FE38:16
    /* 0730: 40 08       */ bra         LBL_073A
LBL_0732:
    /* 0732: 6d f1       */ mov.w       r1,@-r7
    /* 0734: 5e 00 10 fe */ jsr         @FUNC_10FE:24
    /* 0738: 6d 71       */ mov.w       @r7+,r1
LBL_073A:
    /* 073a: 2b 2b       */ mov.b       @DAT_FF2B:8,r3l
    /* 073c: 23 38       */ mov.b       @DAT_FF38:8,r3h
LBL_073E:
    /* 073e: 7e e8 73 50 */ btst        #0x5,@REG_ADCSR:8
    /* 0742: 46 fa       */ bne         LBL_073E
    /* 0744: 28 e0       */ mov.b       @REG_ADDRA:8,r0l
    /* 0746: 18 b8       */ sub.b       r3l,r0l
    /* 0748: 73 29       */ btst        #0x2,r1l
    /* 074a: 46 02       */ bne         LBL_074E
    /* 074c: 17 88       */ neg.b       r0l
LBL_074E:
    /* 074e: 4b 0a       */ bmi         LBL_075A
    /* 0750: 50 30       */ mulxu.b     r3h,r0
    /* 0752: a0 40       */ cmp.b       #0x40,r0h
    /* 0754: 43 10       */ bls         LBL_0766
    /* 0756: f0 40       */ mov.b       #0x40,r0h
    /* 0758: 40 0c       */ bra         LBL_0766
LBL_075A:
    /* 075a: 17 88       */ neg.b       r0l
    /* 075c: 50 30       */ mulxu.b     r3h,r0
    /* 075e: a0 40       */ cmp.b       #0x40,r0h
    /* 0760: 43 02       */ bls         LBL_0764
    /* 0762: f0 40       */ mov.b       #0x40,r0h
LBL_0764:
    /* 0764: 17 80       */ neg.b       r0h
LBL_0766:
    /* 0766: 6b 03 fd 86 */ mov.w       @DAT_FD86:16,r3
    /* 076a: 79 02 00 00 */ mov.w       #0x0,r2
    /* 076e: 19 31       */ sub.w       r3,r1
    /* 0770: 47 2e       */ beq         LBL_07A0
    /* 0772: 4a 0e       */ bpl         LBL_0782
    /* 0774: 79 03 ff 01 */ mov.w       #0xff01,r3
    /* 0778: 1d 31       */ cmp.w       r3,r1
    /* 077a: 44 12       */ bcc         LBL_078E
    /* 077c: 79 01 ff 01 */ mov.w       #0xff01,r1
    /* 0780: 40 0c       */ bra         LBL_078E
LBL_0782:
    /* 0782: 79 03 01 00 */ mov.w       #0x100,r3
    /* 0786: 1d 31       */ cmp.w       r3,r1
    /* 0788: 4b 04       */ bmi         LBL_078E
    /* 078a: 79 01 00 ff */ mov.w       #0xff,r1
LBL_078E:
    /* 078e: 11 81       */ shar.b      r1h
    /* 0790: 13 09       */ rotxr.b     r1l
    /* 0792: 11 81       */ shar.b      r1h
    /* 0794: 13 09       */ rotxr.b     r1l
    /* 0796: 13 0a       */ rotxr.b     r2l
    /* 0798: 11 81       */ shar.b      r1h
    /* 079a: 13 09       */ rotxr.b     r1l
    /* 079c: 13 0a       */ rotxr.b     r2l
    /* 079e: 0c 92       */ mov.b       r1l,r2h
LBL_07A0:
    /* 07a0: 0c 08       */ mov.b       r0h,r0l
    /* 07a2: 4b 04       */ bmi         LBL_07A8
    /* 07a4: f0 00       */ mov.b       #0x0,r0h
    /* 07a6: 40 02       */ bra         LBL_07AA
LBL_07A8:
    /* 07a8: f0 ff       */ mov.b       #0xff,r0h
LBL_07AA:
    /* 07aa: 09 20       */ add.w       r2,r0
    /* 07ac: 6b 02 fd da */ mov.w       @DAT_FDDA:16,r2
    /* 07b0: 19 20       */ sub.w       r2,r0
    /* 07b2: 7e 10 73 00 */ btst        #0x0,@DAT_FF10:8
    /* 07b6: 46 04       */ bne         LBL_07BC
    /* 07b8: 5e 00 0e aa */ jsr         @FUNC_0EAA:24
LBL_07BC:
    /* 07bc: 0d 02       */ mov.w       r0,r2
    /* 07be: 21 31       */ mov.b       @DAT_FF31:8,r1h
    /* 07c0: 6b 03 fd b0 */ mov.w       @DAT_FDB0:16,r3
    /* 07c4: 19 30       */ sub.w       r3,r0
    /* 07c6: 4b 12       */ bmi         LBL_07DA
    /* 07c8: 79 03 00 7f */ mov.w       #0x7f,r3
    /* 07cc: 1d 30       */ cmp.w       r3,r0
    /* 07ce: 4f 02       */ ble         LBL_07D2
    /* 07d0: 0d 30       */ mov.w       r3,r0
LBL_07D2:
    /* 07d2: 6b 80 ff 5e */ mov.w       r0,@DAT_FF5E:16
    /* 07d6: 50 10       */ mulxu.b     r1h,r0
    /* 07d8: 40 18       */ bra         LBL_07F2
LBL_07DA:
    /* 07da: 79 03 ff 81 */ mov.w       #0xff81,r3
    /* 07de: 1d 30       */ cmp.w       r3,r0
    /* 07e0: 44 02       */ bcc         LBL_07E4
    /* 07e2: 0d 30       */ mov.w       r3,r0
LBL_07E4:
    /* 07e4: 6b 80 ff 5e */ mov.w       r0,@DAT_FF5E:16
    /* 07e8: 17 88       */ neg.b       r0l
    /* 07ea: 50 10       */ mulxu.b     r1h,r0
    /* 07ec: 17 00       */ not.b       r0h
    /* 07ee: 17 08       */ not.b       r0l
    /* 07f0: 09 40       */ add.w       r4,r0
LBL_07F2:
    /* 07f2: 6b 82 fd b0 */ mov.w       r2,@DAT_FDB0:16
    /* 07f6: 2b 2c       */ mov.b       @DAT_FF2C:8,r3l
    /* 07f8: 46 06       */ bne         LBL_0800
    /* 07fa: 79 00 00 00 */ mov.w       #0x0,r0
    /* 07fe: 40 24       */ bra         LBL_0824
LBL_0800:
    /* 0800: 23 30       */ mov.b       @DAT_FF30:8,r3h
    /* 0802: 09 20       */ add.w       r2,r0
    /* 0804: 4b 12       */ bmi         LBL_0818
    /* 0806: a0 00       */ cmp.b       #0x0,r0h
    /* 0808: 47 02       */ beq         LBL_080C
    /* 080a: f8 ff       */ mov.b       #0xff,r0l
LBL_080C:
    /* 080c: 50 30       */ mulxu.b     r3h,r0
    /* 080e: 88 80       */ add.b       #0x80,r0l
    /* 0810: 90 00       */ addx        #0x0,r0h
    /* 0812: 0c 08       */ mov.b       r0h,r0l
    /* 0814: 0c 40       */ mov.b       r4h,r0h
    /* 0816: 40 1a       */ bra         LBL_0832
LBL_0818:
    /* 0818: 17 00       */ not.b       r0h
    /* 081a: 17 08       */ not.b       r0l
    /* 081c: 09 40       */ add.w       r4,r0
    /* 081e: a0 00       */ cmp.b       #0x0,r0h
    /* 0820: 47 02       */ beq         LBL_0824
    /* 0822: f8 ff       */ mov.b       #0xff,r0l
LBL_0824:
    /* 0824: 50 30       */ mulxu.b     r3h,r0
    /* 0826: 88 80       */ add.b       #0x80,r0l
    /* 0828: 90 00       */ addx        #0x0,r0h
    /* 082a: 0c 08       */ mov.b       r0h,r0l
    /* 082c: f0 ff       */ mov.b       #0xff,r0h
    /* 082e: 17 08       */ not.b       r0l
    /* 0830: 09 40       */ add.w       r4,r0
LBL_0832:
    /* 0832: 6b 80 fd b8 */ mov.w       r0,@DAT_FDB8:16
    /* 0836: 6b 01 fd d6 */ mov.w       @DAT_FDD6:16,r1
    /* 083a: 09 10       */ add.w       r1,r0
    /* 083c: 11 80       */ shar.b      r0h
    /* 083e: 13 08       */ rotxr.b     r0l
    /* 0840: 6b 03 ff 5a */ mov.w       @DAT_FF5A:16,r3
    /* 0844: 09 30       */ add.w       r3,r0
    /* 0846: 6b 80 ff 50 */ mov.w       r0,@DAT_FF50:16
    /* 084a: 6b 03 fe 36 */ mov.w       @DAT_FE36:16,r3
    /* 084e: 09 30       */ add.w       r3,r0
    /* 0850: 6b 03 fe 38 */ mov.w       @DAT_FE38:16,r3
    /* 0854: 09 30       */ add.w       r3,r0
    /* 0856: 6b 03 fd a8 */ mov.w       @DAT_FDA8:16,r3
    /* 085a: 0c 3b       */ mov.b       r3h,r3l
    /* 085c: 0c 43       */ mov.b       r4h,r3h
    /* 085e: 09 30       */ add.w       r3,r0
    /* 0860: 4b 08       */ bmi         LBL_086A
    /* 0862: a0 00       */ cmp.b       #0x0,r0h
    /* 0864: 47 06       */ beq         LBL_086C
    /* 0866: f8 ff       */ mov.b       #0xff,r0l
    /* 0868: 40 02       */ bra         LBL_086C
LBL_086A:
    /* 086a: 0c 48       */ mov.b       r4h,r0l
LBL_086C:
    /* 086c: 7e 0d 73 00 */ btst        #0x0,@DAT_FF0D:8
    /* 0870: 46 26       */ bne         LBL_0898
    /* 0872: 7e 10 73 00 */ btst        #0x0,@DAT_FF10:8
    /* 0876: 47 1c       */ beq         LBL_0894
    /* 0878: 6a 88 fe 24 */ mov.b       r0l,@DAT_FE24:16
    /* 087c: 5e 00 13 14 */ jsr         @FUNC_1314:24
    /* 0880: 0c 40       */ mov.b       r4h,r0h
    /* 0882: 09 30       */ add.w       r3,r0
    /* 0884: 4b 08       */ bmi         LBL_088E
    /* 0886: 1c 40       */ cmp.b       r4h,r0h
    /* 0888: 47 06       */ beq         LBL_0890
    /* 088a: f8 ff       */ mov.b       #0xff,r0l
    /* 088c: 40 02       */ bra         LBL_0890
LBL_088E:
    /* 088e: 0c 48       */ mov.b       r4h,r0l
LBL_0890:
    /* 0890: 6a 88 fe 25 */ mov.b       r0l,@DAT_FE25:16
LBL_0894:
    /* 0894: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
LBL_0898:
    /* 0898: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 089c: 47 04       */ beq         LBL_08A2
    /* 089e: 5a 00 09 56 */ jmp         @LBL_0956:24
LBL_08A2:
    /* 08a2: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 08a6: 46 26       */ bne         LBL_08CE
    /* 08a8: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 08ac: 46 0a       */ bne         LBL_08B8
    /* 08ae: 79 00 00 00 */ mov.w       #0x0,r0
    /* 08b2: 6b 80 ff 4e */ mov.w       r0,@DAT_FF4E:16
    /* 08b6: 40 16       */ bra         LBL_08CE
LBL_08B8:
    /* 08b8: 6b 00 ff 4e */ mov.w       @DAT_FF4E:16,r0
    /* 08bc: 09 40       */ add.w       r4,r0
    /* 08be: 6b 80 ff 4e */ mov.w       r0,@DAT_FF4E:16
    /* 08c2: 79 03 13 88 */ mov.w       #0x1388,r3
    /* 08c6: 1d 30       */ cmp.w       r3,r0
    /* 08c8: 45 04       */ bcs         LBL_08CE
    /* 08ca: 7f 03 70 10 */ bset        #0x1,@DAT_FF03:8
LBL_08CE:
    /* 08ce: 20 2c       */ mov.b       @DAT_FF2C:8,r0h
    /* 08d0: a0 02       */ cmp.b       #0x2,r0h
    /* 08d2: 42 04       */ bhi         LBL_08D8
    /* 08d4: 5a 00 09 38 */ jmp         @LBL_0938:24
LBL_08D8:
    /* 08d8: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 08dc: 4a 06       */ bpl         LBL_08E4
    /* 08de: 17 00       */ not.b       r0h
    /* 08e0: 17 08       */ not.b       r0l
    /* 08e2: 09 40       */ add.w       r4,r0
LBL_08E4:
    /* 08e4: f3 00       */ mov.b       #0x0,r3h
    /* 08e6: 2b 17       */ mov.b       @DAT_FF17:8,r3l
    /* 08e8: 1d 30       */ cmp.w       r3,r0
    /* 08ea: 43 06       */ bls         LBL_08F2
    /* 08ec: 2a 14       */ mov.b       @DAT_FF14:8,r2l
    /* 08ee: 3a 13       */ mov.b       r2l,@DAT_FF13:8
    /* 08f0: 40 46       */ bra         LBL_0938
LBL_08F2:
    /* 08f2: 2a 13       */ mov.b       @DAT_FF13:8,r2l
    /* 08f4: 1a 0a       */ dec.b       r2l
    /* 08f6: 3a 13       */ mov.b       r2l,@DAT_FF13:8
    /* 08f8: 46 3e       */ bne         LBL_0938
    /* 08fa: 79 00 00 08 */ mov.w       #0x8,r0
    /* 08fe: 6b 03 fd da */ mov.w       @DAT_FDDA:16,r3
    /* 0902: 47 04       */ beq         LBL_0908
    /* 0904: 79 00 00 08 */ mov.w       #0x8,r0
LBL_0908:
    /* 0908: 6b 80 fd d8 */ mov.w       r0,@DAT_FDD8:16
    /* 090c: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 090e: 7f 0c 72 50 */ bclr        #0x5,@DAT_FF0C:8
    /* 0912: 7f 0c 70 60 */ bset        #0x6,@DAT_FF0C:8
    /* 0916: f0 20       */ mov.b       #0x20,r0h
    /* 0918: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 091a: 34 34       */ mov.b       r4h,@DAT_FF34:8
    /* 091c: 79 00 00 00 */ mov.w       #0x0,r0
    /* 0920: 6b 80 ff 4e */ mov.w       r0,@DAT_FF4E:16
    /* 0924: 7f 03 72 10 */ bclr        #0x1,@DAT_FF03:8
    /* 0928: 7e 11 73 50 */ btst        #0x5,@DAT_FF11:8
    /* 092c: 46 06       */ bne         LBL_0934
    /* 092e: fb 31       */ mov.b       #0x31,r3l
    /* 0930: 6a 8b 80 19 */ mov.b       r3l,@DAT_8019:16
LBL_0934:
    /* 0934: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_0938:
    /* 0938: 6b 00 fd 8c */ mov.w       @DAT_FD8C:16,r0
    /* 093c: 19 40       */ sub.w       r4,r0
    /* 093e: 46 06       */ bne         LBL_0946
    /* 0940: 7f 03 70 30 */ bset        #0x3,@DAT_FF03:8
    /* 0944: 40 04       */ bra         LBL_094A
LBL_0946:
    /* 0946: 6b 80 fd 8c */ mov.w       r0,@DAT_FD8C:16
LBL_094A:
    /* 094a: 20 2c       */ mov.b       @DAT_FF2C:8,r0h
    /* 094c: 4b 04       */ bmi         LBL_0952
    /* 094e: 0a 00       */ inc         r0h
    /* 0950: 30 2c       */ mov.b       r0h,@DAT_FF2C:8
LBL_0952:
    /* 0952: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_0956:
    /* 0956: 7e 04 73 40 */ btst        #0x4,@DAT_FF04:8
    /* 095a: 46 64       */ bne         LBL_09C0
    /* 095c: 7e 10 73 00 */ btst        #0x0,@DAT_FF10:8
    /* 0960: 46 4a       */ bne         LBL_09AC
    /* 0962: 7e 42 73 60 */ btst        #0x6,@DAT_FF42:8
    /* 0966: 46 44       */ bne         LBL_09AC
    /* 0968: 6b 00 fd da */ mov.w       @DAT_FDDA:16,r0
    /* 096c: 47 04       */ beq         LBL_0972
    /* 096e: 5a 00 09 ac */ jmp         @LBL_09AC:24
LBL_0972:
    /* 0972: 7e 00 73 30 */ btst        #0x3,@DAT_FF00:8
    /* 0976: 47 04       */ beq         LBL_097C
    /* 0978: 5a 00 09 ac */ jmp         @LBL_09AC:24
LBL_097C:
    /* 097c: 2b 34       */ mov.b       @DAT_FF34:8,r3l
    /* 097e: ab 02       */ cmp.b       #0x2,r3l
    /* 0980: 4b 06       */ bmi         LBL_0988
    /* 0982: 7e 11 73 50 */ btst        #0x5,@DAT_FF11:8
    /* 0986: 47 38       */ beq         LBL_09C0
LBL_0988:
    /* 0988: 2b 1a       */ mov.b       @DAT_FF1A:8,r3l
    /* 098a: f3 00       */ mov.b       #0x0,r3h
    /* 098c: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 0990: 6b 01 fd b2 */ mov.w       @DAT_FDB2:16,r1
    /* 0994: 09 10       */ add.w       r1,r0
    /* 0996: 11 80       */ shar.b      r0h
    /* 0998: 13 08       */ rotxr.b     r0l
    /* 099a: 79 01 00 00 */ mov.w       #0x0,r1
    /* 099e: 1d 10       */ cmp.w       r1,r0
    /* 09a0: 4a 06       */ bpl         LBL_09A8
    /* 09a2: 09 30       */ add.w       r3,r0
    /* 09a4: 4a 06       */ bpl         LBL_09AC
    /* 09a6: 40 18       */ bra         LBL_09C0
LBL_09A8:
    /* 09a8: 1d 30       */ cmp.w       r3,r0
    /* 09aa: 42 14       */ bhi         LBL_09C0
LBL_09AC:
    /* 09ac: 7e 11 73 00 */ btst        #0x0,@DAT_FF11:8
    /* 09b0: 46 0a       */ bne         LBL_09BC
    /* 09b2: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 09b6: e0 f7       */ and.b       #0xf7,r0h
    /* 09b8: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
LBL_09BC:
    /* 09bc: 5a 00 09 fa */ jmp         @LBL_09FA:24
LBL_09C0:
    /* 09c0: 7e 0c 73 40 */ btst        #0x4,@DAT_FF0C:8
    /* 09c4: 46 0e       */ bne         LBL_09D4
    /* 09c6: 7f 06 70 60 */ bset        #0x6,@DAT_FF06:8
    /* 09ca: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 09ce: c0 08       */ or.b        #0x8,r0h
    /* 09d0: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
LBL_09D4:
    /* 09d4: 20 14       */ mov.b       @DAT_FF14:8,r0h
    /* 09d6: 30 13       */ mov.b       r0h,@DAT_FF13:8
    /* 09d8: 79 00 70 3f */ mov.w       #0x703f,r0
    /* 09dc: 6b 80 fd 8c */ mov.w       r0,@DAT_FD8C:16
    /* 09e0: 79 00 01 40 */ mov.w       #0x140,r0
    /* 09e4: 7e 0c 73 40 */ btst        #0x4,@DAT_FF0C:8
    /* 09e8: 47 04       */ beq         LBL_09EE
    /* 09ea: 79 00 03 20 */ mov.w       #0x320,r0
LBL_09EE:
    /* 09ee: 6b 80 fd d8 */ mov.w       r0,@DAT_FDD8:16
    /* 09f2: 34 2c       */ mov.b       r4h,@DAT_FF2C:8
    /* 09f4: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 09f6: f0 40       */ mov.b       #0x40,r0h
    /* 09f8: 30 00       */ mov.b       r0h,@DAT_FF00:8
LBL_09FA:
    /* 09fa: 7f 91 72 70 */ bclr        #0x7,@REG_TCSR:8
    /* 09fe: 6b 00 fd 80 */ mov.w       @DAT_FD80:16,r0
    /* 0a02: 6b 80 fd 82 */ mov.w       r0,@DAT_FD82:16
    /* 0a06: 20 04       */ mov.b       @DAT_FF04:8,r0h
    /* 0a08: 30 05       */ mov.b       r0h,@DAT_FF05:8
    /* 0a0a: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 0a0e: 6b 80 fd b2 */ mov.w       r0,@DAT_FDB2:16
    /* 0a12: 7f 97 72 40 */ bclr        #0x4,@REG_TOCR:8
    /* 0a16: 6d 75       */ mov.w       @r7+,r5
    /* 0a18: 6d 73       */ mov.w       @r7+,r3
    /* 0a1a: 6d 72       */ mov.w       @r7+,r2
    /* 0a1c: 6d 71       */ mov.w       @r7+,r1
    /* 0a1e: 6d 70       */ mov.w       @r7+,r0
    /* 0a20: 56 70       */ rte

glabel FUNC_0A22
    /* 0a22: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 0a26: 4a 06       */ bpl         LBL_0A2E
    /* 0a28: 17 00       */ not.b       r0h
    /* 0a2a: 17 08       */ not.b       r0l
    /* 0a2c: 09 40       */ add.w       r4,r0
LBL_0A2E:
    /* 0a2e: 79 03 00 50 */ mov.w       #0x50,r3
    /* 0a32: 1d 30       */ cmp.w       r3,r0
    /* 0a34: 45 0a       */ bcs         LBL_0A40
    /* 0a36: 79 00 00 00 */ mov.w       #0x0,r0
    /* 0a3a: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 0a3e: 54 70       */ rts
LBL_0A40:
    /* 0a40: 6b 00 ff 5e */ mov.w       @DAT_FF5E:16,r0
    /* 0a44: 6b 80 ff 5c */ mov.w       r0,@DAT_FF5C:16
    /* 0a48: 6b 00 ff 50 */ mov.w       @DAT_FF50:16,r0
    /* 0a4c: 6b 03 ff 54 */ mov.w       @DAT_FF54:16,r3
    /* 0a50: 09 30       */ add.w       r3,r0
    /* 0a52: 11 80       */ shar.b      r0h
    /* 0a54: 13 08       */ rotxr.b     r0l
    /* 0a56: 6b 80 ff 54 */ mov.w       r0,@DAT_FF54:16
    /* 0a5a: 7e 03 73 00 */ btst        #0x0,@DAT_FF03:8
    /* 0a5e: 47 06       */ beq         LBL_0A66
    /* 0a60: 7f 03 72 00 */ bclr        #0x0,@DAT_FF03:8
    /* 0a64: 54 70       */ rts
LBL_0A66:
    /* 0a66: 7f 03 70 00 */ bset        #0x0,@DAT_FF03:8
    /* 0a6a: a0 00       */ cmp.b       #0x0,r0h
    /* 0a6c: 4a 0c       */ bpl         LBL_0A7A
    /* 0a6e: 79 03 ff 81 */ mov.w       #0xff81,r3
    /* 0a72: 1d 30       */ cmp.w       r3,r0
    /* 0a74: 44 0e       */ bcc         LBL_0A84
    /* 0a76: 0d 30       */ mov.w       r3,r0
    /* 0a78: 40 0a       */ bra         LBL_0A84
LBL_0A7A:
    /* 0a7a: 79 03 00 7f */ mov.w       #0x7f,r3
    /* 0a7e: 1d 30       */ cmp.w       r3,r0
    /* 0a80: 45 02       */ bcs         LBL_0A84
    /* 0a82: 0d 30       */ mov.w       r3,r0
LBL_0A84:
    /* 0a84: 6b 80 ff 52 */ mov.w       r0,@DAT_FF52:16
    /* 0a88: 6b 00 ff 5c */ mov.w       @DAT_FF5C:16,r0
    /* 0a8c: 6b 02 ff 52 */ mov.w       @DAT_FF52:16,r2
    /* 0a90: 0d 03       */ mov.w       r0,r3
    /* 0a92: 09 20       */ add.w       r2,r0
    /* 0a94: 6b 02 ff 58 */ mov.w       @DAT_FF58:16,r2
    /* 0a98: 6b 80 ff 58 */ mov.w       r0,@DAT_FF58:16
    /* 0a9c: 09 20       */ add.w       r2,r0
    /* 0a9e: 11 80       */ shar.b      r0h
    /* 0aa0: 13 08       */ rotxr.b     r0l
    /* 0aa2: 19 30       */ sub.w       r3,r0
    /* 0aa4: 6b 03 ff 5a */ mov.w       @DAT_FF5A:16,r3
    /* 0aa8: 10 0b       */ shll.b      r3l
    /* 0aaa: 12 03       */ rotxl.b     r3h
    /* 0aac: 10 0b       */ shll.b      r3l
    /* 0aae: 12 03       */ rotxl.b     r3h
    /* 0ab0: 09 30       */ add.w       r3,r0
    /* 0ab2: 4b 08       */ bmi         LBL_0ABC
    /* 0ab4: fb 05       */ mov.b       #0x5,r3l
    /* 0ab6: 51 b0       */ divxu.b     r3l,r0
    /* 0ab8: 0c 40       */ mov.b       r4h,r0h
    /* 0aba: 40 10       */ bra         LBL_0ACC
LBL_0ABC:
    /* 0abc: 17 00       */ not.b       r0h
    /* 0abe: 17 08       */ not.b       r0l
    /* 0ac0: 09 40       */ add.w       r4,r0
    /* 0ac2: fb 05       */ mov.b       #0x5,r3l
    /* 0ac4: 51 b0       */ divxu.b     r3l,r0
    /* 0ac6: f0 ff       */ mov.b       #0xff,r0h
    /* 0ac8: 17 08       */ not.b       r0l
    /* 0aca: 09 40       */ add.w       r4,r0
LBL_0ACC:
    /* 0acc: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 0ad0: 54 70       */ rts

glabel FUNC_0AD2
    /* 0ad2: 20 2c       */ mov.b       @DAT_FF2C:8,r0h
    /* 0ad4: a0 07       */ cmp.b       #0x7,r0h
    /* 0ad6: 43 52       */ bls         LBL_0B2A
    /* 0ad8: 6b 02 fd b0 */ mov.w       @DAT_FDB0:16,r2
    /* 0adc: 6b 00 ff 5a */ mov.w       @DAT_FF5A:16,r0
    /* 0ae0: 09 02       */ add.w       r0,r2
    /* 0ae2: 4b 0c       */ bmi         LBL_0AF0
    /* 0ae4: 79 00 00 20 */ mov.w       #0x20,r0
    /* 0ae8: 1d 02       */ cmp.w       r0,r2
    /* 0aea: 4f 0e       */ ble         LBL_0AFA
    /* 0aec: 0c 8a       */ mov.b       r0l,r2l
    /* 0aee: 40 0a       */ bra         LBL_0AFA
LBL_0AF0:
    /* 0af0: 79 00 ff e0 */ mov.w       #0xffe0,r0
    /* 0af4: 1d 02       */ cmp.w       r0,r2
    /* 0af6: 4c 02       */ bge         LBL_0AFA
    /* 0af8: 0c 8a       */ mov.b       r0l,r2l
LBL_0AFA:
    /* 0afa: 6b 00 fd a8 */ mov.w       @DAT_FDA8:16,r0
    /* 0afe: 22 32       */ mov.b       @DAT_FF32:8,r2h
    /* 0b00: aa 00       */ cmp.b       #0x0,r2l
    /* 0b02: 4b 06       */ bmi         LBL_0B0A
    /* 0b04: 50 22       */ mulxu.b     r2h,r2
    /* 0b06: 09 20       */ add.w       r2,r0
    /* 0b08: 40 06       */ bra         LBL_0B10
LBL_0B0A:
    /* 0b0a: 17 8a       */ neg.b       r2l
    /* 0b0c: 50 22       */ mulxu.b     r2h,r2
    /* 0b0e: 19 20       */ sub.w       r2,r0
LBL_0B10:
    /* 0b10: 79 02 e0 00 */ mov.w       #0xe000,r2
    /* 0b14: 1d 20       */ cmp.w       r2,r0
    /* 0b16: 45 04       */ bcs         LBL_0B1C
    /* 0b18: 0d 20       */ mov.w       r2,r0
    /* 0b1a: 40 0a       */ bra         LBL_0B26
LBL_0B1C:
    /* 0b1c: 79 02 20 00 */ mov.w       #0x2000,r2
    /* 0b20: 1d 20       */ cmp.w       r2,r0
    /* 0b22: 44 02       */ bcc         LBL_0B26
    /* 0b24: 0d 20       */ mov.w       r2,r0
LBL_0B26:
    /* 0b26: 6b 80 fd a8 */ mov.w       r0,@DAT_FDA8:16
LBL_0B2A:
    /* 0b2a: 54 70       */ rts

glabel FUNC_0B2C
    /* 0b2c: 79 00 00 00 */ mov.w       #0x0,r0
    /* 0b30: 6b 80 ff 4e */ mov.w       r0,@DAT_FF4E:16
    /* 0b34: 7f 03 72 10 */ bclr        #0x1,@DAT_FF03:8
    /* 0b38: 7f 0c 72 60 */ bclr        #0x6,@DAT_FF0C:8
    /* 0b3c: 7f 0d 72 20 */ bclr        #0x2,@DAT_FF0D:8
    /* 0b40: f0 28       */ mov.b       #0x28,r0h
    /* 0b42: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 0b44: 6b 00 fd 88 */ mov.w       @DAT_FD88:16,r0
    /* 0b48: 5e 00 0c ac */ jsr         @FUNC_0CAC:24
    /* 0b4c: 20 44       */ mov.b       @DAT_FF44:8,r0h
    /* 0b4e: 28 45       */ mov.b       @DAT_FF45:8,r0l
    /* 0b50: 1c 08       */ cmp.b       r0h,r0l
    /* 0b52: 47 1a       */ beq         LBL_0B6E
    /* 0b54: 04 80       */ orc         #CCR_I,ccr              // Disable interrupts?
    /* 0b56: 5e 00 0e e2 */ jsr         @FUNC_0EE2:24
    /* 0b5a: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 0b5e: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
    /* 0b62: 06 7f       */ andc        #(~CCR_I & 0xFF),ccr    // Re-enable interrupts?
LBL_0B64:
    /* 0b64: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 0b68: 46 fa       */ bne         LBL_0B64
    /* 0b6a: 7f 10 70 20 */ bset        #0x2,@DAT_FF10:8
LBL_0B6E:
    /* 0b6e: 7f 03 72 30 */ bclr        #0x3,@DAT_FF03:8
    /* 0b72: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 0b76: 5e 00 0b aa */ jsr         @FUNC_0BAA:24
    /* 0b7a: 44 02       */ bcc         LBL_0B7E
    /* 0b7c: 54 70       */ rts
LBL_0B7E:
    /* 0b7e: 5e 00 0b 88 */ jsr         @FUNC_0B88:24
    /* 0b82: f0 84       */ mov.b       #0x84,r0h
    /* 0b84: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 0b86: 54 70       */ rts
glabel FUNC_0B88
    /* 0b88: 20 44       */ mov.b       @DAT_FF44:8,r0h
    /* 0b8a: 46 1c       */ bne         LBL_0BA8
    /* 0b8c: 6b 00 fd 88 */ mov.w       @DAT_FD88:16,r0
    /* 0b90: 79 03 01 05 */ mov.w       #0x105,r3
    /* 0b94: 1d 30       */ cmp.w       r3,r0
    /* 0b96: 42 06       */ bhi         LBL_0B9E
    /* 0b98: 6a 08 60 03 */ mov.b       @DAT_6002+1:16,r0l
    /* 0b9c: 40 04       */ bra         LBL_0BA2
LBL_0B9E:
    /* 0b9e: 6a 08 fb 80 */ mov.b       @DAT_FB80:16,r0l
LBL_0BA2:
    /* 0ba2: f0 00       */ mov.b       #0x0,r0h
    /* 0ba4: 5e 00 47 f4 */ jsr         @FUNC_47F4:24
LBL_0BA8:
    /* 0ba8: 54 70       */ rts

glabel FUNC_0BAA
    /* 0baa: 6a 03 fd e3 */ mov.b       @DAT_FDE3:16,r3h
    /* 0bae: 2b 1d       */ mov.b       @DAT_FF1D:8,r3l
    /* 0bb0: 1c 3b       */ cmp.b       r3h,r3l
    /* 0bb2: 46 04       */ bne         LBL_0BB8
    /* 0bb4: 5a 00 0c 6c */ jmp         @LBL_0C6C:24
LBL_0BB8:
    /* 0bb8: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_0BBC:
    /* 0bbc: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 0bc0: 46 fa       */ bne         LBL_0BBC
    /* 0bc2: 5e 00 47 76 */ jsr         @FUNC_4776:24
    /* 0bc6: 04 80       */ orc         #CCR_I,ccr
    /* 0bc8: 6b 00 fd a4 */ mov.w       @DAT_FDA4:16,r0
    /* 0bcc: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 0bd0: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 0bd4: 7d 10 72 10 */ bclr        #0x1,@r1
    /* 0bd8: 5e 00 1b 06 */ jsr         @FUNC_1B06:24
    /* 0bdc: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 0be0: 46 34       */ bne         LBL_0C16
    /* 0be2: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 0be6: 7d 10 70 20 */ bset        #0x2,@r1
    /* 0bea: 5e 00 47 22 */ jsr         @FUNC_4722:24
    /* 0bee: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 0bf2: 7d 10 72 20 */ bclr        #0x2,@r1
    /* 0bf6: f0 c8       */ mov.b       #0xc8,r0h
    /* 0bf8: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
LBL_0BFC:
    /* 0bfc: 6a 00 80 0a */ mov.b       @DAT_800A:16,r0h
    /* 0c00: e0 60       */ and.b       #0x60,r0h
    /* 0c02: a0 60       */ cmp.b       #0x60,r0h
    /* 0c04: 47 1e       */ beq         LBL_0C24
    /* 0c06: 5e 00 47 22 */ jsr         @FUNC_4722:24
    /* 0c0a: 6a 00 fd 95 */ mov.b       @DAT_FD95:16,r0h
    /* 0c0e: 1a 00       */ dec.b       r0h
    /* 0c10: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
    /* 0c14: 46 e6       */ bne         LBL_0BFC
LBL_0C16:
    /* 0c16: 06 7f       */ andc        #(~CCR_I & 0xFF),ccr
    /* 0c18: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 0c1c: 7f 03 70 40 */ bset        #0x4,@DAT_FF03:8
    /* 0c20: 04 01       */ orc         #CCR_C,ccr
    /* 0c22: 54 70       */ rts
LBL_0C24:
    /* 0c24: 06 7f       */ andc        #(~CCR_I & 0xFF),ccr
    /* 0c26: f0 c8       */ mov.b       #0xc8,r0h
    /* 0c28: 6a 80 fd 96 */ mov.b       r0h,@DAT_FD96:16
LBL_0C2C:
    /* 0c2c: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_0C30:
    /* 0c30: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 0c34: 46 fa       */ bne         LBL_0C30
    /* 0c36: 5e 00 21 b0 */ jsr         @FUNC_21B0:24
    /* 0c3a: 44 0e       */ bcc         LBL_0C4A
    /* 0c3c: 6a 0b fd 96 */ mov.b       @DAT_FD96:16,r3l
    /* 0c40: 1a 0b       */ dec.b       r3l
    /* 0c42: 6a 8b fd 96 */ mov.b       r3l,@DAT_FD96:16
    /* 0c46: 46 e4       */ bne         LBL_0C2C
    /* 0c48: 40 cc       */ bra         LBL_0C16
LBL_0C4A:
    /* 0c4a: 6b 80 fd 84 */ mov.w       r0,@DAT_FD84:16
    /* 0c4e: 0d 03       */ mov.w       r0,r3
    /* 0c50: 10 0b       */ shll.b      r3l
    /* 0c52: 12 03       */ rotxl.b     r3h
    /* 0c54: 10 0b       */ shll.b      r3l
    /* 0c56: 12 03       */ rotxl.b     r3h
    /* 0c58: 6b 83 fd 86 */ mov.w       r3,@DAT_FD86:16
    /* 0c5c: f0 40       */ mov.b       #0x40,r0h
    /* 0c5e: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 0c60: 6b 00 fd a4 */ mov.w       @DAT_FDA4:16,r0
    /* 0c64: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 0c68: 7f bb 70 00 */ bset        #0x0,@REG_P6DR:8
LBL_0C6C:
    /* 0c6c: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 0c6e: 54 70       */ rts

glabel LBL_0C70 // Unused?
    /* 0c70: f0 05       */ mov.b       #0x5,r0h
    /* 0c72: 6a 80 fd ea */ mov.b       r0h,@DAT_FDEA:16
    /* 0c76: 5e 00 0c 84 */ jsr         @FUNC_0C84:24
    /* 0c7a: 44 04       */ bcc         LBL_0C80
    /* 0c7c: 04 01       */ orc         #CCR_C,ccr
    /* 0c7e: 54 70       */ rts
LBL_0C80:
    /* 0c80: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 0c82: 54 70       */ rts

glabel FUNC_0C84
    /* 0c84: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 0c86: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_0C8A:
    /* 0c8a: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 0c8e: 46 fa       */ bne         LBL_0C8A
    /* 0c90: 7e 04 73 30 */ btst        #0x3,@DAT_FF04:8
    /* 0c94: 46 04       */ bne         LBL_0C9A
    /* 0c96: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 0c98: 54 70       */ rts
LBL_0C9A:
    /* 0c9a: 6a 00 fd ea */ mov.b       @DAT_FDEA:16,r0h
    /* 0c9e: 1a 00       */ dec.b       r0h
    /* 0ca0: 47 06       */ beq         LBL_0CA8
    /* 0ca2: 6a 80 fd ea */ mov.b       r0h,@DAT_FDEA:16
    /* 0ca6: 40 dc       */ bra         FUNC_0C84
LBL_0CA8:
    /* 0ca8: 04 01       */ orc         #CCR_C,ccr
    /* 0caa: 54 70       */ rts

glabel FUNC_0CAC
    /* 0cac: 79 03 01 00 */ mov.w       #0x100,r3
    /* 0cb0: 19 30       */ sub.w       r3,r0
    /* 0cb2: 44 04       */ bcc         LBL_0CB8
    /* 0cb4: fb 00       */ mov.b       #0x0,r3l
    /* 0cb6: 40 18       */ bra         LBL_0CD0
LBL_0CB8:
    /* 0cb8: fb 00       */ mov.b       #0x0,r3l
    /* 0cba: 79 01 60 98 */ mov.w       #LBL_6098,r1
LBL_0CBE:
    /* 0cbe: 69 15       */ mov.w       @r1,r5
    /* 0cc0: 1d 50       */ cmp.w       r5,r0
    /* 0cc2: 44 02       */ bcc         LBL_0CC6
    /* 0cc4: 40 0a       */ bra         LBL_0CD0
LBL_0CC6:
    /* 0cc6: 0b 81       */ adds        #2,r1
    /* 0cc8: 0a 0b       */ inc         r3l
    /* 0cca: ab 07       */ cmp.b       #0x7,r3l
    /* 0ccc: 44 02       */ bcc         LBL_0CD0
    /* 0cce: 40 ee       */ bra         LBL_0CBE
LBL_0CD0:
    /* 0cd0: 28 1d       */ mov.b       @DAT_FF1D:8,r0l
    /* 0cd2: 08 b8       */ add.b       r3l,r0l
    /* 0cd4: 38 44       */ mov.b       r0l,@DAT_FF44:8
    /* 0cd6: 54 70       */ rts

glabel FUNC_0CD8
    /* 0cd8: 6b 01 fd bc */ mov.w       @DAT_FDBC:16,r1
    /* 0cdc: a0 00       */ cmp.b       #0x0,r0h
    /* 0cde: 47 1c       */ beq         LBL_0CFC
    /* 0ce0: 4a 1a       */ bpl         LBL_0CFC
    /* 0ce2: 79 03 c8 00 */ mov.w       #0xc800,r3
    /* 0ce6: 1d 30       */ cmp.w       r3,r0
    /* 0ce8: 45 08       */ bcs         LBL_0CF2
    /* 0cea: 69 10       */ mov.w       @r1,r0
    /* 0cec: 17 00       */ not.b       r0h
    /* 0cee: 17 88       */ neg.b       r0l
    /* 0cf0: 54 70       */ rts
LBL_0CF2:
    /* 0cf2: 79 03 00 14 */ mov.w       #0x14,r3
    /* 0cf6: 09 31       */ add.w       r3,r1
    /* 0cf8: 69 10       */ mov.w       @r1,r0
    /* 0cfa: 54 70       */ rts
LBL_0CFC:
    /* 0cfc: 0c 4a       */ mov.b       r4h,r2l
    /* 0cfe: a0 00       */ cmp.b       #0x0,r0h
    /* 0d00: 46 18       */ bne         LBL_0D1A
    /* 0d02: 10 08       */ shll.b      r0l
    /* 0d04: 44 08       */ bcc         LBL_0D0E
    /* 0d06: 79 03 00 04 */ mov.w       #0x4,r3
    /* 0d0a: 09 31       */ add.w       r3,r1
    /* 0d0c: 40 32       */ bra         LBL_0D40
LBL_0D0E:
    /* 0d0e: 10 08       */ shll.b      r0l
    /* 0d10: 44 2e       */ bcc         LBL_0D40
    /* 0d12: 79 03 00 02 */ mov.w       #0x2,r3
    /* 0d16: 09 31       */ add.w       r3,r1
    /* 0d18: 40 26       */ bra         LBL_0D40
LBL_0D1A:
    /* 0d1a: 11 00       */ shlr.b      r0h
    /* 0d1c: 46 08       */ bne         LBL_0D26
    /* 0d1e: 79 03 00 06 */ mov.w       #0x6,r3
    /* 0d22: 09 31       */ add.w       r3,r1
    /* 0d24: 40 1a       */ bra         LBL_0D40
LBL_0D26:
    /* 0d26: 13 08       */ rotxr.b     r0l
    /* 0d28: 11 00       */ shlr.b      r0h
    /* 0d2a: 46 08       */ bne         LBL_0D34
    /* 0d2c: 79 03 00 08 */ mov.w       #0x8,r3
    /* 0d30: 09 31       */ add.w       r3,r1
    /* 0d32: 40 0c       */ bra         LBL_0D40
LBL_0D34:
    /* 0d34: 13 08       */ rotxr.b     r0l
    /* 0d36: 11 00       */ shlr.b      r0h
    /* 0d38: 46 18       */ bne         LBL_0D52
    /* 0d3a: 79 03 00 0a */ mov.w       #0xa,r3
    /* 0d3e: 09 31       */ add.w       r3,r1
LBL_0D40:
    /* 0d40: 6f 12 00 02 */ mov.w       @(0x2:16,r1),r2
    /* 0d44: 69 13       */ mov.w       @r1,r3
    /* 0d46: 19 32       */ sub.w       r3,r2
    /* 0d48: 50 a0       */ mulxu.b     r2l,r0
    /* 0d4a: 0c 08       */ mov.b       r0h,r0l
    /* 0d4c: f0 00       */ mov.b       #0x0,r0h
    /* 0d4e: 09 30       */ add.w       r3,r0
    /* 0d50: 54 70       */ rts
LBL_0D52:
    /* 0d52: 13 08       */ rotxr.b     r0l
    /* 0d54: 11 00       */ shlr.b      r0h
    /* 0d56: 46 08       */ bne         LBL_0D60
    /* 0d58: 79 03 00 0c */ mov.w       #0xc,r3
    /* 0d5c: 09 31       */ add.w       r3,r1
    /* 0d5e: 40 0c       */ bra         LBL_0D6C
LBL_0D60:
    /* 0d60: 13 08       */ rotxr.b     r0l
    /* 0d62: 11 00       */ shlr.b      r0h
    /* 0d64: 46 20       */ bne         LBL_0D86
    /* 0d66: 79 03 00 0e */ mov.w       #0xe,r3
    /* 0d6a: 09 31       */ add.w       r3,r1
LBL_0D6C:
    /* 0d6c: 6f 12 00 02 */ mov.w       @(0x2:16,r1),r2
    /* 0d70: 69 13       */ mov.w       @r1,r3
    /* 0d72: 19 32       */ sub.w       r3,r2
    /* 0d74: 11 02       */ shlr.b      r2h
    /* 0d76: 13 0a       */ rotxr.b     r2l
    /* 0d78: 50 a0       */ mulxu.b     r2l,r0
    /* 0d7a: 0c 08       */ mov.b       r0h,r0l
    /* 0d7c: f0 00       */ mov.b       #0x0,r0h
    /* 0d7e: 10 08       */ shll.b      r0l
    /* 0d80: 12 00       */ rotxl.b     r0h
    /* 0d82: 09 30       */ add.w       r3,r0
    /* 0d84: 54 70       */ rts
LBL_0D86:
    /* 0d86: 13 08       */ rotxr.b     r0l
    /* 0d88: 11 00       */ shlr.b      r0h
    /* 0d8a: 46 08       */ bne         LBL_0D94
    /* 0d8c: 79 03 00 10 */ mov.w       #0x10,r3
    /* 0d90: 09 31       */ add.w       r3,r1
    /* 0d92: 40 18       */ bra         LBL_0DAC
LBL_0D94:
    /* 0d94: 13 08       */ rotxr.b     r0l
    /* 0d96: 11 00       */ shlr.b      r0h
    /* 0d98: 46 08       */ bne         LBL_0DA2
    /* 0d9a: 79 03 00 12 */ mov.w       #0x12,r3
    /* 0d9e: 09 31       */ add.w       r3,r1
    /* 0da0: 40 0a       */ bra         LBL_0DAC
LBL_0DA2:
    /* 0da2: 13 08       */ rotxr.b     r0l
    /* 0da4: 11 00       */ shlr.b      r0h
    /* 0da6: 79 03 00 14 */ mov.w       #0x14,r3
    /* 0daa: 09 31       */ add.w       r3,r1
LBL_0DAC:
    /* 0dac: 6f 12 00 02 */ mov.w       @(0x2:16,r1),r2
    /* 0db0: 69 13       */ mov.w       @r1,r3
    /* 0db2: 19 32       */ sub.w       r3,r2
    /* 0db4: 11 02       */ shlr.b      r2h
    /* 0db6: 13 0a       */ rotxr.b     r2l
    /* 0db8: 11 02       */ shlr.b      r2h
    /* 0dba: 13 0a       */ rotxr.b     r2l
    /* 0dbc: 50 a0       */ mulxu.b     r2l,r0
    /* 0dbe: 0c 08       */ mov.b       r0h,r0l
    /* 0dc0: f0 00       */ mov.b       #0x0,r0h
    /* 0dc2: 10 08       */ shll.b      r0l
    /* 0dc4: 12 00       */ rotxl.b     r0h
    /* 0dc6: 10 08       */ shll.b      r0l
    /* 0dc8: 12 00       */ rotxl.b     r0h
    /* 0dca: 09 30       */ add.w       r3,r0
    /* 0dcc: 54 70       */ rts

glabel FUNC_0DCE
    /* 0dce: 79 03 01 00 */ mov.w       #0x100,r3
    /* 0dd2: 19 30       */ sub.w       r3,r0
    /* 0dd4: 4a 08       */ bpl         LBL_0DDE
    /* 0dd6: 6a 08 fd e0 */ mov.b       @DAT_FDE0:16,r0l
    /* 0dda: 0c 40       */ mov.b       r4h,r0h
    /* 0ddc: 54 70       */ rts
LBL_0DDE:
    /* 0dde: 11 00       */ shlr.b      r0h
    /* 0de0: 13 08       */ rotxr.b     r0l
    /* 0de2: 11 00       */ shlr.b      r0h
    /* 0de4: 13 08       */ rotxr.b     r0l
    /* 0de6: 11 00       */ shlr.b      r0h
    /* 0de8: 13 08       */ rotxr.b     r0l
    /* 0dea: 6a 0a fd e1 */ mov.b       @DAT_FDE1:16,r2l
    /* 0dee: 0c 42       */ mov.b       r4h,r2h
    /* 0df0: 6a 0b fd e0 */ mov.b       @DAT_FDE0:16,r3l
    /* 0df4: 0c 43       */ mov.b       r4h,r3h
    /* 0df6: 19 32       */ sub.w       r3,r2
    /* 0df8: 4b 14       */ bmi         LBL_0E0E
    /* 0dfa: 50 82       */ mulxu.b     r0l,r2
    /* 0dfc: 10 8a       */ shal.b      r2l
    /* 0dfe: 12 02       */ rotxl.b     r2h
    /* 0e00: 10 8a       */ shal.b      r2l
    /* 0e02: 12 02       */ rotxl.b     r2h
    /* 0e04: 6a 08 fd e0 */ mov.b       @DAT_FDE0:16,r0l
    /* 0e08: 08 28       */ add.b       r2h,r0l
    /* 0e0a: 0c 40       */ mov.b       r4h,r0h
    /* 0e0c: 54 70       */ rts
LBL_0E0E:
    /* 0e0e: 17 8a       */ neg.b       r2l
    /* 0e10: 50 82       */ mulxu.b     r0l,r2
    /* 0e12: 10 8a       */ shal.b      r2l
    /* 0e14: 12 02       */ rotxl.b     r2h
    /* 0e16: 10 8a       */ shal.b      r2l
    /* 0e18: 12 02       */ rotxl.b     r2h
    /* 0e1a: 6a 08 fd e0 */ mov.b       @DAT_FDE0:16,r0l
    /* 0e1e: 18 28       */ sub.b       r2h,r0l
    /* 0e20: 0c 40       */ mov.b       r4h,r0h
    /* 0e22: 54 70       */ rts

glabel FUNC_0E24
    /* 0e24: 6b 00 fd 82 */ mov.w       @DAT_FD82:16,r0
    /* 0e28: 0d 12       */ mov.w       r1,r2
    /* 0e2a: 6b 03 fd cc */ mov.w       @DAT_FDCC:16,r3
    /* 0e2e: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 0e32: 47 04       */ beq         LBL_0E38
    /* 0e34: 19 02       */ sub.w       r0,r2
    /* 0e36: 40 04       */ bra         LBL_0E3C
LBL_0E38:
    /* 0e38: 19 20       */ sub.w       r2,r0
    /* 0e3a: 0d 02       */ mov.w       r0,r2
LBL_0E3C:
    /* 0e3c: 1d 32       */ cmp.w       r3,r2
    /* 0e3e: 4e 10       */ bgt         LBL_0E50
    /* 0e40: 6b 03 fd ce */ mov.w       @DAT_FDCE:16,r3
    /* 0e44: 0b 82       */ adds        #2,r2
    /* 0e46: 1d 32       */ cmp.w       r3,r2
    /* 0e48: 4d 06       */ blt         LBL_0E50
    /* 0e4a: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 0e4c: 06 fc       */ andc        #(~(CCR_V | CCR_C) & 0xFF),ccr
    /* 0e4e: 54 70       */ rts
LBL_0E50:
    /* 0e50: 2b 33       */ mov.b       @DAT_FF33:8,r3l
    /* 0e52: ab 04       */ cmp.b       #0x4,r3l
    /* 0e54: 42 10       */ bhi         LBL_0E66
    /* 0e56: 0a 0b       */ inc         r3l
    /* 0e58: 3b 33       */ mov.b       r3l,@DAT_FF33:8
    /* 0e5a: ab 03       */ cmp.b       #0x3,r3l
    /* 0e5c: 4a 04       */ bpl         LBL_0E62
    /* 0e5e: 04 01       */ orc         #CCR_C,ccr
    /* 0e60: 54 70       */ rts
LBL_0E62:
    /* 0e62: 06 fc       */ andc        #(~(CCR_V | CCR_C) & 0xFF),ccr
    /* 0e64: 54 70       */ rts
LBL_0E66:
    /* 0e66: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 0e68: 04 03       */ orc         #(CCR_V | CCR_C),ccr
    /* 0e6a: 54 70       */ rts

glabel FUNC_0E6C
    /* 0e6c: 6b 00 fd 86 */ mov.w       @DAT_FD86:16,r0
    /* 0e70: 0d 12       */ mov.w       r1,r2
    /* 0e72: 1d 02       */ cmp.w       r0,r2
    /* 0e74: 47 12       */ beq         LBL_0E88
    /* 0e76: 4b 04       */ bmi         LBL_0E7C
    /* 0e78: 19 02       */ sub.w       r0,r2
    /* 0e7a: 40 04       */ bra         LBL_0E80
LBL_0E7C:
    /* 0e7c: 19 20       */ sub.w       r2,r0
    /* 0e7e: 0d 02       */ mov.w       r0,r2
LBL_0E80:
    /* 0e80: 6b 03 fd d8 */ mov.w       @DAT_FDD8:16,r3
    /* 0e84: 1d 32       */ cmp.w       r3,r2
    /* 0e86: 4c 06       */ bge         LBL_0E8E
LBL_0E88:
    /* 0e88: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 0e8a: 06 fc       */ andc        #(~(CCR_V | CCR_C) & 0xFF),ccr
    /* 0e8c: 54 70       */ rts
LBL_0E8E:
    /* 0e8e: 23 2c       */ mov.b       @DAT_FF2C:8,r3h
    /* 0e90: fb 00       */ mov.b       #0x0,r3l
    /* 0e92: a3 01       */ cmp.b       #0x1,r3h
    /* 0e94: 43 08       */ bls         LBL_0E9E
    /* 0e96: 2b 33       */ mov.b       @DAT_FF33:8,r3l
    /* 0e98: ab 05       */ cmp.b       #0x5,r3l
    /* 0e9a: 42 08       */ bhi         LBL_0EA4
    /* 0e9c: 0a 0b       */ inc         r3l
LBL_0E9E:
    /* 0e9e: 3b 33       */ mov.b       r3l,@DAT_FF33:8
    /* 0ea0: 04 01       */ orc         #CCR_C,ccr
    /* 0ea2: 54 70       */ rts
LBL_0EA4:
    /* 0ea4: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 0ea6: 04 03       */ orc         #(CCR_V | CCR_C),ccr
    /* 0ea8: 54 70       */ rts

glabel FUNC_0EAA
    /* 0eaa: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 0eae: 46 02       */ bne         LBL_0EB2
    /* 0eb0: 54 70       */ rts
LBL_0EB2:
    /* 0eb2: 79 03 00 14 */ mov.w       #0x14,r3
    /* 0eb6: 0d 02       */ mov.w       r0,r2
    /* 0eb8: 6b 80 fe 08 */ mov.w       r0,@DAT_FE08:16
    /* 0ebc: 4a 06       */ bpl         LBL_0EC4
    /* 0ebe: 09 30       */ add.w       r3,r0
    /* 0ec0: 4a 06       */ bpl         LBL_0EC8
    /* 0ec2: 40 0a       */ bra         LBL_0ECE
LBL_0EC4:
    /* 0ec4: 1d 30       */ cmp.w       r3,r0
    /* 0ec6: 42 06       */ bhi         LBL_0ECE
LBL_0EC8:
    /* 0ec8: 34 34       */ mov.b       r4h,@DAT_FF34:8
    /* 0eca: 0d 20       */ mov.w       r2,r0
    /* 0ecc: 54 70       */ rts
LBL_0ECE:
    /* 0ece: 20 34       */ mov.b       @DAT_FF34:8,r0h
    /* 0ed0: 0a 00       */ inc         r0h
    /* 0ed2: 30 34       */ mov.b       r0h,@DAT_FF34:8
    /* 0ed4: a0 02       */ cmp.b       #0x2,r0h
    /* 0ed6: 4a 06       */ bpl         LBL_0EDE
    /* 0ed8: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 0edc: 54 70       */ rts
LBL_0EDE:
    /* 0ede: 0d 20       */ mov.w       r2,r0
    /* 0ee0: 54 70       */ rts

glabel FUNC_0EE2
    /* 0ee2: 79 01 fb 80 */ mov.w       #0xfb80,r1
    /* 0ee6: 28 44       */ mov.b       @DAT_FF44:8,r0l
    /* 0ee8: 08 89       */ add.b       r0l,r1l
    /* 0eea: 0e 41       */ addx        r4h,r1h
    /* 0eec: f0 00       */ mov.b       #0x0,r0h
    /* 0eee: 79 03 00 09 */ mov.w       #0x9,r3
LBL_0EF2:
    /* 0ef2: 68 18       */ mov.b       @r1,r0l
    /* 0ef4: 6d f0       */ mov.w       r0,@-r7
    /* 0ef6: 5e 00 47 f4 */ jsr         @FUNC_47F4:24
    /* 0efa: 6d 70       */ mov.w       @r7+,r0
    /* 0efc: 79 03 00 09 */ mov.w       #0x9,r3
    /* 0f00: 09 31       */ add.w       r3,r1
    /* 0f02: 0a 00       */ inc         r0h
    /* 0f04: a0 0f       */ cmp.b       #0xf,r0h
    /* 0f06: 46 ea       */ bne         LBL_0EF2
    /* 0f08: 20 44       */ mov.b       @DAT_FF44:8,r0h
    /* 0f0a: 30 45       */ mov.b       r0h,@DAT_FF45:8
    /* 0f0c: 54 70       */ rts

/**
 *  void FUNC_0F0E(u8 r0l) {
 *      U8(0x800D) = r0l;
 *  }
 */
glabel FUNC_0F0E
    /* 0f0e: 6a 88 80 0d */ mov.b       r0l,@DAT_800D:16
    /* 0f12: 54 70       */ rts

glabel FUNC_0F14
    /* 0f14: 79 01 60 a6 */ mov.w       #0x60a6,r1
    /* 0f18: 28 44       */ mov.b       @DAT_FF44:8,r0l
    /* 0f1a: 2b 1d       */ mov.b       @DAT_FF1D:8,r3l
    /* 0f1c: 18 b8       */ sub.b       r3l,r0l
    /* 0f1e: 08 89       */ add.b       r0l,r1l
    /* 0f20: 91 00       */ addx        #0x0,r1h
    /* 0f22: 79 03 00 08 */ mov.w       #0x8,r3
    /* 0f26: 68 18       */ mov.b       @r1,r0l
    /* 0f28: 38 36       */ mov.b       r0l,@DAT_FF36:8
    /* 0f2a: 09 31       */ add.w       r3,r1
    /* 0f2c: 68 18       */ mov.b       @r1,r0l
    /* 0f2e: 38 37       */ mov.b       r0l,@DAT_FF37:8
    /* 0f30: 09 31       */ add.w       r3,r1
    /* 0f32: 68 18       */ mov.b       @r1,r0l
    /* 0f34: 38 38       */ mov.b       r0l,@DAT_FF38:8
    /* 0f36: 09 31       */ add.w       r3,r1
    /* 0f38: 68 18       */ mov.b       @r1,r0l
    /* 0f3a: 6a 88 fd e4 */ mov.b       r0l,@DAT_FDE4:16
    /* 0f3e: 2b 1d       */ mov.b       @DAT_FF1D:8,r3l
    /* 0f40: 46 06       */ bne         LBL_0F48
    /* 0f42: 79 01 ff 60 */ mov.w       #DAT_FF60,r1
    /* 0f46: 40 04       */ bra         LBL_0F4C
LBL_0F48:
    /* 0f48: 79 01 ff 68 */ mov.w       #DAT_FF68,r1
LBL_0F4C:
    /* 0f4c: 28 44       */ mov.b       @DAT_FF44:8,r0l
    /* 0f4e: 2b 1d       */ mov.b       @DAT_FF1D:8,r3l
    /* 0f50: 18 b8       */ sub.b       r3l,r0l
    /* 0f52: 08 89       */ add.b       r0l,r1l
    /* 0f54: 91 00       */ addx        #0x0,r1h
    /* 0f56: 68 18       */ mov.b       @r1,r0l
    /* 0f58: 6a 00 fd e5 */ mov.b       @DAT_FDE5:16,r0h
    /* 0f5c: 73 70       */ btst        #0x7,r0h
    /* 0f5e: 47 06       */ beq         LBL_0F66
    /* 0f60: e0 7f       */ and.b       #0x7f,r0h
    /* 0f62: 18 08       */ sub.b       r0h,r0l
    /* 0f64: 40 02       */ bra         LBL_0F68
LBL_0F66:
    /* 0f66: 08 08       */ add.b       r0h,r0l
LBL_0F68:
    /* 0f68: 38 30       */ mov.b       r0l,@DAT_FF30:8
    /* 0f6a: 54 70       */ rts

glabel LBL_0F6C // unused?
    /* 0f6c: f3 00       */ mov.b       #0x0,r3h
    /* 0f6e: 0c 0b       */ mov.b       r0h,r3l
    /* 0f70: 0c 80       */ mov.b       r0l,r0h
    /* 0f72: f8 00       */ mov.b       #0x0,r0l
    /* 0f74: 1d 13       */ cmp.w       r1,r3
    /* 0f76: 45 04       */ bcs         LBL_0F7C
    /* 0f78: 0c c0       */ mov.b       r4l,r0h
    /* 0f7a: 54 70       */ rts
LBL_0F7C:
    /* 0f7c: fd 08       */ mov.b       #0x8,r5l
LBL_0F7E:
    /* 0f7e: 10 88       */ shal.b      r0l
    /* 0f80: 12 00       */ rotxl.b     r0h
    /* 0f82: 12 0b       */ rotxl.b     r3l
    /* 0f84: 12 03       */ rotxl.b     r3h
    /* 0f86: 0a 08       */ inc         r0l
    /* 0f88: 19 13       */ sub.w       r1,r3
    /* 0f8a: 44 04       */ bcc         LBL_0F90
    /* 0f8c: 09 13       */ add.w       r1,r3
    /* 0f8e: 1a 08       */ dec.b       r0l
LBL_0F90:
    /* 0f90: 1a 0d       */ dec.b       r5l
    /* 0f92: 46 ea       */ bne         LBL_0F7E
    /* 0f94: 54 70       */ rts



LBL_0F96:
    /* 0f96: */ .word 0x0002
    /* 0f98: */ .word 0x0407
    /* 0f9a: */ .word 0x090b
    /* 0f9c: */ .word 0x0d0f
    /* 0f9e: */ .word 0x1214
    /* 0fa0: */ .word 0x1618
    /* 0fa2: */ .word 0x1a1c
    /* 0fa4: */ .word 0x1e20
    /* 0fa6: */ .word 0x2224
    /* 0fa8: */ .word 0x2627
    /* 0faa: */ .word 0x292b
    /* 0fac: */ .word 0x2c2e
    /* 0fae: */ .word 0x3031
    /* 0fb0: */ .word 0x3234
    /* 0fb2: */ .word 0x3536
    /* 0fb4: */ .word 0x3739
    /* 0fb6: */ .word 0x3a3a
    /* 0fb8: */ .word 0x3b3c
    /* 0fba: */ .word 0x3d3e
    /* 0fbc: */ .word 0x3e3f
    /* 0fbe: */ .word 0x3f3f
    /* 0fc0: */ .word 0x4040
    /* 0fc2: */ .word 0x4040
    /* 0fc4: */ .word 0x4040
    /* 0fc6: */ .word 0x403f
    /* 0fc8: */ .word 0x3f3f
    /* 0fca: */ .word 0x3e3e
    /* 0fcc: */ .word 0x3d3c
    /* 0fce: */ .word 0x3b3a
    /* 0fd0: */ .word 0x3a39
    /* 0fd2: */ .word 0x3736
    /* 0fd4: */ .word 0x3534
    /* 0fd6: */ .word 0x3231
    /* 0fd8: */ .word 0x302e
    /* 0fda: */ .word 0x2c2b
    /* 0fdc: */ .word 0x2927
    /* 0fde: */ .word 0x2624
    /* 0fe0: */ .word 0x2220
    /* 0fe2: */ .word 0x1e1c
    /* 0fe4: */ .word 0x1a18
    /* 0fe6: */ .word 0x1614
    /* 0fe8: */ .word 0x120f
    /* 0fea: */ .word 0x0d0b
    /* 0fec: */ .word 0x0907
    /* 0fee: */ .word 0x0402
    /* 0ff0: */ .word 0x00fe
    /* 0ff2: */ .word 0xfcf9
    /* 0ff4: */ .word 0xf7f5
    /* 0ff6: */ .word 0xf3f1
    /* 0ff8: */ .word 0xeeec
    /* 0ffa: */ .word 0xeae8
    /* 0ffc: */ .word 0xe6e4
    /* 0ffe: */ .word 0xe2e0
    /* 1000: */ .word 0xdedc
    /* 1002: */ .word 0xdad9
    /* 1004: */ .word 0xd7d5
    /* 1006: */ .word 0xd4d2
    /* 1008: */ .word 0xd0cf
    /* 100a: */ .word 0xcecc
    /* 100c: */ .word 0xcbca
    /* 100e: */ .word 0xc9c7
    /* 1010: */ .word 0xc6c6
    /* 1012: */ .word 0xc5c4
    /* 1014: */ .word 0xc3c2
    /* 1016: */ .word 0xc2c1
    /* 1018: */ .word 0xc1c1
    /* 101a: */ .word 0xc0c0
    /* 101c: */ .word 0xc0c0
    /* 101e: */ .word 0xc0c0
    /* 1020: */ .word 0xc0c1
    /* 1022: */ .word 0xc1c1
    /* 1024: */ .word 0xc2c2
    /* 1026: */ .word 0xc3c4
    /* 1028: */ .word 0xc5c6
    /* 102a: */ .word 0xc6c7
    /* 102c: */ .word 0xc9ca
    /* 102e: */ .word 0xcbcc
    /* 1030: */ .word 0xcecf
    /* 1032: */ .word 0xd0d2
    /* 1034: */ .word 0xd4d5
    /* 1036: */ .word 0xd7d9
    /* 1038: */ .word 0xdadc
    /* 103a: */ .word 0xdee0
    /* 103c: */ .word 0xe2e4
    /* 103e: */ .word 0xe6e8
    /* 1040: */ .word 0xeaec
    /* 1042: */ .word 0xeef1
    /* 1044: */ .word 0xf3f5
    /* 1046: */ .word 0xf7f9
    /* 1048: */ .word 0xfcfe

LBL_104A:
    /* 104a: */ .word 0x4040
    /* 104c: */ .word 0x4040
    /* 104e: */ .word 0x3f3f
    /* 1050: */ .word 0x3f3e
    /* 1052: */ .word 0x3e3d
    /* 1054: */ .word 0x3c3b
    /* 1056: */ .word 0x3a3a
    /* 1058: */ .word 0x3937
    /* 105a: */ .word 0x3635
    /* 105c: */ .word 0x3432
    /* 105e: */ .word 0x3130
    /* 1060: */ .word 0x2e2c
    /* 1062: */ .word 0x2b29
    /* 1064: */ .word 0x2726
    /* 1066: */ .word 0x2422
    /* 1068: */ .word 0x201e
    /* 106a: */ .word 0x1c1a
    /* 106c: */ .word 0x1816
    /* 106e: */ .word 0x1412
    /* 1070: */ .word 0x0f0d
    /* 1072: */ .word 0x0b09
    /* 1074: */ .word 0x0704
    /* 1076: */ .word 0x0200
    /* 1078: */ .word 0xfefc
    /* 107a: */ .word 0xf9f7
    /* 107c: */ .word 0xf5f3
    /* 107e: */ .word 0xf1ee
    /* 1080: */ .word 0xecea
    /* 1082: */ .word 0xe8e6
    /* 1084: */ .word 0xe4e2
    /* 1086: */ .word 0xe0de
    /* 1088: */ .word 0xdcda
    /* 108a: */ .word 0xd9d7
    /* 108c: */ .word 0xd5d4
    /* 108e: */ .word 0xd2d0
    /* 1090: */ .word 0xcfce
    /* 1092: */ .word 0xcccb
    /* 1094: */ .word 0xcac9
    /* 1096: */ .word 0xc7c6
    /* 1098: */ .word 0xc6c5
    /* 109a: */ .word 0xc4c3
    /* 109c: */ .word 0xc2c2
    /* 109e: */ .word 0xc1c1
    /* 10a0: */ .word 0xc1c0
    /* 10a2: */ .word 0xc0c0
    /* 10a4: */ .word 0xc0c0
    /* 10a6: */ .word 0xc0c0
    /* 10a8: */ .word 0xc1c1
    /* 10aa: */ .word 0xc1c2
    /* 10ac: */ .word 0xc2c3
    /* 10ae: */ .word 0xc4c5
    /* 10b0: */ .word 0xc6c6
    /* 10b2: */ .word 0xc7c9
    /* 10b4: */ .word 0xcacb
    /* 10b6: */ .word 0xccce
    /* 10b8: */ .word 0xcfd0
    /* 10ba: */ .word 0xd2d4
    /* 10bc: */ .word 0xd5d7
    /* 10be: */ .word 0xd9da
    /* 10c0: */ .word 0xdcde
    /* 10c2: */ .word 0xe0e2
    /* 10c4: */ .word 0xe4e6
    /* 10c6: */ .word 0xe8ea
    /* 10c8: */ .word 0xecee
    /* 10ca: */ .word 0xf1f3
    /* 10cc: */ .word 0xf5f7
    /* 10ce: */ .word 0xf9fc
    /* 10d0: */ .word 0xfe00
    /* 10d2: */ .word 0x0204
    /* 10d4: */ .word 0x0709
    /* 10d6: */ .word 0x0b0d
    /* 10d8: */ .word 0x0f12
    /* 10da: */ .word 0x1416
    /* 10dc: */ .word 0x181a
    /* 10de: */ .word 0x1c1e
    /* 10e0: */ .word 0x2022
    /* 10e2: */ .word 0x2426
    /* 10e4: */ .word 0x2729
    /* 10e6: */ .word 0x2b2c
    /* 10e8: */ .word 0x2e30
    /* 10ea: */ .word 0x3132
    /* 10ec: */ .word 0x3435
    /* 10ee: */ .word 0x3637
    /* 10f0: */ .word 0x393a
    /* 10f2: */ .word 0x3a3b
    /* 10f4: */ .word 0x3c3d
    /* 10f6: */ .word 0x3e3e
    /* 10f8: */ .word 0x3f3f
    /* 10fa: */ .word 0x3f40
    /* 10fc: */ .word 0x4040



glabel FUNC_10FE
    /* 10fe: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 1102: 0c 0b       */ mov.b       r0h,r3l
    /* 1104: e0 03       */ and.b       #0x3,r0h
    /* 1106: a0 01       */ cmp.b       #0x1,r0h
    /* 1108: 47 34       */ beq         LBL_113E
    /* 110a: a0 03       */ cmp.b       #0x3,r0h
    /* 110c: 46 6a       */ bne         LBL_1178
    /* 110e: 79 01 0f 96 */ mov.w       #LBL_0F96,r1
    /* 1112: 6a 0a fe 3b */ mov.b       @DAT_FE3B:16,r2l
    /* 1116: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 111a: 0d 30       */ mov.w       r3,r0
    /* 111c: 6a 0b 80 0e */ mov.b       @DAT_800E:16,r3l
    /* 1120: 79 01 10 4a */ mov.w       #LBL_104A,r1
    /* 1124: 6a 0a fe 3a */ mov.b       @DAT_FE3A:16,r2l
    /* 1128: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 112c: 09 30       */ add.w       r3,r0
    /* 112e: 0c 08       */ mov.b       r0h,r0l
    /* 1130: 4a 04       */ bpl         LBL_1136
    /* 1132: f0 ff       */ mov.b       #0xff,r0h
    /* 1134: 40 02       */ bra         LBL_1138
LBL_1136:
    /* 1136: f0 00       */ mov.b       #0x0,r0h
LBL_1138:
    /* 1138: 6b 80 fe 36 */ mov.w       r0,@DAT_FE36:16
    /* 113c: 54 70       */ rts
LBL_113E:
    /* 113e: f3 5a       */ mov.b       #0x5a,r3h
    /* 1140: 1c 3b       */ cmp.b       r3h,r3l
    /* 1142: 4b 02       */ bmi         LBL_1146
    /* 1144: 18 3b       */ sub.b       r3h,r3l
LBL_1146:
    /* 1146: 10 8b       */ shal.b      r3l
    /* 1148: 79 01 0f 96 */ mov.w       #0xf96,r1
    /* 114c: 6a 0a fe 3d */ mov.b       @DAT_FE3D:16,r2l
    /* 1150: 6d f3       */ mov.w       r3,@-r7
    /* 1152: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 1156: 0d 30       */ mov.w       r3,r0
    /* 1158: 6d 73       */ mov.w       @r7+,r3
    /* 115a: 79 01 10 4a */ mov.w       #0x104a,r1
    /* 115e: 6a 0a fe 3c */ mov.b       @DAT_FE3C:16,r2l
    /* 1162: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 1166: 09 30       */ add.w       r3,r0
    /* 1168: 0c 08       */ mov.b       r0h,r0l
    /* 116a: 4a 04       */ bpl         LBL_1170
    /* 116c: f0 ff       */ mov.b       #0xff,r0h
    /* 116e: 40 02       */ bra         LBL_1172
LBL_1170:
    /* 1170: f0 00       */ mov.b       #0x0,r0h
LBL_1172:
    /* 1172: 6b 80 fe 38 */ mov.w       r0,@DAT_FE38:16
    /* 1176: 54 70       */ rts
LBL_1178:
    /* 1178: 7e 00 73 70 */ btst        #0x7,@DAT_FF00:8
    /* 117c: 47 02       */ beq         LBL_1180
    /* 117e: 54 70       */ rts
LBL_1180:
    /* 1180: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 1184: e0 03       */ and.b       #0x3,r0h
    /* 1186: 47 0a       */ beq         LBL_1192
    /* 1188: a0 02       */ cmp.b       #0x2,r0h
    /* 118a: 46 04       */ bne         LBL_1190
    /* 118c: 5a 00 12 0e */ jmp         @LBL_120E:24
LBL_1190:
    /* 1190: 54 70       */ rts
LBL_1192:
    /* 1192: 6b 02 fd b0 */ mov.w       @DAT_FDB0:16,r2
    /* 1196: 79 01 10 4a */ mov.w       #0x104a,r1
    /* 119a: 6a 0b 80 0e */ mov.b       @DAT_800E:16,r3l
    /* 119e: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 11a2: 6b 00 fe 2e */ mov.w       @DAT_FE2E:16,r0
    /* 11a6: 09 30       */ add.w       r3,r0
    /* 11a8: 6b 80 fe 2e */ mov.w       r0,@DAT_FE2E:16
    /* 11ac: 4a 0a       */ bpl         LBL_11B8
    /* 11ae: 79 03 90 00 */ mov.w       #0x9000,r3
    /* 11b2: 1d 30       */ cmp.w       r3,r0
    /* 11b4: 45 42       */ bcs         LBL_11F8
    /* 11b6: 40 08       */ bra         LBL_11C0
LBL_11B8:
    /* 11b8: 79 03 70 00 */ mov.w       #0x7000,r3
    /* 11bc: 1d 30       */ cmp.w       r3,r0
    /* 11be: 44 38       */ bcc         LBL_11F8
LBL_11C0:
    /* 11c0: 6a 80 fe 3a */ mov.b       r0h,@DAT_FE3A:16
    /* 11c4: 6b 02 fd b0 */ mov.w       @DAT_FDB0:16,r2
    /* 11c8: 79 01 0f 96 */ mov.w       #0xf96,r1
    /* 11cc: 6a 0b 80 0e */ mov.b       @DAT_800E:16,r3l
    /* 11d0: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 11d4: 6b 00 fe 30 */ mov.w       @DAT_FE30:16,r0
    /* 11d8: 09 30       */ add.w       r3,r0
    /* 11da: 6b 80 fe 30 */ mov.w       r0,@DAT_FE30:16
    /* 11de: 4a 0a       */ bpl         LBL_11EA
    /* 11e0: 79 03 90 00 */ mov.w       #0x9000,r3
    /* 11e4: 1d 30       */ cmp.w       r3,r0
    /* 11e6: 45 10       */ bcs         LBL_11F8
    /* 11e8: 40 08       */ bra         LBL_11F2
LBL_11EA:
    /* 11ea: 79 03 70 00 */ mov.w       #0x7000,r3
    /* 11ee: 1d 30       */ cmp.w       r3,r0
    /* 11f0: 44 06       */ bcc         LBL_11F8
LBL_11F2:
    /* 11f2: 6a 80 fe 3b */ mov.b       r0h,@DAT_FE3B:16
    /* 11f6: 54 70       */ rts
LBL_11F8:
    /* 11f8: 6a 00 fe 3a */ mov.b       @DAT_FE3A:16,r0h
    /* 11fc: 0c 48       */ mov.b       r4h,r0l
    /* 11fe: 6b 80 fe 2e */ mov.w       r0,@DAT_FE2E:16
    /* 1202: 6a 00 fe 3b */ mov.b       @DAT_FE3B:16,r0h
    /* 1206: 0c 48       */ mov.b       r4h,r0l
    /* 1208: 6b 80 fe 30 */ mov.w       r0,@DAT_FE30:16
    /* 120c: 54 70       */ rts
LBL_120E:
    /* 120e: 6b 02 fd b0 */ mov.w       @DAT_FDB0:16,r2
    /* 1212: 79 01 10 4a */ mov.w       #0x104a,r1
    /* 1216: 6a 0b 80 0e */ mov.b       @DAT_800E:16,r3l
    /* 121a: f3 5a       */ mov.b       #0x5a,r3h
    /* 121c: 1c 3b       */ cmp.b       r3h,r3l
    /* 121e: 4b 02       */ bmi         LBL_1222
    /* 1220: 18 3b       */ sub.b       r3h,r3l
LBL_1222:
    /* 1222: 10 8b       */ shal.b      r3l
    /* 1224: 6d f3       */ mov.w       r3,@-r7
    /* 1226: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 122a: 6b 00 fe 32 */ mov.w       @DAT_FE32:16,r0
    /* 122e: 09 30       */ add.w       r3,r0
    /* 1230: 6b 80 fe 32 */ mov.w       r0,@DAT_FE32:16
    /* 1234: 4a 0c       */ bpl         LBL_1242
    /* 1236: 79 03 90 00 */ mov.w       #0x9000,r3
    /* 123a: 1d 30       */ cmp.w       r3,r0
    /* 123c: 44 10       */ bcc         LBL_124E
    /* 123e: 6d 73       */ mov.w       @r7+,r3
    /* 1240: 40 42       */ bra         LBL_1284
LBL_1242:
    /* 1242: 79 03 70 00 */ mov.w       #0x7000,r3
    /* 1246: 1d 30       */ cmp.w       r3,r0
    /* 1248: 45 04       */ bcs         LBL_124E
    /* 124a: 6d 73       */ mov.w       @r7+,r3
    /* 124c: 40 36       */ bra         LBL_1284
LBL_124E:
    /* 124e: 6a 80 fe 3c */ mov.b       r0h,@DAT_FE3C:16
    /* 1252: 6b 02 fd b0 */ mov.w       @DAT_FDB0:16,r2
    /* 1256: 79 01 0f 96 */ mov.w       #0xf96,r1
    /* 125a: 6d 73       */ mov.w       @r7+,r3
    /* 125c: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 1260: 6b 00 fe 34 */ mov.w       @DAT_FE34:16,r0
    /* 1264: 09 30       */ add.w       r3,r0
    /* 1266: 6b 80 fe 34 */ mov.w       r0,@DAT_FE34:16
    /* 126a: 4a 0a       */ bpl         LBL_1276
    /* 126c: 79 03 90 00 */ mov.w       #0x9000,r3
    /* 1270: 1d 30       */ cmp.w       r3,r0
    /* 1272: 45 10       */ bcs         LBL_1284
    /* 1274: 40 08       */ bra         LBL_127E
LBL_1276:
    /* 1276: 79 03 70 00 */ mov.w       #0x7000,r3
    /* 127a: 1d 30       */ cmp.w       r3,r0
    /* 127c: 44 06       */ bcc         LBL_1284
LBL_127E:
    /* 127e: 6a 80 fe 3d */ mov.b       r0h,@DAT_FE3D:16
    /* 1282: 54 70       */ rts
LBL_1284:
    /* 1284: 6a 00 fe 3c */ mov.b       @DAT_FE3C:16,r0h
    /* 1288: 0c 48       */ mov.b       r4h,r0l
    /* 128a: 6b 80 fe 32 */ mov.w       r0,@DAT_FE32:16
    /* 128e: 6a 00 fe 3d */ mov.b       @DAT_FE3D:16,r0h
    /* 1292: 0c 48       */ mov.b       r4h,r0l
    /* 1294: 6b 80 fe 34 */ mov.w       r0,@DAT_FE34:16
    /* 1298: 54 70       */ rts

glabel FUNC_129A
    /* 129a: 08 b9       */ add.b       r3l,r1l
    /* 129c: 91 00       */ addx        #0x0,r1h
    /* 129e: 68 1b       */ mov.b       @r1,r3l
    /* 12a0: 4b 14       */ bmi         LBL_12B6
    /* 12a2: 1c 4a       */ cmp.b       r4h,r2l
    /* 12a4: 4b 04       */ bmi         LBL_12AA
    /* 12a6: 50 a3       */ mulxu.b     r2l,r3
    /* 12a8: 40 20       */ bra         LBL_12CA
LBL_12AA:
    /* 12aa: 17 8a       */ neg.b       r2l
    /* 12ac: 50 a3       */ mulxu.b     r2l,r3
    /* 12ae: 17 0b       */ not.b       r3l
    /* 12b0: 17 03       */ not.b       r3h
    /* 12b2: 09 43       */ add.w       r4,r3
    /* 12b4: 40 14       */ bra         LBL_12CA
LBL_12B6:
    /* 12b6: 17 8b       */ neg.b       r3l
    /* 12b8: 1c 4a       */ cmp.b       r4h,r2l
    /* 12ba: 4b 0a       */ bmi         LBL_12C6
    /* 12bc: 50 a3       */ mulxu.b     r2l,r3
    /* 12be: 17 0b       */ not.b       r3l
    /* 12c0: 17 03       */ not.b       r3h
    /* 12c2: 09 43       */ add.w       r4,r3
    /* 12c4: 40 04       */ bra         LBL_12CA
LBL_12C6:
    /* 12c6: 17 8a       */ neg.b       r2l
    /* 12c8: 50 a3       */ mulxu.b     r2l,r3
LBL_12CA:
    /* 12ca: 54 70       */ rts



DATA_12CC:
    /* 12cc: */ .word 0x0307
    /* 12ce: */ .word 0x0b0d
    /* 12d0: */ .word 0x0e0c
    /* 12d2: */ .word 0x0905
    /* 12d4: */ .word 0x00fb
    /* 12d6: */ .word 0xf7f4
    /* 12d8: */ .word 0xf2f3
    /* 12da: */ .word 0xf5f9
    /* 12dc: */ .word 0xfdff
DATA_12DE:
    /* 12de: */ .word 0x0308
    /* 12e0: */ .word 0x0b0d
    /* 12e2: */ .word 0x0d0b
    /* 12e4: */ .word 0x0803
    /* 12e6: */ .word 0xfdf8
    /* 12e8: */ .word 0xf5f3
    /* 12ea: */ .word 0xf3f5
    /* 12ec: */ .word 0xf8fd
DATA_12EE:
    /* 12ee: */ .word 0x0308
    /* 12f0: */ .word 0x0c0e
    /* 12f2: */ .word 0x0d0a
    /* 12f4: */ .word 0x0600
    /* 12f6: */ .word 0xfaf6
    /* 12f8: */ .word 0xf3f2
    /* 12fa: */ .word 0xf4f8
    /* 12fc: */ .word 0xe1ff
LBL_12FE:
    /* 12fe: */ .word 0x0309
    /* 1300: */ .word 0x0c0e
    /* 1302: */ .word 0x0c09
    /* 1304: */ .word 0x03fd
    /* 1306: */ .word 0xf7f4
    /* 1308: */ .word 0xf2f4
    /* 130a: */ .word 0xf7fd

JTBL_130C:
    /* 130c: */ .word LBL_1326
    /* 130e: */ .word LBL_1336
    /* 1310: */ .word LBL_1346
    /* 1312: */ .word LBL_1356

glabel FUNC_1314
    /* 1314: 79 02 13 0c */ mov.w       #JTBL_130C,r2       // r2 = JTBL_130C
    /* 1318: 6a 0b fe 28 */ mov.b       @DAT_FE28:16,r3l    // r3l = U8(DAT_FE28)
    /* 131c: 10 8b       */ shal.b      r3l                 // r3l <<= 1
    /* 131e: 08 ba       */ add.b       r3l,r2l             // r2l += r3l
    /* 1320: 92 00       */ addx        #0x0,r2h            // r2h += 0 + Carry
    /* 1322: 69 21       */ mov.w       @r2,r1              // r1 = U16(r2)
    /* 1324: 59 10       */ jmp         @r1                 // PC = r1
                                                            //! Note: unprotected indirect jump, paired with the write mem
                                                            //! debug command this could potentially be used to execute
                                                            //! code out of RAM.
LBL_1326:
    /* 1326: 79 01 12 cc */ mov.w       #DATA_12CC,r1
    /* 132a: 6a 0b fe 26 */ mov.b       @DAT_FE26:16,r3l
    /* 132e: 0a 0b       */ inc         r3l
    /* 1330: ab 11       */ cmp.b       #0x11,r3l
    /* 1332: 45 3c       */ bcs         LBL_1370
    /* 1334: 40 2e       */ bra         LBL_1364
LBL_1336:
    /* 1336: 79 01 12 de */ mov.w       #DATA_12DE,r1
    /* 133a: 6a 0b fe 26 */ mov.b       @DAT_FE26:16,r3l
    /* 133e: 0a 0b       */ inc         r3l
    /* 1340: ab 10       */ cmp.b       #0x10,r3l
    /* 1342: 45 2c       */ bcs         LBL_1370
    /* 1344: 40 1e       */ bra         LBL_1364
LBL_1346:
    /* 1346: 79 01 12 ee */ mov.w       #DATA_12EE,r1
    /* 134a: 6a 0b fe 26 */ mov.b       @DAT_FE26:16,r3l
    /* 134e: 0a 0b       */ inc         r3l
    /* 1350: ab 0f       */ cmp.b       #0xf,r3l
    /* 1352: 45 1c       */ bcs         LBL_1370
    /* 1354: 40 0e       */ bra         LBL_1364
LBL_1356:
    /* 1356: 79 01 12 fe */ mov.w       #LBL_12FE,r1
    /* 135a: 6a 0b fe 26 */ mov.b       @DAT_FE26:16,r3l
    /* 135e: 0a 0b       */ inc         r3l
    /* 1360: ab 0e       */ cmp.b       #0xe,r3l
    /* 1362: 45 0c       */ bcs         LBL_1370
LBL_1364:
    /* 1364: 6a 0b fd 94 */ mov.b       @DAT_FD94:16,r3l
    /* 1368: 1a 0b       */ dec.b       r3l
    /* 136a: 6a 8b fd 94 */ mov.b       r3l,@DAT_FD94:16
    /* 136e: 0c 4b       */ mov.b       r4h,r3l
LBL_1370:
    /* 1370: 6a 8b fe 26 */ mov.b       r3l,@DAT_FE26:16
    /* 1374: 08 b9       */ add.b       r3l,r1l
    /* 1376: 91 00       */ addx        #0x0,r1h
    /* 1378: 68 1b       */ mov.b       @r1,r3l
    /* 137a: 4b 04       */ bmi         LBL_1380
    /* 137c: 0c 43       */ mov.b       r4h,r3h
    /* 137e: 54 70       */ rts
LBL_1380:
    /* 1380: f3 ff       */ mov.b       #0xff,r3h
    /* 1382: 54 70       */ rts



.fill (0x1800 - 0x1384), 1, 0xFF

glabel INTHANDLER_COMMON // interrupt handler and reset
    /* 1800: 04 80       */ orc         #CCR_I,ccr          // set interrupt mask bit?
    /* 1802: f0 49       */ mov.b       #0x49,r0h           // r0h = 0x49
    /* 1804: 30 c4       */ mov.b       r0h,@REG_SYSCR:8    // *0xC4 = r0h
    /* 1806: 79 03 3f 00 */ mov.w       #0x3f00,r3          // r3 = 0x3F00
    /* 180a: 6b 83 ff b0 */ mov.w       r3,@REG_P1DDR:16    // *0xFFB0 = r3
    /* 180e: f4 00       */ mov.b       #0x0,r4h            // r4h = 0x00
    /* 1810: fc 01       */ mov.b       #0x1,r4l            // r4l = 0x01
    /* 1812: 79 01 ff 7e */ mov.w       #DAT_FF7E,r1        // r1 = 0xFF7E
    /* 1816: 79 00 5a a5 */ mov.w       #0x5aa5,r0          // r0 = 0x5AA5
    /* 181a: 69 90       */ mov.w       r0,@r1              // *r1 = r0
    /* 181c: 69 10       */ mov.w       @r1,r0              // r0 = *r1
    /* 181e: 79 03 5a a5 */ mov.w       #0x5aa5,r3          // r3 = 0x5AA5
    /* 1822: 1d 30       */ cmp.w       r3,r0               // COMPARE(r3, r0)
    /* 1824: 47 06       */ beq         LBL_182C            // Branch if r3 == r0
    /* 1826: 69 17       */ mov.w       @r1,r7              // r7 = *r1
    /* 1828: 5a 00 18 aa */ jmp         @LBL_18AA:24

LBL_182C:
    /* 182c: 79 07 ff 80 */ mov.w       #DAT_FF80,r7
    /* 1830: 5e 00 1a 9c */ jsr         @RAMTEST:24         // call subroutine (memtest?)
    /* 1834: 44 04       */ bcc         LBL_183A            // branch on ??
    /* 1836: 5a 00 18 9e */ jmp         @LBL_189E:24

LBL_183A:
    /* 183a: 5e 00 1a d8 */ jsr         @FUNC_1AD8:24
    /* 183e: 44 04       */ bcc         LBL_1844
    /* 1840: 5a 00 18 9e */ jmp         @LBL_189E:24

LBL_1844:
    /* 1844: 5e 00 18 bc */ jsr         @FUNC_18BC:24
    /* 1848: 5e 00 18 e0 */ jsr         @FUNC_18E0:24
    /* 184c: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 1850: 79 07 ff 00 */ mov.w       #DAT_FF00,r7
    /* 1854: 5e 00 19 02 */ jsr         @FUNC_1902:24
    /* 1858: 5e 00 19 b8 */ jsr         @FUNC_19B8:24
    /* 185c: 5e 00 1a 0c */ jsr         @FUNC_1A0C:24
    /* 1860: 5e 00 19 d0 */ jsr         @FUNC_19D0:24
    /* 1864: 5e 00 47 9c */ jsr         @FUNC_479C:24
    /* 1868: 5e 00 1a 74 */ jsr         @FUNC_1A74:24
    /* 186c: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 1870: 7f 0e 70 30 */ bset        #0x3,@DAT_FF0E:8
    /* 1874: 7f 0e 70 20 */ bset        #0x2,@DAT_FF0E:8
    /* 1878: 6a 84 fe 18 */ mov.b       r4h,@DAT_FE18:16
    /* 187c: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 1880: 7d 10 70 00 */ bset        #ASIC_STATUS_DISK_CHANGE,@r1
    /* 1884: 7f 11 70 70 */ bset        #0x7,@DAT_FF11:8
    /* 1888: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 188c: 7d 10 70 40 */ bset        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
    /* 1890: 7d 10 70 30 */ bset        #ASIC_STATUS_HEAD_RETRACTED,@r1
    /* 1894: 7d 10 72 70 */ bclr        #ASIC_STATUS_BUSY,@r1
    /* 1898: 06 7f       */ andc        #(~CCR_I & 0xFF),ccr
    /* 189a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

LBL_189E:
    /* 189e: 5e 00 18 bc */ jsr         @FUNC_18BC:24
    /* 18a2: 5e 00 18 e0 */ jsr         @FUNC_18E0:24
    /* 18a6: 5e 00 47 9c */ jsr         @FUNC_479C:24
LBL_18AA:
    /* 18aa: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 18ae: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 18b2: 7d 10 72 60 */ bclr        #ASIC_STATUS_RESETTING,@r1
    /* 18b6: f0 03       */ mov.b       #0x3,r0h
    /* 18b8: 5a 00 51 00 */ jmp         @FUNC_5100:24

glabel FUNC_18BC
    /* 18bc: f0 02       */ mov.b       #0x2,r0h
    /* 18be: 30 b7       */ mov.b       r0h,@REG_P4DR:8
    /* 18c0: f0 06       */ mov.b       #0x6,r0h
    /* 18c2: 30 b5       */ mov.b       r0h,@REG_P4DDR:8
    /* 18c4: 34 c7       */ mov.b       r4h,@REG_IER:8
    /* 18c6: f0 00       */ mov.b       #0x0,r0h
    /* 18c8: 30 ba       */ mov.b       r0h,@REG_P5DR:8
    /* 18ca: f0 06       */ mov.b       #0x6,r0h
    /* 18cc: 30 b8       */ mov.b       r0h,@REG_P5DDR:8
    /* 18ce: f0 66       */ mov.b       #0x66,r0h
    /* 18d0: 30 bb       */ mov.b       r0h,@REG_P6DR:8
    /* 18d2: f0 f7       */ mov.b       #0xf7,r0h
    /* 18d4: 30 b9       */ mov.b       r0h,@REG_P6DDR:8
    /* 18d6: 34 c9       */ mov.b       r4h,@REG_8TCSR0:8
    /* 18d8: 34 d1       */ mov.b       r4h,@REG_8TCSR1:8
    /* 18da: 34 c8       */ mov.b       r4h,@REG_8TCR0:8
    /* 18dc: 34 d0       */ mov.b       r4h,@REG_8TCR1:8
    /* 18de: 54 70       */ rts

glabel FUNC_18E0
    /* 18e0: 34 90       */ mov.b       r4h,@REG_TIER:8
    /* 18e2: 20 91       */ mov.b       @REG_TCSR:8,r0h
    /* 18e4: 34 91       */ mov.b       r4h,@REG_TCSR:8
    /* 18e6: f0 01       */ mov.b       #0x1,r0h
    /* 18e8: 30 96       */ mov.b       r0h,@REG_TCR:8
    /* 18ea: 34 97       */ mov.b       r4h,@REG_TOCR:8
    /* 18ec: f0 ff       */ mov.b       #0xff,r0h
    /* 18ee: 30 c6       */ mov.b       r0h,@REG_ISCR:8
    /* 18f0: 20 c9       */ mov.b       @REG_8TCSR0:8,r0h
    /* 18f2: 34 c9       */ mov.b       r4h,@REG_8TCSR0:8
    /* 18f4: 20 d1       */ mov.b       @REG_8TCSR1:8,r0h
    /* 18f6: 34 d1       */ mov.b       r4h,@REG_8TCSR1:8
    /* 18f8: 20 e8       */ mov.b       @REG_ADCSR:8,r0h
    /* 18fa: f0 19       */ mov.b       #0x19,r0h
    /* 18fc: 30 e8       */ mov.b       r0h,@REG_ADCSR:8
    /* 18fe: 34 ea       */ mov.b       r4h,@DAT_FFEA:8
    /* 1900: 54 70       */ rts

glabel FUNC_1902            // init RAM?
    /* 1902: f0 00       */ mov.b       #0x0,r0h
    /* 1904: 30 1d       */ mov.b       r0h,@DAT_FF1D:8
    /* 1906: 6a 80 fd e3 */ mov.b       r0h,@DAT_FDE3:16
    /* 190a: 5e 00 47 76 */ jsr         @FUNC_4776:24
    /* 190e: 79 00 05 9b */ mov.w       #0x59b,r0
    /* 1912: 6b 80 fd 9e */ mov.w       r0,@DAT_FD9E:16
    /* 1916: f0 1e       */ mov.b       #0x1e,r0h
    /* 1918: 30 18       */ mov.b       r0h,@DAT_FF18:8
    /* 191a: 30 17       */ mov.b       r0h,@DAT_FF17:8
    /* 191c: f0 14       */ mov.b       #0x14,r0h
    /* 191e: 30 19       */ mov.b       r0h,@DAT_FF19:8
    /* 1920: f0 32       */ mov.b       #0x32,r0h
    /* 1922: 30 1a       */ mov.b       r0h,@DAT_FF1A:8
    /* 1924: 30 1c       */ mov.b       r0h,@DAT_FF1C:8
    /* 1926: f0 10       */ mov.b       #0x10,r0h
    /* 1928: 30 1b       */ mov.b       r0h,@DAT_FF1B:8
    /* 192a: f0 14       */ mov.b       #0x14,r0h
    /* 192c: 30 15       */ mov.b       r0h,@DAT_FF15:8
    /* 192e: 30 14       */ mov.b       r0h,@DAT_FF14:8
    /* 1930: f0 3c       */ mov.b       #0x3c,r0h
    /* 1932: 30 16       */ mov.b       r0h,@DAT_FF16:8
    /* 1934: 79 00 01 00 */ mov.w       #0x100,r0
    /* 1938: 6b 80 fd 8e */ mov.w       r0,@DAT_FD8E:16
    /* 193c: 6b 80 fd 90 */ mov.w       r0,@DAT_FD90:16
    /* 1940: 79 00 18 00 */ mov.w       #0x1800,r0
    /* 1944: 6b 80 fd a0 */ mov.w       r0,@DEBUG_MEMADDR:16
    /* 1948: 34 03       */ mov.b       r4h,@DAT_FF03:8
    /* 194a: 34 0c       */ mov.b       r4h,@DAT_FF0C:8
    /* 194c: 34 06       */ mov.b       r4h,@DAT_FF06:8
    /* 194e: 34 07       */ mov.b       r4h,@DAT_FF07:8
    /* 1950: 34 08       */ mov.b       r4h,@DAT_FF08:8
    /* 1952: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 1954: f0 0f       */ mov.b       #0xf,r0h
    /* 1956: 30 3e       */ mov.b       r0h,@DAT_FF3E:8
    /* 1958: f0 0a       */ mov.b       #0xa,r0h
    /* 195a: 6a 80 fe 0a */ mov.b       r0h,@DAT_FE0A:16
    /* 195e: f0 0f       */ mov.b       #0xf,r0h
    /* 1960: 6a 80 fe 0b */ mov.b       r0h,@DAT_FE0B:16
    /* 1964: f0 be       */ mov.b       #0xbe,r0h
    /* 1966: 6a 80 fd e6 */ mov.b       r0h,@DAT_FDE6:16
    /* 196a: f0 14       */ mov.b       #0x14,r0h
    /* 196c: 6a 80 fd e7 */ mov.b       r0h,@DAT_FDE7:16
    /* 1970: f0 14       */ mov.b       #0x14,r0h
    /* 1972: 6a 80 fd e8 */ mov.b       r0h,@DAT_FDE8:16
    /* 1976: f0 14       */ mov.b       #0x14,r0h
    /* 1978: 6a 80 fd e9 */ mov.b       r0h,@DAT_FDE9:16
    /* 197c: f0 00       */ mov.b       #0x0,r0h
    /* 197e: 6a 80 fd e5 */ mov.b       r0h,@DAT_FDE5:16
    /* 1982: f0 04       */ mov.b       #0x4,r0h
    /* 1984: 6a 80 fe 16 */ mov.b       r0h,@DAT_FE16:16
    /* 1988: 6a 80 fe 14 */ mov.b       r0h,@DAT_FE14:16
    /* 198c: f0 04       */ mov.b       #0x4,r0h
    /* 198e: 6a 80 fe 17 */ mov.b       r0h,@DAT_FE17:16
    /* 1992: 6a 80 fe 15 */ mov.b       r0h,@DAT_FE15:16
    /* 1996: 79 00 00 45 */ mov.w       #0x45,r0
    /* 199a: 6b 80 fe 0c */ mov.w       r0,@DAT_FE0C:16
    /* 199e: 79 00 00 17 */ mov.w       #0x17,r0
    /* 19a2: 6b 80 fe 0e */ mov.w       r0,@DAT_FE0E:16
    /* 19a6: 7f 11 70 50 */ bset        #0x5,@DAT_FF11:8
    /* 19aa: 7f 91 72 10 */ bclr        #0x1,@REG_TCSR:8
    /* 19ae: 7f 11 70 70 */ bset        #0x7,@DAT_FF11:8
    /* 19b2: f0 ff       */ mov.b       #0xff,r0h
    /* 19b4: 30 45       */ mov.b       r0h,@DAT_FF45:8
    /* 19b6: 54 70       */ rts

/**
 *  void FUNC_19B8(void) {
 *      u8 *r1 = DAT_6000;
 *      u8 *r2 = DAT_FB80;
 *      for (u8 r0h = 0x87; r0h != 0; r0h--) {
 *          *r2++ = *r1++;
 *      }
 *  }
 */
glabel FUNC_19B8
    /* 19b8: 79 01 60 00 */ mov.w       #DAT_6000,r1
    /* 19bc: 79 02 fb 80 */ mov.w       #DAT_FB80,r2
    /* 19c0: f0 87       */ mov.b       #0x87,r0h
LBL_19C2:
    /* 19c2: 68 18       */ mov.b       @r1,r0l
    /* 19c4: 68 a8       */ mov.b       r0l,@r2
    /* 19c6: 0b 01       */ adds        #1,r1
    /* 19c8: 0b 02       */ adds        #1,r2
    /* 19ca: 1a 00       */ dec.b       r0h
    /* 19cc: 46 f4       */ bne         LBL_19C2
    /* 19ce: 54 70       */ rts

/**
void FUNC_19D0(void) {
    U8(REG_P6DR) |= (1 << 4);
    U16(DAT_FD92) = DAT_6000;
    U8(DAT_FD94) = 0;
    while (TRUE) {
        FUNC_47F4(r0h=U8(DAT_FD94), r0l=U16(DAT_FD92));
        U8(DAT_FD94)++;
        if (U8(DAT_FD94) == 15)
            break;
        U16(DAT_FD92) += 9;
    }
    U8(DAT_FF45) = r4h;
}
 */
glabel FUNC_19D0
    /* 19d0: 7f bb 70 40 */ bset        #0x4,@REG_P6DR:8
    /* 19d4: 79 01 60 00 */ mov.w       #DAT_6000,r1
    /* 19d8: 6b 81 fd 92 */ mov.w       r1,@DAT_FD92:16
    /* 19dc: fa 00       */ mov.b       #0x0,r2l
    /* 19de: 6a 8a fd 94 */ mov.b       r2l,@DAT_FD94:16
LBL_19E2:
    /* 19e2: 68 18       */ mov.b       @r1,r0l
    /* 19e4: 0c a0       */ mov.b       r2l,r0h
    /* 19e6: 5e 00 47 f4 */ jsr         @FUNC_47F4:24
    /* 19ea: 6a 0a fd 94 */ mov.b       @DAT_FD94:16,r2l
    /* 19ee: 0a 0a       */ inc         r2l
    /* 19f0: 6a 8a fd 94 */ mov.b       r2l,@DAT_FD94:16
    /* 19f4: aa 0f       */ cmp.b       #0xf,r2l
    /* 19f6: 44 10       */ bcc         LBL_1A08
    /* 19f8: 6b 01 fd 92 */ mov.w       @DAT_FD92:16,r1
    /* 19fc: 79 03 00 09 */ mov.w       #0x9,r3
    /* 1a00: 09 31       */ add.w       r3,r1
    /* 1a02: 6b 81 fd 92 */ mov.w       r1,@DAT_FD92:16
    /* 1a06: 40 da       */ bra         LBL_19E2
LBL_1A08:
    /* 1a08: 34 45       */ mov.b       r4h,@DAT_FF45:8
    /* 1a0a: 54 70       */ rts

glabel FUNC_1A0C
    /* 1a0c: 79 01 ff 60 */ mov.w       #DAT_FF60,r1
    /* 1a10: 6b 81 fd 92 */ mov.w       r1,@DAT_FD92:16
    /* 1a14: f0 36       */ mov.b       #0x36,r0h
    /* 1a16: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
LBL_1A1A:
    /* 1a1a: 11 80       */ shar.b      r0h
    /* 1a1c: 5e 00 48 2e */ jsr         @FUNC_482E:24
    /* 1a20: 6a 0b fd 94 */ mov.b       @DAT_FD94:16,r3l
    /* 1a24: 11 8b       */ shar.b      r3l
    /* 1a26: 44 02       */ bcc         LBL_1A2A
    /* 1a28: 0c 80       */ mov.b       r0l,r0h
LBL_1A2A:
    /* 1a2a: a0 f8       */ cmp.b       #0xf8,r0h
    /* 1a2c: 44 2c       */ bcc         LBL_1A5A
    /* 1a2e: a0 40       */ cmp.b       #0x40,r0h
    /* 1a30: 45 28       */ bcs         LBL_1A5A
    /* 1a32: 6b 01 fd 92 */ mov.w       @DAT_FD92:16,r1
    /* 1a36: 68 90       */ mov.b       r0h,@r1
    /* 1a38: 09 41       */ add.w       r4,r1
    /* 1a3a: 6b 81 fd 92 */ mov.w       r1,@DAT_FD92:16
    /* 1a3e: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 1a42: 0a 00       */ inc         r0h
    /* 1a44: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
    /* 1a48: a0 3e       */ cmp.b       #0x3e,r0h
    /* 1a4a: 45 ce       */ bcs         LBL_1A1A
    /* 1a4c: 46 06       */ bne         LBL_1A54
    /* 1a4e: f0 40       */ mov.b       #0x40,r0h
    /* 1a50: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
LBL_1A54:
    /* 1a54: a0 48       */ cmp.b       #0x48,r0h
    /* 1a56: 45 c2       */ bcs         LBL_1A1A
    /* 1a58: 54 70       */ rts
LBL_1A5A:
    /* 1a5a: 79 01 60 c6 */ mov.w       #LBL_60C6,r1    // r1 = LBL_60C6
    /* 1a5e: 79 02 ff 60 */ mov.w       #DAT_FF60,r2    // r2 = DAT_FF60
    /* 1a62: 0c 48       */ mov.b       r4h,r0l         // r0l = r4h (r4h is a function arg?)
LBL_1A64:
    /* 1a64: 68 10       */ mov.b       @r1,r0h         // r0h = *r1
    /* 1a66: 68 a0       */ mov.b       r0h,@r2         // *r2 = r0h
    /* 1a68: 09 41       */ add.w       r4,r1           // r1 += r4
    /* 1a6a: 09 42       */ add.w       r4,r2           // r2 += r4
    /* 1a6c: 0a 08       */ inc         r0l             // r0l++
    /* 1a6e: a8 10       */ cmp.b       #0x10,r0l       // COMPARE(0x10, r0l)
    /* 1a70: 46 f2       */ bne         LBL_1A64        // loop until counter hits 0x10
    /* 1a72: 54 70       */ rts

/**
 *  void FUNC_1A74(void) {
 *      u8 r0h = U8(DAT_8009);
 *      if (r0h != 4) {
 *          r0h = 1;
 *          return FUNC_5100();
 *      }
 *      for (int i = 0; i < 8; i++) {
 *          U16(DAT_8010)[i] = U16(TBL_6088)[i];
 *      }
 *  }
 */
glabel FUNC_1A74
    /* 1a74: 6a 00 80 09 */ mov.b       @DAT_8009:16,r0h    // r0h = *DAT_8009
    /* 1a78: a0 04       */ cmp.b       #0x4,r0h            // COMPARE(4, r0h)
    /* 1a7a: 47 06       */ beq         LBL_1A82            // branch if (r0h == 4)
    /* 1a7c: f0 01       */ mov.b       #0x1,r0h            // r0h = 1
    /* 1a7e: 5a 00 51 00 */ jmp         @FUNC_5100:24       // tail call?
LBL_1A82:
    /* 1a82: 79 01 60 88 */ mov.w       #TBL_6088,r1        // r1 = TBL_6088 source data start
    /* 1a86: 79 03 60 98 */ mov.w       #TBL_6088_END,r3    // r3 = TBL_6088_END source data end
    /* 1a8a: 79 02 80 10 */ mov.w       #DAT_8010,r2        // r2 = DAT_8010 destination to copy to
LBL_1A8E:
    /* 1a8e: 69 10       */ mov.w       @r1,r0              // r0 = *r1
    /* 1a90: 69 a0       */ mov.w       r0,@r2              // *r2 = r0
    /* 1a92: 0b 81       */ adds        #2,r1               // r1 += 2
    /* 1a94: 0b 82       */ adds        #2,r2               // r2 += 2
    /* 1a96: 1d 31       */ cmp.w       r3,r1               // COMPARE(r3, r1)
    /* 1a98: 45 f4       */ bcs         LBL_1A8E            // loop again if carry set (low)
    /* 1a9a: 54 70       */ rts

glabel RAMTEST
    /* 1a9c: 79 01 fb 80 */ mov.w       #RAM_START,r1           // r1 = 0xFB80
    /* 1aa0: 79 02 ff 7e */ mov.w       #RAM_END-2,r2           // r2 = 0xFF7E
    /* 1aa4: 79 00 ff ff */ mov.w       #0xFFFF,r0              // r0 = 0xFFFF
LBL_1AA8:
    /* 1aa8: 69 90       */ mov.w       r0,@r1                  // *r1 = r0
    /* 1aaa: 69 13       */ mov.w       @r1,r3                  // r3 = *r1
    /* 1aac: 1d 30       */ cmp.w       r3,r0                   // COMPARE(r3, r0)
    /* 1aae: 46 24       */ bne         LBL_1AD4                // branch if (r0 != r3)
    /* 1ab0: 0b 81       */ adds        #2,r1                   // r1 += 2
    /* 1ab2: 1d 21       */ cmp.w       r2,r1                   // COMPARE(r2, r1)
    /* 1ab4: 45 f2       */ bcs         LBL_1AA8                // branch if carry set (low)
    /* 1ab6: 79 01 fb 80 */ mov.w       #RAM_START,r1           // r1 = 0xFB80
    /* 1aba: 79 02 ff 7e */ mov.w       #RAM_END-2,r2           // r2 = 0xFF7E
    /* 1abe: 79 00 00 00 */ mov.w       #0x0,r0                 // r0 = 0
LBL_1AC2:
    /* 1ac2: 69 90       */ mov.w       r0,@r1                  // *r1 = r0
    /* 1ac4: 69 13       */ mov.w       @r1,r3                  // r3 = *r1
    /* 1ac6: 1d 30       */ cmp.w       r3,r0                   // COMPARE(r3, r0)
    /* 1ac8: 46 0a       */ bne         LBL_1AD4                // branch if (r0 != r3)
    /* 1aca: 0b 81       */ adds        #2,r1                   // r1 += 2
    /* 1acc: 1d 21       */ cmp.w       r2,r1                   // COMPARE(r2, r1)
    /* 1ace: 45 f2       */ bcs         LBL_1AC2                // branch if carry set (low)
    /* 1ad0: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 1ad2: 54 70       */ rts
LBL_1AD4:
    /* 1ad4: 04 01       */ orc         #CCR_C,ccr
    /* 1ad6: 54 70       */ rts

glabel FUNC_1AD8
    /* 1ad8: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 1ada: 54 70       */ rts

LBL_1ADC: // not called?
    /* 1adc: 79 01 00 a0 */ mov.w       #0xa0,r1
    /* 1ae0: 79 02 7f ff */ mov.w       #0x7fff,r2
    /* 1ae4: 79 00 00 00 */ mov.w       #0x0,r0
    /* 1ae8: f3 00       */ mov.b       #0x0,r3h
LBL_1AEA:
    /* 1aea: 68 1b       */ mov.b       @r1,r3l
    /* 1aec: 09 30       */ add.w       r3,r0
    /* 1aee: 1d 21       */ cmp.w       r2,r1
    /* 1af0: 47 04       */ beq         LBL_1AF6
    /* 1af2: 0b 01       */ adds        #1,r1
    /* 1af4: 40 f4       */ bra         LBL_1AEA
LBL_1AF6:
    /* 1af6: 6b 03 00 4a */ mov.w       @UNK_004A:16,r3
    /* 1afa: 1d 30       */ cmp.w       r3,r0
    /* 1afc: 46 04       */ bne         LBL_1B02
    /* 1afe: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 1b00: 54 70       */ rts
LBL_1B02:
    /* 1b02: 04 01       */ orc         #CCR_C,ccr
    /* 1b04: 54 70       */ rts

glabel FUNC_1B06
    /* 1b06: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 1b0a: 7d 10 70 20 */ bset        #0x2,@r1
    /* 1b0e: 79 02 01 f5 */ mov.w       #0x1f5,r2
    /* 1b12: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 1b16: 7d 10 70 10 */ bset        #0x1,@r1
    /* 1b1a: 79 01 00 05 */ mov.w       #0x5,r1
    /* 1b1e: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 1b22: 7f 03 72 60 */ bclr        #0x6,@DAT_FF03:8
LBL_1B26:
    /* 1b26: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 1b2a: e0 07       */ and.b       #0x7,r0h
    /* 1b2c: a0 03       */ cmp.b       #0x3,r0h
    /* 1b2e: 47 08       */ beq         LBL_1B38
    /* 1b30: 19 42       */ sub.w       r4,r2
    /* 1b32: 46 f2       */ bne         LBL_1B26
    /* 1b34: 7f 03 70 60 */ bset        #0x6,@DAT_FF03:8
LBL_1B38:
    /* 1b38: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 1b3c: 7d 10 72 20 */ bclr        #0x2,@r1
    /* 1b40: 54 70       */ rts



.fill (0x1F00 - 0x1B42), 1, 0xFF



glabel FUNC_1F00
    /* 1f00: 7f 0c 70 40 */ bset        #0x4,@DAT_FF0C:8
    /* 1f04: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 1f08: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 1f0c: 5e 00 23 a0 */ jsr         @FUNC_23A0:24
    /* 1f10: f0 04       */ mov.b       #0x4,r0h
    /* 1f12: 30 1f       */ mov.b       r0h,@DAT_FF1F:8
    /* 1f14: 30 1e       */ mov.b       r0h,@DAT_FF1E:8
    /* 1f16: 34 08       */ mov.b       r4h,@DAT_FF08:8
LBL_1F18:
    /* 1f18: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 1f1c: 7d 10 70 40 */ bset        #0x4,@r1
    /* 1f20: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 1f24: 7d 10 72 40 */ bclr        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
    /* 1f28: 5e 00 47 8e */ jsr         @FUNC_478E:24
    /* 1f2c: 5e 00 19 d0 */ jsr         @FUNC_19D0:24
    /* 1f30: 5e 00 1a 0c */ jsr         @FUNC_1A0C:24
    /* 1f34: 5e 00 24 12 */ jsr         @FUNC_2412:24
    /* 1f38: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 1f3c: 5e 00 24 1c */ jsr         @FUNC_241C:24
    /* 1f40: f0 03       */ mov.b       #0x3,r0h
    /* 1f42: 6a 80 fd ea */ mov.b       r0h,@DAT_FDEA:16
LBL_1F46:
    /* 1f46: 5e 00 1b 06 */ jsr         @FUNC_1B06:24
    /* 1f4a: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 1f4e: 47 4e       */ beq         LBL_1F9E
    /* 1f50: 6a 00 fd ea */ mov.b       @DAT_FDEA:16,r0h
    /* 1f54: 1a 00       */ dec.b       r0h
    /* 1f56: 6a 80 fd ea */ mov.b       r0h,@DAT_FDEA:16
    /* 1f5a: 47 0a       */ beq         LBL_1F66
    /* 1f5c: 79 01 00 0a */ mov.w       #0xa,r1
    /* 1f60: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 1f64: 40 e0       */ bra         LBL_1F46
LBL_1F66:
    /* 1f66: 5e 00 25 26 */ jsr         @FUNC_2526:24
    /* 1f6a: 45 0a       */ bcs         LBL_1F76
    /* 1f6c: 5e 00 1b 06 */ jsr         @FUNC_1B06:24
    /* 1f70: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 1f74: 47 28       */ beq         LBL_1F9E
LBL_1F76:
    /* 1f76: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 1f7a: 47 04       */ beq         LBL_1F80
    /* 1f7c: 5a 00 21 8e */ jmp         @LBL_218E:24
LBL_1F80:
    /* 1f80: 20 1f       */ mov.b       @DAT_FF1F:8,r0h
    /* 1f82: a0 01       */ cmp.b       #0x1,r0h
    /* 1f84: 46 14       */ bne         LBL_1F9A
    /* 1f86: 7f 0e 72 20 */ bclr        #0x2,@DAT_FF0E:8
    /* 1f8a: 6a 84 fe 18 */ mov.b       r4h,@DAT_FE18:16
    /* 1f8e: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 1f92: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 1f96: 7d 10 72 40 */ bclr        #0x4,@r1
LBL_1F9A:
    /* 1f9a: 5a 00 21 6a */ jmp         @LBL_216A:24
LBL_1F9E:
    /* 1f9e: 79 00 00 80 */ mov.w       #0x80,r0
    /* 1fa2: 6b 80 fd a4 */ mov.w       r0,@DAT_FDA4:16
    /* 1fa6: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 1faa: 7d 10 72 30 */ bclr        #ASIC_STATUS_HEAD_RETRACTED,@r1
    /* 1fae: 04 80       */ orc         #CCR_I,ccr
    /* 1fb0: 7f 0d 70 00 */ bset        #0x0,@DAT_FF0D:8
    /* 1fb4: 7f 10 70 20 */ bset        #0x2,@DAT_FF10:8
    /* 1fb8: 79 00 00 80 */ mov.w       #0x80,r0
    /* 1fbc: 6b 80 fd a4 */ mov.w       r0,@DAT_FDA4:16
    /* 1fc0: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 1fc4: 7f bb 70 00 */ bset        #0x0,@REG_P6DR:8
    /* 1fc8: 79 01 00 02 */ mov.w       #0x2,r1
    /* 1fcc: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 1fd0: 5e 00 24 f2 */ jsr         @FUNC_24F2:24
    /* 1fd4: 7f c7 70 20 */ bset        #0x2,@REG_IER:8
    /* 1fd8: 06 7f       */ andc        #(~CCR_I & 0xFF),ccr
    /* 1fda: f0 c8       */ mov.b       #0xc8,r0h
    /* 1fdc: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
LBL_1FE0:
    /* 1fe0: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_1FE4:
    /* 1fe4: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 1fe8: 46 fa       */ bne         LBL_1FE4
    /* 1fea: 5e 00 21 b0 */ jsr         @FUNC_21B0:24
    /* 1fee: 44 10       */ bcc         LBL_2000
    /* 1ff0: 6a 0b fd 95 */ mov.b       @DAT_FD95:16,r3l
    /* 1ff4: 1a 0b       */ dec.b       r3l
    /* 1ff6: 6a 8b fd 95 */ mov.b       r3l,@DAT_FD95:16
    /* 1ffa: 46 e4       */ bne         LBL_1FE0
    /* 1ffc: 5a 00 20 3a */ jmp         @LBL_203A:24
LBL_2000:
    /* 2000: 5e 00 24 88 */ jsr         @FUNC_2488:24
    /* 2004: f0 40       */ mov.b       #0x40,r0h
    /* 2006: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 2008: 7f 0d 72 00 */ bclr        #0x0,@DAT_FF0D:8
LBL_200C:
    /* 200c: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 2010: 47 08       */ beq         LBL_201A
    /* 2012: 7f 08 70 50 */ bset        #0x5,@DAT_FF08:8
    /* 2016: 5a 00 20 3a */ jmp         @LBL_203A:24
LBL_201A:
    /* 201a: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 201e: 47 08       */ beq         LBL_2028
    /* 2020: 7f 08 70 30 */ bset        #0x3,@DAT_FF08:8
    /* 2024: 5a 00 20 3a */ jmp         @LBL_203A:24
LBL_2028:
    /* 2028: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 202c: 47 04       */ beq         LBL_2032
    /* 202e: 5a 00 21 8e */ jmp         @LBL_218E:24
LBL_2032:
    /* 2032: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 2036: 47 d4       */ beq         LBL_200C
    /* 2038: 40 0c       */ bra         LBL_2046
LBL_203A:
    /* 203a: 7f 0d 70 00 */ bset        #0x0,@DAT_FF0D:8
    /* 203e: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 2042: 5a 00 21 6a */ jmp         @LBL_216A:24
LBL_2046:
    /* 2046: 79 01 00 1e */ mov.w       #0x1e,r1
    /* 204a: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 204e: 6b 00 fd a8 */ mov.w       @DAT_FDA8:16,r0
    /* 2052: 0c 08       */ mov.b       r0h,r0l
    /* 2054: 0c 40       */ mov.b       r4h,r0h
    /* 2056: 6b 80 fd a4 */ mov.w       r0,@DAT_FDA4:16
    /* 205a: 6b 80 fd a6 */ mov.w       r0,@DAT_FDA6:16
    /* 205e: 6a 88 fd e0 */ mov.b       r0l,@DAT_FDE0:16
    /* 2062: 6a 88 fd e1 */ mov.b       r0l,@DAT_FDE1:16
    /* 2066: 79 00 03 00 */ mov.w       #0x300,r0
    /* 206a: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 206e: 79 01 00 c8 */ mov.w       #0xc8,r1
    /* 2072: 5e 00 23 4c */ jsr         @FUNC_234C:24
    /* 2076: 44 32       */ bcc         LBL_20AA
    /* 2078: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 207c: 47 04       */ beq         LBL_2082
    /* 207e: 5a 00 21 8e */ jmp         @LBL_218E:24
LBL_2082:
    /* 2082: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 2086: 47 04       */ beq         LBL_208C
    /* 2088: 5a 00 21 8e */ jmp         @LBL_218E:24
LBL_208C:
    /* 208c: 20 1f       */ mov.b       @DAT_FF1F:8,r0h
    /* 208e: a0 01       */ cmp.b       #0x1,r0h
    /* 2090: 46 14       */ bne         LBL_20A6
    /* 2092: 7f 0e 72 20 */ bclr        #0x2,@DAT_FF0E:8
    /* 2096: 6a 84 fe 18 */ mov.b       r4h,@DAT_FE18:16
    /* 209a: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 209e: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 20a2: 7d 10 72 40 */ bclr        #0x4,@r1
LBL_20A6:
    /* 20a6: 5a 00 21 6a */ jmp         @LBL_216A:24
LBL_20AA:
    /* 20aa: 5e 00 21 fc */ jsr         @FUNC_21FC:24
    /* 20ae: 6a 88 fd e1 */ mov.b       r0l,@DAT_FDE1:16
    /* 20b2: 0c 40       */ mov.b       r4h,r0h
    /* 20b4: 6b 80 fd a4 */ mov.w       r0,@DAT_FDA4:16
    /* 20b8: 79 00 01 00 */ mov.w       #0x100,r0
    /* 20bc: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 20c0: 79 01 00 c8 */ mov.w       #0xc8,r1
    /* 20c4: 5e 00 23 4c */ jsr         @FUNC_234C:24
    /* 20c8: 44 0e       */ bcc         LBL_20D8
    /* 20ca: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 20ce: 47 04       */ beq         LBL_20D4
    /* 20d0: 5a 00 21 8e */ jmp         @LBL_218E:24
LBL_20D4:
    /* 20d4: 5a 00 21 6a */ jmp         @LBL_216A:24
LBL_20D8:
    /* 20d8: 5e 00 21 fc */ jsr         @FUNC_21FC:24
    /* 20dc: 6a 88 fd e0 */ mov.b       r0l,@DAT_FDE0:16
    /* 20e0: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 20e4: 7d 10 70 20 */ bset        #0x2,@r1
LBL_20E8:
    /* 20e8: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 20ec: e0 60       */ and.b       #0x60,r0h
    /* 20ee: 47 10       */ beq         LBL_2100
    /* 20f0: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 20f4: 7d 10 70 20 */ bset        #0x2,@r1
    /* 20f8: 79 01 00 05 */ mov.w       #0x5,r1
    /* 20fc: 5e 00 47 3c */ jsr         @FUNC_473C:24
LBL_2100:
    /* 2100: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 2104: 7d 10 72 20 */ bclr        #0x2,@r1
    /* 2108: 79 00 07 08 */ mov.w       #0x708,r0
    /* 210c: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
LBL_2110:
    /* 2110: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_2114:
    /* 2114: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 2118: 46 fa       */ bne         LBL_2114
    /* 211a: 6a 00 80 0a */ mov.b       @DAT_800A:16,r0h
    /* 211e: e0 60       */ and.b       #0x60,r0h
    /* 2120: a0 60       */ cmp.b       #0x60,r0h
    /* 2122: 47 0e       */ beq         LBL_2132
    /* 2124: 6b 00 fd 94 */ mov.w       @DAT_FD94:16,r0
    /* 2128: 19 40       */ sub.w       r4,r0
    /* 212a: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
    /* 212e: 46 e0       */ bne         LBL_2110
    /* 2130: 40 0c       */ bra         LBL_213E
LBL_2132:
    /* 2132: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 2136: e0 30       */ and.b       #0x30,r0h
    /* 2138: 47 f8       */ beq         LBL_2132
    /* 213a: a0 30       */ cmp.b       #0x30,r0h
    /* 213c: 47 64       */ beq         LBL_21A2
LBL_213E:
    /* 213e: 6b 00 fd 88 */ mov.w       @DAT_FD88:16,r0
    /* 2142: 09 40       */ add.w       r4,r0
    /* 2144: 79 03 01 0b */ mov.w       #0x10b,r3
    /* 2148: 1d 30       */ cmp.w       r3,r0
    /* 214a: 44 1a       */ bcc         LBL_2166
    /* 214c: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 2150: 79 01 00 01 */ mov.w       #0x1,r1
    /* 2154: 5e 00 23 4c */ jsr         @FUNC_234C:24
    /* 2158: 45 04       */ bcs         LBL_215E
    /* 215a: 5a 00 20 e8 */ jmp         @LBL_20E8:24
LBL_215E:
    /* 215e: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 2162: 47 02       */ beq         LBL_2166
    /* 2164: 40 28       */ bra         LBL_218E
LBL_2166:
    /* 2166: 7f 08 70 20 */ bset        #0x2,@DAT_FF08:8
LBL_216A:
    /* 216a: 2b 1f       */ mov.b       @DAT_FF1F:8,r3l
    /* 216c: 1a 0b       */ dec.b       r3l
    /* 216e: 3b 1f       */ mov.b       r3l,@DAT_FF1F:8
    /* 2170: 47 2c       */ beq         LBL_219E
    /* 2172: ab 02       */ cmp.b       #0x2,r3l
    /* 2174: 46 14       */ bne         LBL_218A
    /* 2176: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 217a: 47 0e       */ beq         LBL_218A
    /* 217c: 79 01 00 05 */ mov.w       #0x5,r1
    /* 2180: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 2184: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 2188: 46 04       */ bne         LBL_218E
LBL_218A:
    /* 218a: 5a 00 1f 18 */ jmp         @LBL_1F18:24
LBL_218E:
    /* 218e: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 2192: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 2196: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 219a: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
LBL_219E:
    /* 219e: 7f 03 70 60 */ bset        #0x6,@DAT_FF03:8
LBL_21A2:
    /* 21a2: 7f 06 72 60 */ bclr        #0x6,@DAT_FF06:8
    /* 21a6: 7f 06 72 10 */ bclr        #0x1,@DAT_FF06:8
    /* 21aa: 7f 0c 72 40 */ bclr        #0x4,@DAT_FF0C:8
    /* 21ae: 54 70       */ rts

glabel FUNC_21B0
    /* 21b0: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 21b4: ed 07       */ and.b       #0x7,r5l
    /* 21b6: ad 03       */ cmp.b       #0x3,r5l
    /* 21b8: 46 3e       */ bne         LBL_21F8
    /* 21ba: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 21be: e0 07       */ and.b       #0x7,r0h
    /* 21c0: 0d 01       */ mov.w       r0,r1
    /* 21c2: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_21C6:
    /* 21c6: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 21ca: 46 fa       */ bne         LBL_21C6
    /* 21cc: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 21d0: ed 07       */ and.b       #0x7,r5l
    /* 21d2: ad 03       */ cmp.b       #0x3,r5l
    /* 21d4: 46 22       */ bne         LBL_21F8
    /* 21d6: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 21da: e0 07       */ and.b       #0x7,r0h
    /* 21dc: 19 01       */ sub.w       r0,r1
    /* 21de: 4b 0a       */ bmi         LBL_21EA
    /* 21e0: 79 03 00 14 */ mov.w       #0x14,r3
    /* 21e4: 19 31       */ sub.w       r3,r1
    /* 21e6: 4b 0c       */ bmi         LBL_21F4
    /* 21e8: 40 0e       */ bra         LBL_21F8
LBL_21EA:
    /* 21ea: 79 03 00 14 */ mov.w       #0x14,r3
    /* 21ee: 09 31       */ add.w       r3,r1
    /* 21f0: 4a 02       */ bpl         LBL_21F4
    /* 21f2: 40 04       */ bra         LBL_21F8
LBL_21F4:
    /* 21f4: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 21f6: 54 70       */ rts
LBL_21F8:
    /* 21f8: 04 01       */ orc         #CCR_C,ccr
    /* 21fa: 54 70       */ rts

glabel FUNC_21FC
    /* 21fc: fa b4       */ mov.b       #0xb4,r2l
    /* 21fe: 79 00 00 00 */ mov.w       #0x0,r0
    /* 2202: 6b 80 fd a6 */ mov.w       r0,@DAT_FDA6:16
LBL_2206:
    /* 2206: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_220A:
    /* 220a: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 220e: 46 fa       */ bne         LBL_220A
    /* 2210: 6b 00 fd a8 */ mov.w       @DAT_FDA8:16,r0
    /* 2214: 0c 08       */ mov.b       r0h,r0l
    /* 2216: 0c 40       */ mov.b       r4h,r0h
    /* 2218: 6b 03 fd a6 */ mov.w       @DAT_FDA6:16,r3
    /* 221c: 09 30       */ add.w       r3,r0
    /* 221e: 6b 80 fd a6 */ mov.w       r0,@DAT_FDA6:16
    /* 2222: 1a 0a       */ dec.b       r2l
    /* 2224: 46 e0       */ bne         LBL_2206
    /* 2226: fb b4       */ mov.b       #0xb4,r3l
    /* 2228: 51 b0       */ divxu.b     r3l,r0
    /* 222a: 6b 03 fd a4 */ mov.w       @DAT_FDA4:16,r3
    /* 222e: 6b 83 fd a6 */ mov.w       r3,@DAT_FDA6:16
    /* 2232: 54 70       */ rts

glabel FUNC_2234
    /* 2234: 7f 0c 70 40 */ bset        #0x4,@DAT_FF0C:8
    /* 2238: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 223c: 5e 00 47 8e */ jsr         @FUNC_478E:24
    /* 2240: 5e 00 24 12 */ jsr         @FUNC_2412:24
    /* 2244: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 2248: 79 00 00 80 */ mov.w       #0x80,r0
    /* 224c: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2250: 79 01 00 02 */ mov.w       #0x2,r1
    /* 2254: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 2258: 6b 00 fd a4 */ mov.w       @DAT_FDA4:16,r0
    /* 225c: 0c 80       */ mov.b       r0l,r0h
    /* 225e: 0c 48       */ mov.b       r4h,r0l
    /* 2260: 6b 80 fd a8 */ mov.w       r0,@DAT_FDA8:16
    /* 2264: 5e 00 1b 06 */ jsr         @FUNC_1B06:24
    /* 2268: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 226c: 47 04       */ beq         LBL_2272
    /* 226e: 5a 00 23 3e */ jmp         @LBL_233E:24
LBL_2272:
    /* 2272: 7f 0d 70 00 */ bset        #0x0,@DAT_FF0D:8
    /* 2276: 7f 10 70 20 */ bset        #0x2,@DAT_FF10:8
    /* 227a: f0 40       */ mov.b       #0x40,r0h
    /* 227c: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 227e: 7f c7 70 20 */ bset        #0x2,@REG_IER:8
    /* 2282: 06 7f       */ andc        #(~CCR_I & 0xFF),ccr
    /* 2284: f0 c8       */ mov.b       #0xc8,r0h
    /* 2286: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
LBL_228A:
    /* 228a: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_228E:
    /* 228e: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 2292: 46 fa       */ bne         LBL_228E
    /* 2294: 5e 00 21 b0 */ jsr         @FUNC_21B0:24
    /* 2298: 44 10       */ bcc         LBL_22AA
    /* 229a: 6a 0b fd 95 */ mov.b       @DAT_FD95:16,r3l
    /* 229e: 1a 0b       */ dec.b       r3l
    /* 22a0: 6a 8b fd 95 */ mov.b       r3l,@DAT_FD95:16
    /* 22a4: 46 e4       */ bne         LBL_228A
    /* 22a6: 5a 00 23 3e */ jmp         @LBL_233E:24
LBL_22AA:
    /* 22aa: 5e 00 24 88 */ jsr         @FUNC_2488:24
    /* 22ae: 7f bb 70 00 */ bset        #0x0,@REG_P6DR:8
    /* 22b2: f0 40       */ mov.b       #0x40,r0h
    /* 22b4: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 22b6: 7f 0d 72 00 */ bclr        #0x0,@DAT_FF0D:8
LBL_22BA:
    /* 22ba: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 22be: 46 16       */ bne         LBL_22D6
    /* 22c0: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 22c4: 46 10       */ bne         LBL_22D6
    /* 22c6: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 22ca: 47 02       */ beq         LBL_22CE
    /* 22cc: 40 08       */ bra         LBL_22D6
LBL_22CE:
    /* 22ce: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 22d2: 47 e6       */ beq         LBL_22BA
    /* 22d4: 40 04       */ bra         LBL_22DA
LBL_22D6:
    /* 22d6: 5a 00 23 3e */ jmp         @LBL_233E:24
LBL_22DA:
    /* 22da: f0 ff       */ mov.b       #0xff,r0h
    /* 22dc: 30 45       */ mov.b       r0h,@DAT_FF45:8
    /* 22de: 79 00 03 84 */ mov.w       #0x384,r0
    /* 22e2: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
LBL_22E6:
    /* 22e6: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_22EA:
    /* 22ea: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 22ee: 46 fa       */ bne         LBL_22EA
    /* 22f0: 6a 00 80 0a */ mov.b       @DAT_800A:16,r0h
    /* 22f4: e0 60       */ and.b       #0x60,r0h
    /* 22f6: a0 60       */ cmp.b       #0x60,r0h
    /* 22f8: 47 0e       */ beq         LBL_2308
    /* 22fa: 6b 00 fd 94 */ mov.w       @DAT_FD94:16,r0
    /* 22fe: 19 40       */ sub.w       r4,r0
    /* 2300: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
    /* 2304: 46 e0       */ bne         LBL_22E6
    /* 2306: 40 32       */ bra         LBL_233A
LBL_2308:
    /* 2308: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_230C:
    /* 230c: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 2310: 46 fa       */ bne         LBL_230C
    /* 2312: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 2316: e0 30       */ and.b       #0x30,r0h
    /* 2318: 46 0e       */ bne         LBL_2328
    /* 231a: 6b 00 fd 94 */ mov.w       @DAT_FD94:16,r0
    /* 231e: 19 40       */ sub.w       r4,r0
    /* 2320: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
    /* 2324: 46 e2       */ bne         LBL_2308
    /* 2326: 40 12       */ bra         LBL_233A
LBL_2328:
    /* 2328: a0 30       */ cmp.b       #0x30,r0h
    /* 232a: 46 0e       */ bne         LBL_233A
    /* 232c: 7f 0c 72 40 */ bclr        #0x4,@DAT_FF0C:8
    /* 2330: 7f 03 72 30 */ bclr        #0x3,@DAT_FF03:8
    /* 2334: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 2338: 40 08       */ bra         LBL_2342
LBL_233A:
    /* 233a: 7f 08 70 20 */ bset        #0x2,@DAT_FF08:8
LBL_233E:
    /* 233e: 7f 03 70 60 */ bset        #0x6,@DAT_FF03:8
LBL_2342:
    /* 2342: 7f 06 72 60 */ bclr        #0x6,@DAT_FF06:8
    /* 2346: 7f 06 72 10 */ bclr        #0x1,@DAT_FF06:8
    /* 234a: 54 70       */ rts

glabel FUNC_234C
    /* 234c: 6d f1       */ mov.w       r1,@-r7
    /* 234e: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
LBL_2352:
    /* 2352: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 2356: 47 06       */ beq         LBL_235E
    /* 2358: 7f 08 70 50 */ bset        #0x5,@DAT_FF08:8
    /* 235c: 40 3c       */ bra         LBL_239A
LBL_235E:
    /* 235e: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 2362: 47 06       */ beq         LBL_236A
    /* 2364: 7f 08 70 30 */ bset        #0x3,@DAT_FF08:8
    /* 2368: 40 30       */ bra         LBL_239A
LBL_236A:
    /* 236a: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 236e: 47 02       */ beq         LBL_2372
    /* 2370: 40 28       */ bra         LBL_239A
LBL_2372:
    /* 2372: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 2376: 47 da       */ beq         LBL_2352
    /* 2378: 6d 71       */ mov.w       @r7+,r1
    /* 237a: 47 1a       */ beq         LBL_2396
LBL_237C:
    /* 237c: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_2380:
    /* 2380: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 2384: 46 fa       */ bne         LBL_2380
    /* 2386: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 238a: 47 06       */ beq         LBL_2392
    /* 238c: 7f 08 70 30 */ bset        #0x3,@DAT_FF08:8
    /* 2390: 40 0a       */ bra         LBL_239C
LBL_2392:
    /* 2392: 19 41       */ sub.w       r4,r1
    /* 2394: 46 e6       */ bne         LBL_237C
LBL_2396:
    /* 2396: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 2398: 54 70       */ rts
LBL_239A:
    /* 239a: 6d 71       */ mov.w       @r7+,r1
LBL_239C:
    /* 239c: 04 01       */ orc         #CCR_C,ccr
    /* 239e: 54 70       */ rts

glabel FUNC_23A0
    /* 23a0: 79 01 60 00 */ mov.w       #0x6000,r1
    /* 23a4: 79 02 fb 80 */ mov.w       #0xfb80,r2
    /* 23a8: f0 87       */ mov.b       #0x87,r0h
LBL_23AA:
    /* 23aa: 68 18       */ mov.b       @r1,r0l
    /* 23ac: 68 a8       */ mov.b       r0l,@r2
    /* 23ae: 0b 01       */ adds        #1,r1
    /* 23b0: 0b 02       */ adds        #1,r2
    /* 23b2: 1a 00       */ dec.b       r0h
    /* 23b4: 46 f4       */ bne         LBL_23AA
    /* 23b6: 79 00 00 00 */ mov.w       #0x0,r0
    /* 23ba: 6b 80 fd 92 */ mov.w       r0,@DAT_FD92:16
    /* 23be: 79 01 24 0c */ mov.w       #0x240c,r1
LBL_23C2:
    /* 23c2: 79 02 24 12 */ mov.w       #0x2412,r2
    /* 23c6: 1d 21       */ cmp.w       r2,r1
    /* 23c8: 44 40       */ bcc         LBL_240A
    /* 23ca: 68 10       */ mov.b       @r1,r0h
    /* 23cc: f8 09       */ mov.b       #0x9,r0l
    /* 23ce: 50 00       */ mulxu.b     r0h,r0
    /* 23d0: 79 02 fb 80 */ mov.w       #0xfb80,r2
    /* 23d4: 09 02       */ add.w       r0,r2
    /* 23d6: 6a 00 fd 92 */ mov.b       @DAT_FD92:16,r0h
LBL_23DA:
    /* 23da: 11 80       */ shar.b      r0h
    /* 23dc: 5e 00 48 2e */ jsr         @FUNC_482E:24
    /* 23e0: 6a 0b fd 92 */ mov.b       @DAT_FD92:16,r3l
    /* 23e4: 11 8b       */ shar.b      r3l
    /* 23e6: 44 02       */ bcc         LBL_23EA
    /* 23e8: 0c 80       */ mov.b       r0l,r0h
LBL_23EA:
    /* 23ea: a0 ff       */ cmp.b       #0xff,r0h
    /* 23ec: 47 02       */ beq         LBL_23F0
    /* 23ee: 68 a0       */ mov.b       r0h,@r2
LBL_23F0:
    /* 23f0: 0b 02       */ adds        #1,r2
    /* 23f2: 6b 00 fd 92 */ mov.w       @DAT_FD92:16,r0
    /* 23f6: 0a 00       */ inc         r0h
    /* 23f8: 0a 08       */ inc         r0l
    /* 23fa: 6b 80 fd 92 */ mov.w       r0,@DAT_FD92:16
    /* 23fe: a8 09       */ cmp.b       #0x9,r0l
    /* 2400: 45 d8       */ bcs         LBL_23DA
    /* 2402: 6a 84 fd 93 */ mov.b       r4h,@DAT_FD93:16
    /* 2406: 0b 01       */ adds        #1,r1
    /* 2408: 40 b8       */ bra         LBL_23C2
LBL_240A:
    /* 240a: 54 70       */ rts



    /* 240c: */ .word 0x0103
    /* 240e: */ .word 0x0407
    /* 2410: */ .word 0x090c



glabel FUNC_2412
    /* 2412: f0 0b       */ mov.b       #0xb,r0h
    /* 2414: f8 80       */ mov.b       #0x80,r0l
    /* 2416: 5e 00 47 f4 */ jsr         @FUNC_47F4:24
    /* 241a: 54 70       */ rts

glabel FUNC_241C
    /* 241c: f0 be       */ mov.b       #0xbe,r0h
    /* 241e: 30 30       */ mov.b       r0h,@DAT_FF30:8
    /* 2420: 6a 80 fd e6 */ mov.b       r0h,@DAT_FDE6:16
    /* 2424: f0 08       */ mov.b       #0x8,r0h
    /* 2426: 30 31       */ mov.b       r0h,@DAT_FF31:8
    /* 2428: f0 02       */ mov.b       #0x2,r0h
    /* 242a: 30 32       */ mov.b       r0h,@DAT_FF32:8
    /* 242c: f0 14       */ mov.b       #0x14,r0h
    /* 242e: 6a 80 fd e7 */ mov.b       r0h,@DAT_FDE7:16
    /* 2432: f0 14       */ mov.b       #0x14,r0h
    /* 2434: 6a 80 fd e8 */ mov.b       r0h,@DAT_FDE8:16
    /* 2438: f0 14       */ mov.b       #0x14,r0h
    /* 243a: 6a 80 fd e9 */ mov.b       r0h,@DAT_FDE9:16
    /* 243e: f0 66       */ mov.b       #0x66,r0h
    /* 2440: 30 2b       */ mov.b       r0h,@DAT_FF2B:8
    /* 2442: 79 00 00 80 */ mov.w       #0x80,r0
    /* 2446: 6b 80 fd a4 */ mov.w       r0,@DAT_FDA4:16
    /* 244a: f0 80       */ mov.b       #0x80,r0h
    /* 244c: 0c 48       */ mov.b       r4h,r0l
    /* 244e: 6b 80 fd a8 */ mov.w       r0,@DAT_FDA8:16
    /* 2452: 79 00 00 00 */ mov.w       #0x0,r0
    /* 2456: 6b 80 fe 2e */ mov.w       r0,@DAT_FE2E:16
    /* 245a: 6b 80 fe 30 */ mov.w       r0,@DAT_FE30:16
    /* 245e: 6b 80 fe 32 */ mov.w       r0,@DAT_FE32:16
    /* 2462: 6b 80 fe 34 */ mov.w       r0,@DAT_FE34:16
    /* 2466: 6b 80 fe 36 */ mov.w       r0,@DAT_FE36:16
    /* 246a: 6b 80 fe 38 */ mov.w       r0,@DAT_FE38:16
    /* 246e: 6a 80 fe 3a */ mov.b       r0h,@DAT_FE3A:16
    /* 2472: 6a 80 fe 3b */ mov.b       r0h,@DAT_FE3B:16
    /* 2476: 6a 80 fe 3c */ mov.b       r0h,@DAT_FE3C:16
    /* 247a: 6a 80 fe 3d */ mov.b       r0h,@DAT_FE3D:16
    /* 247e: 79 00 00 00 */ mov.w       #0x0,r0
    /* 2482: 6b 80 fd da */ mov.w       r0,@DAT_FDDA:16
    /* 2486: 54 70       */ rts

glabel FUNC_2488
    /* 2488: 6b 80 fd 84 */ mov.w       r0,@DAT_FD84:16
    /* 248c: 0d 03       */ mov.w       r0,r3
    /* 248e: 10 0b       */ shll.b      r3l
    /* 2490: 12 03       */ rotxl.b     r3h
    /* 2492: 10 0b       */ shll.b      r3l
    /* 2494: 12 03       */ rotxl.b     r3h
    /* 2496: 6b 83 fd 86 */ mov.w       r3,@DAT_FD86:16
    /* 249a: 5e 00 0c ac */ jsr         @FUNC_0CAC:24
    /* 249e: 79 00 00 00 */ mov.w       #0x0,r0
    /* 24a2: 6b 80 fd b8 */ mov.w       r0,@DAT_FDB8:16
    /* 24a6: 34 20       */ mov.b       r4h,@DAT_FF20:8
    /* 24a8: 34 2c       */ mov.b       r4h,@DAT_FF2C:8
    /* 24aa: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 24ac: 34 34       */ mov.b       r4h,@DAT_FF34:8
    /* 24ae: 34 05       */ mov.b       r4h,@DAT_FF05:8
    /* 24b0: 7f 03 72 30 */ bclr        #0x3,@DAT_FF03:8
    /* 24b4: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 24b8: 6b 00 fd a4 */ mov.w       @DAT_FDA4:16,r0
    /* 24bc: 0c 80       */ mov.b       r0l,r0h
    /* 24be: 0c 48       */ mov.b       r4h,r0l
    /* 24c0: 6b 80 fd a8 */ mov.w       r0,@DAT_FDA8:16
    /* 24c4: 79 00 03 20 */ mov.w       #0x320,r0
    /* 24c8: 6b 80 fd d8 */ mov.w       r0,@DAT_FDD8:16
    /* 24cc: 79 00 00 80 */ mov.w       #0x80,r0
    /* 24d0: 6b 80 fd b6 */ mov.w       r0,@DAT_FDB6:16
    /* 24d4: 5e 00 0f 14 */ jsr         @FUNC_0F14:24
    /* 24d8: 20 14       */ mov.b       @DAT_FF14:8,r0h
    /* 24da: 30 13       */ mov.b       r0h,@DAT_FF13:8
    /* 24dc: 79 00 70 3f */ mov.w       #0x703f,r0
    /* 24e0: 6b 80 fd 8c */ mov.w       r0,@DAT_FD8C:16
    /* 24e4: 79 00 00 00 */ mov.w       #0x0,r0
    /* 24e8: 6b 80 ff 4e */ mov.w       r0,@DAT_FF4E:16
    /* 24ec: 7f 03 72 10 */ bclr        #0x1,@DAT_FF03:8
    /* 24f0: 54 70       */ rts

glabel FUNC_24F2
    /* 24f2: f9 08       */ mov.b       #0x8,r1l
    /* 24f4: 79 03 00 00 */ mov.w       #0x0,r3
    /* 24f8: f0 00       */ mov.b       #0x0,r0h
LBL_24FA:
    /* 24fa: f8 2e       */ mov.b       #0x2e,r0l
    /* 24fc: 38 e8       */ mov.b       r0l,@REG_ADCSR:8
LBL_24FE:
    /* 24fe: 7e e8 73 50 */ btst        #0x5,@REG_ADCSR:8
    /* 2502: 46 fa       */ bne         LBL_24FE
    /* 2504: 28 e4       */ mov.b       @REG_ADDRC:8,r0l
    /* 2506: 09 03       */ add.w       r0,r3
    /* 2508: 1a 09       */ dec.b       r1l
    /* 250a: 46 ee       */ bne         LBL_24FA
    /* 250c: 11 03       */ shlr.b      r3h
    /* 250e: 13 0b       */ rotxr.b     r3l
    /* 2510: 11 03       */ shlr.b      r3h
    /* 2512: 13 0b       */ rotxr.b     r3l
    /* 2514: 11 03       */ shlr.b      r3h
    /* 2516: 13 0b       */ rotxr.b     r3l
    /* 2518: ab 7a       */ cmp.b       #0x7a,r3l
    /* 251a: 44 04       */ bcc         LBL_2520
    /* 251c: ab 52       */ cmp.b       #0x52,r3l
    /* 251e: 44 02       */ bcc         LBL_2522
LBL_2520:
    /* 2520: fb 66       */ mov.b       #0x66,r3l
LBL_2522:
    /* 2522: 3b 2b       */ mov.b       r3l,@DAT_FF2B:8
    /* 2524: 54 70       */ rts

glabel FUNC_2526
    /* 2526: 04 80       */ orc         #CCR_I,ccr
    /* 2528: 79 00 00 e4 */ mov.w       #0xe4,r0
    /* 252c: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2530: 7f bb 70 00 */ bset        #0x0,@REG_P6DR:8
    /* 2534: 79 01 00 50 */ mov.w       #0x50,r1
    /* 2538: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 253c: 79 00 00 80 */ mov.w       #0x80,r0
    /* 2540: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2544: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 2548: 7d 10 70 10 */ bset        #0x1,@r1
    /* 254c: 79 00 00 1c */ mov.w       #0x1c,r0
    /* 2550: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2554: 79 01 00 0f */ mov.w       #0xf,r1
    /* 2558: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 255c: 79 00 00 80 */ mov.w       #0x80,r0
    /* 2560: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2564: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 2568: 79 00 01 2c */ mov.w       #0x12c,r0
    /* 256c: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
LBL_2570:
    /* 2570: 5e 00 26 f8 */ jsr         @FUNC_26F8:24
    /* 2574: 6b 00 fd 94 */ mov.w       @DAT_FD94:16,r0
    /* 2578: 19 40       */ sub.w       r4,r0
    /* 257a: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
    /* 257e: 46 04       */ bne         LBL_2584
    /* 2580: 5a 00 26 f0 */ jmp         @LBL_26F0:24
LBL_2584:
    /* 2584: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 2588: e0 07       */ and.b       #0x7,r0h
    /* 258a: a0 03       */ cmp.b       #0x3,r0h
    /* 258c: 46 e2       */ bne         LBL_2570
    /* 258e: 79 00 00 6c */ mov.w       #0x6c,r0
    /* 2592: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2596: 7f bb 70 00 */ bset        #0x0,@REG_P6DR:8
    /* 259a: f0 32       */ mov.b       #0x32,r0h
    /* 259c: 30 23       */ mov.b       r0h,@DAT_FF23:8
LBL_259E:
    /* 259e: 5e 00 27 12 */ jsr         @FUNC_2712:24
    /* 25a2: 5e 00 27 20 */ jsr         @FUNC_2720:24
    /* 25a6: 45 0e       */ bcs         LBL_25B6
    /* 25a8: 79 03 01 00 */ mov.w       #0x100,r3
    /* 25ac: 1d 30       */ cmp.w       r3,r0
    /* 25ae: 45 c0       */ bcs         LBL_2570
    /* 25b0: 6b 80 fd 80 */ mov.w       r0,@DAT_FD80:16
    /* 25b4: 40 0c       */ bra         LBL_25C2
LBL_25B6:
    /* 25b6: 20 23       */ mov.b       @DAT_FF23:8,r0h
    /* 25b8: 1a 00       */ dec.b       r0h
    /* 25ba: 30 23       */ mov.b       r0h,@DAT_FF23:8
    /* 25bc: 46 e0       */ bne         LBL_259E
    /* 25be: 5a 00 26 f0 */ jmp         @LBL_26F0:24
LBL_25C2:
    /* 25c2: 34 23       */ mov.b       r4h,@DAT_FF23:8
    /* 25c4: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 25c6: 79 00 00 80 */ mov.w       #0x80,r0
    /* 25ca: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 25ce: 7f 01 70 50 */ bset        #0x5,@DAT_FF01:8
    /* 25d2: 5e 00 25 ea */ jsr         @FUNC_25EA:24
    /* 25d6: 45 10       */ bcs         LBL_25E8
    /* 25d8: 79 00 00 80 */ mov.w       #0x80,r0
    /* 25dc: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 25e0: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 25e4: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 25e6: 54 70       */ rts
LBL_25E8:
    /* 25e8: 54 70       */ rts

glabel FUNC_25EA
    /* 25ea: 79 00 05 95 */ mov.w       #0x595,r0
    /* 25ee: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
LBL_25F2:
    /* 25f2: 6b 00 fd 94 */ mov.w       @DAT_FD94:16,r0
    /* 25f6: 19 40       */ sub.w       r4,r0
    /* 25f8: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
    /* 25fc: 46 04       */ bne         LBL_2602
    /* 25fe: 5a 00 26 ec */ jmp         @LBL_26EC:24
LBL_2602:
    /* 2602: 5e 00 27 12 */ jsr         @FUNC_2712:24
    /* 2606: 5e 00 27 12 */ jsr         @FUNC_2712:24
    /* 260a: 5e 00 27 12 */ jsr         @FUNC_2712:24
    /* 260e: 5e 00 27 12 */ jsr         @FUNC_2712:24
    /* 2612: 5e 00 27 20 */ jsr         @FUNC_2720:24
    /* 2616: 44 0e       */ bcc         LBL_2626
    /* 2618: 20 23       */ mov.b       @DAT_FF23:8,r0h
    /* 261a: 0a 00       */ inc         r0h
    /* 261c: 30 23       */ mov.b       r0h,@DAT_FF23:8
    /* 261e: a0 32       */ cmp.b       #0x32,r0h
    /* 2620: 45 d0       */ bcs         LBL_25F2
    /* 2622: 5a 00 26 f0 */ jmp         @LBL_26F0:24
LBL_2626:
    /* 2626: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 262a: 46 0a       */ bne         LBL_2636
    /* 262c: 79 03 01 32 */ mov.w       #0x132,r3
    /* 2630: 1d 30       */ cmp.w       r3,r0
    /* 2632: 44 18       */ bcc         LBL_264C
    /* 2634: 40 08       */ bra         LBL_263E
LBL_2636:
    /* 2636: 79 03 01 c8 */ mov.w       #0x1c8,r3
    /* 263a: 1d 30       */ cmp.w       r3,r0
    /* 263c: 45 0e       */ bcs         LBL_264C
LBL_263E:
    /* 263e: 2b 33       */ mov.b       @DAT_FF33:8,r3l
    /* 2640: 0a 0b       */ inc         r3l
    /* 2642: 3b 33       */ mov.b       r3l,@DAT_FF33:8
    /* 2644: ab 0a       */ cmp.b       #0xa,r3l
    /* 2646: 45 06       */ bcs         LBL_264E
    /* 2648: 5a 00 26 ec */ jmp         @LBL_26EC:24
LBL_264C:
    /* 264c: 34 33       */ mov.b       r4h,@DAT_FF33:8
LBL_264E:
    /* 264e: 34 23       */ mov.b       r4h,@DAT_FF23:8
    /* 2650: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 2654: 46 06       */ bne         LBL_265C
    /* 2656: 79 02 00 05 */ mov.w       #0x5,r2
    /* 265a: 40 04       */ bra         LBL_2660
LBL_265C:
    /* 265c: 79 02 00 01 */ mov.w       #0x1,r2
LBL_2660:
    /* 2660: 6b 03 fd 80 */ mov.w       @DAT_FD80:16,r3
    /* 2664: 6b 80 fd 80 */ mov.w       r0,@DAT_FD80:16
    /* 2668: 7e 01 73 50 */ btst        #0x5,@DAT_FF01:8
    /* 266c: 46 08       */ bne         LBL_2676
    /* 266e: 19 03       */ sub.w       r0,r3
    /* 2670: 19 32       */ sub.w       r3,r2
    /* 2672: 0d 20       */ mov.w       r2,r0
    /* 2674: 40 04       */ bra         LBL_267A
LBL_2676:
    /* 2676: 19 30       */ sub.w       r3,r0
    /* 2678: 19 20       */ sub.w       r2,r0
LBL_267A:
    /* 267a: 6b 80 ff 5e */ mov.w       r0,@DAT_FF5E:16
    /* 267e: 4b 06       */ bmi         LBL_2686
    /* 2680: f0 14       */ mov.b       #0x14,r0h
    /* 2682: 50 00       */ mulxu.b     r0h,r0
    /* 2684: 40 0c       */ bra         LBL_2692
LBL_2686:
    /* 2686: 17 88       */ neg.b       r0l
    /* 2688: f0 14       */ mov.b       #0x14,r0h
    /* 268a: 50 00       */ mulxu.b     r0h,r0
    /* 268c: 17 00       */ not.b       r0h
    /* 268e: 17 08       */ not.b       r0l
    /* 2690: 09 40       */ add.w       r4,r0
LBL_2692:
    /* 2692: 6b 03 ff 5a */ mov.w       @DAT_FF5A:16,r3
    /* 2696: 09 30       */ add.w       r3,r0
    /* 2698: 4b 08       */ bmi         LBL_26A2
    /* 269a: a0 00       */ cmp.b       #0x0,r0h
    /* 269c: 47 06       */ beq         LBL_26A4
    /* 269e: f8 ff       */ mov.b       #0xff,r0l
    /* 26a0: 40 02       */ bra         LBL_26A4
LBL_26A2:
    /* 26a2: 0c 48       */ mov.b       r4h,r0l
LBL_26A4:
    /* 26a4: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 26a8: 6b 00 ff 5a */ mov.w       @DAT_FF5A:16,r0
    /* 26ac: 6b 03 ff 5e */ mov.w       @DAT_FF5E:16,r3
    /* 26b0: 4b 0c       */ bmi         LBL_26BE
    /* 26b2: 79 02 00 05 */ mov.w       #0x5,r2
    /* 26b6: 1d 23       */ cmp.w       r2,r3
    /* 26b8: 45 0e       */ bcs         LBL_26C8
    /* 26ba: 0d 23       */ mov.w       r2,r3
    /* 26bc: 40 0a       */ bra         LBL_26C8
LBL_26BE:
    /* 26be: 79 02 ff fb */ mov.w       #0xfffb,r2
    /* 26c2: 1d 23       */ cmp.w       r2,r3
    /* 26c4: 44 02       */ bcc         LBL_26C8
    /* 26c6: 0d 23       */ mov.w       r2,r3
LBL_26C8:
    /* 26c8: 10 0b       */ shll.b      r3l
    /* 26ca: 12 03       */ rotxl.b     r3h
    /* 26cc: 09 30       */ add.w       r3,r0
    /* 26ce: 79 03 00 e0 */ mov.w       #0xe0,r3
    /* 26d2: 1d 30       */ cmp.w       r3,r0
    /* 26d4: 45 04       */ bcs         LBL_26DA
    /* 26d6: 0d 30       */ mov.w       r3,r0
    /* 26d8: 40 0a       */ bra         LBL_26E4
LBL_26DA:
    /* 26da: 79 03 00 20 */ mov.w       #0x20,r3
    /* 26de: 1d 30       */ cmp.w       r3,r0
    /* 26e0: 44 02       */ bcc         LBL_26E4
    /* 26e2: 0d 30       */ mov.w       r3,r0
LBL_26E4:
    /* 26e4: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 26e8: 5a 00 25 f2 */ jmp         @LBL_25F2:24
LBL_26EC:
    /* 26ec: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 26ee: 54 70       */ rts

LBL_26F0:
    /* 26f0: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 26f4: 04 01       */ orc         #CCR_C,ccr
    /* 26f6: 54 70       */ rts

glabel FUNC_26F8
    /* 26f8: 79 00 01 2c */ mov.w       #0x12c,r0
    /* 26fc: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3
    /* 2700: 09 30       */ add.w       r3,r0
    /* 2702: 6b 80 ff 94 */ mov.w       r0,@REG_OCR:16
    /* 2706: 7f 91 72 30 */ bclr        #0x3,@REG_TCSR:8
LBL_270A:
    /* 270a: 7e 91 73 30 */ btst        #0x3,@REG_TCSR:8
    /* 270e: 47 fa       */ beq         LBL_270A
    /* 2710: 54 70       */ rts

glabel FUNC_2712
    /* 2712: 28 b7       */ mov.b       @REG_P4DR:8,r0l
    /* 2714: e8 01       */ and.b       #0x1,r0l
    /* 2716: 46 fa       */ bne         FUNC_2712
LBL_2718:
    /* 2718: 28 b7       */ mov.b       @REG_P4DR:8,r0l
    /* 271a: e8 01       */ and.b       #0x1,r0l
    /* 271c: 47 fa       */ beq         LBL_2718
    /* 271e: 54 70       */ rts

glabel FUNC_2720
    /* 2720: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 2724: ed 07       */ and.b       #0x7,r5l
    /* 2726: ad 03       */ cmp.b       #0x3,r5l
    /* 2728: 46 0a       */ bne         LBL_2734
    /* 272a: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 272e: e0 07       */ and.b       #0x7,r0h
    /* 2730: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 2732: 54 70       */ rts
LBL_2734:
    /* 2734: 04 01       */ orc         #CCR_C,ccr
    /* 2736: 54 70       */ rts



.fill (0x2C00 - 0x2738), 1, 0xFF



glabel DD_COMMAND_HANDLER
    /* 2c00: 7e 10 73 20 */ btst        #0x2,@DAT_FF10:8
    /* 2c04: 47 38       */ beq         LBL_2C3E
    /* 2c06: 6b 00 ff 4c */ mov.w       @DAT_FF4C:16,r0
    /* 2c0a: 46 06       */ bne         LBL_2C12
    /* 2c0c: 7f 11 72 10 */ bclr        #0x1,@DAT_FF11:8
    /* 2c10: 40 6a       */ bra         LBL_2C7C
LBL_2C12:
    /* 2c12: 7f 11 70 10 */ bset        #0x1,@DAT_FF11:8
    /* 2c16: 79 03 8b 82 */ mov.w       #0x8b82,r3
    /* 2c1a: 1d 30       */ cmp.w       r3,r0
    /* 2c1c: 45 5e       */ bcs         LBL_2C7C
    /* 2c1e: 7f 0e 70 10 */ bset        #0x1,@DAT_FF0E:8
    /* 2c22: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 2c26: c0 08       */ or.b        #0x8,r0h
    /* 2c28: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
    /* 2c2c: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 2c30: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 2c34: 7f 11 72 10 */ bclr        #0x1,@DAT_FF11:8
    /* 2c38: 7f 0e 70 30 */ bset        #0x3,@DAT_FF0E:8
    /* 2c3c: 40 3e       */ bra         LBL_2C7C
LBL_2C3E:
    /* 2c3e: 5e 00 4c e6 */ jsr         @FUNC_4CE6:24
    /* 2c42: 44 10       */ bcc         LBL_2C54
    /* 2c44: 7e 0e 73 10 */ btst        #0x1,@DAT_FF0E:8
    /* 2c48: 46 32       */ bne         LBL_2C7C
    /* 2c4a: 7e 0e 73 70 */ btst        #0x7,@DAT_FF0E:8
    /* 2c4e: 47 2c       */ beq         LBL_2C7C
    /* 2c50: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
LBL_2C54:
    /* 2c54: 7e 0e 73 20 */ btst        #0x2,@DAT_FF0E:8
    /* 2c58: 46 22       */ bne         LBL_2C7C
    /* 2c5a: 7e 0e 73 70 */ btst        #0x7,@DAT_FF0E:8
    /* 2c5e: 47 1c       */ beq         LBL_2C7C
    /* 2c60: 7e 91 73 10 */ btst        #0x1,@REG_TCSR:8
    /* 2c64: 47 16       */ beq         LBL_2C7C
    /* 2c66: 5e 00 4e 04 */ jsr         @FUNC_4E04:24
    /* 2c6a: 6a 00 fe 18 */ mov.b       @DAT_FE18:16,r0h
    /* 2c6e: 0a 00       */ inc         r0h
    /* 2c70: 6a 80 fe 18 */ mov.b       r0h,@DAT_FE18:16
    /* 2c74: a0 04       */ cmp.b       #0x4,r0h
    /* 2c76: 45 04       */ bcs         LBL_2C7C
    /* 2c78: 7f 0e 70 20 */ bset        #0x2,@DAT_FF0E:8
LBL_2C7C:
    /* 2c7c: 5e 00 4e 04 */ jsr         @FUNC_4E04:24
    /* 2c80: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 2c84: 7c 10 73 70 */ btst        #ASIC_STATUS_BUSY,@r1   // check if we're busy?
    /* 2c88: 47 04       */ beq         LBL_2C8E
    /* 2c8a: 5a 00 2c 9c */ jmp         @GOT_COMMAND:24
LBL_2C8E:
    /* 2c8e: 2b 03       */ mov.b       @DAT_FF03:8,r3l
    /* 2c90: eb 10       */ and.b       #0x10,r3l
    /* 2c92: 47 04       */ beq         LBL_2C98
    /* 2c94: 5a 00 2d 84 */ jmp         @FUNC_2D84:24
LBL_2C98:
    /* 2c98: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
GOT_COMMAND:
    /* 2c9c: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1   // clear bits [2:1] in REG_ASIC_STATUS+1
    /* 2ca0: 7d 10 72 10 */ bclr        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 2ca4: 7d 10 72 20 */ bclr        #ASIC_STATUS_WRITE_PROTECT_ERROR,@r1
    /* 2ca8: 6b 00 80 02 */ mov.w       @REG_ASIC_CMD:16,r0     // read upper 16 bits of ASIC_CMD
    /* 2cac: 79 03 00 50 */ mov.w       #0x50,r3                // check if command 0x50 was requested
    /* 2cb0: 1d 30       */ cmp.w       r3,r0
    /* 2cb2: 46 04       */ bne         LBL_2CB8
    /* 2cb4: 5a 00 45 58 */ jmp         @COMMAND_DEBUG_ENABLE:24
LBL_2CB8:
    /* 2cb8: 79 03 00 20 */ mov.w       #0x20,r3                // for >= 0x20 we need to check debug mode
    /* 2cbc: 1d 30       */ cmp.w       r3,r0
    /* 2cbe: 45 0a       */ bcs         LBL_2CCA                // branch if < 0x20, normal command set
    /* 2cc0: 7e 4a 73 10 */ btst        #0x1,@DEBUG_EN_FLAGS:8  // check if we received command 0x50 with "LEO!" magic value
    /* 2cc4: 46 04       */ bne         LBL_2CCA                // branch if debug mode is enabled
    /* 2cc6: 5a 00 45 b0 */ jmp         @COMMAND_BAD:24         // not in debug mode, command is bad
LBL_2CCA:
    /* 2cca: 10 88       */ shal.b      r0l                     // Shift left by 1 bit, set carry to the deleted bit
    /* 2ccc: 12 00       */ rotxl.b     r0h                     // Shift left by 1 bit, emplace carry into the lsbit
    /* 2cce: 79 01 2c ec */ mov.w       #CMD_TBL,r1             // r1 = CMD_TBL
    /* 2cd2: 09 10       */ add.w       r1,r0                   // r0 += r1
    /* 2cd4: 1d 10       */ cmp.w       r1,r0                   // COMPARE(r1, r0)
    /* 2cd6: 44 04       */ bcc         LBL_2CDC                // Branch if oob?
    /* 2cd8: 5a 00 45 b0 */ jmp         @COMMAND_BAD:24
LBL_2CDC:
    /* 2cdc: 79 01 2d 84 */ mov.w       #CMD_TBL_END,r1         // r1 = CMD_TBL_END
    /* 2ce0: 1d 10       */ cmp.w       r1,r0                   // COMPARE(r1, r0)
    /* 2ce2: 45 04       */ bcs         LBL_2CE8                // Branch if oob?
    /* 2ce4: 5a 00 45 b0 */ jmp         @COMMAND_BAD:24
LBL_2CE8:
    /* 2ce8: 69 01       */ mov.w       @r0,r1                  // r1 = *r0 (load label from jtbl)
    /* 2cea: 59 10       */ jmp         @r1                     // indirect jump to handler

glabel CMD_TBL  // Indexed by ASIC_CMD upper 16 bits
    /* 2cec */  .word COMMAND_NO_OP                 /* [0x00] No Operation (?) */
    /* 2cee */  .word COMMAND_01                    /* [0x01]  */
    /* 2cf0 */  .word COMMAND_02                    /* [0x02]  */
    /* 2cf2 */  .word COMMAND_03                    /* [0x03]  */
    /* 2cf4 */  .word COMMAND_04                    /* [0x04]  */
    /* 2cf6 */  .word COMMAND_05                    /* [0x05]  */
    /* 2cf8 */  .word COMMAND_06                    /* [0x06]  */
    /* 2cfa */  .word COMMAND_07                    /* [0x07]  */
    /* 2cfc */  .word COMMAND_CLEAR_DISK_CHANGE     /* [0x08] Clear DISK_CHANGE bit */
    /* 2cfe */  .word COMMAND_CLR_RST_CHG           /* [0x09] Clear DISK_CHANGE and RESETTING bits */
    /* 2d00 */  .word COMMAND_READ_VERSION          /* [0x0A] Read ASIC Version */
    /* 2d02 */  .word COMMAND_0B                    /* [0x0B]  */
    /* 2d04 */  .word COMMAND_GET_ERRSTAT           /* [0x0C] Get error status */
    /* 2d06 */  .word COMMAND_0D                    /* [0x0D]  */
    /* 2d08 */  .word COMMAND_0E                    /* [0x0E]  */
    /* 2d0a */  .word COMMAND_RTC_SET_YEAR_MONTH    /* [0x0F] RTC: Set Year and Month */
    /* 2d0c */  .word COMMAND_RTC_SET_DAY_HOUR      /* [0x10] RTC: Set Day and Hour */
    /* 2d0e */  .word COMMAND_RTC_SET_MIN_SEC       /* [0x11] RTC: Set Minute and Second, also triggers RTC write? */
    /* 2d10 */  .word COMMAND_RTC_GET_YEAR_MONTH    /* [0x12] RTC: Get Year and Month */
    /* 2d12 */  .word COMMAND_RTC_GET_DAY_HOUR      /* [0x13] RTC: Get Day and Hour */
    /* 2d14 */  .word COMMAND_RTC_GET_MIN_SEC       /* [0x14] RTC: Get Minute and Second, also triggers RTC read? */
    /* 2d16 */  .word COMMAND_15                    /* [0x15]  */
    /* 2d18 */  .word COMMAND_BAD                   /* [0x16] Invalid? */
    /* 2d1a */  .word COMMAND_BAD                   /* [0x17] Invalid? */
    /* 2d1c */  .word COMMAND_BAD                   /* [0x18] Invalid? */
    /* 2d1e */  .word COMMAND_BAD                   /* [0x19] Invalid? */
    /* 2d20 */  .word COMMAND_BAD                   /* [0x1A] Invalid? */
    /* 2d22 */  .word COMMAND_BAD                   /* [0x1B] Invalid? */
    /* 2d24 */  .word COMMAND_BAD                   /* [0x1C] Invalid? */
    /* 2d26 */  .word COMMAND_BAD                   /* [0x1D] Invalid? */
    /* 2d28 */  .word COMMAND_BAD                   /* [0x1E] Invalid? */
    /* 2d2a */  .word COMMAND_BAD                   /* [0x1F] Invalid? */
    /* All the commands past here require sending "LEO!" in two halves over hidden command 0x50 */
    /* 2d2c */  .word COMMAND_20                    /* [0x20]  */
    /* 2d2e */  .word COMMAND_21                    /* [0x21]  */
    /* 2d30 */  .word COMMAND_BAD                   /* [0x22] Invalid? */
    /* 2d32 */  .word COMMAND_23                    /* [0x23]  */
    /* 2d34 */  .word COMMAND_24                    /* [0x24]  */
    /* 2d36 */  .word COMMAND_25                    /* [0x25]  */
    /* 2d38 */  .word COMMAND_26                    /* [0x26]  */
    /* 2d3a */  .word COMMAND_27                    /* [0x27]  */
    /* 2d3c */  .word COMMAND_28                    /* [0x28]  */
    /* 2d3e */  .word COMMAND_29                    /* [0x29]  */
    /* 2d40 */  .word COMMAND_2A                    /* [0x2A]  */
    /* 2d42 */  .word COMMAND_2B                    /* [0x2B]  */
    /* 2d44 */  .word COMMAND_2C                    /* [0x2C]  */
    /* 2d46 */  .word COMMAND_2D                    /* [0x2D]  */
    /* 2d48 */  .word COMMAND_DEBUG_READREG         /* [0x2E]  */
    /* 2d4a */  .word COMMAND_DEBUG_WRITEREG        /* [0x2F]  */
    /* 2d4c */  .word COMMAND_DEBUG_SETADDR         /* [0x30]  */
    /* 2d4e */  .word COMMAND_DEBUG_READMEM         /* [0x31]  */
    /* 2d50 */  .word COMMAND_DEBUG_WRITEMEM        /* [0x32]  */
    /* 2d52 */  .word COMMAND_33                    /* [0x33]  */
    /* 2d54 */  .word COMMAND_34                    /* [0x34]  */
    /* 2d56 */  .word COMMAND_35                    /* [0x35]  */
    /* 2d58 */  .word COMMAND_36                    /* [0x36]  */
    /* 2d5a */  .word COMMAND_BAD                   /* [0x37] Invalid? */
    /* 2d5c */  .word COMMAND_38                    /* [0x38]  */
    /* 2d5e */  .word COMMAND_39                    /* [0x39]  */
    /* 2d60 */  .word COMMAND_3A                    /* [0x3A]  */
    /* 2d62 */  .word COMMAND_3B                    /* [0x3B]  */
    /* 2d64 */  .word COMMAND_3C                    /* [0x3C]  */
    /* 2d66 */  .word COMMAND_3D                    /* [0x3D]  */
    /* 2d68 */  .word COMMAND_3E                    /* [0x3E]  */
    /* 2d6a */  .word COMMAND_3F                    /* [0x3F]  */
    /* 2d6c */  .word COMMAND_40                    /* [0x40]  */
    /* 2d6e */  .word COMMAND_41                    /* [0x41]  */
    /* 2d70 */  .word COMMAND_42                    /* [0x42]  */
    /* 2d72 */  .word COMMAND_BAD                   /* [0x43] Invalid? */
    /* 2d74 */  .word COMMAND_44                    /* [0x44]  */
    /* 2d76 */  .word COMMAND_45                    /* [0x45]  */
    /* 2d78 */  .word COMMAND_BAD                   /* [0x46] Invalid? */
    /* 2d7a */  .word COMMAND_47                    /* [0x47]  */
    /* 2d7c */  .word COMMAND_48                    /* [0x48]  */
    /* 2d7e */  .word COMMAND_49                    /* [0x49]  */
    /* 2d80 */  .word COMMAND_4A                    /* [0x4A]  */
    /* 2d82 */  .word COMMAND_4B                    /* [0x4B]  */
glabel CMD_TBL_END

glabel FUNC_2D84
    /* 2d84: 7f 11 70 00 */ bset        #0x0,@DAT_FF11:8
    /* 2d88: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 2d8c: c0 08       */ or.b        #0x8,r0h
    /* 2d8e: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
    /* 2d92: 6b 00 fd 88 */ mov.w       @DAT_FD88:16,r0
LBL_2D96:
    /* 2d96: 6b 80 fd 90 */ mov.w       r0,@DAT_FD90:16
    /* 2d9a: f0 03       */ mov.b       #0x3,r0h
    /* 2d9c: 30 48       */ mov.b       r0h,@DAT_FF48:8
    /* 2d9e: 5e 00 22 34 */ jsr         @FUNC_2234:24
    /* 2da2: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 2da6: 47 12       */ beq         LBL_2DBA
    /* 2da8: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 2dac: 47 02       */ beq         LBL_2DB0
LBL_2DAE:
    /* 2dae: 40 64       */ bra         LBL_2E14
LBL_2DB0:
    /* 2db0: 5e 00 1f 00 */ jsr         @FUNC_1F00:24
    /* 2db4: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 2db8: 46 34       */ bne         LBL_2DEE
LBL_2DBA:
    /* 2dba: 6b 00 fd 90 */ mov.w       @DAT_FD90:16,r0
    /* 2dbe: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 2dc2: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
LBL_2DC6:
    /* 2dc6: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 2dca: 46 1a       */ bne         LBL_2DE6
    /* 2dcc: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
LBL_2DD0:
    /* 2dd0: 46 14       */ bne         LBL_2DE6
    /* 2dd2: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 2dd6: 46 3c       */ bne         LBL_2E14
    /* 2dd8: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 2ddc: 47 e8       */ beq         LBL_2DC6
    /* 2dde: 7f 11 72 00 */ bclr        #0x0,@DAT_FF11:8
    /* 2de2: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_2DE6:
    /* 2de6: 20 48       */ mov.b       @DAT_FF48:8,r0h
    /* 2de8: 1a 00       */ dec.b       r0h
LBL_2DEA:
    /* 2dea: 30 48       */ mov.b       r0h,@DAT_FF48:8
    /* 2dec: 46 c2       */ bne         LBL_2DB0
LBL_2DEE:
    /* 2dee: 5e 00 46 e6 */ jsr         @FUNC_46E6:24
    /* 2df2: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
LBL_2DF6:
    /* 2df6: c0 08       */ or.b        #0x8,r0h
    /* 2df8: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
    /* 2dfc: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 2e00: 7f 0b 70 30 */ bset        #ERROR_STATUS_NO_SEEK_COMPLETE,@ERROR_STATUS+1:8
    /* 2e04: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 2e08: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 2e0c: 7f 11 72 00 */ bclr        #0x0,@DAT_FF11:8
    /* 2e10: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_2E14:
    /* 2e14: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 2e18: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 2e1c: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 2e20: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
    /* 2e24: 7f 11 72 00 */ bclr        #0x0,@DAT_FF11:8
    /* 2e28: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_NO_OP
    /* 2e2c: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 2e30: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 2e34: 7d 10 72 70 */ bclr        #ASIC_STATUS_BUSY,@r1   // clear busy bit
    /* 2e38: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_01
    /* 2e3c: 5e 00 46 a4 */ jsr         @DD_COMMAND_PROLOG3:24
    /* 2e40: 44 04       */ bcc         LBL_2E46
    /* 2e42: 5a 00 2f dc */ jmp         @LBL_2FDC:24
LBL_2E46:
    /* 2e46: 7f 11 70 50 */ bset        #0x5,@DAT_FF11:8
    /* 2e4a: 20 18       */ mov.b       @DAT_FF18:8,r0h
    /* 2e4c: 30 17       */ mov.b       r0h,@DAT_FF17:8
    /* 2e4e: 20 15       */ mov.b       @DAT_FF15:8,r0h
    /* 2e50: 30 14       */ mov.b       r0h,@DAT_FF14:8
    /* 2e52: 20 1c       */ mov.b       @DAT_FF1C:8,r0h
    /* 2e54: 30 1a       */ mov.b       r0h,@DAT_FF1A:8
    /* 2e56: 79 01 80 18 */ mov.w       #DAT_8018,r1
    /* 2e5a: 7d 10 72 70 */ bclr        #0x7,@r1
    /* 2e5e: 5a 00 2e 84 */ jmp         @LBL_2E84:24

glabel COMMAND_02
    /* 2e62: 5e 00 46 a4 */ jsr         @DD_COMMAND_PROLOG3:24
    /* 2e66: 44 04       */ bcc         LBL_2E6C
    /* 2e68: 5a 00 2f dc */ jmp         @LBL_2FDC:24
LBL_2E6C:
    /* 2e6c: 7f 11 72 50 */ bclr        #0x5,@DAT_FF11:8
    /* 2e70: 20 19       */ mov.b       @DAT_FF19:8,r0h
    /* 2e72: 30 17       */ mov.b       r0h,@DAT_FF17:8
    /* 2e74: 20 16       */ mov.b       @DAT_FF16:8,r0h
    /* 2e76: 30 14       */ mov.b       r0h,@DAT_FF14:8
    /* 2e78: 20 1b       */ mov.b       @DAT_FF1B:8,r0h
    /* 2e7a: 30 1a       */ mov.b       r0h,@DAT_FF1A:8
    /* 2e7c: 79 01 80 18 */ mov.w       #DAT_8018,r1
    /* 2e80: 7d 10 70 70 */ bset        #0x7,@r1
LBL_2E84:
    /* 2e84: 7e 03 73 70 */ btst        #0x7,@DAT_FF03:8
    /* 2e88: 47 1a       */ beq         LBL_2EA4
    /* 2e8a: 7e 0c 73 70 */ btst        #0x7,@DAT_FF0C:8
    /* 2e8e: 47 06       */ beq         LBL_2E96
    /* 2e90: 7f 0c 72 70 */ bclr        #0x7,@DAT_FF0C:8
    /* 2e94: 40 1c       */ bra         LBL_2EB2
LBL_2E96:
    /* 2e96: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 2e9a: 46 2e       */ bne         LBL_2ECA
    /* 2e9c: 7e 00 73 60 */ btst        #0x6,@DAT_FF00:8
    /* 2ea0: 46 28       */ bne         LBL_2ECA
    /* 2ea2: 40 0e       */ bra         LBL_2EB2
LBL_2EA4:
    /* 2ea4: 5e 00 49 a8 */ jsr         @FUNC_49A8:24
    /* 2ea8: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 2eac: 47 04       */ beq         LBL_2EB2
    /* 2eae: 5a 00 2f a8 */ jmp         @LBL_2FA8:24
LBL_2EB2:
    /* 2eb2: 5e 00 1f 00 */ jsr         @FUNC_1F00:24
    /* 2eb6: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 2eba: 47 04       */ beq         LBL_2EC0
    /* 2ebc: 5a 00 2f a8 */ jmp         @LBL_2FA8:24
LBL_2EC0:
    /* 2ec0: 5e 00 4f 16 */ jsr         @FUNC_4F16:24
    /* 2ec4: 44 04       */ bcc         LBL_2ECA
    /* 2ec6: 5a 00 2f a8 */ jmp         @LBL_2FA8:24
LBL_2ECA:
    /* 2eca: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 2ece: e0 0f       */ and.b       #0xf,r0h
    /* 2ed0: 79 03 01 00 */ mov.w       #0x100,r3
    /* 2ed4: 09 30       */ add.w       r3,r0
    /* 2ed6: 6b 80 fd 92 */ mov.w       r0,@DAT_FD92:16
    /* 2eda: 6b 03 fd 9e */ mov.w       @DAT_FD9E:16,r3
    /* 2ede: 1d 30       */ cmp.w       r3,r0
    /* 2ee0: 42 08       */ bhi         LBL_2EEA
    /* 2ee2: 79 03 01 00 */ mov.w       #0x100,r3
    /* 2ee6: 1d 30       */ cmp.w       r3,r0
    /* 2ee8: 44 04       */ bcc         LBL_2EEE
LBL_2EEA:
    /* 2eea: 5a 00 2f 4c */ jmp         @LBL_2F4C:24
LBL_2EEE:
    /* 2eee: 6a 00 80 00 */ mov.b       @REG_ASIC_DATA:16,r0h
    /* 2ef2: e0 f0       */ and.b       #0xf0,r0h
    /* 2ef4: 11 00       */ shlr.b      r0h
    /* 2ef6: 11 00       */ shlr.b      r0h
    /* 2ef8: 11 00       */ shlr.b      r0h
    /* 2efa: 11 00       */ shlr.b      r0h
    /* 2efc: a0 01       */ cmp.b       #0x1,r0h
    /* 2efe: 43 04       */ bls         LBL_2F04
    /* 2f00: 5a 00 2f 4c */ jmp         @LBL_2F4C:24
LBL_2F04:
    /* 2f04: 30 1d       */ mov.b       r0h,@DAT_FF1D:8
    /* 2f06: 6b 00 fd 92 */ mov.w       @DAT_FD92:16,r0
    /* 2f0a: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 2f0e: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
    /* 2f12: 5e 00 30 1a */ jsr         @FUNC_301A:24
    /* 2f16: 45 48       */ bcs         LBL_2F60
LBL_2F18:
    /* 2f18: 7e 11 73 50 */ btst        #0x5,@DAT_FF11:8
    /* 2f1c: 46 26       */ bne         LBL_2F44
LBL_2F1E:
    /* 2f1e: 6b 00 ff 4c */ mov.w       @DAT_FF4C:16,r0
    /* 2f22: 47 20       */ beq         LBL_2F44
    /* 2f24: 79 03 6f 9b */ mov.w       #0x6f9b,r3
    /* 2f28: 1d 03       */ cmp.w       r0,r3
    /* 2f2a: 44 04       */ bcc         LBL_2F30
    /* 2f2c: 5a 00 2f c2 */ jmp         @LBL_2FC2:24
LBL_2F30:
    /* 2f30: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 2f34: 46 2a       */ bne         LBL_2F60
    /* 2f36: 7f 11 70 10 */ bset        #0x1,@DAT_FF11:8
    /* 2f3a: 5e 00 4e 04 */ jsr         @FUNC_4E04:24
    /* 2f3e: 7f 11 72 10 */ bclr        #0x1,@DAT_FF11:8
    /* 2f42: 40 da       */ bra         LBL_2F1E
LBL_2F44:
    /* 2f44: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 2f48: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_2F4C:
    /* 2f4c: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 2f50: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 2f54: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 2f58: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 2f5c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_2F60:
    /* 2f60: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 2f64: 47 04       */ beq         LBL_2F6A
    /* 2f66: 5a 00 2f f0 */ jmp         @LBL_2FF0:24
LBL_2F6A:
    /* 2f6a: 79 00 00 80 */ mov.w       #0x80,r0
    /* 2f6e: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2f72: 5e 00 45 c8 */ jsr         @FUNC_45C8:24
    /* 2f76: 44 2c       */ bcc         LBL_2FA4
    /* 2f78: 79 00 00 80 */ mov.w       #0x80,r0
    /* 2f7c: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 2f80: 5e 00 46 e6 */ jsr         @FUNC_46E6:24
    /* 2f84: 7e 06 73 10 */ btst        #0x1,@DAT_FF06:8
    /* 2f88: 47 06       */ beq         LBL_2F90
    /* 2f8a: 7f 0b 70 20 */ bset        #ERROR_STATUS_DRIVE_NOT_READY,@ERROR_STATUS+1:8
    /* 2f8e: 40 04       */ bra         LBL_2F94
LBL_2F90:
    /* 2f90: 7f 0b 70 30 */ bset        #ERROR_STATUS_NO_SEEK_COMPLETE,@ERROR_STATUS+1:8
LBL_2F94:
    /* 2f94: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 2f98: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 2f9c: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 2fa0: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_2FA4:
    /* 2fa4: 5a 00 2f 18 */ jmp         @LBL_2F18:24
LBL_2FA8:
    /* 2fa8: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 2faa: 7f 0b 70 20 */ bset        #ERROR_STATUS_DRIVE_NOT_READY,@ERROR_STATUS+1:8
    /* 2fae: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 2fb2: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 2fb6: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 2fba: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 2fbe: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_2FC2:
    /* 2fc2: 7f 0e 70 10 */ bset        #0x1,@DAT_FF0E:8
    /* 2fc6: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 2fca: c0 08       */ or.b        #0x8,r0h
    /* 2fcc: 6a 80 80 0f */ mov.b       r0h,@DAT_800F:16
    /* 2fd0: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 2fd4: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 2fd8: 7f 0e 70 30 */ bset        #0x3,@DAT_FF0E:8
LBL_2FDC:
    /* 2fdc: 7f 0b 70 00 */ bset        #ERROR_STATUS_0,@ERROR_STATUS+1:8
    /* 2fe0: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 2fe4: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 2fe8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 2fec: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_2FF0:
    /* 2ff0: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 2ff4: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 2ff8: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 2ffc: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
    /* 3000: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 3002: 7f 0b 70 20 */ bset        #ERROR_STATUS_DRIVE_NOT_READY,@ERROR_STATUS+1:8
    /* 3006: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 300a: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 300e: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 3012: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3016: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_301A
    /* 301a: 7f 11 70 10 */ bset        #0x1,@DAT_FF11:8
    /* 301e: f0 c8       */ mov.b       #0xc8,r0h
LBL_3020:
    /* 3020: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
    /* 3024: 79 01 20 00 */ mov.w       #0x2000,r1
LBL_3028:
    /* 3028: 6d f1       */ mov.w       r1,@-r7
    /* 302a: 6d f0       */ mov.w       r0,@-r7
    /* 302c: 5e 00 4e 04 */ jsr         @FUNC_4E04:24
    /* 3030: 6d 70       */ mov.w       @r7+,r0
    /* 3032: 6d 71       */ mov.w       @r7+,r1
    /* 3034: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3038: 47 08       */ beq         LBL_3042
    /* 303a: 19 41       */ sub.w       r4,r1
    /* 303c: 46 ea       */ bne         LBL_3028
    /* 303e: 5a 00 30 88 */ jmp         @LBL_3088:24
LBL_3042:
    /* 3042: 7e 00 73 60 */ btst        #0x6,@DAT_FF00:8
    /* 3046: 46 04       */ bne         LBL_304C
    /* 3048: 1a 00       */ dec.b       r0h
    /* 304a: 46 d4       */ bne         LBL_3020
LBL_304C:
    /* 304c: 5e 00 4e 04 */ jsr         @FUNC_4E04:24
    /* 3050: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 3054: 47 02       */ beq         LBL_3058
    /* 3056: 40 30       */ bra         LBL_3088
LBL_3058:
    /* 3058: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 305c: 47 02       */ beq         LBL_3060
    /* 305e: 40 28       */ bra         LBL_3088
LBL_3060:
    /* 3060: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 3064: 46 22       */ bne         LBL_3088
    /* 3066: 7e 11 73 50 */ btst        #0x5,@DAT_FF11:8
    /* 306a: 47 0e       */ beq         LBL_307A
    /* 306c: 7e 0c 73 60 */ btst        #0x6,@DAT_FF0C:8
    /* 3070: 47 da       */ beq         LBL_304C
    /* 3072: 7f 11 72 10 */ bclr        #0x1,@DAT_FF11:8
    /* 3076: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 3078: 54 70       */ rts
LBL_307A:
    /* 307a: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 307e: 47 cc       */ beq         LBL_304C
    /* 3080: 7f 11 72 10 */ bclr        #0x1,@DAT_FF11:8
    /* 3084: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 3086: 54 70       */ rts
LBL_3088:
    /* 3088: 7f 11 72 10 */ bclr        #0x1,@DAT_FF11:8
    /* 308c: 04 01       */ orc         #CCR_C,ccr
    /* 308e: 54 70       */ rts

glabel COMMAND_03
    /* 3090: 5e 00 46 a4 */ jsr         @DD_COMMAND_PROLOG3:24
    /* 3094: 44 08       */ bcc         LBL_309E
    /* 3096: 7f 0b 70 00 */ bset        #ERROR_STATUS_0,@ERROR_STATUS+1:8
    /* 309a: 5a 00 31 12 */ jmp         @LBL_3112:24
LBL_309E:
    /* 309e: 7e 03 73 70 */ btst        #0x7,@DAT_FF03:8
    /* 30a2: 47 1a       */ beq         LBL_30BE
    /* 30a4: 7e 0c 73 70 */ btst        #0x7,@DAT_FF0C:8
    /* 30a8: 47 06       */ beq         LBL_30B0
    /* 30aa: 7f 0c 72 70 */ bclr        #0x7,@DAT_FF0C:8
    /* 30ae: 40 1c       */ bra         LBL_30CC
LBL_30B0:
    /* 30b0: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 30b4: 46 24       */ bne         LBL_30DA
    /* 30b6: 7e 00 73 60 */ btst        #0x6,@DAT_FF00:8
    /* 30ba: 46 1e       */ bne         LBL_30DA
    /* 30bc: 40 0e       */ bra         LBL_30CC
LBL_30BE:
    /* 30be: 5e 00 49 a8 */ jsr         @FUNC_49A8:24
    /* 30c2: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 30c6: 47 04       */ beq         LBL_30CC
    /* 30c8: 5a 00 31 0e */ jmp         @LBL_310E:24
LBL_30CC:
    /* 30cc: 5e 00 1f 00 */ jsr         @FUNC_1F00:24
    /* 30d0: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 30d4: 47 04       */ beq         LBL_30DA
    /* 30d6: 5a 00 31 0e */ jmp         @LBL_310E:24
LBL_30DA:
    /* 30da: 34 1d       */ mov.b       r4h,@DAT_FF1D:8
    /* 30dc: 79 00 01 00 */ mov.w       #0x100,r0
    /* 30e0: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 30e4: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
LBL_30E8:
    /* 30e8: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 30ec: 46 3a       */ bne         LBL_3128
    /* 30ee: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 30f2: 46 34       */ bne         LBL_3128
    /* 30f4: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 30f8: 46 5a       */ bne         LBL_3154
    /* 30fa: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 30fe: 47 e8       */ beq         LBL_30E8
    /* 3100: 5e 00 4f 16 */ jsr         @FUNC_4F16:24
    /* 3104: 45 36       */ bcs         LBL_313C
    /* 3106: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 310a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_310E:
    /* 310e: 7f 0b 70 20 */ bset        #ERROR_STATUS_DRIVE_NOT_READY,@ERROR_STATUS+1:8
LBL_3112:
    /* 3112: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3116: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 311a: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 311e: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 3120: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3124: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3128:
    /* 3128: 79 00 00 80 */ mov.w       #0x80,r0
    /* 312c: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 3130: 5e 00 45 c8 */ jsr         @FUNC_45C8:24
    /* 3134: 45 06       */ bcs         LBL_313C
    /* 3136: 5e 00 4f 16 */ jsr         @FUNC_4F16:24
    /* 313a: 44 10       */ bcc         LBL_314C
LBL_313C:
    /* 313c: 5e 00 46 e6 */ jsr         @FUNC_46E6:24
    /* 3140: 7f 0b 70 20 */ bset        #ERROR_STATUS_DRIVE_NOT_READY,@ERROR_STATUS+1:8
    /* 3144: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3148: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
LBL_314C:
    /* 314c: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3150: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3154:
    /* 3154: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 3158: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 315c: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 3160: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
    /* 3164: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 3166: 7f 0b 70 20 */ bset        #ERROR_STATUS_DRIVE_NOT_READY,@ERROR_STATUS+1:8
    /* 316a: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 316e: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3172: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 3176: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 317a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_04
    /* 317e: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 3182: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 3186: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 318a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_318E
    /* 318e: 7e 03 73 70 */ btst        #0x7,@DAT_FF03:8
    /* 3192: 47 18       */ beq         LBL_31AC
    /* 3194: 5e 00 4c 04 */ jsr         @FUNC_4C04:24
    /* 3198: 04 80       */ orc         #CCR_I,ccr
    /* 319a: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 319e: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 31a2: 7d 10 70 40 */ bset        #0x4,@r1
    /* 31a6: 5e 00 4b ac */ jsr         @FUNC_4BAC:24
    /* 31aa: 40 10       */ bra         LBL_31BC
LBL_31AC:
    /* 31ac: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 31b0: 7d 10 72 40 */ bclr        #0x4,@r1
    /* 31b4: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 31b8: 7d 10 70 40 */ bset        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
LBL_31BC:
    /* 31bc: 7f 03 72 70 */ bclr        #0x7,@DAT_FF03:8
    /* 31c0: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 31c4: 7f 11 72 60 */ bclr        #0x6,@DAT_FF11:8
    /* 31c8: 7f 11 70 70 */ bset        #0x7,@DAT_FF11:8
    /* 31cc: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 31ce: 79 00 00 00 */ mov.w       #0x0,r0
    /* 31d2: 6b 80 fe 10 */ mov.w       r0,@DAT_FE10:16
    /* 31d6: 6b 80 fe 12 */ mov.w       r0,@DAT_FE12:16
    /* 31da: 6b 80 ff 4c */ mov.w       r0,@DAT_FF4C:16
    /* 31de: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 31e2: 54 70       */ rts

glabel COMMAND_05
    /* 31e4: 5a 00 30 90 */ jmp         @COMMAND_03:24

glabel COMMAND_06
    /* 31e8: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 31ec: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 31f0: 73 00       */ btst        #0x0,r0h
    /* 31f2: 47 06       */ beq         LBL_31FA
    /* 31f4: 7f 0e 70 50 */ bset        #0x5,@DAT_FF0E:8
    /* 31f8: 40 1e       */ bra         LBL_3218
LBL_31FA:
    /* 31fa: 7f 0e 72 50 */ bclr        #0x5,@DAT_FF0E:8
    /* 31fe: f0 10       */ mov.b       #0x10,r0h
    /* 3200: 1c 08       */ cmp.b       r0h,r0l
    /* 3202: 45 04       */ bcs         LBL_3208
    /* 3204: f8 10       */ mov.b       #0x10,r0l
    /* 3206: 40 08       */ bra         LBL_3210
LBL_3208:
    /* 3208: f0 01       */ mov.b       #0x1,r0h
    /* 320a: 1c 08       */ cmp.b       r0h,r0l
    /* 320c: 44 02       */ bcc         LBL_3210
    /* 320e: f8 01       */ mov.b       #0x1,r0l
LBL_3210:
    /* 3210: f0 17       */ mov.b       #0x17,r0h
    /* 3212: 50 00       */ mulxu.b     r0h,r0
    /* 3214: 6b 80 fe 0c */ mov.w       r0,@DAT_FE0C:16
LBL_3218:
    /* 3218: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 321c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_07
    /* 3220: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 3224: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 3228: 73 00       */ btst        #0x0,r0h
    /* 322a: 47 06       */ beq         LBL_3232
    /* 322c: 7f 0e 70 40 */ bset        #0x4,@DAT_FF0E:8
    /* 3230: 40 14       */ bra         LBL_3246
LBL_3232:
    /* 3232: 7f 0e 72 40 */ bclr        #0x4,@DAT_FF0E:8
    /* 3236: f0 96       */ mov.b       #0x96,r0h
    /* 3238: 1c 08       */ cmp.b       r0h,r0l
    /* 323a: 45 02       */ bcs         LBL_323E
    /* 323c: f8 96       */ mov.b       #0x96,r0l
LBL_323E:
    /* 323e: f0 17       */ mov.b       #0x17,r0h
    /* 3240: 50 00       */ mulxu.b     r0h,r0
    /* 3242: 6b 80 fe 0e */ mov.w       r0,@DAT_FE0E:16
LBL_3246:
    /* 3246: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 324a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_CLEAR_DISK_CHANGE
    /* 324e: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 3252: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3256: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_CHANGE,@r1    // Clear disk change
    /* 325a: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 325e: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_CLR_RST_CHG
    /* 3262: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 3266: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 326a: 7d 10 72 60 */ bclr        #ASIC_STATUS_RESETTING,@r1
    /* 326e: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_CHANGE,@r1
    /* 3272: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3276: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_READ_VERSION
    /* 327a: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 327e: 6b 00 00 4c */ mov.w       @ASIC_VERSION:16,r0         // Read ASIC_VERSION
    /* 3282: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16        // Write to ASIC_DATA
    /* 3286: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 328a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_0B
    /* 328e: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3292: 6a 00 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0h
    /* 3296: e0 f0       */ and.b       #0xf0,r0h
    /* 3298: a0 10       */ cmp.b       #0x10,r0h
    /* 329a: 47 02       */ beq         LBL_329E
    /* 329c: 40 12       */ bra         LBL_32B0
LBL_329E:
    /* 329e: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 32a2: e8 0f       */ and.b       #0xf,r0l
    /* 32a4: a8 07       */ cmp.b       #0x7,r0l
    /* 32a6: 44 08       */ bcc         LBL_32B0
    /* 32a8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 32ac: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_32B0:
    /* 32b0: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 32b4: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 32b8: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 32bc: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 32c0: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_GET_ERRSTAT
    /* 32c4: 5e 00 32 cc */ jsr         @FUNC_32CC:24
    /* 32c8: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_32CC
    /* 32cc: 6b 00 ff 0a */ mov.w       @ERROR_STATUS:16,r0     // r0 = ERROR_STATUS
    /* 32d0: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16    // ASIC_DATA = r0
    /* 32d4: 79 00 00 00 */ mov.w       #0x0,r0                 // r0 = 0
    /* 32d8: 6b 80 ff 0a */ mov.w       r0,@ERROR_STATUS:16     // ERROR_STATUS = 0
    /* 32dc: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 32e0: 54 70       */ rts

glabel COMMAND_0D
    /* 32e2: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 32e6: 5e 00 32 f2 */ jsr         @FUNC_32F2:24
    /* 32ea: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 32ee: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_32F2
    /* 32f2: 5e 00 4c 04 */ jsr         @FUNC_4C04:24
    /* 32f6: 04 80       */ orc         #CCR_I,ccr
    /* 32f8: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 32fc: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 3300: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 3302: 7f 11 70 60 */ bset        #0x6,@DAT_FF11:8
    /* 3306: 7f 11 72 70 */ bclr        #0x7,@DAT_FF11:8
    /* 330a: 79 00 00 00 */ mov.w       #0x0,r0
    /* 330e: 6b 80 fe 10 */ mov.w       r0,@DAT_FE10:16
    /* 3312: 6b 80 ff 4c */ mov.w       r0,@DAT_FF4C:16
    /* 3316: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 331a: 54 70       */ rts

glabel COMMAND_0E
    /* 331c: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3320: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 3324: 46 0a       */ bne         LBL_3330
    /* 3326: 7e 00 73 60 */ btst        #0x6,@DAT_FF00:8
    /* 332a: 46 04       */ bne         LBL_3330
    /* 332c: 5a 00 33 92 */ jmp         @LBL_3392:24
LBL_3330:
    /* 3330: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 3334: 7d 10 70 20 */ bset        #0x2,@r1
    /* 3338: 79 01 00 05 */ mov.w       #0x5,r1
    /* 333c: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 3340: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 3344: 7d 10 72 20 */ bclr        #0x2,@r1
    /* 3348: 79 00 07 08 */ mov.w       #0x708,r0
    /* 334c: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
LBL_3350:
    /* 3350: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
    /* 3354: 79 01 ff ff */ mov.w       #0xffff,r1
LBL_3358:
    /* 3358: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 335c: 47 08       */ beq         LBL_3366
    /* 335e: 19 41       */ sub.w       r4,r1
    /* 3360: 46 f6       */ bne         LBL_3358
    /* 3362: 5a 00 33 92 */ jmp         @LBL_3392:24
LBL_3366:
    /* 3366: 6a 00 80 0a */ mov.b       @DAT_800A:16,r0h
    /* 336a: e0 60       */ and.b       #0x60,r0h
    /* 336c: a0 60       */ cmp.b       #0x60,r0h
    /* 336e: 47 0e       */ beq         LBL_337E
    /* 3370: 6b 00 fd 94 */ mov.w       @DAT_FD94:16,r0
    /* 3374: 19 40       */ sub.w       r4,r0
    /* 3376: 6b 80 fd 94 */ mov.w       r0,@DAT_FD94:16
    /* 337a: 46 d4       */ bne         LBL_3350
    /* 337c: 40 1a       */ bra         LBL_3398
LBL_337E:
    /* 337e: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 3382: e0 30       */ and.b       #0x30,r0h
    /* 3384: 47 f8       */ beq         LBL_337E
    /* 3386: a0 30       */ cmp.b       #0x30,r0h
    /* 3388: 46 0e       */ bne         LBL_3398
    /* 338a: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 338e: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3392:
    /* 3392: 7f 0b 70 20 */ bset        #ERROR_STATUS_DRIVE_NOT_READY,@ERROR_STATUS+1:8
    /* 3396: 40 04       */ bra         LBL_339C
LBL_3398:
    /* 3398: 7f 0b 70 10 */ bset        #ERROR_STATUS_NO_REFERENCE_POSITION_FOUND,@ERROR_STATUS+1:8
LBL_339C:
    /* 339c: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 33a0: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 33a4: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 33a8: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_RTC_SET_YEAR_MONTH
    /* 33ac: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 33b0: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 33b4: 6b 80 fe 1a */ mov.w       r0,@RTC_YEAR:16
    /* 33b8: a0 a0       */ cmp.b       #0xa0,r0h
    /* 33ba: 44 06       */ bcc         LBL_33C2
    /* 33bc: e0 0f       */ and.b       #0xf,r0h
    /* 33be: a0 0a       */ cmp.b       #0xa,r0h
    /* 33c0: 45 06       */ bcs         LBL_33C8
LBL_33C2:
    /* 33c2: f0 00       */ mov.b       #0x0,r0h
    /* 33c4: 6a 80 fe 1a */ mov.b       r0h,@RTC_YEAR:16
LBL_33C8:
    /* 33c8: a8 13       */ cmp.b       #0x13,r0l
    /* 33ca: 44 0a       */ bcc         LBL_33D6
    /* 33cc: a8 00       */ cmp.b       #0x0,r0l
    /* 33ce: 47 06       */ beq         LBL_33D6
    /* 33d0: e8 0f       */ and.b       #0xf,r0l
    /* 33d2: a8 0a       */ cmp.b       #0xa,r0l
    /* 33d4: 45 06       */ bcs         LBL_33DC
LBL_33D6:
    /* 33d6: f0 01       */ mov.b       #0x1,r0h
    /* 33d8: 6a 80 fe 1b */ mov.b       r0h,@RTC_MONTH:16
LBL_33DC:
    /* 33dc: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 33e0: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_RTC_SET_DAY_HOUR
    /* 33e4: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 33e8: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 33ec: 6b 80 fe 1c */ mov.w       r0,@RTC_DAY:16
    /* 33f0: a0 32       */ cmp.b       #0x32,r0h
    /* 33f2: 44 0a       */ bcc         LBL_33FE
    /* 33f4: a0 00       */ cmp.b       #0x0,r0h
    /* 33f6: 47 06       */ beq         LBL_33FE
    /* 33f8: e0 0f       */ and.b       #0xf,r0h
    /* 33fa: a0 0a       */ cmp.b       #0xa,r0h
    /* 33fc: 45 06       */ bcs         LBL_3404
LBL_33FE:
    /* 33fe: f0 01       */ mov.b       #0x1,r0h
    /* 3400: 6a 80 fe 1c */ mov.b       r0h,@RTC_DAY:16
LBL_3404:
    /* 3404: a8 24       */ cmp.b       #0x24,r0l
    /* 3406: 44 06       */ bcc         LBL_340E
    /* 3408: e8 0f       */ and.b       #0xf,r0l
    /* 340a: a8 0a       */ cmp.b       #0xa,r0l
    /* 340c: 45 06       */ bcs         LBL_3414
LBL_340E:
    /* 340e: f0 00       */ mov.b       #0x0,r0h
    /* 3410: 6a 80 fe 1d */ mov.b       r0h,@RTC_HOUR:16
LBL_3414:
    /* 3414: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3418: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_RTC_SET_MIN_SEC
    /* 341c: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 3420: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 3424: 6b 80 fe 1e */ mov.w       r0,@RTC_MINUTE:16
    /* 3428: a0 60       */ cmp.b       #0x60,r0h
    /* 342a: 44 06       */ bcc         LBL_3432
    /* 342c: e0 0f       */ and.b       #0xf,r0h
    /* 342e: a0 0a       */ cmp.b       #0xa,r0h
    /* 3430: 45 06       */ bcs         LBL_3438
LBL_3432:
    /* 3432: f0 00       */ mov.b       #0x0,r0h
    /* 3434: 6a 80 fe 1e */ mov.b       r0h,@RTC_MINUTE:16
LBL_3438:
    /* 3438: a8 60       */ cmp.b       #0x60,r0l
    /* 343a: 44 06       */ bcc         LBL_3442
    /* 343c: e8 0f       */ and.b       #0xf,r0l
    /* 343e: a8 0a       */ cmp.b       #0xa,r0l
    /* 3440: 45 06       */ bcs         LBL_3448
LBL_3442:
    /* 3442: f8 00       */ mov.b       #0x0,r0l
    /* 3444: 6a 88 fe 1f */ mov.b       r0l,@RTC_SECOND:16
LBL_3448:
    /* 3448: f0 03       */ mov.b       #0x3,r0h
    /* 344a: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
LBL_344E:
    /* 344e: f0 0e       */ mov.b       #0xe,r0h
    /* 3450: 5e 00 49 10 */ jsr         @FUNC_4910:24
    /* 3454: 73 00       */ btst        #0x0,r0h
    /* 3456: 47 0e       */ beq         LBL_3466
    /* 3458: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 345c: 1a 00       */ dec.b       r0h
    /* 345e: 47 06       */ beq         LBL_3466
    /* 3460: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
    /* 3464: 40 e8       */ bra         LBL_344E
LBL_3466:
    /* 3466: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 346a: 7f ba 70 20 */ bset        #0x2,@REG_P5DR:8
    /* 346e: f0 07       */ mov.b       #0x7,r0h
    /* 3470: c0 20       */ or.b        #0x20,r0h
    /* 3472: f3 08       */ mov.b       #0x8,r3h
    /* 3474: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 3478: f0 00       */ mov.b       #0x0,r0h
    /* 347a: c0 10       */ or.b        #0x10,r0h
    /* 347c: f3 08       */ mov.b       #0x8,r3h
    /* 347e: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 3482: f0 0e       */ mov.b       #0xe,r0h
    /* 3484: c0 20       */ or.b        #0x20,r0h
    /* 3486: f3 08       */ mov.b       #0x8,r3h
    /* 3488: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 348c: f0 04       */ mov.b       #0x4,r0h
    /* 348e: c0 10       */ or.b        #0x10,r0h
    /* 3490: f3 08       */ mov.b       #0x8,r3h
    /* 3492: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 3496: f0 00       */ mov.b       #0x0,r0h
    /* 3498: c0 20       */ or.b        #0x20,r0h
    /* 349a: f3 08       */ mov.b       #0x8,r3h
    /* 349c: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 34a0: 6a 00 fe 1f */ mov.b       @RTC_SECOND:16,r0h
    /* 34a4: e0 0f       */ and.b       #0xf,r0h
    /* 34a6: c0 10       */ or.b        #0x10,r0h
    /* 34a8: f3 08       */ mov.b       #0x8,r3h
    /* 34aa: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 34ae: f0 01       */ mov.b       #0x1,r0h
    /* 34b0: c0 20       */ or.b        #0x20,r0h
    /* 34b2: f3 08       */ mov.b       #0x8,r3h
    /* 34b4: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 34b8: 6a 00 fe 1f */ mov.b       @RTC_SECOND:16,r0h
    /* 34bc: 11 80       */ shar.b      r0h
    /* 34be: 11 80       */ shar.b      r0h
    /* 34c0: 11 80       */ shar.b      r0h
    /* 34c2: 11 80       */ shar.b      r0h
    /* 34c4: e0 0f       */ and.b       #0xf,r0h
    /* 34c6: c0 10       */ or.b        #0x10,r0h
    /* 34c8: f3 08       */ mov.b       #0x8,r3h
    /* 34ca: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 34ce: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 34d2: 7f ba 72 20 */ bclr        #0x2,@REG_P5DR:8
    /* 34d6: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 34da: f5 32       */ mov.b       #0x32,r5h
    /* 34dc: 6a 0d fe 1e */ mov.b       @RTC_MINUTE:16,r5l
    /* 34e0: 5e 00 35 14 */ jsr         @FUNC_3514:24
    /* 34e4: f5 54       */ mov.b       #0x54,r5h
    /* 34e6: 6a 0d fe 1d */ mov.b       @RTC_HOUR:16,r5l
    /* 34ea: 5e 00 35 14 */ jsr         @FUNC_3514:24
    /* 34ee: f5 98       */ mov.b       #0x98,r5h
    /* 34f0: 6a 0d fe 1c */ mov.b       @RTC_DAY:16,r5l
    /* 34f4: 5e 00 35 14 */ jsr         @FUNC_3514:24
    /* 34f8: f5 ba       */ mov.b       #0xba,r5h
    /* 34fa: 6a 0d fe 1b */ mov.b       @RTC_MONTH:16,r5l
    /* 34fe: 5e 00 35 14 */ jsr         @FUNC_3514:24
    /* 3502: f5 dc       */ mov.b       #0xdc,r5h
    /* 3504: 6a 0d fe 1a */ mov.b       @RTC_YEAR:16,r5l
    /* 3508: 5e 00 35 14 */ jsr         @FUNC_3514:24
    /* 350c: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3510: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_3514
    /* 3514: 0c 50       */ mov.b       r5h,r0h
    /* 3516: 0c d8       */ mov.b       r5l,r0l
    /* 3518: 5e 00 49 5e */ jsr         @FUNC_495E:24
    /* 351c: 0c 50       */ mov.b       r5h,r0h
    /* 351e: 11 80       */ shar.b      r0h
    /* 3520: 11 80       */ shar.b      r0h
    /* 3522: 11 80       */ shar.b      r0h
    /* 3524: 11 80       */ shar.b      r0h
    /* 3526: 0c d8       */ mov.b       r5l,r0l
    /* 3528: 11 88       */ shar.b      r0l
    /* 352a: 11 88       */ shar.b      r0l
    /* 352c: 11 88       */ shar.b      r0l
    /* 352e: 11 88       */ shar.b      r0l
    /* 3530: 5e 00 49 5e */ jsr         @FUNC_495E:24
    /* 3534: 54 70       */ rts

glabel COMMAND_RTC_GET_YEAR_MONTH
    /* 3536: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 353a: 6a 00 fe 1a */ mov.b       @RTC_YEAR:16,r0h
    /* 353e: 6a 08 fe 1b */ mov.b       @RTC_MONTH:16,r0l
    /* 3542: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3546: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 354a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_RTC_GET_DAY_HOUR
    /* 354e: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 3552: 6a 00 fe 1c */ mov.b       @RTC_DAY:16,r0h
    /* 3556: 6a 08 fe 1d */ mov.b       @RTC_HOUR:16,r0l
    /* 355a: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 355e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3562: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_RTC_GET_MIN_SEC
    /* 3566: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 356a: f5 02       */ mov.b       #0x2,r5h
    /* 356c: 6a 85 fd 94 */ mov.b       r5h,@DAT_FD94:16
    /* 3570: f5 10       */ mov.b       #0x10,r5h
    /* 3572: 5e 00 35 f2 */ jsr         @FUNC_35F2:24
    /* 3576: 6a 8d fe 1f */ mov.b       r5l,@RTC_SECOND:16
LBL_357A:
    /* 357a: f5 32       */ mov.b       #0x32,r5h
    /* 357c: 5e 00 35 f2 */ jsr         @FUNC_35F2:24
    /* 3580: 6a 8d fe 1e */ mov.b       r5l,@RTC_MINUTE:16
    /* 3584: f5 54       */ mov.b       #0x54,r5h
    /* 3586: 5e 00 35 f2 */ jsr         @FUNC_35F2:24
    /* 358a: 6a 8d fe 1d */ mov.b       r5l,@RTC_HOUR:16
    /* 358e: f5 98       */ mov.b       #0x98,r5h
    /* 3590: 5e 00 35 f2 */ jsr         @FUNC_35F2:24
    /* 3594: 6a 8d fe 1c */ mov.b       r5l,@RTC_DAY:16
    /* 3598: f5 ba       */ mov.b       #0xba,r5h
    /* 359a: 5e 00 35 f2 */ jsr         @FUNC_35F2:24
    /* 359e: 6a 8d fe 1b */ mov.b       r5l,@RTC_MONTH:16
    /* 35a2: f5 dc       */ mov.b       #0xdc,r5h
    /* 35a4: 5e 00 35 f2 */ jsr         @FUNC_35F2:24
    /* 35a8: 6a 8d fe 1a */ mov.b       r5l,@RTC_YEAR:16
    /* 35ac: f5 10       */ mov.b       #0x10,r5h
    /* 35ae: 5e 00 35 f2 */ jsr         @FUNC_35F2:24
    /* 35b2: 6a 05 fe 1f */ mov.b       @RTC_SECOND:16,r5h
    /* 35b6: 1c 5d       */ cmp.b       r5h,r5l
    /* 35b8: 47 14       */ beq         LBL_35CE
    /* 35ba: 6a 8d fe 1f */ mov.b       r5l,@RTC_SECOND:16
    /* 35be: 6a 05 fd 94 */ mov.b       @DAT_FD94:16,r5h
    /* 35c2: 1a 05       */ dec.b       r5h
    /* 35c4: 6a 85 fd 94 */ mov.b       r5h,@DAT_FD94:16
    /* 35c8: 47 04       */ beq         LBL_35CE
    /* 35ca: 5a 00 35 7a */ jmp         @LBL_357A:24
LBL_35CE:
    /* 35ce: f0 0e       */ mov.b       #0xe,r0h
    /* 35d0: 5e 00 49 10 */ jsr         @FUNC_4910:24
    /* 35d4: 73 10       */ btst        #0x1,r0h
    /* 35d6: 47 08       */ beq         LBL_35E0
    /* 35d8: 6b 00 fe 1e */ mov.w       @RTC_MINUTE:16,r0
    /* 35dc: 70 70       */ bset        #0x7,r0h
    /* 35de: 40 06       */ bra         LBL_35E6
LBL_35E0:
    /* 35e0: 6b 00 fe 1e */ mov.w       @RTC_MINUTE:16,r0
    /* 35e4: 72 70       */ bclr        #0x7,r0h
LBL_35E6:
    /* 35e6: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16    // ASIC_DATA = Minute and Second
    /* 35ea: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 35ee: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_35F2
    /* 35f2: 0c 50       */ mov.b       r5h,r0h
    /* 35f4: 5e 00 49 10 */ jsr         @FUNC_4910:24
    /* 35f8: 0c 0d       */ mov.b       r0h,r5l
    /* 35fa: ed 0f       */ and.b       #0xf,r5l
    /* 35fc: 0c 50       */ mov.b       r5h,r0h
    /* 35fe: 11 80       */ shar.b      r0h
    /* 3600: 11 80       */ shar.b      r0h
    /* 3602: 11 80       */ shar.b      r0h
    /* 3604: 11 80       */ shar.b      r0h
    /* 3606: 5e 00 49 10 */ jsr         @FUNC_4910:24
    /* 360a: 10 80       */ shal.b      r0h
    /* 360c: 10 80       */ shal.b      r0h
    /* 360e: 10 80       */ shal.b      r0h
    /* 3610: 10 80       */ shal.b      r0h
    /* 3612: e0 f0       */ and.b       #0xf0,r0h
    /* 3614: 14 0d       */ or.b        r0h,r5l
    /* 3616: 54 70       */ rts

glabel COMMAND_15
    /* 3618: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 361c: 6a 00 80 00 */ mov.b       @REG_ASIC_DATA:16,r0h       // ASIC_DATA_H
    /* 3620: 47 04       */ beq         LBL_3626
    /* 3622: 6a 80 fe 16 */ mov.b       r0h,@DAT_FE16:16            // LED_ON_TIME?
LBL_3626:
    /* 3626: 6a 00 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0h     // ASIC_DATA_L
    /* 362a: 47 04       */ beq         LBL_3630
    /* 362c: 6a 80 fe 17 */ mov.b       r0h,@DAT_FE17:16            // LED_OFF_TIME?
LBL_3630:
    /* 3630: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3634: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

/**
 *  COMMAND_20:
 *      DD_COMMAND_PROLOG1();
 *      u8 data = U8(ASIC_DATA+1);
 *      if (data & 1)
 *          REG_P6DR &= ~(1 << 1);
 *      else
 *          REG_P6DR |= (1 << 1);
 *      DD_COMMAND_EPILOG();
 *      goto DD_COMMAND_HANDLER;
 */
glabel COMMAND_20
    /* 3638: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 363c: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l     // read byte from ASIC_DATA
    /* 3640: 73 08       */ btst        #0x0,r0l                    // check bit 0
    /* 3642: 46 06       */ bne         LBL_364A                    // branch if bit 0 set
    /* 3644: 7f bb 70 10 */ bset        #0x1,@REG_P6DR:8            // set bit 1 in REG_P6DR
    /* 3648: 40 04       */ bra         LBL_364E                    // branch always
LBL_364A:
    /* 364a: 7f bb 72 10 */ bclr        #0x1,@REG_P6DR:8            // unset bit 1 in REG_P6DR
LBL_364E:
    /* 364e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3652: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_21
    /* 3656: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 365a: 7f 42 72 20 */ bclr        #0x2,@DAT_FF42:8
    /* 365e: 7e 0e 73 70 */ btst        #0x7,@DAT_FF0E:8
    /* 3662: 47 06       */ beq         LBL_366A
    /* 3664: f0 01       */ mov.b       #0x1,r0h
    /* 3666: 5a 00 36 f6 */ jmp         @LBL_36F6:24
LBL_366A:
    /* 366a: 7e 03 73 70 */ btst        #0x7,@DAT_FF03:8
    /* 366e: 46 06       */ bne         LBL_3676
    /* 3670: f0 02       */ mov.b       #0x2,r0h
    /* 3672: 5a 00 36 f6 */ jmp         @LBL_36F6:24
LBL_3676:
    /* 3676: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 367a: 46 06       */ bne         LBL_3682
    /* 367c: f0 07       */ mov.b       #0x7,r0h
    /* 367e: 5a 00 36 f6 */ jmp         @LBL_36F6:24
LBL_3682:
    /* 3682: 7f 42 70 70 */ bset        #0x7,@DAT_FF42:8
    /* 3686: 7f 42 70 60 */ bset        #0x6,@DAT_FF42:8
    /* 368a: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 368e: 73 00       */ btst        #0x0,r0h
    /* 3690: 46 08       */ bne         LBL_369A
    /* 3692: f0 00       */ mov.b       #0x0,r0h
    /* 3694: 6b 80 fd da */ mov.w       r0,@DAT_FDDA:16
    /* 3698: 40 0c       */ bra         LBL_36A6
LBL_369A:
    /* 369a: f0 00       */ mov.b       #0x0,r0h
    /* 369c: 17 00       */ not.b       r0h
    /* 369e: 17 08       */ not.b       r0l
    /* 36a0: 09 40       */ add.w       r4,r0
    /* 36a2: 6b 80 fd da */ mov.w       r0,@DAT_FDDA:16
LBL_36A6:
    /* 36a6: 47 0a       */ beq         LBL_36B2
    /* 36a8: 79 01 00 0c */ mov.w       #0xc,r1
    /* 36ac: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 36b0: 40 14       */ bra         LBL_36C6
LBL_36B2:
    /* 36b2: 79 00 00 00 */ mov.w       #0x0,r0
    /* 36b6: 0c 4b       */ mov.b       r4h,r3l
    /* 36b8: 79 01 fc 08 */ mov.w       #DAT_FC08,r1
LBL_36BC:
    /* 36bc: 69 90       */ mov.w       r0,@r1
    /* 36be: 0b 81       */ adds        #2,r1
    /* 36c0: 0a 0b       */ inc         r3l
    /* 36c2: ab 5a       */ cmp.b       #0x5a,r3l
    /* 36c4: 46 f6       */ bne         LBL_36BC
LBL_36C6:
    /* 36c6: 34 41       */ mov.b       r4h,@DAT_FF41:8
    /* 36c8: 5e 00 37 10 */ jsr         @FUNC_3710:24
    /* 36cc: 20 41       */ mov.b       @DAT_FF41:8,r0h
    /* 36ce: 46 26       */ bne         LBL_36F6
    /* 36d0: fb b3       */ mov.b       #0xb3,r3l
    /* 36d2: 79 01 fc 08 */ mov.w       #DAT_FC08,r1
    /* 36d6: 68 10       */ mov.b       @r1,r0h
LBL_36D8:
    /* 36d8: a0 00       */ cmp.b       #0x0,r0h
    /* 36da: 47 08       */ beq         LBL_36E4
    /* 36dc: 0b 01       */ adds        #1,r1
    /* 36de: 68 10       */ mov.b       @r1,r0h
    /* 36e0: 46 14       */ bne         LBL_36F6
    /* 36e2: 40 02       */ bra         LBL_36E6
LBL_36E4:
    /* 36e4: 0b 01       */ adds        #1,r1
LBL_36E6:
    /* 36e6: 1a 0b       */ dec.b       r3l
    /* 36e8: 47 04       */ beq         LBL_36EE
    /* 36ea: 68 10       */ mov.b       @r1,r0h
    /* 36ec: 40 ea       */ bra         LBL_36D8
LBL_36EE:
    /* 36ee: 68 10       */ mov.b       @r1,r0h
    /* 36f0: 47 04       */ beq         LBL_36F6
    /* 36f2: 6a 00 fc 08 */ mov.b       @DAT_FC08:16,r0h
LBL_36F6:
    /* 36f6: 0c 08       */ mov.b       r0h,r0l
    /* 36f8: e8 0f       */ and.b       #0xf,r0l
    /* 36fa: f0 00       */ mov.b       #0x0,r0h
    /* 36fc: 7e 42 73 20 */ btst        #0x2,@DAT_FF42:8
    /* 3700: 47 02       */ beq         LBL_3704
    /* 3702: 70 00       */ bset        #0x0,r0h
LBL_3704:
    /* 3704: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3708: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 370c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_3710
    /* 3710: 7f 42 70 60 */ bset        #0x6,@DAT_FF42:8
    /* 3714: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 3718: 6b 80 fe 04 */ mov.w       r0,@DAT_FE04:16
    /* 371c: 6b 00 fe 08 */ mov.w       @DAT_FE08:16,r0
    /* 3720: 6b 80 fe 06 */ mov.w       r0,@DAT_FE06:16
    /* 3724: 34 40       */ mov.b       r4h,@DAT_FF40:8
    /* 3726: 7f 42 72 00 */ bclr        #0x0,@DAT_FF42:8
    /* 372a: 7f 42 72 10 */ bclr        #0x1,@DAT_FF42:8
LBL_372E:
    /* 372e: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3732:
    /* 3732: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3736: 46 fa       */ bne         LBL_3732
    /* 3738: 6b 00 fd da */ mov.w       @DAT_FDDA:16,r0
    /* 373c: 46 46       */ bne         LBL_3784
    /* 373e: 6a 0a 80 1b */ mov.b       @DAT_801B:16,r2l
    /* 3742: ea 30       */ and.b       #0x30,r2l
    /* 3744: 47 0e       */ beq         LBL_3754
    /* 3746: aa 30       */ cmp.b       #0x30,r2l
    /* 3748: 47 0a       */ beq         LBL_3754
    /* 374a: 7f 42 72 60 */ bclr        #0x6,@DAT_FF42:8
    /* 374e: f0 06       */ mov.b       #0x6,r0h
    /* 3750: 30 41       */ mov.b       r0h,@DAT_FF41:8
    /* 3752: 54 70       */ rts
LBL_3754:
    /* 3754: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 3758: 6b 03 fe 04 */ mov.w       @DAT_FE04:16,r3
    /* 375c: 6b 80 fe 04 */ mov.w       r0,@DAT_FE04:16
    /* 3760: 09 30       */ add.w       r3,r0
    /* 3762: 11 80       */ shar.b      r0h
    /* 3764: 13 08       */ rotxr.b     r0l
    /* 3766: 79 03 00 00 */ mov.w       #0x0,r3
    /* 376a: 1d 30       */ cmp.w       r3,r0
    /* 376c: 4a 06       */ bpl         LBL_3774
    /* 376e: 17 00       */ not.b       r0h
    /* 3770: 17 08       */ not.b       r0l
    /* 3772: 09 40       */ add.w       r4,r0
LBL_3774:
    /* 3774: f3 00       */ mov.b       #0x0,r3h
    /* 3776: 2b 3e       */ mov.b       @DAT_FF3E:8,r3l
    /* 3778: 1d 30       */ cmp.w       r3,r0
    /* 377a: 45 68       */ bcs         LBL_37E4
    /* 377c: f0 03       */ mov.b       #0x3,r0h
    /* 377e: 30 41       */ mov.b       r0h,@DAT_FF41:8
    /* 3780: 5a 00 38 2c */ jmp         @LBL_382C:24
LBL_3784:
    /* 3784: 6b 00 fe 06 */ mov.w       @DAT_FE06:16,r0
    /* 3788: 6b 03 fe 08 */ mov.w       @DAT_FE08:16,r3
    /* 378c: 6b 83 fe 06 */ mov.w       r3,@DAT_FE06:16
    /* 3790: 7e 42 73 10 */ btst        #0x1,@DAT_FF42:8
    /* 3794: 46 32       */ bne         LBL_37C8
    /* 3796: 10 8b       */ shal.b      r3l
    /* 3798: 12 03       */ rotxl.b     r3h
    /* 379a: 19 03       */ sub.w       r0,r3
    /* 379c: 4b 10       */ bmi         LBL_37AE
    /* 379e: 6a 08 fe 0b */ mov.b       @DAT_FE0B:16,r0l
    /* 37a2: 0c 40       */ mov.b       r4h,r0h
    /* 37a4: 1d 03       */ cmp.w       r0,r3
    /* 37a6: 42 16       */ bhi         LBL_37BE
    /* 37a8: 7f 42 72 10 */ bclr        #0x1,@DAT_FF42:8
    /* 37ac: 40 36       */ bra         LBL_37E4
LBL_37AE:
    /* 37ae: 6a 08 fe 0b */ mov.b       @DAT_FE0B:16,r0l
    /* 37b2: 0c 40       */ mov.b       r4h,r0h
    /* 37b4: 09 03       */ add.w       r0,r3
    /* 37b6: 4b 06       */ bmi         LBL_37BE
    /* 37b8: 7f 42 72 10 */ bclr        #0x1,@DAT_FF42:8
    /* 37bc: 40 26       */ bra         LBL_37E4
LBL_37BE:
    /* 37be: 7f 42 70 10 */ bset        #0x1,@DAT_FF42:8
    /* 37c2: f0 03       */ mov.b       #0x3,r0h
    /* 37c4: 5a 00 38 2c */ jmp         @LBL_382C:24
LBL_37C8:
    /* 37c8: 6a 0b fe 0a */ mov.b       @DAT_FE0A:16,r3l
    /* 37cc: 0c 43       */ mov.b       r4h,r3h
    /* 37ce: 6b 00 fe 08 */ mov.w       @DAT_FE08:16,r0
    /* 37d2: 4b 06       */ bmi         LBL_37DA
    /* 37d4: 1d 30       */ cmp.w       r3,r0
    /* 37d6: 42 06       */ bhi         LBL_37DE
    /* 37d8: 40 0a       */ bra         LBL_37E4
LBL_37DA:
    /* 37da: 09 30       */ add.w       r3,r0
    /* 37dc: 4a 06       */ bpl         LBL_37E4
LBL_37DE:
    /* 37de: f0 03       */ mov.b       #0x3,r0h
    /* 37e0: 5a 00 38 2c */ jmp         @LBL_382C:24
LBL_37E4:
    /* 37e4: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 37e8: ed 07       */ and.b       #0x7,r5l
    /* 37ea: ad 03       */ cmp.b       #0x3,r5l
    /* 37ec: 47 1e       */ beq         LBL_380C
    /* 37ee: 7f 42 70 20 */ bset        #0x2,@DAT_FF42:8
    /* 37f2: 7e 42 73 00 */ btst        #0x0,@DAT_FF42:8
    /* 37f6: 47 0a       */ beq         LBL_3802
    /* 37f8: ad 04       */ cmp.b       #0x4,r5l
    /* 37fa: 47 10       */ beq         LBL_380C
    /* 37fc: f0 05       */ mov.b       #0x5,r0h
    /* 37fe: 30 41       */ mov.b       r0h,@DAT_FF41:8
    /* 3800: 40 2a       */ bra         LBL_382C
LBL_3802:
    /* 3802: f0 05       */ mov.b       #0x5,r0h
    /* 3804: 7f 42 70 00 */ bset        #0x0,@DAT_FF42:8
    /* 3808: 5a 00 38 2c */ jmp         @LBL_382C:24
LBL_380C:
    /* 380c: 7f 42 72 00 */ bclr        #0x0,@DAT_FF42:8
    /* 3810: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 3814: e0 07       */ and.b       #0x7,r0h
    /* 3816: 6b 03 fd 84 */ mov.w       @DAT_FD84:16,r3
    /* 381a: 1d 03       */ cmp.w       r0,r3
    /* 381c: 47 1c       */ beq         LBL_383A
    /* 381e: 7f 42 70 20 */ bset        #0x2,@DAT_FF42:8
    /* 3822: 20 33       */ mov.b       @DAT_FF33:8,r0h
    /* 3824: a0 02       */ cmp.b       #0x2,r0h
    /* 3826: 4b 12       */ bmi         LBL_383A
    /* 3828: f0 08       */ mov.b       #0x8,r0h
    /* 382a: 40 00       */ bra         LBL_382C
LBL_382C:
    /* 382c: 79 01 fc 08 */ mov.w       #DAT_FC08,r1
    /* 3830: 6a 08 80 0e */ mov.b       @DAT_800E:16,r0l
    /* 3834: 08 89       */ add.b       r0l,r1l
    /* 3836: 0e 41       */ addx        r4h,r1h
    /* 3838: 68 90       */ mov.b       r0h,@r1
LBL_383A:
    /* 383a: 28 40       */ mov.b       @DAT_FF40:8,r0l
    /* 383c: 0a 08       */ inc         r0l
    /* 383e: 38 40       */ mov.b       r0l,@DAT_FF40:8
    /* 3840: a8 b9       */ cmp.b       #0xb9,r0l
    /* 3842: 47 04       */ beq         LBL_3848
    /* 3844: 5a 00 37 2e */ jmp         @LBL_372E:24
LBL_3848:
    /* 3848: f0 00       */ mov.b       #0x0,r0h
    /* 384a: 7f 42 72 60 */ bclr        #0x6,@DAT_FF42:8
    /* 384e: 54 70       */ rts

glabel COMMAND_23
    /* 3850: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3854: 5e 00 21 fc */ jsr         @FUNC_21FC:24
    /* 3858: f0 00       */ mov.b       #0x0,r0h
    /* 385a: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 385e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3862: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_24
    /* 3866: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 386a: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 386e: 46 04       */ bne         LBL_3874
    /* 3870: 5a 00 38 e0 */ jmp         @LBL_38E0:24
LBL_3874:
    /* 3874: 79 02 01 68 */ mov.w       #0x168,r2
    /* 3878: 79 00 00 00 */ mov.w       #0x0,r0
    /* 387c: 6b 80 fd fc */ mov.w       r0,@DAT_FDFC:16
    /* 3880: 79 00 ff ff */ mov.w       #0xffff,r0
    /* 3884: 6b 80 fd fe */ mov.w       r0,@DAT_FDFE:16
LBL_3888:
    /* 3888: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_388C:
    /* 388c: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3890: 46 fa       */ bne         LBL_388C
    /* 3892: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 3896: 4b 0e       */ bmi         LBL_38A6
    /* 3898: 6b 03 fd fc */ mov.w       @DAT_FDFC:16,r3
    /* 389c: 1d 30       */ cmp.w       r3,r0
    /* 389e: 45 12       */ bcs         LBL_38B2
    /* 38a0: 6b 80 fd fc */ mov.w       r0,@DAT_FDFC:16
    /* 38a4: 40 0c       */ bra         LBL_38B2
LBL_38A6:
    /* 38a6: 6b 03 fd fe */ mov.w       @DAT_FDFE:16,r3
    /* 38aa: 1d 30       */ cmp.w       r3,r0
    /* 38ac: 44 04       */ bcc         LBL_38B2
    /* 38ae: 6b 80 fd fe */ mov.w       r0,@DAT_FDFE:16
LBL_38B2:
    /* 38b2: 19 42       */ sub.w       r4,r2
    /* 38b4: 46 d2       */ bne         LBL_3888
    /* 38b6: 6b 00 fd fc */ mov.w       @DAT_FDFC:16,r0
    /* 38ba: a0 00       */ cmp.b       #0x0,r0h
    /* 38bc: 47 02       */ beq         LBL_38C0
    /* 38be: f8 ff       */ mov.b       #0xff,r0l
LBL_38C0:
    /* 38c0: 0c 80       */ mov.b       r0l,r0h
    /* 38c2: 6b 05 fd fe */ mov.w       @DAT_FDFE:16,r5
    /* 38c6: 17 05       */ not.b       r5h
    /* 38c8: 17 0d       */ not.b       r5l
    /* 38ca: 09 45       */ add.w       r4,r5
    /* 38cc: a5 00       */ cmp.b       #0x0,r5h
    /* 38ce: 47 02       */ beq         LBL_38D2
    /* 38d0: fd ff       */ mov.b       #0xff,r5l
LBL_38D2:
    /* 38d2: 0c d8       */ mov.b       r5l,r0l
    /* 38d4: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 38d8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 38dc: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_38E0:
    /* 38e0: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 38e4: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 38e8: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 38ec: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 38f0: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_25
    /* 38f4: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 38f8: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 38fc: 46 04       */ bne         LBL_3902
    /* 38fe: 5a 00 39 2e */ jmp         @LBL_392E:24
LBL_3902:
    /* 3902: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 3906: 4b 0a       */ bmi         LBL_3912
    /* 3908: a0 00       */ cmp.b       #0x0,r0h
    /* 390a: 47 04       */ beq         LBL_3910
    /* 390c: 79 00 00 ff */ mov.w       #0xff,r0
LBL_3910:
    /* 3910: 40 10       */ bra         LBL_3922
LBL_3912:
    /* 3912: 17 00       */ not.b       r0h
    /* 3914: 17 08       */ not.b       r0l
    /* 3916: 09 40       */ add.w       r4,r0
    /* 3918: a0 00       */ cmp.b       #0x0,r0h
    /* 391a: 47 04       */ beq         LBL_3920
    /* 391c: 79 00 00 ff */ mov.w       #0xff,r0
LBL_3920:
    /* 3920: f0 01       */ mov.b       #0x1,r0h
LBL_3922:
    /* 3922: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3926: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 392a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_392E:
    /* 392e: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3932: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3936: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 393a: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 393e: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_26
    /* 3942: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3946: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 394a: 73 00       */ btst        #0x0,r0h
    /* 394c: 47 04       */ beq         LBL_3952
    /* 394e: 38 19       */ mov.b       r0l,@DAT_FF19:8
    /* 3950: 40 02       */ bra         LBL_3954
LBL_3952:
    /* 3952: 38 18       */ mov.b       r0l,@DAT_FF18:8
LBL_3954:
    /* 3954: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3958: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_27
    /* 395c: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3960: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 3964: 73 00       */ btst        #0x0,r0h
    /* 3966: 47 04       */ beq         LBL_396C
    /* 3968: 38 16       */ mov.b       r0l,@DAT_FF16:8
    /* 396a: 40 02       */ bra         LBL_396E
LBL_396C:
    /* 396c: 38 15       */ mov.b       r0l,@DAT_FF15:8
LBL_396E:
    /* 396e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3972: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_28
    /* 3976: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 397a: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 397e: 46 04       */ bne         LBL_3984
    /* 3980: 5a 00 39 ec */ jmp         @LBL_39EC:24
LBL_3984:
    /* 3984: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
    /* 3988: 79 01 ff ff */ mov.w       #0xffff,r1
LBL_398C:
    /* 398c: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3990: 47 08       */ beq         LBL_399A
    /* 3992: 19 41       */ sub.w       r4,r1
    /* 3994: 46 f6       */ bne         LBL_398C
    /* 3996: 5a 00 39 ec */ jmp         @LBL_39EC:24
LBL_399A:
    /* 399a: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 399e: 73 00       */ btst        #0x0,r0h
    /* 39a0: 46 08       */ bne         LBL_39AA
    /* 39a2: f0 00       */ mov.b       #0x0,r0h
    /* 39a4: 6b 80 fd da */ mov.w       r0,@DAT_FDDA:16
    /* 39a8: 40 0c       */ bra         LBL_39B6
LBL_39AA:
    /* 39aa: f0 00       */ mov.b       #0x0,r0h
    /* 39ac: 17 00       */ not.b       r0h
    /* 39ae: 17 08       */ not.b       r0l
    /* 39b0: 09 40       */ add.w       r4,r0
    /* 39b2: 6b 80 fd da */ mov.w       r0,@DAT_FDDA:16
LBL_39B6:
    /* 39b6: 20 18       */ mov.b       @DAT_FF18:8,r0h
    /* 39b8: 30 17       */ mov.b       r0h,@DAT_FF17:8
    /* 39ba: 20 15       */ mov.b       @DAT_FF15:8,r0h
    /* 39bc: 30 14       */ mov.b       r0h,@DAT_FF14:8
    /* 39be: f0 40       */ mov.b       #0x40,r0h
    /* 39c0: 30 00       */ mov.b       r0h,@DAT_FF00:8
    /* 39c2: 79 00 70 3f */ mov.w       #0x703f,r0
    /* 39c6: 6b 80 fd 8c */ mov.w       r0,@DAT_FD8C:16
    /* 39ca: 79 00 00 80 */ mov.w       #0x80,r0
    /* 39ce: 6b 80 fd b6 */ mov.w       r0,@DAT_FDB6:16
LBL_39D2:
    /* 39d2: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 39d6: 46 1a       */ bne         LBL_39F2
    /* 39d8: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 39dc: 46 14       */ bne         LBL_39F2
    /* 39de: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 39e2: 47 ee       */ beq         LBL_39D2
    /* 39e4: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 39e8: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_39EC:
    /* 39ec: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 39f0: 40 04       */ bra         LBL_39F6
LBL_39F2:
    /* 39f2: 7f 0b 70 30 */ bset        #ERROR_STATUS_NO_SEEK_COMPLETE,@ERROR_STATUS+1:8
LBL_39F6:
    /* 39f6: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 39fa: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 39fe: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3a02: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_29
    /* 3a06: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3a0a: 7e 03 73 70 */ btst        #0x7,@DAT_FF03:8
    /* 3a0e: 47 4c       */ beq         LBL_3A5C
    /* 3a10: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
LBL_3A14:
    /* 3a14: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 3a18: 47 fa       */ beq         LBL_3A14
    /* 3a1a: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
    /* 3a1e: 6b 00 ff 9a */ mov.w       @REG_ICRB:16,r0
    /* 3a22: 6b 80 fd f4 */ mov.w       r0,@DAT_FDF4:16
    /* 3a26: 6a 84 fd eb */ mov.b       r4h,@DAT_FDEB:16
LBL_3A2A:
    /* 3a2a: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 3a2e: 47 fa       */ beq         LBL_3A2A
    /* 3a30: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
    /* 3a34: 6a 00 fd eb */ mov.b       @DAT_FDEB:16,r0h
    /* 3a38: 0a 00       */ inc         r0h
    /* 3a3a: 6a 80 fd eb */ mov.b       r0h,@DAT_FDEB:16
    /* 3a3e: a0 3c       */ cmp.b       #0x3c,r0h
    /* 3a40: 4b e8       */ bmi         LBL_3A2A
    /* 3a42: 6b 00 ff 9a */ mov.w       @REG_ICRB:16,r0
    /* 3a46: 6b 03 fd f4 */ mov.w       @DAT_FDF4:16,r3
    /* 3a4a: 6b 80 fd f4 */ mov.w       r0,@DAT_FDF4:16
    /* 3a4e: 19 30       */ sub.w       r3,r0
    /* 3a50: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3a54: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3a58: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3A5C:
    /* 3a5c: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3a60: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3a64: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3a68: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3a6c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_2A
    /* 3a70: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3a74: 6a 08 80 00 */ mov.b       @REG_ASIC_DATA:16,r0l
    /* 3a78: 0c 83       */ mov.b       r0l,r3h
    /* 3a7a: e3 0f       */ and.b       #0xf,r3h
    /* 3a7c: fb 09       */ mov.b       #0x9,r3l
    /* 3a7e: 50 33       */ mulxu.b     r3h,r3
    /* 3a80: f0 00       */ mov.b       #0x0,r0h
    /* 3a82: 11 08       */ shlr.b      r0l
    /* 3a84: 11 08       */ shlr.b      r0l
    /* 3a86: 11 08       */ shlr.b      r0l
    /* 3a88: 11 08       */ shlr.b      r0l
    /* 3a8a: 79 01 fb 80 */ mov.w       #0xfb80,r1
    /* 3a8e: 09 31       */ add.w       r3,r1
    /* 3a90: 09 01       */ add.w       r0,r1
    /* 3a92: 68 10       */ mov.b       @r1,r0h
    /* 3a94: 6a 80 80 01 */ mov.b       r0h,@REG_ASIC_DATA+1:16
    /* 3a98: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3a9c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_2B
    /* 3aa0: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3aa4: 6a 00 80 00 */ mov.b       @REG_ASIC_DATA:16,r0h
    /* 3aa8: e0 0f       */ and.b       #0xf,r0h
    /* 3aaa: 5e 00 47 ac */ jsr         @FUNC_47AC:24
    /* 3aae: 6a 80 80 01 */ mov.b       r0h,@REG_ASIC_DATA+1:16
    /* 3ab2: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3ab6: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_2C
    /* 3aba: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3abe: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 3ac2: 0c 03       */ mov.b       r0h,r3h
    /* 3ac4: e3 0f       */ and.b       #0xf,r3h
    /* 3ac6: 0c 35       */ mov.b       r3h,r5h
    /* 3ac8: fb 09       */ mov.b       #0x9,r3l
    /* 3aca: 50 33       */ mulxu.b     r3h,r3
    /* 3acc: 11 00       */ shlr.b      r0h
    /* 3ace: 11 00       */ shlr.b      r0h
    /* 3ad0: 11 00       */ shlr.b      r0h
    /* 3ad2: 11 00       */ shlr.b      r0h
    /* 3ad4: a0 09       */ cmp.b       #0x9,r0h
    /* 3ad6: 44 20       */ bcc         LBL_3AF8
    /* 3ad8: 79 01 fb 80 */ mov.w       #DAT_FB80,r1
    /* 3adc: 09 31       */ add.w       r3,r1
    /* 3ade: 08 09       */ add.b       r0h,r1l
    /* 3ae0: 91 00       */ addx        #0x0,r1h
    /* 3ae2: 68 98       */ mov.b       r0l,@r1
    /* 3ae4: 2b 44       */ mov.b       @DAT_FF44:8,r3l
    /* 3ae6: 1c 0b       */ cmp.b       r0h,r3l
    /* 3ae8: 46 06       */ bne         LBL_3AF0
    /* 3aea: 0c 50       */ mov.b       r5h,r0h
    /* 3aec: 5e 00 47 f4 */ jsr         @FUNC_47F4:24
LBL_3AF0:
    /* 3af0: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3af4: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3AF8:
    /* 3af8: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3afc: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3b00: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3b04: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3b08: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_2D
    /* 3b0c: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3b10: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 3b14: 0c 03       */ mov.b       r0h,r3h
    /* 3b16: e3 0f       */ and.b       #0xf,r3h
    /* 3b18: 79 01 3b 8e */ mov.w       #DAT_3B8E,r1
    /* 3b1c: 79 02 3b 94 */ mov.w       #DAT_3B8E_END,r2
LBL_3B20:
    /* 3b20: 1d 21       */ cmp.w       r2,r1
    /* 3b22: 45 04       */ bcs         LBL_3B28
    /* 3b24: 5a 00 3a ba */ jmp         @COMMAND_2C:24
LBL_3B28:
    /* 3b28: 68 1b       */ mov.b       @r1,r3l
    /* 3b2a: 1c b3       */ cmp.b       r3l,r3h
    /* 3b2c: 47 04       */ beq         LBL_3B32
    /* 3b2e: 0b 01       */ adds        #1,r1
    /* 3b30: 40 ee       */ bra         LBL_3B20
LBL_3B32:
    /* 3b32: 79 02 3b 8e */ mov.w       #DAT_3B8E,r2
    /* 3b36: 19 21       */ sub.w       r2,r1
    /* 3b38: f1 09       */ mov.b       #0x9,r1h
    /* 3b3a: 50 11       */ mulxu.b     r1h,r1
    /* 3b3c: 11 00       */ shlr.b      r0h
    /* 3b3e: 11 00       */ shlr.b      r0h
    /* 3b40: 11 00       */ shlr.b      r0h
    /* 3b42: 11 00       */ shlr.b      r0h
    /* 3b44: a0 09       */ cmp.b       #0x9,r0h
    /* 3b46: 44 32       */ bcc         LBL_3B7A
    /* 3b48: 08 90       */ add.b       r1l,r0h
    /* 3b4a: 6d f0       */ mov.w       r0,@-r7
    /* 3b4c: 11 80       */ shar.b      r0h
    /* 3b4e: 5e 00 48 2e */ jsr         @FUNC_482E:24
    /* 3b52: 6d 73       */ mov.w       @r7+,r3
    /* 3b54: 11 83       */ shar.b      r3h
    /* 3b56: 45 04       */ bcs         LBL_3B5C
    /* 3b58: 0c b0       */ mov.b       r3l,r0h
    /* 3b5a: 40 02       */ bra         LBL_3B5E
LBL_3B5C:
    /* 3b5c: 0c b8       */ mov.b       r3l,r0l
LBL_3B5E:
    /* 3b5e: 0c 3b       */ mov.b       r3h,r3l
    /* 3b60: 5e 00 48 72 */ jsr         @FUNC_4872:24
    /* 3b64: 45 04       */ bcs         LBL_3B6A
    /* 3b66: 5a 00 3a ba */ jmp         @COMMAND_2C:24
LBL_3B6A:
    /* 3b6a: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3b6e: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3b72: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3b76: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3B7A:
    /* 3b7a: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3b7e: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3b82: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3b86: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3b8a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel DAT_3B8E
    /* 3b8e: 01 03       */ .word   0x0103
    /* 3b90: 04 07       */ .word   0x0407
    /* 3b92: 09 0c       */ .word   0x090C
glabel DAT_3B8E_END

// ASIC_DATA: upper byte is the register offset to read from, lower byte is filled with the read data
glabel COMMAND_DEBUG_READREG
    /* 3b94: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3b98: 6a 08 80 00 */ mov.b       @REG_ASIC_DATA:16,r0l
    /* 3b9c: f0 00       */ mov.b       #0x0,r0h
    /* 3b9e: 79 01 80 00 */ mov.w       #REG_ASIC_DATA,r1
    /* 3ba2: 09 01       */ add.w       r0,r1
    /* 3ba4: 68 18       */ mov.b       @r1,r0l
    /* 3ba6: 6a 88 80 01 */ mov.b       r0l,@REG_ASIC_DATA+1:16     // *ASIC_DATA_l = *(ASIC_DATA + *ASIC_DATA_h)
    /* 3baa: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3bae: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

// ASIC_DATA: upper byte is the register offset and lower byte is the value to write to it
glabel COMMAND_DEBUG_WRITEREG
    /* 3bb2: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3bb6: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 3bba: 79 01 80 00 */ mov.w       #REG_ASIC_DATA,r1
    /* 3bbe: 08 09       */ add.b       r0h,r1l
    /* 3bc0: 91 00       */ addx        #0x0,r1h
    /* 3bc2: 68 98       */ mov.b       r0l,@r1                     // *(ASIC_DATA + *ASIC_DATA_h) = *ASIC_DATA_l
    /* 3bc4: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3bc8: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_DEBUG_SETADDR
    /* 3bcc: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3bd0: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0        // Read upper 16 bits of ASIC_DATA
    /* 3bd4: 6b 80 fd a0 */ mov.w       r0,@DEBUG_MEMADDR:16        // Store to debug mem addr for commands 0x31/0x32
    /* 3bd8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3bdc: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_DEBUG_READMEM
    /* 3be0: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3be4: 6b 01 fd a0 */ mov.w       @DEBUG_MEMADDR:16,r1        // Get debug mem addr
    /* 3be8: 68 18       */ mov.b       @r1,r0l                     // Read the byte at the address
    /* 3bea: 6a 88 80 01 */ mov.b       r0l,@REG_ASIC_DATA+1:16     // Write to ASIC_DATA
    /* 3bee: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3bf2: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_DEBUG_WRITEMEM
    /* 3bf6: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3bfa: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l     // Read the byte to write from ASIC_DATA
    /* 3bfe: 6b 01 fd a0 */ mov.w       @DEBUG_MEMADDR:16,r1        // Get debug mem addr
    /* 3c02: 68 98       */ mov.b       r0l,@r1                     // Store the byte to debug mem addr
    /* 3c04: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3c08: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_33
    /* 3c0c: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3c10: 6a 00 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0h     // r0h = ASIC_DATA_l
    /* 3c14: 73 00       */ btst        #0x0,r0h                    // test bit 0
    /* 3c16: 47 06       */ beq         LBL_3C1E                    // branch if bit 0 is unset
    /* 3c18: 5e 00 47 8e */ jsr         @FUNC_478E:24
    /* 3c1c: 40 04       */ bra         LBL_3C22
LBL_3C1E:
    /* 3c1e: 5e 00 47 9c */ jsr         @FUNC_479C:24
LBL_3C22:
    /* 3c22: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3c26: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_34
    /* 3c2a: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3c2e: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 3c32: 46 04       */ bne         LBL_3C38
    /* 3c34: 5a 00 3c 66 */ jmp         @LBL_3C66:24
LBL_3C38:
    /* 3c38: 6a 00 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0h
    /* 3c3c: a0 b4       */ cmp.b       #0xb4,r0h
    /* 3c3e: 45 04       */ bcs         LBL_3C44
    /* 3c40: 5a 00 3c 66 */ jmp         @LBL_3C66:24
LBL_3C44:
    /* 3c44: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3C48:
    /* 3c48: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3c4c: 46 fa       */ bne         LBL_3C48
    /* 3c4e: 6a 08 80 0e */ mov.b       @DAT_800E:16,r0l
    /* 3c52: 1c 80       */ cmp.b       r0l,r0h
    /* 3c54: 46 ee       */ bne         LBL_3C44
    /* 3c56: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 3c5a: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3c5e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3c62: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3C66:
    /* 3c66: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3c6a: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3c6e: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3c72: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3c76: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_35
    /* 3c7a: 5e 00 4c 04 */ jsr         @FUNC_4C04:24
    /* 3c7e: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 3c80: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 3c84: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3c88: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_36
    /* 3c8c: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 3c90: 46 04       */ bne         LBL_3C96
    /* 3c92: 5a 00 30 90 */ jmp         @COMMAND_03:24
LBL_3C96:
    /* 3c96: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3c9a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_38
    /* 3c9e: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 3ca2: 38 1b       */ mov.b       r0l,@DAT_FF1B:8
    /* 3ca4: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3ca8: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_39
    /* 3cac: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3cb0: 5e 00 50 2a */ jsr         @FUNC_502A:24
    /* 3cb4: 44 04       */ bcc         LBL_3CBA
    /* 3cb6: 5a 00 3d 7c */ jmp         @LBL_3D7C:24
LBL_3CBA:
    /* 3cba: 79 00 00 00 */ mov.w       #0x0,r0
    /* 3cbe: 6b 80 fe 04 */ mov.w       r0,@DAT_FE04:16
    /* 3cc2: 79 02 01 68 */ mov.w       #0x168,r2
    /* 3cc6: 79 00 00 00 */ mov.w       #0x0,r0
    /* 3cca: 6b 80 fd fc */ mov.w       r0,@DAT_FDFC:16
    /* 3cce: 79 00 ff ff */ mov.w       #0xffff,r0
    /* 3cd2: 6b 80 fd fe */ mov.w       r0,@DAT_FDFE:16
LBL_3CD6:
    /* 3cd6: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3CDA:
    /* 3cda: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3cde: 46 fa       */ bne         LBL_3CDA
    /* 3ce0: 6a 00 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0h
    /* 3ce4: 73 10       */ btst        #0x1,r0h
    /* 3ce6: 47 14       */ beq         LBL_3CFC
    /* 3ce8: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 3cec: 6b 03 fe 04 */ mov.w       @DAT_FE04:16,r3
    /* 3cf0: 09 30       */ add.w       r3,r0
    /* 3cf2: 11 80       */ shar.b      r0h
    /* 3cf4: 13 08       */ rotxr.b     r0l
    /* 3cf6: 6b 80 fe 04 */ mov.w       r0,@DAT_FE04:16
    /* 3cfa: 40 04       */ bra         LBL_3D00
LBL_3CFC:
    /* 3cfc: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
LBL_3D00:
    /* 3d00: 4b 16       */ bmi         LBL_3D18
    /* 3d02: 6b 03 fd fc */ mov.w       @DAT_FDFC:16,r3
    /* 3d06: 1d 30       */ cmp.w       r3,r0
    /* 3d08: 45 22       */ bcs         LBL_3D2C
    /* 3d0a: 6b 80 fd fc */ mov.w       r0,@DAT_FDFC:16
    /* 3d0e: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 3d12: 6a 80 fd 92 */ mov.b       r0h,@DAT_FD92:16
    /* 3d16: 40 14       */ bra         LBL_3D2C
LBL_3D18:
    /* 3d18: 6b 03 fd fe */ mov.w       @DAT_FDFE:16,r3
    /* 3d1c: 1d 30       */ cmp.w       r3,r0
    /* 3d1e: 44 0c       */ bcc         LBL_3D2C
    /* 3d20: 6b 80 fd fe */ mov.w       r0,@DAT_FDFE:16
    /* 3d24: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 3d28: 6a 80 fd 93 */ mov.b       r0h,@DAT_FD93:16
LBL_3D2C:
    /* 3d2c: 19 42       */ sub.w       r4,r2
    /* 3d2e: 46 a6       */ bne         LBL_3CD6
    /* 3d30: 6a 00 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0h
    /* 3d34: 73 00       */ btst        #0x0,r0h
    /* 3d36: 46 10       */ bne         LBL_3D48
    /* 3d38: 6b 00 fd fc */ mov.w       @DAT_FDFC:16,r0
    /* 3d3c: a0 00       */ cmp.b       #0x0,r0h
    /* 3d3e: 47 02       */ beq         LBL_3D42
    /* 3d40: f8 ff       */ mov.b       #0xff,r0l
LBL_3D42:
    /* 3d42: 6a 00 fd 92 */ mov.b       @DAT_FD92:16,r0h
    /* 3d46: 40 14       */ bra         LBL_3D5C
LBL_3D48:
    /* 3d48: 6b 00 fd fe */ mov.w       @DAT_FDFE:16,r0
    /* 3d4c: 17 00       */ not.b       r0h
    /* 3d4e: 17 08       */ not.b       r0l
    /* 3d50: 09 40       */ add.w       r4,r0
    /* 3d52: a0 00       */ cmp.b       #0x0,r0h
    /* 3d54: 47 02       */ beq         LBL_3D58
    /* 3d56: f8 ff       */ mov.b       #0xff,r0l
LBL_3D58:
    /* 3d58: 6a 00 fd 93 */ mov.b       @DAT_FD93:16,r0h
LBL_3D5C:
    /* 3d5c: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3d60: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3d64: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3D68: // unused?
    /* 3d68: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3d6c: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3d70: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3d74: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3d78: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3D7C:
    /* 3d7c: 7f 0b 70 30 */ bset        #ERROR_STATUS_NO_SEEK_COMPLETE,@ERROR_STATUS+1:8
    /* 3d80: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3d84: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 3d88: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3d8c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_3A
    /* 3d90: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3d94: 5e 00 50 2a */ jsr         @FUNC_502A:24
    /* 3d98: 44 04       */ bcc         LBL_3D9E
    /* 3d9a: 5a 00 3e 34 */ jmp         @LBL_3E34:24
LBL_3D9E:
    /* 3d9e: 5e 00 50 16 */ jsr         @FUNC_5016:24
    /* 3da2: 79 02 00 b4 */ mov.w       #0xb4,r2
    /* 3da6: 79 00 fc 08 */ mov.w       #DAT_FC08,r0
    /* 3daa: 6b 80 fd 92 */ mov.w       r0,@DAT_FD92:16
    /* 3dae: 34 25       */ mov.b       r4h,@DAT_FF25:8
    /* 3db0: 0c 4e       */ mov.b       r4h,r6l
    /* 3db2: 7f 42 70 60 */ bset        #0x6,@DAT_FF42:8
LBL_3DB6:
    /* 3db6: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3DBA:
    /* 3dba: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3dbe: 46 fa       */ bne         LBL_3DBA
    /* 3dc0: 7f 03 72 60 */ bclr        #0x6,@DAT_FF03:8
    /* 3dc4: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 3dc8: ed 30       */ and.b       #0x30,r5l
    /* 3dca: 47 0a       */ beq         LBL_3DD6
    /* 3dcc: ad 30       */ cmp.b       #0x30,r5l
    /* 3dce: 47 06       */ beq         LBL_3DD6
    /* 3dd0: 70 0e       */ bset        #0x0,r6l
    /* 3dd2: 7f 03 70 60 */ bset        #0x6,@DAT_FF03:8
LBL_3DD6:
    /* 3dd6: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 3dda: ed 07       */ and.b       #0x7,r5l
    /* 3ddc: ad 03       */ cmp.b       #0x3,r5l
    /* 3dde: 47 06       */ beq         LBL_3DE6
    /* 3de0: 70 1e       */ bset        #0x1,r6l
    /* 3de2: 7f 03 70 60 */ bset        #0x6,@DAT_FF03:8
LBL_3DE6:
    /* 3de6: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 3dea: e0 07       */ and.b       #0x7,r0h
    /* 3dec: 6b 03 fd 84 */ mov.w       @DAT_FD84:16,r3
    /* 3df0: 1d 03       */ cmp.w       r0,r3
    /* 3df2: 47 06       */ beq         LBL_3DFA
    /* 3df4: 70 2e       */ bset        #0x2,r6l
    /* 3df6: 7f 03 70 60 */ bset        #0x6,@DAT_FF03:8
LBL_3DFA:
    /* 3dfa: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 3dfe: 47 18       */ beq         LBL_3E18
    /* 3e00: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 3e04: 0c e8       */ mov.b       r6l,r0l
    /* 3e06: 6b 01 fd 92 */ mov.w       @DAT_FD92:16,r1
    /* 3e0a: 69 90       */ mov.w       r0,@r1
    /* 3e0c: 0b 81       */ adds        #2,r1
    /* 3e0e: 6b 81 fd 92 */ mov.w       r1,@DAT_FD92:16
    /* 3e12: 20 25       */ mov.b       @DAT_FF25:8,r0h
    /* 3e14: 0a 00       */ inc         r0h
    /* 3e16: 30 25       */ mov.b       r0h,@DAT_FF25:8
LBL_3E18:
    /* 3e18: 19 42       */ sub.w       r4,r2
    /* 3e1a: 47 04       */ beq         LBL_3E20
    /* 3e1c: 5a 00 3d b6 */ jmp         @LBL_3DB6:24
LBL_3E20:
    /* 3e20: f0 00       */ mov.b       #0x0,r0h
    /* 3e22: 28 25       */ mov.b       @DAT_FF25:8,r0l
    /* 3e24: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3e28: 7f 42 72 60 */ bclr        #0x6,@DAT_FF42:8
    /* 3e2c: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3e30: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_3E34:
    /* 3e34: 7f 42 72 60 */ bclr        #0x6,@DAT_FF42:8
    /* 3e38: 7f 0b 70 30 */ bset        #ERROR_STATUS_NO_SEEK_COMPLETE,@ERROR_STATUS+1:8
    /* 3e3c: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3e40: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1 // raise mechanic error
    /* 3e44: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3e48: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_3B
    /* 3e4c: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3e50: 7f 0d 70 00 */ bset        #0x0,@DAT_FF0D:8
    /* 3e54: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 3e58: 7f 00 72 50 */ bclr        #0x5,@DAT_FF00:8
    /* 3e5c: 79 00 03 20 */ mov.w       #0x320,r0
    /* 3e60: 6b 80 fd d8 */ mov.w       r0,@DAT_FDD8:16
    /* 3e64: 7f 0c 70 70 */ bset        #0x7,@DAT_FF0C:8
    /* 3e68: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3e6c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_3C
    /* 3e70: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3e74: 5e 00 50 16 */ jsr         @FUNC_5016:24
    /* 3e78: 79 01 80 00 */ mov.w       #REG_ASIC_DATA,r1
    /* 3e7c: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3E80:
    /* 3e80: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3e84: 47 08       */ beq         LBL_3E8E
    /* 3e86: 19 41       */ sub.w       r4,r1
    /* 3e88: 46 f6       */ bne         LBL_3E80
    /* 3e8a: 5a 00 3e f0 */ jmp         @LBL_3EF0:24
LBL_3E8E:
    /* 3e8e: 6a 00 80 0a */ mov.b       @DAT_800A:16,r0h
    /* 3e92: e0 60       */ and.b       #0x60,r0h
    /* 3e94: a0 60       */ cmp.b       #0x60,r0h
    /* 3e96: 47 04       */ beq         LBL_3E9C
    /* 3e98: 5a 00 3e f0 */ jmp         @LBL_3EF0:24
LBL_3E9C:
    /* 3e9c: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3EA0:
    /* 3ea0: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3ea4: 46 fa       */ bne         LBL_3EA0
    /* 3ea6: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 3eaa: 46 f0       */ bne         LBL_3E9C
    /* 3eac: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 3eb0: e0 30       */ and.b       #0x30,r0h
    /* 3eb2: a0 30       */ cmp.b       #0x30,r0h
    /* 3eb4: 46 3a       */ bne         LBL_3EF0
    /* 3eb6: 5e 00 3f 04 */ jsr         @FUNC_3F04:24
    /* 3eba: 79 01 fc 08 */ mov.w       #DAT_FC08,r1
    /* 3ebe: 69 90       */ mov.w       r0,@r1
LBL_3EC0:
    /* 3ec0: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3EC4:
    /* 3ec4: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3ec8: 46 fa       */ bne         LBL_3EC4
    /* 3eca: 5e 00 3f 04 */ jsr         @FUNC_3F04:24
    /* 3ece: 79 01 fc 08 */ mov.w       #DAT_FC08,r1
    /* 3ed2: f3 00       */ mov.b       #0x0,r3h
    /* 3ed4: 6a 0b 80 0e */ mov.b       @DAT_800E:16,r3l
    /* 3ed8: 10 8b       */ shal.b      r3l
    /* 3eda: 12 03       */ rotxl.b     r3h
    /* 3edc: 09 31       */ add.w       r3,r1
    /* 3ede: 69 90       */ mov.w       r0,@r1
    /* 3ee0: 79 00 01 66 */ mov.w       #0x166,r0
    /* 3ee4: 1d 03       */ cmp.w       r0,r3
    /* 3ee6: 45 d8       */ bcs         LBL_3EC0
    /* 3ee8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3eec: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

LBL_3EF0:
    /* 3ef0: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3ef4: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3ef8: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1 // raise mechanic error
    /* 3efc: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3f00: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_3F04
    /* 3f04: 6b 05 80 0a */ mov.w       @DAT_800A:16,r5
    /* 3f08: 2b 2b       */ mov.b       @DAT_FF2B:8,r3l
    /* 3f0a: 23 38       */ mov.b       @DAT_FF38:8,r3h
    /* 3f0c: 28 e0       */ mov.b       @REG_ADDRA:8,r0l
    /* 3f0e: 18 b8       */ sub.b       r3l,r0l
    /* 3f10: 73 0d       */ btst        #0x0,r5l
    /* 3f12: 46 02       */ bne         LBL_3F16
    /* 3f14: 17 88       */ neg.b       r0l
LBL_3F16:
    /* 3f16: 4b 0a       */ bmi         LBL_3F22
    /* 3f18: 50 30       */ mulxu.b     r3h,r0
    /* 3f1a: a0 7f       */ cmp.b       #0x7f,r0h
    /* 3f1c: 43 10       */ bls         LBL_3F2E
    /* 3f1e: f0 7f       */ mov.b       #0x7f,r0h
    /* 3f20: 40 0c       */ bra         LBL_3F2E
LBL_3F22:
    /* 3f22: 17 88       */ neg.b       r0l
    /* 3f24: 50 30       */ mulxu.b     r3h,r0
    /* 3f26: a0 80       */ cmp.b       #0x80,r0h
    /* 3f28: 43 02       */ bls         LBL_3F2C
    /* 3f2a: f0 80       */ mov.b       #0x80,r0h
LBL_3F2C:
    /* 3f2c: 17 80       */ neg.b       r0h
LBL_3F2E:
    /* 3f2e: 0c 08       */ mov.b       r0h,r0l
    /* 3f30: 0c d0       */ mov.b       r5l,r0h
    /* 3f32: 54 70       */ rts

glabel COMMAND_3D
    /* 3f34: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3f38: f0 00       */ mov.b       #0x0,r0h
    /* 3f3a: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 3f3e: 79 03 00 b4 */ mov.w       #0xb4,r3
    /* 3f42: 1d 30       */ cmp.w       r3,r0
    /* 3f44: 44 18       */ bcc         LBL_3F5E
    /* 3f46: 10 88       */ shal.b      r0l
    /* 3f48: 12 00       */ rotxl.b     r0h
    /* 3f4a: 79 01 fc 08 */ mov.w       #DAT_FC08,r1
    /* 3f4e: 09 01       */ add.w       r0,r1
    /* 3f50: 69 10       */ mov.w       @r1,r0
    /* 3f52: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3f56: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3f5a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

LBL_3F5E:
    /* 3f5e: 79 00 ff ff */ mov.w       #0xffff,r0
    /* 3f62: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 3f66: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 3f6a: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 3f6e: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1     // raise mechanic error
    /* 3f72: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 3f76: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel DAT_3F7A
    /* 3f7a */  .word 0x6a71
    /* 3f7c */  .word 0x7881

glabel COMMAND_3E
    /* 3f7e: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 3f82: 7f 10 70 00 */ bset        #0x0,@DAT_FF10:8
    /* 3f86: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 3f8a: 4b 04       */ bmi         LBL_3F90
    /* 3f8c: a8 04       */ cmp.b       #0x4,r0l
    /* 3f8e: 45 02       */ bcs         LBL_3F92
LBL_3F90:
    /* 3f90: f8 02       */ mov.b       #0x2,r0l
LBL_3F92:
    /* 3f92: 6a 88 fe 28 */ mov.b       r0l,@DAT_FE28:16
    /* 3f96: 6a 84 fe 26 */ mov.b       r4h,@DAT_FE26:16
    /* 3f9a: 79 01 00 fa */ mov.w       #0xfa,r1
    /* 3f9e: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 3fa2: 79 00 00 00 */ mov.w       #0x0,r0
    /* 3fa6: 6b 80 fe 2e */ mov.w       r0,@DAT_FE2E:16
    /* 3faa: 6b 80 fe 30 */ mov.w       r0,@DAT_FE30:16
    /* 3fae: 6b 80 fe 32 */ mov.w       r0,@DAT_FE32:16
    /* 3fb2: 6b 80 fe 34 */ mov.w       r0,@DAT_FE34:16
    /* 3fb6: 6a 08 fe 28 */ mov.b       @DAT_FE28:16,r0l
    /* 3fba: 79 01 3f 7a */ mov.w       #DAT_3F7A,r1
    /* 3fbe: 08 89       */ add.b       r0l,r1l
    /* 3fc0: 91 00       */ addx        #0x0,r1h
    /* 3fc2: 68 10       */ mov.b       @r1,r0h
    /* 3fc4: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
LBL_3FC8:
    /* 3fc8: 6a 00 fe 26 */ mov.b       @DAT_FE26:16,r0h
    /* 3fcc: 46 fa       */ bne         LBL_3FC8
LBL_3FCE:
    /* 3fce: 6a 08 fe 25 */ mov.b       @DAT_FE25:16,r0l
    /* 3fd2: 6a 88 fe 27 */ mov.b       r0l,@DAT_FE27:16
    /* 3fd6: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_3FDA:
    /* 3fda: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 3fde: 46 fa       */ bne         LBL_3FDA
    /* 3fe0: 6b 00 fe 2a */ mov.w       @DAT_FE2A:16,r0
    /* 3fe4: 6b 03 fe 2e */ mov.w       @DAT_FE2E:16,r3
    /* 3fe8: 09 03       */ add.w       r0,r3
    /* 3fea: 6b 83 fe 2e */ mov.w       r3,@DAT_FE2E:16
    /* 3fee: 6b 00 fe 2c */ mov.w       @DAT_FE2C:16,r0
    /* 3ff2: 6b 03 fe 30 */ mov.w       @DAT_FE30:16,r3
    /* 3ff6: 09 03       */ add.w       r0,r3
    /* 3ff8: 6b 83 fe 30 */ mov.w       r3,@DAT_FE30:16
    /* 3ffc: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 4000: 46 cc       */ bne         LBL_3FCE
    /* 4002: 6a 08 fe 28 */ mov.b       @DAT_FE28:16,r0l
    /* 4006: 79 01 3f 7a */ mov.w       #DAT_3F7A,r1
    /* 400a: 08 89       */ add.b       r0l,r1l
    /* 400c: 91 00       */ addx        #0x0,r1h
    /* 400e: 68 10       */ mov.b       @r1,r0h
    /* 4010: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
LBL_4014:
    /* 4014: 6a 08 fe 24 */ mov.b       @DAT_FE24:16,r0l
    /* 4018: 6a 88 fe 27 */ mov.b       r0l,@DAT_FE27:16
    /* 401c: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_4020:
    /* 4020: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 4024: 46 fa       */ bne         LBL_4020
    /* 4026: 6b 00 fe 2a */ mov.w       @DAT_FE2A:16,r0
    /* 402a: 6b 03 fe 32 */ mov.w       @DAT_FE32:16,r3
    /* 402e: 09 03       */ add.w       r0,r3
    /* 4030: 6b 83 fe 32 */ mov.w       r3,@DAT_FE32:16
    /* 4034: 6b 00 fe 2c */ mov.w       @DAT_FE2C:16,r0
    /* 4038: 6b 03 fe 34 */ mov.w       @DAT_FE34:16,r3
    /* 403c: 09 03       */ add.w       r0,r3
    /* 403e: 6b 83 fe 34 */ mov.w       r3,@DAT_FE34:16
    /* 4042: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 4046: 46 cc       */ bne         LBL_4014
    /* 4048: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 404c: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

LBL_4050:
    /* 4050: */ .word 0x605A
    /* 4052: */ .word 0x472B
    /* 4054: */ .word 0x09E6
    /* 4056: */ .word 0xC6AE
    /* 4058: */ .word 0xA2A2
    /* 405a: */ .word 0xAEC6
    /* 405c: */ .word 0xE609
    /* 405e: */ .word 0x2B47
    /* 4060: */ .word 0x5AFF
LBL_4062:
    /* 4062: */ .word 0x6059
    /* 4064: */ .word 0x4425
    /* 4066: */ .word 0x00DB
    /* 4068: */ .word 0xBCA7
    /* 406a: */ .word 0xA0A7
    /* 406c: */ .word 0xBCDB
    /* 406e: */ .word 0x0025
    /* 4070: */ .word 0x4459
LBL_4072:
    /* 4072: */ .word 0x6058
    /* 4074: */ .word 0x401E
    /* 4076: */ .word 0xF6D0
    /* 4078: */ .word 0xB2A2
    /* 407a: */ .word 0xA2B2
    /* 407c: */ .word 0xD0F6
    /* 407e: */ .word 0x1E40
    /* 4080: */ .word 0x58FF
LBL_4082:
    /* 4082: */ .word 0x6056
    /* 4084: */ .word 0x3C15
    /* 4086: */ .word 0xEBC4
    /* 4088: */ .word 0xAAA0
    /* 408a: */ .word 0xAAC4
    /* 408c: */ .word 0xEB15
    /* 408e: */ .word 0x3C56
LBL_4090:
    /* 4090: */ .word 0x0023
    /* 4092: */ .word 0x4156
    /* 4094: */ .word 0x605C
    /* 4096: */ .word 0x4D33
    /* 4098: */ .word 0x12EE
    /* 409a: */ .word 0xCDB3
    /* 409c: */ .word 0xA4A0
    /* 409e: */ .word 0xAABF
    /* 40a0: */ .word 0xDDFF
LBL_40A2:
    /* 40a2: */ .word 0x0025
    /* 40a4: */ .word 0x4459
    /* 40a6: */ .word 0x6059
    /* 40a8: */ .word 0x4425
    /* 40aa: */ .word 0x00DB
    /* 40ac: */ .word 0xBCA7
    /* 40ae: */ .word 0xA0A7
    /* 40b0: */ .word 0xBCDB
LBL_40B2:
    /* 40b2: */ .word 0x0027
    /* 40b4: */ .word 0x475B
    /* 40b6: */ .word 0x5F53
    /* 40b8: */ .word 0x3814
    /* 40ba: */ .word 0xECC8
    /* 40bc: */ .word 0xADA1
    /* 40be: */ .word 0xA5B9
    /* 40c0: */ .word 0xD9FF
LBL_40C2:
    /* 40c2: */ .word 0x002A
    /* 40c4: */ .word 0x4B5E
    /* 40c6: */ .word 0x5E4B
    /* 40c8: */ .word 0x2A00
    /* 40ca: */ .word 0xD6B5
    /* 40cc: */ .word 0xA2A2
    /* 40ce: */ .word 0xB5D6

LBL_40D0:
    /* 40d0: */ .word LBL_4050
    /* 40d2: */ .word LBL_4062
    /* 40d4: */ .word LBL_4072
    /* 40d6: */ .word LBL_4082
LBL_40D8:
    /* 40d8: */ .word LBL_4090
    /* 40da: */ .word LBL_40A2
    /* 40dc: */ .word LBL_40B2
    /* 40de: */ .word LBL_40C2

glabel FUNC_40E0
    /* 40e0: 79 02 40 d0 */ mov.w       #LBL_40D0,r2
    /* 40e4: 6a 08 fe 28 */ mov.b       @DAT_FE28:16,r0l
    /* 40e8: 10 88       */ shal.b      r0l
LBL_40EA:
    /* 40ea: 08 8a       */ add.b       r0l,r2l
    /* 40ec: 92 00       */ addx        #0x0,r2h
    /* 40ee: 69 21       */ mov.w       @r2,r1
    /* 40f0: 6a 0b fe 26 */ mov.b       @DAT_FE26:16,r3l
    /* 40f4: 6a 08 fe 27 */ mov.b       @DAT_FE27:16,r0l
    /* 40f8: f0 80       */ mov.b       #0x80,r0h
    /* 40fa: 18 08       */ sub.b       r0h,r0l
    /* 40fc: 0c 8a       */ mov.b       r0l,r2l
    /* 40fe: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 4102: 1c 43       */ cmp.b       r4h,r3h
    /* 4104: 4b 06       */ bmi         LBL_410C
    /* 4106: 0c 3b       */ mov.b       r3h,r3l
    /* 4108: 0c 43       */ mov.b       r4h,r3h
    /* 410a: 40 04       */ bra         LBL_4110
LBL_410C:
    /* 410c: 0c 3b       */ mov.b       r3h,r3l
    /* 410e: f3 ff       */ mov.b       #0xff,r3h
LBL_4110:
    /* 4110: 6b 83 fe 2a */ mov.w       r3,@DAT_FE2A:16
    /* 4114: 79 02 40 d8 */ mov.w       #LBL_40D8,r2
    /* 4118: 6a 00 fe 28 */ mov.b       @DAT_FE28:16,r0h
    /* 411c: 10 80       */ shal.b      r0h
    /* 411e: 08 0a       */ add.b       r0h,r2l
    /* 4120: 92 00       */ addx        #0x0,r2h
LBL_4122:
    /* 4122: 69 21       */ mov.w       @r2,r1
LBL_4124:
    /* 4124: 6a 0b fe 26 */ mov.b       @DAT_FE26:16,r3l
    /* 4128: 0c 8a       */ mov.b       r0l,r2l
    /* 412a: 5e 00 12 9a */ jsr         @FUNC_129A:24
    /* 412e: 1c 43       */ cmp.b       r4h,r3h
    /* 4130: 4b 06       */ bmi         LBL_4138
    /* 4132: 0c 3b       */ mov.b       r3h,r3l
    /* 4134: 0c 43       */ mov.b       r4h,r3h
LBL_4136:
    /* 4136: 40 04       */ bra         LBL_413C
LBL_4138:
    /* 4138: 0c 3b       */ mov.b       r3h,r3l
    /* 413a: f3 ff       */ mov.b       #0xff,r3h
LBL_413C:
    /* 413c: 6b 83 fe 2c */ mov.w       r3,@DAT_FE2C:16
    /* 4140: 54 70       */ rts

glabel COMMAND_3F
    /* 4142: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 4146: f0 00       */ mov.b       #0x0,r0h
LBL_4148:
    /* 4148: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 414c: 79 03 00 04 */ mov.w       #0x4,r3
    /* 4150: 1d 30       */ cmp.w       r3,r0
    /* 4152: 44 40       */ bcc         LBL_4194
    /* 4154: 10 88       */ shal.b      r0l
    /* 4156: 12 00       */ rotxl.b     r0h
    /* 4158: 79 01 fe 2e */ mov.w       #DAT_FE2E,r1
    /* 415c: 09 01       */ add.w       r0,r1
    /* 415e: 69 13       */ mov.w       @r1,r3
    /* 4160: 6b 83 80 00 */ mov.w       r3,@REG_ASIC_DATA:16
    /* 4164: 79 03 00 06 */ mov.w       #0x6,r3
    /* 4168: 1d 30       */ cmp.w       r3,r0
    /* 416a: 47 08       */ beq         LBL_4174
    /* 416c: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 4170: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_4174:
    /* 4174: 7f 10 72 00 */ bclr        #0x0,@DAT_FF10:8
    /* 4178: 79 00 00 00 */ mov.w       #0x0,r0
    /* 417c: 6b 80 fe 2e */ mov.w       r0,@DAT_FE2E:16
    /* 4180: 6b 80 fe 30 */ mov.w       r0,@DAT_FE30:16
    /* 4184: 6b 80 fe 32 */ mov.w       r0,@DAT_FE32:16
    /* 4188: 6b 80 fe 34 */ mov.w       r0,@DAT_FE34:16
    /* 418c: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 4190: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24
LBL_4194:
    /* 4194: 79 00 ff ff */ mov.w       #0xffff,r0
    /* 4198: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16                // ASIC_DATA = 0xFFFF
    /* 419c: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 41a0: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 41a4: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1     // raise mechanic error
    /* 41a8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 41ac: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_40
    /* 41b0: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 41b4: 38 1c       */ mov.b       r0l,@DAT_FF1C:8
    /* 41b6: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 41ba: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_41
    /* 41be: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 41c2: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 41c6: e0 0f       */ and.b       #0xf,r0h
    /* 41c8: 79 03 01 00 */ mov.w       #0x100,r3
    /* 41cc: 09 30       */ add.w       r3,r0
    /* 41ce: 6b 80 fd fc */ mov.w       r0,@DAT_FDFC:16
    /* 41d2: 6b 03 fd 9e */ mov.w       @DAT_FD9E:16,r3
    /* 41d6: 1d 30       */ cmp.w       r3,r0
    /* 41d8: 42 08       */ bhi         LBL_41E2
    /* 41da: 79 03 01 00 */ mov.w       #0x100,r3
    /* 41de: 1d 30       */ cmp.w       r3,r0
    /* 41e0: 44 04       */ bcc         LBL_41E6
LBL_41E2:
    /* 41e2: 5a 00 42 a6 */ jmp         @LBL_42A6:24
LBL_41E6:
    /* 41e6: 79 03 00 05 */ mov.w       #0x5,r3
    /* 41ea: 09 30       */ add.w       r3,r0
    /* 41ec: 6b 80 fd fe */ mov.w       r0,@DAT_FDFE:16
    /* 41f0: 6a 00 80 00 */ mov.b       @REG_ASIC_DATA:16,r0h
    /* 41f4: e0 f0       */ and.b       #0xf0,r0h
    /* 41f6: 11 00       */ shlr.b      r0h
    /* 41f8: 11 00       */ shlr.b      r0h
    /* 41fa: 11 00       */ shlr.b      r0h
    /* 41fc: 11 00       */ shlr.b      r0h
    /* 41fe: a0 01       */ cmp.b       #0x1,r0h
    /* 4200: 43 04       */ bls         LBL_4206
    /* 4202: 5a 00 42 a6 */ jmp         @LBL_42A6:24
LBL_4206:
    /* 4206: 30 1d       */ mov.b       r0h,@DAT_FF1D:8
    /* 4208: 6b 00 fd fc */ mov.w       @DAT_FDFC:16,r0
    /* 420c: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4210: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
    /* 4214: 5e 00 30 1a */ jsr         @FUNC_301A:24
    /* 4218: 44 04       */ bcc         LBL_421E
    /* 421a: 5a 00 42 ba */ jmp         @LBL_42BA:24
LBL_421E:
    /* 421e: f0 00       */ mov.b       #0x0,r0h
    /* 4220: 6a 80 fe 20 */ mov.b       r0h,@DAT_FE20:16
    /* 4224: f0 ff       */ mov.b       #0xff,r0h
    /* 4226: 6a 80 fe 22 */ mov.b       r0h,@DAT_FE22:16
    /* 422a: f0 0a       */ mov.b       #0xa,r0h
    /* 422c: 30 25       */ mov.b       r0h,@DAT_FF25:8
    /* 422e: 6b 00 fd fe */ mov.w       @DAT_FDFE:16,r0
LBL_4232:
    /* 4232: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4236: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
LBL_423A:
    /* 423a: 7e 00 73 70 */ btst        #0x7,@DAT_FF00:8
    /* 423e: 47 fa       */ beq         LBL_423A
LBL_4240:
    /* 4240: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_4244:
    /* 4244: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 4248: 46 fa       */ bne         LBL_4244
    /* 424a: 20 e0       */ mov.b       @REG_ADDRA:8,r0h
    /* 424c: 6a 08 fe 20 */ mov.b       @DAT_FE20:16,r0l
    /* 4250: 1c 80       */ cmp.b       r0l,r0h
    /* 4252: 45 04       */ bcs         LBL_4258
    /* 4254: 6a 80 fe 20 */ mov.b       r0h,@DAT_FE20:16
LBL_4258:
    /* 4258: 6a 08 fe 22 */ mov.b       @DAT_FE22:16,r0l
    /* 425c: 1c 80       */ cmp.b       r0l,r0h
    /* 425e: 44 04       */ bcc         LBL_4264
    /* 4260: 6a 80 fe 22 */ mov.b       r0h,@DAT_FE22:16
LBL_4264:
    /* 4264: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 4268: 46 50       */ bne         LBL_42BA
    /* 426a: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 426e: 46 4a       */ bne         LBL_42BA
    /* 4270: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 4274: 47 ca       */ beq         LBL_4240
    /* 4276: 20 25       */ mov.b       @DAT_FF25:8,r0h
    /* 4278: 1a 00       */ dec.b       r0h
    /* 427a: 30 25       */ mov.b       r0h,@DAT_FF25:8
    /* 427c: 47 14       */ beq         LBL_4292
    /* 427e: 73 00       */ btst        #0x0,r0h
    /* 4280: 47 08       */ beq         LBL_428A
    /* 4282: 6b 00 fd fc */ mov.w       @DAT_FDFC:16,r0
    /* 4286: 5a 00 42 32 */ jmp         @LBL_4232:24
LBL_428A:
    /* 428a: 6b 00 fd fe */ mov.w       @DAT_FDFE:16,r0
    /* 428e: 5a 00 42 32 */ jmp         @LBL_4232:24
LBL_4292:
    /* 4292: 6a 00 fe 20 */ mov.b       @DAT_FE20:16,r0h
    /* 4296: 6a 08 fe 22 */ mov.b       @DAT_FE22:16,r0l
    /* 429a: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 429e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 42a2: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

LBL_42A6:
    /* 42a6: 7f 0b 70 50 */ bset        #ERROR_STATUS_INVALID_ARG,@ERROR_STATUS+1:8
    /* 42aa: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 42ae: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1     // raise mechanic error
    /* 42b2: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 42b6: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

LBL_42BA:
    /* 42ba: 79 00 00 80 */ mov.w       #0x80,r0
    /* 42be: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 42c2: 5e 00 45 c8 */ jsr         @FUNC_45C8:24
    /* 42c6: 45 04       */ bcs         LBL_42CC
    /* 42c8: 5a 00 42 1e */ jmp         @LBL_421E:24
LBL_42CC:
    /* 42cc: 79 00 00 80 */ mov.w       #0x80,r0
    /* 42d0: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 42d4: 5e 00 46 e6 */ jsr         @FUNC_46E6:24
    /* 42d8: 7f 0b 70 30 */ bset        #ERROR_STATUS_NO_SEEK_COMPLETE,@ERROR_STATUS+1:8
    /* 42dc: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 42e0: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1     // raise mechanic error
    /* 42e4: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 42e8: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_42
    /* 42ec: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 42f0: 38 3e       */ mov.b       r0l,@DAT_FF3E:8
    /* 42f2: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 42f6: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_44
    /* 42fa: 6a 00 80 00 */ mov.b       @REG_ASIC_DATA:16,r0h
    /* 42fe: 11 80       */ shar.b      r0h
    /* 4300: 5e 00 48 2e */ jsr         @FUNC_482E:24
    /* 4304: 6a 0b 80 00 */ mov.b       @REG_ASIC_DATA:16,r3l
    /* 4308: 11 8b       */ shar.b      r3l
    /* 430a: 45 06       */ bcs         LBL_4312
    /* 430c: 6a 80 80 01 */ mov.b       r0h,@REG_ASIC_DATA+1:16
    /* 4310: 40 04       */ bra         LBL_4316
LBL_4312:
    /* 4312: 6a 88 80 01 */ mov.b       r0l,@REG_ASIC_DATA+1:16
LBL_4316:
    /* 4316: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 431a: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_45
    /* 431e: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0
    /* 4322: e0 7f       */ and.b       #0x7f,r0h
    /* 4324: 11 80       */ shar.b      r0h
    /* 4326: 5e 00 48 2e */ jsr         @FUNC_482E:24
    /* 432a: 6b 03 80 00 */ mov.w       @REG_ASIC_DATA:16,r3
    /* 432e: 11 83       */ shar.b      r3h
    /* 4330: 45 04       */ bcs         LBL_4336
    /* 4332: 0c b0       */ mov.b       r3l,r0h
    /* 4334: 40 02       */ bra         LBL_4338
LBL_4336:
    /* 4336: 0c b8       */ mov.b       r3l,r0l
LBL_4338:
    /* 4338: 0c 3b       */ mov.b       r3h,r3l
    /* 433a: 5e 00 48 72 */ jsr         @FUNC_4872:24
    /* 433e: 45 04       */ bcs         LBL_4344
    /* 4340: f8 00       */ mov.b       #0x0,r0l
    /* 4342: 40 02       */ bra         LBL_4346
LBL_4344:
    /* 4344: f8 01       */ mov.b       #0x1,r0l
LBL_4346:
    /* 4346: f0 00       */ mov.b       #0x0,r0h
    /* 4348: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 434c: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 4350: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_47
    /* 4354: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 4358: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 435c: 6a 88 fd e5 */ mov.b       r0l,@DAT_FDE5:16
    /* 4360: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 4364: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_48
    /* 4368: 20 30       */ mov.b       @DAT_FF30:8,r0h
    /* 436a: 6a 80 80 01 */ mov.b       r0h,@REG_ASIC_DATA+1:16
    /* 436e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 4372: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_49
    /* 4376: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 437a: 7f 0c 70 40 */ bset        #0x4,@DAT_FF0C:8
    /* 437e: f0 28       */ mov.b       #0x28,r0h
    /* 4380: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
LBL_4384:
    /* 4384: 5e 00 44 04 */ jsr         @FUNC_4404:24
    /* 4388: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 438c: a0 12       */ cmp.b       #0x12,r0h
    /* 438e: 44 30       */ bcc         LBL_43C0
    /* 4390: 6a 00 fd 95 */ mov.b       @DAT_FD95:16,r0h
    /* 4394: 1a 00       */ dec.b       r0h
    /* 4396: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
    /* 439a: 46 e8       */ bne         LBL_4384
    /* 439c: 40 00       */ bra         LBL_439E
LBL_439E:
    /* 439e: f0 10       */ mov.b       #0x10,r0h
    /* 43a0: 28 30       */ mov.b       @DAT_FF30:8,r0l
    /* 43a2: a8 ff       */ cmp.b       #0xff,r0l
    /* 43a4: 47 50       */ beq         LBL_43F6
    /* 43a6: 08 80       */ add.b       r0l,r0h
    /* 43a8: 30 30       */ mov.b       r0h,@DAT_FF30:8
    /* 43aa: 44 04       */ bcc         LBL_43B0
    /* 43ac: f0 ff       */ mov.b       #0xff,r0h
    /* 43ae: 30 30       */ mov.b       r0h,@DAT_FF30:8
LBL_43B0:
    /* 43b0: f0 28       */ mov.b       #0x28,r0h
    /* 43b2: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
    /* 43b6: 79 01 03 e8 */ mov.w       #0x3e8,r1
    /* 43ba: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 43be: 40 c4       */ bra         LBL_4384
LBL_43C0:
    /* 43c0: f0 28       */ mov.b       #0x28,r0h
    /* 43c2: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
LBL_43C6:
    /* 43c6: 5e 00 44 04 */ jsr         @FUNC_4404:24
    /* 43ca: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 43ce: a0 12       */ cmp.b       #0x12,r0h
    /* 43d0: 44 0e       */ bcc         LBL_43E0
    /* 43d2: 6a 00 fd 95 */ mov.b       @DAT_FD95:16,r0h
    /* 43d6: 1a 00       */ dec.b       r0h
    /* 43d8: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
    /* 43dc: 46 e8       */ bne         LBL_43C6
    /* 43de: 40 16       */ bra         LBL_43F6
LBL_43E0:
    /* 43e0: 28 30       */ mov.b       @DAT_FF30:8,r0l
    /* 43e2: 1a 08       */ dec.b       r0l
    /* 43e4: 38 30       */ mov.b       r0l,@DAT_FF30:8
    /* 43e6: f0 28       */ mov.b       #0x28,r0h
    /* 43e8: 6a 80 fd 95 */ mov.b       r0h,@DAT_FD95:16
    /* 43ec: 79 01 03 e8 */ mov.w       #0x3e8,r1
    /* 43f0: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 43f4: 40 d0       */ bra         LBL_43C6
LBL_43F6:
    /* 43f6: 20 30       */ mov.b       @DAT_FF30:8,r0h
    /* 43f8: 6a 80 80 01 */ mov.b       r0h,@REG_ASIC_DATA+1:16
    /* 43fc: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 4400: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_4404
    /* 4404: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 4408: 46 fa       */ bne         FUNC_4404
    /* 440a: 6a 84 fd 94 */ mov.b       r4h,@DAT_FD94:16
LBL_440E:
    /* 440e: 79 03 00 10 */ mov.w       #0x10,r3
    /* 4412: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 4416: 6b 01 fd b2 */ mov.w       @DAT_FDB2:16,r1
    /* 441a: 09 10       */ add.w       r1,r0
    /* 441c: 11 80       */ shar.b      r0h
    /* 441e: 13 08       */ rotxr.b     r0l
    /* 4420: 79 01 00 00 */ mov.w       #0x0,r1
    /* 4424: 1d 10       */ cmp.w       r1,r0
    /* 4426: 4a 06       */ bpl         LBL_442E
    /* 4428: 09 30       */ add.w       r3,r0
    /* 442a: 4a 10       */ bpl         LBL_443C
    /* 442c: 40 04       */ bra         LBL_4432
LBL_442E:
    /* 442e: 1d 30       */ cmp.w       r3,r0
    /* 4430: 43 0a       */ bls         LBL_443C
LBL_4432:
    /* 4432: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 4436: 0a 00       */ inc         r0h
    /* 4438: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
LBL_443C:
    /* 443c: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_4440:
    /* 4440: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 4444: 46 fa       */ bne         LBL_4440
    /* 4446: 6a 00 80 0e */ mov.b       @DAT_800E:16,r0h
    /* 444a: 46 c2       */ bne         LBL_440E
    /* 444c: 54 70       */ rts

glabel COMMAND_4A
    /* 444e: 6a 00 80 00 */ mov.b       @REG_ASIC_DATA:16,r0h
    /* 4452: 6a 80 fe 0a */ mov.b       r0h,@DAT_FE0A:16
    /* 4456: 6a 08 80 01 */ mov.b       @REG_ASIC_DATA+1:16,r0l
    /* 445a: 6a 88 fe 0b */ mov.b       r0l,@DAT_FE0B:16
    /* 445e: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 4462: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_4B
    /* 4466: 5e 00 46 8c */ jsr         @DD_COMMAND_PROLOG1:24
    /* 446a: 7e 0e 73 70 */ btst        #0x7,@DAT_FF0E:8
    /* 446e: 47 06       */ beq         LBL_4476
    /* 4470: f0 01       */ mov.b       #0x1,r0h
    /* 4472: 5a 00 44 9e */ jmp         @LBL_449E:24
LBL_4476:
    /* 4476: 7e 03 73 70 */ btst        #0x7,@DAT_FF03:8
    /* 447a: 46 06       */ bne         LBL_4482
    /* 447c: f0 02       */ mov.b       #0x2,r0h
    /* 447e: 5a 00 44 9e */ jmp         @LBL_449E:24
LBL_4482:
    /* 4482: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 4486: 46 06       */ bne         LBL_448E
    /* 4488: f0 07       */ mov.b       #0x7,r0h
    /* 448a: 5a 00 44 9e */ jmp         @LBL_449E:24
LBL_448E:
    /* 448e: 7f 42 70 60 */ bset        #0x6,@DAT_FF42:8
    /* 4492: 34 41       */ mov.b       r4h,@DAT_FF41:8
    /* 4494: 5e 00 44 b0 */ jsr         @FUNC_44B0:24
    /* 4498: 20 41       */ mov.b       @DAT_FF41:8,r0h
    /* 449a: 46 02       */ bne         LBL_449E
    /* 449c: f0 00       */ mov.b       #0x0,r0h
LBL_449E:
    /* 449e: 0c 08       */ mov.b       r0h,r0l
    /* 44a0: e8 0f       */ and.b       #0xf,r0l
    /* 44a2: f0 00       */ mov.b       #0x0,r0h
    /* 44a4: 6b 80 80 00 */ mov.w       r0,@REG_ASIC_DATA:16
    /* 44a8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 44ac: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_44B0
    /* 44b0: 7f 42 70 60 */ bset        #0x6,@DAT_FF42:8
    /* 44b4: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 44b8: 6b 80 fe 04 */ mov.w       r0,@DAT_FE04:16
    /* 44bc: 6b 00 fe 08 */ mov.w       @DAT_FE08:16,r0
    /* 44c0: 6b 80 fe 06 */ mov.w       r0,@DAT_FE06:16
    /* 44c4: 34 40       */ mov.b       r4h,@DAT_FF40:8
    /* 44c6: 7f 42 72 00 */ bclr        #0x0,@DAT_FF42:8
    /* 44ca: 7f 42 72 10 */ bclr        #0x1,@DAT_FF42:8
LBL_44CE:
    /* 44ce: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_44D2:
    /* 44d2: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 44d6: 46 fa       */ bne         LBL_44D2
    /* 44d8: 6a 0a 80 1b */ mov.b       @DAT_801B:16,r2l
    /* 44dc: ea 30       */ and.b       #0x30,r2l
    /* 44de: 47 0e       */ beq         LBL_44EE
    /* 44e0: aa 30       */ cmp.b       #0x30,r2l
    /* 44e2: 47 0a       */ beq         LBL_44EE
    /* 44e4: 7f 42 72 60 */ bclr        #0x6,@DAT_FF42:8
    /* 44e8: f0 06       */ mov.b       #0x6,r0h
    /* 44ea: 30 41       */ mov.b       r0h,@DAT_FF41:8
    /* 44ec: 54 70       */ rts
LBL_44EE:
    /* 44ee: 6b 00 fd b0 */ mov.w       @DAT_FDB0:16,r0
    /* 44f2: 6b 03 fe 04 */ mov.w       @DAT_FE04:16,r3
    /* 44f6: 6b 80 fe 04 */ mov.w       r0,@DAT_FE04:16
    /* 44fa: 09 30       */ add.w       r3,r0
    /* 44fc: 11 80       */ shar.b      r0h
    /* 44fe: 13 08       */ rotxr.b     r0l
    /* 4500: 79 03 00 00 */ mov.w       #0x0,r3
    /* 4504: 1d 30       */ cmp.w       r3,r0
    /* 4506: 4a 06       */ bpl         LBL_450E
    /* 4508: 17 00       */ not.b       r0h
    /* 450a: 17 08       */ not.b       r0l
    /* 450c: 09 40       */ add.w       r4,r0
LBL_450E:
    /* 450e: f3 00       */ mov.b       #0x0,r3h
    /* 4510: 2b 3e       */ mov.b       @DAT_FF3E:8,r3l
    /* 4512: 1d 30       */ cmp.w       r3,r0
    /* 4514: 45 08       */ bcs         LBL_451E
    /* 4516: f0 03       */ mov.b       #0x3,r0h
    /* 4518: 30 41       */ mov.b       r0h,@DAT_FF41:8
    /* 451a: 5a 00 45 42 */ jmp         @LBL_4542:24
LBL_451E:
    /* 451e: 6a 0d 80 1b */ mov.b       @DAT_801B:16,r5l
    /* 4522: ed 07       */ and.b       #0x7,r5l
    /* 4524: ad 03       */ cmp.b       #0x3,r5l
    /* 4526: 47 08       */ beq         LBL_4530
    /* 4528: f0 05       */ mov.b       #0x5,r0h
    /* 452a: 30 41       */ mov.b       r0h,@DAT_FF41:8
    /* 452c: 5a 00 45 42 */ jmp         @LBL_4542:24
LBL_4530:
    /* 4530: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 4534: e0 07       */ and.b       #0x7,r0h
    /* 4536: 6b 03 fd 84 */ mov.w       @DAT_FD84:16,r3
    /* 453a: 1d 03       */ cmp.w       r0,r3
    /* 453c: 47 04       */ beq         LBL_4542
    /* 453e: f0 08       */ mov.b       #0x8,r0h
    /* 4540: 30 41       */ mov.b       r0h,@DAT_FF41:8
LBL_4542:
    /* 4542: 28 40       */ mov.b       @DAT_FF40:8,r0l
    /* 4544: 0a 08       */ inc         r0l
    /* 4546: 38 40       */ mov.b       r0l,@DAT_FF40:8
    /* 4548: a8 b4       */ cmp.b       #0xb4,r0l
    /* 454a: 47 04       */ beq         LBL_4550
    /* 454c: 5a 00 44 ce */ jmp         @LBL_44CE:24
LBL_4550:
    /* 4550: f0 00       */ mov.b       #0x0,r0h
    /* 4552: 7f 42 72 60 */ bclr        #0x6,@DAT_FF42:8
    /* 4556: 54 70       */ rts

/* Command to enable debug mode that allows commands >= 0x20 */
glabel COMMAND_DEBUG_ENABLE
    /* 4558: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 455c: 7e 4a 73 00 */ btst        #0x0,@DEBUG_EN_FLAGS:8      // test bit 0 in DEBUG_EN_FLAGS
    /* 4560: 46 1c       */ bne         LBL_457E                    // if set, branch forward
    /* 4562: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0        // Read ASIC_DATA
    /* 4566: 79 03 4c 45 */ mov.w       #0x4c45,r3                  // "LE"
    /* 456a: 1d 30       */ cmp.w       r3,r0
    /* 456c: 46 06       */ bne         LBL_4574                    // check ASIC_DATA == "LE"
    /* 456e: 7f 4a 70 00 */ bset        #0x0,@DEBUG_EN_FLAGS:8      // set bit 0 in DEBUG_EN_FLAGS
    /* 4572: 40 28       */ bra         LBL_459C                    // branch always
LBL_4574:
    /* 4574: 7f 4a 72 00 */ bclr        #0x0,@DEBUG_EN_FLAGS:8      // clear bits 0 and 1 in DEBUG_EN_FLAGS
    /* 4578: 7f 4a 72 10 */ bclr        #0x1,@DEBUG_EN_FLAGS:8
    /* 457c: 40 1e       */ bra         LBL_459C                    // branch always
LBL_457E:
    /* 457e: 6b 00 80 00 */ mov.w       @REG_ASIC_DATA:16,r0        // Read ASIC_DATA
    /* 4582: 79 03 4f 21 */ mov.w       #0x4f21,r3                  // "O!"
    /* 4586: 1d 30       */ cmp.w       r3,r0
    /* 4588: 46 0a       */ bne         LBL_4594                    // check ASIC_DATA == "O!"
    /* 458a: 7f 4a 70 10 */ bset        #0x1,@DEBUG_EN_FLAGS:8      // set bit 1 in DEBUG_EN_FLAGS
    /* 458e: 7f 4a 72 00 */ bclr        #0x0,@DEBUG_EN_FLAGS:8      // clear bit 0 in DEBUG_EN_FLAGS
    /* 4592: 40 08       */ bra         LBL_459C                    // branch always
LBL_4594:
    /* 4594: 7f 4a 72 00 */ bclr        #0x0,@DEBUG_EN_FLAGS:8      // clear bits 0 and 1 in DEBUG_EN_FLAGS
    /* 4598: 7f 4a 72 10 */ bclr        #0x1,@DEBUG_EN_FLAGS:8
LBL_459C:                   // respond as if the command was invalid to mask its existence?
    /* 459c: 7f 0b 70 40 */ bset        #ERROR_STATUS_INVALID_CMD,@ERROR_STATUS+1:8     // set invalid command bit in error status
    /* 45a0: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 45a4: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1                 // raise mechanic error
    /* 45a8: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 45ac: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel COMMAND_BAD
    /* 45b0: 5e 00 46 9e */ jsr         @DD_COMMAND_PROLOG2:24
    /* 45b4: 7f 0b 70 40 */ bset        #ERROR_STATUS_INVALID_CMD,@ERROR_STATUS+1:8     // set invalid command bit in error status
    /* 45b8: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 45bc: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_ERROR,@r1                 // raise mechanic error
    /* 45c0: 5e 00 46 ca */ jsr         @DD_COMMAND_EPILOG:24
    /* 45c4: 5a 00 2c 00 */ jmp         @DD_COMMAND_HANDLER:24

glabel FUNC_45C8
    /* 45c8: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 45cc: 7d 10 70 40 */ bset        #0x4,@r1
    /* 45d0: 6b 00 fd 88 */ mov.w       @DAT_FD88:16,r0
    /* 45d4: 6b 80 fd 8e */ mov.w       r0,@DAT_FD8E:16
    /* 45d8: f0 03       */ mov.b       #0x3,r0h
    /* 45da: 30 48       */ mov.b       r0h,@DAT_FF48:8
    /* 45dc: 5e 00 22 34 */ jsr         @FUNC_2234:24
    /* 45e0: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 45e4: 47 12       */ beq         LBL_45F8
    /* 45e6: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 45ea: 47 02       */ beq         LBL_45EE
    /* 45ec: 40 7c       */ bra         LBL_466A
LBL_45EE:
    /* 45ee: 5e 00 1f 00 */ jsr         @FUNC_1F00:24
    /* 45f2: 7e 03 73 60 */ btst        #0x6,@DAT_FF03:8
    /* 45f6: 46 5c       */ bne         LBL_4654
LBL_45F8:
    /* 45f8: 6b 00 fd 8e */ mov.w       @DAT_FD8E:16,r0
    /* 45fc: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4600: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
LBL_4604:
    /* 4604: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 4608: 46 16       */ bne         LBL_4620
    /* 460a: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 460e: 46 10       */ bne         LBL_4620
    /* 4610: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 4614: 46 54       */ bne         LBL_466A
    /* 4616: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 461a: 47 e8       */ beq         LBL_4604
    /* 461c: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 461e: 54 70       */ rts
LBL_4620:
    /* 4620: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 4624: 47 10       */ beq         LBL_4636
    /* 4626: 79 01 00 05 */ mov.w       #0x5,r1
    /* 462a: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 462e: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 4632: 47 02       */ beq         LBL_4636
    /* 4634: 40 34       */ bra         LBL_466A
LBL_4636:
    /* 4636: 20 48       */ mov.b       @DAT_FF48:8,r0h
    /* 4638: 1a 00       */ dec.b       r0h
    /* 463a: 30 48       */ mov.b       r0h,@DAT_FF48:8
    /* 463c: 46 b0       */ bne         LBL_45EE
    /* 463e: 7f 0e 72 20 */ bclr        #0x2,@DAT_FF0E:8
    /* 4642: 6a 84 fe 18 */ mov.b       r4h,@DAT_FE18:16
    /* 4646: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 464a: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 464e: 7d 10 72 40 */ bclr        #0x4,@r1
    /* 4652: 40 26       */ bra         LBL_467A
LBL_4654:
    /* 4654: 79 00 00 80 */ mov.w       #0x80,r0
    /* 4658: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 465c: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 4660: 6b 00 fd 8e */ mov.w       @DAT_FD8E:16,r0
    /* 4664: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4668: 40 10       */ bra         LBL_467A
LBL_466A:
    /* 466a: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 466e: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 4672: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 4676: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
LBL_467A:
    /* 467a: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 467e: 04 01       */ orc         #CCR_C,ccr
    /* 4680: 54 70       */ rts

glabel FUNC_4682 // unused?
    /* 4682: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4686: 7d 10 72 70 */ bclr        #ASIC_STATUS_BUSY,@r1
    /* 468a: 54 70       */ rts

glabel DD_COMMAND_PROLOG1
    /* 468c: 34 0a       */ mov.b       r4h,@ERROR_STATUS:8  // r4h = 0, clear error status
    /* 468e: 34 0b       */ mov.b       r4h,@ERROR_STATUS+1:8
    /* 4690: 79 00 00 00 */ mov.w       #0x0,r0
    /* 4694: 6b 80 fe 10 */ mov.w       r0,@DAT_FE10:16
    /* 4698: 6b 80 fe 12 */ mov.w       r0,@DAT_FE12:16
    /* 469c: 54 70       */ rts

glabel DD_COMMAND_PROLOG2
    /* 469e: 34 0a       */ mov.b       r4h,@ERROR_STATUS:8  // r4h = 0, clear error status
    /* 46a0: 34 0b       */ mov.b       r4h,@ERROR_STATUS+1:8
    /* 46a2: 54 70       */ rts

glabel DD_COMMAND_PROLOG3
    /* 46a4: 34 0a       */ mov.b       r4h,@ERROR_STATUS:8  // r4h = 0, clear error status
    /* 46a6: 34 0b       */ mov.b       r4h,@ERROR_STATUS+1:8
    /* 46a8: 7e 0e 73 10 */ btst        #0x1,@DAT_FF0E:8
    /* 46ac: 47 04       */ beq         LBL_46B2
    /* 46ae: 04 01       */ orc         #CCR_C,ccr
    /* 46b0: 40 16       */ bra         LBL_46C8
LBL_46B2:
    /* 46b2: 79 00 00 00 */ mov.w       #0x0,r0
    /* 46b6: 6b 80 fe 10 */ mov.w       r0,@DAT_FE10:16
    /* 46ba: 6b 80 fe 12 */ mov.w       r0,@DAT_FE12:16
    /* 46be: 7f 11 72 70 */ bclr        #0x7,@DAT_FF11:8
    /* 46c2: 7f 11 72 60 */ bclr        #0x6,@DAT_FF11:8
    /* 46c6: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
LBL_46C8:
    /* 46c8: 54 70       */ rts

glabel DD_COMMAND_EPILOG
    /* 46ca: 79 01 80 06 */ mov.w       #DAT_8006,r1            // r1 = DAT_8006
LBL_46CE:
    /* 46ce: 7c 10 73 70 */ btst        #0x7,@r1                // set compare based on  *r1 & (1 << 7)
    /* 46d2: 46 fa       */ bne         LBL_46CE                // branch if bit is set? wait for something
    /* 46d4: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 46d8: 7d 10 72 70 */ bclr        #ASIC_STATUS_BUSY,@r1           // no longer busy
    /* 46dc: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 46e0: 7d 10 70 10 */ bset        #ASIC_STATUS_MECHANIC_INTR,@r1  // raise mechanic interrupt to indicate command is done
    /* 46e4: 54 70       */ rts

glabel FUNC_46E6
    /* 46e6: 04 80       */ orc         #CCR_I,ccr
    /* 46e8: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 46ec: 79 00 00 00 */ mov.w       #0x0,r0
    /* 46f0: 6b 80 ff 4c */ mov.w       r0,@DAT_FF4C:16
    /* 46f4: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 46f8: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 46fa: 5e 00 50 70 */ jsr         @FUNC_5070:24
    /* 46fe: 44 20       */ bcc         LBL_4720
    /* 4700: 7f bb 70 20 */ bset        #0x2,@REG_P6DR:8
    /* 4704: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4708: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 470c: 7d 10 70 70 */ bset        #0x7,@r1
    /* 4710: 7d 10 72 60 */ bclr        #0x6,@r1
    /* 4714: 7f 03 72 70 */ bclr        #0x7,@DAT_FF03:8
    /* 4718: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 471c: 7f 06 70 10 */ bset        #0x1,@DAT_FF06:8
LBL_4720:
    /* 4720: 54 70       */ rts

glabel FUNC_4722
    /* 4722: 79 00 05 dc */ mov.w       #0x5dc,r0           // r0 = 0x5DC
    /* 4726: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3      // r3 = *REG_FRC
    /* 472a: 09 30       */ add.w       r3,r0               // r0 += r3
    /* 472c: 6b 80 ff 94 */ mov.w       r0,@REG_OCR:16      // *REG_OCR = r0
    /* 4730: 7f 91 72 30 */ bclr        #0x3,@REG_TCSR:8    // *REG_TCSR &= ~(1 << 3)
LBL_4734:
    /* 4734: 7e 91 73 30 */ btst        #0x3,@REG_TCSR:8    // while bit 3 in REG_TCSR is set?
    /* 4738: 47 fa       */ beq         LBL_4734
    /* 473a: 54 70       */ rts

glabel FUNC_473C
    /* 473c: 6d f1       */ mov.w       r1,@-r7             // push r1
    /* 473e: 5e 00 47 22 */ jsr         @FUNC_4722:24
    /* 4742: 6d 71       */ mov.w       @r7+,r1             // pop r1
    /* 4744: 19 41       */ sub.w       r4,r1               // r1--
    /* 4746: 46 f4       */ bne         FUNC_473C
    /* 4748: 54 70       */ rts

glabel LBL_474A // not called?
    /* 474a: 6d f0       */ mov.w       r0,@-r7
    /* 474c: 6d f3       */ mov.w       r3,@-r7
    /* 474e: 6d f5       */ mov.w       r5,@-r7
    /* 4750: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3
    /* 4754: 79 05 05 d2 */ mov.w       #0x5d2,r5
LBL_4758:
    /* 4758: 6b 00 ff 92 */ mov.w       @REG_FRC:16,r0
    /* 475c: 19 30       */ sub.w       r3,r0
    /* 475e: 1d 50       */ cmp.w       r5,r0
    /* 4760: 4d f6       */ blt         LBL_4758
    /* 4762: 19 41       */ sub.w       r4,r1
    /* 4764: 47 08       */ beq         LBL_476E
    /* 4766: 79 05 05 dc */ mov.w       #0x5dc,r5
    /* 476a: 09 53       */ add.w       r5,r3
    /* 476c: 40 ea       */ bra         LBL_4758
LBL_476E:
    /* 476e: 6d 75       */ mov.w       @r7+,r5
    /* 4770: 6d 73       */ mov.w       @r7+,r3
    /* 4772: 6d 70       */ mov.w       @r7+,r0
    /* 4774: 54 70       */ rts

glabel FUNC_4776
    /* 4776: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 477a: 20 1d       */ mov.b       @DAT_FF1D:8,r0h
    /* 477c: 47 06       */ beq         LBL_4784
    /* 477e: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 4782: 40 04       */ bra         LBL_4788
LBL_4784:
    /* 4784: 7d 10 70 50 */ bset        #0x5,@r1
LBL_4788:
    /* 4788: 6a 80 fd e3 */ mov.b       r0h,@DAT_FDE3:16
    /* 478c: 54 70       */ rts

glabel FUNC_478E
    /* 478e: 6a 08 fb fe */ mov.b       @DAT_FBFE:16,r0l
    /* 4792: e8 cf       */ and.b       #0xcf,r0l
    /* 4794: f0 0e       */ mov.b       #0xe,r0h
    /* 4796: 5e 00 47 f4 */ jsr         @FUNC_47F4:24
    /* 479a: 54 70       */ rts

glabel FUNC_479C
    /* 479c: 6a 08 fb fe */ mov.b       @DAT_FBFE:16,r0l
    /* 47a0: c8 30       */ or.b        #0x30,r0l
    /* 47a2: f0 0e       */ mov.b       #0xe,r0h
    /* 47a4: 5e 00 47 f4 */ jsr         @FUNC_47F4:24
    /* 47a8: 54 70       */ rts

glabel FUNC_47AA // unused?
    /* 47aa: 54 70       */ rts

glabel FUNC_47AC
    /* 47ac: 10 80       */ shal.b      r0h
    /* 47ae: e0 1e       */ and.b       #0x1e,r0h
    /* 47b0: c0 80       */ or.b        #0x80,r0h
    /* 47b2: f8 00       */ mov.b       #0x0,r0l
    /* 47b4: 7f bb 72 50 */ bclr        #0x5,@REG_P6DR:8
    /* 47b8: f3 07       */ mov.b       #0x7,r3h
    /* 47ba: 5e 00 48 0e */ jsr         @FUNC_480E:24
    /* 47be: 7f bb 72 60 */ bclr        #0x6,@REG_P6DR:8
    /* 47c2: f3 77       */ mov.b       #0x77,r3h
    /* 47c4: 33 b9       */ mov.b       r3h,@REG_P6DDR:8
    /* 47c6: 7f bb 70 60 */ bset        #0x6,@REG_P6DR:8
    /* 47ca: f3 08       */ mov.b       #0x8,r3h
LBL_47CC:
    /* 47cc: 7f bb 72 60 */ bclr        #0x6,@REG_P6DR:8
    /* 47d0: 7f bb 70 60 */ bset        #0x6,@REG_P6DR:8
    /* 47d4: 10 80       */ shal.b      r0h
    /* 47d6: 7e bb 73 70 */ btst        #0x7,@REG_P6DR:8
    /* 47da: 46 04       */ bne         LBL_47E0
    /* 47dc: 72 00       */ bclr        #0x0,r0h
    /* 47de: 40 02       */ bra         LBL_47E2
LBL_47E0:
    /* 47e0: 70 00       */ bset        #0x0,r0h
LBL_47E2:
    /* 47e2: 1a 03       */ dec.b       r3h
    /* 47e4: 46 e6       */ bne         LBL_47CC
    /* 47e6: 7f bb 70 50 */ bset        #0x5,@REG_P6DR:8
    /* 47ea: 7f bb 72 70 */ bclr        #0x7,@REG_P6DR:8
    /* 47ee: f3 f7       */ mov.b       #0xf7,r3h
    /* 47f0: 33 b9       */ mov.b       r3h,@REG_P6DDR:8
    /* 47f2: 54 70       */ rts

glabel FUNC_47F4
    /* 47f4: 10 80       */ shal.b      r0h
    /* 47f6: e0 1e       */ and.b       #0x1e,r0h
    /* 47f8: c0 c0       */ or.b        #0xc0,r0h
    /* 47fa: 7f bb 72 50 */ bclr        #0x5,@REG_P6DR:8
    /* 47fe: f3 10       */ mov.b       #0x10,r3h
    /* 4800: 5e 00 48 0e */ jsr         @FUNC_480E:24
    /* 4804: 7f bb 70 50 */ bset        #0x5,@REG_P6DR:8
    /* 4808: 7f bb 72 70 */ bclr        #0x7,@REG_P6DR:8
    /* 480c: 54 70       */ rts

glabel FUNC_480E
    /* 480e: 7f bb 72 60 */ bclr        #0x6,@REG_P6DR:8
    /* 4812: 73 70       */ btst        #0x7,r0h
    /* 4814: 46 06       */ bne         LBL_481C
    /* 4816: 7f bb 72 70 */ bclr        #0x7,@REG_P6DR:8
    /* 481a: 40 04       */ bra         LBL_4820
LBL_481C:
    /* 481c: 7f bb 70 70 */ bset        #0x7,@REG_P6DR:8
LBL_4820:
    /* 4820: 7f bb 70 60 */ bset        #0x6,@REG_P6DR:8
    /* 4824: 10 88       */ shal.b      r0l
    /* 4826: 12 00       */ rotxl.b     r0h
    /* 4828: 1a 03       */ dec.b       r3h
    /* 482a: 46 e2       */ bne         FUNC_480E
    /* 482c: 54 70       */ rts

glabel FUNC_482E
    /* 482e: 11 00       */ shlr.b      r0h
    /* 4830: 13 08       */ rotxr.b     r0l
    /* 4832: e0 1f       */ and.b       #0x1f,r0h
    /* 4834: c0 c0       */ or.b        #0xc0,r0h
    /* 4836: 7f b7 70 20 */ bset        #0x2,@REG_P4DR:8
    /* 483a: f3 09       */ mov.b       #0x9,r3h
    /* 483c: 5e 00 48 f0 */ jsr         @FUNC_48F0:24
    /* 4840: f3 10       */ mov.b       #0x10,r3h
LBL_4842:
    /* 4842: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 4846: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 484a: 73 0b       */ btst        #0x0,r3l
    /* 484c: 46 04       */ bne         LBL_4852
    /* 484e: 72 08       */ bclr        #0x0,r0l
    /* 4850: 40 02       */ bra         LBL_4854
LBL_4852:
    /* 4852: 70 08       */ bset        #0x0,r0l
LBL_4854:
    /* 4854: 10 88       */ shal.b      r0l
    /* 4856: 12 00       */ rotxl.b     r0h
    /* 4858: 2b ba       */ mov.b       @REG_P5DR:8,r3l
    /* 485a: 1a 03       */ dec.b       r3h
    /* 485c: 46 e4       */ bne         LBL_4842
    /* 485e: 73 0b       */ btst        #0x0,r3l
    /* 4860: 46 04       */ bne         LBL_4866
    /* 4862: 72 08       */ bclr        #0x0,r0l
    /* 4864: 40 02       */ bra         LBL_4868
LBL_4866:
    /* 4866: 70 08       */ bset        #0x0,r0l
LBL_4868:
    /* 4868: 7f b7 72 20 */ bclr        #0x2,@REG_P4DR:8
    /* 486c: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 4870: 54 70       */ rts

glabel FUNC_4872
    /* 4872: 0d 05       */ mov.w       r0,r5
    /* 4874: f0 98       */ mov.b       #0x98,r0h
    /* 4876: f8 00       */ mov.b       #0x0,r0l
    /* 4878: 7f b7 70 20 */ bset        #0x2,@REG_P4DR:8
    /* 487c: f3 09       */ mov.b       #0x9,r3h
    /* 487e: 5e 00 48 f0 */ jsr         @FUNC_48F0:24
    /* 4882: 7f b7 72 20 */ bclr        #0x2,@REG_P4DR:8
    /* 4886: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 488a: 0c b0       */ mov.b       r3l,r0h
    /* 488c: 11 00       */ shlr.b      r0h
    /* 488e: 13 08       */ rotxr.b     r0l
    /* 4890: e0 1f       */ and.b       #0x1f,r0h
    /* 4892: c0 a0       */ or.b        #0xa0,r0h
    /* 4894: 7f b7 70 20 */ bset        #0x2,@REG_P4DR:8
    /* 4898: f3 09       */ mov.b       #0x9,r3h
    /* 489a: 5e 00 48 f0 */ jsr         @FUNC_48F0:24
    /* 489e: 0d 50       */ mov.w       r5,r0
    /* 48a0: f3 10       */ mov.b       #0x10,r3h
    /* 48a2: 5e 00 48 f0 */ jsr         @FUNC_48F0:24
    /* 48a6: 7f b7 72 20 */ bclr        #0x2,@REG_P4DR:8
    /* 48aa: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 48ae: 79 00 ff ff */ mov.w       #0xffff,r0
    /* 48b2: 79 03 00 01 */ mov.w       #0x1,r3
    /* 48b6: 7f b7 70 20 */ bset        #0x2,@REG_P4DR:8
LBL_48BA:
    /* 48ba: 7e ba 73 00 */ btst        #0x0,@REG_P5DR:8
    /* 48be: 46 08       */ bne         LBL_48C8
    /* 48c0: 19 30       */ sub.w       r3,r0
    /* 48c2: 46 f6       */ bne         LBL_48BA
    /* 48c4: f5 ff       */ mov.b       #0xff,r5h
    /* 48c6: 40 02       */ bra         LBL_48CA
LBL_48C8:
    /* 48c8: f5 00       */ mov.b       #0x0,r5h
LBL_48CA:
    /* 48ca: 7f b7 72 20 */ bclr        #0x2,@REG_P4DR:8
    /* 48ce: f0 80       */ mov.b       #0x80,r0h
    /* 48d0: f8 00       */ mov.b       #0x0,r0l
    /* 48d2: 7f b7 70 20 */ bset        #0x2,@REG_P4DR:8
    /* 48d6: f3 09       */ mov.b       #0x9,r3h
    /* 48d8: 5e 00 48 f0 */ jsr         @FUNC_48F0:24
    /* 48dc: 7f b7 72 20 */ bclr        #0x2,@REG_P4DR:8
    /* 48e0: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 48e4: a5 00       */ cmp.b       #0x0,r5h
    /* 48e6: 46 04       */ bne         LBL_48EC
    /* 48e8: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 48ea: 40 02       */ bra         LBL_48EE
LBL_48EC:
    /* 48ec: 04 01       */ orc         #CCR_C,ccr
LBL_48EE:
    /* 48ee: 54 70       */ rts

glabel FUNC_48F0
    /* 48f0: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 48f4: 73 70       */ btst        #0x7,r0h
    /* 48f6: 46 06       */ bne         LBL_48FE
    /* 48f8: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 48fc: 40 04       */ bra         LBL_4902
LBL_48FE:
    /* 48fe: 7f ba 70 10 */ bset        #0x1,@REG_P5DR:8
LBL_4902:
    /* 4902: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 4906: 10 88       */ shal.b      r0l
    /* 4908: 12 00       */ rotxl.b     r0h
    /* 490a: 1a 03       */ dec.b       r3h
    /* 490c: 46 e2       */ bne         FUNC_48F0
    /* 490e: 54 70       */ rts

glabel FUNC_4910
    /* 4910: e0 0f       */ and.b       #0xf,r0h
    /* 4912: c0 60       */ or.b        #0x60,r0h
    /* 4914: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 4918: 7f ba 70 20 */ bset        #0x2,@REG_P5DR:8
    /* 491c: f3 08       */ mov.b       #0x8,r3h
    /* 491e: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 4922: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 4926: f3 04       */ mov.b       #0x4,r3h
    /* 4928: 33 b8       */ mov.b       r3h,@REG_P5DDR:8
    /* 492a: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 492e: f3 07       */ mov.b       #0x7,r3h
LBL_4930:
    /* 4930: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 4934: 10 80       */ shal.b      r0h
    /* 4936: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 493a: 7e ba 73 10 */ btst        #0x1,@REG_P5DR:8
    /* 493e: 46 04       */ bne         LBL_4944
    /* 4940: 72 00       */ bclr        #0x0,r0h
    /* 4942: 40 02       */ bra         LBL_4946
LBL_4944:
    /* 4944: 70 00       */ bset        #0x0,r0h
LBL_4946:
    /* 4946: 1a 03       */ dec.b       r3h
    /* 4948: 46 e6       */ bne         LBL_4930
    /* 494a: e0 0f       */ and.b       #0xf,r0h
    /* 494c: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 4950: 7f ba 72 20 */ bclr        #0x2,@REG_P5DR:8
    /* 4954: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 4958: f3 06       */ mov.b       #0x6,r3h
    /* 495a: 33 b8       */ mov.b       r3h,@REG_P5DDR:8
    /* 495c: 54 70       */ rts

glabel FUNC_495E
    /* 495e: e0 0f       */ and.b       #0xf,r0h
    /* 4960: c0 20       */ or.b        #0x20,r0h
    /* 4962: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 4966: 7f ba 70 20 */ bset        #0x2,@REG_P5DR:8
    /* 496a: f3 08       */ mov.b       #0x8,r3h
    /* 496c: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 4970: e8 0f       */ and.b       #0xf,r0l
    /* 4972: c8 10       */ or.b        #0x10,r0l
    /* 4974: 0c 80       */ mov.b       r0l,r0h
    /* 4976: f3 08       */ mov.b       #0x8,r3h
    /* 4978: 5e 00 49 8a */ jsr         @FUNC_498A:24
    /* 497c: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 4980: 7f ba 72 20 */ bclr        #0x2,@REG_P5DR:8
    /* 4984: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 4988: 54 70       */ rts

glabel FUNC_498A
    /* 498a: 7f b7 70 10 */ bset        #0x1,@REG_P4DR:8
    /* 498e: 73 70       */ btst        #0x7,r0h
    /* 4990: 46 06       */ bne         LBL_4998
    /* 4992: 7f ba 72 10 */ bclr        #0x1,@REG_P5DR:8
    /* 4996: 40 04       */ bra         LBL_499C
LBL_4998:
    /* 4998: 7f ba 70 10 */ bset        #0x1,@REG_P5DR:8
LBL_499C:
    /* 499c: 7f b7 72 10 */ bclr        #0x1,@REG_P4DR:8
    /* 49a0: 10 80       */ shal.b      r0h
    /* 49a2: 1a 03       */ dec.b       r3h
    /* 49a4: 46 e4       */ bne         FUNC_498A
    /* 49a6: 54 70       */ rts

glabel FUNC_49A8
    /* 49a8: 7f 06 72 10 */ bclr        #0x1,@DAT_FF06:8
    /* 49ac: 7e 0e 73 20 */ btst        #0x2,@DAT_FF0E:8
    /* 49b0: 46 08       */ bne         LBL_49BA
    /* 49b2: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 49b6: 5a 00 4a ac */ jmp         @LBL_4AAC:24
LBL_49BA:
    /* 49ba: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 49be: 7d 10 72 40 */ bclr        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
    /* 49c2: 04 80       */ orc         #CCR_I,ccr
    /* 49c4: 7f 03 72 60 */ bclr        #0x6,@DAT_FF03:8
    /* 49c8: 5e 00 47 9c */ jsr         @FUNC_479C:24
    /* 49cc: f0 04       */ mov.b       #0x4,r0h
    /* 49ce: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
    /* 49d2: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 49d6: 7d 10 72 50 */ bclr        #0x5,@r1
LBL_49DA:
    /* 49da: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 49de: 47 12       */ beq         LBL_49F2
    /* 49e0: 5e 00 4c e6 */ jsr         @FUNC_4CE6:24
    /* 49e4: 7e 0e 73 70 */ btst        #0x7,@DAT_FF0E:8
    /* 49e8: 47 08       */ beq         LBL_49F2
    /* 49ea: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
    /* 49ee: 5a 00 4a ac */ jmp         @LBL_4AAC:24
LBL_49F2:
    /* 49f2: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 49f6: 7d 10 70 40 */ bset        #0x4,@r1
    /* 49fa: 7e 0e 73 30 */ btst        #0x3,@DAT_FF0E:8
    /* 49fe: 47 44       */ beq         LBL_4A44
    /* 4a00: 7f bb 72 20 */ bclr        #0x2,@REG_P6DR:8
    /* 4a04: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4a08: 7d 10 70 70 */ bset        #0x7,@r1
    /* 4a0c: 7d 10 70 60 */ bset        #0x6,@r1
    /* 4a10: 79 01 00 0a */ mov.w       #0xa,r1
    /* 4a14: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4a18: 7f bb 70 20 */ bset        #0x2,@REG_P6DR:8
    /* 4a1c: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4a20: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 4a24: 7d 10 70 70 */ bset        #0x7,@r1
    /* 4a28: 7d 10 72 60 */ bclr        #0x6,@r1
    /* 4a2c: 79 01 00 5a */ mov.w       #0x5a,r1
    /* 4a30: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4a34: 6a 00 fd 94 */ mov.b       @DAT_FD94:16,r0h
    /* 4a38: 1a 00       */ dec.b       r0h
    /* 4a3a: 6a 80 fd 94 */ mov.b       r0h,@DAT_FD94:16
    /* 4a3e: 46 9a       */ bne         LBL_49DA
    /* 4a40: 7f 0e 72 30 */ bclr        #0x3,@DAT_FF0E:8
LBL_4A44:
    /* 4a44: 7f bb 72 20 */ bclr        #0x2,@REG_P6DR:8
    /* 4a48: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4a4c: 7d 10 70 50 */ bset        #0x5,@r1
    /* 4a50: 7d 10 72 70 */ bclr        #0x7,@r1
    /* 4a54: 7d 10 72 60 */ bclr        #0x6,@r1
    /* 4a58: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3
    /* 4a5c: 79 00 13 88 */ mov.w       #0x1388,r0
    /* 4a60: 09 30       */ add.w       r3,r0
    /* 4a62: 6b 80 ff 94 */ mov.w       r0,@REG_OCR:16
    /* 4a66: 7f c7 72 20 */ bclr        #0x2,@REG_IER:8
    /* 4a6a: 7f 90 70 30 */ bset        #0x3,@REG_TIER:8
    /* 4a6e: 06 7f       */ andc        #(~CCR_I & 0xFF),ccr
    /* 4a70: 79 00 00 00 */ mov.w       #0x0,r0
    /* 4a74: 6b 80 fd f2 */ mov.w       r0,@DAT_FDF2:16
    /* 4a78: 5e 00 4b 02 */ jsr         @FUNC_4B02:24
    /* 4a7c: 44 06       */ bcc         LBL_4A84
    /* 4a7e: 7f 06 70 10 */ bset        #0x1,@DAT_FF06:8
    /* 4a82: 40 28       */ bra         LBL_4AAC
LBL_4A84:
    /* 4a84: 04 80       */ orc         #CCR_I,ccr
    /* 4a86: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 4a8a: 47 12       */ beq         LBL_4A9E
    /* 4a8c: 5e 00 4c e6 */ jsr         @FUNC_4CE6:24
    /* 4a90: 7e 0e 73 70 */ btst        #0x7,@DAT_FF0E:8
    /* 4a94: 47 08       */ beq         LBL_4A9E
    /* 4a96: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
    /* 4a9a: 5a 00 4a ac */ jmp         @LBL_4AAC:24
LBL_4A9E:
    /* 4a9e: 7f 90 72 30 */ bclr        #0x3,@REG_TIER:8
    /* 4aa2: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 4aa6: 7f 03 70 70 */ bset        #0x7,@DAT_FF03:8
    /* 4aaa: 54 70       */ rts
LBL_4AAC:
    /* 4aac: 04 80       */ orc         #CCR_I,ccr
    /* 4aae: 7f 90 72 30 */ bclr        #0x3,@REG_TIER:8
    /* 4ab2: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 4ab6: 7f bb 70 20 */ bset        #0x2,@REG_P6DR:8
    /* 4aba: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4abe: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 4ac2: 7d 10 70 70 */ bset        #0x7,@r1
    /* 4ac6: 7d 10 72 60 */ bclr        #0x6,@r1
    /* 4aca: 7f 03 70 60 */ bset        #0x6,@DAT_FF03:8
    /* 4ace: 7f 03 72 70 */ bclr        #0x7,@DAT_FF03:8
    /* 4ad2: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4ad6: 7d 10 70 40 */ bset        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
    /* 4ada: 54 70       */ rts

glabel OCIA_HANDLER
    /* 4adc: 6d f0       */ mov.w       r0,@-r7             // save r0
    /* 4ade: 6d f3       */ mov.w       r3,@-r7             // save r3
    /* 4ae0: 6b 00 fd f2 */ mov.w       @DAT_FDF2:16,r0     // r0 = U16(DAT_FDF2)
    /* 4ae4: 09 40       */ add.w       r4,r0               // r0 += r4     (r4 = 0x0001)
    /* 4ae6: 6b 80 fd f2 */ mov.w       r0,@DAT_FDF2:16     // U16(DAT_FDF2) = r0
    /* 4aea: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3      // r3 = U16(REG_FRC)
    /* 4aee: 79 00 13 88 */ mov.w       #0x1388,r0          // r0 = 0x1388
    /* 4af2: 09 30       */ add.w       r3,r0               // r0 += r3
    /* 4af4: 6b 80 ff 94 */ mov.w       r0,@REG_OCR:16      // U16(REG_OCR) = r0
    /* 4af8: 7f 91 72 30 */ bclr        #0x3,@REG_TCSR:8    // U8(REG_TCSR) &= ~(1 << 3)
    /* 4afc: 6d 73       */ mov.w       @r7+,r3             // restore r3
    /* 4afe: 6d 70       */ mov.w       @r7+,r0             // restore r0
    /* 4b00: 56 70       */ rte

glabel FUNC_4B02
    /* 4b02: 34 91       */ mov.b       r4h,@REG_TCSR:8
LBL_4B04:
    /* 4b04: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 4b08: 46 18       */ bne         LBL_4B22
    /* 4b0a: 6b 00 fd f2 */ mov.w       @DAT_FDF2:16,r0
    /* 4b0e: 79 03 01 f4 */ mov.w       #0x1f4,r3
    /* 4b12: 1d 30       */ cmp.w       r3,r0
    /* 4b14: 45 ee       */ bcs         LBL_4B04
LBL_4B16:
    /* 4b16: 7f 0e 72 20 */ bclr        #0x2,@DAT_FF0E:8
    /* 4b1a: 6a 84 fe 18 */ mov.b       r4h,@DAT_FE18:16
    /* 4b1e: 04 01       */ orc         #CCR_C,ccr
    /* 4b20: 54 70       */ rts
LBL_4B22:
    /* 4b22: 79 02 00 08 */ mov.w       #0x8,r2
LBL_4B26:
    /* 4b26: 5e 00 4b 48 */ jsr         @FUNC_4B48:24
    /* 4b2a: 44 0e       */ bcc         LBL_4B3A
    /* 4b2c: 6b 00 fd f2 */ mov.w       @DAT_FDF2:16,r0
    /* 4b30: 79 03 01 f4 */ mov.w       #0x1f4,r3
    /* 4b34: 1d 30       */ cmp.w       r3,r0
    /* 4b36: 45 ea       */ bcs         LBL_4B22
    /* 4b38: 40 dc       */ bra         LBL_4B16
LBL_4B3A:
    /* 4b3a: 19 42       */ sub.w       r4,r2
    /* 4b3c: 79 03 00 00 */ mov.w       #0x0,r3
    /* 4b40: 1d 32       */ cmp.w       r3,r2
    /* 4b42: 4a e2       */ bpl         LBL_4B26
    /* 4b44: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 4b46: 54 70       */ rts

glabel FUNC_4B48
    /* 4b48: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 4b4c: 47 3c       */ beq         LBL_4B8A
    /* 4b4e: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
    /* 4b52: 6a 00 fd eb */ mov.b       @DAT_FDEB:16,r0h
    /* 4b56: 0a 00       */ inc         r0h
    /* 4b58: 6a 80 fd eb */ mov.b       r0h,@DAT_FDEB:16
    /* 4b5c: a0 3c       */ cmp.b       #0x3c,r0h
    /* 4b5e: 4b 2a       */ bmi         LBL_4B8A
    /* 4b60: 6a 84 fd eb */ mov.b       r4h,@DAT_FDEB:16
    /* 4b64: 6b 00 ff 9a */ mov.w       @REG_ICRB:16,r0
    /* 4b68: 6b 03 fd f4 */ mov.w       @DAT_FDF4:16,r3
    /* 4b6c: 6b 80 fd f4 */ mov.w       r0,@DAT_FDF4:16
    /* 4b70: 19 30       */ sub.w       r3,r0
    /* 4b72: 79 03 94 65 */ mov.w       #0x9465,r3
    /* 4b76: 1d 30       */ cmp.w       r3,r0
    /* 4b78: 4e 0c       */ bgt         LBL_4B86
    /* 4b7a: 79 03 92 eb */ mov.w       #0x92eb,r3
    /* 4b7e: 1d 30       */ cmp.w       r3,r0
    /* 4b80: 4b 04       */ bmi         LBL_4B86
    /* 4b82: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 4b84: 54 70       */ rts
LBL_4B86:
    /* 4b86: 04 01       */ orc         #CCR_C,ccr
    /* 4b88: 54 70       */ rts
LBL_4B8A:
    /* 4b8a: 6b 00 ff 92 */ mov.w       @REG_FRC:16,r0
    /* 4b8e: 6b 03 fd f4 */ mov.w       @DAT_FDF4:16,r3
    /* 4b92: 19 30       */ sub.w       r3,r0
    /* 4b94: 79 03 b8 92 */ mov.w       #0xb892,r3
    /* 4b98: 1d 30       */ cmp.w       r3,r0
    /* 4b9a: 43 ac       */ bls         FUNC_4B48
    /* 4b9c: 6a 8c fd eb */ mov.b       r4l,@DAT_FDEB:16
    /* 4ba0: 6b 00 ff 9a */ mov.w       @REG_ICRB:16,r0
    /* 4ba4: 6b 80 fd f4 */ mov.w       r0,@DAT_FDF4:16
    /* 4ba8: 40 dc       */ bra         LBL_4B86
    /* 4baa: 54 70       */ rts

glabel FUNC_4BAC
    /* 4bac: 04 80       */ orc         #CCR_I,ccr
    /* 4bae: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 4bb0: fa fa       */ mov.b       #0xfa,r2l
    /* 4bb2: 7f bb 70 20 */ bset        #0x2,@REG_P6DR:8
    /* 4bb6: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4bba: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 4bbe: 7d 10 70 60 */ bset        #0x6,@r1
    /* 4bc2: 7d 10 70 70 */ bset        #0x7,@r1
LBL_4BC6:
    /* 4bc6: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3
    /* 4bca: 79 00 11 94 */ mov.w       #0x1194,r0
    /* 4bce: 09 30       */ add.w       r3,r0
    /* 4bd0: 6b 80 ff 94 */ mov.w       r0,@REG_OCR:16
    /* 4bd4: 7f 91 72 30 */ bclr        #0x3,@REG_TCSR:8
    /* 4bd8: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
LBL_4BDC:
    /* 4bdc: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 4be0: 47 06       */ beq         LBL_4BE8
    /* 4be2: 1a 0a       */ dec.b       r2l
    /* 4be4: 47 08       */ beq         LBL_4BEE
    /* 4be6: 40 de       */ bra         LBL_4BC6
LBL_4BE8:
    /* 4be8: 7e 91 73 30 */ btst        #0x3,@REG_TCSR:8
    /* 4bec: 47 ee       */ beq         LBL_4BDC
LBL_4BEE:
    /* 4bee: 7f bb 70 20 */ bset        #0x2,@REG_P6DR:8
    /* 4bf2: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4bf6: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 4bfa: 7d 10 70 70 */ bset        #0x7,@r1
    /* 4bfe: 7d 10 72 60 */ bclr        #0x6,@r1
    /* 4c02: 54 70       */ rts

glabel FUNC_4C04
    /* 4c04: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4c08: 7d 10 70 30 */ bset        #ASIC_STATUS_HEAD_RETRACTED,@r1
    /* 4c0c: 04 80       */ orc         #CCR_I,ccr
    /* 4c0e: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 4c10: 7f bb 70 00 */ bset        #0x0,@REG_P6DR:8
    /* 4c14: f0 0a       */ mov.b       #0xa,r0h
    /* 4c16: 30 23       */ mov.b       r0h,@DAT_FF23:8
LBL_4C18:
    /* 4c18: 5e 00 26 f8 */ jsr         @FUNC_26F8:24
    /* 4c1c: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 4c20: e0 07       */ and.b       #0x7,r0h
    /* 4c22: a0 03       */ cmp.b       #0x3,r0h
    /* 4c24: 47 0c       */ beq         LBL_4C32
    /* 4c26: 20 23       */ mov.b       @DAT_FF23:8,r0h
    /* 4c28: 1a 00       */ dec.b       r0h
    /* 4c2a: 30 23       */ mov.b       r0h,@DAT_FF23:8
    /* 4c2c: 46 ea       */ bne         LBL_4C18
    /* 4c2e: 5a 00 4c 98 */ jmp         @LBL_4C98:24
LBL_4C32:
    /* 4c32: f0 0a       */ mov.b       #0xa,r0h
    /* 4c34: 30 23       */ mov.b       r0h,@DAT_FF23:8
LBL_4C36:
    /* 4c36: 5e 00 27 12 */ jsr         @FUNC_2712:24
    /* 4c3a: 5e 00 27 20 */ jsr         @FUNC_2720:24
    /* 4c3e: 45 0c       */ bcs         LBL_4C4C
    /* 4c40: 79 03 01 64 */ mov.w       #0x164,r3
    /* 4c44: 1d 30       */ cmp.w       r3,r0
    /* 4c46: 44 10       */ bcc         LBL_4C58
    /* 4c48: 5a 00 4c 98 */ jmp         @LBL_4C98:24
LBL_4C4C:
    /* 4c4c: 20 23       */ mov.b       @DAT_FF23:8,r0h
    /* 4c4e: 1a 00       */ dec.b       r0h
    /* 4c50: 30 23       */ mov.b       r0h,@DAT_FF23:8
    /* 4c52: 46 e2       */ bne         LBL_4C36
    /* 4c54: 5a 00 4c 98 */ jmp         @LBL_4C98:24
LBL_4C58:
    /* 4c58: 6b 80 fd 80 */ mov.w       r0,@DAT_FD80:16
    /* 4c5c: 34 23       */ mov.b       r4h,@DAT_FF23:8
    /* 4c5e: 34 33       */ mov.b       r4h,@DAT_FF33:8
    /* 4c60: 79 00 00 80 */ mov.w       #0x80,r0
    /* 4c64: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 4c68: 7f 01 72 50 */ bclr        #0x5,@DAT_FF01:8
    /* 4c6c: 5e 00 25 ea */ jsr         @FUNC_25EA:24
    /* 4c70: 44 04       */ bcc         LBL_4C76
    /* 4c72: 5a 00 4c 98 */ jmp         @LBL_4C98:24
LBL_4C76:
    /* 4c76: 79 00 00 e4 */ mov.w       #0xe4,r0
    /* 4c7a: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 4c7e: 79 01 01 2c */ mov.w       #0x12c,r1
    /* 4c82: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4c86: 79 00 00 80 */ mov.w       #0x80,r0
    /* 4c8a: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 4c8e: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 4c92: 5e 00 47 9c */ jsr         @FUNC_479C:24
    /* 4c96: 54 70       */ rts
LBL_4C98:
    /* 4c98: 7f bb 70 00 */ bset        #0x0,@REG_P6DR:8
    /* 4c9c: 79 00 00 80 */ mov.w       #0x80,r0
    /* 4ca0: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 4ca4: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
LBL_4CA8:
    /* 4ca8: 79 01 00 02 */ mov.w       #0x2,r1
    /* 4cac: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4cb0: 6b 00 ff 5a */ mov.w       @DAT_FF5A:16,r0
    /* 4cb4: 79 03 00 04 */ mov.w       #0x4,r3
    /* 4cb8: 09 30       */ add.w       r3,r0
    /* 4cba: 79 03 00 e4 */ mov.w       #0xe4,r3
    /* 4cbe: 1d 30       */ cmp.w       r3,r0
    /* 4cc0: 44 0a       */ bcc         LBL_4CCC
    /* 4cc2: 6b 80 ff 5a */ mov.w       r0,@DAT_FF5A:16
    /* 4cc6: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 4cca: 40 dc       */ bra         LBL_4CA8
LBL_4CCC:
    /* 4ccc: 79 01 01 2c */ mov.w       #0x12c,r1
    /* 4cd0: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4cd4: 79 00 00 80 */ mov.w       #0x80,r0
    /* 4cd8: 5e 00 0f 0e */ jsr         @FUNC_0F0E:24
    /* 4cdc: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 4ce0: 5e 00 47 9c */ jsr         @FUNC_479C:24
    /* 4ce4: 54 70       */ rts

glabel FUNC_4CE6
    /* 4ce6: 20 b3       */ mov.b       @REG_P2DR:8,r0h
    /* 4ce8: 28 0e       */ mov.b       @DAT_FF0E:8,r0l
    /* 4cea: e0 80       */ and.b       #0x80,r0h
    /* 4cec: e8 80       */ and.b       #0x80,r0l
    /* 4cee: 1c 08       */ cmp.b       r0h,r0l
    /* 4cf0: 46 04       */ bne         LBL_4CF6
    /* 4cf2: 5a 00 4d 8e */ jmp         @LBL_4D8E:24
LBL_4CF6:
    /* 4cf6: 73 70       */ btst        #0x7,r0h
    /* 4cf8: 47 40       */ beq         LBL_4D3A
    /* 4cfa: f0 10       */ mov.b       #0x10,r0h
    /* 4cfc: 30 4b       */ mov.b       r0h,@DAT_FF4B:8
LBL_4CFE:
    /* 4cfe: 79 01 00 32 */ mov.w       #0x32,r1
    /* 4d02: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4d06: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 4d0a: 46 04       */ bne         LBL_4D10
    /* 4d0c: 5a 00 4d 8e */ jmp         @LBL_4D8E:24
LBL_4D10:
    /* 4d10: 20 4b       */ mov.b       @DAT_FF4B:8,r0h
    /* 4d12: 1a 00       */ dec.b       r0h
    /* 4d14: 30 4b       */ mov.b       r0h,@DAT_FF4B:8
    /* 4d16: 46 e6       */ bne         LBL_4CFE
    /* 4d18: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 4d1c: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 4d20: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 4d24: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 4d28: 7d 10 72 40 */ bclr        #0x4,@r1
    /* 4d2c: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4d30: 7d 10 70 40 */ bset        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
    /* 4d34: 7d 10 70 30 */ bset        #ASIC_STATUS_HEAD_RETRACTED,@r1
    /* 4d38: 40 50       */ bra         LBL_4D8A
LBL_4D3A:
    /* 4d3a: 79 01 00 32 */ mov.w       #0x32,r1
    /* 4d3e: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4d42: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4d46: 7c 10 73 70 */ btst        #ASIC_STATUS_BUSY,@r1
    /* 4d4a: 47 18       */ beq         LBL_4D64
    /* 4d4c: 6b 00 80 02 */ mov.w       @REG_ASIC_CMD:16,r0     // r0 = *ASIC_CMD
    /* 4d50: 79 03 00 0c */ mov.w       #0xc,r3                 // r3 = 0xC
    /* 4d54: 1d 30       */ cmp.w       r3,r0                   // r0 == 0xC ?
    /* 4d56: 46 0c       */ bne         LBL_4D64
    /* 4d58: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4d5c: 7d 10 72 10 */ bclr        #ASIC_STATUS_MECHANIC_ERROR,@r1
    /* 4d60: 5e 00 32 cc */ jsr         @FUNC_32CC:24           // Make error status available on ASIC_DATA
LBL_4D64:
    /* 4d64: 79 01 00 32 */ mov.w       #0x32,r1                // r1 = 0x32
    /* 4d68: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 4d6c: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 4d70: 46 1c       */ bne         LBL_4D8E
    /* 4d72: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4d76: 7d 10 70 00 */ bset        #ASIC_STATUS_DISK_CHANGE,@r1
    /* 4d7a: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 4d7e: 7d 10 70 00 */ bset        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 4d82: 7f 0e 72 70 */ bclr        #0x7,@DAT_FF0E:8
    /* 4d86: 7f 0e 72 10 */ bclr        #0x1,@DAT_FF0E:8
LBL_4D8A:
    /* 4d8a: 04 01       */ orc         #CCR_C,ccr
    /* 4d8c: 54 70       */ rts
LBL_4D8E:
    /* 4d8e: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 4d90: 54 70       */ rts

glabel FUNC_4D92
    /* 4d92: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 4d96: 47 04       */ beq         LBL_4D9C
    /* 4d98: 5e 00 4c 04 */ jsr         @FUNC_4C04:24
LBL_4D9C:
    /* 4d9c: 04 80       */ orc         #CCR_I,ccr
    /* 4d9e: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 4da2: 5e 00 47 9c */ jsr         @FUNC_479C:24
    /* 4da6: 7e 03 73 70 */ btst        #0x7,@DAT_FF03:8
    /* 4daa: 47 04       */ beq         LBL_4DB0
    /* 4dac: 5e 00 4b ac */ jsr         @FUNC_4BAC:24
LBL_4DB0:
    /* 4db0: 7f bb 70 20 */ bset        #0x2,@REG_P6DR:8
    /* 4db4: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4db8: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 4dbc: 7d 10 70 70 */ bset        #0x7,@r1
    /* 4dc0: 7d 10 72 60 */ bclr        #0x6,@r1
    /* 4dc4: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 4dc8: 7d 10 72 40 */ bclr        #0x4,@r1
    /* 4dcc: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4dd0: 7d 10 70 40 */ bset        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
    /* 4dd4: 7d 10 70 30 */ bset        #ASIC_STATUS_HEAD_RETRACTED,@r1
    /* 4dd8: 34 00       */ mov.b       r4h,@DAT_FF00:8
    /* 4dda: 7f 03 72 40 */ bclr        #0x4,@DAT_FF03:8
    /* 4dde: 7f 03 72 70 */ bclr        #0x7,@DAT_FF03:8
    /* 4de2: 7f 0e 70 30 */ bset        #0x3,@DAT_FF0E:8
    /* 4de6: 7f 11 70 70 */ bset        #0x7,@DAT_FF11:8
    /* 4dea: 7f 10 72 20 */ bclr        #0x2,@DAT_FF10:8
    /* 4dee: 79 00 00 00 */ mov.w       #0x0,r0
    /* 4df2: 6b 80 ff 4c */ mov.w       r0,@DAT_FF4C:16
    /* 4df6: 6b 80 ff 4e */ mov.w       r0,@DAT_FF4E:16
    /* 4dfa: 7f 0e 72 10 */ bclr        #0x1,@DAT_FF0E:8
    /* 4dfe: 7f 03 72 10 */ bclr        #0x1,@DAT_FF03:8
    /* 4e02: 54 70       */ rts

glabel FUNC_4E04
    /* 4e04: 7e 91 73 10 */ btst        #0x1,@REG_TCSR:8
    /* 4e08: 46 04       */ bne         LBL_4E0E
    /* 4e0a: 5a 00 4f 14 */ jmp         @LBL_4F14:24
LBL_4E0E:
    /* 4e0e: 7f 91 72 10 */ bclr        #0x1,@REG_TCSR:8
    /* 4e12: 7e 11 73 70 */ btst        #0x7,@DAT_FF11:8
    /* 4e16: 47 04       */ beq         LBL_4E1C
    /* 4e18: 5a 00 4e e2 */ jmp         @LBL_4EE2:24
LBL_4E1C:
    /* 4e1c: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 4e20: 73 40       */ btst        #0x4,r0h
    /* 4e22: 47 1e       */ beq         LBL_4E42
    /* 4e24: 6a 00 fe 14 */ mov.b       @DAT_FE14:16,r0h
    /* 4e28: 1a 00       */ dec.b       r0h
    /* 4e2a: 6a 80 fe 14 */ mov.b       r0h,@DAT_FE14:16
    /* 4e2e: 46 2e       */ bne         LBL_4E5E
    /* 4e30: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 4e34: 7d 10 72 40 */ bclr        #0x4,@r1
    /* 4e38: 6a 00 fe 16 */ mov.b       @DAT_FE16:16,r0h
    /* 4e3c: 6a 80 fe 14 */ mov.b       r0h,@DAT_FE14:16
    /* 4e40: 40 1c       */ bra         LBL_4E5E
LBL_4E42:
    /* 4e42: 6a 00 fe 15 */ mov.b       @DAT_FE15:16,r0h
    /* 4e46: 1a 00       */ dec.b       r0h
    /* 4e48: 6a 80 fe 15 */ mov.b       r0h,@DAT_FE15:16
    /* 4e4c: 46 10       */ bne         LBL_4E5E
    /* 4e4e: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 4e52: 7d 10 70 40 */ bset        #0x4,@r1
    /* 4e56: 6a 00 fe 17 */ mov.b       @DAT_FE17:16,r0h
    /* 4e5a: 6a 80 fe 15 */ mov.b       r0h,@DAT_FE15:16
LBL_4E5E:
    /* 4e5e: 7e 11 73 60 */ btst        #0x6,@DAT_FF11:8
    /* 4e62: 46 32       */ bne         LBL_4E96
    /* 4e64: 7e 0e 73 50 */ btst        #0x5,@DAT_FF0E:8
    /* 4e68: 47 04       */ beq         LBL_4E6E
    /* 4e6a: 5a 00 4f 14 */ jmp         @LBL_4F14:24
LBL_4E6E:
    /* 4e6e: 7e 11 73 10 */ btst        #0x1,@DAT_FF11:8
    /* 4e72: 47 04       */ beq         LBL_4E78
    /* 4e74: 5a 00 4f 14 */ jmp         @LBL_4F14:24
LBL_4E78:
    /* 4e78: 6b 00 fe 10 */ mov.w       @DAT_FE10:16,r0
    /* 4e7c: 09 40       */ add.w       r4,r0
    /* 4e7e: 6b 80 fe 10 */ mov.w       r0,@DAT_FE10:16
    /* 4e82: 6b 03 fe 0c */ mov.w       @DAT_FE0C:16,r3
    /* 4e86: 1d 30       */ cmp.w       r3,r0
    /* 4e88: 44 04       */ bcc         LBL_4E8E
    /* 4e8a: 5a 00 4f 14 */ jmp         @LBL_4F14:24
LBL_4E8E:
    /* 4e8e: 5e 00 32 f2 */ jsr         @FUNC_32F2:24
    /* 4e92: 5a 00 4f 14 */ jmp         @LBL_4F14:24
LBL_4E96:
    /* 4e96: 5e 00 50 70 */ jsr         @FUNC_5070:24
    /* 4e9a: 44 1e       */ bcc         LBL_4EBA
    /* 4e9c: 7f bb 70 20 */ bset        #0x2,@REG_P6DR:8
    /* 4ea0: 79 01 80 1e */ mov.w       #DAT_801E,r1
    /* 4ea4: 7d 10 72 50 */ bclr        #0x5,@r1
    /* 4ea8: 7d 10 70 70 */ bset        #0x7,@r1
    /* 4eac: 7d 10 72 60 */ bclr        #0x6,@r1
    /* 4eb0: 7f 03 72 70 */ bclr        #0x7,@DAT_FF03:8
    /* 4eb4: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 4eb8: 40 5a       */ bra         LBL_4F14
LBL_4EBA:
    /* 4eba: 7e 0e 73 50 */ btst        #0x5,@DAT_FF0E:8
    /* 4ebe: 47 02       */ beq         LBL_4EC2
    /* 4ec0: 40 52       */ bra         LBL_4F14
LBL_4EC2:
    /* 4ec2: 7e 0e 73 40 */ btst        #0x4,@DAT_FF0E:8
    /* 4ec6: 47 02       */ beq         LBL_4ECA
    /* 4ec8: 40 4a       */ bra         LBL_4F14
LBL_4ECA:
    /* 4eca: 6b 00 fe 12 */ mov.w       @DAT_FE12:16,r0
    /* 4ece: 09 40       */ add.w       r4,r0
    /* 4ed0: 6b 80 fe 12 */ mov.w       r0,@DAT_FE12:16
    /* 4ed4: 6b 03 fe 0e */ mov.w       @DAT_FE0E:16,r3
    /* 4ed8: 1d 30       */ cmp.w       r3,r0
    /* 4eda: 45 38       */ bcs         LBL_4F14
    /* 4edc: 5e 00 31 8e */ jsr         @FUNC_318E:24
    /* 4ee0: 40 32       */ bra         LBL_4F14
LBL_4EE2:
    /* 4ee2: 6a 00 80 0f */ mov.b       @DAT_800F:16,r0h
    /* 4ee6: 73 40       */ btst        #0x4,r0h
    /* 4ee8: 47 2a       */ beq         LBL_4F14
    /* 4eea: 6b 00 fe 12 */ mov.w       @DAT_FE12:16,r0
    /* 4eee: 09 40       */ add.w       r4,r0
    /* 4ef0: 6b 80 fe 12 */ mov.w       r0,@DAT_FE12:16
    /* 4ef4: 79 03 00 10 */ mov.w       #0x10,r3
    /* 4ef8: 1d 30       */ cmp.w       r3,r0
    /* 4efa: 45 18       */ bcs         LBL_4F14
    /* 4efc: 79 01 80 0f */ mov.w       #DAT_800F,r1
    /* 4f00: 7d 10 72 40 */ bclr        #0x4,@r1
    /* 4f04: 79 01 80 05 */ mov.w       #REG_ASIC_STATUS+1,r1
    /* 4f08: 7d 10 70 40 */ bset        #ASIC_STATUS_MOTOR_NOT_SPINNING,@r1
    /* 4f0c: 79 00 00 00 */ mov.w       #0x0,r0
    /* 4f10: 6b 80 fe 12 */ mov.w       r0,@DAT_FE12:16
LBL_4F14:
    /* 4f14: 54 70       */ rts

glabel FUNC_4F16
    /* 4f16: 79 00 00 fb */ mov.w       #0xfb,r0
    /* 4f1a: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4f1e: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
LBL_4F22:
    /* 4f22: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 4f26: 46 18       */ bne         LBL_4F40
    /* 4f28: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 4f2c: 46 12       */ bne         LBL_4F40
    /* 4f2e: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 4f32: 47 04       */ beq         LBL_4F38
    /* 4f34: 5a 00 4f ea */ jmp         @LBL_4FEA:24
LBL_4F38:
    /* 4f38: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 4f3c: 47 e4       */ beq         LBL_4F22
    /* 4f3e: 40 0a       */ bra         LBL_4F4A
LBL_4F40:
    /* 4f40: 5e 00 45 c8 */ jsr         @FUNC_45C8:24
    /* 4f44: 44 04       */ bcc         LBL_4F4A
    /* 4f46: 5a 00 4f de */ jmp         @LBL_4FDE:24
LBL_4F4A:
    /* 4f4a: f0 b4       */ mov.b       #0xb4,r0h
    /* 4f4c: f8 05       */ mov.b       #0x5,r0l
    /* 4f4e: 6b 80 fd 92 */ mov.w       r0,@DAT_FD92:16
LBL_4F52:
    /* 4f52: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_4F56:
    /* 4f56: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 4f5a: 46 fa       */ bne         LBL_4F56
    /* 4f5c: 6a 00 80 1b */ mov.b       @DAT_801B:16,r0h
    /* 4f60: e0 07       */ and.b       #0x7,r0h
    /* 4f62: a0 03       */ cmp.b       #0x3,r0h
    /* 4f64: 46 20       */ bne         LBL_4F86
    /* 4f66: 6b 00 80 0a */ mov.w       @DAT_800A:16,r0
    /* 4f6a: 73 70       */ btst        #0x7,r0h
    /* 4f6c: 46 18       */ bne         LBL_4F86
    /* 4f6e: e0 07       */ and.b       #0x7,r0h
    /* 4f70: 79 03 07 04 */ mov.w       #0x704,r3
    /* 4f74: 1d 30       */ cmp.w       r3,r0
    /* 4f76: 46 0e       */ bne         LBL_4F86
    /* 4f78: 6a 00 fd 93 */ mov.b       @DAT_FD93:16,r0h
    /* 4f7c: 1a 00       */ dec.b       r0h
    /* 4f7e: 6a 80 fd 93 */ mov.b       r0h,@DAT_FD93:16
    /* 4f82: 46 08       */ bne         LBL_4F8C
    /* 4f84: 40 26       */ bra         LBL_4FAC
LBL_4F86:
    /* 4f86: f0 05       */ mov.b       #0x5,r0h
    /* 4f88: 6a 80 fd 93 */ mov.b       r0h,@DAT_FD93:16
LBL_4F8C:
    /* 4f8c: 6a 00 fd 92 */ mov.b       @DAT_FD92:16,r0h
    /* 4f90: 1a 00       */ dec.b       r0h
    /* 4f92: 6a 80 fd 92 */ mov.b       r0h,@DAT_FD92:16
    /* 4f96: 46 ba       */ bne         LBL_4F52
    /* 4f98: 7e b3 73 70 */ btst        #0x7,@REG_P2DR:8
    /* 4f9c: 46 40       */ bne         LBL_4FDE
    /* 4f9e: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 4fa2: 46 3a       */ bne         LBL_4FDE
    /* 4fa4: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 4fa8: 47 34       */ beq         LBL_4FDE
    /* 4faa: 40 5a       */ bra         LBL_5006
LBL_4FAC:
    /* 4fac: 79 00 01 00 */ mov.w       #0x100,r0
    /* 4fb0: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4fb4: 5e 00 0b 2c */ jsr         @FUNC_0B2C:24
LBL_4FB8:
    /* 4fb8: 7e 03 73 30 */ btst        #0x3,@DAT_FF03:8
    /* 4fbc: 46 14       */ bne         LBL_4FD2
    /* 4fbe: 7e 03 73 40 */ btst        #0x4,@DAT_FF03:8
    /* 4fc2: 46 0e       */ bne         LBL_4FD2
    /* 4fc4: 7e 03 73 10 */ btst        #0x1,@DAT_FF03:8
    /* 4fc8: 46 20       */ bne         LBL_4FEA
    /* 4fca: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 4fce: 47 e8       */ beq         LBL_4FB8
    /* 4fd0: 40 08       */ bra         LBL_4FDA
LBL_4FD2:
    /* 4fd2: 5e 00 45 c8 */ jsr         @FUNC_45C8:24
    /* 4fd6: 44 02       */ bcc         LBL_4FDA
    /* 4fd8: 40 04       */ bra         LBL_4FDE
LBL_4FDA:
    /* 4fda: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 4fdc: 54 70       */ rts
LBL_4FDE:
    /* 4fde: 79 00 01 00 */ mov.w       #0x100,r0
    /* 4fe2: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4fe6: 04 01       */ orc         #CCR_C,ccr
    /* 4fe8: 54 70       */ rts
LBL_4FEA:
    /* 4fea: 79 00 01 00 */ mov.w       #0x100,r0
    /* 4fee: 6b 80 fd 88 */ mov.w       r0,@DAT_FD88:16
    /* 4ff2: 79 01 80 04 */ mov.w       #REG_ASIC_STATUS,r1
    /* 4ff6: 7d 10 72 00 */ bclr        #ASIC_STATUS_DISK_PRESENT,@r1
    /* 4ffa: 7f 0e 70 70 */ bset        #0x7,@DAT_FF0E:8
    /* 4ffe: 5e 00 4d 92 */ jsr         @FUNC_4D92:24
    /* 5002: 04 01       */ orc         #CCR_C,ccr
    /* 5004: 54 70       */ rts
LBL_5006:
    /* 5006: 04 80       */ orc         #CCR_I,ccr
    /* 5008: 5e 00 4b ac */ jsr         @FUNC_4BAC:24
    /* 500c: 7f bb 72 00 */ bclr        #0x0,@REG_P6DR:8
    /* 5010: f0 02       */ mov.b       #0x2,r0h
    /* 5012: 5a 00 51 00 */ jmp         @FUNC_5100:24

glabel FUNC_5016
    /* 5016: f0 b4       */ mov.b       #0xb4,r0h
    /* 5018: 79 01 fc 08 */ mov.w       #DAT_FC08,r1
    /* 501c: 79 03 ff ff */ mov.w       #0xffff,r3
LBL_5020:
    /* 5020: 69 93       */ mov.w       r3,@r1
    /* 5022: 0b 81       */ adds        #2,r1
    /* 5024: 1a 00       */ dec.b       r0h
    /* 5026: 46 f8       */ bne         LBL_5020
    /* 5028: 54 70       */ rts

glabel FUNC_502A
    /* 502a: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
    /* 502e: 79 01 ff ff */ mov.w       #0xffff,r1
LBL_5032:
    /* 5032: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 5036: 47 08       */ beq         LBL_5040
    /* 5038: 19 41       */ sub.w       r4,r1
    /* 503a: 46 f6       */ bne         LBL_5032
    /* 503c: 5a 00 50 68 */ jmp         @LBL_5068:24
LBL_5040:
    /* 5040: 7e bb 73 00 */ btst        #0x0,@REG_P6DR:8
    /* 5044: 47 22       */ beq         LBL_5068
    /* 5046: 7e 0d 73 00 */ btst        #0x0,@DAT_FF0D:8
    /* 504a: 46 1c       */ bne         LBL_5068
    /* 504c: f0 ff       */ mov.b       #0xff,r0h
    /* 504e: 30 25       */ mov.b       r0h,@DAT_FF25:8
LBL_5050:
    /* 5050: 7f 03 70 20 */ bset        #0x2,@DAT_FF03:8
LBL_5054:
    /* 5054: 7e 03 73 20 */ btst        #0x2,@DAT_FF03:8
    /* 5058: 46 fa       */ bne         LBL_5054
    /* 505a: 7e 00 73 50 */ btst        #0x5,@DAT_FF00:8
    /* 505e: 46 0c       */ bne         LBL_506C
    /* 5060: 20 25       */ mov.b       @DAT_FF25:8,r0h
    /* 5062: 1a 00       */ dec.b       r0h
    /* 5064: 30 25       */ mov.b       r0h,@DAT_FF25:8
    /* 5066: 46 e8       */ bne         LBL_5050
LBL_5068:
    /* 5068: 04 01       */ orc         #CCR_C,ccr
    /* 506a: 54 70       */ rts
LBL_506C:
    /* 506c: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 506e: 54 70       */ rts

glabel FUNC_5070
    /* 5070: 6b 00 ff 92 */ mov.w       @REG_FRC:16,r0
    /* 5074: 6b 80 fd f4 */ mov.w       r0,@DAT_FDF4:16
    /* 5078: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
LBL_507C:
    /* 507c: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 5080: 46 16       */ bne         LBL_5098
    /* 5082: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3
    /* 5086: 6b 00 fd f4 */ mov.w       @DAT_FDF4:16,r0
    /* 508a: 19 03       */ sub.w       r0,r3
    /* 508c: 79 00 02 b5 */ mov.w       #0x2b5,r0
    /* 5090: 1d 03       */ cmp.w       r0,r3
    /* 5092: 45 e8       */ bcs         LBL_507C
    /* 5094: 5a 00 50 c0 */ jmp         @LBL_50C0:24
LBL_5098:
    /* 5098: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
    /* 509c: 6b 00 ff 9a */ mov.w       @REG_ICRB:16,r0
    /* 50a0: 6b 80 fd f4 */ mov.w       r0,@DAT_FDF4:16
LBL_50A4:
    /* 50a4: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 50a8: 46 52       */ bne         LBL_50FC
    /* 50aa: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3
    /* 50ae: 6b 00 fd f4 */ mov.w       @DAT_FDF4:16,r0
    /* 50b2: 19 03       */ sub.w       r0,r3
    /* 50b4: 79 00 02 b5 */ mov.w       #0x2b5,r0
    /* 50b8: 1d 03       */ cmp.w       r0,r3
    /* 50ba: 45 e8       */ bcs         LBL_50A4
    /* 50bc: 5a 00 50 c0 */ jmp         @LBL_50C0:24
LBL_50C0:
    /* 50c0: f0 37       */ mov.b       #0x37,r0h
    /* 50c2: 6a 80 fd f4 */ mov.b       r0h,@DAT_FDF4:16
    /* 50c6: 6b 03 ff 92 */ mov.w       @REG_FRC:16,r3
    /* 50ca: 79 00 93 a8 */ mov.w       #0x93a8,r0
    /* 50ce: 09 30       */ add.w       r3,r0
    /* 50d0: 6b 80 ff 94 */ mov.w       r0,@REG_OCR:16
    /* 50d4: 7f 91 72 30 */ bclr        #0x3,@REG_TCSR:8
    /* 50d8: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
LBL_50DC:
    /* 50dc: 7e 91 73 60 */ btst        #0x6,@REG_TCSR:8
    /* 50e0: 47 10       */ beq         LBL_50F2
    /* 50e2: 7f 91 72 60 */ bclr        #0x6,@REG_TCSR:8
    /* 50e6: 6a 00 fd f4 */ mov.b       @DAT_FDF4:16,r0h
    /* 50ea: 1a 00       */ dec.b       r0h
    /* 50ec: 6a 80 fd f4 */ mov.b       r0h,@DAT_FDF4:16
    /* 50f0: 47 0a       */ beq         LBL_50FC
LBL_50F2:
    /* 50f2: 7e 91 73 30 */ btst        #0x3,@REG_TCSR:8
    /* 50f6: 47 e4       */ beq         LBL_50DC
    /* 50f8: 04 01       */ orc         #CCR_C,ccr
    /* 50fa: 54 70       */ rts
LBL_50FC:
    /* 50fc: 06 fe       */ andc        #(~CCR_C & 0xFF),ccr
    /* 50fe: 54 70       */ rts

glabel FUNC_5100
    /* 5100: 6a 80 fd 93 */ mov.b       r0h,@DAT_FD93:16
LBL_5104:
    /* 5104: 6a 00 fd 93 */ mov.b       @DAT_FD93:16,r0h
    /* 5108: 6a 80 fd 92 */ mov.b       r0h,@DAT_FD92:16
LBL_510C:
    /* 510c: 7f bb 70 10 */ bset        #0x1,@REG_P6DR:8
    /* 5110: 5e 00 47 22 */ jsr         @FUNC_4722:24
    /* 5114: 7f bb 72 10 */ bclr        #0x1,@REG_P6DR:8
    /* 5118: 5e 00 47 22 */ jsr         @FUNC_4722:24
    /* 511c: 6a 00 fd 92 */ mov.b       @DAT_FD92:16,r0h
    /* 5120: 1a 00       */ dec.b       r0h
    /* 5122: 6a 80 fd 92 */ mov.b       r0h,@DAT_FD92:16
    /* 5126: 46 e4       */ bne         LBL_510C
    /* 5128: 79 01 00 14 */ mov.w       #0x14,r1
    /* 512c: 5e 00 47 3c */ jsr         @FUNC_473C:24
    /* 5130: 5a 00 51 04 */ jmp         @LBL_5104:24



.fill (0x6000 - 0x5134), 1, 0xFF



glabel DAT_6000
    /* 6000 */  .word 0x6660
glabel DAT_6002
    /* 6002 */  .word 0x5c56
    /* 6004 */  .word 0x5049
    /* 6006 */  .word 0x433d
    /* 6008 */  .word 0x3727
    /* 600a */  .word 0x1f1f
    /* 600c */  .word 0x1f1f
    /* 600e */  .word 0x1f67
    /* 6010 */  .word 0x5f57
    /* 6012 */  .word 0x1010
    /* 6014 */  .word 0x1010
    /* 6016 */  .word 0x1010
    /* 6018 */  .word 0x1010
    /* 601a */  .word 0x1017
    /* 601c */  .word 0x1717
    /* 601e */  .word 0x1a19
    /* 6020 */  .word 0x1919
    /* 6022 */  .word 0x1818
    /* 6024 */  .word 0x100e
    /* 6026 */  .word 0x0e0e
    /* 6028 */  .word 0x0d0e
    /* 602a */  .word 0x0e0f
    /* 602c */  .word 0x0f5f
    /* 602e */  .word 0x5f5f
    /* 6030 */  .word 0x5f5f
    /* 6032 */  .word 0x5e5e
    /* 6034 */  .word 0x5e5e
    /* 6036 */  .word 0x5656
    /* 6038 */  .word 0x5656
    /* 603a */  .word 0x5656
    /* 603c */  .word 0x5656
    /* 603e */  .word 0x5616
    /* 6040 */  .word 0x1414
    /* 6042 */  .word 0x1310
    /* 6044 */  .word 0x0f0e
    /* 6046 */  .word 0x0d0d
    /* 6048 */  .word 0x0d0d
    /* 604a */  .word 0x0d0d
    /* 604c */  .word 0x0d0d
    /* 604e */  .word 0x0d0d
    /* 6050 */  .word 0x0d65
    /* 6052 */  .word 0x6565
    /* 6054 */  .word 0x6464
    /* 6056 */  .word 0x6565
    /* 6058 */  .word 0x6563
    /* 605a */  .word 0x0000
    /* 605c */  .word 0x0000
    /* 605e */  .word 0x0000
    /* 6060 */  .word 0x0000
    /* 6062 */  .word 0x0000
    /* 6064 */  .word 0x0000
    /* 6066 */  .word 0x0000
    /* 6068 */  .word 0x0000
    /* 606a */  .word 0x0000
    /* 606c */  .word 0xa6a6
    /* 606e */  .word 0x96a5
    /* 6070 */  .word 0x9696
    /* 6072 */  .word 0x96a6
    /* 6074 */  .word 0xa740
    /* 6076 */  .word 0x4040
    /* 6078 */  .word 0x4040
    /* 607a */  .word 0x4040
    /* 607c */  .word 0x4040
    /* 607e */  .word 0x0909
    /* 6080 */  .word 0x0909
    /* 6082 */  .word 0x0909
    /* 6084 */  .word 0x0909
    /* 6086 */  .word 0x09ff

glabel TBL_6088
    /* 6088 */  .word 0x347a
    /* 608a */  .word 0x6460
    /* 608c */  .word 0x8634
    /* 608e */  .word 0x40a7
    /* 6090 */  .word 0x2738
    /* 6092 */  .word 0x0600
    /* 6094 */  .word 0x09d7
    /* 6096 */  .word 0x85b3
glabel TBL_6088_END

glabel LBL_6098
    /* 6098 */  .word 0x009e
    /* 609a */  .word 0x013c
    /* 609c */  .word 0x01d1
    /* 609e */  .word 0x0266
    /* 60a0 */  .word 0x02fb
    /* 60a2 */  .word 0x0390
    /* 60a4 */  .word 0x0425
    /* 60a6 */  .word 0x2527
    /* 60a8 */  .word 0x2a2d
    /* 60aa */  .word 0x2f32
    /* 60ac */  .word 0x3537
    /* 60ae */  .word 0x3532
    /* 60b0 */  .word 0x312f
    /* 60b2 */  .word 0x2e2c
    /* 60b4 */  .word 0x2b2a
    /* 60b6 */  .word 0xc4bf
    /* 60b8 */  .word 0xb9b4
    /* 60ba */  .word 0xafa9
    /* 60bc */  .word 0xa49f
    /* 60be */  .word 0x100f
    /* 60c0 */  .word 0x0f0e
    /* 60c2 */  .word 0x0e0e
    /* 60c4 */  .word 0x0f0f

glabel LBL_60C6
    /* 60c6 */  .word 0xbebe
    /* 60c8 */  .word 0xbebe
    /* 60ca */  .word 0xbebe
    /* 60cc */  .word 0xbebe
    /* 60ce */  .word 0xbebe
    /* 60d0 */  .word 0xbebe
    /* 60d2 */  .word 0xbebe
    /* 60d4 */  .word 0xbebe



.fill (0x6200 - 0x60D6), 1, 0xFF



    .word 0x00E6, 0x012C, 0x0154, 0x0177
    .word 0x0154, 0x0154, 0x0154

glabel UNK_620E
    .word 0x0168
    .word 0x0003, 0x0004, 0x0006, 0x0009
    .word 0x000E, 0x0017, 0x0026, 0x003B
    .word 0x0057, 0x007D, 0x00B3, 0x00FE
    .word 0x0003, 0x0004, 0x0006, 0x0009
    .word 0x000E, 0x0017, 0x0026, 0x003B
    .word 0x0057, 0x007D, 0x00B3, 0x00FE

glabel FUNC_6240
    /* 6240: 0d 10       */ mov.w       r1,r0               // r0 = r1
    /* 6242: 79 02 00 38 */ mov.w       #0x38,r2            // r2 = 0x38
    /* 6246: 6b 82 fd d0 */ mov.w       r2,@DAT_FDD0:16     // *0xFDD0 = r2
    /* 624a: 7e 0c 73 40 */ btst        #0x4,@DAT_FF0C:8    // TEST 0x4 at 0x0C
    /* 624e: 46 14       */ bne         LBL_6264            // Branch if bit is set?
    /* 6250: 79 03 62 10 */ mov.w       #0x6210,r3
    /* 6254: 6b 83 fd bc */ mov.w       r3,@DAT_FDBC:16
    /* 6258: 6a 08 fd e8 */ mov.b       @DAT_FDE8:16,r0l
    /* 625c: 38 35       */ mov.b       r0l,@DAT_FF35:8
    /* 625e: f8 10       */ mov.b       #0x10,r0l
    /* 6260: 38 0f       */ mov.b       r0l,@DAT_FF0F:8
    /* 6262: 40 14       */ bra         LBL_6278
LBL_6264:
    /* 6264: 79 03 62 28 */ mov.w       #0x6228,r3
    /* 6268: 6b 83 fd bc */ mov.w       r3,@DAT_FDBC:16
    /* 626c: 6a 08 fd e8 */ mov.b       @DAT_FDE8:16,r0l
    /* 6270: 38 35       */ mov.b       r0l,@DAT_FF35:8
    /* 6272: f8 10       */ mov.b       #0x10,r0l
    /* 6274: 38 0f       */ mov.b       r0l,@DAT_FF0F:8
    /* 6276: 40 00       */ bra         LBL_6278
LBL_6278:
    /* 6278: 7e 0c 73 40 */ btst        #0x4,@DAT_FF0C:8
    /* 627c: 47 0a       */ beq         LBL_6288
    /* 627e: 79 00 00 80 */ mov.w       #0x80,r0
    /* 6282: 6b 80 fd b4 */ mov.w       r0,@DAT_FDB4:16
    /* 6286: 40 08       */ bra         LBL_6290
LBL_6288:
    /* 6288: 79 00 00 80 */ mov.w       #0x80,r0
    /* 628c: 6b 80 fd b4 */ mov.w       r0,@DAT_FDB4:16
LBL_6290:
    /* 6290: 0d 10       */ mov.w       r1,r0
    /* 6292: a0 00       */ cmp.b       #0x0,r0h
    /* 6294: 46 24       */ bne         LBL_62BA
    /* 6296: 88 f8       */ add.b       #0xf8,r0l
    /* 6298: 10 08       */ shll.b      r0l
    /* 629a: 12 00       */ rotxl.b     r0h
    /* 629c: 10 08       */ shll.b      r0l
    /* 629e: 12 00       */ rotxl.b     r0h
    /* 62a0: 10 08       */ shll.b      r0l
    /* 62a2: 12 00       */ rotxl.b     r0h
    /* 62a4: 10 08       */ shll.b      r0l
    /* 62a6: 12 00       */ rotxl.b     r0h
    /* 62a8: 6b 03 62 0e */ mov.w       @UNK_620E:16,r3
    /* 62ac: 09 30       */ add.w       r3,r0
    /* 62ae: 6b 03 fd b4 */ mov.w       @DAT_FDB4:16,r3
    /* 62b2: 1d 30       */ cmp.w       r3,r0
    /* 62b4: 42 04       */ bhi         LBL_62BA
    /* 62b6: 6b 80 fd b4 */ mov.w       r0,@DAT_FDB4:16
LBL_62BA:
    /* 62ba: 54 70       */ rts



/* probably padded with dd or ld */
.fill (0x8000 - 0x62BC), 1, 0xFF



.bss

######################### External Mem (1)

REG_ASIC_DATA: // BW    The upper 16 bits of ASIC_DATA
    .skip 0x2

REG_ASIC_CMD: // W      The upper 16 bits of ASIC_CMD
    .skip 0x2

REG_ASIC_STATUS: // I   The upper 16 bits of ASIC_STATUS
    .skip 0x2

DAT_8006: // I  read-only
    .skip 0x1
DAT_8007: // B  read-only
    .skip 0x1

DAT_8008: //    Unused?
    .skip 0x1
DAT_8009: // B  read-only
    .skip 0x1

DAT_800A: // BW  read-only
    .skip 0x2

DAT_800C: //    Unused?
    .skip 0x1
DAT_800D: // B  write-only
    .skip 0x1

DAT_800E: // B  read-only
    .skip 0x1
DAT_800F: // B  r/w
    .skip 0x1

DAT_8010: // W  write-only, over 0x10 bytes?
    .skip 0x8

DAT_8018: // b  write-only?
    .skip 0x1
DAT_8019: // B  write-only?
    .skip 0x1

DAT_801A: //    Unused?
    .skip 0x1
DAT_801B: // b  read-only
    .skip 0x1

DAT_801C: //    Unused?
    .skip 0x2

DAT_801E: // b  r/w
    .skip 0x1
DAT_801F: //    Unused?
    .skip 0x1

######################### Internal RAM
.skip 0xFB80 - 0x8020

RAM_START:

DAT_FB80: // B
    .skip 0x7E

DAT_FBFE: // B
    .skip 0xA

DAT_FC08: // B
    .skip 0x178

DAT_FD80: // W
    .skip 0x2

DAT_FD82: // W
    .skip 0x2

DAT_FD84: // W
    .skip 0x2

DAT_FD86: // W
    .skip 0x2

DAT_FD88: // W
    .skip 0x2

DAT_FD8A: // W
    .skip 0x2

DAT_FD8C: // W
    .skip 0x2

DAT_FD8E: // W
    .skip 0x2

DAT_FD90: // W
    .skip 0x2

DAT_FD92: // BW
    .skip 0x1
DAT_FD93: // B
    .skip 0x1

DAT_FD94: // BW
    .skip 0x1
DAT_FD95: // B
    .skip 0x1

DAT_FD96: // B
    .skip 0x8

DAT_FD9E: // W
    .skip 0x2

DEBUG_MEMADDR: // W
    .skip 0x4

DAT_FDA4: // W
    .skip 0x2

DAT_FDA6: // W
    .skip 0x2

DAT_FDA8: // W
    .skip 0x4

DAT_FDAC: // W
    .skip 0x2

DAT_FDAE: // W
    .skip 0x2

DAT_FDB0: // W
    .skip 0x2

DAT_FDB2: // W
    .skip 0x2

DAT_FDB4: // W
    .skip 0x2

DAT_FDB6: // W
    .skip 0x2

DAT_FDB8: // W
    .skip 0x2

DAT_FDBA: // W
    .skip 0x2

DAT_FDBC: // W
    .skip 0x2

DAT_FDBE: // W
    .skip 0x2

DAT_FDC0: // B
    .skip 0xA

DAT_FDCA: // W
    .skip 0x2

DAT_FDCC: // W
    .skip 0x2

DAT_FDCE: // W
    .skip 0x2

DAT_FDD0: // W
    .skip 0x2

DAT_FDD2: // W
    .skip 0x4

DAT_FDD6: // W
    .skip 0x2

DAT_FDD8: // W
    .skip 0x2

DAT_FDDA: // W
    .skip 0x4

DAT_FDDE: // W
    .skip 0x2

DAT_FDE0: // B
    .skip 0x1

DAT_FDE1: // B
    .skip 0x1

DAT_FDE2: // B
    .skip 0x1

DAT_FDE3: // B
    .skip 0x1

DAT_FDE4: // B
    .skip 0x1

DAT_FDE5: // B
    .skip 0x1

DAT_FDE6: // B
    .skip 0x1

DAT_FDE7: // B
    .skip 0x1

DAT_FDE8: // B
    .skip 0x1

DAT_FDE9: // B
    .skip 0x1

DAT_FDEA: // B
    .skip 0x1

DAT_FDEB: // B
    .skip 0x7

DAT_FDF2: // W
    .skip 0x2

DAT_FDF4: // BW
    .skip 0x8

DAT_FDFC: // W
    .skip 0x2

DAT_FDFE: // W
    .skip 0x6

DAT_FE04: // W
    .skip 0x2

DAT_FE06: // W
    .skip 0x2

DAT_FE08: // W
    .skip 0x2

DAT_FE0A: // B
    .skip 0x1

DAT_FE0B: // B
    .skip 0x1

DAT_FE0C: // W
    .skip 0x2

DAT_FE0E: // W
    .skip 0x2

DAT_FE10: // W
    .skip 0x2

DAT_FE12: // W
    .skip 0x2

DAT_FE14: // B
    .skip 0x1

DAT_FE15: // B
    .skip 0x1

DAT_FE16: // B
    .skip 0x1

DAT_FE17: // B
    .skip 0x1

DAT_FE18: // B
    .skip 0x2

RTC_YEAR: // BW
    .skip 0x1
RTC_MONTH: // B
    .skip 0x1

RTC_DAY: // BW
    .skip 0x1
RTC_HOUR: // B
    .skip 0x1

RTC_MINUTE: // BW
    .skip 0x1
RTC_SECOND: // B
    .skip 0x1

DAT_FE20: // B
    .skip 0x2

DAT_FE22: // B
    .skip 0x2

DAT_FE24: // B
    .skip 0x1

DAT_FE25: // B
    .skip 0x1

DAT_FE26: // B
    .skip 0x1

DAT_FE27: // B
    .skip 0x1

DAT_FE28: // B
    .skip 0x2

DAT_FE2A: // W
    .skip 0x2

DAT_FE2C: // W
    .skip 0x2

DAT_FE2E: // W
    .skip 0x2

DAT_FE30: // W
    .skip 0x2

DAT_FE32: // W
    .skip 0x2

DAT_FE34: // W
    .skip 0x2

DAT_FE36: // W
    .skip 0x2

DAT_FE38: // W
    .skip 0x2

DAT_FE3A: // B
    .skip 0x1

DAT_FE3B: // B
    .skip 0x1

DAT_FE3C: // B
    .skip 0x1

DAT_FE3D: // B
    .skip 0xC3

DAT_FF00: // Bb
    .skip 0x1

DAT_FF01: // b
    .skip 0x2

DAT_FF03: // Bb
    .skip 0x1

DAT_FF04: // Bb
    .skip 0x1

DAT_FF05: // B
    .skip 0x1

DAT_FF06: // Bb
    .skip 0x1

DAT_FF07: // Bb
    .skip 0x1

DAT_FF08: // Bb
    .skip 0x2

ERROR_STATUS: // BW
    .skip 0x2

DAT_FF0C: // Bb
    .skip 0x1

DAT_FF0D: // b
    .skip 0x1

DAT_FF0E: // Bb
    .skip 0x1

DAT_FF0F: // Bb
    .skip 0x1

DAT_FF10: // b
    .skip 0x1

DAT_FF11: // b
    .skip 0x2

DAT_FF13: // B
    .skip 0x1

DAT_FF14: // B
    .skip 0x1

DAT_FF15: // B
    .skip 0x1

DAT_FF16: // B
    .skip 0x1

DAT_FF17: // B
    .skip 0x1

DAT_FF18: // B
    .skip 0x1

DAT_FF19: // B
    .skip 0x1

DAT_FF1A: // B
    .skip 0x1

DAT_FF1B: // B
    .skip 0x1

DAT_FF1C: // B
    .skip 0x1

DAT_FF1D: // B
    .skip 0x1

DAT_FF1E: // B
    .skip 0x1

DAT_FF1F: // B
    .skip 0x1

DAT_FF20: // B
    .skip 0x3

DAT_FF23: // B
    .skip 0x2

DAT_FF25: // B
    .skip 0x3

DAT_FF28: // B
    .skip 0x2

DAT_FF2A: // B
    .skip 0x1

DAT_FF2B: // B
    .skip 0x1

DAT_FF2C: // BW
    .skip 0x3

DAT_FF2F: // B
    .skip 0x1

DAT_FF30: // B
    .skip 0x1

DAT_FF31: // B
    .skip 0x1

DAT_FF32: // B
    .skip 0x1

DAT_FF33: // B
    .skip 0x1

DAT_FF34: // B
    .skip 0x1

DAT_FF35: // B
    .skip 0x1

DAT_FF36: // B
    .skip 0x1

DAT_FF37: // B
    .skip 0x1

DAT_FF38: // B
    .skip 0x1

DAT_FF39: // B
    .skip 0x1

DAT_FF3A: // B
    .skip 0x2

DAT_FF3C: // B
    .skip 0x2

DAT_FF3E: // B
    .skip 0x2

DAT_FF40: // B
    .skip 0x1

DAT_FF41: // B
    .skip 0x1

DAT_FF42: // Bb
    .skip 0x1

DAT_FF43: // B
    .skip 0x1

DAT_FF44: // B
    .skip 0x1

DAT_FF45: // B
    .skip 0x2

DAT_FF47: // B
    .skip 0x1

DAT_FF48: // B
    .skip 0x2

DEBUG_EN_FLAGS: // b
    .skip 0x1

DAT_FF4B: // B
    .skip 0x1

DAT_FF4C: // BW
    .skip 0x2

DAT_FF4E: // BW
    .skip 0x2

DAT_FF50: // BW
    .skip 0x2

DAT_FF52: // W
    .skip 0x2

DAT_FF54: // W
    .skip 0x2

DAT_FF56: // B
    .skip 0x2

DAT_FF58: // W
    .skip 0x2

DAT_FF5A: // W
    .skip 0x2

DAT_FF5C: // BW
    .skip 0x2

DAT_FF5E: // W
    .skip 0x2

DAT_FF60: // W
    .skip 0x2

DAT_FF62: // B
    .skip 0x4

DAT_FF66: // B
    .skip 0x2

DAT_FF68:
    .skip 0x8

DAT_FF70: // B
    .skip 0x6

DAT_FF76: // B
    .skip 0x4

DAT_FF7A: // B
    .skip 0x4

DAT_FF7E: // B
    .skip 0x2

RAM_END:

######################### External Mem (2)

DAT_FF80:
    .skip 0x8

######################### Registers

DAT_FF88:
    .skip 0x8

REG_TIER: // Timers: Timer Interrupt Enable
    .skip 0x1

REG_TCSR: // Timers: Timer Control/Status
    .skip 0x1

REG_FRC: // Timers: Free-Running Counter
    .skip 0x2

REG_OCR: // Timers: Output Compare A/B
    .skip 0x2

REG_TCR: // Timers: Timer Control
    .skip 0x1

REG_TOCR: // Timers: Timer Output Compare Control
    .skip 0x1

REG_ICRA: // Timers: Input Capture A
    .skip 0x2

REG_ICRB: // Timers: Input Capture B
    .skip 0x2

REG_ICRC: // Timers: Input Capture C
    .skip 0x2

REG_ICRD: // Timers: Input Capture D
    .skip 0x2

DAT_FFA0: // Unused
    .skip 0xC

REG_P1PCR: // Port 1 Pull-up Control
    .skip 0x1
REG_P2PCR: // Port 2 Pull-up Control
    .skip 0x1
REG_P3PCR: // Port 3 Pull-up Control
    .skip 0x1
           // Nothing?
    .skip 0x1

REG_P1DDR: // Port 1 Data Direction
    .skip 0x1
REG_P2DDR: // Port 2 Data Direction
    .skip 0x1

REG_P1DR: // Port 1 Data
    .skip 0x1

REG_P2DR: // Port 2 Data
    .skip 0x1

REG_P3DDR: // Port 3 Data Direction
    .skip 0x1

REG_P4DDR: // Port 4 Data Direction
    .skip 0x1

REG_P3DR: // Port 3 Data
    .skip 0x1

REG_P4DR: // Port 4 Data
    .skip 0x1

REG_P5DDR: // Port 5 Data Direction
    .skip 0x1

REG_P6DDR: // Port 6 Data Direction
    .skip 0x1

REG_P5DR: // Port 5 Data
    .skip 0x1

REG_P6DR: // Port 6 Data
    .skip 0x1

DAT_FFBC: // Unused
    .skip 0x2

REG_P7PIN: // Port 7 Input
    .skip 0x2

DAT_FFC0: // Unused
    .skip 0x2

REG_WSCR: // Wait-State Control
    .skip 0x1

DA_STCR: // 8-bit Timer: Serial/Timer Control
    .skip 0x1

REG_SYSCR: // System Control
    .skip 0x1

REG_MDCR: // Mode Control
    .skip 0x1

REG_ISCR: // IRQ Sense Control
    .skip 0x1

REG_IER: // IRQ Enable
    .skip 0x1

REG_8TCR0: // 8-bit Timer (Channel 0): Timer Control
    .skip 0x1

REG_8TCSR0: // 8-bit Timer (Channel 0): Timer Control/Status
    .skip 0x1

REG_8TCORA0: // 8-bit Timer (Channel 0): Time Constant Register A
    .skip 0x1

REG_8TCORB0: // 8-bit Timer (Channel 0): Time Constant Register B
    .skip 0x1

REG_8TCNT0: // 8-bit Timer (Channel 0): Timer Counter
    .skip 0x4

REG_8TCR1: // 8-bit Timer (Channel 1): Timer Control
    .skip 0x1

REG_8TCSR1: // 8-bit Timer: (Channel 1): Timer Control/Status
    .skip 0x1

REG_8TCORA1: // 8-bit Timer: (Channel 1): Time Constant Register A
    .skip 0x1

REG_8TCORB1: // 8-bit Timer: (Channel 1): Time Constant Register B
    .skip 0x1

REG_8TCNT1: // 8-bit Timer: (Channel 1): Timer Counter
    .skip 0x1

DAT_FFD5: // Unused
    .skip 0xB

REG_ADDRA: // A/D Converter: A/D data register A
    .skip 0x2

REG_ADDRB: // A/D Converter: A/D data register B
    .skip 0x2

REG_ADDRC: // A/D Converter: A/D data register C
    .skip 0x2

REG_ADDRD: // A/D Converter: A/D data register D
    .skip 0x2

REG_ADCSR: // A/D Converter: A/D control/status
    .skip 0x2

DAT_FFEA: // ?
    .skip 0x16
