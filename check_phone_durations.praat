form Check phone duration
	word phonetier phones
	word outliersphonetier outliers
	word phones_to_exclude _
	real alpha 0.02
endform

tgID=selected("TextGrid")
#jpg 26.01.2008
#get phonetier and outlierphonestier
#create if nec.
call findtierbyname 'phonetier$' 1
phonesTID=findtierbyname.return
if phonesTID=0
  exit
endif
call findtierbyname 'outliersphonetier$' 1
if findtierbyname.return=0
  outliersTID=phonesTID+1
  Duplicate tier... 'phonesTID' 'outliersTID' 'outliersphonetier$'
else
  outliersTID=findtierbyname.return
endif

sum=0
sum2=0
small=0
large=0
#pause phonesTID='phonesTID' outliersTID='outliersTID'
tierID=Extract tier... 'phonesTID'
tableID=Down to TableOfReal (any)
i=1
n=Get number of rows
while i<=n
  l$=Get row label... 'i'
#  printline 'i' 'n' 'phones_to_exclude$' 'l$' 
  if index(phones_to_exclude$,l$)!=0
    Remove row (index)... 'i'
#    printline Remove
    n=n-1
  else 
    i=i+1
  endif
endwhile

table2ID=To Table... rowLabel
lower = Get quantile... Duration 'alpha'
alpha2=1-alpha
upper = Get quantile... Duration 'alpha2'

printline Lower and uppers limits to alert : 'lower' 'upper'

#2eme parcours des phonemes
#si out of -2s +2s, add to outliers_phonetier_phones
select 'tgID'
ni=Get number of intervals... 'phonesTID'
for i to ni
  l$=Get label of interval... 'phonesTID' 'i'
  if index(phones_to_exclude$,l$)=0
    sp=Get starting point... 'phonesTID' 'i'
    ep=Get end point... 'phonesTID' 'i'
    if (ep-sp<=lower)
      Set interval text... 'outliersTID' 'i' -
      small=small+1
    elsif (ep-sp>=upper)
      Set interval text... 'outliersTID' 'i' + 
      large=large+1
    else
      Set interval text... 'outliersTID' 'i' 
    endif
  endif
endfor

printline 'ni' total phones
printline Small phones :'small'/'n'
printline Large phones :'large'/'n'
select 'tableID'
plus 'table2ID'
plus 'tierID'
Remove
select 'tgID'

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
endproc
