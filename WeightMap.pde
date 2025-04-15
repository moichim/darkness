import java.util.Map;

class WeightMap {

  protected PImage image;

  int radius = 10;

  WeightMap(
    PImage image
    ) {
    this.image = image;
    this.image.loadPixels();
  }

  protected color getColorAt(
    PVector position
    ) {

    if (
      position.x < 0
      || position.x > this.image.width
      || position.y < 0
      || position.y > this.image.height
      ) {
      return 0;
    }

    int index = (int) position.x + (this.image.width * (int) position.y);

    if ( index < this.image.width * this.image.height ) {
        color result = this.image.pixels[ (int) index ];
        return result;
    }
    return 0;
  }

  public PVector getDirection(
    PVector position,
    PVector direction,
    color col
    ) {

    int minX = (int) max(0, position.x - this.radius);
    int maxX = (int) min(this.image.width, position.x + this.radius);

    int minY = (int) max(0, position.x - this.radius);
    int maxY = (int) min(this.image.height, position.y + this.radius);

    HashMap<PVector, Float> map = new HashMap<PVector, Float>();

    float brightness = brightness(col);

    // iterate vertical values
    for ( int y = minY; y <= maxY; y++ ) {

      PVector dirToPointTop =  position.copy().sub( minX, y ).normalize();
      color colTop = this.getColorAt( new PVector( minX, y) );
      map.put( dirToPointTop, brightness(colTop) );

      PVector dirToPointBottom = position.copy().sub( maxX, y ).normalize();
      color colBottom = this.getColorAt( new PVector( maxX, y) );
      map.put( dirToPointBottom, brightness(colBottom) );
    }

    // iterate horizontal values
    for ( int x = minX + 1; x < maxX; x++ ) {

      PVector dirToPointLeft = position.copy().sub( x, minY ).normalize();
      color colLeft = this.getColorAt( new PVector(x, minY) );
      map.put( dirToPointLeft, brightness(colLeft) );

      PVector dirToPointRight = position.copy().sub(x, maxY).normalize();
      color colRight = this.getColorAt( new PVector(x, maxY) );
      map.put( dirToPointRight, brightness( colRight ) );
    }

    float brightestValue = 100;
    PVector brightestAngle = null;

    // Get the brightest value
    for ( Map.Entry<PVector, Float> entry : map.entrySet() ) {
      if ( brightestValue == 100 || brightestAngle == null ) {
        brightestValue = entry.getValue();
        brightestAngle = entry.getKey();
      } 
      /*
      else {

        float diff = abs( brightness - entry.getValue() );

        if ( diff < brightestValue ) {
            brightestValue = entry.getValue();
            brightestAngle = entry.getKey();
        }

      }
      */
      
 
      else if ( 
        entry.getValue() > brightestValue
      ) {
        brightestValue = entry.getValue();
        brightestAngle = entry.getKey();
      }

    }

    return brightestAngle;
  }
}
