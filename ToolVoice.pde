class ToolVoice extends ToolAbstract {

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
        this.addRenderer( circles );
        this.jump().setImpact( 0.3 );
        
    }

    public static final String EFFECT_COLOR = "one_effect_color";
    public static final String EFFECT_GRID = "one_effect_grid";

    public void onMutedOn() {}
    public void onMutedOff() {}

    public void onOneOn() {
        this.colors().setThreshold( 100 );

        EffectRaiseRandomColor randomColor = new EffectRaiseRandomColor(
            this,
            150,
            500
        );

        this.addEffect( ToolKytar.EFFECT_COLOR, randomColor );

        this.refreshPhaseAfter = 0;
    }

    public void onOneOff() {
        // Cleanup after color changes
        this.colors().setThreshold( 100 );
        this.removeEffect( ToolKytar.EFFECT_COLOR );
        this.colors().resetRendererColor();
    }

    public void onMultipleOn() {
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