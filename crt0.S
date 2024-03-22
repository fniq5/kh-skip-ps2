.set noat
.set noreorder
.text 
.align 2
.globl _start
_start:
  la $t0, _fbss
  la $t1, _end

1:
  sltu $at, $t0, $t1
  beq $at, $zero, 2f
  nop
  sq $zero, ($t0)
  j 1b
  addiu $t0, $t0, 16
2:
  la $gp, _gp
  move $a0, $gp
  la $a1, _stack
  la $a2, _stack_size
  la $a3, _args
  la $t0, _root
  li $v1, 60
  syscall # SetupThread

  j CStart
  move $sp, $v0

_root:
  li $v1, 35
  syscall # ExitThread

.bss
.align 6
_args:
  .space 256

