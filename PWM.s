#include <xc.inc>
    
global  PWM_Setup, PWM_update
extrn	ADC_Setup, ADC_Output, Thermal_sensor_read, ADC_output_array
extrn	PWM_output
    
psect	udata_acs   ; reserve data space in access ram
duty_cycle	    equ 0x40
    
psect	uart_code,class=CODE
PWM_Setup:
    bcf	    TRISC, PORTC_RC2_POSN, A 
    bcf	    TRISG, PORTG_RG3_POSN, A 
    movlw   0x3C
    movwf   CCP4CON, A
    movlw   0xF9
    movwf   CCPR4L, A
    movlw   0x00
    movwf   CCPR4H, A	;set duty cycle 100%
    movlw   0x06
    movwf   T2CON, A
    movlw   0xF9
    movwf   PR2		;period 0.25ms
    clrf    CCPTMRS1
    return
    
    
PWM_update:
    movf    PWM_output, W, A
    movwf   CCPR4L, A
    return


end
