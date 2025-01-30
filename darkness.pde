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

String os = System.getProperty("os.name");
boolean isMac = os == "Mac OS X";

boolean runSC = true;

Process sc;

void setup() {

  // fullScreen( P2D );
  size( 1920, 1080, P2D );

  // Running the SuperCollider
  /*
  println( "Operating system", os );
  if ( isMac == true && runSC == true ) {
    String scpath = "/Applications/SuperCollider.app/Contents/MacOS/sclang";
    String soundFilePath = sketchPath( "sound.scd" );
    String[] command = { scpath, soundFilePath };
    process = exec( command );
    println( "executed", command );
  } else if ( isMac == false && runSC == true ) {
    String command = "sclang " + sketchPath("sound.scd");
    process = launch( command );
    println( "launched", command );
  }
  */

  osc = new OscP5(this, 57120); 


  String[] cameras = Capture.list();

  printArray(cameras);

  ui = new UiBooster();

  String cam = cameras[0];

  if ( isMac ) {
    cam = "pipeline:autovideosrc";
  }

  video = new Capture(this, cam);
  video.start();

  controller = new Controller(
    video,
    width,
    height,
    osc
  );
  
  // Green
  controller.trackers.create( 14, 84, 8, 40 );
  
  // Red
  controller.trackers.create( 176, 11, 11, 70 );


  // Blue
  controller.trackers.create( 87, 181, 222, 50 );

  controller.trackers.create( 189, 51, 69, 40 );
  controller.trackers.create( 9, 23, 97, 40 );

  frameRate(40);

  image(video, 0, 0);

  background(0);

  video.loadPixels();
  
  

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
