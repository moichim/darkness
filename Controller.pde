


class Controller {

  Trackers trackers;
  Particles particles;
  Capture video;
  Mapping mapping;

  FloatControl distThreshold = new FloatControl( "Tracker Dist Threshold", 50 );

  Form state;

  OscP5 osc;

  boolean isMac = false;

  Composition composition = new Composition();



  protected float bga = 15;
  protected boolean displayTrackers = true;
  protected boolean displayCamera = true;
  protected boolean displayFps = true;
  protected float colorDeviationThreshold = 100;
  protected float minSpeed = 4;
  protected float maxSpeed = 20;
  protected float lostParticlesDistance = 800;

  protected float blipFreqMin = 3;
  protected float blipFreqMax = 20;

  protected boolean mutualBlobs = true;
  protected float mutualMinDistance = 100;
  protected float mutualMaxDistance = 500;




  Controller(
    Capture video,
    int outputWidth,
    int outputHeight,
    OscP5 osc
    ) {

    this.video = video;
    this.osc = osc;

    this.trackers = new Trackers( video );
    this.particles = new Particles( outputWidth, outputHeight );

    this.mapping = new Mapping(
      new PVector( video.width, video.height ),
      new PVector( outputWidth, outputHeight )
      );

    this.state = ui.createForm( "Application settings" )
      .addSlider("BG opacity", 0, 100, (int) this.bga, 10, 5)
      .addCheckbox( "Display trackers", false )
      .addCheckbox( "Display camera", false )
      .addCheckbox( "Display FPS", true )
      .addSlider( "Color Deviation Threshold", 0, 255, (int) this.colorDeviationThreshold, 128, 0 )
      .addSlider( "Speed Min", 0, 10, (int) this.minSpeed, 1, 0 )
      .addSlider( "Speed Max", 10, 20, (int) this.maxSpeed, 5, 0 )
      .addSlider( "Lost particles distance", 0, outputWidth, (int) this.lostParticlesDistance, 200, 100 )
      .addSlider( "Blip freq min", 0, 200, (int) this.blipFreqMin, 100, 0 )
      .addSlider( "Blip freq max", 0, 300, (int) this.blipFreqMax, 100, 0 )
      .addCheckbox( "Mutual blobs", this.mutualBlobs ) // 10
      .addSlider( "Mutual min distance", 0, 300, (int) this.mutualMinDistance, 100, 0 )
      .addSlider( "Mutual max distance", 0, 1000, (int) this.mutualMaxDistance, 100, 0 )
      .addButton( "Black out", () -> background(0) )
      .addButton( "Play", () -> this.trackers.startRecording() )
      .addButton( "Stop", () -> this.trackers.endRecording() )
      .run();

    this.state.close();
    // this.trackers.startRecording();

    this.isMac = System.getProperty("os.name").contains( "Mac OS X" );

  }


  public void setBga( float value ) {
    this.bga = constrain( value, 0, 255 );
    this.state.getByIndex(0).setValue( (int) round( value ) );
  }

  public void goBgaTo( float target, float step ){
    target = constrain( target, 0, 255 );

    float distance = step * 1.5;

    if ( this.bga == target  ) {
      // Do nothing
    } else if ( abs( this.bga - target ) <= distance ) {
      this.setBga( target );
    } else if ( this.bga < target ) {
      this.setBga( this.bga + step );
    } else if ( this.bga > target ) {
      this.setBga( this.bga - step );
    }

  }

  public void setColorDeviationThreshold( float value ) {
    this.colorDeviationThreshold = value;
    this.state.getByIndex(4).setValue((int) round( value ) );
  }

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

  public boolean mutualBlobs() { return this.mutualBlobs; }
  public void setMutualBlobs( boolean value ) {
    this.mutualBlobs = value;
    this.state.getByIndex(10).setValue( (boolean) value );
  }


  public float mutualMinDistance() { return this.mutualMinDistance; }
  public void setMutualMinDistance( float value ) {
    float sanitisedValue = min( value, this.mutualMaxDistance );
    sanitisedValue = max( sanitisedValue, 0 );
    this.mutualMinDistance = sanitisedValue;
    this.state.getByIndex(11).setValue( (int) round( sanitisedValue ) );
  }

