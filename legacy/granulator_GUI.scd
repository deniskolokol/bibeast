//======== 1 =========
//===== server =======
(
s = Server.internal;
Server.default = s;
s.boot;
)


//======== 2 =========
//=== synths' def ====
(
SynthDef( \synthgran0, {
	arg busnum = 0, bufnum = 0, bufdur, ax, ay, panidx, vol;
	var trate = 1, pos, dur, clk;
	pos = ax * bufdur; // arg X - position
	trate = (ay * 112) + 8; //arg Y - trate, 8..120
	dur = 12 / trate;
	clk = Impulse.kr(trate);
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 1, pos + TRand.kr(0, 0.01, clk), dur, WhiteNoise.kr(panidx), vol));
}).send(s);

SynthDef( \synthgran1, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
	var trate = 1, pos, dur, clk;
	pos = ax * bufdur; // arg X: position
	trate = (ay * 59) + 1; //arg Y: trate, 1..60
	dur = 4 / trate;
	clk = Dust.kr(trate);
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 1, pos + TRand.kr(0, 0.01, clk), dur, WhiteNoise.kr(panidx), vol));
}).send(s);

SynthDef( \synthgran2, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
	var trate, tratectrl, pos, dur, clk;
	pos = (ax * (bufdur - 0.2))+0.1; // arg X: position
	tratectrl = (ay * 2.9) + 0.1; //arg Y: tratectrl, 0.1..3.0
	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
	dur = 12 / trate;
	clk = Impulse.ar(trate);
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 1, pos, dur, WhiteNoise.kr(panidx), vol));
}).send(s);

//SynthDef( \synthgran3, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
//	var tratectrl = 12, trate, dur, durctrl, pos, clk;
//	pos = ax * bufdur; // arg X: position
//	durctrl = (ay*23.8)+0.2; // arg Y: durctrl 0.2..24
//	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,4,60);
//	dur = durctrl / trate;
//	clk = Impulse.kr(trate);
//	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 1, pos + TRand.kr(0, 0.01, clk), dur, WhiteNoise.kr(panidx), vol));
//}).send(s);
SynthDef( \synthgran3, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
	var tratectrl, trate, dur, durctrl, pos, clk;
	pos = ax * bufdur; // arg X: position
	tratectrl = trunc((ay*198)+2); // arg Y: durctrl 2..200
	dur = 4 / tratectrl;
	trate = Dseq([10, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
	clk = Impulse.ar(tratectrl);
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, trate, pos, dur, Dseq([0-panidx, panidx], inf), vol));
}).send(s);


SynthDef( \synthgran4, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
	var trate, dur, clk, pos;
	trate = round((ay*99)+1, 1.0);  //arg Y: trate 1..100, step 1.0
	dur = 4 / trate;
	clk = Impulse.kr(trate);
	pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 1, pos, dur, WhiteNoise.kr(panidx), vol));
}).send(s);

SynthDef( \synthgran5, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
	var trate, dur, clk, pos;
	pos = ax * bufdur; // arg X: position
	trate = (ay*399)+1; // arg Y: trate 1..400
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 2 ** WhiteNoise.kr(2), pos, dur, WhiteNoise.kr(panidx), vol));
}).send(s);

//SynthDef( \synthgran6, {
//	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
//	var trate, dur, clk, pos;
//	pos = ax * bufdur; // arg X: position
//	trate = (ay*99)+2; //arg Y: trate 2..100 how to make it exponential?
//	clk = Impulse.ar(trate);
//	dur = 1.2 / trate;
//	Out.ar(busnum,TGrains.ar(2, clk, bufnum, (1.2 ** WhiteNoise.kr(3).round(1)), pos, dur, WhiteNoise.kr(panidx), vol));
//}).send(s);

SynthDef( \synthgran6, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
	var trate, dur, clk, pos, d, z;
	pos = round((ax*0.19)+0.1, 0.01); // arg X: position
	trate = (ay*19)+1; //arg Y: trate 2..100 how to make it exponential?
	clk = Impulse.ar(trate * 10);

	d = { Dwhite(0.1, 0.2, 1) };
	z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };

	Out.ar(busnum,TGrains.ar(2, clk, bufnum,
		rate:Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * pos + 1,
		centerPos: Dseq(z.dup(8), inf) / pos,
		dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
		pan:Dseq([0-panidx, 0-(panidx/2), 0-(panidx/4), 0-(panidx/6), 0, panidx/6, panidx/4, panidx/2, panidx], inf) * 2 - 1,
		amp: Dseq([1, 0, z.value, 0, 2, 1.0, 1, 0.1, 0.1], inf) * vol));
}).send(s);

