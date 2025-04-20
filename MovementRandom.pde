class MovementRandom extends MovementAbstract {

    protected float noiseStep = 0.09;
    protected float xoff = random(1000);
    protected float yoff = random(1000);
    protected float spread = 12;

    MovementRandom( Particle particle ) {
        this.particle = particle;
    }

    public void setNoiseStep( float value ) {
        this.noiseStep = value;
    }

    public void setSpread( float value ) {
        this.spread = value;
    }

    protected void evaluate() {

        float angleX = map( noise(this.xoff), 0, 1, (-PI * 2) / this.spread, (PI * 2) / this.spread );
        float angleY = map( noise(this.yoff), 0, 1, (-PI * 2) / this.spread, (PI * 2) / this.spread );

        PVector direction = this.particle.direction.copy();
        direction.rotate( angleX );
        direction.rotate( angleY );

        this.applyDirection( direction );

        this.xoff += this.noiseStep;
        this.yoff += this.noiseStep;

    }


}