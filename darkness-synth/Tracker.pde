// Define the new SynthDef
SynthDef(\polyLayeredSynth, {
    |out = 0, freq = 440, depthStart = 3, depthEnd = 1.5,
    atk = 0.01, sus = 0.1, rel = 0.2, pan = 0,
    speed1 = 1, speed2 = 1, orientation = 0|

    var freqStart, freqEnd, freqEnv, ampEnv, vibrato, mainOsc, secondaryOsc, sig;

    // Calculate frequency range based on depth parameters
    freqStart = freq / depthStart;
    freqEnd = freq / depthEnd;

    // Frequency envelope
    freqEnv = EnvGen.kr(
        Env([freqStart, freq, freqEnd], [atk, sus, rel], ['exp', 'exp'])
    );

    // Vibrato as a function of speed parameters
    vibrato = SinOsc.kr(speed1).range(-1, 1) * freq * 0.05;

    // Main oscillator with frequency envelope and vibrato
    mainOsc = SinOsc.ar(freqEnv + vibrato);

    // Secondary oscillator for layering
    secondaryOsc = SinOsc.ar(freq * 0.5) * 0.3; // Lower frequency for layering

    // Amplitude envelope
    ampEnv = EnvGen.kr(Env.perc(atk, rel, 1, curve: -4), doneAction: 2);

    // Combine signals
    sig = (mainOsc + secondaryOsc) * ampEnv;

    // Apply orientation effect (e.g., a filter)
    sig = BPF.ar(sig, orientation.linlin(-1, 1, 200, 2000), 0.707);

    // Pan the output
    sig = Pan2.ar(sig, pan);

    // Output the signal
    Out.ar(out, sig);
}).add;

// Now we can create a new DarknessToolSynth instance for this synth
~polySynth = DarknessToolSynth.new(
    "polySynth", 
    \polyLayeredSynth, 
    57134, // Listening port
    57135  // Sending port
);

// Set parameters for the synth
~polySynth.setBuf(0); // Assuming a buffer index
~polySynth.setDur(1);
~polySynth.setPan(0);
~polySynth.setOctave(4);
~polySynth.setMelody(Pseq([0, 2, 4, 5, 7], inf));
~polySynth.setShift(0);
~polySynth.setScale(Scale.major);
~polySynth.setDepthStart(Pseq([3, 4, 5], inf));
~polySynth.setDepthEnd(Pseq([1.5, 2, 3], inf));
~polySynth.setVibRate(Pseq([4, 6, 8], inf));
~polySynth.setVibDepth(Pseq([0.01, 0.05, 0.1], inf));

// Start listening for OSC messages
~polySynth.listen;

// Play the synth
~polySynth.play;