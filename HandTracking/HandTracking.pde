import java.util.ArrayList;
import java.util.Set;
import java.util.*;
import KinectPV2.KJoint;
import KinectPV2.*;
// OSC libraries
import oscP5.*;
import netP5.*;



float thold = 5;
float spifac = 1.05;
int outnum;
float drag = 0.01;
int big = 1000;
float mX;
float mY;

KinectPV2 kinect;
Communication com;
Ball bodies[] = new Ball[big];
HashMap<Integer, BallHand> ballHands;
HashMap<Integer, PVector> trackedBodies;

void setup() {
  //size(1280, 720);
  fullScreen(P3D, SPAN);
  strokeWeight(1);
  fill(255, 255, 255);
  stroke(255, 255, 255, 5);
  background(0, 0, 0);
  smooth(4);

  //translate(width/KinectPV2.WIDTHColor,0,0);
  //scale(2,1,1);
  
  for(int i = 0; i < big; i++) {
    bodies[i] = new Ball();
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
  
  ballHands = new HashMap<Integer, BallHand>();
  com = new Communication(12000, "143.106.219.176");  
}

void draw() {
  
  fill(255);
  text("Number of people: " + skeletonArray.size(), 10, 20 + textAscent());  

  // Set all joints from the detected bodies
  trackedBodies =  new HashMap<Integer, PVector[]>();
  for (KSkeleton skeleton : kinect.getSkeleton3d())
    if (skeleton.isTracked())
       this.trackedBodies.put(skeleton.getIndexColor(), util.mapSkeletonToScreen(skeleton.getJoints()));


  // update bodies position
  for(Integer id: trackedBodies.keySet()){
    BallHand bh = ballHands.getOrDefault(id, null);
    
    if(bh==null){
      bh = new BallHand(trackedBodies.get(id), id);
      trackedBodies.put(id, bh);
    } else {
      bh.update(trackedBodies.get(id));
    }
  }

  //verify if person is still present
  BallHand[] bhands = ballhands.values().toArray(new BallHand[0]); 

  for(int b = bhands.length-1; b>=0;b--){
    if(trackedBodies.keySet().contains(bhands[b].bodyColor)){
      PVector body = trackedBodies.get(bhands[b].bodyColor);
     // bhands[b].render()
    
    }
  }
  
  //If certain is not tracked anymore, its particle body is removed
  if (trackedBodies.keySet().size() != particleBodies.size()) {
    ArrayList<Integer> deadBodies = new ArrayList<Integer>();

    for (Integer id : trackedBodies.keySet())
      if (!deadBodies.contains(id))
        deadBodies.add(id);

    for (Integer id : deadBodies)
      particleBodies.remove(id);
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
