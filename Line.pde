class Line {

    ArrayList<PVector> points = new ArrayList<PVector>();

    public int identity;

    Line(
        int identity
    ) {
        this.identity = identity;
    }

    void add(PVector p) {
        points.add(p);
    }

    void draw() {
        beginShape();
        stroke(255);
        for (PVector p : points) {
            vertex(p.x, p.y);
        }
        endShape();
    }

}