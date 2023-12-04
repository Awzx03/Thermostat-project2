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
    movwf   set_T+3
    movlw   0x02
    movwf   set_T+1
    movlw   0x08
    movwf   set_T+2
    return
PID_error:
    movff   ADC_output_array, current_T, A
    movff   ADC_output_array+1, current_T+1, A
    movff   ADC_output_array+2, current_T+2, A
    movff   ADC_output_array+3, current_T+3, A

    movf    current_T+3, W, A
    subwf   set_T+3, W, A
    movwf   error_T+3, A

    
    movf    current_T+2, W, A
    subwfb  set_T+2, W, A
    movwf   error_T+2, A
    
    movf    current_T+1, W, A
    subwfb  set_T+1, W, A
    movwf   error_T+1, A
    
    movf    current_T, W, A
    subwfb  set_T, W, A
    movwf   error_T, A
    
    return
    
    
    
       
    
    


end
