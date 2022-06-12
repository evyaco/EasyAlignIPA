# EasyAlignHebrew
EasyAlign plugin for Praat with support for Hebrew analysis

* See a [video manual](https://openu.zoom.us/rec/share/9Yg_xeE5SnXKK7jh9y0ivqcB_fJ2hSFTUm139Y4LAJZgkPfIxE3fZZzWg9PwWPrg.Fcwbn87UjyPBE5rh?startTime=1654683393000) and visit [the project's page](https://www.openu.ac.il/en/omilab/pages/Phoneme-Aligner.aspx).
* Read about [EasyAlign](http://latlcui.unige.ch/phonetique/easyalign.php) - there you can find additional manuals, installations and publications.

Simple Manual:
You will need a sound file and a transcription text file divided to lines; each line represents an utterance. The text must be represented in IPA.
1. Open -> Read strings from raw text file... and choose the text file.
2. Open -> Read from file... and choose the sound file.
3. Select both files in Praat's objects list
4. Praat -> EasyAlign -> Macro-segmentation...
5. View the sound and the new textgrid (together) and fix the utterances borders if needed.
6. Select the textgrid file
7. Praat -> EasyAlign -> IPA to SAMPA...
8. Select the sound file and the textgrid
9. Praat -> EasyAlign -> Phone segmentation...
10. View the sound and the textgrid and fix the words/syllables/phonemes tiers if needed.

EasyAlign was written by jeanphilippegoldman@gmail.com (2007-2011)

Hebrew support by evyaco@gmail.com and vereds@openu.ac.il (2022)


The work described here has been funded by the Research Authority of The Open University of Israel, grant 41459. 

Please cite as:
Vered Silber-Varod, Evan Cohen, Evyatar Cohen, Inbar Strull, Vered Aharonson. (manuscript). [Towards a Public Segment Catalogue of Spoken Hebrew](https://www.researchgate.net/publication/360463146_Towards_a_Public_Segment_Catalogue_of_Spoken_Hebrew).
