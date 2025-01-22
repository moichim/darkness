class Particles {

    Trackers trackers;

    ArrayList<AbstractParticle> points = new ArrayList<AbstractParticle>();

    int max = 200;

    Particles(
        Trackers trackers
    ) {
        this.trackers = trackers;
    }

    AbstractParticle emit(
        float x,
        float y,
        Tracker tracker,
        Blob blob
    ) {
        AbstractParticle item = new AbstractParticle(x,y,tracker, blob);
        this.points.add( item );

        if ( this.points.size() >= this.max ) {
            this.points.remove( 0 );
        }
        return item;
    }

    void remove(
        AbstractParticle particle
    ) {

        PVector position = particle.position;

        Blob nearestBlob = null;
        float nearestDiff = 0;
        for ( Blob blob : particle.tracker.blobs ) {

            if ( nearestBlob == null ) {
                nearestBlob = blob;

                nearestDiff = blob.getCenter().dist( particle.position );

            } else {

                float diff = blob.getCenter().dist( particle.position );

                if ( diff < nearestDiff ) {
                    nearestBlob = blob;
                    nearestDiff = diff;
                }

            }

        }

        if ( nearestBlob != null ) {
            particle.blob = nearestBlob;
        } else {
            this.points.remove( particle );   
        }
    }

    void update() {
        for ( AbstractParticle p : this.points ) {
            p.update();
        }
    }

    void draw() {
        for ( AbstractParticle p : this.points ) {
            p.draw();
        }
    }

}