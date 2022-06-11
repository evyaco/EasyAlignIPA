# from an ortho tier, phonetize 
# jeanphilippegoldman@gmail.com
# tregunc - july 06
# mornex  - dec 06
# may08 plugf multitel phonetizer for fr and en

#form 2.Phonetisation : phonetize orthographic tier to phonetic tier

# evyaco@gmail.com
# June 2022: initial Hebrew support

form 2. IPA to SAMPA
comment Select one or more TextGrid(s)
word ipa_tier IPA
word sampa_tier SAMPA
comment Choose a language
optionmenu language: 1
		option heb
    option fra
		option en
		option spa
		option spa (seseo)
		option porbra
		option slk
comment If sampa_tier exists,
boolean overwrite_sampa_tier 1
comment After phonetisation
boolean open_textgrid 1
endform
clearinfo
keeptmpfile=0
#option sw
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
  if ipa_tier$=""
    ipa_tier$="ortho"
  endif
  call findtierbyname 'ipa_tier$' 1 1
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
    if language$!="heb"
      call mystrip 0 0 1 's$'
      l$=mystrip.arg$
    else
      l$=s$
    endif
    if index(l$,newline$)>0
      l$ = replace_regex$(l$,newline$," ",0)
    endif
    if language$!="heb"
      l$=replace_regex$(l$,".*","\L&",1)
    endif
    if language$="slk"
      call lowercaseslovak 'l$'
      l$=lowercaseslovak.r$
    endif
    Set interval text... 'orthoTID' 'i' 'l$'
  endfor

  #look for an existing phono tier
  call findtierbyname 'sampa_tier$' 0 1
  phonoTID=findtierbyname.return
  if phonoTID!=0
    if overwrite_sampa_tier=1
      Remove tier... 'phonoTID'
      if phonoTID<orthoTID
        orthoTID=orthoTID-1
      endif
    endif
  endif
  Duplicate tier... 'orthoTID' 'orthoTID' 'sampa_tier$'
  phonoTID=orthoTID
  orthoTID=orthoTID+1


  #for i to nint
  #  l$=Get label of interval... 'phonoTID' 'i'
  #  if mid$(l$,1,1)=="%"
  #    Set interval text... 'phonoTID' 'i'
  #  endif
  #endfor

  ###############################################################################
  #     save ortho to t.txt  launch external phonetizer   #  
  ###############################################################################

  iID=Extract tier... 'phonoTID'
  trID=Down to TableOfReal (any)
  sID=Extract row labels as Strings

  createDirectory("tmp")
  printline Language : 'language$'
  tmpDir$="tmp\"
  langDir$="lang\'language$'\"
  filedelete 'tmpDir$'tout.txt

  if language$=="fra" or language$=="en"
    ns=Get number of strings
    s2ID = Copy... phono
    Text writing preferences... try ISO Latin-1, then UTF-16
    Text reading preferences... try UTF-8, then ISO Latin-1
    printline 'langDir$'phon250.exe 'langDir$'phon250.'language$'.ini 'tmpDir$'t.txt 'tmpDir$'tout.txt
    for i to ns
      select sID
      s$=Get string... 'i'
      #pause 's$'
      if s$="_" or s$="" or left$(s$,1)="%"
      else
        filedelete tmp/t.txt
        fileappend tmp/t.txt 's$'
        system 'langDir$'phon250.exe 'langDir$'phon250.'language$'.ini 'tmpDir$'t.txt 'tmpDir$'tout.txt

        s3ID=Read Strings from raw text file... tmp/tout.txt
        ns3=Get number of strings
        s$=""
        for i3 to ns3
          s3$=Get string... 'i3'
          s$=s$+s3$
        endfor
        Remove
        select s2ID
        Set string... 'i' 's$'
      endif
    endfor

  elsif language$=="sw"
    Write to raw text file... 'langDir$'/t.txt
    system cd lang && cd sw && psw.exe t.txt tout.txt 
    s2ID=Read Strings from raw text file... 'langDir$'/tout.txt
    
  elsif language$=="spa" or language$=="spa (seseo)"
    Text writing preferences... try ISO Latin-1, then UTF-16
    Text reading preferences... try UTF-8, then ISO Latin-1
    seseo$=""
    if language$="spa (seseo)"
      seseo$="-MS"
      language$="spa"
      langDir$="lang\'language$'\"
    endif
    #suppress uppercase for SAGA
    Change... .* \L& 0 Regular Expressions
    Write to raw text file... tmp/t.txt
    printline 'langDir$'saga.exe -MX 'seseo$' 'tmpDir$'t.txt 'tmpDir$'tout.txt
    system 'langDir$'saga.exe -MX 'seseo$' 'tmpDir$'t.txt 'tmpDir$'tout.txt
    s4ID=Read Strings from raw text file... tmp/tout.txt.fon
    s3ID=Change... r 4 0 Literals
    s2ID=Change... 44 r 0 Literals
    #suppress - syllabic boundary
    select s4ID
    plus s3ID
    Remove
    select s2ID
  elsif language$=="porbra"
    #one word per line
    Change... " " \n 0 Regular Expressions
    #lowercase only
    Change... .* \L& 0 Regular Expressions
    Change... ? ? 0 Literals

    Text writing preferences... UTF-8
    Write to raw text file... 'tmpDir$'t.txt
    #  system 'langDir$'tcclapsG2P.exe 'tmpDir$'t.txt false
    #  system move dicionariofoneticohifen.txt 'tmpDir$'tout.txt
    #  filedelete vogaistonicashifen.txt
    printline  system 'langDir$'lapsG2UFPB.exe 'tmpDir$'t.txt false 'langDir$'tabela
    printline  system move 'langDir$'dicionariofonetico.txt 'tmpDir$'tout.txt
    system 'langDir$'lapsG2UFPB.exe 'tmpDir$'t.txt false 'langDir$'tabela
    system move dicionariofonetico.txt 'tmpDir$'tout.txt
    s3ID=Read Strings from raw text file... 'tmpDir$'tout.txt
    #pour chaque Strings de sID, compter les mots, pop n strings de s2ID pour une nouvelle string de s2ID
    select sID
    s2ID = Copy... phono
    ns=Get number of strings
    sindex=1
    printline 'ns' phrases
    for i to ns
      select sID
      s$=Get string... i
      s$ = replace_regex$(s$ , "[^ ]","",0)
      nw=length(s$)
      select s3ID
      sout$= Get string... sindex
      sout$ = replace_regex$(sout$ , "^.*    ","",1)
      sout$ = replace_regex$(sout$ , " ","",0)
      for j from 1 to nw
        sout2$ = Get string... sindex+j
        sout2$ = replace_regex$(sout2$ , "^.*    ","",1)
        sout2$ = replace_regex$(sout2$ , " ","",0)
        sout$ = sout$ + " " +sout2$
      endfor
      sindex = sindex+nw+1
      select s2ID
      sout$=replace_regex$(sout$,"R","h/",0)
      sout$=replace_regex$(sout$,"X","h/",0)
      sout$=replace_regex$(sout$,"r","4",0)
      Set string... i 'sout$'
    endfor
    select s3ID
    Remove
  elsif language$=="slk"
    Text writing preferences... UTF-8
    Text reading preferences... try UTF-8, then ISO Latin-1
    Write to raw text file... 'tmpDir$'t.txt
    
    system 'langDir$'slk.exe 'tmpDir$'t.txt 'tmpDir$'tout.txt 
    s3ID=Read Strings from raw text file... 'tmpDir$'tout.txt
    s4ID=Change... "![^ ]!" "" 0 Regular Expressions
    s5ID=Change... "   " # 0 Regular Expressions
    s6ID=Change... " " "" 0 Regular Expressions
    s2ID=Change... # " " 0 Regular Expressions
    select s3ID
    plus s4ID
    plus s5ID
    plus s6ID
    Remove
    select s2ID
  elsif language$=="heb"
  
    s2ID = Copy... phono
    
    select Table 'language$'
    num_of_rows = Get number of rows
    for i from 1 to num_of_rows 
      select Table 'language$'
      ipa_char$ = Get value... i ipa
      sampa_char$ = Get value... i sampa
      if (ipa_char$ <> "") and (sampa_char$ <> "")
        #printline "ipa is 'ipa_char$' and sampa is 'sampa_char$'!"
        old_s2ID = s2ID
        select s2ID
        s2ID = Change... 'ipa_char$' 'sampa_char$' 0 Regular Expressions
        select old_s2ID
        Remove
      endif
    endfor
    select Table 'language$'
    Remove
    select s2ID
  endif
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

include utils.praat
#  & timeout /T -1