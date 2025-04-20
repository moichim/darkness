class OrderNormal extends AbstractOrder {

    protected PImage map;

    OrderNormal( Tracker tracker ) {
        this.tracker = tracker;
    }

    public void setMap( PImage map ) {
        this.map = map;
        this.map.loadPixels();
    }

    public void evaluate(Particle particle) {

        PVector direction = this.getNormalVector( particle.position );

        particle.direction = PVector.lerp( particle.direction, direction, this.impact ).normalize();

    }


    /**  */
    protected PVector getNormalVector( PVector position ) {

        color col = this.getColorAt( position );
        float red = red( col );
        float green = green( col );
        float blue = blue( col );

        float x = red / 255 * 2 - 1;
        float y = green / 255 * 2 - 1;

        return new PVector( x, y );

    }

    protected color getColorAt(
        PVector position
    ) {

        if (
            this.on == false
            || this.map == null
        ) {
            return 0;
        }

        if (
            position.x < 0
            || position.x > this.map.width
            || position.y < 0
            || position.y > this.map.height
        ) {
        return 0;
        }

        int index = (int) position.x + (this.map.width * (int) position.y);

        if ( index < this.map.width * this.map.height ) {
            color result = this.map.pixels[ (int) index ];
            return result;
        }
        return 0;
    }

}