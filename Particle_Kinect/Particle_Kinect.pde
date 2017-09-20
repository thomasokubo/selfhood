// Data structure
// Data structure
import java.util.Set;

// Kinect libraries
import KinectPV2.KJoint;
import KinectPV2.*;

 
// Kinect conatainer
KinectPV2 kinect;

// Communication object
Communication com;

// Body of particles to be rendered
HashMap<Integer, ParticleBody> particleBodies;

// Max distance between two bodies
float maxDist = dist(0, 0, width, height);

// Array to save the states of the hands
ArrayList<Integer> leftState;
ArrayList<Integer> rightState;


void setup() {
  
  // Screen size, renderer and frameRate
  fullScreen(P3D, SPAN);
  //size(1280, 720, FX2D);
  frameRate(30);

  // Kinect setup
  kinect = new KinectPV2(this);
  kinect.enableSkeleton3DMap(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  kinect.init();
  
  // Create bodies holder
  particleBodies = new HashMap<Integer, ParticleBody>();
  
  // Initialize Communication module
  com = new Communication(12000, "143.106.219.176"); 

  // Initiate hands state
  try {
    leftState = new ArrayList<Integer>();
    rightState = new ArrayList<Integer>();
    for(int i=0;i<6;i++){
      leftState.add(2);
      rightState.add(2);
    }
  } catch(NullPointerException ex) {
    println("Exception: " +ex);
  }
}

void draw() {
  // Clear screen
  background(0);

  // Print FPS
  text("FPS " + round(frameRate), 10, 10 + textAscent());

  
  /******** ADD to MODEL class ****************************************************************************/ 
  // Get bodies from record or kinect
  HashMap<Integer, PVector[]> bodies =  new HashMap<Integer, PVector[]>();
  
 // Get all joints from the detected bodies
  for (KSkeleton skeleton : kinect.getSkeleton3d())
    if (skeleton.isTracked())
       bodies.put(skeleton.getIndexColor(), mapSkeletonToScreen(skeleton.getJoints()));
    
  // Pass bodies indexes to detectedID
  Set<Integer> detectedId = bodies.keySet();
  
  /************************************************************************************************************/
  // Até aqui temos: bodies(HashMap<Integer, PVector[]>), detectedID
  
  
  /******** ADD to VIEW class ****************************************************************************/
  // Update bodies position
  for (Integer id : bodies.keySet()) {
    ParticleBody pBody = particleBodies.getOrDefault(id, null);     

    if (pBody == null) {
      // Create a new particle body
      pBody = new ParticleBody(bodies.get(id), id);
      // Store list
      particleBodies.put(id, pBody);
    } else {
      // Update body's joints
      pBody.update(bodies.get(id));
    }
  }
  
  
  // Verify if person is still present
  ParticleBody[] pBodies = particleBodies.values().toArray(new ParticleBody[0]);

  for (int b = pBodies.length - 1; b >=0; b--) {
    if (detectedId.contains(pBodies[b].bodyColor)) {
      pBodies[b].render(pBodies);
    } else if (pBodies[b].isDead()) {
      particleBodies.remove(b);
    }
  }

  //If certain is not tracked anymore, its particle body is removed
  if (detectedId.size() != particleBodies.size()) {
    ArrayList<Integer> deadBodies = new ArrayList<Integer>();

    for (Integer id : particleBodies.keySet())
      if (!deadBodies.contains(id))
        deadBodies.add(id);

    for (Integer id : deadBodies)
      particleBodies.remove(id);
  }
  /************************************************************************************************************/


  fill(255);
  text("Body count: " + particleBodies.size(), 10, 20 + textAscent());
 
 
  // Communication Part ====================================================
  
  // Sends beginning information to PD with the number os people detected
  com.sendBeginningInfo(detectedId.size());

  // Send coordenates and state of both hands: open(0) and closed(1)
  // PS: if the state is unkonwn, it will interpretate as closed
  for (int body = 0; body < pBodies.length; body++) {
    ParticleBody particleBody = pBodies[body];
    
    
  
    try {
      
      /******** ADD to MODEL class ****************************************************************************/    
      // State of left hand: open(2) closed(3)
      if(kinect.getSkeleton3d().get(body).getLeftHandState()==3 && leftState.get(body)==2)
        leftState.set(body,3);
      else if(kinect.getSkeleton3d().get(body).getLeftHandState()==2 && leftState.get(body)==3) 
        leftState.set(body,2);
          
       
      // State of right hand      
      if(kinect.getSkeleton3d().get(body).getRightHandState()==3 && rightState.get(body)==2)
        rightState.set(body,3);
      else if(kinect.getSkeleton3d().get(body).getRightHandState()==2 && rightState.get(body)==3)
        rightState.set(body,2);
      /************************************************************************************************************/
        
        
      // Sends person information  
      com.sendPersonInfo(body, particleBody.center.x, particleBody.center.y, particleBody.center.z, particleBody.leftHand.x, particleBody.leftHand.y, particleBody.leftHand.z, particleBody.rightHand.x, particleBody.rightHand.y, particleBody.rightHand.z, leftState.get(body)-2, rightState.get(body)-2);
    } catch(Exception ex){
      println("Exception " + ex);
    }
  }
  
  // Sends ending infromation to PD
  com.sendEndingInfo();
  
}




/*============================================================================================================================================================================================*/
// Particle Body model
//TODO Add this function into ParticleBody class 
PVector[] mapSkeletonToScreen(KJoint[] joints) {
  // Create mapped joints array
  PVector[] mappedJoints = new PVector[joints.length];
  for (int j = 0; j < joints.length; j++) {
    mappedJoints[j] = kinect.MapCameraPointToColorSpace(joints[j].getPosition());
    mappedJoints[j].x *= (float)width / KinectPV2.WIDTHColor;
    mappedJoints[j].y *= (float)height / KinectPV2.HEIGHTColor;
  }
  return mappedJoints;
}


// Particle body
/*
class ParticleBody {
  ParticleSystem[] psJoints;
  PVector center;
  PVector leftHand;
  PVector rightHand;
  int bodyColor;
  Timer addParticleTimer;

  public ParticleBody(PVector[] joints, int bodyColor) {
    // Store body color index
    this.bodyColor = bodyColor;
       
    // Create ps list
    psJoints = new ParticleSystem[joints.length];
    // Create ps joints
    for (int j = 0; j < joints.length; j++)
      psJoints[j] = new ParticleSystem(20, joints[j], bodyColor);
    // Create and start timer
    addParticleTimer = new Timer();
    center = joints[KinectPV2.JointType_SpineMid];
    leftHand = joints[KinectPV2.JointType_HandLeft];
    rightHand = joints[KinectPV2.JointType_HandRight];
  }

  public void update(PVector[] joints) {
    for (int j = 0; j < joints.length; j++)
      // Update ps positions
      psJoints[j].origin = joints[j];
    center = joints[KinectPV2.JointType_SpineMid];
    leftHand = joints[KinectPV2.JointType_HandLeft];
    rightHand = joints[KinectPV2.JointType_HandRight];
  }

  public void render(ParticleBody[] pBodies) {
    // Check if its time to add a new particle to the each ps
    if (addParticleTimer.getTime() > 1) {
      int pColor = bodyColor;
      for (int b = 0; b < pBodies.length; b++) {
        //if(rightState.get(b)==2) bodyColor=0;
        if (pBodies[b].bodyColor == bodyColor)
          continue;
        float dist = dist(pBodies[b].center.x, pBodies[b].center.y, center.x, center.y);
        float choice = random(maxDist); 
        text(choice + " \\ " + dist, 10, 30 + textAscent());
        if (5 * choice > dist) {
          pColor = pBodies[b].bodyColor;
          break;
        }
      }
      for (int j = 0; j < psJoints.length; j++) {
        // Run ps
        psJoints[j].run();
        // Add a new particle to the ps
        psJoints[j].addParticle(1, pColor);
      }
      addParticleTimer.reset();
    } else {
      for (int j = 0; j < psJoints.length; j++) {
        // Run ps
        psJoints[j].run();
      }
    }
  }

  public boolean isDead() {
    for (ParticleSystem ps : psJoints) {
      if (!ps.isDead())
        return false;
    }
    return true;
  }
}
*/


// Particle System
/*************************************
class ParticleSystem {

  ArrayList<Particle> particles;
  PVector origin;
  int psColor;

  ParticleSystem(int num, PVector v, int psColor) {
    this.psColor = psColor;
    particles = new ArrayList<Particle>();
    origin = v.copy();
    addParticle(num, psColor);
  }

  void run() {
    // Cycle through the ArrayList backwards, because we are deleting while iterating
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  void addParticle(int numberParticles, int currentColor) {
    for (int i = 0; i < numberParticles; i++) {
      particles.add(new Particle(origin, currentColor));
    }
  }

  // A method to test if the particle system still has particles
  boolean isDead() {
    return particles.isEmpty();
  }
}
*********************/


// A simple Particle class
/*
class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  int birth;
  int pColor;

  Particle(PVector l, int pColor) {
    acceleration = new PVector(0, 0.1);
    velocity = new PVector(random(-1, 1), random(-2, 0));
    position = l.copy().add(random(-50, 50), random(-50, 50));
    lifespan = 1000.0;
    birth = millis();
    this.pColor = pColor;
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
  }

  // Method to display
  void display() {
    stroke(255, lifespan);
    fill(pColor, lifespan);
    ellipse(position.x, position.y, 4, 4);
  }

  // Is the particle still useful?
  boolean isDead() {
    return (millis() - birth > lifespan);
  }
}
*/

class Timer {
  int initialTime;

  public Timer() {
    reset();
  }

  public int getTime() {
    return millis() - initialTime;
  }

  public void reset() {
    initialTime = millis();
  }
}

/*
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}
*/