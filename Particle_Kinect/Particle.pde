// A simple Particle class
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