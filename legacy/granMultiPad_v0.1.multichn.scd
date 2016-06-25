
// after creating new gran-synth,
// !!!!   DON'T FORGET !!!
// to add it into synthNameList (number of the element should be corresponding the number in the name of synth)
//
// WARNING! the code labelled " -- buffer pool recording -- " is adopted from XiiBufferPool.sc and dependent on ixi

//= GUI and controls =


(
var synthList=Array.fill(4, nil), channels;
var poolName, pool, poolindex, poolnamesarray;
var tmpBuffer, synthIn;
var w;
var slL=145, slT=80, slW=115, slH=100, hrIndex = 120;
var globalFont1=Font("Helvetica", 9), globalFont2=Font("Helvetica", 12), globalFont3=Font("Helvetica", 36), globalFont4=Font("Helvetica", 13);
var ctlFocusColor=Color.red(alpha:0.2), ctlMainColor1=Color.new255(205, 138, 138), ctlMainColor2=Color.new255(205, 200, 177), ctlColor10=Color.new255(205, 92, 92, 0.05), ctlColor11=Color.new255(205, 92, 92), ctlColor20=Color.new255(100, 149, 237, 0.6), ctlColor21=Color.new255(70, 130, 180), btColorOff=Color.new255(250, 250, 250), btColorOn=Color.new255(43, 43, 43), btColorPlay=Color.new255(178, 34, 34), btColorStop=Color.new255(238, 216, 174), slidColorProgress=Color.new255(123, 104, 238), btKnobColor=Color.new255(205, 38, 38), btColorBG = Color.new255(248, 248, 255), btColorEffColor=Color.new255(96, 123, 139);
var chlistStereo, chlistMono, bufferList, bufnumList=List.new, monoChList;
var sndNameList=[], bufDurList=List.new;
var grSTxList=List.new, grSTyList=List.new, grslidList=List.new, grVolList=List.new, grSTVolList=List.new, grPanList=List.new, grSTPanList=List.new, grChList=List.new, grFileList=List.new, sfViewList=List.new;
var slRamp, stRamp, grVolInput, stVolInput, grBufLen, stBufLen, btInputLoop, btInputRec, rslInputDur, btPlayBuff;
var timeSpec=[0.5, 10, \lin, 0.5, 1, "sec"].asSpec, volSpec=\db.asSpec, dispSpec=[0.5, 0.001, \lin, 0.001].asSpec, radSpec=[0.01, 1, \lin, 0.01].asSpec, rotateFreqSpec= [0.1, 8].asSpec;
var grGlobBtList=List.new, grGlobVolBtList=List.new, grModSwitchList=List.new, globSlidList=Array.fill(4, 0), globVolList=Array.fill(4, 0);
var grSTxGlob, grSTyGlob, grslidGlob, grVolGlob, grSTVolGlob, grPanGlob, grSTPanGlob;
var loadFileList;
var psetNum=50, psetButtList=List.new, psetList=Array.fill(psetNum, nil), psetCurr, psetChange, saveSettings, restoreSettings;
var presetsFile=nil;
var synthNameList, pmSynthNames=List.new;
// -- buffer pool recording --
var ampAnalFunc, ampAnalyserSynth, responder, numChannels, recSynth, secTask, updateFileList, loadBufTask, currRec=4, filename;
var rslRecLevel, tvRecNameList=List.new, stTimeText=List.new, btBufFile=List.new, btBufRec=List.new, bufList=List.new, bufListSelections=List.new;
//perlin distrib variables
var knPerlinDurGlob, stPerlinDurGlob, slPerlinDispGlob, stPerlinDispGlob, knPerlinRaduisGlob, stPerlinRaduisGlob;
var knPerlinDurList=List.new, stPerlinDurList=List.new, slPerlinDispList=List.new, stPerlinDispList=List.new, knPerlinRaduisList=List.new, stPerlinRaduisList=List.new;
var perlinDistr;
//universal procedures


var slideEnv;

//4ch setup
var btRotClock= List.new, btRotAnticlock= List.new, sslRotateFreq= List.new, stRotateFreq= List.new;
//4ch setup




// LOOPER PANEL variables
//interface defaults
var loopLeft = 635, loopTop = 2, loopWidth = 100;
var loopColorBg = Color.new255(205, 200, 177), loopColorCurr = Color.new255(240, 240, 240), loopColorTransp = Color.gray(alpha:0.01);
var fillStr = "       ";
var btLoopAreaList = List.new, btLoopAreaLabels, cvLoopArea = List.new, knLoopPan = List.new, ssLoopVolInd = List.new, ssLoopVol = List.new, btLoopPlayStop = List.new, btLoopPause = List.new, btLoopRec = List.new, pmLoopFileList = List.new, pmLoopChList = List.new, btLoopChanMode = List.new, nbLoopTrigRamp = List.new, ssLoopPlaybackInd = List.new, cvLoopWaveArea = List.new, sfLoopWave = List.new, btLoopMode = List.new;


var loopSynthList = Array.fill(4, nil);
var idNum= 70; // loopers start from 70
var tracks= 4;
var resetclock, seltime, moveTimeCursor, updateLooperList;
var indTaskList= [nil, nil, nil, nil], currPosList= [0, 0, 0, 0];


// LOOPER PANEL end

//MIDI
var ccResp;
//MIDI

synthNameList = ["drone4ch", "shake4ch", "swirl4ch", "waves4ch", "chop4ch", "fount4ch", "exciter4ch", "stutt4ch", "slice4ch", "loopstrch"];

// channels lists
channels = 52; // replace by ixi preferences
chlistStereo = Array.fill(trunc(channels / 2), nil);
chlistMono = Array.fill(channels, nil);
channels.do({ |i|
	chlistMono.put(i, i.asSymbol);
	if( i < (channels / 2), { chlistStereo.put(i, (i*2).asSymbol ++ ", " ++ ((i*2)+1).asSymbol ); } );
	i=i+1;
});

tmpBuffer = Buffer.alloc(s, s.sampleRate, 1); // 1 seconds 1 channel Buffer - default

w = GUI.window.new("GRAN-MultiPad 4 channel", Rect(100, 400, 1200, 450), resizable:false);


//w.alpha = 0.9;


w.view.background = Color.new255(205, 201, 165);

//preferences file
"Trying to open presets file...".postln;
try{
	presetsFile = File("preferences/gmpsets4ch.dk", "r");
	psetList = presetsFile.readAllString.interpret;
	"OK!".postln;
}{
	("Sorry, cannot open presets file"++String.scDir++"/preferences/gmpsets4ch.dk" ++"!").postln;
	"Will be replaced on window close, so please take care of the current file (if any)!".postln;
	presetsFile = nil;
};

// GUI definition
//ramp time for changing presets and synths
GUI.staticText.new(w,Rect(5, 49, 50, 13))
	.string_("ramp time (s)")
	.font_(globalFont1);
slRamp = SmoothSlider(w, Rect(55, 49, 66, 13))
	.knobSize_(0.4)
	.canFocus_(false)
	.mode_(\jump)
	.value_(timeSpec.unmap(2));
slRamp.hilightColor = slRamp.background;

stRamp = GUI.staticText.new(w, Rect(100, 50, 20, 12))
	.font_(globalFont1)
	.string_(timeSpec.map(slRamp.value));
slRamp.action_({ |sl|
	stRamp.string = timeSpec.map(sl.value)
});

//global area
GUI.staticText.new(w,Rect(5, 65, 65, 15))
	.string_("global control")
	.font_(globalFont1);
grslidGlob = GUI.slider2D.new(w, Rect(slL-140, slT, slW, slH)) // global 2D slider
	.background_(ctlMainColor1)
	.canFocus_(false)
	.knobColor_(btKnobColor)
	.x_(0.0)
	.y_(0.0);
grSTxGlob = GUI.staticText.new(w, Rect(slL-140+trunc(slW/2)+3, slT+slH-13, 30, 15))
	.font_(globalFont1)
	.string_(0.0);
grSTyGlob = GUI.staticText.new(w, Rect(slL-140+2, slT+trunc(slH/2)-13, 30, 15))
	.font_(globalFont1)
	.string_(0.0);
grVolGlob = SmoothSlider(w, Rect(5, 182, slW, 13))
	.hilightColor_(Gradient(btKnobColor, ctlColor10, 12))
	.knobSize_(0.4)
	.knobColor_(btKnobColor)
	.canFocus_(false)
	.mode_(\move);
grSTVolGlob = GUI.staticText.new(w, Rect(95, 183, 24, 12))
	.font_(globalFont1)
	.stringColor_(Color.white)
	.string_(volSpec.map(0));
grPanGlob = SmoothSlider(w,Rect(5, 196, slW, 13))
	.hilightColor_(Gradient(slidColorProgress, ctlColor20, 12))
	.knobSize_(0.4)
	.canFocus_(false)
	.mode_(\move)
	.value_(0.7);
grSTPanGlob = GUI.staticText.new(w, Rect(97, 197, 24, 12))
	.stringColor_(Color.white)
	.font_(globalFont1)
	.string_(round(grPanGlob.value, 0.01));
bufferList = GUI.popUpMenu.new(w,Rect(20, 212, 100, 15))
	.background_(Color.new255(255, 255, 255))
	.canFocus_(false)
	.font_(globalFont1)
	.items_(if(XQ.poolNames == [], { ["no bufferPool"] }, { XQ.poolNames }));
// channel dropdown list
GUI.staticText.new(w,Rect(34, 230, 47, 15))
	.string_("input bus")
	.font_(globalFont1);
monoChList = GUI.popUpMenu.new(w,Rect(78, 230, 42, 15))
	.background_(btColorBG)
	.canFocus_(false)
	.font_(globalFont1)
	.items_(chlistMono);
// input volume
GUI.staticText.new(w,Rect(7, 247, 30, 15))
	.string_("in vol")
	.font_(globalFont1);
grVolInput = SmoothSlider(w, Rect(33, 247, 87, 13))
	.hilightColor_(Gradient(btColorPlay, ctlColor10, 12))
	.knobSize_(0.4)
	.knobColor_(btKnobColor)
	.canFocus_(false)
	.mode_(\move)
	.value_(volSpec.unmap(-1.0));
stVolInput = GUI.staticText.new(w, Rect(95, 248, 23, 12))
	.font_(globalFont1)
	.stringColor_(Color.white)
	.string_(volSpec.map(grVolInput.value));
// tmp buffer length
GUI.staticText.new(w,Rect(2, 263, 50, 15))
	.string_("buf len")
	.font_(globalFont1);
grBufLen = SmoothSlider(w, Rect(33, 263, 87, 13))
	.hilightColor_(btColorEffColor)
	.knobSize_(0.4)
	.canFocus_(false)
	.mode_(\jump)
	.value_(timeSpec.unmap(1));
stBufLen = GUI.staticText.new(w, Rect(102, 263, 20, 12))
	.font_(globalFont1)
	.stringColor_(Color.white)
	.string_(timeSpec.map(grBufLen.value));
//recording dur progress bar (range slider)
rslInputDur = SmoothSlider(w, Rect(75, slT+(slH*2)+3, 65, 16))
	.knobColor_(btColorEffColor)
	.visible_(false)
	.hilightColor_(btColorEffColor)
	.knobSize_(0.1)
	.canFocus_(false)
	.mode_(\move)
	.value_(0);

//record loop button
btInputLoop = RoundButton(w,Rect(3, slT+(slH*2), 28, 20))
	.font_(globalFont1)
	.canFocus_(false)
	.states_([
		["one", btColorOn, btColorOff],
		["loop", btColorOff, btColorOn]
	])
	.radius_( 3 )
	.value_(0);

btInputRec = RoundButton(w,Rect(33, slT+(slH*2), 40, 20))
	.canFocus_(false)
	.states_([
		[\record, btColorPlay, btColorStop],
		[\stop, btColorStop, btColorPlay]
	])
	.radius_( 3 )
	.value_(0)
	.action_({ |bt|
		var r, sp, cycles, cnt=0, loop=btInputLoop.value;
		if(bt.value == 1, {
			bt.inverse_(true);
			tmpBuffer.free;
			tmpBuffer = Buffer.alloc(s, s.sampleRate * timeSpec.map(grBufLen.value), 1); // 1 channel Buffer
			synthIn = Synth.new(\syninbuff, [\bufnum, tmpBuffer.bufnum, \busnum, monoChList.value, \volIn, grVolInput.value, \loop, btInputLoop.value]); //recording synth
			rslInputDur.visible_(true); rslInputDur.value = 0;
			cycles = timeSpec.map(grBufLen.value) / 0.01;
			sp = [0, cycles, \lin, 0.1, 0].asSpec;
			r = Routine({ |time|
				inf.do({
					cycles.do({ |i|
						{ cnt = i+1; rslInputDur.value = sp.unmap(cnt) }.defer;
						0.01.wait;
					});
					if(loop == 0, { SystemClock.clear; { btInputRec.valueAction_(0); }.defer; });
					cnt = 0;
					0.1.wait;
				});
			});
			SystemClock.play(r);

		}, {


			bt.inverse_(false);
			SystemClock.clear;
			synthIn.free;
		});
	});
//TEST - play buf button
btPlayBuff = GUI.button.new(w,Rect(635, 231, 15, 15))
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

//EFFECTS
//global perlin ctrls
GUI.staticText.new(w,Rect(5, slT+(slH*2)+22, slW, 12))
	.background_(Color.white)
	.font_(globalFont1)
	.string_("           perlin distrib ");
GUI.hLayoutView.new(w, Rect(slW+5, slT+(slH*2)+31, 500, 2))
	.background_(Color.white);
GUI.hLayoutView.new(w, Rect(5, slT+(slH*2)+33, slW+500, 1))
	.background_(btColorEffColor);
knPerlinDurGlob = GUI.knob.new(w, Rect(slL-120, slT+(slH*2)+38, 31, 13)) // param - duration
	.value_(timeSpec.unmap(2))
	.canFocus_(false);
stPerlinDurGlob = GUI.staticText.new(w, Rect(slL-120, slT+(slH*2)+65, 31, 10))
	.font_(globalFont1)
	.align_(\center)
	.string_(timeSpec.map(knPerlinDurGlob.value));
knPerlinDurGlob.action_({ |sl|
	stPerlinDurGlob.string_(timeSpec.map(sl.value));
});
slPerlinDispGlob = GUI.slider.new(w, Rect(slL-120, slT+(slH*2)+50, 30, 13)) // param - dispersion
	.background_(Gradient(Color.white, btColorEffColor, \h, 8))
	.visible_(false)
	.canFocus_(false)
	.value_(dispSpec.unmap(0.01));
stPerlinDispGlob = GUI.staticText.new(w, Rect(slW-17, slT+(slH*2)+49, slW-90, 10))
	.font_(globalFont1)
	.visible_(false)
	.string_(dispSpec.map(slPerlinDispGlob.value));
slPerlinDispGlob.action_({ |sl|
	stPerlinDispGlob.string_(dispSpec.map(sl.value));
});
knPerlinRaduisGlob = GUI.knob.new(w, Rect(slL-75, slT+(slH*2)+38, 31, 13)) // param - max radius
	.canFocus_(false)
	.value_(radSpec.unmap(0.15));
stPerlinRaduisGlob = GUI.staticText.new(w, Rect(slL-75, slT+(slH*2)+65, 31, 10))
	.font_(globalFont1)
	.align_(\center)
	.string_(radSpec.map(knPerlinRaduisGlob.value));
knPerlinRaduisGlob.action_({ |sl|
	stPerlinRaduisGlob.string_(radSpec.map(sl.value));
});
//perlin labels
GUI.staticText.new(w, Rect(slW-108, slT+(slH*2)+39, slW-80, 10))
	.font_(globalFont1)
	.string_("dur");
GUI.staticText.new(w, Rect(slW+8, slT+(slH*2)+49, slW-80, 10))
	.font_(globalFont1)
	.visible_(false)
	.string_("disp");
GUI.staticText.new(w, Rect(slW-10, slT+(slH*2)+39, slW-80, 10))
	.font_(globalFont1)
	.string_("radius");


// -- buffer pool recording --
//recording level meter
rslRecLevel = SmoothSlider(w, Rect(slL-19, slT+slH+50, 14, 48))
	.visible_(true)
	.hilightColor_(ctlColor11)
	.knobSize_(0.01)
	.knobColor_(ctlColor11)
	.canFocus_(false)
	.mode_(\move);

// preparation for recording into buffer:
ampAnalFunc = { // this is called on CmdPeriod
	ampAnalyserSynth = Synth(\xiiVuMeter, [\inbus, monoChList.value, \amp, grVolInput.value], addAction:\addToTail);
};
ampAnalFunc.value;
numChannels = 1;


// synths labels
GUI.staticText.new(w,Rect(127, 81, 20, 15))
	.string_("X,Y")
	.font_(globalFont1);
GUI.staticText.new(w,Rect(127, 182, 20, 15))
	.string_("vol")
	.font_(globalFont1);
GUI.staticText.new(w,Rect(125, 196, 20, 15))
	.string_("wide")
	.font_(globalFont1);
GUI.staticText.new(w,Rect(125, 212, 20, 15))
	.string_("buff")
	.font_(globalFont1);
//global shortcuts help
GUI.staticText.new(w,Rect(80, 83, 40, 15))
	.string_("Alt + T") // Alt+T global X,Y
	.font_(globalFont2)
	.stringColor_(Color.white);
GUI.staticText.new(w,Rect(10, 182, 40, 15))
	.string_("Alt + B") // Alt+B global volume
	.font_(globalFont1)
	.stringColor_(Color.white);
GUI.staticText.new(w,Rect(127, 363, 20, 15))
	.string_("out")
	.font_(globalFont1);


// loop for synth controls
4.do({ |i|
	//select of the synth in a slot
	pmSynthNames.add(
		GUI.popUpMenu.new(w,Rect(slL+(i*hrIndex), 55, 100, 20))
			.items_(synthNameList)
			.visible_(true)
			.background_(btColorBG)
			.canFocus_(false)
			.font_(globalFont4)
			.value_(i)
	);
	// slider global button
	grGlobBtList.add(
		RoundButton(w, Rect(247+(i*hrIndex), 59, 13, 13))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.canFocus_(false)
			.border_(0.7)
			.extrude_(false)
			.action_({ |butt|
				globSlidList[i] = butt.value;
			});
	);
	// 2D slider
	grslidList.add(
		GUI.slider2D.new(w, Rect(slL+(i*hrIndex), slT, slW, slH))


			.background_(ctlMainColor2)


			.knobColor_(btKnobColor)
			.x_(0.0)
			.y_(0.0)
			.canFocus_(false);
	);
	// coordinates - X
	grSTxList.add(
		GUI.staticText.new(w, Rect(slL+trunc(slW/2)+3+(i*hrIndex), slT+slH-13, 30, 15))
			.font_(globalFont1)
			.string_(0.0);
	);
	// coordinates - Y
	grSTyList.add(
		GUI.staticText.new(w, Rect(slL+(i*hrIndex)+2, slT+trunc(slH/2)-13, 30, 15))
			.font_(globalFont1)
			.string_(0.0);
	);
	// synth number label
	GUI.staticText.new(w, Rect(slL+slW-25+(i*hrIndex), slT-2, 40, 45))
		.string_((i+1).asSymbol)
		.font_(globalFont3)
		.stringColor_(Color.white);
	//volume slider
	grVolList.add(
		SmoothSlider(w, Rect(145+(i*hrIndex), 182, 102, 13))
			.hilightColor_(Gradient(btKnobColor, ctlColor10, 12))
			.knobSize_(0.4)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.mode_(\move);
	);
	//volume static text
	grSTVolList.add(
		GUI.staticText.new(w, Rect(223+(i*hrIndex), 183, 23, 12))
			.font_(globalFont1)
			.stringColor_(Color.white)
			.string_(volSpec.map(0))
	);
	//Global volume button
	grGlobVolBtList.add(
		RoundButton.new(w,Rect(250+(i*hrIndex), 183, 10, 10))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.canFocus_(false)
			.border_(0.7)
			.extrude_(false)
			.action_({ arg butt;
				globVolList[i] = butt.value;
			};)
	);
	//wide panorama slider
	grPanList.add(
		SmoothSlider(w, Rect(145+(i*hrIndex), 196, 102, 13))
			.hilightColor_(Gradient(slidColorProgress, ctlColor20, 12))
			.knobSize_(0.4)
			.canFocus_(false)
			.mode_(\move)
			.value_(0.7)
	);
	//wide panorama static text
	grSTPanList.add(
		GUI.staticText.new(w, Rect(226+(i*hrIndex), 196, 23, 12))
			.font_(globalFont1)
			.stringColor_(Color.white)
			.string_(grPanList[i].value);
	);
	//SinOsc modulation switch
	grModSwitchList.add(
		RoundButton.new(w,Rect(250+(i*hrIndex), 197, 10, 10))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor21]
			])
			.value_(0)
			.canFocus_(false)
			.border_(0.7)
			.extrude_(false)
			.action_({ |butt|
				if(butt.value == 0, { //switch off SinOsc.rk modulation
					if(synthList[i] != nil, { synthList[i].set(\modf, 1) });
				});
			});
	);
	// soundfiles
	grFileList.add(GUI.popUpMenu.new(w ,Rect(145+(i*hrIndex), 212, 115, 15))
		.background_(Color.new255(255, 255, 255))
		.canFocus_(false)
		.value_(i+1)
		.font_(globalFont1);
	);

	//waveshape
	//??? to-do: view of a current position of playback (of course, only if it's possible for TGrains)
	sfViewList.add(
		GUI.soundFileView.new(w,Rect(slL+(i*hrIndex), slT+slH+50, slW, 30))
			.timeCursorOn_(true)
			.timeCursorColor_(Color.white)
			.timeCursorPosition_(0)
			.drawsWaveForm_(true)
			.gridOn_(true)
			.gridResolution_(1)
			.gridColor_(Color.white)
			.waveColors_([ btKnobColor, ctlMainColor1 ])
			.background_(ctlMainColor2)
			.canFocus_(false)
	);

	//recorder section
	//filename
	tvRecNameList.add(
		GUI.textView.new(w, Rect(slL+(i*hrIndex), slT+slH+83, slW, 15))
			.hasVerticalScroller_(false)
			.autohidesScrollers_(true)
			.font_(globalFont1)
			.string_("");
	);
	//buffer to file button
	btBufFile.add(
		RoundButton(w,Rect(slL+(i*hrIndex), slT+(slH*2)+2, 37, 17))
			.font_(globalFont1)
			.states_([ [\document, btColorOn, btColorStop] ])
			.radius_( 3 )
	);
	//buffer pool record button
	btBufRec.add(
		RoundButton(w,Rect(slL+(i*hrIndex)+40, slT+(slH*2)+2, 35, 17))
			.canFocus_(false)
			.states_([
				[\record, btColorPlay, btColorStop],
				[\stop, btColorStop, btColorPlay]
			])
			.radius_( 3 )
			.value_(0)
	);
	//rec time counter
	stTimeText.add(
		GUI.staticText.new(w, Rect(slL+80+(i*hrIndex), slT+(slH*2)+3, 40, 15))
			.font_(globalFont2)
			.string_("00:00");
	);



	// ... filters & effects

	//Perlin distrib
	knPerlinDurList.add(
		GUI.knob.new(w, Rect(slL+(i*hrIndex)+15, slT+(slH*2)+38, 30, 13)) // param - duration
			.value_(timeSpec.unmap(4.0.rand))
			.canFocus_(false)
	);
	stPerlinDurList.add(
		GUI.staticText.new(w, Rect(slL+(i*hrIndex)+15, slT+(slH*2)+65, 31, 10))			.font_(globalFont1)
			.align_(\center)
			.string_(timeSpec.map(knPerlinDurList[i].value));
	);
	knPerlinDurList[i].action_({ |sl|
		stPerlinDurList[i].string_(timeSpec.map(sl.value));
	});
	slPerlinDispList.add( // invisible!
		GUI.slider.new(w, Rect(slL+(i*hrIndex)+2, slT+(slH*2)+50, slW-27, 8)) // param - dispersion
			.background_(Gradient(Color.white, btColorEffColor, \h, 8))
			.visible_(false)
			.canFocus_(false)
			.value_(dispSpec.unmap(0.01));
	);
	stPerlinDispList.add( // invisible!
		GUI.staticText.new(w, Rect(slL+94+(i*hrIndex), slT+(slH*2)+49, slW-90, 10))
			.font_(globalFont1)
			.visible_(false)
			.string_(dispSpec.map(slPerlinDispList[i].value));
	);
	slPerlinDispList[i].action_({ |sl|
		stPerlinDispList[i].string_(dispSpec.map(sl.value));
	});
	knPerlinRaduisList.add(
		GUI.knob.new(w, Rect(slL+(i*hrIndex)+60, slT+(slH*2)+38, 30, 13)) // param - max radius
			.canFocus_(false)
			.value_(radSpec.unmap(0.5.rand));
	);
	stPerlinRaduisList.add(
		GUI.staticText.new(w, Rect(slL+(i*hrIndex)+60, slT+(slH*2)+65, 31, 10))
			.font_(globalFont1)
			.align_(\center)
			.string_(radSpec.map(knPerlinRaduisList[i].value));
	);
	knPerlinRaduisList[i].action_({ |sl|
		stPerlinRaduisList[i].string_(radSpec.map(sl.value));
	});



	// output channel dropdown list
	grChList.add(
		GUI.popUpMenu.new(w, Rect(slL+(i*hrIndex), slT+(slH*2)+80, 60, 20))
			.items_(chlistMono)
			.background_(btColorBG)
			.canFocus_(false)
			.font_(globalFont2)
	);

	//4ch setup
	//switch rotate on buttons
	btRotClock.add(
		RoundButton(w,Rect(slL+(i*hrIndex), slT+(slH*2)+108, 35, 25))
			.font_(globalFont4)
			.states_([
				[">", btColorOn, btColorStop],
				["->", btColorStop, slidColorProgress]
			])
			.radius_( 3 )
	);
	btRotAnticlock.add(
		RoundButton(w,Rect(slL+(i*hrIndex)+37, slT+(slH*2)+108, 35, 25))
			.font_(globalFont4)
			.states_([
				["<", btColorOn, btColorStop],
				["<-", btColorStop, slidColorProgress]
			])
			.radius_( 3 )
	);
	//frequency Knob
	sslRotateFreq.add(
		GUI.knob.new(w, Rect(slL+(i*hrIndex)+77, slT+(slH*2)+105, 31, 53))
			.canFocus_(false)
			.value_(rotateFreqSpec.unmap(0.5));
	);
	stRotateFreq.add(
		GUI.staticText.new(w, Rect(slL+(i*hrIndex)+84, slT+(slH*2)+131, 15, 15))
			.font_(globalFont1)
			.align_(\center)
			.string_(rotateFreqSpec.map(sslRotateFreq[i].value));
	);
	//4ch setup

	//actions
	grslidList[i].action_({
		if(synthList[i] != nil, {
			synthList[i].set(\ax, grslidList[i].x, \ay, grslidList[i].y);
			if(grModSwitchList[i].value == 1, { // to modulate or not to modulate?



//				synthList[i].set(\modf, 4400*(grslidList[i].y).abs); //SinOsc.kr modulation
				synthList[i].set(\modf, 4400*([-0.8, 0.8].asSpec.map(grslidList[i].y)).abs); //SinOsc.kr modulation
			});


		});

		grSTxList[i].string_(round(grslidList[i].x * 100, 0.1));
		grSTyList[i].string_(round(grslidList[i].y * 100, 0.1))
	});
	// for the purposes of saving RAM & CPU the volume slider controls also creation of the synth:
	// if vol != 0 the synth[i] is being created, othervise it's been freed
	grVolList[i].action_({ |sl|
		var currBufnum, currBufDur, currSynth;
		grSTVolList[i].string_(volSpec.map(grVolList[i].value));
		if(grVolList[i].value != 0, {
			// vol is not 0
			if(synthList[i] != nil, {
				synthList[i].set(\vol, sl.value);
			}, {
				//grFileList[i].action.value(grFileList[i].value); // load monobuf
				currBufnum = bufnumList.at(grFileList[i].value);
				currBufDur = bufDurList.at(grFileList[i].value);
				currSynth = \gmp ++ pmSynthNames[i].value ++ synthNameList.at(pmSynthNames[i].value);
				synthList[i] = Synth.new(currSynth, [
					\busnum, grChList[i].value,
					\bufnum, currBufnum,
					\bufdur, currBufDur,
					\ax, grslidList[i].x, \ay, grslidList[i].y,
					\panidx, grPanList[i].value,
					\vol, sl.value,
					\rotate, (0- (btRotAnticlock[i].value- btRotClock[i].value)),
					\rotfreq, rotateFreqSpec.map(sslRotateFreq[i].value)
				]);
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

	pmSynthNames[i].action_({ arg pm;
		var newSynthName, newSynth, currBufnum, currBufDur, xfadeTask, xfadeTime, currVol;
		newSynthName = \gmp ++ pmSynthNames[i].value ++ synthNameList.at(pmSynthNames[i].value);
		if(grVolList[i].value > 0.0, {
			if( synthList[i].defName != newSynthName , {
				grFileList[i].action.value(grFileList[i].value); // load monobuf
				currBufnum = bufnumList.at(grFileList[i].value);
				currBufDur = bufDurList.at(grFileList[i].value);

				//creating new synth with initial volume 0
				newSynth = Synth.new(newSynthName, [
					\busnum, grChList[i].value,
					\bufnum, currBufnum,
					\bufdur, currBufDur,
					\ax, grslidList[i].x, \ay, grslidList[i].y,
					\panidx, grPanList[i].value,
					\vol, 0.01,
					\rotate, (0- (btRotAnticlock[i].value- btRotClock[i].value)),
					\rotfreq, rotateFreqSpec.map(sslRotateFreq[i].value)
				]);

				//now cross-fading volumes of the current synth and new one
				//??? DOESNT WORK WITH TGRAINS !!!
				xfadeTime = timeSpec.map(slRamp.value);
				currVol = grVolList[i].value;
				xfadeTask = Task.new({ |time|
					var volInc, volDec;
					trunc(xfadeTime/0.01).do({ |j|
						volInc = currVol * (j/(trunc(xfadeTime/0.01)-1)).sqrt;
						volDec = currVol * (1-(j/(trunc(xfadeTime/0.01)-1)**3));
						newSynth.set(\vol, volInc);
						synthList[i].set(\vol, volDec);
						0.01.wait;
					});
					xfadeTask.stop;
					synthList[i].free;
					synthList[i] = newSynth;
					newSynth = nil;
				}).start;
			});
		});
	});

	grPanList[i].action_({
		if(synthList[i] != nil, { synthList[i].set(\panidx, grPanList[i].value) });
		grSTPanList[i].string_(round(grPanList[i].value, 0.01))
	});
	grChList[i].action_({
		if(synthList[i] != nil, { synthList[i].set(\busnum, grChList[i].value) });
	});

	// file list action
	// PROBLEMS:
	// - changing the file if the synth is active cause jumping into wrong position
	// - changing to 'internal buffer' doesn't make any effect at all
	grFileList[i].action_({ |popup|
		var filepath, soundfile, selStart, selEnd, checkBufLoadTask, tmpBuf, currVol;
		if(popup.value != 0, {
			btBufFile[i].enabled_(false); // buffer cannot be saved to a file
			filepath = XQ.globalBufferDict.at(poolName)[0][popup.value-1].path; // value-1 'cause the 1st buffer is always internal
			selStart = XQ.globalBufferDict.at(poolName)[1][popup.value-1][0];
			selEnd = selStart + XQ.globalBufferDict.at(poolName)[1][popup.value-1][1]-1;
			soundfile = SoundFile.new;
			soundfile.openRead(filepath);
			if(soundfile.numChannels == 2, {
				tmpBuf = Buffer.readChannel(s, filepath, selStart, channels: [0]); //if it's stereo, read only left channel
			}, {
				tmpBuf = Buffer.read(s, filepath, selStart);
			});

			sfViewList[i].drawsWaveForm_(true);
			sfViewList[i].soundfile_(soundfile);
			sfViewList[i].read(0, soundfile.numFrames);
			sfViewList[i].selectionDuration(0);
			sfViewList[i].refresh;

			soundfile.close;
			checkBufLoadTask = Task({
				inf.do({
					if(tmpBuf.numChannels != nil, {
						synthList.at(i).set(\bufnum, tmpBuf.bufnum);
						synthList.at(i).set(\bufdur, tmpBuf.numFrames/tmpBuf.sampleRate);
						checkBufLoadTask.stop;
					});
					0.1.wait;
				});
			}).start;
		}, {
			btBufFile[i].enabled_(true); // buffer can be saved to a file
			sfViewList[i].drawsWaveForm_(false); //clearing soundfile view
			synthList.at(i).set(\bufnum, tmpBuffer.bufnum); // set internal buffer
		});
		grVolList[i].valueAction_(grVolList[i].value);
	});

	//buffer to file button
	btBufFile[i].action_({ |butt|
		var file, f, buffer;

		filename = tvRecNameList[i].string;
		if(filename == "", {
			filename = "gmt_" ++ Date.getDate.stamp.asString;
		});
		file = "sounds/ixiquarks/"++filename++".aif";

		tmpBuffer.write(file, "AIFF");
		if(s.serverRunning, {
			buffer = Buffer.read(s, file);
			loadBufTask = Task({
				inf.do({ |j|
					if(buffer.numChannels != nil, {


						f = SoundFile.new;
						f.openRead(file);


						bufList.add(buffer);
						bufListSelections.add([0, f.numFrames]);
						f.close;
						XQ.globalBufferDict.add(poolName.asSymbol -> [bufList, bufListSelections]);
						//{ this.sendBufferPoolToWidgets }.defer;
						{ updateFileList.value(i) }.defer;
						loadBufTask.stop;
					});
				0.1.wait;
				});
			}).start;
		}, {
			XiiAlert("ixi alert: you need to start the server in order to record");
			btBufRec[i].value_(0);
		});
	});

	// -- buffer pool recording --
	//record button
	btBufRec[i].action_({ |butt|
		//start/stop recording to current open bufferpool
		var file, f, filesize, buffer;
		if(s.serverRunning == true, { // if the server is running
			if(butt.value == 1, {
				butt.inverse_(true);
				4.do({|j| //switch off all other recording
					if(j != i, {
						btBufRec[j].enabled_(false);
					})
				});
				currRec = i; // for the purpose of update time text only for the current recording

				filename = tvRecNameList[i].string;
				if(filename == "", {
					filename = "gmt_" ++ Date.getDate.stamp.asString;
					tvRecNameList[i].string_(filename);
				});

				recSynth = XiiRecord(s, monoChList.value, 1, sampleFormat: XQ.pref.bitDepth);
				recSynth.start("sounds/ixiquarks/"++filename++".aif");
				recSynth.setAmp_(grVolInput.value);
				secTask.start;
			}, {
				butt.inverse_(false);
				4.do({|j| //switch on other record-buttons
					if(j != i, {
						btBufRec[j].enabled_(true);
					})
				});
				recSynth.stop;
				secTask.stop;
				file = "sounds/ixiquarks/"++filename++".aif";
				buffer = Buffer.read(s, file);
				// -- buffer pool recording --
				tvRecNameList[i].string_("");
				if(s.serverRunning, {
					loadBufTask = Task({
						inf.do({ |j|
						if(buffer.numChannels != nil, {
							// get soundfile frames when loaded into buffer
							f = SoundFile.new;
							f.openRead(file);
							bufList.add(buffer);
							bufListSelections.add([0, f.numFrames]);
							f.close;
							XQ.globalBufferDict.add(poolName.asSymbol -> [bufList, bufListSelections]);
							//{ this.sendBufferPoolToWidgets }.defer;
							{ updateFileList.value(i) }.defer;
							loadBufTask.stop;
						});
						0.1.wait;
						});
					}).start;
				});
			});
		}, {
			XiiAlert("ixi alert: you need to start the server in order to record");
			btBufRec[i].value_(0);
		});
	});

	//4ch setup - rotate actions
	//switch rotate on buttons
	btRotClock[i].action_({ |bt|
		if (bt.value == 1, {
			btRotAnticlock[i].valueAction_(0);
			synthList[i].set(\rotate, 1, \rotfreq, rotateFreqSpec.map(sslRotateFreq[i].value))
		}, {
			synthList[i].set(\rotate, 0)
		})
	});
	btRotAnticlock[i].action_({ |bt|
		if (bt.value == 1, {
			btRotClock[i].valueAction_(0);
			synthList[i].set(\rotate,-1, \rotfreq, rotateFreqSpec.map(sslRotateFreq[i].value))
		}, {
			synthList[i].set(\rotate, 0)
		})
	});
	sslRotateFreq[i].action_({ |ssl|
		stRotateFreq[i].string = round(rotateFreqSpec.map(ssl.value), 0.1);
		synthList[i].set(\rotfreq, rotateFreqSpec.map(ssl.value))
	});
	//4ch setup
}); // end of synths loop

// global controls' actions
grslidGlob.action_({
	4.do({ |i|
		if(globSlidList[i] == 1, {
			grslidList[i].activex_(grslidGlob.x);
			grslidList[i].activey_(grslidGlob.y);
			grSTxList[i].string_(round(grslidList[i].x * 100, 0.1));
			grSTyList[i].string_(round(grslidList[i].y * 100, 0.1))
		});
	});


	grSTxGlob.string_(round(grslidGlob.x * 100, 0.1));
	grSTyGlob.string_(round(grslidGlob.y * 100, 0.1));
});


grVolGlob.action_({ |ssl|
	4.do({ |i|
		if (globVolList[i] == 1, {
			grVolList[i].valueAction_(ssl.value);
		});
	});


	grSTVolGlob.string_(volSpec.map(ssl.value));
});


grPanGlob.action_({ |ssl|
	4.do({ |i|
		grPanList[i].valueAction_(ssl.value);
	});


	grSTPanGlob.string_(round(ssl.value, 0.01));
});


monoChList.action_({
	if(synthIn != nil, { synthIn.set(\busnum, monoChList.value) });
});
grVolInput.action_({ arg sl;


	stVolInput.string_(volSpec.map(grVolInput.value));
	if(synthIn != nil, { synthIn.set(\volIn, grVolInput.value) });
});


grBufLen.action_({ |sl|
	stBufLen.string_(timeSpec.map(sl.value));
	bufDurList[0] = timeSpec.map(sl.value);


});


monoChList.action_({ |pm|
// -- buffer pool recording --
	ampAnalyserSynth.set(\inbus, pm.value);
	4.do({ |i|
		if(btBufRec[i].value == 1, { recSynth.inbus_(pm.value) })
	});
});
bufferList.action_({ |item|
	poolName = bufferList.items[item.value];
	loadFileList.value(poolName.asSymbol);
	// -- buffer pool recording --
	if(try { XQ.globalBufferDict.at(poolName)[0] } != nil, {
		bufList=List.new;
		bufListSelections=List.new;
		XQ.globalBufferDict.at(poolName)[0].do({ arg buffer, i;
			bufList.add(buffer);
			bufListSelections.add([0, buffer.numFrames]);
		 });
	});

});

//universal slider move


// params: interfce element, start val, end val, duration (s), density(0.001-1), shape (0-lin, 1-rand, 2-exp fast, 3-exp slow, 4-sin)
slideEnv = { arg elt, start, end, dur, density, shape;


	var xTask, randArrLev, randArrTime, env, total;
	total = max(trunc(dur/density), 1.0); //total number of cycles
	randArrLev = Array.fill(total, { max(start, end).linrand });
	randArrLev.put(0, start);
	randArrLev.put(total-1, end);
	randArrTime = Array.fill(total-1, { density });
	env = case



		{ shape == 0 } { Env.new([start, end], [dur],'linear').asStream } // linear
		{ shape == 1 } { Env.new(randArrLev, randArrTime,'linear').asStream } // random
		{ shape == 2 } { Env.new([start, end], [dur],'welch').asStream } // welch
		{ shape == 3 } { Env.new([max(start,0.001), max(end, 0.001)], [dur],'exponential').asStream } //exponential
		{ shape == 4 } { Env.new([start, end], [dur],'sine').asStream }; //sine






	xTask = Task.new({ |time|
		total.do({ |j|
			{ if( elt != nil, { elt.valueAction_(env.next) } )}.defer;
			density.wait;
		});
		xTask.stop;
		{ elt.valueAction_(end) }.defer; // the last move for exp envelope
	}).start;


};




// -- buffer pool recording --
// updating the seconds text
secTask = Task({var sec, min, secstring, minstring;
	sec = 0;
	min = 0;
	inf.do({ |i|
		sec = sec + 1;
		if(sec > 59, {min = min+1; sec = 0;});
		if(min < 10, {minstring = "0"++min.asString}, {minstring = min.asString});
		if(sec < 10, {secstring = "0"++sec.asString}, {secstring = sec.asString});
		{ stTimeText[currRec].string_(minstring++":"++secstring) }.defer;
		1.wait;
	});
});

// -- buffer pool recording --
// OSC responder for rec levels
responder = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
	{
	w.isClosed.not.if({ // if window is not closed, update GUI...
		if (msg[1] == ampAnalyserSynth.nodeID, {
			rslRecLevel.value = \amp.asSpec.unmap(msg[3]) * grVolInput.value;
		});

// LOOPER PANEL
		if((msg[2]-idNum >= 0) && (msg[2] <= (idNum+(8))), { // 8 means 4 tracks 2 indicators each (L & R)
			ssLoopVolInd.at(msg[2]-idNum).value_(1-(msg[3].ampdb.abs * 0.01))
		});
// LOOPER PANEL end

	});
	}.defer;
}).add;






//TASKS & EFFECTS
//perlin distrib
perlinDistr = { arg currPad, dur, disp, radius;
	var rp, xStart, yStart, perlinTask, ctrlPad, chanceX, chanceY;
	if(currPad > 3, { ctrlPad = grslidGlob }, { ctrlPad = grslidList[currPad] });


	xStart = ctrlPad.x; yStart = ctrlPad.y;
	chanceX = if(0.7.coin == true, {1}, {-1}); chanceY = if(0.5.coin == true, {1}, {-1});
	rp = RedPerlin.new;



	perlinTask = Task.new({ |time|
		trunc(dur/disp).do({ |j|
			{
				ctrlPad.activex_(sin(xStart) + (rp.noise1D(chanceX*sin(j/100), 0.75, 6, 1) * radius));
				ctrlPad.activey_(sin(yStart) + (rp.noise1D(chanceY*cos(j/100), 0.75, 6, 1) * radius));
				if(grModSwitchList[currPad].value == 1, { //SinOsc.rk modulation
					synthList[currPad].set(\modf, 4400*(yStart-ctrlPad.y).abs);
				});
			}.defer;
			disp.wait;
		});
		perlinTask.stop;
		{
			ctrlPad.activex_(xStart);
			ctrlPad.activey_(yStart);
			synthList[currPad].set(\modf, 1); //SinOsc.rk modulation switch off
		}.defer;
	}).start;


};


//keyboard control


w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	var tmpVar,
		keyArr = #[29, 18, 19, 20, 21, 23, 22, 26, 28, 25],  // char codes of numbers 0-9
		fKeyArr = #[18, 19, 20, 21, 23, 71, 89, 91], // Fn + "char" codes
		tyuiKeyArr= #[17, 16, 32, 34], // T Y U I
		ghjkKeyArr= #[5,  4,  38, 40], // G H J K
		five2eightKeyArr= #[23, 22, 26, 28], // 5-8
		five2eightKeyFnArr= #[23, 71, 89, 91, 8388608, 8388864, 10486016, 10485760]; // 5-8 & Fn (all possible modifiers)
	[char, modifiers, unicode, keycode].postln;

	// non-sequence collections of keys
	if (tyuiKeyArr.includes(keycode) == true, {
		tmpVar = tyuiKeyArr.find([keycode]); // index
		if( (modifiers == 0) || (modifiers == 256), {
			btRotClock[tmpVar].valueAction_(1- btRotClock[tmpVar].value);
		})
	});
	if (ghjkKeyArr.includes(keycode) == true, {
		tmpVar = ghjkKeyArr.find([keycode]); // index
		if( (modifiers == 0) || (modifiers == 256), {
			btRotAnticlock[tmpVar].valueAction_(1- btRotAnticlock[tmpVar].value);
		})
	});

// LOOPER PANEL keys
//	if (five2eightKeyArr.includes(keycode) == true, { // 5-8
//		tmpVar = keyArr.find([keycode]) - 5; // index
//
//		case
//		{ (modifiers == 0) || (modifiers == 256) } {
//			// here will be PAUSE
//		}
//	});

	if(five2eightKeyFnArr.includes(keycode) == true, { // Fn + 5-8
		tmpVar = five2eightKeyFnArr.find([keycode]); // index
		if( five2eightKeyFnArr.includes(modifiers), { // Fn+<num> - update fileLists, check last element
			updateLooperList.value(tmpVar);
		});
	});
// LOOPER PANEL end

	// sequences or single keys
	case
		{keycode == 27} {if(psetCurr <= psetNum, { psetList.put(psetCurr, nil); })} // minus, delete preset
		{keycode == 24} { // plus ("=" actually), add/update preset
			if(psetCurr <= psetNum, {
				saveSettings.value(psetCurr);
			})
		}
		{keycode == 11} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + v - select all volume global switches
			4.do({ |i|



				grGlobVolBtList[i].valueAction_(1);
				globVolList[i] = 1;
			});


		})}
		{keycode == 35} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + p - select all modulation switches
			4.do({ |i|
				grModSwitchList[i].valueAction_(1 - grModSwitchList[i].value);



			});
		})}


		{keycode == 17} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + t - select all 2Dsliders global switches
			4.do({ |i|



				grGlobBtList[i].valueAction_(1);
				globSlidList[i] = 1;
			});


		})}
		{keycode == 42} { // "\" (record / stop) & Alt + \ (loop record)
			if((modifiers == 524320) || (modifiers == 524576), { btInputLoop.valueAction_(1 - btInputLoop.value) });
			btInputRec.valueAction_(1 - btInputRec.value);
		}
		{(keycode >= 18) && (keycode < 22)} { // 1-4
			case
				{(modifiers == 0) || (modifiers == 256)} { // toggle vol (fade-in: exp fast,fade-out: exp slow)
					if( grVolList[char.digit-1].value > 0, {
						slideEnv.value(grVolList[char.digit-1], grVolList[char.digit-1].value, 0, 0.2, 0.001, 3);
					}, {
						slideEnv.value(grVolList[char.digit-1], 0, 0.9, 0.2, 0.001, 2);
					});
				}
				{(modifiers == 524320) || (modifiers == 524576)} { // Alt+<num> - check/uncheck global 2D
					grGlobBtList[keyArr.find([keycode])-1].valueAction_(1-grGlobBtList[keyArr.find([keycode])-1].value);
				}
				{(modifiers == 131330) || (modifiers == 131074)} { // Left Shift+<num> - check/uncheck SinOsc modulation
					grModSwitchList[keyArr.find([keycode])-1].valueAction_(1-grModSwitchList[keyArr.find([keycode])-1].value);
				}
				{(modifiers == 8388608) || (modifiers == 8388864)} { // Fn+<num> - update fileLists, check last element
					tmpVar = grFileList[fKeyArr.find([keycode])].value;
					updateFileList.value(fKeyArr.find([keycode]));
					if( grFileList[fKeyArr.find([keycode])].value == tmpVar, { // if the last file one has already being selected
						grFileList[fKeyArr.find([keycode])].valueAction_(0); // change for the first one - internal buffer
					});
				}
		}
		{(keycode >= 12) && (keycode < 16)} { //Q W E R - individual record
			if ( (modifiers == 0) || (modifiers == 256),
				{btBufRec[keycode-12].valueAction_(1-btBufRec[keycode-12].value)}
			)
		}
		{(keycode >= 0) && (keycode < 4)} { // A S D F - save buffer into file
			if(btBufFile[keycode].enabled == true, { btBufFile[keycode].valueAction_(1) })
		}
		{(keycode >= 6) && (keycode < 10)} { // Z X C V - Perlin x/y randomizator
			perlinDistr.value(keycode-6, timeSpec.map(knPerlinDurList[keycode-6].value), dispSpec.map(slPerlinDispList[keycode-6].value), radSpec.map(knPerlinRaduisList[keycode-6].value));
		}
		{keycode == 50} { // ` - global x/y randomizator
			perlinDistr.value(keycode, timeSpec.map(knPerlinDurGlob.value), dispSpec.map(slPerlinDispGlob.value), radSpec.map(knPerlinRaduisGlob.value));



		}

