import java.util.function.Function;
import java.io.File;


class ImageMap extends HashMap<Integer, ArrayList<PImage>> {

    Function<PImage,Integer> sorter;

    ImageMap(
        Function<PImage,Integer> sorter
    ) {
        super();
        this.sorter = sorter;
    }

    void register( PImage img ) {
        int key = this.sorter.apply( img );
        this.getOrCreateList( key ).add( img );
    }

    ArrayList<PImage> getOrCreateList( int width ) {
        if ( this.containsKey( width ) ) {
            return this.get( width );
        }
        ArrayList<PImage> item = new ArrayList<PImage>();
        this.put( width, item );
        return item;
    }

    PImage getClosestSmaller( int width ) {
        int closestWidth = 99999999;
        ArrayList<PImage> array = new ArrayList<PImage>();
        for ( Integer key : this.keySet() ) {
            if ( key < closestWidth ) {
                closestWidth = key;
                array = this.get(key);
            }
        }
        return this.selectRandom( array );
    }

    PImage getFromRange( int from, int to ) {
        ArrayList<PImage> subset = new ArrayList<PImage>();
        for ( Integer key : this.keySet() ) {
            if ( key >= from && key <= to ) {
                subset.addAll( this.get( key ) );
            }
        }

        return this.selectRandom( subset );
    }



    PImage selectRandom( ArrayList<PImage> array ) {
        int key = (int) round( random( 0, array.size() - 1 ) );
        return array.get( key );
    }

}


class SampleBank {

    PApplet app;

    ImageMap hundreds;
    ImageMap exact;

    SampleBank() {
        this.hundreds = new ImageMap( img -> (int) round( img.width / 100 ) * 100 );
        this.exact = new ImageMap( img -> img.width );
    }

    SampleBank load(
        String path
    ) {

        PImage img = loadImage( path );
        
        this.hundreds.register( img );
        this.exact.register( img );

        return this;

    }

}

class FolderBank {

    String path;

    ImageMap exact;

    FolderBank(
        String path
    ) {
        this.path = path;
        this.exact = new ImageMap( img -> img.width );
    }

    void load() {

        String p = sketchPath( "data/" + this.path );

        File actual = new File(p);
        for( File f : actual.listFiles()){

            if ( f.getName().endsWith("png") ) {
                String fp = p + "/" + f.getName();

                PImage img = loadImage( fp );

                this.exact.register( img );

            }

            
        }

    }

}