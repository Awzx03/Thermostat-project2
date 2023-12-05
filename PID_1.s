#include <xc.inc>
    
global  PID_error, PID_Setup
extrn	ADC_Setup, ADC_Output, Thermal_sensor_read, ADC_output_array
    
psect	udata_acs   ; reserve data space in access ram
Kp	    equ 1
;Ki:	    equ 0.01
;Kd:	    equ 0.005
	    	
set_T:	    ds 4
current_T:  ds 4
error_T:    ds 4
Output	    equ 0x40
    
psect	uart_code,class=CODE
PID_Setup:
    movlw   0x00
    movwf   set_T
    movlw   0x12
    movwf   set_T+1
    return
PID_error:
    movff   ADC_output_array, current_T, A
    movff   ADC_output_array+1, current_T+1, A
    movff   ADC_output_array+2, current_T+2, A
    movff   ADC_output_array+3, current_T+3, A

    swapf   current_T+3, f, A
    movf    current_T+3, W, A

    
    swapf   current_T+1, f, A
    movf    current_T+1, W, A
    iorwf   current_T+2, f, A
    return
    
    
    
       
dec_convert3:
    movlw   0xF6
    subwf   error_T+3, f, A
    return


end
