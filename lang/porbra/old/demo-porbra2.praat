clearinfo
Read from file... porbra.wav
Read Strings from raw text file... porbra.txt
pause Sound and transcription loaded. Launch step#1 Utterance segmentation ?
select Sound porbra
plus Strings porbra
execute "../../utt_seg2.praat" ortho yes
select TextGrid untitled
Rename... porbra
pause Utterance segmentation done. Launch step#2 Phonetisation ?
editor TextGrid porbra
 Close
endeditor
execute "../../phonetize_orthotier2.praat" ortho phono porbra yes  yes
pause Phonetisation. Launch step#3 Phoneme Segmentation ?
editor TextGrid porbra
 Close
endeditor
select Sound porbra
plus TextGrid porbra
execute "../../align_sound.praat" ortho phono yes porbra }^}-':;(),.?¿ no yes no 90 yes yes
   
