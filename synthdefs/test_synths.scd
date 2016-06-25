// based on Xii adcreverb
//SynthDef(\gmpAdcverb2x2, { arg inbus=0, outbus=0, revtime=3, hfdamping=0.5, mix=0.1, level=0;
//   	var fx, fxIn, sig;
//   	sig= In.ar(outbus, 2);
//	fxIn= LeakDC.ar(sig.sum) * mix; // make a mono in, leakdc it
//	fx= XiiAdCreVerb.ar(fxIn, revtime, hfdamping, nOuts: 2);
//	ReplaceOut.ar(outbus, LeakDC.ar((sig * level) + fx)) // level
//},[0,0,0,0]).send(s); // having a lag here would result in big blow of noise at start

// soda physical emulation - in progress
SynthDef( \soda00fontain, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, vol, modf = 1;
	var trate, dur, clk, pos;
	var panSpec = [-0.99, 0.99].asSpec, trateSpec = [20.0, 0.1].asSpec;
	trate = trateSpec.map(ay); //arg Y: trate 0.1..20
	dur = 1 / trate;
	clk = Impulse.kr(trate);
	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
	Out.ar(busnum,
		TGrains.ar(
			numChannels: 2,
			trigger: clk,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
			centerPos: pos,
			dur: dur,
			pan: panSpec.map(ax),
			amp: vol
		)
	);
}).send(s);

SynthDef( \soda01slicer, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, impulse=1;
	var trate, dur, clk, pos;
	pos = Integrator.kr(BrownNoise.kr(ax)); // arg X: position
	trate = (ay*99)+1;  //arg Y: trate 1..100
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 2 ** WhiteNoise.kr(2), pos, dur, panidx, vol));
}).send(s);

SynthDef( \gmp14proba, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, syntype=0;
	var trate, dur, clk, pos, out, updateRate=30;
	var posDef= [ax, ax, Integrator.kr(BrownNoise.kr(ax)), ax, ax, Integrator.kr(BrownNoise.kr(ax))];
	trate = (ay*118)+2; //arg Y: trate 2..120
	dur = 12 / trate;
	clk = Impulse.kr(trate);
//	pos + TRand.kr(0, 0.01, clk)
	pos= Integrator.kr(BrownNoise.kr(ax));
//	pos= posDef[syntype];
	out= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(
			numChannels: 2,
			trigger: clk,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum) * frate,
			centerPos: pos * fpos,
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1), [fdur, dur ]),
			pan: WhiteNoise.kr(panidx, panshift),
			amp: vol
		);
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);
