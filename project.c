#include <xc.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

// Configuration bits for PIC16F877A
#pragma config FOSC = HS   // Oscillator Selection bits (HS oscillator)
#pragma config WDTE = OFF  // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF // Power-up Timer Enable bit (PWRT disabled)
#pragma config BOREN = ON  // Brown-out Reset Enable bit (BOR enabled)
#pragma config LVP = OFF   // Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
#pragma config CPD = OFF   // Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
#pragma config WRT = OFF   // Flash Program Memory Write Enable bits (Write protection off)
#pragma config CP = OFF    // Flash Program Memory Code Protection bit (Code protection off)

#define _XTAL_FREQ 20000000 // Define oscillator frequency for delay functions

// Define macros for pins
#define IR_TOP PORTBbits.RB0
#define IR_BOTTOM PORTBbits.RB1
#define MOTOR_CONTROL_PIN_1 PORTDbits.RD6
#define MOTOR_CONTROL_PIN_2 PORTDbits.RD7

// LCD module connections
#define LCD_RS PORTDbits.RD0
#define LCD_EN PORTDbits.RD1
#define LCD_D4 PORTDbits.RD2
#define LCD_D5 PORTDbits.RD3
#define LCD_D6 PORTDbits.RD4
#define LCD_D7 PORTDbits.RD5

#define LCD_RS_Direction TRISDbits.TRISD0
#define LCD_EN_Direction TRISDbits.TRISD1
#define LCD_D4_Direction TRISDbits.TRISD2
#define LCD_D5_Direction TRISDbits.TRISD3
#define LCD_D6_Direction TRISDbits.TRISD4
#define LCD_D7_Direction TRISDbits.TRISD5

void ADC_Init()
{
    // Initialize ADC module
    ADCON0 = 0x41; // Turn on the ADC module, select channel 0
    ADCON1 = 0x80; // Configure the result format and clock
}

unsigned int ADC_Read(unsigned char channel)
{
    if (channel > 7)
        return 0; // Channel range for PIC16F877A is 0-7

    ADCON0 &= 0xC5;         // Clear the channel selection bits
    ADCON0 |= channel << 3; // Select the required channel
    __delay_us(30);         // Acquisition time to charge hold capacitor
    GO_nDONE = 1;           // Start conversion
    while (GO_nDONE)
        ; // Wait for the conversion to complete

    return ((ADRESH << 8) + ADRESL); // Return result
}

void Lcd_Cmd(unsigned char cmd)
{
    LCD_RS = 0; // RS = 0 for command
    LCD_D4 = (cmd >> 4) & 1;
    LCD_D5 = (cmd >> 5) & 1;
    LCD_D6 = (cmd >> 6) & 1;
    LCD_D7 = (cmd >> 7) & 1;
    LCD_EN = 1;
    __delay_us(1);
    LCD_EN = 0;

    __delay_us(200);

    LCD_D4 = cmd & 1;
    LCD_D5 = (cmd >> 1) & 1;
    LCD_D6 = (cmd >> 2) & 1;
    LCD_D7 = (cmd >> 3) & 1;
    LCD_EN = 1;
    __delay_us(1);
    LCD_EN = 0;

    __delay_ms(2);
}

void Lcd_Chr_Cp(char data)
{
    LCD_RS = 1; // RS = 1 for data
    LCD_D4 = (data >> 4) & 1;
    LCD_D5 = (data >> 5) & 1;
    LCD_D6 = (data >> 6) & 1;
    LCD_D7 = (data >> 7) & 1;
    LCD_EN = 1;
    __delay_us(1);
    LCD_EN = 0;

    __delay_us(200);

    LCD_D4 = data & 1;
    LCD_D5 = (data >> 1) & 1;
    LCD_D6 = (data >> 2) & 1;
    LCD_D7 = (data >> 3) & 1;
    LCD_EN = 1;
    __delay_us(1);
    LCD_EN = 0;

    __delay_ms(2);
}

void Lcd_Out(unsigned char row, unsigned char column, const char *text)
{
    unsigned char pos;
    switch (row)
    {
    case 1:
        pos = 0x80 + column - 1;
        break;
    case 2:
        pos = 0xC0 + column - 1;
        break;
    case 3:
        pos = 0x94 + column - 1;
        break;
    case 4:
        pos = 0xD4 + column - 1;
        break;
    default:
        pos = 0x80 + column - 1;
        break;
    }
    Lcd_Cmd(pos);
    while (*text)
    {
        Lcd_Chr_Cp(*text++);
    }
}

void Lcd_Init()
{
    LCD_RS_Direction = 0;
    LCD_EN_Direction = 0;
    LCD_D4_Direction = 0;
    LCD_D5_Direction = 0;
    LCD_D6_Direction = 0;
    LCD_D7_Direction = 0;

    LCD_RS = 0;
    LCD_EN = 0;

    __delay_ms(20);

    Lcd_Cmd(0x03);
    __delay_ms(5);
    Lcd_Cmd(0x03);
    __delay_us(100);
    Lcd_Cmd(0x03);
    Lcd_Cmd(0x02); // Initialize LCD in 4-bit mode

    Lcd_Cmd(0x28); // 2 lines, 5x7 matrix in 4-bit mode
    Lcd_Cmd(0x0C); // Display on, cursor off
    Lcd_Cmd(0x06); // Increment cursor (shift cursor to right)
    Lcd_Cmd(0x01); // Clear display screen
    __delay_ms(2);
}

char value[7];

int read_ldr()
{
    int light;
    unsigned int adc_value = ADC_Read(0);
    light = 100 - (int)(adc_value / 10.24);
    sprintf(value, "%d", light);
    Lcd_Out(2, 1, "Light = ");
    Lcd_Out(2, 9, value);
    Lcd_Chr_Cp('%');
    Lcd_Chr_Cp(' ');

    if (light >= 65)
    { // SWITCH off the light when light is 65 percent
        PORTBbits.RB1 = 0;
    }
    else
    {
        PORTBbits.RB1 = 1;
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
    TRISBbits.TRISB0 = 1; // IR Sensor Top as input
    TRISBbits.TRISB1 = 1; // IR Sensor Bottom as input
    TRISDbits.TRISD6 = 0; // Motor control pin 1 as output
    TRISDbits.TRISD7 = 0; // Motor control pin 2 as output

    stopMotor();
}

void main()
{
    int light;
    setup();
    ADC_Init();

    Lcd_Init();    // Initialize LCD
    Lcd_Cmd(0x01); // Clear display
    Lcd_Cmd(0x0C); // Cursor off

    Lcd_Out(1, 1, "AUTOMATIC");
    Lcd_Out(2, 1, "LIGHT SYSTEM");
    __delay_ms(250);
    Lcd_Cmd(0x01); // Clear display

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
        __delay_ms(100); // Add some delay for stability
    }
}
