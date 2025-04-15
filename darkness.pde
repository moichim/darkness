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
PImage list;

String os = System.getProperty("os.name");
boolean isMac = os.contains( "Mac OS X" );

boolean runSC = true;

Process sc;

SampleBank listy;

Tracker bell;
Tracker kytar;
Tracker piano;
Tracker voice;

PImage stripes;
PImage mask;
PImage colorfulMask;

boolean isReady = false;

void setup() {

  fullScreen();
  // size( 1920, 1080 );

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

  FolderBank flowers = new FolderBank("flowers");
  flowers.load();
  
  stripes = loadImage( "weights/stripes.png" );
  mask = loadImage( "weights/circles.png" );
  colorfulMask = loadImage( "weights/grid.png" );

  // colorMode(HSB);


  // Green
  // controller.trackers.create( 17, 173, 31, 70, "/a" );
  piano = controller.trackers.create( 50, 200, 57,
    0.052,
    0.372,
    0.174,
    "/piano"
    );
  // piano.addCircleRenderer();
  piano.addParticlesRenderer()
    .setWeightMask(stripes);

  // Red is mapped to stars
  bell = controller.trackers.create( 255, 10, 10,
    0.110,
    0.762,
    0.703,
    "/bell"
    );
  bell.addBankRenderer( bank2 );
  bell.addParticlesRenderer()
    .setWeightMask( mask );

  // Blue
  kytar = controller.trackers.create( 15, 52, 230,
    0.047,
    0.802,
    0.762,
    "/kytar" );
  kytar.addParticlesRenderer()
    .setWeightMask(mask);

  // Blue
  voice = controller.trackers.create( 200, 200, 80,
    0,//0.081,
    0.814,
    0.791,
    "/voice"
    );
  voice.addBankRenderer( flowers );
  voice.addParticlesRenderer()
    .setWeightMask(colorfulMask);


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

  isReady = true;

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

if ( key == 'm' ) {
              bell.particleRenderer.unsetWeightMask();
              kytar.particleRenderer.unsetWeightMask();
              piano.particleRenderer.unsetWeightMask();
              voice.particleRenderer.unsetWeightMask();
            }

            if ( key == 'n' ) {
              bell.particleRenderer.setWeightMask(stripes);
              kytar.particleRenderer.setWeightMask(stripes);
              piano.particleRenderer.setWeightMask(stripes);
              voice.particleRenderer.setWeightMask(stripes);
            }

            if ( key == 'b' ) {
              bell.particleRenderer.setWeightMask(mask);
              kytar.particleRenderer.setWeightMask(mask);
              piano.particleRenderer.setWeightMask(mask);
              voice.particleRenderer.setWeightMask(mask);
            }

            if ( key == 'v' ) {
              bell.particleRenderer.setWeightMask(colorfulMask);
              kytar.particleRenderer.setWeightMask(colorfulMask);
              piano.particleRenderer.setWeightMask(colorfulMask);
              voice.particleRenderer.setWeightMask(colorfulMask);
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

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

  if ( !isReady ) {
    return;
  }
  /* print the address pattern and the typetag of the received OscMessage */
  // print("### received an osc message.");
  // print(" addrpattern: "+theOscMessage.addrPattern());
  // println(" typetag: "+theOscMessage.typetag());

  switch (theOscMessage.addrPattern()) {

    case "/bell":
      bell.doJump(10f);
      break;
    case "/kytar":
      kytar.doJump(10f);
      break;
    case "/piano":
      piano.doJump(10f);
      break;
    case "/voice":
      voice.doJump(10f);
      break;
  }

  
}`
