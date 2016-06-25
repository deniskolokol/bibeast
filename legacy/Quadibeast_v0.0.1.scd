

//name - see http://en.wikipedia.org/wiki/List_of_Hulk_supporting_characters
//Bi-Beast - A giant two-headed android living on a floating island in the sky, and containing the knowledge of the bird people that built it.

// Quadibest 0.0.1 (concert version of Bibeast 0.1.1)
//
// keyboard mapping:
// +        5 6 7 8 - Loopers 5-8 choose / start/pause
// + Ctrl + 5 6 7 8 - Loopers 5-8 stop
// + Alt  + 5 6 7 8 - Loopers 5-8 add to global
// + Fn   + 5 6 7 8 - Loopers 5-8 choose last buffer
// +        T Y U I - Loopers 5-8 start/stop rec
// + Fn   + T Y U I - Loopers 5-8 internal buffer
// +        G H J K - Loopers 5-8 playback normal/backward
// +        V B N M - Loopers 5-8 playback loop/one
// + Alt  + V B N M - Loopers 5-8 xfade mode on/off
//
// +        1 2 3 4 - Grans 1-4 choose / on/off
// + Alt  + 1 2 3 4 - Grans 1-4 add to global
// + Ctrl + 1 2 3 4 - Grans 1-4 deconstruct
// + Fn   + 1 2 3 4 - Grans 1-4 choose last buffer
// +        Q W E R - Grans 1-4 start/stop rec
// + Fn   + Q W E R - Grans 1-4 choose 1st buffer
// +        A S D F - Grans 1-4 save internal buffer to file
// +       [`]Z X C - re-map from Z & X to Grans 1-4
//
// MIDI mapping:
// + X-Session:
// ++ buttons:
// +++ 1, 2 - 1st 2 grans on/off
// +++ 4, 5, 6, 7 - Loopers 5-8 start/pause
// +++ 4, 5, 6, 7 dbl click - Loopers 5-8 stop
// ++ knobs
// +++ 52 - 55 - Loopers 5-8 vol
// - I-CubeX
// -- 1 & 2 - curr Loop pitch (0, 1) & (1, 2)

