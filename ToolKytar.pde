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

    public void onMutedOn() {
    }
    public void onMutedOff() {}

    public static final String EFFECT_COLOR = "one_effect_color";
    public static final String EFFECT_GRID = "one_effect_grid";

    public void onOneOn() {

        // Rise the random colors

        this.colors().setThreshold( 80 );

        EffectRaiseRandomColor randomColor = new EffectRaiseRandomColor(
            this,
            150,
            500
        );

        this.addEffect( ToolKytar.EFFECT_COLOR, randomColor );


        // Show dense grid for sort time in long intervals
        EffectToggleGridOnJump toggleGrid = new EffectToggleGridOnJump(
            this,
            this.getRandomInt( 1, 3 ),
            15,
            25,
            TOGGLE_GRID.TOGGLE
        );

        toggleGrid.setDelay( this.getRandomInt( 500, 2000 ) );
        toggleGrid.setDuration( this.getRandomInt( 100, 300 ) );
        toggleGrid.setImpact( 0.6 );

        // Configure the repetition
        toggleGrid.setRepeat( item -> {
            item.setDelay( this.getRandomInt( 1000, 2000 ) );
            item.setDuration( this.getRandomInt( 100, 300 ) );
            item.getTool().columns().off();
        } );

        this.addEffect( ToolKytar.EFFECT_GRID, toggleGrid );
        

        this.refreshPhaseAfter = 0;
    }

    public void onOneOff() {
        // Cleanup after color changes
        this.colors().setThreshold( 80 );
        this.removeEffect( ToolKytar.EFFECT_COLOR );
        this.colors().resetRendererColor();
        // Cleanup after grid toggling
        this.removeEffect( ToolKytar.EFFECT_GRID );
        this.columns().off();
        this.columns().setImpact( 0.5 );
    }

    public void onMultipleOn() {

        this.colors().setThreshold(120);

        EffectRaiseRandomColor randomColor = new EffectRaiseRandomColor(
            this,
            110,
            500
        );

        this.addEffect( ToolKytar.EFFECT_COLOR, randomColor );


        // Show dense grid for sort time in long intervals
        EffectToggleGridOnJump toggleGrid = new EffectToggleGridOnJump(
            this,
            3,
            5,
            40,
            TOGGLE_GRID.TOGGLE
        );

        toggleGrid.setDelay( this.getRandomInt( 300, 1000 ) );
        toggleGrid.setDuration( this.getRandomInt( 300, 500 ) );
        toggleGrid.setImpact( 0.7 );

        // Configure the repetition
        toggleGrid.setRepeat( item -> {
            item.setDelay( this.getRandomInt( 300, 1000 ) );
            item.setDuration( this.getRandomInt( 300, 500 ) );
            item.getTool().columns().off();
        } );

        this.addEffect( ToolKytar.EFFECT_GRID, toggleGrid );

    }
    public void onMultipleOff() {
        // Cleanup after color changes
        this.colors().setThreshold( 80 );
        this.removeEffect( ToolKytar.EFFECT_COLOR );
        this.colors().resetRendererColor();
        // Cleanup after grid toggling
        this.removeEffect( ToolKytar.EFFECT_GRID );
        this.columns().off();
        this.columns().setImpact( 0.5 );
    }

    public void onEventOn() {

    }
    public void onEventOff() {
        
    }

    protected void onUpdateTool() {

    }

    protected void onRefresh() {}

}