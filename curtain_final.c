sbit IR_TOP at RB0_bit;    // IR sensor at the top
sbit IR_BOTTOM at RB1_bit; // IR sensor at the bottom
sbit MOTOR_CONTROL_PIN_1 at RD6_bit;
sbit MOTOR_CONTROL_PIN_2 at RD7_bit;

// LCD module connections
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
    if (light >= 65) // SWITCH off the light when light is 65 percent
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
        ; // Wait for top sensor trigger
    stopMotor();
}

void closeCurtain()
{
    MOTOR_CONTROL_PIN_1 = 0;
    MOTOR_CONTROL_PIN_2 = 1;
    while (!IR_BOTTOM)
        ; // Wait for bottom sensor trigger
    stopMotor();
}

void setup()
{
    TRISB0_bit = 1; // IR Sensor Top as input
    TRISB1_bit = 1; // IR Sensor Bottom as input
    TRISD6_bit = 0; // Motor control pin 1 as output
    TRISD7_bit = 0; // Motor control pin 2 as output

    stopMotor();
}

void main()
{
    int light;
    setup();
    // TRISB = 0X00;
    // PORTB = 0X00;
    ADC_Init();

    Lcd_Init();               // Initialize LCD
    Lcd_Cmd(_LCD_CLEAR);      // Clear display
    Lcd_Cmd(_LCD_CURSOR_OFF); // Cursor off

    Lcd_Out(1, 1, "AUTOMATIC");
    Lcd_Out(2, 1, "LIGHT SYSTEM");
    delay_ms(250);
    Lcd_Cmd(_LCD_CLEAR);

    Lcd_Out(1, 1, "LIGHT SENSOR"); // Write text in first row

    while (1)
    {
        light = read_ldr();

        if (light > 70)
        { // Light threshold
            openCurtain();
        }
        else
        {
            closeCurtain();
        }
        Delay_ms(100); // Add some delay for stability
    }
}