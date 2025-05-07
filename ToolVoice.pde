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


    }
    public void onEventOff() {
    }

    protected void onUpdateTool() {

    }

    protected void onRefresh() {}

}