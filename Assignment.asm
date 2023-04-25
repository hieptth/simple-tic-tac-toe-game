#Computer Architecture Assignment - Sem 211 - Truong Tan Hao Hiep - ID: 2011211
.data
#Game UI
	greetings: .asciiz "+------------------------+\n| WELCOME TO TIC TAC TOE |\n+------------------------+\n\n"
	gameplay: .asciiz "***HOW TO PLAY***\nEnter a number that corresponds to a point on the board as shown in example below.\n\n"
	rule: .asciiz "\nThe first player play as X and the second player play as O. Players take turns putting their marks in empty squares. X always goes first.\nThe first player to get 3 in a row (up, down, across, or diagonally) is the winner.\nIf there is no winner after the board is filled, call it a tie.\n"
	start: .asciiz "**Enjoy your game!**\n\n---------- GAME HAS STARTED ----------\n\n"
#data
	sideboard: .word 0, 0, 0, 0, 0, 0, 0, 0, 0
	player1: .asciiz "\nPlayer 1"
	player2: .asciiz "\nPlayer 2"
	x: .asciiz "X"
	o: .asciiz "O"
	board: .asciiz " 1 | 2 | 3 \n---+---+---\n 4 | 5 | 6 \n---+---+---\n 7 | 8 | 9 \n"
	inquire: .asciiz "'s turn: "
	invalid: .asciiz "\n***Invalid Move***\n\n"
	occupied: .asciiz "\n***Space already occupied***\n\n"
	won: .asciiz " won!\n\n"
	tie: .asciiz "\nIt's a tie!\n\n"
	rematch: .asciiz "Do you want a rematch? [0]yes [1]no :\t"
	empty: .byte ' '
.text
.globl main
main:
Prompt:					#Create game UI
	li $v0, 4
	la $a0, greetings
	syscall
	la $a0, gameplay
	syscall
	la $a0, board
	syscall
	la $a0, rule
	syscall
	la $a0, start
	syscall
	
LoadData:				#Load data to register
	la $s1, board
	li $s3, 0			#Count the turn
	la $s4, sideboard
	
Cleanup:
	#Clean up the board before the game (for the rematch)
	lb $s0, empty
	sb $s0, 1($s1)			#first row
	sb $s0, 5($s1)
	sb $s0, 9($s1)
	sb $s0, 25($s1)			#second row
	sb $s0, 29($s1)
	sb $s0, 33($s1)
	sb $s0, 49($s1)			#third row
	sb $s0, 53($s1)
	sb $s0, 57($s1)
	
	#Clean up the sideboard for rematch
	li $s7, 0
	sw $s7, 0($s4)
	sw $s7, 4($s4)
	sw $s7, 8($s4)
	sw $s7, 12($s4)
	sw $s7, 16($s4)
	sw $s7, 20($s4)
	sw $s7, 24($s4)
	sw $s7, 28($s4)
	sw $s7, 32($s4)
	
Play:
	li $v0, 4			#ask for input
	andi $s7, $s3, 1		#check turn for even/odd
	beqz $s7, X
	la $a0, player2			#player 2 if odd turn (started with 0)
	syscall
	j Conc
X:
	la $a0, player1			#player 1 if even turn
	syscall
Conc:
	la $a0, inquire
	syscall
	li $v0, 5
	syscall
	move $s5, $v0			#s5 hold the input
	addi $s5, $s5, -1		#my code work on the set from 0-8
	
	#Check validity (if input is in 0-8 and the space is not occupied
	bgt $s5, 8, Error
	bltz $s5, Error
	
	#Calculate the exact cell
	#My formula: 24*(input/3) + 1 + 4*(x - (x/3)*3)
	div $s2, $s5, 3	
	mul $s2, $s2, 3	
	sub $s2, $s5, $s2
	mul $s2, $s2, 4
	addi $s2, $s2, 1
	div $s6, $s5, 3
	mul $s6, $s6, 24
	add $s2, $s2, $s6
	add $s2, $s2, $s1		#Set $s2 to address of corresponding cell in board
	lb $t0, ($s2)			#get the value at s2 for comparison
	
	bne $t0, $s0, Occupied		#Occupied if not "empty"

	mul $t0, $s5, 4			#get address of corresponding cell in sideboard
	add $t0, $s4, $t0
	
	beqz $s7, Player1		#Player 1's turn if turn is even
	lb $s6, o
	li $t1, 2
	sb $t1, 0($t0)
	j GoodInput
Player1:
	lb $s6, x
	li $t1, 1
	sb $t1, 0($t0)
GoodInput:
	sb $s6, 0($s2)
	addi $s3, $s3, 1		#increase the count (turn)

PrintBoard:
	li $v0, 4
	la $a0, board
	syscall

	bgt $s3, 4, CheckVictory
NoVictor:
	beq $s3, 9, Tie
	j Play

Endgame:
	li $v0, 10
	syscall
	
Error:
	li $v0, 4
	la $a0, invalid
	syscall
	j Play
	
Occupied:
	li $v0, 4
	la $a0, occupied
	syscall
	j Play
	
Tie:
	li $v0, 4
	la $a0, tie
	syscall
	j Rematch
	
Rematch:
	li $v0, 4
	la $a0, rematch
	syscall
	li $v0, 5
	syscall
	bnez $v0, Endgame
	li $v0, 4
	la $a0, start
	syscall
	j LoadData
	
CheckVictory:
	#load temp value
	lb $t0, 0($s4)
	lb $t1, 4($s4)
	lb $t2, 8($s4)
	lb $t3, 12($s4)
	lb $t4, 16($s4)
	lb $t5, 20($s4)
	lb $t6, 24($s4)
	lb $t7, 28($s4)
	lb $t8, 32($s4)

	and $s6, $t0, $t1		#1st row
	and $s6, $s6, $t2
	bnez $s6, Won
	
	and $s6, $t3, $t4		#2nd row
	and $s6, $s6, $t5
	bnez $s6, Won
	
	and $s6, $t6, $t7		#3rd row
	and $s6, $s6, $t8
	bnez $s6, Won
	
	and $s6, $t0, $t3		#1st col
	and $s6, $s6, $t6
	bnez $s6, Won
	
	and $s6, $t1, $t4		#2nd row
	and $s6, $s6, $t7
	bnez $s6, Won
	
	and $s6, $t2, $t5		#3rd row
	and $s6, $s6, $t8
	bnez $s6, Won
	
	and $s6, $t0, $t4		#left to right diagonal
	and $s6, $s6, $t8
	bnez $s6, Won
	
	and $s6, $t2, $t4		#right to left diagonal
	and $s6, $s6, $t6
	bnez $s6, Won
	
	j NoVictor
	
Won:
	li $v0, 4
	beqz $s7, P1
	la $a0, player2			#player 2 if odd turn (started with 0)
	syscall
	j Next
P1:
	la $a0, player1			#player 1 if even turn
	syscall
Next:
	la $a0, won
	syscall
	j Rematch
