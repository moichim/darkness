class AbstractPoint extends PVector {

    int time;
    Mapping mapping;

    AbstractPoint( float x, float y, int time, Mapping mapping ) {
        super( x, y );
        this.time = time;
        this.mapping = mapping;
    }

    boolean isWithinDistance( float distance, float x, float y ) {
        return this.dist( new PVector(x, y) ) < distance;
    }


    PVector toNormalised() {
        return this.mapping.normalised( this );
        /*
        PVector normalised = this.mapping.normalised( this );
        return new AbstractPoint( normalised.x, normalised.y, this.time, this.mapping );
        */
    }

    PVector toIndex() {
        return this.mapping.index(  this );
        /*
        PVector index = this.mapping.index( this );
        return new AbstractPoint( index.x, index.y, this.time, this.mapping );
        */
    }

}