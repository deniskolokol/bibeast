
//=== synths' def ====
// used in granulator_waves

SynthDef(\sgrain2, {arg bufnum=0, rate=1, pan=0.0, startPos=0.0, dur=0.08, amp=0.6, busnum=0;


	var grain;
	grain = PlayBuf.ar(1, bufnum, rate*BufRateScale.kr(bufnum), 1, BufFrames.ir(bufnum)*startPos, 0)
		*(EnvGen.kr(Env.sine(dur,amp),doneAction:2)-0.001);
	Out.ar(busnum,Pan2.ar(grain, pan))
}).send(s);



// used in granMultiPad 4 channel
//temporarily stereo

SynthDef( \gmp0drone4ch, {


	arg busnum = 0, bufnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1, factor= 1, trigID= 60;
	var trate = 1, pos, dur, clk, in, out, outC, outR, updateRate=40;
	trate = (ay * 112) + 8; //arg Y - trate, 8..120
	dur = 12 / trate;
	clk = Impulse.kr(trate);
	pos = ax * bufdur + TRand.kr(0, 0.01, clk); // arg X - position

	in= TGrains.ar(
		numChannels: 2,
		trigger: clk,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum)
			* (SinOsc.kr(modf, 0, 0.5*modf, 440)/440)
			* factor,
		centerPos: pos,
		dur: dur,
		pan: WhiteNoise.kr(panidx),
		amp: vol
	);
	out= PitchShift.ar(in, 0.2, 1.25, 0.01*panidx, 0.0001, 0.1)
		+PitchShift.ar(in, 0.2, 0.5,  0.01*panidx, 0.0001, 0.2);

	outC = in+out;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in+out), 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);

	SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(outC.at(0)));
	SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(outC.at(1)));

	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);




SynthDef( \gmp1shake4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
	var trate = 1, pos, dur, clk, in, out, outC, outR;
	pos = ax * bufdur; // arg X: position
	trate = (ay * 59) + 1; //arg Y: trate, 1..60
	dur = 4 / trate;
	clk = Dust.kr(trate);

	in= TGrains.ar(
		numChannels: 2,
		trigger: clk,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
		centerPos: pos + TRand.kr(0, 0.01, clk),
		dur: dur,
		pan: WhiteNoise.kr(panidx),
		amp: vol
	);
	out= PitchShift.ar(in, 0.2, 1.25, 0.01*panidx, 0.0001, 0.15)
		+PitchShift.ar(in, 0.2, 0.5,  0.01*panidx, 0.0001, 1);

	outC = in+out;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in+out), 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);



SynthDef( \gmp2swirl4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
	var trate, tratectrl, pos, dur, clk, in, out, outC, outR;
	pos = (ax * (bufdur - 0.2))+0.1; // arg X: position
	tratectrl = (ay * 2.9) + 0.1; //arg Y: tratectrl, 0.1..3.0
	//tratectrl = (ay * 0.99) + 0.01; //arg Y: tratectrl, 0.01..1
	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
	dur = (12 / trate);
	clk = Impulse.ar(trate);
	in= TGrains.ar(
		numChannels: 2,
		trigger: clk,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
		centerPos: pos,
		dur: dur,
		pan: WhiteNoise.kr(panidx),
		amp: vol
	);
	// adding a "chord" only on the highest trates
	out= PitchShift.ar(in, 0.2, 1.25, 0.01*panidx, 0.0001, trate*0.0025)
		+PitchShift.ar(in, 0.2, 0.5,  0.01*panidx, 0.0001, trate*0.0080);

	outC = in+out;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in+out), 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);



SynthDef( \gmp3waves4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
	var trate, tratectrl, pos, dur, clk, in, out, outC, outR;
	pos = (ax * (bufdur - 0.2))+0.1; // arg X: position
	tratectrl = 0.268605; //yes, const!
	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
	dur = (12 / trate);
	clk = Impulse.ar(LinExp.kr(LFTri.kr(trate),-1,1,8,120));
	in= TGrains.ar(
		numChannels: 2,
		trigger: clk,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
		centerPos: pos,
		dur: dur,
		pan: WhiteNoise.kr(panidx),
		amp: vol
	);
	// adding a "chord" depending on Y ControlSpec
	out= RLPF.ar(
			PitchShift.ar(in, 0.2, 1.8, 0.01*panidx, 0.0001, [0.001, 0.800, \exp].asSpec.map(ay)),
			SinOsc.kr(tratectrl*0.5, 0.5pi, 37, 52).midicps,
			0.1,
			[0.01, 0.3, \exp].asSpec.map(ay)
		)
		+PitchShift.ar(in, 0.2, 0.5, 0.01*panidx, 0.0001, [1.000, 0.001, \exp].asSpec.map(ay));

	outC = in+out;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in+out), 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);



