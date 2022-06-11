form preptk
real preptk_threshold 90
word phonestier phones
word sylltier syll
word wordstier words
endform

call findtierbyname2 0 phonesTID 'phonestier$'
call findtierbyname2 0 syllTID 'sylltier$'
call findtierbyname2 0 wordsTID 'wordstier$'

n = Get number of intervals... 'phonesTID'
ll$=""
ld=0
i=1
preptk_threshold=preptk_threshold/1000
nptk=0
while i<=n

  l$= Get label of interval... 'phonesTID' 'i'
  sp= Get starting point... 'phonesTID' 'i'
  ep= Get end point... 'phonesTID' 'i'
  d=ep-sp
  if (l$=="p" or l$=="t" or l$=="k" or l$=="D") and ll$=="_" and (ld < preptk_threshold)
    #phones
    Remove boundary at time... 'phonesTID' 'sp'
    i1=i-1
    Set interval text... 'phonesTID' 'i1' 'l$'
    i=i-1
    n=n-1
    
    if wordsTID!=0
      #words
      wi=Get interval at time... 'wordsTID' 'sp'
      wsp= Get starting point... 'wordsTID' 'wi'
      wl$=Get label of interval... 'wordsTID' 'wi'
      if wsp=sp
        Remove boundary at time... 'wordsTID' 'sp'
        wi1=wi-1
        Set interval text... 'wordsTID' 'wi1' 'wl$'
      endif
      #stats printline 'l$' 'ld' 'sp' 'wl$'
      nptk=nptk+1
    endif
    if syllTID!=0
      wi=Get interval at time... 'syllTID' 'sp'
      wsp= Get starting point... 'syllTID' 'wi'
      wl$=Get label of interval... 'syllTID' 'wi'
      if wsp=sp
        Remove boundary at time... 'syllTID' 'sp'
        wi1=wi-1
        Set interval text... 'syllTID' 'wi1' 'wl$'
      endif
    endif
    
  endif
  ll$=l$
  ld=d
  i=i+1
endwhile
preptk_threshold=preptk_threshold*1000
printline Pre-PTK filter : 'nptk' silences removed (threshold was 'preptk_threshold' ms)

include utils.praat