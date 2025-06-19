class RendererBlobImagePixels extends RendererAbstract {

    PImage[] images;
    int currentImageIndex = 0;
    float dotDiameter;

    RendererBlobImagePixels(Tracker tracker, String[] imagePaths, int pixelCount, float dotDiameter) {
        super(tracker);
        images = new PImage[imagePaths.length];
        for (int i = 0; i < imagePaths.length; i++) {
            images[i] = loadImage(imagePaths[i]);
        }
        this.dotDiameter = dotDiameter;
    }

    void shuffle() {
        int newIndex;
        do {
            newIndex = int(random(images.length));
        } while (newIndex == currentImageIndex && images.length > 1);
        currentImageIndex = newIndex;
    }

    void updateInTracker(Tracker tracker) {}

    void drawInTracker() {}

    void updateInBlob(Blob blob) {}

    void drawInBlob(Blob blob) {
        push();

        PImage img = images[currentImageIndex];

        float halfW = blob.width * 0.5;
        float halfH = blob.height * 0.5;

        float sceneW = width;
        float sceneH = height;

        float imgStartX = map(blob.center.x - halfW, 0, sceneW, 0, img.width);
        float imgEndX   = map(blob.center.x + halfW, 0, sceneW, 0, img.width);
        float imgStartY = map(blob.center.y - halfH, 0, sceneH, 0, img.height);
        float imgEndY   = map(blob.center.y + halfH, 0, sceneH, 0, img.height);

        float radius = min(halfW, halfH);

        for (float y = imgStartY; y < imgEndY; y += dotDiameter) {
            for (float x = imgStartX; x < imgEndX; x += dotDiameter) {
                float px = map(x, imgStartX, imgEndX, -halfW, halfW);
                float py = map(y, imgStartY, imgEndY, -halfH, halfH);

                float distNorm = sqrt(sq(px) + sq(py)) / radius;
                float prob = lerp(1.0, 0.0, pow(distNorm, 2));

                if (distNorm > 1.0) continue;

                if (random(1) < prob) {
                    color c = img.get(int(x), int(y));
                    push();
                    translate(blob.center.x, blob.center.y);
                    noStroke();
                    fill(c);
                    ellipse(px, py, dotDiameter, dotDiameter);
                    pop();
                }
            }
        }

        pop();
    }
}