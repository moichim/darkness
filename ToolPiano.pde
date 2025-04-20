class ToolPiano extends ToolAbstract {

    ToolPiano(
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
            "/piano",
            renderColor
        );

        // Configure the particle renderer

        RendererCircles circles = new RendererCircles(
            this,
            renderColor
        );
        this.addRenderer( circles );
        
    }

    public void onMutedOn() {}
    public void onMutedOff() {}

    public void onOneOn() {}
    public void onOneOff() {}

    public void onMultipleOn() {}
    public void onMultipleOff() {}

    public void onEventOn() {}
    public void onEventOff() {}

    protected void onUpdateTool() {
        // Update the tool here
    }

    protected void onRefresh() {}

}