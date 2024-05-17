
_read_ldr:

;curtain_final.c,23 :: 		int read_ldr()
;curtain_final.c,26 :: 		unsigned int adc_value = 0;
;curtain_final.c,27 :: 		adc_value = ADC_Read(0);
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
;curtain_final.c,28 :: 		light = 100 - adc_value / 10.24;
	CALL       _word2double+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      215
	MOVWF      R4+1
	MOVLW      35
	MOVWF      R4+2
	MOVLW      130
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	MOVF       R0+2, 0
	MOVWF      R4+2
	MOVF       R0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      72
	MOVWF      R0+2
	MOVLW      133
	MOVWF      R0+3
	CALL       _Sub_32x32_FP+0
	CALL       _double2int+0
	MOVF       R0+0, 0
	MOVWF      read_ldr_light_L0+0
	MOVF       R0+1, 0
	MOVWF      read_ldr_light_L0+1
;curtain_final.c,29 :: 		inttostr(light, value);
	MOVF       R0+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       R0+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _value+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;curtain_final.c,30 :: 		lcd_out(2, 1, "Light = ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_curtain_final+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;curtain_final.c,31 :: 		lcd_out(2, 9, Ltrim(value));
	MOVLW      _value+0
	MOVWF      FARG_Ltrim_string+0
	CALL       _Ltrim+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;curtain_final.c,32 :: 		Lcd_Chr_Cp('%');
	MOVLW      37
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;curtain_final.c,33 :: 		Lcd_Chr_Cp(' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;curtain_final.c,34 :: 		if (light >= 65) // SWITCH off the light when light is 65 percent
	MOVLW      128
	XORWF      read_ldr_light_L0+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_ldr13
	MOVLW      65
	SUBWF      read_ldr_light_L0+0, 0
L__read_ldr13:
	BTFSS      STATUS+0, 0
	GOTO       L_read_ldr0
;curtain_final.c,36 :: 		PORTB.F1 = 0;
	BCF        PORTB+0, 1
;curtain_final.c,37 :: 		}
	GOTO       L_read_ldr1
L_read_ldr0:
;curtain_final.c,40 :: 		PORTB.F1 = 1;
	BSF        PORTB+0, 1
;curtain_final.c,41 :: 		}
L_read_ldr1:
;curtain_final.c,42 :: 		return light;
	MOVF       read_ldr_light_L0+0, 0
	MOVWF      R0+0
	MOVF       read_ldr_light_L0+1, 0
	MOVWF      R0+1
;curtain_final.c,43 :: 		}
L_end_read_ldr:
	RETURN
; end of _read_ldr

_stopMotor:

;curtain_final.c,45 :: 		void stopMotor()
;curtain_final.c,47 :: 		MOTOR_CONTROL_PIN_1 = 0;
	BCF        RD6_bit+0, BitPos(RD6_bit+0)
;curtain_final.c,48 :: 		MOTOR_CONTROL_PIN_2 = 0;
	BCF        RD7_bit+0, BitPos(RD7_bit+0)
;curtain_final.c,49 :: 		}
L_end_stopMotor:
	RETURN
; end of _stopMotor

_openCurtain:

;curtain_final.c,51 :: 		void openCurtain()
;curtain_final.c,53 :: 		MOTOR_CONTROL_PIN_1 = 1;
	BSF        RD6_bit+0, BitPos(RD6_bit+0)
;curtain_final.c,54 :: 		MOTOR_CONTROL_PIN_2 = 0;
	BCF        RD7_bit+0, BitPos(RD7_bit+0)
;curtain_final.c,55 :: 		while (!IR_TOP)
L_openCurtain2:
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L_openCurtain3
;curtain_final.c,56 :: 		; // Wait for top sensor trigger
	GOTO       L_openCurtain2
L_openCurtain3:
;curtain_final.c,57 :: 		stopMotor();
	CALL       _stopMotor+0
;curtain_final.c,58 :: 		}
L_end_openCurtain:
	RETURN
; end of _openCurtain

_closeCurtain:

;curtain_final.c,60 :: 		void closeCurtain()
;curtain_final.c,62 :: 		MOTOR_CONTROL_PIN_1 = 0;
	BCF        RD6_bit+0, BitPos(RD6_bit+0)
