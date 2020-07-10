########################################################################
# COMP1521 20T2 --- assignment 1: a cellular automaton renderer
#
# Written by <<YOU>>, July 2020.


# Maximum and minimum values for the 3 parameters.

MIN_WORLD_SIZE	=    1
MAX_WORLD_SIZE	=  128
MIN_GENERATIONS	= -256
MAX_GENERATIONS	=  256
MIN_RULE	=    0
MAX_RULE	=  255

# Characters used to print alive/dead cells.

ALIVE_CHAR	= '#'
DEAD_CHAR	= '.'

# Maximum number of bytes needs to store all generations of cells.

MAX_CELLS_BYTES	= (MAX_GENERATIONS + 1) * MAX_WORLD_SIZE

	.data

# `cells' is used to store successive generations.  Each byte will be 1
# if the cell is alive in that generation, and 0 otherwise.

cells:	.space MAX_CELLS_BYTES


# Some strings you'll need to use:

prompt_world_size:	.asciiz "Enter world size: "
error_world_size:	.asciiz "Invalid world size\n"
prompt_rule:		.asciiz "Enter rule: "
error_rule:		.asciiz "Invalid rule\n"
prompt_n_generations:	.asciiz "Enter how many generations: "
error_n_generations:	.asciiz "Invalid number of generations\n"
testing:	.asciiz "--------------testing-------------\n"
	.text

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `main', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `run_generation' FINISHES
	#

main:
	#
	# REPLACE THIS COMMENT WITH YOUR CODE FOR `main'.
	#


	# replace the syscall below with
	#
	# li	$v0, 0
	# jr	$ra
	#
	# if your code for `main' preserves $ra by saving it on the
	# stack, and restoring it after calling `print_world' and
	# `run_generation'.  [ there are style marks for this ]

	la	$a0, prompt_world_size		# printf("Enter world size: ");
	li	$v0, 4
	syscall

	li	$v0, 5						# scanf("%d", &world_size);
	syscall

	move	$s0, $v0		 		# $s0 = world_size

	blt	$s0, MIN_WORLD_SIZE, invalidWorldSize	# if (world_size < MIN_WORLD_SIZE
	bgt	$s0, MAX_WORLD_SIZE, invalidWorldSize	# || world_size > MAX_WORLD_SIZE), then invalidWorldSize
	
	la	$a0, prompt_rule		# printf("Enter rule: ");
	li	$v0, 4
	syscall

	li	$v0, 5						# scanf("%d", &rule);
	syscall

	move	$s1, $v0		 		# $s1 = rule

	blt	$s1, MIN_RULE, invalidRule	# if (rule < MIN_RUL
	bgt	$s1, MAX_RULE, invalidRule	# || rule > MAX_RULE), then invalidRule

	la	$a0, prompt_n_generations	# printf("Enter how many generations: ");
	li	$v0, 4
	syscall

	li	$v0, 5						# scanf("%d", &n_generations);
	syscall

	move	$s2, $v0		 		# $s2 = n_generations

	blt	$s2, MIN_GENERATIONS, invalidGenerations	# if (n_generations < MIN_GENERATIONS
	bgt	$s1, MAX_GENERATIONS, invalidGenerations	# || n_generations > MAX_GENERATIONS), then invalidGenerations

	li	$a0, '\n'					# putchar('\n');
	li	$v0, 11
	syscall

	li	$s3, 0						# int reverse = 0;
	bgez	$s2, positiveGenerations				# if n_generations >= 0,then positiveGenerations

	li	$s3, 1						# reverse = 1;
	li	$t0, 0
	sub	$s2, $t0, $s2				# n_generations = -n_generations;
positiveGenerations:

	li	$s4, 4					# intsize = sizeof(int)
	li	$t0, 2
	move	$t1, $s0			# $t1 = world_size
	div		$t1, $t0			# col = world_size / 2
	mflo	$t2					# $t2 = floor($t1 / $t0) 
	mfhi	$t3					# $t3 = $t1 mod $t0 

								# since row is 0, then we only have to calculate the column for the offset 
	mul	$t2, $t2, $s4			# offset = col * intsize

	li	$t3, 1
	sw	$t3, cells($t2)			# cells[0][world_size / 2] = 1;

	move	$a0, $s0			# $a0 = world_size
	li	$a1, 1					# int g = 1
	move	$a2, $s1			# $a2 = rule

