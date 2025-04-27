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
    addi sp,sp,-8
    sw ra,4(sp)
    sw s1,0(sp)
    move s1,a0
    li v0,9
    li a0,20
    syscall
    move t2,v0
    sw a1,0(t2)
    sw zero,4(t2)
    sw zero,8(t2)
    li t0,1
    sw t0,12(t2)
    sw zero,16(t2)
    move t1,s1
    move t0,zero
bst1:
    beqz t1,bst2
    move t0,t1
    lw t3,0(t1)
    blt a1,t3,bstl
    lw t1,8(t1)
    j bst1
bstl:
    lw t1,4(t1)
    j bst1
bst2:
    sw t0,16(t2)
    beqz t0,rootset
    lw t3,0(t0)
    blt a1,t3,linkl2
    sw t2,8(t0)
    j inscont
linkl2:
    sw t2,4(t0)
inscont:
    move a0,t2
    jal insert_fixup
    move s1,v0
    move v0,s1
    lw s1,0(sp)
    lw ra,4(sp)
    addi sp,sp,8
    jr ra
rootset:
    move s1,t2
    j inscont

# Function: insert_fixup
# Arguments:
#    $a0 - pointer to the newly inserted node
# Returns:
#	$v0 - pointer to the root of the tree

insert_fixup:
    addi sp,sp,-4
    sw ra,0(sp)
    move t2,a0
fix_loop:
    lw t1,16(t2)
    beqz t1,fix_end
    lw t3,12(t1)
    beqz t3,fix_end
    lw t4,16(t1)
    lw t5,4(t4)
    beq t5,t1,left_case
    lw t6,4(t4)
    bnez t6,chk_u_r
    j fix_end
chk_u_r:
    lw t3,12(t6)
    bnez t3,recolor_r
    lw t5,4(t1)
    beq t2,t5,inner_r
    sw zero,12(t1)
    li t7,1
    sw t7,12(t4)
    move a0,t4
    jal rotate_left
    j fix_end
inner_r:
    move a0,t1
    jal rotate_right
    move t2,t1
    j fix_loop

left_case:
    lw t6,8(t4)
    bnez t6,chk_u_l
    j fix_end
chk_u_l:
    lw t3,12(t6)
    bnez t3,recolor_l
    lw t5,8(t1)
    beq t2,t5,inner_l
    sw zero,12(t1)
    li t7,1
    sw t7,12(t4)
    move a0,t4
    jal rotate_right
    j fix_end
inner_l:
    move a0,t1
    jal rotate_left
    move t2,t1
    j fix_loop

recolor_r:
    sw zero,12(t1)
    sw zero,12(t6)
    li t7,1
    sw t7,12(t4)
    move t2,t4
    j fix_loop

recolor_l:
    sw zero,12(t1)
    sw zero,12(t6)
    li t7,1
    sw t7,12(t4)
    move t2,t4
    j fix_loop

fix_end:
    move t0,s1
    sw zero,12(t0)
    move v0,t0
    lw ra,0(sp)
    addi sp,sp,4
    jr ra

rotate_left:
    addi sp,sp,-4
    sw ra,0(sp)
    lw t1,8(a0)
    beqz t1,rl_done
    lw t2,4(t1)
    sw t2,8(a0)
    bnez t2,rl_s1
    j rl_s2
rl_s1:
    sw a0,16(t2)
rl_s2:
    lw t3,16(a0)
    sw t3,16(t1)
    bnez t3,rl_s3
    j rl_s4
rl_s3:
    lw t4,4(t3)
    beq a0,t4,rl_s4
    sw t1,8(t3)
rl_s4:
    sw a0,4(t1)
    sw t1,16(a0)
rl_done:
    lw ra,0(sp)
    addi sp,sp,4
    jr ra

rotate_right:
    addi sp,sp,-4
    sw ra,0(sp)
    lw t1,4(a0)
    beqz t1,rr_done
    lw t2,8(t1)
    sw t2,4(a0)
    bnez t2,rr_s1
    j rr_s2
rr_s1:
    sw a0,16(t2)
rr_s2:
    lw t3,16(a0)
    sw t3,16(t1)
    bnez t3,rr_s3
    j rr_s4
rr_s3:
    lw t4,4(t3)
    beq a0,t4,rr_s4
    sw t1,4(t3)
rr_s4:
    sw a0,8(t1)
    sw t1,16(a0)
rr_done:
    lw ra,0(sp)
    addi sp,sp,4
    jr ra