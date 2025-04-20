class RendererFolderBank extends RendererAbstract {

    FolderBank bank;

    RendererFolderBank(
        Tracker tracker,
        FolderBank bank
    ) {
        super( tracker );
        this.bank = bank;
    }

    void updateInTracker( Tracker tracker ) {}

    void drawInTracker() {}

    void updateInBlob( Blob blob ) {}

    void drawInBlob( Blob blob ) {

        push();

        translate( blob.center.x, blob.center.y );

        rotate( random(0, 2*PI) );

        float sc = max(50, blob.width);

        PImage img = this.bank.exact.getFromRange( 0, 1200 );

        blendMode( LIGHTEST );

        imageMode( CENTER );

        image( img, 0, 0, sc, sc );


        blendMode( BLEND );

        pop();

    }


}