runLoop:		
	bgt	$a1, $s2, runEnd		# while (g <= n_generations){

	addi	$sp, $sp, -4		# Save the return register
	sw	$ra, 0($sp)

	jal	run_generation			# jump to run_generation

	lw	$ra, 0($sp)				# load the return register
	addi	$sp, $sp, 4

	addi	$a1, $a1, 1			# g++;
	j	runLoop
runEnd:
	move	$a0, $s0				# $a0 = world_size
	li	$t0, 0
	move	$a1, $t0				# int g = 0

	beqz	$s3, falseReverse		# if reverse is false, then falseReverse

	move	$a1, $s2				# int g = n_generations

	addi	$sp, $sp, -4			# Save register
	sw	$ra, 0($sp)
trueReverseLoop:
	bltz	$s2, trueReverseEnd			# while (g >= 0) {

	jal	print_generation			# jump to print_generation

	move	$s7, $a0

	move	$a0, $s2					# putchar('\n');
	li	$v0, 1
	syscall

	li	$a0, '\n'					# putchar('\n');
	li	$v0, 11
	syscall
	move	$a0, $s7

	addi	$s2, $s2, -1			#	g--;
	j trueReverseLoop
trueReverseEnd:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
mainEnd:
	li	$v0, 0
	jr	$ra



invalidWorldSize:
	la	$a0, error_world_size		# printf("Invalid world size\n");
	li	$v0, 4
	syscall

	li	$v0, 1
	jr	$ra							# return 1;
invalidRule:
	la	$a0, error_rule				# printf("Invalid rule\n");
	li	$v0, 4
	syscall

	li	$v0, 1
	jr	$ra							# return 1;
invalidGenerations:
	la	$a0, error_n_generations	# printf("Invalid number of generations\n");
	li	$v0, 4
	syscall

	li	$v0, 1
	jr	$ra							# return 1;
falseReverse:
	addi	$sp, $sp, -4			# Save register
	sw	$ra, 0($sp)

	li	$a1, 0						# int g = 0
falseReverseLoop:
	bgt	$a1, $s2, falseReverseEnd	# while (g <= n_generations){
	move	$a0, $s0				# $a0 = world_size	

	jal	print_generation			# jump to print_generation
	
	addi	$a1, $a1, 1				# g++;
	j	falseReverseLoop
falseReverseEnd:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4

	j mainEnd



	#
	# Given `world_size', `which_generation', and `rule', calculate
	# a new generation according to `rule' and store it in `cells'.
	#

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `run_generation', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `run_generation' FINISHES
	#

run_generation:
	addi	$sp, $sp, -20
	sw	$s0, 0($sp)			# Storing 4 bit off from $sp, because the the first 4 bit already stored $ra
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)

	li	$s0, 0				# int x = 0

run_generation_loop:

	bge	$s0, $a0,	run_generation_end		# while (x < world_size) {

	li	$s1, 0								# int left = 0
	li	$s2, 4								# intsize = sizeof(int)
	
	li	$t0, MAX_WORLD_SIZE
	mul	$s3, $t0, $s2						# rowsize = #cols * intsize

	blez	$s0, initialise_centre			# if (x > 0) {

	addi	$t0, $a1, -1					# row = which_generation - 1
	mul	$t1, $t0, $s3						# $t1 = row * rowsize

	addi $t2, $s0, -1						# $t2 = x - 1
	mul	$t2, $t2, $s2						# $t2 = col * intsize

	add	$t0, $t1, $t2						# offset = $t1 + $t2
	lw	$s1, cells($t0)						# left = cells[which_generation - 1][x - 1];

