abstract class RendererAbstract {

    Tracker tracker;

    RendererAbstract(
        Tracker tracker
    ) {
        this.tracker = tracker;
    }

    abstract void updateInBlob( Blob blob );

    abstract void drawInBlob( Blob blob );

    abstract void drawInTracker();

    color getDeviatedColor( color col ) {
        return color(
            this.getDeviatedChannel( red( col ) ),
            this.getDeviatedChannel( green( col ) ),
            this.getDeviatedChannel( blue( col ) )
        );
    }

    float getDeviatedChannel( float value ) {
        float deviation = controller.colorDeviationThreshold();
        float min = constrain( value - deviation, 0, 255 );
        float max = constrain( value + deviation, 0, 255 );
        return random( min, max );
    }

}

class RendererParticles extends RendererAbstract {

    int tick = 0;

    WeightMap weightMap = null;
    OrderColumns orderColumns;
    OrderCircle orderCircle;
    OrderRound orderRound;
    OrderRandom orderRandom;

    RendererParticles(
        Tracker tracker
    ) {
        super( tracker );
        this.orderColumns = new OrderColumns( tracker );
        this.orderRound = new OrderRound( tracker );
        this.orderRandom = new OrderRandom( tracker );
        this.orderCircle = new OrderCircle( tracker );

        this.orderColumns.configure( false, 10, 50 );
        this.orderColumns.setImpact( 0.5 );
        this.orderColumns.off();

        this.orderRound.configure(6);
        this.orderRound.setImpact(0.8);
        // this.orderRound.on();

        // this.orderRandom.on();
        // this.orderRandom.setImpact(1);
        // this.orderRandom.setNoiseStep( 1 );
        // this.orderRandom.setSpread( 8 );
    }

    RendererParticles setWeightMask(PImage image) {
        this.weightMap = new WeightMap(image);
        return this;
    }

    RendererParticles unsetWeightMask() {
        this.weightMap = null;
        return this;
    }

    void updateInBlob( Blob blob ) {

        float life = map( blob.diameter, 0, video.width, 5, 1 );
        
        this.emitParticle( blob );

        if ( this.tick >= life ) {
            this.emitParticle( blob );
            this.tick = 0;
        }

        this.tick++;

    }

    void updateInParticle( Particle particle ) {
        this.orderColumns.applyToParticle( particle );
        this.orderRound.applyToParticle( particle );
        this.orderCircle.applyToParticle( particle );
    }

    protected void emitParticle( Blob blob ) {
        blob.particles.add( controller.particles.emit( blob ) );
    }

    void drawInBlob( Blob blob ) {}

    void drawInTracker() {}

}


class RendererCircles extends RendererAbstract {

    RendererCircles(
        Tracker tracker
    ) {
        super( tracker );
    }

    void updateInBlob( Blob blob ) {}

     void drawInBlob( Blob blob ) {

        push();

        translate( blob.center.x, blob.center.y );

        noFill();
        stroke( this.tracker.emissionColor );

        float diameter = max( blob.movement, 20 );

        ellipse( 0, 0, diameter, diameter );

        int amount = (int) map( blob.movement, 0, 100, 0, 10 );

        for ( int i = 0; i < amount; i++ ) {

            color col = this.getDeviatedColor( this.tracker.emissionColor );

            fill( col );
            noStroke();

            float x = random( -diameter, diameter );
            float y = random( -diameter, diameter );

            float w = random( 5, 20 );// map( random(), 0, 1, 5, 20 );

            ellipse( x, y, w, w );

        }

        pop();

     }

    void drawInTracker() {}

    

}


class RendererBitmap extends RendererAbstract {

    PImage image;
    PGraphics graphics;

    RendererBitmap(
        Tracker tracker,
        PImage image
    ) {
        super( tracker );
        this.image = image;
        this.graphics = createGraphics( 
            width,    
            height
        );
    }

    void resetCanvas() {
        this.graphics.background(0);
    }

    void updateInBlob( Blob blob ) {}

    void drawInBlob( Blob blob ) {}

    void drawInTracker() {

        for ( Blob blob : this.tracker.blobs ) {

            push();

            translate( blob.center.x, blob.center.y );

            float diameter = max( blob.movement, 50 );

            blendMode( LIGHTEST );

            rotate( random( 0, 2 * PI ) );

            // this.graphics.ellipse( 0, 0, diameter, diameter );

            color col = this.getDeviatedColor( this.tracker.emissionColor );

            // tint( col, 255 );
            image( list, 0, 0, diameter, diameter );

            // noTint();

            blendMode( BLEND );

            pop();

        }

    }

}

class RendererSample extends RendererAbstract {

    FolderBank bank;

    RendererSample(
        Tracker tracker,
        FolderBank bank
    ) {
        super( tracker );
        this.bank = bank;
    }

    void updateInBlob( Blob blob ) {}

    void drawInBlob( Blob blob ) {

        push();

        translate( blob.center.x, blob.center.y );

        rotate( random(0, 2*PI) );

        float sc = max(50, blob.width);

        PImage img = this.bank.exact.getFromRange( 0, 1200 );

        blendMode( LIGHTEST );

        imageMode( CENTER );

        image( img, 0, 0, sc, sc );


        blendMode( BLEND );

        pop();

    }

    void drawInTracker() {}


}