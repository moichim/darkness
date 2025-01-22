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

  ArrayList<AbstractParticle> particles = new ArrayList<AbstractParticle>();

  int tick = 0;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }

  void update(
    Tracker tracker
  ) {

    float life = map( this.diameter(), 0, video.width, 5, 1 );

    // if ( this.tick >= life ) {

      PVector center = this.getCenter();
      AbstractParticle item = tracker.trackers.particles.emit( center.x, center.y, tracker, this );

      this.particles.add( item );

      // this.tick = 0;

    // }

    this.tick++;

  }


  void remove() {

    for ( AbstractParticle particle: this.particles ) {
      trackers.particles.remove( particle );
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

  float diameter() {
    return sqrt( ( this.width() * this.width() ) + ( this.height() * this.height() ) );
  }


  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }
  
  void become(Blob other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }
  
  PVector getCenter() {
    float x = (maxx - minx)* 0.5 + minx;
    float y = (maxy - miny)* 0.5 + miny;    
    return new PVector(x,y); 
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
