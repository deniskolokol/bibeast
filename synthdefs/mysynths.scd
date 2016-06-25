// Recording synth
SynthDef(\recsyn_1, { arg inbus, bufnum= 0, amp= 1;
	DiskOut.ar(bufnum, Limiter.ar(amp * InFeedback.ar(inbus, 1), 0.99, 0.01) );
}).send(s);

//=== synths' def ====
SynthDef( \gmp0drone, {
    arg busnum = 0, bufnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 1, factor= 0, trigID= 60, gate= 0, destruct= 0, frate= 1, fpos= 1, fdur= 1;
	var trate = 1, pos, dur, clk, in, out1, out2, out, updateRate=30, d, z, destrClk;

	pos = ax * bufdur; // arg X - position
	trate = (ay * 112) + 8; //arg Y - trate, 8..120
	dur = 12 / trate;
	clk = Impulse.kr(trate);
	d = { Dwhite(0.1, 0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
	destrClk = Dust.kr((destruct**3*99)+1);

	in= EnvGen.kr(Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2)
		*TGrains.ar(
			numChannels: 2,
			trigger: clk,
			bufnum: bufnum,
			rate: SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
				[
					Duty.kr(destrClk, 0, Drand([1+((destruct**3*9.9)+0.1), 1+destruct, 0-destruct], inf) * pos),
					BufRateScale.kr(bufnum) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440)
				]),
			centerPos: (pos + TRand.kr(0, 0.01, clk)) * fpos,
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1),
				[fdur, dur ]),
			pan: SelectX.kr(
					BinaryOpUGen('==', destruct, 0) * 2,
					[
						TDuty.kr(destrClk, 0, Dseq([0-panidx, 0-(panidx*0.5), 0-(panidx*0.25), 0-(panidx*0.16), d.value, 0, z.value, panidx*0.16, panidx*0.25, panidx*0.5, panidx], inf) * 2 - 1),
						WhiteNoise.kr(panidx, panshift)
					]),
			amp: SelectX.kr(
					BinaryOpUGen('==', destruct, 0) * 2,
					[
						TDuty.kr(destrClk, 0, Dseq([1, 0, max(1, z.value), 0, 0.6, 1.0, 1, 0.1, 0.1], inf)),
						vol
					]
				)
		);
	out= (in*vol)
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp1shake, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 1, factor= 0, trigID= 60, gate= 0, destruct= 0, frate= 1, fpos= 1, fdur= 1;
	var trate = 1, pos, dur, clk, in, out, updateRate=30, d, z, destrClk;
	pos = ax * bufdur; // arg X: position
	trate = (ay * 59) + 1; //arg Y: trate, 1..60
	dur = 4 / trate;
	clk = Dust.kr(trate);
	d = { Dwhite(0.1, 0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
	destrClk= Impulse.kr(destruct*10);

	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(
			numChannels: 2,
			trigger: clk,
			bufnum: bufnum,
			rate: SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
				[
					TDuty.kr(destrClk, 0, Dseq([rrand(destruct, destruct*0.7), 1, z.value, rrand(destruct, destruct*0.5), 0.5, destruct, 0.1, 0.1], inf) * pos),
					BufRateScale.kr(bufnum) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440)
				]),
			centerPos: (pos + TRand.kr(0, 0.01, clk)) * fpos,
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1),
				[fdur, dur ]),
			pan: SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
				[
					TDuty.kr(destrClk, 0, Dseq([rrand(panidx, panidx*0.25), d.value, 0, z.value, rrand(panidx*0.25, 1-panidx), panidx], inf) * 2 - 1),
					WhiteNoise.kr(panidx, panshift)
				]),
			amp:SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
				[
					TDuty.kr(destrClk, 0, Dseq([1, 0, max(1, z.value), 0, 0.6, 1.0, 1, 0.1, 0.1], inf)),
					vol
				]);
		);
	out= in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 3))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp2fountain, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 1, factor= 0, trigID= 60, gate= 0, destruct= 0, frate= 1, fpos= 1, fdur= 1;
	var trate, dur, clk, pos, in, out, updateRate=30, d, z, destrClk;
	trate = (ay*49.0)+1.0; //arg Y: trate 0.1..50
	dur = 4 / trate;
	clk = Impulse.kr(trate);
	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
	d = { Dwhite(destruct, destruct+0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
	destrClk= Dust.kr(destruct**3*10);
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(
			numChannels: 2,
			trigger: clk,
			bufnum: bufnum,
			rate: SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
				[
					TDuty.kr(destrClk, 0, Drand([1, z.value, 0.5, 0-(destruct**3), 0-(destruct*5), 1+destruct, 0.2, destruct**3], inf)),
					BufRateScale.kr(bufnum) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440)
				]),
			centerPos: pos * fpos,
//			dur: SelectX.kr(
//					BinaryOpUGen('==', destruct, 0) * 2,
//					[TDuty.kr(destrClk, 0, Dseq([0.5, d.value, destruct, z.value*destruct, z.value*2] * 4, inf) / trate), dur ]
//				),
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1),
				[fdur, dur ]),
			pan: SelectX.kr(
					BinaryOpUGen('==', destruct, 0) * 2,
					[
						TDuty.kr(destrClk, 0, Dseq([0-panidx, 0-(panidx*0.5), 0-(panidx*0.25), 0-(panidx*0.16), d.value, 0, z.value, panidx*0.16, panidx*0.25, panidx*0.5, panidx], inf) * 2 - 1),
						WhiteNoise.kr(panidx, panshift)
					]
				),
			amp: SelectX.kr(
					BinaryOpUGen('==', destruct, 0) * 2,
					[
						TDuty.kr(destrClk, 0, Dseq([1, 0, max(1, z.value), 0, 0.6, 1.0, 1, 0.1, 0.1], inf)),
						vol
					]
				)
		);
	out= in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp3stutter, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0;
	var trate, dur, clk, pos, d, z, in, out, updateRate=30;
	pos = round((ax*0.19)+0.1, 0.01); // arg X: position
	trate = (ay*49.0)+1; //arg Y: trate 1..50
	clk = Impulse.ar(trate * 10);
	d = { Dwhite(0.1, 0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(2, clk, bufnum,
			rate:Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * pos + 1,
			centerPos: Dseq(z.dup(8), inf) / pos,
			dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
			pan:Dseq([0-panidx, 0-(panidx*0.5), 0-(panidx*0.25), 0-(panidx*0.16), d.value, 0, z.value, panidx*0.16, panidx*0.25, panidx*0.5, panidx], inf) * 2 - 1,
			amp: Dseq([1, 0, min(1.2, z.value), 0, 0.6, 1.0, 1, 0.1, 0.1], inf)
		);
	out= in * vol; // add processing here in case of nesessity
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp4exciter, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0;
	var trate, clk, pos, d, z, in, out, updateRate=30;
	pos = ax * bufdur; // arg X: position
	trate = (ay*9)+1; // arg Y: trate 1..10
	clk = Impulse.kr(trate);
	d = { Dwhite(0.2, 0.5, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(2, clk, bufnum,
			rate: Dseq([0.1, 1, z.value, 0.5, ay/2, 0.2, 0.1, 0.1, d.value, ay*0.7.rand], inf) * pos + 1,
			centerPos: pos + TRand.kr(0, 0.01, clk),
			dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
			pan:WhiteNoise.kr(panidx, panshift),
			amp:Dseq([0.8, 0, 1, 0, 0.9, 1.0, 1, 0.1, 0.1], inf)
		);
	out= vol * in;
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp5slicer, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, factor= 0, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1;
	var trate, dur, clk, pos, in, out, updateRate=30;
	pos = ax * bufdur; // arg X: position
	trate = (ay*99)+1;  //arg Y: trate 1..100
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(
			numChannels:2,
			trigger:clk,
			bufnum:bufnum,
			rate:(2 ** WhiteNoise.kr(2)) * frate  * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440),
			centerPos:pos * fpos,
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1), [fdur, dur ]),
			pan:WhiteNoise.kr(panidx, panshift),
			amp:vol);
	out= in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out*vol);
}).send(s);

