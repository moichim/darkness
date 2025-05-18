import java.util.function.Consumer;

abstract class EffectAbstract {

    protected int tickActive = 0;
    protected int tickRunning = 0;
    protected int delay = 0;
    protected int duration = 0;
    protected boolean refreshesItself = false;

    protected boolean active = true;
    protected boolean running = false;

    protected ToolAbstract tool;

    protected Consumer<ToolAbstract> removeCallback;
    protected Consumer<EffectAbstract> refreshCallback;

    protected float impact = 1;

    EffectAbstract(
        ToolAbstract tool
    ) {
        this.tool = tool;
    }

    public void setDelay( int delay ) {
        this.delay = (int) max( delay, 0 );
    }

    public void setDuration( int duration ) {
        this.duration = (int) max( duration, 0 );
    }

    public void setCallback( Consumer<ToolAbstract> callback ) {
        this.removeCallback = callback;
    }

    public void setRepeat(
        Consumer<EffectAbstract> callback
    ) {
        this.refreshesItself = true;
        this.refreshCallback = callback;
    }

    public void setImpact( float value ) {
        this.impact = constrain( value, 0, 1 );
    }

    public float getImpact() {
        return this.impact;
    }

    public ToolAbstract getTool() {
        return this.tool;
    }


    public void activate() {
        if ( this.active == false ) {
            this.active = true;
            this.onActivate();
        }
    }
    protected abstract void onActivate();

    public void update() {

        // Update only when the effect is active
        if ( this.active == true ) {

            // If the effect is not triggered already, do nothing
            if ( this.delay > 0 && this.tickActive < this.delay ) {
                this.tickActive += 1;
                return;
            }

            // Execute the effect
            this.performUpdate();

            // The duration
            if ( this.duration > 0 && this.tickRunning >= this.duration ) {
                this.performDeactivateOrRefresh();
            } else {
                this.tickRunning += 1;
            }

        }


    }

    /** Internal method that performs the entire update and its logic */
    private void performUpdate() {
        if ( this.running == false ) {
            this.running = true;
            println( "Starting effect", this, "on", this.tool );
            this.onStart( this.duration );
        }
        this.onUpdate( this.tickActive, this.duration );
        this.tickActive += 1;
    }

    private void performDeactivateOrRefresh() {

        this.tickActive = 0;
        this.tickRunning = 0;
        this.running = false;
        this.active = false;

        if ( this.refreshesItself == true ) {
            if ( this.refreshCallback != null ) {
                this.refreshCallback.accept( this );
            }

        } else {
            this.deactivate();
            if ( this.removeCallback != null ) {
                this.removeCallback.accept( this.tool );
            }
        }

    }

    /** This method runs every time the effect is running */
    protected abstract void onUpdate( int effectTick, int effectDuration );
    
    /** This method runs only when this effect starts after the delay */
    protected abstract void onStart( int effectDuration );



    public void deactivate() {
        if ( this.active == true ) {
            this.active = false;
            this.running = false;
            this.tickActive = 0;
            this.tickRunning = 0;
            println( "deactivating effect", this, "on", this.tool );
            this.onDeactivate();
        }
    }
    protected abstract void onDeactivate();


    public void beforeRemoved() {
        println( "callling callback", this.removeCallback );
        if ( this.removeCallback != null ) {
            this.removeCallback.accept( this.tool );
        }
    }

    public abstract void onJump();

}