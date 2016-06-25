# bibeast
A tool for live granular synthesis in surround sound

WARNING! Old code, needs revision!

name - see http://en.wikipedia.org/wiki/List_of_Hulk_supporting_characters
Bi-Beast - A giant two-headed android living on a floating island in the sky, and containing the knowledge of the bird people that built it.

this is work-in-progress Bibeast_v0.1.2

to-do in Bibeast_v0.2:
- new window - short help on shortcuts as in ixi GrainBox's color info
- clean the code - no useless variables, etc.
- file management:
-- on open - create a dir ~/Music/bibeast/sounds/<datetime> and write newely recorded sounds there with names Gran1-0, Gran1-1, Gran2-0, Gran2-1,.. , Loop
- General
-- all the pre-sets should be moved to Dictionary(?)
-- Bibeast should work with "Projects" (saved files), all the presets should be saved in the Project's Dictionary
-- change buffer pools to work with filesystem, remember open folder in the Project's Dictionary

to-do or not to-do
- dynamic shortcuts for 2, 3 or 4 tracks mode (map keyboard)
-- implement patterns:
--- "degrees" of deconstruction (use MIDI knob scaled as in case of ccRespVsSynth)
--- use tempo parameter (locally on a looper, but with possibility of global ctrl)
--- global tempo (tacts and bpm)

to-do in longer perspective (Bibeast_v0.3...)
- warp looping synth (changing tempo without affecting pitch)
- divide functionality to classes, use objects & their methods instead of functions
