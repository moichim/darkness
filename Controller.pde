


class Controller {

    Trackers trackers;
    Particles particles;
    Capture video;
    Mapping mapping;

    FloatControl distThreshold = new FloatControl( "Tracker Dist Threshold", 50 );

    Controller(
        Capture video,
        int outputWidth,
        int outputHeight
    ) {

        this.video = video;

        this.trackers = new Trackers( video );
        this.particles = new Particles();

        this.mapping = new Mapping(
            new PVector( video.width, video.height ),
            new PVector( outputWidth, outputHeight )
        );
    }



}