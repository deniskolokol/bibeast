
// -- synths for bibeast


SynthDef( \bb0fount, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var trate, dur, clk, pos, in, out, updateRate=30;
	trate = ay.linlin(0,1, 1,50); //arg Y: trate 0.1..50
	dur = 4 / trate;
	clk = Impulse.kr(trate);
	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
	in= TGrains.ar(
			numChannels: 4,
			trigger: clk,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440),
			centerPos: pos * fpos,
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1), [fdur, dur ]),
			pan: WhiteNoise.kr(panidx, panshift),
			amp: 1
		);

	out= vol *
		(in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;

SynthDef( \bb1stut, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var trate, dur, clk, pos, d, z, in, out, updateRate=30;
	pos = round((ax*0.19)+0.1, 0.01); // arg X: position
	trate = (ay*49.0)+1; //arg Y: trate 1..50
	clk = Impulse.ar(trate * 10);
	d = { Dwhite(0.1, 0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
	in= TGrains.ar(4, clk, bufnum,
			rate:(Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * pos + 1) * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440) * frate,
			centerPos: Dseq(z.dup(8), inf) / pos,
			dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
			pan:Dseq([0-panidx, 0-(panidx*0.5), 0-(panidx*0.25), 0-(panidx*0.16), d.value, 0, z.value, panidx*0.16, panidx*0.25, panidx*0.5, panidx], inf) * 2 - 1,
			amp: Dseq([1, 0, z.value.min(1.3), 0, 0.6, 1.0, 1, 0.1, 0.1], inf)
		);
	out= vol*
		(in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;


SynthDef( \bb2slice, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;


	var trate, dur, clk, pos, in, out, updateRate=30;


	pos = ax * bufdur; // arg X: position


	trate = ay.linlin(0,1, 1,100);  //arg Y: trate 1..100
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	in= TGrains.ar(
			numChannels:4,
			trigger:clk,
			bufnum:bufnum,
			rate:(2 ** WhiteNoise.kr(2)) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440),
			centerPos:pos * fpos,


			dur:SelectX.kr(BinaryOpUGen('==', fdur, 1), [fdur, dur]),


			pan:WhiteNoise.kr(panidx, panshift),
			amp:1);


	out= vol *
		(in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;



SynthDef( \bb3chop, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var tratectrl, trate, dur, durctrl, pos, clk, in, out, updateRate=30;
	pos = ax * bufdur; // arg X: position
	trate = ay.linlin(0,1, 2,50); // arg Y: durctrl 2..50
	dur = 4 / trate;
	tratectrl = Dseq([2, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
	clk = Impulse.kr(trate);
	in= TGrains.ar(4, clk, bufnum, tratectrl * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440), pos * fpos, dur * fdur, SinOsc.kr(clk*10,0,panidx, panshift).abs, 1);
	out= vol *
		(in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;

SynthDef( \bb4shake, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var trate = 1, pos, dur, clk, in, out, updateRate=30;
	pos = ax * bufdur; // arg X: position
	trate = ay.linlin(0,1, 1,60); //arg Y: trate, 1..60
	dur = 4 / trate;
	clk = Dust.kr(trate);
	in= TGrains.ar(
			numChannels: 4,
			trigger: clk,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440),
			centerPos: fpos*(pos + TRand.kr(0, 0.01, clk)),
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1), [fdur, dur ]),
			pan: WhiteNoise.kr(panidx, panshift),
			amp: 1
		);
	out= vol *
		(in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;


SynthDef( \bb5drone, {
	arg busnum = 0, bufnum = 0, bufdur, ax, ay, panidx= 0.8, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var trate = 1, pos, dur, clk, in, out, updateRate=30;
	pos = ax * bufdur; // arg X - position
	trate = (ay * 72) + 8; //arg Y - trate, 8..80
	dur = 12 / trate;
	clk = Impulse.kr(trate);
	in= TGrains.ar(
			numChannels: 4,
			trigger: clk,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440),
			centerPos: (pos + TRand.kr(0, 0.01, clk)) * fpos,
			dur: dur,
			pan: WhiteNoise.kr(panidx, panshift),
			amp: 1
		);


	out= vol *
		(in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );

	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;






SynthDef( \bb6gendsl, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var trate, dur, clk, pos, in1, in2, out, updateRate=30;
	pos= ax * bufdur; // arg X: position
	trate= (ay*9)+1;  //arg Y: trate 1..10


	dur= 8 / trate;


	clk= Impulse.kr(trate);



	in1= TGrains.ar(
		numChannels:4,
		trigger:clk,
		bufnum:bufnum,
		rate:BufRateScale.kr(bufnum) * Gendy1.ar(1,1,1,1.0,30,100,0.3,0.05,5) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440),
		centerPos:pos * fpos,
		dur:dur,
		pan:0,
		amp:0.3
	);
	in2= Normalizer.ar(
		RLPF.ar(
			RLPF.ar(
				Gendy2.ar(a:SinOsc.kr(0.4,0,0.05,0.05),c:SinOsc.kr(0.3,0,0.1,0.5)),
				ax.linexp(0,1,10,10000),
				0.05
			),
			ay.linexp(0,1,10,10000),0.05, vol*0.3
		),
		0.2
	);

	out= vol *
		PanAz.ar(


			numChans:4,
			in:in1+in2,


			pos:Lag.kr(LFNoise0.kr(ay)),
			level:0.5,


			width:4,
			orientation:Lag.kr(LFNoise0.kr(1))


		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );


	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;



SynthDef( \bb7gendy, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, rotate= 0, rotfreq= 1, trigID= 60, gate= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var trate, dur, clk, pos, in, out, updateRate=30;

	pos= ax * bufdur; // arg X: position
	trate= (ay*9)+1;  //arg Y: trate 1..10
	dur= 4 / trate;


	clk= Impulse.kr(trate);

	in= Normalizer.ar(
		RLPF.ar(
			RLPF.ar(
				Gendy2.ar(a:SinOsc.kr(0.4,0,0.05,0.05),c:SinOsc.kr(0.3,0,0.1,0.5)),
				ax.linexp(0,1,10,10000),
				0.05),
			ay.linexp(0,1,10,10000), 0.05, vol*0.05),
		0.7
	);

	out= vol*
		PanAz.ar(
			numChans:4,



			in:in,
			pos:Lag.kr(LFNoise0.kr(ay)),


			level:0.5,
			width:4,



			orientation:Lag.kr(LFNoise0.kr(1))
		);
	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );


	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).store;




SynthDef(\bb8loopst, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 1, frate= 1, factor= 0, trigID= 60, gate= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;

	var timescale, ratescale, trig, trigdiv, env, offset, fadeTime = 0.1, speed, in, out, updateRate=30;
	timescale = ax * bufdur; // arg X: duration
	speed = ay.linlin(0,1, 5,20);
	trig = Impulse.kr(speed);
	trigdiv = PulseDivider.kr(trig, 2, [0,1]); // divide triggers over 2 channels
	env = Lag.kr(ToggleFF.kr(trig), fadeTime); // one signal to contol which channel is heard
	offset = Phasor.ar(0, timescale * BufRateScale.kr(bufnum), 0, BufFrames.kr(bufnum));
	in=	SelectL.ar( env,
			PlayBuf.ar(
				1,
				bufnum,
				frate
					* (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
				trigdiv,


				offset,

				1.0
			)
		);


	in=	vol *
		(in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
		);




	out= PanAz.ar(



		numChans:4,
		in:in,


		pos:LFNoise0.kr(panidx.linlin(0,1,5,0.2)),



		width:panidx.linlin(0,1,1,3),
		orientation:Lag.kr(LFNoise0.kr(panshift))


	);


	out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);

}).store;





SynthDef( \bb9pitch, {


	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.5, vol, trigID= 60, gate= 0, inbus= 8, att= 0.1, rel= 1, crva= -3, crvr= 3;
	var freq, hasFreq, in, out, updateRate=30;

	in = Mix.new(InFeedback.ar(inbus));
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
	//freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
	out = Mix.new(
		[
			VarSaw.ar(freq * [ay, ay+1, ay+2], 0, LFNoise1.kr(0.3,0.1,0.1), Amplitude.kr(in, 0.05, 0.05)),
			CombC.ar(LPF.ar(in, ay*1000+0.01), 0.1, (2 * freq).reciprocal, -6).distort * 0.05
		]
	);
	6.do({
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], ax.linlin(0,1, 0.1, 4))
	});

	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, Pan2.ar(out, panidx.linlin(0,1, -1, 1), vol * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 )));
}).store;