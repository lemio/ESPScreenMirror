#define LILYGO_TDISPLAY_AMOLED_SERIES

#include "Arduino.h"
#include "esp_arduino_version.h"
#include <LilyGo_AMOLED.h>      
#include <TFT_eSPI.h>   
#include "true_color.h"
#include <LV_Helper.h>
#include <SPI.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <WiFi.h>
#include <esp_wifi.h>
#include <ArduinoWebsockets.h>
#include <WiFiconfig.h>
#include <TJpg_Decoder.h>

// Create a TFT_eSPI object 
using namespace websockets;
WebsocketsServer server;
WebsocketsClient client;


LilyGo_Class amoled;

#define WIDTH  536
//amoled.height()
#define HEIGHT 240
//amoled.width()
#define BUFFER_SIZE WIDTH * HEIGHT

//Red 0xF800 Green 0x07E0 Blue 0x001F
uint16_t buffer_bmp[BUFFER_SIZE] = {0xF800,0xF800,0xF800, 0x0000,0x0000,0x0000, 0x07E0,0x07E0,0x07E0, 0x0000,0x0000,0x0000, 0x001F,0x001F,0x001F, 0x0000}; //Blue 0x001F

bool tft_output(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t* bitmap)
{
   // Stop further decoding as image is running off bottom of screen
  //if ( y >= tft.height() ) return 0;

  // This function will clip the image block rendering automatically at the TFT boundaries
  amoled.pushColors(x, y, w, h, bitmap);

  // This might work instead if you adapt the sketch to use the Adafruit_GFX library
  // tft.drawRGBBitmap(x, y, bitmap, w, h);

  // Return 1 to decode next block
  return 1;
}

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

    TJpgDec.setJpgScale(1);

  // The decoder must be given the exact name of the rendering function above
  TJpgDec.setCallback(tft_output);

  WiFi.softAP(ssid, password);

  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP Address : ");
  Serial.println(IP);

  server.listen(8888);
}

void loop()
{
    if(server.poll()){
      client = server.accept();
    }

    if(client.available()){
      client.poll();

      WebsocketsMessage msg = client.readBlocking();

      uint32_t t = millis();

      // Get the width and height in pixels of the jpeg if you wish
      uint16_t w = 0, h = 0;
      TJpgDec.getJpgSize(&w, &h, (const uint8_t*)msg.c_str(), msg.length());
      Serial.print("Width = "); Serial.print(w); Serial.print(", height = "); Serial.println(h);
    
      // Draw the image, top left at 0,0
      TJpgDec.drawJpg(0, 0, (const uint8_t*)msg.c_str(), msg.length());
    
      // How much time did rendering take (ESP8266 80MHz 271ms, 160MHz 157ms, ESP32 SPI 120ms, 8bit parallel 105ms
      t = millis() - t;
      Serial.print(t); Serial.println(" ms");
    }      

}


