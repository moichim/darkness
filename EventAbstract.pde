abstract class EventAbstract {

    protected Story story;

    public abstract int getDuration();

    public EventAbstract(
        Story story
    ) {
        this.story = story;
        this.onInit();
    }

    public abstract int getCode();

    public abstract void onInit();

    public abstract void onActivate();

    public abstract void onDeactivate();

    protected void renderStart( color col ) {
        push();
        translate(20, 100);
        fill( col );
        // ellipse( 0, 0, 20, 20 );
        pop();
    }

    protected void renderEnd( color col ) {
        push();
        translate(20, 100);
        fill( col );
        // rect( 100, 0, 20, 20 );
        pop();
    }

}