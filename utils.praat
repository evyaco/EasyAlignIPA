apath$=""
procedure checksampa .s$
  .n=length(.s$)
  .return=0
#  printline checking '.s$'
  .i=1
  while .i<=.n
    .c$=mid$(.s$,.i,1)
    #    print '.i' '.c$'
    if (index(" _hptkbdgfsSvzZlRmnjwHieEaAoOuy29@XN:r",.c$)>0)
      if (index("aeo9",.c$)>0) and (.i<.n)
#        print is aeo9
        .c2$=mid$(.s$,.i+1,1)
        if (.c2$=="~")
          .i=.i+1
#          printline isnasal
        endif
      endif
    elsif .c$=="B"
      if .i<=.n-3
        .mid$=mid$(.s$,.i,4)
        if .mid$=="BRTH"
          .i=.i+3
        endif
      endif
    endif
#    printline
    .i=.i+1
  endwhile
endproc


procedure checksampa2 .s$ .language$ .allow$
#printline '.language$'  '.s$'
  select Table '.language$'
  .n=length(.s$)
  .return=0
#printline checking #'.s$'#
  .i=1
  .msg$=""
  .cont=1
  while (.i<=.n)&(.cont=1)
    .convrow=0
    if .i<.n-2
      .c2$=mid$(.s$,.i,4)
      .convrow = Search column... sampa '.c2$'
#printline search #'.c2$'# , found '.convrow'
      if .convrow!=0
        .c3$=Get value... '.convrow' htk
        .i=.i+3
      endif
    endif
    if (.convrow=0) and (.i<.n-1)
      .c2$=mid$(.s$,.i,3)
      .convrow = Search column... sampa '.c2$'
#printline search #'.c2$'# , found '.convrow'
      if .convrow!=0
        .c3$=Get value... '.convrow' htk
        .i=.i+2
      endif
    endif
    if (.convrow=0) and (.i<.n)
      .c2$=mid$(.s$,.i,2)
      .convrow = Search column... sampa '.c2$'
#printline search #'.c2$'# , found '.convrow'
      if .convrow!=0
        .c3$=Get value... '.convrow' htk
       .i=.i+1
      endif
    endif
    if (.convrow=0)
      .c2$=mid$(.s$,.i,1)
      .convrow = Search column... sampa '.c2$'
#printline search #'.c2$'# , found '.convrow'
      if .convrow!=0
        .c3$=Get value... '.convrow' htk
      elsif index(.allow$,.c2$)>0
        .c3$=""
      else
        .msg$="('.c2$') '.i'th char is not sampa in '.s$'"
        .cont=0
      endif
    endif
    .i=.i+1
  endwhile
endproc

procedure checknl .s$
  .n=length(.s$)
  .return=0
#  printline checking '.s$' '.n'
  .i=1
  while .i<=.n
    .c$=mid$(.s$,.i,1)
#    .tmp=index(" ptkbdgfsSvzZGhxmnNJrljwIEAOY@aeiouy2",.c$)
#    printline '.i' '.c$' '.tmp'
    if index(" ptkbdgfsSvzZGhxmnNJrljwIEAOY@aeiouy2",.c$)>0
      if ((.c$="e")or(.c$="A")) and (.i<.n)
        .c2$=mid$(.s$,.i,2)
        if (.c2$=="ei") or (.c2$=="eu") or (.c2$=="ey") or (.c2$=="Au")
          .i=.i+1
        endif
      endif
    else
     .return=1
     .wrongc$=.c$
     .wrongi=.i
    endif
    .i=.i+1
  endwhile

endproc

procedure convertsampatohtk .w$
  .wout$=""
  for .ii to length(.w$)
    .convrow=0
    if .ii<length(.w$)-2
      .c2$=mid$(.w$,.ii,4)
      .convrow = Search column... sampa '.c2$'
      if .convrow!=0
        .c2$=Get value... '.convrow' htk
        .ii=.ii+3
      endif
    endif
    if (.convrow=0) and (.ii<length(.w$)-1)
      .c2$=mid$(.w$,.ii,3)
      .convrow = Search column... sampa '.c2$'
      if .convrow!=0
        .c2$=Get value... '.convrow' htk
        .ii=.ii+2
      endif
    endif
    if (.convrow=0) and (.ii<length(.w$))
      .c2$=mid$(.w$,.ii,2)
      .convrow = Search column... sampa '.c2$'
      if .convrow!=0
        .c2$=Get value... '.convrow' htk
        .ii=.ii+1
      endif
    endif
    if (.convrow=0)
      .c2$=mid$(.w$,.ii,1)
      .convrow = Search column... sampa '.c2$'
      if .convrow!=0
        .c2$=Get value... '.convrow' htk
      endif
    endif
    .wout$=.wout$+" "+.c2$
  endfor
