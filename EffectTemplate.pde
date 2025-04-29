class EffectTemplate extends EffectAbstract {

    EffectTemplate(
        ToolAbstract tool
    ) {
        super(tool);
    }

    protected void onActivate() {}
    protected void onStart( int effectDuration ) {}
    protected void onUpdate( int effectTick, int effectDuration ) {}
    protected void onDeactivate() {}
    public void onJump() {}

}