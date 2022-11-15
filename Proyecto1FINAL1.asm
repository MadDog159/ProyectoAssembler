	# Prints y Reads
	
	.macro print_int(%int)
		move	$a0, %int
		li	$v0, 1
		syscall
	.end_macro
	
	.macro print_string(%str)
		la	$a0, %str
		li	$v0, 4
		syscall
	.end_macro
	
	.macro read_int(%reg)
		li	$v0, 5
		syscall
		move	%reg, $v0
	.end_macro
	
	
	# De Romano a Decimal
	.macro getValor(%char, %res)
		
		# %char es un registro con numero ascii (byte)
		# %res registro con el valor entero (respuesta)
		
		li	$t2, 0			# Indice
		
		gvLoop:
			lb	$t3, asciiV($t2)	# Valor numerico ascii
			beq	%char, $t3, gvReturn
			addi	$t2, $t2, 1
			b	gvLoop
		
		gvReturn:
			mul	$t2, $t2, 2
		lh	%res, valor($t2)
	.end_macro
	
	.macro romanToDecimal(%str, %len, %res)
		
		# %str es la cadena compuesta SOLO de simbolos romanos
		# %len registro con longitud (en bytes) de la cadena
		# %res registro con la suma (respuesta)
		
		li	%res, 0
		li	$t7, 0		# Indice	i
		li	$t6, 0		# Indice + 1	j
		li	$t5, 0		# Simbolo 1	s1
		li	$t4, 0		# Simbolo 2	s2
		
		rtdLP:	bge	$t7, %len, rtdReturn	# if i >= cadena.length
			add	$t6, $t7, 1		# j = i + 1
			lb	$t5, %str($t7)
			getValor($t5, $t5)		# s1 = cadena[i].value
			lb	$t4, %str($t6)
			getValor($t4, $t4)		# s2 = cadena[j].value
			
			rtdif:	bge	$t5, $t4, rtdel		# if s1 >= s2
				sub	%res, %res, $t5
				addi	$t7, $t7, 1
				b	rtdLP
			
			rtdel:
				add	%res, %res, $t5
				addi	$t7, $t7, 1
				b	rtdLP
		
		rtdReturn:
			
	.end_macro
	
	
	# Obtener longitud de la String ingresada por el usuario
	.macro	validarLen(%str)
		
		li $t0,0
		li $t1,0
		
		lb $t0,%str($t1)
		
		contadorDigitos:
			lb $t0,%str($t1) #carga en $t0 el valor del string en cierto indice o posicion
	
			beqz $t0,nDigitos #ve a nDigitos si $t0 es null o 0
	
			addi $t1,$t1,1 
	
			bne $t0,0,contadorDigitos #si $t0 es diferente de 0, entonces salta a contadaorDigitos
	
		nDigitos:
		
	.end_macro 
	
	
	# Pedir numeros Romanos al Usuario
	.macro requerirNumerosRomanos()
       		 	
       		 	li  $v0,4            # despliegue del mensaje para la lectura del primer numero romano
          		la  $a0,premsj2
          		syscall
          
          
          		#lectura del primer numero romano
          		li $v0, 8
			la $a0, palabra
			li $a1, 100
			syscall    
          
          
          		li  $v0,4            # despliegue del mensaje para la lectura del segundo numero romano
          		la  $a0,premsj3
          		syscall
          
      
          		#lectura del segundo numero romano
          		li $v0, 8
			la $a0, palabra2
			li $a1, 100
			syscall

           .end_macro 
           
           # Pedir Numeros Romanos al usuario y convertirlos en Numeros Decimales
           .macro procesarInput()
           
           	# pedir los numeros al usuario
           	requerirNumerosRomanos()
           	
           	# obtener el length del primer numero
           	validarLen(palabra)
           	sub $t1, $t1, 1		#Restar el salto de linea
           	
           	# convertir de Romano a Decimal
           	romanToDecimal(palabra, $t1, $t8)   #Guardo en $t8 el numero en decimal
           	
           	# obtener el length del primer numero
           	validarLen(palabra2)
           	sub $t1, $t1, 1		#Restar el salto de linea
           	
           	# convertir de Romano a Decimal
           	romanToDecimal(palabra2, $t1, $t9)   #Guardo en $t9 el numero en decimal
           
           .end_macro
           
           
           # Operaciones
           
           .macro suma()
           	
           	li  $v0,4            # despliegue del mensaje de opcion Suma
          	la  $a0,msjSuma
          	syscall
          	
           	# realizar operacion
           	add $t1, $t8, $t9
           	
           .end_macro 
           
           .macro resta()
           
           	li  $v0,4            # despliegue del mensaje de opcion Resta
          	la  $a0,msjResta
          	syscall
           	
           	# realizar operacion
           	sub $t1, $t8, $t9
           	
           .end_macro 
           
           .macro multiplicacion()
           
           	li  $v0,4            # despliegue del mensaje de opcion Multipliacion
          	la  $a0,msjMultipliacion
          	syscall
           	
           	# realizar operacion
           	mult $t8, $t9
           	mflo $t1
           	
           .end_macro 
           
           
           # Mostrar Opciones de Suma-Resta-Multiplicacion y realizar la operacion
           .macro opciones()
           		li  $v0,4            # despliegue del mensaje de bienvenida y menu de opciones
          		la  $a0,premsj1
          		syscall
          
          
          		#lectura de opcion marcada del menu por el usuario
          		li $v0,5
          		syscall
          		move $t0,$v0    
          
           		beq $t0,1,realizarSuma
           		beq $t0,2,realizarResta
           		beq $t0,3,realizarMultiplicacion
           		bgt $t0,3,FIN
           	
           	realizarSuma:
           		procesarInput()
           		suma()
           		FINALIZAR
           		
           		
           	realizarResta:
           		procesarInput()
           		resta()
           		FINALIZAR
           		
           		
           	realizarMultiplicacion:
           		procesarInput()
           		multiplicacion()
           		FINALIZAR
           		
           		
           	FIN:	
           		li  $v0,4            # despliegue del mensaje de opcion ingresada no valida
          		la  $a0,msjNotValid
          		syscall
           		
           		li  $v0,10           # fin del programa
          		syscall
           		
           .end_macro 
           
	# De Decimal a Romano
	
	   .macro pushChar1(%chari, %i, %t)
		# %chari, registro con indice de character que se tienen que agregar
		# %i, registro de indice de respuesta donde se compienza a agregar
		# %t, cantidad de veces que se agrega
		
		lb	$t9, asciiV(%chari)	# $t5 tiene el valos ascii del caracter que se tiene que push
		
		ps1LP:	beqz	%t, ps1Return
			sb	$t9, res(%i)
			addi	%i, %i, 1
			subi	%t, %t, 1
			b	ps1LP
		ps1Return:
	.end_macro
	
	.macro	pushChar2(%chari, %i, %t)
		# %chari, indice de character(es) que se tienen que agregar
		# %i, indice donde se compienza a agregar
		# %t, cantidad de veces que se agrega
		
		lb	$t9, asciiM(%chari)	# $t5 tiene el valos ascii del caracter que se tiene que push
		add	$t8, %chari, 1
		lb	$t8, asciiM($t8)
		
		ps2LP:	beqz	%t, ps2Return
			sb	$t9, res(%i)
			addi	%i, %i, 1
			sb	$t8, res(%i)
			addi	%i, %i, 1
			subi	%t, %t, 1
			b	ps2LP
		ps2Return:
	.end_macro
	
	.macro decimalToRoman(%num)
		# %num registro donde esta numero entero
		li	$t6, 0		# Indice de respuesta
			
		bgtz	%num, dtrLP	# Si es positivo (num > 0) => comenzar rutina normal
		# Si es negativo:
		mul	%num, %num, -1	# Convertimos en positivo
		li	$t5, 45		# ascii(45) = "-"
		sb	$t5, res($t6)	# En la primera posicion esta "-"
		addi	$t6, $t6, 1	# Incrementamos indice porque primer posicion ocupada

		dtrLP:	beqz	%num, dtrReturn
		
		drtIF1:	blt	%num, 1000, drtIF2	# if num >= 1000: [1000, inf)
			div 	%num, %num, 1000	# en %num esta el quotiant
			li	$t5, 6			# Indice de char V (asciicV(6) = 'M')
			pushChar1($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF2:	blt	%num, 900, drtIF3	# if 1000 > num >= 900: [900, 999]
			div 	%num, %num, 900		# en %num esta el quotiant
			li	$t5, 10			# Indice de char M (asciicM(10) = 'CM')
			pushChar2($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
		
		drtIF3:	blt	%num, 500, drtIF4	# if 900 > num >= 500: [500, 899]
			div 	%num, %num, 500		# en %num esta el quotiant
			li	$t5, 5			# Indice de char V (asciicV(5) = 'D')
			pushChar1($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF4:	blt	%num, 400, drtIF5	# if 500 > num >= 400: [400, 499]
			div 	%num, %num, 400		# en %num esta el quotiant
			li	$t5, 8			# Indice de char M (asciicM(8) = 'CD')
			pushChar2($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF5:	blt	%num, 100, drtIF6	# if 400 > num >= 100: [100, 399]
			div 	%num, %num, 100		# en %num esta el quotiant
			li	$t5, 4			# Indice de char V (asciicV(4) = 'C')
			pushChar1($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF6:	blt	%num, 90, drtIF7	# if 100 > num >= 90: [90, 99]
			div 	%num, %num, 90		# en %num esta el quotiant
			li	$t5, 6			# Indice de char M (asciicM(6) = 'XC')
			pushChar2($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
		
		drtIF7:	blt	%num, 50, drtIF8	# if 90 > num >= 50: [50, 89]
			div 	%num, %num, 50		# en %num esta el quotiant
			li	$t5, 3			# Indice de char V (asciicV(3) = 'L')
			pushChar1($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
		
		drtIF8:	blt	%num, 40, drtIF9	# if 50 > num >= 40: [40, 49]
			div 	%num, %num, 40		# en %num esta el quotiant
			li	$t5, 4			# Indice de char M (asciicM(4) = 'XL')
			pushChar2($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF9:	blt	%num, 10, drtIF10	# if 40 > num >= 10: [10, 39]
			div 	%num, %num, 10		# en %num esta el quotiant
			li	$t5, 2			# Indice de char V (asciicV(2) = 'X')
			pushChar1($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF10:blt	%num, 9, drtIF11		# if 10 > num >= 9: [9]
			div 	%num, %num, 9		# en %num esta el quotiant
			li	$t5, 2			# Indice de char M (asciicM(2) = 'IX')
			pushChar2($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF11:blt	%num, 5, drtIF12	# if 9 > num >= 5: [5, 8]
			div 	%num, %num, 5		# en %num esta el quotiant
			li	$t5, 1			# Indice de char V (asciicV(1) = 'V')
			pushChar1($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF12:blt	%num, 4, drtIF13	# if 5 > num >= 4: [4]
			div 	%num, %num, 4		# en %num esta el quotiant
			li	$t5, 0			# Indice de char M (asciicM(0) = 'IV')
			pushChar2($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
			
		drtIF13:				# if 4 > num >= 1: [1, 3]
			div 	%num, %num, 1		# en %num esta el quotiant
			li	$t5, 0			# Indice de char V (asciicV(0) = 'I')
			pushChar1($t5, $t6, %num)
			mfhi	%num			# ahora en %num esta el reminder
			b	dtrLP
		dtrReturn:
	.end_macro
	
	.macro FINALIZAR()
           
           	print_string(msjRespuesta) # En $t1 esta la respueta
           	beqz	$t1, skip
           	decimalToRoman($t1)
           	print_string(res)
           	b jump1
           	skip:
           	print_string(nada)
           	jump1:
           	li  $v0,4            # despliegue del mensaje de Fin del programa
          	la  $a0,msjFIN
          	syscall
           		
           	
           	li  $v0,10           # fin del programa
          	syscall
           .end_macro 

	.data	# Segmento de data

palabra: .space 101
palabra2: .space 101


	#	I    V    X    L    C    D    M    \n
asciiV:	.byte	73   86   88   76   67   68   77   10
valor:	.half	1    5    10   50   100  500  1000  0

	#	IV	IX	XL	XC	CD	CM
asciiM:	.byte	73 86	73 88	88 76	88 67	67 68	67 77
	#	4	9	40	90	400	900

	# NOTA: un (1) character ascii se guarda en un (1) byte
	# en .space x, se puede guardar x - 1 characteres ascii
	
salto:	.asciiz	"\n"
premsj1: .asciiz "***BIENVENIDO***\nEste programa te proveera opciones para realizar operaciones operaciones aritmeticas entre numeros romanos.\n***MENU DE OPCIONES*** \nIngresa 1 para sumar.\nIngresa 2 para restar.\nIngresa 3 para multiplicar.\n===>  "
premsj2: .asciiz "Introduce el primer numero romano:\n===>  "
premsj3: .asciiz "Introduce el segundo numero romano:\n===>  "
msjNotValid: .asciiz "No se ha escogido una opcion valida" 
msjSuma: .asciiz "***SUMA DE NUMEROS ROMANOS***\n"
msjResta: .asciiz "***RESTA DE NUMEROS ROMANOS***\n"
msjMultipliacion: .asciiz "***MULTIPLIACION DE NUMEROS ROMANOS***\n"
msjRespuesta: .asciiz "El resultado de la operacion es: "
msjFIN: .asciiz "\n***FIN DEL PROGRAMA***"
nada:	.asciiz "NADA"
res:	.space 	21	# 16 bits para guardar resultado. Maximo un numero de 20 caracteres (1 para signo)

	.text	# Segmento de instrucciones
	
	# Aqui corre el programa
	opciones()

