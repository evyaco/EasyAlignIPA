#phono aligner
#jeanphilippegoldman@gmail.com
#tregunc - july'06
###2007
#26 sept allow elision
#22aout workaround a bug due to new praat unicode version
#5 mai mono , generic phon conversion
###2006
#22 dec bug with monophone words
#20 dec resample to 16000Hz

# June 2022: IPA support (for Hebrew) by evyaco@gmail.com for OMILab (vereds@openu.ac.il)


form 3.Segmentation: create phones, syll and words tiers
comment Creates 'phones','words' tiers from a Sound and a TextGrid with 'phono' tier (and 'ortho' tier)
comment Select one Sound and one TextGrid
sentence ipa_tier IPA
#sentence sampa_tier SAMPA
boolean overwrite 1
comment Choose a language
optionmenu language: 1
		option heb
word chars_to_ignore }-';(),.
boolean precise_endpointing 0
comment Variation detection
boolean consider_star 1
boolean allow_elision 0
comment After processing,
real preptk_threshold_(ms) 90
boolean make_syllable_tier 1
boolean open_sound_and_tg 1
comment Tiers word, syllable and phoneme will show fixed IPA characters. What about utterance tier?
boolean fix_ipa_in_utterance_tier 1
endform

#char to ignore : ^ (<slk)
;precise_endpointing =1 means no initial or final sp
if precise_endpointing
	bsil$=""
else
	bsil$="-b sil"
endif
printline 
printline ###EASYALIGN: Segment in phones, sylls, words
printline 

soundIDMono = -1
soundIDMonoSampled = -1

keeptmpfile = 1
removeMonoSound = 1

#Post-process pre-ptk pauses. Suppress pause less than (in ms)
n_utt_rec=0
n_utt_notrec=0
n_utt_ignored=0
n_utt_misformatted=0
n_utt_silence=0

basename$=""
ns=numberOfSelected("Sound")
nt=numberOfSelected("TextGrid")

if nt=1 and ns=1
	basename$=selected$("TextGrid")
	tgID=selected("TextGrid")
	soundID=selected("Sound")
	by_select=1
else
	exit Select one Sound and one TextGrid
endif

Read from file... lang/'language$'/'language$'.Table
Append row
nr=Get number of rows
Set string value... 'nr' htk sil
Set string value... 'nr' sampa _

langTableID=Read from file... lang/lang.Table
langcol=Search column... lang 'language$'
spfreqref = Get value... 'langcol' sp
targetkind$ = Get value... 'langcol' tk
Remove

filedelete reco.log

srcrateref=10000000/spfreqref
if fileReadable("lang/'language$'/'language$'.cfg")
	Read Strings from raw text file... lang/'language$'/'language$'.cfg
else
	Read Strings from raw text file... analysis.cfg
endif
Set string... 1 SOURCERATE = 'srcrateref'
Set string... 2 TARGETKIND = 'targetkind$'
Write to raw text file... tmp/analysis.cfg
Remove

select 'soundID'
soundID_orig = soundID
;jpg 4.5.07
ncan=Get number of channels
if ncan=2
	Convert to mono
	soundID=selected("Sound")
	soundIDMono = soundID
endif

spfreq = Get sampling frequency
if spfreq != spfreqref
	Resample... spfreqref 5
	soundID=selected("Sound")
	soundIDMonoSampled = soundID
	spfreq=spfreqref
endif

select 'tgID'
st = Get start time
if st!= 0
	printline TextGrid does not start at time 0. Times are shifted are zero.
	Shift to zero
endif

sampa_tier$ = "SAMPA"
call ipa_to_sampa_stage language$ 'ipa_tier$' 'sampa_tier$'

# Ignore orthography for now. It was alredy converted (in 2nd phase from IPA to SAMPA)
call findtierbyname 'ipa_tier$' 1 1
orthoTID = findtierbyname.return
ipaTID = findtierbyname.return
if language$=="heb"
	orthoTID = 0
endif

call findtierbyname 'sampa_tier$' 1 1
phonoTID = findtierbyname.return

#jpg 22.04.2008: checks if phonoTID and orthoTID have the same boundaries
call checkOrthoAndPhonoTiers

