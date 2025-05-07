class EffectSetColorOnJump extends EffectAbstract {

    ArrayList<Integer> sequence = new ArrayList<Integer>();
    int pointer = 0;

    EffectSetColorOnJump(
        ToolAbstract tool
    ) {
        super( tool );
    }

    public EffectSetColorOnJump addStep( color value ) {
        this.sequence.add( value );
        return this;
    }

    protected void onActivate() {}
    protected void onStart( int effectDuration ) {}
    protected void onUpdate( int effectTick, int effectDuration ) {}
    protected void onDeactivate() {}

    public void onJump() {
        color newColor = this.getColorAndShuffle();
        this.tool.colors().setRendererColor( newColor );
    }

    protected color getColorAndShuffle() {
        if ( this.sequence.size() > 0 ) {

            color next = this.sequence.get( 0 );
            this.sequence.remove(0);
            this.sequence.add( next );
            return next;

        }

        return this.tool.colors().generateRgbDeviation( this.tool.colors().getRenderColor(), 100 );
    }

}