// Example for library:
// https://github.com/Bodmer/TJpg_Decoder

// This example renders a Jpeg file that is stored in an array within Flash (program) memory
// see panda.h tab.  The panda image file being ~13Kbytes.

//#define USE_DMA

// Include the array
#include "panda.h"
#define LILYGO_TDISPLAY_AMOLED_SERIES
#include "esp_arduino_version.h"
#if ESP_ARDUINO_VERSION < ESP_ARDUINO_VERSION_VAL(3,0,0)
#if defined(LILYGO_TWRITSTBAND_S3)
#include <LilyGo_Wristband.h> //To use LilyGo Wristband S3, please include <LilyGo_Wristband.h>
#elif defined(LILYGO_TDISPLAY_AMOLED_SERIES)
#include <LilyGo_AMOLED.h>      //To use LilyGo AMOLED series screens, please include <LilyGo_AMOLED.h>
#endif
#include <TFT_eSPI.h>   //https://github.com/Bodmer/TFT_eSPI
#include <LV_Helper.h>

// Include the jpeg decoder library
#include <TJpg_Decoder.h>
LilyGo_Class amoled;

// Include the TFT library https://github.com/Bodmer/TFT_eSPI
#include "SPI.h"
#include <TFT_eSPI.h>              // Hardware-specific library
TFT_eSPI tft = TFT_eSPI();         // Invoke custom library

// This next function will be called during decoding of the jpeg file to render each
// 16x16 or 8x8 image tile (Minimum Coding Unit) to the TFT.
bool tft_output(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t* bitmap)
{
   // Stop further decoding as image is running off bottom of screen
  if ( y >= tft.height() ) return 0;


  // Non-DMA blocking alternative
  amoled.pushColors(x, y, w, h, bitmap);  // Blocking, so only returns when image block is drawn
#endif
  // Return 1 to decode next block.
  return 1;
}

void setup()
{

    
  Serial.begin(115200);
  Serial.println("\n\n Testing TJpg_Decoder library");

  // Initialise the TFT
  tft.begin();
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.fillScreen(TFT_BLACK);


if (!amoled.begin()) {
        while (1) {
            Serial.println("There is a problem with the device!~"); delay(1000);
        }
    }

  // The jpeg image can be scaled down by a factor of 1, 2, 4, or 8
  TJpgDec.setJpgScale(1);

  // The colour byte order can be swapped by the decoder
  // using TJpgDec.setSwapBytes(true); or by the TFT_eSPI library:
  tft.setSwapBytes(true);

  // The decoder must be given the exact name of the rendering function above
  TJpgDec.setCallback(tft_output);


}

void loop()
{
  // Show a contrasting colour for demo of draw speed
  tft.fillScreen(TFT_RED);


  // Get the width and height in pixels of the jpeg if you wish:
  uint16_t w = 0, h = 0;
  TJpgDec.getJpgSize(&w, &h, panda, sizeof(panda));
  Serial.print("Width = "); Serial.print(w); Serial.print(", height = "); Serial.println(h);

  // Time recorded for test purposes
  uint32_t dt = millis();

  // Must use startWrite first so TFT chip select stays low during DMA and SPI channel settings remain configured
  tft.startWrite();

  // Draw the image, top left at 0,0 - DMA request is handled in the call-back tft_output() in this sketch
  TJpgDec.drawJpg(0, 0, panda, sizeof(panda));

  // Must use endWrite to release the TFT chip select and release the SPI channel
  tft.endWrite();

  // How much time did rendering take (ESP8266 80MHz 262ms, 160MHz 149ms, ESP32 SPI 111ms, 8bit parallel 90ms
  dt = millis() - dt;
  Serial.print(dt); Serial.println(" ms");

  // Wait before drawing again
  delay(2000);
}
