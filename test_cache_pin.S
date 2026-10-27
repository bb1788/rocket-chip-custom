.option norvc
.option norelax

.section .text
.balign 4
.global _start

_start:
    # Any exception goes to the failure handler.
    la t0, fail
    csrw mtvec, t0

    # Addresses of the two test objects.
    la s0, pinned_data
    la s1, normal_data

    # Write different values, making both cache lines dirty.
    li t0, 0x111
    sd t0, 0(s0)

    li t0, 0x222
    sd t0, 0(s1)

    fence rw, rw

    # CFLUSH_D_L1 with rs1 = x0: full DCache flush.
    .word 0xfc000073

    fence rw, rw

    # Both values must still be correct after the flush.
    ld t0, 0(s0)
    li t1, 0x111
    bne t0, t1, fail

    ld t0, 0(s1)
    li t1, 0x222
    bne t0, t1, fail

pass:
    la t0, tohost
    li t1, 1
    sd t1, 0(t0)
    fence rw, rw
    j halt

.balign 4
fail:
    # Keep exception information for later debugging.
    csrr s2, mcause
    csrr s3, mepc
    csrr s4, mtval

    la t0, tohost
    li t1, 3
    sd t1, 0(t0)
    fence rw, rw

halt:
    j halt

.section .pin_data, "aw", @progbits
.balign 64
pinned_data:
    .dword 0

.section .normal_data, "aw", @progbits
.balign 64
normal_data:
    .dword 0

.section .tohost, "aw", @progbits
.balign 64
.global tohost
tohost:
    .dword 0

.balign 64
.global fromhost
fromhost:
    .dword 0