abstract class RendererAbstract {

    Tracker tracker;

    RendererAbstract( Tracker tracker ) {
        this.tracker = tracker;
    }

    abstract void updateInTracker( Tracker tracker );

    abstract void updateInBlob( Blob blob );

    abstract void drawInBlob( Blob blob );

    abstract void drawInTracker();

    color getDeviatedColor( color col ) {
        return color(
            this.getDeviatedChannel( red( col ) ),
            this.getDeviatedChannel( green( col ) ),
            this.getDeviatedChannel( blue( col ) )
        );
    }

    float getDeviatedChannel( float value ) {
        float deviation = controller.colorDeviationThreshold();
        float min = constrain( value - deviation, 0, 255 );
        float max = constrain( value + deviation, 0, 255 );
        return random( min, max );
    }

}