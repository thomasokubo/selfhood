// Kinect Library
import KinectPV2.*;
// Blob detection library
import blobDetection.*;

import java.util.Set;

// Kinect interface
KinectPV2 kinect;

// Blob detection object
BlobDetection theBlobDetection;

// Custom polygon for blob representation
PolygonBlob poly = new PolygonBlob();

// Person object
Person person;

// Communication object
Communication com;


// PImage to hold incoming imagery and smaller one for blob detection
PImage KinectImage, BlobsImage;

// the kinect's dimensions to be used later on for calculations
int kinectWidth = 640;
int kinectHeight = 480;

// to center and rescale from 640x480 to higher custom resolutions
float reScale;

// background color
color bgColor;

// three color palettes (artifact from me storing many interesting color palettes as strings in an external data file ;-)
String[] palettes = {

  "-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634", 

  "-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031", 

  "-16711663,-13888933,-9029017,-5213092,-1787063,-11375744,-2167516,-15713402,-5389468,-2064585"

};

// an array called flow of 2250 Particle objects (see Particle class)
Particle[] flow = new Particle[2250];

// global variables to influence the movement of all particles
float globalX, globalY;
 //<>//
void setup() {

 
  //size(1280, 720, FX2D);
  //size(1280, 720); //<>// //<>//
  fullScreen(P3D, SPAN);

  kinect = new KinectPV2(this);
  kinect.enableBodyTrackImg(true);
  kinect.init();

  person = new Person();
  com = new Communication(12000, "146.109.312.516");

  // calculate the reScale value
  // currently it's rescaled to fill the complete width (cuts of top-bottom)
  // it's also possible to fill the complete height (leaves empty sides)
  reScale = (float) width / kinectWidth;

  // create a smaller blob image for speed and efficiency
  BlobsImage = createImage(kinectWidth/3, kinectHeight/3, RGB);

  // initialize blob detection object to the blob image dimensions
  theBlobDetection = new BlobDetection(BlobsImage.width, BlobsImage.height);
  theBlobDetection.setThreshold(0.2);
  setupFlowfield();
}



void draw() {

  // fading background
  noStroke();
  fill(bgColor, 65);
  rect(0, 0, width, height);


  // Get Kinect user image
  KinectImage = kinect.getBodyTrackImage();
  
  person.setJoints();

  // Rescale and blur image for blob detection
  BlobsImage.copy(KinectImage, 0, 0, KinectImage.width, KinectImage.height, 0, 0, BlobsImage.width, BlobsImage.height);
  BlobsImage.filter(BLUR);

  // Detect the blobs
  theBlobDetection.computeBlobs(BlobsImage.pixels);

  // Reset the polygon
  poly.reset();
  // Create the polygon from the blobs
  poly.createPolygon();

  // Draw
  drawFlowfield();
}



void setupFlowfield() {

  // set stroke weight (for particle display) to 2.5

  strokeWeight(2.5);

  // initialize all particles in the flow

  for(int i=0; i<flow.length; i++) {

    flow[i] = new Particle(i/10000.0);

  }

  // set all colors randomly now

  setRandomColors(1);

}



void drawFlowfield() {

  // center and reScale from Kinect to custom dimensions

  translate(0, (height-kinectHeight*reScale)/2);

  scale(reScale);

  // set global variables that influence the particle flow's movement

  globalX = noise(frameCount * 0.01) * width/2 + width/4;

  globalY = noise(frameCount * 0.005 + 5) * height;

  // update and display all particles in the flow

  for (Particle p : flow) {

    p.updateAndDisplay();

  }

  // set the colors randomly every 240th frame

  setRandomColors(240);

}



// sets the colors every nth frame

void setRandomColors(int nthFrame) {

  if (frameCount % nthFrame == 0) {

    // turn a palette into a series of strings

    String[] paletteStrings = split(palettes[int(random(palettes.length))], ",");

    // turn strings into colors

    color[] colorPalette = new color[paletteStrings.length];

    for (int i=0; i<paletteStrings.length; i++) {

      colorPalette[i] = int(paletteStrings[i]);

    }

    // set background color to first color from palette

    bgColor = colorPalette[0];

    // set all particle colors randomly to color from palette (excluding first aka background color)

    for (int i=0; i<flow.length; i++) {

      flow[i].col = colorPalette[int(random(1, colorPalette.length))];

    }

  }

}