//		{keycode == 22} { // TEMP-6 task [20.8, 91.9] -> [95, 3.5]
//
//			var envX, envY, tempTask;


//



//			envX = Env.new([0.208, 0.950], [49],'lin').asStream; //exponential X
//			envY = Env.new([0.919, 0.035], [49],'lin').asStream; //exponential Y
//
//			tempTask = Task.new({ |time|
//				4900.do({ |j|
//					{
//						grslidList[2].activex_(envX.next);
//						grslidList[2].activey_(envY.next);
//					}.defer;
//					0.01.wait;
//				});
//				tempTask.stop;
//			}).start;
//
//		};



//		{(keycode == 71) || (keycode == 89) || (keycode == 91)} { // Fn + <num 6-8> - isn't necessary right now, maybe in the future
//				if((modifiers == 8388608) || (modifiers == 8388864) || (modifiers == 10485760) || (modifiers == 10486016), {
//				updateFileList.value(fKeyArr.find([keycode]))
//			});
//		};
};




// load file lists
loadFileList = { arg pn, update=1;
	poolName = pn;
	sndNameList=[];
	bufnumList=List.new; bufDurList=List.new;
	bufList=List.new; bufListSelections=List.new;
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
			// -- buffer pool recording --
			bufList.add(buffer);
			bufListSelections.add([0, buffer.numFrames]);
		 });
	});
	if(update == 1, {
		// put the new sounds into popupmenus
		4.do({ |j|
			grFileList[j].items_(sndNameList);
			grFileList[j].action.value(j); // for the purpose of showing wave-shape
		});
	});
};






