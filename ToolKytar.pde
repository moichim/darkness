class ToolKytar extends ToolAbstract {

    PImage monkey;

    ToolKytar(
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
            "/kytar",
            renderColor
        );

        RendererCircles circles = new RendererCircles(
            this,
            renderColor
        );
        this.addRenderer( circles );
        this.monkey = loadImage("normals/countryside_raw.png");
        
    }

    public void onMutedOn() {}
    public void onMutedOff() {}

    public void onOneOn() {
        this.colors().setThreshold( 100 );

        this.refreshPhaseAfter = 0;
    }

    public void onOneOff() {
        this.colors().setThreshold( 100 );
    }

    public void onMultipleOn() {

        this.columns().on();
        this.columns().setNumber( this.getRoundedInt( this.getRandomFloat(4.0, 20) ) );
        this.columns().setOrientation( this.refreshToggle );
        this.columns().setImpact(0.5);

        this.random().setImpact( 0.9 );
        this.random().setSpread(4);

        this.refreshPhaseAfter = (int) this.getRandomFloat( 10, 70 );
        this.doRefreshPhase = true;

    }
    public void onMultipleOff() {
        this.columns().off();
        this.random().setSpread(8);
        this.random().setImpact(0.7);
        this.refreshPhaseAfter = 0;
        this.doRefreshPhase = false;
    }

    public void onEventOn() {
        this.jump().setImpact( 0.3 );
        this.normal().setImpact(1);
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