endproc

procedure convertgeneral .from$ .to$ .w$
  .sep$=newline$
  #printline '.w$' '.from$' '.to$'
  .verbose =0
  .status=0
  .wout$=""
  for .ii to length(.w$)
    .convrow=0
    .c2$=mid$(.w$,.ii,1)
    if .c2$=" "
    else
      if .ii<length(.w$)-1
        .c2$=mid$(.w$,.ii,3)
        if .verbose
          print '.ii' '.c2$'/
        endif
        if .c2$!="   "
          .convrow = Search column... '.from$' "'.c2$'"
          if .convrow!=0
            .c2$=Get value... '.convrow' '.to$'
            .ii=.ii+2
            if .verbose
              printline '.c2$' FOUND
             endif
           endif
        endif
      endif
      if (.convrow=0) and (.ii<length(.w$))
        .c2$=mid$(.w$,.ii,2)
        if .verbose
          print '.ii''.c2$'/
        endif
        if .c2$!="  "
          .convrow = Search column... '.from$' '.c2$'
          if .convrow!=0
            .c2$=Get value... '.convrow' '.to$'
            .ii=.ii+1
            if .verbose
              printline '.c2$' FOUND
            endif
          endif
        endif
      endif
      if (.convrow=0)
        .c2$=mid$(.w$,.ii,1)
        if .verbose
          print '.ii''.c2$'/
        endif
        if .c2$!=" "
          .convrow = Search column... '.from$' '.c2$'
          if .convrow!=0
            .c2$=Get value... '.convrow' '.to$'
            if .verbose
              printline '.c2$' FOUND
            endif
          else
            printline '.c2$' UNKNOWN CHAR ('.ii')
            .status=-1
          endif
        else
#          print _
        endif
      endif
      .wout$=.wout$+.c2$+.sep$
    endif
  endfor
  if .verbose
    printline *'.wout$'*
  endif
endproc

#find a tier by name
#if second arg is >0, if does not exists, exit
#if third >0, check also if interval tier, if not: exit

procedure findtierbyname .name$ .v1 .v2
  .n = Get number of tiers
  .return = 0
  for .i to .n
    .tmp$ = Get tier name... '.i'
    if .tmp$==.name$
      .return = .i
    endif
  endfor
  if  (.return == 0) and (.v1 > 0)
    exit Tier ''.name$'' not found in TextGrid. Exiting...
  endif
  if  (.return > 0) and (.v2>0)
    .i = Is interval tier... '.return'
    if .i==0
      exit Tier #'.return' named '.name$' is not an interval tier. Exiting...
    endif
  endif
endproc


#countwords
procedure countwords .arg$
.nsafe=0
.return=0
while length(.arg$)>0 ;and .nsafe<300
#  printline countwords 's$'
  .nsafe=.nsafe+1
  .isp=index(.arg$," ")    ;index of space char
  .return=.return+1
  if .isp==0
    .arg$=""
  else 
    .arg$=mid$(.arg$,.isp+1,length(.arg$)-.isp)
  endif
endwhile
endproc

