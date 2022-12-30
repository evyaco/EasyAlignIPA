# from an ortho tier, phonetize 
# jeanphilippegoldman@gmail.com
# tregunc - july 06
# mornex  - dec 06
# may08 plugf multitel phonetizer for fr and en

#form 2.Phonetisation : phonetize orthographic tier to phonetic tier

# June 2022: IPA support (for Hebrew) by evyaco@gmail.com for OMILab (vereds@openu.ac.il)

procedure ipa_to_sampa_stage .language$ .ipa_tier$ .sampa_tier$
	overwrite_sampa_tier = 1
	open_textgrid = 1
	keeptmpfile=0
	#########################
	#check selected objects #
	#########################

	printline
	printline ###EASYALIGN: Phonetize ortho tier
	ntg=numberOfSelected("TextGrid")
	if ntg<1
		exit Select at least one TextGrid
	endif
	for i to ntg
		t'i'ID=selected("TextGrid",i)
		t'i'$=selected$("TextGrid",i)
	endfor

	Read from file... lang/'language$'/'language$'.Table

	for itg to ntg

		tgID=t'itg'ID
		select tgID
		tgname$=selected$("TextGrid")
		printline ###TG 'itg'/'ntg' 'tgname$'
		call textEncodingPreferences

		#########################
		#find ortho tier        #
		#########################

		select 'tgID'
		call findtierbyname '.ipa_tier$' 1 1
		orthoTID=findtierbyname.return
		orthotiername$=Get tier name... 'orthoTID'
		print Using tier #'orthoTID' ('orthotiername$')



		#########################
		#     clean ortho       #
		#########################

		nint=Get number of intervals... 'orthoTID'
		printline with 'nint' intervals
		for i to nint
			s$=Get label of interval... 'orthoTID' 'i'
			if index(s$,newline$)>0
				s$ = replace_regex$(s$,newline$," ",0)
			endif
			Set interval text... 'orthoTID' 'i' 's$'
		endfor

		#look for an existing phono tier
		call findtierbyname '.sampa_tier$' 0 1
		phonoTID=findtierbyname.return
		if phonoTID!=0
			if overwrite_sampa_tier=1
				Remove tier... 'phonoTID'
				if phonoTID<orthoTID
					orthoTID=orthoTID-1
				endif
			endif
		endif
		Duplicate tier... 'orthoTID' 'orthoTID' '.sampa_tier$'
		phonoTID=orthoTID
		orthoTID=orthoTID+1


		iID=Extract tier... 'phonoTID'
		trID=Down to TableOfReal (any)
		sID=Extract row labels as Strings

		s2ID = Copy... phono
  
		select Table 'language$'
		num_of_rows = Get number of rows
		for i from 1 to num_of_rows 
			ipa_char$ = Get value... i ipa
			sampa_char$ = Get value... i sampa
			printline the ipa is 'ipa_char$' and the sampa is 'sampa_char$'
			if (ipa_char$ <> "") and (sampa_char$ <> "")
				#printline "ipa is 'ipa_char$' and sampa is 'sampa_char$'!"
				old_s2ID = s2ID
				select s2ID
				s2ID = Change... 'ipa_char$' 'sampa_char$' 0 Regular Expressions
				select old_s2ID
				Remove
			endif
			select Table 'language$'
		endfor
		select Table 'language$'
		Remove

		call resumeTextEncodingPreferences
		select 'trID'
		plus 'sID'
		plus 'iID'
		Remove

		####################################
		#     read phono from new strings  # 
		####################################

		for i to nint
			select 's2ID'
			p$=Get string... 'i'
			if language$="fra" or language$="en" 
				p$=replace$(p$," ","",0)
				p$=replace$(p$,"|"," ",0)
				p$=replace$(p$,"_","",0)
				p$=replace$(p$,"  "," ",0)
				while (right$(p$,1)==" ")
					p$ = left$(p$,length(p$)-1)
				endwhile
			endif
			select 'tgID'
			Set interval text... 'phonoTID' 'i' 'p$'
			l$=Get label of interval... 'orthoTID' 'i'
			if left$(l$,1)=="%" or l$=""
				Set interval text... 'phonoTID' 'i'
			elsif l$="_"
				Set interval text... 'phonoTID' 'i' _
			endif
		endfor

		if keeptmpfile=0
			filedelete tout.txt
			filedelete t.txt
		endif

		# redo junk ,etc...

		select 's2ID'
		Remove
		if open_textgrid
			select 'tgID'
					
			#Remove tier... 'orthoTID'
			#Duplicate tier... 'phonoTID' 'phonoTID' ortho
			Edit
		endif

	endfor
endproc

# """""Generic""""" for any string in a specific language [for this specific scripts language no procedure will help]
procedure sampa_to_ipa .rec_file$ .lang$ .should_read_from_file .string_when_no_file$
  printline rec file is '.rec_file$'
  #.output_string$ = .input_string$
  # adds language table object
  if .should_read_from_file = 1
    .input_string$ < '.rec_file$'
  else
    .input_string$ = .string_when_no_file$
  endif
  printline language is '.lang$'
  Read from file... lang/'.lang$'/'.lang$'.Table
  select Table '.lang$'
  num_of_rows = Get number of rows
  for curr_row from 1 to num_of_rows 
    ipa_char$ = Get value... curr_row ipa
    sampa_char$ = Get value... curr_row sampa
    if (ipa_char$ <> "") and (sampa_char$ <> "")
      #printline "ipa is 'ipa_char$' and sampa is 'sampa_char$'!"
      .input_string$ = replace$(.input_string$, sampa_char$, ipa_char$, 0)
    endif
  endfor

  printline the input string after is '.input_string$'

  # removes language table object
  Remove
endproc

include utils.praat
#  & timeout /T -1