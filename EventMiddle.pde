class EventMiddle extends EventAbstract {

    public int getDuration() {
        return 1000;
    }

    EventMiddle(
        Story story
    ) {
        super(story);
    }

    public int getCode() {
        return 2;
    }

    public void onInit() {

        
        
    }

    public void onActivate() {

        this.renderStart( color(0,255,0) );
        this.story.sendEventStart( this.getCode() );

    }

    public void onDeactivate() {

        this.renderEnd( color(0,255,0) );
        this.story.sendEventEnd();

    }

}