SynthDef( \gmp4chop4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
	var tratectrl, trate, dur, durctrl, pos, clk, in, outC, outR;
	pos = ax * bufdur; // arg X: position
	tratectrl = trunc((ay*198)+2); // arg Y: durctrl 2..200
	dur = 4 / tratectrl;
	trate = Dseq([10, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
	clk = Impulse.ar(tratectrl);

	in= TGrains.ar(2, clk, bufnum, trate, pos, dur, Dseq([0-panidx, panidx], inf), vol);

	outC = in;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in),	 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);




SynthDef( \gmp5fount4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1, factor= 1;
	var trate, dur, clk, pos, in, outC, outR;
	//trate = (ay*49)+1; //arg Y: trate 1..50
	trate = (ay*49.9)+0.1; //arg Y: trate 0.1..50
	dur = 4 / trate;
	clk = Impulse.kr(trate);
	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
	in= TGrains.ar(
		numChannels: 2,
		trigger: clk,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum)
			* (SinOsc.kr(modf, 0, 0.5*modf, 440)/440)
			* factor,
		//rate: Dseq([1, 1.1, 0.9, 0.8, 0.9, 1, 1, 1.1, 1.2, 0.9, 0.8, 0.2], inf),
		centerPos: pos,
		dur: dur,
		pan: WhiteNoise.kr(panidx),
		amp: vol
	);

	outC = in;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in),	 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);




SynthDef( \gmp6exciter4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
	var trate, clk, pos, d, z, in, outC, outR;
	pos = pos = ax * bufdur; // arg X: position
	trate = (ay*9)+1; // arg Y: trate 1..10
	clk = Impulse.kr(trate);
	d = { Dwhite(0.2, 0.5, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };

	in= TGrains.ar(2, clk, bufnum,
		rate: Dseq([0.1, 1, z.value, 0.5, ay/2, 0.2, 0.1, 0.1, d.value, ay*0.7.rand], inf) * pos + 1,
		centerPos: pos + TRand.kr(0, 0.01, clk),
		dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
		pan:WhiteNoise.kr(panidx),
		amp:Dseq([0.8, 0, 1, 0, 0.9, 1.0, 1, 0.1, 0.1], inf) * vol
	);

	outC = in;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in),	 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);




SynthDef( \gmp7stutt4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
	var trate, dur, clk, pos, d, z, in, outC, outR;
	pos = round((ax*0.19)+0.1, 0.01); // arg X: position
	trate = (ay*19)+1; //arg Y: trate 1..20 how to make it exponential?
	clk = Impulse.ar(trate * 10);
	d = { Dwhite(0.1, 0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };

	in= TGrains.ar(2, clk, bufnum,
		rate:Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * pos + 1,
		centerPos: Dseq(z.dup(8), inf) / pos,
		dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
		pan:Dseq([0-panidx, 0-(panidx/2), 0-(panidx/4), 0-(panidx/6), 0, panidx/6, panidx/4, panidx/2, panidx], inf) * 2 - 1,
		amp: Dseq([1, 0, max(1, z.value), 0, 0.6, 1.0, 1, 0.1, 0.1], inf) * vol
	);

	outC = in;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in),	 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);





SynthDef( \gmp8slice4ch, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
	var trate, dur, clk, pos, in, outC, outR;
	pos = ax * bufdur; // arg X: position


	trate = (ay*99)+1;  //arg Y: trate 1..100


	dur = 8 / trate;


	clk = Impulse.kr(trate);

	in= TGrains.ar(2, clk, bufnum, 2 ** WhiteNoise.kr(2), pos, dur, WhiteNoise.kr(panidx), vol);



	outC = in;
	outR = PanAz.ar(
		2, 				 					//numChans
		Mix.new(in),	 					//in
		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
		vol,			 					//level
		[0.5, 4.0].asSpec.map(panidx)		//width
	);
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);



SynthDef( \gmp10gendy, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
	var trate, dur, clk, pos, in1, in2, outC, outR;
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

	outC = Normalizer.ar(Pan2.ar(in1+in2, Lag.kr(LFNoise0.kr(panidx),0.5)), vol* 0.3);


	outR = PanAz.ar(2,Mix.new(in1+in2),LFSaw.kr(rotfreq, 0.5pi)*rotate,vol,[0.5, 4.0].asSpec.map(panidx));
	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
}).send(s);