(


var tracks= 4;


var synthList= Array.fill(tracks, nil), channels;
var poolName, pool, poolindex, poolnamesarray;
var tmpBuffer, synthIn;
var w; // main window
var slL=200, slT=450, slW=115, slH=100, hrIndex = 120, granWidth= 125, leftPos=200, topPos= 105;
var globalFont1=Font("Helvetica", 9), globalFont2=Font("Helvetica", 12), globalFont3=Font("Helvetica", 36), globalFont4=Font("Helvetica", 13), globalFont5=Font("Helvetica", 14);
var ctlFocusColor=Color.red(alpha:0.2), ctlMainColor1=Color.new255(205, 138, 138), ctlMainColor2=Color.new255(205, 200, 177), ctlColor10=Color.new255(205, 92, 92, 0.05), ctlColor11=Color.new255(205, 92, 92), ctlColor20=Color.new255(100, 149, 237, 0.6), ctlColor21=Color.new255(70, 130, 180), btColorOff=Color.new255(250, 250, 250), btColorOn=Color.new255(43, 43, 43), btColorPlay=Color.new255(178, 34, 34), btColorStop=Color.new255(238, 216, 174), slidColorProgress=Color.new255(123, 104, 238), btKnobColor=Color.new255(205, 38, 38), btColorBG = Color.new255(248, 248, 255), btColorEffColor=Color.new255(96, 123, 139), ctlMainColorTransp= Color.new255(205, 138, 138, 0.3), stlColorKnob= Color.new255(52,70,83), ctlColorTransp= Color.gray(alpha:0.01), ctlColorCurr= Color.new255(240, 240, 240);
var chlistStereo, chlistMono, bufferList, bufnumList=List.new, monoChList, stereoChList;
var sndNameList=[], bufDurList=List.new;
var btMultichanMode; // stereo / quadro switch
var grSTxList=List.new, grSTyList=List.new, sfViewList=List.new, grslidList=List.new, grVolList=List.new, grVol0= List.new, grChList=List.new, rsWideRangeList= List.new, slMiscDev= List.new, slMiscAve= List.new;
var cvRamp, nbRamp, grVolInput, grBufLen, stBufLen, btInputLoop, btInputRec, rslInputDur, btPlayBuff;
var rampMin= 0.5, rampMax= 10.0; // min and max ramp time
var timeSpec=[0.5, 10, \lin, 0.5, 1, "sec"].asSpec, sec3Spec= [0.5, 3, \lin, 0.5].asSpec, volSpec=ControlSpec(0.ampdb, 4.ampdb, \db, units: " dB"), ampSpec=ControlSpec(0, 2, \lin), dispSpec=[0.5, 0.001, \lin, 0.001].asSpec, radSpec=[0.01, 1, \lin, 0.01].asSpec;
var grGlobBtList=List.new, globSlidList=Array.fill(4, 0);
var cvIntBuf;
var psetNum=40, psetButtList=List.new, psetList=Array.fill(psetNum, nil), psetCurr, psetChange, saveSettings, restoreSettings;
var presetsFile=nil;
var synthNameList, pmSynthNames= List.new, stSynthNames= List.new, stSynthSelect= List.new;


var btGranAreaList= List.new, btGranAreaLabels, cvGranArea= List.new, ssGranVolInd= List.new, stFilename= List.new, btSynthOnOff= List.new;
var cvBufList, lvBuffers, btAddFile, btFreeFile, btSaveBuf, stStatusBar, btPanic;
var currGran, bufTrack= Array.fill(tracks*2, 0);
var volAction, synthNamesAction, synthOnOff;
var currDragFile, idPad= 60; // granulators start from 60


// LOOPER PANEL variables


var loopLeft= leftPos+5+(granWidth*tracks), loopWidth= 100;
var loopColorBg= Color.new255(205, 200, 177), loopColorCurr= Color.new255(240, 240, 240), loopColorTransp= Color.gray(alpha:0.01);
var btLoopAreaList= List.new, btLoopAreaLabels, cvLoopArea= List.new, knLoopPan= List.new, ssLoopVolInd= List.new, ssLoopVol= List.new, btLoopPlayPause= List.new, btLoopStop= List.new, btLoopRec= List.new, pmLoopChList= List.new, nbLoopTrigRamp= List.new, ssLoopPlaybackInd= List.new, cvLoopWaveArea= List.new, sfLoopWave= List.new, slLoopZoom= List.new, btLoopMode= List.new, btLoopStartPos= List.new, btLoopEndPos= List.new, stTimecode= List.new, btLoopClearSel= List.new, btRecMSswitch= List.new, btLoopDir= List.new, btLoopCF= List.new, ssLoopPitch= List.new, stLoopPitchString= List.new, btLoopGlob= List.new;
var btLoopPlayPauseGlob, btLoopStopGlob;


var loopSynthList= Array.fill(tracks, nil);
var idNum= 70; // loopers start from 70
var moveTimeCursor, updateLooperList, clearOnStop, startLoopSynth, convertTime, loadFileLoop;
var indTaskList= [nil, nil, nil, nil], currPosList= [nil, nil, nil, nil], procTaskList= [nil, nil, nil, nil];
var pitchSpec= [0, 2, \lin].asSpec, pitchSpecDisp= [0, 2, \lin, 0.01].asSpec; // pitchSpecDisp is for display
var currLooper, globalLoopList;


var pitchSign, btPitchDef;
var mouseTrackMode= 0; // tracking mouse in XY ctrls from mouseOverAction (0,1)


// LOOPER PANEL variables - end


// -- buffer pool recording --


var ampAnalFunc, ampAnalyserSynth, responder, numChannels, recSynth, secTask, updateFileList, loadBufTask, currRec=4, filename;
var rslRecLevel, tvRecNameList=List.new, stTimeText=List.new, btBufFile=List.new, btBufRec=List.new, bufList=List.new, bufListSelections=List.new;


var loadFile, loadFileList, loadBuffers, getFilePaths, getMonoBuff;


var factorDistrib, sendParam, sndTask= Array.fill(tracks, nil);


//universal procedures


var slideEnv;


var btSendParm= List.new;


//file management


var soundsDir= "/Users/deniskolokol/Music/bibeast/sounds/"; // previously it was "sounds/ixiquarks/"


// keycode arrays


var keyArr= #[29, 18, 19, 20, 21, 23, 22, 26, 28, 25],  // keycodes of numbers 0-9
fKeyArr= #[18, 19, 20, 21, 23, 71, 89, 91], // Fn + keycodes
keys1234= #[18, 19, 20, 21],  // 1-4 keycodes
keys5678= #[23, 22, 26, 28],  // 5-8 keycodes
keys5678Fn= #[23, 71, 89, 91], // Fn + 5-8
keysQWER= #[12, 13, 14, 15],  // Q W E R keycodes
keysASDF= #[0, 1, 2, 3],  // A S D F keycodes
keys_ZXC= #[50, 6, 7, 8],  // ~ Z X C keycodes
keysTYUI= #[17, 16, 32, 34],  // T Y U I keycodes
keysTYUIFn= #[17, 16, 86, 87],  // Fn + T Y U I
keysGHJK= #[5, 4, 38, 40],  // G H J K keycodes
keysVBNM= #[9, 11, 45, 46],  // V B N M keycodes
modifClean= #[0, 256, 10486016, 10485760], // no modifiers
modifCmd= #[11534600, 11534608, 11534344, 11534352], // modifiers - Command
modifCtrl= #[262145, 262401], // modifiers - Control
modifAlt= #[524320, 524576], // modifiers - Alt
modifFn= #[8388608, 8388864, 10485760, 10486016]; // modifiers - Fn


//MIDI


var ccRespVsSynth, ccRespVsSynthSens, ccResp, nOnResp, nOffResp;
var synthModif= Array.fill(tracks, [1,1,1]);
var clickBootSec= Date.getDate.bootSeconds, doubleClick= false, procClick; //MIDI button double click processing


//WIDYMO


var degreeCtrl, ccRespSens, btScaleSynOnOff, pmScaleSynChannel, cvScaleSyn, mslScaleSynSettings;
var labelTop;
var syn= nil, synctl0, synctl1, synctl2, synctl3, synctl4, synctl5;
var switchScaleSyn, setScaleGUI;
var scaleSynSettings= [\freq1, \freq2, \freq3, \fmod1, \fmod2, \fmod3, \fmoda1, \fmoda2, \fmoda3, \pmod1, \pmod2, \pmod3, \amod1, \amod2, \amod3, \amoda1, \amoda2, \amoda3, \smod, \smoda, \smodm, \smodaa, \smodmm, \cmod, \cmoda, \room, \reverb, \damp, \input, \spread, \dry, \early, \tail, \amp];
var synCtrls= Array.fill(scaleSynSettings.size, 0);
var scaleSynSpec= [
	#[20, 10000, \exp, 0, 100],
	#[20, 10000, \exp, 0, 200],
	#[20, 10000, \exp, 0, 300],
	#[0.001, 100, \exp, 0, 0.11],
	#[0.001, 100, \exp, 0, 0.22],
	#[0.001, 100, \exp, 0, 0.33],
	#[0, 100, \lin, 0, 1],
	#[0, 100, \lin, 0, 1],
	#[0, 100, \lin, 0, 1],
	#[0.001, 100, \exp, 0, 0.1],
	#[0.001, 100, \exp, 0, 0.2],
	#[0.001, 100, \exp, 0, 0.3],
	#[0.001, 100, \exp, 0, 0.01],
	#[0.001, 100, \exp, 0, 0.02],
	#[0.001, 100, \exp, 0, 0.03],
	#[0, 10, \lin, 0, 0.05],
	#[0, 10, \lin, 0, 0.05],
	#[0, 10, \lin, 0, 0.05],
	#[0.001, 100, \exp, 0, 0.13],
	#[0, 100, \lin, 0, 5],
	#[0, 100, \lin, 0, 6],
	#[0, 100, \lin, 0, 8],
	#[0, 100, \lin, 0, 50],
	#[0.001, 100, \exp, 0, 1.2],
	#[0, 10, \lin, 0, 0.6],
	#[0, 300, \lin, 1, 20],
	#[0, 30, \lin, 0, 5],
	#[0, 1, \lin, 0, 1],
	#[0, 1, \lin, 0, 0.5],
	#[0, 100, \lin, 0, 25],
	#[0, 1, \lin, 0, 0],
	#[0, 1, \lin, 0, 1],
	#[0, 1, \lin, 0, 1],
	#[0, 1, \lin, 0, 1],
];

synctl0= Synth.new(\krdgAbMin2);
synctl1= Synth.new(\krdgAbMin3);
synctl2= Synth.new(\krdgBMaj2);
synctl3= Synth.new(\krdgBMaj3);
synctl4= Synth.new(\krdgDbMaj2);
synctl5= Synth.new(\krdgDbMaj3);


//WIDYMO

//initial idea
//synthNameList= ["drone", "shake", "fount", "slice", "chop", "stut", "pitch"]; // pitch should always be the last one
//ccRespVsSynth= [0, 25, 50, 75, 100, 125]; // should be 1 less than in synthNameList, so that not to touch pitch
//for eobody (changes should be made in mysynths as well)
synthNameList= ["fount", "stut", "slice", "chop", "shake", "drone", "gendsl", "gendy", "loopst", "pitch"]; // pitch should always be the last one
ccRespVsSynth= [0, 11, 33, 50, 65, 81, 95, 117, 127]; // synths map to MIDI knob/slider (should be 1 less than in synthNameList, so that not to touch pitch)
ccRespVsSynthSens= [0, 30, 65, 90, 110, 125]; // the same but for sensor - only 1st 4 synths

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

w= GUI.window.new("Quadibeast 0.0.1", Rect(265, 500, loopLeft+70+(loopWidth*tracks), 465), resizable:false);
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

// buffer list section



cvBufList= CompositeView(w,Rect(0, topPos, 200, w.bounds.height-40))
	.background_(ctlColorTransp);


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
btSaveBuf = RoundButton(cvBufList, Rect(138, 4, 57, 17))
	.states_([["save buf",Color.black, Color.clear]])
	.font_(GUI.font.new("Helvetica", 9))
	.radius_( 3 )
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
lvBuffers = SCListView.new(cvBufList, Rect(5, 25, 190, 310))
	.canFocus_(false)
	.hiliteColor_(btColorEffColor)
	.beginDragAction_({ |view| currDragFile= view.value }) //0 means file, 1 means synth
	.mouseDownAction_({ arg view, x, y, modifiers, buttonNumber, clickCount;
		// load file to current Gran: -double click; -drag & drop
		// load file to current Looper: -Cmd + dbl click; -drag & drop
		if(clickCount == 2, {
			if((modifiers == 524320) || (modifiers == 524576), { // Alt + dbl click - add to Looper
				loadFile.value(currGran, view.value)
			}, { // dbl click - add to gran
				loadFileLoop.value(currLooper, view.value);
			})
		});
	});

//add file(s) button
btAddFile = RoundButton(cvBufList, Rect(5, 340, 55, 18))
	.states_([["add file(s)",Color.black, Color.clear]])
	.font_(globalFont1)
	.radius_( 3 )
	.action_({ |bt|
		GUI.dialog.getPaths({ |paths|
			loadBuffers.value(paths);
		});
	});
//free file button
btFreeFile = RoundButton(cvBufList, Rect(65, 340, 50, 18))
	.states_([["free",Color.black, Color.clear]])
	.font_(GUI.font.new("Helvetica", 9))
	.radius_( 3 )
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






GUI.hLayoutView.new(w, Rect(loopLeft+(tracks*loopWidth)+5, 2, 2, 500))
	.background_(Color.white);
GUI.hLayoutView.new(w, Rect(loopLeft+(tracks*loopWidth)+6, 2, 1, 500))
	.background_(Color.grey(alpha:0.7));



//ramp time for changing presets and synths
cvRamp= CompositeView(w,Rect(loopLeft+(tracks*loopWidth)+10, 40, 55, 50))
	.background_(ctlColorTransp);



GUI.staticText.new(cvRamp,Rect(0, 0, 80, 15))
	.string_("ramp time (s)")
	.font_(globalFont1);
nbRamp = SCNumberBox.new(cvRamp, Rect(0, 15, 35, 15))
	.font_(globalFont2)
	.canFocus_(false)
	.scroll_(true)
	.scroll_step_(0.5)
	.alt_scale_(0.1)
	.value_(0.5)
	.action_({ |nb|
		if(nb.value > rampMax, { nb.value= rampMax });
		if(nb.value < rampMin, { nb.value= rampMin });
	});



// stereo / quadro switch
btMultichanMode= RoundButton(w,Rect(loopLeft+(tracks*loopWidth)+7, 80, 60, 30))


	.canFocus_(false)
	.font_(globalFont4)
	.states_([
		["stereo", btColorOn, ctlMainColor2],
		["quadro", Color.white, ctlColor21]
	])
	.radius_( 2 )
	.value_(0)
	.action_({ |bt|
		this.executeFile(Archive.archiveDir ++ "/bibsyn" ++ (bt.value*2+2).asString ++".rtf"); //synths



	});


// internal buffer settings



cvIntBuf= CompositeView(w,Rect(loopLeft+(tracks*loopWidth)+7, topPos+144, 55, 230))
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
rslRecLevel = SmoothSlider(cvIntBuf, Rect(13, 50, 10, 87)) //recording level meter
	.visible_(true)
	.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
	.knobSize_(0.01)
	.knobColor_(ctlColor11)
	.canFocus_(false)
	.mode_(\move);
grVolInput= SmoothSlider(cvIntBuf, Rect(24, 50, 10, 87))
	.hilightColor_(Gradient(btColorPlay, ctlColor10, 12))
	.knobSize_(0.4)
	.knobColor_(btKnobColor)
	.canFocus_(false)
	.mode_(\move)
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
btInputLoop= RoundButton(cvIntBuf,Rect(4, 168, 45, 15))
	.font_(globalFont1)
	.canFocus_(false)
	.states_([
		["one", btColorOn, btColorOff],
		["loop", btColorOff, btColorOn]
	])
	.radius_( 3 )
	.value_(1);
//record buffer button
btInputRec = RoundButton(cvIntBuf,Rect(4, 185, 45, 20))
	.canFocus_(false)
	.states_([
		[\record, btColorPlay, btColorStop],
		[\stop, btColorStop, btColorPlay]
	])
	.radius_( 3 )
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
rslInputDur = SmoothSlider(cvIntBuf, Rect(4, 207, 45, 5))
	.knobColor_(btColorEffColor)
	.visible_(false)
	.hilightColor_(btColorEffColor)
	.knobSize_(0.1)
	.canFocus_(false)
	.mode_(\move)
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

// gran synth ctrls
tracks.do({ |i|
	var trigID= idPad + (i * 2);

	// button - selecting current gran area


	btGranAreaList.add(
		RoundButton(w,Rect(leftPos+(i*granWidth), topPos, granWidth, 45))



			.canFocus_(false) .font_(globalFont3) .radius_(3) .border_(0.5) .value_(0)
			.states_([
				["      ", ctlColorCurr, ctlMainColor2],
				["      ", ctlMainColor2, ctlColorCurr]
			])
			.receiveDragHandler_({
				stFilename[i].object= lvBuffers.items.indexOf(currDragFile);
				loadFile.value(i, currDragFile);
			})
			.action_({ |bt|
				var soundfile;
				tracks.do({ |j|
					if( (btGranAreaList[j].value == 1) && (j != i), { btGranAreaList[j].value = 0 });
				});
				bt.value= 1; // keep current state, at least one gran should be active
				currGran= i;
			})
	);



	//select of the synth in a slot
	pmSynthNames.add(i); // just a number of a synth
	stSynthNames.add(
		SCStaticText.new(w,Rect(leftPos+(i*granWidth)+5, topPos+12, granWidth, 45))
			.font_(globalFont4)
			.string_(synthNameList.at(pmSynthNames[i]))
	);

	//label for selecting synth
	stSynthSelect.add(
		SCStaticText.new(w,Rect(leftPos+(i*granWidth)+5, topPos-7, granWidth, 45))
			.font_(globalFont4)
			.stringColor_(Color.red)
			.visible_(false)
			.string_(synthNameList.at(pmSynthNames[i]))
	);






	// gran area



	cvGranArea.add(
		CompositeView(w,Rect(leftPos+(i*granWidth), topPos+45, granWidth, 280))
			.background_(ctlColorTransp)
	);
	// gran 2D slid & waveform area



	//switch synth on
	btSynthOnOff.add(
		RoundButton(w,Rect(leftPos+(i*granWidth)+81, topPos, granWidth*0.35, 45))
			.font_(globalFont3)
			.canFocus_(false)
			.states_([
				[(i+1).asString, btColorPlay, Color.clear],
				[(i+1).asString, btColorOff, btColorPlay]
			])
			.radius_(3)
			.border_(1)
			.action_({ |bt|
				synthOnOff.value(i, trigID, bt.value);
			})
	);

	//volume indicator - left channel
	ssGranVolInd.add(
		SmoothSlider(cvGranArea[i], Rect(45, 5, 10, 85))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume indicator - right channel
	ssGranVolInd.add(
		SmoothSlider(cvGranArea[i], Rect(56, 5, 10, 85))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);

	//volume slider
	grVolList.add(
		SmoothSlider(cvGranArea[i], Rect(67, 5, 10, 85))
			.hilightColor_(Gradient(btKnobColor, ctlColor10, 12))
			.background_(Color.gray(alpha:0.01))
			.knobSize_(0.4)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.mode_(\move)
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
		SCUserView(cvGranArea[i], Rect(67, (grVolList[i].bounds.top + grVolList[i].bounds.height)*0.5, 10, 2))
			.canFocus_(false)
			.background_(Color.black)
	);

	// slider global button
	grGlobBtList.add(
		RoundButton(cvGranArea[i], Rect(5, 5, 13, 13))
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
		RoundButton(cvGranArea[i], Rect(5, 51, 30, 16))
			.font_(globalFont1)
			.states_([ [\document, btColorOn, btColorStop] ])
			.radius_(3)
			.action_({ |butt|
				var file, f, buffer;

				filename = tvRecNameList[i].string;
				if(filename == "", {
					filename = "Track" ++ (i+1).asSymbol ++ "_" ++ Date.getDate.stamp.asString;
				});
				file = soundsDir ++ filename ++ ".aif";

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
		RoundButton(cvGranArea[i],Rect(5, 33, 30, 16))
			.font_(globalFont1)
			.states_([
				[\clock, btColorOn, ctlColor10],
				[\clock, Color.white, btColorOn]
			])
			.radius_(3)
			.border_(2)
			.action_({ |bt|
				sendParam.value(i, bt.value)
			})
	);

	//buffer pool record button
	btBufRec.add(
		RoundButton(cvGranArea[i],Rect(5, 71, 30, 18))
			.canFocus_(false)
			.states_([
				[\record, btColorPlay, btColorStop],
				[\stop, btColorStop, btColorPlay]
			])
			.radius_( 3 )
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
						recSynth.start(soundsDir ++ filename ++ ".aif");
						recSynth.setAmp_(grVolInput.value);
						secTask.start;
					}, {
						butt.inverse_(false);
						tracks.do({|j| //switch on other record-buttons
							btBufRec[j].enabled_(true);
						});
						recSynth.stop;
						secTask.stop;
						file = soundsDir ++ filename ++ ".aif";
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

	// file name
	stFilename.add(
		DragBoth(cvGranArea[i], Rect(2, 108, granWidth-4, 50))
			.background_(ctlMainColor1.alpha_(0.3))
			.align_(\left)
			.object_("")
			.beginDragAction_({ |obj| currDragFile= lvBuffers.items.indexOf(obj.object.asString) }) //0 is file, 1 is synth
			.receiveDragHandler_({ |obj|
				obj.object= lvBuffers.items.indexOf(currDragFile);
				loadFile.value(i, currDragFile);
			})
	);

	// output channel dropdown list
	grChList.add(
		SCPopUpMenu.new(cvGranArea[i], Rect(80, 70, 42, 20))
			.items_(chlistMono)
			.background_(btColorBG)
			.canFocus_(false)
			.font_(globalFont2)
			.action_({
				if(synthList[i] != nil, { synthList[i].set(\busnum, grChList[i].value) });
			})
	);

	//waveshape
	sfViewList.add(
		SCSoundFileView.new(cvGranArea[i],Rect(3, 160, granWidth-3, granWidth))
			.drawsWaveForm_(true)
			.gridOn_(true)
			.gridResolution_(1)
			.gridColor_(Color.white)
			.waveColors_([ btKnobColor, ctlMainColor1 ])
			.background_(ctlMainColor2)
			.canFocus_(false)
	);
	// 2D slider
	grslidList.add(
		SC2DSlider(cvGranArea[i], Rect(3, 160, granWidth-3, granWidth))


			.background_(ctlMainColorTransp)


			.knobColor_(slidColorProgress)
			.x_(0.0)
			.y_(0.0)
			.canFocus_(false)
			.mouseDownAction_({ arg sl, x, y, modifiers, buttonNumber, clickCount;
				if(clickCount == 2, {
					if((modifiers == 0) || (modifiers == 256), { // just double click left button
						mouseTrackMode= 1 - mouseTrackMode;
						tracks.do({ |j|
							grslidList[j].knobColor_(Color.new255(123-(mouseTrackMode*123), 104-(mouseTrackMode*104), 238-(mouseTrackMode*238)));
						});
					})
				});
			})
			.mouseOverAction_({ |sl, x, y|
				stStatusBar.string = "x " ++ round(sl.x * 100, 0.1).asString ++ ";   y " ++ round(sl.y * 100, 0.1).asString ++ "   gran" ++ (i+1).asString;
				if(mouseTrackMode == 1, {
					sl.activex_(x.linlin(0, sl.bounds.width, 0,1));
					sl.activey_(y.linlin(0, sl.bounds.height, 1,0));
				});
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
		SCRangeSlider(cvGranArea[i], Rect(45, 92, 77, 14))
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
	slMiscDev.add( SCSlider(cvGranArea[i], Rect(86, 60, 82, 8)) .visible_(false) );
	slMiscAve.add( SCSlider(cvGranArea[i], Rect(86, 70, 82, 8)) .visible_(false) );
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
		loadFile.value(curr, bufTrack[curr], update:false); // filling out currBufnum is not enough - buffer can be stereo. loadFile cuts the right channel
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
			synthList[curr].set(\vol, ampSpec.map(grVolList[curr].value));
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

			xfadeTime = nbRamp.value;
			currVol = grVolList[curr].value;

			//creating new synth with initial volume 0
			newSynth = Synth.new(newSynthName, [
				\busnum, grChList[curr].value,
				\bufnum, currBufnum,
				\bufdur, currBufDur,
				\ax, grslidList[curr].x, \ay, grslidList[curr].y,
				\panidx, rsWideRangeList[curr].hi-rsWideRangeList[curr].lo,
				\panshift, \pan.asSpec.map([rsWideRangeList[curr].lo, rsWideRangeList[curr].hi].mean),
				\vol, currVol,
				\trigID, trigID,
				\gate, 1,
				\frate, synthModif[curr][0],
				\fdur, synthModif[curr][1],
				\modf, synthModif[curr][2],
				\att, xfadeTime,
				\crva, 2
			]);



			// filling out currBufnum is not enough - buffer can be stereo. getMonoBuff cuts the right channel
			getMonoBuff.value(curr, bufTrack[curr], newSynth);



			//now cross-fading volumes of the current synth and new one
			synthList[curr].set(\rel, xfadeTime, \crvr, -2);
			xfadeTask = Task.new({ |time|
				(xfadeTime+0.01).wait; // wait before kill the old synth
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

factorDistrib= { arg cur, switchOn;
	var rp, backTask, tmpVar, j= 1;


	rp = RedPerlin.new;
	switch( switchOn,
		false, { // switching it off
			procTaskList[cur].stop; procTaskList[cur]= nil;


			backTask= Task.new({ |time|
				10.do({ |j|


					synthList[cur].set(\factor, 0);



					0.1.wait;
				});
			}).start;


		},
		true, { // switching on
			if(procTaskList[cur].isNil, {


				rp.spook= rrand(5,15);
				procTaskList[cur]= Task({
					{
						tmpVar= abs(rp.noise1D(sin(j/100) + cos(j/100), 0.75, 9, 1));
						{ if(synthList[cur] != nil, { synthList[cur].set(\factor, tmpVar) } )}.defer;
						j= j+1;
						tmpVar.linexp(0, 1.5, 0.5, 0.05).wait;
					}.loop
				}).start;



			});


		}
	);


};

// -- buffer pool recording --
// OSC responder for rec levels
responder = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
	{
	w.isClosed.not.if({ // if window is not closed, update GUI...
		if (msg[1] == ampAnalyserSynth.nodeID, {
			rslRecLevel.value_( (1-(msg[3].ampdb.abs * 0.01)) * grVolInput.value );
		});

		if((msg[2]-idPad >= 0) && (msg[2] <= (idPad+(tracks*2))), { // tracks*2 - for 2 indicators per each gran (L & R)
			ssGranVolInd.at(msg[2]-idPad).value_(1-(msg[3].ampdb.abs * 0.01))
		});
// LOOPER PANEL
		if((msg[2]-idNum >= 0) && (msg[2] <= (idNum+(tracks*2))), { // tracks*2 - for 2 indicators per each looper (L & R)
			ssLoopVolInd.at(msg[2]-idNum).value_(1-(msg[3].ampdb.abs * 0.01))
		});
// LOOPER PANEL end
	});
	}.defer;
}).add;

//keyboard control
w.view.keyUpAction = { arg view, char, modifiers, unicode, keycode;
	var tmpVar;


	if( keys_ZXC.includes(keycode), { // ~ z x c
		tmpVar = keys_ZXC.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers - Perlin randomizator for synth factor
				factorDistrib.value(tmpVar, false);
			}
	});




};



w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	var tmpVar;
	[modifiers, unicode, keycode].postln;



// LOOPER PANEL keys
	if( keys5678.includes(keycode), { // 5 6 7 8
		tmpVar = keys5678.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers
				if(btLoopAreaList[tmpVar].value != 1, { // if selected looper is not current, select indicated looper
					btLoopAreaList[tmpVar].valueAction_(1)
				}, { // otherwise start/pause
					btLoopPlayPause[tmpVar].valueAction_(1-btLoopPlayPause[tmpVar].value)
				})
			}
			{ modifCtrl.includes(modifiers) } { // Ctrl + 5 6 7 8 - playback stop on current looper
				btLoopStop[tmpVar].valueAction_(1)
			}
			{ modifAlt.includes(modifiers) } { // Alt + 5 6 7 8 - check/uncheck global switch on current looper
				btLoopGlob[tmpVar].valueAction_(1-btLoopGlob[tmpVar].value);
			}
	});
	if( keys5678Fn.includes(keycode), { // Fn + 5 6 7 8 - update fileLists, select last buffer
		tmpVar = keys5678Fn.indexOf(keycode);
		if( modifFn.includes(modifiers), {
			updateLooperList.value(tmpVar);
		});
	});
	if( keysTYUI.includes(keycode), { // t y u i
		tmpVar = keysTYUI.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers
				btLoopRec[tmpVar].valueAction_(1-btLoopRec[tmpVar].value)
			}
	});
	if( keysTYUIFn.includes(keycode), { // Fn + t y u i - select 1st buffer (internal)
		tmpVar = keysTYUIFn.indexOf(keycode);
		if( modifFn.includes(modifiers), {
			loadFileLoop.value(tmpVar, 0);
		});
	});
	if( keysGHJK.includes(keycode), { // g h j k
		tmpVar = keysGHJK.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers - switch playback normal/backward
				btLoopDir[tmpVar].valueAction_(1-btLoopDir[tmpVar].value)
			}
	});
	if( keysVBNM.includes(keycode), { // v b n m
		tmpVar = keysVBNM.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers - switch playback mode loop/one on loopers 5-8
				btLoopMode[tmpVar].valueAction_(1-btLoopMode[tmpVar].value)
			}
			{ modifAlt.includes(modifiers) } { // Alt + v b n m - cross-fade mode of loopers 5-8
				btLoopCF[tmpVar].valueAction_(1-btLoopCF[tmpVar].value);
			}
	});
	// for current looper
	case
		{keycode == 25} { btLoopStartPos[currLooper].valueAction_(1) }  // 9 | start pos | of curr looper
		{keycode == 29} { btLoopEndPos[currLooper].valueAction_(1) }    // 0 |  end pos  |
		{keycode == 27} { btLoopClearSel[currLooper].valueAction_(1) }  //"-"| clear sel |
		{keycode == 44} { //"/" - pitch to default
			slideEnv.value(ssLoopPitch[currLooper], ssLoopPitch[currLooper].value, pitchSpec.unmap(1), 0.2, 0.01, 3);
		};
// LOOPER PANEL end

// GRAN PANEL
	if( keys1234.includes(keycode), { // 1 2 3 4
		tmpVar = keys1234.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers
				if(btGranAreaList[tmpVar].value != 1, {
					btGranAreaList[tmpVar].valueAction_(1)
				}, { // otherwise on/off current granulator
					btSynthOnOff[tmpVar].valueAction_(1-btSynthOnOff[tmpVar].value)
				})
			}
			{ modifCtrl.includes(modifiers) } { // Ctrl + 1 2 3 4 - launch/stop pattern deconstruction
				btSendParm[tmpVar].valueAction_(1-btSendParm[tmpVar].value);
			}
			{ modifAlt.includes(modifiers) } { // Alt + 1 2 3 4 - global switch on current granulator
				grGlobBtList[tmpVar].valueAction_(1-grGlobBtList[tmpVar].value);
			}
			{ modifFn.includes(modifiers) } { // Fn + 1 2 3 4 - update fileLists, check last element
				updateFileList.value(tmpVar);
			}
	});
	if( keysQWER.includes(keycode), { // q w e r
		tmpVar = keysQWER.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers - individual record
				btBufRec[tmpVar].valueAction_(1-btBufRec[tmpVar].value)
			}
			{ modifFn.includes(modifiers) } { // Fn + q w e r - select 1st buffer (internal)
				loadFile.value(tmpVar, 0);
			}
	});
	if( keysASDF.includes(keycode), { // a s d f
		tmpVar = keysASDF.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers - save internal buffer to file
				if(btBufFile[tmpVar].enabled == true, { btBufFile[tmpVar].valueAction_(1) })
			}
	});
	if( keys_ZXC.includes(keycode), { // ~ z x c
		tmpVar = keys_ZXC.indexOf(keycode);
		case
			{ modifClean.includes(modifiers) } { // no modifiers - Perlin randomizator for synth factor
				factorDistrib.value(tmpVar, true); // true until keyUpAction
			}
	});
// GRAN PANEL - end

// sequences or single keys
	case
		{keycode == 51} {if(psetCurr <= psetNum, { psetList.put(psetCurr, nil); })} // <-|, delete preset
		{keycode == 24} { // plus ("=" actually), add/update preset
			if(psetCurr <= psetNum, {
				saveSettings.value(psetCurr);
			})
		}
		{keycode == 16} {if( modifAlt.includes(modifiers), { // Alt + y - select/deselect all global switches
			tracks.do({ |i|
				grGlobBtList[i].valueAction_(1-grGlobBtList[i].value);



				globSlidList[i] = grGlobBtList[i].value;


			});



		})}


		{keycode == 17} {if( modifAlt.includes(modifiers), { // Alt + t - select all 2Dsliders global switches
			tracks.do({ |i|
				grGlobBtList[i].valueAction_(1);
				globSlidList[i] = grGlobBtList[i].value;



			})
		})}


		{keycode == 42} { // "\" (record / stop) & Right Shift + \ (loop record)
			if((modifiers == 131076) || (modifiers == 131332), { btInputLoop.valueAction_(1 - btInputLoop.value) });
			btInputRec.valueAction_(1 - btInputRec.value);
		}
		//[up, down, left right]
		{keycode == 123} { // [<-] previous synth on current track
			//[<-] previous synth on current track
			if(modifClean.includes(modifiers), {
				stSynthSelect[currGran].visible_(true);
				tmpVar = if(synthNameList.indexOf(stSynthSelect[currGran].string) == 0, { // here - current synth number
						synthNameList.size-1
					}, {
						synthNameList.indexOf(stSynthSelect[currGran].string)-1
					});
				stSynthSelect[currGran].string_(synthNameList[tmpVar]);
			});
			//cmd + [<-] - prev buffer on current track
			if(modifCmd.includes(modifiers), {
				tmpVar= bufTrack[currGran]; // the number of current buffer
				if(tmpVar == 0, { // current buffer is 'internal buffer'
					updateFileList.value(currGran); // in this case "next" means "last" one
				},{
					loadFile.value(currGran, tmpVar-1); // previous buffer
				});
			});



		}


		{keycode == 124} {
			//[->] next synth on current track
			if(modifClean.includes(modifiers), {
					stSynthSelect[currGran].visible_(true);
					tmpVar = if(synthNameList.indexOf(stSynthSelect[currGran].string) == (synthNameList.size-1), { // here - current synth number
							0
						}, {
							synthNameList.indexOf(stSynthSelect[currGran].string)+1
						});
					stSynthSelect[currGran].string_(synthNameList[tmpVar]);
			});
			//cmd + [->] - next buffer on current gran
			if(modifCmd.includes(modifiers), {
				tmpVar= bufTrack[currGran]; // the number of current buffer
				if(tmpVar == (lvBuffers.items.size-1), { // current buffer is the last one
					loadFile.value(currGran, 0); // in this case "next" means the "first" one ('internal buffer')
				},{
					loadFile.value(currGran, tmpVar+1); // next buffer
				});
			});



		}


		{keycode == 125} {
			// [down] make selected synth active on current track
			if(modifClean.includes(modifiers), {
				stSynthSelect[currGran].visible_(false);
				pmSynthNames[currGran]= synthNameList.indexOf(stSynthSelect[currGran].string);
				if(synthList[currGran] != nil, { synthNamesAction.value(currGran) });
				stSynthNames[currGran].string= stSynthSelect[currGran].string;
			});
			//cmd + [down] - next buffer on current looper
			if(modifCmd.includes(modifiers), {
				tmpVar= bufTrack[currLooper+tracks]; // the number of current buffer
				if(tmpVar == (lvBuffers.items.size-1), { // current buffer is the last one
					loadFileLoop.value(currLooper, 0); // in this case "next" means the "first" one ('internal buffer')
				},{
					loadFileLoop.value(currLooper, tmpVar+1); // next buffer
				});


				if(btLoopPlayPause[currLooper].value == 1, {
					btLoopStop[currLooper].valueAction_(1); //stop current buffer playback
					btLoopPlayPause[currLooper].valueAction_(1); //start new buffer playback


				})
			});




		}


		{keycode == 126} {
			// [up] cancel selection of the synth
			if(modifClean.includes(modifiers), {
				stSynthSelect[currGran].string= stSynthNames[currGran].string;
				stSynthSelect[currGran].visible_(false);
			});
			//cmd + [up] - prev buffer on current looper
			if(modifCmd.includes(modifiers), {
				tmpVar= bufTrack[currLooper+tracks]; // the number of current buffer
				if(tmpVar == 0, { // current buffer is 'internal buffer'
					updateLooperList.value(currLooper); // in this case "next" means "last" one
				},{
					loadFileLoop.value(currLooper, tmpVar-1); // previous buffer
				});


				if(btLoopPlayPause[currLooper].value == 1, {
					btLoopStop[currLooper].valueAction_(1); //stop current buffer playback
					btLoopPlayPause[currLooper].valueAction_(1); //start new buffer playback
				})


			});



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

getMonoBuff= { arg currTrack, currBuf, currSynth;
var filepath, soundfile, tmpBuf, checkBufLoadTask;


	if(try { XQ.globalBufferDict.at(poolName)[0] } != nil, {
		bufTrack[currTrack]= currBuf;
		XQ.globalBufferDict.at(poolName)[0][currBuf-1].postln;
		if(try {filepath = XQ.globalBufferDict.at(poolName)[0][currBuf-1].path} != nil, {
			//filepath = XQ.globalBufferDict.at(poolName)[0][currBuf-1].path; // the 1st buffer is always internal
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
		});
	});


};



loadFile= { arg currTrack, currBuf, currSynth, update= true;
	var filepath, soundfile, checkBufLoadTask, tmpBuf;
	// first assume that it is internal buffer which is added
	stFilename[currTrack].object_(lvBuffers.items[0]);
	bufTrack[currTrack]= 0;

	// first we presume it's internal buffer
	btBufFile[currTrack].enabled_(true); // which can be saved to a file
	if(update == true, { sfViewList[currTrack].drawsWaveForm_(false) }); // and doesn't have a wave shape

	if(synthList.at(currTrack) != nil, {
		synthList.at(currTrack).set(\bufnum, tmpBuffer.bufnum, \bufdur, tmpBuffer.numFrames/tmpBuffer.sampleRate); // set internal buffer
	});
	// but can be some real file as well - need to check
	if( currBuf != 0, {
		if(try { XQ.globalBufferDict.at(poolName)[0] } != nil, {
			stFilename[currTrack].object_(lvBuffers.items[currBuf]);

			bufTrack[currTrack]= currBuf;
			filepath = XQ.globalBufferDict.at(poolName)[0][currBuf-1].path; // the 1st buffer is always internal
			btBufFile[currTrack].enabled_(false); // buffer cannot be saved to a file
			soundfile = SoundFile.new;
			soundfile.openRead(filepath);
			if(soundfile.numChannels == 2, {
				tmpBuf = Buffer.readChannel(s, filepath, channels: [0]); //if it's stereo, read only left channel
			}, {
				tmpBuf = Buffer.read(s, filepath);
			});

			if(update == true, {
				sfViewList[currTrack].drawsWaveForm_(true);
				sfViewList[currTrack].soundfile_(soundfile);

				if(soundfile.numFrames <= (soundfile.sampleRate*60), { // soundfile is less than minute
					sfViewList[currTrack].read(0, soundfile.numFrames);				}, {
					sfViewList[currTrack].readWithTask(0, soundfile.numFrames);
				});
				sfViewList[currTrack].selectionDuration(0);
				sfViewList[currTrack].refresh;
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
		});
	});
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
		RoundButton(w,Rect(
				3+((if(i<(psetNum/2), {i}, {i-(psetNum/2)}))*25),
				2+((if(i<(psetNum/2), {0}, {1}))*25),
				25, 25 )
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
	psetSynth.put(6, nbRamp.value); // 6 - swith pre-set ramp time
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
		nbRamp.valueAction_(presetCurrNode[4][6]);
		grBufLen.valueAction_(sec3Spec.unmap(presetCurrNode[4][8]));
		//bufferList.valueAction_(presetCurrNode[4][9]); // decide what to do with buffer
		// prepare to refill global arrays


		globSlidList = Array.fill(4, 0);


		tracks.do({ |i|
			// WARNING!! the order of the updates matters!
			startVol = grVolList[i].value;
			grChList[i].valueAction_(presetCurrNode[i][1]);


			grGlobBtList[i].valueAction_(presetCurrNode[i][4]);



			grslidList[i].activex_(presetCurrNode[i][2]);
			grslidList[i].activey_(presetCurrNode[i][3]);


			grVolList[i].valueAction_(presetCurrNode[i][5]);



			//panorama wide settings
			rsWideRangeList[i].activeLo_(if(presetCurrNode[i][6].isNil, {0.2}, {presetCurrNode[i][6]}) );
			rsWideRangeList[i].activeHi_(if(presetCurrNode[i][7].isNil, {0.8}, {presetCurrNode[i][7]}) );
			//bookmark - ERROR HERE!!!
			//stFilename[i].object= lvBuffers.items.indexOf(presetCurrNode[i][9]);
			//lvBuffers.items.indexOf()
			btSynthOnOff[i].valueAction_(1); //switch on the synth




			pmSynthNames[i]= synthNameList.find([presetCurrNode[i][0]]);
			stSynthNames[i].string_(synthNameList.at(pmSynthNames[i]) );


			if(synthList[i] != nil, { synthNamesAction.value(i) });
		});
	});
};




// LOOPER PANEL

globalLoopList=Array.fill(tracks, 0);

tracks.do({ |i|


	var trigID= idNum + (i * 2);

	// looper area


	cvLoopArea.add(
		CompositeView(w,Rect(loopLeft+(i*loopWidth), topPos+45, loopWidth, 158))
			.background_(loopColorTransp)
	);
	// waveform area
	cvLoopWaveArea.add(
		CompositeView(w,Rect(loopLeft+3, topPos+205, loopWidth*5+(loopWidth/2), 150))
			.background_(loopColorTransp)
	);
	// waveform
	sfLoopWave.add(
		SCSoundFileView.new(cvLoopWaveArea[i], Rect(0, 20, loopWidth*tracks-2, 85))
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
		GUI.slider2D.new(cvLoopWaveArea[i], Rect(0, 105, loopWidth*tracks-2, 44)) // scroll w/zoom x
			.canFocus_(false)
			.knobColor_(Color.red(alpha:0.5))
			.action_({ |sl|
				var y;
				try{
					sfLoopWave[i].zoomToFrac(y = sl.y * 0.95 + 0.05);
					sfLoopWave[i].scrollTo(sl.x);
				};
			})
			.y_(1).x_(0.5);
	);

	// startLoop button
	btLoopStartPos.add(
		RoundButton(cvLoopWaveArea[i], Rect(0, 0, 63, 13))
			.font_(globalFont1)
			.background_(loopColorCurr)
			.canFocus_(false)
			.states_([
				["start pos", btColorOn, ctlColor10],
			])
			.radius_(3)
			.border_(1)
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
		RoundButton(cvLoopWaveArea[i], Rect(66, 0, 63, 13))
			.font_(globalFont1)
			.background_(loopColorCurr)
			.canFocus_(false)
			.states_([
				["end pos", btColorOn, ctlColor10],
			])
			.radius_(3)
			.border_(1)
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
		RoundButton(cvLoopWaveArea[i], Rect(130, 0, 63, 13))
			.font_(globalFont1)
			.background_(loopColorCurr)
			.canFocus_(false)
			.states_([
				["clear sel", btColorOn, ctlColor10],
			])
			.radius_(3)
			.border_(1)
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

	// button - selecting current looper


	btLoopAreaList.add(


		RoundButton(w,Rect(loopLeft+(i*loopWidth), topPos, loopWidth, 45))
			.canFocus_(false) .font_(globalFont3) .radius_(3) .border_(0.5) .value_(0)
			.states_([
				["       " ++ (i+1+tracks).asString, loopColorCurr, loopColorBg],
				["       " ++ (i+1+tracks).asString, loopColorBg, loopColorCurr]
			])



			.receiveDragHandler_({
				stFilename[i+tracks].object= lvBuffers.items.indexOf(currDragFile);
				loadFileLoop.value(i, currDragFile);
			})


			.action_({ |bt|
				tracks.do({ |j|
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
		SmoothSlider(w, Rect(loopLeft+(i*loopWidth)+2, topPos+38, loopWidth-5, 5))
			.knobColor_(btColorEffColor)
			.visible_(false)
			.hilightColor_(btColorEffColor)
			.knobSize_(0.1)
			.canFocus_(false)
			.mode_(\move)
			.value_(0);
	);
	//timecode string
	stTimecode.add(
		GUI.staticText.new(w, Rect(loopLeft+(i*loopWidth)+2, topPos+20, 60, 17))
			.font_(globalFont5)
			.string_("")
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
		SmoothSlider(cvLoopArea[i], Rect(42, 5, 10, 85))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume indicator - right channel
	ssLoopVolInd.add(
		SmoothSlider(cvLoopArea[i], Rect(53, 5, 10, 85))
			.hilightColor_( Gradient( Color.red.alpha_(0.9), Color.green.alpha_(0.8), \v ) )
			.knobSize_(0.1)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.value_(volSpec.unmap(0.ampdb))
	);
	//volume slider
	ssLoopVol.add(
		SmoothSlider(cvLoopArea[i], Rect(64, 5, 10, 85))
			.background_(Color.gray(alpha:0.01))
			.hilightColor_(Gradient(btKnobColor, ctlColor10, 12))
			.knobSize_(0.4)
			.knobColor_(btKnobColor)
			.canFocus_(false)
			.mode_(\move)
			.value_(volSpec.unmap(0))
			.mouseOverAction_({ |sl|
				stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " loop " ++ (i+1) ++ " vol ";
			})
			.action_({ |sl|
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\vol, ampSpec.map(sl.value)) });
				stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " loop " ++ (i+1) ++ " vol ";

				if(globalLoopList[i] == 1, {
					tracks.do({ |j|
						if( (globalLoopList[j] == 1) && (i != j), {
							ssLoopVol[j].value= sl.value;
							if(loopSynthList[j] !=nil, { loopSynthList[j].set(\vol, ampSpec.map(ssLoopVol[j].value)) });
						});
					});
				});
			})
	);
	// slider limiter
	grVol0.add(
		SCUserView(cvLoopArea[i], Rect(64, (ssLoopVol[i].bounds.top + ssLoopVol[i].bounds.height)*0.5, 10, 2))
			.canFocus_(false)
			.background_(Color.black)
	);

	// start/pause button
	btLoopPlayPause.add(
		RoundButton(cvLoopArea[i], Rect(5, 35, 30, 18))
			.canFocus_(false)
			.states_([
				[\play, btColorOn, ctlColor10],
				[\pause, btColorPlay, loopColorCurr]
			])
			.radius_(3)
			.border_(2)
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
		RoundButton(cvLoopArea[i], Rect(5, 53, 30, 15))
			.canFocus_(false)
			.states_([
				[\stop, btColorOn, ctlColor10],
			])
			.radius_(3)
			.border_(2)
			.value_(0)
			.action_({
				moveTimeCursor.value(i, 0, 0, 0, -1);
			})
	);
	// record button
	btLoopRec.add(
		RoundButton(cvLoopArea[i], Rect(5, 71, 30, 18))
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
						tracks.do({|j| //switch off all other recording
							btBufRec[j].enabled_(false);
							if(j != i, {
								btLoopRec[j].enabled_(false);
							})
						});
						currRec = i+tracks; // for the purpose of update time text only for the current looper

						filename = tvRecNameList[i].string;
						if(filename == "", {
							filename = "Track" ++ (i+3).asSymbol ++ "_" ++ Date.getDate.stamp.asString;						});

						if(btRecMSswitch[i].value == 0, { // record from mono bus
							recSynth = XiiRecord(s, monoChList.value, 1, sampleFormat: XQ.pref.bitDepth);
						}, { // record from stereo bus
							recSynth = XiiRecord(s, stereoChList.value*2, 2, sampleFormat: XQ.pref.bitDepth);
						});
						recSynth.start(soundsDir ++ filename ++ ".aif");
						recSynth.setAmp_(grVolInput.value);
						secTask.start;
					}, {
						butt.inverse_(false);
						tracks.do({|j| //switch on other record-buttons
							btBufRec[j].enabled_(true);
							btLoopRec[j].enabled_(true);
						});
						recSynth.stop;
						secTask.stop;
						file = soundsDir ++ filename ++ ".aif";
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
								{
									if(btLoopPlayPause[i].value == 1, {
										btLoopStop[i].valueAction_(1); //stop current buffer playback
										btLoopPlayPause[i].valueAction_(1); //start new buffer playback
									})
								}.defer;
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
		RoundButton(cvLoopArea[i], Rect(79, 5, 13, 13))
			.states_([
				["", Color.black, ctlMainColor2],
				["", Color.black, ctlColor11]
			])
			.value_(0)
			.canFocus_(false)
			.border_(0.7)
			.extrude_(false)
			.action_({ |bt|
				globalLoopList[i] = bt.value;
			});
	);
	// mono/stereo rec button
	btRecMSswitch.add(
		RoundButton(cvLoopArea[i], Rect(75, 20, 20, 13))
			.canFocus_(false)
			.font_(globalFont1)
			.states_([
				["mn", btColorOn, ctlMainColor2],
				["st", Color.white, ctlColor21],
			])
			.radius_(3)
			.border_(1)
			.value_( if(i < 1, {0}, {1}) )
	);
	// dir button
	btLoopDir.add(
		RoundButton(cvLoopArea[i], Rect(75, 34, 20, 18))
			.canFocus_(false)
			.font_(globalFont1)
			.states_([
				["rev", btColorOn, btColorOff],
				["rev", btColorOff, btColorOn]
			])
			.radius_(3)
			.border_(1)
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
		RoundButton(cvLoopArea[i], Rect(75, 53, 20, 18))
			.canFocus_(false)
			.states_([
				[\roundArrow, btColorOn, btColorOff],
				[\lineArrow, btColorOff, btColorOn]
			])
			.radius_(3)
			.border_(1)
			.value_(0)
			.action_({ |bt|
				if(loopSynthList[i] !=nil, { loopSynthList[i].set(\loop, 1-bt.value) });
			})
	);
	// cross-fade button
	btLoopCF.add(
		RoundButton(cvLoopArea[i], Rect(75, 72, 20, 18))
			.canFocus_(false)
			.font_(globalFont1)
			.states_([
				["|..|", btColorOn, btColorOff],
				["X", btColorOn, Color.new255( 205, 190, 112 )]
			])
			.radius_(3)
			.border_(1)
			.value_( if(i < 1, {0}, {1}) )
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
	//pitch slider
	ssLoopPitch.add(
		SmoothSlider(cvLoopArea[i], Rect(2, 107, cvLoopArea[i].bounds.width-17, 13))
			.background_(Color.gray(alpha:0.7))
			.canFocus_(false)
			.knobSize_(0.4)
			.mode_(\move)
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
	ssLoopPitch[i].hilightColor = ssLoopPitch[i].background;
	//pitch string
	stLoopPitchString.add(
		GUI.staticText.new(cvLoopArea[i], Rect(4, 108, 50, 13))
			.font_(globalFont1)
			.stringColor_(Color.white)
			.string_(pitchSpecDisp.map(ssLoopPitch[i].value))
	);

	// pitch to default
	btPitchDef.add(
		RoundButton(cvLoopArea[i], Rect(87, 107, 13, 13))
			.font_(globalFont1)
			.canFocus_(false)
			.states_([
				["0", btColorOn, ctlColor10],
			])
			.radius_(3)
			.border_(1)
			.value_(0)
			.action_({ |bt|
				ssLoopPitch[i].valueAction_(pitchSpecDisp.unmap(1))
			})
	);

	// file container (one list for both Grans & Loopers!!)
	stFilename.add(
		DragBoth(cvLoopArea[i], Rect(2, 124, loopWidth-4, 33))
			.background_(ctlMainColor1.alpha_(0.3))
			.object_("")
			.beginDragAction_({ |obj| currDragFile= lvBuffers.items.indexOf(obj.object.asString) }) //0 is file, 1 is synth
			.receiveDragHandler_({ |obj|
				obj.object= lvBuffers.items.indexOf(currDragFile);
				loadFileLoop.value(i, currDragFile);
			})
	);

	// output channel dropdown list
	pmLoopChList.add(
		SCPopUpMenu.new(cvLoopArea[i], Rect(42, 90, 53, 15))
			.items_(chlistStereo)
			.font_(globalFont1)
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
btLoopPlayPauseGlob= RoundButton(w, Rect(loopLeft+(tracks*loopWidth)+15, topPos+105, 30, 18))
	.canFocus_(false)
	.states_([
		[\play, btColorOn, ctlColor10],
		[\pause, btColorPlay, loopColorCurr]
	])
	.radius_(3)
	.border_(2)
	.value_(0)
	.action_({ |bt|
		tracks.do({ |i|
			if(globalLoopList[i] == 1, {
				btLoopPlayPause[i].valueAction_(bt.value);
			})
		});
	});
//global stop button
btLoopStopGlob= RoundButton(w, Rect(loopLeft+(tracks*loopWidth)+15, topPos+125, 30, 18))
	.canFocus_(false)
	.states_([
		[\stop, btColorOn, ctlColor10],
	])
	.radius_(3)
	.border_(2)
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
btPanic= RoundButton(w, Rect(loopLeft+(tracks*loopWidth)+20, 5, 30, 30))
	.canFocus_(false)
	.states_([
		[\x, Color.white, btColorPlay],
	])
	.radius_(3)
	.border_(2)
	.value_(0)
	.action_({ |bt|
		tracks.do({ |i|
			btSynthOnOff[i].valueAction_(0); //stop ALL grans
			//stop ALL loopers
			moveTimeCursor.value(i, 0, 0, 0, -1);
			btLoopPlayPauseGlob.value = 0;
			// volume indicators to 0
			slideEnv.value(ssGranVolInd[i*2], ssLoopVolInd[i*2].value, volSpec.unmap(0.ampdb), 1, 0.01, 2);
			slideEnv.value(ssGranVolInd[i*2+1], ssLoopVolInd[i*2+1].value, volSpec.unmap(0.ampdb), 1, 0.01, 2);
		});
	});

loadFileLoop= { arg currTrack, currBuf;
	var filepath, soundfile, selStart, selEnd, checkBufLoadTask, tmpBuf;
	// first assume that we add an internal buffer
	stFilename[currTrack+tracks].object_(lvBuffers.items[0]);
	bufTrack[currTrack+tracks]= 0;
	sfLoopWave[currTrack].drawsWaveForm_(false); //initially clearing soundfile view

	if(currBuf != 0, {
		currPosList[currTrack]= nil; // clear current position
		if(try { XQ.globalBufferDict.at(poolName)[0] } != nil, {
			stFilename[currTrack+tracks].object_(lvBuffers.items[currBuf]);
			bufTrack[currTrack+tracks]= currBuf;
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
		});
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

procClick= { |currLoop, currStamp|


var rr;
	//actually average double-click is within 0.3s, 0.5s is to be on a safe side
	if((currStamp-clickBootSec) <= 0.5, { doubleClick= true }, { doubleClick= false });
	clickBootSec= currStamp;
	// "dirty" read - no delay for "single click"
	// always returns "single click", even if it's a first of "double click"
	if(doubleClick == true, { // double click
		{ btLoopStop[currLoop].valueAction_(1) }.defer;
	}, { // single click
		{ btLoopPlayPause[currLoop].valueAction_(1-btLoopPlayPause[currLoop].value) }.defer;
	});



//	// "clean" read
//	// gives only one result "double click" or "single click"
//	// but after a short delay
//	if(doubleClick == false, { // if single click, wait 0.3s
//		rr= Routine({
//			0.3.wait;
//			if(doubleClick == true, { // double click
//				{ btLoopStop[currLoop].valueAction_(1) }.defer;
//			}, { // single click
//				{ btLoopPlayPause[currLoop].valueAction_(1-btLoopPlayPause[currLoop].value) }.defer;
//			});
//			rr.stop;
//		}).play;
//	})

};




updateLooperList= { |currLoop| // update fileLists, check last element



	loadFileList.value(bufferList.items[bufferList.value].asSymbol, 1); // update filelist
	loadFileLoop.value(currLoop, lvBuffers.items.size-1);
};


// LOOPER PANEL end

//WIDYMO
//syn settings



cvScaleSyn= CompositeView(w,Rect(510, 0, w.bounds.width-700, topPos-5))
	.background_(ctlMainColorTransp);

SCStaticText(cvScaleSyn, Rect(10, 0, 60, 30))
	.string_("Scale synth")
	.font_(globalFont1);



mslScaleSynSettings= SCMultiSliderView(cvScaleSyn, Rect(65, 5, scaleSynSettings.size*15, 70))
	.background_(Color.green.alpha_(0.0))
	.fillColor_(Color.grey.alpha_(0.3))
	.isFilled_(true)
	.indexThumbSize_(13)
	.gap_(2)
	.value_({1.0.rand} ! scaleSynSettings.size)
	.mouseOverAction_({ |msl|
		stStatusBar.string = "scale synth - " ++ scaleSynSettings[msl.index] ++ ": " ++ round(scaleSynSpec[msl.index].asSpec.map( msl.value[msl.index] ), 0.001).asString;
	})
	.action_({ |msl|
		if(syn != nil, {
			// dynamically pick up parameter's index to set it's value mapped with Spec, selected by this index
			syn.set( msl.index, scaleSynSpec[msl.index].asSpec.map( msl.value[msl.index] ) );
			stStatusBar.string = "scale synth - " ++ scaleSynSettings[msl.index] ++ ": " ++ round(scaleSynSpec[msl.index].asSpec.map( msl.value[msl.index] ), 0.001).asString;
		});
	});

btScaleSynOnOff= RoundButton(cvScaleSyn, Rect(10, 35, 50, 45))



	.canFocus_(false) .font_(globalFont1) .radius_(3) .border_(0.5) .value_(0)
	.states_([
		["switch ON", btColorOn, btColorOff],
		["switch OFF", btColorOff, btColorOn]
	])
	.action_({ |bt|
		if(bt.value == 1, {
			mslScaleSynSettings.fillColor= Color.blue.alpha_(0.3);
		}, {
			mslScaleSynSettings.fillColor= Color.grey.alpha_(0.3);
		});
		switchScaleSyn.value(bt.value)
	});



pmScaleSynChannel= SCPopUpMenu.new(cvScaleSyn, Rect(btScaleSynOnOff.bounds.left, btScaleSynOnOff.bounds.top+btScaleSynOnOff.bounds.height+5, btScaleSynOnOff.bounds.width, 15))
	.items_(chlistStereo)
	.font_(globalFont1)
	.background_(btColorBG)
	.canFocus_(false)
	.action_({ |pm|
		if(syn != nil, {
			syn.set(\outbus, pm.value * 2);
		})
	});

labelTop= mslScaleSynSettings.bounds.top+mslScaleSynSettings.bounds.height;
scaleSynSettings.size.do({ |i|
	if(labelTop > 95, { labelTop= mslScaleSynSettings.bounds.top+mslScaleSynSettings.bounds.height });



	SCStaticText(cvScaleSyn, Rect(65+(15*i), labelTop, 30, 15))
		.string_(scaleSynSettings[i])
		.font_(globalFont1);
	labelTop= labelTop + 10;


});







//on/off scalesynth
switchScaleSyn= { |on|
	if( on == 1, {


		if(syn == nil, {
			syn= Synth.new(\scaledrone, [\outbus, pmScaleSynChannel.value * 2]);
			setScaleGUI.value(syn, mslScaleSynSettings);
		});



	}, {


		if(syn != nil, { syn.free; syn= nil; });



	})
};




//update multislider using Scalesyn parameters


setScaleGUI= { arg syn, msl;
	var loadSynCtlTask;
	if(syn != nil, {
		msl.value.size.do({ |i|
			syn.get(i, { |val|
				synCtrls[i]= scaleSynSpec[i].asSpec.unmap(val);
			})
		});
		loadSynCtlTask = Task({
			inf.do({ |j|
				if(synCtrls.sum > 0, {
					{ msl.value= synCtrls }.defer;
					loadSynCtlTask.stop;
				});
				0.1.wait;
			});
		}).start;
	});
};
//WIDYMO - end



this.executeFile(Archive.archiveDir ++ "/bibsyn2.rtf"); //load stereo grans by default
btLoopAreaList[0].valueAction_(1); // make the 1st looper active
tracks.do({ |i| //load files
	loadFile.value(i, i);
	loadFileLoop.value(i, i);
});



//MIDI


MIDIClient.init; // intialize the client
13.do({ arg i; MIDIIn.connect(i, MIDIClient.sources.at(i)); });


ccResp = CCResponder({ |src, chan, num, val|
	var panDir, factor;
	var currPitch, currDur, currModf;
	var loLimit= 55, hiLimit= 60, loMIDIsig= 50, hiMIDIsig= 65; // 0-40 is [0.1 .. 0.9]; 41-70 is 1; 71-112 is [1.1 .. 2]
	var loLimXS= 50, hiLimXS= 80; // limits on XSession 0-40 is [0.1 .. 0.9]; 41-70 is 1; 71-112 is [1.1 .. 2]
	[src,chan,num,val].postln;
	case


		{ (num >= 48) && (num < 50) } {  // 1 2 gran vol (VOL 1, VOL 2)
			//{ grVolList[num - 48].valueAction_((val/127)**3) }.defer // exp slider
			{ grVolList[num - 48].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer // lin slider
		}
		{ (num >= 52) && (num < 56) } {  // 5 6 7 8 loopers vol (X-Session SEND, MASTER VOL)
			//{ ssLoopVol[num - 54].valueAction_((val/127)**3) }.defer // exp slider
			{ ssLoopVol[num - 52].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer // lin slider
		}



		{ (num >= 56) && (num < 58) } {  // 1 2 synth type X-Session
			if(ccRespVsSynth.includes(val), {
				{


					pmSynthNames[num-56]= ccRespVsSynth.indexOf(val);
					if(synthList[num-56] != nil, { synthNamesAction.value(num-56) });
					stSynthNames[num-56].string= synthNameList[ccRespVsSynth.indexOf(val)];
				}.defer;
			});
		}



		{ (num >= 58) && (num < 60) } {  // 1 2 fRate X-Session


			if(synthList[num - 58] != nil, {
				case
					{val < (loLimXS+1)} {
						currPitch= val.linlin(0,loLimXS, 0.05,0.99);
						currPitch= currPitch + rrand(currPitch, currPitch*0.25);
					}
					{val > (hiLimXS-1)} {
						currPitch= val.linlin(hiLimXS,127, 1.01,2.00);
						currPitch= currPitch + rrand(currPitch, currPitch*0.25);
					}
					{(val > loLimXS) && (val < hiLimXS)} {
						currPitch=1.00;
					};
					synthList[num - 58].set(\frate, currPitch);
					synthModif[num - 58][0]= currPitch;
			} );
		}



		{ (num >= 50) && (num < 52) } {  // 1 2 modf X-Session


			if(synthList[num - 50] != nil, {
				case
					{val < (loLimXS+1)} {
						currModf= val.linlin(0,loLimXS, -0.10,0.01) * 4400;
					}
					{val > (hiLimXS-1)} {
						currModf= val.linlin(hiLimXS,127, 0.01,0.10) * 4400;
					}
					{(val > loLimXS) && (val < hiLimXS)} {
						currModf=1.00;
					};
					synthList[num - 50].set(\modf, currModf);
					synthModif[num - 50][2]= currModf;
			} );
		}
		//X-Session crossfade slider
		{ num == 10 } { //current looper's pitch control
			{ ssLoopPitch[currLooper].valueAction_(val.linlin(0, 127, 0, 1)) }.defer;
		}
		//X-Session buttons
		{ num == 15 } { // [1]
			//{ btBufRec[0].valueAction_(1-btBufRec[0].value) }.defer //gran 1 rec/stop
			{ btSynthOnOff[0].valueAction_(1-btSynthOnOff[0].value) }.defer // gran 1 on/off
		}
		{ num == 3 } { // [1]
			{ btSynthOnOff[0].valueAction_(1-btSynthOnOff[0].value) }.defer // gran 1 on/off
		}
		{ num == 85 } { // [2]
			//{ btBufRec[1].valueAction_(1-btBufRec[1].value) }.defer //gran 2 rec/stop
			{ btSynthOnOff[1].valueAction_(1-btSynthOnOff[1].value) }.defer // gran 2 on/off
		}



		{ (num >= 87) && (num < 89) } {  // [4][5] Loopers 5 6 start/pause/stop
			procClick.value(num-87, Date.getDate.bootSeconds);


		}


		{ num == 90 } { // [7] looper 7 start/pause/stop
			procClick.value(2, Date.getDate.bootSeconds);
		}
		{ num == 118 } { // [8] looper 8 start/pause/stop
			procClick.value(3, Date.getDate.bootSeconds);
		}





		//WIDYMO
		{ num == 14 } { // [0]
			{ btScaleSynOnOff.valueAction_( 1 - btScaleSynOnOff.value ) }.defer
//			if(syn == nil, {
//				syn= Synth.new(\scaledrone);
//			}, {
//				syn.free;
//				syn= nil;
//			});
		}
		{ num == 86 } { if(syn != nil, { syn.set(\freq2, "c0"); syn.set(\freq3, "c1"); }); } // [3]
		{ num == 89 } { if(syn != nil, { syn.set(\freq2, "c2"); syn.set(\freq3, "c3"); }); } // [6]
		{ num == 119} { if(syn != nil, { syn.set(\freq2, "c4"); syn.set(\freq3, "c5"); }); } // [9]
		{ num == 63} { // (c16)
			if(syn != nil, {
				{
					synCtrls[synCtrls.size-1]= (val/127)**3; // amp is the last scale syn parameter
					mslScaleSynSettings.valueAction_( synCtrls ); // ERROR! doesn't evoke action, only moves slider
					syn.set( synCtrls.size-1, scaleSynSpec[synCtrls.size-1].asSpec.map( synCtrls[synCtrls.size-1] ) );
				}.defer
			});
		}
		//WIDYMO


	},
	39740545, nil, nil, nil //1074999183 - X-Session
);



ccRespSens = CCResponder({ |src, chan, num, val|
	var tmpVal;
//	[src,chan,num,val].postln;
	case


		// I-CubeX
		{ num == 1 } {
			//WIDYMO



			if(syn != nil, { // scale synth control
				tmpVal= val.linlin(0, 127, 0, 0.4);
				syn.set(\amoda2, tmpVal, \amoda3, tmpVal);
				synCtrls[13]= tmpVal; synCtrls[14]= tmpVal; //amoda2 and amoda3 respectively
				{ mslScaleSynSettings.valueAction_( synCtrls ); }.defer; // ERROR! doesn't evoke action, only moves slider
			}, { // if there's no csale syn around - ctrl current rate - up (Touch)
				{ ssLoopPitch[currLooper].valueAction_(val.linlin(0, 127, 0.5, 1)) }.defer;
			});


			//WIDYMO
		}
		{ num == 2 } {  // timescale for Phasor gran (Touch micro-10 v1.0)
			if(loopSynthList[currLooper] != nil, {
				loopSynthList[currLooper].set(\timescale, val.linexp(0,127, 1, 0.0001))
			});
		}



		//WIDYMO
		{ num == 3 } { //num == 60
			if(synctl0 != nil, { synctl0.set(\modval, val) });
			if(synctl2 != nil, { synctl2.set(\modval, val) });
			if(synctl4 != nil, { synctl4.set(\modval, val) });
			if(syn != nil, { // GUI update
				synCtrls[1]= val.linlin(0, 127, 0, 1); // freq2
				{ mslScaleSynSettings.valueAction_( synCtrls ); }.defer;
			})
		}
		{ num == 4 } {
			if(synctl1 != nil, { synctl1.set(\modval, val) });
			if(synctl3 != nil, { synctl3.set(\modval, val) });
			if(synctl5 != nil, { synctl5.set(\modval, val) });
			if(syn != nil, { // GUI update
				synCtrls[2]= val.linlin(0, 127, 0, 1); // freq3
				{ mslScaleSynSettings.valueAction_( synCtrls ); }.defer;
			})
		}
		//WIDYMO


	},
	-724096638, nil, nil, nil // I-Cube
);



nOnResp = NoteOnResponder({|src, chan, num, val|
	[src,chan,num,val].postln;
	},


	nil, nil, nil, nil
);


nOffResp = NoteOffResponder({|src, chan, num, val|
	[src,chan,num,val].postln;
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
	// LOOPER PANEL
		if(indTaskList[i] != nil, { indTaskList[i].stop; indTaskList[i]= nil } );
		loopSynthList[i].set(\gate, 0);
	// LOOPER PANEL end
	});
	synthIn.free;
	CCResponder.removeAll; nOnResp.remove; nOffResp.remove; //MIDI
	//WIDYMO
	switchScaleSyn.value(0);
	synctl0.free; synctl1.free; synctl2.free;
	synctl3.free; synctl4.free; synctl5.free;
	//WIDYMO
};

)