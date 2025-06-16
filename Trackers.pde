import java.util.Map;
import java.util.Arrays;

class Trackers extends ArrayList<Tracker> {

  Capture video;

  boolean recording = false;

  int numActiveColors = 0;
  int numBlobs = 0;
  float averageBlobSpeed = 0;

  Form colors;

  Trackers(
    Capture video
    ) {
    this.video = video;
  }

  void createColorDialog() {

    if ( this.colors != null ) {
      return;
    }

    UiBooster ui = new UiBooster();

    FormBuilder builder = ui.createForm( "Colors and attributes" );

    RowFormBuilder ctrl = builder.startRow();

    ctrl.addButton("Camera", () -> {
      controller.displayCamera = !controller.displayCamera;
    });

    ctrl.addButton( "Trackers", () -> {
      controller.displayTrackers = !controller.displayTrackers;
    } );

    ctrl.addButton( "FPS", () -> {
      controller.displayFps = !controller.displayFps;
    } );

    ctrl.endRow();



    RowFormBuilder row = builder.startRow();

    for (Tracker tracker : this) {
        row.addButton("Zobraz " + tracker.instrument, () -> {
            showInstrumentDialog(tracker);
        });
    }

    row.endRow();

    // Připrav data do tabulky
    String[][] tableData = new String[this.size()][6];
    int i = 0;
    for (Tracker tracker : this) {
        tableData[i][0] = tracker.instrument;
        tableData[i][1] = hue( tracker.trackColor ) + ", " + saturation( tracker.trackColor ) + ", " + brightness( tracker.trackColor );
        tableData[i][2] = red( tracker.trackColor ) + ", " + green( tracker.trackColor ) + ", " + blue( tracker.trackColor );
        tableData[i][3] = str(tracker.threshold);
        tableData[i][4] = str(tracker.thresholdSaturation);
        tableData[i][5] = str(tracker.thresholdBrightness);
        i++;
    }

    builder.addTable(
      "Hodnoty",
      Arrays.asList("Instrument", "HSB", "RGB", "Hue", "Saturation", "Brightness"),
      tableData
    );

    int x = 800;
    int y = 300;
    int gap = 20;

    builder.andWindow()
      .setSize( x, y )
      .setPosition( width - x - gap, height - y - gap )
      .save();

    this.colors = builder.run();
  }


  void showInstrumentDialog( Tracker tracker ) {
    UiBooster ui = new UiBooster();
    FormBuilder builder = ui.createForm( "Instrument: " + tracker.instrument );
    builder.startRow();

    builder.endRow();
    String col = "color_" + tracker.instrument;
    Color c = new Color(
      (int) red( tracker.trackColor ),
      (int) green( tracker.trackColor ),
      (int) blue( tracker.trackColor )
      );
    builder.addColorPicker( col, c );
    builder.addSlider( "hue_" + tracker.instrument, 0, 1000, (int) (tracker.threshold * 1000), 500, 0 );
    builder.addSlider( "sat_" + tracker.instrument, 0, 1000, (int) (tracker.thresholdSaturation * 1000), 500, 0 );
    builder.addSlider( "bri_" + tracker.instrument, 0, 1000, (int) (tracker.thresholdBrightness * 1000), 500, 0 );
    
    builder.setChangeListener( (element, value, f) -> {

      println( element, element.getValue(), tracker );

      if ( element.getLabel().equals( col ) ) {
        Color c_ = (Color) value;
        tracker.setColor( c_.getRed(), c_.getGreen(), c_.getBlue() );
      }

      if ( element.getLabel().equals( "hue_" + tracker.instrument ) ) {
        tracker.setThresholdHue( ((Integer) value) / 1000f );
      }

      if ( element.getLabel().equals( "sat_" + tracker.instrument ) ) {
        tracker.setThresholdSaturation( ((Integer) value) / 1000f );
      }

      if ( element.getLabel().equals( "bri_" + tracker.instrument ) ) {
        tracker.setThresholdBrightness( ((Integer) value) / 1000f );
      }
    } );

    builder.run();
  }


  void startRecording() {
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
    for ( Tracker tracker : this ) {
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
    for ( Particle particle : controller.particles.points ) {

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
    ) {

    for ( Tracker tracker : this ) {
      tracker.sendInstrumentMessage( amplitude );
    }
  }

  public void render() {

    for ( Tracker tracker : this ) {

      for ( RendererAbstract renderer : tracker.renderers ) {
        renderer.drawInTracker();

        for ( Blob b : tracker.blobs ) {
          renderer.drawInBlob( b );
        }
      }
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
