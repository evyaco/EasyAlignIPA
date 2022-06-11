form One-click phone segmentation with EasyAlign
comment Select exactly a Sound and a Strings object
comment Transcription tier:
word ortho_tier ortho
  comment Choose a language
optionmenu language: 1
		option fra
		option spa
		option porbra
		option slk		
endform

if numberOfSelected("Sound")!=1 or numberOfSelected("Strings")!=1
  exit Select exactly a Sound object and a Strings object
endif
clearinfo
sID=selected("Sound")
eadir$=preferencesDirectory$+"\plugin_easyalign\"
execute "'eadir$'utt_seg2.praat" 'ortho_tier$' no
tgID=selected("Sound")
select tgID
execute "'eadir$'phonetize_orthotier2.praat" 'ortho_tier$' phono 'language$' yes  no
select tgID
plus sID
execute "'eadir$'align_sound.praat" ortho phono yes 'language$' }?^ no yes no 90 yes yes
   
