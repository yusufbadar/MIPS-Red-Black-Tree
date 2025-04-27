.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

# red-black data
lparen: .asciiz "("
rparen_space: .asciiz ") "
color_red: .asciiz "R"
color_black: .asciiz "B"

.text
.globl print_tree 
.globl search_node
.globl insert_node

# Function: print_tree
# Print all the values and colors with in-order traversal (format: value, left, right, color)
# Arguments: 
#   $a0 - pointer to root
# Returns: void

print_tree:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)        
    move $s0, $a0
    beqz $s0, print_tree_end
    lw $a0, 4($s0)
    jal print_tree
    lw $t0, 0($s0)
    lw $t1, 16($s0)
    lw $t2, 12($s0)
    beqz $t1, no_parent
    lw $t3, 0($t1)
    j have_parent
no_parent:
    li $t3, 0
have_parent:
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, lparen
    li $v0, 4
    syscall
    move $a0, $t3
    li $v0, 1
    syscall
    beqz $t2, print_black
    la $a0, color_red
    li $v0, 4
    syscall
    j after_color
print_black:
    la $a0, color_black
    li $v0, 4
    syscall
after_color:
    la $a0, rparen_space
    li $v0, 4
    syscall
    lw $a0, 8($s0)
    jal print_tree
print_tree_end:
    # Epilogue
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra # return

# Function: search_node
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to find
# Returns:
#   $v0 : -1 if not found, else pointer to node

search_node:
    # Function prologue
    move $t0, $a0
search_loop: 
    beqz $t0, not_found
    lw $t1, 0($t0)
    beq $t1, $a1, search_found
	blt $a1, $t1, search_left
    lw $t0, 8($t0)
    j search_loop
search_left:
    lw $t0, 4($t0)
    j search_loop
search_found:
    move $v0, $t0
    j search_node_end
not_found:
    li $v0, -1
    jr $ra
search_node_end:	
	#Function Epilogue
	jr $ra

# Function: insert_node
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to insert
# Returns: 
#	$v0 - pointer to root

insert_node:
	# Function prologue
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s1, 0($sp)
    move $s1, $a0
    li $v0,9
    li $a0,20
    syscall
    move $a0, $s1
    move $t0,$v0
    sw $a1,0($t0)
    li $t1,1
    sw $t1,12($t0)
    sw $zero,4($t0)
    sw $zero,8($t0)
    sw $zero,16($t0)
    move $t1,$zero
    move $t2,$s1
bst_loop:
    beqz $t2,bst_done
    move $t1,$t2
    lw $t3,0($t2)
    blt $a1,$t3,bst_left
    lw $t2,8($t2)
    j bst_loop
bst_left:
    lw $t2,4($t2)
    j bst_loop
bst_done:
    sw $t1,16($t0)
    beqz $t1,new_root
    lw $t3,0($t1)
    blt $a1,$t3,link_L
    sw $t0,8($t1)
    j after_ins
link_L:
    sw $t0,4($t1)
new_root:
    move $a0,$t0
after_ins:
    move $a0,$t0
    jal insert_fixup
    move $v0,$a0
    j insert_node_done

insert_node_done:
	#Function Epilogue
    lw $s1, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

insert_fixup:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    move $t2,$a0
fix_loop:
    lw $t1,16($t2)
    beqz $t1,done_fix
    lw $t3,12($t1)
    beqz $t3,done_fix
    lw $t4,16($t1)
    lw $t5,4($t4)
    beq $t5,$t1,case_L
    lw $t6,4($t4)
    beqz $t4, done_fix
    j chk_uncle
case_L:
    lw $t6,8($t4)
chk_uncle:
    beqz $t6,do_rot
    lw $t7,12($t6)
    beqz $t7,do_rot
    li $t8,0
    sw $t8,12($t1)
    sw $t8,12($t6)
    li $t8,1
    sw $t8,12($t4)
    move $t2,$t4
    j fix_loop
do_rot:
    lw $t5,4($t4)
    beq $t5,$t1,rot_L
    move $a0,$t1
    jal rotate_right
    j rot_swap
rot_L:
    move $a0,$t1
    jal rotate_left
rot_swap:
    move $a0,$t4
    jal rotate_left
    lw $t1,16($t2)
    lw $t4,16($t1)
    lw $t8,12($t1)
    lw $t9,12($t4)
    sw $t8,12($t4)
    sw $t9,12($t1)
done_fix:
    move $t0,$a0
find_rt:
    lw $t1,16($t0)
    bnez $t1,find_rt
    sw $zero,12($t0)
    move $v0,$t0
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

rotate_left:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    lw $t1,8($a0)
    beqz $t1, done_rotate_left
    beqz $t1, rootL
    lw $t2,4($t1)
    sw $t2,8($a0)
    beqz $t2,skip1
    sw $a0,16($t2)
skip1:
    lw $t3,16($a0)
    sw $t3,16($t1)
    beqz $t3,rootL
    lw $t4,4($t3)
    
    beq $a0,$t4,linkpl1
    sw  $t1,8($t3)
    j rl_fix
linkpl1:
    sw $t1,4($t3)
rl_fix:
rootL:
    sw $a0,4($t1)
    sw $t1,16($a0) 
    lw $ra,0($sp)
    addi $sp,$sp,4
    jr $ra

rotate_right:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    lw $t1,4($a0)
    beqz $t1, done_rotate_right
    lw $t2,8($t1)
    sw $t2,4($a0)
    beqz $t2,skip2
    sw $a0,16($t2)
skip2:
    lw $t3,16($a0)
    sw $t3,16($t1)
    beqz $t3,rootR
    lw $t4,4($t3)
    beq $a0,$t4,linkpl2
    sw $t1,4($t3)
    j cont2
linkpl2:
    sw $t1,8($t3)
cont2:
rootR:
    sw  $a0,8($t1)
    sw  $t1,16($a0)
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr  $ra

done_rotate_left:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
done_rotate_right:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra