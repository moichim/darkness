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

    PVector output( PVector input ) {
        return new PVector(
            map( input.x, 0, this.input.x, 0, this.output.x ),
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