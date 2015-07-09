    .file   "conway.c"
    .text

.globl getValue
    .type   update, @function

getValue:
	pushl 	%ebp
	movl 	%esp, %ebp
	pushl	%ebx
	pushl 	%edx

	movl	8(%ebp), %eax #pointer
	movl	12(%ebp), %ebx #width index
	movl	16(%ebp), %edx #height index

	cmpl	20(%ebp), %ebx
	jge	.bad
	cmpl	24(%ebp),%edx
	jge	.bad
	cmpl	$0,	%ebx
	jl	.bad
	cmpl	$0, %edx
	jl	.bad

	sall	$2, %ebx
	sall	$2, %edx

	addl	%ebx, %eax
	movl	(%eax), %eax
	addl	%edx, %eax
	movl	(%eax), %eax
	
	jmp	.endGetValue

.bad:
	movl	$0, %eax

.endGetValue:
	popl	%edx
	popl	%ebx
	popl	%ebp
	ret

.globl getCount
    .type   update, @function

getCount:
	
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx

	subl	$36, %esp

	movl	12(%ebp), %ebx #inner j
	subl	$1, %ebx

	movl	16(%ebp), %edx #outer i
	subl	$1, %edx

	movl	$0, -4(%ebp) #total
	movl	$3, -8(%ebp) #inner counter
	movl	$3, -12(%ebp) #outer counter

.countLoop:

	movl	20(%ebp), %eax
	movl	%eax, 12(%esp) #set max width

	movl	24(%ebp), %eax
	movl	%eax, 16(%esp) #set max height

	movl	8(%ebp), %eax #set static pointer
	movl	%eax, (%esp)

	movl	%ebx, 4(%esp) 
	movl	%edx, 8(%esp)

	call	getValue 

	addl	%eax, -4(%ebp)
	addl 	$1, %ebx

	movl	-8(%ebp), %ecx
	subl	$1, -8(%ebp)

	loop .countLoop
	
	movl	12(%ebp), %ebx #reset inner j
	subl	$1, %ebx

	movl	$3, -8(%ebp) #inner counter

	addl	$1, %edx #increment outer i

	movl	-12(%ebp), %ecx #restore outer counter
	subl	$1, -12(%ebp)

	loop .countLoop

	movl 	-4(%ebp), %eax

.endOfGetCount:

	addl	$36, %esp
	popl	%ebx
	popl	%ebp
	ret


.globl update
    .type   update, @function

update:
    #place your code here
    pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx

	subl	$64, %esp

	movl	12(%ebp), %eax
	cmpl	$0, %eax
	jle	.endofUpdate

	movl	16(%ebp), %eax
	cmpl	$0, %eax
	jle	.endofUpdate

	sall	$2, %eax # height * 4 
	movl	%eax, (%esp)   
	call	malloc #allocate columns
	movl	%eax, -4(%ebp) # -4 Static Pointer to the array copy

	movl	16(%ebp), %ecx

	movl	$0, %edx

.allocateRowsLoop:
	
	movl	12(%ebp), %eax
	sall	$2, %eax # width * 4 
	
	pushl	%edx #check to make sure allocated correctly
	pushl	%ecx 
	pushl	%eax 
	call	malloc 
	popl	%ebx
	popl	%ecx
	popl	%edx

	movl	-4(%ebp), %ebx #edx is offset so now I just need to add it to the onset
	addl	%edx,	%ebx
	movl	%eax, (%ebx)

	addl	$4, %edx
	
	loop	.allocateRowsLoop

.copySetUp:
	
	movl	16(%ebp) ,%eax
	movl	%eax, -8(%ebp) #height counter

	movl	12(%ebp) ,%eax
	movl	%eax, -12(%ebp) #width counter

	movl	-4(%ebp), %eax	
	movl	%eax, -16(%ebp) # outer pointer new
	
	movl	(%eax), %eax
	movl	%eax, -20(%ebp) # inner pointer of new

	movl	8(%ebp), %eax 
	movl	%eax, -24(%ebp) # outer pointer old

	movl 	(%eax),%eax
	movl	%eax, -28(%ebp) # inner pointer old


