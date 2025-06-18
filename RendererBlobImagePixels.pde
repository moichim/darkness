class RendererBlobImagePixels extends RendererAbstract {

    PImage img;
    float dotDiameter;

    RendererBlobImagePixels(Tracker tracker, String imagePath, int pixelCount, float dotDiameter) {
        super(tracker);
        this.img = loadImage(imagePath);
        this.dotDiameter = dotDiameter;
    }

    void updateInTracker(Tracker tracker) {}

    void drawInTracker() {}

    void updateInBlob(Blob blob) {}

    void drawInBlob(Blob blob) {
        push();

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

                float distNorm = sqrt(sq(px) + sq(py)) / radius; // 0 ve středu, 1 na okraji
                float prob = lerp(1.0, 0.0, pow(distNorm, 2)); // Kvadraticky méně pravděpodobné u okraje

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
// ...existing code...
}