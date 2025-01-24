abstract class AbstractControl<T> {

    protected T value;

    protected String label;

    AbstractControl(
        String label,
        T value
    ) {
        this.value = value;
        this.label = label;
    }

    public T value() {
        return this.value;
    }

    public void set( T value ) {
        this.value = this.validate( value );
    }

    protected abstract T validate( T value );

}


class IntegerControl extends AbstractControl<Integer>{

    protected int min = Integer.MIN_VALUE;
    protected int max = Integer.MAX_VALUE;

    IntegerControl(
        String label,
        int value
    ) {
        super( label, value );
    }


    public IntegerControl setMin( int min ) {
        this.min = min;
        return this;
    }

    public IntegerControl setMax( int max ) {
        this.max = max;
        return this;
    }

    protected Integer validate( Integer value ) {

        if ( this.min != Integer.MIN_VALUE ) {
            value = max( value, this.min );
        }

        if ( this.max != Integer.MAX_VALUE ) {
            value = min( value, this.max );
        }

        return value;

    }

}



class FloatControl extends AbstractControl<Float>{

    protected float min = Float.MIN_VALUE;
    protected float max = Float.MAX_VALUE;

    protected String label;

    FloatControl(
        String label,
        float value
    ) {
        super( label, value );
    }


    public FloatControl setMin( float min ) {
        this.min = min;
        return this;
    }

    public FloatControl setMax( float max ) {
        this.max = max;
        return this;
    }

    protected Float validate( Float value ) {

        if ( this.min != Float.MIN_VALUE ) {
            value = max( value, this.min );
        }

        if ( this.max != Float.MAX_VALUE ) {
            value = min( value, this.max );
        }

        return value;

    }

    float generateRandom() {
        if ( this.min == Float.MIN_VALUE || this.max == Float.MAX_VALUE ) {
            return this.value;
        }
        this.value = random( this.min, this.max );
        return this.value;
    }

}