(
s = Server.internal;
Server.default = s;
s.boot;
)

b.free;

b = Buffer.read(s,"sounds/ixiquarks/sheptest.aif"); // must be mono-sound!!!

(
var buffDur, w, synthgran0, synthgran1, synthgran2, synthgran3, synthgran4, synthgran5, synthgran6, synthgran7, synthgran8, grslid0, grslid1, grslid2, grslid3, grslid4, grslid5, grslid6, grslid7, grslid8, grVol0, grVol1, grVol2, grVol3, grVol4, grVol5, grVol6, grVol7, grVol8;

buffDur = b.numFrames / b.sampleRate; // buffer length in seconds

w = SCWindow("buffer granulator", Rect(100, 400, 820, 470));
w.view.decorator = FlowLayout(w.view.bounds);

//synths section
// ALL GO TO 6,7 BUSES!!!
synthgran0 = {
	arg trate, pos, dur, clk, pan, vol;
	dur = 12 / trate;
	clk = Impulse.kr(trate);
	pan = WhiteNoise.kr(0.6);
	Out.ar(6,TGrains.ar(2, clk, b.bufnum, 1, pos + TRand.kr(0, 0.01, clk), dur, pan, vol));
}.scope(zoom: 4);

synthgran1 = {
	arg trate, dur, clk, pos, pan, vol;
	dur = 4 / trate;
	clk = Dust.kr(trate);
	pan = WhiteNoise.kr(0.6);
	Out.ar(6,TGrains.ar(2, clk, b.bufnum, 1, pos + TRand.kr(0, 0.01, clk), dur, pan, vol));
}.scope(zoom: 4);

synthgran2 = {
	arg trate, tratectrl, dur, clk, pos, pan, vol;
	trate = LinExp.kr(LFTri.kr(tratectrl),-1,1,8,120);
	dur = 12 / trate;
	clk = Impulse.ar(trate);
	pan = WhiteNoise.kr(0.6);
	Out.ar(6,TGrains.ar(2, clk, b.bufnum, 1, pos, dur, pan, vol));
}.scope(zoom: 4);

synthgran3 = {
	arg trate, dur, durctrl, clk, pos, pan, vol;
	trate = 12;
	dur = durctrl / trate;
	clk = Impulse.kr(trate);
	pan = WhiteNoise.kr(0.6);
	Out.ar(6,TGrains.ar(2, clk, b.bufnum, 1, pos + TRand.kr(0, 0.01, clk), dur, pan, vol));
}.scope(zoom: 4);

synthgran4 = {
	arg trate, dur, clk, pos, posctrl, pan, vol;
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	pos = Integrator.kr(BrownNoise.kr(posctrl));
	pan = WhiteNoise.kr(0.6);
	Out.ar(6,TGrains.ar(2, clk, b.bufnum, 1, pos, dur, pan, vol));
}.scope(zoom: 4);

synthgran5 = {
	arg trate, dur, clk, pos, pan, vol;
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	pan = WhiteNoise.kr(0.8);
	Out.ar(6,TGrains.ar(2, clk, b.bufnum, 2 ** WhiteNoise.kr(2), pos, dur, pan, vol));
}.scope(zoom: 4);

synthgran6 = {
	arg trate, dur, cntr, vol;
	dur = 1.2 / trate;
	Out.ar(6,TGrains.ar(2, Impulse.ar(trate), b.bufnum, (1.2 ** WhiteNoise.kr(3).round(1)), cntr, dur, WhiteNoise.kr(0.6), vol));
}.scope(zoom: 4);

synthgran7 = {
	arg trate, dur, clk, pos, pan, vol;
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	pan = WhiteNoise.kr(0.8);
	Out.ar(6,TGrains.ar(2, clk, b.bufnum, 2 ** WhiteNoise.kr(2), pos, dur, pan, vol));
}.scope(zoom: 4);

synthgran8 = {
	arg trate, dur, z, d, vol;
	d = { Dwhite(0.1, 0.2, 1) };
	z = {
		Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) 	};
	Out.ar(6,
		TGrains.ar(2, Impulse.ar(trate), b.bufnum,
			rate: Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * 2 + 1,
			centerPos: Dseq(z.dup(8), inf),
			dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
			pan: Dseq([0.7, 0.6, 0.5, 0.2, 0, 0.2, 0.5, 0.6, 0.7], inf) * 2 - 1,
			amp: Dseq([1, 0, z.value, 0, 2, 1.0, 1, 0.1, 0.1], inf) * vol
		)
	);
}.scope(zoom: 4);

