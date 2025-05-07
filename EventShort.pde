class EventShort extends EventAbstract {

    public int getDuration() {
        return 100;
    }

    EventShort(
        Story story
    ) {
        super(story);
    }

    public void onInit() {
        
    }

    public void onActivate() {

        this.renderStart( color(255) );

    }

    public void onDeactivate() {

        this.renderEnd( color(255) );

    }

}