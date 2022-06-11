clearinfo
eadir$=preferencesDirectory$+"\plugin_easyalign\"
Read from file... spa.wav
Read Strings from raw text file... spa.txt
pause Sound and transcription loaded. Launch step#1 Utterance segmentation ?
select Sound spa
plus Strings spa
execute "'eadir$'utt_seg2.praat" ortho yes
pause Utterance segmentation done. Launch step#2 Phonetisation ?
editor TextGrid spa
 Close
endeditor
execute "'eadir$'phonetize_orthotier2.praat" ortho phono spa yes yes
pause Phonetisation. Launch step#3 Phoneme Segmentation ?
editor TextGrid spa
 Close
endeditor
select Sound spa
plus TextGrid spa
execute "'eadir$'align_sound.praat" ortho phono yes spa }^}-':;(),.?¿ no yes no 90 yes yes
   