// GUI definition
grslid0 = SC2DSlider(w, Rect(5, 5, 185, 185));
grVol0 = SCSlider(w, Rect(195, 5, 10, 200));
grslid1 = SC2DSlider(w, Rect(215, 5, 185, 185));
grVol1 = SCSlider(w, Rect(410, 5, 10, 200));
grslid2 = SC2DSlider(w, Rect(420, 5, 185, 185));
grVol2 = SCSlider(w, Rect(605, 5, 10, 200));
grslid3 = SC2DSlider(w, Rect(620, 5, 185, 185));
grVol3 = SCSlider(w, Rect(805, 5, 10, 200));
w.view.decorator.nextLine;
grslid4 = SC2DSlider(w, Rect(5, 200, 185, 185));
grVol4 = SCSlider(w, Rect(195, 215, 10, 200));
grslid5 = SC2DSlider(w, Rect(215, 200, 185, 185));
grVol5 = SCSlider(w, Rect(410, 215, 10, 200));
grslid6 = SC2DSlider(w, Rect(420, 200, 185, 185));
grVol6 = SCSlider(w, Rect(605, 215, 10, 200));
grslid7 = SC2DSlider(w, Rect(620, 200, 185, 185));
grVol7 = SCSlider(w, Rect(805, 215, 10, 200));
w.view.decorator.nextLine;
grslid8 = SCSlider(w, Rect(5, 425, 800, 25));
grVol8 = SCSlider(w, Rect(5, 460, 800, 10));

//actions of GUI elements
grslid0.action_({
	synthgran0.set(
		\pos, grslid0.x * buffDur, // 0..buffDur
		\trate, round((grslid0.y*112)+8,1.0)); //8..120 step 1
		("synth 0 [x,y] =" + [round(grslid0.x, 0.001), round(grslid0.y, 0.001)]).postln;
});
grVol0.action_({
	synthgran0.set(\vol, round(grVol0.value, 0.001));
	("synth 0 vol =" + round(grVol0.value, 0.001)).postln;
});

grslid1.action_({
	synthgran1.set(
		\pos, grslid1.x * buffDur, // 0..buffDur
		\trate, round((grslid1.y*112)+8,1.0)); //8..120 step 1
		("synth 1 [x,y] =" + [round(grslid1.x, 0.001), round(grslid1.y, 0.001)]).postln;
});
grVol1.action_({
	synthgran1.set(\vol, round(grVol1.value, 0.001));
	("synth 1 vol =" + round(grVol1.value, 0.001)).postln;
});

grslid2.action_({
	synthgran2.set(
		\pos, grslid2.x * buffDur, // 0..buffDur
		\tratectrl, (grslid2.y*1.9)+0.1); //0.1..2.0 - how to make it exponential?
		("synth 2 [x,y] =" + [round(grslid2.x, 0.001), round(grslid2.y, 0.001)]).postln;
});
grVol2.action_({
	synthgran2.set(\vol, round(grVol2.value, 0.001));
	("synth 2 vol =" + round(grVol2.value, 0.001)).postln;
});

