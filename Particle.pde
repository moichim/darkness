enum LIFE {
  RUNSAWAY,
  FOLLOWS,
  LOST,
  REACHED,
  DEAD
}

class Particle {

  /** The state that determines everything else. */
  LIFE phase = LIFE.RUNSAWAY;

  /** The current position */
  PVector position;
  /** The previous position is stored for the purpose of render */
  PVector prev;
  /** The direction = a normalised vector manipulated by movements */
  PVector direction;
  /** The current speed */
  float speed;
  /** The current speed is multiplied by this factor to enable temporal changements of speed in effects such as sumps etc. */
  float speedFactor = 1;

  /** The current color */
  color currentColor;

  int tick = 0;

  Blob blob;

  

  protected float reachDistance = 30;
  protected float screenBoundary = 50;
  protected float lifeDuration = 200;
  protected float originalDiameter;



  MovementRandom movementRandom;
  MovementFollow movementFollow;
  MovementApproach movementApproach;
  MovementJump movementJump;
  MovementColor movementColor;

  float speedMultiplocatorLocal;


  Particle(
    Blob blob
  ) {

    this.blob = blob;

    // Create the core properties
    this.position = blob.center.copy();
    this.prev = this.position;
    this.speed = random( 1, 5 );
    this.direction = new PVector(
      random( -1, 1 ),
      random(-1, 1 )
    );
    this.currentColor = blob.tracker.particleRenderer.getColor(); // The initial color comes from the renderer
    this.speedMultiplocatorLocal = random(1,2);


    // Create the movements
    this.movementRandom = new MovementRandom( this );
    this.movementFollow = new MovementFollow( this );
    this.movementApproach = new MovementApproach( this );
    this.movementJump = new MovementJump( this );
    this.movementColor = new MovementColor( this );

    this.originalDiameter = blob.diameter;

    
  }

  /** Get the current renderer if any */
  public RendererParticles getRenderer() {
    if (this.blob != null) {
      if ( this.blob.tracker != null ) {
        return this.blob.tracker.particleRenderer;
      }
    }
    return null;
  }

  void setDead() {
    this.phase = LIFE.DEAD;
    this.movementFollow.off();
    this.movementApproach.off();
    this.movementJump.off();
    this.movementRandom.off();
    this.movementColor.off();
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
      this.movementColor.setTarget( blob.tracker.particleRenderer.getColor() );
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
      this.movementColor.setTarget( externalBlob.tracker.particleRenderer.getColor() );
    }
  }

  void unassignExternalBlob() {
    this.setLost();
  }


  /** Conditions that automatically evaluate the particle's lifecycle. */
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

    float finalSpeed = this.speed * ( this.speedFactor * delta ) * speedMultiplicator * this.speedMultiplocatorLocal;

    change.mult( 
      constrain(
        finalSpeed,
        0.1,
        30
      )  
    );

    // Update the position
    this.position.add( change );
  }



  /** 
   * Before move, all internal movements are applied.
   * Also, the particle's oorders are applied. 
   */
  protected void updateMovements() {
    
    this.movementFollow.update();
    this.movementApproach.update();
    this.movementJump.update();
    this.movementColor.update();
    this.movementRandom.update();

    if ( this.blob != null ) {
      if ( this.blob.tracker != null ) {
        this.blob.tracker.particleRenderer.updateInParticle( this );
      }
    }

  }

  public void update() {

    this.checkBoundaries();

    this.evaluateLife();

    this.updateMovements();

    this.doMove();
    
  }

  public void draw() {

    RendererParticles renderer = this.getRenderer();
    if (renderer != null && renderer.isHidden()) {
        return; // Pokud je renderer skrytý, nevykresluj částici
    }

    push();

    strokeWeight(2);
    stroke( this.currentColor );
    line( this.prev.x, this.prev.y, this.position.x, this.position.y );

    noStroke();

    pop();
  }
}
