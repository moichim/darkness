class EffectToggleCirclesOnJump extends EffectAbstract {

    protected int numJumps = 0;
    protected int counter = 0;
    int every;
    int minCircles;
    int maxCircles;

    EffectToggleCirclesOnJump(
        ToolAbstract tool,
        int every,
        int minCircles,
        int maxCircles
    ) {
        super( tool );
        this.every = every;
        this.minCircles = minCircles;
        this.maxCircles = maxCircles;
        this.setImpact( this.tool.circle().getImpact() );
    }

    protected void onActivate() {}
    protected void onStart( int effectDuration ) {
        this.tool.circle().setImpact( this.getImpact() );
        this.tool.circle().on();
    }
    protected void onUpdate( int effectTick, int effectDuration ) {}
    protected void onDeactivate() {
        this.tool.circle().off();
    }

    public void onJump() {

        if ( this.counter == this.every ) {
            this.counter = 0;
            this.numJumps = this.numJumps >= 10 ? 0 : this.numJumps + 1;
            this.resetCircles();
        }
        else {
            this.counter += 1;
        }
        
    }

    protected void resetCircles() {

        int number = (int) round( random( this.minCircles, this.maxCircles ) );

        this.tool.circle().setNumber( number );

    }

}