grslid3.action_({
	synthgran3.set(
		\pos, grslid3.x * buffDur, // 0..buffDur
		\durctrl, (grslid3.y*23.8)+0.2); //0.2..24 - how to make it exponential?
		("synth 3 [x,y] =" + [round(grslid3.x, 0.001), round(grslid3.y, 0.001)]).postln;
});
grVol3.action_({
	synthgran3.set(\vol, round(grVol3.value, 0.001));
	("synth 3 vol =" + round(grVol3.value, 0.001)).postln;
});

grslid4.action_({
	synthgran4.set(
		\posctrl, grslid4.x, // 0..1 step 0.00...01
		\trate, round((grslid4.y*99)+1, 1.0)); //1..100, step 1.0 - how to make it exponential?
		("synth 4 [x,y] =" + [round(grslid4.x, 0.001), round(grslid4.y, 0.001)]).postln;
});
grVol4.action_({
	synthgran4.set(\vol, round(grVol4.value, 0.001));
	("synth 4 vol =" + round(grVol4.value, 0.001)).postln;
});

grslid5.action_({
	synthgran5.set(
		\pos, grslid5.x * buffDur, // 0..buffDur
		\trate, (grslid5.y*399)+1); //1..400 how to make it exponential?
		("synth 5 [x,y] =" + [round(grslid5.x, 0.001), round(grslid5.y, 0.001)]).postln;
});
grVol5.action_({
	synthgran5.set(\vol, round(grVol5.value, 0.001));
	("synth 5 vol =" + round(grVol5.value, 0.001)).postln;
});

grslid6.action_({
	synthgran6.set(
		\cntr, grslid6.x * buffDur, // 0..buffDur
		\trate, (grslid6.y*118)+2); //2..120 how to make it exponential?
		("synth 6 [x,y] =" + [round(grslid6.x, 0.001), round(grslid6.y, 0.001)]).postln;
});
grVol6.action_({
	synthgran6.set(\vol, round(grVol6.value, 0.001));
	("synth 6 vol =" + round(grVol6.value, 0.001)).postln;
});

grslid7.action_({
	synthgran7.set(
		\pos, grslid7.x * buffDur, // 0..buffDur
		\trate, (grslid7.y*399)+1); //1..400 how to make it exponential?
		("synth 7 [x,y] =" + [round(grslid7.x, 0.001), round(grslid7.y, 0.001)]).postln;
});
grVol7.action_({
	synthgran7.set(\vol, round(grVol7.value, 0.001));
	("synth 7 vol =" + round(grVol7.value, 0.001)).postln;
});

grslid8.action_({
	synthgran8.set(\trate, (grslid8.value * 99)+1); //1..100 how to make it exponential?
	("synth 8 x =" + round(grslid8.value, 0.001)).postln;
});
grVol8.action_({
	synthgran8.set(\vol, grVol8.value);
	("synth 8 vol =" + round(grVol8.value, 0.001)).postln;
});

//get the list of settings
w.view.keyDownAction = {
	arg view, char, modifiers, unicode, keycode;
	//[char, keycode].postln;
	("   ").postln;
	("====== synths settings snapshot [x,y] / vol ======").postln;
	("synth 0:" + [round(grslid0.x, 0.001), round(grslid0.y, 0.001)] + "/ " + round(grVol0.value, 0.001)).postln;
	("synth 1:" + [round(grslid1.x, 0.001), round(grslid1.y, 0.001)] + "/ " + round(grVol1.value, 0.001)).postln;
	("synth 2:" + [round(grslid2.x, 0.001), round(grslid2.y, 0.001)] + "/ " + round(grVol2.value, 0.001)).postln;
	("synth 3:" + [round(grslid3.x, 0.001), round(grslid3.y, 0.001)] + "/ " + round(grVol3.value, 0.001)).postln;
	("synth 4:" + [round(grslid4.x, 0.001), round(grslid4.y, 0.001)] + "/ " + round(grVol4.value, 0.001)).postln;
	("synth 5:" + [round(grslid5.x, 0.001), round(grslid5.y, 0.001)] + "/ " + round(grVol5.value, 0.001)).postln;
	("synth 6:" + [round(grslid6.x, 0.001), round(grslid6.y, 0.001)] + "/ " + round(grVol6.value, 0.001)).postln;
	("synth 7:" + [round(grslid7.x, 0.001), round(grslid7.y, 0.001)] + "/ " + round(grVol7.value, 0.001)).postln;
	("synth 8:" + round(grslid8.value, 0.001) + "/ " + round(grVol8.value, 0.001)).postln;
};