hmmfile$="lang/'language$'/'language$'.hmm"
if fileReadable(hmmfile$)
else
	 hmmfile$="lang/fra/fra.hmm"
endif
printline Using HMM file: 'hmmfile$'

n = Get number of intervals... 'phonoTID'
first=1
printline beforefor and num is 'n'
for i from 1 to n

	printline num utterance number 'i'

	select 'tgID'
	#printline int 'i'
	l$ = Get label of interval... 'phonoTID' 'i'
	align_it=0

	#IGNORE phono segment empty or startinh with %/[
	if (l$=="") or (mid$(l$,1,1)=="%") or (mid$(l$,1,1)=="[")
		align_it=5
		n_utt_ignored = n_utt_ignored + 1
		#printline Utt.# 'i' ignored (phono tier is empty or start with a %) 'l$'

	#SKIP phono segment with _ only
	elsif (l$=="_") 
		align_it=6
		n_utt_silence = n_utt_silence + 1
		#printline Utt.# 'i' ignored (phono tier is silence)

	#PROCESS the others
	else
		for j to length(chars_to_ignore$)
			l$=replace$(l$,mid$(chars_to_ignore$,j,1),"",0)
		endfor
		call removespaces 1 1 1 'l$'
		l$ = removespaces.arg$

		lobak$=l$
		call countwords 'l$'
		npw = countwords.return
		if language$="nl"
			call checknl 'l$'
		elsif language$="fra" or language$="sw" or language$="en" or language$="nan" or language$="spa" or language$="slk" or language$="porbra" or language$="heb"
			call checksampa2 "'l$'" 'language$' * 
			isgood=1-checksampa2.cont
			#pause 'language$' 'l$' 'isgood'
		else
			call checksampa 'l$'
			isgood=checksampa.i
		endif

		printline "is good is 'isgood'"

		# alert about bad SAMPA characters
		if isgood!=0
			align_it = 3
			if language$="nl"
				printline Utt.# 'i' misformatted: 'checknl.wrongi'th char is not SAMPA (a): |'checknl.wrongc$'| in 'l$'
			elsif language$="fra" or language$="sw" or language$="en" or language$="nan" or language$="spa" or language$="slk" or language$="porbra" or language$="heb" 
				printline Utt.# 'i' misformatted: 'checksampa2.i'th char is not SAMPA (b): |'checksampa2.c2$'| in |'checksampa2.s$'|
			else
				printline Utt.# 'i' misformatted: 'checksampa.i'th char is not SAMPA (c): |'checksampa.c$'| in |'checksampa.s$'|
			endif
			n_utt_misformatted = n_utt_misformatted + 1

		# irrelevant when working with IPA
		else
			select 'tgID'
			if orthoTID>0 and orthoTID!=phonoTID
				lo$ = Get label of interval... 'orthoTID' 'i'
				call mystrip 0 0 1 'lo$'
				lo$ = mystrip.arg$
				call countwords 'lo$'
				now = countwords.return
				if now!=npw
					#try with ortho clean up
					call mystrip 0 1 1 'lo$'
					lo$ = mystrip.arg$
					call countwords 'lo$'
					now = countwords.return
					if now!=npw
						#try with ortho clean up
						call mystrip 1 1 1 'lo$'
						lo$ = mystrip.arg$
						call countwords 'lo$'
						now = countwords.return
						if now!=npw
							align_it=2
							printline Utt.# 'i' misformatted: 'ortho' has 'now' words as 'phono' tier has 'npw' words : 'lo$'
							printline vs. 'l$'
							n_utt_misformatted = n_utt_misformatted + 1
						else
							align_it=1
						endif
					else
						align_it=1
					endif
				else
					align_it=1
				endif
				lobak$=lo$
			else
				align_it=1
				printline "align_it is 'align_it'"
			endif
		endif
	endif ; empty or sil or junk int

	# START RECO

	select 'tgID'
	sp=Get starting point... 'phonoTID' 'i'
	end=Get end point... 'phonoTID' 'i'
	filedelete tmp/'basename$'_'i'.dct
	filedelete tmp/'basename$'_'i'.lab
	filedelete tmp/'basename$'_'i'.rec
	filedelete tmp/'basename$'_'i'.wav
	if align_it==1
		#printline label$ is now #'l$'#
		iw=1
		nsafe=0

		if fileReadable("tmp/'basename$'_'i'.dct")
			filedelete tmp/'basename$'_'i'.dct
		endif
		
		if fileReadable("tmp/'basename$'_'i'.lab")
			filedelete tmp/'basename$'_'i'.lab
		endif
		if precise_endpointing=0
			fileappend "tmp/'basename$'_'i'.dct" sil'tab$'sil'newline$'
		endif

		w$=""
		while length(l$)>0
			select 'tgID'
			nsafe=nsafe+1
			isp=index(l$," ")
			if isp==0
				w$=l$
				l$=""
			else 
				w$=mid$(l$,1,isp-1)
				l$=mid$(l$,isp+1,length(l$)-isp)
			endif
			w1$=w$
			
			if (left$(w1$,1)=="9") or (left$(w1$,1)=="2")
				w1$="a"+w1$
				#pause do I really come here sometimes ?
			endif
			
			# irrelevant for IPA
			if orthoTID>0 and orthoTID!=phonoTID
				ispo=index(lo$," ")
				if isp==0    ;ispo?
					wo$=lo$
					lo$=""
				else 
					wo$=mid$(lo$,1,ispo-1)
					lo$=mid$(lo$,ispo+1,length(lo$)-ispo)
				endif
				w1$=wo$
			endif

			#jpg 22aout07
			call dediacritize 'w1$'
			w1$=dediacritize.s$

			#printline here 'iw' 'w$' 'wo$'

			fileappend "tmp/'basename$'_'i'.lab" 'w1$''newline$'
			wout$=""
			if length(l$)=0
				final_space=0
			else
				final_space=1
			endif
			
			select Table 'language$'
			if (consider_star=0)
				w$=replace$(w$,"*","",0)
				call addwordtodct 'final_space' 'w$'
			else
				call countchar * 'w$'
				if countchar.n=0
					call addwordtodct 'final_space' 'w$'
				elsif countchar.n=1
					call addonestarword 'final_space' 'w$'
				elsif countchar.n=2
					istar=index(w$,"*")
					w5$=replace$(w$,"*","",1)
					call addonestarword 'final_space' 'w5$'
					w6$=left$(w5$,istar-2)+right$(w5$,length(w5$)-istar+1)
					call addonestarword 'final_space' 'w6$'
					#printline W56 |'w$'|'w5$'|'w6$'|
				endif
			endif
			
			if (allow_elision=1) and (index(wout$,"@")>0)
				wout$=replace$(wout$," @","",0)
				fileappend "tmp/'basename$'_'i'.dct" 'w1$''tab$''wout$' sp'newline$'
			endif
				
			iw=iw+1
			#    printline label$ is now !'l$'!
		endwhile

		#jpg 17.06.2008 add aux dct
		if fileReadable("lang/'language$'.dctnonono")
			auxdctID = Read Strings from raw text file... lang/'language$'.dct
			naux=Get number of strings
			for iaux to naux
				s$=Get string... 'iaux'
				fileappend "tmp/'basename$'_'i'.dct" 's$''newline$'
			endfor
			Remove
		endif
		 
		select 'tgID'
		start = Get starting point... 'phonoTID' 'i'
		end = Get end point...  'phonoTID' 'i'
		select 'soundID'
		Extract part... 'start' 'end' Rectangular 1 no
		soundpartID = selected("Sound")
		#jpg 22 aout 2007
		Scale peak... 0.99
		Write to WAV file... tmp/'basename$'_'i'.wav
		Remove
			
		if language$="slk" 
			t1$ = "-T 1"
		else
			t1$=""
		endif
			
		system HVite -A 't1$' 'bsil$' -a -m -C tmp/analysis.cfg  -H "'hmmfile$'" -t 250 "tmp/'basename$'_'i'.dct" lang/'language$'/'language$'phone1.list "tmp/'basename$'_'i'.wav" >> "tmp/reco.log"  2>&1
		if fileReadable("tmp/'basename$'_'i'.rec")==0
			printline Utt.# 'i', alignment could not be aligned. : 'lobak$'
			n_utt_notrec = n_utt_notrec +1    ; nombre de reco non reussies
		else
			n_utt_rec = n_utt_rec +1    ; nombre de reco reussies
		endif
	endif

	select 'tgID'
	if first==1
		first=0
		call findtierbyname words 0 1
		wordsTID = findtierbyname.return

		if wordsTID!=0
			if overwrite=1
				Remove tier... 'wordsTID'
				printline Overwriting previous words tier
				wordsTID=1
				Insert interval tier... 'wordsTID' words
			else
				printline Renaming previous words tier as wordsbak
				Set tier name... 'wordsTID' wordsbak
				Insert interval tier... 'wordsTID' words
			endif
		else
			wordsTID=1
			Insert interval tier... 'wordsTID' words
		endif

		call findtierbyname phones 0 1
		phonesTID = findtierbyname.return
		if phonesTID!=0
			if overwrite=1
				Remove tier... 'phonesTID'
				printline Overwriting previous phones tier
				phonesTID=1
				Insert interval tier... 'phonesTID' phones
			else
				printline Renaming previous phones tier as phonesback
				Set tier name... 'phonesTID' phonesback
				Insert interval tier... 'phonesTID' phones
			endif
		else
			phonesTID=1
			Insert interval tier... 'phonesTID' phones
		endif
		call findtierbyname words 0 1
		wordsTID = findtierbyname.return
		call findtierbyname 'ipa_tier$' 1 1
		orthoTID = findtierbyname.return
		# Ignore orthography for now. It was alredy converted (in 2nd phase from IPA to SAMPA)
		if language$=="heb"
			orthoTID = 0
			printline orthoTID 'orthoTID' phonoTID 'phonoTID'
		endif
		call findtierbyname 'sampa_tier$' 1 1
		phonoTID = findtierbyname.return

		printline wordsTID 'wordsTID' phonesTID 'phonesTID'
		

		#printline wordsTID 'wordsTID' phonesTID 'phonesTID'
		if (wordsTID !=0 or phonesTID != 0) and overwrite==1
			#pause Tier 'words' and/or 'phones already exists. Erase tiers and continue ?
			if wordsTID!=0
				Remove tier... 'wordsTID'
				Insert interval tier... 'wordsTID' words
				printline Overwriting previous words tier
			else
				#jpg 30.04.07
				if phonesTID!=0
					wordsTID=phonesTID+1
				else
					wordsTID=1
				endif
				Insert interval tier... 'wordsTID' words
			endif
			#jpg 30.04.07
			if phonesTID!=0
				Remove tier... 'phonesTID'
				Insert interval tier... 'phonesTID' phones
				printline Overwriting previous phones tier
			else
				phonesTID=wordsTID
				wordsTID=wordsTID+1
				Insert interval tier... 'wordsTID' phones
			endif
		else

			# irrelevant for IPA
			if orthoTID!=0
				mintid=min(phonoTID,orthoTID)
			else
				mintid=phonoTID
			endif
			Insert interval tier... 'mintid' words
			Insert interval tier... 'mintid' phones
			phonesTID=mintid
			wordsTID=mintid+1
			phonoTID=phonoTID+2

			# irrelevant for IPA
			if orthoTID!=0
				orthoTID=orthoTID+2
			endif
		endif
	endif
	printline before getrecc
	call getrec "tmp/'basename$'_'i'.rec" 'phonesTID' 'wordsTID' 'sp' 'language$'
	if keeptmpfile=0
		filedelete tmp/'basename$'_'i'.dct
		filedelete tmp/'basename$'_'i'.lab
		filedelete tmp/'basename$'_'i'.rec
		filedelete tmp/'basename$'_'i'.wav
	endif

	call findtierbyname 'ipa_tier$' 1 1
	ipaTID = findtierbyname.return

	if fix_ipa_in_utterance_tier = 1
		select 'tgID'
		l$ = Get label of interval... 'phonoTID' 'i'
		call sampa_to_ipa 0 'language$' 0 'l$'
		l$ = sampa_to_ipa.input_string$
		select 'tgID'
		Set interval text... 'ipaTID' 'i' 'l$'
	endif
	
	#Get label of interval... 'phonoTID' 'i'


	printline after keep
