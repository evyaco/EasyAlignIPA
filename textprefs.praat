procedure textEncodingPreferences
Read Strings from raw text file... C:\Documents and Settings\goldman\Praat\Preferences5.ini
.ns=Get number of strings
for .i to .ns
  .s$=Get string... '.i'
  if index(.s$,"TextEncoding.inputEncoding:")
    .teie$=extractLine$(s$,"TextEncoding.inputEncoding: ")
  elsif index(.s$,"TextEncoding.outputEncoding:")
    .teoe$=extractLine$(.s$,"TextEncoding.outputEncoding: ")
  endif
endfor
#printline '.teie$'
#printline '.teoe$'
endproc


#Text reading preferences... try UTF-8, then Windows Latin-1


