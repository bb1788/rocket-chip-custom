.global _start
.section .text
_start:
    # 1. 准备输入数据
    li x10, 5            # rs1 = 5
    li x11, 3            # rs2 = 3

    # 2. 执行自定义指令 ADD2: x12 = x10 + (x11 << 1) = 5 + 6 = 11
    # 格式: .insn r opcode, func3, func7, rd, rs1, rs2
    .insn r 0x0B, 1, 0, x12, x10, x11

    # 3. 验证计算结果是否等于 11
    li x13, 11
    bne x12, x13, fail

pass:
    # 测试通过：向 tohost 写入 1 (按照规范: (result << 1) | 1 => (0<<1)|1 = 1)
    la x14, tohost
    li x15, 1
    sd x15, 0(x14)
    j 1f

fail:
    # 测试失败：向 tohost 写入 3
    la x14, tohost
    li x15, 3
    sd x15, 0(x14)

1:
    j 1b

.section .data
.align 6
.global tohost
tohost:
    .dword 0
.global fromhost
fromhost:
    .dword 0