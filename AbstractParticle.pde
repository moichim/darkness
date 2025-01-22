class AbstractParticle {

    PVector position;
    PVector prev;
    PVector direction;
    float speed;

    PVector destination;

    color col;

    int tick = 0;
    float noiseStep = 0.09;
    float xoff = random(1000);
    float yoff = random(1000);

    Blob blob;
    Tracker tracker;

    AbstractParticle(
        float x,
        float y,
        Tracker tracker,
        Blob blob
    ) {

        this.position = mapping.output( new PVector( x, y ) );
        this.prev = this.position;

        this.col = this.deviation( tracker );

        this.speed = random( 1, 5 );
        this.direction = new PVector(
            random( -1, 1 ),
            random(-1, 1 )
        );

        this.blob = blob;
        this.tracker = tracker;

    }

    protected color deviation(
        Tracker tracker
    ) {
        return color(
            this.deviateChannel( tracker.r, 100 ),
            this.deviateChannel( tracker.g, 100 ),
            this.deviateChannel( tracker.b, 100 )
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

        this.tick++;


        PVector blobCenter = this.blob.getCenter();

        PVector mappedBlobCenter = mapping.output( blobCenter );

        float dist = mappedBlobCenter.dist( this.position );

        if ( dist < 20 ) {
            this.rotateRandomly();
        } else {

            PVector diff = mappedBlobCenter.sub( this.position );
            diff.normalize();
            this.direction = diff;

            this.rotateRandomly();

        }

        this.prev = this.position.copy();

        PVector change = this.direction.copy();
        change.mult( this.speed );

        this.position.add( change );

    }

    public void draw() {

        push();

        stroke( this.col );
        line( this.prev.x, this.prev.y, this.position.x, this.position.y );

        noStroke();
        //fill( this.col );
        // ellipse( this.position.x, this.position.y, 10, 10 );

        pop();

    }


}