SynthDef( \gmp6gendy, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, rotate= 0, rotfreq= 1, trigID= 60, gate= 0;
	var trate, dur, clk, pos, in, out, updateRate=30;
	pos= ax * bufdur; // arg X: position
	trate= (ay*9)+1;  //arg Y: trate 1..10
	dur= 4 / trate;
	clk= Impulse.kr(trate);
	in= RLPF.ar(
		RLPF.ar(
			Gendy2.ar(a:SinOsc.kr(0.4,0,0.05,0.05),c:SinOsc.kr(0.3,0,0.1,0.5)),
			ax.linexp(0,1,10,10000),
		0.05),
	ay.linexp(0,1,10,10000), 0.05, vol*0.05);
	in= Normalizer.ar(in, vol* 0.7);
//	in= Compander.ar(in, in,
//		thresh: 0.1,
//		slopeBelow: 1,
//		slopeAbove: 0.5,
//		clampTime: 0.01,
//		relaxTime: 0.01
//	);
	out = Pan2.ar(in, Lag.kr(LFNoise0.kr(panidx, panshift),0.5)) *EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp7latoocar, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, factor= 0, rotate= 0, rotfreq= 1, trigID= 60, gate= 0;
	var trate, dur, clk, pos, in, out, updateRate=30;
	pos= Integrator.kr(BrownNoise.kr(ax)); // arg X: position
	trate= ay.linlin(0,1,1,20);  //arg Y
	dur= 4 / trate;
//	clk= Impulse.kr(TRand.ar(trate/2, trate*2));
	clk= LatoocarfianC.ar( trate, LFNoise2.kr(2,1.5,1.5), LFNoise2.kr(2,1.5,1.5), LFNoise2.kr(2,0.5,1.5), LFNoise2.kr(2,0.5,1.5) );
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		* TGrains.ar(
			numChannels:2,
			trigger:clk,
			bufnum:bufnum,
			rate:BufRateScale.kr(bufnum),
//				* LinExp.kr(LatoocarfianC.ar( trate, LFNoise2.kr(2,1.5,1.5), LFNoise2.kr(2,1.5,1.5), LFNoise2.kr(2,0.5,1.5), LFNoise2.kr(2,0.5,1.5) ), -2.7, 2.7, 0.6, 1.4), // for some reason doesn't work in SC 3.4
			centerPos:pos,
			dur:dur,
			pan:WhiteNoise.kr(panidx, panshift),
			amp:vol
//				* LinLin.kr(
//					LatoocarfianC.ar( trate*10, LFNoise2.kr(2,1.5,1.5), LFNoise2.kr(2,1.5,1.5), LFNoise2.kr(2,0.5,1.5), LFNoise2.kr(2,0.5,1.5) ),
//					-3, 3,
//					0.01, 1
//				) // for some reason doesn't work in SC 3.4
		);
	out= in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp8chopper, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, factor= 0, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1;
	var tratectrl, trate, dur, durctrl, pos, clk, in, out, updateRate=30;
	pos = ax * bufdur; // arg X: position
	tratectrl = ay.linlin(0, 1, 2, 200); //trunc((ay*198)+2); // arg Y: durctrl 2..50
	dur = 4 / tratectrl;
	trate = Dseq([2, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
	clk = Impulse.kr(tratectrl);
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(2, clk, bufnum, trate * frate, pos * fpos, dur * fdur, Dseq([0-panidx, panidx], inf), vol);
	out= in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

//chopper for 'there are no...'
//SynthDef( \gmp3chopper, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
//	var tratectrl, trate, dur, durctrl, pos, clk;
//	pos = ax * bufdur; // arg X: position
//	tratectrl = trunc((ay*9.5)+0.5); // arg Y: durctrl 2..200
//	dur = 4 / tratectrl;
//	trate = Dseq([2, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
//	clk = Impulse.ar(tratectrl);
//	Out.ar(busnum,TGrains.ar(2, clk, bufnum, trate, pos, dur, Dseq([0-panidx, panidx], inf), vol));
//}).send(s);

SynthDef( \gmp9swirl, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 1, factor= 0, trigID= 60, gate= 0, destruct= 0, frate= 1, fpos= 1, fdur= 1;
	var trate, tratectrl, pos, dur, clk, in, out, updateRate=30, d, z, destrClk;
	pos = (ax * (bufdur - 0.2))+0.1; // arg X: position
	tratectrl = ((ay * 2.9) + 0.1); //arg Y: tratectrl, 0.1..3.0
	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
	dur = 12 / trate;
	clk = Impulse.ar(trate);
	d = { Dwhite(0.1, 0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
	destrClk= Impulse.kr(destruct*10);
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(
			numChannels: 2,
			trigger: clk,
			bufnum: bufnum,
			rate: SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
				[
					TDuty.kr(destrClk, 0, Dseq([rrand(destruct, destruct*0.7), 1, z.value, rrand(destruct, destruct*0.5), 0.5, destruct, 0.1, 0.1], inf) * pos),
					BufRateScale.kr(bufnum) * frate * (LFSaw.kr(modf, 0, 0.5*modf, 440)/440),
				]),
			centerPos: pos * fpos,
//			dur: SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
//				[
//					TDuty.kr(destrClk, 0, Dseq([destruct, d.value, destruct, z.value, destruct, destruct, z.value] * 4, inf) / trate),
//					dur
//				]),
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1),
				[fdur, dur ]),
			pan: WhiteNoise.kr(panidx, panshift),
			amp:SelectX.kr(BinaryOpUGen('==', destruct, 0) * 2,
				[
					TDuty.kr(destrClk, 0, Dseq([1, 0, max(1, z.value), 0, 0.6, 1.0, 1, 0.1, 0.1], inf)),
					vol
				]);
		);
	out= in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef( \gmp10waves, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 0, factor= 0, trigID= 60, rotfreq= 1, gate= 0, destruct= 0, frate= 1, fpos= 1, fdur= 1;
	var trate, tratectrl, pos, dur, clk, in, out, updateRate=30;
	pos = (ax * (bufdur - 0.2))+0.1; // arg X: position
	tratectrl = 0.268605; //yes, const!
	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
	dur = 12 / trate;
	clk = Impulse.ar(LinExp.kr(LFTri.kr(trate),-1,1,8,120));
	in= EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
		*TGrains.ar(
			numChannels: 2,
			trigger: clk,
			bufnum: bufnum,
			rate: BufRateScale.kr(bufnum)
				* frate
				* (SyncSaw.kr(modf, modf*0.2, 0.5*modf, 440)/440),
			centerPos: pos * fpos,
			dur: SelectX.kr(BinaryOpUGen('==', fdur, 1), [fdur, dur ]),
			pan: WhiteNoise.kr(panidx, panshift),
			amp: vol
		);
	// adding a "chord" depending on Y ControlSpec
	out= in
		+ RLPF.ar(
			PitchShift.ar(in, 0.2, 1.8, 0.01*panidx, 0.0001, [0.001, 0.800, \exp].asSpec.map(ay)),
			SinOsc.kr(tratectrl*0.5 + destruct, 0.5pi, 37, 52).midicps,
			0.1,
			[0.01, 0.5, \exp].asSpec.map(ay)
		)
		+PitchShift.ar(in, 0.2, 0.5, 0.01*panidx, 0.0001, [1.000, 0.001, \exp].asSpec.map(ay));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out);
}).send(s);

SynthDef(\gmp11loopstrch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 1, factor= 0, trigID= 60, gate= 0;
	var timescale, ratescale, trig, trigdiv, env, offset, fadeTime = 0.1, speed = 20.0, in, out, updateRate=30;
	timescale = ax * bufdur; // arg X: duration
	ratescale = (ay*1.99)+0.01; // 0..2
	trig = Impulse.kr(speed);
	trigdiv = PulseDivider.kr(trig, 2, [0,1]); // divide triggers over 2 channels
	env = Lag.kr(ToggleFF.kr(trig), fadeTime); // one signal to contol which channel is heard
	offset = Phasor.ar(0, timescale * BufRateScale.kr(bufnum), 0, BufFrames.kr(bufnum)).poll;
	in=	Pan2.ar(
			SelectL.ar( env,
				EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )
				*PlayBuf.ar(
					1,
					bufnum,
					ratescale * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
					trigdiv,
					offset,
					1.0)
				),
		\pan.asSpec.map(panidx)
	);
	out= in
		+PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
		+PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2));
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out * vol);
}).send(s);

