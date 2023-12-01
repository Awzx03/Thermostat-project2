#include <xc.inc>
extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_D, LCD_line2 ; external LCD subroutines
extrn	ADC_Setup,ADC_Output, Thermal_sensor_read		   ; external ADC subroutines

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine

    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
Temp_array:    ds 0x80 ; reserve 128 bytes for message data
;
psect	data    
;	; ******* myTable, data in programme memory, and its length *****
Temp_display:
	db	'T','E','M','P','E','R','A','T','U','R','E',':', 0x0a
;					; message, plus carriage return
	length   EQU	13	; length of data
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
	goto	start
	
	; ******* Main programme ****************************************
start: 	lfsr	0, Temp_array	; Load FSR0 with address in RAM	
	movlw	low highword(Temp_display)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(Temp_display)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(Temp_display)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	length	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished

	movlw	length	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, Temp_array
	call	LCD_Write_Message
	
measure_loop:
	call	LCD_line2
	call	Thermal_sensor_read

	call	ADC_Output
	goto	measure_loop	; goto current line in code
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst
