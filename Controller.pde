


class Controller {

  Trackers trackers;
  Particles particles;
  Capture video;
  Mapping mapping;

  FloatControl distThreshold = new FloatControl( "Tracker Dist Threshold", 50 );

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
  }

  public float bga() {
    return 15; // this.state.getByIndex(0).asFloat();
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
                // this.state.show();
            }

            if ( key == 'z' ) {
                // this.state.close();
            }
        }

    }



}