endfor

printline
if n_utt_rec!=0
	printline 'n_utt_rec' utt. aligned
	l$="'n_utt_rec' utt. aligned'newline$'"
	l$ >> tmp/log.txt
endif
if n_utt_notrec!=0
	printline 'n_utt_notrec' utt. could NOT be aligned by the speech engine. Make shorter utt.
endif
if n_utt_misformatted!=0
	printline 'n_utt_misformatted' utt. were misformated. Check spaces or SAMPA symbols...
endif
if n_utt_ignored!=0
	printline 'n_utt_ignored' utt. ignored (empty or %-junk utt)
endif
if n_utt_silence!=0
	printline 'n_utt_silence' utt. were annotated as silence (_)
endif

#pause extract initial and final pauses from phono and ortho segments
#
# extract initial and final pauses from phono and ortho segments
#
select 'tgID'
uints = Get number of intervals... 'phonoTID'
uint=1
while uint<=uints
	#get phono info
	usp = Get starting point... 'phonoTID' 'uint'
	uep = Get end point... 'phonoTID' 'uint'
	ulab$=Get label of interval... 'phonoTID' 'uint'
	if orthoTID>0
		uolab$=Get label of interval... 'orthoTID' 'uint'
	endif
	
	#get 1st PHONE info
	pint = Get interval at time... 'phonesTID' 'usp'
	psp = Get starting point... 'phonesTID' 'pint'
	pep = Get end point... 'phonesTID' 'pint'
	plab$ = Get label of interval... 'phonesTID' 'pint'
	#printline uint='uint' ('usp','uep') pint='pint' ('psp','pep') 'plab$' 'ulab$'

	if plab$=="_"
		if pep<uep
			#pause MSG 101 'pep' 'uep' 'uint' 'pint'
			if orthoTID>0
				Insert boundary... 'orthoTID' 'pep'
				Set interval text... 'orthoTID' 'uint' _
			endif
			if orthoTID!=phonoTID
				Insert boundary... 'phonoTID' 'pep'
				Set interval text... 'phonoTID' 'uint' _
			endif
			uint=uint+1
			uints=uints+1
			if orthoTID>0
				Set interval text... 'orthoTID' 'uint' 'uolab$'
			endif
			if orthoTID!=phonoTID       
				Set interval text... 'phonoTID' 'uint' 'ulab$'
			endif
		endif
	endif
	pint = Get interval at time... 'phonesTID' 'uep'

	if pint>1
		ppint = pint-1
		ppsp = Get starting point... 'phonesTID' 'ppint'
		ppep = Get end point... 'phonesTID' 'ppint'
		pplab$ = Get label of interval... 'phonesTID' 'ppint'
		#printline uint='uint' ('usp','uep') ppint='ppint' ('ppsp','ppep') 'pplab$' 'ulab$' (pint='pint')

		if (pplab$=="_") and (ppsp>usp)
			if orthoTID>0
				Insert boundary... 'orthoTID' 'ppsp'
			endif
			if orthoTID!=phonoTID
				Insert boundary... 'phonoTID' 'ppsp'
			endif
			uint=uint+1
			uints=uints+1
			if orthoTID>0
				Set interval text... 'orthoTID' 'uint' _
			endif
			if orthoTID!=phonoTID
				Set interval text... 'phonoTID' 'uint' _
			endif
		endif
	endif 
	uint=uint+1