//SynthDef( \gmp10gendy, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
//	var trate, dur, clk, pos, in, outC, outR;
//	pos= ax * bufdur; // arg X: position
//	trate= (ay*9)+1;  //arg Y: trate 1..10


//	dur= 8 / trate;


//	clk= Impulse.kr(trate);


//
//	in= Normalizer.ar(
//			RLPF.ar(
//				RLPF.ar(
//
//					TGrains.ar(
//					numChannels:2,
//					trigger:clk,
//					bufnum:bufnum,
//					rate:BufRateScale.kr(bufnum)
//						* Gendy2.kr(a:SinOsc.kr(0.4,0,0.05,0.05),c:SinOsc.kr(0.3,0,0.1,0.5)).poll,
//					centerPos:pos,
//					dur:dur,
//					pan:Lag.kr(LFNoise0.kr(panidx),0.5)),
//				ax.linexp(0,1,10,10000), 0.05
//				),
//			ay.linexp(0,1,10,10000), 0.05),
//		vol, 0.01);
//
//	outC = in;


//	outR = PanAz.ar(2,Mix.new(in),LFSaw.kr(rotfreq, 0.5pi)*rotate,vol,[0.5, 4.0].asSpec.map(panidx));
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);



//SynthDef( \gmp9dust4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
//	var trate, dur, clk, pos, in, outC, outR;
//	trate = (ay*4.99)+0.01; //arg Y: trate 0.1..5
//	dur = 1 / trate;
//	clk = Dust.kr(trate);
//	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
//
//	in= TGrains.ar(
//		numChannels: 2,
//		trigger: clk,
//		bufnum: bufnum,
//		rate: BufRateScale.kr(bufnum),
//		centerPos: pos,
//		dur: Dseq([0.1, rrand(0.1, dur), 0.01, 0.05, 0.1], inf),
//		pan: Dseq([0-panidx, 0-(panidx/2), 0-(panidx/4), 0-(panidx/6), 0, panidx/6, panidx/4, panidx/2, panidx], inf) * 2 - 1,
//		amp: vol
//	);
//
//	outC = in;
//	outR = PanAz.ar(
//		2, 				 					//numChans
//		Mix.new(in),	 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);



//4ch temporarily switched off




