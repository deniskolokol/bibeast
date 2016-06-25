//name - see http://en.wikipedia.org/wiki/List_of_Hulk_supporting_characters
//Bi-Beast - A giant two-headed android living on a floating island in the sky, and containing the knowledge of the bird people that built it.
(
var tracks= 2;
var synthList= Array.fill(tracks, nil), channels;
var poolName, pool, poolindex, poolnamesarray;
var tmpBuffer, synthIn;
var w;
var slL=200, slT=450, slW=115, slH=100, hrIndex = 120, granWidth= 125, leftPos=200, topPos= 45;
var globalFont1=Font("Helvetica", 9), globalFont2=Font("Helvetica", 12), globalFont3=Font("Helvetica", 36), globalFont4=Font("Helvetica", 13), globalFont5=Font("Helvetica", 14);
var ctlFocusColor=Color.red(alpha:0.2), ctlMainColor1=Color.new255(205, 138, 138), ctlMainColor2=Color.new255(205, 200, 177), ctlColor10=Color.new255(205, 92, 92, 0.05), ctlColor11=Color.new255(205, 92, 92), ctlColor20=Color.new255(100, 149, 237, 0.6), ctlColor21=Color.new255(70, 130, 180), btColorOff=Color.new255(250, 250, 250), btColorOn=Color.new255(43, 43, 43), btColorPlay=Color.new255(178, 34, 34), btColorStop=Color.new255(238, 216, 174), slidColorProgress=Color.new255(123, 104, 238), btKnobColor=Color.new255(205, 38, 38), btColorBG = Color.new255(248, 248, 255), btColorEffColor=Color.new255(96, 123, 139), ctlMainColorTransp= Color.new255(205, 138, 138, 0.3), stlColorKnob= Color.new255(52,70,83), ctlColorTransp= Color.gray(alpha:0.01), ctlColorCurr= Color.new255(240, 240, 240);
var chlistStereo, chlistMono, bufferList, bufnumList=List.new, monoChList, stereoChList;
var sndNameList=[], bufDurList=List.new;
var grSTxList=List.new, grSTyList=List.new, grslidList=List.new, grVolList=List.new, grVol0= List.new, grChList=List.new, rsWideRangeList= List.new, slMiscDev= List.new, slMiscAve= List.new;
var slRamp, stRamp, grVolInput, grBufLen, stBufLen, btInputLoop, btInputRec, rslInputDur, btPlayBuff;
var timeSpec=[0.5, 10, \lin, 0.5, 1, "sec"].asSpec, sec3Spec= [0.5, 3, \lin, 0.5].asSpec, volSpec=ControlSpec(0.ampdb, 2.ampdb, \db, units: " dB"), dispSpec=[0.5, 0.001, \lin, 0.001].asSpec, radSpec=[0.01, 1, \lin, 0.01].asSpec;
var grGlobBtList=List.new, globSlidList=Array.fill(4, 0);
var cvIntBuf;
var psetNum=30, psetButtList=List.new, psetList=Array.fill(psetNum, nil), psetCurr, psetChange, saveSettings, restoreSettings;
var presetsFile=nil;
var synthNameList, pmSynthNames= List.new, stSynthNames= List.new, stSynthSelect= List.new;
var btGranAreaList= List.new, btGranAreaLabels, cvGranArea= List.new, ssGranVolInd= List.new, stFilename= List.new, btSynthOnOff= List.new;
var cvBufList, lvBuffers, btAddFile, btFreeFile, btSaveBuf, lvGranSynths, stStatusBar, btPanic;
var currGran, bufTrack= Array.fill(tracks, 0);
var volAction, synthNamesAction, synthOnOff;
var dragSrc, currDragFile, idPad= 60; // granulators start from 60
// -- buffer pool recording --
var ampAnalFunc, ampAnalyserSynth, responder, numChannels, recSynth, secTask, updateFileList, loadBufTask, currRec=4, filename;
var rslRecLevel, tvRecNameList=List.new, stTimeText=List.new, btBufFile=List.new, btBufRec=List.new, bufList=List.new, bufListSelections=List.new;
var loadFile, loadFileList, loadBuffers, getFilePaths;
var sendParam, sndTask= Array.fill(tracks, nil);
var defCoord= List.new;
//universal procedures
var slideEnv;
var btSendParm= List.new;
//MIDI
var ccRespVsSynth, ccResp;
var synthModif= Array.fill(tracks, [1,1]);
//redEffectsRack: consider using Array of racks in the future, for now - absolute values: 0 - channels 0,1; 2 - channels 2,3
//var rER0, rERG0, rER2, rERG2;

//initial
synthNameList= ["drone", "shake", "fount", "slice", "chop", "stut", "pitch"]; // pitch should always be the last one
ccRespVsSynth= [0, 25, 50, 75, 100, 125]; // should be 1 less than in synthNameList, so that not to touch pitch
//for eobody (changes should be made in mysynths as well)
synthNameList= ["fount", "slice", "chop", "stut", "pitch"]; // pitch should always be the last one
ccRespVsSynth= [0, 60, 90, 125]; // should be 1 less than in synthNameList, so that not to touch pitch

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

w= GUI.window.new("biBeast mini", Rect(412, 500, 545, 400), resizable:false);
w.acceptsMouseOver= true;
w.view.background= Color.new255(205, 201, 165);

//preferences file
"Trying to open presets file...".postln;
try{
	presetsFile= File("preferences/bbeast.dk", "r");
	psetList= presetsFile.readAllString.interpret;
	"OK!".postln;
}{
	("Sorry, cannot open presets file"++String.scDir++"/preferences/bbeast.dk" ++"!").postln;
	"Will be replaced on window close, so please take care of the current file (if any)!".postln;
	presetsFile= nil;
};

// GUI definition
GUI.hLayoutView.new(w, Rect(leftPos+(tracks*granWidth)+5, 2, 2, 500))
	.background_(Color.white);
GUI.hLayoutView.new(w, Rect(leftPos+(tracks*granWidth)+6, 2, 1, 500))
	.background_(Color.grey(alpha:0.7));
//ramp time for changing presets and synths
GUI.staticText.new(w,Rect(leftPos+(tracks*granWidth)+10, 70, 40, 30))
	.string_("ramp time (s)")
	.font_(globalFont1);
slRamp = Slider(w, Rect(leftPos+(tracks*granWidth)+24, 100, 17, 66))
	.knobSize_(0.4)
	.canFocus_(false)
	.value_(timeSpec.unmap(0.5))
	.mouseOverAction_({ |sl|
		stStatusBar.string = timeSpec.map(sl.value).asString ++ "s (ramp time)"
	})
	.action_({ |sl|
		stRamp.string = timeSpec.map(sl.value);
		stStatusBar.string = timeSpec.map(sl.value).asString ++ "s (ramp time)"	});
slRamp.hilightColor= slRamp.background;
stRamp = StaticText.new(w, Rect(leftPos+(tracks*granWidth)+23, 103, 20, 12))
	.font_(globalFont1)
	.align_(\center)
	.stringColor_(Color.white)
	.string_(timeSpec.map(slRamp.value));

// buffer list section
cvBufList= CompositeView(w,Rect(0, 40, 200, 220))
	.background_(ctlColorTransp);
//buffer list
bufferList = PopUpMenu.new(cvBufList,Rect(5, 5, 130, 15))
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
//panic button
btPanic= Button(w, Rect(leftPos+(tracks*granWidth)+20, 40, 30, 30))
	.canFocus_(false)
	.states_([
		[\x, Color.white, btColorPlay],
	])
	.border_(2)
	.value_(0)
	.action_({ |bt|
		tracks.do({ |i|
			btSynthOnOff[i].valueAction_(0); //switch off all grans
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
lvBuffers = ListView.new(cvBufList, Rect(5, 25, 190, 310))
	.canFocus_(false)
	.hiliteColor_(btColorEffColor)
	.beginDragAction_({ |view| dragSrc= 0; currDragFile= view.value }) //0 means file, 1 means synth
	.mouseDownAction_({ arg view, x, y, modifiers, buttonNumber, clickCount;
		// load file to current Gran: -double click; -drag & drop
		var filepath, soundfile, checkBufLoadTask, tmpBuf;
		if(clickCount == 2, { loadFile.value(currGran, view.value) });
	});

//add file(s) button
btAddFile = Button(cvBufList, Rect(5, 340, 55, 18))
	.states_([["add file(s)",Color.black, Color.clear]])
	.font_(globalFont1)
	.action_({ |bt|
		GUI.dialog.getPaths({ |paths|
			loadBuffers.value(paths);
		});
	});
//free file button
btFreeFile = Button(cvBufList, Rect(65, 340, 50, 18))
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
	.visible_(false)
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
cvIntBuf= CompositeView(w,Rect(leftPos+(tracks*granWidth)+10, 180, 55, 230))
	.background_(ctlColorTransp);
// rec busses (mono & stereo)
GUI.staticText.new(cvIntBuf,Rect(0, 17, 37, 15))
	.string_("mn")
	.font_(globalFont1);
monoChList = GUI.popUpMenu.new(cvIntBuf,Rect(13, 16, 37, 15))
	.background_(btColorBG)
	.canFocus_(false)
	.font_(globalFont1)
	.items_(chlistMono)
	.value_(30)
	.action_({ |pm|
		if(synthIn != nil, { synthIn.set(\busnum, pm.value) });

		ampAnalyserSynth.set(\inbus, pm.value);
		tracks.do({ |i|
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
		tracks.do({ |i|
			if(btBufRec[i].value == 1, { recSynth.inbus_(pm.value) })
		});
});
// input volume
rslRecLevel = Slider(cvIntBuf, Rect(13, 50, 10, 87)) //recording level meter
	.visible_(true)
	.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
	.knobSize_(0.01)
	.knobColor_(ctlColor11)
	.canFocus_(false);
grVolInput= Slider(cvIntBuf, Rect(24, 50, 10, 87))
	.hilightColor_(Gradient(btColorPlay, ctlColor10, 12))
	.knobSize_(0.4)
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
grBufLen= Slider(cvIntBuf, Rect(4, 152, 45, 13))
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
	.value_(1);
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
	.hilightColor_(btColorEffColor)
	.knobSize_(0.1)
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

//status bar
stStatusBar= StaticText(w,Rect(slL, w.bounds.height-17, w.bounds.width-210, 15))
	.string_(" ")
	.font_(globalFont2);

// -- buffer pool recording --
// preparation for recording into buffer:
ampAnalFunc = { // this is called on CmdPeriod
	ampAnalyserSynth = Synth(\xiiVuMeter, [\inbus, monoChList.value, \amp, grVolInput.value], addAction:\addToTail);
};
ampAnalFunc.value;
numChannels = 1;

// gran synth ctrls
tracks.do({ |i|
	var trigID= idPad + (i * 2);

	// button - selecting current gran area
	btGranAreaList.add(
		Button(w,Rect(leftPos+(i*granWidth), topPos, granWidth, 45))
			.canFocus_(false) .font_(globalFont3) .value_(0)
			.states_([
				["      ", ctlColorCurr, ctlMainColor2],
				["      ", ctlMainColor2, ctlColorCurr]
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
				tracks.do({ |j|
					if( (btGranAreaList[j].value == 1) && (j != i), { btGranAreaList[j].value = 0 });
				});
				bt.value= 1; // keep current state, at least one looper should be active
				currGran= i;
			})
	);

	//select of the synth in a slot
	pmSynthNames.add(i); // just a number of a synth
	stSynthNames.add(
		StaticText.new(w,Rect(leftPos+(i*granWidth)+5, topPos+12, granWidth, 45))
			.font_(globalFont4)
			.string_(lvGranSynths.items.at(pmSynthNames[i]))
	);
	//label for selecting synth
	stSynthSelect.add(
		StaticText.new(w,Rect(leftPos+(i*granWidth)+5, topPos-7, granWidth, 45))
			.font_(globalFont4)
			.stringColor_(btGranAreaList[i].background)
			.string_(lvGranSynths.items.at(pmSynthNames[i]))
	);


	// gran area
	cvGranArea.add(
		CompositeView(w,Rect(leftPos+(i*granWidth), topPos+45, granWidth, 280))
			.background_(ctlColorTransp)
	);
	// gran 2D slid & waveform area

	//switch synth on
	btSynthOnOff.add(
		Button(w,Rect(leftPos+(i*granWidth)+81, topPos, granWidth*0.35, 45))
			.font_(globalFont3)
			.canFocus_(false)
			.states_([
				[(i+1).asString, btColorPlay, Color.clear],
				[(i+1).asString, btColorOff, btColorPlay]
			])
			.action_({ |bt|
				bt.value.postln;
				synthOnOff.value(i, trigID, bt.value);
			})
	);

	//volume indicator - left channel
	ssGranVolInd.add(
		Slider(cvGranArea[i], Rect(45, 5, 10, 85))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume indicator - right channel
	ssGranVolInd.add(
		Slider(cvGranArea[i], Rect(56, 5, 10, 85))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);

	//volume slider
	grVolList.add(
		Slider(cvGranArea[i], Rect(67, 5, 10, 85))
			.hilightColor_(Gradient(btKnobColor, ctlColor10, 12))
			.background_(Color.gray(alpha:0.01))
			.knobSize_(0.4)
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
		SCUserView(cvGranArea[i], Rect(67, 33, 10, 2))
			.canFocus_(false)
			.background_(Color.black)
	);

	// panorama knob
    knRateList.add(
        Knob(cvGranArea[i], Rect(95, 60, 40, 40))
        .centered_(true)
        .value_(0.5)
        .mouseOverAction_({ |sl|
            stStatusBar.string = round([0.1, 4].asSpec.map(sl.value), 0.01).asString ++ " gran " ++ (i+1) ++ " rate ";
        })
        .action_({ |sl|
            stStatusBar.string = round([0.1, 4].asSpec.map(sl.value), 0.01).asString ++ " gran " ++ (i+1) ++ " rate ";
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


	// slider global button
	grGlobBtList.add(
		Button(cvGranArea[i], Rect(5, 5, 13, 13))
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
						tracks.do({|j| //switch on other record-buttons
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
                                    { this.sendBufferPoolToWidgets }.defer;
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

	// file name
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
		PopUpMenu.new(cvGranArea[i], Rect(80, 70, 42, 20))
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
		SC2DSlider(cvGranArea[i], Rect(3, 160, granWidth-3, granWidth))
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
							});
						});
					});
				});
			})
	);

	// coordinates - X
	grSTxList.add(
		GUI.staticText.new(cvGranArea[i], Rect(
			grslidList[i].bounds.left+grslidList[i].bounds.width-25,
			grslidList[i].bounds.top+grslidList[i].bounds.height-15,
		25, 15 ))
			.font_(globalFont1)
			.string_(0.0);
	);
	// coordinates - Y
	grSTyList.add(
		GUI.staticText.new(cvGranArea[i], Rect( 8, grslidList[i].bounds.top+5, 30, 15 ))
			.font_(globalFont1)
			.string_(0.0);
	);
	//wide panorama ranger
	rsWideRangeList.add(
		RangeSlider(cvGranArea[i], Rect(45, 92, 77, 14))
			.canFocus_(false)
			.lo_(\pan.asSpec.unmap(-0.8))
			.hi_(\pan.asSpec.unmap(0.8))
			.knobColor_(Color.grey(0.5))
			.background_(Color.grey(0.8))
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
	//miscelaneous sliders for panorama range: deviation, average (invisible!)
	slMiscDev.add( Slider(cvGranArea[i], Rect(86, 60, 82, 8)) .visible_(false) );
	slMiscAve.add( Slider(cvGranArea[i], Rect(86, 70, 82, 8)) .visible_(false) );
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


// synth on/off
synthOnOff= { arg curr, trigID, onOff= 1;
	var currBufnum, currBufDur, currSynth;

	if(onOff == 1, {
		// switch it ON
		currBufnum = bufnumList.at(bufTrack[curr]);
		currBufDur = bufDurList.at(bufTrack[curr]);

		currSynth = \bb ++ pmSynthNames[curr].value ++ synthNameList.at(pmSynthNames[curr].value);
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
        // filling out currBufnum is not enough - buffer can be stereo. loadFile cuts the right channel
		loadFile.value(curr, bufTrack[curr], update:false);
	},
	{ // switch it OFF
		if(synthList[curr] != nil, {
			synthList[curr].set(\gate, 0);
			synthList[curr] = nil;
			if( bufTrack[curr].value > 0 , {
				s.cachedBufferAt( bufnumList.at(bufTrack[curr].value) ).clear;
			});
			// volume indicators to 0
			slideEnv.value(ssGranVolInd[curr*2], 1, volSpec.unmap(0.ampdb), 1, 0.1, 2);
			slideEnv.value(ssGranVolInd[curr*2+1], 1, volSpec.unmap(0.ampdb), 1, 0.1, 2);
		});
	});
};


// the volume slider controls start (>0) / end (0) the synth:
volAction= { arg curr, trigID;
	var currBufnum, currBufDur, currSynth;

	if(grVolList[curr].value != 0, {
		// vol is not 0
		if(synthList[curr] != nil, {
			synthList[curr].set(\vol, grVolList[curr].value);
		}, { });
	},
	{ });
};

//pmSynthNames[i].action_
synthNamesAction= ({ |curr|
	var trigID, newSynthName, newSynth, currBufnum, currBufDur, xfadeTask, xfadeTime, currVol;
	newSynthName = \bb ++ pmSynthNames[curr] ++ synthNameList.at(pmSynthNames[curr]);
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
				\gate, 1,
				\frate, synthModif[curr][0],
				\fdur, synthModif[curr][1]
			]);

            // filling out currBufnum is not enough - buffer can be stereo. loadFile cuts the right channel
			loadFile.value(curr, bufTrack[curr], newSynth, false);

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
        });
    }.defer;
}).add;

//keyboard control
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

    // sequences or single keys
    case
    {keycode == 51} {if(psetCurr <= psetNum, { psetList.put(psetCurr, nil); })} // <-|, delete preset
    {keycode == 24} { // plus ("=" actually), add/update preset
        if(psetCurr <= psetNum, {
            saveSettings.value(psetCurr);
        })
    }
    {keycode == 16} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + y - select/deselect all global switches
        tracks.do({ |i|
            grGlobBtList[i].valueAction_(1-grGlobBtList[i].value);
            globSlidList[i] = grGlobBtList[i].value;
        });
    })}
    {keycode == 17} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + t - deselect all 2Dsliders global switches
        tracks.do({ |i|
            grGlobBtList[i].valueAction_(1);
            globSlidList[i] = grGlobBtList[i].value;
        })
    })}
    {keycode == 42} { // "\" (record / stop) & Right Shift + \ (loop record)
        if((modifiers == 131076) || (modifiers == 131332), { btInputLoop.valueAction_(1 - btInputLoop.value) });
        btInputRec.valueAction_(1 - btInputRec.value);
    }
    {(keycode >= 18) && (keycode < 22)} { // 1-4
        tmpVar = keyArr.find([keycode]) - 1; // index
        case
        {(modifiers == 0) || (modifiers == 256)} { // toggle vol (fade-in: exp fast,fade-out: exp slow)
            // if selected granulator is not current, select indicated granulator
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
        {(modifiers == 8388608) || (modifiers == 8388864)} { // Fn + <num> - update fileLists, check last element
            updateFileList.value(fKeyArr.find([keycode]));
        }
        {(modifiers == 262145) || (modifiers == 262401)} { // Ctrl + <num> - launch pattern deconstruction
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
    {keycode == 123} { // previous synth on current track
        stSynthSelect[currGran].stringColor_(Color.red);
        tmpVar = if(lvGranSynths.items.indexOf(stSynthSelect[currGran].string) == 0, { // here - current synth number
            lvGranSynths.items.size-1
        }, {
            lvGranSynths.items.indexOf(stSynthSelect[currGran].string)-1
        });
        stSynthSelect[currGran].string_(lvGranSynths.items[tmpVar]);
    }
    {keycode == 124} { // next synth on current track
        stSynthSelect[currGran].stringColor_(Color.red);
        // here - current synth number
        tmpVar = if(lvGranSynths.items.indexOf(stSynthSelect[currGran].string) == (lvGranSynths.items.size-1), {
            0
        }, {
            lvGranSynths.items.indexOf(stSynthSelect[currGran].string)+1
        });
        stSynthSelect[currGran].string_(lvGranSynths.items[tmpVar]);
    }
    {keycode == 125} { // make selected synth active on current track
        stSynthSelect[currGran].stringColor_(btGranAreaList[currGran].background);
        pmSynthNames[currGran]= lvGranSynths.items.indexOf(stSynthSelect[currGran].string).postln;
        synthNamesAction.value(currGran);
        stSynthNames[currGran].string= stSynthSelect[currGran].string;
    }
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
        // make the previously chosen pre-set into previous state
		psetButtList[psetCurr].value = if(psetList[psetCurr] != nil, { 1 }, { 0 });
	});
	psetButtList[preset].value = 2; // push the button
	psetCurr = preset;
	restoreSettings.value(psetCurr);
};