procedure removepunct .arg$
      .arg$=replace$(.arg$,""""," ",0)
      .arg$=replace$(.arg$,"/"," ",0)
      .arg$=replace$(.arg$,"("," ",0)
      .arg$=replace$(.arg$,")"," ",0)
      .arg$=replace$(.arg$,"."," ",0)
      .arg$=replace$(.arg$,"?"," ",0)
      .arg$=replace$(.arg$,"!"," ",0)
      .arg$=replace$(.arg$,";"," ",0)
      .arg$=replace$(.arg$,":"," ",0)
      .arg$=replace$(.arg$,","," ",0)
      .arg$=replace$(.arg$,"«"," ",0)
      .arg$=replace$(.arg$,"»"," ",0)
      .arg$=replace$(.arg$,"#"," ",0)
      .arg$=replace$(.arg$,"|"," ",0)
      .arg$=replace$(.arg$,"<"," ",0)
      .arg$=replace$(.arg$,">"," ",0)
      .arg$=replace$(.arg$,"*"," ",0)
      .arg$=replace$(.arg$,"/"," ",0)
      .arg$=replace_regex$(.arg$,"\t"," ",0)
#      .arg$=replace$(.arg$,"'"," ",0)
#      .arg$=replace$(.arg$,"-"," ",0)
      .arg$=replace$(.arg$," - "," ",0)

endproc
      
procedure removespaces arg1 arg2 arg3 .arg$

   while (arg1 >0) and (left$(.arg$,1)==" ") 		;remove leading spaces
     .arg$ = right$(.arg$,length(.arg$)-1)
   endwhile
   while (arg2 >0) and (right$(.arg$,1)==" ") 		;remove trailing spaces
     .arg$ = left$(.arg$,length(.arg$)-1)
   endwhile
   if (arg3 > 0) and (index(.arg$,"  ")>0)	        ;remove mutliple space
     .arg$=replace_regex$(.arg$," + "," ",0)
   endif
endproc

procedure mystrip separate_the_quote delete_the_dash remove_punct .arg$

#replace quote by true-quote
  .arg$=replace$(.arg$,"’","'",0)
#add space after ,
  .arg$=replace$(.arg$,",",", ",0)

#add space after '
  if separate_the_quote==1
    .arg$=replace$(.arg$,"'","' ",0)
  endif

#delete dashes
  if delete_the_dash==1
    .arg$=replace$(.arg$,"-"," ",0)
  endif

#remove punct
  if remove_punct
    call removepunct '.arg$'
    .arg$=removepunct.arg$
  endif

  call removespaces 1 1 1 '.arg$'
  .arg$ = removespaces.arg$
endproc

procedure loaddic basename$ warn_if_no_cat load_main_dic

if load_main_dic==1
  dic$="dic.txt"
  Read Table from tab-separated file... 'dic$'
  n=Get number of rows
  max=n
  printline Loaded 'max' words from main dictionary
else
  Create Table with column names... dic 0 ortho phono clitic
  n=0
  max=0
endif
dicID=selected("Table")

#insert aux dic
if fileReadable("'basename$'.dic")
  Read Table from tab-separated file... 'basename$'.dic
  auxdicID=selected("Table")
  
  select 'auxdicID'
  n=Get number of rows
  nc = Get number of columns
  if nc==2
    printline Warning : Your auxiliary dic has only two columns.
    clitic$="0"
  elsif nc!=3
    exit Your auxiliary dic has 'nc' columns. Should be 2 or 3.
  endif
  for i to n
    select 'auxdicID'
    o$ = Get value... 'i' ortho
    p$ = Get value... 'i' phono
    
    if nc==3
      clitic$ = Get value... 'i' clitic
    else 
      clitic$="0"
    endif
    
    if p$=="?"
      printline In auxiliary dic, word 'o$' is not phonetized !!!
    else
      call checksampa 'p$'
    endif
    if clitic$=="0" and warn_if_no_cat==1
      printline In auxiliary dic, word 'o$' has no clitic info !!!
    endif
    select 'dicID'
    Insert row... 1
    Set string value... 1 ortho 'o$'
    Set string value... 1 phono 'p$'
    Set string value... 1 clitic 'clitic$'
    
  endfor
  printline Loaded 'n' words from your local dictionary
else
  #create table for unknown words
  Create Table with column names... unknown_words 0 ortho phono clitic
  auxdicID=selected("Table")
  printline No local dictionary found
endif
endproc

procedure countchar .c$ .s$
.n=0
.i=index(.s$,.c$)
#printline FIRST '.i' '.s$'
while .i>0
  .n=.n+1
  .s$=right$(.s$,length(.s$)-.i-length(.c$)+1)
  .i=index(.s$,.c$)
  #printline '.i' '.s$'
endwhile
endproc

procedure textEncodingPreferences
  Read Strings from raw text file... 'preferencesDirectory$'\Preferences5.ini
  .ns=Get number of strings
  for .i to .ns
    .s$=Get string... '.i'
    if index(.s$,"TextEncoding.inputEncoding:")
      .teie$=extractLine$(.s$,"TextEncoding.inputEncoding: ")
    elsif index(.s$,"TextEncoding.outputEncoding:")
      .teoe$=extractLine$(.s$,"TextEncoding.outputEncoding: ")
    endif
  endfor
  printline Saving text encodings prefs... (Will be restored if script does not stop in the meantime)
  printline Reading: '.teie$'
  printline Writing: '.teoe$'
  Remove
endproc

procedure resumeTextEncodingPreferences
  Text reading preferences... 'textEncodingPreferences.teie$'
  Text writing preferences... 'textEncodingPreferences.teoe$'
endproc


#jpg 22aout07
procedure dediacritize .s$
      .s$=replace_regex$(.s$,"č","\\304\\215",0);
      .s$=replace_regex$(.s$,"Ľ","\\304\\275",0);
      .s$=replace_regex$(.s$,"ľ","\\304\\276",0);      
      .s$=replace_regex$(.s$,"š","\\305\\241",0);
      .s$=replace_regex$(.s$,"ť","\\305\\245",0);
      .s$=replace_regex$(.s$,"Ž","\\305\\275",0);
      .s$=replace_regex$(.s$,"ž","\\305\\276",0);
      .s$=replace_regex$(.s$,"à","\\340",0);
      .s$=replace_regex$(.s$,"á","\\341",0);
      .s$=replace_regex$(.s$,"â","\\342",0);
      .s$=replace_regex$(.s$,"ã","\\343",0);
      .s$=replace_regex$(.s$,"ä","\\344",0);
      .s$=replace_regex$(.s$,"å","\\345",0);
      .s$=replace_regex$(.s$,"æ","\\346",0);
      .s$=replace_regex$(.s$,"ç","\\347",0);
      .s$=replace_regex$(.s$,"è","\\350",0);
      .s$=replace_regex$(.s$,"é","\\351",0);
      .s$=replace_regex$(.s$,"ê","\\352",0);
      .s$=replace_regex$(.s$,"ë","\\353",0);
      .s$=replace_regex$(.s$,"ì","\\354",0);
      .s$=replace_regex$(.s$,"í","\\355",0);
      .s$=replace_regex$(.s$,"î","\\356",0);
      .s$=replace_regex$(.s$,"ï","\\357",0);
      .s$=replace_regex$(.s$,"ñ","\\360",0);
      .s$=replace_regex$(.s$,"ò","\\361",0);
      .s$=replace_regex$(.s$,"ó","\\362",0);
      .s$=replace_regex$(.s$,"ô","\\363",0);
      .s$=replace_regex$(.s$,"õ","\\364",0);
      .s$=replace_regex$(.s$,"ö","\\365",0);
      .s$=replace_regex$(.s$,"ù","\\371",0);
      .s$=replace_regex$(.s$,"ú","\\372",0);
      .s$=replace_regex$(.s$,"ý","\\375",0);      
endproc

procedure diacritize .s$
      .s$=replace_regex$(.s$,"\\304\\215","č",0);
      .s$=replace_regex$(.s$,"\\304\\275","Ľ",0);
      .s$=replace_regex$(.s$,"\\304\\276","ľ",0);      
      .s$=replace_regex$(.s$,"\\305\\241","š",0);
      .s$=replace_regex$(.s$,"\\305\\245","ť",0);
      .s$=replace_regex$(.s$,"\\305\\275","Ž",0);
      .s$=replace_regex$(.s$,"\\305\\276","ž",0);
      .s$=replace_regex$(.s$,"\\340","à",0);
      .s$=replace_regex$(.s$,"\\341","á",0);
      .s$=replace_regex$(.s$,"\\342","â",0);
      .s$=replace_regex$(.s$,"\\343","ã",0);
      .s$=replace_regex$(.s$,"\\344","ä",0);
      .s$=replace_regex$(.s$,"\\345","å",0);
      .s$=replace_regex$(.s$,"\\346","æ",0);
      .s$=replace_regex$(.s$,"\\347","ç",0);
      .s$=replace_regex$(.s$,"\\350","è",0);
      .s$=replace_regex$(.s$,"\\351","é",0);
      .s$=replace_regex$(.s$,"\\352","ê",0);
      .s$=replace_regex$(.s$,"\\353","ë",0);
      .s$=replace_regex$(.s$,"\\354","ì",0);
      .s$=replace_regex$(.s$,"\\355","í",0);
      .s$=replace_regex$(.s$,"\\356","î",0);
      .s$=replace_regex$(.s$,"\\357","ï",0);
      .s$=replace_regex$(.s$,"\\360","ñ",0);
      .s$=replace_regex$(.s$,"\\361","ò",0);
      .s$=replace_regex$(.s$,"\\362","ó",0);
      .s$=replace_regex$(.s$,"\\363","ô",0);
      .s$=replace_regex$(.s$,"\\364","õ",0);
      .s$=replace_regex$(.s$,"\\365","ö",0);
      .s$=replace_regex$(.s$,"\\371","ù",0);
      .s$=replace_regex$(.s$,"\\372","ú",0);
      .s$=replace_regex$(.s$,"\\375","ý",0);

endproc

procedure lowercaseslovak .r$
  .u$="ÁÄČĎÉĚÍĹĽŇÓÖŔŘŠŤÚŮÜÝŽ"
  .l$="áäčďéěíĺľňóöŕřšťúůüýž"
  for .i to length(.u$)
    .r$=replace_regex$(.r$,mid$(.u$,.i,1),mid$(.l$,.i,1),0);
  endfor
endproc

procedure findtierbyname2 .verbose .var$ .name$
  .n = Get number of tiers
  '.var$' = 0
  .i=1
  while .i<=.n
    .tmp$ = Get tier name... '.i'
    #printline +'.tmp$'+'.name$'+
    if .tmp$ =.name$
      '.var$' = .i
      if .verbose
        printline Tier '.name$' found in TextGrid : '.i' 
      endif
    endif
    .i=.i+1
  endwhile
endproc
