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
  BufferedImage test = rotateImage(robot.createScreenCapture(bounds),0);
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
      
      long startTime = System.nanoTime();
    int q = 0;
    int timedelay = 4000;
    while (System.nanoTime()-startTime < timedelay){
      q++;
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
//https://stackoverflow.com/questions/37758061/rotate-a-buffered-image-in-java
private static BufferedImage rotateImage(BufferedImage buffImage, double angle) {
    double radian = Math.toRadians(angle);
    double sin = Math.abs(Math.sin(radian));
    double cos = Math.abs(Math.cos(radian));

    int width = buffImage.getWidth();
    int height = buffImage.getHeight();

    int nWidth = (int) Math.floor((double) width * cos + (double) height * sin);
    int nHeight = (int) Math.floor((double) height * cos + (double) width * sin);

    BufferedImage rotatedImage = new BufferedImage(
            nWidth, nHeight, BufferedImage.TYPE_INT_ARGB);

    Graphics2D graphics = rotatedImage.createGraphics();

    graphics.setRenderingHint(
            RenderingHints.KEY_INTERPOLATION,
            RenderingHints.VALUE_INTERPOLATION_BICUBIC);

    graphics.translate((nWidth - width) / 2, (nHeight - height) / 2);
    // rotation around the center point
    graphics.rotate(radian, (double) (width / 2), (double) (height / 2));
    graphics.drawImage(buffImage, 0, 0, null);
    graphics.dispose();

    return rotatedImage;
}