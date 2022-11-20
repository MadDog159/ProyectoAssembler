.macro print_S (%x)
	li $v0 4
	la $a0 %x
	syscall
.end_macro
.macro print_I (%y)
	li $v0 1
	move $a0 %y
	syscall
.end_macro

.data
Mensaje1:.asciiz "Bienvenido a la Calculadora de Programador\n"
Mensaje2:.asciiz "Elija el sistema numerico que introducira: \n 1)Binario \n 2)Decimal Empaquetado\n 3)Base 10 \n 4)Octal \n 5)Hexadecimal\n"
Mensaje3:.asciiz "\n El sistema de numeracion al cual convertir: \n 1)Binario \n 2)Decimal Empaquetado\n 3)Base 10 \n 4)Octal \n 5)Hexadecimal\n"
Mensaje4:.asciiz "\n Numero en base 10 introducido: "
SOS: .asciiz "Pase por aqui \n"

numeroCadena:.space 32
numeroEmpaquetado: .space 32
numeroHexadecimal: .space 8
numeroHexadecimalSal: .space 9
signo: .space 2

.text
li $s0 0
print_S(Mensaje1)

menu: ############################################################################################

print_S(Mensaje2)

# El usurio elijira entre :
# 1) Binario
# 2) Decimal empaquetada
# 3) Base 10
# 4) Octal
# 5) Hexadecimal

li $v0, 5
syscall

beq $v0 1 Binario_a2
beq $v0 2 DecimalEmpaquetado
beq $v0 3 Base10
beq $v0 4 Octal
beq $v0 5 Hexadecimal
blt $v0 1 menu
bgt $v0 5 menu

li $t0 0 # es nuestra variable de iteracion
li $t3 0

# $t1 guardar cada uno de los caracteres leidos
# $t2 guardaremos la representacion numerica de dichos caracteres

Binario_a2:#############################################################################################
#00000000000000000000000000001111
	li $v0 8
	la $a0 numeroCadena
	li $a1 33
	syscall

	GuardarBits:
		#print_S(numeroCadena)
		li $t2 0
		li $t9 32
		lb $t1 numeroCadena($t0) 	# cargo el valor ascii de 0 o 1
		beq $t1 0xA finGuardarBits	# $t1 = null finalizar
		beq $t1 0x0 finGuardarBits	
		subi $t2 $t1 0x30 		# $t2 con el bit especifico del caracter
		addi $t0 $t0 1			# $t0 contador + 1
		sub $t9 $t9 $t0        		# $t9 = t9 - el contador, sera un iterador de posiciones en memoria
		sllv $t2 $t2 $t9		# $t2 = t2 empujado a la izquierda por el iterador
		or $t3 $t3 $t2			#guardo en memoria cada uno de los bits
		b GuardarBits
		
	finGuardarBits:
		print_S(Mensaje4)
		print_I($t3)
		li $t0 0
		move $t0 $t3
		b menu2
		
DecimalEmpaquetado: ##################################################################
#00000000000000000000000101011101
	li $v0 8
	la $a0 numeroCadena
	li $a1 33
	syscall
	li $t0 28 # recorrido de izquierda a derecha de la cadena
	li $t8 1  # exponente 
	li $t7 0  # contador
	li $t5 1  # valor del signo
	li $s4 4  # constante 4
	li $s5 10  # exponente del 10

	
	GuardarEmpaquetado:
		#print_S(numeroCadena)
		li $t2 0
		li $t9 32
		lb $t1 numeroCadena($t0) 	# cargo el valor ascii de 0 o 1
		beq $t1 0xA finGuardarEmpaquetado 	# $t1 = null finalizar
		beq $t1 0x0 finGuardarEmpaquetado	
		bltz $t0 finGuardarEmpaquetado
		subi $t2 $t1 0x30 	# $t2 con el bit especifico del caracter
		addi $t0 $t0 1		# $t0 contador de 28 a 32
		addi $t7 $t7 1       	# $t7 contador de 1 a 4
		sub $t9 $t9 $t7        	# $t9 = 32 - el contador t7 para recorrer 4 espacios
		sllv $t2 $t2 $t9	# $t2 = t2 empujado a la izquierda por el iterador t9 quedando en 28
		or $t3 $t3 $t2		#guardo en memoria cada uno de los bits
		beq $t9 28 valor	
		b GuardarEmpaquetado
		
	valor:
		addi $t0 $t0 -8 	# paso a las siguientes 4 posiciones mas a la izquierdas
		li $t7 0		# reseteo t7 a 0
		li $t4 0		# $t4 guardar el valor final
		srlv $t3 $t3 $t9 	# los 4 bits mas a la izquierda los paso a la dereche
		or $t4 $t4 $t3		# $t4 tendra el valor especifico del nibble obtenido de la cadena
		beq $t4 13 negativo
		beq $t4 12 GuardarEmpaquetado
		mul $t4 $t4 $t8     	# $t4 = valor obtenido * $t8
		add $t6 $t6 $t4        # $t6 es sumar el valor obtenido
		mul $t8 $t8 $s5		# $t8 es un exponente 10^n
		b GuardarEmpaquetado
	negativo:
		li $t5 -1
		#sb $t5 numeroDecimal($t7)
		b GuardarEmpaquetado
		
	finGuardarEmpaquetado:
		mul $t6 $t6 $t5
		print_S(Mensaje4)
		print_I($t6)
		li $t0 0
		move $t0 $t6
		b menu2

