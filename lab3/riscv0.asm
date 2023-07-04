# 设置前两项
.data
1 # a1 in 0x0000
1 # a2 in 0x0004
.text
# 输入
addi t0 x0 20 # Store n=5 in reg t0
addi t1, x0, 8 # t1做存储指针

# 计算
lw t2, 0  # f(n-2)
lw t3, 4  # f(n-1)
addi t0, t0, -2
loop: add t4, t2, t3 # f(n)
addi t2, t3, 0
addi t3, t4, 0

# 存储
sw t4, 0(t1) # save f(n)
addi t1, t1, 4 # 指向下个储存位置
addi t0, t0, -1 # n--
blt x0, t0, loop
done: #结束程序