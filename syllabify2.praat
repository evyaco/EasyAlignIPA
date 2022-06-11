tgID=selected("TextGrid")
include utils.praat
debug=0
printline Syllabify...
select 'tgID'
    call findtierbyname words 1 1
    wordsTID = findtierbyname.return
    call findtierbyname phones 1 1
    phonesTID = findtierbyname.return
#    call findtierbyname phono 1 1
#    phonoTID = findtierbyname.return
    call findtierbyname syll 0 1
    syllTID = findtierbyname.return

   # printline 'tgID' 'phonesTID' 'syllTID' 'wordsTID'

   #jpg 09.02.2006
   #from a selected TextGrid with phone tier in tier 1
   #duplicate first (phone) tier to second (syl) tier

    #rwhichinfo 1=sil 2=ptkbdgvf 3=sSzZTD 4=lR4mnxX 5=jhw 6=vowel 

   if syllTID==0
     syllTID=phonesTID+1
     Duplicate tier... 'phonesTID' 'syllTID' syll
     printline Creating syll tier
#     if wordsTID>=syllTID
#       wordsTID=wordsTID+1
#     endif
#     if phonoTID>=syllTID
#       phonoTID=phonoTID+1
#     endif
     
   else
     Remove tier... 'syllTID'
     syllTID=phonesTID+1
     Duplicate tier... 'phonesTID' 'syllTID' syll
#     Insert interval tier... 'syllTID' syll
     printline Overwriting previous syll tier
   endif

#printline "start"
current = Get number of intervals... 'syllTID'
#printline 'current'

labeln$=""
nncat=0
ncat=0
call getccat
call getcpcat
call getcppcat
#  printline phonesTID ='phonesTID'
#  printline syllTID ='syllTID'
#  printline wordsTID ='wordsTID'
#  printline phonoTID ='phonoTID'
#  printline orthoTID ='orthoTID'

#current=140

while current > 1
time = Get starting point... 'syllTID' 'current'
wint = Get interval at time... 'wordsTID' 'time'
word$ = Get label of interval... 'wordsTID' 'wint'
ft=floor(time)


call myprint 'ft' 'labelpp$' 'labelp$'.'label$' 'labeln$' 'labelnn$' 'cppcat' 'cpcat'.'ccat' 'ncat' 'nncat' ('word$') ==>
  if ccat = 6
    if cpcat= 2 or cpcat=3 or cpcat=4 or cpcat=5
      call delcurrent
    endif
  elsif ccat = 5
    if cpcat= 2
      if ncat = 6
        call delcurrent
      endif
    elsif cpcat= 3
      if ncat = 3			;mO~tan-j-nO~
        call delcurrent
      elsif ncat = 6
        #profes-j-onel
        call delcurrent
      elsif ncat= 4 			;i n.j l  @ 6 3 5 4 6 (désigne)
        call delcurrent
      elsif ncat=1			;i n.j _  l 6 3 5 1 4 (désigne)
        call delcurrent
      endif
    elsif cpcat= 4 
      if ncat = 6 			; mOr-j-En
        call delcurrent
      endif
    elsif cpcat= 6
      if ncat = 5 or ncat = 4 or ncat= 3 or ncat= 2 or ncat=1
        call delcurrent
      endif
    endif
  elsif ccat = 4
    if cpcat= 2
      if ncat = 1 or ncat= 5 or ncat = 6 	; egza~p-l-sil  at-R-wa
        call delcurrent
      elsif ncat=2 and nncat=6 and cppcat=6  	; va~d-Rdabor (ameline)
        call delcurrent
      elsif ncat=2 and nncat=6 and cppcat=3  	; (mini)st.Rp(uR in ministre pour)
        call delcurrent
      elsif ncat=2 and nncat=4 and cppcat=6  	; o t.R p  R 6 2 4 2 4 (autres) ==>
        call delcurrent
      elsif ncat=3 and cppcat=6  		;i v R s  @ 6 2 4 3 (livre) ==>
        call delcurrent
      elsif ncat=3 and cppcat=3  		; (mini)st.Rn(@sEs) ministre ne cesse
        call delcurrent
      elsif ncat==4 				;a b.l l  E 6 2 4 4 6 (véritable) ==>
        call delcurrent
      endif
    elsif cpcat= 3
    #  if ncat = 3
    #    #mO~tan-j-nO~
    #    call delcurrent
    #  elsif ncat = 6
    #    #profes-j-onel
    #    call delcurrent
    #  endif
    elsif cpcat= 4 or cpcat= 5
      if ncat=2 or ncat=1
        call delcurrent
      endif
    elsif cpcat= 6
      if ncat = 4 or ncat= 3 or ncat= 2 or ncat= 1
        # 1=e-R-sil
        # was ncat = 5 or mor-j-en
        call delcurrent
      endif
    endif
  elsif ccat = 3
    if cpcat= 6
      if ncat=4 or ncat = 3 or ncat = 2 or ncat = 1
        call delcurrent
      elsif ncat = 5 and (nncat=3 or nncat=4 or nncat=1)	; mo~ta-n-jno~py (ameline)
      								; z i.n j  l 3 6 3 5 4 (désigne)
      								; z i.n j  _ 3 6 3 5 1 (désigne)
        call delcurrent
      endif
    elsif cpcat= 4
      if ncat = 1 or ncat =2 or ncat =3 			; al-m-sil  aR-m-dujE wouteR-snu
        call delcurrent
      elsif ncat=6 and cppcat=1					; _l.ministre
        call delcurrent
      endif
    elsif cpcat= 3
      if ncat=2 and nncat=6 and cppcat=6			; e~pas.stupide
      elsif ncat = 1 or ncat =2					;a-m-s?  domEn-s-kjabl
        call delcurrent
      elsif cppcat=1						; sil Z-m@, sil-m-s@ (lucchini 275.35)
        call delcurrent
      endif
    elsif cpcat= 2
      if cppcat = 1						;_psk@ lucchini 31.04
        call delcurrent
      elsif cppcat = 4						;_doublure d-son  vet'ment wouters 133s
        call delcurrent
      elsif cppcat = 6 and ncat=3				; E k.s s  e 6 2 3 3 6 (circonflexe)
        call delcurrent
      elsif cppcat = 6 and ncat=1				; 0 i k.s _  6 2 3 1 0 (s) ==>  "ekonomiks"
        call delcurrent
      elsif cppcat=5						;j d.Z E  s 5 2 3 6 3 (Digest) ==>
        call delcurrent
      endif
    endif
  elsif ccat = 2  
    if cpcat= 6
      if ncat = 1 or ncat = 2
        #or ncat = 3
        # sporti-f-sil kara-k-tEr ak-sjo~
        call delcurrent
      elsif ncat = 3
        if nncat=2 or nncat=6 or nncat=5 or nncat=3		;l E.k s  s 4 6 2 3 3 (circonflexe)
          							; e-k-sperja~s toute-cette ak-sjo~
								;0 m i.k s _ 3 6 2 3 1 (konomiks) ==>
          call delcurrent
        elsif nncat=1
          call delcurrent
        endif
      elsif ncat = 4
        if nncat=1 or nncat=2 or nncat=3 or nncat=4		; va~-dRdabor (ameline)
          							; egza~-p-l-sil
          							; l i.v R  s 4 6 2 4 3 (livre) ==>
								; t a.b l  l 2 6 2 4 4 (véritable) ==>
          call delcurrent
        endif
      endif
    elsif cpcat= 3
      if ncat = 2 or ncat=1					; pis-t-purdenuvodebuSe  pis-k
        call delcurrent
      elsif ncat=4 and nncat=1					; minis.tR_
        call delcurrent
      elsif ncat=4 and (nncat=3 or nncat=2 or nncat=4)		; minis.tRn(@...)  minis.tRp(uR) minis.tR(la)
        call delcurrent
      elsif ncat=6 and cppcat=3					; pass.tu
        call delcurrent
      elsif cppcat = 2 or cppcat=1				; eks-p-erja~s  _s-ki
        call delcurrent
      endif
    elsif cpcat= 4
      if ncat = 2 						; savwajar-d-d@lamorjEn
        call delcurrent
      elsif ncat=1 						;E R.b _  m 6 4 2 1 3 (verbe)
        call delcurrent
      elsif ncat=4 and nncat=1 					;9 R.t R  _ 6 4 2 4 1 (meutre) ==>
        call delcurrent
      elsif cppcat=1						; _l.vi
      	call delcurrent
      endif
    elsif cpcat= 2
      if cppcat = 1						; _p-t
        call delcurrent
      endif
    endif
  elsif ccat = 1 ;sil
  endif
  call zap
