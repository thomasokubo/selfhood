class Person {
  
  HashMap<Integer, PVector[]> bodies;
  
  //wont use it
  HashMap<Integer, Integer> leftState;
  HashMap<Integer, Integer> rightState;

  Util util;
  
  // Constructor
  Person(){
    try {
      bodies =  new HashMap<Integer, PVector[]>();
      leftState = new HashMap<Integer, Integer>();
      rightState = new HashMap<Integer, Integer>();
      util = new Util();
    } catch(NullPointerException ex) {
      println("Exception: " +ex);
    }
  }
  
 
  void setJoints(){
    // Set all joints from the detected bodies
    for (KSkeleton skeleton : kinect.getSkeleton3d())
      if (skeleton.isTracked()){
         this.bodies.put(skeleton.getIndexColor(), util.mapSkeletonToScreen(skeleton.getJoints()));
         this.leftState.put(skeleton.getIndexColor(), skeleton.getLeftHandState());
         this.rightState.put(skeleton.getIndexColor(), skeleton.getRightHandState());
      }
  }
  
  
  PVector[] GetJoints(int index){
    return bodies.get(index);
  }
  

  HashMap<Integer, PVector[]> getBodies() {
    return this.bodies;
  }
  
  Integer getLeftState(Integer index) {
    return this.leftState.get(index);
  }
  
  Integer getRightState(Integer index) {
    return this.rightState.get(index);
  }
  
  Set<Integer> getKeys() {
    return bodies.keySet();
  }
  
  int getSize(){
    return bodies.size();
  }
  
  
  
}
