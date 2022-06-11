form Naive Segmentation
  comment Segment a sentence phono tier into segmental phones tier
  comment Choose a language below or Select a phone Table
  optionmenu language: 1
	option fr
	option en
	option es
	option tw
  word colname sampa
  comment Select one or more TextGrid(s)
  word sentence_tier phono
  word chars_to_ignore _}^;:-,.()'?*
  boolean ignore_space_char 1
  word phones_tier phones
  boolean segment_only_unaligned_utterances  1
  boolean add_external_pauses_before_segmentation 1
endform

#todo
#check if chars to ignore belongs to phone list in table
#ignore already aligned utterances
#allow to overwrite already aligned utterances
#add to EA setup
#test on several TGs
#use intrinsic durations in phone tables ? :(

clearinfo
call process_selection
select tphonesID
call get_longest_string_in_column 'colname$'
maxlength=get_longest_string_in_column.maxlength

for tgi to ntg
  select tg'tgi'ID
  tgID=selected("TextGrid")
  tgname$=selected$("TextGrid")
  call findtierbyname 'sentence_tier$' 1 1
  phonoTID=findtierbyname.return

  call findtierbyname 'phones_tier$' 0 1
  phonesTID=findtierbyname.return
  if phonesTID=0
    Insert interval tier... 1 'phones_tier$'
    phonesTID=1
  endif
  call findtierbyname 'sentence_tier$' 1 1
  phonoTID=findtierbyname.return
  epfinal=Get end time
  
  nint=Get number of intervals... phonoTID
  for int to nint

    l$=Get label of interval... phonoTID int
    if ignore_space_char
      l$=replace$(l$," ","",0)
    endif
    for k to length(chars_to_ignore$)
      l$=replace$(l$,mid$(chars_to_ignore$,k,1),"",0)
    endfor
    if add_external_pauses_before_segmentation
      l$="_"+l$+"_"
    endif
    sp=Get start point... phonoTID int
    ep=Get end point... phonoTID int
    dur=ep-sp
    
    nc=0
    #count phones
    select tphonesID
    while length(l$)>0
      call getnextphone 'l$'
      p$=getnextphone.c$
      l$=right$(l$,length(l$)-length(p$))
      nc=nc+1
      c'nc'$=p$
      #pause 'p$'<='l$'
    endwhile
    
#pause 'nc' phones 'c1$' 'c2$'    
    #add phones
    select tgID
    for nci to nc
      t=sp+dur*(nci-1)/nc
      call addboundary phonesTID t
      phint=Get interval at time... phonesTID t
      p$=c'nci'$
      Set interval text... phonesTID phint 'p$'
    endfor

    #add a final boundary
    call addboundary phonesTID ep
    
  endfor
endfor


####################################
procedure addboundary .tid .t
  .int=Get interval at time... .tid .t
  .t2=Get start point... .tid .int
  #printline 'i' 'len' 'dur' 'sp' 't:3' 't2:3'
  if .t2<.t and .t!= epfinal
    Insert boundary... .tid .t
  elsif .t2>.t
     pause ??
  else
    # id , boundary already exists
  endif
endproc

procedure getnextphone .l$
  .k=maxlength
  .c$=""
  while .k>0
    .c$=left$(.l$,.k)
    .lc=Search column... 'colname$' '.c$'
    #printline 'l$'>>search "'l2$'">>'lc'
    if .lc!=0
      #printline Found col '.lc' '.c$' => '.l$'
      .k=0
    elsif (length(.l$))>0 and (.k==1)
      #printline unknown char "'.c$'"
      .k=.k-1
    else
      .k=.k-1
    endif
    #pause '.k' '.lc' '.c$'
  endwhile
endproc

################################

#should be in utils.praat (same as in checkphonesintiers.praat)

procedure process_selection
  nt=numberOfSelected("Table")
  ntg=numberOfSelected("TextGrid")
  if nt>1
    exit Select one Table at max
  elsif nt=1
    tphonesID=selected("Table")
  else
    tphonesID=0
  endif
  if ntg=0
    exit Select at least one TextGrid
  endif
  for i to ntg
    tg'i'ID=selected("TextGrid",i)
    tg'i'name$=selected$("TextGrid",i)
  endfor
  if tphonesID=0
    #read a tablea
    if language$="(language)"
      exit Select a Table object or a language in the list !
    else
      tphonesID=Read Table from tab-separated file... lang/'language$'.Table
    endif
  endif
endproc


procedure findtierbyname .name$ .v1 .v2
#.v1 exits if tiername not found
#.v2 exists if tier is point tier
  .n = Get number of tiers
  .return = 0
  for .i to .n
    .tmp$ = Get tier name... '.i'
    if .tmp$==.name$
      .return = .i
    endif
  endfor
  if  (.return == 0) and (.v1 > 0)
    exit Tier '.name$' not found in TextGrid. Exiting...
  endif
  if  (.return > 0) and (.v2>0)
    .i = Is interval tier... '.return'
    if .i==0
      exit Tier #'.return' named 'f.name$' is not an interval tier. Exiting...
    endif
  endif
endproc

procedure get_longest_string_in_column .colname$
  .nr=Get number of rows
  .maxlength=0
  .maxi=0
  .maxstring$=""
  for .i to .nr
    .l$=Get value... .i '.colname$'
    if length(.l$)>.maxlength
      .maxlength=length(.l$)
      .maxi=.i
    endif
  endfor
  if .maxi>0
    .maxstring$=Get value... .maxi '.colname$'
  endif
endproc