SynthDef( \gmp12pitchsaw, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.5, vol, trigID= 60, gate= 0, inbus= 8;
	var freq, hasFreq, in, out, updateRate=30;
	in = Mix.new(InFeedback.ar(inbus));
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
//	freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
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
	Out.ar(busnum, Pan2.ar(out, panidx.linlin(0,1, -1, 1), vol * EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 )));
}).send(s);

SynthDef( \gmp13gendsl, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, trigID= 60, gate= 0;
	var trate, dur, clk, pos, in1, in2, out, updateRate=30;
	pos= ax * bufdur; // arg X: position
	trate= (ay*9)+1;  //arg Y: trate 1..10
	dur= 8 / trate;
	clk= Impulse.kr(trate);
	in1= TGrains.ar(
		numChannels:2,
		trigger:clk,
		bufnum:bufnum,
		rate:BufRateScale.kr(bufnum)
			* Gendy1.ar(1,1,1,1.0,30,100,0.3,0.05,5),
		centerPos:pos,
		dur:dur,
		pan:WhiteNoise.kr(panidx),
		amp:vol*0.5);
	in2= RLPF.ar(
		RLPF.ar(
			Gendy2.ar(a:SinOsc.kr(0.4,0,0.05,0.05),c:SinOsc.kr(0.3,0,0.1,0.5)),
			ax.linexp(0,1,10,10000),
		0.05),
	ay.linexp(0,1,10,10000),0.05, vol*0.3);
	out = Normalizer.ar(Pan2.ar(in1+in2, Lag.kr(LFNoise0.kr(panidx),0.5)), vol* 0.5)
		* EnvGen.kr( Env.asr(0.1, 1, 1, -4), gate: gate, doneAction: 2 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
	Out.ar(busnum, out );
}).send(s);

