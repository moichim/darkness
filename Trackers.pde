import java.util.Map;

class Trackers extends ArrayList<Tracker> {

  Capture video;

  boolean recording = false;

  int numActiveColors = 0;
  int numBlobs = 0;
  float averageBlobSpeed = 0;

  Trackers(
    Capture video
    ) {
    this.video = video;
  }

  void create(
    int r,
    int g,
    int b,
    float threshold,
    String instrument
    ) {

    this.add( new Tracker( r, g, b, threshold, instrument ) );
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
  }


  void update() {

    this.video.loadPixels();

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
      }
    }

    int blobCount = 0;

    // Analyse for sound
    for ( Tracker tracker: this ) {
      blobCount += tracker.blobs.size();
    }

    if ( blobCount == 0 ) {
      // controller.particles.points.clear();
      for ( Particle p : controller.particles.points ) {

        if ( p.phase == LIFE.DEAD ) {
          // controller.particles.points.remove( p );
        } else {
          p.setLost();
        }
      }
    }

    this.updateStatistics();

  }

  protected void updateStatistics() {

    int trackerCount = 0;
    float speedSum = 0;
    int blobCount = 0;

    for ( Tracker tracker : this ) {
      
      // Calculate the tracker`s inner statistics
      tracker.updateStatistics();
      
      // Reset the tracker's particle count
      tracker.particleCount = 0;

      // Reset the trackers average speed
      tracker.averageParticleSpeed = 0;

      // Reset the particle position attributes
      tracker.center.x = 0;
      tracker.center.y = 0;
      
      // Update local statistics
      blobCount += tracker.blobs.size();
      speedSum += tracker.averageSpeed;
      
      if ( tracker.blobs.size() > 0 ) {
        trackerCount += 1;
      }

    }

    // Calculate global statistics
    this.averageBlobSpeed = speedSum / this.size();
    this.numActiveColors = trackerCount;
    this.numBlobs = blobCount;

    // Count particles per tracker
    for( Particle particle : controller.particles.points ) {

      if ( particle.blob != null ) {
        particle.blob.tracker.particleCount += 1;
        particle.blob.tracker.averageParticleSpeed += particle.speed;
        particle.blob.tracker.center.x += particle.position.x;
        particle.blob.tracker.center.y += particle.position.y;
      }

    }

    // Calculate the particle count
    for ( Tracker tracker : this ) {

      tracker.amplitudeAspect = tracker.particleCount / controller.particles.points.size();
      tracker.averageParticleSpeed = tracker.averageParticleSpeed / tracker.particleCount;
      tracker.center.x = tracker.center.x / tracker.particleCount;
      tracker.center.y = tracker.center.y / tracker.particleCount;
      tracker.pan = map( tracker.center.x, 0, controller.mapping.output.x, -1, 1 );
      tracker.h = map( tracker.center.y, 0, controller.mapping.output.y, 0, 1 );

    }

  }

  void sendInstrumentMessages(
    float amplitude
  ){

    for ( Tracker tracker : this ) {
      tracker.sendInstrumentMessage( amplitude );
    }

  }



  public void draw() {

      for ( int i = 0; i < this.size(); i++ ) {
        Tracker tracker = this.get(i);
        tracker.draw();
        tracker.drawSound( i );
      }

  }


}