endwhile

select 'tgID'
noints = Get number of intervals... 'phonesTID'
last$ = Get label of interval... 'phonesTID' 'noints'
nouints = Get number of intervals... 'phonoTID'
ulast$ = Get label of interval... 'phonoTID' 'nouints'
for noint from 1 to noints-1
	noint1=noints-noint
	curr$ = Get label of interval... 'phonesTID' 'noint1'
	noint2=noint1+1
	sp = Get starting point... 'phonesTID' 'noint2'
	sp1 = Get starting point... 'phonesTID' 'noint1'
	uint = Get interval at time... 'phonoTID' 'sp1'
	#printline 'phonoTID' 'uint' 'sp1' 'sp' 'noint1' 'noint2'
	sp_utt = Get starting point... 'phonoTID' 'uint'
	ucurr$ = Get label of interval... 'phonoTID' 'uint'
	#ep_utt = Get end point... 'phonesTID' 'noint2'
	#printline sp='sp' sp1='sp1' sp'_utt='sp_utt'

	if (last$=="_") and (curr$=="_") and (ulast$=="_") and (ucurr$=="_") and (sp1==sp_utt)
		#pause sp='sp' sp1='sp1' sp_utt='sp_utt'
		#phones
		Remove left boundary... 'phonesTID' 'noint2'
		Set interval text... 'phonesTID' 'noint1' _

		#words
		nint2 = Get interval at time... 'wordsTID' 'sp'
		Set interval text... 'wordsTID' 'nint2'
		Remove left boundary... 'wordsTID' 'nint2'

		#phono
		nint2 = Get interval at time... 'phonoTID' 'sp'
		Set interval text... 'phonoTID' 'nint2'
		Remove left boundary... 'phonoTID' 'nint2'

		#ortho
		if orthoTID>0 and orthoTID!=phonoTID
			nint2 = Get interval at time... 'orthoTID' 'sp'
			Set interval text... 'orthoTID' 'nint2'
			Remove left boundary... 'orthoTID' 'nint2'
		endif

	endif
	last$=curr$
	ulast$=ucurr$
