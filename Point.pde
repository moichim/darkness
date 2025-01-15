class Point extends AbstractPoint {

    Point( float x, float y, int time, Mapping mapping ) {
        super( x, y, time, mapping );
    }

    void drawInput() {

        PVector output = this.mapping.output( this );

        noStroke();
        fill( 0 );
        ellipse( this.x, this.y, 10, 10 );

    }

    void drawOutput(
        Point next,
        color col
    ) {
        
        PVector output = this.mapping.output( this );

        noStroke();
        fill( col );
        ellipse( output.x, output.y, 10, 10 );
        text( this.time, output.x, output.y + 20 );

        if ( next != null ) {
            PVector nextOutput = this.mapping.output( next );
            stroke( col );
            noFill();
            line( output.x, output.y, nextOutput.x, nextOutput.y );

        }
        
    }

}