// Const. variables
float thold = 5;
float spifac = 1.05;
int outnum;
float drag = 0.01;
int big = 1000;

class Ball {
  float X;
  float Y;
  float Xv;
  float Yv;
  float pX;
  float pY;
  float w;
  
  Ball() {
    try{
      X = random(width/KinectPV2.WIDTHColor);
      Y = random(height/KinectPV2.HEIGHTColor);
      w = random(1/thold, thold);
    } catch(Exception ex){
      println("To infinity");
    }
  }
  
  void render(int handState) {  
  
    if(handState != 2) {
      Xv /= spifac;
      Yv /= spifac;
    }

    Xv += drag * (mX - X) * w;
    Yv += drag * (mY - Y) * w;
    X += Xv;
    Y += Yv;
    line(X, Y, pX, pY);
    pX = X;
    pY = Y;
  }
}
