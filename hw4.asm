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

insert_node_done:
	#Function Epilogue
    jr $ra