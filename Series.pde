class Series {

    ArrayList<Serie> series = new ArrayList<Serie>();
    HashMap<Integer, Serie> seriesById = new HashMap<Integer, Serie>();

    Mapping mapping;

    boolean recording = false;

    Series(
        Mapping mapping
    ) {
        this.mapping = mapping;
    }

    protected boolean pointIsWithinInput( float x, float y ) {
        return x < this.mapping.input.x && y < this.mapping.input.y;
    }

    protected Serie startSerie(
        int id,
        Tracker tracker,
        float x,
        float y,
        int time 
    ) {

        if ( ! this.mapping.isWithinInput( x, y ) ) {
            return null;
        }

        Serie serie = new Serie( id, tracker, this.mapping );
        serie.addPoint( x, y, time );
        this.series.add( serie );
        this.seriesById.put( id, serie );
        return serie;

    }

    protected Serie getSerie( int id ) {
        return this.seriesById.get( id );
    }

    void addOrUpdateSerie(
        int id,
        Tracker tracker,
        float x,
        float y,
        int time
    ) {

        Serie serie = this.getSerie( id );

        if ( serie == null ) {
            serie = this.startSerie( id, tracker, x, y, time );
        } else {
            serie.addPoint( x, y, time );
        }

    }

    void drawInput() {

        for ( Serie serie : this.series ) {
            serie.drawInput();
        }

    }

    void drawOutput() {

        for ( Serie serie : this.series ) {
            serie.drawOutput();
        }

    }

    Series flush() {
        this.series.clear();
        this.seriesById.clear();
        return this;
    }

    void recordingStart() {
        this.recording = true;
    }

    void recordingEnd() {
        this.recording = false;
    }



}