.copyLoop:
	
	movl	-12(%ebp), %ecx #restore outer counter
	subl	$1, -12(%ebp)

	movl	-28(%ebp), %eax #puts value to copy in eax
	movl 	(%eax), %eax

	movl	-20(%ebp), %ebx 
	movl	%eax, (%ebx) #puts it in copy array

	addl	$4, -20(%ebp) #shifts inners
	addl	$4, -28(%ebp)  		

	loop 	.copyLoop #inner loop condition through "rows"
	
	movl	-8(%ebp), %ecx #restores column counter
	subl	$1, -8(%ebp)

	movl	12(%ebp), %eax	#reset inner counter
	movl	%eax, -12(%ebp)

	addl	$4, -24(%ebp) #shifts outer pointers
	addl	$4, -16(%ebp)

	movl	-24(%ebp), %eax #moves inners to next place
	movl	(%eax), %eax
	movl	%eax, -28(%ebp)

	movl	-16(%ebp), %eax
	movl	(%eax), %eax
	movl	%eax, -20(%ebp)

	loop	.copyLoop #outerLoop through "columns"

.setUpTraversal:

	movl	16(%ebp) ,%eax
	movl	%eax, -8(%ebp) #height counter

	movl	12(%ebp) ,%eax
	movl	%eax, -12(%ebp) #width counter

	movl	-4(%ebp), %eax	
	movl	%eax, -16(%ebp) # outer pointer new
	
	movl	(%eax), %eax
	movl	%eax, -20(%ebp) # inner pointer of new

	movl	8(%ebp), %eax 
	movl	%eax, -24(%ebp) # outer pointer old

	movl 	(%eax),%eax
	movl	%eax, -28(%ebp) # inner pointer old

.traversalLoop:
	
	movl	-4(%ebp), %eax #outer pointer
	movl	%eax, (%esp) 

	movl	12(%ebp), %eax #width index
	movl	%eax, 12(%esp) #max width
	subl	-12(%ebp) ,%eax
	movl	%eax, 8(%esp)

	movl	16(%ebp), %eax #height index
	movl	%eax, 16(%esp) #max height
	subl	-8(%ebp) ,%eax
	movl	%eax, 4(%esp)

	call	getCount 

	movl	-20(%ebp), %ebx #puts current value in ebx
	movl 	(%ebx), %ebx

	subl	%ebx, %eax # count method counts self. This undos that

	cmpl	$1, %ebx
	je 	.valueIsOne


.valueIsZero:
	
	cmpl 	$3 , %eax
	jne .traversalLoopContinued

	movl	-28(%ebp), %eax
	movl	$1, (%eax)
	jmp .traversalLoopContinued

.valueIsOne:

	cmpl	$2, %eax
	je	.traversalLoopContinued

	cmpl	$3, %eax
	je	.traversalLoopContinued

	movl	-28(%ebp), %eax
	movl	$0, (%eax)	

.traversalLoopContinued:
	
	addl	$4, -20(%ebp) #shift inner pointers
	addl	$4, -28(%ebp)

	movl	-12(%ebp), %ecx #restore inner ecx
	subl	$1, -12(%ebp)

	loop .traversalLoop #inner loop

	addl	$4, -24(%ebp) #Shift outer pointers
	addl	$4, -16(%ebp)

	movl	-24(%ebp), %eax #moving old inner pointer
	movl	(%eax), %eax
	movl	%eax, -28(%ebp)

	movl	-16(%ebp), %eax #moving new inner pointer
	movl	(%eax), %eax
	movl	%eax, -20(%ebp)

	movl	12(%ebp) ,%eax
	movl	%eax, -12(%ebp) #reset width counter

	movl	-8(%ebp), %ecx #restore outer ecx
	subl	$1, -8(%ebp)

	dec %ecx
	jnz .traversalLoop #outer loop

.setUpFreeMemory:
	movl	16(%ebp), %ecx
	movl	-4(%ebp), %ebx

.freeMemory:
	
	movl	(%ebx), %eax
	movl	%eax, (%esp)

	pushl	%ecx 
	pushl	%eax 
	call	free 
	popl	%edx
	popl	%ecx

	addl	$4, %ebx
	
	loop	.freeMemory

	movl	-4(%ebp), %ebx
	movl	%ebx, (%esp)
	call	free

.endofUpdate:
	addl	$64, %esp
	popl	%ebx
	popl	%ebp
	ret
