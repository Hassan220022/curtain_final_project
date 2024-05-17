#line 1 "C:/Users/hassa/Documents/curtain_final_project/curtain_final.c"
sbit IR_TOP at RB0_bit;
sbit IR_BOTTOM at RB1_bit;
sbit MOTOR_CONTROL_PIN_1 at RD6_bit;
sbit MOTOR_CONTROL_PIN_2 at RD7_bit;


sbit LCD_RS at RD0_bit;
sbit LCD_EN at RD1_bit;
sbit LCD_D4 at RD2_bit;
sbit LCD_D5 at RD3_bit;
sbit LCD_D6 at RD4_bit;
sbit LCD_D7 at RD5_bit;

sbit LCD_RS_Direction at TRISD0_bit;
sbit LCD_EN_Direction at TRISD1_bit;
sbit LCD_D4_Direction at TRISD2_bit;
sbit LCD_D5_Direction at TRISD3_bit;
sbit LCD_D6_Direction at TRISD4_bit;
sbit LCD_D7_Direction at TRISD5_bit;

char value[7];

int read_ldr()
{
 int light;
 unsigned int adc_value = 0;
 adc_value = ADC_Read(0);
 light = 100 - adc_value / 10.24;
 inttostr(light, value);
 lcd_out(2, 1, "Light = ");
 lcd_out(2, 9, Ltrim(value));
 Lcd_Chr_Cp('%');
 Lcd_Chr_Cp(' ');
 if (light >= 65)
 {
 PORTB.F1 = 0;
 }
 else
 {
 PORTB.F1 = 1;
 }
 return light;
}

void stopMotor()
{
 MOTOR_CONTROL_PIN_1 = 0;
 MOTOR_CONTROL_PIN_2 = 0;
}

void openCurtain()
{
 MOTOR_CONTROL_PIN_1 = 1;
 MOTOR_CONTROL_PIN_2 = 0;
 while (!IR_TOP)
 ;
 stopMotor();
}

void closeCurtain()
{
 MOTOR_CONTROL_PIN_1 = 0;
 MOTOR_CONTROL_PIN_2 = 1;
 while (!IR_BOTTOM)
 ;
 stopMotor();
}

void setup()
{
 TRISB0_bit = 1;
 TRISB1_bit = 1;
 TRISD6_bit = 0;
 TRISD7_bit = 0;

 stopMotor();
}

void main()
{
 int light;
 setup();


 ADC_Init();

 Lcd_Init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);

 Lcd_Out(1, 1, "AUTOMATIC");
 Lcd_Out(2, 1, "LIGHT SYSTEM");
 delay_ms(250);
 Lcd_Cmd(_LCD_CLEAR);

 Lcd_Out(1, 1, "LIGHT SENSOR");

 while (1)
 {
 light = read_ldr();

 if (light > 70)
 {
 openCurtain();
 }
 else
 {
 closeCurtain();
 }
 Delay_ms(100);
 }
}
