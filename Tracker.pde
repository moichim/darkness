class Tracker {

  ArrayList<Blob> blobs = new ArrayList<Blob>();
  ArrayList<Blob> temp = new ArrayList<Blob>();

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

  // Synth synth;

  Tracker(
    int r,
    int g,
    int b,
    float threshold
  ) {
    this.setColor( r, g, b );
    this.threshold = threshold;
    this.emissionColor = this.trackColor;

    // this.synth = new Synth( "sine" );
    // this.synth.set( "amp", 0 );
    // this.synth.create();

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
  }

  void setColor( float r, float g, float b ) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.trackColor = color( r, g, b );
  }

  public void preprocessPixels() {
    this.temp.clear();
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

      b.update( this );

    }

    this.updateStatistics();

  }

  protected void matchBlobs() {

    for (int i = this.temp.size()-1; i >= 0; i--) {
      if (this.temp.get(i).size() < 800) {
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
          b.remove();
          this.blobs.remove(i);
        }
      }

    }

  }

  protected void updateStatistics() {

    float speedSum = 0;

    for ( Blob blob : this.blobs ) {
      speedSum += blob.movement;
    }

    this.averageSpeed = speedSum / this.blobs.size();

  }


  public void debug() {
  }

  public void draw() {
    for ( Blob b : this.blobs ) {
      b.show( this.trackColor );
    }
  }


  public void analyseForSound() {

    // Detect end / start of the playback
    if ( this.playing == true && this.blobs.size() == 0 ) {
      println( "Ended playing!", this );
      this.playing = false;
    } else if ( this.playing == false && this.blobs.size() > 0) {
      println( "Started playing!", this );
      this.playing = true;
    }



    if ( this.playing == true ) {

      float amp = constrain(
        map( this.blobs.size(), 0, 4, 0, 1 ),
        0,
        1
      );

      // this.synth.set( "amp", amp );
    } else {
      // this.synth.set( "amp", 0 );
    }

    if ( this.blobs.size() > 0 ) {

      float freq = random(20,100);

      OscMessage myMessage = new OscMessage("/freq");
      myMessage.add(freq);
      osc.send(myMessage, "127.0.0.1", 57120);

      float movementSum = 0;

      for ( Blob blob : this.blobs ) {
        movementSum += blob.movement;
      }

      float averageMovement = movementSum / this.blobs.size();

      // println( this.trackColor, averageMovement );

    }

  }


}
