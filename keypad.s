#include <xc.inc>
    
global  KeyPad_Setup, KeyPad_readrow, test_none
global	KeyPad_test, key_number, KeyPad_input2, KeyPad_input4
global  set_T_low_dec, set_T_high_dec, temp
extrn	LCD_Send_Byte_D, dec_convert

    
psect	udata_acs   ; reserve data space in access ram
KeyPad_counter: ds 1	    ; reserve 1 byte for variable 
KP_cnt_l:	ds 1   ; reserve 1 byte for variable 
KP_cnt_h:	ds 1   ; reserve 1 byte for variable
KP_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
KP_tmp:		ds 1   ; reserve 1 byte for temporary use
low_bits:	ds 1
key_value:	ds 1
key_number:	ds 1
key_error:	ds 1
digit_count:	ds 1
set_T_low_dec:	ds 1
set_T_high_dec:	ds 1
temp:		ds 4
    
    
psect	Keypad_code,class=CODE
KeyPad_Setup:
    movlb   15
    bsf	    REPU
    movlb   0
    clrf    LATE, A
    ;movlw   10
    ;call    KeyPad_delay_ms
    movlw   0x00
    movwf   TRISD, A
    movlw   0x00
    movwf   key_error
    
    return
    
    
KeyPad_readrow:
    movlw   0x0f
    movwf   TRISE, A
    movlw   10
    call    KeyPad_delay_ms
    movff   PORTE, low_bits
   
    
KeyPad_readcol:
    movlw   0xf0
    movwf   TRISE, A
    movlw   10
    call    KeyPad_delay_ms
    movf    PORTE, W, A

KeyPad_value:
    iorwf   low_bits, W, A
    movwf   key_value, A
 
KeyPad_test:
    movlw	0xff
    cpfseq	key_value, A
    return
    goto	KeyPad_readrow
    
    
test_none:
    movlw   0xff
    cpfseq  key_value, A
    bra	    test_0
    retlw   0xff

test_0:
    movlw   0xBE
    cpfseq  key_value, A
    bra	    test_1
    retlw   0x30
    
test_1:
    movlw   0x77
    cpfseq  key_value, A
    bra	    test_2
    
    retlw   0x31
    
test_2:
    movlw   0xB7
    cpfseq  key_value, A
    bra	    test_3
    retlw   '2'
    
test_3:
    movlw   0xD7
    cpfseq  key_value, A
    bra	    test_4
    retlw   '3'
    
;test_F:
;    movlw   0xE7
;    cpfseq  key_value, A
;    bra	    test_4
;    retlw   'F'
    
test_4:
    movlw   0x7B
    cpfseq  key_value, A
    bra	    test_5
    retlw   '4'
    
test_5:
    movlw   0xBB
    cpfseq  key_value, A
    bra	    test_6
    retlw   '5'
    
test_6:
    movlw   0xDB
    cpfseq  key_value, A
    bra	    test_7
    retlw   '6'
    
;test_E:
;    movlw   0xEB
;    cpfseq  key_value, A
;    bra	    test_7
;    retlw   'E'
    
test_7:
    movlw   0x7D
    cpfseq  key_value, A
    bra	    test_8
    retlw   '7'
    
test_8:
    movlw   0xBD
    cpfseq  key_value, A
    bra	    test_9
    retlw   '8'

test_9:
    movlw   0xDD
    cpfseq  key_value, A
    bra	    test_error
    retlw   '9'
    
;test_D:
;    movlw   0xED
;    cpfseq  key_value, A
;    bra	    test_A
;    retlw   'D'
;    
;test_A:
;    movlw   0x7E
;    cpfseq  key_value, A
;    bra	    test_B
;    retlw   'A'
;    
;test_B:
;    movlw   0xDE
;    cpfseq  key_value, A
;    bra	    test_C
;    retlw   'B'
;    
;test_C:
;    movlw   0xEE
;    cpfseq  key_value, A
;    bra	    test_error
;    retlw   'C'
    
test_error:
    movlw   0xf0
    movwf   key_error
    retlw   0xff
    
error_identifier:
    movlw   0xf0
    cpfseq  key_error
    call    KeyPad_output
    clrf    key_error
    return
    
KeyPad_output:
    movf    key_number, W, A
    call    LCD_Send_Byte_D
    movlw   0x00
    cpfseq  digit_count
    bra	    second
    movlw   0x30
    subwf   key_number,W, A
    movwf   temp, A
    movlw   0x01
    addwf   digit_count,f, A
    movlw   1000
    call    KeyPad_delay_ms
    return
second:
    movlw   0x01
    cpfseq  digit_count
    bra	    third
    movlw   0x30
    subwf   key_number,W, A
    movwf   temp + 1, A
    movlw   0x01
    addwf   digit_count,f, A
    movlw   1000
    call    KeyPad_delay_ms
    return
third:
    movlw   0x02
    cpfseq  digit_count
    bra	    fourth
    movlw   0x30
    subwf   key_number,W, A
    movwf   temp + 2, A
    movlw   0x01
    addwf   digit_count,f, A
    movlw   1000
    call    KeyPad_delay_ms
    return
fourth:
    movlw   0x30
    subwf   key_number,W, A
    movwf   temp + 3, A
    movlw   0x01
    addwf   digit_count,f, A
    movlw   1000
    call    KeyPad_delay_ms
    return
    
    
    
    
KeyPad_input2:
    movlw   0x00
    movwf   digit_count
    
input_loop2:
    ;temp    EQU 0x30
    call    KeyPad_readrow
    call    test_none
    movwf   key_number,A
    call    error_identifier
    movlw   0x02
    cpfseq  digit_count, A
    bra	    input_loop2
    movff   temp, set_T_high_dec, A
    movff   temp+1, set_T_low_dec, A
    call    dec_convert
    return

    
KeyPad_input4:
    movlw   0x00
    movwf   digit_count
    
input_loop4:
    call    KeyPad_readrow
    call    test_none
    movwf   key_number,A
    call    error_identifier
    movlw   0x04
    cpfseq  digit_count, A
    bra	    input_loop4
    return
    
    
    
KeyPad_delay_ms:		    ; delay given in ms in W
	movwf	KP_cnt_ms, A
kplp2:	movlw	250	    ; 1 ms delay
	call	KeyPad_delay_x4us	
	decfsz	KP_cnt_ms, A
	bra	kplp2
	return
    
KeyPad_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	KP_cnt_l, A	; now need to multiply by 16
	swapf   KP_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	KP_cnt_l, W, A ; move low nibble to W
	movwf	KP_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	KP_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	KeyPad_delay
	return

KeyPad_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
kplp1:	decf 	KP_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	KP_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	kplp1		; carry, then loop again
	return		




	
	
	
