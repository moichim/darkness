import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;

class RendererSequence extends RendererAbstract {

    protected String folder;

    ArrayList<PImage> images = new ArrayList<PImage>();

    protected boolean playing = false;
    protected int tick = 0;

    protected boolean loop = false;

    PImage current;

    RendererSequence(
        Tracker tracker,
        String folder
    ) {

        super( tracker );
        this.folder = folder;

        this.loadFolder();

    }

    void start() {
        if ( ! this.playing ) {
            this.playing = true;
            this.tick = 0;
        }
    }

    void stop() {

        if ( this.playing ) {
            this.playing = false;
            this.tick = 0;
        }

    }

    RendererSequence setLoop( boolean value ) {
        this.loop = value;
        return this;
    }

    void loadFolder() {

        File dir = new File( dataPath( this.folder ) );
        File[] files = dir.listFiles( (d, name) -> name.endsWith(".png") );

        Arrays.sort( files, (f1, f2) -> f1.getName().compareTo(f2.getName()) );

        for ( File f: files ) {

            if ( f.getName().toLowerCase().endsWith(".png") ) {

                this.images.add( loadImage( f.getAbsolutePath() ) );

            }

        }

        if ( this.images.size() > 0 ) {
            this.current = this.images.get(0);
        }

    }

    void updateInBlob( Blob blob ) {
    }

    void updateInTracker( Tracker tracker ) {

        // println( this.images.size() );

        if ( this.playing == true ) {

            println( this.images.size(), this.tick, this.current.width, this.current.height );

            // Check if the end is reached
            if ( this.tick > this.images.size() - 1) {
                if ( this.loop ) {
                    this.tick = 0;
                } else {
                    this.stop();
                    return;
                }
            } 
            // Play the current image
            else {

                this.current = this.images.get( this.tick );

                this.tick++;

                

            }

        }

    }

    void drawInTracker() {


        // println( this.images.size() );

        if ( this.playing == true ) {

            println( this.images.size(), this.tick, this.current.width, this.current.height );

            // Check if the end is reached
            if ( this.tick > this.images.size() - 1) {
                if ( this.loop ) {
                    this.tick = 0;
                } else {
                    this.stop();
                    return;
                }
            } 
            // Play the current image
            else {

                this.current = this.images.get( this.tick );

                this.tick++;       

            }

        }

        if ( this.current != null && this.playing == true ) {
            blendMode( REPLACE );
            tint( this.tracker.emissionColor );
            image( this.current, 0, 0);
            blendMode( BLEND );
        }
    }

    void drawInBlob( Blob blob ) {

    }

}