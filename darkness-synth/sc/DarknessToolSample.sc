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

    // Vibrato effect based on speed parameters
    vibrato = SinOsc.kr(speed1).range(-1, 1) * freq * speed2;

    // Main oscillator with frequency envelope and vibrato
    mainOsc = SinOsc.ar(freqEnv + vibrato);

    // Amplitude envelope
    ampEnv = EnvGen.kr(Env.perc(atk, rel, 1, curve: -4), doneAction: 2);

    // Secondary oscillator for layering
    secondaryOsc = SinOsc.ar(freq * 0.5) * 0.5; // Lower frequency for layering

    // Combine signals
    sig = (mainOsc * ampEnv) + secondaryOsc;

    // Apply orientation effect (e.g., a filter)
    sig = BPF.ar(sig, orientation.linlin(-1, 1, 200, 2000), 0.707); // Bandpass filter

    // Pan the output
    sig = Pan2.ar(sig, pan);

    // Output the final signal
    Out.ar(out, sig);
}).add;

// Now, we can create a new DarknessToolSynth instance to control this synth
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
~polySynth.setPan(0); // Pan
~polySynth.setDepthStart(3); // Depth start
~polySynth.setDepthEnd(1.5); // Depth end
~polySynth.setVibRate(5); // Vibrato rate
~polySynth.setVibDepth(0.1); // Vibrato depth

// Play the synth
~polySynth.play;

// To stop the synth
// ~polySynth.stop;