endfor

#pre ptk filter 18.9.2006
if preptk_threshold>0 
	execute preptk.praat preptk_threshold phones "" words
endif

#include syllabify2.praat
if make_syllable_tier
	execute syllabify2.praat
endif

printline syllabify was executed

if keeptmpfile=0
	filedelete tmp/reco.log
	filedelete tmp/log.txt
endif

if removeMonoSound = 1
	if soundIDMono > -1
		select 'soundIDMono'
		Remove
	endif
	if soundIDMonoSampled > -1
		select 'soundIDMonoSampled'
		Remove
	endif
endif

select Table 'language$'
Remove

select 'tgID'
if by_select==0
	Write to text file... tmp/'basename$'.TextGrid
	printline TextGrid written : tmp/'basename$'.TextGrid
endif
call findtierbyname 'sampa_tier$' 1 1
phonoTID = findtierbyname.return
Remove tier... 'phonoTID'
plus 'soundID_orig'

if open_sound_and_tg
	Edit
else
	#Remove
endif


fappendinfo tmp/'basename$'.info.txt
printline Info saved in: tmp/'basename$'.info.txt


procedure getrec recfile$ phonesTID wordsTID shift language$
.verbose=0
tgID = selected("TextGrid")
if fileReadable(recfile$)

	# read rec file and convert to to IPA
	call sampa_to_ipa 'recfile$' 'language$' 1 "bla"
	select 'tgID'
	rec$ = sampa_to_ipa.input_string$

	#word in line
	wil=0
	nsafe=0
	nointphones=0
	nointwords=0
	nl=0
	intwords=0
	nwords=0
	i1=0
	
	while length(rec$)>0 ;and nsafe<4000
		if nl==1
			wil=0
			nl=0
		endif
		nsafe=nsafe+1
		isp=index(rec$," ")
		inl=index(rec$,newline$)
		if isp>0 and (isp<inl or inl==0)
			i1=isp
			wil=wil+1
		elsif inl>0 and (inl<isp or isp==0)
			i1=inl
			wil=wil+1
			nl=1
		endif

		w$=mid$(rec$,1,i1-1)
		rec$=mid$(rec$,i1+1,length(rec$)-i1)
		if .verbose=1
				printline 'wil' 'w$' 'rec_start' 'rec_end'
		endif
		if wil==1
			rec_start='w$'/10000000
		elsif wil==2
			rec_end='w$'/10000000
		elsif wil == 3 and rec_start!=rec_end
			if rec_start!=0
				rec_start=rec_start+0.015 	;tatatang.... was 0.013
			endif
			rec_start = rec_start + shift
			rec_end = rec_end + shift
			if rec_start>0
				Insert boundary... 'phonesTID' 'rec_start'
			endif
			intphones = Get interval at time... 'phonesTID' 'rec_start'
			if w$=="sp"
				Set interval text... 'phonesTID' 'intphones' _
				if rec_start != shift
					Insert boundary... 'wordsTID' 'rec_start'
					intwords1=intwords+1
					Set interval text... 'wordsTID' 'intwords1' _
				endif
			else
				select Table 'language$'
				phonerow = Search column... htk 'w$'
				if phonerow!=0
					w$=Get value... 'phonerow' sampa
				endif
				if w$=="sil"
					w$="_"
				endif
				select 'tgID'
				Set interval text... 'phonesTID' 'intphones' 'w$'
			endif
		elsif (rec_start!=rec_end) and (wil == 5)
			if rec_start>0
				Insert boundary... 'wordsTID' 'rec_start'
			endif
			if (nwords==0) and (w$=="sp")
				w$="_"
			endif
			nwords=nwords+1
			intwords = Get interval at time... 'wordsTID' 'rec_start'
			call diacritize 'w$'
			w$=diacritize.s$
			if w$=="sil"
				w$="_"
			endif
			Set interval text... 'wordsTID' 'intwords' 'w$'
		endif
	endwhile
