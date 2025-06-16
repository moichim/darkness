abstract class Tracker {

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

  boolean isPlaying = false;
  protected int isPlayingTick = 0;
  protected int isPlayingTickThreshold = 10;

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
  boolean ready = false;

  RendererParticles particleRenderer = null;
  RendererCircles circleRenderer = null;
  RendererFolderBank folderBankRenderer = null;

  float orientation = 0;


  Tracker(
    int r,
    int g,
    int b,
    float threshold,
    float saturation,
    float brightness,
    String instrument
  ) {
    // Look for the color configuration
    JSONObject config = this.loadColorConfig( instrument, r, g, b, threshold, saturation, brightness );

    float storedHue = config.getFloat( "hue" );
    float storedSaturation = config.getFloat( "saturation" );
    float storedBrightness = config.getFloat( "brightness" );

    float storedR = config.getFloat( "r" );
    float storedG = config.getFloat( "g" );
    float storedB = config.getFloat( "b" );


    this.setColor( storedR, storedG, storedB );
    this.threshold = storedHue;
    this.thresholdSaturation = storedSaturation;
    this.thresholdBrightness = storedBrightness;
    this.emissionColor = this.trackColor;
    this.instrument = instrument;
    this.calculateTrasholds(this.trackColor);

    this.ready = true;

  }

  public JSONObject loadColorConfig(
        String instrument,
        float defaultR,
        float defaultG,
        float defaultB,
        float defaultHue,
        float defaultSaturation,
        float defaultBrightness
    ) {
        String filename = this.getConfigFileName( instrument );
        JSONObject obj = null;
        try {
            obj = loadJSONObject( filename );
        } catch( Exception e ) {
            obj = this.saveColorConfig( instrument, defaultR, defaultG, defaultB, defaultHue, defaultSaturation, defaultBrightness );
        }

        if (obj == null) {
          // Pokud se stále nepodařilo vytvořit, vytvoř prázdný objekt s výchozími hodnotami
          obj = new JSONObject();
          obj.setFloat( "r", defaultR );
          obj.setFloat( "g", defaultG );
          obj.setFloat( "b", defaultB );
          obj.setFloat( "hue", defaultHue );
          obj.setFloat( "saturation", defaultSaturation );
          obj.setFloat( "brightness", defaultBrightness );
          saveJSONObject(obj, filename);
      }

        println( filename, obj );

        return obj;
    }

    public String getConfigFileName( String inst ) {
        return dataPath( "config_" + inst.replace("/", "") + ".json" );
    }

    public JSONObject saveColorConfig(
        String instrument,
        float r,
        float g,
        float b,
        float trackHue,
        float trackSaturation,
        float trackBrightness
    ) {
        String filename = this.getConfigFileName( instrument );
        JSONObject obj = new JSONObject();
        obj.setFloat( "r", r );
        obj.setFloat( "g", g );
        obj.setFloat( "b", b );
        obj.setFloat( "hue", trackHue );
        obj.setFloat( "saturation", trackSaturation );
        obj.setFloat( "brightness", trackBrightness );
        saveJSONObject( obj, filename );
        return obj;
    }

    protected void persist() {
      
      if ( this.ready == true ) {
        this.saveColorConfig( this.instrument, red( this.trackColor), green(this.trackColor), blue(this.trackColor), this.threshold, this.thresholdSaturation, this.thresholdBrightness );
      }
      
    }


    public void setThresholdHue( float value ) {
      this.threshold = value;
      this.persist();
    }

    public void setThresholdSaturation( float value ) {
      this.thresholdSaturation = value;
      this.persist();
    }

    public void setThresholdBrightness( float value ) {
      this.thresholdBrightness = value;
      this.persist();
    }





  protected void addRenderer(
    RendererAbstract renderer
  ) {
    this.renderers.add( renderer );
  }

  void reset() {
    this.blobs.clear();
    this.temp.clear();
    this.blobCounter = 0;
  }


/** @deprecated */
  void doJump( float amount ) {

    this.particleRenderer.driverJump.doJump( amount );

  }

  void setColor( color col ) {
    this.r = red( col );
    this.g = green( col );
    this.b = blue( col );
    this.trackColor = col;
    this.emissionColor = col;
    this.calculateTrasholds(this.trackColor);
    this.persist();
  }

  void setColor( float r, float g, float b ) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.trackColor = color( r, g, b );
    this.emissionColor = this.trackColor;
    this.calculateTrasholds(this.trackColor);
    this.persist();
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

    // Perform renderer updates in blobs
    for ( Blob b: this.blobs ) {

      for ( RendererAbstract renderer : this.renderers ) {
        renderer.updateInBlob( b );
      }

    }

    // Perform renderer updates in this tracker
    for ( RendererAbstract renderer : this.renderers ) {
      renderer.updateInTracker( this );
    }

    this.updateTool();

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



  public void updateStatistics() {

    if ( this.blobs.size() > 0 ) {

      float speedSum = 0;

      float pivotX = 0;
      float pivotY = 0;

      PVector orientationMin = new PVector( controller.mapping.output.x, controller.mapping.output.y );
      PVector orientationMax = new PVector(0,0);

      for ( Blob blob : this.blobs ) {
        speedSum += blob.movement;
        pivotX += blob.center.x;
        pivotY += blob.center.y;

        orientationMin.x = min( orientationMin.x, blob.center.x - (blob.width / 2) );
        orientationMin.y = min( orientationMin.y, blob.center.y - ( blob.height / 2 ) );

        orientationMax.x = max( orientationMax.x, blob.center.x + ( blob.width / 2 ) );
        orientationMax.y = max( orientationMax.y, blob.center.y + ( blob.height / 2 ) );

      }

      float dimensionX = orientationMax.x - orientationMin.x;
      float dimensionY = orientationMax.y - orientationMin.y;

      boolean isHorizontal = dimensionX > dimensionY;
      float mapTo = isHorizontal ? 1 : -1;

      float a = min( dimensionX, dimensionY );
      float b = max( dimensionX, dimensionY );

      float clear = a * 3.0;
      b = constrain( b, 0, clear );

      float aspect = map( b, 0.0, clear, 0.0, mapTo );
      // aspect = constrain( aspect, 0.0, mapTo );
      this.orientation = aspect;


      float orientation = (dimensionX - dimensionY) / max(dimensionX, dimensionY);
      orientation = constrain(orientation, -1, 1);
      // this.orientation = orientation;

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


    // Update is playing
    if ( this.blobs.size() > 0 ) {
      this.isPlaying = true;
      this.isPlayingTick = 0;
    } else {

      if ( this.isPlaying == true ) {
        this.isPlayingTick++;
        if ( this.isPlayingTick > this.isPlayingTickThreshold ) {
          this.isPlaying = false;
          this.isPlayingTick = 0;
        }
      }

    }

  }

/** @deprecated */
  public void debug() {
  }

  public void draw() {
    for ( Blob b : this.blobs ) {
      b.show( this.trackColor );
    }
  }

/** @deprecated */
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
    textAlign( LEFT );
    text( this.instrument + " : " + this.blobs.size() + " - r:" + red(this.trackColor) + " g:" + green( this.trackColor ) + " b:" + blue( this.trackColor ), 50, 10 );
    // fill(0);
    text( this.averageParticleSpeed, 10, 20 );

    text( this.threshold, 10, 30 );
    text( this.thresholdSaturation, 10, 40 );
    text( this.thresholdBrightness, 10, 50 );
    text( "ORI: " + this.orientation, 10, 70 );

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

    if (frameCount % 100 == 0) {
      println( this, this.pivot.x, this.pivot.y );
    }

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

    // Add orientation -1 = horizontal, 1 = vertical, 0 = square
    msg.add( this.orientation );

    // Sent the message at the end
    controller.send( msg );

  }

  protected abstract void updateTool();

  protected float getRandomFloat( float high ) {
    return random(high);
  }

  protected float getRandomFloat( float low, float high ) {
    return random(low, high);
  }

  protected int getRandomInt( int high ) {
    return (int) random( (int) high );
  }

  protected int getRandomInt( int low, int high ) {
    return (int) random( (int) low, (int) high );
  }

  protected int getRoundedInt( float value ) {
    return (int) round(value);
  }

  protected boolean getRandomBoolean() {
    return random(1) > 0.5;
  }


}
