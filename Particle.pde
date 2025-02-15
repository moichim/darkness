enum LIFE {
  RUNSAWAY,
    FOLLOWS,
    LOST,
    REACHED,
    DEAD,
    FOLLOWS_CLOSEST_NEIGHBOUR
}

class Particle {

  PVector position;
  PVector prev;
  PVector direction;
  float speed;

  color col;
  color colTarget;

  int tick = 0;
  float noiseStep = 0.09;
  float xoff = random(1000);
  float yoff = random(1000);

  Blob blob;
  Blob externalBlob;

  LIFE phase = LIFE.RUNSAWAY;

  float reachDistance = 30;
  float screenBoundary = 50;
  float lifeDuration = 200;
  float originalDiameter;


  Particle(
    Blob blob
    ) {

    this.blob = blob;

    this.position = blob.center.copy();
    this.position.x += random( -20, 20 );
    this.position.y += random( -20, 20 );
    this.prev = this.position;

    this.col = this.deviation( this.blob.tracker.emissionColor, (int) round( controller.colorDeviationThreshold() ) );// this.deviation( blob.tracker );
    this.colTarget = this.col;

    this.originalDiameter = blob.diameter;

    this.speed = random( 1, 5 );
    this.direction = new PVector(
      random( -1, 1 ),
      random(-1, 1 )
      );
  }

  void setLost() {
    if ( this.phase != LIFE.LOST ) {
      this.blob = null;
      this.phase = LIFE.LOST;
      this.colTarget = color(0);
      this.tick = 0;
      this.lifeDuration = round( random( 20, 100 ) );
    }
  }

  void assignToBlob( Blob blob ) {
    if ( this.blob != blob ) {
      this.blob = blob;
      this.phase = LIFE.FOLLOWS;
      this.colTarget = blob.tracker.trackColor;
    }
  }

  void assignToExternalBlob(
    Blob externalBlob
  ) {
    this.phase = LIFE.FOLLOWS_CLOSEST_NEIGHBOUR;
    this.externalBlob = blob;
    this.colTarget = blob.tracker.trackColor;
  }

  void unassignExternalBlob() {
    this.blob = null;
    this.externalBlob = null;
    this.phase = LIFE.LOST;
    this.colTarget = color(0,0,0);
  }


  protected void evaluateLife() {

    // If there is no blob, mark as lost
    if ( this.phase == LIFE.LOST ) {
      this.tick++;
      this.speed = lerp( this.speed, 1, .1 );
      if ( this.tick >= this.lifeDuration ) {
        this.phase = LIFE.DEAD;
      }
    }

    // Check if the external blob is near enough to die
    else if ( this.phase == LIFE.FOLLOWS_CLOSEST_NEIGHBOUR ) {
      if ( this.externalBlob == null ) {
        this.phase = LIFE.DEAD;
      } else {

        float distance = this.position.dist( this.externalBlob.center );
        if ( distance <= this.reachDistance ) {
          this.phase = LIFE.DEAD;
        }

      }
    }

    // If the phase is out, check for the distance towards the blob and eventually set as null
    else if ( this.phase == LIFE.RUNSAWAY ) {

      this.syncFromBlob();

      float dist = this.blob.center.dist( this.position );
      if ( dist >= this.originalDiameter / 2 ) {
        this.phase = LIFE.FOLLOWS;
      }

    }

    // If follows, check if reached already and eventually set the reach
    else if ( this.phase == LIFE.FOLLOWS ) {

      this.syncFromBlob();

      float dist = this.blob.center.dist( this.position );
      if ( dist <= this.reachDistance ) {
        this.phase = LIFE.REACHED;
      }
    }
  }

  public void applyDirection() {


    switch ( this.phase ) {

      case LOST:
        this.rotateRandomly();
        break;

      case RUNSAWAY:
        this.rotateRandomly();
        break;

      case FOLLOWS_CLOSEST_NEIGHBOUR:

        if ( this.externalBlob == null ) {
          this.phase = LIFE.LOST;
        } else {
          PVector target = this.externalBlob.center.copy();
          target.sub( this.position );
          target.normalize();
          this.direction.lerp( target, .5 );
          this.rotateRandomly();
        }

        break;

      case FOLLOWS:
        PVector change = this.blob.center.copy();
        change.sub( this.position );
        change.normalize();
        this.direction.lerp( change, .5 );
        this.rotateRandomly();
        break;

      case REACHED:
        this.rotateRandomly();
        break;


    }

  }

  protected void checkBoundaries() {

    if (
      this.position.x < -1 * this.screenBoundary
      || this.position.x > controller.mapping.output.x + this.screenBoundary
      || this.position.y < -1 * this.screenBoundary
      || this.position.y > controller.mapping.output.y + this.screenBoundary
      ) {
      this.phase = LIFE.DEAD;
    }
  }

  protected void doMove() {

    // Store the current position as previous
    this.prev = this.position.copy();

    // Calculate the new position based on speed and direction
    PVector change = this.direction.copy();
    change.mult( this.speed );
    this.position.add( change );
  }

  protected void syncFromBlob() {

    // Update the speed by blob movement
    // map the speed from 1 to 20
    if ( this.blob != null ) {

      if ( this.blob.movement != 0 ) {

        float movement = map( this.blob.movement, 0, controller.mapping.output.x / 10, 0, 1 );

        float distance = this.position.dist( this.blob.center );

        float d = constrain( 
          map( distance, 0, 300, 1, 2 ), 
          1, 
          2 
        );

        this.speed = controller.minSpeed() + ( controller.maxSpeed() * movement );
        // this.speed *= d;

      }
    }

    // Update the noise offset by
  }

  protected void updateColor() {
    if ( this.col != this.colTarget ) {
      this.col = lerpColor( this.col, this.colTarget, 0.01 );
    }
  }

  public void setColorFromTracker() {
    if ( this.blob != null ) {
      this.colTarget = this.deviation( this.blob.tracker.trackColor, controller.colorDeviationThreshold() );
    }
  }

  public void setColor(
    color col,
    float deviation
  ) {
    this.colTarget = color(
      this.deviateChannel( red( col ), deviation ),
      this.deviateChannel( green( col ), deviation ),
      this.deviateChannel( blue(col), deviation )
    );
  }




  protected color deviation(
    color col,
    float deviation
    ) {
    return color(
      this.deviateChannel( red(col), deviation ),
      this.deviateChannel( green(col), deviation ),
      this.deviateChannel( blue(col), deviation )
      );
  }

  protected float deviateChannel(
    float value,
    float threshold
    ) {
    float min = max( value - threshold, 0 );
    float max = min( value + threshold, 255 );
    return random( min, max );
  }

  protected void rotateRandomly() {

    float angleX = map( noise(this.xoff), 0, 1, -PI / 4, PI / 4 );
    float angleY = map( noise(this.yoff), 0, 1, -PI / 4, PI / 4 );

    this.direction.rotate( angleX );
    this.direction.rotate( angleY );

    this.xoff += this.noiseStep;
    this.yoff += this.noiseStep;
  }

  public void update() {

    this.checkBoundaries();

    this.evaluateLife();

    this.applyDirection();

    this.doMove();

    this.updateColor();
  }

  public void draw(
  ) {

    push();

    strokeWeight(2);
    stroke( this.col );
    line( this.prev.x, this.prev.y, this.position.x, this.position.y );

    noStroke();
    //fill( this.col );
    // ellipse( this.position.x, this.position.y, 10, 10 );

    pop();
  }
}
