// Define the new SynthDef
SynthDef(\polyLayeredSynth, {
    |out = 0, freq = 440, depthStart = 3, depthEnd = 1.5,
    atk = 0.01, sus = 0.1, rel = 0.2, pan = 0,
    speed1 = 1, speed2 = 1, orientation = 0|

    var freqStart, freqEnd, freqEnv, ampEnv, vibrato, mainOsc, sig;

    // Calculate frequency range based on depth parameters
    freqStart = freq / depthStart;
    freqEnd = freq / depthEnd;

    // Frequency envelope
    freqEnv = EnvGen.kr(
        Env([freqStart, freq, freqEnd], [atk, sus, rel], ['exp', 'exp'])
    );

    // Vibrato effect based on speed parameters
    vibrato = SinOsc.kr(speed1).range(-1, 1) * freq * 0.05;

    // Main oscillator with frequency envelope and vibrato
    mainOsc = SinOsc.ar(freqEnv + vibrato);

    // Amplitude envelope
    ampEnv = EnvGen.kr(Env.perc(atk, rel, 1, curve: -4), doneAction: 2);

    // Apply orientation to an effect (e.g., a low-pass filter)
    var filteredSig = RLPF.ar(mainOsc * ampEnv, orientation.linlin(-1, 1, 200, 2000), 0.5);

    // Pan the signal
    sig = Pan2.ar(filteredSig, pan);

    // Output the signal
    Out.ar(out, sig);
}).add;

// Now, we will create a new DarknessToolSynth instance to control this synth
~polySynth = DarknessToolSynth.new(
    "polySynth", 
    \polyLayeredSynth, 
    57133, // Listening port
    57134  // Sending port
);

// Set parameters for the synth
~polySynth.setBuf(0); // Buffer number (if needed)
~polySynth.setDur(1); // Duration
~polySynth.setOctave(4); // Base octave
~polySynth.setMelody(Pseq([0, 2, 4, 5, 7], inf)); // Melody sequence
~polySynth.setShift(0); // Shift
~polySynth.setPan(0); // Pan position
~polySynth.setDepthStart(Pseq([3, 2, 1.5], inf)); // Depth start
~polySynth.setDepthEnd(Pseq([1.5, 2, 3], inf)); // Depth end
~polySynth.setVibRate(Pseq([4, 8, 12], inf)); // Vibrato rate
~polySynth.setVibDepth(Pseq([0.01, 0.05, 0.1], inf)); // Vibrato depth
~polySynth.setBeatAmp(Pseq([1, 0.5, 0.75], inf)); // Beat amplitude
~polySynth.setBeatFreqRatio(Pseq([0.5, 1, 2], inf)); // Beat frequency ratio

// Start listening to the synth
~polySynth.listen;

// Play the synth
~polySynth.play;