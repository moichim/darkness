import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;

class RendererVideo extends RendererAbstract {

    protected String folder;

    protected boolean playing = false;

    protected boolean loop = false;

    protected int speed = 1;
    protected float alpha = 255;

    String file;

    Movie video;

    RendererVideo(
        Tracker tracker,
        Movie video
    ) {

        super( tracker );

        this.video = video;

    }

    void start() {
        if ( ! this.playing ) {
            this.playing = true;
            this.video.loop();
        }
    }

    void stop() {

        if ( this.playing ) {
            this.video.pause();
            this.video.jump(0);
        }

    }

    RendererVideo setLoop( boolean value ) {
        this.loop = value;
        return this;
    }

    RendererVideo setAlpha( float value ) {
        this.alpha = value;
        return this;
    }

    RendererVideo setSpeed( int value ) {
        this.speed = value;
        return this;
    }


    void updateInBlob( Blob blob ) {
    }

    void updateInTracker( Tracker tracker ) {}

    void drawInTracker() {


        // println( this.video, this.playing, this.video.available() );

        if ( this.playing == true && this.video.available()) {

            // println( "Video is available" );

            // this.video.read();

            // blendMode( SCREEN );
            // tint( this.tracker.emissionColor, 126 );
            image( this.video, 0, 0);
            blendMode( BLEND );
            // noTint();


        }

    }

    void drawInBlob( Blob blob ) {

    }

}