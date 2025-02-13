class Particles {

  ArrayList<Particle> points = new ArrayList<Particle>();

  int max = 800;

  // public PGraphics canvas;

  Particles(
    int w,
    int h
  ) {
    // this.canvas = createGraphics( w, h );
  }

  Particle emit(
    Blob blob
    ) {



    Particle item = new Particle(blob);
    this.points.add( item );

    if ( this.points.size() >= this.max ) {
      this.points.remove( 0 );
    }
    return item;
  }

  void remove(
    Particle particle
    ) {

    PVector position = particle.position;

    Blob nearestBlob = null;
    float nearestDiff = 0;
  }

  void update() {

    if ( this.points.size() > 0 ) {


      // First, perform updates with the particles
      for ( int i = this.points.size() - 1; i >= 0; i-- ) {
        Particle p = this.points.get( i );

        // Remove the dead or reached
        if ( p.phase == LIFE.DEAD || p.phase == LIFE.REACHED ) {
          // println( "Point", i, "from", this.points.size(), "just died" );
          // p.blob.particles.remove( p );
          this.points.remove( p );
          // this.points.remove( p );
        }

        // Reassign the lost
        else if ( p.phase == LIFE.LOST ) {

          for ( Tracker tracker : controller.trackers ) {

            if ( p.phase == LIFE.LOST ) {

              for ( Blob blob : tracker.blobs ) {

                float distance = blob.center.dist( p.position );

                if ( distance <= controller.lostParticlesDistance() ) {
                  p.assignToBlob( blob );
                }
              }
            }
          }
        }
      }


      for ( Particle p : this.points ) {
        p.update();
      }
    }

    // if ( frameCount % 10 == 0 ) {
      this.syncToSound();
    // }
  }

  void syncToSound() {

    float amp = 0;
    float freq = 0;
    float pan = 0;


    if ( this.points.size() > 0 ) {
      
      // Calculate the amplitude
      amp = map( this.points.size(), 0, this.max, 0, 1 );
      
      float posSum = 0;
      float speedSum = 0;

      for ( Particle particle : this.points ) {
        posSum += particle.position.x;
        speedSum += particle.speed;
      }

      float posAvg = posSum / this.points.size();
      float speedAvg = speedSum / this.points.size();

      // Calculate the frequency
      freq = map( speedAvg, controller.minSpeed(), controller.maxSpeed(), controller.blipFreqMin(), controller.blipFreqMax() );
      pan = map( posAvg, 0, controller.mapping.output.x, -1, 1 );

      // println(freq, speedAvg, controller.minSpeed(), controller.maxSpeed(), controller.blipFreqMin(), controller.blipFreqMax());

    }

    // controller.syncBlip( pan, amp, freq );

  }

  void draw() {

    // this.canvas.beginDraw();
    blendMode(MULTIPLY);
    fill( 0, 0, 0, controller.bga() );
    rect( 0, 0, width, height );
    blendMode(BLEND);

    for ( Particle p : this.points ) {
      p.draw( );
    }

    // this.canvas.endDraw();

    // image( this.canvas, 0, 0 );


  }
}
