import java.util.Map;

class Trackers extends ArrayList<Tracker> {

  Capture video;

  boolean recording = false;

  Particles particles = new Particles( this );

  Trackers(
    Capture video
    ) {
    this.video = video;
  }

  void create(
    int r,
    int g,
    int b,
    float threshold
    ) {

    this.add( new Tracker( r, g, b, threshold, this ) );
  }


  void startRecording( ) {
    for ( Tracker tracker : this ) {
      tracker.reset();
    }
    this.recording = true;
    println( "recording started" );
  }

  void endRecording() {
    this.recording = false;
    println( "recording ended" );
    time.end();

  }


  void update() {

    this.particles.update();
    this.particles.draw();

    if ( this.recording == false ) {
      // do nothing
    } else {

      // Popsprocess every trackes
      for ( Tracker tracker : this ) {
        tracker.preprocessPixels();
      }

      // Iterate all pixels
      for (int x = 0; x < this.video.width; x++ ) {
        for (int y = 0; y < this.video.height; y++ ) {
          int loc = x + y * this.video.width;
          // What is current color
          color currentColor = this.video.pixels[loc];

          for ( Tracker tracker : this ) {
            tracker.processPixel( currentColor, x, y );
          }
        }
      }

      // Popsprocess every trackes
      for ( Tracker tracker : this ) {
        tracker.postPoxelsProcessed();
        tracker.update();
        tracker.debug();
        tracker.draw();
      }
    }
  }
}
