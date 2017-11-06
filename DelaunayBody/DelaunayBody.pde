// Data structures
import java.util.Set;
import java.util.ArrayList;
// Kinect libraries
import KinectPV2.KJoint;
import KinectPV2.*;
// Image processing and graphic comp. libraries
import megamu.mesh.*;
import gab.opencv.*;

KinectPV2 kinect;
OpenCV opencv;
Person person;
Communication com;

PImage img;
PImage src, dst;
ArrayList<Contour> contours;
ArrayList<Contour> polygons;
ArrayList<Integer> leftHandState;
ArrayList<Integer> rightHandState;

boolean leftOpen = true;
boolean rightOpen = true;

void setup() {
  fullScreen(P3D, SPAN);
  //size(512, 424, P3D);
  //size(1280, 720, P2D);
  //size(1280,720,FX2D);

  kinect = new KinectPV2(this);

  //Enables depth and Body tracking (mask image)
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);
  
  /* ADD **********************************/
  kinect.enableSkeleton3DMap(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  /****************************************/
  
  kinect.init();

  person = new Person();
  com = new Communication(12000, "143.106.219.176,12000");

}

void draw() {
  background(0);
  //translate(width / 2, 0, 0);
  scale(3, 3, 3);
  //image(kinect.getDepthMaskImage(), 0, 0);
  img = kinect.getDepthMaskImage();
  

  int[] depth = kinect.getRawDepthData();
  for (int i=0; i<kinect.WIDTHDepth; i++) {
    for (int j=0; j<kinect.HEIGHTDepth; j++) {
      int offset = i+j*kinect.WIDTHDepth;
      int d = depth[offset];
      if (d>300 && d<1500) {
        img.pixels[offset] = color(0, 255, 0);
      } else {
        img.pixels[offset] = color(0);
      }
    }
  }

  img.updatePixels();
 
  opencv = new OpenCV(this, img);
  opencv.gray();
  opencv.threshold(70);
  dst = opencv.getOutput();
  contours = opencv.findContours();

  noFill();
  strokeWeight(2);
  int counter = 0;
  for (Contour contour : contours) {
    counter++;
    int nothing = 0;
 
    stroke(0, 255, 0);
 
    float[][] points = new float[contour.getPoints().size()/50][4];
    for(int i=0;i<contour.getPoints().size();i++){
      try {
        points[i][0] = contour.getPoints().get(i*50).x;
        points[i][1] = contour.getPoints().get(i*50).y;
      } catch(Exception ex){
        //println("No more points.");
        nothing = 1;
      }
    }
   
    
    Delaunay myDelaunay = new Delaunay(points);
    
    float[][] myEdges = myDelaunay.getEdges();
    pushMatrix();
    for(int i=0; i<myEdges.length; i++)
    {
      float startX = myEdges[i][0];
      float startY = myEdges[i][1];
      float endX = myEdges[i][2]; 
      float endY = myEdges[i][3];
      if (abs(startY - endY) <100 && abs(startX-endX)<100)
        line( startX, startY, endX, endY );
    }
    popMatrix();
  
  }
  
  //ArrayList<KSkeleton> skeletonArray = kinect.getSkeleton3d();
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
  println("Number of people: " + skeletonArray.size());
  
  com.sendBeginningInfo(skeletonArray.size());
 
  for(int i=0;i<skeletonArray.size() && i<6 ;i++){
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if(skeleton.isTracked()){
      KJoint[] joints = skeleton.getJoints();
      try {
        com.sendPersonInfo(i, joints[KinectPV2.JointType_SpineMid].getX(),joints[KinectPV2.JointType_SpineMid].getY(), joints[KinectPV2.JointType_SpineMid].getZ(), joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getY(), joints[KinectPV2.JointType_HandLeft].getZ(),joints[KinectPV2.JointType_HandRight].getX(),joints[KinectPV2.JointType_HandRight].getY(), joints[KinectPV2.JointType_HandRight].getZ(), person.leftState.get(i)-2, person.rightState.get(i)-2);
      } catch (Exception ex) {
        println("No body detected");
      }
      
      //osc.send(msg, destinyLocation);
      com.sendEndingInfo();
    }
  }  
}