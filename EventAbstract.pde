abstract class EventAbstract {

    protected Story story;

    public abstract int getDuration();

    public EventAbstract(
        Story story
    ) {
        this.story = story;
        this.onInit();
    }

    public abstract void onInit();

    public abstract void onActivate();

    public abstract void onDeactivate();

    protected void renderStart( color col ) {
        push();
        translate(100, 100);
        fill( col );
        ellipse( 0, 0, 100, 100 );
        pop();
    }

    protected void renderEnd( color col ) {
        push();
        translate(100, 100);
        fill( col );
        rect( 100, 0, 100, 100 );
        pop();
    }

}