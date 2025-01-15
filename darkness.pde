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

  // trackers.create( 255, 255, 255, 20 );

  // trackers.create( 87, 181, 222, 40 );
  // trackers.create( 168, 43, 20, 40 );

  trackers.create( 10, 10, 255, 100 );

  // Serialising

  mapping = new Mapping(
    new PVector( video.width, video.height ),
    new PVector( 1920, 1080 )
    );

  series = new Series( mapping );
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {

  if ( playback == null ) {

    /** Tracking */

    background( 50 );

    video.loadPixels();
    image(video, 0, 0);
    trackers.update();

    /** Serialising */

    time.update();

    series.drawInput();
    series.drawOutput();

  }


  /** Visualisation */
  if ( playback != null ) {
    playback.update();
    playback.draw();
  }


  if ( trackers.recording == true ) {

    noStroke();
    fill( 255, 0, 0 );
    ellipse( 50, 50, 20, 20 );
    float w = map( trackers.ticks, 0, trackers.duration, 0, mapping.input.x );
    rect(0, 0, w, 10 );
    noFill();

  }

  fill( 0 );
  // rect( width - 120, 0, 200, 30 );


  fill( 255 );
  textSize( 20 );
  text( frameRate, width - 100, 20 );
  text( time.currentTime, 20, 20 );


  /** Keyboard input */
  if ( keyPressed ) {
    if ( key == 'r' ) {
      series.flush();
      time.start();
      trackers.startRecording( 500 );
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
