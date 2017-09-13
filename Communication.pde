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
  
  void sendBeginningInfo(int size){
    OscMessage msg = new OscMessage("/people/number");
    msg.add(size);
    this.osc.send(msg, this.destinyLocation);
  }
  
  void sendPersonInfo(int bodyIndex, float centerX, float centerY, float centerZ, float rightHandX, float rightHandY, float rightHandZ, float leftHandX, float leftHandY, float leftHandZ, int rightHandState, int leftHandState){
    OscMessage msg = new OscMessage("");
    msg.clear();
    
    msg.setAddrPattern("/people/position/p" + bodyIndex);
    msg.add(map(centerX, 0, width, 0, 1));
    msg.add(map(centerY, 0, height, 0, 1));
    msg.add(centerZ);
 
    msg.add(map(rightHandX, 0, width, 0, 1));
    msg.add(map(rightHandY, 0, height, 0, 1));
    msg.add(rightHandZ);
    
    msg.add(map(leftHandX, 0, width, 0, 1));
    msg.add(map(leftHandY, 0, height, 0, 1));
    msg.add(leftHandZ);
    
    this.osc.send(msg, this.destinyLocation);
  }

  void sendEndingInfo(){
    OscMessage msg = new OscMessage("");
    msg.clear();
    msg.setAddrPattern("/people/done");
    msg.add(1);
    this.osc.send(msg, this.destinyLocation);
  }

}
