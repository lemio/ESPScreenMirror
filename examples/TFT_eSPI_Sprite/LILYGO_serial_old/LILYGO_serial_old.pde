/*
Works with OLED_ExternalScreen_tft_faster_refresh_colour

*/

import java.awt.*;
Robot robot;
import java.util.concurrent.TimeUnit;
import java.awt.image.*;
import processing.serial.*;
String portName;
Serial myPort;  // Create object from Serial class
int val;
void setup(){
  size(536,240);
  frameRate(10);
  portName = Serial.list()[0];
    printArray(Serial.list());
  //myPort = new Serial(this, portName, 9600);
  myPort = new Serial(this, portName, 4000000);
  
try
  {
    robot = new Robot();
 
  }catch (AWTException e){
    throw new RuntimeException("Unable to Initialize", e);
  }
}
int mX = 0;
int mY = 0;
int sX = 0;
int sY = 0;
int rX = 0;

int screen_width = 536 ;
int screen_height = 240;
int rY = 0;
int time = 0;
void draw(){
  if (rX == 0){
Point mouse;
  mouse = MouseInfo.getPointerInfo().getLocation();
  
  mX = mouse.x;
  mY = mouse.y;
  }else{
  mX = rX;
  mY = rY;
  }
  Rectangle bounds = new Rectangle(mX, mY, screen_width, screen_height);
  BufferedImage test = rotateImage(robot.createScreenCapture(bounds),0);
  PImage c = new PImage(test);
  //c.filter(GRAY);
  image(c,0,0);
  for (int b=0;b<10;b++){
  myPort.write((byte) 'R');
  myPort.write((byte) '.');
  }
  //float displayBrightness = red(c.get(screen_width-1,screen_height-1))*2;
  //if (displayBrightness == 0 || true){
    //myPort.write((byte) 255);
  //}else{
  //   myPort.write((byte) displayBrightness);
  //}
  loadPixels();
  //byte[] displayMessage = new byte[screen_height*screen_width*2];;
  for (int y=0;y<screen_height;y++){
    
  for (int x =0;x<screen_width;x++){
  
  //long value = 0;
  color p = pixels[x+y*screen_width];
  
  //int r = round( map(red(p),0,256,0,31));
  int r = ((int)red(p))>>3;
  //int g = round(map(green(p),0,256,0,63));
 int g = ((int)green(p))>>2;
  //int b = round(map(blue(p),0,256,0,31));
  int b = ((int)blue(p))>>3;
  long value = (r<<11)+(g<<5)+b;
  
  //long value = (b<<11)+(r<<5)+g;
  if (x ==0 && y==0){
    print (r);
    print(" ");
    print (g);
    print(" ");
    print (b);
    print(" ");
  println (Integer.toHexString((int)value));
  }
   
   myPort.write((byte)(value & 0xff));
   myPort.write((byte)((value >> 8) & 0xff));
  //print (r);
  
  
    long startTime = System.nanoTime();
    int q = 0;
    int timedelay = 4000;
    while (System.nanoTime()-startTime < timedelay){
      q++;
    }
    long endTime = System.nanoTime();
    println(endTime-startTime);
  
  
}
  }
  //myPort.write(displayMessage);
}
  

void cross(float x, float y, float size){
  stroke(0);
line(x-size,y,x+size,y);
line(x,y-size,x,y+size);
stroke(255);
x++;
y++;
line(x-size,y,x+size,y);
line(x,y-size,x,y+size);


}
int aX = 0;
int aY = 0;
int serialCount = 0;
/*
void serialEvent(Serial myPort) {
  
   int inByte = myPort.read();
  print((char) inByte);
   if (inByte == 'A'){
     print("Got an A");
    aX += 100;
    if (aX> 255){
    aX = 0;
    }
  }
  /*
  if (inByte == 'S'){
    serialCount = 0;
  }
  if (serialCount == 1){
    aX = inByte;
  } 
  if (serialCount == 2){
    aY = inByte;
  }
  serialCount++;*/
//}
boolean play = false;
void keyPressed(){
  if (keyCode == UP) {
    rX = mX;
    rY = mY;
    

  }
  if (keyCode == DOWN) {
    sX = mX;
    sY = mY;
    surface.setSize(sX-rX,sY-rY);

  }
  if (key== 'r') {
      myPort.clear();
      myPort.stop();
     myPort = new Serial(this, portName, 400000);

  }
  if (key == 'p'){
    filter(THRESHOLD);
    println("saved image");
    saveFrame("disp-######.png");
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