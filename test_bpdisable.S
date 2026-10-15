.option norvc
.option norelax

.section .text
.balign 4
.global _start
_start:
    # Any exception makes the test fail.
    la t0, fail
    csrw mtvec, t0

    li t1, 0
    li t2, 16

warmup:
    addi t1, t1, 1
    blt t1, t2, warmup

    # BPDISABLE: 0x0000500b
    .word 0x0000500b

    # This branch must be taken.
    beq t1, t2, after_branch
    j fail

after_branch:
    addi t1, t1, 1
    li t2, 17
    bne t1, t2, fail

    # Allow time for the disable window to expire.
    .rept 32
    nop
    .endr

pass:
    la t0, tohost
    li t1, 1
    sd t1, 0(t0)
    j halt

.balign 4
fail:
    csrr s0, mcause
    csrr s1, mepc
    csrr s2, mtval

    la t0, tohost
    li t1, 3
    sd t1, 0(t0)

halt:
    j halt

.section .tohost,"aw",@progbits
.balign 64
.global tohost
tohost:
    .dword 0

.balign 64
.global fromhost
fromhost:
    .dword 0