SynthDef( \synthgran7, {
	arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx, vol;
	var trate, dur, clk, pos;
	pos = ax * bufdur; // arg X: position
	trate = (ay*199)+1;  //arg Y: trate 1..200
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	Out.ar(busnum,TGrains.ar(2, clk, bufnum, 2 ** WhiteNoise.kr(2), pos, dur, WhiteNoise.kr(panidx), vol));
}).send(s);

SynthDef( \syninbuff, {
	arg bufnum, busnum = 0, volIn = 0.8, rate = 1, loop = 1;
	RecordBuf.ar(InFeedback.ar(busnum), bufnum, 0, volIn, 0, 1, loop, 1);
}).send(s);

)


//======== 4 =========
//= GUI and controls =
(
var synthList, channels;
var poolName, pool, poolindex, poolnamesarray;
var tmpBuffer, synthIn;
var w;
var globalFont1 = Font("Helvetica", 9), globalFont2 = Font("Helvetica", 12), globalFont3 = Font("Helvetica", 36), ctlFocusColor = Color.red(alpha:0.2), ctlMainColor1 = Color.new255(205, 138, 138), ctlMainColor2 = Color.new255(205, 200, 177), ctlColor10 = Color.new255(205, 92, 92, 0.05), ctlColor11 = Color.new255(205, 92, 92), ctlColor20 = Color.new255(100, 149, 237, 0.6), ctlColor21 = Color.new255(70, 130, 180), btColorOff = Color.new255(250, 250, 250), btColorOn = Color.new255(43, 43, 43), btColorPlay = Color.new255(178, 34, 34), btColorStop = Color.new255(240, 230, 140), slidColorProgress = Color.new255(123, 104, 238);
var chlistStereo, chlistMono, bufferList, bufnumList, chBuffers, monoChList;
var sndNameList, bufDurList, valList;
var grSTxList, grSTyList, grslidList, grVolList, grSTVolList, grPanList, grSTPanList, grChList, grFileList, grVolInput, grTFVolInput, grBufLen, grTFBufLen, btInputLoop, btInputRec, rslInputDur, btPlayBuff;
var timeSpec = [0.5, 10, \lin, 0.5, 1, "sec"].asSpec, volSpec = \db.asSpec;
var grGlobBtList, grGlobVolBtList, grGlobPanBtList, globSlidList, globVolList, globPanList;
var grSTxGlob, grSTyGlob, grslidGlob, grVolGlob, grNBVolGlob, grPanGlob, grNBPanGlob;
var loadFileList;
var psetNum, psetButtList, psetList, psetCurr, psetChange, saveSettings, restoreSettings;
var presetsFile = nil;
var synthNameList = Array.fill(8, nil), pmSynthNames = List.new;

//8.do({ |i| synthNameList[i] = \synthgran++i });
synthNameList = ["drone", "drone_chopper", "swirl", "chopper", "fountain", "slicer", "stutterer", "spring"];

synthList = Array.fill(8, nil);

// channels lists
channels = 52; // replace by ixi preferences
chlistStereo = Array.fill(trunc(channels / 2), nil);
chlistMono = Array.fill(channels, nil);
channels.do({ arg i;
	chlistMono.put(i, i.asSymbol);
	if( i < (channels / 2), { chlistStereo.put(i, (i*2).asSymbol ++ ", " ++ ((i*2)+1).asSymbol ); } );
	i=i+1;
});

tmpBuffer = Buffer.alloc(s, s.sampleRate, 1); // 1 seconds 1 channel Buffer - default

w = GUI.window.new("granulator", Rect(100, 400, 1110, 220), resizable:false);
//w.alpha = 0.9;
//w.view.background = Color.new255(71, 71, 71);

globSlidList = Array.fill(8, 0);
globVolList = Array.fill(8, 0);
globPanList = Array.fill(8, 0);
grGlobBtList = List.new;
grslidList = List.new;
grGlobVolBtList = List.new;
grVolList = List.new;
grSTVolList = List.new;
grGlobPanBtList = List.new;
grPanList = List.new;
grSTPanList = List.new;
grChList = List.new;
grSTxList = List.new;
grSTyList = List.new;
grFileList = List.new;
bufnumList = List.new;
chBuffers = Array.fill(8, nil);
sndNameList = [];
bufDurList = List.new;
psetNum = 50;
psetList = Array.fill(psetNum, nil);

//preferences file
"Trying to open presets file...".postln;
try{
	presetsFile = File("preferences/granpsets.dk", "r");
	psetList = presetsFile.readAllString.interpret;
	"OK!".postln;
}{
	("Sorry, cannot open presets file"++String.scDir++"/preferences/granpsets.dk" ++"!").postln;
	"Will be replaced on window close, so please take care of the current file (if any)!".postln;
	presetsFile = nil;
};

// GUI definition
//global area
GUI.staticText.new(w,Rect(10, 3, 65, 15))
	.string_("global control")
	.font_(globalFont1);
grslidGlob = GUI.slider2D.new(w, Rect(5, 20, 115, 100))
	.background_(ctlMainColor1)
	.focusColor_(Color.red(alpha:0.2))
	.x_(0.0)
	.y_(0.0);
grSTxGlob = GUI.staticText.new(w, Rect(100, 105, 30, 15))
	.font_(globalFont1)
	.string_(0.0);
grSTyGlob = GUI.staticText.new(w, Rect(7, 23, 30, 15))
	.font_(globalFont1)
	.string_(0.0);
grNBVolGlob = GUI.numberBox.new(w, Rect(95, 122, 24, 12))
	.background_(ctlMainColor1)
	.font_(globalFont1)
	.align_(\right)
	.value_(volSpec.map(0));
grVolGlob = GUI.slider.new(w, Rect(5, 122, 88, 13))
	.background_(Gradient(ctlColor10, ctlMainColor1, \h, 12))
	.focusColor_(Color.red(alpha:0.2));
grNBPanGlob = GUI.numberBox.new(w, Rect(95, 136, 24, 12))
	.font_(globalFont1)
	.align_(\right)
	.value_(0.7);
grPanGlob = GUI.slider.new(w,Rect(5, 136, 88, 13))
	.background_(Gradient(ctlColor10, ctlMainColor1, \h, 12))
	.focusColor_(Color.red(alpha:0.2))
	.value_(0.7);
bufferList = GUI.popUpMenu.new(w,Rect(20, 152, 100, 15))
	.background_(Color.new255(255, 255, 255))
	.canFocus_(false)
	.font_(globalFont1)
	.items_(if(XQ.poolNames == [], { ["no bufferPool"] }, { XQ.poolNames }));
// channel dropdown list
GUI.staticText.new(w,Rect(20, 170, 50, 15))
	.string_("input bus")
	.font_(globalFont1);
monoChList = GUI.popUpMenu.new(w,Rect(65, 170, 45, 15))
	.background_(Color.new255(255, 255, 255))
	.canFocus_(false)
	.font_(globalFont1)
	.items_(chlistMono);
// input volume
grVolInput = GUI.slider.new(w, Rect(163, 171, 96, 13))
	.background_(Gradient(ctlColor10, ctlMainColor1, \h, 12))
	.value_(0.8)
	.canFocus_(false);
GUI.staticText.new(w,Rect(123, 171, 50, 15))
	.string_("input vol")
	.font_(globalFont1);
grTFVolInput = GUI.numberBox.new(w, Rect(260, 171, 23, 12))
	.background_(ctlMainColor1)
	.font_(globalFont1)
	.value_(round(grVolInput.value, 0.01).asSymbol);
grTFVolInput.setProperty(\align,\right);
// tmp buffer length
grBufLen = GUI.slider.new(w, Rect(342, 171, 96, 13))
	.background_(Gradient(ctlColor10, ctlMainColor1, \h, 13))
	.value_(timeSpec.unmap(1))
	.canFocus_(false);
GUI.staticText.new(w,Rect(295, 171, 50, 15))
	.string_("buf len (s)")
	.font_(globalFont1);
grTFBufLen = GUI.numberBox.new(w, Rect(440, 171, 23, 12))
	.background_(ctlMainColor1)
	.font_(globalFont1)
	.value_(timeSpec.map(grBufLen.value));
grTFBufLen.setProperty(\align,\right);
//recording dur progress bar (range slider)
rslInputDur = GUI.rangeSlider.new(w, Rect(545, 171, 85, 15))
	.background_(Color.red(alpha:0.001))
	.knobColor_(slidColorProgress)
	.visible_(false)
	.canFocus_(false)
	.lo_(0)
	.hi_(0);
//record loop button
btInputLoop = GUI.button.new(w,Rect(468, 171, 25, 15))
	.font_(globalFont1)
	.states_([
		["one", btColorOn, btColorOff],
		["loop", btColorOff, btColorOn]
	])
	.value_(0);
//record trigger button
btInputRec = GUI.button.new(w,Rect(496, 170, 45, 17))
	.font_(globalFont2)
	.states_([
		["REC", btColorPlay, btColorStop],
		["STOP", btColorStop, btColorPlay]
	])
	.value_(0)
	.action_({ |bt|
		var r, sp, cycles, cnt=0, loop=btInputLoop.value;
		if(bt.value == 1, {
			tmpBuffer.free;
			tmpBuffer = Buffer.alloc(s, s.sampleRate * grTFBufLen.value, 1); // 1 channel Buffer
			synthIn = Synth.new(\syninbuff, [\bufnum, tmpBuffer.bufnum, \busnum, monoChList.value, \volIn, grVolInput.value, \loop, btInputLoop.value]); //recording synth
			rslInputDur.visible_(true); rslInputDur.hi = 0;
			cycles = grTFBufLen.value / 0.01;
			sp = [0, cycles, \lin, 0.1, 0].asSpec;
			r = Routine({ |time|
				inf.do({
					cycles.do({ |i|
						{ cnt = i+1; rslInputDur.hi = sp.unmap(cnt) }.defer;
						0.01.wait;
					});
					if(loop == 0, { SystemClock.clear; { btInputRec.valueAction_(0); }.defer; });
					cnt = 0;
					0.1.wait;
				});
			});
			SystemClock.play(r);
		}, {
				SystemClock.clear;
				synthIn.free;
		});
	});
//TEST - play buf button
btPlayBuff = GUI.button.new(w,Rect(635, 171, 15, 15))
	.font_(globalFont1)
	.visible_(false)
	.states_([
		[">", btColorOn, btColorOff]
	])
	.value_(0)
	.action_({ |bt|
		{ Out.ar(0, Pan2.ar(
			PlayBuf.ar(1, tmpBuffer.bufnum, BufRateScale.kr(tmpBuffer.bufnum), 1, 0, 0), 0)
		)}.play(s);
	});

// synths labels
GUI.staticText.new(w,Rect(127, 1, 20, 15))
	.string_("out")
	.font_(globalFont1);
GUI.staticText.new(w,Rect(127, 21, 20, 15))
	.string_("X,Y")
	.font_(globalFont1);
GUI.staticText.new(w,Rect(127, 122, 20, 15))
	.string_("vol")
	.font_(globalFont1);
GUI.staticText.new(w,Rect(125, 136, 20, 15))
	.string_("wide")
	.font_(globalFont1);
GUI.staticText.new(w,Rect(125, 152, 20, 15))
	.string_("buff")
	.font_(globalFont1);
//global shortcuts help
GUI.staticText.new(w,Rect(80, 23, 40, 15))
	.string_("Alt + T") // Alt+t global X,Y
	.font_(globalFont2)
	.stringColor_(Color.white);
GUI.staticText.new(w,Rect(57, 122, 40, 15))
	.string_("Alt + V") // Alt+t global X,Y
	.font_(globalFont1)
	.stringColor_(Color.white);
GUI.staticText.new(w,Rect(57, 137, 40, 15))
	.string_("Alt + W") // Alt+t global X,Y
	.font_(globalFont1)
	.stringColor_(Color.white);

// loop for synth controls
8.do({ arg i;
	var hrIndex = 120; // horizontal space required for a section

	// channel dropdown list
	grChList.add(
		GUI.popUpMenu.new(w,Rect(145+(i*hrIndex), 1, 42, 15))
			.items_(chlistStereo)
			.background_(Color.new255(255, 255, 255))
			.canFocus_(false)
			.font_(globalFont1)
	);
	//select of the synth on a slot
	pmSynthNames.add(
		GUI.popUpMenu.new(w,Rect(188+(i*hrIndex), 1, 62, 15))
			.items_(synthNameList)
			.visible_(true)
			.background_(Color.new255(255, 255, 255))
			.canFocus_(false)
			.font_(globalFont1)
	);
//	//waveshape - tmp
//	sfView.add(
//		GUI.soundFileView.new(w,Rect(188+(i*hrIndex), 1, 62, 15))
//			.items_(synthNameList)
//			.visible_(false) // UWAGA! clear the line when the feature is added
//			.background_(Color.new255(255, 255, 255))
//			.canFocus_(false)
//			.font_(globalFont1)
//	);
	// slider global button
	grGlobBtList.add(
		GUI.button.new(w, Rect(252+(i*hrIndex), 4, 10, 10))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.action_({ |butt|
				globSlidList[i] = butt.value;
			});
	);
	// 2D slider
	grslidList.add(
		GUI.slider2D.new(w, Rect(145+(i*hrIndex), 20, 115, 100))
			.background_(ctlMainColor2)
			.focusColor_(ctlFocusColor)
			.x_(0.0)
			.y_(0.0)
			.canFocus_(true);
	);
	// coordinates - X
	grSTxList.add(
		GUI.staticText.new(w, Rect(240+(i*hrIndex), 105, 30, 15))
			.font_(globalFont1)
			.string_(0.0);
	);
	// coordinates - Y
	grSTyList.add(
		GUI.staticText.new(w, Rect(147+(i*hrIndex), 23, 30, 15))
			.font_(globalFont1)
			.string_(0.0);
	);
	// synth number label
	GUI.staticText.new(w, Rect(233+(i*hrIndex), 18, 40, 45))
		.string_((i+1).asSymbol)
		.font_(globalFont3)
		.stringColor_(Color.white);
	// synth descr
	GUI.staticText.new(w, Rect(180+(i*hrIndex), 40, 80, 45))
		.string_(synthNameList[i])
		.font_(globalFont2)
		.stringColor_(Color.white);
	//volume slider
	grVolList.add(
		GUI.slider.new(w, Rect(145+(i*hrIndex), 122, 102, 13))
			.focusColor_(Color.red(alpha:0.2))
			.background_(Gradient(ctlColor10, ctlColor11, \h, 14))
	);
	//volume static text
	grSTVolList.add(
		GUI.staticText.new(w, Rect(223+(i*hrIndex), 123, 23, 12))
			.font_(globalFont1)
			.stringColor_(Color.white)
			.string_(volSpec.map(0))
	);
	//Global volume button
	grGlobVolBtList.add(
		GUI.button.new(w,Rect(250+(i*hrIndex), 123, 10, 10))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.action_({ arg butt;
				globVolList[i] = butt.value;
			};)
	);
	//wide panorama slider
	grPanList.add(
		GUI.slider.new(w, Rect(145+(i*hrIndex), 136, 102, 13))
			.focusColor_(Color.red(alpha:0.2))
			.background_(Gradient(ctlColor20, ctlColor21, \h, 14))
			.value_(0.7)
	);
	//wide panorama static text
	grSTPanList.add(
		GUI.staticText.new(w, Rect(226+(i*hrIndex), 136, 23, 12))
			.font_(globalFont1)
			.stringColor_(Color.white)
			.string_(grPanList[i].value);
	);
	//Global wide panorama button
	grGlobPanBtList.add(
		GUI.button.new(w,Rect(250+(i*hrIndex), 137, 10, 10))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.canFocus_(true)
			.action_({ arg butt;
				globPanList[i] = butt.value;
			});
	);
	// soundfiles
	grFileList.add(GUI.popUpMenu.new(w ,Rect(145+(i*hrIndex), 152, 115, 15))
		.background_(Color.new255(255, 255, 255))
		.canFocus_(false)
		.value_(i)
		.font_(globalFont1);
	);

	//actions
	grslidList[i].action_({
		if(synthList[i] != nil, { synthList[i].set(\ax, grslidList[i].x, \ay, grslidList[i].y) });
		grSTxList[i].string_(round(grslidList[i].x * 100, 0.1));
		grSTyList[i].string_(round(grslidList[i].y * 100, 0.1))
	});
	// for the purposes of saving RAM & CPU the volume slider controls also creation of the synth:
	// if vol != 0 the synth[i] is being created, othervise it's been freed
	grVolList[i].action_({ |sl|
		var currBufnum, currBufDur;
		grSTVolList[i].string_(volSpec.map(grVolList[i].value));
		if(grVolList[i].value != 0, {
			// vol is not 0
			if(synthList[i] != nil, {
				synthList[i].set(\vol, sl.value);
			}, {
				grFileList[i].action.value(grFileList[i].value); // load monobuf
				currBufnum = bufnumList.at(grFileList[i].value);
				currBufDur = bufDurList.at(grFileList[i].value);
				synthList[i] = Synth.new(\synthgran++i, [\busnum, (grChList[i].value * 2), \bufnum, currBufnum, \bufdur, currBufDur, \ax, grslidList[i].x, \ay, grslidList[i].y, \panidx, grPanList[i].value, \vol, sl.value]);
				grslidList[i].background_(ctlFocusColor)
			});
		},
		{ // vol is 0
			if(synthList[i] != nil, {
				synthList[i].free;
				synthList[i] = nil;
				grslidList[i].background_(ctlMainColor2)
			});
		});
	});

	grPanList[i].action_({
		if(synthList[i] != nil, { synthList[i].set(\panidx, grPanList[i].value) });
		grSTPanList[i].string_(round(grPanList[i].value, 0.01))
	});
	grChList[i].action_({
		if(synthList[i] != nil, { synthList[i].set(\busnum, (grChList[i].value * 2)) });
	});
	// file list action
	grFileList[i].action_({ |popup|
		var filepath, soundfile, selStart, selEnd, checkBufLoadTask, tmpBuf;
		if(popup.value != 0, {
			filepath = XQ.globalBufferDict.at(poolName)[0][popup.value-1].path; // value-1 'cause the 1st buffer is always internal
			selStart = XQ.globalBufferDict.at(poolName)[1][popup.value-1][0];
			selEnd = selStart + XQ.globalBufferDict.at(poolName)[1][popup.value-1][1]-1;
			soundfile = SoundFile.new;
			soundfile.openRead(filepath);
			if(soundfile.numChannels == 2, {
				tmpBuf = Buffer.readChannel(s, filepath, selStart, selEnd, [0]); //if it's stereo, read only left channel
			}, {
				tmpBuf = Buffer.read(s, filepath, selStart, selEnd); // make a right size buffer if only part of file is selected
			});
			chBuffers.at(i, tmpBuf);
			soundfile.close;
			checkBufLoadTask = Task({
				inf.do({
					if(tmpBuf.numChannels != nil, {
						synthList.at(i).set(\bufnum, tmpBuf.bufnum);
						checkBufLoadTask.stop;
					});
					0.1.wait;
				});
			}).start;
		});
	});
}); // end of synths loop

// global controls' actions
grslidGlob.action_({
	8.do({
		arg i;
		if(globSlidList[i] == 1, {
			grslidList[i].x_(grslidGlob.x);
			grslidList[i].y_(grslidGlob.y);
			synthList[i].set(\ax, grslidList[i].x, \ay, grslidList[i].y);
			grSTxList[i].string_(round(grslidList[i].x * 100, 0.1));
			grSTyList[i].string_(round(grslidList[i].y * 100, 0.1))
		});
	});
	grSTxGlob.string_(round(grslidGlob.x * 100, 0.1));
	grSTyGlob.string_(round(grslidGlob.y * 100, 0.1));
});
grVolGlob.action_({ arg sl;
	8.do({
		arg i;
		if (globVolList[i] == 1, {
			grVolList[i].valueAction_(sl.value);
		});
	});
	grNBVolGlob.value_(volSpec.map(sl.value));
});
grPanGlob.action_({ arg sl;
	8.do({
		arg i;
		if (globPanList[i] == 1, {
			grPanList[i].valueAction_(sl.value);
		});
	});
	grNBPanGlob.value_(round(grPanGlob.value, 0.01));
});
monoChList.action_({
	if(synthIn != nil, { synthIn.set(\busnum, monoChList.value) });
});
grVolInput.action_({ arg sl;
	grTFVolInput.value_(round(sl.value, 0.01).asSymbol);
	if(synthIn != nil, { synthIn.set(\volIn, grVolInput.value) });
});
grBufLen.action_({ |sl|
	grTFBufLen.value_(timeSpec.map(sl.value));
	bufDurList[0] = timeSpec.map(sl.value);
});

bufferList.action_({ |item|
	var dictArray, filepath, selStart, selEnd, soundfile, tmpBuf;
	poolName = bufferList.items[item.value];
	loadFileList.value(poolName.asSymbol);
});

loadFileList = { arg pn;
	poolName = pn;
	sndNameList = []; bufnumList = List.new; bufDurList = List.new;
	// in any case loading internal buffer
	bufnumList.add(tmpBuffer.bufnum);
	bufDurList.add(tmpBuffer.numFrames/tmpBuffer.sampleRate);
	sndNameList.add("internal buffer");
	// loading files from the first opened buffer pool (if any)
	if(try { XQ.globalBufferDict.at(poolName)[0] } != nil, {
		XQ.globalBufferDict.at(poolName)[0].do({ arg buffer, i;
			sndNameList = sndNameList.add(buffer.path.basename);
			bufnumList.add(buffer.bufnum);
			bufDurList.add(buffer.numFrames / buffer.sampleRate); // buffer length in seconds
		 });
	});
	// put the new sounds into popupmenus
	8.do({ |j|
		grFileList[j].items_(sndNameList);
		grFileList[j].value = j;
	});
};

// update pool and fileList on open
loadFileList.value(XQ.poolNames[0].asSymbol); // load the first pool

poolnamesarray = XQ.globalBufferDict.keys.asArray.sort;
pool = bufferList.items.at(bufferList.value);
bufferList.items_(poolnamesarray);
poolindex = bufferList.items.indexOf(pool);
if(poolindex == nil, {
	bufferList.value_(0);
	loadFileList.value(poolnamesarray[0]);
},{
	bufferList.value_(poolindex);
	loadFileList.value(pool);
});

bufferList.valueAction_(0);

// load the first pool
//if(XQ.poolNames.size > 0, { loadFileList.value(XQ.poolNames[0].asSymbol) });

//pre-sets section
psetCurr = psetNum+1; // initial state, means no pre-set is choosen

GUI.hLayoutView.new(w, Rect(0, 187, 1110, 30))
	.background_(Color.red(alpha:0.1));
psetButtList = List.new;
psetNum.do({ arg i;
	psetButtList.add(
		GUI.button.new(w,Rect(6+(i*22), 193, 22, 22))
			.font_(globalFont2)
			.canFocus_(false)
			.states_([
				[(i+1).asSymbol, Color.black, ctlMainColor2], // 0 - no pre-set
				[(i+1).asSymbol, Color.black, Color.red(alpha:0.1)], // 1 - pre-set
				[(i+1).asSymbol, Color.white, ctlColor11] // 2 - pushed button
			])
			.value_(if(psetList[i] != nil, { 1 }, { 0 }))
			.action_({ psetChange.value(i) });
	);
});

psetChange = {arg preset;
	if((preset != psetCurr) && (psetCurr <= psetNum), {
		psetButtList[psetCurr].value = if(psetList[psetCurr] != nil, { 1 }, { 0 }); // make the previously chosen pre-set into previous state
	});
	psetButtList[preset].value = 2; // push the button
	psetCurr = preset;
	restoreSettings.value(psetCurr);
};

w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	var keyArr = #[29, 18, 19, 20, 21, 23, 22, 26, 28, 25],  // char codes of numbers 0-9
	   fKeyArr = #[18, 19, 20, 21, 23, 71, 89, 91]; // Fn + "char" codes
	[char, modifiers, unicode, keycode].postln;
	case
		{keycode == 27} {if(psetCurr <= psetNum, { psetList.put(psetCurr, nil); })} // minus, delete preset
		{keycode == 24} {
			if(psetCurr <= psetNum, {
				saveSettings.value(psetCurr);
				})
		} // plus ("=" actually), add/update preset
		{keycode == 9} {if(modifiers == 524576, { // Alt + v - select all volume global switches
			8.do({ arg i;
				grGlobVolBtList[i].valueAction_(1);
				globVolList[i] = 1;
			});
		})}
		{keycode == 13} {if(modifiers == 524576, { // Alt + w - select all wide global switches
			8.do({ arg i;
				grGlobPanBtList[i].valueAction_(1);
				globPanList[i] = 1;
			});
		})}
		{keycode == 17} {if(modifiers == 524576, { // Alt + t - select all 2Dsliders global switches
			8.do({ arg i;
				grGlobBtList[i].valueAction_(1);
				globSlidList[i] = 1;
			});
		})}
		{keycode == 15} { // R (record / stop) & Alt + R (loop record)
			if((modifiers == 524320) || (modifiers == 524576), { btInputLoop.valueAction_(1 - btInputLoop.value) });
			btInputRec.valueAction_(1 - btInputRec.value);
		}
		{((keycode >= 18) && (keycode < 24)) || (keycode == 26) || (keycode == 28)} { // 1-8
			case
				{(modifiers == 0) || (modifiers == 256)} { // toggle vol slider
					if( grVolList[char.digit-1].value > 0, {
						grVolList[char.digit-1].valueAction_(0)
					}, {
						grVolList[char.digit-1].valueAction_(0.9)
					}); // should be some ramp time or not?
				}
				{(modifiers == 524320) || (modifiers == 524576)} { // Alt+<num> - check/uncheck global 2D
					grGlobBtList[keyArr.find([keycode])-1].valueAction_(1-grGlobBtList[keyArr.find([keycode])-1].value);
				}
				//bookmark
				{(modifiers == 8388608) || (modifiers == 8388864)} { // Fn+<num 1-5> - update fileLists, check last element
					valList = Array.fill(8, nil); // save the positions of popupmenus
					8.do({ |cnt| valList[cnt] = grFileList[cnt].value });
					loadFileList.value(bufferList.items[bufferList.value].asSymbol); // update filelists
					8.do({ |cnt|
						grFileList[cnt].items_(sndNameList); // put the new sounds into popupmenus
						if( (cnt == (fKeyArr.find([keycode]))), {
							grFileList[cnt].valueAction_(grFileList[cnt].size - 1); // select last element
							fKeyArr.find([keycode]).postln;
						},{
							grFileList[cnt].value = valList[cnt];
						} );
					});
				};
		}
		{(keycode == 71) || (keycode == 89) || (keycode == 91)} { // Fn + <num 6-8>
				if((modifiers == 8388608) || (modifiers == 8388864) || (modifiers == 10485760) || (modifiers == 10486016), {
				// Fn + <number> - update fileLists, check last element
					valList = Array.fill(8, nil); // save the positions of popupmenus
					8.do({ |cnt| valList[cnt] = grFileList[cnt].value });
					loadFileList.value(bufferList.items[bufferList.value].asSymbol); // update filelists
					8.do({ |cnt|
						grFileList[cnt].items_(sndNameList); // put the new sounds into popupmenus
						if( (cnt == (fKeyArr.find([keycode]))), {
							grFileList[cnt].valueAction_(grFileList[cnt].size - 1); // select last element
							fKeyArr.find([keycode]).postln;
						},{
							grFileList[cnt].value = valList[cnt];
						} );
					});
				});
		};
};

