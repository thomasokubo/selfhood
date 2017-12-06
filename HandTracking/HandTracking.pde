  // Data structure library
import java.util.ArrayList;
import java.util.Set;
import java.util.*;

// Kinect library
import KinectPV2.KJoint;
import KinectPV2.*;

// OSC libraries
import oscP5.*;
import netP5.*;

KinectPV2 kinect;
Communication com;
Person person;



// Turn into a vector
float mX;
float mY;

//Ball bodies[] = new Ball[big];
HashMap<Integer, BallHand> ballHands;
//HashMap<Integer, PVector[]> trackedBodies;

void setup() {
  //size(1280, 720);
  fullScreen(P3D, SPAN);
  frameRate(30);
  
  strokeWeight(1);
  fill(255);
  stroke(255, 255, 255, 5);
  background(0, 0, 0);
  smooth(4);
  
  kinect = new KinectPV2(this);
  kinect.enableSkeleton3DMap(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  kinect.init();
  
  ballHands = new HashMap<Integer, BallHand>();
  com = new Communication(12000, "143.106.219.176");
  person = new Person();
  
}

void draw() {
 
  // person has the joints mapped into pvector
  person.setJoints();
  
  // set of id's 
  Set<Integer> detectedId = person.getKeys();
  
  // update bodies position
  for(Integer id: person.getKeys()){
    // get person or null
    BallHand bh = ballHands.getOrDefault(id, null);
    
    if(bh==null){
      bh = new BallHand(person.getBodies().get(id), id);
      ballHands.put(id, bh);
    } else {
      bh.update(person.getBodies().get(id), person.getLeftState(id), person.getRightState(id));
    }
  }
  
  /***********VERIFIED***********/


  //verify if person is still present
  BallHand[] bhands = ballHands.values().toArray(new BallHand[0]); 

  for(int b = bhands.length-1; b>=0;b--){
    if(detectedId.contains(bhands[b].bodyColor)){
      bhands[b].render(); // Problema aqui
    }
  }
  

  //If certain is not tracked anymore, its particle body is removed
  if (detectedId.size() != ballHands.size()) {
    ArrayList<Integer> deadBodies = new ArrayList<Integer>();

    for (Integer id : ballHands.keySet())
      if (!deadBodies.contains(id))
        deadBodies.add(id);

    for (Integer id : deadBodies)
      ballHands.remove(id);
  }  
  
  fill(255);
  text("Number of people: " + ballHands.size(), 10, 20 + textAscent());
  com.sendBeginningInfo(detectedId.size());
  
  /*
  //individual joints
  for (int i = 0; i < bhands.length; i++) {
   
    BallHand hand = bhands[i];
      
      String x = Float.toString(hand.rightHand.x);
      if(x!="-Infinity"){
        
        if(kinect.getSkeleton3d().get(i).getRightHandState() == 2) {
          background(0, 0, 0);

          mX += 0.1 * (hand.rightHand.x  - mX);
          mY += 0.1 * (hand.rightHand.y - mY);
        }
  
        mX += 0.1 * (hand.rightHand.x - mX);
        mY += 0.1 * (hand.rightHand.y - mY);  
 
        com.sendPersonInfo(i, hand.center.x, hand.center.y, hand.center.z, hand.rightHand.x, hand.rightHand.y, hand.rightHand.z, hand.leftHand.x,  hand.leftHand.y, hand.leftHand.z, hand.leftState, hand.rightState);
      } else {
        println("To -infinity");
      }
    }
  
  com.sendEndingInfo();
  */
 
}
