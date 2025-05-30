class OrderColumns extends AbstractOrder {

  protected int number = 0;
  protected int segments = 0;
  protected float step = 0;
  protected float width = 50;
  protected boolean vertical = true;

  OrderColumns( Tracker tracker ) {
    this.tracker = tracker;
  }

  public void configure(
    boolean vertical,
    int number,
    float width
    ) {

    int numberSafe = max( number, 1 );

    this.vertical = vertical;
    this.number = numberSafe;
    this.segments = numberSafe + 1;
    float dimension = this.vertical == true
      ? controller.mapping.output.x
      : controller.mapping.output.y;
    this.step = dimension / this.segments;
    this.width = constrain( width, 0, this.step / 3 );
  }

  public void setNumber( int number ) {

    int numberSafe = max( number, 1 );

    float dimension = this.vertical == true
      ? controller.mapping.output.x
      : controller.mapping.output.y;

    this.number = numberSafe;
    this.segments = numberSafe + 1;
    this.step = dimension / this.segments;
    this.width = constrain( width, 0, this.step / 3 );

  }

  public void setOrientation( boolean vertical ) {
    if ( this.vertical != vertical ) {
      this.configure( vertical, this.number, this.width );
    }
  }


  protected void evaluate( Particle particle ) {

    float position = this.getParticlePosition( particle );

    float nearest = this.getNearestColumnPosition( position );

    boolean isInsideColumn = this.isInsideColumn( position, nearest );

    PVector towards = this.getRotationTowards( position, nearest );

    PVector inwards = this.getRotationInside( position, nearest );

    float halfAColumn = this.step / 2;
    float distance = abs( position - nearest );
    float difference = abs( halfAColumn - distance );
    float towardsRatio = map( difference, 0, halfAColumn, 0, 1 );

    PVector result = PVector.lerp( towards, inwards, towardsRatio ).normalize();

    particle.direction = PVector.lerp( particle.direction, result, this.impact );
  }


  protected float getParticlePosition( Particle particle ) {
    return this.vertical == true
      ? particle.position.x
      : particle.position.y;
  }

  protected float getNearestColumnPosition( float position ) {

    float nearest = 0;
    boolean matched = false;

    if (this.step <= 0) {
      println("OrderColumns: step is zero or negative! number:", this.number, "segments:", this.segments);
      return 0;
    }

    while ( nearest < controller.mapping.output.x && matched == false ) {

      float next = nearest + this.step;
      float threshold = next - ( this.step / 2);

      if ( position >= threshold ) {
        nearest = next;
      } else {
        matched = true;
        break;
      }
    }

    return nearest;
  }

  protected boolean isInsideColumn( float position, float nearest ) {
    float distance = abs( nearest - position );
    float threshold = this.width / 2;
    float thresholdDeviation = random( this.width / 5 );
    return distance < ( threshold + thresholdDeviation );
  }

  protected PVector getRotationTowards( float position, float nearest ) {

    float distance = nearest - position;
    PVector direction = this.vertical == true
      ? new PVector( distance, 0 )
      : new PVector( 0, distance );
    direction.normalize();

    return direction;
  }

  protected PVector getRotationInside( float position, float nearest ) {
    float distance = nearest - position;
    PVector direction = this.vertical == true
      ? new PVector( 0, distance )
      : new PVector(distance, 0);
    direction.normalize();
    return direction;
  }
}