Base10:  #################################################################################################

	li $v0 8
	la $a0 numeroCadena
	li $a1 33
	syscall

	li $t0 0 #En $t0 vamos a guardar el valor de la suma de los valores de la Cadena.
	li $t1 0 #$t1 nos servir� de apuntador a memoria auxiliar para recorrer la Cadena. Se pone 1 para no contar el simbolo que se introduce antes del numero.
	li $t8 0 #seteamos $t8 como verificador de negativo, si es 0 es positivo, si es 1 es negativo
	li $t6 1 #$t6 ser� el apuntador siguiente de la cadena
	li $t7 10 #$t7 ser� el multiplicador por 10 para luego sumarle el siguiente numero

	lbu $t2 numeroCadena($t1) #carga el codigo ascii del signoint en $s0
	beq $t2 45 esnegint #$t2 indice 0 es - entonces:
	beq $t2 43 esposint #t2 indice 0 es + entonces:
	b loop1int #si el primer valor de la cadena no es + o -, entonces se toma como positivo el numero y se inicia desde indice 0 el loop lector

	esposint: #funcion de primer valor de cadena como +
		li $t1 1 #se ignora el + y se continua al loop
		b loop1int

	esnegint: #funcion de primer valor de cadena como -
		li $t8 1 #se setea $t8 como positivo para verificador de negativo
		li $t1 1 #se salta el simbolo - para continuar con el numero
		b loop1int

	loop1int:
		lbu $t2 numeroCadena($t1) #carga en $t2 el contenido del slot con indice $t1 en la cadena
		beqz $t2 finLoop1 #finalizador
		beq $t2 0xA finLoop1 #finalizador 2
	
		addi $t1 $t1 1 #sumar 1 al apuntador de la cadena
		subi $t2 $t2 48 #convertir cada numero de la cadena en int normal
		add $t0 $t0 $t2 #suma el valor convertido a int en $t0
	
		addi $t6 $t6 1 #sumar 1 al apuntador a siguiente de la cadena
	
		lbu $t5 numeroCadena($t6) #carga en $t5 el valor siguiente de la cadena, apuntado por $t6
		bne $t5 0xA loop2int #asegura que el siguiente no sea fin de cadena para multiplicar por 10
		bnez $t5 loop2int #asegurador 2

		b loop1int
	
	loop2int: #literalmente multiplica por 10 el int final si tiene numero siguiente
		mulo $t0 $t0 $t7
		b loop1int

	finLoop1:
		div $t0 $t0 10 #Quitamos el excedente (no pude arreglarlo dentro del loop)
		beq $t8 0 finsignoint #verificar si es negativo

	signoint: #introduce el negativo a nuestra variable final $t0 si $t8 es 1
		mulo $t0 $t0 -1

	finsignoint:
		print_S(Mensaje4)
		print_I($t0)
		b menu2