updateFileList = { |currPad| // update fileLists, check last element



	loadFileList.value(bufferList.items[bufferList.value].asSymbol, 0); // update filelists
	grFileList[currPad].items_(sndNameList); // put the new sounds into current popupmenu
	grFileList[currPad].valueAction_(grFileList[currPad].size-1); // select last element
};


// update pool and fileList on open
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
loadFileList.value(XQ.poolNames[0].asSymbol); // load the first pool
//XQ.globalBufferDict.at(\solo0)[0].do({ |buffer, i| XQ.globalBufferDict.at(\solo0)[0][i].postln });
//bufList.size-1.do({ |i| bufList[i].postln; });







//pre-sets section
psetCurr = psetNum+1; // initial state, means no pre-set is choosen

psetNum.do({ |i|
	psetButtList.add(
		RoundButton(w,Rect(
				3+((if(i<(psetNum/2), {i}, {i-(psetNum/2)}))*25),
				2+((if(i<(psetNum/2), {0}, {1}))*22),
				25, 22 )
		)
			.font_(globalFont2)
			.canFocus_(false)
			.radius_(2)
			.border_(0.5)
			.states_([
				[(i+1).asString, Color.black, ctlMainColor2], // 0 - no pre-set
				[(i+1).asString, Color.black, Color.red(alpha:0.1)], // 1 - pre-set
				[(i+1).asString, Color.white, ctlColor11] // 2 - pushed button
			])
			.value_(if(psetList[i] != nil, { 1 }, { 0 }))
			.action_({ psetChange.value(i) });
	);
});

