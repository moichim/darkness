/**
 * Animate the particle`s color
 */
class MovementColor extends MovementAbstract {

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

            if ( this.target != this.particle.currentColor ) {
                this.particle.currentColor = lerpColor(
                    this.particle.currentColor, 
                    this.target, 
                    this.impact 
                );
            } else {
                // this.target = null;
            }

        // }
    }

}