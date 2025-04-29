import java.util.function.Consumer;


abstract class DriverAbstract extends ObjectImpactableTracker {

    abstract MovementAbstract getParticleMovementObject( Particle particle );

    public void on() {
        super.on();
        this.forEveryParticle( particle -> {
            this.getParticleMovementObject(particle).setOn( true );
        } );
    }

     public void off() {
        super.off();
        this.forEveryParticle( particle -> {
            this.getParticleMovementObject(particle).setOn( false );
        } );
    }

    public void setImpact( float value ) {

        super.setImpact( value );

        this.forEveryParticle( particle -> {
            this.getParticleMovementObject(particle).setImpact( value );
        } );

    }

    /** 
     * Apply the state to new particles
     */
    public abstract void applyToNewParticle( Particle particle );

    protected void forEveryParticle( Consumer<Particle> function ) {
        for ( Blob blob : this.tracker.blobs ) {
            for ( Particle particle : blob.particles ) {
                function.accept( particle );
            }
        }
    }

    /**
     * Update the internal state
     */
    public abstract void update();



}