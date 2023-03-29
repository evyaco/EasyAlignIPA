# EasyAlignIPA
Plugin for Praat allowing auto-segmentation: automatically creates tiers of IPA utterances, words, syllables and phonemes based on a text file and a sound file.

[EasyAlign](http://latlcui.unige.ch/phonetique/easyalign.php) was written by jeanphilippegoldman@gmail.com (2007-2011)

EasyAlignIPA version with Hebrew support by evyaco@gmail.com for OmiLab veredsilber@gmail.com (2022). For using this version see a video manual ([English](https://openu.zoom.us/rec/share/9Yg_xeE5SnXKK7jh9y0ivqcB_fJ2hSFTUm139Y4LAJZgkPfIxE3fZZzWg9PwWPrg.Fcwbn87UjyPBE5rh?startTime=1654683393000) or [Hebrew](https://openu.zoom.us/rec/play/nGu3CeXSg3XtV3ioldy-FfUQbDCL30n7-LQjA6neI2cYSyU0tnZmiZA6LZrXLq9kPuYop3A2LcxFZVzP.y-39NAiaqtuxcYZ3?startTime=1655014775000&_x_zm_rtaid=UB7KabwnQqWButWneFNRtQ.1655035123155.ba6434aef661507106a37360ccbee35a&_x_zm_rhtaid=940)) and visit [the project's page](https://www.openu.ac.il/en/omilab/pages/Phoneme-Aligner.aspx).


Simple Manual:\
You will need a sound file and a transcription text file divided to lines; **8each line represents an utterance**. The text must be represented in IPA.
1. Open -> Read strings from raw text file... and choose the text file.
2. Open -> Read from file... and choose the sound file.
3. Select both files in Praat's objects list
4. Praat -> EasyAlignIPA -> Macro-segmentation...
5. View the sound and the new textgrid (together) and fix the utterances borders if needed.
6. Select the sound file **and** the textgrid
9. Praat -> EasyAlignIPA -> Phone segmentation...
10. View the sound and the textgrid and fix the words/syllables/phonemes tiers if needed.


The work described here has been funded by the Research Authority of The Open University of Israel, grant 41459. 

Please cite:\
Silber-Varod, V., E. Cohen, I. Strull, E. G. Cohen (2023). A Catalogue of the Hebrew Sounds, ADHO Digital Humanities Conference 2023: Collaboration as Opportunity, July 10-14 2023, Graz, Austria.

More reading:\
Vered Silber-Varod, Evan Cohen, Evyatar Cohen, Inbar Strull, Vered Aharonson. (manuscript). Towards a Public Segment Catalogue of Spoken Hebrew.
