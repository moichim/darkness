class Time {

  boolean playing = false;

  int lastUpdated;
  int currentTime;
  int duration = -1;

  Time() {
  }

  Time start(
    ) {

    this.playing = true;
    this.lastUpdated = millis();
    this.currentTime = 0;
    println( "starting" );
    return this;
  }

  Time setDuration() {
    this.duration = -1;
    return this;
  }

  Time setDuration( int duration ) {
    this.duration = duration;
    return this;
  }

  Time end() {

    this.playing = false;
    println("ending");

    return this;
  }

  void update() {

    if ( this.playing == true ) {

      int current = millis();

      int time = current - this.lastUpdated;

      this.currentTime += time;

      this.lastUpdated = current;

      if ( this.duration > 0 ) {
        if ( this.currentTime >= this.duration ) {
          this.end();
        }
      }

      println( this.currentTime );

    }
  }

  float getIndex() {
    if ( this.duration == -1 ) {
      return 0;
    } else {
      return map( this.currentTime, 0, this.duration, 0, 1);
    }
  }

  float getIndexWithinRange(
    int from,
    int to
  ) {
    if ( this.duration == -1 ) {
      return 0;
    }

    if ( this.currentTime < from || this.currentTime > to ) {
      return 0;
    } else {
      return map( this.currentTime, from, to, 0, 1);
    }

  }
}
