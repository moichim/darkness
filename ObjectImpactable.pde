abstract class ObjectImpactable {

    protected float impact = 0;
    public void setImpact(float value) { this.impact = constrain(value, 0,1); }
    public float getImpact() {return this.impact;}


    protected boolean on = false;
    public void on() { this.on = true; }
    public void off() { this.on = false; }
    public void setOn(boolean value) { this.on = value; }

}