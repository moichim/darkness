// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/r0lvsMPGEoY

import processing.video.*;

// Tracking
Capture video;
Trackers trackers;

// Serialising
Mapping mapping;
Time time = new Time();
Series series;
Playback playback;

Particles particles;

float distThreshold = 50;
float maxLife = 200;
float threshold = 40;

void setup() {
  size( 1920, 1080 );

  String[] cameras = Capture.list();

  printArray(cameras);

  // Tracking

  video = new Capture(this, cameras[0]);
  video.start();

  trackers = new Trackers( video );
  particles = new Particles( trackers );

  // trackers.create( 255, 255, 255, 20 );
  
  // Green
  trackers.create( 14, 84, 8, 40 );
  
  // Red
  trackers.create( 176, 11, 11, 70 );


  // Blue
  trackers.create( 87, 181, 222, 50 );

  trackers.create( 245, 237, 5, 50 );
  trackers.create( 10, 10, 255, 75 );

  mapping = new Mapping(
    new PVector( video.width, video.height ),
    new PVector( width, height )
  );

  background(0);

  fullScreen();

}

void captureEvent(Capture video) {
  video.read();
}

void draw() {

  video.loadPixels();
  image(video, 0, 0);
  trackers.update();

  fill( 0, 0, 0, 15 );
  rect( 0, 0, width, height );

  // background( 0, 0, 0, 50 );

  particles.update();
  particles.draw();

  /** Keyboard input */
  if ( keyPressed ) {
    if ( key == 'r' ) {
      time.start();
      trackers.startRecording();
    }
    if ( key == 'e' ) {
      time.end();
      trackers.endRecording();
    }
  }

}


float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void stopPlayback() {
  playback = null;
}
