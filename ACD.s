#include <xc.inc>

global  ADC_Setup, ADC_Output, Thermal_sensor_read, ADC_output_array,UART_transmit
extrn	LCD_Send_Byte_D, LCD_delay_ms
extrn   UART_Transmit_Byte
psect	udata_acs   ; reserve data space in access ram
RES3:	    ds 1
RES2:	    ds 1
RES1:	    ds 1
RES0:	    ds 1
RES33:	    ds 1
RES22:	    ds 1
RES11:	    ds 1
RES00:	    ds 1
k_high:	    ds 1
k_low:	    ds 1
LCD_counter:	    ds 1
ADC_output_array:   ds 4
    
	
psect	adc_code, class=CODE

ADC_Setup:
	bsf	TRISA, PORTA_RA3_POSN, A  ; pin RA3==AN0 input
	movlb	0x0f
	bsf	ANSEL3	    ; set AN0 to analog
	movlb	0x00
	movlw   0x0D	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

Thermal_sensor_read:
	call	ADC_Read
	
	lfsr	1, ADC_output_array
	call	ADC_Mul_k
	call	ADC_Mul_10
	call	ADC_Mul_10
	call	ADC_Mul_10
	return
	
	
	
ADC_Mul_k:
	movlw	0x41
	movwf	k_high
	movlw	0x8a
	movwf	k_low
	MOVF	ADRESL, W, A
	MULWF	k_low, A
	MOVFF	PRODH, RES1 ;
	MOVFF	PRODL, RES0 ;
	;
	MOVF	ADRESH, W, A
	MULWF	k_high, A 
	MOVFF	PRODH, RES3 ;
	MOVFF	PRODL, RES2 ;
	;
	MOVF	ADRESL, W, A
	MULWF	k_high ; ARG1L * ARG2H->
	; PRODH:PRODL
	MOVF	PRODL, W, A ;
	ADDWF	RES1, F ; Add cross
	MOVF	PRODH, W, A ; products
	ADDWFC	RES2, F ;
	CLRF	WREG ;
	ADDWFC	RES3, F ;
	;
	MOVF	ADRESH, W, A ;
	MULWF	k_low ; ARG1H * ARG2L->
	; PRODH:PRODL
	MOVF	PRODL, W, A ;
	ADDWF	RES1, F ; Add cross
	MOVF	PRODH, W, A ; products
	ADDWFC	RES2, F ;
	CLRF	WREG ;
	ADDWFC	RES3, F ;
	movff	RES3, POSTINC1
	return
	
ADC_Mul_10:
	movlw	0x0a
	movwf	k_low
	MOVF	RES0, W, A
	MULWF	k_low, A
	MOVFF	PRODH, RES11 ;
	MOVFF	PRODL, RES00 ;
	;
	MOVF	RES2, W, A
	MULWF	k_low, A 
	MOVFF	PRODH, RES33 ;
	MOVFF	PRODL, RES22 ;
	
	MOVF	RES1, W, A
	MULWF	k_low, A ; ARG1L * ARG2H->
	; PRODH:PRODL
	MOVF	PRODL, W, A ;
	ADDWF	RES11, F ; Add cross
	MOVF	PRODH, W, A ; products
	ADDWFC	RES22, F ;
	CLRF	WREG ;
	ADDWFC	RES33, F ;
	movff	RES00, RES0
	movff	RES11, RES1
	movff	RES22, RES2
	movff	RES33, RES3
	movff	RES3, POSTINC1
	return
	
ADC_Output:
	movf	ADC_output_array+1, W, A
	addlw	'0'
	call    LCD_Send_Byte_D
	movf	ADC_output_array+2, W, A
	addlw	'0'
	call    LCD_Send_Byte_D
	
	movlw	'.'
	call    LCD_Send_Byte_D
	
	movf	ADC_output_array+3, W, A
	addlw	'0'
	call    LCD_Send_Byte_D
	
	movlw	0xFA
	call	LCD_delay_ms
	movlw	0xFA
	call	LCD_delay_ms
	movlw	0xFA
	call	LCD_delay_ms
	movlw	0xFA
	call	LCD_delay_ms
	movlw	0xFA
	call	LCD_delay_ms
	movlw	0xFA
	call	LCD_delay_ms

	return
	
UART_transmit:
	movf	ADRESH, W, A
	call	UART_Transmit_Byte
	movf	ADRESL, W, A
	call	UART_Transmit_Byte
	return
	
    
end