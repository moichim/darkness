class ParticleRay extends Particle {
  int rays;
  float maxLife;
  float tick = 0;
  float maxRayLength;
  float raySpeed;
  float segmentLength = 5;

  ParticleRay(Blob blob, int rays, float maxLife, float maxRayLength, color c) {
    super(blob);
    this.rays = rays;
    // Přepočítáme maxRayLength a maxLife podle blobu
    this.maxRayLength = blob.diameter / 2.0;
    this.raySpeed = max(1, blob.diameter / 20.0); // rychlost podle velikosti blobu
    this.maxLife = this.maxRayLength / this.raySpeed;
    this.currentColor = c;
    this.phase = LIFE.FOLLOWS;
    this.tick = 0;
  }

  @Override
  public void update() {
    tick++;
    if (tick >= maxLife) {
      this.phase = LIFE.DEAD;
    }
  }

  @Override
  public void draw() {
    push();
    stroke(currentColor);
    float centerX = position.x;
    float centerY = position.y;
    float startLen = min(tick * raySpeed, maxRayLength);
    float endLen = min(startLen + segmentLength, maxRayLength);

    for (int i = 0; i < rays; i++) {
      float angle = TWO_PI * i / rays;
      float x1 = centerX + cos(angle) * startLen;
      float y1 = centerY + sin(angle) * startLen;
      float x2 = centerX + cos(angle) * endLen;
      float y2 = centerY + sin(angle) * endLen;
      line(x1, y1, x2, y2);
    }
    pop();
  }
}