DarknessToolSample : DarknessToolBase {

    var <>bpfFreq, <>bpfQ, <>bpfMapper;

    *new { |name, listeningPort, sendingPort|
        ^super.new(name, listeningPort, sendingPort);
    }

    init {
        super.init;

        this.bpfFreq = this.symbol("BpfFreq");
        this.bpfQ = this.symbol("BpfQ");

        Pdefn(this.bpfFreq, 0);
        Pdefn(this.bpfQ, 0.707);

        this.makePattern;

        OSCdef.newMatching(this.listener, { |msg, time, addr, recvPort|
            var amp=msg[1], pan=msg[2], h=msg[3], speed=msg[7], pivotx=msg[5], pivoty=msg[6], orientation=msg[8];

            this.setAmp(amp);
            this.setPan(pan);
			// Tempo se nastavuje pouze pokud je to nastaveno
            if(this.oscTempoEnabled == true, {
			    this.setTempo(speed.asStringPrec(2).asFloat.linexp(0.0, 1.0, 1, 6.0).min(6).max(1));
			},{});
            this.mapOctave(pivoty);

            if(this.bpfMapper.notNil) { this.bpfMapper.value(msg); };
            if(this.mapper.notNil) { this.mapper.value(amp, pan, h, speed, pivotx, pivoty, orientation); };
        }, this.msg, recvPort: this.listeningPort);
    }

    makePattern {
        Pbindef.new(this.pattern,
            \instrument, \sampler,
            \dur, Pdefn(this.dur),
            \buf, Pdefn(this.buf),
            \amp, Pdefn(\master) * Pdefn(this.amp),
            \degree, Pdefn(this.melody) + Pdefn(this.shift),
            \scale, Pdefn(this.scale),
            \octave, Pdefn(this.octave),
            \pan, Pdefn(this.pan),
            \bpfFreq, Pdefn(this.bpfFreq),
            \bpfQ, Pdefn(this.bpfQ),
            \onNote, Pfunc({ processing.sendMsg(this.msg); this.msg.postln; })
        );
        ("Initialised Pbindef" ++ this.name).postln;
    }

    setBpfFreq { |value| Pdefn(this.bpfFreq, value); }
    setBpfQ { |value| Pdefn(this.bpfQ, value); }
    setBpf { |freq, q| this.setBpfFreq(freq); this.setBpfQ(q); }
    setBpfMapper { |func| this.bpfMapper = func; }
}