;curtain_final.c,63 :: 		MOTOR_CONTROL_PIN_2 = 1;
	BSF        RD7_bit+0, BitPos(RD7_bit+0)
;curtain_final.c,64 :: 		while (!IR_BOTTOM)
L_closeCurtain4:
	BTFSC      RB1_bit+0, BitPos(RB1_bit+0)
	GOTO       L_closeCurtain5
;curtain_final.c,65 :: 		; // Wait for bottom sensor trigger
	GOTO       L_closeCurtain4
L_closeCurtain5:
;curtain_final.c,66 :: 		stopMotor();
	CALL       _stopMotor+0
;curtain_final.c,67 :: 		}
L_end_closeCurtain:
	RETURN
; end of _closeCurtain

_setup:

;curtain_final.c,69 :: 		void setup()
;curtain_final.c,71 :: 		TRISB0_bit = 1; // IR Sensor Top as input
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;curtain_final.c,72 :: 		TRISB1_bit = 1; // IR Sensor Bottom as input
	BSF        TRISB1_bit+0, BitPos(TRISB1_bit+0)
;curtain_final.c,73 :: 		TRISD6_bit = 0; // Motor control pin 1 as output
	BCF        TRISD6_bit+0, BitPos(TRISD6_bit+0)
;curtain_final.c,74 :: 		TRISD7_bit = 0; // Motor control pin 2 as output
	BCF        TRISD7_bit+0, BitPos(TRISD7_bit+0)
;curtain_final.c,76 :: 		stopMotor();
	CALL       _stopMotor+0
;curtain_final.c,77 :: 		}
L_end_setup:
	RETURN
; end of _setup

_main:

;curtain_final.c,79 :: 		void main()
;curtain_final.c,82 :: 		setup();
	CALL       _setup+0
;curtain_final.c,85 :: 		ADC_Init();
	CALL       _ADC_Init+0
;curtain_final.c,87 :: 		Lcd_Init();               // Initialize LCD
	CALL       _Lcd_Init+0
;curtain_final.c,88 :: 		Lcd_Cmd(_LCD_CLEAR);      // Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;curtain_final.c,89 :: 		Lcd_Cmd(_LCD_CURSOR_OFF); // Cursor off
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;curtain_final.c,91 :: 		Lcd_Out(1, 1, "AUTOMATIC");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_curtain_final+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;curtain_final.c,92 :: 		Lcd_Out(2, 1, "LIGHT SYSTEM");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_curtain_final+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;curtain_final.c,93 :: 		delay_ms(250);
	MOVLW      7
	MOVWF      R11+0
	MOVLW      88
	MOVWF      R12+0
	MOVLW      89
	MOVWF      R13+0
L_main6:
	DECFSZ     R13+0, 1
	GOTO       L_main6
	DECFSZ     R12+0, 1
	GOTO       L_main6
	DECFSZ     R11+0, 1
	GOTO       L_main6
	NOP
	NOP
;curtain_final.c,94 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;curtain_final.c,96 :: 		Lcd_Out(1, 1, "LIGHT SENSOR"); // Write text in first row
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr4_curtain_final+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;curtain_final.c,98 :: 		while (1)
L_main7:
;curtain_final.c,100 :: 		light = read_ldr();
	CALL       _read_ldr+0
;curtain_final.c,102 :: 		if (light > 70)
	MOVLW      128
	MOVWF      R2+0
	MOVLW      128
	XORWF      R0+1, 0
	SUBWF      R2+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main19
	MOVF       R0+0, 0
	SUBLW      70
L__main19:
	BTFSC      STATUS+0, 0
	GOTO       L_main9
;curtain_final.c,104 :: 		openCurtain();
	CALL       _openCurtain+0
;curtain_final.c,105 :: 		}
	GOTO       L_main10
L_main9:
;curtain_final.c,108 :: 		closeCurtain();
	CALL       _closeCurtain+0
;curtain_final.c,109 :: 		}
L_main10:
;curtain_final.c,110 :: 		Delay_ms(100); // Add some delay for stability
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_main11:
	DECFSZ     R13+0, 1
	GOTO       L_main11
	DECFSZ     R12+0, 1
	GOTO       L_main11
	DECFSZ     R11+0, 1
	GOTO       L_main11
	NOP
	NOP
;curtain_final.c,111 :: 		}
	GOTO       L_main7
;curtain_final.c,112 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
