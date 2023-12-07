#include <xc.inc>
    
global  PID_error, PID_Setup, dec_convert, PWM_output, PID_output
extrn	ADC_Setup, ADC_Output, Thermal_sensor_read, ADC_output_array
    
psect	udata_acs   ; reserve data space in access ram
Kp	    equ 1
;Ki:	    equ 0.01
;Kd:	    equ 0.005
	    	
set_T:			ds 2
current_T_low:		ds 1
current_T_high:		ds 1
former_e_low:		ds 1
former_e_high:		ds 1
error_T_low:		ds 1
error_T_high:		ds 1
error_sum_low:		ds 1
error_sum_high:		ds 1
error_d_low:		ds 1
error_d_high:		ds 2
time_count:		ds 2
set_T_low:		ds 1
set_T_high:		ds 1
PWM_output:		ds 1

	    
psect	uart_code,class=CODE
PID_Setup:
    clrf    error_sum_low, A
    clrf    error_sum_high, A
    clrf    set_T_low, A
    clrf    set_T_high, A
    clrf    time_count, A
    clrf    former_e_low
    clrf    former_e_high
    call    dec_convert
    return
    
    
PID_error:
    movlw   0x01
    addwf   time_count
    movff   ADRESL, current_T_low, A
    movff   ADRESH, current_T_high, A
    
    movf    current_T_low, W, A
    subwf   set_T_low, W, A
    movwf   error_T_low
    movf    current_T_high, W, A
    subwfb  set_T_high, W, A
    movwf   error_T_high
    

PID_integral:
    movf    error_T_low, W, A
    addwf   error_sum_low, f, A
    movf    error_T_high, W, A
    addwfc  error_sum_high, f, A

PID_derivative: 
    
    movf    former_e_low, W, A
    subwf   error_T_low, W, A
    movwf   error_d_low
    movf    former_e_high, W, A
    subwfb  error_T_high, W, A
    movwf   error_d_high
    
    movff   error_T_low, former_e_low, A
    movff   error_T_high, former_e_high, A
    return
    
    
  
; PID_error:
;     movff   ADC_output_array, current_T, A
;     movff   ADC_output_array+1, current_T+1, A
;     movff   ADC_output_array+2, current_T+2, A
;     movff   ADC_output_array+3, current_T+3, A
; 
;     swapf   current_T+3, f, A
;     movf    current_T+3, W, A
; 
;     
;     swapf   current_T+1, f, A
;     movf    current_T+1, W, A
;     iorwf   current_T+2, f, A
;     return
    
dec_convert:
    movlw   0x02
    movwf   0x40, A
    movlw   0x08
    movwf   0x41, A
   
    
    
convert_loop1:
    movlw   0x00
    cpfseq  0x41, A
    goto    add_10
    goto    add_100
   
add_10:
    movlw   0x01
    subwf   0x41, f, A
    
    movlw   0x0A
    addwf   set_T_low, f, A
    movlw   0x00
    addwfc  set_T_high, f, A
    goto    convert_loop1 
    
convert_loop2:
    movlw   0x00
    cpfseq  0x40, A
    goto    add_100
    return
    
add_100:
    movlw   0x01
    subwf   0x40, f, A
    movlw   0x64
    addwf   set_T_low, f, A
    movlw   0x00
    addwfc  set_T_high, f, A
    goto    convert_loop2
    


PID_output:
   ; movlw   0xf
    ;cpfsgt  
    
    movlw   0x64
    cpfsgt  error_T_low, A
    goto    P_control
    movlw   0xf9
    movwf   PWM_output
    return
    
P_control:
    movlw   0x02
    mulwf   error_T_low, A
    movff   PRODL, PWM_output
    return
    


    
    
    
end
