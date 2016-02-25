/// Fractal Music Box

/// Made for the Monthly Music Hackathon February 2016
/// Code by Elliot Cole with inspiration and more coding by Erika Nesse

// To use: First start the server, then initialize,
// then do steps 1-5 as marked in the code to make a fractal.

s.boot; // start server
( // initialize
~freqArray = {rrand(-5,14)}!10;

// a nice ping noise
SynthDef(\ping, {arg freq=440, sustain = 0.3, amp=0.1, pan=0;
	var env, sound;
	env = EnvGen.kr(Env.perc(releaseTime:sustain), doneAction:2);
	sound = SinOsc.ar(freq, mul:amp) * env;
	sound = Pan2.ar(sound, pan);
	Out.ar(0, sound);
}).add;


(
~fractalize = {arg freq, time, timeProportions, depth;

	if (depth == 0,
		{
			"basecase.  adding:%".format(time);
			~timesToPlay.add(time);
			~notesToPlay.add(~freqArray.wrapAt(freq));
		},
		{
			var newDurations;
			newDurations = time*timeProportions;
			newDurations.do {|x, i|
				~fractalize.value(~freqArray.wrapAt(i) + freq, x, timeProportions, depth-1);
			}
		}
	);
}
);

(
r = Routine.new({
	~timePoints = List.new;
	~durs = List.new;
	~timePoints.add(TempoClock.default.seconds).yield;
	loop {
		~timePoints.add(TempoClock.default.seconds);
		~durs.add(~timePoints[~timePoints.size-1] - ~timePoints[~timePoints.size-2]);
		~normalized = ~durs.asArray.normalizeSum;
		//~normalized = ~normalized*12; // uncomment to normalize rhythm to 12 beats
		//~normalized = ~normalized.ceil;
		//~normalized = ~normalized.normalizeSum;
		~durs.postln.yield;
	};
})
);

// for file recording
SynthDef("help-Diskout", {arg bufnum;
    DiskOut.ar(bufnum, In.ar(0,2));
}).send(s);


~timeFactor = 10; // how much longer than the original time to play the fractal
)



r.reset // reset durations (1)
r.next //input rhythm (2) : press ctrl-enter on this line repeatedly to create a rhythm



(
~timesToPlay = List.new; ~notesToPlay = List.new;
~freqArray = [1, 2, 3, 4, 5, 6, 7, 8];
//~freqArray = {rrand(-5,14)}!10; // uncomment to randomize frequencies

)// reset notes and times (3)

~fractalize.value(1, ~durs.sum*~timeFactor, ~normalized, 3); // fractalize (4)


~timesToPlay
~notesToPlay


(
Pdef(\player, Pbind(
	\instrument, \ping, // change instrument here
	\dur, Pseq(~timesToPlay,1),
	\degree, Pseq(~notesToPlay, 1),
	\legato, 5,
	\octave, 4,
	\amp, 0.1,
	\pan, Pwhite(-1.0, 1)
).play)

) // play (5)



//// File stuff
(
// allocate a disk i/o buffer
b= Buffer.alloc(s, 65536, 2);

// create an output file for this buffer, leave it open
b.write("~/Documents/Programming/Supercollider/supercollider.aiff".standardizePath, "aiff", "int16", 0, 0, true); //
// create the diskout node; making sure it comes after the source
d = Synth.tail(nil, "help-Diskout", ["bufnum", b]);

) // start file recording

(

d.free;
// close the buffer and the soundfile
b.close;
// free the buffer
b.free;

)// stop file recording







