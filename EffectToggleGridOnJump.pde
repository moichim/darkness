enum TOGGLE_GRID {
    COLUMNS,
    ROWS,
    RANDOM,
    TOGGLE
}

class EffectToggleGridOnJump extends EffectAbstract {

    protected int numJumps = 0;
    protected int counter = 0;
    int every;
    int minColumns;
    int maxColumns;
    TOGGLE_GRID mode;

    EffectToggleGridOnJump(
        ToolAbstract tool,
        int every,
        int minColumns,
        int maxColumns,
        TOGGLE_GRID mode
    ) {
        super( tool );
        this.every = every;
        this.minColumns = minColumns;
        this.maxColumns = maxColumns;
        this.mode = mode;
    }

    protected void onActivate() {}
    protected void onStart( int effectDuration ) {
        this.tool.columns().on();
        this.tool.columns().setImpact( this.getImpact() );
    }
    protected void onUpdate( int effectTick, int effectDuration ) {}
    protected void onDeactivate() {
        this.tool.columns().off();
    }

    public void setEvery( int value ) {
        this.every = value;
    }

    public void onJump() {

        if ( this.counter == this.every - 1 ) {
            this.counter = 0;
            this.numJumps = this.numJumps >= 10 ? 0 : this.numJumps + 1;
            this.resetColumns();
        }
        else {
            this.counter += 1;
        }
        
    }

    protected void resetColumns() {

        int number = (int) round( random( this.minColumns, this.maxColumns ) );

        boolean isVertical = this.getIsVertical();

        this.tool.columns().setNumber( number );
        this.tool.columns().setOrientation( isVertical );

    }

    protected boolean getIsVertical() {

        switch ( this.mode ) {
            case COLUMNS:
                return true;
            case ROWS:
                return false;
            case RANDOM:
                return random(1.0) > 0.5;
            case TOGGLE:
            default:
                return this.numJumps % 2 == 0;
        }

    }

}