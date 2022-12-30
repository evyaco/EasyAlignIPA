#jeanphilippegoldman@gmail.com
#mornex-les-bains dec 06
#22dec bug with one-pphrase file


# June 2022: IPA Support by evyaco@gmail.com for OMILab (vereds@openu.ac.il)


form 1. Macro-segmentation: creates ortho tier from Sound and Strings
	comment select a Sound and a Strings object
	word text_tier IPA
	real silence_threshold_dB: -43.0
	real minimal_silence_duration_ms: 0.2
	real minimal_utterance_duration_ms: 0.1
	real hebrew_factor_for_utternace_length: 1.075
	comment After macro-segmentation,
	boolean open_sound_and_tg 1
endform

include utils.praat

alpha=0.25
silence_detection = silence_threshold_dB
minimal_silence_duration = minimal_silence_duration_ms
minimal_utterance_duration = minimal_utterance_duration_ms
hebrew_factor_estimated_length = hebrew_factor_for_utternace_length
keep_silence_tier = 0
silence_tier_id = 1
ortho_tier_id = 2

basename$=""
nso=numberOfSelected("Sound")
nst=numberOfSelected("Strings")

if nst=1 and nso=1
	basename$=selected$("Strings")
	stringsID=selected("Strings")
	soundID=selected("Sound")
	sound$=selected$("Sound")
else
	exit Select exactly one Sound and one Strings object
endif


####SILENCE DETECTION
select 'soundID'
d= Get total duration
To TextGrid (silences)... 100 0 'silence_detection' 'minimal_silence_duration' 'minimal_utterance_duration' #
Insert interval tier... ortho_tier_id 'text_tier$'
tgID=selected("TextGrid")
Rename... 'sound$'

#select 'silences'
num_of_intervals_in_silence_grid = Get number of intervals... 'silence_tier_id'
curr_silence_interval=0


Read from file... lang/heb/heb.Table

####CLEAN TEXT STRINGS
select 'stringsID'
n = Get number of strings
lb=0
la=0
for i to n
	select 'stringsID'
	s$ = Get string... 'i' 
	lb=lb+length(s$)
	call mystrip 0 0 0 's$'
	la=la+length(mystrip.arg$)
	Set string... 'i' 'mystrip.arg$'
endfor
printline ###EASYALIGN: Segment in utterances
printline Using Strings 'basename$'...
printline Lines : 'n' strings
printline Length 'la' caracters after cleanup ('lb' before) 


####FINDING BOUNDARIES
timepos=0  ; d=duration
textpos=1  ;la=textlength
curry=1
nv=0
nnv=0
for i to n
	select 'stringsID'
	s$ = Get string... 'i'
	if length(s$)>0
	 ####printline
	 ####printline
		nv=nv+1
		call getTA timepos silence_tier_id   ; get remaining articulation time
		silence_interval_at_timepos = Get interval at time... silence_tier_id timepos
		silence_test$ = Get label of interval... silence_tier_id silence_interval_at_timepos
		if silence_test$=="#"
			timepos = Get end time of interval... silence_tier_id silence_interval_at_timepos
			silence_boundary=timepos-0.01
			Insert boundary... ortho_tier_id 'silence_boundary'
			call getTA timepos silence_tier_id
		 ####printline the time after silence should be 'timepos'
			curry = curry + 1
		endif
		
		inbal_duration = 0
		select Table heb
		for j from 1 to length(s$)
			curr_char$ = mid$(s$, j, 1)
			curr_char_index = Search column... ipa 'curr_char$'
			if curr_char_index > 0
				curr_char_duration = Get value... 'curr_char_index' duration
			else
				curr_char_duration = 0.05
			endif
			inbal_duration = inbal_duration + curr_char_duration
		 ####printline for character 'curr_char$' the index is 'curr_char_index' and the duration is 'curr_char_duration'
		endfor

		select 'tgID'

		estimated_dur = getTA.ta * length(s$) / (la-textpos) * hebrew_factor_estimated_length
		initial_estimated_dur = estimated_dur
		
	 ####printline initial estimated_dur is 'initial_estimated_dur' and inbal duration is 'inbal_duration'
		
		t1=timepos+(1-alpha)*estimated_dur
		t2=timepos+estimated_dur ; decide which better: this line or the next
	 ####printline t1 is 't1' and first calc of t2 is 't2'
		t2=min(d,timepos+(1+alpha)*estimated_dur) ; d it total duration - so it handles EOF here
	 ####printline t1 is 't1' and second calc of t2 is 't2'
		i1=Get interval at time... silence_tier_id 't1' 
		i2=Get interval at time... silence_tier_id 't2'

		call gettime timepos estimated_dur silence_tier_id
		
		estimated_dur = gettime.time 
		estimated_dur = estimated_dur - timepos

		#if 
		
	 ####printline *********************************************************
	 ####printline curr_string = 's$'
	 ####printline *********************************************************
	 ####printline textpos = 'textpos'
	 ####printline timepos = 'timepos'
		la_minus_textpos = la-textpos
	 ####printline la - textpos = 'la_minus_textpos'
		curr_string_length = length(s$)
	 ####printline length of string = 'curr_string_length'
	 ####printline getTA.ta = 'getTA.ta'
	 ####printline estimated_dur = 'estimated_dur'
	 ####printline time 't2' > 'gettime.time'
	 ####printline t1='t1' i1='i1' t2='t2' i2='i2'
		maxdur=0
		maxdurj=-1
		silence_in_middle = 0
		silence_found = 0
		first_silence_found_start = 0
		for j from i1 to i2
			l$ = Get label of interval... silence_tier_id 'j'
		 ####printline checking silences between 'i1' and 'i2'
			if l$="#"
				silent_praat_start=Get starting point... silence_tier_id 'j'
				silent_end_praat=Get end point... silence_tier_id 'j'
				mp=(silent_praat_start+silent_end_praat)/2
			 ####printline textpause j is 'j' silent in praat starts at 'silent_praat_start' and ends at 'silent_end_praat' and maxdur is 'maxdur'
				if silent_end_praat-silent_praat_start > maxdur
					maxdurj=j
					maxdurmp=mp
					maxdur=silent_end_praat-silent_praat_start
				endif
				if silent_end_praat < timepos + estimated_dur
					silence_start = silent_praat_start
					silence_in_middle = 1
				endif
				if silence_in_middle = 1 and silence_found = 0
				 ####printline we have silent in middle
					first_silence_found_start = silence_start
					silence_found = 1
					#timepos = silence_start
				else
					#timepos = timepos + estimated_dur
				endif
			endif  
		endfor
		 #printline maxdur
		 #printline 'maxdurj' 'maxdurmp' 'maxdur' 't1' 't2'
		if maxdurj!=-1
			estimated_dur=maxdurmp-timepos
		endif

		if silence_found = 1
			timepos = first_silence_found_start
		else
			timepos = timepos + estimated_dur
		endif
		 #printline timepos 'timepos'
		 #printline
		select 'tgID'
		if timepos>0 and timepos<d and i<n 
			 #printline 'i'/'n' boundary at 'timepos'
			 #timepos = timepos - 0.1
			Insert boundary... ortho_tier_id 'timepos'
		endif
		Set interval text... ortho_tier_id 'curry' 's$'
		textpos=textpos+length(s$)
		curry=curry+1 ; miam!
	else 
		nnv=nnv+1
	endif

 printline 'initial_estimated_dur', 'estimated_dur', 'inbal_duration'

