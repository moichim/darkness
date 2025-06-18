/**
 * Renderer, který emituje RayParticle do Particles.
 */
class RendererRayParticles extends RendererAbstract {

  int rays = 12;
  float maxLife = 60;
  float maxRayLength = 80;
  color rayColor = color(255); // výchozí barva

  RendererRayParticles(Tracker tracker) {
    super(tracker);
    if (tracker != null) {
      this.rayColor = tracker.particleRenderer.getColor();
    }
  }

  /**
   * Aktualizuje lokální barvu, pokud existuje tracker.
   */
  void updateRayColor() {
    if (tracker != null) {
      this.rayColor = tracker.particleRenderer.getColor();
    }
  }

  /**
   * Emituje RayParticle do Particles na pozici středu blobu.
   */
  public void emitRayParticle(Blob blob) {
    updateRayColor();
    ParticleRay ray = new ParticleRay(blob, rays, maxLife, maxRayLength, rayColor);
    controller.particles.recieveEmittedParticle(ray);
    // Nepřidává se do blob.particles, protože RayParticle není vázán na blob
  }

  void updateInBlob(Blob blob) {
    emitRayParticle(blob);
  }

  void setColor(color c) {
    this.rayColor = c;
  }

  color getColor() {
    return this.rayColor;
  }

  void resetColor() {
    if (tracker != null) {
      this.rayColor = tracker.particleRenderer.getColor();
    }
  }

  void updateInTracker(Tracker tracker) {}
  void updateInParticle(Particle particle) {}
  void drawInBlob(Blob blob) {}
  void drawInTracker() {}
}