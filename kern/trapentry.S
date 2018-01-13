/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(DivideError,T_DIVIDE)
TRAPHANDLER_NOEC(DebugExceptions,T_DEBUG)
TRAPHANDLER_NOEC(NonMaskableInterrupt,T_NMI)
TRAPHANDLER_NOEC(Brkpt,T_BRKPT)
TRAPHANDLER_NOEC(Overflow,T_OFLOW)
TRAPHANDLER_NOEC(BoundsCheck,T_BOUND)
TRAPHANDLER_NOEC(InvalidOpcode,T_ILLOP)
TRAPHANDLER_NOEC(CoprocessorNotAvailable,T_DEVICE)
TRAPHANDLER(DoubleFault,T_DBLFLT)
TRAPHANDLER(InvalidTSS,T_TSS)
TRAPHANDLER(SegmentNotPresent,T_SEGNP)
TRAPHANDLER(StackException,T_STACK)
TRAPHANDLER(GeneralProtectionException,T_GPFLT)
TRAPHANDLER(PageFault,T_PGFLT)
TRAPHANDLER_NOEC(CoprocessorError,T_FPERR)
TRAPHANDLER_NOEC(AligmentCheck,T_ALIGN)
TRAPHANDLER_NOEC(MachineCheck,T_MCHK)
TRAPHANDLER_NOEC(SIMD_FloatingPointError,T_SIMDERR)
TRAPHANDLER_NOEC(SysCall,T_SYSCALL)

/*
 * Lab 3: Your code here for _alltraps
 */
 /* 宏定义的函数中将SS 寄存器到 EIP 寄存器包括error code压入栈中
  所以这里只需要根据trapfram结构，倒序 push 余下的寄存器
  pushal 指令会按顺序将 eax 到 edi 压入栈中
  call 之后的指令是当 call trap 失败时可以还原相关寄存器
  如果没有失败，处理程序在env_pop_tf中做pop操作*/
_alltraps:
	pushl %ds
	pushl %es
	pushal 

	movl $GD_KD, %eax
	movw %ax, %ds
	movw %ax, %es

	push %esp
	call trap