//SynthDef( \gmp0drone4ch, {
//	arg busnum = 0, bufnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
//	var trate = 1, pos, dur, clk, in, out, outC, outR;
//	trate = (ay * 112) + 8; //arg Y - trate, 8..120
//	dur = 12 / trate;
//	clk = Impulse.kr(trate);
//	pos = ax * bufdur + TRand.kr(0, 0.01, clk); // arg X - position
//
//	in= TGrains.ar(
//		numChannels: 4,
//		trigger: clk,
//		bufnum: bufnum,
//		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
//		centerPos: pos,
//		dur: dur,
//		pan: WhiteNoise.kr(panidx),
//		amp: vol
//	);
//	out= PitchShift.ar(in, 0.2, 1.25, 0.01*panidx, 0.0001, 0.15)
//		+PitchShift.ar(in, 0.2, 0.5,  0.01*panidx, 0.0001, 1);
//
//	outC = in+out;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in+out), 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//
//SynthDef( \gmp1shake4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
//	var trate = 1, pos, dur, clk, in, out, outC, outR;
//	pos = ax * bufdur; // arg X: position
//	trate = (ay * 59) + 1; //arg Y: trate, 1..60
//	dur = 4 / trate;
//	clk = Dust.kr(trate);
//
//	in= TGrains.ar(
//		numChannels: 4,
//		trigger: clk,
//		bufnum: bufnum,
//		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
//		centerPos: pos + TRand.kr(0, 0.01, clk),
//		dur: dur,
//		pan: WhiteNoise.kr(panidx),
//		amp: vol
//	);
//	out= PitchShift.ar(in, 0.2, 1.25, 0.01*panidx, 0.0001, 0.15)
//		+PitchShift.ar(in, 0.2, 0.5,  0.01*panidx, 0.0001, 1);
//
//	outC = in+out;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in+out), 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//SynthDef( \gmp2swirl4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
//	var trate, tratectrl, pos, dur, clk, in, out, outC, outR;
//	pos = (ax * (bufdur - 0.2))+0.1; // arg X: position
//	tratectrl = (ay * 2.9) + 0.1; //arg Y: tratectrl, 0.1..3.0
//	//tratectrl = (ay * 0.99) + 0.01; //arg Y: tratectrl, 0.01..1
//	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
//	dur = (12 / trate);
//	clk = Impulse.ar(trate);
//	in= TGrains.ar(
//		numChannels: 4,
//		trigger: clk,
//		bufnum: bufnum,
//		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
//		centerPos: pos,
//		dur: dur,
//		pan: WhiteNoise.kr(panidx),
//		amp: vol
//	);
//	// adding a "chord" only on the highest trates
//	out= PitchShift.ar(in, 0.2, 1.25, 0.01*panidx, 0.0001, trate*0.0025)
//		+PitchShift.ar(in, 0.2, 0.5,  0.01*panidx, 0.0001, trate*0.0080);
//
//	outC = in+out;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in+out), 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//SynthDef( \gmp3waves4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
//	var trate, tratectrl, pos, dur, clk, in, out, outC, outR;
//	pos = (ax * (bufdur - 0.2))+0.1; // arg X: position
//	tratectrl = 0.268605; //yes, const!
//	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
//	dur = (12 / trate);
//	clk = Impulse.ar(LinExp.kr(LFTri.kr(trate),-1,1,8,120));
//	in= TGrains.ar(
//		numChannels: 4,
//		trigger: clk,
//		bufnum: bufnum,
//		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
//		centerPos: pos,
//		dur: dur,
//		pan: WhiteNoise.kr(panidx),
//		amp: vol
//	);
//	// adding a "chord" depending on Y ControlSpec
//	out= RLPF.ar(
//			PitchShift.ar(in, 0.2, 1.8, 0.01*panidx, 0.0001, [0.001, 0.800, \exp].asSpec.map(ay)),
//			SinOsc.kr(tratectrl*0.5, 0.5pi, 37, 52).midicps,
//			0.1,
//			[0.01, 0.3, \exp].asSpec.map(ay)
//		)
//		+PitchShift.ar(in, 0.2, 0.5, 0.01*panidx, 0.0001, [1.000, 0.001, \exp].asSpec.map(ay));
//
//	outC = in+out;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in+out), 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//SynthDef( \gmp4chop4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
//	var tratectrl, trate, dur, durctrl, pos, clk, in, outC, outR;
//	pos = ax * bufdur; // arg X: position
//	tratectrl = trunc((ay*198)+2); // arg Y: durctrl 2..200
//	dur = 4 / tratectrl;
//	trate = Dseq([10, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
//	clk = Impulse.ar(tratectrl);
//
//	in= TGrains.ar(4, clk, bufnum, trate, pos, dur, Dseq([0-panidx, panidx], inf), vol);
//
//	outC = in;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in),	 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//
//SynthDef( \gmp5fount4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
//	var trate, dur, clk, pos, in, outC, outR;
//	//trate = (ay*49)+1; //arg Y: trate 1..50
//	trate = (ay*49.9)+0.1; //arg Y: trate 0.1..50
//	dur = 4 / trate;
//	clk = Impulse.kr(trate);
//	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
//	in= TGrains.ar(
//		numChannels: 4,
//		trigger: clk,
//		bufnum: bufnum,
//		rate: BufRateScale.kr(bufnum) * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
//		centerPos: pos,
//		dur: dur,
//		pan: WhiteNoise.kr(panidx),
//		amp: vol
//	);
//
//	outC = in;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in),	 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//
//SynthDef( \gmp6exciter4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
//	var trate, clk, pos, d, z, in, outC, outR;
//	pos = pos = ax * bufdur; // arg X: position
//	trate = (ay*9)+1; // arg Y: trate 1..10
//	clk = Impulse.kr(trate);
//	d = { Dwhite(0.2, 0.5, 1) };
//	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
//
//	in= TGrains.ar(4, clk, bufnum,
//		rate: Dseq([0.1, 1, z.value, 0.5, ay/2, 0.2, 0.1, 0.1, d.value, ay*0.7.rand], inf) * pos + 1,
//		centerPos: pos + TRand.kr(0, 0.01, clk),
//		dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
//		pan:WhiteNoise.kr(panidx),
//		amp:Dseq([0.8, 0, 1, 0, 0.9, 1.0, 1, 0.1, 0.1], inf) * vol
//	);
//
//	outC = in;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in),	 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//
//SynthDef( \gmp7stutt4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
//	var trate, dur, clk, pos, d, z, in, outC, outR;
//	pos = round((ax*0.19)+0.1, 0.01); // arg X: position
//	trate = (ay*19)+1; //arg Y: trate 1..20 how to make it exponential?
//	clk = Impulse.ar(trate * 10);
//	d = { Dwhite(0.1, 0.2, 1) };
//	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
//
//	in= TGrains.ar(4, clk, bufnum,
//		rate:Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * pos + 1,
//		centerPos: Dseq(z.dup(8), inf) / pos,
//		dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
//		pan:Dseq([0-panidx, 0-(panidx/2), 0-(panidx/4), 0-(panidx/6), 0, panidx/6, panidx/4, panidx/2, panidx], inf) * 2 - 1,
//		amp: Dseq([1, 0, max(1, z.value), 0, 0.6, 1.0, 1, 0.1, 0.1], inf) * vol
//	);
//
//	outC = in;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in),	 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//
//
//SynthDef( \gmp8slice4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, rotate= 0, rotfreq= 1;
//	var trate, dur, clk, pos, in, outC, outR;


