class OrderRound extends AbstractOrder {

    protected int division = 4; // Defaultní počet úhlů

    OrderRound(Tracker tracker) {
        this.tracker = tracker;
    }

    public void configure(int division) {
        this.division = max(1, division); // Zajistí, že division je alespoň 1
    }

    protected void evaluate(Particle particle) {
        // Získání aktuálního směru částice
        PVector direction = particle.direction.copy();
        float angle = atan2(direction.y, direction.x);

        // Výpočet kroku úhlu na základě division
        float step = TWO_PI / division;

        // Zaokrouhlení úhlu na nejbližší násobek kroku
        float roundedAngle = round(angle / step) * step;

        // Převod zaokrouhleného úhlu zpět na vektor
        PVector roundedDirection = new PVector(cos(roundedAngle), sin(roundedAngle));

        // Interpolace mezi původním směrem a zaokrouhleným směrem
        particle.direction = PVector.lerp(particle.direction, roundedDirection, this.impact);
    }
}