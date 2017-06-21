import KinectPV2.KJoint;
import KinectPV2.KinectPV2;
import KinectPV2.KSkeleton;
import KinectPV2.HDFaceData;
import processing.core.*;


KinectPV2 kinect;

ArrayList<KSkeleton> skeleton;
ArrayList<Integer> leftState;
ArrayList<Integer> rightState;
  
  public void setup() {
    size(1920, 1080, P3D);

    kinect = new KinectPV2(this);
    
    kinect.enableColorImg(true);
    kinect.enableHDFaceDetection(true);
    kinect.enableSkeletonColorMap(true);
     
    kinect.init();
    
    
    leftState = new ArrayList<Integer>();
    rightState = new ArrayList<Integer>();
    for(int i=0;i<6;i++)
      leftState.add(2);
    for(int i=0;i<6;i++)
      rightState.add(2);
  }

  public void draw() {
    background(0);

    // DRAW COLOR IMAGE MAP
    // image(kinect.getColorImage(), 0, 0);

    ArrayList<HDFaceData> hdFaceData = kinect.getHDFaceVertex();

    stroke(0, 255, 0);
    for (int j = 0; j < KinectPV2.BODY_COUNT; j++) {
      beginShape(POINTS);
      try {
      if (hdFaceData.get(j).isTracked()) {
        for (int i = 0; i < KinectPV2.HDFaceVertexCount; i++) {
          float x = hdFaceData.get(j).getX(i);
          float y = hdFaceData.get(j).getY(i);
          vertex(x, y);
        }
      }
      } catch(Exception ex){
        println("No body detected.");
        
      }
      endShape();
    }

    skeleton =  kinect.getSkeletonColorMap();
      
    // individual JOINTS
    for (int i = 0; i < skeleton.size(); i++) {
      if (skeleton.get(i).isTracked()) {
        KJoint[] joints = skeleton.get(i).getJoints();

        int col = getIndexColor(i,joints[KinectPV2.JointType_HandRight]);
        fill(col);
        stroke(col);
        drawBody(joints);

        // draw different color for each hand state
        drawHandState(joints[KinectPV2.JointType_HandRight]);
        drawHandState(joints[KinectPV2.JointType_HandLeft]);
        
        try{
          // State of right hand      
          if(kinect.getSkeleton3d().get(i).getRightHandState()==3 && rightState.get(i)==2)
            rightState.set(i,3);
          else if(kinect.getSkeleton3d().get(i).getRightHandState()==2 && rightState.get(i)==3)
            rightState.set(i,2);
        } catch(Exception ex){
          
        }
        
  
      }
    }
    
     fill(255, 0, 0);
     text(frameRate, 50, 50);
  }

  // use different color for each skeleton tracked
  int getIndexColor(int index, KJoint handJoint) {
    int col = color(255);
    switch(handJoint.getState()){
      case KinectPV2.HandState_Closed: 
        if (index == 0)
          col = color(255, 0, 0);
        if (index == 1)
          col = color(0, 255, 0);
        if (index == 2)
          col = color(0, 0, 255);
        if (index == 3)
          col = color(255, 255, 0);
        if (index == 4)
          col = color(0, 255, 255);
        if (index == 5)
          col = color(255, 0, 255);
        break;
      case KinectPV2.HandState_Open:
        col = color(0,0,0);
        break;
    }
    return col;
  }

  // DRAW BODY
  void drawBody(KJoint[] joints) {
    drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
    drawBone(joints, KinectPV2.JointType_Neck,
        KinectPV2.JointType_SpineShoulder);
    drawBone(joints, KinectPV2.JointType_SpineShoulder,
        KinectPV2.JointType_SpineMid);
    drawBone(joints, KinectPV2.JointType_SpineMid,
        KinectPV2.JointType_SpineBase);
    drawBone(joints, KinectPV2.JointType_SpineShoulder,
        KinectPV2.JointType_ShoulderRight);
    drawBone(joints, KinectPV2.JointType_SpineShoulder,
        KinectPV2.JointType_ShoulderLeft);
    drawBone(joints, KinectPV2.JointType_SpineBase,
        KinectPV2.JointType_HipRight);
    drawBone(joints, KinectPV2.JointType_SpineBase,
        KinectPV2.JointType_HipLeft);

    // Right Arm
    drawBone(joints, KinectPV2.JointType_ShoulderRight,
        KinectPV2.JointType_ElbowRight);
    drawBone(joints, KinectPV2.JointType_ElbowRight,
        KinectPV2.JointType_WristRight);
    drawBone(joints, KinectPV2.JointType_WristRight,
        KinectPV2.JointType_HandRight);
    drawBone(joints, KinectPV2.JointType_HandRight,
        KinectPV2.JointType_HandTipRight);
    drawBone(joints, KinectPV2.JointType_WristRight,
        KinectPV2.JointType_ThumbRight);

    // Left Arm
    drawBone(joints, KinectPV2.JointType_ShoulderLeft,
        KinectPV2.JointType_ElbowLeft);
    drawBone(joints, KinectPV2.JointType_ElbowLeft,
        KinectPV2.JointType_WristLeft);
    drawBone(joints, KinectPV2.JointType_WristLeft,
        KinectPV2.JointType_HandLeft);
    drawBone(joints, KinectPV2.JointType_HandLeft,
        KinectPV2.JointType_HandTipLeft);
    drawBone(joints, KinectPV2.JointType_WristLeft,
        KinectPV2.JointType_ThumbLeft);

    // Right Leg
    drawBone(joints, KinectPV2.JointType_HipRight,
        KinectPV2.JointType_KneeRight);
    drawBone(joints, KinectPV2.JointType_KneeRight,
        KinectPV2.JointType_AnkleRight);
    drawBone(joints, KinectPV2.JointType_AnkleRight,
        KinectPV2.JointType_FootRight);

    // Left Leg
    drawBone(joints, KinectPV2.JointType_HipLeft,
        KinectPV2.JointType_KneeLeft);
    drawBone(joints, KinectPV2.JointType_KneeLeft,
        KinectPV2.JointType_AnkleLeft);
    drawBone(joints, KinectPV2.JointType_AnkleLeft,
        KinectPV2.JointType_FootLeft);

    drawJoint(joints, KinectPV2.JointType_HandTipLeft);
    drawJoint(joints, KinectPV2.JointType_HandTipRight);
    drawJoint(joints, KinectPV2.JointType_FootLeft);
    drawJoint(joints, KinectPV2.JointType_FootRight);

    drawJoint(joints, KinectPV2.JointType_ThumbLeft);
    drawJoint(joints, KinectPV2.JointType_ThumbRight);

    drawJoint(joints, KinectPV2.JointType_Head);
  }

  void drawJoint(KJoint[] joints, int jointType) {
    pushMatrix();
    translate(joints[jointType].getX(), joints[jointType].getY(),
        joints[jointType].getZ());
    ellipse(0, 0, 25, 25);
    popMatrix();
  }

  void drawBone(KJoint[] joints, int jointType1, int jointType2) {
    pushMatrix();
    translate(joints[jointType1].getX(), joints[jointType1].getY(),
        joints[jointType1].getZ());
    ellipse(0, 0, 25, 25);
    popMatrix();
    line(joints[jointType1].getX(), joints[jointType1].getY(),
        joints[jointType1].getZ(), joints[jointType2].getX(),
        joints[jointType2].getY(), joints[jointType2].getZ());
  }

  void drawHandState(KJoint joint) {
    noStroke();
    handState(joint.getState());
    pushMatrix();
    translate(joint.getX(), joint.getY(), joint.getZ());
    ellipse(0, 0, 70, 70);
    popMatrix();
  }

  /*
   * Different hand state KinectPV2.HandState_Open KinectPV2.HandState_Closed
   * KinectPV2.HandState_Lasso KinectPV2.HandState_NotTracked
   */
  void handState(int handState) {
    switch (handState) {
    case KinectPV2.HandState_Open:
      fill(0, 255, 0);
      break;
    case KinectPV2.HandState_Closed:
      fill(255, 0, 0);
      break;
/*    case KinectPV2.HandState_Lasso:
      fill(0, 0, 255);
      break;
    case KinectPV2.HandState_NotTracked:
      fill(255, 255, 255);
      break;*/
    }
  }
