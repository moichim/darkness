/**
 * Adjust the particles direction towards its blob.
 */
class MovementFollow extends MovementAbstract {

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

        // float speed = map( this.blob.diameter, 0, video.width, 5, 1 );
        // this.applySpeed( speed );

    }

}