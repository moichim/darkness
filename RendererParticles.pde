/** 
 * The main object holding the tracker`s particles.
 * 
 * The logic is in Order classes. This renderer class is responsible mainly 
 * for creation of particles and populating their parameters.
 */
class RendererParticles extends RendererAbstract {

    int tick = 0;

    int emisionRate = 1;

    protected color originalRendererColor;
    protected color renderColor;

    OrderColumns orderColumns;
    OrderCircle orderCircle;
    OrderRound orderRound;
    OrderNormal orderNormal;

    DriverRandom driverRandom;
    DriverJump driverJump;
    DriverFollow driverFollow;
    DriverApproach driverApproach;
    DriverColor driverColor;


    RendererParticles(
        Tracker tracker,
        color renderColor
    ) {
        super( tracker );

        this.renderColor = renderColor;
        this.originalRendererColor = renderColor;
        
        this.orderColumns = new OrderColumns( tracker );
        this.orderRound = new OrderRound( tracker );
        this.orderCircle = new OrderCircle( tracker );
        this.orderNormal = new OrderNormal( tracker );

        this.driverRandom = new DriverRandom( tracker );
        this.driverJump = new DriverJump( tracker );
        this.driverFollow = new DriverFollow( tracker );
        this.driverApproach = new DriverApproach( tracker );
        this.driverColor = new DriverColor( tracker );

    }


    public Particle emitParticleFromBlob(
        Blob blob
    ) {

        Particle particle = new Particle( blob );

        // Apply the drivers' state
        this.driverRandom.applyToNewParticle( particle );
        this.driverJump.applyToNewParticle( particle );
        this.driverFollow.applyToNewParticle( particle );
        this.driverApproach.applyToNewParticle( particle );
        this.driverColor.applyToNewParticle( particle );

        // Randomise the position
        particle.position.x += random( -20, 20 );
        particle.position.y += random( -20, 20 );

        // Store the particle in the controller
        controller.particles.recieveEmittedParticle( particle );

        // Store the particle in the blob
        blob.particles.add( particle );

        return particle;

    }


    public void setColor( color value ) {
        this.renderColor = value;
    }

    public color getColor() {
        return this.renderColor;
    }

    public void resetColor() {
        this.renderColor = this.originalRendererColor;
    }

    void updateInTracker( Tracker tracker ) {
        // Update the drivers
        this.driverRandom.update();
        this.driverJump.update(); // This seems not to be necessary
    }

    void updateInBlob( Blob blob ) {

        for ( int i = 0; i <= this.emisionRate; i++ ) {
            this.emitParticleFromBlob( blob );
        }

    }

    void updateInParticle( Particle particle ) {
        this.orderColumns.applyToParticle( particle );
        this.orderRound.applyToParticle( particle );
        this.orderCircle.applyToParticle( particle );
        this.orderNormal.applyToParticle( particle );
    }

    void drawInBlob( Blob blob ) {}

    void drawInTracker() {}

}