endfor

select Table heb
Remove

if nv>0
 ####printline Created ortho tier with 'nv' intervals
endif
if nnv>0
 ####printline 'nnv' non valid lines were ignored (empty or punctuation only)
endif
printline Don't forget to save your new TextGrid !!

if keep_silence_tier==0
	select 'tgID'
	Remove tier... silence_tier_id
endif

if open_sound_and_tg
	select 'tgID'
	plus 'soundID'
	Edit
endif

select 'tgID'

exit

procedure getTA .start .tier
	select 'tgID'
	.si= Get interval at time... '.tier' '.start'
	.l$=Get label of interval... '.tier' '.si'
	.ni = Get number of intervals... '.tier'
	 if .l$="#"
		.si=.si+1   ; check if not at the end
		if .si<=.ni
			.sp=Get starting point... '.tier' '.si'
			.ep=Get end point... '.tier' '.si'
			.ta=.ep-.sp
#     ####printline started in silence int '.ta' si in now '.si' 
		else
			.ta=0 
#     ####printline started in last silence int '.ta'

		endif
	else
		.ep=Get end point... '.tier' '.si'
		.ta=.ep-.start
#   ####printline started in speech. first int fgives '.ta'
	endif
	
	for .i from .si+1 to .ni
		.l$=Get label of interval... '.tier' '.i'
 #  ####printline '.i' "'.l$'"
		if .l$!="#"
			.sp=Get starting point... '.tier' '.i'
			.ep=Get end point... '.tier' '.i' 
			.ta=.ta+.ep-.sp
		endif
	endfor
endproc


procedure gettime .start .dur .tier
#get new time provided a duration articulation time
select 'tgID'
.si= Get interval at time... '.tier' '.start'
.l$=Get label of interval... '.tier' '.si'
.ni = Get number of intervals... '.tier'
if .l$="#"
	.si=.si+1		; 1st int is silence
	if .si<=.ni
		.curdur=0
	.time=Get end point... '.tier' '.si'
		#printline gettime1
	else
		.time=Get end time
		#printline gettime2
	endif
else			; 1st int is not silence
	.ep=Get end point... '.tier' '.si'
	if .ep-.start> .dur	;  dur s'arrete avant la fin du 1er intervalle
		.time=.start+.dur
		.si=.ni+1
		#printline gettime3
	else
		.curdur=.ep-.start
		.si=.si+1
		.time=.ep
		#printline gettime4
	 endif
endif

while .si<=.ni
	.l$=Get label of interval... '.tier' '.si'
	if .l$!="#"
		.ep=Get end point... '.tier' '.si'
		.sp=Get starting point... '.tier' '.si'
		if .ep-.sp+.curdur> .dur
			.time=.sp+.dur-.curdur
			.si=.ni+1
		else
			.curdur=.ep-.sp+.curdur
		 endif
	endif
	.si=.si+1
endwhile

endproc

