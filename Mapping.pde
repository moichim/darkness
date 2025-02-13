class Mapping {

    PVector input;
    PVector output;

    Mapping(
        PVector input,
        PVector output
    ) {
        this.input = input;
        this.output = output;
    }

    float xoutput( float value ) {
        return map( value, 0, this.input.x,  this.output.x,0 );
    }

    float youtput( float value ) {
        return map( value, 0, this.input.y, 0, this.output.y );
    }

    PVector output( PVector input ) {
        return new PVector(
            map( input.x, 0, this.input.x, this.output.x,0 ),
            map( input.y, 0, this.input.y, 0, this.output.y )
        );
    }

    PVector normalised( PVector input ) {
        return new PVector(
            map( input.x, 0, this.input.x, 0, 1 ),
            map( input.y, 0, this.input.y, 0, 1 )
        );
    }

    PVector index( PVector input ) {
        return new PVector(
            map( input.x, 0, this.input.x, -1, 1 ),
            map( input.y, 0, this.input.y, -1, 1 )
        );
    }

    boolean isWithinInput( float x, float y ) {
        return x < this.input.x && y < this.input.y;
    }

}