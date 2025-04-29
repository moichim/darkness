class EffectRaiseRandomColor extends EffectAbstract {

    protected float targetThreshold;
    protected float originalThreshold;

    EffectRaiseRandomColor(
        ToolAbstract tool,
        float targetThreshold,
        int duration
    ) {
        super( tool );
        this.duration = duration;
        this.targetThreshold = abs( targetThreshold );
        this.originalThreshold = abs( this.tool.colors().getThreshold() );
    }

    protected void onActivate() {}
    protected void onStart( int effectDuration ) {}
    protected void onUpdate( int effectTick, int effectDuration ) {

        if ( this.duration <= 0 ) {
            return;
        } else {

            if ( this.tool.colors().getThreshold() == this.targetThreshold ) {
                this.deactivate();
            } else {

                float aspect = map( effectTick, 0, effectDuration, 0, 1 );
                float newThreshold = lerp( this.originalThreshold, this.targetThreshold, aspect );

                this.tool.colors().setThreshold( newThreshold );

            }

            
        }

    }
    protected void onDeactivate() {}

    public void onJump() {}

}