	.file	"UpperCase.ll"
	.text
	.globl	upper_case
	.align	16, 0x90
	.type	upper_case,@function
upper_case:                             # @upper_case
	.cfi_startproc
# BB#0:                                 # %entry
	movl	$0, -4(%rsp)
	jmp	.LBB0_1
	.align	16, 0x90
.LBB0_5:                                # %incre
                                        #   in Loop: Header=BB0_1 Depth=1
	incl	%eax
	movl	%eax, -4(%rsp)
.LBB0_1:                                # %loop
                                        # =>This Inner Loop Header: Depth=1
	movslq	-4(%rsp), %rax
	movb	(%rdi,%rax), %cl
	testb	%cl, %cl
	je	.LBB0_6
# BB#2:                                 # %cond1
                                        #   in Loop: Header=BB0_1 Depth=1
	cmpb	$97, %cl
	jl	.LBB0_5
# BB#3:                                 # %cond2
                                        #   in Loop: Header=BB0_1 Depth=1
	cmpb	$122, %cl
	jg	.LBB0_5
# BB#4:                                 # %rep
                                        #   in Loop: Header=BB0_1 Depth=1
	addb	$-32, %cl
	movb	%cl, (%rdi,%rax)
	jmp	.LBB0_5
.LBB0_6:                                # %end
	ret
.Ltmp0:
	.size	upper_case, .Ltmp0-upper_case
	.cfi_endproc


	.section	".note.GNU-stack","",@progbits
