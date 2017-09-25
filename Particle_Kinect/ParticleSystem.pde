
// Particle System
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