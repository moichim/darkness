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

    FormBuilder builder = ui.createForm( "Calibration" );

    RowFormBuilder ctrl = builder.startRow();

    ctrl.addButton("Camera", () -> {
      controller.displayCamera = !controller.displayCamera;
    });

    ctrl.addButton( "Trackers", () -> {
      controller.displayTrackers = !controller.displayTrackers;
    } );

    ctrl.addButton( "Enable all", () -> {
      controller.trackers.forEach( t -> {
        t.enable();
      } );
    } );

    ctrl.addButton( "Disable all", () -> {
      controller.trackers.forEach( t -> {
        t.disable();
      } );
    } );

    ctrl.addButton( "Store", () -> {
      controller.trackers.forEach( t -> {
        t.storeBackup();
      } );
    } );

    ctrl.addButton( "Restore", () -> {
      controller.trackers.forEach( t -> {
        t.applyBackup();
      } );
    } );

    ctrl.addButton( "Factory", () -> {
      controller.trackers.forEach( t -> {
        t.applyFactory();
      } );
    } );

    ctrl.endRow();



    RowFormBuilder row = builder.startRow();

    for (Tracker tracker : this) {

      Color t = new Color( ( brightness( tracker.trackColor ) ) > 127 ? color( 0 ) : color( 255 ) );

        row.addButton(
          tracker.instrument, 
          (element, form) -> {
            showInstrumentDialog(tracker);
          },
          new Color( tracker.trackColor ),
          t
        );
  
    }

    row.endRow();

    RowFormBuilder onoff = builder.startRow();

    for (Tracker tracker : this) {
        onoff.addButton("Přepni " + tracker.instrument, () -> {
            tracker.toggle();
        });
    }

    onoff.endRow();

    int x = 800;
    int y = 200;
    int gap = 20;

    builder.andWindow()
      .setSize( x, y )
      .setPosition( width - x - gap, height - y - gap )
      .save();

    builder.setCloseListener((form) -> {
      this.colors = null;
    });

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

    stroke( 255 );

    rect( 0, 0, controller.mapping.input.x, controller.mapping.input.y );

    noStroke();

    for ( int i = 0; i < this.size(); i++ ) {
      Tracker tracker = this.get(i);
      tracker.draw();
      tracker.drawSound( i );
    }

    float gap = 50;

    fill(0);
    rectMode(CORNER);
    rect( controller.mapping.input.x + gap, 125, 200, 50 );

    textAlign( LEFT );
    fill( 255 );
    textSize( 20 );
    text( story.phase.getCurrentPhase().key().toString(), controller.mapping.input.x + gap, 125 );
    text( "FPS: " + frameRate, controller.mapping.input.x + gap, 145 );
  }
}
