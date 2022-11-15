.macro print(%x)
	li $v0 4
	la $a0 %x 
	syscall
.end_macro

.macro printNum(%y)
	li $v0 1
	move $a0 %y
	syscall
.end_macro

.data

	mensajeInicial: .asciiz "\nBienvenidos a la Calculadora \n"
	salto: .asciiz "\n"
	msjError: .asciiz "ERROR\n"
	mensajeConvertir: .asciiz "El sistema de numeración a convertir es:\n\nBinario Complemento a Dos[1], Decimal Empaquetado[2], Base 10[3], Octal[4], Hexadecimal[5] \n"
	mensajeConvertir2: .asciiz "El sistema de numeración al que se convertira es:\n\nBinario Complemento a Dos[1], Decimal Empaquetado[2], Base 10[3], Octal[4], Hexadecimal[5] \n"
	msjIntroduzcaNum: .asciiz "Introduzca el numero: "
	mensajeDec: .asciiz "El resultado es: "
	numero: .space 33
	signo: .space 2
.text

	li $s2 0 #primera posicion
	li $s0 2 #constante a multiplicar o dividir

	print(mensajeInicial)
	print(mensajeConvertir)
	li $v0 5
	syscall
	move $t0 $v0
	print(salto)
	print(msjIntroduzcaNum)
	
	beq $t0 1 continueBinario #Binario complemento a dos
	beq $t0 2 continueBinario
	beq $t0 3 continueBinario
	beq $t0 4 continueBinario
	beq $t0 5 continueBinario
	
	error:
		print(msjError)
		li $v0 10		#imprimir el mensaje de error
		syscall
	
	continueBinario:
		li $v0 8
		la $a0 numero		#guardar el binario en memoria
		li $a1 33
		syscall
		
	li $t1 0
	lb $t2 numero($t1)
	beq $t2 0x30 esBinario
	recorrido:
		lb $t2 numero($t1)
		beq $t2 0x00 primeraResta #0x00 es el caracter nulo en ascii hex
		beq $t2 0xA primeraResta # 0xA es el enter en ascii hex
		addi $t1 $t1 1
		b recorrido
	
	primeraResta:
		subi $t1 $t1 1 
		li $t9 0
		add $t9 $t9 $t1 #Ultima Posicion duplicada para convertir el numero a decimal
		
	
	restaNumero:
		beq $t1 -1 convierteDecimal
		lb $t2 numero($t1)
		beq $t2 0x30 volver		#si el numero cargado es 0 se cambia por un 1 y si es 1 se cambia por un 0 y se detiene en este ultimo caso
		beq $t2 0x31 finalizaResta
		b error
		
		volver:
			li $t2 0x31
			sb $t2 numero($t1)
			subi $t1 $t1 1		#fue un cero el numero cargado
			b restaNumero
		
		finalizaResta:
			li $t2 0x30
			sb $t2 numero($t1)
			b convierteDecimal	#fue un uno el numero cargado
	
	convierteDecimal:
		print(salto)
		print(numero)
		li $t3 1 #numero a sumar
		lb $t2 numero($t9) #el $t9 contiene la posicion del bit menos significativo
		li $t4 0x2D
		sb $t4 signo($s2) 
		beq $t2 0x30 iniciaEnCero 
		beq $t2 0x31 iniciaEnUno 
		
		iniciaEnUno:
		li $t0 0 #resultado en decimal
		b sigueDecimal
	
		iniciaEnCero:
		li $t0 1 #resultado en decimal
		b sigueDecimal
		
		sigueDecimal:
			mul $t3 $t3 $s0
			subi $t9 $t9 1
			lb $t2 numero($t9)
			beq $t2 0x00 convertirPara
			beq $t2 0x30 sumaPana
			beq $t2 0x31 noSume
			
			sumaPana:
				add $t0 $t0 $t3
				b sigueDecimal
				
			noSume:
				b sigueDecimal

	esBinario: #esto aplica para los positivos
		
		recorrido2:
		lb $t2 numero($t1)
		beq $t2 0x00 primeraResta2 #0x00 es el caracter nulo en ascii hex
		beq $t2 0xA primeraResta2 # 0xA es el enter en ascii hex
		addi $t1 $t1 1
		b recorrido2
	
		primeraResta2:
		subi $t1 $t1 1 
		li $t9 0
		add $t9 $t9 $t1 #Ultima Posicion duplicada para convertir el numero a decimal
		
		print(salto)
		print(numero)
		li $t3 1 #numero a sumar
		lb $t2 numero($t9) #el $t9 contiene la posicion del bit menos significativo
		li $t4 0x2B
		sb $t4 signo($s2) 
		beq $t2 0x31 iniciaEnUno2
		beq $t2 0x30 iniciaEnCero2
		
		iniciaEnCero2:
		li $t0 0 #resultado en decimal
		b sigueDecimal2
	
		iniciaEnUno2:
		li $t0 1 #resultado en decimal
		b sigueDecimal2
		
		sigueDecimal2:
			mul $t3 $t3 $s0
			subi $t9 $t9 1
			lb $t2 numero($t9)
			beq $t2 0x00 convertirPara
			beq $t2 0x31 sumaPana2
			beq $t2 0x30 noSume2
			
			sumaPana2:
				add $t0 $t0 $t3
				b sigueDecimal2
				
			noSume2:
				b sigueDecimal2
	
			
	convertirPara:
		print(salto)
		print(mensajeDec)
		print(signo)
		printNum($t0)
		print(salto)
		print(mensajeConvertir2)
		move $t1 $t0	#numero convertido a decimal
		lb $t2 signo($s2) #signo en hex
		
		li $v0 5
		syscall
		move $t0 $v0
		
		beq $t0 1 resultadoBinario #Binario complemento a dos
		beq $t0 2 resultadoBinario
		beq $t0 3 resultadoBinario
		beq $t0 4 resultadoBinario
		beq $t0 5 resultadoBinario
	
	resultadoBinario:
		lb $t2 signo($s2) #se evalua el signo para ver como convertir a complemento a dos
		beq $t2 0x2B conversionPositiva
		
	
	conversionPositiva:

		restaUno:
			subi $t1 $t1 1
			b conversionPositiva
		
		   
	final:
		li $v0 10
		syscall
	
