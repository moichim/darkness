enum LIFE {
  RUNSAWAY,
  FOLLOWS,
  LOST,
  REACHED,
  DEAD
}

class Particle {

  PVector position;
  PVector prev;
  PVector direction;
  float speed;
  float speedFactor = 1;

  color col;

  int tick = 0;

  Blob blob;

  LIFE phase = LIFE.RUNSAWAY;

  protected float reachDistance = 30;
  protected float screenBoundary = 50;
  protected float lifeDuration = 200;
  protected float originalDiameter;



  MovementRandom movementRandom;
  MovementFollow movementFollow;
  MovementApproach movementApproach;
  MovementJump movementJump;
  MovementColor movementColor;
  MovementNormal movementNormal;


  Particle(
    Blob blob
  ) {

    this.blob = blob;

    this.movementRandom = new MovementRandom( this );
    this.movementFollow = new MovementFollow( this );
    this.movementApproach = new MovementApproach( this );
    this.movementJump = new MovementJump( this );
    this.movementColor = new MovementColor( this );
    this.movementNormal = new MovementNormal( this );

    this.movementRandom.on();
    this.movementRandom.setImpact(0.7);
    this.movementJump.setImpact( 0.5 );
    this.movementFollow.setImpact(0.2);

    // this.movementNormal.on();
    this.movementNormal.setImpact(1);



    this.position = blob.center.copy();
    this.position.x += random( -20, 20 );
    this.position.y += random( -20, 20 );
    this.prev = this.position;

    this.col = this.deviation( this.blob.tracker.emissionColor, (int) round( controller.colorDeviationThreshold() ) );// this.deviation( blob.tracker );
    this.movementColor.setTarget( this.col );

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
      this.tick = 0;
      this.lifeDuration = round( random( 20, 100 ) );
      
      // Update movements
      this.movementFollow.off();
      this.movementApproach.off();
      this.movementJump.off();
      this.movementRandom.on();
      this.movementRandom.setImpact( 0.5 );
      this.movementColor.on();
      this.movementColor.setTarget( color(0) );
      // this.movementColor.setImpact( 0.1 );

    }
  }

  void assignToBlob( Blob blob ) {
    if ( this.blob != blob ) {
      this.blob = blob;
      this.phase = LIFE.FOLLOWS;
      this.movementFollow.on();
      this.movementFollow.setTarget( blob );
      this.movementApproach.on();
      this.movementApproach.setTarget( blob );
      this.movementColor.setTarget( blob.tracker.trackColor );
    }
  }

  void assignToExternalBlob(
    Blob externalBlob
    ) {
    this.phase = LIFE.FOLLOWS;
    this.movementFollow.setTarget( externalBlob );
    this.movementFollow.on();
    this.movementApproach.setTarget( externalBlob );
    this.movementApproach.on();
    if ( externalBlob.tracker != null ) {
      this.movementColor.setTarget( externalBlob.tracker.trackColor );
    }
  }

  void unassignExternalBlob() {
    this.setLost();
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

    // If the phase is out, check for the distance towards the blob and eventually set as null
    else if ( this.phase == LIFE.RUNSAWAY ) {

      float dist = this.blob.center.dist( this.position );
      if ( dist >= this.originalDiameter / 2 ) {
        this.phase = LIFE.FOLLOWS;
        this.movementFollow.on();
        this.movementApproach.on();
      }

    }

    // If follows, check if reached already and eventually set the reach
    else if ( this.phase == LIFE.FOLLOWS ) {

      float dist = this.blob.center.dist( this.position );
      if ( dist <= this.reachDistance ) {
        this.phase = LIFE.REACHED;
      }
    }
  }

  

  public void doJump( float amount ) {
    this.movementJump.setJump( amount );
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
    change.mult( this.speed * this.speedFactor );

    // Update the position
    this.position.add( change );
  }

  public void setColor(
    color col,
    float deviation
  ) {
    this.movementColor.setTarget( 
      color(
        this.deviateChannel( red( col ), deviation ),
        this.deviateChannel( green( col ), deviation ),
        this.deviateChannel( blue(col), deviation )
      ) 
    );
  }

  public void setRandomColorFromTracker() {
    this.movementColor.setTarget( 
      this.deviation(this.blob.tracker.trackColor, 200) 
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

  protected void updateMovements() {
    this.movementRandom.update();
    this.movementFollow.update();
    this.movementApproach.update();
    this.movementJump.update();
    this.movementColor.update();
    this.movementNormal.update();
  }

  public void update() {

    this.checkBoundaries();

    this.evaluateLife();

    this.updateMovements();

    this.doMove();
    
  }

  public void draw() {

    push();

    strokeWeight(2);
    stroke( this.col );
    line( this.prev.x, this.prev.y, this.position.x, this.position.y );

    noStroke();

    pop();
  }
}
