class EventRandom extends EventAbstract {

    public int getDuration() {
        return 358;
    }

    EventRandom(
        Story story
    ) {
        super(story);
    }

    public int getCode() {
        return 3;
    }

    public void onInit() {

    }

    public void onActivate() {

        this.renderStart( color(0,0,255) );
        this.story.sendEventStart( this.getCode() );

    }

    public void onDeactivate() {

        this.renderEnd( color(0,0,255) );
        this.story.sendEventEnd();

    }

}