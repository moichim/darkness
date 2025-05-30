class RendererCircles extends RendererAbstract {

    color renderColor;

    RendererCircles(
        Tracker tracker,
        color renderColor
    ) {
        super( tracker );
        this.renderColor = renderColor;
    }

    void updateInTracker( Tracker tracker ) {}

    void drawInTracker() {}

    void updateInBlob( Blob blob ) {}

     void drawInBlob( Blob blob ) {

        push();

        translate( blob.center.x, blob.center.y );

        noFill();
        stroke( this.renderColor );

        float diameter = max( blob.movement, 20 );

        ellipse( 0, 0, diameter, diameter );

        int amount = (int) map( blob.movement, 0, 100, 0, 10 );

        for ( int i = 0; i < amount; i++ ) {

            color col = this.getDeviatedColor( this.renderColor );

            fill( col );
            noStroke();

            float x = random( -diameter, diameter );
            float y = random( -diameter, diameter );

            float w = random( 5, 20 );// map( random(), 0, 1, 5, 20 );

            ellipse( x, y, w, w );

        }

        pop();

     }

}