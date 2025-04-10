// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/r0lvsMPGEoY

import processing.video.*;
import uibooster.*;
import uibooster.model.*;
import oscP5.*;
import java.awt.Color;  // Java Color třída


Capture video;
Controller controller;
UiBooster ui;

OscP5 osc;

PShader blur;
PImage cosmos;
PImage mask;
PImage list;

String os = System.getProperty("os.name");
boolean isMac = os.contains( "Mac OS X" );

boolean runSC = true;

Process sc;

SampleBank listy;

Tracker bell;
Tracker kytar;

void setup() {

  // fullScreen();
  size( 1920, 1080 );

  frameRate(30);

  osc = new OscP5(this, 7772); 

  blur = loadShader("blur.glsl"); 

  String[] cameras = Capture.list();

  printArray(cameras);
  println("Platform", os);

  ui = new UiBooster();

  String cam = "pipeline:autovideosrc";

  if ( isMac == false ) {
    cam = cameras[0];
  }

  video = new Capture(this, cam);
  video.start();

  controller = new Controller(
    video,
    width,
    height,
    osc
  );

  FolderBank bank = new FolderBank("multicolor");
  bank.load();

  FolderBank bank2 = new FolderBank("blue");
  bank2.load();

  
  // Green
  // controller.trackers.create( 17, 173, 31, 70, "/a" );
  kytar = controller.trackers.create( 50, 200, 57, 80, "/kytar" )
    // .addBankRenderer( bank )
    // .addImageRenderer( cosmos )
    // .addCircleRenderer()
    .addCircleRenderer()
    .addParticlesRenderer()
    ;

  // Red is mapped to stars
  bell = controller.trackers.create( 255, 10, 10, 80, "/bell" )
    
    .addBankRenderer( bank2 )

    .addParticlesRenderer();

  // Blue
  controller.trackers.create( 15, 52, 230, 50, "/saber" )
    // .addCircleRenderer()
    .addParticlesRenderer();

    // Blue
  controller.trackers.create( 200, 17, 230, 50, "/d" )
    .addBankRenderer( bank2 )
    .addParticlesRenderer();


  controller.trackers.createColorDialog();
  
  // Red
  // controller.trackers.create( 176, 11, 11, 70, "a second instrument" );

  // Blue
  // controller.trackers.create( 87, 181, 222, 50, "a third instrument" );
  // controller.trackers.create( 189, 51, 69, 40, "a fifth instrument" );
  // controller.trackers.create( 9, 23, 97, 40, "a sixth instrument" );

  frameRate(40);

  image(video, 0, 0);

  background(0);

  video.loadPixels();

  controller.trackers.startRecording();

  // controller.scStart();
  
  

}

void captureEvent(Capture video) {
  video.read();
}

void draw() {

  controller.updateUi();

  // video.loadPixels();
  // image(video, 0, 0);


  controller.trackers.update();
  controller.particles.update();

  

  // background( 0, 0, 0, 50 );

  
  controller.particles.draw();

  controller.trackers.render();

  controller.listenKeyboard();

  controller.composition.update();


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

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());

  switch (theOscMessage.addrPattern()) {

    case "/bell":
      bell.doJump(20f);
      break;
    case "/kytar":
      kytar.doJump(20f);
      break;

  }

  
}`
