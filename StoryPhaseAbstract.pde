import java.util.function.Consumer;

abstract class StoryPhaseAbstract {

    abstract PHASE key();

    abstract int code();

    protected Story getStory() {
        return story;
    }

    void activate() {

        if ( this.getStory().phase.getCurrentPhase().code() != this.code() ) {
            this.onActivate();
            println( "activating story phase", this.key() );
        }

    }

    abstract void onActivate();

    abstract void execute( int ticks );

    void end() {

        if ( this.getStory().phase.getCurrentPhase().code() == this.code() ) {
            this.onEnd();
            println( "deactivating story phase", this.key() );
        }

    }

    abstract void onEnd();

}