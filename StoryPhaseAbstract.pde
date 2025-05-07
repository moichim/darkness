import java.util.function.Consumer;

abstract class StoryPhaseAbstract {

    protected Story story;

    abstract PHASE key();

    abstract int code();

    protected Story getStory() {
        return this.story;
    }

    StoryPhaseAbstract(
        Story story
    ) {
        this.story = story;
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