call myprint NL
endwhile




procedure delcurrent
  start = Get starting point... 'syllTID' 'current'
  #check if not beg of utt
#  uint = Get interval at time... 'phonoTID' 'start'
#  usp = Get starting point... 'phonoTID' 'uint'
#  if usp<start
    Remove boundary at time... 'syllTID' 'start'
    call myprint DEL
#  endif
endproc

procedure zap
  current = current -1
  nncat=ncat
  ncat=ccat
  ccat=cpcat
  cpcat=cppcat
  labelnn$=labeln$
  labeln$=label$
  label$=labelp$
  labelp$=labelpp$
  call getcppcat
endproc

procedure whichpho2 pho$
  rwhichpho=0
#  if (index_regex(pho$,"^\[.*\]$"))=1
#    printline silence: 'pho$'
#  endif
  if pho$="sil" or pho$="" or pho$="_" or pho$=""  or pho$="-"  or pho$="*" or (index_regex(pho$,"^\[.*\]$")=1)
    rwhichpho = 1
  else
    pho2$ = left$(pho$,1)
    if index ("aAeEoOiuy@269", pho2$) > 0
      rwhichpho = 6
    elsif index ("BGptkbdgfvc", pho2$) > 0
      rwhichpho = 2
    elsif index ("TDsSzZmnNJ", pho2$) > 0
      rwhichpho = 3
    elsif pho$="jj"
      rwhichpho = 3
    elsif index ("lLrRXxh4", pho2$) > 0
      rwhichpho = 4
    elsif index ("jwH", pho2$) > 0
      rwhichpho = 5
    else
      printline UNKNOWN'pho$'
    endif
  endif
endproc 

procedure getccat
  
  label$= Get label of interval... 'syllTID' 'current'
  call whichpho2 'label$'
  ccat=rwhichpho
endproc

procedure getcpcat
if current>1
  cp=current-1
  labelp$= Get label of interval... 'syllTID' 'cp'
  call whichpho2 'labelp$'
  cpcat=rwhichpho
else
  cpcat=0
endif
endproc

procedure getcppcat
if current >2
  cpp=current-2
  labelpp$= Get label of interval... 'syllTID' 'cpp'
  call whichpho2 'labelpp$'
  cppcat=rwhichpho
else
  cppcat=0
endif
endproc

procedure myprint myprint_s$
if debug=1
  if myprint_s$=="NL"
    printline
  else
    print 'myprint_s$'
  endif
endif
endproc

