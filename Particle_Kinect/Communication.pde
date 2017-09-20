// OSC libraries
import oscP5.*;
import netP5.*;

class Communication {

  // OSC controller and destiny location
  OscP5 osc;
  NetAddress destinyLocation;

  Communication(int port, String ip) {
    osc = new OscP5(this, port);
    destinyLocation = new NetAddress(ip, port);
  }
  
  // Initiates communication with PD (stablished by the protocol)
  void sendBeginningInfo(int size){
    OscMessage msg = new OscMessage("/people/number");
    msg.add(size);
    this.osc.send(msg, this.destinyLocation);
  }
  
  // Sends a person information to PD
  void sendPersonInfo(int bodyIndex, float centerX, float centerY, float centerZ, float rightHandX, float rightHandY, float rightHandZ, float leftHandX, float leftHandY, float leftHandZ, int rightHandState, int leftHandState){
    OscMessage msg = new OscMessage("");
    msg.clear();
    msg.setAddrPattern("/people/position/p" + bodyIndex);
    String lx = Float.toString(leftHandX);
    String rx = Float.toString(rightHandX);
    String cx = Float.toString(centerX);
    
    if(lx!="-Infinity" && rx!="-Infinity" && cx!="-Infinity" ){
      msg.add(map(centerX, 0, width, 0, 1));
      msg.add(map(centerY, 0, height, 0, 1));
      msg.add(centerZ);
      
      try {
        // Coordinates of left hand
        msg.add(map(rightHandX, 0, width, 0, 1));
        msg.add(map(rightHandY, 0, height, 0, 1));
        msg.add(rightHandZ);
  
        // Coordinates of right hand
        msg.add(map(leftHandX, 0, width, 0, 1));
        msg.add(map(leftHandY, 0, height, 0, 1));
        msg.add(leftHandZ);
 
        msg.add(leftHandState);      
        msg.add(rightHandState);
  
  
      } catch(Exception ex) {
        println("No body detected");
      }
      
      this.osc.send(msg, this.destinyLocation);
    }

  }

  // Ends communication with PD (stablished by the protocol)
  void sendEndingInfo(){
    OscMessage msg = new OscMessage("");
    msg.clear();
    msg.setAddrPattern("/people/done");
    msg.add(1);
    this.osc.send(msg, this.destinyLocation);
  }

}