Octal:   #################################################################################################
	li $v0 8
	la $a0 numeroCadena
	li $a1 33
	syscall

	li $t0 0 #En $t0 vamos a guardar el valor de la suma de los valores de la Cadena.
	li $t1 0 #$t1 nos servir� de apuntador a memoria auxiliar para recorrer la Cadena. Se pone 1 para no contar el simbolo que se introduce antes del numero.
	li $t8 0 #seteamos $t8 como verificador de negativo, si es 0 es positivo, si es 1 es negativo
	li $t4 0 #contador de numeros en la cadena
	li $t6 0 #$t6 ser� el apuntador auxiliar de la cadena
	li $t7 8 #$t7 ser� el multiplicador por 8 para luego sumarle el siguiente numero

	lbu $t2 numeroCadena($t1) #carga el codigo ascii del signoint en $s0
	beq $t2 45 esnegintoctal #$t2 indice 0 es - entonces:
	beq $t2 43 esposintoctal #t2 indice 0 es + entonces:
	b contadoroctal #si el primer valor de la cadena no es + o -, entonces se toma como positivo el numero y se inicia desde indice 0 el loop lector

	esposintoctal: #funcion de primer valor de cadena como +
		li $t1 1 #se ignora el + y se continua al loop
		li $t6 1 #se ignora el + y se continua al loop
		b contadoroctal

	esnegintoctal: #funcion de primer valor de cadena como -
		li $t8 1 #se setea $t8 como positivo para verificador de negativo
		li $t1 1 #se salta el simbolo - para continuar con el numero
		li $t6 1 #se salta el simbolo - para continuar con el numero
		b contadoroctal
	
	contadoroctal:
		lbu $t5 numeroCadena($t6)
		beqz $t5 fincontadoroctal #finalizador
		beq $t5 0xA fincontadoroctal #finalizador 2
	
		addi $t6 $t6 1 #sumar 1 al apuntador de la cadena
		addi $t4 $t4 1 #sumar 1 al contador de la cadena
	
		b contadoroctal
	fincontadoroctal:
		subi $t4 $t4 1 #le restamos 1 del indice 0 para usarlo entonces como auxiliar de multiplier

	loop1octal:
		lbu $t2 numeroCadena($t1)
		beqz $t2 finLoop1octal #finalizador
		beq $t2 0xA finLoop1octal #finalizador 2
	
		addi $t1 $t1 1 #sumar 1 al apuntador de la cadena
		subi $t2 $t2 48 #convertir cada numero de la cadena en int normal restandole su valor ascii
	
		li $s0 1 #seteamos $s0 a 0 para comenzar a acumular para simular un exponente
		li $t7 8 #seteamos $t7 a 8 para mantener la integridad del simulador de exponentes
		blez $t4 powzerooctal #si es nuestro ultimo valor, ira directo a la suma si tener que multiplicarse, por ser pow(0)
		
	multiplieroctal: #simulacion de exponentes
		beq $s0 $t4 finmultiplieroctal #finalizador de iteraciones
		mulo $t7 $t7 $t7 #multiplicador por el mismo (8)
		addi $s0 $s0 1 #suma 1 al contador del finalizador
		b multiplieroctal #iterador
	
	finmultiplieroctal:
		blez  $t4 powzerooctal #si es nuestro ultimo valor, no se multiplica por 8, si no q seria exponente 0, o sea por 1, que seria el mismo, por lo que no hay que multiplicarlo por nada
		mulo $t2 $t7 $t2 #como no es nuestro ultimo valor, se multiplica por lo resultante de la funcion multiplier

	powzerooctal:
		subi $t4 $t4 1 #le restamos 1 a nuestro nuevo contador de repeticiones de pow
		add $t0 $t0 $t2 #suma el valor convertido a int en $t0
		addi $t6 $t6 1 #sumar 1 al apuntador a siguiente de la cadena

	b loop1octal

	finLoop1octal:
		beq $t8 0 finsignooctal #verificar si es negativo

	signooctal: #introduce el negativo a nuestra variable final $t0 si $t8 es 1
		mulo $t0 $t0 -1

	finsignooctal:
		print_S(Mensaje4)
		print_I($t0)
		b menu2


Hexadecimal:	#########################################################################################
	li $v0 8
	la $a0 numeroHexadecimal
	li $a1 9
	syscall
	li $s6 16
	li $t6 1
	li $t0 8
	li $t3 1
	li $t5 0
	
	GuardarHex:#print_S(numeroCadena)
		li $t2 0
		addi $t0 $t0 -1			# $t0 contador + 1
		bltz $t0 finGuardarHex
		lb $t1 numeroHexadecimal($t0) 	# cargo el valor ascii de 0 o 1			
		beq $t1 0x2d negativoHex
		beq $t1 0x2b finGuardarHex
		subi $t2 $t1 0x30 		# $t2 con el bit especifico del caracter
		bgt $t2 9 restaHex
	sigamo:	
		mul $t4 $t3 $t2
		add $t5 $t5 $t4
		mul $t3 $t3 $s6			#guardo en memoria cada uno de los bits
		b GuardarHex
	restaHex:
		addi $t2 $t2 -7
		b sigamo
	
	negativoHex:
		li $t6 -1
		mul $t5 $t5 $t6
		b finGuardarHex
		
	finGuardarHex:
		print_S(Mensaje4)
		print_I($t5)
		li $t0 0
		move $t0 $t5
		b menu2
	
