#include <xc.inc>
    
global  PID_error, PID_Setup, dec_convert, PWM_output, PID_output
global	error_sum_low, error_sum_high, time_count_l, time_count_h
extrn	ADC_Setup, ADC_Output, Thermal_sensor_read, ADC_output_array
extrn	Divide_start, div_result
    
psect	udata_acs   ; reserve data space in access ram
Kp	    equ 1

current_T_low:		ds 1
current_T_high:		ds 1
former_e_low:		ds 1
former_e_high:		ds 1
error_T_low:		ds 1
error_T_high:		ds 1
error_sum_low:		ds 1
error_sum_high:		ds 1
error_d_low:		ds 1
error_d_high:		ds 1
time_count_l:		ds 1
time_count_h:		ds 1
set_T_low:		ds 1
set_T_high:		ds 1
    

Output_l:		ds 1
Output_h:		ds 1
    
    
I_output_l:		ds 1
I_output_h:		ds 1
D_output_l:		ds 1
D_output_h:		ds 1
    
PWM_output:		ds 1
psect	uart_code,class=CODE
PID_Setup:
    clrf    error_sum_low, A
    clrf    error_sum_high, A
    clrf    error_T_low, A
    clrf    error_T_high, A
    clrf    Output_l, A
    clrf    Output_h, A
    clrf    set_T_low, A
    clrf    set_T_high, A
    clrf    time_count_l, A
    clrf    time_count_h, A
    clrf    former_e_low
    clrf    former_e_high
    call    dec_convert
    
    return
    
    
PID_error:
    movlw   0x01
    addwf   time_count_l
    movlw   0x00
    addwfc  time_count_h
    movff   ADRESL, current_T_low, A
    movff   ADRESH, current_T_high, A
    
    movf    current_T_low, W, A
    subwf   set_T_low, W, A
    movwf   error_T_low
    movf    current_T_high, W, A
    subwfb  set_T_high, W, A
    movwf   error_T_high
  
    movf    error_T_low, W, A
    addwf   Output_l, f, A
    movf    error_T_high, W, A
    addwfc  Output_h, f, A
    

PID_integral:
    movf    error_T_low, W, A
    addwf   error_sum_low, f, A
    movf    error_T_high, W, A
    addwfc  error_sum_high, f, A
    call    Divide_start
    rrcf    div_result, f, A
    movf    div_result, W, A
    addwf   Output_l, f, A
    movlw   0x00
    addwfc  Output_h, f, A
    
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
    

PID_output:
    movlw   0xf0
    cpfslt  error_T_high, A
    goto    turn_off		;turn off when temperature is higher than set T
    goto    PID_switch
    
 
PID_switch:
    movlw   0x3E		;6.2 degrees difference
    cpfsgt  error_T_low, A
    goto    P_control
    movlw   0xf9
    movwf   PWM_output
    return
    
P_control:
    movlw   0x04
    mulwf   error_T_low, A
    movff   PRODL, PWM_output
    return

I_control:
    
 
turn_off:
    movlw   0x00
    movwf   PWM_output
    return


    
    
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
    


    
    
end
