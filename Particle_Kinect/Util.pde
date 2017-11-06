class Util {

   Util(){}
  
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
}