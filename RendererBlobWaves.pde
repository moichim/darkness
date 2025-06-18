class RendererBlobWaves extends RendererAbstract {

    float noiseSeedOffset;

    RendererBlobWaves(Tracker tracker) {
        super(tracker);
        noiseSeedOffset = random(10000);
    }

    void updateInTracker(Tracker tracker) {}

    void drawInTracker() {}

    void updateInBlob(Blob blob) {}

    void drawInBlob(Blob blob) {
        push();

        translate(blob.center.x, blob.center.y);

        // Výpočet direction podle pohybu blobu
        float direction = 0;
        if (blob.prev != null) {
            float dx = blob.center.x - blob.prev.x;
            float dy = blob.center.y - blob.prev.y;
            if (dx != 0 || dy != 0) {
                direction = atan2(dy, dx);
            }
        }
        rotate(direction);

        float baseRadius = max(blob.movement, 40) * 0.8;
        int points = 8;
        float angleStep = TWO_PI / points;
        float waveAmplitude = baseRadius * 3; // výraznější vlnění

        noFill();
        stroke(tracker.emissionColor);
        strokeWeight(2);

        beginShape();
        // Pro uzavřenou křivku s curveVertex je vhodné zopakovat první 2 body na konci
        for (int j = -2; j < points + 2; j++) {
            int i = (j + points) % points;
            float angle = i * angleStep;

            float noiseVal = noise(
                noiseSeedOffset + cos(angle) * 0.5 + frameCount * 0.02,
                noiseSeedOffset + sin(angle) * 0.5 + frameCount * 0.02
            );

            // Výrazné prolínání v okolí hlavních bodů
            float waveStrength = 1.0 + 0.7 * cos(4 * angle);

            float r = baseRadius + (noiseVal - 0.5) * waveAmplitude * waveStrength;

            float x = cos(angle) * r;
            float y = sin(angle) * r;

            curveVertex(x, y);
        }
        endShape(CLOSE);

        pop();
    }
}