class DriverJump extends DriverAbstract {

    DriverJump( Tracker tracker ) {
        this.tracker = tracker;
    }

    public MovementJump getParticleMovementObject( Particle particle ) { return particle.movementJump; }

    public void doJump( float amount ) {
        this.forEveryParticle( particle -> particle.movementJump.doJump( amount )
        );
    }

    public void setImpact( float value ) {

        super.setImpact( value );

        this.forEveryParticle( particle -> {
            particle.movementJump.setImpact( value );
        } );

    }

    public void applyToNewParticle( Particle particle ) {
        particle.movementJump.setOn( this.on );
        particle.movementJump.setImpact( this.impact );
    }

    public void update() {}

}