SynthDef(\gmpFreeverb2x2, { arg inbus=0, outbus=0, mix=0.25, room=0.15, damp=0.5, fxlevel=0.75, drylevel=0;
	var fx, sig;
	sig = In.ar(outbus, 2);
	fx = FreeVerb.ar(sig, mix, room, damp);
	ReplaceOut.ar(outbus, (fx*fxlevel) + (sig*drylevel));
},[0,0,0.1,0.1,0,0]).send(s);


// universal synth for recording into buffer
SynthDef( \syninbuff, {
	arg bufnum, busnum = 0, volIn = 0.8, loop= 1, dur= 1, gate= 0;
	RecordBuf.ar(
		InFeedback.ar(busnum)
		* EnvGen.kr( Env.linen(0.1, dur-0.2, 0.1, volIn, \welch), gate: Impulse.kr(gate.reciprocal) ),
		bufnum, 0, volIn, 0, 1, loop, 1
	); // envelope trigger doesn't work!!!
}).send(s);

// stereo files playback with phasing
SynthDef(\gmpLoopStereo, { arg trigID= 10, out= 0, bufnum= 0, vol= 0.0, pan= 1, trig= 0, rate= 1.0, startPos= 0, startLoop= 0, endLoop, lag= 0, gate= 1, timescale= 0;
	var updateRate=10, playbuf, signal, phase, shiftTrig;
	shiftTrig= SelectX.ar(BinaryOpUGen('==', timescale, 0), [ Impulse.ar(timescale), Silent.ar ]);
	phase= Phasor.ar(shiftTrig, BufRateScale.kr(bufnum) * rate, startPos, endLoop, startLoop);
	playbuf= vol
		* EnvGen.kr( Env.asr(0.1, 1, 0.1, 4), gate: gate, doneAction: 2 )
		* SelectX.ar(BinaryOpUGen('==', lag, 0) * 2, [
			PlayBufCF.ar(2, bufnum, rate*BufRateScale.ir(bufnum), Impulse.kr((trig*rate-lag).reciprocal), startPos, 1, lag),
			BufRd.ar(2, bufnum, phase)
		]);
	signal= [ playbuf.at(0) * (1-pan).min(1),  playbuf.at(1) * (1+pan).min(1) ]; //manual panning
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(signal.at(0))); //LEFT
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(signal.at(1))); //RIGHT
	SendTrig.kr(Impulse.kr(updateRate), trigID+2, phase); //PHASE for playback position
	Out.ar(out, signal);
}).send(s);

