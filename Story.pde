import java.util.function.Consumer;


class Story {

    Controller controller;

    StoryPhase phase;

    ArrayList<ToolAbstract> tools = new ArrayList<ToolAbstract>();

    ToolPiano piano;
    ToolKytar kytar;
    ToolBell bell;
    ToolVoice voice;
    ToolPulse pulse;

    Story( Controller controller ) {
        this.controller = controller;
        this.phase = new StoryPhase(this);
    }

    /** Needs to be called in the setup function */
    public void start() {

        color pianoColor = color( 36, 168, 73 );
        this.piano = new ToolPiano(
            pianoColor,
            0.041,
            0.105,
            0.099,
            pianoColor
        );

        this.addTool( this.piano );


        color kytarColor = color( 18, 18, 219);
        this.kytar = new ToolKytar(
            kytarColor,
            0.110,
            0.506,
            0.448,
            kytarColor
        );

        this.addTool( this.kytar );

        color bellColor = color( 184, 12, 19);
        this.bell = new ToolBell(
            bellColor,
            0.110,
            0.506,
            0.448,
            bellColor
        );

        this.addTool( this.bell );

        color voiceColor = color( 168, 165, 44);
        color voiceRenderColor = color( 252, 244, 3 );
        this.voice = new ToolVoice(
            voiceColor,
            0.128,
            0.384,
            0.419,
            voiceRenderColor
        );

        this.addTool( this.voice );

        color pulseColor = color( 168, 165, 44);
        color pulseRenderColor = color( 151, 102, 207 );
        this.pulse = new ToolPulse(
            pulseColor,
            0.128,
            0.384,
            0.419,
            pulseRenderColor
        );

        this.addTool( this.pulse );


    }

    

    public void update() {

        this.phase.update();

    }


    void listenKeyboard() {}

    void listenOsc( OscMessage message ) {

        String address = message.addrPattern();

        this.forEveryTool( (tool) -> {
            if ( tool.instrument.equals( address ) ) {
                // println( "jumping", tool.instrument );
                tool.jump().doJump( tool.jumpAmount );
                tool.callOnEveryEffect( effect -> effect.onJump() );
            }
        });

    }



    protected void addTool( ToolAbstract tool ) {
        this.controller.trackers.add( tool );
        this.tools.add( tool );
    }

    public int getNumPlayingTools() {

        int num = 0;
        
        for ( ToolAbstract tool : this.tools ) {
            if ( tool.isPlaying == true ) {
                num++;
            }
        }

        return num;

    }

    public void forEveryTool( Consumer<ToolAbstract> callback ) {
        for ( ToolAbstract tool : this.tools ) {
            callback.accept( tool );
        }
    }

    public void sendEventStart( int code ) {
        OscMessage msg = this.controller.msg( "/event" );
        msg.add( true );
        msg.add( code );
        this.controller.send( msg );
    }

    public void sendEventEnd() {
        OscMessage msg = this.controller.msg( "/event" );
        msg.add( false );
        msg.add( -1 );
        this.controller.send( msg );
    }


}