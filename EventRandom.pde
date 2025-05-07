class EventRandom extends EventAbstract {

    public int getDuration() {
        return 358;
    }

    EventRandom(
        Story story
    ) {
        super(story);
    }

    public void onInit() {

    }

    public void onActivate() {

        this.renderStart( color(0,0,255) );

    }

    public void onDeactivate() {

        this.renderEnd( color(0,0,255) );

    }

}