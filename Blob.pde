// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/r0lvsMPGEoY

/**
 * Documentation file for `Blob`
 */
class Blob {

  float minx;
  float miny;
  float maxx;
  float maxy;
      
  int id = 0;
  
  boolean taken = false;

  ArrayList<Particle> particles = new ArrayList<Particle>();

  float movement;
  PVector prev;
  PVector center;
  float diameter;
  float width;
  float height;

  int tick = 0;

  Tracker tracker;

  Blob(float x, float y, Tracker tracker) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    this.tracker = tracker;
    this.recalculate();
  }

  PVector getCenter() {
    float x = (maxx - minx)* 0.5 + minx;
    float y = (maxy - miny)* 0.5 + miny;    
    return new PVector(x,y); 
  }

  protected void recalculate() {

    PVector c = (PVector) this.getCenter();

    if ( this.prev == null && c != null ) {
      this.prev = c.copy();
    } else {
      this.prev = this.center.copy();
    }

    // this.prev = this.center.clone();
    this.center = mapping.output( c );
    this.movement = this.prev.dist( this.center );
    this.width = mapping.xoutput( this.maxx - this.minx );
    this.height = mapping.youtput( this.maxy - this.miny );
    this.diameter = sqrt( ( this.width * this.width ) + ( this.height * this.height ) );

  }

  void update(
    Tracker tracker
  ) {

    float life = map( this.diameter, 0, video.width, 5, 1 );

    this.particles.add( tracker.trackers.particles.emit( this ) );

    if ( this.tick >= life ) {

      this.particles.add( 
        tracker.trackers.particles.emit( this )
      );

    }

    this.tick++;

  }


  void remove() {

    for ( Particle particle: this.particles ) {
      particle.setLost();
      this.tracker.trackers.particles.remove( particle );
    }

    this.particles.clear();

  }
    
  void show(color col) {
    stroke(col);
    // fill(col);
    noFill();
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);
    
    textAlign(CENTER);
    textSize(64);
    noStroke();
    fill(col);
    text(id, minx + (maxx-minx)*0.5, maxy - 10);
    textSize(20);
  }

  float width() {
    return this.maxx - this.minx;
  }

  float height() {
    return this.maxy - this.miny;
  }

  /** @deprecated */
  float diameter() {
    return sqrt( ( this.width() * this.width() ) + ( this.height() * this.height() ) );
  }


  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
    this.recalculate();
  }
  
  void become(Blob other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
    this.recalculate();
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }
  
  

  boolean isNear(float x, float y) {

    float cx = max(min(x, maxx), minx);
    float cy = max(min(y, maxy), miny);
    float d = distSq(cx, cy, x, y);

    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}