// mono files playback with phasing
SynthDef(\gmpLoopMono, { arg trigID= 10, out= 0, bufnum= 0, vol= 0.0, pan= 1, trig= 1, rate= 1.0, startPos= 0, startLoop= 0, endLoop= 1000, lag= 0, gate= 1, timescale= 0;
	var updateRate=10, playbuf, signal, phase, shiftTrig;
	shiftTrig= SelectX.ar(BinaryOpUGen('==', timescale, 0), [ Impulse.ar(timescale), Silent.ar ]);
	phase= Phasor.ar(shiftTrig, BufRateScale.kr(bufnum) * rate, startPos, endLoop, startLoop);
	playbuf= vol
		* EnvGen.kr( Env.asr(0.1, 1, 0.1, 4), gate: gate, doneAction: 2 )
		* SelectX.ar(BinaryOpUGen('==', lag, 0) * 2, [
			PlayBufCF.ar(1, bufnum, rate*BufRateScale.ir(bufnum), Impulse.kr((trig*rate-lag).reciprocal), startPos, 1, lag),
			BufRd.ar(1, bufnum, phase)
		]);
	signal= Pan2.ar(playbuf, pan);
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(signal.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(signal.at(1)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+2, phase); //PHASE for playback position
	Out.ar(out, signal);
}).send(s);

SynthDef(\gmpLoopStereoFFT, { arg trigID= 10, out= 0, bufnum= 0, fftbufnum, vol= 0.0, pan= 1, trig= 0, rate= 1.0, startPos= 0, startLoop= 0, endLoop, lag= 0, gate= 0, timescale= 0;
	var updateRate=10, playbuf, signal, phase, shiftTrig, chain;
	shiftTrig= Impulse.ar(timescale);
	phase= Phasor.ar(0, BufRateScale.kr(bufnum) * rate, startPos, endLoop, startLoop); // what should be resetPos???!!!
	playbuf= vol
		* EnvGen.kr( Env.asr(0.1, 1, 0.1, 4), gate: gate, doneAction: 2 )
		* SelectX.ar(BinaryOpUGen('==', lag, 0) * 2, [
			PlayBufCF.ar(2, bufnum, rate*BufRateScale.ir(bufnum), Impulse.kr((trig*rate-lag).reciprocal), startPos, 1, lag),
			BufRd.ar(2, bufnum, phase, 1, 4)
		]);
	signal= [ playbuf.at(0) * (1-pan).min(1),  playbuf.at(1) * (1+pan).min(1) ]; //manual panning
	chain = FFT(fftbufnum, signal);
	chain = PV_MagFreeze(chain, timescale > 0.5 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(signal.at(0))); //LEFT
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(signal.at(1))); //RIGHT
	SendTrig.kr(Impulse.kr(updateRate), trigID+2, phase); //PHASE for playback position
	//Out.ar(out, signal);
	Out.ar(out, IFFT(chain, 0).dup);
}, #[0.05]).send(s);

SynthDef(\gmpLoopMonoFFT, { arg trigID= 10, out= 0, bufnum= 0, fftbufnum, vol= 0.0, pan= 1, trig= 0, rate= 1.0, startPos= 0, startLoop= 0, endLoop= 1000, lag= 0, gate= 0, timescale= 0;
	var updateRate=10, playbuf, signal, phase, shiftTrig, chain;
	shiftTrig= Impulse.ar(timescale);
	phase= Phasor.ar(0, BufRateScale.kr(bufnum) * rate, startPos, endLoop, startLoop);
	playbuf= vol
		* EnvGen.kr( Env.asr(0.1, 1, 0.1, 4), gate: gate, doneAction: 2 )
		* SelectX.ar(BinaryOpUGen('==', lag, 0) * 2, [
			PlayBufCF.ar(1, bufnum, rate*BufRateScale.ir(bufnum), Impulse.kr((trig*rate-lag).reciprocal), startPos, 1, lag),
			BufRd.ar(1, bufnum, phase, 4)
		]);
	signal= Pan2.ar(playbuf, pan);
	chain = FFT(fftbufnum, signal);
	chain = PV_MagFreeze(chain, timescale > 0.5 );
	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(signal.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(signal.at(1)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+2, phase); //PHASE for playback position
	//Out.ar(out, signal);
	Out.ar(out, IFFT(chain, 0).dup);
}, #[0.05]).send(s);

// used in granulator_waves
SynthDef(\sgrain2, {arg bufnum=0, rate=1, pan=0.0, startPos=0.0, dur=0.08, amp=0.6, vol= 0, busnum=0;
	var grain;
	grain = PlayBuf.ar(1, bufnum, rate*BufRateScale.kr(bufnum), 1, BufFrames.ir(bufnum)*startPos, 0)
		*(EnvGen.kr(Env.sine(dur,amp * vol),doneAction:2)-0.001);
	Out.ar(busnum,Pan2.ar(grain, pan))
}).send(s);


// used in granulator_waves
SynthDef(\sgrain1, {arg bufnum=0, rate=1, pan=0.0, startPos=0.0, dur=0.08, amp=0.6, busnum=0;
	var grain;
	grain = PlayBuf.ar(1, bufnum, rate*BufRateScale.kr(bufnum), 1, BufFrames.ir(bufnum)*startPos, 0)
		*(EnvGen.kr(Env.perc(0.03,dur,amp),doneAction:2)-0.001);
	Out.ar(busnum,Pan2.ar(grain, pan))
}).send(s);

//WIDYMO
SynthDef( \scaledrone, {
	arg freq1= 62, freq2= 294, freq3= 2960,
		fmod1= 0.11, fmod2= 0.22, fmod3= 0.33,
		fmoda1= 1, fmoda2= 1, fmoda3= 1,
		pmod1= 0.1, pmod2= 0.2, pmod3= 0.3,
		amod1= 0.01, amod2= 0.001, amod3= 0.001,
		amoda1= 0.05, amoda2= 0.2, amoda3= 0.2,
		smod= 0.13, smoda= 5, smodm= 6,
		smodaa= 8, smodmm= 50,
		cmod= 1.2, cmoda= 0.6,
		room= 20, reverb= 5, damp= 1, input= 0.5, spread= 25, dry= 0, early= 1, tail= 1,
		amp= 0.7, outbus= 0;
	var signal, out;
	signal= Limiter.ar(
		LeakDC.ar(
			GVerb.ar(
				Splay.ar(
					SinOsc.ar(
						[freq1, freq2, freq3]
						+SinOsc.ar( [fmod1, fmod2, fmod3], 0, [fmoda1, fmoda2, fmoda3] ),
						SinOsc.ar(
							[pmod1, pmod2, pmod3], 0, 2pi),
							SinOsc.ar( [amod1, amod2, amod3], 0, [amoda1, amoda2, amoda3] )
					),
					SinOsc.ar(
						SinOsc.ar(
							SinOsc.ar(smod, 0, smoda, smodm), 0, smodaa, smodmm
						), 0, 1, 1
					), amp, SinOsc.ar(cmod, 0, cmoda)
				), room, reverb, damp, input, spread, dry, early, tail
			)
		)
	);
	out= signal;
	Out.ar(outbus, out);
}, #[0.02]).send(s);

SynthDef(\krdgAbMin2, { arg outbus= 0, modval= 127;
	var freq2, workScale = FloatArray[ 0, 3, 7 ]; // minor
	freq2= DegreeToKey.kr(LocalBuf.newFrom(workScale), modval.linlin(0, 127, 0, 15), 12, 1, 56).midicps; // 56 - Ab2
	Out.kr(outbus, freq2)
}).send(s);

SynthDef(\krdgAbMin3, { arg outbus= 1, modval= 127;
	var freq3, workScale = FloatArray[ 0, 3, 7 ]; // minor
	freq3= DegreeToKey.kr(LocalBuf.newFrom(workScale), modval.linlin(0, 127, 0, 15), 12, 1, 80).midicps; // 80 - Ab4
	Out.kr(outbus, freq3)
}).send(s);

SynthDef(\krdgBMaj2, { arg outbus= 2, modval= 127;
	var freq2, workScale = FloatArray[ 0, 4, 7 ]; // major
	freq2= DegreeToKey.kr(LocalBuf.newFrom(workScale), modval.linlin(0, 127, 0, 15), 12, 1, 56).midicps; // 59 - B2
	Out.kr(outbus, freq2)
}).send(s);

SynthDef(\krdgBMaj3, { arg outbus= 3, modval= 127;
	var freq3, workScale = FloatArray[ 0, 4, 7 ]; // major
	freq3= DegreeToKey.kr(LocalBuf.newFrom(workScale), modval.linlin(0, 127, 0, 15), 12, 1, 83).midicps; // 83 - B4
	Out.kr(outbus, freq3)
}).send(s);

SynthDef(\krdgDbMaj2, { arg outbus= 4, modval= 127;
	var freq2, workScale = FloatArray[ 0, 4, 7 ]; // major
	freq2= DegreeToKey.kr(LocalBuf.newFrom(workScale), modval.linlin(0, 127, 0, 15), 12, 1, 49).midicps; // 49 - Db2
	Out.kr(outbus, freq2)
}).send(s);

SynthDef(\krdgDbMaj3, { arg outbus= 5, modval= 127;
	var freq3, workScale = FloatArray[ 0, 4, 7 ]; // major
	freq3= DegreeToKey.kr(LocalBuf.newFrom(workScale), modval.linlin(0, 127, 0, 15), 12, 1, 85).midicps; // 85 - Db5
	Out.kr(outbus, freq3)
}).send(s);
//WIDYMO


//PG_L1
// ---- SYNTHS ----
SynthDef(\pgl1_lflow, { arg dryBus= 0, wetBus, mod= 0, panidx= 0.8, panshift= 0, amp= 0.1, dry= 0.5, mnote= 0, att= 0.25, rel= 1, crva= 3, crvr= -3, gate= 1, done= 2;
	var env, out, scale = FloatArray[0,2,5,7,10]; // scale
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: done );
	out= Pan2.ar(
		LPF.ar(
			LFSaw.ar( mnote + LinLin.kr(mod, -1, 1, 0.01, MouseY.kr(1.5, 0.02, 1))*100 + #[300, 301, 80, 81], 0, 0.8 ).mean,
		2000),
		mod*panidx,
		amp*mod.linlin(-1, 1, 0.3, 1)
	);
	Out.ar(dryBus, env * out);
	Out.ar(wetBus, env * out * (1 - dry));
}).send(s);

SynthDef(\pgl1_lfmid, { arg dryBus= 0, wetBus, mod= 0, panidx= 0.8, panshift= 0, amp= 0.1, dry= 0.5, mnote= 0, att= 0.25, rel= 1, crva= 3, crvr= -3, gate= 1, done= 2;
	var env, out;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: done );
	out= Pan2.ar(
		RLPF.ar(
			LFSaw.ar(mnote + LinLin.kr(mod, -1, 1, 0.1, 54) + #[300, 301, 80, 81], 0, 0.8).mean,
			LinLin.kr(mod, -1, 1, 10, 102).midicps, 0.1, 1
		) * 0.5,
		mod * [1, -1].choose * panidx,
		amp * mod.linlin(-1,1, 0.2, 0.4)
	);
	Out.ar(dryBus, env * out);
	Out.ar(wetBus, env * out * (1 - dry));
}).send(s);

SynthDef(\pgl1_lfmip, { arg dryBus= 0, wetBus, mod= 0, panidx= 0.8, panshift= 0, amp= 0.1, dry= 0.5, mnote= 0, att= 0.25, rel= 1, crva= 3, crvr= -3, gate= 1, done= 2, freqBase= 85;
	var env, out;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: done );
	out= Pan2.ar(
			RLPF.ar(
				LFSaw.ar(mnote + freqBase + mod.linlin(-1,1, -40, 40)),
				LinLin.kr(mod, -1, 1, 80, 30).midicps, 0.1, 1
			) * 0.5,
		mod * [1, -1].choose * panidx,
		amp * mod.linlin(-1,1, 0.01, 0.2)
	);
	Out.ar(dryBus, env * out);
	Out.ar(wetBus, env * out * (1 - dry));
}).send(s);

SynthDef(\pgl1_lfs, { arg dryBus= 0, wetBus, mod= 0, panidx= 0.8, panshift= 0, amp= 0.1, dry= 0.5, freqBase=85, mnote= 0, att= 0.25, rel= 1, crva= 3, crvr= -3, gate= 1, done= 2;
	var env, out;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: done );
	out= Pan2.ar(
		LFSaw.ar(mnote + freqBase + mod.linlin(-1,1, -50, 0)),
		mod * [1, -1].choose,
		amp * mod.linlin(-1,1, 0.1, 0.3) * 0.3
	);
	Out.ar(dryBus, env * out);
	Out.ar(wetBus, env * out * (1 - dry));
}).send(s);

//sum effect synth
SynthDef(\pgl1_comb, { arg outBus= 30, inBus;
	var input;
	input = In.ar(inBus, 2);
	CombN.ar(input, 0.31, 0.31, 2);
	Out.ar(outBus, input);
}).send(s);

//control synths - mod
SynthDef(\kr_ml0, { arg outbus= 0, att= 0.1, rel= 1, crva= -3, crvr= 3, gate= 1;
	var env, mod;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	mod= env * LorenzL.ar( SinOsc.kr(0.1,20,0.49,0.51), LFNoise0.kr(5, 1, 25), LFNoise0.kr(1, 2, 15), LFNoise0.kr(10, 2, 1) );
	Out.kr(outbus, mod)
}).send(s);

SynthDef(\kr_mg2, { arg outbus= 0, att= 0.1, rel= 1, crva= -3, crvr= 3, gate= 1;
	var env, mod;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	mod= env * Gendy3.kr(2,30,SinOsc.kr(1,0,0.49,0.51),LFNoise0.kr(5, 1, 25), 0.05, SinOsc.kr(0.1,0,0.3,0.1), SinOsc.kr(0.19,0,0.49,0.51),12,10);
	Out.kr(outbus, mod)
}).send(s);

SynthDef(\kr_mg0, { arg outbus= 0, att= 0.1, rel= 1, crva= -3, crvr= 3, gate= 1;
	var env, mod;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	mod= env * Gendy3.kr(6,30,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51), 0.1, SinOsc.kr(0.27,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51),12,10);
	Out.kr(outbus, mod)
}).send(s);

SynthDef(\kr_mg1, { arg outbus= 0, freq= 1, att= 0.1, rel= 1, crva= -3, crvr= 3, gate= 1;
	var env, mod;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	mod= env * Gendy2.ar(minfreq: freq, maxfreq: freq*5, a:SinOsc.kr(0.4,0,0.05,0.05), c:SinOsc.kr(0.3,0,0.1,0.5), minfreq:0.1);
	Out.kr(outbus, mod)
}).send(s);

SynthDef(\kr_ml1, { arg outbus= 0, freq=100, att= 0.1, rel= 1, crva= -3, crvr= 3, gate= 1;
	var env, mod;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	mod= env * LorenzL.ar( freq, LFNoise0.kr(1, 2, 10), LFNoise0.kr(1, 20, 38), LFNoise0.kr(1, 1.5, 2) );
	Out.kr(outbus, mod)
}).send(s);

SynthDef(\kr_mh0, { arg outbus= 0, att= 0.1, rel= 1, crva= -3, crvr= 3, gate= 1;
	var env, mod;
	env= EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
	mod= env * HenonC.ar( MouseX.kr(1, 200), LFNoise0.kr(1, 0.2, 1.2), LFNoise0.kr(1, 0.15, 0.15) );
	Out.kr(outbus, mod)
}).send(s);

// help synths for automatic composition
SynthDef(\p_bowedstring, { arg freq = 440, gate = 1, dec= 0.3, amp = 0.5, slideTime = 0.17, ffreq = 1100;
	var	sig, env = Env.adsr(0.01, dec, 0.4, 0.1);
	freq = Lag.kr(freq, slideTime);
	sig = Klank.ar(`[
			Array.series(12, freq, freq),
			Array.geom(12, 1, rrand(0.7,0.9)),
			Array.fill(12, {rrand(1.0,3.0)})
		], {ClipNoise.ar(0.003)}.dup).softclip
		* amp
		* EnvGen.kr(env, gate, doneAction: 2);
	sig = LPF.ar(sig, ffreq);
	Out.ar(0, sig ! 2)
}).send(s);

SynthDef(\p_piano, { arg freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100;
	var	sig, delayTime, detune, strike, hammerEnv, hammer, env = Env.adsr(0.01, 0.3, 0.4, 0.1);
	freq = Lag.kr(freq, slideTime);
	strike = Impulse.ar(0.1+0.4.rand, 2pi.rand, 0.1); // random period for each key
	hammerEnv = Decay2.ar(strike, 0.008, 0.04); // excitation envelope
	sig= Pan2.ar(
			// array of 3 strings per note
			Mix.ar(Array.fill(3, { arg i;
				// detune strings, calculate delay time :
				detune = #[-0.05, 0, 0.04].at(i);
				delayTime = 1 / (freq.cpsmidi + detune).midicps;
				// each string gets own exciter :
				hammer = LFNoise2.ar(3000, hammerEnv); // 3000 Hz was chosen by ear..
				CombL.ar(hammer,		// used as a string resonator
					delayTime, 		// max delay time
					delayTime,			// actual delay time
					6) 				// decay time of string
			})),
			Rand(-0.5, 0.5)
		)
		* amp
		* EnvGen.kr(env, gate, doneAction: 2);
	sig = LPF.ar(sig, ffreq);
	Out.ar(0, sig ! 2)
}).send(s);