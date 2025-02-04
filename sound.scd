// Spuštění zvukového serveru
s = Server.default;
s.boot; // Spuštění zvukového serveru

(
// Počkejte, dokud není server připraven
s.waitForBoot({

	SynthDef(\foldsaw, {
		arg freq=4, detune=1, atk=0.01, dec=0.3, rel=3, c1=1, c2=(-1), gate=1,
		mincf=40, maxcf=12000, minrq=0.002, maxrq=0.2, boost=1.25, amp=1, out=0, pan=0;
		var sig, env;
		env = EnvGen.kr(Env.adsr(atk,dec,0.5,rel), gate, doneAction:2);
		sig = Saw.ar(
			freq +
			LFNoise1.kr(LFNoise1.kr(0.5!8).range(0.1,1)).bipolar(detune);
		);
		5.do{sig = (sig*boost).fold(-1.0,1.0)};
		sig = BPF.ar(
			sig,
			LFNoise1.kr({ExpRand(0.005,0.05)}!8).exprange(mincf, maxcf),
			LFNoise1.kr({ExpRand(0.1,0.75)}!8).range(minrq, maxrq)
		);
		sig = Splay.ar(sig, 0.1, 1, pan) * env * amp * 2;
		Out.ar(out, sig);
	}).add;


	Quarks.install("SoundFileCollection") // `SoundFileCollection` je součástí tohoto balíčku

	File.getcwd.asAbsolutePath

	~path = thisProcess.nowExecutingPath.dirname +/+ "/samples/";

	// strunné nástroje
	~string = Buffer.readChannel(
		s,
		~path +/+ "1_nastroje/stars/rev/star_1.aiff"
		// channels:[0]
	);

	~string.bufnum








	//
// Načtení Bufferů
//


~buffers = Array.new; // Inicializace pole pro buffery
~mode = "raw"; // nastavit režim přehrávání rev / raw

// Kořenová složka pro finální buffery
~rootFolder = PathName.new( ~path );

~dict = Dictionary.new;

~scandir = { arg path, name;
	var content;
		content = PathName.new( ~path +/+ path );

		~dict[]
		content.entries.do({ arg c;
			c.postln;
			array.add(c);
			c;
			~dict[c] = c;
		});
		array;
};

	~scandir.value( "1_nastroje/stars/rev/" );

	~dict;

// iterovat složku 01_kolizni
~counter=0;
~rootFolder.entries.do({
	arg path;
	~folderContent = PathName.new( path.fullPath );
	path.fullPath.postln;
	// iterovat oddíl samplů
	~folderContent.entries.do({
		arg pth;
		~sampleFolder = PathName.new( pth.fullPath++~mode );
		// iterovat obsah dané složky
		~sampleFolder.entries.do({
			arg spl;
			~buffers = ~buffers.add(Buffer.read(s,spl.fullPath));
			(~counter + spl.fullPath).postln;
			~counter = ~counter + 1;

		});
	});
})

	~buffers.size;

// Nastavení po definici synťáků
//~sounds = Group.new();
//~effects = Group.after(~sounds);








SynthDef.new(\sample, {
		arg amp=1, out=0, pan=0, rate=1, buf;
		var sig;
		sig = PlayBuf.ar(1,buf, BufRateScale.kr(buf) * rate, doneAction:2);
		sig = Pan2.ar(sig,pan);
		sig = sig * amp;
		// sig = FreeVerb.ar(sig,room:1);
		Out.ar(out,sig);
}).add;

	x = Synth.new(\sample,[\buf, 4, \rate, 1, \amp, 0.3, \pan,-1]);

    // Počkejte, dokud není SynthDef nahrán
    s.sync;


	["Started scsynth on", NetAddr.localAddr.hostname, NetAddr.langPort].postln;

    // Debug zpráva
    "SynthDef s ADSR obálkou byl úspěšně nahrán a Synth spuštěn!".postln;

	~x = Synth(\foldsaw, [\freq, 4, \amp, 1]);

	n = NetAddr.new( NetAddr.localAddr.hostname, NetAddr.localAddr.port );

	// n.sendMsg("/blip", 4, 0, 3);

    // Definice OSC routy pro přijímání zpráv
    OSCdef.newMatching(\blipp, { |msg, time, addr, recvPort|
		var pan = msg[1], amp = msg[2], freq = msg[3];
		~x.set(\freq, freq, \amp, amp, \pan, pan);
		[msg, time, addr, recvPort].postln;
	},
	"/blip",
	// n
	// NetAddr.new( "127.0.0.1", NetAddr.langPort )
	// "127.0.0.1",
	// NetAddr.langPort

	);

	OSCdef(\blipp).enable;
	// OSCdef(\blipp).disable;

    s.plotTree;
    s.meter;

});

)


