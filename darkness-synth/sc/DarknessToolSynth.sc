// Define the new SynthDef
SynthDef(\polyLayeredSynth, {
    |out = 0, freq = 440, depthStart = 3, depthEnd = 1.5,
    atk = 0.01, sus = 0.1, rel = 0.2, pan = 0,
    speed1 = 1, speed2 = 1, orientation = 0|

    var freqStart, freqEnd, freqEnv, ampEnv, vibrato, mainOsc, sig;

    // Calculate frequency range based on depth
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
    sig = LPF.ar(mainOsc, orientation.linlin(-1, 1, 200, 2000));

    // Set amplitude to 1
    sig = sig * ampEnv;

    // Pan the signal
    sig = Pan2.ar(sig, pan);

    // Output the signal
    Out.ar(out, sig);
}).add;

// Now, we will create a new DarknessToolSynth instance for this synth
~polySynth = DarknessToolSynth.new(
    "polySynth", 
    \polyLayeredSynth, 
    57120, // Listening port
    57133  // Sending port
);

// Set parameters for the synth
~polySynth.setBuf(0); // Buffer number (if needed)
~polySynth.setDur(1); // Duration
~polySynth.setPan(0); // Center pan
~polySynth.setOctave(4); // Base octave
~polySynth.setMelody(Pseq([0, 2, 4, 5, 7, 9, 11], inf)); // Melody sequence
~polySynth.setShift(0); // Shift
~polySynth.setScale(Scale.major); // Scale

// Set additional parameters for speed and orientation
~polySynth.setVibRate(Pseq([4, 8, 12], inf)); // Vibrato rate
~polySynth.setVibDepth(0.1); // Vibrato depth
~polySynth.setBeatAmp(0.5); // Beat amplitude
~polySynth.setBeatFreqRatio(1); // Beat frequency ratio

// Start listening for OSC messages
~polySynth.listen;

// Play the synth
~polySynth.play;