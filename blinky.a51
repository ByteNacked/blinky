; ************************************************************************
; Source file		: blinky.a51
; Project		: 
; Version		:
; Date			: 
; Student		: 
; University		: SPbPU

; Chip type		: 80C515
; Clock frequency	: 12 MHz
; Memory model		: Small
; Internal RAM size	: 256
; External RAM size	: 0
; Data Stack size	: 48
; Cross assembler	: ASEM-51 v 1.1
; ************************************************************************

$NOMOD51				; отключаем стандартную библиотеку функций x51-процессоров, чтобы позже подключить свою
;$NOPAGING				; разбиение на страницы
$INCLUDE (80C515.MCU)	; подключаем свою библиотеку функций

LONG_BUTTON_DELAY equ 05h 
;-------------------------------------------------------------------------
; Конфигурирование аппаратуры

BUTTON	BIT	P1.0
LED 	BIT P1.1
;-------------------------------------------------------------------------
; Резервирование внутренней памяти данных под переменные и стек
DSEG	at 	020h		
Counter:		DS	1	
Switch:		DS	1	 
Sign:		DS	1 		 		 
//DisplayPhase:	DS	1 	 
//Digit0: 	DS	1 		
//Digit1:    	DS	1 	 

stackArea:	DS	48		; стек по адресу 020h + 6 = 026h

CSEG					; сегмент КОДА
;-------------------------------------------------------------------------
; Таблица векторов прерывания

	ORG	RESET			
	jmp	Init  		
	reti

;-------------------------------------------------------------------------
; Инициализация МК и дисплея

Init:
	mov Counter, #00h;
	mov Switch, #00h;
	CAll MainLoop

MainLoop:

	CALL ledDelay
	CALL countIterationIfPressed			
	//CALL checkIfReleased


   cpl LED

jmp MainLoop


ledDelay:
	
		mov	r0,#03h
	outerCicle:
		mov	r1,#00h
	innerCicle:
		mov r2,#00h
		djnz r2, $ 
		djnz r1,innerCicle
		djnz r0,outerCicle

ret

countIterationIfPressed:
	
	jb BUTTON, checkIfReleased
	inc Counter
	ret
		
checkIfReleased:
	mov R3, Counter
	cjne R3, #00h, L1 
	ret   //Button was not pressed (Counter = 0)
			
	L1:
	CALL determineLonginessOfPress
	mov Counter, #00h					   //RESET counter for next button press/release cycle
	 
ret

determineLonginessOfPress:
	mov A, R3
	subb A, #05h//LONG_BUTTON_DELAY	 //Why dont work with constant?
	mov Sign, A	


	JB Sign.7, S1
	   CALL LongPressHandler	 // if LONG_BUTTON_DELAY >= Counter (LongPress)

	ret
					 // if LONG_BUTTON_DELAY < Counter (ShortPress)  
	S1: 
	CAll ShortPressHandler
	
ret


LongPressHandler:
   mov Switch, #02h
ret

ShortPressHandler:
   mov Switch, #01h
ret

END


