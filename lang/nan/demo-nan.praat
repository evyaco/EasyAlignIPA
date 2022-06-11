clearinfo
n$="chx_twmin"
Read from file... 'n$'.wav
Read from file... 'n$'.TextGrid
plus Sound 'n$'
Edit
pause Sound and transcription loaded. Launch step#3 Phoneme Segmentation ?
editor TextGrid 'n$'
 Close
endeditor
select Sound 'n$'
plus TextGrid 'n$'
execute "../../align_sound.praat" phono phono yes nan }?^ yes yes no 90 yes yes
 