else
	if shift!=0
		Insert boundary... 'phonesTID' 'shift'
		pint = Get interval at time... 'phonesTID' 'shift'
		Set interval text... 'phonesTID' 'pint' _
		Insert boundary... 'wordsTID' 'shift'
		wint = Get interval at time... 'wordsTID' 'shift'
		Set interval text... 'wordsTID' 'wint' _
#    printline insert p&w bound at 'shift' (pint='pint', wint='wint')
	endif
endif   ; recfile is readable
endproc

procedure wanabergo
if nt>1
	exit Please select only one TextGrid
elsif nt=1
	basename$=selected$("TextGrid")
	tgID=selected("TextGrid")
	if ns>1
		exit Please select only one Sound
	elsif ns=1
		soundID=selected("Sound")
	elsif ns=0
		if fileReadable("'basename$'.wav")
			Read from file... 'basename$'.wav
			soundID=selected("Sound")
		else
			exit File "'basename$'.wav" not readable
		endif
	endif
else ; nt=0
	if ns>1
		exit Please select only one Sound
	elsif ns=1
		soundID=selected("Sound")
		basename$=selected$("Sound")
		if fileReadable("'basename$'.TextGrid")
			Read from file... 'basename$'.Text
			tgID=selected("TextGrid")
		else
			exit File "'basename$'.TextGrid" not readable
		endif
	elsif ns=0
		#from filename field
		basename$=filename$-".wav"
		basename$=basename$-".TextGrid"
		if fileReadable("'basename$'.wav")
			Read from file... 'basename$'.wav
			soundID=selected("Sound")
		else
			exit File "'basename$'.wav" not readable
		endif
		if fileReadable("'basename$'.TextGrid")
			Read from file... 'basename$'.TextGrid
			tgID=selected("TextGrid")
		else
			exit File "'basename$'.TextGrid" not readable
		endif
	endif
