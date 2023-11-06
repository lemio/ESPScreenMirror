# ESPScreenMirror
This code is intended to mirror the display on a laptop to a LILYGO AMOLED display

![Picture of the ESP32 devkit showing the same image as the laptop 
screen](./images/picture_screenshot.jpeg)


## 3️⃣ PlatformIO Quick Start (Recommended)

1. Install [Visual Studio Code](https://code.visualstudio.com/) and [Python](https://www.python.org/)
2. Search for the `PlatformIO` plugin in the `VisualStudioCode` extension and install it.
3. After the installation is complete, you need to restart `VisualStudioCode`
4. After restarting `VisualStudioCode`, select `File` in the upper left corner of `VisualStudioCode` -> `Open Folder` -> select the `LilyGO AMOLED Series` directory
5. Wait for the installation of third-party dependent libraries to complete
6. Click on the `platformio.ini` file, and in the `platformio` column
7. Uncomment one of the lines `src_dir = xxxx` to make sure only one line works
8. Click the (✔) symbol in the lower left corner to compile
9. Connect the board to the computer USB
10. Click (→) to upload firmware
11. Click (plug symbol) to monitor serial output
12. If it cannot be written, or the USB device keeps flashing, please check the **FAQ** below

# Hardware
* [LILYGO AMOLED display](https://www.lilygo.cc/products/t-display-s3-amoled)
* [AMOLED Driver datasheet](./datasheet/SH8501B0%20DataSheet.pdf)
* [ESP32S3](https://www.espressif.com.cn/en/support/documents/technical-documents?keys=&field_type_tid%5B%5D=842)
* [Board schematic](./schematic/T-Display_AMOLED-Lite.pdf)
* [Board 3D step](./shell/PCB_3D.7z)
* [Board Dimensions](./shell/PCB.DXF)