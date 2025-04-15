class Tracker {

  ArrayList<Blob> blobs = new ArrayList<Blob>();
  ArrayList<Blob> temp = new ArrayList<Blob>();
  ArrayList<RendererAbstract> renderers = new ArrayList<RendererAbstract>();

  int blobCounter = 0;

  // int maxLife = 200;

  /** @deprecated */
  color trackColor;

  float threshold = 0.5;
  float thresholdSaturation = 0.5;
  float thresholdBrightness = 0.5;

  color emissionColor;

  float r;
  float g;
  float b;

  boolean playing = false;

  float averageSpeed = 0;
  float averageParticleSpeed = 0;
  String instrument;

  float amplitudeAspect = 0;
  PVector center = new PVector(width / 2, height / 2);
  PVector pivot = new PVector(0.5, 0.5);
  float pan = 1;
  float h = 0;
  float heightMin = 0;
  float heightMax = 0;

  float particleCount = 0;

  boolean closest = false;

  RendererParticles particleRenderer = null;
  RendererCircles circleRenderer = null;
  RendererSample bankRenderer = null;
  RendererBitmap bitmapRenderer = null;


  Tracker(
    int r,
    int g,
    int b,
    float threshold,
    float saturation,
    float brightness,
    String instrument
  ) {
    this.setColor( r, g, b );
    this.threshold = threshold;
    this.thresholdSaturation = saturation;
    this.thresholdBrightness = brightness;
    this.emissionColor = this.trackColor;
    this.instrument = instrument;
    this.calculateTrasholds(this.trackColor);

  }

  protected Tracker addRenderer(
    RendererAbstract renderer
  ) {
    this.renderers.add( renderer );
    return this;
  }

  RendererParticles addParticlesRenderer() {
    RendererParticles renderer = new RendererParticles( this );
    this.renderers.add( renderer );
    this.particleRenderer = renderer;
    return renderer;
  }

  RendererCircles addCircleRenderer() {
    RendererCircles renderer = new RendererCircles( this );
    this.renderers.add( renderer );
    this.circleRenderer = renderer;
    return renderer;
  }

  RendererBitmap addImageRenderer( PImage image ) {
    RendererBitmap renderer = new RendererBitmap( this, image );
    this.renderers.add( renderer );
    this.bitmapRenderer = renderer;
    return renderer;
  }

  RendererSample addBankRenderer( FolderBank bank ) {
    RendererSample renderer = new RendererSample( this, bank );
    this.renderers.add( renderer );
    this.bankRenderer = renderer;
    return renderer;
  }

  void reset() {
    this.blobs.clear();
    this.temp.clear();
    this.blobCounter = 0;
  }

  void doJump( float amount ) {
    for (Blob blob : this.blobs ) {
      for (Particle particle : blob.particles ) {
        particle.doJump(amount);
        particle.setRandomColorFromTracker();
      }
    }
  }

  void setColor( color col ) {
    this.r = red( col );
    this.g = green( col );
    this.b = blue( col );
    this.trackColor = col;
    this.emissionColor = col;
    this.calculateTrasholds(this.trackColor);
  }

  void setColor( float r, float g, float b ) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.trackColor = color( r, g, b );
    this.emissionColor = this.trackColor;
    this.calculateTrasholds(this.trackColor);
  }

  public void preprocessPixels() {
    this.temp.clear();
  }


  public void assignToClosest(

  ) {

  }



  protected float trackHue = 0;
  protected float trackSaturation = 0;
  protected float trackBrightness = 0;

  protected void calculateTrasholds( color col ) {
    float h2 = hue(col);
    float s2 = saturation(col);
    float b2 = brightness(col);
    this.trackHue = h2;
    this.trackSaturation = s2;
    this.trackBrightness = b2;
  }



  public void processPixel( color currentColor, int x, int y ) {

    /*
    float r1 = red(currentColor);
    float g1 = green(currentColor);
    float b1 = blue(currentColor);

    float r2 = this.r;
    float g2 = this.g;
    float b2 = this.b;

    float d = distSq(r1, g1, b1, r2, g2, b2);

    */

    /*

    float h1 = hue(currentColor);
  float s1 = saturation(currentColor);
  float b1 = brightness(currentColor);

  // Převod referenční barvy do HSB
  color reference = color(this.r, this.g, this.b); // tvoříme barvu z uložených RGB složek
  float h2 = hue(reference);
  float s2 = saturation(reference);
  float b2 = brightness(reference);

  // Výpočet vzdálenosti v HSB prostoru (s přihlédnutím ke kruhové povaze odstínu)
  float dh = min(abs(h1 - h2), 360 - abs(h1 - h2)) / 360.0; // normované na 0–1
  float ds = (s1 - s2) / 100.0;
  float db = (b1 - b2) / 100.0;

  float d = dh*dh + ds*ds + db*db;

  */

  // Aktuální barva pixelu
  float h1 = hue(currentColor);
  float s1 = saturation(currentColor);
  float b1 = brightness(currentColor);

  // Referenční barva (trackColor složený z RGB složek)
  float h2 = this.trackHue;
  float s2 = this.trackSaturation;
  float b2 = this.trackBrightness;

  // Rozdíl odstínu (s přihlédnutím ke kruhovému rozsahu)
  float dh = min(abs(h1 - h2), 360 - abs(h1 - h2)) / 360.0;
  float ds = abs(s1 - s2) / 100.0;
  float db = abs(b1 - b2) / 100.0;

    if (dh * dh < threshold * threshold &&
      ds * ds < thresholdSaturation * thresholdSaturation &&
      db * db < thresholdBrightness * thresholdBrightness) {
      boolean found = false;
      for (Blob b : this.temp) {
        if (b.isNear(x, y)) {
          b.add(x, y);
          found = true;
          break;
        }
      }
      if ( !found ) {
        Blob b = new Blob(x, y, this );
        this.temp.add(b);
      }
    }
  }

  public void postPoxelsProcessed() {

    this.matchBlobs();

  }

  public void update() {

    for ( Blob b: this.blobs ) {

      // b.update( this );

      for ( RendererAbstract renderer : this.renderers ) {
        renderer.updateInBlob( b );
      }


    }

  }

  protected void matchBlobs() {

    for (int i = this.temp.size()-1; i >= 0; i--) {
      if (this.temp.get(i).size() < 800) {
        this.temp.get(i).unassignExternalBlob();
        this.temp.remove(i);
      }
    }


    // There are no blobs!
    if ( this.blobs.isEmpty() && this.temp.size() > 0 ) {
      for ( Blob b : this.temp ) {
        b.id = this.blobCounter;
        this.blobs.add( b );
        this.blobCounter++;
      }
    }
    // If more blobs wer found than before
    else if (this.blobs.size() <= this.temp.size()) {

      for (Blob b: this.blobs) {

        float recordD = 1000;
        Blob matched = null;

        for (Blob cb: this.temp) {

          PVector centerB = b.getCenter();
          PVector centerCB = cb.getCenter();

          float d = PVector.dist(centerB, centerCB);

          if ( d < recordD && !cb.taken ) {
            recordD = d;
            matched = cb;
          }

        }

        matched.taken = true;
        b.become( matched );

      }

      for (Blob b: this.temp) {
        if (!b.taken) {
          b.id = this.blobCounter;
          this.blobs.add(b);
          this.blobCounter++;
        }
      }

    }
    // Is less blobs were found than before
    else if ( this.blobs.size() > this.temp.size() ) {

      for ( Blob b: this.blobs ) {
        b.taken = false;
      }

      // Match whatever blobs you can match
      for ( Blob cb: this.temp ) {

        float recordD = 1000;
        Blob matched = null;

        for ( Blob b: this.blobs ) {

          PVector centerB = b.getCenter();
          PVector centerCB = cb.getCenter();

          float d = PVector.dist(centerB, centerCB);

          if ( d < recordD && !b.taken ) {
            recordD = d;
            matched = b;
          }

        }

        if ( matched != null ) {
          matched.taken = true;
          matched.become( cb );
        }

      }

      for ( int i = this.blobs.size() - 1; i >= 0; i-- ) {
        Blob b = this.blobs.get(i);
        if (!b.taken) {
          b.unassignExternalBlob();
          b.remove();
          this.blobs.remove(i);
        }
      }

    }

  }



  public void updateStatistics() {

    if ( this.blobs.size() > 0 ) {
      float speedSum = 0;

      float pivotX = 0;
      float pivotY = 0;

      for ( Blob blob : this.blobs ) {
        speedSum += blob.movement;
        pivotX += blob.center.x;
        pivotY += blob.center.y;
      }

      float speed = speedSum / this.blobs.size();

      float speedMax = 50;

      float normalisedSpeed = map(
        constrain(speed, 0, speedMax),
        0, speedMax,
        0,1
      );

    if( normalisedSpeed == 0 ) {
      this.averageSpeed = lerp( this.averageSpeed, 0, 0.1 );
    } else {
      this.averageSpeed = lerp( normalisedSpeed, this.averageSpeed, 0.5 );
    }
      

      this.pivot.x = map( pivotX / this.blobs.size(), 0, controller.mapping.output.x, 0, 1 );
      this.pivot.y = map( pivotY / this.blobs.size(), 0, controller.mapping.output.y, 0, 1 );

    } else {
      this.averageSpeed = lerp( this.averageSpeed, 0, 0.1 );
    }

  }


  public void debug() {
  }

  public void draw() {
    for ( Blob b : this.blobs ) {
      b.show( this.trackColor );
    }
  }


  public void drawSound( int index ) {

    push();

    float w = 200;
    float h = 100;

    float start = controller.mapping.input.x + ( w * index );

    translate( start, 0 );

    // print bg
    fill( 0 );
    stroke(255);
    rect( 0, 0, w, h );

    // Print pan
    PVector pan = new PVector(
      map( this.pan, -1, 1, 0, w ),
      h / 2
    );

    // Print the name of the instrument
    fill( this.trackColor );
    textSize( 10 );
    text( this.instrument, 10, 10 );
    // fill(0);
    text( this.averageParticleSpeed, 10, 20 );

    text( this.threshold, 10, 30 );
    text( this.thresholdSaturation, 10, 40 );
    text( this.thresholdBrightness, 10, 50 );

    // Print the pan
    noStroke();
    fill( this.trackColor );
    ellipseMode( CENTER );
    ellipse( pan.x, pan.y, 10, 10 );

    // Print the amplitude
    rectMode(CORNER);
    rect( 
      w - 10, 
      0, 
      10,
      map( this.amplitudeAspect, 0, 1, 0, h )
    );

    // Print the speed
    fill(255);
    rect(
      w - 20,
      0, 10,
      this.averageParticleSpeed
    );

    // Print the height
    ellipse(w / 2, map( this.h, 0, 1, 0, h ), 10, 10);

    pop();

  }


  /** Send regular OSC message every turn */
  void sendInstrumentMessage(
    float amplitude
  ) {

    amplitude = constrain( amplitude, 0, 1 );

    OscMessage msg = controller.msg( this.instrument );

    // Amplitude is defined by the aspect and is multiplitd by the provided aspect
    msg.add( this.amplitudeAspect * amplitude );

    // Pan X is calculated from the center aspect
    msg.add( this.pan );

    // Y is mapped to 0-1
    msg.add( this.h );

    // Average speed is sent as real number
    msg.add( this.averageSpeed );

    // Current pivot is sent as index
    msg.add(this.pivot.x);
    msg.add(this.pivot.y);

    // Lastly, add average particle speed
    msg.add(
      map(
        constrain( 
          Float.isNaN( this.averageParticleSpeed ) ? 0 : this.averageParticleSpeed, 
          controller.minSpeed(), 
          controller.maxSpeed()
        ),
        controller.minSpeed(),
        controller.maxSpeed(),
        0,
        1
      )
    );

    // Sent the message at the end
    controller.send( msg );

  }


}
