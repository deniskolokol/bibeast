(
var tracks= 2;
var synthList= Array.fill(tracks, nil), channels;
var poolName, pool, poolindex, poolnamesarray;
var tmpBuffer, synthIn;
var w; // main window
var slL=200, slT=450, slW=115, slH=100, hrIndex = 120, granWidth= 125, leftPos=200, topPos= 45;
// outlook
var globalFont1=Font("Helvetica", 9), globalFont2=Font("Helvetica", 12), globalFont3=Font("Helvetica", 36), globalFont4=Font("Helvetica", 13), globalFont5=Font("Helvetica", 14);
var ctlFocusColor=Color.red(alpha:0.2), ctlMainColor1=Color.new255(205, 138, 138), ctlMainColor2=Color.new255(205, 200, 177), ctlColor10=Color.new255(205, 92, 92, 0.05), ctlColor11=Color.new255(205, 92, 92), ctlColor20=Color.new255(100, 149, 237, 0.6), ctlColor21=Color.new255(70, 130, 180), btColorOff=Color.new255(250, 250, 250), btColorOn=Color.new255(43, 43, 43), btColorPlay=Color.new255(178, 34, 34), btColorStop=Color.new255(238, 216, 174), slidColorProgress=Color.new255(123, 104, 238), btKnobColor=Color.new255(205, 38, 38), btColorBG = Color.new255(248, 248, 255), btColorEffColor=Color.new255(96, 123, 139), ctlMainColorTransp= Color.new255(205, 138, 138, 0.3), stlColorKnob= Color.new255(52,70,83), ctlColorTransp= Color.gray(alpha:0.01), ctlColorCurr= Color.new255(240, 240, 240);
var chlistStereo, chlistMono, bufferList, bufnumList=List.new, monoChList, stereoChList;
var sndNameList=[], bufDurList=List.new;
var btMultichanMode, btSensorMode;
var grSTxList=List.new, grSTyList=List.new, sfViewList=List.new, grslidList=List.new, grVolList=List.new, grChList=List.new, rsWideRangeList= List.new, slMiscDev= List.new, slMiscAve= List.new;
var cvRamp, nbRamp, grVolInput, grBufLen, stBufLen, btInputLoop, btInputRec, rslInputProgress;
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
var currDragFile, idGran= 60; // granulators start from 60
// LOOPER PANEL variables
var loopLeft= leftPos+5+(granWidth*tracks), loopWidth= 100;
var loopColorBg= Color.new255(205, 200, 177), loopColorCurr= Color.new255(240, 240, 240), loopColorTransp= Color.gray(alpha:0.01);
var btLoopAreaList= List.new, btLoopAreaLabels, cvLoopArea= List.new, knLoopPan= List.new, ssLoopVolInd= List.new, ssLoopVol= List.new, btLoopPlayPause= List.new, btLoopStop= List.new, btLoopRec= List.new, pmLoopChList= List.new, nbLoopTrigRamp= List.new, ssLoopPlaybackInd= List.new, cvLoopWaveArea= List.new, sfLoopWave= List.new, slLoopZoom= List.new, btLoopMode= List.new, btLoopStartPos= List.new, btLoopEndPos= List.new, stTimecode= List.new, btLoopClearSel= List.new, btRecMSswitch= List.new, btLoopDir= List.new, btLoopCF= List.new, ssLoopRate= List.new, stLoopRateString= List.new, btLoopGlob= List.new;
var btLoopPlayPauseGlob, btLoopStopGlob;
var loopSynthList= Array.fill(tracks, nil);
var idLoop= 70; // loopers start from 70
var updateLooperList, clearOnStop, startLoopSynth, convertTime, loadFileLoop, calcPositions, nextBuffLoop, prevBuffLoop, stopstartPlaybackLoop;
var indTaskList= Array.fill(tracks*2, nil), currPosList= Array.fill(tracks*2, 0), procTaskList= Array.fill(tracks*2, nil);
var rateSpec= [0, 2, \lin].asSpec, rateSpecDisp= [0, 2, \lin, 0.01].asSpec; // rateSpecDisp is for display
var currLooper, globalLoopList;
var rateSign, btRateDef;
var mouseTrackMode= [0, 0]; // tracking mouse in XY ctrls from mouseOverAction (0,1)
// LOOPER PANEL variables - end
// -- buffer pool recording --
var ampAnalFunc, ampAnalyserSynth, responder, numChannels, recSynth, secTask, updateFileList, loadBufTask, currRec=4, filename;
var rslRecLevel, tvRecNameList=List.new, stTimeText=List.new, btBufFile=List.new, btBufRec=List.new, bufList=List.new, bufListSelections=List.new;
var loadFile, loadFileList, loadBuffers, getFilePaths, getMonoBuff;
var factorDistrib, moveStartPos, synType, sendParam, sndTask= Array.fill(tracks, nil);
//universal procedures
var slideEnv;
var btSendParm= List.new;
//file management
var soundsDir= "/Users/deniskolokol/Music/bibeast/sounds/"; // previously it was "sounds/ixiquarks/"
//MIDI
var ccRespVsSynth, ccRespVsSynthSens;
var ccResp_xSession, ccResp_xSessionPro, nOnResp_xSessionPro, nOffResp_xSessionPro, ccResp_eobody, ccResp_iCubex;
var xSession= 1219363690, xSessionPro= -1410198277, eobody= 2104456446, iCubex= 1359464389; // MIDI devices sources
var panDir, factor;
var currRate, currDur, currModf, ctrlModf;
var loLimit= 55, hiLimit= 60, loMIDIsig= 50, hiMIDIsig= 65; // 0-40 is [0.1 .. 0.9]; 41-70 is 1; 71-112 is [1.1 .. 2]
var loLimXS= 50, hiLimXS= 80; // limits on XSession 0-40 is [0.1 .. 0.9]; 41-70 is 1; 71-112 is [1.1 .. 2]
var synthModif= Array.fill(tracks, [1,1,1]);
var clickBootSec= Date.getDate.bootSeconds, procClick; //MIDI button double click processing
var synthCtrlArgs= List[ [\kr_ml0, 0], [\kr_mg2, 1], [\kr_mg0, 2], [\kr_ml1, 3], [\kr_mg1, 4], [\kr_mh0, 5] ];

//environment
var synthPath= PathName.new("~/Music/SuperCollider/scwork/");

Server.default = s = Server.internal;

s.options.numInputBusChannels = 8;
s.options.numOutputBusChannels = 8;
s.options.memSize = 262144;
s.options.blockSize = 512;

s.boot;

s.waitForBoot{
    this.executeFile(synthPath.fullPath +/+ "mysynths.scd");
    //initial idea
    synthNameList= ["cmb", "probe", "starfield", "fount", "stut", "drone", "loopst", "pitch"]; // pitch should always be the last one
    ccRespVsSynth= [0, 18, 36, 54, 72, 90, 108, 127]; // synths map to MIDI knob/slider (should be 1 less than in synthNameList, so that not to touch pitch)
    ccRespVsSynthSens= [0, 30, 65, 90, 110, 125]; // the same but for sensor - only 1st 4 synths

    // synths for bbeast electro
    SynthDef(\be0cmb, { arg bufnum=0, busnum=0, bufdur, ax, ay, panidx=0.7, panshift=0, vol, trigID=60, gate=0, frate=1, fpos=1, fdur=1, modf, factor=0, att=0.1, rel=1, crva= -3, crvr=3;
        var in, out, rate=1, pulse, n= 8, delayL, delayR, updateRate=30;
        pulse= LFNoise0.kr(rrand(0.2,1.0), 1,1).squared * frate;
        delayL= ay.linlin(0,1, 0.01, 0.05);
        delayR= ax.linlin(0,1, 0.01, 0.05);
        in= Klank.ar(
            `[Array.fill(n, {exprand(1.0,20.0)}),
                nil,
                Array.fill(n, {0.2.rand})
            ],
            Blip.ar(pulse, [rrand(2,5),rrand(2,5)], 0.1)
        ).fold2(0.2).cubed * 12;
        in= Mix.arFill(3, { CombL.ar(in, 0.1, 0.03.linrand, 4.0.linrand) });
        out= in.distort * 0.5;
        6.do({out= AllpassN.ar(out, 0.05, [delayL, delayR], 3)});
        out= LeakDC.ar(out);
        SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
        SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
        Out.ar(busnum, Pan2.ar(out, panidx.linlin(0,1, -1, 1), vol
            * EnvGen.kr(Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 )));
    }).send(s);

    SynthDef(\be1probe, { arg bufnum=0, busnum=0, bufdur, ax, ay, panidx=0.7, panshift=0, vol, trigID=60, gate=0, frate=1, fpos=1, fdur=1, modf, factor=0, att=0.1, rel=1, crva= -3, crvr=3;
        var in, out, rate, fbase=80, delayL=0.01, delayR=0.05, updateRate=30;
        rate= frate.max(0.1) * exprand(3,8);
        fbase= modf.linlin(-440,440, 25,4000);
        delayL= ay.linlin(0,1, 0.0001, 0.05);
        delayR= ax.linlin(0,1, 0.0001, 0.05);
        in= LPZ2.ar(
            LFPulse.ar( // populate the sin w/SinOsc
                fbase, 2pi.rand, 0.1,
                (
                    Mix.ar(SinOsc.ar(rate * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.04)).max(0)
                    * Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand])).abs)
            )
        );
        2.do({ out= AllpassN.ar(in, 0.05, [delayL,delayR], 3.0.rand, 2); });
        SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
        SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
        Out.ar(busnum, Pan2.ar(out, panidx.linlin(0,1, -1, 1), vol * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 )));
    }).send(s);

    SynthDef(\be2starfield, { arg bufnum=0, busnum=0, bufdur=1, ax=0.1, ay=0.1, panidx=0.5, vol=0.5, trigID=60, gate=0, frate=1, modf=1, att= 0.1, rel= 1, crva= -3, crvr=3;
        var in, out, dir= [1, 0], q= 0.1, a= 2pi, b= 400, c= 0, x, m, freq=400, updateRate=30;
        x= (1..8)*20;
        dir= dir.put(1, ay.linlin(0, 1, pi, -pi));
        dir= dir.put(0, ax.linlin(0, 1, -pi, pi));
        q= dir[1].atan2(dir[0])+pi;
        a= frate.linlin(0,2, 2pi, 0);
        b= dir[1].hypot(dir[0])*400+200;
        c= modf.linlin(-440,440, 0, 50);
        in= SinOsc.ar(c, BPF.ar(BPF.ar(LFSaw.ar(freq*x, 0, a), b), x, q), vol*0.5);
        in= Limiter.ar(Mix(in)) * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
        out= Pan2.ar(in, panidx.linlin(0,1, -1, 1));
        SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
        SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
        Out.ar(busnum, out);
    }, #[0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]).send(s);

    SynthDef( \be3fount, { arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
        var trate, dur, clk, pos, in, out, updateRate=30;
        trate = ay.linlin(0,1, 1,50); //arg Y: trate 0.1..50
        dur = 4 / trate;
        clk = Impulse.kr(trate);
        pos = Integrator.kr(BrownNoise.kr(ax)); //arg X: position control 0..1
        in= TGrains.ar(
            numChannels: 2,
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
        SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0))); // LEFT
        SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1))); // RIFGHT
        Out.ar(busnum, out);
    }).send(s);

    SynthDef( \be4stut, { arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
        var trate, dur, clk, pos, d, z, in, out, updateRate=30;
        pos = round((ax*0.19)+0.1, 0.01); // arg X: position
        trate = (ay*49.0)+1; //arg Y: trate 1..50
        clk = Impulse.ar(trate * 10);
        d = { Dwhite(0.1, 0.2, 1) };
        z = { Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) };
        in= TGrains.ar(2, clk, bufnum,
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

    SynthDef( \be5drone, { arg busnum = 0, bufnum = 0, bufdur, ax, ay, panidx= 0.8, panshift= 0, vol, trigID= 60, gate= 0, frate= 1, fpos= 1, fdur= 1, modf= 1, factor= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
        var trate = 1, pos, dur, clk, in, out, updateRate=30;
        pos = ax * bufdur; // arg X - position
        trate = (ay * 72) + 8; //arg Y - trate, 8..80
        dur = 12 / trate;
        clk = Impulse.kr(trate);
        in= TGrains.ar(
            numChannels: 2,
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

    SynthDef(\be6loopst, { arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.7, panshift= 0, vol, modf = 1, frate= 1, factor= 0, trigID= 60, gate= 0, att= 0.1, rel= 1, crva= -3, crvr= 3;
        var timescale, trig, trigdiv, env, offset, fadeTime = 0.1, speed, in, out, updateRate=30;
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
                frate * (SinOsc.kr(modf, 0, 0.5*modf, 440)/440),
                trigdiv,
                offset,
                1.0)
        );
        in=	vol *
        (in
            +PitchShift.ar(in, 0.2, factor, 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 4))
            +PitchShift.ar(in, 0.2, factor.linlin(0,1.5, 0.3,0.7), 0.01*panidx, factor.linlin(0, 1.5, 0.1, 0.5), factor.linlin(0, 1, 0, 2))
        );
        out= Pan2.ar(in, panidx.linlin(0,1,-1,1));
        out= out * EnvGen.kr( Env.asr(att, 1, rel, [crva, crvr]), gate: gate, doneAction: 2 );
        SendTrig.kr(Impulse.kr(updateRate), trigID, Amplitude.kr(out.at(0)));
        SendTrig.kr(Impulse.kr(updateRate), trigID+1, Amplitude.kr(out.at(1)));
        Out.ar(busnum, out);
    }).store;

    SynthDef( \be7pitch, { arg bufnum = 0, busnum = 0, bufdur, ax, ay, panidx= 0.5, vol, trigID= 60, gate= 0, inbus= 8, att= 0.1, rel= 1, crva= -3, crvr= 3;
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
    }).send(s);

    // channels lists
    channels= (XQ.pref.numberOfChannels ? 52).asInteger;
    chlistStereo= Array.fill(trunc(channels / 2), nil);
    chlistMono= Array.fill(channels, nil);
    channels.do({ |i|
        chlistMono.put(i, i.asSymbol);
        if( i < (channels / 2), { chlistStereo.put(i, (i*2).asSymbol ++ ", " ++ ((i*2)+1).asSymbol ); } );
        i=i+1;
    });
    // chaotic maps ctrl synths
    synthCtrlArgs.size.do({ |i|
        Synth(synthCtrlArgs[i][0].asSymbol, [\outbus, synthCtrlArgs[i][1]]);
    });

    tmpBuffer= Buffer.alloc(s, s.sampleRate, 1); // 1 seconds 1 channel Buffer - default

    w= Window("biBeast mini", Rect(412, 500, loopLeft+70+(loopWidth*tracks), 405), resizable:false)
    .acceptsMouseOver_(true);
    w.view.background_(Color.new255(205, 201, 165));

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
    cvBufList= CompositeView(w,Rect(0, 40, 200, w.bounds.height-40))
    .background_(ctlColorTransp);
    //buffer list
    bufferList = PopUpMenu(cvBufList,Rect(5, 5, 130, 15))
    .background_(Color.new255(255, 255, 255))
    .canFocus_(false)
    .font_(globalFont1)
    .items_(if(XQ.poolNames == [], { ["no bufferPool"] }, { XQ.poolNames }))
    .action_({ |item|
        // bookmark
        // -- buffer pool recording --
        if(try { XQ.globalBufferDict.at(poolName)[0] } != nil, {
            poolName = bufferList.items[item.value];
            loadFileList.value(poolName.asSymbol);

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
    .font_(globalFont1)
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
    .font_(globalFont1)
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

    HLayoutView(w, Rect(loopLeft+(tracks*loopWidth)+5, 2, 2, 500))
    .background_(Color.white);
    HLayoutView(w, Rect(loopLeft+(tracks*loopWidth)+6, 2, 1, 500))
    .background_(Color.grey(alpha:0.7));
    //ramp time for changing presets and synths
    cvRamp= CompositeView(w,Rect(loopLeft+(tracks*loopWidth)+10, 40, 55, 50))
    .background_(ctlColorTransp);
    StaticText(cvRamp,Rect(0, 0, 80, 15))
    .string_("ramp time (s)")
    .font_(globalFont1);
    nbRamp = NumberBox(cvRamp, Rect(0, 15, 35, 15))
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
    btMultichanMode= Button(w,Rect(loopLeft+(tracks*loopWidth)+7, 72, 60, 25))
    .canFocus_(false)
    .font_(globalFont4)
    .states_([
        ["stereo", btColorOn, ctlMainColor2],
        ["quadro", Color.white, ctlColor21]
    ])
    .value_(0)
    .action_({ |bt|
        this.executeFile(synthPath.fullPath +/+ "/bibsyn" ++ (bt.value*2+2).asString ++".scd"); //synths
    });
    btSensorMode= Button(w,Rect(loopLeft+(tracks*loopWidth)+7, 99, 60, 25))
    .canFocus_(false)
    .font_(globalFont4)
    .states_([
        ["sens off", btColorOn, ctlMainColor2],
        ["sens on", Color.white, ctlColor21]
    ])
    .value_(0);
    // internal buffer settings
    cvIntBuf= CompositeView(w,Rect(loopLeft+(tracks*loopWidth)+7, 180, 55, 230))
    .background_(ctlColorTransp);
    // rec busses (mono & stereo)
    StaticText(cvIntBuf,Rect(0, 17, 37, 15))
    .string_("mn")
    .font_(globalFont1);
    monoChList = PopUpMenu(cvIntBuf,Rect(13, 16, 40, 15))
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
    StaticText(cvIntBuf,Rect(0, 34, 37, 15))
    .string_("st")
    .font_(globalFont1);
    stereoChList = PopUpMenu(cvIntBuf,Rect(13, 33, 40, 15))
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
    grVolInput= Slider(cvIntBuf, Rect(13, 50, 10, 87))
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
    // input volume indicator
    rslRecLevel = LevelIndicator(cvIntBuf, Rect(24, 50, 20, 87)) //recording level meter
    .canFocus_(false) .style_(0) .warning_(0.6) .critical_(0.9) .numTicks_(11) .numMajorTicks_(3) .value_(volSpec.unmap(0.ampdb));
    //buffer len
    StaticText(cvIntBuf,Rect(5, 140, 50, 13))
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
    stBufLen = StaticText(cvIntBuf, Rect(23, 153, 20, 12))
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
        [\REC, btColorPlay, btColorStop],
        [\stop, btColorStop, btColorPlay]
    ])
    .value_(0)
    .action_({ |bt|
        var routRec, sp, cycles, cnt=0;
        if(bt.value == 1, {
            tmpBuffer.free;
            tmpBuffer = Buffer.alloc(s, s.sampleRate * sec3Spec.map(grBufLen.value), 1); // 1 channel Buffer
            synthIn = Synth(\syninbuff, [\bufnum, tmpBuffer.bufnum, \busnum, monoChList.value, \volIn, grVolInput.value, \loop, btInputLoop.value, \gate, sec3Spec.map(grBufLen.value), \dur, sec3Spec.map(grBufLen.value)]); //recording synth
            rslInputProgress.value= 0;
            cycles = sec3Spec.map(grBufLen.value) / 0.25;
            sp = [0, cycles, \lin, 0.1, 0].asSpec;
            routRec = Routine({ |time|
                inf.do({
                    cycles.do({ |i|
                        cnt = i+1;
                        rslInputProgress.value= sp.unmap(cnt);
                        if(bt.value == 0, { routRec.stop; });
                        0.25.wait;
                    });
                    { if(btInputLoop.value == 0, { bt.valueAction_(0) }) }.defer;
                    cnt = 0;
                    0.001.wait;
                });
            }).play(AppClock);
            }, {
                routRec.stop;
                synthIn.free;
        });
    });
    //recording dur progress bar
    rslInputProgress = LevelIndicator(cvIntBuf, Rect(4, 207, 45, 10))
    .canFocus_(false) .value_(0) .style_(1);

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
        var trigID= idGran + (i * 2);

        // button - selecting current gran area
        btGranAreaList.add(
            Button(w,Rect(leftPos+(i*granWidth), topPos, granWidth, 45))
            .canFocus_(false) .font_(globalFont3) .value_(0)
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
            StaticText(w,Rect(leftPos+(i*granWidth)+5, topPos+12, granWidth, 45))
            .font_(globalFont4)
            .string_(synthNameList.at(pmSynthNames[i]))
        );
        //label for selecting synth
        stSynthSelect.add(
            StaticText(w,Rect(leftPos+(i*granWidth)+5, topPos-7, granWidth, 45))
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
            Button(w,Rect(leftPos+(i*granWidth)+81, topPos, granWidth*0.35, 45))
            .font_(globalFont3)
            .canFocus_(false)
            .states_([
                [(i+1).asString, btColorPlay, Color.clear],
                [(i+1).asString, btColorOff, btColorPlay]
            ])
            .action_({ |bt|
                synthOnOff.value(i, trigID, bt.value);
            })
        );

        //volume indicator - left channel
        ssGranVolInd.add(
            LevelIndicator(cvGranArea[i], Rect(45, 5, 13, 85))
            .canFocus_(false) .style_(0) .warning_(0.6) .critical_(0.9) .value_(volSpec.unmap(0.ampdb))
        );

        //volume indicator - right channel
        ssGranVolInd.add(
            LevelIndicator(cvGranArea[i], Rect(56, 5, 13, 85))
            .canFocus_(false) .style_(0) .warning_(0.6) .critical_(0.9) .value_(volSpec.unmap(0.ampdb))
        );

        //volume slider
        grVolList.add(
            Slider(cvGranArea[i], Rect(67, 5, 10, 85))
            .knobColor_(btKnobColor)
            .background_(Color.gray(alpha:0.4))
            .canFocus_(false)
            .mouseOverAction_({ |sl|
                stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " gran " ++ (i+1).asSymbol ++ " volume ";
            })
            .action_({ |sl| // the volume slider controls start (>0) / end (0) the synth:
                stStatusBar.string = round(volSpec.map(sl.value), 0.01).asString ++ " gran " ++ (i+1).asSymbol ++ " volume ";

                trigID= idGran + (i * 2);
                volAction.value(i, trigID);

                if(globSlidList[i] == 1, {
                    tracks.do({ |j|
                        if( (globSlidList[j] == 1) && (i != j), {
                            grVolList[j].value_(sl.value);
                            trigID= idGran + (j * 2);
                            volAction.value(j, trigID);
                        });
                    });
                });
            });
        );
        // vol ind border
        UserView(cvGranArea[i], Rect(67, (grVolList[i].bounds.top + grVolList[i].bounds.height)*0.5, 10, 2))
        .canFocus_(false) .background_(Color.white);

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

        //recorder section
        //filename
        tvRecNameList.add(
            TextView(cvGranArea[i], Rect(5, 160, granWidth-10, 20))
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
            .states_([ ["buf sv", btColorOn, btColorStop] ])
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
            Button(cvGranArea[i],Rect(5, 33, 30, 16))
            .font_(globalFont1)
            .states_([
                [\dec, btColorOn, ctlColor10],
                [\dec, Color.white, btColorOn]
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
                [\R, btColorPlay, btColorStop],
                [\stop, btColorStop, btColorPlay]
            ])
            .value_(0)
            .action_({ |butt|
                var file, f, filesize, buffer;
                if(s.serverRunning == true, { // if the server is running
                    if(butt.value == 1, {
                        tracks.do({|j| //switch off all other recording
                            if(j != i, {
                                btBufRec[j].enabled= false;
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
            StaticText(cvGranArea[i], Rect(5, 90, 40, 15))
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
            PopUpMenu(cvGranArea[i], Rect(80, 70, 42, 20))
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
            SoundFileView(cvGranArea[i],Rect(3, 160, granWidth-3, granWidth))
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
            Slider2D(cvGranArea[i], Rect(3, 160, granWidth-3, granWidth))
            .background_(ctlMainColorTransp)
            .knobColor_(slidColorProgress)
            .x_(0.0)
            .y_(0.0)
            .canFocus_(false)
            .mouseDownAction_({ arg sl, x, y, modifiers, buttonNumber, clickCount;
                if(clickCount == 2, {
                    if((modifiers == 0) || (modifiers == 256), { // just double click left button
                        mouseTrackMode[i]= 1 - mouseTrackMode[i];
                        grslidList[i].knobColor_(Color.new255(123-(mouseTrackMode[i]*123), 104-(mouseTrackMode[i]*104), 238-(mouseTrackMode[i]*238)));
                    })
                });
            })
            .mouseOverAction_({ |sl, x, y|
                stStatusBar.string = "x " ++ round(sl.x * 100, 0.1).asString ++ ";   y " ++ round(sl.y * 100, 0.1).asString ++ "   gran" ++ (i+1).asString;
                if(mouseTrackMode[i] == 1, {
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
            StaticText(cvGranArea[i], Rect(
                grslidList[i].bounds.left+grslidList[i].bounds.width-25,
                grslidList[i].bounds.top+grslidList[i].bounds.height-15, 25, 15 ))
            .font_(globalFont1)
            .string_(0.0);
        );
        // coordinates - Y
        grSTyList.add(
            StaticText(cvGranArea[i], Rect( 8, grslidList[i].bounds.top+5, 30, 15 ))
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
                    synthList[i].set(\panidx, [sl.hi, sl.lo].mean, \panshift, \pan.asSpec.map([sl.lo, sl.hi].mean));
                });
            });
        );
        //miscelaneous sliders for panorama range: deviation, average (invisible!)
        slMiscDev.add( Slider(cvGranArea[i], Rect(86, 60, 82, 8)) .visible_(false) );
        slMiscAve.add( Slider(cvGranArea[i], Rect(86, 70, 82, 8)) .visible_(false) );
    }); // end of synths loop

    btGranAreaList[0].valueAction_(1); // make the 1st granulator active

    sendParam= { arg curr, switchOn;
        var timeprop, base, x, y;
        var p1, p2, pRate, pPos, pDur, pAmp;
        var valWait, valRate, valPos, valDur, valAmp, vSign; // TEMP

        p1= exprand(0.1, 0.3);
        p2= Prand([Pgeom(0.1, 1+p1, 20), Pgeom(1, 1-p1, 35)], inf).asStream;
        pRate= Pxrand( [1, 1, p2.next, 0.5, 0.5, 0.2, 0.3, p2.next, 1+p2.next, 1-p2.next], inf ).asStream;
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
                                vSign= [-1,1].wchoose([0.2, 0.8]);
                                valRate= (pRate.next*x*vSign+vSign).round(0.0625);
                                valPos=  pPos.next/x;
                                valDur=  pDur.next*y.linlin(0,1,3,0.1);
                                valAmp=  pAmp.next.clip(0.1, grVolList[curr].value);
                                if(synthList[curr] != nil, {
                                    //synthList[curr].set( \frate, valRate, \fpos, valPos, \fdur, valDur, \vol, valAmp );
                                    synthList[curr].set( \frate, ["c2", "c3", "c4", "c5", "c6"].choose, \fpos, valPos, \fdur, valDur, \vol, valAmp );
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
        [rsWideRangeList[curr].hi, rsWideRangeList[curr].lo].mean.postln;
        if(onOff == 1, {
            // switch it ON
            currBufnum = bufnumList.at(bufTrack[curr]);
            currBufDur = bufDurList.at(bufTrack[curr]);

            currSynth = \be ++ pmSynthNames[curr].value ++ synthNameList.at(pmSynthNames[curr].value);
            synthList[curr] = Synth(currSynth, [
                \busnum, grChList[curr].value,
                \bufnum, currBufnum,
                \bufdur, currBufDur,
                \ax, grslidList[curr].x, \ay, grslidList[curr].y,
                \panidx, [rsWideRangeList[curr].hi, rsWideRangeList[curr].lo].mean,
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
        newSynthName = \be ++ pmSynthNames[curr] ++ synthNameList.at(pmSynthNames[curr]);
        if(grVolList[curr].value > 0.0, {
            if( synthList[curr].defName != newSynthName, {
                trigID= idGran + (curr * 2);

                currBufnum = bufnumList.at(bufTrack[curr].value);
                currBufDur = bufDurList.at(bufTrack[curr].value);

                xfadeTime = nbRamp.value;
                currVol = grVolList[curr].value;

                //creating new synth with initial volume 0
                newSynth = Synth(newSynthName, [
                    \busnum, grChList[curr].value,
                    \bufnum, currBufnum,
                    \bufdur, currBufDur,
                    \ax, grslidList[curr].x, \ay, grslidList[curr].y,
                    \panidx, [rsWideRangeList[curr].hi, rsWideRangeList[curr].lo].mean,
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
                if( elt != nil, {
                    try{
                        elt.valueAction_(env.next)
                    }{
                        elt.value_(env.next)
                    };
                });
                density.wait;
            });
            xTask.stop;
            try{ // the last move for exp envelope
                elt.valueAction_(end);
            }{
                elt.value_(end)
            };
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

    stopstartPlaybackLoop= { |ind|
        if(btLoopPlayPause[ind].value == 1, {
            btLoopStop[ind].valueAction_(1); //stop current buffer playback
            btLoopPlayPause[ind].valueAction_(1); //start new buffer playback
        })
    };

    nextBuffLoop= { |ind|
        if( bufTrack[ind+tracks] == (lvBuffers.items.size-1), { // current buffer is the last one
            loadFileLoop.value(ind, 0); // in this case "next" means the "first" one ('internal buffer')
            },{
                loadFileLoop.value(ind, bufTrack[ind+tracks]+1); // simply next buffer
        });
        stopstartPlaybackLoop.value(ind);
    };

    prevBuffLoop= { |ind|
        if(bufTrack[ind+tracks] == 0, { // current buffer is 'internal buffer'
            updateLooperList.value(ind); // in this case "next" means "last" one
            },{
                loadFileLoop.value(ind, bufTrack[ind+tracks]-1); // previous buffer
        });
        stopstartPlaybackLoop.value(ind);
    };

    // -- buffer pool recording --
    // OSC responder for rec levels
    responder= OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
        var mtxLoopVolInd= #[70, 71, 73, 74, 76, 77, 79, 80]; // volume ind indexes for up to 4 tracks
        var mtxLoopPos= #[72, 75, 78, 81]; // position ind indexes for up to 4 tracks
        var ind, dur, buff, startPos, startLoop, endLoop;
        {
            w.isClosed.not.if({ // if window is not closed, update GUI...
                if (msg[1] == ampAnalyserSynth.nodeID, {
                    rslRecLevel.value_( (1-(msg[3].ampdb.abs * 0.01)) * grVolInput.value );
                });

                if((msg[2]-idGran >= 0) && (msg[2] <= (idGran+(tracks*2)+1)), { // tracks*2 - for 2 indicators per each gran (L & R)
                    ssGranVolInd.at(msg[2]-idGran).value_(1-(msg[3].ampdb.abs * 0.01))
                });
                // LOOPER PANEL
                if( mtxLoopVolInd.includes(msg[2]), { // volume meters
                    ssLoopVolInd.at(mtxLoopVolInd.indexOf(msg[2])).value_(1-(msg[3].ampdb.abs * 0.01));		});
                if( mtxLoopPos.includes(msg[2]), { // playback indicator
                    ind= mtxLoopPos.indexOf(msg[2]);
                    buff= XQ.buffers(poolName).at(bufTrack[ind+tracks]-1); // bufer on current looper

                    currPosList[ind]= msg[3]; //saving current position
                    sfLoopWave[ind].timeCursorPosition_(msg[3]); // msg[3] is a current frame

                    # startPos, startLoop, endLoop= calcPositions.value(ind, buff, sfLoopWave[ind]);
                    ssLoopPlaybackInd[ind].value= msg[3].linlin(startLoop, endLoop, 0, 1); //progress

                    stTimecode[ind].string= convertTime.value(msg[3]/buff.sampleRate); //elapsed time

                    if(msg[3] >= (endLoop-5000), { // 5000 frames is an adjustment of the reading of responder
                        if(btLoopMode[ind].value == 1, {
                            clearOnStop.value(ind);
                            }, {
                                loopSynthList[ind].set(\startPos, startLoop); // come back to the initial position
                        });
                    });
                });
                // LOOPER PANEL end
            });
        }.defer;
    }).add;

    //keyboard control
    w.view.keyUpAction = { arg view, char, modifiers, unicode, keycode;
        var tmpVar;
        case
        {(keycode >= 6) && (keycode < 8)} { // Z X - Perlin randomizator
            factorDistrib.value(keycode-6, false);
        }
    };

    w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
        var tmpVar,
        keyArr = #[29, 18, 19, 20, 21, 23, 22, 26, 28, 25],  // char codes of numbers 0-9
        fKeyArr = #[18, 19, 20, 21, 23, 71, 89, 91], // Fn + "char" codes
        modifClean= #[0, 256, 10486016, 10485760], // no modifiers
        modifCmd= #[11534600, 11534608, 11534344, 11534352]; // modifiers - Command

        [modifiers, unicode, keycode].postln;

        // LOOPER PANEL keys
        case
        {(keycode >= 20) && (keycode < 22)} {
            tmpVar = keycode - 20; // index
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
            {(modifiers == 524320) || (modifiers == 524576)} { // Alt + 3 4 - check/uncheck global switch
                btLoopGlob[tmpVar].valueAction_(1-btLoopGlob[tmpVar].value);
            }
            {(modifiers == 8388608) || (modifiers == 8388864)} { // Fn + 3 4 - update fileLists, check last element
                updateLooperList.value(tmpVar);
            }
        }
        {(keycode >= 14) && (keycode < 16)} { //E R
            tmpVar = keycode - 14; // index
            case
            { (modifiers == 0) || (modifiers == 256) } { //E R - individual record
                btLoopRec[tmpVar].valueAction_(1-btLoopRec[tmpVar].value)
            }
            {(modifiers == 8388608) || (modifiers == 8388864)} { //Fn + E R - load internal buffer to a track
                loadFileLoop.value(tmpVar, 0);
            }
        }
        {(keycode >= 2) && (keycode < 4)} { //D F
            tmpVar = keycode - 2; // index
            case
            { (modifiers == 0) || (modifiers == 256) } { //E R - individual record
                btLoopDir[tmpVar].valueAction_(1-btLoopDir[tmpVar].value)
            };
        }
        {(keycode >= 8) && (keycode < 10)} { //C V
            tmpVar = keycode - 8; // index
            case
            { (modifiers == 0) || (modifiers == 256) } { //C V - loop mode
                btLoopMode[tmpVar].valueAction_(1-btLoopMode[tmpVar].value)
            }
            {(modifiers == 524320) || (modifiers == 524576)} { // Alt + C V - cross-fade mode
                btLoopCF[tmpVar].valueAction_(1-btLoopCF[tmpVar].value);
            };
        }
        {keycode == 25} { btLoopStartPos[currLooper].valueAction_(1) }  // 9 | start pos | of curr looper
        {keycode == 29} { btLoopEndPos[currLooper].valueAction_(1) }    // 0 |  end pos  |
        {keycode == 27} { btLoopClearSel[currLooper].valueAction_(1) }  //"-"| clear sel |
        {keycode == 43} { //"<" - looper 1 rate to default
            if(modifClean.includes(modifiers), {
                slideEnv.value(ssLoopRate[0], ssLoopRate[0].value, rateSpec.unmap(1), 0.2, 0.01, 3);
            });
        }
        {keycode == 47} { //">" - looper 2 rate to default
            if(modifClean.includes(modifiers), {
                slideEnv.value(ssLoopRate[1], ssLoopRate[1].value, rateSpec.unmap(1), 0.2, 0.01, 3);
            });
        };

        // LOOPER PANEL end

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
        {keycode == 17} {if( (modifiers == 524576) || (modifiers == 524320), { // Alt + t - select all 2Dsliders global switches
            tracks.do({ |i|
                grGlobBtList[i].valueAction_(1);
                globSlidList[i] = grGlobBtList[i].value;
            })
        })}
        {keycode == 42} { // "\" (record / stop) & Right Shift + \ (loop record)
            if((modifiers == 131076) || (modifiers == 131332), { btInputLoop.valueAction_(1 - btInputLoop.value) });
            btInputRec.valueAction_(1 - btInputRec.value);
        }
        {keycode == 30} { // sensor mode on/off
            btSensorMode.value_(1 - btSensorMode.value);
        }
        {(keycode >= 18) && (keycode < 20)} { // 1-2
            tmpVar = keyArr.find([keycode]) - 1; // index
            case
            {(modifiers == 0) || (modifiers == 256)} { // toggle vol (fade-in: exp fast,fade-out: exp slow)
                // if selected granulator is not current, select indicated granulator
                if(btGranAreaList[tmpVar].value != 1, {
                    btGranAreaList[tmpVar].valueAction_(1)
                    }, {
                        btSynthOnOff[tmpVar].valueAction_(1-btSynthOnOff[tmpVar].value)
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
        {(keycode >= 12) && (keycode < 14)} { //Q W
            case
            { (modifiers == 0) || (modifiers == 256) } { //Q W - individual record
                btBufRec[keycode-12].valueAction_(1-btBufRec[keycode-12].value)
            }
            {(modifiers == 8388608) || (modifiers == 8388864)} { //Fn + Q W - load internal buffer to a track
                loadFile.value(keycode-12, 0);
            }
        }
        {(keycode >= 0) && (keycode < 2)} { // A S - save buffer into file
            if(btBufFile[keycode].enabled == true, { btBufFile[keycode].valueAction_(1) })
        }
        {(keycode >= 6) && (keycode < 8)} { // Z X - Perlin randomizator for synth factor
            factorDistrib.value(keycode-6, true);
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
                nextBuffLoop.value(currLooper);
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
                prevBuffLoop.value(currLooper);
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
            if(try {filepath = XQ.globalBufferDict.at(poolName)[0][currBuf-1].path} != nil, { // the 1st buffer is always internal
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
            Button(w,Rect(
                3+((if(i<(psetNum/2), {i}, {i-(psetNum/2)}))*32.5),
                2+((if(i<(psetNum/2), {0}, {1}))*18),
                32.5, 18 )
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
                //stFilename[i].object= lvBuffers.items.indexOf(presetCurrNode[i][9]);
                //lvBuffers.items.indexOf()

                pmSynthNames[i]= synthNameList.find([presetCurrNode[i][0]]);
                stSynthNames[i].string_(synthNameList.at(pmSynthNames[i]) );
                if(synthList[i] != nil, { synthNamesAction.value(i) });
            });
        });
    };


    // LOOPER PANEL

    globalLoopList=Array.fill(tracks, 0);

    tracks.do({ |i|
        var trigID= idLoop + (i * 3);

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
            SoundFileView(cvLoopWaveArea[i], Rect(0, 20, loopWidth*tracks-2, 85))
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
            .mouseUpAction_({ |sfv|
                var startPos, startLoop, endLoop, currPos, buffer;

                if(loopSynthList[i] != nil, {
                    clearOnStop.value(i); // first stop current playback
                    btLoopPlayPause[i].value= 1; //return "Play/Pause" button into || state
                    ssLoopPlaybackInd[i].visible= true; //return visibility of the playback progress
                    stTimecode[i].visible= true; //return visibility of timecode

                    if (bufTrack[i+tracks] > 0, {
                        buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
                        }, {
                            buffer = tmpBuffer
                    });

                    startPos= sfv.selections[0][0];
                    startLoop= startPos;
                    endLoop= startLoop + sfLoopWave[i].selections[0][1];
                    if(sfLoopWave[i].selectionSize(0) < 10, { endLoop = buffer.numFrames-1; });

                    //show selection
                    sfLoopWave[i].setSelection(0, [startLoop, endLoop-startLoop]);
                    sfLoopWave[i].refresh;

                    startLoopSynth.value(i, trigID, buffer, startPos, startLoop, endLoop); // play a synth
                });
            })
        );

        //waveform zoom
        slLoopZoom.add(
            Slider2D(cvLoopWaveArea[i], Rect(0, 105, loopWidth*tracks-2, 44)) // scroll w/zoom x
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
            Button(cvLoopWaveArea[i], Rect(0, 0, 63, 15))
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

                        clearOnStop.value(i); // first stop current playback
                        btLoopPlayPause[i].value= 1; //return "Play/Pause" button into || state
                        ssLoopPlaybackInd[i].visible= true; //return visibility of the playback progress
                        stTimecode[i].visible= true; //return visibility of timecode


                        if (bufTrack[i+tracks] > 0, {
                            buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
                            }, {
                                buffer = tmpBuffer
                        });

                        trigID= idLoop + (i * 3);

                        selEnd= sfLoopWave[i].selections[0][0] + sfLoopWave[i].selections[0][1];
                        sfLoopWave[i].setSelectionStart(0, startPos);
                        sfLoopWave[i].setSelectionSize(0, selEnd-startPos);

                        startLoop= startPos;
                        endLoop= selEnd;
                        if(sfLoopWave[i].selectionSize(0) < 10, { endLoop = buffer.numFrames-1; });

                        startLoopSynth.value(i, trigID, buffer, startPos, startLoop, endLoop); // play a synth
                    })
                })
            })
        );
        // endLoop button
        btLoopEndPos.add(
            Button(cvLoopWaveArea[i], Rect(66, 0, 63, 15))
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

                        # startPos, startLoop, endLoop= calcPositions.value(i, buffer, sfLoopWave[i]);

                        loopSynthList[i].set(\endLoop, endLoop);
                    })
                })
            })
        );
        // clear selection button
        btLoopClearSel.add(
            Button(cvLoopWaveArea[i], Rect(130, 0, 63, 15))
            .font_(globalFont1)
            .background_(loopColorCurr)
            .canFocus_(false)
            .states_([
                ["clear sel", btColorOn, ctlColor10],
            ])
            .value_(0)
            .action_({ |bt|
                var buffer, startPos, startLoop, endLoop;
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
                            # startPos, startLoop, endLoop= calcPositions.value(i, buffer, sfLoopWave[i]);

                            loopSynthList[i].set(\startPos, startPos, \startLoop, startLoop, \endLoop, endLoop);
                        });
                    });
                })
            })
        );

        // button - selecting current looper
        btLoopAreaList.add(
            Button(w,Rect(loopLeft+(i*loopWidth), topPos, loopWidth, 45))
            .canFocus_(false) .font_(globalFont3) .value_(0)
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
        // setting \timescale to looper synth (WARNING! set visible_(true) for test purposes)
        Slider(w, Rect(loopLeft+(i*loopWidth)+2, topPos+10, loopWidth-40, 15))
        .canFocus_(false) .value_(0) .visible_(false)
        .action_({ |sl|
            if(loopSynthList[i] !=nil, {
                loopSynthList[i].set(
                    \timescale, sl.value.linlin(0,1,0,100),
                    \startLoop, max( (currPosList[i] - sl.value.linlin(0,1, 1000,2205)), 0) // some frames earlier
                )
            });
        });
        // playback position progress bar (on a button)
        ssLoopPlaybackInd.add(
            LevelIndicator(w, Rect(loopLeft+(i*loopWidth)+2, topPos+36, loopWidth-5, 5))
            .canFocus_(false) .value_(0) .style_(1);
        );
        //timecode string (on a button)
        stTimecode.add(
            StaticText(w, Rect(loopLeft+(i*loopWidth)+2, topPos+20, 60, 17))
            .font_(globalFont5)
            .string_("")
        );

        // panorama knob
        knLoopPan.add(
            Knob(cvLoopArea[i], Rect(5, 5, 30, 13))
            .centered_(true) .canFocus_(false) .value_(0.5)
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
            LevelIndicator(cvLoopArea[i], Rect(42, 5, 13, 85))
            .canFocus_(false) .style_(0) .warning_(0.6) .critical_(0.9) .value_(volSpec.unmap(0.ampdb));
        );
        //volume indicator - right channel
        ssLoopVolInd.add(
            LevelIndicator(cvLoopArea[i], Rect(53, 5, 13, 85))
            .canFocus_(false) .style_(0) .warning_(0.6) .critical_(0.9) .value_(volSpec.unmap(0.ampdb));
        );
        //volume slider
        ssLoopVol.add(
            Slider(cvLoopArea[i], Rect(64, 5, 10, 85))
            .knobColor_(btKnobColor) .background_(Color.gray(alpha:0.4)) .canFocus_(false) .value_(volSpec.unmap(0))
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
        UserView(cvLoopArea[i], Rect(64, (ssLoopVol[i].bounds.top + ssLoopVol[i].bounds.height)*0.5, 10, 2))
        .canFocus_(false) .background_(Color.white);

        // start/pause button
        btLoopPlayPause.add(
            Button(cvLoopArea[i], Rect(5, 35, 30, 18))
            .canFocus_(false)
            .states_([
                [">", btColorOn, ctlColor10],
                ["||", btColorPlay, loopColorCurr]
            ])
            .value_(0)
            .action_({ arg butt; var startPos, startLoop, endLoop, buffer;
                if(butt.value == 1, { // start
                    if (bufTrack[i+tracks] > 0, {
                        buffer = XQ.buffers(poolName).at(bufTrack[i+tracks]-1)
                        }, {
                            buffer = tmpBuffer
                    });

                    trigID= idLoop + (i * 3);

                    # startPos, startLoop, endLoop= calcPositions.value(i, buffer, sfLoopWave[i]);

                    stTimecode[i].visible= true; ssLoopPlaybackInd[i].visible= true;

                    startLoopSynth.value(i, trigID, buffer, startPos, startLoop, endLoop); // play a synth
                    },{ // pause
                        loopSynthList[i].free;
                        loopSynthList[i]= nil;
                });
            })
        );
        // stop button
        btLoopStop.add(
            Button(cvLoopArea[i], Rect(5, 53, 30, 15))
            .canFocus_(false)
            .font_(globalFont1)
            .states_([
                ["[]", btColorOn, ctlColor10],
            ])
            .value_(0)
            .action_({
                clearOnStop.value(i);
            })
        );
        // record button
        btLoopRec.add(
            Button(cvLoopArea[i], Rect(5, 71, 30, 18))
            .canFocus_(false)
            .states_([
                [\R, btColorPlay, btColorStop],
                [\stop, btColorStop, btColorPlay]
            ])
            .value_(0)
            .action_({ |butt|
                //start/stop recording to current open bufferpool
                var file, f, filesize, buffer;
                if(s.serverRunning == true, { // if the server is running
                    if(butt.value == 1, {
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

                        // check DiskOut help for example!

                        recSynth.start(soundsDir ++ filename ++ ".aif");
                        recSynth.setAmp_(grVolInput.value);
                        secTask.start;
                        }, {
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
                ["st", Color.white, ctlColor21],
            ])
            .value_( if(i < 1, {0}, {1}) )
        );
        // dir button
        btLoopDir.add(
            Button(cvLoopArea[i], Rect(75, 34, 20, 18))
            .canFocus_(false)
            .font_(globalFont1)
            .states_([
                [\rev, btColorOn, btColorOff],
                [\rev, btColorOff, btColorOn]
            ])
            .value_(0)
            .action_({ |bt|
                if(loopSynthList[i] !=nil, {
                    rateSign= if(bt.value == 1, { -1 }, { 1 });
                    loopSynthList[i].set(\rate, rateSign * rateSpec.map(ssLoopRate[i].value));
                });
            })
        );
        // loop/one button
        btLoopMode.add(
            Button(cvLoopArea[i], Rect(75, 53, 20, 18))
            .canFocus_(false)
            .font_(globalFont1)
            .states_([
                ["lp", btColorOn, btColorOff],
                ["one", btColorOff, btColorOn]
            ])
            .value_(0)
        );
        // cross-fade button
        btLoopCF.add(
            Button(cvLoopArea[i], Rect(75, 72, 20, 18))
            .canFocus_(false)
            .font_(globalFont1)
            .states_([
                ["|..|", btColorOn, btColorOff],
                ["X", btColorOn, Color.new255( 205, 190, 112 )]
            ])
            .value_( if(i < 1, {0}, {1}) )
            .action_({ |bt|
                if(loopSynthList[i] !=nil, {
                    if(bt.value == 1, { loopSynthList[i].set(\lag, 0.1) }, { loopSynthList[i].set(\lag, 0) });
                });
            })
        );
        // time string
        stTimeText.add(
            StaticText(cvLoopArea[i], Rect(5, 90, 40, 15))
            .font_(globalFont5)
            .string_("00:00");
        );
        //rate slider
        ssLoopRate.add(
            Slider(cvLoopArea[i], Rect(2, 107, cvLoopArea[i].bounds.width-17, 13))
            .background_(Color.grey(0.7))
            .knobColor_(Color.grey(0.5))
            .canFocus_(false)
            .value_(rateSpec.unmap(1))
            .mouseOverAction_({ |sl|
                stStatusBar.string = stLoopRateString[i].string ++ " loop " ++ (i+1) ++ " rate ";
            })
            .action_({ |sl|
                rateSign= if(btLoopDir[i].value == 1, { -1 }, { 1 });
                stLoopRateString[i].string= rateSign * rateSpecDisp.map(sl.value);
                stStatusBar.string = stLoopRateString[i].string ++ " loop " ++ (i+1) ++ " rate ";
                if(loopSynthList[i] !=nil, { loopSynthList[i].set(\rate, rateSign * rateSpec.map(sl.value)) });

                if(globalLoopList[i] == 1, {
                    tracks.do({ |j|
                        if( (globalLoopList[j] == 1) && (i != j), {
                            ssLoopRate[j].value= sl.value;
                            stLoopRateString[j].string= rateSign * rateSpecDisp.map(ssLoopRate[j].value);
                            if(loopSynthList[j] !=nil, { loopSynthList[j].set(\rate, rateSign * rateSpec.map(ssLoopRate[j].value)) });
                        });
                    });
                });

            })
        );
        //rate string
        stLoopRateString.add(
            StaticText(cvLoopArea[i], Rect(4, 108, 50, 13))
            .font_(globalFont1)
            .stringColor_(Color.white)
            .string_(rateSpecDisp.map(ssLoopRate[i].value))
        );

        // rate to default
        btRateDef.add(
            Button(cvLoopArea[i], Rect(87, 107, 13, 13))
            .font_(globalFont1)
            .canFocus_(false)
            .states_([
                ["0", btColorOn, ctlColor10],
            ])
            .value_(0)
            .action_({ |bt|
                ssLoopRate[i].valueAction_(rateSpecDisp.unmap(1))
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
            PopUpMenu(cvLoopArea[i], Rect(42, 90, 53, 15))
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
    btLoopPlayPauseGlob= Button(w, Rect(loopLeft+(tracks*loopWidth)+10, topPos+80, 30, 18))
    .canFocus_(false)
    .states_([
        [">", btColorOn, ctlColor10],
        ["||", btColorPlay, loopColorCurr]
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
    btLoopStopGlob= Button(w, Rect(loopLeft+(tracks*loopWidth)+10, topPos+100, 30, 18))
    .canFocus_(false)
    .states_([
        ["[]", btColorOn, ctlColor10],
    ])
    .value_(0)
    .action_({ |bt|
        tracks.do({ |i|
            if(globalLoopList[i] == 1, {
                clearOnStop.value(i);
                btLoopPlayPauseGlob.value = 0;
            })
        });
    });

    //panic button
    btPanic= Button(w, Rect(loopLeft+(tracks*loopWidth)+20, 5, 30, 30))
    .canFocus_(false)
    .states_([
        [\x, Color.white, btColorPlay],
    ])
    .value_(0)
    .action_({ |bt|
        tracks.do({ |i|
            btSynthOnOff[i].valueAction_(0); //stop ALL grans
            //stop ALL loopers
            clearOnStop.value(i);
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

    calcPositions= { arg curr, buff, sfv;
        var sp, sl, el;

        sp= if( currPosList[curr] != nil, { currPosList[curr] }, { sfv.selections[0][0] });
        sl= sfv.selections[0][0];
        el= if( sfv.selections[0][1] != 0, { sl + sfv.selections[0][1] }, { buff.numFrames-1 });
        if( sfv.selectionSize(0) < 10, { el= buff.numFrames-1 });

        [sp, sl, el] //startPos, startLoop, endLoop
    };

    startLoopSynth= { arg curr, trigID, buffer, startPos, startLoop, endLoop;
        var rateSn, cfLag, sName;

        rateSn= if(btLoopDir[curr].value == 0, { 1 }, { -1 });
        cfLag= if(btLoopCF[curr].value == 1, { 0.1 }, { 0 });

        sName= if(buffer.numChannels == 2, { \gmpLoopStereo }, { \gmpLoopMono });

        loopSynthList[curr]= Synth(sName, [
            \bufnum, buffer.bufnum,
            \trigID, trigID, // the bus for the gui update
            \out, pmLoopChList[curr].value * 2,
            \vol, ampSpec.map(ssLoopVol[curr].value),
            \pan, \pan.asSpec.map(knLoopPan[curr].value),
            \rate, rateSn * rateSpec.map(ssLoopRate[curr].value),
            \startPos, startPos,
            \endLoop, endLoop,
            \trig, (endLoop-startPos)/buffer.sampleRate,
            \lag, cfLag
        ], s, \addToHead);
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
        var doubleClick;
        //actually average double-click is within 0.3s, 0.5s is to be on a safe side
        if((currStamp-clickBootSec) <= 0.5, { doubleClick= true }, { doubleClick= false });
        clickBootSec= currStamp;

        // dirty read
        if(doubleClick, {
            { btLoopStop[currLoop].valueAction_(1) }.defer;
            }, {
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

    ctrlModf= { |currSyn, currVal|
        if(synthList[currSyn] != nil, {
            case
            {currVal < (loLimXS+1)} {
                currModf= currVal.linlin(0,loLimXS, -0.100,0.001) * 4400;
            }
            {currVal > (hiLimXS-1)} {
                currModf= currVal.linlin(hiLimXS,127, 0.001,0.100) * 4400;
            }
            {(currVal > loLimXS) && (currVal < hiLimXS)} {
                currModf=1.00;
            };
            synthList[currSyn].set(\modf, currModf);
            synthModif[currSyn][2]= currModf;
        } );
    };

    moveStartPos= { |val, lo, hi|
        var buff, startPos, startLoop, endLoop, vl;

        if(loopSynthList[currLooper].isNil.not, {
            buff= XQ.buffers(poolName).at(bufTrack[currLooper+tracks]-1); // bufer on current looper

            # startPos, startLoop, endLoop= calcPositions.value(currLooper, buff, sfLoopWave[currLooper]);

            vl= val.linlin(lo, hi, startLoop, endLoop).round(s.sampleRate*0.1); // shouldn't this be multiple of s.sampleRate/100
            loopSynthList[currLooper].set(\timescale, val, \startLoop, vl);

            SystemClock.sched(0.8, { loopSynthList[currLooper].set(\timescale, 0); nil });
        });
    };

    synType= { |ind, val|
        if(ccRespVsSynth.includes(val), {
            pmSynthNames[ind]= ccRespVsSynth.indexOf(val);
            if(synthList[ind] != nil, { synthNamesAction.value(ind) });
            stSynthNames[ind].string= synthNameList[ccRespVsSynth.indexOf(val)];
        });
    };


    updateLooperList= { |currLoop| // update fileLists, check last element
        loadFileList.value(bufferList.items[bufferList.value].asSymbol, 1); // update filelist
        loadFileLoop.value(currLoop, lvBuffers.items.size-1);
    };
    // LOOPER PANEL end

    this.executeFile(synthPath +/+ "/bibsyn2.rtf"); //load stereo grans by default
    btLoopAreaList[0].valueAction_(1); // make the 1st looper active
    tracks.do({ |i| //load files
        loadFile.value(i, i);
        loadFileLoop.value(i, i);
    });


    //MIDI
    MIDIClient.init; // intialize the client
    13.do({ arg i; MIDIIn.connect(i, MIDIClient.sources.at(i)); });

    // X-Session
    ccResp_xSession = CCResponder({ |src, chan, num, val|
        //	[src,chan,num,val].postln;
        case
        { (num >= 48) && (num < 50) } {  // 1 2 gran vol (VOL 1, VOL 2)
            //{ grVolList[num - 48].valueAction_((val/127)**3) }.defer // exp slider
            { grVolList[num - 48].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer // lin slider
        }
        { (num >= 54) && (num < 56) } {  // 3 4 loopers vol (X-Session SEND, MASTER VOL)
            //{ ssLoopVol[num - 54].valueAction_((val/127)**3) }.defer // exp slider
            { ssLoopVol[num - 54].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer // lin slider
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
                    currRate= val.linlin(0,loLimXS, 0.05,0.99);
                    currRate= currRate + rrand(currRate, currRate*0.25);
                }
                {val > (hiLimXS-1)} {
                    currRate= val.linlin(hiLimXS,127, 1.01,2.00);
                    currRate= currRate + rrand(currRate, currRate*0.25);
                }
                {(val > loLimXS) && (val < hiLimXS)} {
                    currRate=1.00;
                };
                synthList[num - 58].set(\frate, currRate);
                synthModif[num - 58][0]= currRate;
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
        { num == 10 } { //current looper's rate control
            { ssLoopRate[currLooper].valueAction_(val.linlin(0, 127, 0, 1)) }.defer;
        }
        //X-Session buttons
        { num == 15 } { // [1]
            //{ btBufRec[0].valueAction_(1-btBufRec[0].value) }.defer //gran 1 rec/stop
            { btSynthOnOff[0].valueAction_(1-btSynthOnOff[0].value) }.defer // gran 1 on/off
        }
        { num == 3 } { // [1] -- the same for num 3 (num on xsession changed by itself - WTF ??)
            //{ btBufRec[0].valueAction_(1-btBufRec[0].value) }.defer //gran 1 rec/stop
            { btSynthOnOff[0].valueAction_(1-btSynthOnOff[0].value) }.defer // gran 1 on/off
        }
        { num == 85 } { // [2]
            //{ btBufRec[1].valueAction_(1-btBufRec[1].value) }.defer //gran 2 rec/stop
            { btSynthOnOff[1].valueAction_(1-btSynthOnOff[1].value) }.defer // gran 2 on/off
        }
        { (num >= 87) && (num < 89) } { // [4][5] Loopers 3,4 rec/stop
            { btLoopRec[num-87].valueAction_(1-btLoopRec[num-87].value) }.defer
        }
        { num == 90 } { // [7] looper 3 start/pause/stop
            procClick.value(0, Date.getDate.bootSeconds);
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
        }
        { num == 118 } { // [8] looper 4 start/pause/stop
            procClick.value(1, Date.getDate.bootSeconds);
        }
        },
        xSession, nil, nil, nil // X-Session
    );

    // X-Session Pro
    ccResp_xSessionPro = CCResponder({ |src, chan, num, val|
        //	[src,chan,num,val].postln;
        case
        { num == 27 } {  // gran 1 vol (left HIGH)
            { grVolList[0].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer
        }
        { num == 34 } {  // gran 2 vol (right HIGH)
            { grVolList[1].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer
        }
        { num == 28 } {  // gran 1 fRate (left MID)
            //			if( synthList[0].isNil.not, { synthList[0].set( \frate, val.linlin(0,127, 0.01,1.99).round(0.125) ); })
            if( synthList[0].isNil.not, { synthList[0].set( \frate, val.linlin(0,127, 0.01,1.99) ); })
        }
        { num == 35 } {  // gran 2 fRate (right MID)
            //			if( synthList[1].isNil.not, { synthList[1].set( \frate, val.linlin(0,127, 0.01,1.99).round(0.125) ); })
            if( synthList[1].isNil.not, { synthList[1].set( \frate, val.linlin(0,127, 0.01,1.99) ); })
        }
        { num == 29 } {  // gran 1 modf (left LOW)
            ctrlModf.value(0, val);
        }
        { num == 36 } {  // gran 2 modf (right LOW)
            ctrlModf.value(1, val);
        }
        { num == 24 } {  // gran 1 gran synth type (left 1)
            { synType.value(0, val); }.defer;
        }
        { num == 31 } {  // gran 2 gran synth type (right 1)
            { synType.value(1, val); }.defer;
        }
        { num == 25 } {  // gran 1 Y (left 2)
            { grslidList[0].activey_(val.linlin(0,127, 0,1)); }.defer;
        }
        { num == 26 } {  // gran 1 X (left 3)
            { grslidList[0].activex_(val.linlin(0,127, 0,1)); }.defer;
        }
        { num == 32 } {  // gran 2 Y (right 2)
            { grslidList[1].activey_(val.linlin(0,127, 0,1)); }.defer;
        }
        { num == 33 } {  // gran 2 X (right 3)
            { grslidList[1].activex_(val.linlin(0,127, 0,1)); }.defer;
        }
        { num == 11 } {  // looper 3 vol (Volume A)
            { ssLoopVol[0].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer
        }
        { num == 14 } {  // looper 4 vol (Volume B)
            { ssLoopVol[1].valueAction_(val.linlin(0,127, 0.00,1.00)) }.defer
        }
        { num == 12 } {  // looper 3 rate (Pitch A)
            { ssLoopRate[0].valueAction_(val.linlin(0, 127, 0.00,1.00)) }.defer;
        }
        { num == 15 } {  // looper 4 rate (Pitch B )
            { ssLoopRate[1].valueAction_(val.linlin(0, 127, 0.00,1.00)) }.defer;
        }
        { num == 17 } { // curr loop pos (crossfader)
            { moveStartPos.value(val, 0, 127); }.defer;
        }
        },
        xSessionPro, nil, nil, nil // X-Session Pro
    );
    nOnResp_xSessionPro = NoteOnResponder({|src, chan, num, val|
        //	[src,chan,num,val].postln;
        case
        { num == 44 } { // [Headphone Button Left]
            { btSynthOnOff[0].valueAction_(1-btSynthOnOff[0].value) }.defer // gran 1 on/off
        }
        { num == 45 } { // [Headphone Button Right]
            { btSynthOnOff[1].valueAction_(1-btSynthOnOff[1].value) }.defer // gran 2 on/off
        }
        { num == 46 } {  // loop 1 prev track (left <)
            { prevBuffLoop.value(0); }.defer;
        }
        { num == 43 } {  // loop 1 next track (left >)
            { nextBuffLoop.value(0); }.defer; // single click - next buffer
        }
        { num == 56 } {  // loop 2 prev track (right <)
            { prevBuffLoop.value(1); }.defer; // single click - prev buffer
        }
        { num == 57 } {  // loop 2 next track (right >)
            { nextBuffLoop.value(1); }.defer; // single click - next buffer
        }
        { num == 70 } { // looper 3 start/pause/stop
            procClick.value(0, Date.getDate.bootSeconds);
        }
        { num == 69 } { // looper 4 start/pause/stop
            procClick.value(1, Date.getDate.bootSeconds);
        }
        },
        xSessionPro, nil, nil, nil
    );
    nOffResp_xSessionPro = NoteOffResponder({|src, chan, num, val|
        [src,chan,num,val].postln;
        case
        { num == 58 } { // looper 3 rec stop
            { btLoopRec[0].valueAction_(1-btLoopRec[0].value) }.defer
        }
        { num == 59 } { // looper 4 rec stop
            { btLoopRec[1].valueAction_(1-btLoopRec[1].value) }.defer
        }
        },
        xSessionPro, nil, nil, nil
    );

    // eobody
    ccResp_eobody = CCResponder({ |src, chan, num, val|
        //	[src,chan,num,val].postln;
        case
        { num == 1 } { // gran 1 Y
            { if(btSensorMode.value==1, { grslidList[0].activey_(val.linlin(52,65, 0,1)); }) }.defer;
        }
        { num == 2 } { // gran 1 X
            { if(btSensorMode.value==1, { grslidList[0].activex_(val.linlin(52,65, 0,1)); }) }.defer;
        }
        { num == 3 } {  // 3 on eobody - pitch follower volume
            { if(btSensorMode.value==1, { grslidList[1].activey_(val.linlin(52,65, 0,1)); }) }.defer;
        }
        { num == 4 } {  // fRate - 4 on eobody
            { if(btSensorMode.value==1, { grslidList[1].activex_(val.linlin(52,65, 0,1)); }) }.defer;
        }
        },
        eobody, nil, nil, nil // eobody
    );

    // I-CubeX
    ccResp_iCubex = CCResponder({ |src, chan, num, val|
        var tmpVal;
        //	[src,chan,num,val].postln;
        // only 2/3-d sensors are controlled with btSensorMode!!!
        case
        { num == 1 } {  // current looper rate
            { ssLoopRate[currLooper].valueAction_(val.linlin(0, 127, 0.5, 1)) }.defer;
        }
        { num == 2 } {  // current looper cuts
            if(loopSynthList[currLooper] != nil, {
                loopSynthList[currLooper].set(
                    \timescale, val,
                    \startLoop, max( (currPosList[currLooper] - val.linlin(0,1, 1000,2205)), 0) // some frames earlier
                );
            });
        }
        { num == 5 } {  // fRate
            {
                if(btSensorMode.value==1, {
                    if(synthList[0] != nil, {
                        synthList[0].set(\frate, val.linlin(0, 127, 0.1, 2.0) + bilinrand(0.1));
                    } );
                })
            }.defer
        }
        //		{ num == 6 } {  // y
        //			{
        //				if(btSensorMode.value==1, {
        //					grslidList[0].activey_(val.linlin(0, 127, 0, 1))
        //				})
        //			}.defer
        //		}
        { num == 6 } {  // gran 0 amp
            {
                if(btSensorMode.value==1, {
                    grVolList[0].valueAction_(val.linlin(2, 127, 0, 1))
                })
            }.defer
        }
        { num == 7 } {  // pitch follower XY
            {
                if(btSensorMode.value==1, {
                    tmpVal=127-val;
                    grslidList[1].activey_(tmpVal.linlin(95, 127, 0, 1));
                    grslidList[1].activex_(tmpVal.linlin(95, 127, 0, 1))
                    //					grslidList[1].activey_(val.linlin(0, 127, 0, 1));
                    //					grslidList[1].activex_(val.linlin(0, 127, 0, 1))
                })
            }.defer
        }
        { num == 8 } {  // gran 1 amp
            {
                if(btSensorMode.value==1, {
                    tmpVal=127-val;
                    grVolList[1].valueAction_(tmpVal.linlin(2,45, 0,1))
                    //					grVolList[1].valueAction_(val.linlin(2, 127, 0, 1))
                })
            }.defer
        }
        },
        iCubex, nil, nil, nil // i-CubeX
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
        //MIDI
        ccResp_xSession.remove; ccResp_xSessionPro.remove; ccResp_eobody.remove; ccResp_iCubex.remove;
        nOnResp_xSessionPro.remove; nOffResp_xSessionPro.remove;
        sndTask.do({ |ts| if(ts.notNil, {ts.stop; ts= nil}) });
    };
};
)