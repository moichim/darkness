class Tracker {

  ArrayList<Blob> blobs = new ArrayList<Blob>();
  ArrayList<Blob> temp = new ArrayList<Blob>();
  ArrayList<RendererAbstract> renderers = new ArrayList<RendererAbstract>();

  int blobCounter = 0;

  // int maxLife = 200;

  /** @deprecated */
  color trackColor;
  float threshold = 40;

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

  Tracker(
    int r,
    int g,
    int b,
    float threshold,
    String instrument
  ) {
    this.setColor( r, g, b );
    this.threshold = threshold;
    this.emissionColor = this.trackColor;
    this.instrument = instrument;

    // this.synth = new Synth( "sine" );
    // this.synth.set( "amp", 0 );
    // this.synth.create();

  }

  Tracker addRenderer(
    RendererAbstract renderer
  ) {
    this.renderers.add( renderer );
    return this;
  }

  Tracker addParticlesRenderer() {
    this.renderers.add( new RendererParticles( this ) );
    return this;
  }

  Tracker addCircleRenderer() {
    this.renderers.add( new RendererCircles( this ) );
    return this;
  }

  Tracker addImageRenderer( PImage image ) {
    this.renderers.add( new RendererBitmap( this, image ) );
    return this;
  }

  Tracker addBankRenderer( FolderBank bank ) {
    this.renderers.add( new RendererSample( this, bank ) );
    return this;
  }

  void reset() {
    this.blobs.clear();
    this.temp.clear();
    this.blobCounter = 0;
  }

  void setColor( color col ) {
    this.r = red( col );
    this.g = green( col );
    this.b = blue( col );
    this.trackColor = col;
    this.emissionColor = col;
  }

  void setColor( float r, float g, float b ) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.trackColor = color( r, g, b );
    this.emissionColor = this.trackColor;
  }

  public void preprocessPixels() {
    this.temp.clear();
  }


  public void assignToClosest(

  ) {

  }



  public void processPixel( color currentColor, int x, int y ) {

    float r1 = red(currentColor);
    float g1 = green(currentColor);
    float b1 = blue(currentColor);

    float r2 = this.r;
    float g2 = this.g;
    float b2 = this.b;

    float d = distSq(r1, g1, b1, r2, g2, b2);

    if ( d < this.threshold*this.threshold ) {
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

      this.averageSpeed = speedSum / this.blobs.size();
      this.pivot.x = map( pivotX / this.blobs.size(), 0, controller.mapping.output.x, 0, 1 );
      this.pivot.y = map( pivotY / this.blobs.size(), 0, controller.mapping.output.y, 0, 1 );

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

    // Sent the message at the end
    controller.send( msg );

  }


}
