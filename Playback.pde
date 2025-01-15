class Playback {

  Time time = new Time();
  Series series;

  boolean running = false;

  ArrayList<Effect> effects = new ArrayList<Effect>();


  Playback(
    Series series,
    int duration
    ) {
    this.series = series;
    this.time.setDuration( duration );
    println( "Creating playback" );
  }


  protected void init() {
    for ( Serie serie : this.series.series ) {
      Effect effect = new Effect( serie, this );
      this.effects.add( effect );
      // effect.mapToTime( 100, 2000 );
      println( "creating effect from", serie.id, serie, effect );
    }
  }



  void start() {
    this.init();
    this.time.start();
    println( "starting playback" );
  }

  void end() {
    this.time.end();
  }

  void update() {

    this.time.update();

    if ( this.time.playing == true ) {

      // Iterovat všechny efekty
      for ( Effect effect : this.effects ) {

        effect.setTime( this.time.currentTime );

      }
    }
  }

  void draw() {
    if ( this.time.playing == true ) {

      // Draw the timeline
      fill( 255, 0, 0 );
      float w = this.time.getIndex() * width;
      rect( 0, 0, w, 10 );


      fill(0);

      text( "Čas " + this.time.getIndex(), 200, 100 );

        for ( Effect effect : this.effects ) {

        effect.draw();
        
      }

    }
  }
}
