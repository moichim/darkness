class DriverColor extends DriverAbstract {

    protected float threshold = 100;

    DriverColor( Tracker tracker ) {
        this.tracker = tracker;
    }

    public MovementColor getParticleMovementObject( Particle particle ) { return particle.movementColor; }

    public void setThreshold( float value ) {
        this.threshold = constrain( value, 0, 255 );
    }

    /** Get the current render color of this renderer */
    protected color getRenderColor() {
        return this.getRenderer().getColor();
    }


    /** Impose target color to all particles */
    public void imposeTargetColor( color value ) {
        this.forEveryParticle( particle -> particle.movementColor.setTarget( value ) );
    }


    /** Force all affected particles to generate a deviated color from the renderer */
    public void imposeRendererColor( float threshold ) {

        this.forEveryParticle( particle -> {

            color rendererColor = this.getRenderColor();

            color newColor = threshold == 0
                ? rendererColor
                : this.generateRgbDeviation( rendererColor, threshold );

            particle.movementColor.setTarget( newColor );

        } );

    }


    /** Generate a deviated RGB color from the provided color and the given threshold */
    public color generateRgbDeviation(
        color value,
        float threshold
    ) {
        return color(
            this.deviateRgbChannel( red( value ), threshold ),
            this.deviateRgbChannel( green( value ), threshold ),
            this.deviateRgbChannel( blue( value ), threshold )
        );
    }

    /** Generate a random RGB value for one channel */
    protected float deviateRgbChannel(
        float value,
        float threshold
    ) {
        return random( 
            max( 0, value - threshold ),
            min( 255, value + threshold )
        );
    }

    public void applyToNewParticle( Particle particle ) {

        particle.movementColor.setOn( this.on );

        // Generate the color from current threshold
        color newColor = this.generateRgbDeviation(
            this.getRenderColor(),
            this.threshold
        );
        // Set the color to the particle
        particle.currentColor = newColor;

    }

    public void update() {}

}