abstract class AbstractOrder {

    Tracker tracker;

    protected float impact = 0;
    public void setImpact(float value) { this.impact = constrain(value, 0,1); }

    protected boolean on = false;
    public void on() { this.on = true; }
    public void off() { this.on = false; }
    public boolean getOn() { return this.on; }

    public void applyToParticle( Particle particle ) {
        if ( this.on == true ) {
            this.evaluate( particle );
        }
    }

    protected abstract void evaluate( Particle particle );

}

class OrderColumns extends AbstractOrder {

    protected int number = 0;
    protected int segments = 0;
    protected float step = 0;
    protected float width = 50;
    protected boolean vertical = true;

    OrderColumns( Tracker tracker ){
        this.tracker = tracker;
    }

    public void configure(
        boolean vertical,
        int number,
        float width
    ) {
        this.vertical = vertical;
        this.number = number;
        this.segments = number + 1;
        float dimension = this.vertical == true 
            ? controller.mapping.output.x
            : controller.mapping.output.y;
        this.step = dimension / this.segments;
        this.width = constrain( width, 0, this.step / 3 );
    }

    protected void evaluate( Particle particle ) {

        float position = this.getParticlePosition( particle );

        float nearest = this.getNearestColumnPosition( position );

        boolean isInsideColumn = this.isInsideColumn( position, nearest );

        PVector towards = this.getRotationTowards( position, nearest );

        PVector inwards = this.getRotationInside( position, nearest );

        float halfAColumn = this.step / 2;
        float distance = abs( position - nearest );
        float difference = abs( halfAColumn - distance );
        float towardsRatio = map( difference, 0, halfAColumn, 0, 1 );

        PVector result = PVector.lerp( towards, inwards, towardsRatio ).normalize();

        particle.direction = PVector.lerp( particle.direction, result, this.impact );
    
    }


    protected float getParticlePosition( Particle particle ) {
        return this.vertical == true
            ? particle.position.x
            : particle.position.y;
    }

    protected float getNearestColumnPosition( float position ) {

        float nearest = 0;
        boolean matched = false;

        while ( nearest < controller.mapping.output.x && matched == false ) {

            float next = nearest + this.step;
            float threshold = next - ( this.step / 2);

            if ( position >= threshold ) {
                nearest = next;
            } else {
                matched = true;
                break;
            }

            
        }

        return nearest;

    }

    protected boolean isInsideColumn( float position, float nearest ) {
        float distance = abs( nearest - position );
        float threshold = this.width / 2;
        float thresholdDeviation = random( this.width / 5 );
        return distance < ( threshold + thresholdDeviation );
    }

    protected PVector getRotationTowards( float position, float nearest ) {

        float distance = nearest - position;
        PVector direction = this.vertical == true
            ? new PVector( distance, 0 )
            : new PVector( 0, distance );
        direction.normalize();

        return direction;

    }

    protected PVector getRotationInside( float position, float nearest ) {
        float distance = nearest - position;
        PVector direction = this.vertical == true
            ? new PVector( 0, distance )
            : new PVector(distance, 0);
        direction.normalize();
        return direction;
    }

}


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


class OrderCircle extends AbstractOrder {

    protected int number = 0; // Počet kruhů
    protected float step = 0; // Vzdálenost mezi kruhy
    protected float width = 50; // Šířka kruhu

    OrderCircle(Tracker tracker) {
        this.tracker = tracker;
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





class OrderRandom extends AbstractOrder {

    OrderRandom( Tracker tracker ) {
        this.tracker = tracker;
    }

    public void setImpact( float value ) {
        for ( Blob blob : this.tracker.blobs ) {
            for ( Particle particle : blob.particles ) {
                particle.movementRandom.setImpact( value );
            }
        }
    }

    public void setNoiseStep( float value ) {
        for ( Blob blob : this.tracker.blobs ) {
            for ( Particle particle : blob.particles ) {
                particle.movementRandom.setNoiseStep( value );
            }
        }
    }

    public void setSpread( float value ) {
        for ( Blob blob : this.tracker.blobs ) {
            for ( Particle particle : blob.particles ) {
                particle.movementRandom.setSpread( value );
            }
        }
    }

    public void evaluate(Particle particle) {}

}