
/**
 * Set the particle's speed based on the blob's movement.
 */
class MovementApproach extends MovementAbstract {

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