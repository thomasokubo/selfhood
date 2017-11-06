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

// Person object
Person person;

// Body of particles to be rendered
HashMap<Integer, ParticleBody> particleBodies;

// Max distance between two bodies
float maxDist = dist(0, 0, width, height);

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
  person = new Person();
  
}

void draw() {
  // Clear screen
  background(0);

  // Print FPS
  text("FPS " + round(frameRate), 10, 10 + textAscent());

 
  // Set all joints from the detected bodies 
  person.setJoints();  
  
  
  /******** ADD to VIEW class ****************************************************************************/
  // Pass bodies indexes to detectedID
  Set<Integer> detectedId = person.getKeys();
  
  // Update bodies position
  for (Integer id : person.getKeys()) {
    ParticleBody pBody = particleBodies.getOrDefault(id, null);     

    if (pBody == null) {
      // Create a new particle body
      pBody = new ParticleBody(person.getBodies().get(id), id);
      // Store list
      particleBodies.put(id, pBody);
    } else {
      // Update body's joints
      pBody.update(person.getBodies().get(id));
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
      // Set hands status
      person.setHandsState(body);
      // Sends person information  
      com.sendPersonInfo(body, particleBody.center.x, particleBody.center.y, particleBody.center.z, particleBody.leftHand.x, particleBody.leftHand.y, particleBody.leftHand.z, particleBody.rightHand.x, particleBody.rightHand.y, particleBody.rightHand.z, person.leftState.get(body)-2, person.rightState.get(body)-2);
    } catch(Exception ex){
      println("Exception " + ex);
    }
  }
  // Sends ending infromation to PD
  com.sendEndingInfo();
}


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