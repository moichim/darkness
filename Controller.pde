


class Controller {

  Trackers trackers;
  Particles particles;
  Capture video;
  Mapping mapping;

  FloatControl distThreshold = new FloatControl( "Tracker Dist Threshold", 50 );

  Form state;

  Controller(
    Capture video,
    int outputWidth,
    int outputHeight
    ) {

    this.video = video;

    this.trackers = new Trackers( video );
    this.particles = new Particles( outputWidth, outputHeight );

    this.mapping = new Mapping(
      new PVector( video.width, video.height ),
      new PVector( outputWidth, outputHeight )
      );

    this.state = ui.createForm( "Application settings" )
      .addSlider("BG opacity", 0, 100, 15, 10, 5)
      .addCheckbox( "Display trackers", false )
      .addCheckbox( "Display camera", false )
      .addCheckbox( "Display FPS", true )
      .addSlider( "Color Deviation Threshold", 0, 255, 100, 128, 0 )
      .addSlider( "Speed Min", 0, 3, 1, 1, 0 )
      .addSlider( "Speed Max", 0, 20, 7, 5, 0 )
      .addSlider( "Lost particles distance", 0, outputWidth, 800, 200, 100 )
      .addButton( "Black out", () -> background(0) )
      .addButton( "Play", () -> this.trackers.startRecording() )
      .addButton( "Stop", () -> this.trackers.endRecording() )
      .run();

    // this.state.close();
  }



  protected float bga = 15;
  protected boolean displayTrackers = false;
  protected boolean displayCamera = false;
  protected boolean displayFps = true;
  protected float colorDeviationThreshold = .01;
  protected float minSpeed = 1;
  protected float maxSpeed = 7;
  protected float lostParticlesDistance = 800;

  public float bga() {
    return this.bga;
  }
  public boolean displayTrackers() {
    return this.displayTrackers;
  }
  public boolean displayCamera() {
    return this.displayCamera;
  }
  public boolean displayFps() {
    return this.displayFps;
  }
  public float colorDeviationThreshold() {
    return this.colorDeviationThreshold;
  }
  public float minSpeed() {
    return this.minSpeed;
  }
  public float maxSpeed() {
    return this.maxSpeed;
  }
  public float lostParticlesDistance() {
    return this.lostParticlesDistance;
  }


  protected void updateUi() {

    this.bga = this.state.getByIndex(0).asFloat();

    this.displayTrackers = (boolean) this.state.getByIndex(1).getValue();
    this.displayCamera = (boolean) this.state.getByIndex(2).getValue();
    this.displayFps = (boolean) this.state.getByIndex(3).getValue();
    this.colorDeviationThreshold = this.state.getByIndex(4).asFloat();
    this.minSpeed = this.state.getByIndex( 5 ).asFloat();
    this.maxSpeed = this.state.getByIndex( 6 ).asFloat();
    this.lostParticlesDistance = this.state.getByIndex( 7 ).asFloat();
  }


  public void drawDebug() {

    if ( this.displayCamera == true ) {
      image(this.video, 0, 0);
    }

    if ( this.displayTrackers == true ) {
      this.trackers.draw();
    }

    if ( this.displayFps == true ) {
      fill( 0 );
      rect( 0, 0, 50, 20 );
      fill( 255 );
      textSize( 10 );
      text( frameRate, 10, 10 );
    }
  }



  public void listenKeyboard() {

    /** Keyboard input */
        if ( keyPressed ) {
            if ( key == 'r' ) {
                this.trackers.startRecording();
            }
            if ( key == 'e' ) {
                this.trackers.endRecording();
            }

            if ( key == 'u' ) {
                this.state.show();
            }

            if ( key == 'z' ) {
                this.state.close();
            }
        }

    }



}