saveSettings = {arg pset;
	var psetSynth, psetCurrList;
	psetCurrList = List.fill(9, nil); // 8 synths, global settings
	8.do({ arg i;
		psetSynth = Array.fill(10, nil); // the settings list of every other synth
		psetSynth.put(0, "synthgran"++i); // 0 - synth name
		psetSynth.put(1, grChList[i].value); // 1 - buses
		psetSynth.put(2, grslidList[i].x); // 2 - 2D slider X
		psetSynth.put(3, grslidList[i].y); // 3 - 2D slider Y
		psetSynth.put(4, grGlobBtList[i].value); // 4 - global XY
		psetSynth.put(5, grVolList[i].value); // 5 - volume
		psetSynth.put(6, grGlobVolBtList[i].value); // 6 - volume global mode
		psetSynth.put(7, grPanList[i].value); // 7 - wide
		psetSynth.put(8, grGlobPanBtList[i].value); // 8 - wide global mode
		psetSynth.put(9, grFileList[i].value); // 9 - soundfile
		psetCurrList.put(i, psetSynth); // put synthgran[i] settings into the pre-set list
	});
	psetSynth = Array.fill(10, nil); // now - global settings
	psetSynth.put(0, "global"); // 0 - "global"
	psetSynth.put(1, monoChList.value); // 1 - global input bus
	psetSynth.put(2, grslidGlob.x); // 2 - global 2D slider X
	psetSynth.put(3, grslidGlob.y); // 3 - global 2D slider Y
	psetSynth.put(4, 0); // 4 - buffer type: 0 - buffer pool; 1 - audio input // doesn't matter, previously it was grInputTypeAI.value
	psetSynth.put(5, grVolGlob.value); // 5 - global volume
	psetSynth.put(6, grVolInput.value); // 6 - input volume
	psetSynth.put(7, grPanGlob.value); // 7 - global wide
	psetSynth.put(8, timeSpec.map(grBufLen.value)); // 8 - input buffer length
	psetSynth.put(9, bufferList.value); // 9 - buffer num
	psetCurrList.put(8, psetSynth); // the list of global settings is no 8 in the pre-set list

	psetList.put(pset, psetCurrList);
};

