// 显式声明符号，供仿真器前端服务（dtm）通信使用
volatile unsigned long tohost __attribute__((aligned(64))) = 0;
volatile unsigned long fromhost __attribute__((aligned(64))) = 0;

int main() {
    long a = 5;
    long b = 3;
    long result;

    // 使用自定义 ADD2 指令: result = 5 + (3 << 1) = 11
    asm volatile (
        ".insn r 0x0B, 1, 0, %0, %1, %2"
        : "=r" (result)
        : "r" (a), "r" (b)
    );

    // 将结果写入 tohost，通知仿真器测试结束并传递状态
    // 按照 Rocket Chip 规范：(result << 1) | 1 表示结束
    tohost = (result == 11) ? 1 : 3; // 1 代表 pass, 3 代表 fail

    while (1); // 结束后的死循环
}