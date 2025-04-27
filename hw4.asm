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
#    $a0 - pointer to root
#    $a1 - value to insert
# Returns:
#	$v0 - pointer to root

insert_node:
	addi $sp,$sp,-8
	sw $ra,4($sp)
	sw $s1,0($sp)
	move $s1,$a0
	li $v0,9
	li $a0,20
	syscall
	move $t0,$v0
	sw $a1,0($t0)
	sw $zero,4($t0)
	sw $zero,8($t0)
	li $t1,1
	sw $t1,12($t0)
	sw $zero,16($t0)
	move $t2,$s1
	move $t3,$zero
bst_walk:
	beqz $t2,bst_link
	move $t3,$t2
	lw $t4,0($t2)
	blt $a1,$t4,bst_left
	lw $t2,8($t2)
	j bst_walk
bst_left:
	lw $t2,4($t2)
	j bst_walk
bst_link:
	sw $t3,16($t0)
	beqz $t3,new_root
	lw $t4,0($t3)
	blt $a1,$t4,link_left
	sw $t0,8($t3)
	j go_fix
link_left:
	sw $t0,4($t3)
	j go_fix
new_root:
	move $s1,$t0
go_fix:
	move $a0,$t0
	jal insert_fixup
	move $v0,$v0
	lw $s1,0($sp)
	lw $ra,4($sp)
	addi $sp,$sp,8
	jr $ra

# Function: insert_fixup
# Arguments:
#    $a0 - pointer to the newly inserted node
# Returns:
#	$v0 - pointer to the root of the tree
insert_fixup:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	move $t0,$a0
fix_loop:
	lw $t1,16($t0)
	beqz $t1,end_fix
	lw $t2,12($t1)
	beqz $t2,end_fix
	lw $t3,16($t1)
	beqz $t3,end_fix
	lw $t4,4($t3)
	beq $t4,$t1,case_left
case_right:
	lw $t5,4($t3)
	beqz $t5,uncle_black_R
	lw $t6,12($t5)
	beqz $t6,uncle_black_R
	sw $zero,12($t1)
	sw $zero,12($t5)
	li $t7,1
	sw $t7,12($t3)
	move $t0,$t3
	j fix_loop
uncle_black_R:
	lw $t6,4($t1)
	bne $t0,$t6,right_ok
	move $a0,$t1
	jal rot_right
	move $t0,$a0
right_ok:
	move $a0,$t3
	jal rot_left
	sw $zero,12($t1)
	li $t7,1
	sw $t7,12($t3)
	j end_fix
case_left:
	lw $t5,8($t3)
	beqz $t5,uncle_black_L
	lw $t6,12($t5)
	beqz $t6,uncle_black_L
	sw $zero,12($t1)
	sw $zero,12($t5)
	li $t7,1
	sw $t7,12($t3)
	move $t0,$t3
	j fix_loop
uncle_black_L:
	lw $t6,8($t1)
	bne $t0,$t6,left_ok
	move $a0,$t1
	jal rot_left
	move $t0,$a0
left_ok:
	move $a0,$t3
	jal rot_right
	sw $zero,12($t1)
	li $t7,1
	sw $t7,12($t3)
end_fix:
	move $t9,$t0
up_root:
	lw $t8,16($t9)
	beqz $t8,root_done
	move $t9,$t8
	j up_root
root_done:
	sw $zero,12($t9)
	move $v0,$t9
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

rot_left:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	lw $t1,8($a0)
	beqz $t1,rl_ret
	lw $t2,4($t1)
	sw $t2,8($a0)
	beqz $t2,rl_pok
	sw $a0,16($t2)
rl_pok:
	lw $t3,16($a0)
	sw $t3,16($t1)
	beqz $t3,rl_setroot
	lw $t4,4($t3)
	beq $a0,$t4,rl_lchild
	sw $t1,8($t3)
	j rl_setroot
rl_lchild:
	sw $t1,4($t3)
rl_setroot:
	sw $a0,4($t1)
	sw $t1,16($a0)
rl_ret:
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

rot_right:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	lw $t1,4($a0)
	beqz $t1,rr_ret
	lw $t2,8($t1)
	sw $t2,4($a0)
	beqz $t2,rr_pok
	sw $a0,16($t2)
rr_pok:
	lw $t3,16($a0)
	sw $t3,16($t1)
	beqz $t3,rr_setroot
	lw $t4,4($t3)
	beq $a0,$t4,rr_rchild
	sw $t1,4($t3)
	j rr_setroot
rr_rchild:
	sw $t1,8($t3)
rr_setroot:
	sw $a0,8($t1)
	sw $t1,16($a0)
rr_ret:
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra