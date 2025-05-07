class OrderCircle extends AbstractOrder {

    protected int number = 0; // Počet kruhů
    protected float step = 0; // Vzdálenost mezi kruhy
    protected float width = 50; // Šířka kruhu

    OrderCircle(Tracker tracker) {
        this.tracker = tracker;
    }

    public void setNumber( int num ) {
        this.configure( num, this.width );
    }

    public void configure(int number, float width) {
        this.number = max(1, number); // Zajistí, že počet kruhů je alespoň 1
        this.step = controller.mapping.output.x / (this.number + 1); // Vypočítá vzdálenost mezi kruhy
        this.width = constrain(width, 0, this.step / 3); // Nastaví šířku kruhu
    }

    protected void evaluate(Particle particle) {
        // Střed plátna
        PVector center = new PVector(controller.mapping.output.x / 2, controller.mapping.output.y / 2);

        // Vzdálenost částice od středu
        float distance = particle.position.dist(center);

        // Nejbližší kruh
        float nearest = this.getNearestCircleRadius(distance);

        // Směr k nejbližšímu kruhu
        PVector towards = this.getRotationTowards(particle.position, center, nearest);

        // Směr po obvodu kruhu
        PVector around = this.getRotationAround(particle.position, center, nearest);

        // Výpočet interpolace mezi směrem k a po obvodu kruhu
        float halfACircle = this.step / 2;
        float difference = abs(halfACircle - abs(distance - nearest));
        float towardsRatio = map(difference, 0, halfACircle, 1, 0);

        PVector result = PVector.lerp(towards, around, towardsRatio).normalize();

        // Nastavení směru částice
        particle.direction = PVector.lerp(particle.direction, result, this.impact);
    }

    protected float getNearestCircleRadius(float distance) {
        float nearest = 0;
        boolean matched = false;

        while (nearest < controller.mapping.output.x / 2 && !matched) {
            float next = nearest + this.step;
            float threshold = next - (this.step / 2);

            if (distance >= threshold) {
                nearest = next;
            } else {
                matched = true;
            }
        }

        return nearest;
    }

    protected PVector getRotationTowards(PVector position, PVector center, float radius) {
        PVector direction = PVector.sub(center, position).normalize();
        return direction.mult(radius - position.dist(center));
    }

    protected PVector getRotationAround(PVector position, PVector center, float radius) {
        PVector direction = PVector.sub(position, center).normalize();
        direction = new PVector(-direction.y, direction.x); // Otočení o 90° pro pohyb po obvodu
        return direction.mult(radius);
    }
}