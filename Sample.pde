class Sample extends AbstractPoint {

  float index = 0;
  Effect effect;

  float maxSize = 100;

  float timeRelative;
  float indexRelative;

  Sample(
    Point point,
    Effect effect
    ) {
    super( point.x, point.y, point.time, point.mapping );
    this.effect = effect;
    this.remapLocalTime();
  }

  protected void remapLocalTime() {

    this.timeRelative = this.time - this.effect.start;
    this.indexRelative = this.timeRelative / this.effect.duration;

  }

  void setIndex( float index ) {
    this.index = index;
  }

  void draw() {

    if ( this.index == 0 ) {
      // return;
    }

    float size = this.maxSize * this.index;

    noStroke();
    fill( 30 );

    PVector output = this.mapping.output( this );

    ellipse( output.x, output.y, size, size );

    fill( 255 );
    text( this.index, output.x, output.y );
    text( "time" + this.time, output.x, output.y + 20 );

  }
}
