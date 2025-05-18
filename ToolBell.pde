class ToolBell extends ToolAbstract {

    ToolBell(
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
            "/bell",
            renderColor
        );

        FolderBank bank = new FolderBank("multicolor");
        bank.load();

        this.folderBankRenderer = new RendererFolderBank(
            this,
            bank
        );
        this.addRenderer( this.folderBankRenderer );

        // Configure the particle renderer
        
    }

    public static final String EFFECT_COLOR = "one_effect_color";
    public static final String EFFECT_GRID = "one_effect_grid";

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

        // this.circle().on();
        // this.circle().configure( this.getRoundedInt( this.getRandomFloat(4.0, 10) ), 20 );
        // this.circle().setImpact(0.5);

        this.random().setImpact( 0.9 );
        this.random().setSpread(4);

        // this.refreshPhaseAfter = (int) this.getRandomFloat( 50, 150 );
        // this.doRefreshPhase = true;

        EffectToggleCirclesOnJump circleEffect = new EffectToggleCirclesOnJump(this, 5, 3, 20 );

        this.circle().setImpact(0.9);
        circleEffect.setDelay( (int) this.getRandomInt( 20, 100 ) );
        circleEffect.setDuration( (int) this.getRandomInt(300, 500) );
        circleEffect.setImpact( 0.9 );
        circleEffect.activate();

        circleEffect.setRepeat( item -> {
            println("Circle refreshes");
            item.setDelay( (int) this.getRandomInt( 20, 100 ) );
            item.setDuration( (int) this.getRandomInt( 300, 1000 ) );
            item.getTool().circle().off();
            item.activate();
        } );

        this.addEffect( ToolBell.EFFECT_GRID, circleEffect );

    }
    public void onMultipleOff() {
        this.circle().off();
        this.random().setSpread(8);
        this.random().setImpact(0.7);
        this.refreshPhaseAfter = 0;
        this.doRefreshPhase = false;
        this.removeEffect( ToolBell.EFFECT_GRID );
    }

    public void onEventOn() {}
    public void onEventOff() {}

    protected void onUpdateTool() {

    }

    protected void onRefresh() {}

}