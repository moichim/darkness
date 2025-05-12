class EventLong extends EventAbstract {

    public int getDuration() {
        return 100000;
    }

    PImage monkey;

    EventLong(
        Story story
    ) {
        super(story);
    }

    public int getCode() {
        return 1;
    }

    public void onInit() {
        this.monkey = loadImage("normals/flower_central.png");
    }

    public void onActivate() {

        this.story.sendEventStart( this.getCode() );

        this.renderStart( color(255,0,0) );

        this.story.piano.normal().on();
        this.story.piano.normal().setImpact( 0.9 );
        this.story.piano.normal().setMap( this.monkey );

        this.story.kytar.normal().on();
        this.story.kytar.normal().setImpact( 0.9 );
        this.story.kytar.normal().setMap( this.monkey );

        this.story.bell.normal().on();
        this.story.bell.normal().setImpact( 0.7 );
        this.story.bell.normal().setMap( this.monkey );

        this.story.voice.normal().on();
        this.story.voice.normal().setImpact( 0.5 );
        this.story.voice.normal().setMap( this.monkey );

    }

    public void onDeactivate() {

        this.renderEnd( color(255,0,0) );

        this.story.voice.normal().off();
        this.story.piano.normal().off();
        this.story.kytar.normal().off();
        this.story.bell.normal().off();

        this.story.sendEventEnd();

    }

}