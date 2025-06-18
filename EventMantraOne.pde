class EventMantraOne extends EventAbstract {

    public int getDuration() {
        return 13 * (int) round( frameRate );
    }

    PImage monkey;
    PImage flowers;

    EventMantraOne(
        Story story
    ) {
        super(story);
    }

    public int getCode() {
        return 1;
    }

    public void onInit() {
        this.monkey = loadImage("normals/relief_dekor.png");
        this.flowers = loadImage( "normals/flower_grid.png" );
    }

    public void onActivate() {

        this.story.sendEventStart( this.getCode() );

        this.story.kytar.flowers
            .setLoop(true)
            .setSpeed(2)
            .start();

        this.renderStart( color(255,0,0) );

        this.story.piano.circle().on();
        this.story.piano.circle().setImpact( 0.7 );
        this.story.piano.circle().setNumber( 12 );

        this.story.kytar.normal().on();
        this.story.kytar.normal().setImpact( 0.5 );
        this.story.kytar.normal().setMap( this.monkey );
        this.story.kytar.columns().on();
        this.story.kytar.columns().setImpact( 0.5 );

        this.story.bell.normal().on();
        this.story.bell.normal().setImpact( 0.9 );
        this.story.bell.normal().setMap( this.flowers );

        this.story.voice.normal().on();
        this.story.voice.normal().setImpact( 0.3 );
        this.story.voice.normal().setMap( this.monkey );

        this.story.pulse.normal().on();
        this.story.pulse.normal().setImpact( 0.7 );
        this.story.pulse.normal().setMap( this.monkey );

        this.story.angels.normal().on();
        this.story.angels.normal().setImpact( 0.7 );
        this.story.angels.normal().setMap( this.flowers );

    }

    public void onDeactivate() {

        this.story.kytar.flowers.stop();

        this.renderEnd( color(255,0,0) );

        this.story.voice.normal().off();
        this.story.piano.circle().off();
        this.story.kytar.normal().off();
        this.story.kytar.columns().off();
        this.story.bell.normal().off();
        this.story.pulse.normal().off();
        this.story.angels.normal().off();

        this.story.sendEventEnd();

    }

}