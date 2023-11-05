/*
 @ Author Geert Roumen
 @ Hardware T-Display-S3-AMOLED
 */


//Import libraries
import java.awt.*;
Robot robot;
import java.util.concurrent.TimeUnit;
import java.awt.image.*;
import processing.serial.*;
String portName;
Serial arduinoPort;  // Create object from Serial class
int val;

int screen_width = 536 ;
int screen_height = 240;
//Setup function (runs once)
void setup() {
  //Set the size of the window (make sure it matches the resolution of your screen), for T-Display-S3-AMOLED it is 536x240
  size(536, 240);
  frameRate(2);
  /// Sets the [portName] variable to the first available serial port in the system.
  portName = Serial.list()[0];
  // Prints list of serial ports to the console
  printArray(Serial.list());
  arduinoPort = new Serial(this, portName, 4000000);
  //Try to create a new Robot, which will allow us to take screenshots/recordings
  try
  {
    robot = new Robot();
  }
  catch (AWTException e) {
    throw new RuntimeException("Unable to Initialize", e);
  }
}

int mousex = 0;
int mouseY = 0;
int savedX = 0;
int recordedX = 0;
int recordedY = 0;


int time = 0;
void draw() {
  if (recordedX == 0) {
    Point mouse;
    mouse = MouseInfo.getPointerInfo().getLocation();
    mousex = mouse.x;
    mouseY = mouse.y;
  } else {
    mousex = recordedX;
    mouseY = recordedY;
  }
  Rectangle bounds = new Rectangle(mousex, mouseY, screen_width, screen_height);
  BufferedImage test = robot.createScreenCapture(bounds);
  PImage c = new PImage(test);
  image(c, 0, 0);
  //Send 10 times R. to indicate the start of a new frame
  for (int b=0; b<10; b++) {
    arduinoPort.write((byte) 'R');
    arduinoPort.write((byte) '.');
  }
  //Load the pixels of the image into the pixels[] array
  loadPixels();

  //Loop through all the pixels
  for (int y=0; y<screen_height; y++) {
    for (int x =0; x<screen_width; x++) {
      //Get the color of the pixel
      color p = pixels[x+y*screen_width];
      //Convert the color to a 16 bit value
      int r = ((int)red(p))>>3;
      int g = ((int)green(p))>>2;
      int b = ((int)blue(p))>>3;
      long value = (r<<11)+(g<<5)+b;

      //Send the 16 bit value to the Arduino
      arduinoPort.write((byte)(value & 0xff));
      arduinoPort.write((byte)((value >> 8) & 0xff));
      
      //Wait 1ms every 50 pixels to prevent the Arduino from overflowing
      if ((x+y*screen_width) % 50 == 0) {
        delay(1);
      }
    }
  }
}

void keyPressed() {
  //If the user presses the UP key, record the current mouse position so we can use it as the left top corner of the screen
  if (keyCode == UP) {
    recordedX = mousex;
    recordedY = mouseY;
  }
}
