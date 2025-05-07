class DriverApproach extends DriverAbstract {

    DriverApproach( Tracker tracker ) {
        this.tracker = tracker;
    }

    public MovementApproach getParticleMovementObject( Particle particle ) { return particle.movementApproach; }

    public void setImpact( float value ) {

        super.setImpact( value );

        this.forEveryParticle( particle -> {
            particle.movementApproach.setImpact( value );
        } );

    }

    public void applyToNewParticle( Particle particle ) {
        particle.movementApproach.setOn( this.on );
        particle.movementApproach.setImpact( this.impact );
    }

    public void update() {}

}