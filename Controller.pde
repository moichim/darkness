


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

    this.state = ui
      .createForm( "Blablátořík" )
      .addSlider("Background opacity?", 0, 255, 15, 10, 1)
      .run();

    this.state.close();
      // .run();
  }

  public float bga() {
    return this.state.getByIndex(0).asFloat();
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
