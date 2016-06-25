
// after creating new gran-synth,
// !!!!   DON'T FORGET !!!
// to add it into synthNameList (number of the element should be corresponding the number in the name of synth)
//
// WARNING! the code labelled " -- buffer pool recording -- " is adopted from XiiBufferPool.sc and dependent on ixi


//= GUI and controls =


(


var tracks= 4;


var synthList= Array.fill(tracks, nil), channels;
var poolName, pool, poolindex, poolnamesarray;
var tmpBuffer, synthIn;
var w;
var slL=200, slT=450, slW=115, slH=100, hrIndex = 120, granWidth= 90, leftPos=200, topPos= 45;
var globalFont1=Font("Helvetica", 9), globalFont2=Font("Helvetica", 12), globalFont3=Font("Helvetica", 36), globalFont4=Font("Helvetica", 13), globalFont5=Font("Helvetica", 14);
var ctlFocusColor=Color.red(alpha:0.2), ctlMainColor1=Color.new255(205, 138, 138), ctlMainColor2=Color.new255(205, 200, 177), ctlColor10=Color.new255(205, 92, 92, 0.05), ctlColor11=Color.new255(205, 92, 92), ctlColor20=Color.new255(100, 149, 237, 0.6), ctlColor21=Color.new255(70, 130, 180), btColorOff=Color.new255(250, 250, 250), btColorOn=Color.new255(43, 43, 43), btColorPlay=Color.new255(178, 34, 34), btColorStop=Color.new255(238, 216, 174), slidColorProgress=Color.new255(123, 104, 238), btKnobColor=Color.new255(205, 38, 38), btColorBG = Color.new255(248, 248, 255), btColorEffColor=Color.new255(96, 123, 139), ctlMainColorTransp= Color.new255(205, 138, 138, 0.3), stlColorKnob= Color.new255(52,70,83);
var chlistStereo, chlistMono, bufferList, bufnumList=List.new, monoChList, stereoChList;
var sndNameList=[], bufDurList=List.new;
var grSTxList=List.new, grSTyList=List.new, grslidList=List.new, grVolList=List.new, grVol0= List.new, grChList=List.new, rsWideRangeList= List.new, slMiscDev= List.new, slMiscAve= List.new;
var sfViewGran, waveStep=0; //, sfViewDraw;
var slRamp, stRamp, grVolInput, grBufLen, stBufLen, btInputLoop, btInputRec, rslInputDur, btPlayBuff;
var timeSpec=[0.5, 10, \lin, 0.5, 1, "sec"].asSpec, sec3Spec= [0.5, 3, \lin, 0.5].asSpec, volSpec=ControlSpec(0.ampdb, 2.ampdb, \db, units: " dB"), dispSpec=[0.5, 0.001, \lin, 0.001].asSpec, radSpec=[0.01, 1, \lin, 0.01].asSpec;
var grGlobBtList=List.new, grModSwitchList=List.new, globSlidList=Array.fill(4, 0);
var cvIntBuf;
var psetNum=50, psetButtList=List.new, psetList=Array.fill(psetNum, nil), psetCurr, psetChange, saveSettings, restoreSettings;
var presetsFile=nil;
var synthNameList, pmSynthNames= List.new, stSynthNames= List.new, stSynthSelect= List.new;


var btGranAreaList= List.new, btGranAreaLabels, cvGranArea= List.new, cvGranWaveArea= List.new, ssGranVolInd= List.new, stFilename= List.new;
var cvBufList, lvBuffers, btAddFile, btFreeFile, btSaveBuf, lvGranSynths, stStatusBar, btPanic;
var currGran, bufTrack= Array.fill(tracks*2, 0);
var volAction, synthNamesAction;
var dragSrc, currDragFile, idPad= 60; // granulators start from 60


// -- buffer pool recording --
var ampAnalFunc, ampAnalyserSynth, responder, numChannels, recSynth, secTask, updateFileList, loadBufTask, currRec=4, filename;
var rslRecLevel, tvRecNameList=List.new, stTimeText=List.new, btBufFile=List.new, btBufRec=List.new, bufList=List.new, bufListSelections=List.new;


var loadFile, loadFileList, loadBuffers, getFilePaths;


//perlin distrib variables
var knPerlinDurGlob, stPerlinDurGlob, slPerlinDispGlob, stPerlinDispGlob, knPerlinRaduisGlob, stPerlinRaduisGlob;
var knPerlinDurList=List.new, stPerlinDurList=List.new, slPerlinDispList=List.new, stPerlinDispList=List.new, knPerlinRaduisList=List.new, stPerlinRaduisList=List.new;
var perlinDistr, factorDistrib, sendParam, sndTask= Array.fill(tracks, nil);
var defCoord= List.new;
//universal procedures


var slideEnv;


//experimental


var btRateFactor= List.new, btSendParm= List.new, perlinMain= RedPerlin.new, mouseDownInd;
// LOOPER PANEL variables
var loopLeft= leftPos + 365, loopWidth= 100;
var loopColorBg= Color.new255(205, 200, 177), loopColorCurr= Color.new255(240, 240, 240), loopColorTransp= Color.gray(alpha:0.01);
var btLoopAreaList= List.new, btLoopAreaLabels, cvLoopArea= List.new, knLoopPan= List.new, ssLoopVolInd= List.new, ssLoopVol= List.new, btLoopPlayPause= List.new, btLoopStop= List.new, btLoopRec= List.new, pmLoopChList= List.new, nbLoopTrigRamp= List.new, ssLoopPlaybackInd= List.new, cvLoopWaveArea= List.new, sfLoopWave= List.new, slLoopZoom= List.new, btLoopMode= List.new, btLoopStartPos= List.new, btLoopEndPos= List.new, stTimecode= List.new, btLoopClearSel= List.new, btRecMSswitch= List.new, btLoopDir= List.new, btLoopCF= List.new, ssLoopPitch= List.new, stLoopPitchString= List.new, btLoopGlob= List.new;
var btLoopPlayPauseGlob, btLoopStopGlob;


var loopSynthList= Array.fill(4, nil);
var idNum= 70; // loopers start from 70
var moveTimeCursor, updateLooperList, clearOnStop, startLoopSynth, convertTime, loadFileLoop;
var indTaskList= [nil, nil, nil, nil], currPosList= [nil, nil, nil, nil], procTaskList= [nil, nil, nil, nil];
var pitchSpec= [0, 2, \lin].asSpec, pitchSpecDisp= [0, 2, \lin, 0.01].asSpec; // pitchSpecDisp is for display
var currLooper, globalLoopList;


var pitchSign, btPitchDef;
//MIDI
var ccResp;
//redEffectsRack: consider using Array of racks in the future, for now - absolute values: 0 - channels 0,1; 2 - channels 2,3
var rER0, rERG0, rER2, rERG2;
//Scheduler: at the moment specifically for sampling & looping in the 'Let you tell us something'
var procLYTUS;
//var currPath= "sounds/granpad/" ++ Date.getDate.format("%Y-%d-%e_%H-%m");


synthNameList= ["drone", "shake", "fountain", "stutter", "exciter", "slicer", "gendy", "latoocar", "chopper", "swirl", "waves", "loopstrch", "pitchsaw", "gendsl", "proba"];


// channels lists
channels= 52; // replace by ixi preferences
chlistStereo= Array.fill(trunc(channels / 2), nil);
chlistMono= Array.fill(channels, nil);
channels.do({ |i|
	chlistMono.put(i, i.asSymbol);
	if( i < (channels / 2), { chlistStereo.put(i, (i*2).asSymbol ++ ", " ++ ((i*2)+1).asSymbol ); } );
	i=i+1;
});

tmpBuffer= Buffer.alloc(s, s.sampleRate, 1); // 1 seconds 1 channel Buffer - default

tracks.do({ |i| defCoord.add([nil, nil])});

w= GUI.window.new("GRAN-MultiPad v0.5", Rect(412, 500, 1030, 450), resizable:false);
w.acceptsMouseOver= true;


//w.alpha= 0.9;


w.view.background= Color.new255(205, 201, 165);



//preferences file
"Trying to open presets file...".postln;
try{
	presetsFile= File("preferences/gmpsets4ch.dk", "r");
	psetList= presetsFile.readAllString.interpret;
	"OK!".postln;
}{
	("Sorry, cannot open presets file"++String.scDir++"/preferences/gmpsets4ch.dk" ++"!").postln;
	"Will be replaced on window close, so please take care of the current file (if any)!".postln;
	presetsFile= nil;
};

// GUI definition
GUI.hLayoutView.new(w, Rect(loopLeft+(4*loopWidth)+5, 2, 2, 500))
	.background_(Color.white);
GUI.hLayoutView.new(w, Rect(loopLeft+(4*loopWidth)+6, 2, 1, 500))
	.background_(Color.grey(alpha:0.7));
//ramp time for changing presets and synths
GUI.staticText.new(w,Rect(loopLeft+(4*loopWidth)+10, 36, 40, 30))
	.string_("ramp time (s)")
	.font_(globalFont1);
slRamp = Slider(w, Rect(loopLeft+(4*loopWidth)+24, 60, 17, 66))
	.canFocus_(false)
	.value_(timeSpec.unmap(2))
	.mouseOverAction_({ |sl|
		stStatusBar.string = timeSpec.map(sl.value).asString ++ "s (ramp time)"
	})
	.action_({ |sl|
		stRamp.string = timeSpec.map(sl.value);
		stStatusBar.string = timeSpec.map(sl.value).asString ++ "s (ramp time)"	});
stRamp = SCStaticText.new(w, Rect(loopLeft+(4*loopWidth)+23, 63, 20, 12))
	.font_(globalFont1)
	.align_(\center)
	.stringColor_(Color.white)
	.string_(timeSpec.map(slRamp.value));

// buffer list section



cvBufList= CompositeView(w,Rect(0, 40, 200, 220))
	.background_(loopColorTransp);


//buffer list
bufferList = SCPopUpMenu.new(cvBufList,Rect(5, 5, 130, 15))
	.background_(Color.new255(255, 255, 255))
	.canFocus_(false)
	.font_(globalFont1)
	.items_(if(XQ.poolNames == [], { ["no bufferPool"] }, { XQ.poolNames }))
	.action_({ |item|
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
//save buffer button
btSaveBuf = Button(cvBufList, Rect(138, 4, 57, 17))
	.states_([["save buf",Color.black, Color.clear]])
	.font_(GUI.font.new("Helvetica", 9))
	.action_({ |bt|
		var str, oldnamelist, bufferDict;
		bufferDict = if(Object.readArchive("preferences/bufferPools.ixi").isNil, { // if no dict, create it
			()
		}, {
			Object.readArchive("preferences/bufferPools.ixi")
		});
		str = bufferList.items.at(bufferList.value);
		bufferDict.add((str).asSymbol -> [getFilePaths.value(poolName.asSymbol), XQ.globalBufferDict.at(poolName.asSymbol)[1]]);
		bufferDict.writeArchive("preferences/bufferPools.ixi");
		("====  " ++ poolName ++ " is saved into dictionary").postln;
	});

//buffer pool - files list
lvBuffers = SCListView.new(cvBufList, Rect(5, 25, 190, 175))
	.canFocus_(false)
	.hiliteColor_(btColorEffColor)
	.beginDragAction_({ |view| dragSrc= 0; currDragFile= view.value }) //0 means file, 1 means synth
	.mouseDownAction_({ arg view, x, y, modifiers, buttonNumber, clickCount;
		// load file to current Gran: -double click; -drag & drop
		// load file to current Looper: -Cmd + dbl click; -drag & drop
		var filepath, soundfile, checkBufLoadTask, tmpBuf;
		//[modifiers, buttonNumber, clickCount].postln;
		if(clickCount == 2, {
			if((modifiers == 524320) || (modifiers == 524576), { // Alt + dbl click - add to Looper
				loadFile.value(currGran, view.value)
			}, { // dbl click - add to gran
				loadFileLoop.value(currLooper, view.value);
			})
		});
	});


//add file(s) button
btAddFile = Button(cvBufList, Rect(5, 205, 55, 18))
	.states_([["add file(s)",Color.black, Color.clear]])
	.font_(globalFont1)
	.action_({ |bt|
		GUI.dialog.getPaths({ |paths|
			loadBuffers.value(paths);
		});
	});
//free file button
btFreeFile = Button(cvBufList, Rect(65, 205, 50, 18))
	.states_([["free",Color.black, Color.clear]])
	.font_(GUI.font.new("Helvetica", 9))
	.action_({ |bt|
		var fileindex, filename;
		if(lvBuffers.value != 0, { // we never touch internal buffer
			fileindex = lvBuffers.value;
			filename = lvBuffers.items[lvBuffers.value];
			bufList[fileindex-1].free; // with "internal buffer" in mind
			sndNameList.removeAt(fileindex);
			lvBuffers.items_(sndNameList);
			XQ.buffers(poolName.asSymbol).removeAt(fileindex-1);
			XQ.selections(poolName.asSymbol).removeAt(fileindex-1);
			lvBuffers.value_(fileindex-1);
		});
	});





//synth list


lvGranSynths= ListView(w, Rect(5, topPos+230, 190, 130))


	.items_(synthNameList)
	.canFocus_(false)
	.hiliteColor_(btColorEffColor)
	.beginDragAction_({ dragSrc= 1 }) //0 means file, 1 means synth
	.mouseDownAction_({ arg view, x, y, modifiers, buttonNumber, clickCount;
		if(clickCount == 2, {
			pmSynthNames[currGran]= view.value;
			stSynthNames[currGran].string_(lvGranSynths.items[view.value]);
			synthNamesAction.value(currGran);
		})
	});




// internal buffer settings



cvIntBuf= CompositeView(w,Rect(loopLeft+(4*loopWidth)+10, 210, 55, 230))
	.background_(loopColorTransp);


// rec busses (mono & stereo)
GUI.staticText.new(cvIntBuf,Rect(0, 17, 37, 15))
	.string_("mn")
	.font_(globalFont1);
monoChList = GUI.popUpMenu.new(cvIntBuf,Rect(13, 16, 37, 15))
	.background_(btColorBG)
	.canFocus_(false)
	.font_(globalFont1)
	.items_(chlistMono)
	.action_({ |pm|
		if(synthIn != nil, { synthIn.set(\busnum, pm.value) });

		ampAnalyserSynth.set(\inbus, pm.value);
		4.do({ |i|
			if(btBufRec[i].value == 1, { recSynth.inbus_(pm.value) });
			if(synthList[i] != nil, { synthList[i].set(\inbus, pm.value)  });
		});
});
GUI.staticText.new(cvIntBuf,Rect(0, 34, 37, 15))
	.string_("st")
	.font_(globalFont1);
stereoChList = GUI.popUpMenu.new(cvIntBuf,Rect(13, 33, 37, 15))
	.background_(btColorBG)
	.canFocus_(false)
	.font_(globalFont1)
	.items_(chlistStereo)
	.action_({ |pm|
		if(synthIn != nil, { synthIn.set(\busnum, pm.value) });

		ampAnalyserSynth.set(\inbus, pm.value);
		4.do({ |i|
			if(btBufRec[i].value == 1, { recSynth.inbus_(pm.value) })
		});
});
// input volume
rslRecLevel = Slider(cvIntBuf, Rect(13, 50, 10, 87)) //recording level meter
	.visible_(true)
	.knobColor_(ctlColor11)
	.canFocus_(false);
grVolInput= Slider(cvIntBuf, Rect(24, 50, 10, 87))
	.knobColor_(btKnobColor)
	.canFocus_(false)
	.value_(1)
	.mouseOverAction_({ |sl|
		stStatusBar.string = round(volSpec.map(grVolInput.value), 0.01).asString ++ " input vol ";
	})
	.action_({ |sl|
		stStatusBar.string = round(volSpec.map(grVolInput.value), 0.01).asString ++ " input vol ";


		if(synthIn != nil, { synthIn.set(\volIn, grVolInput.value) });
});


GUI.staticText.new(cvIntBuf,Rect(5, 140, 50, 13))
	.string_("buf len,s")
	.font_(globalFont1);
grBufLen= SCSlider(cvIntBuf, Rect(4, 152, 45, 13))
	.background_(btColorEffColor)
	.knobColor_(stlColorKnob)
	.canFocus_(false)
	.value_(sec3Spec.unmap(1))
	.mouseOverAction_({ |sl|
		stStatusBar.string = sec3Spec.map(sl.value).asString ++ " s, buf len ";
	})
	.action_({ |sl|
		stStatusBar.string = sec3Spec.map(sl.value).asString ++ " s, buf len ";
		stBufLen.string_(sec3Spec.map(sl.value));
		bufDurList[0] = sec3Spec.map(sl.value);
});
stBufLen = GUI.staticText.new(cvIntBuf, Rect(23, 153, 20, 12))
	.font_(globalFont1)
	.stringColor_(Color.white)
	.string_(sec3Spec.map(grBufLen.value));
//record loop button
btInputLoop= Button(cvIntBuf,Rect(4, 168, 45, 15))
	.font_(globalFont1)
	.canFocus_(false)
	.states_([
		["one", btColorOn, btColorOff],
		["loop", btColorOff, btColorOn]
	])
	.value_(0);
//record buffer button
btInputRec = Button(cvIntBuf,Rect(4, 185, 45, 20))
	.canFocus_(false)
	.states_([
		[\record, btColorPlay, btColorStop],
		[\stop, btColorStop, btColorPlay]
	])
	.value_(0)
	.action_({ |bt|
		var r, sp, cycles, cnt=0;
		if(bt.value == 1, {
			bt.inverse_(true);
			tmpBuffer.free;
			tmpBuffer = Buffer.alloc(s, s.sampleRate * sec3Spec.map(grBufLen.value), 1); // 1 channel Buffer
			synthIn = Synth.new(\syninbuff, [\bufnum, tmpBuffer.bufnum, \busnum, monoChList.value, \volIn, grVolInput.value, \loop, btInputLoop.value, \gate, sec3Spec.map(grBufLen.value), \dur, sec3Spec.map(grBufLen.value)]); //recording synth
			rslInputDur.visible_(true); rslInputDur.value = 0;
			cycles = sec3Spec.map(grBufLen.value) / 0.25;
			sp = [0, cycles, \lin, 0.1, 0].asSpec;
			r = Routine({ |time|
				inf.do({
					cycles.do({ |i|
						{
							cnt = i+1; rslInputDur.value = sp.unmap(cnt);
							//bookmark
//							sfViewDraw.refresh;
						}.defer;
						0.25.wait;
					});
					{ if(btInputLoop.value == 0, { SystemClock.clear; btInputRec.valueAction_(0) }) }.defer;
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


//recording dur progress bar
rslInputDur = Slider(cvIntBuf, Rect(4, 207, 45, 5))
	.knobColor_(btColorEffColor)
	.visible_(false)
	.canFocus_(false)
	.value_(0);


//TEST - play buf button
btPlayBuff = GUI.button.new(cvIntBuf,Rect(1, 215, 45, 15))
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
GUI.staticText.new(w,Rect(10, 385, 40, 60))
	.font_(globalFont1)
	.string_("perlin distrib - global");
knPerlinDurGlob = Knob(w, Rect(slL-120, 415, 31, 13)) // param - duration
	.value_(timeSpec.unmap(2))
	.canFocus_(false);
stPerlinDurGlob = GUI.staticText.new(w, Rect(slL-120, 440, 31, 10))
	.font_(globalFont1)
	.align_(\center)
	.string_(timeSpec.map(knPerlinDurGlob.value));
knPerlinDurGlob.action_({ |sl|
	stPerlinDurGlob.string_(timeSpec.map(sl.value));
});
slPerlinDispGlob = GUI.slider.new(w, Rect(slL-120, 415, 30, 13)) // param - dispersion
	.background_(Gradient(Color.white, btColorEffColor, \h, 8))
	.visible_(false)
	.canFocus_(false)
	.value_(dispSpec.unmap(0.01));
stPerlinDispGlob = GUI.staticText.new(w, Rect(slW-17, 440, slW-90, 10))
	.font_(globalFont1)
	.visible_(false)
	.string_(dispSpec.map(slPerlinDispGlob.value));
slPerlinDispGlob.action_({ |sl|
	stPerlinDispGlob.string_(dispSpec.map(sl.value));
});
knPerlinRaduisGlob = Knob(w, Rect(slL-75, 415, 31, 13)) // param - max radius
	.canFocus_(false)
	.value_(radSpec.unmap(0.15));
stPerlinRaduisGlob = GUI.staticText.new(w, Rect(slL-75, 440, 31, 10))
	.font_(globalFont1)
	.align_(\center)
	.string_(radSpec.map(knPerlinRaduisGlob.value));
knPerlinRaduisGlob.action_({ |sl|
	stPerlinRaduisGlob.string_(radSpec.map(sl.value));
});
//perlin labels
SCStaticText.new(w, Rect(slL-137, 415, slW-80, 10))
	.font_(globalFont1)
	.string_("dur");
SCStaticText.new(w, Rect(slW+8, 415, slW-80, 10))
	.font_(globalFont1)
	.visible_(false)
	.string_("disp");
SCStaticText.new(w, Rect(slL-43, 415, slW-80, 10))
	.font_(globalFont1)
	.string_("radius");

//status bar



stStatusBar= SCStaticText(w,Rect(slL, w.bounds.height-17, w.bounds.width-210, 15))
	.string_(" ")


	.font_(globalFont2);



// -- buffer pool recording --
// preparation for recording into buffer:
ampAnalFunc = { // this is called on CmdPeriod
	ampAnalyserSynth = Synth(\xiiVuMeter, [\inbus, monoChList.value, \amp, grVolInput.value], addAction:\addToTail);
};
ampAnalFunc.value;
numChannels = 1;

//bookmark
//sfViewDraw= SCUserView.new(w, Rect(leftPos, 460, granWidth*3, 150))
//	.background_(ctlMainColor2)
//	.clearOnRefresh_(false)
//	.drawFunc_({ |uv|
//		Pen.color = Color.blue(0.7, 0.5);
//		Pen.moveTo((uv.bounds.left+waveStep)@(rslRecLevel.value/2));
//		waveStep= waveStep+ 0.1;
//		rslRecLevel.value.postln;
//		Pen.lineTo((uv.bounds.left+waveStep)@(rslRecLevel.value/2));
//		Pen.perform(\stroke);
//	});

sfViewGran= SCSoundFileView.new(w, Rect(leftPos, topPos+230, granWidth*3, 150))
	.timeCursorOn_(true)
	.timeCursorColor_(Color.white)
	.timeCursorPosition_(0)
	.drawsWaveForm_(true)
	.gridOn_(true)
	.gridResolution_(1)
	.gridColor_(Color.white)
	.waveColors_([ ctlMainColor1, ctlMainColor1 ])
	.background_(Color.white.alpha_(0.02))
	.canFocus_(false);


// gran synth ctrls
tracks.do({ |i|
	var trigID= idPad + (i * 2);

	// button - selecting current gran area


	btGranAreaList.add(
		Button(w,Rect(leftPos+(i*granWidth), topPos, granWidth, 45))



			.canFocus_(false) .font_(globalFont3) .value_(0)
			.states_([
				["      " ++ (i+1).asString, loopColorCurr, loopColorBg],
				["      " ++ (i+1).asString, loopColorBg, loopColorCurr]
			])
			.receiveDragHandler_({
				case
					{ dragSrc == 0 } { // file


						stFilename[i].object= lvBuffers.items.indexOf(currDragFile);
						loadFile.value(i, currDragFile);



					}
					{ dragSrc == 1 } { // synth


						pmSynthNames[i]= lvGranSynths.value;
						stSynthNames[i].string_(lvGranSynths.items.at(pmSynthNames[i]) );
						synthNamesAction.value(i);



					};
			})
			.action_({ |bt|
				var soundfile;
				4.do({ |j|
					if( (btGranAreaList[j].value == 1) && (j != i), { btGranAreaList[j].value = 0 });
					cvGranArea[j].background_(loopColorTransp);
					cvGranWaveArea[j].visible = false;
				});
				bt.value= 1; // keep current state, at least one looper should be active
				cvGranArea[i].background_(loopColorCurr);
				cvGranWaveArea[i].visible = true;
				currGran= i;



				if(bufTrack[i].value != 0, {
					soundfile = SoundFile.new;
					soundfile.openRead(XQ.globalBufferDict.at(poolName)[0][bufTrack[i]-1].path);
					sfViewGran.drawsWaveForm_(true);
					sfViewGran.soundfile_(soundfile);
					sfViewGran.read(0, soundfile.numFrames, block:16);
					sfViewGran.selectionDuration(0);
					sfViewGran.refresh;
					soundfile.close;
				}, {
					sfViewGran.drawsWaveForm_(false); //clearing soundfile view
				});




			})
	);



	//select of the synth in a slot
	pmSynthNames.add(i); // just a number of a synth
	stSynthNames.add(
		SCStaticText.new(w,Rect(leftPos+(i*granWidth)+5, topPos+12, granWidth, 45))
			.font_(globalFont4)
			.string_(lvGranSynths.items.at(pmSynthNames[i]))
	);
	//label for selecting synth
	stSynthSelect.add(
		SCStaticText.new(w,Rect(leftPos+(i*granWidth)+5, topPos-7, granWidth, 45))
			.font_(globalFont4)
			.stringColor_(Color.red)
			.visible_(false)
			.string_(lvGranSynths.items.at(pmSynthNames[i]))
	);







	// gran area



	cvGranArea.add(
		CompositeView(w,Rect(leftPos+(i*granWidth), topPos+45, granWidth, 180))
			.background_(loopColorTransp)
	);
	// gran 2D slid & waveform area
	cvGranWaveArea.add(
		CompositeView(w,Rect(leftPos, topPos+230, granWidth*4, 150))
			.background_(loopColorTransp)
	);



	//volume indicator - left channel
	ssGranVolInd.add(
		Slider(cvGranArea[i], Rect(50, 5, 10, 100))
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume indicator - right channel
	ssGranVolInd.add(
		Slider(cvGranArea[i], Rect(61, 5, 10, 100))
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume slider
	grVolList.add(
		Slider(cvGranArea[i], Rect(72, 5, 10, 100))
			.background_(Color.gray(alpha:0.01))
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.mouseOverAction_({ |sl|
				stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " gran " ++ (i+1).asSymbol ++ " volume ";
			})
			.action_({ |sl| // the volume slider controls start (>0) / end (0) the synth:
				stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " gran " ++ (i+1).asSymbol ++ " volume ";

				trigID= idPad + (i * 2);
				volAction.value(i, trigID);

				if(globSlidList[i] == 1, {
					tracks.do({ |j|
						if( (globSlidList[j] == 1) && (i != j), {
							grVolList[j].value_(sl.value);
							trigID= idPad + (j * 2);
							volAction.value(j, trigID);
						});
					});
				});
			});
	);
	// vol ind border
	grVol0.add(
		SCUserView(cvGranArea[i], Rect(72, 33, 10, 2))
			.canFocus_(false)
			.background_(Color.black)
	);
	// slider global button
	grGlobBtList.add(
		Button(cvGranArea[i], Rect(5, 5, 13, 13))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.canFocus_(false)
			.action_({ |butt|
				globSlidList[i] = butt.value;
			});
	);
	//SinOsc modulation switch
	grModSwitchList.add(
		Button.new(cvGranArea[i], Rect(20, 5, 10, 10))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor21]
			])
			.value_(0)
			.canFocus_(false)
			.action_({ |butt|
				if(butt.value == 0, { //switch off SinOsc.rk modulation
					if(synthList[i] != nil, { synthList[i].set(\modf, 1 ) });
				});
			});
	);

	//recorder section
	//filename
	tvRecNameList.add(
		SCTextView.new(cvGranArea[i], Rect(5, 160, granWidth-10, 20))
			.hasVerticalScroller_(false)
			.autohidesScrollers_(true)
			.font_(globalFont1)
			.string_("")
			.visible_(false);
	);
	//buffer to file button
	btBufFile.add(
		Button(cvGranArea[i], Rect(5, 51, 30, 16))
			.font_(globalFont1)
			.states_([ [\document, btColorOn, btColorStop] ])
			.action_({ |butt|
				var file, f, buffer;

				filename = tvRecNameList[i].string;
				if(filename == "", {
					filename = "Track" ++ (i+1).asSymbol ++ "_" ++ Date.getDate.stamp.asString;
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
			})
	);

	//send params
	btSendParm.add(
		Button(cvGranArea[i],Rect(5, 33, 30, 16))
			.font_(globalFont1)
			.states_([
				[\clock, btColorOn, ctlColor10],
				[\clock, Color.white, btColorOn]
			])
			.action_({ |bt|
				sendParam.value(i, bt.value)
			})
	);

	//buffer pool record button
	btBufRec.add(
		Button(cvGranArea[i],Rect(5, 71, 30, 18))
			.canFocus_(false)
			.states_([
				[\record, btColorPlay, btColorStop],
				[\stop, btColorStop, btColorPlay]
			])
			.value_(0)
			.action_({ |butt|
				var file, f, filesize, buffer;
				if(s.serverRunning == true, { // if the server is running
					if(butt.value == 1, {
						butt.inverse_(true);
						tracks.do({|j| //switch off all other recording
							btLoopRec[j].enabled_(false);
							if(j != i, {
								btBufRec[j].enabled_(false);
							})
						});
						currRec = i; // for the purpose of update time text only for the current recording

						filename = tvRecNameList[i].string;
						if(filename == "", {
							filename = "Track" ++ (i+1).asSymbol ++ "_" ++ Date.getDate.stamp.asString;
							tvRecNameList[i].string_(filename);
						});

						recSynth = XiiRecord(s, monoChList.value, 1, sampleFormat: XQ.pref.bitDepth);
						recSynth.start("sounds/ixiquarks/"++filename++".aif");
						recSynth.setAmp_(grVolInput.value);
						secTask.start;
					}, {
						butt.inverse_(false);
						4.do({|j| //switch on other record-buttons
							btLoopRec[j].enabled_(true);
							btBufRec[j].enabled_(true);
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
			})
	);
	//rec time counter
	stTimeText.add(
		GUI.staticText.new(cvGranArea[i], Rect(5, 90, 40, 15))
			.font_(globalFont5)
			.string_("00:00");
	);

	// try to use just one list for both Grans & Loopers!
	stFilename.add(
		DragBoth(cvGranArea[i], Rect(2, 108, granWidth-4, 50))
			.background_(ctlMainColor1.alpha_(0.3))
			.align_(\left)
			.object_("")
			.beginDragAction_({ |obj| dragSrc= 0; currDragFile= lvBuffers.items.indexOf(obj.object.asString) }) //0 is file, 1 is synth
			.receiveDragHandler_({ |obj|
				if(dragSrc == 0, {
					obj.object= lvBuffers.items.indexOf(currDragFile);
					loadFile.value(i, currDragFile);
				})
			})
	);

	// output channel dropdown list
	grChList.add(
		SCPopUpMenu.new(cvGranArea[i], Rect(5, 157, 62, 20))
			.items_(chlistMono)
			.background_(btColorBG)
			.canFocus_(false)
			.font_(globalFont2)
			.action_({
				if(synthList[i] != nil, { synthList[i].set(\busnum, grChList[i].value) });
			})
	);

	//waveshape & 2D slider area
	// 2D slider
	grslidList.add(
		GUI.slider2D.new(cvGranWaveArea[i], Rect(0, 0, granWidth*3, cvGranWaveArea[i].bounds.height))


			.background_(ctlMainColorTransp)


			.knobColor_(slidColorProgress)
			.x_(0.0)
			.y_(0.0)
			.canFocus_(false)
			.mouseOverAction_({ |sl|
				stStatusBar.string = "x " ++ round(sl.x * 100, 0.1).asString ++ ";   y " ++ round(sl.y * 100, 0.1).asString ++ "   gran" ++ (i+1).asString;
			})
			.action_({ |sl|
				stStatusBar.string = "x " ++ round(sl.x * 100, 0.1).asString ++ ";   y " ++ round(sl.y * 100, 0.1).asString ++ "   gran" ++ (i+1).asString;
				grSTxList[i].string_(round(sl.x * 100, 0.1));
				grSTyList[i].string_(round(sl.y * 100, 0.1));

				if(synthList[i] != nil, {
					synthList[i].set(\ax, sl.x, \ay, sl.y);
					if(grModSwitchList[i].value == 1, { // to modulate or not to modulate?
						synthList[i].set(\modf, 4400*(sl.y.linlin(0, 1, -0.1, 0.1))); //SinOsc.kr modulation
					});



				});



				if(globSlidList[i] == 1, {
					tracks.do({ |j|
						if((globSlidList[j] == 1) && (j != i), {
							grslidList[j].x_(sl.x);
							grslidList[j].y_(sl.y);
							grSTxList[j].string_(round(grslidList[j].x * 100, 0.1));
							grSTyList[j].string_(round(grslidList[j].y * 100, 0.1));

							if(synthList[j] != nil, {
								synthList[j].set(\ax, sl.x, \ay, sl.y);

								if(grModSwitchList[j].value == 1, { // to modulate or not to modulate?
									synthList[j].set(\modf, 4400*([-0.8, 0.8].asSpec.map(sl.y)).abs); //SinOsc.kr modulation
								});
							});
						});
					});
				});
			})
	);

	// coordinates - X
	grSTxList.add(
		GUI.staticText.new(cvGranWaveArea[i], Rect( grslidList[i].bounds.width/2-10, grslidList[i].bounds.height-14, 30, 15 ))
			.font_(globalFont1)
			.string_(0.0);
	);
	// coordinates - Y
	grSTyList.add(
		GUI.staticText.new(cvGranWaveArea[i], Rect( 5, grslidList[i].bounds.height / 2, 30, 15 ))
			.font_(globalFont1)
			.string_(0.0);
	);
	//wide panorama ranger
	rsWideRangeList.add(
		SCRangeSlider(cvGranWaveArea[i], Rect(276, 0, 82, 13))
			.canFocus_(false)
			.lo_(\pan.asSpec.unmap(-0.8))
			.hi_(\pan.asSpec.unmap(0.8))
			.knobColor_(Color.white)
			.background_(slidColorProgress.alpha_(0.7))
			.mouseOverAction_({ |sl|
				stStatusBar.string = round(sl.range, 0.01).asString ++ " gran " ++ (i+1) ++ " field width ";
			})
			.action_({ |sl|
				stStatusBar.string = round(sl.range, 0.01).asString ++ " gran " ++ (i+1) ++ " field width ";
				if(synthList[i] != nil, {
					synthList[i].set(\panidx, sl.hi-sl.lo, \panshift, \pan.asSpec.map([sl.lo, sl.hi].mean));
				});
			});
	);
	//miscelaneous sliders for panorama range: deviation, average
	slMiscDev.add( SCSlider(cvGranWaveArea[i], Rect(276, 15, 82, 5)) .visible_(false) );
	slMiscAve.add( SCSlider(cvGranWaveArea[i], Rect(276, 20, 82, 5)) .visible_(false) );
	SCStaticText(cvGranWaveArea[i], Rect(280, 13, 80, 13))
		.font_(globalFont2)
		.string_("L                   R");



	// ... filters & effects

	//Perlin distrib
	knPerlinDurList.add(
		Knob(cvGranWaveArea[i], Rect(320, 95, 30, 13)) // param - duration
			.value_(timeSpec.unmap(4.0.rand))
			.canFocus_(false)
	);
	stPerlinDurList.add(
		SCStaticText.new(cvGranWaveArea[i], Rect(320, 120, 31, 10))			.font_(globalFont1)
			.align_(\center)
			.string_(timeSpec.map(knPerlinDurList[i].value));
	);
	knPerlinDurList[i].action_({ |sl|
		stPerlinDurList[i].string_(timeSpec.map(sl.value));
	});
	slPerlinDispList.add( // invisible!
		SCSlider(w, Rect(slL+(i*hrIndex)+2, slT+(slH*2)+85, slW-27, 8)) // param - dispersion
			.background_(Gradient(Color.white, btColorEffColor, \h, 8))
			.visible_(false)
			.canFocus_(false)
			.value_(dispSpec.unmap(0.01));
	);
	stPerlinDispList.add( // invisible!
		SCStaticText(w, Rect(slL+94+(i*hrIndex), slT+(slH*2)+78, slW-90, 10))
			.font_(globalFont1)
			.visible_(false)
			.string_(dispSpec.map(slPerlinDispList[i].value));
	);
	slPerlinDispList[i].action_({ |sl|
		stPerlinDispList[i].string_(dispSpec.map(sl.value));
	});
	knPerlinRaduisList.add(
		Knob(cvGranWaveArea[i], Rect(280, 95, 31, 13)) // param - max radius
			.canFocus_(false)
			.value_(radSpec.unmap(0.5.rand));
	);
	stPerlinRaduisList.add(
		SCStaticText(cvGranWaveArea[i], Rect(280, 120, 31, 10))
			.font_(globalFont1)
			.align_(\center)
			.string_(radSpec.map(knPerlinRaduisList[i].value));
	);
	knPerlinRaduisList[i].action_({ |sl|
		stPerlinRaduisList[i].string_(radSpec.map(sl.value));
	});

	//experimental section - rate factor
	btRateFactor.add(
		Button(cvGranWaveArea[i],Rect(275, 135, 50, 15))
			.font_(globalFont1)
			.states_([
				["perlin mod", Color.white, btColorOn],
				["perlin mod", btColorOn, ctlColor10]
			])
			.value_(1)
			.mouseDownAction_({ |bt|
				var j= 1, pval;
				perlinMain.spook= knPerlinDurList[i].value.linlin(0,1, 5,15);
				mouseDownInd= Task({
					{
						pval= abs(perlinMain.noise1D(sin(j/100) + cos(j/100), 0.75, 9, 1));
						{ synthList[i].set(\factor, pval) }.defer;
						j= j+1;
						pval.linexp(0, 1.5, 0.3, 0.01).wait;
					}.loop
				}).start;
			})
			.action_({ |bt|
				mouseDownInd.stop;
				synthList[i].set(\factor, 0);
			})
	);
}); // end of synths loop


btGranAreaList[0].valueAction_(1); // make the 1st granulator active


sendParam= { arg curr, switchOn;
	var timeprop, pos, base, x, y;
	var p1, p2, pRate, pPos, pDur, pAmp;
	var valWait, valRate, valPos, valDur, valAmp; // TEMP

	p1= exprand(0.1, 0.2);
	p2= Prand([Pgeom(0.1, 1+p1, 20), Pgeom(1, 1-p1, 35)], inf).asStream;
	pRate= Pxrand( [1, 1, p2.next, 0.5, 0.5, 0.2, 0.3, p2.next, 1+p2.next, 1-p2.next], inf).asStream;
	pPos= Pseq(p2.dup(10), inf).asStream;
	pDur= Pshuf([1, p1, 1, p2.next, 0.5, 0.5, 0.1, p2.next, 2, 1+p2.next], inf).asStream;
	pAmp= Pshuf([1, 0.6, p2.next.min(0.7), 0.3, 0.1+p2.next, 1, 1, 0.3, 0.1, 1-p2.next], inf).asStream;

	switch( switchOn,


		0, { // switching it off
			sndTask[curr].stop; sndTask[curr]= nil;
			if(synthList[curr] != nil, { synthList[curr].set(\frate, 1, \fpos, 1, \fdur, 1, \vol, grVolList[curr].value) } );
		},
		1, { // switching on
			if(sndTask[curr].isNil, {
				sndTask[curr]= Task({


					{
						{
							x= max(grslidList[curr].x, 0.01); y= max(grslidList[curr].y, 0.01);
							pos= x;
							valRate= pRate.next;
							valPos=  pPos.next;
							valDur=  pDur.next;
							valAmp=  pAmp.next;
							round([valWait, valRate, valPos, valDur, valAmp], 0.01).postln;
							if(synthList[curr] != nil, {
								synthList[curr].set( \frate, valRate*pos+1, \fpos, valPos/pos, \fdur, valDur*y.linlin(0,1,0.1,3), \vol, valAmp );
							});
						}.defer;
						valWait= p2.next;
						rrand(valWait.max(0.01), valWait/10).wait;
					}.loop
				}).start;
			});



		}


	);
};







// the volume slider controls start (>0) / end (0) the synth:
volAction= { arg curr, trigID;
	var currBufnum, currBufDur, currSynth;

	if(grVolList[curr].value != 0, {
		// vol is not 0
		if(synthList[curr] != nil, {
			synthList[curr].set(\vol, grVolList[curr].value);
		}, {
			currBufnum = bufnumList.at(bufTrack[curr]);
			currBufDur = bufDurList.at(bufTrack[curr]);

			currSynth = \gmp ++ pmSynthNames[curr].value ++ synthNameList.at(pmSynthNames[curr].value);
			synthList[curr] = Synth.new(currSynth, [
				\busnum, grChList[curr].value,
				\bufnum, currBufnum,
				\bufdur, currBufDur,
				\ax, grslidList[curr].x, \ay, grslidList[curr].y,
				\panidx, rsWideRangeList[curr].hi-rsWideRangeList[curr].lo,
				\panshift, \pan.asSpec.map([rsWideRangeList[curr].lo, rsWideRangeList[curr].hi].mean),
				\vol, grVolList[curr].value,
				\trigID, trigID,
				\inbus, monoChList.value,
				\gate, 1
			]);
			loadFile.value(curr, bufTrack[curr], update:false); // filling out currBufnum is not enough - buffer can be stereo. loadFile cuts the right channel
		});
	},
	{ // vol is 0
		if(synthList[curr] != nil, {
			synthList[curr].set(\gate, 0);
			synthList[curr] = nil;
			if( bufTrack[curr].value > 0 , {
				s.cachedBufferAt( bufnumList.at(bufTrack[curr].value) ).clear;
			});
			// volume indicators to 0
			slideEnv.value(ssGranVolInd[curr*2], ssLoopVolInd[curr*2].value, volSpec.unmap(0.ampdb), 1, 0.1, 2);
			slideEnv.value(ssGranVolInd[curr*2+1], ssLoopVolInd[curr*2+1].value, volSpec.unmap(0.ampdb), 1, 0.1, 2);
		});
	});
};

//pmSynthNames[i].action_
synthNamesAction= ({ |curr|
	var trigID, newSynthName, newSynth, currBufnum, currBufDur, xfadeTask, xfadeTime, currVol;
	newSynthName = \gmp ++ pmSynthNames[curr] ++ synthNameList.at(pmSynthNames[curr]);
	if(grVolList[curr].value > 0.0, {
		if( synthList[curr].defName != newSynthName, {
			trigID= idPad + (curr * 2);

			currBufnum = bufnumList.at(bufTrack[curr].value);
			currBufDur = bufDurList.at(bufTrack[curr].value);

			//creating new synth with initial volume 0
			newSynth = Synth.new(newSynthName, [
				\busnum, grChList[curr].value,
				\bufnum, currBufnum,
				\bufdur, currBufDur,
				\ax, grslidList[curr].x, \ay, grslidList[curr].y,
				\panidx, rsWideRangeList[curr].hi-rsWideRangeList[curr].lo,
				\panshift, \pan.asSpec.map([rsWideRangeList[curr].lo, rsWideRangeList[curr].hi].mean),
				\vol, 0.01,
				\trigID, trigID,
				\gate, 1
			]);
			loadFile.value(curr, bufTrack[curr], newSynth, false); // filling out currBufnum is not enough - buffer can be stereo. loadFile cuts the right channel

			//now cross-fading volumes of the current synth and new one
			xfadeTime = timeSpec.map(slRamp.value);
			currVol = grVolList[curr].value;
			xfadeTask = Task.new({ |time|
				var volInc, volDec;
				trunc(xfadeTime/0.01).do({ |j|
					volInc = currVol * (j/(trunc(xfadeTime/0.01)-1)).sqrt;
					volDec = currVol * (1-(j/(trunc(xfadeTime/0.01)-1)**3));
					newSynth.set(\vol, volInc);
					synthList[curr].set(\vol, volDec);
					0.01.wait;
				});
				xfadeTask.stop;
				synthList[curr].set(\gate, 0);
				synthList[curr] = newSynth;
				newSynth = nil;
			}).start;
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
			if( elt != nil, { elt.valueAction_(env.next) });
			density.wait;
		});
		xTask.stop;
		elt.valueAction_(end); // the last move for exp envelope
	}).play(AppClock);


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
			rslRecLevel.value_( (1-(msg[3].ampdb.abs * 0.01)) * grVolInput.value );
		});

		if((msg[2]-idPad >= 0) && (msg[2] <= (idPad+(8))), { // 8 means 4 tracks 2 indicators each (L & R)
			ssGranVolInd.at(msg[2]-idPad).value_(1-(msg[3].ampdb.abs * 0.01))
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
	ctrlPad = grslidList[currPad];


	xStart = ctrlPad.x; yStart = ctrlPad.y;
	chanceX = if(0.7.coin == true, {1}, {-1}); chanceY = if(0.5.coin == true, {1}, {-1});
	rp = RedPerlin.new;



	perlinTask = Task.new({ |time|
		trunc(dur/disp).do({ |j|
			{
				//xStart + (rp.noise1D(chanceX*sin(j/100), 0.75, 6, 1) * radius).postln;
				ctrlPad.activex_(xStart + (rp.noise1D(chanceX*sin(j/100), 0.75, 6, 1) * radius));
				ctrlPad.activey_(yStart + (rp.noise1D(chanceY*cos(j/100), 0.75, 6, 1) * radius));
				if(grModSwitchList[currPad].value == 1, { //SinOsc.rk modulation
					synthList[currPad].set(\modf, (yStart-ctrlPad.y).abs);
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

factorDistrib= { arg cur, switchOn, radius= 0.15;
	var rp, ctrlPad, chanceX, chanceY, xStart, yStart, backTask, tmpVar, j= 1;
	ctrlPad = grslidList[cur];


	chanceX = if(0.5.coin == true, {1}, {-1}); chanceY = if(0.7.coin == true, {1}, {-1});
	xStart= defCoord[cur][0]; yStart= defCoord[cur][1];
	rp = RedPerlin.new;
	switch( switchOn,
		false, { // switching it off
			procTaskList[cur].stop; procTaskList[cur]= nil;
			defCoord[cur][0]= nil; defCoord[cur][1]= nil;


			backTask= Task.new({ |time|
				10.do({ |j|


					{
						if(btRateFactor[cur].value == 1, {
							synthList[cur].set(\factor, 0);
						}, {
							tmpVar= radius * j.linlin(0, 9, 1, 0);
							ctrlPad.activex_(xStart + (chanceX * radius * j.linlin(0, 9, 1, 0)));
							ctrlPad.activey_(yStart + (chanceY * radius * j.linlin(0, 9, 1, 0)));
							if(grModSwitchList[cur].value == 1, { synthList[cur].set(\modf, 1) });
						});



					}.defer;
					0.1.wait;
				});
			}).start;


		},
		true, { // switching on
			if(procTaskList[cur].isNil, {
				if(btRateFactor[cur].value == 1, { // modulating factor


					perlinMain.spook= knPerlinDurList[cur].value.linlin(0,1, 5,15);
					procTaskList[cur]= Task({
						{
							tmpVar= abs(perlinMain.noise1D(sin(j/100) + cos(j/100), 0.75, 9, 1));
							{ if(synthList[cur] != nil, { synthList[cur].set(\factor, tmpVar) } )}.defer;
							j= j+1;
							tmpVar.linexp(0, 1.5, 0.5, 0.05).wait;
						}.loop
					}).start;


				}, { // moving 2D
					procTaskList[cur]= Task.new({ |time|
						inf.do({ |j|
							{
								ctrlPad.activex_(xStart + (perlinMain.noise1D(chanceX*sin(j/100), 0.75, 6, 1) * radius));



								ctrlPad.activey_(yStart + (perlinMain.noise1D(chanceY*cos(j/100), 0.75, 6, 1) * radius));
								if(grModSwitchList[cur].value == 1, { //SinOsc.rk modulation
									synthList[cur].set(\modf, (yStart-ctrlPad.y).abs);
								});
							}.defer;
							0.01.wait;
						});
					}).start;


				});



			});


		}
	);


};




//keyboard control


w.view.keyUpAction = { arg view, char, modifiers, unicode, keycode;
	var tmpVar;
	case
		{(keycode >= 6) && (keycode < 10)} { // Z X C V - Perlin x/y randomizator
			tmpVar= keycode-6;



			factorDistrib.value(tmpVar, false);


		}
};





w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	var tmpVar,
		keyArr = #[29, 18, 19, 20, 21, 23, 22, 26, 28, 25],  // char codes of numbers 0-9
		fKeyArr = #[18, 19, 20, 21, 23, 71, 89, 91], // Fn + "char" codes
		tyuiKeyArr= #[17, 16, 32, 34], // T Y U I
		tyuiKeyFnArr= #[17, 16, 86, 87, 8388608, 8388864, 10486016, 10485760], // T Y U I & Fn (all possible modifiers)
		ghjkKeyArr= #[5, 4, 38, 40], // G H J K
		bnmComKeyArr= #[11, 45, 46, 43], // B N M ","
		five2eightKeyArr= #[23, 22, 26, 28], // 5-8
		five2eightKeyFnArr= #[23, 71, 89, 91, 8388608, 8388864, 10486016, 10485760]; // 5-8 & Fn (all possible modifiers)
	[char, modifiers, unicode, keycode].postln;



// LOOPER PANEL keys
	if (five2eightKeyArr.includes(keycode) == true, { // 5-8
		tmpVar = keyArr.find([keycode]) - 5; // index
		case
		{ (modifiers == 0) || (modifiers == 256) } {
			// if selected looper is not current, select indicated looper
			// otherwise start/pause
			if(btLoopAreaList[tmpVar].value != 1, {
				btLoopAreaList[tmpVar].valueAction_(1)
			}, {
				btLoopPlayPause[tmpVar].valueAction_(1-btLoopPlayPause[tmpVar].value)
			})
		}
		{ (modifiers == 262401) || (modifiers == 262145) || (modifiers == 131076) || (modifiers == 131332) } { // Ctrl (or right Shift) + 5-8 - stop
			btLoopStop[tmpVar].valueAction_(1)
		}
		{(modifiers == 524320) || (modifiers == 524576)} { // Alt + 5-8 - check/uncheck global switch
			btLoopGlob[tmpVar].valueAction_(1-btLoopGlob[tmpVar].value);
		}

	});

	if(five2eightKeyFnArr.includes(keycode) == true, { // Fn + 5-8
		tmpVar = five2eightKeyFnArr.find([keycode]); // index
		if( five2eightKeyFnArr.includes(modifiers), { // Fn+<num> - update fileLists, check last element
			updateLooperList.value(tmpVar);
		});
	});
	if(tyuiKeyFnArr.includes(keycode) == true, { // Fn + T Y U I
		tmpVar = tyuiKeyFnArr.find([keycode]); // index
		if( tyuiKeyFnArr.includes(modifiers), { // Fn+<num> - load interbnal buffer to a track
			loadFileLoop.value(tmpVar, 0);
		});
	});
	if (tyuiKeyArr.includes(keycode) == true, { // T Y U I - individual record
		tmpVar = tyuiKeyArr.find([keycode]); // index
		if ( (modifiers == 0) || (modifiers == 256),
			{btLoopRec[tmpVar].valueAction_(1-btLoopRec[tmpVar].value)}
		)
	});
	if (ghjkKeyArr.includes(keycode) == true, { // G H J K - straight / reverse switch
		tmpVar = ghjkKeyArr.find([keycode]); // index
		if ( (modifiers == 0) || (modifiers == 256),
			{btLoopDir[tmpVar].valueAction_(1-btLoopDir[tmpVar].value)}
		)
	});
	if (bnmComKeyArr.includes(keycode) == true, { // B N M "," - loop / one switch
		tmpVar = bnmComKeyArr.find([keycode]); // index
		if ( (modifiers == 0) || (modifiers == 256),
			{btLoopMode[tmpVar].valueAction_(1-btLoopMode[tmpVar].value)}
		)
	});
	case
		{keycode == 25} { btLoopStartPos[currLooper].valueAction_(1) }  // 9 | start pos | of curr looper
		{keycode == 29} { btLoopEndPos[currLooper].valueAction_(1) }    // 0 |  end pos  |
		{keycode == 27} { btLoopClearSel[currLooper].valueAction_(1) }  //"-"| clear sel |
		{keycode == 30} { //"/" - pitch to default (old settings 44)
			slideEnv.value(ssLoopPitch[currLooper], ssLoopPitch[currLooper].value, pitchSpec.unmap(1), 0.2, 0.01, 3);
		};

// LOOPER PANEL end
	// sequences or single keys
	case
		{keycode == 51} {if(psetCurr <= psetNum, { psetList.put(psetCurr, nil); })} // <-|, delete preset
		{keycode == 10} { // - add/update preset, originally plus ("=" actually)
			if(psetCurr <= psetNum, {
				saveSettings.value(psetCurr);
			})
		}
		{keycode == 35} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + p - select all modulation switches
			4.do({ |i|
				grModSwitchList[i].valueAction_(1 - grModSwitchList[i].value);



			});
		})}


		{keycode == 16} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + y - select/deselect all global switches
			tracks.do({ |i|
				grGlobBtList[i].valueAction_(1-grGlobBtList[i].value);



				globSlidList[i] = grGlobBtList[i].value;

				btLoopGlob[i].valueAction_(1-btLoopGlob[i].value);
				globalLoopList[i] = btLoopGlob[i].value;


			});



		})}


		{keycode == 17} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + t - deselect all 2Dsliders global switches
			tracks.do({ |i|
				grGlobBtList[i].valueAction_(1);
				globSlidList[i] = grGlobBtList[i].value;




				btLoopGlob[i].valueAction_(1);
				globalLoopList[i] = btLoopGlob[i].value;
			})
		})}
		{keycode == 37} { // L - switch loop/one mode for curent looper
			btLoopMode[currLooper].valueAction_(1-btLoopMode[currLooper].value)
		}


		{keycode == 42} { // "\" (record / stop) & Right Shift + \ (loop record)
			if((modifiers == 131076) || (modifiers == 131332), { btInputLoop.valueAction_(1 - btInputLoop.value) });
			btInputRec.valueAction_(1 - btInputRec.value);
		}
		{(keycode >= 18) && (keycode < 22)} { // 1-4
			tmpVar = keyArr.find([keycode]) - 1; // index
			case
				{(modifiers == 0) || (modifiers == 256)} { // toggle vol (fade-in: exp fast,fade-out: exp slow)
					// if selected granulator is not current, select indicated granulator
					// otherwise start/pause
					if(btGranAreaList[tmpVar].value != 1, {
						btGranAreaList[tmpVar].valueAction_(1)
					}, {
						if( grVolList[tmpVar].value > 0, {
							slideEnv.value(grVolList[tmpVar], grVolList[tmpVar].value, 0, 0.2, 0.01, 3);
						}, {
							slideEnv.value(grVolList[tmpVar], 0, volSpec.unmap(0), 0.2, 0.01, 3);
						});
					})
				}
				{(modifiers == 524320) || (modifiers == 524576)} { // Alt + <num> - check/uncheck global switch
					grGlobBtList[tmpVar].valueAction_(1-grGlobBtList[tmpVar].value);
				}
				{(modifiers == 131330) || (modifiers == 131074)} { // Left Shift + <num> - check/uncheck SinOsc modulation
					grModSwitchList[tmpVar].valueAction_(1-grModSwitchList[tmpVar].value);
				}
				{(modifiers == 8388608) || (modifiers == 8388864)} { // Fn + <num> - update fileLists, check last element
					updateFileList.value(fKeyArr.find([keycode]));
				}
				{(modifiers == 262145) || (modifiers == 262401) || (modifiers == 131076)  || (modifiers == 131332)} { // Ctrl (or right Shift) + <num> - launch pattern deconstruction
					btSendParm[tmpVar].valueAction_(1-btSendParm[tmpVar].value);
				}
		}
		{(keycode >= 12) && (keycode < 16)} { //Q W E R
			case
				{ (modifiers == 0) || (modifiers == 256) } { //Q W E R - individual record
					btBufRec[keycode-12].valueAction_(1-btBufRec[keycode-12].value)
				}
				{(modifiers == 8388608) || (modifiers == 8388864)} { //Fn + Q W E R - load internal buffer to a track
					loadFile.value(keycode-12, 0);
				}
		}
		{(keycode >= 0) && (keycode < 4)} { // A S D F - save buffer into file
			if(btBufFile[keycode].enabled == true, { btBufFile[keycode].valueAction_(1) })
		}
		{(keycode >= 6) && (keycode < 10)} { // Z X C V - Perlin x/y randomizator


//			perlinDistr.value(keycode-6, timeSpec.map(knPerlinDurList[keycode-6].value), dispSpec.map(slPerlinDispList[keycode-6].value), radSpec.map(knPerlinRaduisList[keycode-6].value));


			tmpVar= keycode-6;
			if((defCoord[tmpVar][0] == nil) && (defCoord[tmpVar][1] == nil), {
				defCoord[tmpVar][0]= grslidList[tmpVar].x;
				defCoord[tmpVar][1]= grslidList[tmpVar].y;
			});
			factorDistrib.value(tmpVar, true);


		}
		{keycode == 50} { // ` - global x/y randomizator
			tracks.do({ |i|
				if(globSlidList[i] == 1, {
					perlinDistr.value(i, timeSpec.map(knPerlinDurGlob.value), dispSpec.map(slPerlinDispGlob.value), radSpec.map(knPerlinRaduisGlob.value));
				});
			});



		}
		//bookmark


		{keycode == 123} { // previous synth on current track
			stSynthSelect[currGran].visible_(true);
			tmpVar = if(lvGranSynths.items.indexOf(stSynthSelect[currGran].string) == 0, { // here - current synth number
					lvGranSynths.items.size-1
				}, {
					lvGranSynths.items.indexOf(stSynthSelect[currGran].string)-1
				});
			stSynthSelect[currGran].string_(lvGranSynths.items[tmpVar]);



		}


		{keycode == 124} { // next synth on current track
			stSynthSelect[currGran].visible_(true);
			tmpVar = if(lvGranSynths.items.indexOf(stSynthSelect[currGran].string) == (lvGranSynths.items.size-1), { // here - current synth number
					0
				}, {
					lvGranSynths.items.indexOf(stSynthSelect[currGran].string)+1
				});
			stSynthSelect[currGran].string_(lvGranSynths.items[tmpVar]);



		}


		{keycode == 125} { // make selected synth active on current track
			stSynthSelect[currGran].visible_(false);
			// CHANGE SYNTH HERE - REWRITE synthNamesAction TO HAVE PARAMS oldSynth & newSynth
			pmSynthNames[currGran]= lvGranSynths.items.indexOf(stSynthSelect[currGran].string).postln;
			synthNamesAction.value(currGran);
			stSynthNames[currGran].string= stSynthSelect[currGran].string;



		}

		{keycode == 39} { // TEMP-scheduling for 'let you tell us sthn'
			procLYTUS.value(0);
		};




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




getFilePaths= { arg poolName;
	var pathArr= List.new;
	XQ.globalBufferDict.at(poolName)[0].do({ arg buffer, i;
		pathArr = pathArr.add(buffer.path);
	});

	pathArr;
};



loadBuffers= {arg paths, selections;
	var f, filesize, buffer, loadBufTask;
	paths.do({ arg file;
		file.postln;
		f = SoundFile.new;
		f.openRead(file);
		buffer = Buffer.read(s, file);
		bufList.add(buffer);
		// if loading from Cocoa Dialog, then all file is selected:
		if(selections.isNil, {bufListSelections.add([0, f.numFrames])});
		sndNameList = sndNameList.add(file.basename);
		f.close;
	});
	lvBuffers.items_(sndNameList);
	if(selections.notNil, {bufListSelections = selections}); // if loading from PoolManager, then supply selection list
	XQ.globalBufferDict.add(poolName.asSymbol -> [bufList, bufListSelections]);
	if(s.serverRunning, {
		loadBufTask = Task({
			inf.do({ |i|
			if(bufList[bufList.size-1].numChannels != nil, { loadBufTask.stop });
			"loading sounds ->  ".post; (i*100).post; " milliseconds".postln;
			0.1.wait;
			});
		}).start;
	});
};



loadFile= { arg currTrack, currBuf, currSynth, update= true;
	var filepath, soundfile, checkBufLoadTask, tmpBuf;
	stFilename[currTrack].object_(lvBuffers.items[currBuf]);
	bufTrack[currTrack]= currBuf;

	if(currBuf != 0, {
		btBufFile[currTrack].enabled_(false); // buffer cannot be saved to a file
		filepath = XQ.globalBufferDict.at(poolName)[0][currBuf-1].path; // the 1st buffer is always internal
		soundfile = SoundFile.new;
		soundfile.openRead(filepath);
		if(soundfile.numChannels == 2, {
			tmpBuf = Buffer.readChannel(s, filepath, channels: [0]); //if it's stereo, read only left channel
		}, {
			tmpBuf = Buffer.read(s, filepath);
		});

		if(update == true, {
			if(btGranAreaList[currTrack].value == 1, {
				sfViewGran.drawsWaveForm_(true);
				sfViewGran.soundfile_(soundfile);

				if(soundfile.numFrames <= (soundfile.sampleRate*60), { // soundfile is less than minute
					sfViewGran.read(0, soundfile.numFrames);				}, {
					sfViewGran.readWithTask(0, soundfile.numFrames);
				});
				sfViewGran.selectionDuration(0);
				sfViewGran.refresh;
			});
		});

		soundfile.close;

		checkBufLoadTask = Task({
			inf.do({
				if(tmpBuf.numChannels != nil, {
					if(currSynth != nil, {
						currSynth.set(\bufnum, tmpBuf.bufnum, \bufdur, tmpBuf.numFrames/tmpBuf.sampleRate);
					}, {
						synthList.at(currTrack).set(\bufnum, tmpBuf.bufnum, \bufdur, tmpBuf.numFrames/tmpBuf.sampleRate);
					});
					checkBufLoadTask.stop;
				});
				0.1.wait;
			});
		}).start;
	}, {
		btBufFile[currTrack].enabled_(true); // buffer can be saved to a file
		if(btGranAreaList[currTrack].value == 1, { sfViewGran.drawsWaveForm_(false) }); //clearing soundfile view
		synthList.at(currTrack).set(\bufnum, tmpBuffer.bufnum, \bufdur, tmpBuffer.numFrames/tmpBuffer.sampleRate); // set internal buffer
	});
	if (grVolList[currTrack].value != 0, { grVolList[currTrack].valueAction_(grVolList[currTrack].value) } );
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
		lvBuffers.items_(sndNameList); // add new sounds to list
	});
};






updateFileList = { |currPad| // update fileLists, check last element



	loadFileList.value(bufferList.items[bufferList.value].asSymbol, 1); // update filelists
	loadFile.value(currPad, lvBuffers.items.size-1);
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







//pre-sets section
psetCurr = psetNum+1; // initial state, means no pre-set is choosen

psetNum.do({ |i|
	psetButtList.add(
		Button(w,Rect(
				3+((if(i<(psetNum/2), {i}, {i-(psetNum/2)}))*36),
				2+((if(i<(psetNum/2), {0}, {1}))*18),
				36, 18 )
		)
			.font_(globalFont2)
			.canFocus_(false)
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
		psetSynth.put(6, slMiscDev[i].value); // 6 - panorama wide - deviation
		psetSynth.put(7, slMiscAve[i].value); // 7 - panorama wide - average
		psetSynth.put(8, grModSwitchList[i].value); // 8 - modulation switch
		psetSynth.put(9, stFilename[i].object.asSymbol); // 9 - soundfile
		psetSynth.put(10, knPerlinDurList[i].value); // 10 - perlin - duration
		psetSynth.put(11, slPerlinDispList[i].value); // 11 - perlin - dispersion
		psetSynth.put(12, knPerlinRaduisList[i].value); // 12 - perlin - radius
		psetCurrList.put(i, psetSynth); // put synthgran[i] settings into the pre-set list
	});
	psetSynth = Array.fill(20, nil); // global settings
	psetSynth.put(0, "global"); // 0 - "global"
	psetSynth.put(1, monoChList.value); // 1 - global input bus
	psetSynth.put(2, nil); // 2 - GLOBALS GONE
	psetSynth.put(3, nil); // 3 - GLOBALS GONE
	psetSynth.put(4, nil); // 4 - GLOBALS GONE
	psetSynth.put(5, grVolInput.value); // 5 - input volume
	psetSynth.put(6, slRamp.value); // 6 - swith pre-set ramp time
	psetSynth.put(7, nil); // 7 - GLOBALS GONE
	psetSynth.put(8, sec3Spec.map(grBufLen.value)); // 8 - input buffer length
	psetSynth.put(9, bufferList.value.asString); // 9 - buffer num
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
		grVolInput.valueAction_(presetCurrNode[4][5]);
		slRamp.valueAction_(presetCurrNode[4][6]);
		grBufLen.valueAction_(sec3Spec.unmap(presetCurrNode[4][8]));
		//bufferList.valueAction_(presetCurrNode[4][9]); // decide what to do with buffer
		knPerlinDurGlob.valueAction_(presetCurrNode[4][10]);
		slPerlinDispGlob.valueAction_(presetCurrNode[4][11]);
		knPerlinRaduisGlob.valueAction_(presetCurrNode[4][12]);

		// prepare to refill global arrays


		globSlidList = Array.fill(4, 0);



		4.do({ |i|
			// WARNING!! the order of the updates matters!
			startVol = grVolList[i].value;
			if(startVol == 0, { synthNamesAction.value(currGran) });
			grChList[i].valueAction_(presetCurrNode[i][1]);


			grGlobBtList[i].valueAction_(presetCurrNode[i][4]);



			grslidList[i].activex_(presetCurrNode[i][2]);
			grslidList[i].activey_(presetCurrNode[i][3]);


			grVolList[i].valueAction_(presetCurrNode[i][5]);

			pmSynthNames[i]= synthNameList.find([presetCurrNode[i][0]]);
			stSynthNames[i].string_(lvGranSynths.items.at(pmSynthNames[i]) );
			synthNamesAction.value(i);



			//panorama wide settings
			slMiscDev[i].valueAction_(if(presetCurrNode[i][6].isNil, {0.8}, {presetCurrNode[i][6]}) ); // 6 - deviation
			slMiscAve[i].valueAction_(if(presetCurrNode[i][7].isNil, {0.4}, {presetCurrNode[i][7]}) ); // 7 - average
			rsWideRangeList[i].setDeviation(slMiscDev[i].value, slMiscAve[i].value);
			rsWideRangeList[i].setSpanActive(rsWideRangeList[i].lo, rsWideRangeList[i].hi);

			//bookmark - ERROR HERE!!!
			//stFilename[i].object= lvBuffers.items.indexOf(presetCurrNode[i][9]);
			//lvBuffers.items.indexOf()
			//presetCurrNode[i][9].asSymbol.postln;


			grModSwitchList[i].valueAction_(presetCurrNode[i][8]);


			knPerlinDurList[i].valueAction_(presetCurrNode[i][10]);
			slPerlinDispList[i].valueAction_(presetCurrNode[i][11]);
			knPerlinRaduisList[i].valueAction_(presetCurrNode[i][12]);
		});
	});
};





//orientation grids
//w.drawHook = {
//	Pen.strokeColor = Color.white;
//	//5, 80, 115, 100
//	//vertical top to bottom
//	Pen.line((slL-140+trunc(slW/2))@slT+1, (slL-140+trunc(slW/2))@(slT+slH-2)); // global
//	4.do({ |i| Pen.line((slL+(i*hrIndex)+trunc(slW/2))@slT+1, (slL+(i*hrIndex)+trunc(slW/2))@(slT+slH-2)) }); // 1-4
//	//horizontal left to right
//	Pen.line((slL-140+1)@(slT+trunc(slH/2)+1), (slL-140+slW-2)@(slT+trunc(slH/2)+1)); // global
//	4.do({ |i| Pen.line((slL+(i*hrIndex)+1)@(slT+trunc(slH/2)+1), (slL+(i*hrIndex)+slW-2)@(slT+trunc(slH/2)+1)); }); // 1-4
//	//diagonal left top to right bottom
//	Pen.line((slL-140+1)@(slT+1), (slL-140+slW-2)@(slT+slH-2)); // global
//	4.do({ |i| Pen.line((slL+(i*hrIndex)+1)@(slT+1), (slL+(i*hrIndex)+slW-2)@(slT+slH-2)); }); // 1-4
//	//diagonal left bottom to right top
//	Pen.line((slL-140+1)@(slT+slH-2), (slL-140+slW-2)@slT+1); // global
//	4.do({ |i| Pen.line((slL+(i*hrIndex)+1)@(slT+slH-2), (slL+(i*hrIndex)+slW-2)@slT+1); }); // 1-4
//	//orientation rectangle
//	Pen.addRect(Rect(slL-140+trunc(slW/4), slT+trunc(slT/4)+4, trunc(slW/2)+2, trunc(slH/2)+1)); // global
//	4.do({ |i| Pen.addRect(Rect(slL+(i*hrIndex)+trunc(slW/4), slT+trunc(slT/4)+4, trunc(slW/2)+2, trunc(slH/2)+1)); }); // 1-4
//	Pen.stroke;
//};


// LOOPER PANEL

//to-do:
//- the possibility of warping synth (changing pitch without changing tempo)

globalLoopList=Array.fill(tracks, 0);

tracks.do({ |i|


	var trigID= idNum + (i * 2);

	// looper area


	cvLoopArea.add(
		CompositeView(w,Rect(loopLeft+(i*loopWidth), topPos+45, loopWidth, 180))
			.background_(loopColorTransp)
	);
	// waveform area
	cvLoopWaveArea.add(
		CompositeView(w,Rect(loopLeft, topPos+230, loopWidth*5+(loopWidth/2), 150))
			.background_(loopColorTransp)
	);
	// waveform
	sfLoopWave.add(
		SCSoundFileView.new(cvLoopWaveArea[i], Rect(0, 20, loopWidth*4, 90))
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
			.canFocus_(false)
			.mouseUpAction_({
				var startPos, startLoop, endLoop, currPos, buffer;

				if(loopSynthList[i] != nil, {
					moveTimeCursor.value(i, 0, 0, 0, -1); // first stop current playback
					btLoopPlayPause[i].value= 1; //return "Play/Pause" button into || state

					if (bufTrack[i+tracks] > 0, {
						buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
					}, {
						buffer = tmpBuffer
					});

					currPosList[i]= nil; // clearing up current position
					startPos= sfLoopWave[i].selections[0][0];



					startLoop= startPos;
					endLoop= startLoop + sfLoopWave[i].selections[0][1];
					if(sfLoopWave[i].selectionSize(0) < 10, { endLoop = buffer.numFrames-1; });
					//show selection
					sfLoopWave[i].setSelection(0, [startLoop, endLoop-startLoop]);
					sfLoopWave[i].refresh;

					moveTimeCursor.value(i, buffer.sampleRate, startPos, endLoop, 0); // switch on playback indicator
					startLoopSynth.value(i, trigID, buffer, startPos, startLoop, endLoop); // play a synth
				});
			})


	);
	//waveform zoom
	slLoopZoom.add(
		GUI.slider2D.new(cvLoopWaveArea[i], Rect(0, 115, loopWidth*4, 40)) // scroll w/zoom x
			.canFocus_(false)
			.action_({ |sl|
				var y;
				sfLoopWave[i].zoomToFrac(y = sl.y * 0.95 + 0.05);
				sfLoopWave[i].scrollTo(sl.x);
			})
			.y_(1).x_(0.5);
	);

	// startLoop button
	btLoopStartPos.add(
		Button(cvLoopWaveArea[i], Rect(0, 0, 60, 17))
			.font_(globalFont1)
			.background_(loopColorCurr)
			.canFocus_(false)
			.states_([
				["start pos", btColorOn, ctlColor10],
			])
			.value_(0)
			.action_({ |bt|
				var buffer, startPos, selEnd, startLoop, endLoop;
				if(loopSynthList[i] != nil, {
					if(currPosList[i] != nil, {
						startPos= currPosList[i];

						moveTimeCursor.value(i, 0, 0, 0, -1); // first stop current playback
						btLoopPlayPause[i].value= 1; //return "Play/Pause" button into || state

						if (bufTrack[i+tracks] > 0, {
							buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
						}, {
							buffer = tmpBuffer
						});

						trigID = idNum + (i * 2);

						selEnd= sfLoopWave[i].selections[0][0] + sfLoopWave[i].selections[0][1];
						sfLoopWave[i].setSelectionStart(0, startPos);
						sfLoopWave[i].setSelectionSize(0, selEnd-startPos);




						startLoop= startPos;
						endLoop= selEnd;



						if(sfLoopWave[i].selectionSize(0) < 10, { endLoop = buffer.numFrames-1; });

						moveTimeCursor.value(i, buffer.sampleRate, startPos, endLoop, 0); // switch on playback indicator
						startLoopSynth.value(i, trigID, buffer, startPos, startLoop, endLoop); // play a synth
					})
				})
			})
	);
	// endLoop button
	btLoopEndPos.add(
		Button(cvLoopWaveArea[i], Rect(63, 0, 60, 17))
			.font_(globalFont1)
			.background_(loopColorCurr)
			.canFocus_(false)
			.states_([
				["end pos", btColorOn, ctlColor10],
			])
			.value_(0)
			.action_({ |bt|
				var buffer, startPos, selEnd, startLoop, endLoop;
				if(loopSynthList[i] != nil, {
					if(currPosList[i] != nil, {
						if (bufTrack[i+tracks] > 0, {
							buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
						}, {
							buffer = tmpBuffer
						});

						selEnd= currPosList[i];
						startPos= sfLoopWave[i].selections[0][0];






						sfLoopWave[i].setSelectionStart(0, startPos);
						sfLoopWave[i].setSelectionSize(0, selEnd-startPos);




						startLoop= startPos;
						endLoop= selEnd;



						if(sfLoopWave[i].selectionSize(0) < 10, { endLoop = buffer.numFrames-1; });

						moveTimeCursor.value(i, buffer.sampleRate, startPos, endLoop, 0, true); // switch on playback indicator
						loopSynthList[i].set(\endLoop, endLoop);
					})
				})
			})
	);
	// clear selection button
	btLoopClearSel.add(
		Button(cvLoopWaveArea[i], Rect(127, 0, 60, 17))
			.font_(globalFont1)
			.background_(loopColorCurr)
			.canFocus_(false)
			.states_([
				["clear sel", btColorOn, ctlColor10],
			])
			.value_(0)
			.action_({ |bt|
				var buffer, startPos, endLoop;
				if(loopSynthList[i] != nil, {
					sfLoopWave[i].setSelectionStart(0, 0);
					sfLoopWave[i].setSelectionSize(0, 0);

					if(loopSynthList[i] != nil, {
						if(currPosList[i] != nil, {
							if (bufTrack[i+tracks] > 0, {
								buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
							}, {
								buffer = tmpBuffer
							});
							startPos= currPosList[i];
							endLoop = buffer.numFrames-1;

							loopSynthList[i].set(\startPos, startPos, \startLoop, 0, \endLoop, endLoop);
							moveTimeCursor.value(i, buffer.sampleRate, currPosList[i], endLoop, 0, true); // switch on playback indicator
						});
					});
				})
			})
	);
	//pitch slider
	ssLoopPitch.add(
		Slider(cvLoopWaveArea[i], Rect(195, 2, 90, 13))
			.background_(Color.gray(alpha:0.7))
			.canFocus_(false)
			.value_(pitchSpec.unmap(1))
			.mouseOverAction_({ |sl|
				stStatusBar.string = stLoopPitchString[i].string ++ " loop " ++ (i+1) ++ " pitch ";
			})
			.action_({ |sl|
				pitchSign= if(btLoopDir[i].value == 1, { -1 }, { 1 });
				stLoopPitchString[i].string= pitchSign * pitchSpecDisp.map(sl.value);
				stStatusBar.string = stLoopPitchString[i].string ++ " loop " ++ (i+1) ++ " pitch ";
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\pitch, pitchSign * pitchSpec.map(sl.value)) });

				if(globalLoopList[i] == 1, {
					tracks.do({ |j|
						if( (globalLoopList[j] == 1) && (i != j), {
							ssLoopPitch[j].value= sl.value;
							stLoopPitchString[j].string= pitchSign * pitchSpecDisp.map(ssLoopPitch[j].value);
							if(loopSynthList[j] !=nil, { loopSynthList[j].set(\pitch, pitchSign * pitchSpec.map(ssLoopPitch[j].value)) });
						});
					});
				});

			})
	);
	//pitch string
	stLoopPitchString.add(
		GUI.staticText.new(cvLoopWaveArea[i], Rect(197, 2, 50, 13))
			.font_(globalFont1)
			.stringColor_(Color.white)
			.string_(pitchSpecDisp.map(ssLoopPitch[i].value))
	);

	// pitch to default
	btPitchDef.add(
		Button(cvLoopWaveArea[i], Rect(290, 0, 17, 17))
			.font_(globalFont1)
			.background_(loopColorCurr)
			.canFocus_(false)
			.states_([
				["0", btColorOn, ctlColor10],
			])
			.value_(0)
			.action_({ |bt|
				ssLoopPitch[i].valueAction_(pitchSpecDisp.unmap(1))
			})
	);

	//timecode string
	stTimecode.add(
		GUI.staticText.new(cvLoopWaveArea[i], Rect(loopWidth*4-50, 0, 60, 17))
			.font_(globalFont5)
			.string_("")
	);

	// button - selecting current looper


	btLoopAreaList.add(


		Button(w,Rect(loopLeft+(i*loopWidth), topPos, loopWidth, 45))
			.canFocus_(false) .font_(globalFont3) .value_(0)
			.states_([
				["       " ++ (i+5).asString, loopColorCurr, loopColorBg],
				["       " ++ (i+5).asString, loopColorBg, loopColorCurr]
			])



			.receiveDragHandler_({
				case
					{ dragSrc == 0 } { // file


						stFilename[i+4].object= lvBuffers.items.indexOf(currDragFile);
						loadFileLoop.value(i, currDragFile);



					}
					{ dragSrc == 1 } { // synth
						//do nothing
					};
			})


			.action_({ |bt|
				4.do({ |j|
					if( (btLoopAreaList[j].value == 1) && (j != i), { btLoopAreaList[j].value = 0 });
					cvLoopArea[j].background_(loopColorTransp);
					cvLoopWaveArea[j].visible = false;
				});
				bt.value= 1; // keep current state, at least one looper should be active
				cvLoopArea[i].background_(loopColorCurr);
				cvLoopWaveArea[i].visible = true;
				currLooper= i;
			})
	);
	// playback position progress bar (on a button)
	ssLoopPlaybackInd.add(
		Slider(w, Rect(loopLeft+(i*loopWidth)+2, topPos+38, loopWidth-5, 5))
			.knobColor_(btColorEffColor)
			.visible_(false)
			.canFocus_(false)
			.value_(0);
	);

	// panorama knob
	knLoopPan.add(
		Knob(cvLoopArea[i], Rect(5, 5, 30, 13))
			.centered_(true)
			.value_(0.5)
			.mouseOverAction_({ |sl|
				stStatusBar.string = round(\pan.asSpec.map(sl.value), 0.01).asString ++ " loop " ++ (i+1) ++ " pan ";
			})
			.action_({ |sl|
				stStatusBar.string = round(\pan.asSpec.map(sl.value), 0.01).asString ++ " loop " ++ (i+1) ++ " pan ";
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\pan, \pan.asSpec.map(sl.value)) });

				if(globalLoopList[i] == 1, {
					tracks.do({ |j|
						if( (globalLoopList[j] == 1) && (i != j), {
							knLoopPan[j].value= sl.value;
							if(loopSynthList[j] !=nil, { loopSynthList[j].set(\pan, \pan.asSpec.map(knLoopPan[j].value)) });
						});
					});
				});
			})
	);
	//volume indicator - left channel
	ssLoopVolInd.add(
		Slider(cvLoopArea[i], Rect(42, 5, 10, 100))
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume indicator - right channel
	ssLoopVolInd.add(
		Slider(cvLoopArea[i], Rect(53, 5, 10, 100))
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume slider
	ssLoopVol.add(
		Slider(cvLoopArea[i], Rect(64, 5, 10, 100))
			.background_(Color.gray(alpha:0.01))
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0))
			.mouseOverAction_({ |sl|
				stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " loop " ++ (i+1) ++ " vol ";
			})
			.action_({ |sl|
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\vol, sl.value) });
				stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " loop " ++ (i+1) ++ " vol ";

				if(globalLoopList[i] == 1, {
					tracks.do({ |j|
						if( (globalLoopList[j] == 1) && (i != j), {
							ssLoopVol[j].value= sl.value;
							if(loopSynthList[j] !=nil, { loopSynthList[j].set(\vol, ssLoopVol[j].value) });
						});
					});
				});
			})
	);
	// slider global button
	grVol0.add(
		SCUserView(cvLoopArea[i], Rect(64, 33, 10, 2))
			.canFocus_(false)
			.background_(Color.black)
	);


	// start/pause button
	btLoopPlayPause.add(
		Button(cvLoopArea[i], Rect(5, 35, 30, 18))
			.canFocus_(false)
			.states_([
				[\play, btColorOn, ctlColor10],
				[\pause, btColorPlay, loopColorCurr]
			])
			.value_(0)
			.action_({ arg butt; var startPos, startLoop, endLoop, buffer;
				if(butt.value == 1, {
					if (bufTrack[i+tracks] > 0, {
						buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
					}, {
						buffer = tmpBuffer
					});

					trigID = idNum + (i * 2);




					startPos= if(currPosList[i] == nil, { sfLoopWave[i].selections[0][0] }, { currPosList[i] } );
					startLoop= sfLoopWave[i].selections[0][0];


					endLoop= startLoop + sfLoopWave[i].selections[0][1];
					if(sfLoopWave[i].selectionSize(0) < 10, { endLoop = buffer.numFrames-1; });

					moveTimeCursor.value(i, buffer.sampleRate, startLoop, endLoop, 0); // switch on playback indicator



					startLoopSynth.value(i, trigID, buffer, startPos, startLoop, endLoop); // play a synth
				},{


					// pause processing
					loopSynthList[i].set(\gate, 0); loopSynthList[i] = nil;
					moveTimeCursor.value(i, 0, 0, 0, 1);
				});
		})
	);
	// stop button
	btLoopStop.add(
		Button(cvLoopArea[i], Rect(5, 53, 30, 15))
			.canFocus_(false)
			.states_([
				[\stop, btColorOn, ctlColor10],
			])
			.value_(0)
			.action_({
				moveTimeCursor.value(i, 0, 0, 0, -1);
			})
	);
	// record button
	btLoopRec.add(
		Button(cvLoopArea[i], Rect(5, 71, 30, 18))
			.canFocus_(false)
			.states_([
				[\record, btColorPlay, btColorStop],
				[\stop, btColorStop, btColorPlay]
			])
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
						currRec = i+4; // for the purpose of update time text only for the current looper

						filename = tvRecNameList[i].string;
						if(filename == "", {
							filename = "Track" ++ (i+5).asSymbol ++ "_" ++ Date.getDate.stamp.asString;						});

						if(btRecMSswitch[i].value == 0, { // record from mono bus
							recSynth = XiiRecord(s, monoChList.value, 1, sampleFormat: XQ.pref.bitDepth);
						}, { // record from stereo bus
							recSynth = XiiRecord(s, stereoChList.value*2, 2, sampleFormat: XQ.pref.bitDepth);
						});
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
	// global mode selector button
	btLoopGlob.add(
		Button(cvLoopArea[i], Rect(79, 5, 13, 13))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.canFocus_(false)
			.action_({ |bt|
				globalLoopList[i] = bt.value;
			});
	);
	// mono/stereo rec button
	btRecMSswitch.add(
		Button(cvLoopArea[i], Rect(75, 20, 20, 13))
			.canFocus_(false)
			.font_(globalFont1)
			.states_([
				["mn", btColorOn, ctlMainColor2],
				["st", Color.white, ctlColor21]
			])
			.value_( if(i < 3, {0}, {1}) )
	);
	// dir button
	btLoopDir.add(
		Button(cvLoopArea[i], Rect(75, 45, 20, 18))
			.canFocus_(false)
			.font_(globalFont1)
			.states_([
				["rev", btColorOn, btColorOff],
				["rev", btColorOff, btColorOn]
			])
			.value_(0)
			.action_({ |bt|
				if(loopSynthList[i] !=nil, {
					pitchSign= if(bt.value == 1, { -1 }, { 1 });
					loopSynthList[i].set(\pitch, pitchSign * pitchSpec.map(ssLoopPitch[i].value));
				});
			})
	);
	// loop/one button
	btLoopMode.add(
		Button(cvLoopArea[i], Rect(75, 65, 20, 18))
			.canFocus_(false)
			.states_([
				[\roundArrow, btColorOn, btColorOff],
				[\lineArrow, btColorOff, btColorOn]
			])
			.value_(0)
			.action_({ |bt|
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\loop, 1-bt.value) });
			})
	);
	// cross-fade button
	btLoopCF.add(
		Button(cvLoopArea[i], Rect(75, 85, 20, 18))
			.canFocus_(false)
			.font_(globalFont1)
			.states_([
				["|..|", btColorOn, btColorOff],
				["X", btColorOn, Color.new255( 205, 190, 112 )]
			])
			.value_( if(i < 3, {0}, {1}) )
			.action_({ |bt|
				if(loopSynthList[i] !=nil, {
					if(bt.value == 1, { loopSynthList[i].set(\lag, 0.1) }, { loopSynthList[i].set(\lag, 0) });
				});
			})
	);
	// time string
	stTimeText.add(
		GUI.staticText.new(cvLoopArea[i], Rect(5, 90, 40, 15))
			.font_(globalFont5)
			.string_("00:00");
	);

	// file container (one list for both Grans & Loopers!!)
	stFilename.add(
		DragBoth(cvLoopArea[i], Rect(2, 108, loopWidth-4, 50))
			.background_(ctlMainColor1.alpha_(0.3))
			.object_("")
			.beginDragAction_({ |obj| dragSrc= 0; currDragFile= lvBuffers.items.indexOf(obj.object.asString) }) //0 is file, 1 is synth
			.receiveDragHandler_({ |obj|
				if(dragSrc == 0, {
					obj.object= lvBuffers.items.indexOf(currDragFile);
					loadFileLoop.value(i, currDragFile);
				})
			})
	);

	// output channel dropdown list
	pmLoopChList.add(
		SCPopUpMenu.new(cvLoopArea[i], Rect(5, 157, 62, 20))
			.items_(chlistStereo)
			.background_(btColorBG)
			.canFocus_(false)
			.action_({ |pm|
				if(loopSynthList[i] != nil, {
					loopSynthList[i].set(\out, pm.value * 2);
				})
			})
	);
});



//global ctrls
// global start/pause button
btLoopPlayPauseGlob= Button(w, Rect(loopLeft+(4*loopWidth)+15, topPos+45+60, 30, 18))
	.canFocus_(false)
	.states_([
		[\play, btColorOn, ctlColor10],
		[\pause, btColorPlay, loopColorCurr]
	])
	.value_(0)
	.action_({ |bt|
		tracks.do({ |i|
			if(globalLoopList[i] == 1, {
				btLoopPlayPause[i].valueAction_(bt.value);
			})
		});
	});
//global stop button
btLoopStopGlob= Button(w, Rect(loopLeft+(4*loopWidth)+15, topPos+125, 30, 18))
	.canFocus_(false)
	.states_([
		[\stop, btColorOn, ctlColor10],
	])
	.value_(0)
	.action_({ |bt|
		tracks.do({ |i|
			if(globalLoopList[i] == 1, {
				// btLoopStop[i].valueAction_(0); - WhyTF doesn't this work???
				moveTimeCursor.value(i, 0, 0, 0, -1);
				btLoopPlayPauseGlob.value = 0;
			})
		});
	});

//panic button
btPanic= Button(w, Rect(loopLeft+(4*loopWidth)+20, 5, 30, 30))
	.canFocus_(false)
	.states_([
		[\x, Color.white, btColorPlay],
	])
	.value_(0)
	.action_({ |bt|
		tracks.do({ |i|
			//stop ALL loopers
			moveTimeCursor.value(i, 0, 0, 0, -1);
			btLoopPlayPauseGlob.value = 0;
			//stop ALL grans
			if(synthList[i] != nil, {
				synthList[i].set(\gate, 0);
				synthList[i] = nil;
			});
			// volume indicators to 0
			slideEnv.value(ssGranVolInd[i*2], ssLoopVolInd[i*2].value, volSpec.unmap(0.ampdb), 1, 0.01, 2);
			slideEnv.value(ssGranVolInd[i*2+1], ssLoopVolInd[i*2+1].value, volSpec.unmap(0.ampdb), 1, 0.01, 2);
		});
	});


loadFileLoop= { arg currTrack, currBuf;
	var filepath, soundfile, selStart, selEnd, checkBufLoadTask, tmpBuf;

	stFilename[currTrack+4].object_(lvBuffers.items[currBuf]);
	bufTrack[currTrack+4]= currBuf;

	if(currBuf != 0, {
		currPosList[currTrack]= nil; // clear current position
		filepath = XQ.globalBufferDict.at(poolName)[0][currBuf-1].path; // value-1 'cause the 1st buffer is always internal
		soundfile = SoundFile.new;
		soundfile.openRead(filepath);
		sfLoopWave[currTrack].drawsWaveForm_(true);
		sfLoopWave[currTrack].soundfile_(soundfile);
		if(soundfile.numFrames <= (soundfile.sampleRate*60), { // soundfile is less than minute
			sfLoopWave[currTrack].read(0, soundfile.numFrames);
		}, {
			sfLoopWave[currTrack].readWithTask(0, soundfile.numFrames);
		});
		sfLoopWave[currTrack].setSelectionStart(0, 0);
		sfLoopWave[currTrack].setSelectionSize(0, 0);
		sfLoopWave[currTrack].refresh;

		soundfile.close;
	}, {
		sfLoopWave[currTrack].drawsWaveForm_(false); //clearing soundfile view
	});
};


startLoopSynth = { arg curr, trigID, buffer, startPos, startLoop, endLoop;
	var pitchSn, cfLag;
	pitchSn= if(btLoopDir[curr].value == 0, { 1 }, { -1 });
	cfLag= if(btLoopCF[curr].value == 1, { 0.1 }, { 0 });

	loopSynthList[curr]=
		if(buffer.numChannels == 2, {
			Synth.new(\gmpLoopStereo,
				[ \bufnum, buffer.bufnum,
				  \trigID, trigID, // the bus for the gui update
				  \out, pmLoopChList[curr].value * 2,
				  \vol, ssLoopVol[curr].value,
				  \pan, \pan.asSpec.map(knLoopPan[curr].value),
				  \pitch, pitchSn * pitchSpec.map(ssLoopPitch[curr].value),
				  \startPos, startPos,
				  \startLoop, startLoop,
				  \endLoop, endLoop,
				  \loop, 1-btLoopMode[curr].value,
				  \trig, (endLoop-startLoop)/buffer.sampleRate,
				  \lag, cfLag,
				  \gate, 1
				],
				s, \addToHead);
		}, {
			Synth.new(\gmpLoopMono,
				[ \bufnum, buffer.bufnum,
				  \trigID, trigID, // the bus for the gui update
				  \out, pmLoopChList[curr].value * 2,
				  \vol, ssLoopVol[curr].value,
				  \pan, \pan.asSpec.map(knLoopPan[curr].value),
				  \pitch, pitchSn * pitchSpec.map(ssLoopPitch[curr].value),
				  \startPos, startPos,
				  \startLoop, startLoop,
				  \endLoop, endLoop,
				  \loop, 1-btLoopMode[curr].value,
				  \trig, (endLoop-startLoop)/buffer.sampleRate,
				  \lag, cfLag,
				  \gate, 1
				],
				s, \addToHead);
		});
};


//playback indicator
moveTimeCursor = { arg curr, sRate, startPos, end, action= 0, reload= false;
	var start, pos, dur, envDur= 0;

	start= startPos;
	dur= end-start;
	pos= if(btLoopDir[curr].value == 0, { 0 }, { dur });




	case
		{action == 0}  { // start
			sfLoopWave[curr].timeCursorPosition_(pos);
			ssLoopPlaybackInd[curr].value= pos.linlin(0, dur, 0, 1);
			ssLoopPlaybackInd[curr].visible = true;
			stTimecode[curr].visible = true;

			if(reload == true, { if(indTaskList[curr] != nil, { indTaskList[curr].stop; indTaskList[curr]= nil; }); });

			if(indTaskList[curr] != nil, {
				indTaskList[curr].resume
			}, {
				indTaskList[curr]= Task.new({ |time|
					inf.do({ |i|
						{
							w.isClosed.not.if({
								currPosList[curr]= start+pos;
								sfLoopWave[curr].timeCursorPosition_(currPosList[curr]);
								ssLoopPlaybackInd[curr].value = pos.linlin(0, dur, 0, 1);
								stTimecode[curr].string= convertTime.value(currPosList[curr]/sRate);
							});

							if(btLoopDir[curr].value == 0, { // normal playback
								if((start+pos) >= end, {
									// set indicator to start position
									if(btLoopMode[curr].value == 0, { // loop is on
										pos= 0;
										start= sfLoopWave[curr].selections[0][0];



//										envDur= case
//											{sfLoopWave[curr].selections[0][1] == 0} { (sfLoopWave[curr].numFrames-1)/sRate }
//											{sfLoopWave[curr].selections[0][1] < 0}  { (sfLoopWave[curr].numFrames+sfLoopWave[curr].selections[0][1])/sRate }
//											{sfLoopWave[curr].selections[0][1] > 0} { sfLoopWave[curr].selections[0][1]/sRate };
//										[sfLoopWave[curr].selections[0][0], sfLoopWave[curr].selections[0][1], sfLoopWave[curr].numFrames, envDur].postln;
//										// i need to RE-TRIGGER an envelope here, not just to update a parameter !!!
//										loopSynthList[i].set(\envdur, envDur);
									}, {
										ssLoopPlaybackInd[curr].visible= false;
										stTimecode[curr].visible = false;
										indTaskList[curr].stop;
										indTaskList.put(curr, nil);
										clearOnStop.value(curr);
									});
								});
							}, { // reversed playback
								if(pos <= 0, {
									// set indicator to start position
									if(btLoopMode[curr].value == 0, { // loop is on
										start= sfLoopWave[curr].selections[0][0];
										dur= end-start;
										pos= dur;
									}, {
										ssLoopPlaybackInd[curr].visible= false;
										stTimecode[curr].visible = false;
										indTaskList[curr].stop;
										indTaskList.put(curr, nil);
										clearOnStop.value(curr);
									});
								});

							})
						}.defer;

						if(btLoopDir[curr].value == 0, {
							pos= pos + (pitchSpec.map(ssLoopPitch[curr].value)*(sRate/100))
						}, {
							pos= pos - (pitchSpec.map(ssLoopPitch[curr].value)*(sRate/100));
						});
						0.01.wait;
					});
				}).start;

			});
		}
		{action == 1}  { if(indTaskList[curr] != nil, { // pause
			indTaskList[curr].pause;
		}) }
		{action == -1} { if(indTaskList[curr] != nil, { // stop
			indTaskList[curr].stop;
			indTaskList.put(curr, nil);
			clearOnStop.value(curr);
		}) };
};


clearOnStop = { |currPad|
	var stopTask;
	if(loopSynthList[currPad] != nil, {


		loopSynthList[currPad].set(\gate, 0);
		loopSynthList[currPad]= nil;
	});
	// volume indicators to 0
	slideEnv.value(ssLoopVolInd[currPad*2], ssLoopVolInd[currPad*2].value, volSpec.unmap(0.ampdb), 1.5, 0.01, 2);
	slideEnv.value(ssLoopVolInd[currPad*2+1], ssLoopVolInd[currPad*2+1].value, volSpec.unmap(0.ampdb), 1.5, 0.01, 2);

	btLoopPlayPause[currPad].value= 0;



	ssLoopPlaybackInd[currPad].visible= false;
	stTimecode[currPad].visible = false;

	// clear currPosList and put cursor to the start of selection
	stopTask = Task.new({ |time|
		5.do({ |j|
			{
				w.isClosed.not.if({
					currPosList.put(currPad, nil);
					sfLoopWave[currPad].timeCursorPosition= sfLoopWave[currPad].selections[0][0];
				})
			}.defer;
			0.1.wait;
		});
	}).start;

};



convertTime= { arg timecode;
	var sec= 0, min= 0, minstring= "00", secstring= "00";
	if(timecode >= 60, { min= trunc(timecode / 60); sec= round(timecode % 60, 0.1); }, { sec= round(timecode,0.1)});
	if(min < 10, {minstring = "0"++min.asString}, {minstring = min.asString});
	if(sec < 10, {secstring = "0"++sec.asString}, {secstring = sec.asString});
	minstring++":"++secstring
};



updateLooperList= { |currLoop| // update fileLists, check last element



	loadFileList.value(bufferList.items[bufferList.value].asSymbol, 1); // update filelist
	loadFileLoop.value(currLoop, lvBuffers.items.size-1);
};


// LOOPER PANEL end


//initial settings
btLoopAreaList[0].valueAction_(1); // make the 1st looper active
4.do({ |i|
	loadFile.value(i, i);
	loadFileLoop.value(i, i);
});


//Scheduler: at the moment - specifically for sampling & looping in the 'Let you tell us something'
procLYTUS= { arg cnt;
	var recTask0, cycle=120; // 2'

	//apply settings to and start click-track
	pmLoopChList[pmLoopChList.size-1].value= 14;



	btLoopMode[pmLoopChList.size-1].valueAction_(1); // loop off
	btLoopPlayPause[pmLoopChList.size-1].valueAction_(1);



	"task started".postln;
	//0'-2' - recording
	btLoopRec[cnt].valueAction_(1);
	recTask0 = Task({
		inf.do({ |j|
			{
				if(j == cycle, { btLoopRec[cnt].valueAction_(0); }); // 1st take - rec finished
				if(j == (cycle+2), { // wait 2'' for saving
					knLoopPan[cnt].valueAction_(0.32); // slightly adjust panorama to the left
					btLoopMode[cnt].valueAction_(1); // loop off
					btLoopPlayPause[cnt].valueAction_(1); //then play it back
					btLoopRec[cnt+1].valueAction_(1); // and start the next recording
				});
				if(j == (cycle*2+2), { btLoopRec[cnt+1].valueAction_(0); }); // 2nd take - rec finished
				if(j == (cycle*2+4), { // wait 2'' for saving
					knLoopPan[cnt+1].valueAction_(0.62); // slightly adjust panorama to the right
					btLoopMode[cnt+1].valueAction_(1); // loop off
					btLoopPlayPause[cnt+1].valueAction_(1); //then play it back
					btLoopPlayPause[cnt].valueAction_(1); //and the previous one
					btLoopRec[cnt+2].valueAction_(1); // and start the next recording
				});
				if(j == (cycle*3+2), { btLoopRec[cnt+2].valueAction_(0); }); // 3rd take - rec finished
				if(j == (cycle*3+6), { // wait 2'' for saving
					knLoopPan[cnt+2].valueAction_(0.4); // slightly adjust panorama to the left
					btLoopMode[cnt+2].valueAction_(1); // loop off
					btLoopPlayPause[cnt+2].valueAction_(1); //then play it back
					btLoopPlayPause[cnt+1].valueAction_(1); //and the previous one
					btLoopPlayPause[cnt].valueAction_(1); //and the first one
					recTask0.stop;
					"task finished".postln;
				});
			}.defer;
			1.wait;
		});
	}).start;
};





//MIDI


//MIDIClient.init(4,3);			// explicitly intialize the client
//4.do({ arg i; MIDIIn.connect(i, MIDIClient.sources.at(i)); });


MIDIClient.init;			// explicitly intialize the client
13.do({ arg i; MIDIIn.connect(i, MIDIClient.sources.at(i)); });


ccResp = CCResponder({ |src, chan, num, val|
	var five2eightKeys=  #[88, 89, 90, 118]; // T Y U I
	var panDir, factor;


	//[src,chan,num,val].postln;
	case
		{ num == 10 } { //crossfade slider on X-Session:
			//pitch control in looper section (current loop)
			{ ssLoopPitch[currLooper].valueAction_(val.linlin(0, 127, 0, 1)) }.defer;
		}
		{ (num >= 48) && (num < 52) } {  // 1-4 gran vol
			{ grVolList[num - 48].valueAction_((val/127)**3) }.defer // exp slider
		}
		{ num == 1 } {  // current gran factor
			synthList[currGran].set(\factor, val.linlin(0, 100, 0, 1));



			if(globSlidList[currGran] == 1, {
				tracks.do({ |j|
					if( (globSlidList[j] == 1) && (currGran != j), { synthList[j].set(\factor, val.linlin(0, 100, 0, 1)) });
				});
			});



		}
		{ num == 56 } {  // current gran factor - TEMPORARY DOUBLING 1
			synthList[currGran].set(\factor, val.linlin(0, 100, 0, 1));




			if(globSlidList[currGran] == 1, {
				tracks.do({ |j|
					if( (globSlidList[j] == 1) && (currGran != j), { synthList[j].set(\factor, val.linlin(0, 100, 0, 1)) });
				});
			});



		}
		{ num == 2 } {  // current gran destruct
			synthList[currGran].set(\destruct, val.linlin(0, 127, 0, 1));
		}
		{ num == 57 } {  // current gran destruct - TEMPORARY DOUBLING 2
			synthList[currGran].set(\destruct, val.linlin(0, 127, 0, 1));
		}
		{ num == 5 } {  // x



			{ grslidList[currGran].activex_(val.linlin(0, 116, 0, 1)) }.defer


		}
		{ num == 4 } {  // y



			{ grslidList[currGran].activey_(val.linlin(0, 127, 1, 0)) }.defer


		}

		{ (num >= 52) && (num < 56) } {  // 5-8 loopers vol
			{ ssLoopVol[num - 52].valueAction_((val/127)**3) }.defer // exp slider
		}


//		{ ((num >= 88) && (num < 91)) || (num == 118) } { // 5 - 8 Start/Pause
//			{
//				btLoopPlayPause[five2eightKeys.find([num])].valueAction_(1-btLoopPlayPause[five2eightKeys.find([num])].value);
//			}.defer
//		}
		{ (num >= 60) && (num < 63) } {  // pan knobs for looper 28-31 (TEMPORARY!) except of 8th
			{ knLoopPan[num - 60].valueAction_(val.linlin(0, 127, 0, 1)) }.defer
		}
		{ num == 59 } {  // current gran panorama wide
			{
				slMiscDev[currGran].value_(val.linlin(0, 127, 0, 1));
				rsWideRangeList[currGran].setDeviation(slMiscDev[currGran].value, slMiscAve[currGran].value);
				rsWideRangeList[currGran].setSpanActive(rsWideRangeList[currGran].lo, rsWideRangeList[currGran].hi)
			}.defer
		}
		{ num == 58 } {  // current gran panorama pos
			{
				slMiscAve[currGran].value_(val.linlin(0, 127, 0, 1));
				rsWideRangeList[currGran].setDeviation(slMiscDev[currGran].value, slMiscAve[currGran].value);
				rsWideRangeList[currGran].setSpanActive(rsWideRangeList[currGran].lo, rsWideRangeList[currGran].hi)
			}.defer
		}
	},
	nil, nil, nil, nil
);


//MIDI

//redEffectsRack
//rER0= RedEffectsRack([RedEfxComp], 0);
//rERG0= RedEffectsRackGUI(rER0, 620@270);
//rER2= RedEffectsRack([RedEfxComp], 2);
//rERG2= RedEffectsRackGUI(rER2, 620@150);
//redEffectsRack


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
		synthList[i].set(\gate, 0);
// LOOPER PANEL
		if(indTaskList[i] != nil, { indTaskList[i].stop; indTaskList[i]= nil } );
		loopSynthList[i].set(\gate, 0);
// LOOPER PANEL end
	});
	synthIn.free;
	ccResp.remove; //MIDI
	rER0.free; rERG0.close; rER2.free; rERG2.close; //redEffectsRack
};

)