class EventMantraTwo extends EventAbstract {

    public int getDuration() {
        return 13 * (int) round( frameRate );
    }

    PImage monkey;

    EventMantraTwo(
        Story story
    ) {
        super(story);
    }

    public int getCode() {
        return 2;
    }

    public void onInit() {
        this.monkey = loadImage("normals/relief_dekor.png");
    }

    public void onActivate() {

        this.story.sendEventStart( this.getCode() );

        this.renderStart( color(255,0,0) );

        this.story.piano.normal().on();
        this.story.piano.normal().setImpact( 0.5 );
        this.story.piano.normal().setMap( this.monkey );

        this.story.kytar.normal().on();
        this.story.kytar.normal().setImpact( 0.1 );
        this.story.kytar.normal().setMap( this.monkey );

        this.story.bell.normal().on();
        this.story.bell.normal().setImpact( 0.9 );
        this.story.bell.normal().setMap( this.monkey );

        this.story.voice.normal().on();
        this.story.voice.normal().setImpact( 0.3 );
        this.story.voice.normal().setMap( this.monkey );

        this.story.pulse.normal().on();
        this.story.pulse.normal().setImpact( 0.7 );
        this.story.pulse.normal().setMap( this.monkey );

        this.story.angels.normal().on();
        this.story.angels.normal().setImpact( 1.0 );
        this.story.angels.normal().setMap( this.monkey );

    }

    public void onDeactivate() {

        this.renderEnd( color(255,0,0) );

        this.story.voice.normal().off();
        this.story.piano.normal().off();
        this.story.kytar.normal().off();
        this.story.bell.normal().off();
        this.story.pulse.normal().off();
        this.story.angels.normal().off();

        this.story.sendEventEnd();

    }

}