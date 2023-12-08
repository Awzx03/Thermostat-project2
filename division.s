#include <xc.inc>
    
global	Divide_start, div_result
extrn  PID_error, PID_Setup, dec_convert, PWM_output, PID_output
extrn	ADC_Setup, ADC_Output, Thermal_sensor_read, ADC_output_array
extrn   error_sum_low, error_sum_high, time_count_l, time_count_h
    
psect	udata_acs   ; reserve data space in access ram	    	

numerator_low:		ds 1
numerator_high:		ds 1
div_result:		ds 1

	    
psect	uart_code,class=CODE
Divide_start:
    movff   error_sum_low, numerator_low, A
    movff   error_sum_high, numerator_high, A
    clrf    div_result, A
Divide_loop:
    bcf	    STATUS, 0
    movf    time_count_l, W, A
    subwf   numerator_low, f, A
    movf    time_count_h, W, A
    subwfb  numerator_high, f, A
    btfsc   STATUS, 0
    goto    result_loop
    return
    

result_loop:
    movlw   0x01
    addwf   div_result, f, A
    bra	    Divide_loop

   
    
end
