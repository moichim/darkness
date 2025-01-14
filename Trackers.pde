import java.util.Map;

class Trackers extends ArrayList<Tracker> {

    Capture video;

  Trackers(
    Capture video
    ) {
        this.video = video;
  }

  void create(
    int r,
    int g,
    int b
    ) {

    this.add( new Tracker( r, g, b ) );
  }


  void update() {

    // this.video.loadPixels();

    // Popsprocess every trackes
    for ( Tracker tracker: this ) {
        tracker.preprocessPixels();
    }

    // Iterate all pixels
    for (int x = 0; x < this.video.width; x++ ) {
      for (int y = 0; y < this.video.height; y++ ) {
        int loc = x + y * this.video.width;
        // What is current color
        color currentColor = this.video.pixels[loc];

        for ( Tracker tracker: this ) {
            tracker.processPixel( currentColor, x, y );
        }

      }
    }

    // Popsprocess every trackes
    for ( Tracker tracker: this ) {
        tracker.postPoxelsProcessed();
        tracker.debug();
        tracker.draw();
    }
  }
}
