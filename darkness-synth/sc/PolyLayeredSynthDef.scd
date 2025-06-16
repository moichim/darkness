s.boot;

(
// Cinkavý VarSaw: pouze horní frekvence, využití depthStart a depthEnd, jemný reverb, oscilující BPF

SynthDef(\polyLayeredSynth, {
    |out = 0, freq = 880, atk = 0.005, sus = 0.05, rel = 0.18, pan = 0,
    depthStart = 2, depthEnd = 4, orientation = 0, speed = 1, vibRate = 6, vibDepth = 0.03|

    var sig, ampEnv, hpFreq, bpfFreq, bpfQ, revMix, width, bpfMod;

    // Šířka pilového vlnění podle depthStart (vyšší depth = užší zvuk)
    width = depthStart.linexp(1, 8, 0.1, 0.9);

    // Amplitudová obálka s mírně zvednutým sustainem, aby nekončila klapnutím
    ampEnv = EnvGen.kr(
        Env([0, 1, 0.7, 0], [atk, sus, rel], [-4, -4, -4]),
        doneAction: 2
    );

    // Highpass filtr - cutoff podle depthEnd (vyšší depthEnd = vyšší cutoff)
    hpFreq = freq * depthEnd.linexp(1, 8, 0.5, 1.2);

    // VarSaw s modulovanou šířkou
    sig = VarSaw.ar(freq, width: width) * ampEnv;

    sig = HPF.ar(sig, hpFreq);

    // Oscilace střední frekvence BPF
    bpfMod = SinOsc.kr(vibRate, 0, vibDepth * freq);

    // BPF pro další zúžení spektra, Q ovlivněno orientation a speed
    bpfFreq = freq + orientation.linlin(-1, 1, -200, 200) + bpfMod;
    bpfQ = speed.linlin(0, 2, 0.5, 2);
    sig = BPF.ar(sig, bpfFreq, bpfQ);

    // Jemný reverb (velmi malý mix, aby neklapal konec)
    revMix = 0.12;
    sig = (sig * (1 - revMix)) + (FreeVerb.ar(sig, 0.4, 0.7, 0.3) * revMix);

    // Výstup s panoramou
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)

(
// Vokálovitý zvuk: polyfonní VarSaw, formantové filtry, jemný chorus a reverb
// Andělský vokálový synth s výrazným reverbem a jemným chorusem
SynthDef(\polyLayeredSynth, {
    |out = 0, freq = 440, amp = 1, atk = 0.15, sus = 0.5, rel = 2.5, pan = 0,
    vibRate = 5, vibDepth = 0.02, depthEnd = 1, beatAmp = 0|

    var sig, ampEnv, dry, chorus, revMix, outEnv;
    var formantFreqs, formantRatios, nFormants, norm;

	var panSpread = 0.05;

	// beatAmp = beatAmp.linlin(-1, 1, 0, 1);

    // Sborový základ: 3 SinOsc s jemným rozladěním
    sig = (
		Pan2.ar( SinOsc.ar(freq), pan - panSpread ) +
		Pan2.ar( SinOsc.ar(freq * 1.005, 0.2pi), pan + panSpread ) +
        Pan2.ar( LinXFade2.ar(
			SinOsc.ar(freq * 0.997, 0.4pi),
			Saw.ar(freq * 0.997, 0.4pi),
			beatAmp
		), pan + LFNoise1.kr(0.2).range(-1 * panSpread, panSpread) )
    ) / 3;

    // Hlavní obálka
    ampEnv = EnvGen.kr(
        Env([0, 1.5, 1, 0], [atk, sus, rel], [-4, -4, -4]),
        doneAction: 2
    );
    sig = sig * ampEnv * amp;

    // 5 formantových frekvencí pro bohatší vokál
    formantRatios = [ 0.75, 1, 1.25, 1.5, 2, 2.5, 3]; // např. 1, 5/4, 3/2, 2, 5/2
    formantFreqs = formantRatios.collect { |r| freq * r };
    nFormants = formantFreqs.size;

    // Randomizace Q a frekvence, obálka pouze depthEnd
    dry = Mix.fill(nFormants, { |i|
        var q = 0.18 + LFNoise1.kr(0.5).range(-0.04, 0.04);
        var freqOffset = LFNoise1.kr(0.3).range(-10, 10);
        var freqEnv = EnvGen.kr(
            Env(
            [formantFreqs[i], formantFreqs[i] * depthEnd], // levels
            [atk + sus + rel],                             // times
            -4                                             // curve
        )
        );
        var vibrato = SinOsc.kr(vibRate, 0, vibDepth * formantFreqs[i]);
        BPF.ar(sig, freqEnv + vibrato + freqOffset, q)
    }) / nFormants;

    // Chorus efekt
    chorus = Mix([
        dry,
        DelayC.ar(dry, 0.04, SinOsc.kr(0.23, 0, 0.018, 0.02)),
        DelayC.ar(dry, 0.04, SinOsc.kr(0.17, 0, 0.012, 0.01))
    ]) / 3;

    // Výrazný reverb
    revMix = 0.55;
    sig = (chorus * (1 - revMix)); // + (FreeVerb.ar(chorus, 0.98, 0.95, 0.7) * revMix);

    // Výstupní obálka pro plynulé doznění reverbu (delší fade-out)
    outEnv = EnvGen.kr(
        Env([1, 1, 0], [atk + sus + rel, 1.2]), // fade-out 1.2s
        doneAction: 2
    );
    sig = sig * outEnv;


    // Panorama a limiter s výrazným zesílením
    sig = Pan2.ar(sig, pan);

    // Limiter na konci
    sig = Limiter.ar(sig * 8, 0.99);

    Out.ar(out, sig);

}).add;
)

(
// Create a new DarknessToolSynth instance for the polyphonic synth
~polySynth = DarknessToolSynth.new(
    "polySynth",
    \polyLayeredSynth,
    57134, // Listening port
    57135  // Sending port
);
)

~polySynth.setAtk(0.025);
~polySynth.setSus(0.25);
~polySynth.setRel(2);
~polySynth.setAmp(1);
~polySynth.setPan(1);
// Set parameters for the synth
~polySynth.setBuf(0); // Buffer number (if needed)
~polySynth.setDur(1); // Duration
~polySynth.setOctave(5); // Base octave
~polySynth.setMelody(Pseq([0, 2, 4, 7, 10, 8], inf)); // Melody sequence
~polySynth.setShift(0); // Shift
~polySynth.setPan(0); // Pan position
~polySynth.setDepthStart(Pseq([3, 2, 1.5], inf)); // Depth start
~polySynth.setDepthEnd(Pseq([1.5, 2, 3], inf)); // Depth end
~polySynth.setVibRate(Pseq([4, 6, 8], inf)); // Vibrato rate
~polySynth.setVibDepth(Pseq([0.05, 0.1, 0.15], inf)); // Vibrato depth
~polySynth.setBeatAmp(Pseq([0.4, 0.6, 0.8], inf)); // Beat amplitude
~polySynth.setBeatFreqRatio(Pseq([0.5, 1, 2], inf)); // Beat frequency ratio

~polySynth.setBeatAmp(-1);

// Start listening for OSC messages
~polySynth.listen;

// Play the synth
~polySynth.stop;