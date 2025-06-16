s.boot;







(
SynthDef(\sineBeatLayered, {
    |out = 0, freq = 440, depthStart = 3, depthEnd = 1.5,
     atk = 0.01, sus = 0.1, rel = 0.2, amp = 0.5,
     vibRate = 6, vibDepth = 0.05,
     beatFreqRatio = 0.5, beatAmp = 0.4, beatRel = 0.08|

    var freqStart, freqEnd, freqEnv, ampEnv, vibrato, mainOsc;
    var beatEnv, beatOsc, sig;

    freqStart = freq / depthStart;
    freqEnd = freq / depthEnd;

    // Frekvenční obálka
    freqEnv = EnvGen.kr(
        Env([freqStart, freq, freqEnd], [atk, sus, rel], ['exp', 'exp'])
    );

    // Vibrato jako relativní odchylka
    vibrato = SinOsc.kr(vibRate).range(-1, 1) * freq * vibDepth;

    // Hlavní sinusovka s frekvenční obálkou a vibratem
    mainOsc = SinOsc.ar(freqEnv + vibrato);

    // Amplitudová obálka
    ampEnv = EnvGen.kr(Env.perc(atk, rel, 1, curve: -4), doneAction: 2);

    // Beatová vrstva – nízká sinusovka s rychlým dozvukem
    beatEnv = EnvGen.kr(Env.perc(0.001, beatRel), levelScale: beatAmp);
    beatOsc = SinOsc.ar(freq * beatFreqRatio) * beatEnv;

    // Výstup
    sig = (mainOsc * ampEnv * amp) + ( beatOsc * amp );

	sig = Limiter.ar( sig, 1, 0.01 );

    Out.ar(out, sig ! 2);
}).add;
)




~p = DarknessToolSynth.new("test", \beatLayered, ~in, ~out );

~p.play;






(

Synth(\beatLayered, [
    \freq, 220,
    \depthStart, 4,
    \depthEnd, 1.5,
    \atk, 0.005,
    \sus, 0.5,
    \rel, 1,
    \vibRate, 50,
    \vibDepth, 1,
    \beatFreqRatio, 0.5,  // druhý oscilátor bude na 110 Hz
    \beatAmp, 0.8,
    \beatRel, 0.5,
    \amp, 0.3,
	\pan, -0.2
]);

)


(
Pbindef(\sinePulseTest,
    \instrument, \beatLayered,
    \dur, 0.4,
    \freq, Pseq([110, 220, 330, 440, 660, 1000].scramble, inf),
    \depthStart, Pseq([6, 4, 2], inf),
    \depthEnd, Pseq([1.2, 2, 1.8, 5, 0.75], inf),
    \atk, Pwhite(0.005, 0.02, inf),
    \sus, Pwhite(0.05, 0.15, inf),
    \rel, Pwhite(0.5, 1, inf),
	\vibRate, Pseq([4.0, 50.0, 20.0, 15.0], inf),
    \vibDepth, Pseq([0.01, 0.05, 0.15], inf),
    \beatAmp, Pseq([1.0, 0.3, 0.6, 0.9].scramble, inf),
    \beatFreqRatio, Pseq([0.25, 0.5, 1, 2].scramble, inf),
    \beatRel, Pwhite(0.03, 0.5, inf),
    \amp, 0.1
).play;
)


Pbindef( \sinePulseTest ).stop;





