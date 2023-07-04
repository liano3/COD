# 设置前两项
.data
0
1 # a1 in 0x0000
0
1 # a2 in 0x0004
.text
# 输入
addi t5, x0, 10
li t6, 0x7f0c
li s7, 0x80000000
jal scan
addi t1, a0, -48
jal scan
addi t2, a0, 0
beq t2, t5, entry1
addi t2, t2, -48
addi t3, x0, 9	# 循环控制
loop2: add t0, t0, t1
addi t3, t3, -1
bge t3, x0, loop2
add t0, t0, t2
jal scan
addi t3, a0, 0
beq t3, t5, entry
entry1: addi t0, t1, 0
entry: addi t1, x0, 16 # t1做存储指针
# 计算
lw t3, 0
lw t2, 4  # f(n-2)
addi a0, t2, 0
jal print
addi a0, x0, -38
jal print
lw s3, 8
lw s2, 12 # f(n-1)
addi a0, s2, 0
jal print
addi a0, x0, -38
jal print
addi t0, t0, -2
loop3: add s4, t2, s2 
add s5, t3, s3 # f(n)=f(n-1)+f(n-2)
and s6, t2, s7
beq s6, x0, noc1
and s6, s2, s7
beq s6, x0, noc2
carry: addi s5, s5, 1
jal next
noc1: and s6, s2, s7
beq s6, x0, next
noc2: and s6, s4, s7
beq s6, x0, carry
next: addi t2, s2, 0
addi t3, s3, 0
addi s2, s4, 0
addi s3, s5, 0
# 打印
addi s8, x0, 0
addi s0, x0, 0 # 左移位数
addi s1, x0, 28 # 右移位数
loop4: sll a0, s5, s0
srl a0, a0, s1
jal setflg
beq s8, x0, skip # 去除前导0
jal print
skip: addi s0, s0, 4
bge s1, s0, loop4
addi s0, x0, 0
addi s8, x0, 0
loop5: sll a0, s4, s0
srl a0, a0, s1
bne s5, x0, skip1
jal setflg
beq s8, x0, skip2 # 去除前导0
skip1: jal print
skip2: addi s0, s0, 4
bge s1, s0, loop5
addi a0, x0, -38
jal print
# 存储
sw s5, 0(t1) # save f(n)
addi t1, t1, 4 # 指向下个储存位置
sw s4, 0(t1)
addi t1, t1, 4
addi t0, t0, -1 # n--
blt x0, t0, loop3
jal done

# 读入函数
scan:
loop: lw a1, 0x7f00
beq a1, x0, loop
lw a0, 0x7f04
jalr x0, 0(x1)

# 输出函数(数字转ascii码)
print:
addi a1, a0, -10
addi a0, a0, 48
blt a1, x0, digit
addi a0, a0, 39
digit: sw a0, 0(t6)
jalr x0, 0(x1)

# 标识函数(去除前导0)
setflg:
bne s8, x0, return
beq a0, x0, return
addi s8, x0, 1
return: jalr x0, 0(x1)

done: #结束程序
