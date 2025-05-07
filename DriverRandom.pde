class DriverRandom extends DriverAbstract {

    protected float noiseStep = 0.1;
    protected float spread = 12;

    DriverRandom( Tracker tracker ) {
        this.tracker = tracker;
    }

    public MovementRandom getParticleMovementObject( Particle particle ) { return particle.movementRandom; }

    public void setImpact( float value ) {

        super.setImpact( value );

        this.forEveryParticle( particle -> {
            particle.movementRandom.setImpact( value );
        } );

    }

    public void setNoiseStep( float value ) {

        this.forEveryParticle( particle -> {
            particle.movementRandom.setNoiseStep( value );
        } );

    }

    public void setSpread( float value ) {

        this.forEveryParticle( particle -> particle.movementRandom.setSpread( value ) );

    }

    public void applyToNewParticle( Particle particle ) {
        particle.movementRandom.setOn( this.on );
        particle.movementRandom.setImpact( this.impact );
        particle.movementRandom.setNoiseStep( this.noiseStep );
        particle.movementRandom.setSpread( this.spread );
    }

    public void update() {}

}