//==defaults
//bg & focus colors
grslid0.background_(Color.new(0.847, 0.831, 0.749));
grslid1.background_(Color.new(0.847, 0.831, 0.749));
grslid2.background_(Color.new(0.847, 0.831, 0.749));
grslid3.background_(Color.new(0.847, 0.831, 0.749));
grslid4.background_(Color.new(0.847, 0.831, 0.749));
grslid5.background_(Color.new(0.847, 0.831, 0.749));
grslid6.background_(Color.new(0.847, 0.831, 0.749));
grslid7.background_(Color.new(0.847, 0.831, 0.749));
grslid8.background_(Color.new(0.847, 0.831, 0.749));
grslid0.focusColor_(Color.red(alpha:0.2));
grslid1.focusColor_(Color.red(alpha:0.2));
grslid2.focusColor_(Color.red(alpha:0.2));
grslid3.focusColor_(Color.red(alpha:0.2));
grslid4.focusColor_(Color.red(alpha:0.2));
grslid5.focusColor_(Color.red(alpha:0.2));
grslid6.focusColor_(Color.red(alpha:0.2));
grslid7.focusColor_(Color.red(alpha:0.2));
grslid8.focusColor_(Color.red(alpha:0.2));
//null positions on open
grslid0.x_(0.0);
grslid0.y_(0.0);
grslid1.x_(0.0);
grslid1.y_(0.0);
grslid2.x_(0.0);
grslid2.y_(0.0);
grslid3.x_(0.0);
grslid3.y_(0.0);
grslid4.x_(0.0);
grslid4.y_(0.0);
grslid5.x_(0.0);
grslid5.y_(0.0);
grslid6.x_(0.0);
grslid6.y_(0.0);
grslid7.x_(0.0);
grslid7.y_(0.0);

w.front;
w.onClose = {
	synthgran0.free;
	synthgran1.free;
	synthgran2.free;
	synthgran3.free;
	synthgran4.free;
	synthgran5.free;
	synthgran6.free;
	synthgran7.free;
	synthgran8.free;
};
)





// === original patch starts here