saveSettings = { |pset|
	var psetSynth, psetCurrList;
	psetCurrList = List.fill(5, nil); // 4 synths + global settings
	tracks.do({ |i|
		psetSynth = Array.fill(20, nil); // settings list of a synth (0-10 in use, 11-19 reserved for future use)
		psetSynth.put(0, synthNameList.at(pmSynthNames[i].value)); // 0 - synth name
		psetSynth.put(1, grChList[i].value); // 1 - buses
		psetSynth.put(2, grslidList[i].x); // 2 - 2D slider X
		psetSynth.put(3, grslidList[i].y); // 3 - 2D slider Y
		psetSynth.put(4, grGlobBtList[i].value); // 4 - global XY
		psetSynth.put(5, grVolList[i].value); // 5 - volume
		psetSynth.put(6, rsWideRangeList[i].lo); // 6 - panorama wide - lo
		psetSynth.put(7, rsWideRangeList[i].hi); // 7 - panorama wide - hi
		psetSynth.put(8, nil); // 8 - vacant
		psetSynth.put(9, stFilename[i].object.asSymbol); // 9 - soundfile
		psetSynth.put(10, nil); // 10 - vacant
		psetSynth.put(11, nil); // 11 - vacant
		psetSynth.put(12, nil); // 12 - vacant
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
	psetSynth.put(10, nil); // 10 - vacant
	psetSynth.put(11, nil); // 11 - vacant
	psetSynth.put(12, nil); // 12 - vacant
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
        bufferList.valueAction_(presetCurrNode[4][9]);
		// prepare to refill global arrays
		globSlidList = Array.fill(4, 0);
		tracks.do({ |i|
			// WARNING!! the order of the updates matters!
			startVol = grVolList[i].value;
			if(startVol == 0, { synthNamesAction.value(currGran) });
			grChList[i].valueAction_(presetCurrNode[i][1]);
			grGlobBtList[i].valueAction_(presetCurrNode[i][4]);
			grslidList[i].activex_(presetCurrNode[i][2]);
			grslidList[i].activey_(presetCurrNode[i][3]);
			grVolList[i].valueAction_(presetCurrNode[i][5]);

			//panorama wide settings
			slMiscDev[i].valueAction_(if(presetCurrNode[i][6].isNil, {0.8}, {presetCurrNode[i][6]}) ); // 6 - deviation
			slMiscAve[i].valueAction_(if(presetCurrNode[i][7].isNil, {0.4}, {presetCurrNode[i][7]}) ); // 7 - average
			rsWideRangeList[i].setDeviation(slMiscDev[i].value, slMiscAve[i].value);
			rsWideRangeList[i].setSpanActive(rsWideRangeList[i].lo, rsWideRangeList[i].hi);
			rsWideRangeList[i].activeLo_(if(presetCurrNode[i][6].isNil, {0.2}, {presetCurrNode[i][6]}) );
			rsWideRangeList[i].activeHi_(if(presetCurrNode[i][7].isNil, {0.8}, {presetCurrNode[i][7]}) );

			stFilename[i].object= lvBuffers.items.indexOf(presetCurrNode[i][9]);
			lvBuffers.items.indexOf()
			presetCurrNode[i][9].asSymbol.postln;

			//switch on the synth
			btSynthOnOff[i].valueAction_(1);

			pmSynthNames[i]= synthNameList.find([presetCurrNode[i][0]]);
			stSynthNames[i].string_(lvGranSynths.items.at(pmSynthNames[i]) );
			synthNamesAction.value(i);
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

tracks.do({ |i|
	loadFile.value(i, i);
});

//MIDI
MIDIClient.init; // intialize the client
13.do({ arg i; MIDIIn.connect(i, MIDIClient.sources.at(i)); });
ccResp = CCResponder({ |src, chan, num, val|
    var panDir, factor;
    var currPitch, currDur;
    [src,chan,num,val].postln;
    case
    { (num >= 48) && (num < 52) } {  // 1-4 gran vol
        { grVolList[num - 48].valueAction_((val/127)**3) }.defer // exp slider
    }
    { num == 58 } {  // current gran factor - TEMPORARY DOUBLING 1
        synthList[currGran].set(\factor, val.linlin(0, 100, 0, 1));

        if(globSlidList[currGran] == 1, {
            tracks.do({ |j|
                if( (globSlidList[j] == 1) && (currGran != j), { synthList[j].set(\factor, val.linlin(0, 100, 0, 1)) });
            });
        });

    }
    { num == 59 } {  // current gran destruct - TEMPORARY DOUBLING 2
        synthList[currGran].set(\destruct, val.linlin(0, 127, 0, 1));
    }
    { num == 5 } {  // x
        { grslidList[currGran].activex_(val.linlin(0, 116, 0, 1)) }.defer
    }
    { num == 1 } {  // gran amp - 1 on eobody
        { grVolList[0].valueAction_(val.linlin(56,68, 0.001,1.000)) }.defer
    }
    { num == 2 } {  // fRate - 2 on eobody, 60 on X-Session
        if(synthList[0] != nil, {
            // 0-40 is [0.1 .. 0.9]; 41-70 is 1; 71-112 is [1.1 .. 2]
            var loLimit= 55, hiLimit= 60, loMIDIsig= 50, hiMIDIsig= 65;
            case
            {val < (loLimit+1)} {
                currPitch= val.linlin(loMIDIsig,loLimit, 0.10,0.90);
                currPitch= currPitch + rrand(currPitch, currPitch*0.25);
            }
            {val > (hiLimit-1)} {
                currPitch= val.linlin(hiLimit,hiMIDIsig, 1.10,2.00);
                currPitch= currPitch + rrand(currPitch, currPitch*0.25);
            }
            {(val > loLimit) && (val < hiLimit)} {
                currPitch=1.00;
            };
            synthList[0].set(\frate, currPitch);
            synthModif[0][0]= currPitch;
        } );
    }
    { num == 3 } {  // 3 on eobody - pitch follower volume
        { grVolList[1].valueAction_(val.linlin(54,66, 0.001,1.000)) }.defer
    }
    { num == 5 } {  // 5 on eobody - gran synth type
        if(ccRespVsSynth.includes(val), {
            {
                pmSynthNames[0]= ccRespVsSynth.indexOf(val);
                synthNamesAction.value(0);
                stSynthNames[0].string= synthNameList[ccRespVsSynth.indexOf(val)];
            }.defer;
        });
    }
    { num == 6 } {  // 6 on eobody - pitch follower XY
        {
            grslidList[1].activey_(val.linlin(0, 106, 0, 1));
            grslidList[1].activex_(val.linlin(0, 106, 0, 1))
        }.defer
    }
    { num == 1 } {  // current gran factor
        synthList[currGran].set(\factor, val.linlin(0, 100, 0, 1));

        if(globSlidList[currGran] == 1, {
            tracks.do({ |j|
                if( (globSlidList[j] == 1) && (currGran != j), { synthList[j].set(\factor, val.linlin(0, 100, 0, 1)) });
            });
        });

    }
    { num == 4 } {  // pitch follower Y
        { grslidList[1].activey_(val.linlin(50, 65, 0.1, 1.0)) }.defer
    }
    { num == 5 } {  // fDur - 61 on X-Session
        if(synthList[currGran] != nil, {
            case // 0-40 is [0.15 .. 0.99]; 41-70 is 1; 71-112 is [1.1 .. 2]
            {val < 41} { currDur= val.linlin(0, 40, 0.15, 0.99); currDur= currDur + rrand(currDur, currDur*0.25) }
            {val > 69} { currDur= val.linlin(70,126, 1.1, 2); currDur= currDur + rrand(currDur, currDur*0.25) }
            {(val >= 41) && (val < 70)} { currDur= 1 };
            synthList[currGran].set(\fdur, currDur);
            synthModif[currGran][1]= currDur;
        } )
    }
    { num == 6 } { // destruct
        synthList[currGran].set(\destruct, val.linlin(0, 127, 0, 1));
        {
            if(val == 60, { sendParam.value(0, 1) });
            if(val == 20, { sendParam.value(0, 0) });
        }.defer
    }
    { num == 3 } {  // y
        { grslidList[0].activey_(val.linlin(0, 127, 0, 1)) }.defer
    }
},
nil, nil, nil, nil
);
//MIDI

w.refresh;
w.front;

w.onClose = {
	SystemClock.clear;

	ampAnalyserSynth.free; // kill the analyser
	responder.remove; // kill the OSC responder

	presetsFile = File.new("preferences/bbeast.dk", "w");
	presetsFile.write(psetList.asCompileString);
	presetsFile.close;
	tracks.do({ |i|
		synthList[i].set(\gate, 0);
	});
	synthIn.free;
	ccResp.remove; //MIDI
};

)