psetChange = { |preset|
	if((preset != psetCurr) && (psetCurr <= psetNum), {
		psetButtList[psetCurr].value = if(psetList[psetCurr] != nil, { 1 }, { 0 }); // make the previously chosen pre-set into previous state
	});
	psetButtList[preset].value = 2; // push the button
	psetCurr = preset;
	restoreSettings.value(psetCurr);
};



saveSettings = { |pset|
	var psetSynth, psetCurrList;
	psetCurrList = List.fill(5, nil); // 4 synths + global settings
	4.do({ |i|



		psetSynth = Array.fill(20, nil); // settings list of a synth (0-10 in use, 11-19 reserved for future use)
		psetSynth.put(0, synthNameList.at(pmSynthNames[i].value)); // 0 - synth name


		psetSynth.put(1, grChList[i].value); // 1 - buses
		psetSynth.put(2, grslidList[i].x); // 2 - 2D slider X
		psetSynth.put(3, grslidList[i].y); // 3 - 2D slider Y
		psetSynth.put(4, grGlobBtList[i].value); // 4 - global XY
		psetSynth.put(5, grVolList[i].value); // 5 - volume
		psetSynth.put(6, grGlobVolBtList[i].value); // 6 - volume global mode
		psetSynth.put(7, grPanList[i].value); // 7 - wide
		psetSynth.put(8, grModSwitchList[i].value); // 8 - modulation switch
		psetSynth.put(9, grFileList[i].value); // 9 - soundfile
		psetSynth.put(10, knPerlinDurList[i].value); // 10 - perlin - duration
		psetSynth.put(11, slPerlinDispList[i].value); // 11 - perlin - dispersion
		psetSynth.put(12, knPerlinRaduisList[i].value); // 12 - perlin - radius
		psetCurrList.put(i, psetSynth); // put synthgran[i] settings into the pre-set list
	});
	psetSynth = Array.fill(20, nil); // global settings
	psetSynth.put(0, "global"); // 0 - "global"
	psetSynth.put(1, monoChList.value); // 1 - global input bus
	psetSynth.put(2, grslidGlob.x); // 2 - global 2D slider X
	psetSynth.put(3, grslidGlob.y); // 3 - global 2D slider Y
	psetSynth.put(4, grVolGlob.value); // 4 - global volume
	psetSynth.put(5, grVolInput.value); // 5 - input volume
	psetSynth.put(6, slRamp.value); // 6 - swith pre-set ramp time
	psetSynth.put(7, grPanGlob.value); // 7 - global wide
	psetSynth.put(8, timeSpec.map(grBufLen.value)); // 8 - input buffer length
	psetSynth.put(9, bufferList.value); // 9 - buffer num
	psetSynth.put(10, knPerlinDurGlob.value); // 10 - perlin - duration
	psetSynth.put(11, slPerlinDispGlob.value); // 11 - perlin - dispersion
	psetSynth.put(12, knPerlinRaduisGlob.value); // 12 - perlin - radius
	psetCurrList.put(4, psetSynth); // the list of global settings is no 4 in the pre-set list

	psetList.put(pset, psetCurrList);
};





