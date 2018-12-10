import milchreis.imageprocessing.*;
import processing.video.*;



BackgroundImage background1 = new BackgroundImage(#FF7F66);
BackgroundImage background2 = new BackgroundImage(#FFDD6F);

PImage backgroundTester;
PImage backgroundTester2;
PImage blendedBackground;


PFont font;
Capture cam;
Capture cam2;
String mode = "menu";
//main menu buttons
Circle circle1;
Circle circle2;
Circle circle3;
FlashingSign sign;
int count; // used for flashing sign

// single player menu
PImage whichBlend;

//Motion measure
// Previous Frame
PImage prevFrame;
float r1;
float g1;
float b1;
float r2;
float g2;
float b2;
float diff;

//set for second camera
PImage prevFrame_;
float r1_;
float g1_;
float b1_;
float r2_;
float g2_;
float b2_;
float diff_;


//back to menu box
menuBox menuBox;

//new blend
int numPixels;
int[] previousFrame;
int numPixels2;
int[] previousFrame2;

class Circle {
  int x;
  int y;
  int size;
  String text;
  color circleColor = color(#E8A159);
  color circleHighlight = color(#FFDD6F);


  Circle(int posX, int posY, String t) {
    x = posX;
    y = posY;
    text = t;
  }

  void display(boolean isHover) {
    stroke(0);
    if (isHover) {
      size = 350;
      textFont(font, 50);
      fill(0);
      text(text, 480, 400);
      fill(circleHighlight, 100);
    } else {
      size = 300;
      fill(circleColor);
    }
    ellipse(x, y, size, size);
  }


  boolean isHover() {
    float disX = x - mouseX;
    float disY = y - mouseY;
    if (sqrt(sq(disX) + sq(disY)) < size/2 ) {
      return true;
    } else {
      return false;
    }
  }
}


// single player manu
ArrayList<Rectangle> rectangles = new ArrayList<Rectangle>();
class Rectangle {
  int x;
  int y;
  int size;
  PImage img;
  PImage menu;


  Rectangle(int posX, int posY, String imageRoot, String menuImage) {
    x = posX;
    y = posY; 
    menu = loadImage(menuImage);
    img = loadImage(imageRoot);
    img.resize(width, height);
    size = 300;
  }

  void display(int changeSize) { //actually create the character
    image(menu, x, y, changeSize, changeSize);
  }

  boolean isHover() {
    if (mouseX >= x && mouseX <= x+size && 
      mouseY >= y && mouseY <= y+size) {
      return true;
    } else {
      return false;
    }
  }
}

class menuBox {
  int x;
  int y;
  int h; //height
  int w; //width
  color menuColor = #FFDD6F;
  color menuHighlight = #000000;

  menuBox() {
    x = width-200;
    y = height -50;
    h = 20;
    w = 180;
  }
  void display(color changeColor) {
    noFill();
    noStroke();
    rect(x, y, w, h); // invisible rectangle makes it easier to know when mouse is hovering
    textFont(font, 20);
    fill(changeColor);
    text("BACK TO MENU", x, y+h/2+10);
  }
  boolean isHover() {
    if (mouseX >= x && mouseX <= x+w && 
      mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }
}

class FlashingSign {
  int x;
  int y;
  color signColor = #FFDD6F;

  FlashingSign() {
    x = 200;
    y = 200;
  }

  void display() {
    textFont(font, 100);
    fill(signColor);
    text("MOVE", x, y);
  }

  class BackgroundImage {
    int x;
    int y;
    int h;
    int w;
    color imageColor;
    PImage img;

    BackgroundImage(color c) {
      x = 0;
      y = 0;
      h = height;
      w = width;
      img = createImage(width, height, RGB);
      imageColor = c;
      img.loadPixels();
      for (int i = 0; i < img.pixels.length; i++) {
        img.pixels[i] = color(imageColor);
      }
      img.updatePixels();
      img.resize(width, height);
    }

    void display() {
      image(img, x, y, w, h);
    }
  }



  void setup() {
    fullScreen();
    backgroundTester = loadImage("background1.png");
    backgroundTester.resize(width, height);
    backgroundTester2 = loadImage("background2.png");
    backgroundTester2.resize(width, height);
    font = createFont("BungeeShade-Regular", 32);
    String[] cameras = Capture.list();

    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(i + cameras[i]);
      }


      // The camera can be initialized directly using an 
      // element from the array returned by list():
      cam = new Capture(this, width, height, cameras[0]);
      cam2 = new Capture(this, width, height, cameras[18]);
      //cam = new Capture(this, width, height);
      cam.start();
      cam2.start();
    }


    ellipseMode(CENTER);
    //buttons for single user menu
    rectangles.add(new Rectangle(300, 50, "person.jpg", "person2.jpg"));
    rectangles.add(new Rectangle(300, 500, "tiger.jpg", "tiger2.jpg"));
    rectangles.add(new Rectangle(850, 500, "eagle.jpg", "eagle.jpg"));
    rectangles.add(new Rectangle(850, 50, "peacock.jpg", "peacock.jpg"));

    //Motion previous image
    prevFrame = createImage(cam.width, cam.height, RGB);
    prevFrame_ = createImage(cam2.width, cam2.height, RGB);

    // menu rectangle
    menuBox = new menuBox();


    //circles for main manu
    circle1 = new Circle(width/2-400, height/2+200, "Single Player");
    circle2 = new Circle(width/2+300, height/2+200, "Double Players");
    circle3 = new Circle(width/2+450, height/2+200, "Double Players");
    ellipseMode(CENTER);

    sign = new FlashingSign();
    count = 0;


    // new blend
    numPixels = cam.width * cam.height;
    numPixels2 = cam2.width * cam2.height;
    // Create an array to store the previously captured frame
    previousFrame = new int[numPixels];
    previousFrame2 = new int[numPixels2];
    loadPixels();
  }


  void captureEvent(Capture cam, Capture cam2) {
    // Save previous frame for motion detection!!

    prevFrame.copy(cam, 0, 0, cam.width, cam.height, 0, 0, cam.width, cam.height); // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.updatePixels();  // Read image from the camera
    cam.read();

    prevFrame_.copy(cam2, 0, 0, cam2.width, cam2.height, 0, 0, cam2.width, cam2.height); // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame_.updatePixels();  // Read image from the camera
    cam2.read();
  }


  void draw() {
    if (mode == "menu") {
      float intensity = map(mouseX, 0, width, 0.0f, 1.0f);

      blendedBackground = Blend.apply(backgroundTester, backgroundTester2, intensity);
      background(blendedBackground);

      textFont(font, 200);
      fill(#FFDD6F);
      text("BLEND", width/4-40, height/3);
      fill(#90C3D4);

      // display buttons
      circle1.display(circle1.isHover());
      if (circle2.isHover() || circle3.isHover()) {
        circle2.display(true);
        circle3.display(true);
      } else {
        circle2.display(false);
        circle3.display(false);
      }
    } else if (mode == "single player menu") {
      float intensity = map(mouseX, 0, width, 0.0f, 1.0f);

      blendedBackground = Blend.apply(backgroundTester, backgroundTester2, intensity);
      background(blendedBackground);
      textFont(font, 70);
      fill(#FFDD6F);
      text("Pick your Blend", 340, 450);
      for (int i = 0; i < rectangles.size(); i++) {
        if (rectangles.get(i).isHover()) {
          rectangles.get(i).display(350);
        } else {
          rectangles.get(i).display(300);
        }
      }
      if (menuBox.isHover()) {
        menuBox.display(menuBox.menuHighlight);
      } else {
        menuBox.display(menuBox.menuColor);
      }
    } else if (mode == "single player") {
      count ++;
      // INSERT FLASHING SIGN
      
      
      
      
      
      
      
      
      
      
      if (cam.available() == true) {
        cam.read();
      }
      cam.loadPixels();

      int movementSum = calculateMovement(cam, previousFrame); // Amount of movement in the frame
      float intensity;
      if (movementSum < 20000000) {
        intensity = map(movementSum, 60000000, 10000000, 0.0f, 0.3f);
      } else {
        intensity = map(movementSum, 20000000, 180000000, 0.3f, 1.0f); // some other way to change intensity, maybe whoever is moving more?
      }

      PImage out = Blend.apply(whichBlend, cam, intensity);
      image(out, 0, 0);

      if (menuBox.isHover()) {
        menuBox.display(menuBox.menuHighlight);
      } else {
        menuBox.display(menuBox.menuColor);
      }
    } else {
      if (cam.available() == true) {
        cam.read();
      }
      if (cam2.available() == true) {
        cam2.read();
      }

      cam.loadPixels();
      cam2.loadPixels();

      int movementSum = calculateMovement(cam, previousFrame); // Amount of movement in the frame
      int movementSum2 = calculateMovement(cam2, previousFrame2);

      float intensity = map(movementSum-movementSum2, -150000000, 200000000, 0.0f, 1.0f);

      PImage out = Blend.apply(cam2, cam, intensity);
      image(out, 0, 0);

      if (menuBox.isHover()) {
        menuBox.display(menuBox.menuHighlight);
      } else {
        menuBox.display(menuBox.menuColor);
      }
      sign.display();

      if (menuBox.isHover()) {
        menuBox.display(menuBox.menuHighlight);
      } else {
        menuBox.display(menuBox.menuColor);
      }
    }
  }

  void mousePressed() {
    if (menuBox.isHover()) {
      mode = "menu";
    }
    if (mode == "single player menu") {
      for (int i = 0; i < rectangles.size(); i++) {
        if (rectangles.get(i).isHover()) {
          //rectangles.get(i).
          whichBlend = rectangles.get(i).img;
          mode = "single player";
        }
      }
      if (menuBox.isHover()) {
        mode = "menu";
      }
    } else if (mode == "menu" && circle1.isHover()) { 
      mode = "single player menu";
    } else if (mode == "menu" && (circle2.isHover() || circle3.isHover())) {
      print("Entering double player");
      mode = "double player";
    }
  }

  int calculateMovement(Capture cam, int[] frame) {
    int movementSum = 0; // Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = cam.pixels[i];
      color prevColor = frame[i];
      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;
      // Save the current color into the 'previous' buffer
      frame[i] = currColor;
    }
    return movementSum;
  }
