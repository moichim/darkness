abstract class ToolAbstract extends Tracker {

    protected int phaseTick = 0;
    protected int refreshPhaseAfter = 0;
    protected boolean doRefreshPhase = false;
    protected boolean refreshToggle = false;

    public float jumpAmount = 5f;

    ToolAbstract(
        color trackColor,
        float hue,
        float saturation,
        float brightness,
        String instrument,
        color renderColor
    ) {
        super(
            (int) red( trackColor ), 
            (int) green(trackColor ), 
            (int) blue( trackColor ),
            hue,
            saturation,
            brightness,
            instrument
        );

        this.particleRenderer = new RendererParticles( this, renderColor );
        this.addRenderer( this.particleRenderer );

        // Configure the following movement
        this.follow().setImpact( 0.3 );
        this.follow().on();

        this.approach().setImpact( 0.2 );
        this.approach().on();

        this.random().setImpact( 0.7 );
        this.random().on();
        this.random().setNoiseStep( 0.3 );

        this.jump().on();
        this.jump().setImpact( 1 );
    }

    protected Story getStory() {
        return story;
    }

    protected StoryPhase getPhase() {
        return this.getStory().phase;
    }

    public DriverRandom random() {
        return this.particleRenderer.driverRandom;
    }

    public DriverFollow follow() {
        return this.particleRenderer.driverFollow;
    } 
    public DriverJump jump() {
        return this.particleRenderer.driverJump;
    }
    public DriverApproach approach() {
        return this.particleRenderer.driverApproach;
    }
    public DriverColor colors() {
        return this.particleRenderer.driverColor;
    }
    public OrderColumns columns() {
        return this.particleRenderer.orderColumns;
    }
    public OrderCircle circle() {
        return this.particleRenderer.orderCircle;
    }
    public OrderRound round() {
        return this.particleRenderer.orderRound;
    }
    public OrderNormal normal() {
        return this.particleRenderer.orderNormal;
    }

    public abstract void onMutedOn();
    public abstract void onMutedOff();

    public abstract void onOneOn();
    public abstract void onOneOff();

    public abstract void onMultipleOn();
    public abstract void onMultipleOff();

    public abstract void onEventOn();
    public abstract void onEventOff();

    public void mutedOn() {
        this.phaseTick = 0;
        this.onMutedOn();
    }
    public void mutedOff() {
        this.phaseTick = 0;
        this.onMutedOff();
    }

    public void oneOn() {
        this.phaseTick = 0;
        this.onOneOn();
    }
    public void oneOff() {
        this.phaseTick = 0;
        this.onOneOff();
    }

    public void multipleOn() {
        this.phaseTick = 0;
        this.onMultipleOn();
    }
    public void multipleOff() {
        this.phaseTick = 0;
        this.onMultipleOff();
    }

    public void eventOn() {
        this.phaseTick = 0;
        this.onEventOn();
    }
    public void eventOff() {
        this.phaseTick = 0;
        this.onEventOff();
    }

    protected abstract void onUpdateTool();

    protected abstract void onRefresh();

    protected void updateTool() {
        this.phaseTick++;
        this.onUpdateTool();

        if ( this.refreshPhaseAfter > 0 && this.doRefreshPhase == true) {

            if ( this.phaseTick % this.refreshPhaseAfter == 0 ) {

                this.phaseTick = 0;
                switch ( this.getPhase().current.code() ) {
                    case 0:
                        this.mutedOn();
                        break;
                    case 1:
                        this.oneOn();
                        break;
                    case 2: 
                        this.multipleOn();
                        break;
                    case 3:
                        this.eventOn();
                        break;
                }
                this.refreshToggle = !this.refreshToggle;
                this.onRefresh();

            }

        }

    }

}