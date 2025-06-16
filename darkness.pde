import processing.video.*;
import uibooster.*;
import uibooster.model.*;
import oscP5.*;
import java.awt.Color;


Capture video;
Controller controller;
Story story;
UiBooster ui;

OscP5 osc;

String os = System.getProperty("os.name");
boolean isMac = os.contains("Mac OS X");

boolean runSC = true;

Process sc;

boolean isReady = false;

int maxFrameRate = 30;
int idealFrameRate = 15;
float maxSpeedAspect = 0.7;
float speedMultiplicator = 1;
void setSpeedMultiplocator(float value) {
    speedMultiplicator = constrain(value,1, 5);
}
float delta;

void setup() {
    
    fullScreen();
    // size( 1920, 1080 );

    noCursor();

    background(0);
    
    frameRate(maxFrameRate);

    OscProperties properties = new OscProperties();
    properties.setListeningPort(47120); // osc receive port (from sc)
    
    osc = new OscP5(this, properties);
    
    String[] cameras = Capture.list();
    
    printArray(cameras);
    println("Platform", os);
    
    ui= new UiBooster();
    
    String cam = "pipeline:autovideosrc";
    
    if(isMac == false) {
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

    story = new Story( controller );

    story.start();
    
    

    
    image(video, 0, 0);
    
    video.loadPixels();
    
    
    
    // controller.scStart();

    
}

void captureEvent(Capture video) {
    video.read();
}

boolean initialised = false;

void draw() {

    if ( initialised == false && frameCount < 100 ) {
        textSize( 100 );
        background(0);
        fill(255);
        textAlign( CENTER );
        text( "Symfonie barev", width / 2, height / 2 - 50 );

        textSize( 20 );
        text( "© Jan Jáchim, 2025", width / 2, height / 2 + 50 );

        fill( 0, 255, 0 );
        text( "'c' = calibration", width / 2, height / 2 + 100 );

        textSize( 15 );

        return;
    } else if (initialised == false ) {
        initialised = true;
        controller.trackers.startRecording();
        // controller.trackers.createColorDialog();
    }

    float fr = (float) constrain(frameRate, idealFrameRate, maxFrameRate);

    delta = map( fr, idealFrameRate, maxFrameRate, 1, maxSpeedAspect );
    
    isReady = true;
    
    controller.updateUi();
    
    
    controller.trackers.update();
    controller.particles.update();

    story.update();
    
    
    
    //background( 0, 0, 0, 50 );
    
    
    controller.particles.draw();
    
    controller.trackers.render();
    
    controller.listenKeyboard();
    
    // controller.composition.update();
    
    
    controller.drawDebug();

    
    
    
}


float distSq(float x1, float y1, float x2, float y2) {
    float d = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
    return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
    float d = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1);
    return d;
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

    if ( !isReady ) {
        // return;
    }
    /* print the address pattern and the typetag of the received OscMessage */
    // print("### received an osc message.");
    // print(" addrpattern: "+theOscMessage.addrPattern());
    // println(" typetag: "+theOscMessage.typetag());

    story.listenOsc( theOscMessage );


} `
