// Data structures
import java.util.Set;
import java.util.ArrayList;

// Kinect libraries
import KinectPV2.KJoint;
import KinectPV2.*;

// Image processing and graphic comp. libraries
import megamu.mesh.*;
import gab.opencv.*;

// OSC libraries
import netP5.*;
import oscP5.*;

KinectPV2 kinect;
OpenCV opencv;
OscP5 osc;
NetAddress destinyLocation;

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

  
  /* ADD **********************************/  
  osc = new OscP5(this,12000);
  destinyLocation = new NetAddress("143.106.219.176,12000", 12000);

  leftHandState = new ArrayList<Integer>();
  rightHandState = new ArrayList<Integer>();
  for(int i=0;i<6;i++){
    leftHandState.add(2);
    rightHandState.add(2);
  }
 /****************************************/
 
}

void draw() {
  background(0);
  translate(width / 2, 0, 0);
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
    
  /* Add ***************************************************/
  
  //ArrayList<KSkeleton> skeletonArray = kinect.getSkeleton3d();
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
  println("Number of people: " + skeletonArray.size());
  
  // Send number of people to PD
  OscMessage msg = new OscMessage("/people/number");
  msg.add(skeletonArray.size());
  osc.send(msg, destinyLocation);
  
  
  for(int i=0;i<skeletonArray.size() && i<6 ;i++){
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if(skeleton.isTracked()){
      msg.clear();
      msg.setAddrPattern("/people/position/p" + i);
      
      KJoint[] joints = skeleton.getJoints();

      try {
        
        // All coordinates were normalized in [0-1]
        // Mid spine coordinates 
        msg.add(map(joints[KinectPV2.JointType_SpineMid].getX(), 0, width,  0,1));
        msg.add(map(joints[KinectPV2.JointType_SpineMid].getY(), 0, width,  0,1));
        msg.add(map(joints[KinectPV2.JointType_SpineMid].getZ(), 0, width,  0,1));
      
        // Left hand coordinates
        msg.add(map(joints[KinectPV2.JointType_HandLeft].getX(), 0, width,  0,1));
        msg.add(map(joints[KinectPV2.JointType_HandLeft].getY(), 0, width,  0,1));
        msg.add(map(joints[KinectPV2.JointType_HandLeft].getZ(), 0, width,  0,1));
        
        // Right hand coordinates
        msg.add(map(joints[KinectPV2.JointType_HandRight].getX(), 0, width,  0,1));
        msg.add(map(joints[KinectPV2.JointType_HandRight].getY(), 0, width,  0,1));
        msg.add(map(joints[KinectPV2.JointType_HandRight].getZ(), 0, width,  0,1));
      
       // State of left hand: open(2) closed(3)
        if(skeleton.getLeftHandState()==3 && leftHandState.get(i)==2)
          leftHandState.set(i,3);
        else if(skeleton.getLeftHandState()==2 && leftHandState.get(i)==3) 
          leftHandState.set(i,2);
          
        msg.add(leftHandState.get(i)-2);
        
       
        
        // State of right hand: open(2) closed(3)
        if(skeleton.getRightHandState()==3 && rightHandState.get(i)==2)
          rightHandState.set(i,3);
       
        else if(skeleton.getRightHandState()==2 && rightHandState.get(i)==3) 
          rightHandState.set(i,2);
          
        msg.add(rightHandState.get(i)-2);
          
        drawHandState(joints, i);
    
      } catch (Exception ex) {
        println("No body detected");
      }
      
      osc.send(msg, destinyLocation);
      
    }
  }  
  
  
  
  /********************************************************/
  
  /*
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
   
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
       drawHandState(joints[KinectPV2.JointType_HandRight], 0);
       drawHandState(joints[KinectPV2.JointType_HandLeft], 1);
       drawVolume(joints[KinectPV2.JointType_HandLeft]);
     }
   }
  */
   /*
   pushMatrix();
   noFill();
   strokeWeight(10);
   arc(350, 400, 725, 725, PI-QUARTER_PI, TWO_PI+QUARTER_PI);
   popMatrix();

  fill(255, 0, 0);
  text(frameRate, 50, 50);
  */
}

void drawVolume(KJoint joint){
  if(!leftOpen){
    strokeWeight(10);
    pushMatrix();
    translate(joint.getX(), joint.getY(), joint.getZ());
    //ellipse(0, 0, 50, 50);
    line(0, 0,joint.getX(), joint.getY());
    popMatrix();
  
  }
}


//draw the body
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  //Single joints
  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw a single joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw a bone from two joints
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

void drawHandState(KJoint[] joints, int i) {
  color yellow = color(255,255,0);
  color black = color(0,0,0);
  if(rightHandState.get(i)==3){
    noStroke();
    fill(yellow);
    pushMatrix();
    ellipse(joints[KinectPV2.JointType_HandRight].getX(),joints[KinectPV2.JointType_HandRight].getY(),50,50);
    popMatrix();
    noStroke();
    fill(black);
    pushMatrix();
    ellipse(joints[KinectPV2.JointType_HandRight].getX(),joints[KinectPV2.JointType_HandRight].getY(),40,40);
    popMatrix();
  }
  
  if(leftHandState.get(i)==3){
    noStroke();
    fill(yellow);
    pushMatrix();
    ellipse(joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getY(),50,50);
    popMatrix();
    
    noStroke();
    fill(black);
    pushMatrix();
    ellipse(joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getY(),40,40);
    popMatrix();
  }
  
  if(rightHandState.get(i)==3 && leftHandState.get(i)==3){
    strokeWeight(5);
    stroke(yellow);
    pushMatrix();
    line(joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getY(), joints[KinectPV2.JointType_HandRight].getX(),joints[KinectPV2.JointType_HandRight].getY());
    popMatrix();
    
    /* Volume's visual effect */
  } /*else if(rightHandState.get(i)!=3 && leftHandState.get(i)==3) {
    strokeWeight(5);
    stroke(yellow);
    pushMatrix();
    line(joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getY(), joints[KinectPV2.JointType_HandLeft].getX(), kinect.HEIGHTDepth);
    popMatrix();
  
  }*/
  
}



//Depending on the hand state change the color
void leftHandState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    leftOpen = true;
    break;
  case KinectPV2.HandState_Closed:
    leftOpen = false;
    fill(255, 255, 0);
    break;
  case KinectPV2.HandState_Lasso:
    if(!leftOpen)
      fill(255, 255, 0);
    break;
  case KinectPV2.HandState_NotTracked:
    /*if(!leftOpen)
      fill(255, 255, 0);*/
    leftOpen = true; 
    break;
    
  }
}

void rightHandState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    rightOpen = true;
    break;
  case KinectPV2.HandState_Closed:
    rightOpen = false;
    fill(255, 255, 0);
    break;
  case KinectPV2.HandState_Lasso:
    if(!rightOpen)
      fill(255, 255, 0);
    break;
  case KinectPV2.HandState_NotTracked:
    rightOpen = true;
    break;
    
    
  }
}
