abstract class AbstractMovement {

    Particle particle;
    protected float impact = 1;
    protected boolean on = false;

    public float getImpact() { return this.impact; }
    public void setImpact( float value ) { this.impact = constrain(value, 0, 1); }

    public boolean getOn() { return this.on; }
    public void setOn( boolean value ) { this.on = value; }
    public void on() { this.on = true; }
    public void off() { this.on = false; }

    public void update() {
        if ( this.on == true ) {
            this.evaluate();
        }
    }

    protected abstract void evaluate();

    protected void applyDirection( PVector value ) {
        this.particle.direction.lerp( value, this.impact );
    }

    protected void applySpeed( float value ) {
        this.particle.speed = lerp( this.particle.speed, value, this.impact );
    }

}

class MovementRandom extends AbstractMovement {

    protected float noiseStep = 0.09;
    protected float xoff = random(1000);
    protected float yoff = random(1000);

    MovementRandom( Particle particle ) {
        this.particle = particle;
    }

    public void setNoiseStep( float value ) {
        this.noiseStep = value;
    }

    protected void evaluate() {

        float angleX = map( noise(this.xoff), 0, 1, -PI / 4, PI / 4 );
        float angleY = map( noise(this.yoff), 0, 1, -PI / 4, PI / 4 );

        PVector direction = this.particle.direction.copy();
        direction.rotate( angleX );
        direction.rotate( angleY );

        this.applyDirection( direction );

        this.xoff += this.noiseStep;
        this.yoff += this.noiseStep;

    }


}

class MovementFollow extends AbstractMovement {

    protected Blob blob = null;

    MovementFollow( Particle particle ) {
        this.particle = particle;
        this.blob = particle.blob;
    }

    public void setTarget( Blob blob ) {
        this.blob = blob;
    }

    public void unsetTarget() {
        this.blob = null;
    }


    protected void evaluate() {
        if ( this.blob == null ) {
            return;
        }

        PVector direction = this.blob.center
            .copy()
            .sub( this.particle.position )
            .normalize();

        this.applyDirection( direction );

        float speed = map( this.blob.diameter, 0, video.width, 5, 1 );
        this.applySpeed( speed );

    }

}

class MovementApproach extends AbstractMovement {

    protected Blob blob = null;

    MovementApproach( Particle particle ) {
        this.particle = particle;
        this.blob = particle.blob;
    }

    public void setTarget( Blob blob ) {
        this.blob = blob;
    }

    public void unsetTarget() {
        this.blob = null;
    }

    protected void evaluate() {

        if ( this.blob != null ) {

            if ( this.blob.movement != 0 ) {

                float movement = map(
                    this.blob.movement,
                    0,
                    controller.mapping.output.x / 10, 
                    0, 
                    1
                );

                float distance = this.particle.position.dist( this.blob.center );

                float d = constrain(
                    map( distance, 0, 300, 2, 1 ),
                    1,
                    2
                );

                float value = controller.minSpeed() + ( controller.maxSpeed() * movement );

                this.applySpeed( value );

            }

        }

    }

}

class MovementJump extends AbstractMovement {

    float jump = 0;
    float factor = 1;

    MovementJump( Particle particle ) {
        this.particle = particle;
    }

    public void setJump(float value) {
        this.jump = abs( value );
    }

    protected void evaluate() {
        if ( this.jump == 0 ) {
            // Do nothing
        }
        else if (this.jump <= 0.1) {
            this.jump = 0;
            this.factor = 1;
        } else {
            this.jump = lerp( this.jump, 0, 0.9 );
            this.factor = 1 + this.jump;
        }

        float value = lerp( this.factor, 1, this.impact );

        this.particle.speed = this.particle.speed * value;

    }


}



class MovementNormal extends AbstractMovement {

    MovementNormal( Particle particle ) {
        this.particle = particle;
    }


    protected void evaluate() {

        if ( this.particle.blob != null ) {
            if (this.particle.blob.tracker != null ) {
                if ( this.particle.blob.tracker.particleRenderer.weightMap != null ) {

                    PVector direction = this.particle.blob.tracker.particleRenderer.weightMap.getNormalVector( this.particle.position );

                    this.applyDirection( direction );

                }
            }
        }

    }

}




class MovementColor extends AbstractMovement {

    protected float impact = 0.1;

    protected color target;

    MovementColor( Particle particle ) {
        this.particle = particle;
    }

    public void setTarget( color value ) {
        this.target = value;
    }

    public void unsetTarget() {
        // this.target;
    }

    protected void evaluate() {
        // if ( this.target != null ) {

            if ( this.target != this.particle.col ) {
                this.particle.col = lerpColor( this.particle.col, this.target, this.impact );
            } else {
                // this.target = null;
            }

        // }
    }

    public void grabColorFromTracker() {
        if ( this.particle.blob != null ) {
            if ( this.particle.blob.tracker != null ) {
                this.target = this.particle.blob.tracker.trackColor;
            }
        }
    }

}