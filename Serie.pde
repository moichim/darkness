class Serie {

    ArrayList<Point> points = new ArrayList<Point>();

    float minDistance = 0;
    float maxDistance = 50;

    Mapping mapping;
    Tracker tracker;
    int id;

    Serie(
        int id,
        Tracker tracker,
        Mapping mapping
    ) {
        this.id = id;
        this.mapping = mapping;
        this.tracker = tracker;
    }

    Serie setMinDistance( float value ) {
        this.minDistance = value;
        return this;
    }

    Serie setMaxDistance( float value ) {
        this.maxDistance = value;
        return this;
    }

    Point getLastPoint() {

        if ( this.points.size() == 0 ) {
            return null;
        } else {
            return this.points.get( this.points.size() - 1 );
        }

    }

    Serie addPoint(
        float x,
        float y,
        int time
    ) {

        if ( this.mapping.isWithinInput( x, y ) == false ) {
            return this;
        }

        Point lastPoint = this.getLastPoint();

        if ( lastPoint == null ) {
            this.points.add( new Point( x, y, time, this.mapping ) );
        } else {

            if ( !lastPoint.isWithinDistance( this.minDistance, x, y ) && lastPoint.isWithinDistance( this.maxDistance, x, y ) ) {
                this.points.add( new Point( x, y, time, this.mapping ) );
            } else {

            }

        }

        return this;

    }

    void drawInput() {

        for ( int i = 0; i < this.points.size(); i++ ) {
            Point point = this.points.get( i );
            point.drawInput();
        }

        PVector center = this.getCenter();

        fill( this.tracker.trackColor );
        ellipse( center.x, center.y, 20, 20);

    }

    void drawOutput() {

        for (  int i = 0; i < this.points.size() - 1; i++ ) {
            Point point = this.points.get( i );
            Point nextPoint = this.points.get( i + 1 );

            point.drawOutput( nextPoint, this.tracker.trackColor );
        }

    }



    public int getStart() {
        if ( this.points.size() == 0 ) {
            return 0;
        }
        return this.points.get(0).time;
    }

    public int getEnd() {
        if ( this.points.size() == 0 ) {
            return 0;
        }
        return this.points.get( this.points.size() - 1 ).time;
    }


    public int getDuration() {

        return this.getEnd() - this.getStart();

    }


    public float getLength() {

        float length = 0;

        for ( int i = 0; i < this.points.size() - 1; i++ ) {
            Point point = this.points.get( i );
            Point nextPoint = this.points.get( i + 1 );
            length += point.dist( nextPoint );
        }

        return length;

    }


    public PVector getCenter() {

        float x = 0;
        float y = 0;

        for ( Point point : this.points ) {
            x += point.x;
            y += point.y;
        }

        return new PVector( x / this.points.size(), y / this.points.size() );

    }

    public int getSize() {
        return this.points.size();
    }


    

}