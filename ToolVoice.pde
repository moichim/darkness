class ToolVoice extends ToolAbstract {

    PImage monkey;
    PImage monkeys;

    public float jumpAmount = 1f;

    ToolVoice(
        color trackColor,
        float hue,
        float saturation,
        float brightness,
        color renderColor
    ) {
        super(
            trackColor,
            hue,
            saturation,
            brightness,
            "/voice",
            renderColor
        );

        RendererCircles circles = new RendererCircles(
            this,
            renderColor
        );
        // this.addRenderer( circles );

        this.monkey = loadImage("normals/countryside_raw.png");
        this.monkeys = loadImage( "normals/monkeys.png" );
        this.jump().setImpact( 0.3 );
        
    }

    public void onMutedOn() {}
    public void onMutedOff() {}

    public void onOneOn() {
        this.colors().setThreshold( 100 );

        this.normal().setMap( this.monkeys );
        this.normal().on();
        this.normal().setImpact(1);

        this.refreshPhaseAfter = 0;
    }

    public void onOneOff() {
        this.colors().setThreshold( 100 );
        this.normal().off();
    }

    public void onMultipleOn() {

        this.normal().setMap( this.monkey );
        this.normal().on();

    }
    public void onMultipleOff() {

        this.normal().off();
        
    }

    public void onEventOn() {

        this.normal().setMap( this.monkey );
        this.normal().on();


    }
    public void onEventOff() {
         this.normal().off();
    }

    protected void onUpdateTool() {

        if ( this.getPhase().current.key() == PHASE.ONE ) {

            float index = constrain( this.phaseTick, 90, 200 );

            float threshold = map( index, 90, 200, 100, 150 );

            this.colors().setThreshold( threshold);

        }

        if ( this.getPhase().current.key() == PHASE.MULTIPLE ) {

            float index = constrain( this.phaseTick, 90, 200 );

            float threshold = map( index, 90, 200, 100, 150 );

            this.colors().setThreshold( threshold);

        }

    }

    protected void onRefresh() {}

}