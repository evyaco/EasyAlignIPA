form check textgrids
	optionmenu language: 1
		option fr
		option es
		option sw
		option tw
	boolean check_phones 1
	boolean check_syll 1
	boolean check_words 1
endform

#clearinfo

if numberOfSelected("TextGrid")=1
  tgID=selected("TextGrid")
else
  exit select one and only one textgrid
endif

if check_phones==1
  select 'tgID'
  call findtierbyname phones 0
  phonesTID = findtierbyname.r
  if phonesTID==0
    exit No phones tier found....
  endif
  n=Get number of intervals... 'phonesTID'
  printline
  printline Check report on 'n' phones
  Read from file... lang/'language$'.Table
  tID=selected("Table")
  nnul=0
  nsil=0
  nnon=0
  noui=0
  for i from 1 to n
    select 'tgID'
    l$ = Get label of interval... 'phonesTID' 'i'
    if l$=""
    	nnul=nnul+1
    	printline In phones tier, interval #'i' is empty
    elsif l$="_"
    	nsil=nsil+1
    else
    	select 'tID'
        c=Search column... sampa 'l$'
    	if c==0
    	  nnon=nnon+1
       	  printline In phones tier, interval #'i' is not valid ('l$')
    	else
    	  noui=noui+1
    	endif
    endif
  endfor
  printline Check report on 'n' phones
  printline  'nsil' sil (_) phones
  printline  'noui' correct phones
  printline  'nnon' incorrect phones
  printline  'nnul' empty phones
  select 'tID'
  Remove
endif

if check_syll==1
  select 'tgID'
  call findtierbyname phones 0
  phonesTID = findtierbyname.r
  call findtierbyname syll 0
  syllTID = findtierbyname.r
  if syllTID==0
    exit No syll tier found....
  endif
  n=Get number of intervals... 'syllTID'
  printline
  printline Check report on 'n' sylls
  Read from file... 'language$'.Table
  tID=selected("Table")
  nnul=0
  nsil=0
  nnon=0
  noui=0
  nnovow=0
  nmulvow=0
  
  for i from 1 to n
    select 'tgID'
    
    if i>1
      sp = Get starting point... 'syllTID' 'i'
      spi = Get interval at time... 'phonesTID' 'sp'
      sp2 = Get starting point... 'phonesTID' 'spi'
      if sp!=sp2
        printline In syll tier, interval #'i' is not starting at a phoneme start
      endif
    endif  
    
    l$ = Get label of interval... 'syllTID' 'i'
    if l$=""
    	nnul=nnul+1
    	printline In syll tier, interval #'i' is empty
    elsif l$="_"
    	nsil=nsil+1
    else
      select 'tID'
      v=0
      for ii to length(l$)
        length_phonetosearch=3
        c=0
        while (length_phonetosearch>=1) and (c=0)
          if ii<length(l$)-length_phonetosearch+2
            c2$=mid$(l$,ii,length_phonetosearch)
            c = Search column... sampa 'c2$'
            if c!=0
              ii=ii+length_phonetosearch-1
              v2=Get value... 'c' voy
              v=v+v2
            else
              if length_phonetosearch=1
                ii=ii+1
              endif
            endif
#            printline search 'l$' 'ii' 'c2$' 'c' 'length_phonetosearch' 'v2' 'v'
          endif
          length_phonetosearch=length_phonetosearch-1
        endwhile
      endfor
      if c=0
  	  nnon=nnon+1
     	  printline In syll tier, interval #'i' is not valid ('l$')
      else
    	  if v>1
       	    printline In syll tier, interval #'i' has 'v' vowels ('l$')
    	    nmulvow=nmulvow+1
    	  elsif v=0
       	    printline In syll tier, interval #'i' has no vowel ('l$')
    	    nnovow=nnovow+1
    	  else
    	    noui=noui+1
    	  endif
      endif
    endif
  endfor
  printline Check report on 'n' sylls
  printline  'nsil' sil (_) sylls
  printline  'noui' correct sylls
  printline  'nmulvow' sylls with multiple vowels
  printline  'nnovow' sylls with no vowel
  printline  'nnon' incorrect sylls
  printline  'nnul' empty sylls
  select 'tID'
  Remove
endif


if check_words==1
  select 'tgID'
  call findtierbyname phones 0
  phonesTID = findtierbyname.r
  call findtierbyname words 0
  wordsTID = findtierbyname.r
  if wordsTID==0
    exit No words tier found....
  endif
  n=Get number of intervals... 'wordsTID'
  printline
  printline Check report on 'n' words
  nnul=0
  nsil=0
  noui=0
  
  for i from 1 to n
    select 'tgID'
    if i>1
      sp = Get starting point... 'wordsTID' 'i'
      spi = Get interval at time... 'phonesTID' 'sp'
      sp2 = Get starting point... 'phonesTID' 'spi'
      if sp!=sp2
        printline In words tier, interval #'i' is not starting at a phoneme start
      endif
    endif  
    
    
    
    l$ = Get label of interval... 'wordsTID' 'i'
    if l$=""
    	nnul=nnul+1
    	printline In words tier, interval #'i' is empty
    elsif l$="_"
    	nsil=nsil+1
    else
      noui=noui+1
    endif
  endfor
  printline  'nsil' sil (_) words
  printline  'noui' correct words
  printline  'nnul' empty words
endif

procedure findtierbyname .name$ .verbose
  .n = Get number of tiers
  .return = 0
  .i=1
  while .i<=.n
    .tmp$ = Get tier name... '.i'
    if .tmp$ =.name$
      .return = .i
      if .verbose
        printline Tier '.name$' found in TextGrid : '.return'
      endif
    endif
    .i=.i+1
  endwhile
  .r=.return
endproc

procedure mydate str$
date$ = date$()
#printline >>> 'date$' 'str$'
endproc
