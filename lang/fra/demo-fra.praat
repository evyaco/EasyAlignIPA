clearinfo
eadir$=preferencesDirectory$+"\plugin_easyalign\"
Read from file... prince.wav
Read Strings from raw text file... prince.txt
pause Sound and transcription loaded. Launch step#1 Utterance segmentation ?
select Sound prince
plus Strings prince
execute "'eadir$'utt_seg2.praat" ortho yes
pause Utterance segmentation done. Launch step#2 Phonetisation ?
editor TextGrid prince
 Close
endeditor
select TextGrid prince
execute "'eadir$'phonetize_orthotier2.praat" ortho phono fra yes  yes
pause Phonetisation. Launch step#3 Phoneme Segmentation ?
editor TextGrid prince
 Close
endeditor
select Sound prince
plus TextGrid prince
execute "'eadir$'align_sound.praat" ortho phono yes fra }?^ no yes no 90 yes yes
   