restoreSettings = {arg pset;
	var presetCurrNode, startVol;
	if(psetList[pset] != nil, {
		presetCurrNode = psetList[pset]; // current presets list

		// first restore global settings
		monoChList.valueAction_(presetCurrNode[4][1]);
		grslidGlob.activex_(presetCurrNode[4][2]);
		grslidGlob.activey_(presetCurrNode[4][3]);
		grVolGlob.valueAction_(presetCurrNode[4][4]);
		grVolInput.valueAction_(presetCurrNode[4][5]);
		slRamp.valueAction_(presetCurrNode[4][6]);
		grPanGlob.valueAction_(presetCurrNode[4][7]);
		grBufLen.valueAction_(timeSpec.unmap(presetCurrNode[4][8]));
		bufferList.valueAction_(presetCurrNode[4][9]); // decide what to do with buffer
		knPerlinDurGlob.valueAction_(presetCurrNode[4][10]);
		slPerlinDispGlob.valueAction_(presetCurrNode[4][11]);
		knPerlinRaduisGlob.valueAction_(presetCurrNode[4][12]);

		// prepare to refill global arrays


		globSlidList = Array.fill(4, 0);
		globVolList = Array.fill(4, 0);
		//globPanList = Array.fill(4, 0);



		4.do({ |i|
			// WARNING!! the order of the updates matters!
			startVol = grVolList[i].value;
			if(startVol == 0, {
				// no crossfade if there's no synth working previously, simple substitution
				pmSynthNames[i].valueAction_(synthNameList.find([presetCurrNode[i][0]]));
			});
			grChList[i].valueAction_(presetCurrNode[i][1]);


			grGlobBtList[i].valueAction_(presetCurrNode[i][4]);


			grFileList[i].valueAction_(presetCurrNode[i][9]);



			grslidList[i].activex_(presetCurrNode[i][2]);
			grslidList[i].activey_(presetCurrNode[i][3]);


			grVolList[i].valueAction_(presetCurrNode[i][5]);


			pmSynthNames[i].valueAction_(synthNameList.find([presetCurrNode[i][0]]));


			grGlobVolBtList[i].valueAction_(presetCurrNode[i][6]);


			grPanList[i].valueAction_(presetCurrNode[i][7]);


			grModSwitchList[i].valueAction_(presetCurrNode[i][8]);


			knPerlinDurList[i].valueAction_(presetCurrNode[i][10]);
			slPerlinDispList[i].valueAction_(presetCurrNode[i][11]);
			knPerlinRaduisList[i].valueAction_(presetCurrNode[i][12]);


`			// only the states of the buttons updated, so have to update global lists manually
			globSlidList[i] = grGlobBtList[i].value;
			globVolList[i] = grGlobVolBtList[i].value;


		});
	});
};



//orientation grids
w.drawHook = {
	Pen.strokeColor = Color.white;
	//5, 80, 115, 100
	//vertical top to bottom
	Pen.line((slL-140+trunc(slW/2))@slT+1, (slL-140+trunc(slW/2))@(slT+slH-2)); // global
	4.do({ |i| Pen.line((slL+(i*hrIndex)+trunc(slW/2))@slT+1, (slL+(i*hrIndex)+trunc(slW/2))@(slT+slH-2)) }); // 1-4
	//horizontal left to right
	Pen.line((slL-140+1)@(slT+trunc(slH/2)+1), (slL-140+slW-2)@(slT+trunc(slH/2)+1)); // global
	4.do({ |i| Pen.line((slL+(i*hrIndex)+1)@(slT+trunc(slH/2)+1), (slL+(i*hrIndex)+slW-2)@(slT+trunc(slH/2)+1)); }); // 1-4
	//diagonal left top to right bottom
	Pen.line((slL-140+1)@(slT+1), (slL-140+slW-2)@(slT+slH-2)); // global
	4.do({ |i| Pen.line((slL+(i*hrIndex)+1)@(slT+1), (slL+(i*hrIndex)+slW-2)@(slT+slH-2)); }); // 1-4
	//diagonal left bottom to right top
	Pen.line((slL-140+1)@(slT+slH-2), (slL-140+slW-2)@slT+1); // global
	4.do({ |i| Pen.line((slL+(i*hrIndex)+1)@(slT+slH-2), (slL+(i*hrIndex)+slW-2)@slT+1); }); // 1-4
	//orientation rectangle
	Pen.addRect(Rect(slL-140+trunc(slW/4), slT+trunc(slT/4)+4, trunc(slW/2)+2, trunc(slH/2)+1)); // global
	4.do({ |i| Pen.addRect(Rect(slL+(i*hrIndex)+trunc(slW/4), slT+trunc(slT/4)+4, trunc(slW/2)+2, trunc(slH/2)+1)); }); // 1-4
	Pen.stroke;
};


// LOOPER PANEL

//problems:
//- when "loop" switched off, playback continues until the end of file, ignoring selection
//to-do:
//- file system & drag-n-drop (w/automatic addition to buffer pool)
//- see "SCKnob" help for mouseOverAction_ - use it to show value in status bar


tracks.do({ |i|


	var trigID= idNum + (i * 2);

	// looper area


	cvLoopArea.add(
		CompositeView(w,Rect(loopLeft+(i*loopWidth), loopTop+45, loopWidth, 180))
			.background_(loopColorTransp)
	);
	// waveform area
	cvLoopWaveArea.add(
		CompositeView(w,Rect(loopLeft, loopTop+230, loopWidth*5+(loopWidth/2), 150))
			.background_(loopColorTransp)
	);
	// waveform
	sfLoopWave.add(
		SCSoundFileView.new(cvLoopWaveArea[i], Rect(loopWidth+20, 5, loopWidth*4+20, 90))
			.timeCursorOn_(true)
			.timeCursorColor_(Color.white)
			.timeCursorPosition_(0)
			.drawsWaveForm_(true)
			.gridOn_(true)
			.gridResolution_(1)
			.gridColor_(Color.white)
			.waveColors_([ btKnobColor, btKnobColor ])
			.background_(ctlMainColor2)
			.setSelectionColor(0, ctlMainColor1)
			.elasticMode_(true)
			.canFocus_(false)
	);

	// button - selecting current looper


	btLoopAreaList.add(


		RoundButton(w,Rect(loopLeft+(i*loopWidth), loopTop, loopWidth, 45))
			.canFocus_(false) .font_(globalFont3) .radius_(3) .border_(0.5) .value_(0)
			.states_([
				[fillStr ++ (i+5).asString, loopColorCurr, loopColorBg],
				[fillStr ++ (i+5).asString, loopColorBg, loopColorCurr]
			])
			.action_({ |bt|
				4.do({ |j|
					if( (btLoopAreaList[j].value == 1) && (j != i), { btLoopAreaList[j].value = 0 });
					cvLoopArea[j].background_(loopColorTransp);
					cvLoopWaveArea[j].visible = false;
				});
				bt.value = 1; // keep current state, at least one looper should be active
				cvLoopArea[i].background_(loopColorCurr);
				cvLoopWaveArea[i].visible = true;
			})
	);
	// soundfiles
	pmLoopFileList.add(
		GUI.popUpMenu.new(cvLoopArea[i] ,Rect(5, 5, loopWidth - 10, 15))
			.background_(Color.new255(255, 255, 255))
			.canFocus_(false)
			.items_(sndNameList)
			.value_(i+1)
			.font_(globalFont1)
			.action_({ |popup|
				var filepath, soundfile, selStart, selEnd, checkBufLoadTask, tmpBuf;
				if(popup.value != 0, {
					filepath = XQ.globalBufferDict.at(poolName)[0][popup.value-1].path; // value-1 'cause the 1st buffer is always internal
					selStart = XQ.globalBufferDict.at(poolName)[1][popup.value-1][0];
					selEnd = selStart + XQ.globalBufferDict.at(poolName)[1][popup.value-1][1]-1;
					soundfile = SoundFile.new;
					soundfile.openRead(filepath);
					sfLoopWave[i].drawsWaveForm_(true);
					sfLoopWave[i].soundfile_(soundfile);
					sfLoopWave[i].read(0, soundfile.numFrames);
					sfLoopWave[i].selectionDuration(0);
					sfLoopWave[i].refresh;
					soundfile.close;

					//filling out the array of initial positions
					currPosList[i] = sfLoopWave[i].selections[0][0];
				}, {
					sfLoopWave[i].drawsWaveForm_(false); //clearing soundfile view
				});
			});
	);
	// panorama knob
	knLoopPan.add(
		Knob(cvLoopArea[i], Rect(5, 25, 30, 13))
			.centered_(true)
			.value_(0.5)
			.action_({ |sl|
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\pan, \pan.asSpec.map(sl.value)) });
//				//global settings
//				panArray[i] = sl.value;
//				params[3] = panArray;
			})
	);
	//volume indicator - left channel
	ssLoopVolInd.add(
		SmoothSlider(cvLoopArea[i], Rect(42, 25, 10, 100))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))

	);
	//volume indicator - right channel
	ssLoopVolInd.add(
		SmoothSlider(cvLoopArea[i], Rect(53, 25, 10, 100))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume slider
	ssLoopVol.add(
		SmoothSlider(cvLoopArea[i], Rect(64, 25, 10, 100))
			.background_(Color.gray(alpha:0.01))
			.hilightColor_(Gradient(btKnobColor, ctlColor10, 12))
			.knobSize_(0.4)
			.knobColor_(btKnobColor)
			.mode_(\move)
			.value_(volSpec.unmap(-1.0))
			.action_({ |sl|
				var globalActiveCounter = 0, volAll = 0;
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\vol, sl.value) });
//				//global settings
//				tracks.do({ |i|
//					if(globalList[i] == 1, {
//						globalActiveCounter = globalActiveCounter + 1;
//						volAll = volAll + sl.value;
//						globalVolSlider.value_(volAll/globalActiveCounter);
//					})
//				});
//				volArray[i] = sl.value;
//				params[2] = volArray;
			})
	);

	// start/stop button
	btLoopPlayStop.add(
		RoundButton(cvLoopArea[i], Rect(5, 60, 30, 18))
			.canFocus_(false)
			.states_([
				[\play, btColorOn, ctlColor10],
				[\stop, btColorPlay, loopColorCurr]
			])
			.radius_(3)
			.border_(2)
			.value_(0)
			.action_({ arg butt; var startPos, endPos, buffer;
				if(butt.value == 1, {
					if (pmLoopFileList[i].value != 0, {
						buffer = XQ.buffers(poolName)[pmLoopFileList[i].value-1]
					}, {
						buffer = tmpBuffer
					});

					trigID = idNum + (i * 2);

//					startPos = XQ.selections(poolName)[pmLoopFileList[i].value][0] + (params[7][i][0] * XQ.selections(poolName)[sfdropDownList[i].value][1]);
//					endPos = XQ.selections(poolName)[sfdropDownList[i].value][0] + (XQ.selections(poolName)[sfdropDownList[i].value][1] * params[7][i][1]);

					startPos= sfLoopWave[i].selections[0][0];
					endPos= startPos + sfLoopWave[i].selections[0][1];
					if(sfLoopWave[i].selectionSize(0) < 10, {
					 	endPos = buffer.numFrames-1;
						seltime = (buffer.numFrames-startPos)/buffer.sampleRate;
					}, {
						seltime = sfLoopWave[i].selections[0][1]/buffer.sampleRate;
					});
					//("startPos, endPos= " + [startPos, endPos]).postln;

					// switch on playback indicator
					moveTimeCursor.value(i, buffer.sampleRate, startPos, endPos, 0);

					loopSynthList[i] =
						if(buffer.numChannels == 2, {
							Synth.new(\gmpLoopStereo,
								[ \bufnum, buffer.bufnum,
								  \trigID, trigID, // the bus for the gui update
								  \out, pmLoopChList[i].value * 2,
								  \trig, 1/seltime, // trigger for loop
								  \vol, ssLoopVol[i].value,
								  \pan, \pan.asSpec.map(knLoopPan[i].value),
								  \pitch, 1, // fill later
								  \startPos, startPos,
								  \endPos, endPos,
								  \loop, 1-btLoopMode[i].value
								  ],
								  s, \addToHead);
						}, {
							Synth.new(\gmpLoopMono,
								[ \bufnum, buffer.bufnum,
								  \trigID, trigID, // the bus for the gui update
								  \out, pmLoopChList[i].value * 2,
								  \trig, 1/seltime, // trigger for loop
								  \vol, ssLoopVol[i].value,
								  \pan, \pan.asSpec.map(knLoopPan[i].value),
								  \pitch, 1, // fill later
								  \startPos, startPos,
								  \endPos, endPos,
								  \loop, 1-btLoopMode[i].value
								  ], // the default out bus
								  s, \addToHead);
						});
					},{
						loopSynthList[i].free;
						loopSynthList[i] = nil;

						// volume indicators to 0
						slideEnv.value(ssLoopVolInd[i*2], ssLoopVolInd[i*2].value, volSpec.unmap(0.ampdb), 1.5, 0.01, 2);
						slideEnv.value(ssLoopVolInd[i*2+1], ssLoopVolInd[i*2+1].value, volSpec.unmap(0.ampdb), 1.5, 0.01, 2);
						// stop moving playback indicator
						moveTimeCursor.value(i, 0, 0, 0, -1);
					});
		})
	);
	// pause button
	btLoopPause.add(
		RoundButton(cvLoopArea[i], Rect(5, 80, 30, 18))
			.canFocus_(false)
			.states_([
				[\pause, btColorOn, ctlColor10],
			])
			.radius_(3)
			.border_(2)
			.value_(0)
	);
	// record button
	btLoopRec.add(
		RoundButton(cvLoopArea[i], Rect(5, 101, 30, 18))
			.canFocus_(false)
			.states_([
				[\record, btColorPlay, btColorStop],
				[\stop, btColorStop, btColorPlay]
			])
			.radius_(3)
			.border_(2)
			.value_(0)
			.action_({ |butt|
				//start/stop recording to current open bufferpool
				var file, f, filesize, buffer;
				if(s.serverRunning == true, { // if the server is running
					if(butt.value == 1, {
						butt.inverse_(true);
						4.do({|j| //switch off all other recording
							btBufRec[j].enabled_(false);
							if(j != i, {
								btLoopRec[j].enabled_(false);
							})
						});
						currRec = i; // for the purpose of update time text only for the current recording

						filename = tvRecNameList[i].string;
						if(filename == "", {
							filename = "gmt_" ++ Date.getDate.stamp.asString;
						});

						recSynth = XiiRecord(s, monoChList.value, 1, sampleFormat: XQ.pref.bitDepth);
						recSynth.start("sounds/ixiquarks/"++filename++".aif");
						recSynth.setAmp_(grVolInput.value);
						secTask.start;
					}, {
						butt.inverse_(false);
						4.do({|j| //switch on other record-buttons
							btBufRec[j].enabled_(true);
							btLoopRec[j].enabled_(true);
						});
						recSynth.stop;
						secTask.stop;
						file = "sounds/ixiquarks/"++filename++".aif";
						buffer = Buffer.read(s, file);
						// -- buffer pool recording --
						loadBufTask = Task({
							inf.do({ |j|
							if(buffer.numChannels != nil, {
								// get soundfile frames when loaded into buffer
								f = SoundFile.new;
								f.openRead(file);
								bufList.add(buffer);
								bufListSelections.add([0, f.numFrames]);
								f.close;
								XQ.globalBufferDict.add(poolName.asSymbol -> [bufList, bufListSelections]);
								//bookmark
								{ updateLooperList.value(i) }.defer;
								loadBufTask.stop;
							});
							0.1.wait;
							});
						}).start;
					});
				}, {
					XiiAlert("ixi alert: you need to start the server in order to record");
					btBufRec[i].value_(0);
				});
			}
			)
	);
	// loop/one button
	btLoopMode.add(
		RoundButton(cvLoopArea[i], Rect(75, 101, 20, 18))
			.canFocus_(false)
			.states_([
				[\roundArrow, btColorOn, btColorOff],
				[\lineArrow, btColorOff, btColorOn]
			])
			.radius_(3)
			.border_(2)
			.value_(0)
			.action_({ |bt|
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\loop, 1-bt.value) });
			})
	);
	// ramp time before triggering
	// WARNING! time in miliseconds!
	nbLoopTrigRamp.add(
		SCNumberBox.new(cvLoopArea[i], Rect(5, 130, 35, 16))
			.font_(globalFont1)
			.background_(btColorBG)
			.clipLo_(0.0)
			.clipHi_(10000.0)
			.value_(0.0)
			.step_(50.0) // doesn't work - why?
	);
	// playback position progress bar
	ssLoopPlaybackInd.add(
		SmoothSlider(cvLoopArea[i], Rect(45, 130, loopWidth - 48, 16))
			.background_(Color.gray(alpha:0.01))
			.knobColor_(btColorEffColor)
			.visible_(false)
			.hilightColor_(btColorEffColor)
			.knobSize_(0.1)
			.canFocus_(false)
			.mode_(\move)
			.value_(0);
	);
	// output channel dropdown list
	pmLoopChList.add(
		SCPopUpMenu.new(cvLoopArea[i], Rect(5, 153, 62, 20))
			.items_(chlistStereo)
			.background_(btColorBG)
			.canFocus_(false)
	);
	// button for changing modes stereo/mono
	btLoopChanMode.add(
		RoundButton(cvLoopArea[i], Rect(70, 153, 20, 20))
			.canFocus_(false)
			.states_([
				["st", btColorOn, ctlColor10],
				["mn", btColorOn, loopColorCurr]
			])
			.radius_(3)
			.border_(1)
			.value_(0)
			.action_({ |bt|
				var currVal = pmLoopChList[i].value;
				if(bt.value == 0, { // switch to stereo
					pmLoopChList[i].items_(chlistStereo);
					pmLoopChList[i].valueAction_(trunc(currVal / 2));
				}, { // switch to mono
					pmLoopChList[i].items_(chlistMono);
					pmLoopChList[i].valueAction_(currVal * 2);
				})
			})
	);
});

btLoopAreaList[0].valueAction_(1); // make the 1st looper active
//initial settings before open
4.do({ |i|
	pmLoopFileList[i].valueAction_(i);
});

//bookmark
// action (0 - start, 1 - pause, -1 - stop)
moveTimeCursor = { arg curr, sRate, start, end, action= 0;
	var pos= 0, dur= end-start;




	sfLoopWave[curr].timeCursorPosition_(start);
	ssLoopPlaybackInd[curr].value=0;
	ssLoopPlaybackInd[curr].visible = true;






	case
		{action == 0}  {
			if(indTaskList[curr] != nil, {
				indTaskList[curr].play
			}, {
				indTaskList[curr]= Task.new({ |time|
					inf.do({ |i|
						{
							w.isClosed.not.if({
								sfLoopWave[curr].timeCursorPosition_(start+pos);
								ssLoopPlaybackInd[curr].value = pos.linlin(0, dur, 0, 1);
							});

							if((start+pos) >= end, {
								if(btLoopMode[curr].value == 0, { // loop is on
									sfLoopWave[curr].timeCursorPosition_(start);
									ssLoopPlaybackInd[curr].value = 0;
									pos= 0;
								}, {
									ssLoopPlaybackInd[curr].visible = false;
									indTaskList[curr].stop;
								})
							});
						}.defer;

						pos= pos + (sRate/100);
						0.01.wait;
					});
				}).start;
			});
		}
		{action == 1}  { if(indTaskList[curr] != nil, {
			indTaskList[curr].pause;
			currPosList[i] = pos;
		}) }
		{action == -1} { if(indTaskList[curr] != nil, {
			ssLoopPlaybackInd[curr].visible = false;
			indTaskList[curr].stop;
			indTaskList[curr]= nil;
		}) };
};





updateLooperList = { |currPad| // update fileLists, check last element



	loadFileList.value(bufferList.items[bufferList.value].asSymbol, 0); // update filelists
	pmLoopFileList[currPad].items_(sndNameList); // put the new sounds into current popupmenu of looper
	pmLoopFileList[currPad].valueAction_(pmLoopFileList[currPad].size-1); // select last element
};


// LOOPER PANEL end







//4ch setup
//evChPos = EnvelopeView(w, Rect(470, 390, 150, 150))
//	.thumbWidth_(15.0)
//	.thumbHeight_(15.0)
//	.drawLines_(false)
//	.drawRects_(true)
//	.selectionColor_(Color.red)
//	.value_([[0.3, 0.45, 0.6, 0.75], [0.9, 0.88, 0.86, 0.84]])
//	.gridOn_(true)
//	.action_({ |ev|
//		if(synthList[ev.index] != nil, {
//			synthList[ev.index].set(\azim, ev.value[0][ev.index]);


//			synthList[ev.index].set(\elev, ev.value[1][ev.index]);
//		});
//		[
//			[-pi,pi].asSpec.map(ev.value[0][ev.index]),
//			[-0.5pi, 0.5pi].asSpec.map(ev.value[1][ev.index])
//		].postln
//	});


//
//4.do({ |i|
//	evChPos.setString(i, ["1", "2", "3", "4"].at(i));
//	evChPos.setFillColor(i,Color.white);
//});
//


//// speakers labels


//GUI.staticText.new(w, Rect(evChPos.bounds.left+1, evChPos.bounds.top+1, 25, 20))


//	.string_("fL-0")
//	.font_(globalFont4);
//GUI.staticText.new(w, Rect(evChPos.bounds.left+evChPos.bounds.width-26, evChPos.bounds.top+1, 25, 20))
//	.string_("fR-1")
//	.font_(globalFont4);
//GUI.staticText.new(w, Rect(evChPos.bounds.left+evChPos.bounds.width-26, evChPos.bounds.top+evChPos.bounds.height-21, 25, 20))
//	.string_("rR-2")
//	.font_(globalFont4);
//GUI.staticText.new(w, Rect(evChPos.bounds.left+1, evChPos.bounds.top+evChPos.bounds.height-21, 25, 20))
//	.string_("rL-3")
//	.font_(globalFont4);
//4ch setup

//MIDI


//MIDIClient.init(4,3);			// explicitly intialize the client
//4.do({ arg i; MIDIIn.connect(i, MIDIClient.sources.at(i)); });
MIDIClient.init(13,3);			// explicitly intialize the client
13.do({ arg i; MIDIIn.connect(i, MIDIClient.sources.at(i)); });


ccResp = CCResponder({ |src, chan, num, val|
	var five2eightKeys=  #[88, 89, 90, 118]; // T Y U I


	[src,chan,num,val].postln;
	case
		{ (num >= 16) && (num < 20) } {  // vol knobs
			{ grVolList[num - 16].valueAction_(val.linlin(0, 127, 0, 1)) }.defer
		}
		{ ((num >= 88) && (num < 91)) || (num == 118) } {
			{
				btLoopPlayStop[five2eightKeys.find([num])].valueAction_(1-btLoopPlayStop[five2eightKeys.find([num])].value);
			}.defer
		}
		{ (num >= 28) && (num < 32) } {
			{ grslidList[num - 28].activey_(val.linlin(0, 127, 0, 1)); }.defer  // 28-31 X
		}
		{ (num >= 20) && (num < 24) } {  // 20-23 rotate freq
			{ ssLoopVol[num - 20].valueAction_(val.linlin(0, 127, 0, 1)) }.defer
		}
	},
	nil,
	0, nil, nil
);


//MIDI

w.refresh;
w.front;

w.onClose = {
	SystemClock.clear;

	ampAnalyserSynth.free; // kill the analyser
	responder.remove; // kill the OSC responder

	presetsFile = File.new("preferences/gmpsets4ch.dk", "w");
	presetsFile.write(psetList.asCompileString);
	presetsFile.close;
	4.do({ |i|
		synthList[i].free;
// LOOPER PANEL
		loopSynthList[i].free;
// LOOPER PANEL end
	});
	synthIn.free;
	ccResp.remove; //MIDI
};

)