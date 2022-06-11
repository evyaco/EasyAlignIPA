form check phones in tier
  comment Choose a language below or Select a phone Table
  optionmenu language: 1
		option (language)
		option fr
		option en
		option es
		option tw
  word colname sampa
  comment Select a TextGrid
  word tiername phono
  word chars_to_ignore _}?^~;:-,.()'¿
  boolean ignore_space_char 1
endform
do_stat_table=1

clearinfo

call process_selection

select tphonesID
call get_longest_string_in_column 'colname$'
maxlength=get_longest_string_in_column.maxlength

if do_stat_table
  select tphonesID
  Append column... TOTAL
endif
for i to ntg
  select tg'i'ID
  tgname$=selected$("TextGrid")
  if do_stat_table
    select tphonesID
    Append column... 'tgname$'
    select tg'i'ID
  endif
  printline TextGrid 'tgname$'
  call findtierbyname 'tiername$' 1 1
  phonesTID=findtierbyname.return
  nint=Get number of intervals... 'phonesTID'
  for j to nint
    select tg'i'ID
    l$=Get label of interval... phonesTID j
    if ignore_space_char
      l$=replace$(l$," ","",0)
    endif
    for k to length(chars_to_ignore$)
      l$=replace$(l$,mid$(chars_to_ignore$,k,1),"",0)
    endfor

    #call check phones in an interval
    select tphonesID
    k=maxlength
    while length(l$)>0
      l2$=left$(l$,k)
      lc=Search column... 'colname$' 'l2$'
      #printline 'l$'>>search "'l2$'">>'lc'
      if lc!=0
        c$=Get value... 'lc' 'colname$'
        l$=right$(l$,length(l$)-k)
        #printline Found col 'lc' 'c$' => 'l$'
        k=maxlength
        if do_stat_table
          ncount = Get value... 'lc' 'tgname$'
          if ncount=undefined
            ncount=0
          endif
          ncount = ncount + 1
          Set numeric value... 'lc' 'tgname$' 'ncount'
	endif
      elsif (length(l$))>0 and (k==1)
        printline In int#'j', unknown char "'l2$'"
        l$=right$(l$,length(l$)-1)
      else
        k=k-1
      endif
    endwhile
  endfor
endfor
select tphonesID
ncol=Get column index... TOTAL
ncol2=Get number of columns
nrows=Get number of rows
for i to nrows
  s=0
  for j from ncol+1 to ncol2
    s3$=Get column label... j
    s2=Get value... i 's3$'
    if s2=undefined
      s2=0
    endif
    s=s+s2
  endfor
  Set numeric value... i TOTAL s
endfor


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
#.v2 exist if tier is point tier
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
