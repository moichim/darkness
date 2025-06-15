DarknessEvent {
    var <>onStart;
    var <>onStop;
    var <>active = false;

    *new {|onStart,onStop|
        var instance = super.new();
        instance.onStart = onStart;
        instance.onStop = onStop;
        ^instance;
    }

    start {
        if(this.active == true, {
            this.onStart.value;
        }, {
            this.active = true;
            this.onStart.value;
        });
    }

    end {
        if(this.active == false, {
            this.onStop.value;
        }, {
            this.active = false;
            this.onStop.value;
        });
    }

}