endif
endproc


#jpg 22.04.2008: checks if phonoTID and orthoTID have the same boundaries
procedure checkOrthoAndPhonoTiers
if orthoTID>0
	np = Get number of intervals... 'phonoTID'
	no = Get number of intervals... 'orthoTID'
	if no!=np
		exit phono and ortho tier should have the same number of intervals. Exiting....
	endif
	for i to np
		spp=Get starting point... 'phonoTID' 'i'
		spo=Get starting point... 'orthoTID' 'i'
		if spp!=spo
			exit Starting points of interval 'i' differ in phono and ortho tiers ('spp:3', 'spo:3'). Exiting....
		endif
	endif
endif
endproc


procedure addwordtodct .final_space .w$
		call convertsampatohtk '.w$'
		if .final_space=1
			.sp$=" sp"
		else
			.sp$=""
		endif
		.wout$=replace$(convertsampatohtk.wout$," ","",1)
		fileappend "tmp/'basename$'_'i'.dct" 'w1$''tab$''.wout$''.sp$''newline$'
endproc

procedure addonestarword .final_space .w$
	.istar=index(.w$,"*")
	.w$=replace$(.w$,"*","",0)
	#printline istar0 |'.w$'|
	call addwordtodct '.final_space' '.w$'
	.w$=left$(.w$,.istar-2)+right$(.w$,length(.w$)-.istar+1)
	#printline istar0 |'.w$'|
	call addwordtodct '.final_space' '.w$'
endproc

include utils.praat
include ipa_to_sampa_to_ipa.praat