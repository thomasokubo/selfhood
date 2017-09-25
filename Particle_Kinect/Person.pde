class Person {
  
  HashMap<Integer, PVector[]> bodies;
  ArrayList<Integer> leftState;
  ArrayList<Integer> rightState;
  ArrayList<Boolean> tracked;
  
  // Constructor
  Person(){
    try {
      bodies =  new HashMap<Integer, PVector[]>();
      leftState = new ArrayList<Integer>();
      rightState = new ArrayList<Integer>();
      tracked = new ArrayList<Boolean>();
      for(int i=0;i<6;i++){
        leftState.add(2);
        rightState.add(2);
        tracked.add(false);
      }
    } catch(NullPointerException ex) {
      println("Exception: " +ex);
    }
  }
  
 
  void SetJoints(){
    // Set all joints from the detected bodies
    for (KSkeleton skeleton : kinect.getSkeleton3d())
      if (skeleton.isTracked())
         this.bodies.put(skeleton.getIndexColor(), mapSkeletonToScreen(skeleton.getJoints()));
  }
  
  
  PVector[] GetJoints(int index){
    return bodies.get(index);
  }
  
  void SetHandsState(int body){
        // State of left hand: open(2) closed(3)
      if(kinect.getSkeleton3d().get(body).getLeftHandState()==3 && leftState.get(body)==2)
        leftState.set(body,3);
      else if(kinect.getSkeleton3d().get(body).getLeftHandState()==2 && leftState.get(body)==3) 
        leftState.set(body,2);
          
       
      // State of right hand      
      if(kinect.getSkeleton3d().get(body).getRightHandState()==3 && rightState.get(body)==2)
        rightState.set(body,3);
      else if(kinect.getSkeleton3d().get(body).getRightHandState()==2 && rightState.get(body)==3)
        rightState.set(body,2);{
  }
  

  
  
}