//	pos = ax * bufdur; // arg X: position


//	trate = (ay*99)+1;  //arg Y: trate 1..100


//	dur = 8 / trate;
//	clk = Impulse.kr(trate);
//
//	in= TGrains.ar(4, clk, bufnum, 2 ** WhiteNoise.kr(2), pos, dur, WhiteNoise.kr(panidx), vol);


//
//	outC = in;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in),	 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
//
//
//SynthDef( \gmp9dust4ch, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol, modf = 1, rotate= 0, rotfreq= 1;
//	var trate, dur, clk, pos, in, outC, outR;
//	trate = (ay*4.99)+0.01; //arg Y: trate 0.1..5
//	dur = 1 / trate;
//	clk = Dust.kr(trate);
//	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
//
//	in= TGrains.ar(
//		numChannels: 4,
//		trigger: clk,
//		bufnum: bufnum,
//		rate: BufRateScale.kr(bufnum),
//		centerPos: pos,
//		dur: Dseq([0.1, rrand(0.1, dur), 0.01, 0.05, 0.1], inf),
//		pan: Dseq([0-panidx, 0-(panidx/2), 0-(panidx/4), 0-(panidx/6), 0, panidx/6, panidx/4, panidx/2, panidx], inf) * 2 - 1,
//		amp: vol
//	);
//
//	outC = in;
//	outR = PanAz.ar(
//		4, 				 					//numChans
//		Mix.new(in),	 					//in
//		LFSaw.kr(rotfreq, 0.5pi)*rotate,	//[anti]clockwise
//		vol,			 					//level
//		[0.5, 4.0].asSpec.map(panidx)		//width
//	);
//	Out.ar(busnum, SelectX.ar(BinaryOpUGen('==', rotate, 0) * 3, [outR, outC]) );
//}).send(s);
//
//
////SynthDef( \gmp8tmp, {
////	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
////	var trate, dur, clk, pos, d, z, in, out;
////	pos = round((ax*0.19)+0.1, 0.01); // arg X: position
////	trate = (ay*19)+1; //arg Y: trate 1..20 how to make it exponential?
////	clk = Impulse.ar(trate * 10);
////	d = { Dwhite(0.1, 0.2, 1) };
////	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
////	in= TGrains.ar(4, clk, bufnum,
////		rate:Dseq([1.3, 1.5, z.value, 1.5, 1.5, 1.2, 1.1, 1.1, 1.3, 1.7], inf) * trate + 1,
////		centerPos: Dseq(z.dup(8), inf) / pos,
////		dur: Dseq([0.1, d.value, 0.2, z.value, 0.5, 0.1, 0.3, z.value], inf) / pos,
////		pan:Dseq([0-panidx, 0-(panidx/2), 0-(panidx/4), 0-(panidx/6), 0, panidx/6, panidx/4, panidx/2, panidx], inf) * 2 - 1,
////		amp: Dseq([0.4, 0.1, z.value, 0, 0.8, 1.0, 0.5, 0.4, 0.1], inf) * vol);
////
//////	out= PitchShift.ar(in, 0.2, 0.5,  0.01*panidx, 0.0001, 0.75)
//////		+PitchShift.ar(in, 0.2, 0.2,  0.01*panidx, 0.0001, 1);
//////
//////	Out.ar(busnum, in+out);
////	Out.ar(busnum, in);
////}).send(s);