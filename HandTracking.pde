import java.util.ArrayList;
import KinectPV2.KJoint;
import KinectPV2.*;
import oscP5.*;
import netP5.*;

KinectPV2 kinect;

Communication com;

float thold = 5;
float spifac = 1.05;
int outnum;
float drag = 0.01;
int big = 1000;
ball bodies[] = new ball[big];
float mX;
float mY;

void setup() {
  //size(1280, 720);
  fullScreen(P2D, SPAN);
  strokeWeight(1);
  fill(255, 255, 255);
  stroke(255, 255, 255, 5);
  background(0, 0, 0);
  smooth(4);

  translate(width/KinectPV2.WIDTHColor,0,0);
  scale(2,1,1);
  for(int i = 0; i < big; i++) {
    bodies[i] = new ball();
  }
  
  kinect = new KinectPV2(this);

  //Enables depth and Body tracking (mask image)
  //kinect.enableDepthMaskImg(true);
  //kinect.enableSkeletonDepthMap(true);
  /* ADD ************************************/  
  kinect.enableSkeleton3DMap(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  /*****************************************/
  kinect.init();
  
  com = new Communication(12000, "143.106.219.176");  
}

void draw() {
  
  
  //get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //ArrayList<KSkeleton> skeletonArray =kinect.getSkeleton3d();

  fill(255);
  text("Number of people: " + skeletonArray.size(), 10, 20 + textAscent());

  int numBodies=0;
  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {  
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) 
      numBodies++;
  }

  com.sendBeginningInfo(skeletonArray.size());
  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {
    
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      
   
      String x = Float.toString(joints[KinectPV2.JointType_HandRight].getX());
      if(x!="-Infinity"){
        
        //if(joints[KinectPV2.JointType_HandRight].getState() == 3) {
        if(kinect.getSkeleton3d().get(i).getRightHandState() == 2) {
          background(0, 0, 0);
          mX += 0.1 * (joints[KinectPV2.JointType_HandRight].getX()  - mX);
          mY += 0.1 * (joints[KinectPV2.JointType_HandRight].getY() - mY);
        }
  
        mX += 0.1 * (joints[KinectPV2.JointType_HandRight].getX() - mX);
        mY += 0.1 * (joints[KinectPV2.JointType_HandRight].getY() - mY);
          
        for(int j = 0; j < big; j++) {
          bodies[j].render(joints[KinectPV2.JointType_HandRight]);
        }       
        com.sendPersonInfo(i, joints[KinectPV2.JointType_SpineMid].getX(),joints[KinectPV2.JointType_SpineMid].getY(),joints[KinectPV2.JointType_SpineMid].getZ(),joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getY(),joints[KinectPV2.JointType_HandLeft].getZ(),joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getState(),joints[KinectPV2.JointType_HandLeft].getState());
      } else {
        println("To -infinity");
      }
      
      
      
     
    }
    
  } 
  com.sendEndingInfo();
}

class ball {
  float X;
  float Y;
  float Xv;
  float Yv;
  float pX;
  float pY;
  float w;
  
  ball() {
    try{
      X = random(width/KinectPV2.WIDTHColor);
      Y = random(height/KinectPV2.HEIGHTColor);
      w = random(1/thold, thold);
    } catch(Exception ex){
      println("To infinity");
    }
  }
  
  void render(KJoint joint) {
    if(joint.getState() != 2) {
      Xv /= spifac;
      Yv /= spifac;
    }
    Xv += drag * (mX - X) * w;
    Yv += drag * (mY - Y) * w;
    X += Xv;
    Y += Yv;
    line(X, Y, pX, pY);
    pX = X;
    pY = Y;
  }
}
