class EventShort extends EventAbstract {

    public int getDuration() {
        return 100;
    }

    EventShort(
        Story story
    ) {
        super(story);
    }

    public int getCode() {
        return 4;
    }

    public void onInit() {
        
    }

    public void onActivate() {

        this.renderStart( color(255) );
        this.story.sendEventStart( this.getCode() );

    }

    public void onDeactivate() {

        this.renderEnd( color(255) );
        this.story.sendEventEnd();

    }

}