  public float mutualMaxDistance() { return this.mutualMaxDistance; }
  public void setMutualMaxDistance( float value ) {
    float sanitisedValue = max( value, this.mutualMinDistance );
    sanitisedValue = min( sanitisedValue, 1000 );
    this.mutualMaxDistance = sanitisedValue;
    this.state.getByIndex(12).setValue( (int) round( sanitisedValue ) );
  }


  void setSpeedMin( float value ) {
    this.minSpeed = value;
    this.state.getByIndex(5).setValue((int) round( value ) );
  }

  void setSpeedMax( float value ) {
    this.maxSpeed = value;
    this.state.getByIndex(6).setValue((int) round( value ) );
  }

  protected float stepValueTo(
    float original,
    float target,
    float step
  ) {

    if ( original == target ) {
      return target;
    } else if ( abs( original - target ) <= step * 1.5 ) {
      return target;
    } else if ( original < target ) {
      return original + step;
    } else if ( original > target ) {
      return original - step;
    }

    return original;

  }

  public void goSpeedTo(
    float targetMin,
    float targetMax,
    float step
  ) {

    float min = this.stepValueTo( this.minSpeed, targetMin, step );
    if ( min != this.minSpeed ) { 
      this.setSpeedMin( min ); 
    }

    float max = this.stepValueTo( this.maxSpeed, targetMax, step );
    if ( max != this.maxSpeed ) { 
      this.setSpeedMax( max ); 
    }

  }


  public float lostParticlesDistance() {
    return this.lostParticlesDistance;
  }

  public float blipFreqMin() {
    return this.blipFreqMin;
  }
  public float blipFreqMax() {
    return this.blipFreqMax;
  }


  protected void updateUi() {

    this.bga = this.state.getByIndex(0).asFloat();

    this.displayTrackers = (boolean) this.state.getByIndex(1).getValue();
    this.displayCamera = (boolean) this.state.getByIndex(2).getValue();
    this.displayFps = (boolean) this.state.getByIndex(3).getValue();
    this.colorDeviationThreshold = this.state.getByIndex(4).asFloat();
    this.minSpeed = this.state.getByIndex( 5 ).asFloat();
    this.maxSpeed = this.state.getByIndex( 6 ).asFloat();
    this.blipFreqMin = this.state.getByIndex(8).asFloat();
    this.blipFreqMax = this.state.getByIndex(9).asFloat();
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

  public OscMessage msg( String key ) {
    return new OscMessage( key );
  }

  public void send(
    OscMessage msg
  ) {
    this.osc.send( msg, "127.0.0.1", 57133 );
    // println( msg );
  }

  public void syncBlip(
    float pan,
    float amp,
    float freq
  ) {
    OscMessage msg = this.msg("/blip");
    msg.add( constrain( pan, -1, 1 ) );
    msg.add( constrain( amp, 0, 1 ) );
    msg.add( 
      freq
      // constrain( freq, this.blipFreqMin, this.blipFreqMax ) 
    );
    if ( this.trackers.recording ) {
      this.send(msg);
    }
    
  }

  Process process;

  void scStart() {

    if ( this.process == null ) {

      if ( this.isMac == true ) {
        String scpath = "/Applications/SuperCollider.app/Contents/MacOS/sclang";
        String soundFilePath = sketchPath( "sound.scd" );
        String[] command = { scpath, soundFilePath };
        this.process = exec( command );
        println( "executed", command );
      } else if ( this.isMac == false ) {
        String command = "sclang " + sketchPath("sound.scd");
        process = launch( command );
        println( "launched", command );
      }

    }

  }

  void scEnd() {
    
    println( "Trying to destroy", this.process );

    if ( this.process != null ) {

      this.process.destroy();

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

            if ( key == 's' ) {
              this.scStart();
            }

            if ( key == 'd' ) {
              this.scEnd();
            }

            if ( key == 'c' ) {
              this.trackers.colors.show();
            }

            if ( key == 'x' ) {
              this.trackers.colors.close();
            }



        }

    }



}
