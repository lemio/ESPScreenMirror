#define LILYGO_TDISPLAY_AMOLED_SERIES

#include "Arduino.h"
#include "esp_arduino_version.h"
#include <LilyGo_AMOLED.h>      
#include <TFT_eSPI.h>   
#include "true_color.h"
#include <LV_Helper.h>

// Create a TFT_eSPI object 
LilyGo_Class amoled;

#define WIDTH  536
//amoled.height()
#define HEIGHT 240
//amoled.width()
#define BUFFER_SIZE WIDTH * HEIGHT

//Red 0xF800 Green 0x07E0 Blue 0x001F
uint16_t buffer_bmp[BUFFER_SIZE] = {0xF800,0xF800,0xF800, 0x0000,0x0000,0x0000, 0x07E0,0x07E0,0x07E0, 0x0000,0x0000,0x0000, 0x001F,0x001F,0x001F, 0x0000}; //Blue 0x001F

void setup()
{
    // Use TFT_eSPI Sprite made by framebuffer , unnecessary calling during use tft.xxxx function
    Serial.begin(4000000);

    // Automatically determine the access device
    if (!amoled.begin()) {
        while (1) {
            Serial.println("There is a problem with the device!~"); delay(1000);
        }
    }
}

void loop()
{
    //spr.pushImage(0, 0, WIDTH, HEIGHT, (uint16_t *)gImage_true_color);
    amoled.pushColors(0, 0, WIDTH, HEIGHT, buffer_bmp);
    delay(2000);
    while(true){
        receiveImage(BUFFER_SIZE);
        amoled.pushColors(0, 0, WIDTH, HEIGHT, buffer_bmp);
    }

}
void receiveImage (int length){
    int i = 0;
    while(!Serial.available()){}
    for (int begin = 0;begin<10;begin ++){
    while(!Serial.available()){}
    while(Serial.read() != 'R'){}
    while(!Serial.available()){}
    while(Serial.read() != '.'){}
    }
    while(i < length){
        while(!Serial.available()){}
        int t = Serial.read();
        while(!Serial.available()){}
        buffer_bmp[i] = (Serial.read() ) + (t << 8);
        
        i++;
    }
}

