// Spuštění zvukového serveru
s = Server.default;
s.boot; // Spuštění zvukového serveru

// Počkejte, dokud není server připraven
s.waitForBoot({
    // Definice syntezátoru s ADSR obálkou
    SynthDef(\simpleSynth, { |freq = 440, amp = 0.5, sustain = 1.0, attack = 0.01, decay = 0.2, release = 0.5|
        var sig, env;

        // Obálka ADSR
        env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), doneAction: 2);
        // doneAction: 2 zajistí uvolnění syntezátoru po ukončení obálky

        // Generátor sinusového signálu s obálkou a amplitudou
        sig = SinOsc.ar(freq) * env * amp;

        // Poslání výstupu do 1. a 2. kanálu (stereo)
        Out.ar(0, sig.dup);
    }).add; // Zaregistrování SynthDef na serveru


	SynthDef(\sine, {
		var snd;
		snd = SinOsc.ar(\freq.kr(440));
		snd = snd * Env.perc(0.01, 0.3).ar(Done.freeSelf);
		Out.ar(0, snd);
	}).add;

    // Počkejte, dokud není SynthDef nahrán
    s.sync;


    // Debug zpráva
    "SynthDef s ADSR obálkou byl úspěšně nahrán a Synth spuštěn!".postln;


    // Definice OSC routy pro přijímání zpráv
    OSCdef(\freq, { |msg|
        var freq = msg[1]; // Předpokládáme, že frekvence je na druhém místě v zprávě
        Synth(\sine, [freq: freq]);
    }).add;

    // Naslouchání na portu 57120 (změňte podle potřeby)
    OSCFunc.add({ |time, addr, msg, port|
        if (port == 57120, {
            // Zpracování příchozích zpráv
            postln("Received OSC message:", msg);
            OSCdef(\freq).value(msg);
        });
    });

});


