#include <xc.inc>

;extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_line2, LCD_clear ; external LCD subroutines
extrn	ADC_Setup, ADC_Output, Thermal_sensor_read		   ; external ADC subroutines
extrn   KeyPad_Setup,KeyPad_input2, key_number, KeyPad_input4
extrn	PID_error, PID_Setup, PID_output
extrn	PWM_Setup, PWM_update
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
temp_low:   ds 1
temp_high:  ds 1
    
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'T', 'E', 'M','P','E','R', 'A', 'T','U','R','E',':',0x0a
	myTable_l   EQU	13	; length of data
	align	2
	
myTable2:
	db	'T', 'I', 'M','E',':',0x0a
	myTable_2   EQU	6	; length of data
	align	2

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	;call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	ADC_Setup	; setup ADC
	call    KeyPad_Setup
	call	PID_Setup
	call	PWM_Setup
	goto	first_line
	
	; ******* Main programme ****************************************
first_line: 	
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loop1: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop1		; keep going until finished
		
	movlw	myTable_l-1	; output message to LCD
				; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	call	input2
	
second_line:
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable2)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable2)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable2)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_2	; bytes to read
	movwf 	counter, A		; our counter register
loop2: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop2		; keep going until finished
	movlw	myTable_2-1	; output message to LCD
				; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	call	input4
    
input2:
	call    KeyPad_input2
	movff	0x30, PORTD, A
	call	LCD_line2
	movlw	0x32
	goto	second_line

input4:
	call    KeyPad_input4
	movff	0x30, PORTD, A
	call	LCD_clear
	goto	Temp_display
	
Temp_display:
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loopT: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loopT		; keep going until finished

	movlw	myTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	goto	negative_feedback_loop

negative_feedback_loop:
	call	LCD_line2
	call	Thermal_sensor_read
	call	ADC_Output
	call	PID_error
	call	PID_output
	call	PWM_update
	goto	negative_feedback_loop	
	
	
	
	
	
	
;measure_loop:
;	call	ADC_Read
;	movf	ADRESH, W, A
;	call	LCD_Write_Hex
;	movf	ADRESL, W, A
;	call	LCD_Write_Hex
;	goto	measure_loop		; goto current line in code
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst