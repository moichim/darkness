abstract class AbstractOrder extends ObjectImpactableTracker {

    public void applyToParticle( Particle particle ) {
        if ( this.on == true ) {
            this.evaluate( particle );
        }
    }

    protected abstract void evaluate( Particle particle );

}