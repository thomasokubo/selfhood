class BallHand {
  
  //BallSystem[] balls;
  Ball bodies[];
  PVector center;
  PVector leftHand;
  PVector rightHand;
  int rightState;
  int leftState;
  int bodyColor;

  public BallHand(PVector[] joints, int bodyColor) {
    
    this.bodies = new Ball[big];
    
    // Store body color index
    this.bodyColor = bodyColor;
  
       
    // Create ps list
    //balls = new BallSystem[joints.length];
    // Create ps joints
    for (int j = 0; j < joints.length; j++)
      bodies[j] = new Ball();
      
    center = joints[KinectPV2.JointType_SpineMid];
    leftHand = joints[KinectPV2.JointType_HandLeft];
    rightHand = joints[KinectPV2.JointType_HandRight];
    leftState = 2;
    rightState = 2;  
  }

  public void update(PVector[] joints, Integer left, Integer right) {
    center = joints[KinectPV2.JointType_SpineMid];
    leftHand = joints[KinectPV2.JointType_HandLeft];
    rightHand = joints[KinectPV2.JointType_HandRight];
    
    rightState = right;
    leftState = left;
  }

  public void render() {
    
    String x = Float.toString(this.rightHand.x);
    if(x!="-Infinity"){
      
      if(this.rightState == 2) {
        background(0, 0, 0);

        mX += 0.1 * (this.rightHand.x  - mX);
        mY += 0.1 * (this.rightHand.y - mY);
      }

      mX += 0.1 * (this.rightHand.x - mX);
      mY += 0.1 * (this.rightHand.y - mY);  
 
    } else {
      println("To -infinity");
    }
     
    
    for (int j = 0; j < bodies.length; j++) {
      try{        
        this.bodies[0].render(2); // Problema aqui
        //println(this.bodies[j].X); // Problema aqui
      } catch(NullPointerException ex){
        println(ex);
      }
    }
  }
}  