restoreSettings = {arg pset;
	var presetCurrNode;
	if(psetList[pset] != nil, {
		presetCurrNode = psetList[pset]; // current presets list

		// first restore global settings
		monoChList.valueAction_(presetCurrNode[8][1]);
		grslidGlob.activex_(presetCurrNode[8][2]);
		grslidGlob.activey_(presetCurrNode[8][3]);
		grVolGlob.valueAction_(presetCurrNode[8][5]);
		grVolInput.valueAction_(presetCurrNode[8][6]);
		grPanGlob.valueAction_(presetCurrNode[8][7]);
		grBufLen.valueAction_(timeSpec.unmap(presetCurrNode[8][8]));
		bufferList.valueAction_(presetCurrNode[8][9]); // decide what to do with buffer

		// prepare to refill global arrays
		globSlidList = Array.fill(8, 0);
		globVolList = Array.fill(8, 0);
		globPanList = Array.fill(8, 0);

		8.do({ arg i;
			grChList[i].valueAction_(presetCurrNode[i][1]);
			grslidList[i].activex_(presetCurrNode[i][2]);
			grslidList[i].activey_(presetCurrNode[i][3]);
			grGlobBtList[i].valueAction_(presetCurrNode[i][4]);
			grGlobVolBtList[i].valueAction_(presetCurrNode[i][6]);
			grPanList[i].valueAction_(presetCurrNode[i][7]);
			grGlobPanBtList[i].valueAction_(presetCurrNode[i][8]);
			grFileList[i].valueAction_(presetCurrNode[i][9]); // not working
			grVolList[i].valueAction_(presetCurrNode[i][5]);
`			// only the states of the buttons updated, so have to update global lists manually
			globSlidList[i] = grGlobBtList[i].value;
			globVolList[i] = grGlobVolBtList[i].value;
			globPanList[i] = grGlobPanBtList[i].value;
		});
	});
};

w.refresh;
w.front;

w.onClose = {
	SystemClock.clear;

	presetsFile = File.new("preferences/granpsets.dk", "w");
	presetsFile.write(psetList.asCompileString);
	presetsFile.close;
	8.do({ arg i;
		synthList[i].free;
	});
	synthIn.free;
};

)