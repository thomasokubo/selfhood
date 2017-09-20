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