// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/r0lvsMPGEoY

import processing.video.*;
import uibooster.*;
import uibooster.model.*;
import oscP5.*;


Capture video;
Controller controller;
UiBooster ui;

OscP5 osc;

void setup() {

  // fullScreen( P2D );
  size( 1920, 1080, P2D );

  

  // Running the SC
  String command = "sclang " + sketchPath("sound.scd");
  println( command );
  launch( command );

  osc = new OscP5(this, 57120); 


  String[] cameras = Capture.list();

  printArray(cameras);

  ui = new UiBooster();

  // Tracking

  video = new Capture(this, cameras[0]);
  video.start();

  controller = new Controller(
    video,
    width,
    height
  );

  // controller.trackers.create( 255, 255, 255, 20 );
  
  // Green
  controller.trackers.create( 14, 84, 8, 40 );
  
  // Red
  controller.trackers.create( 176, 11, 11, 70 );


  // Blue
  controller.trackers.create( 87, 181, 222, 50 );

  controller.trackers.create( 245, 237, 5, 50 );
  controller.trackers.create( 10, 10, 255, 75 );

  background(0);

  

}

void captureEvent(Capture video) {
  video.read();
}

void draw() {

  controller.updateUi();

  video.loadPixels();
  // image(video, 0, 0);


  controller.trackers.update();
  controller.particles.update();

  

  // background( 0, 0, 0, 50 );

  
  controller.particles.draw();

  controller.listenKeyboard();


  controller.drawDebug();
  

}


float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