menu2:	################################################################################################
	print_S(Mensaje3)	
	li $v0 5
	syscall
	
	beq $v0 1 BinA2
	beq $v0 2 DecEmp
#	beq $v0 3 Bas10
#	beq 4, $v0 Oct
	beq $v0 5 Hex
	blt $v0 1 menu2
	bgt $v0 5 menu2
	li $v0 10
	syscall

BinA2: #############################################################################################
	li $v0 35
	move $a0 $t0
	syscall
	li $v0 10
	syscall
	
DecEmp: #############################################################################################
	li $t4,0x0c
   	bgez $t0 siga
     	abs $t0,$t0
     	li $t4,0x0d
	siga:  
		li $t5,0 	#registro donde quedar�n 7 decimales + el signo
      		li $t1,0 	#contador de iteraciones, debe llegar hasta 7
       		li $t2,0 	# desplazamiento variable del shift left logical )se incrementa de 4 en 4=
       		li $t9 31
       		li $t8 0       # contador de caracter
	registroEmpaquetado: 
		div $t0,$t0,10
       		mfhi $t3 	# residuo de la divisi�n va a $t3
      		sllv $t3,$t3,$t2
 		or $t5,$t5,$t3
 		addi $t1,$t1,1
 		addi $t2,$t2,4
       		blt  $t1,7,registroEmpaquetado
       		sll $t5,$t5,4
       		or $t5,$t5,$t4
       		b imprimir
       	imprimir:
       		bltz $t9 listo
       		srlv $t6 $t5 $t9
       		and $t6 $t6 0x1
       		bnez $t6 guardar
       		b guardar0
       	
       	guardar0:
       		li $t7 0x30
       		sb $t7 numeroEmpaquetado($t8)
       		addi $t8 $t8 1
       		addi $t9 $t9 -1
       		b imprimir
       	guardar:
       		li $t7 0x31
       		sb $t7 numeroEmpaquetado($t8)
       		addi $t8 $t8 1
       		addi $t9 $t9 -1
       		b imprimir
       	listo:
       		print_S(numeroEmpaquetado)
       		
#Bas10:########################################################################################################
	



Oct: #########################################################################################################




Hex: ##############################################################################
	li $s0 0x0f
	li $t1 28
	li $t9 0

	li $t4,0x2b
   	bgez $t0 convertirHexadecimal
     	mul $t0 $t0 -1
     	#print_I($t0)
     	li $t4,0x2d
	
	convertirHexadecimal:
		bltz $t1 finconvertirHexadecimal
		srlv $t2 $t0 $t1
		and $t2 $t2 $s0
		beq $t1 28 guardarSigno
		beq $t2 0 guardar0Hex
		beq $t2 1 guardar1
		beq $t2 2 guardar2
		beq $t2 3 guardar3
		beq $t2 4 guardar4
		beq $t2 5 guardar5
		beq $t2 6 guardar6
		beq $t2 7 guardar7
		beq $t2 8 guardar8
		beq $t2 9 guardar9
		beq $t2 10 guardar10
		beq $t2 11 guardar11
		beq $t2 12 guardar11
		beq $t2 13 guardar13
		beq $t2 14 guardar14
		beq $t2 15 guardar15
		
	guardar0Hex:
       		li $t7 0x30
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar1:
       		li $t7 0x31
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar2:
       		li $t7 0x32
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar3:
       		li $t7 0x33
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar4:
       		li $t7 0x34
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar5:
       		li $t7 0x35
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar6:
       		li $t7 0x36
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar7:
       		li $t7 0x37
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar8:
       		li $t7 0x38
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar9:
       		li $t7 0x39
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar10:
       		li $t7 0x41
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar11:
       		li $t7 0x42
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar12:
       		li $t7 0x43
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar13:
       		li $t7 0x44
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar14:
       		li $t7 0x45
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardar15:
       		li $t7 0x46
       		sb $t7 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
       	guardarSigno:
       		sb $t4 numeroHexadecimalSal($t9)
       		addi $t9 $t9 1
       		addi $t1 $t1 -4
       		b convertirHexadecimal
		
	finconvertirHexadecimal:
		print_S(numeroHexadecimalSal)
		li $v0 10
		syscall
	
	
	
