class Tracker {

  ArrayList<Blob> blobs = new ArrayList<Blob>();

  int blobCounter = 0;

  int maxLife = 200;

  color trackColor;
  float threshold = 40;
  float distThreshold = 50;

  Tracker(
    Capture video
    ) {
  }


  processPixel( color currentColor ) {

    float r1 = red(currentColor);
    float g1 = green(currentColor);
    float b1 = blue(currentColor);

    float r2 = red(this.trackColor);
    float g2 = green(this.trackColor);
    float b2 = blue(this.trackColor);

    float d = distSq(r1, g1, b1, r2, g2, b2);

    if ( d < this.threshold*this.threshold ) {
      boolean found = false;
      for (Blob b : currentBlobs) {
        if (b.isNear(x, y)) {
          b.add(x, y);
          found = true;
          break;
        }
      }
      if ( !found ) {
        Blob b = new Blob(x, y);
        currentBlobs.add(b);
      }
    }
  }

  postPoxelsProcessed() {

    this.reduceBlobsBySize();

  }

  protected reduceBlobsBySize() {

    for (int i = this.blobs.size()-1; i >= 0; i--) {
      if (this.blobs.get(i).size() < 500) {
        this.blobs.remove(i);
      }
    }
  }
}
