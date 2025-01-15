class Effect {

  Serie serie;
  Playback playback;

  int ms = 0;
  float index = 0;

  ArrayList<Sample> samples = new ArrayList<Sample>();

  int start;
  int end;
  int duration;

  Effect(
    Serie serie,
    Playback playback
    ) {

    this.serie = serie;
    this.playback = playback;

    this.mapToTime( this.serie.getStart(), this.serie.getEnd() );

    /*
    this.start = this.serie.getStart();
    this.end = this.serie.getEnd();
    this.duration = this.end - this.start;

    this.remapSamples();
    */
  }

  protected void remapSamples() {

    // Clear samples on start
    this.samples.clear();

    // Create new samples right now
    for ( Point point : this.serie.points ) {
      Sample sample = new Sample( point, this );
      this.samples.add( sample );
    }
  }

  void mapToTime( int from, int to ) {
    this.start = from;
    this.end = to;
    this.duration = to - from;
    this.remapSamples();
  }

  void lookForFirstSample( int time ) {

    if ( this.samples.size() == 0 ) {
      return;
    }

    Sample sample = this.samples.get( 0 );

    if ( sample != null ) {
      if ( sample.timeRelative < time ) {
        sample.draw();
        this.samples.remove( 0 );
        lookForFirstSample( time );
      }
    }

  }

    void setTime( int time ) {

      lookForFirstSample( time );



      /*

        if ( time < this.start ) {
            setIndex( 0 );
        } else if ( time > this.end ) {
            setIndex( 1 );
        } else {
            float index = map( time, this.start, this.end, 0, 1 );
            setIndex( index );
        }
        */

    }

    protected void setIndex( float index ) {

        for ( Sample sample : this.samples ) {
            sample.setIndex( index );
        }

    }

    public void draw() {
        for ( Sample sample : this.samples ) {
            // sample.draw();
        }
    }


}
