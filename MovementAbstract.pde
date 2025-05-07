abstract class MovementAbstract extends ObjectImpactable {

    Particle particle;

    public void update() {
        if ( this.on == true ) {
            this.evaluate();
        }
    }

    protected abstract void evaluate();

    protected void applyDirection( PVector value ) {
        this.particle.direction.lerp( value, this.impact ).normalize();
    }

    protected void applySpeed( float value ) {
        this.particle.speed = lerp( this.particle.speed, value, this.impact );
    }

}