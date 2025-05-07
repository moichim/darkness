/**
 * Adjust the particle's speed to simulate a jump.
 */
class MovementJump extends MovementAbstract {

    float jump = 0;
    float factor = 1;

    MovementJump( Particle particle ) {
        this.particle = particle;
    }

    public void doJump(float value) {
        this.jump = value;
    }

    protected void evaluate() {


        if ( this.jump >= 0.1 ) {
            this.factor = 1 + this.jump;
            this.jump = lerp( 0, this.jump, 0.5 );
        } else {
            this.jump = 0;
            this.factor = 1;
        }

        float value = lerp( 1, this.factor, this.impact );

        this.particle.speedFactor = value;

    }


}