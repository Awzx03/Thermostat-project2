#include <xc.inc>
    
global  PID_error
extrn	ADC_Setup, ADC_Output, Thermal_sensor_read, ADC_output_array
    
psect	udata_acs   ; reserve data space in access ram
Kp:	    equ 0.1
Ki:	    equ 0.01
Kd:	    equ 0.005
	    	
set_T:	    ds 4
current_T:  ds 4-
error:	    ds 10	    ; reserve 1 byte for variable UART_counter
Output:	    equ 0x40
    
psect	uart_code,class=CODE

PID_error:
    
    
    
       
    
    


end