initialise_centre:

	addi	$t0, $a1, -1					# row = which_generation - 1
	mul	$t1, $t0, $s3						# $t1 = row * rowsize

	mul	$t2, $s0, $s2						# $t2 = col * intsize

	add	$t0, $t1, $t2						# offset = $t1 + $t2
	lw	$s4, cells($t0)						# centre = cells[which_generation - 1][x];

	li	$s5, 0								# int right = 0

	add	$t0, $a0, -1						# $t0 = world_size - 1
	bge	$s0, $t0, initialise_state			# if (x < world_size - 1) {

	addi	$t0, $a1, -1					# row = which_generation - 1
	mul	$t1, $t0, $s3						# $t1 = row * rowsize

	addi $t2, $s0, 1						# $t2 = x + 1
	mul	$t2, $t2, $s2						# $t2 = col * intsize

	add	$t0, $t1, $t2						# offset = $t1 + $t2
	lw	$s5, cells($t0)						# right = cells[which_generation - 1][x - 1];
	
initialise_state:

	li	$t0, 2
	sllv	$s1, $s1, $t0					# left = left << 2

	li	$t0, 1
	sllv	$s4, $s4, $t0					# centre = centre << 1

	or	$s1, $s1, $s4						# int state = left << 2 | centre << 1
	or	$s1, $s1, $s5						# state = state = | right << 0


	li	$t0, 1
	sllv	$s1, $t0, $s1					# int bit = 1 << state;
	
	and	$s1, $a2, $s1						# int set = rule & bit;

	beqz	$s1, setZero

	mul	$t1, $a1, $s3						# $t1 = row * rowsize

	mul	$t2, $s0, $s2						# $t2 = col * intsize

	add	$t0, $t1, $t2						# offset = $t1 + $t2

	li	$t1, 1
	sw	$t1, cells($t0)						# cells[which_generation][x] = 1;

	j	increment
setZero:
	mul	$t1, $a1, $s3						# $t1 = row * rowsize

	mul	$t2, $s0, $s2						# $t2 = col * intsize

	add	$t0, $t1, $t2						# offset = $t1 + $t2

	li	$t1, 0
	sw	$t1, cells($t0)						# cells[which_generation][x] = 0;

increment:
	addi	$s0, $s0, 1						# x++

	j	run_generation_loop
run_generation_end:

	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 20

	jr	$ra



	#
	# Given `world_size', and `which_generation', print out the
	# specified generation.
	#

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `print_generation', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `print_generation' FINISHES
	#

print_generation:
	addi	$sp, $sp, -20
	sw	$s0, 0($sp)			# Storing 4 bit off from $sp, because the the first 4 bit already stored $ra
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	
	move	$s7, $s0				# save the world_size
	move	$s6, $a1				# save the which_generation

	move	$a0, $s6				# printf("%d", which_generation);
	li	$v0, 1
	syscall

	li	$a0, '\t'					# putchar('\t');
	li	$v0, 11
	syscall

	li	$s0, 0						# int x = 0;
	li	$s1, 4						# intsize = sizeof(int)
	
	li	$t0, MAX_WORLD_SIZE
	mul	$s2, $t0, $s1				# rowsize = #cols * intsize
print_loop:

	bge	$s0, $s7, print_end			# while ( x < world_size) {
	
	mul	$t1, $s6, $s2				# $t1 = row * rowsize

	mul	$t2, $s0, $s1				# $t2 = col * intsize

	add	$t0, $t1, $t2				# offset = $t1 + $t2

	lw	$t1, cells($t0)				# $t1 = cells[which_generation][x];

	beqz	$t1, deadChar			# if cells[which_generation][x] is false, then deadChar

	li	$t0, ALIVE_CHAR
	move	$a0, $t0
	li	$v0, 11
	syscall

print_increment:
	addi	$s0, $s0, 1				# x++;
	j	print_loop
print_end:
	li	$a0, '\n'					# putchar('\n');
	li	$v0, 11
	syscall

	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	addi	$sp, $sp, 20

	jr	$ra

deadChar:
	li	$t0, DEAD_CHAR
	move	$a0, $t0
	li	$v0, 11
	syscall

	j	print_increment