class DriverFollow extends DriverAbstract {

    DriverFollow( Tracker tracker ) {
        this.tracker = tracker;
    }

    public MovementFollow getParticleMovementObject( Particle particle ) { return particle.movementFollow; }

    public void setImpact( float value ) {

        super.setImpact( value );

        this.forEveryParticle( particle -> {
            particle.movementFollow.setImpact( value );
        } );

    }

    public void applyToNewParticle( Particle particle ) {
        particle.movementFollow.setOn( this.on );
        particle.movementFollow.setImpact( this.impact );
    }

    public void update() {}

}