(
{
var trate, dur, rate;
trate = MouseY.kr(2,200,1);
dur = 4 / trate;
rate = Dseq([10, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
TGrains.ar(2, Impulse.ar(trate), b.bufnum, rate, MouseX.kr(0,BufDur.kr(b.bufnum)), dur, Dseq([-1, 1], inf), 0.1, 2);
}.scope(zoom: 4);
)


//synthgran0
(
{
var trate, dur, clk, pos, pan;
trate = MouseY.kr(8,120,1);
dur = 12 / trate;
clk = Impulse.kr(trate);
pos = MouseX.kr(0,BufDur.kr(b.bufnum)) + TRand.kr(0, 0.01, clk);
pan = WhiteNoise.kr(0.6);
TGrains.ar(2, clk, b.bufnum, 1, pos, dur, pan, 0.3);
}.scope(zoom: 4);
)

//synthgran1
(
{
var trate, dur, clk, pos, pan;
trate = MouseY.kr(8,120,1);
dur = 4 / trate;
clk = Dust.kr(trate);
pos = MouseX.kr(0,BufDur.kr(b.bufnum)) + TRand.kr(0, 0.01, clk);
pan = WhiteNoise.kr(0.6);
TGrains.ar(2, clk, b.bufnum, 1, pos, dur, pan, 0.1);
}.scope(zoom: 4);
)

//synthgran2
(
{
var trate, dur, clk, pos, pan;
trate = LinExp.kr(LFTri.kr(MouseY.kr(0.1,2,1)),-1,1,8,120);
dur = 12 / trate;
clk = Impulse.ar(trate);
pos = MouseX.kr(0,BufDur.kr(b.bufnum));
pan = WhiteNoise.kr(0.6);
TGrains.ar(2, clk, b.bufnum, 1, pos, dur, pan, 0.1);
}.scope(zoom: 4);
)

//synthgran3
(
{
var trate, dur, clk, pos, pan;
trate = 12;
dur = MouseY.kr(0.2,24,1) / trate;
clk = Impulse.kr(trate);
pos = MouseX.kr(0,BufDur.kr(b.bufnum)) + TRand.kr(0, 0.01, clk);
pan = WhiteNoise.kr(0.6);
TGrains.ar(2, clk, b.bufnum, 1, pos, dur, pan, 0.1);
}.scope(zoom: 4);
)

//synthgran4
(
{
var trate, dur, clk, pos, pan;
trate = MouseY.kr(1,100,1);
dur = 8 / trate;
clk = Impulse.kr(trate);
pos = Integrator.kr(BrownNoise.kr(MouseX.kr(0.001,1.0)));
pan = WhiteNoise.kr(0.6);
TGrains.ar(2, clk, b.bufnum, 1, pos, dur, pan, 0.1);
}.scope(zoom: 4);
)

//synthgran5
(
{
var trate, dur, clk, pos, pan;
trate = MouseY.kr(1,400,1);
dur = 8 / trate;
clk = Impulse.kr(trate);
pos = MouseX.kr(0,BufDur.kr(b.bufnum));
pan = WhiteNoise.kr(0.8);
TGrains.ar(2, clk, b.bufnum, 2 ** WhiteNoise.kr(2), pos, dur, pan, 0.1);
}.scope(zoom: 4);
)


//synthgran6
(
{
var trate, dur;
trate = MouseY.kr(2,120,1);
dur = 1.2 / trate;
TGrains.ar(2, Impulse.ar(trate), b.bufnum, (1.2 ** WhiteNoise.kr(3).round(1)), MouseX.kr(0,BufDur.kr(b.bufnum)), dur, WhiteNoise.kr(0.6), 0.1);
}.scope(zoom: 4);
)


//synthgran7
(
{
	var trate, dur, clk, pos, pan;
	trate = MouseY.kr(1,400,1);
	dur = 8 / trate;
	clk = Impulse.kr(trate);
	pos = MouseX.kr(0,BufDur.kr(b.bufnum));
	pan = WhiteNoise.kr(0.8);
	TGrains.ar(2, clk, b.bufnum, 2 ** WhiteNoise.kr(2), pos, dur, pan, 0.1);
}.scope(2, zoom: 4);
)


//synthgran8
(
{
	var trate, dur, z, d;
	trate = MouseX.kr(1, 100, 1);
	d = { Dwhite(0.1, 0.2, 1) };
	z = {
		Drand([Dgeom(0.1, 1 + d.value, Diwhite(20, 40)), Dgeom(1, 1 - d.value, Diwhite(20, 40))]) 	};
	TGrains.ar(
		2,
		Impulse.ar(trate),
		b.bufnum,
		rate: Dseq([1, 1, z.value, 0.5, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1], inf) * 2 + 1,
		centerPos: Dseq(z.dup(8), inf),
		dur: Dseq([1, d.value, 1, z.value, 0.5, 0.5, 0.1, z.value] * 2, inf) / trate,
		pan: Dseq([0.7, 0.6, 0.5, 0.2, 0, 0.2, 0.5, 0.6, 0.7], inf) * 2 - 1,
		amp: Dseq([1, 0, z.value, 0, 2, 1.0, 1, 0.1, 0.1], inf)
	);
}.scope(zoom: 4);
)