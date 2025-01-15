import java.util.Map;

class Trackers extends ArrayList<Tracker> {

  Capture video;

  boolean recording = false;
  protected int duration = 0;
  protected int ticks = 0;

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

    this.add( new Tracker( r, g, b, threshold ) );
  }


  void startRecording( int duration ) {
    for ( Tracker tracker : this ) {
      tracker.reset();
    }
    this.recording = true;
    this.duration = duration;
    this.ticks = 0;
    println( "recording started" );
  }

  void endRecording() {
    this.recording = false;
    println( "recording ended" );
    time.end();
    playback = new Playback( series, 10 * 1000);
    playback.start();

  }


  void update() {

    if ( this.recording == false ) {
      // do nothing
    } else {

      // Update local ticks if recording
      this.ticks++;

      if ( this.ticks >= this.duration ) {
        this.endRecording();
      }

      // this.video.loadPixels();

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
        tracker.debug();
        tracker.draw();
      }
    }
  }
}
