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
    this.minx = x;
    this.miny = y;
    this.maxx = x;
    this.maxy = y;
    this.tracker = tracker;
    this.recalculate();
  }

  PVector getCenter() {
    float x = (this.maxx - this.minx)* 0.5 + this.minx;
    float y = (this.maxy - this.miny)* 0.5 + this.miny;    
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
    this.center = controller.mapping.output( c );
    this.movement = this.prev.dist( this.center );
    this.width = //controller.mapping.xoutput( 
    this.maxx - this.minx; //);
    this.height = //controller.mapping.youtput(
     this.maxy - this.miny; // );
    this.diameter = sqrt( ( this.width * this.width ) + ( this.height * this.height ) );

  }


  void remove() {

    for ( Particle particle: this.particles ) {
      particle.setLost();
    }

    this.particles.clear();

  }
    
  void show(color col) {
    stroke(col);
    // fill(col);
    noFill();
    strokeWeight(2);
    rectMode(CORNERS);
    rect(this.minx, this.miny, this.maxx, this.maxy);
    
    textAlign(CENTER);
    textSize(64);
    noStroke();
    fill(col);
    text(this.id, this.minx + (this.maxx-this.minx)*0.5, this.maxy - 10);
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
    this.minx = min(this.minx, x);
    this.miny = min(this.miny, y);
    this.maxx = max(this.maxx, x);
    this.maxy = max(this.maxy, y);
    this.recalculate();
  }
  
  void become(Blob other) {
    this.minx = other.minx;
    this.maxx = other.maxx;
    this.miny = other.miny;
    this.maxy = other.maxy;
    this.recalculate();
  }

  float size() {
    return (this.maxx-this.minx)*(this.maxy-this.miny);
  }
  
  

  boolean isNear(float x, float y) {

    float cx = max(min(x, this.maxx), this.minx);
    float cy = max(min(y, this.maxy), this.miny);
    float d = distSq(cx, cy, x, y);

    float distThreshold = controller.distThreshold.value();

    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}
