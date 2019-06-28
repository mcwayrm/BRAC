clear
set more off
log close _all

/*****************
Description:
	 TUP endline enumerator training Quiz grading
	 
*****************/

global USER "Ryan McWay"
local date `c(current_date)'
local time `c(current_time)'
local home "<local>"
//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
cd "`home'"
local input	"`home'\input"
local edit "`home'\edit"
local output "`home'\output"
**************************************************************************
display "Analysis run by $USER at `date' and `time'"

**************************************************************************

//********** Day 2 Quiz

do "`home'\scripts\import_tup_quiz.do"

foreach v of varlist duration project q_section2 q_section3 q_section5_acres q_section5 q_section11{
	destring `v', replace
}

replace name = strproper(name)
drop if name == "Ryan" | name == "Mutebi Ronald" | name == "Agatha Nakidde"

gen id = .
replace id = 1 if name == "Duchu Henry"
replace id = 2 if name == "Bukirwa Rebecca"
replace id = 3 if name == "Wanna Sarah"
replace id = 4 if name == "Malengo Douglas"
replace id = 5 if name == "Namutamba Esther"
replace id = 6 if name == "Nakidde Agatha"
replace id = 7 if name == "Charles Mulondo"
replace id = 8 if name == "Ismail Musana"
replace id = 9 if name == "Namatovu Bukenya Harriet"
replace id = 10 if name == "Waiswa Jimmy"
replace id = 11 if name == "Oundo Joseph"
replace id = 12 if name == "Steven"
replace id = 13 if name == "Aheebwa Aishah"
replace id = 15 if name == "Nsubuga Paul"
replace id = 16 if name == "Kanyemera Fridah"
replace id = 17 if name == "Namatovu Catherine"
replace id = 18 if name == "Namugoya Susan"
replace id = 19 if name == "Nevis Bukirwa"
replace id = 20 if name == "Shamim Nalukenge"
replace id = 21 if name == "Lydia"
replace id = 22 if name == "Chloe"
replace id = 23 if name == "Nalubwama"
replace id = 24 if name == "Nantume"
replace id = 25 if name == "David"
replace id = 26 if name == "Apio"
replace id = 27 if name == "Ahimbisibwe"
replace id = 28 if name == "Omiat"
replace id = 29 if name == "Shafik"
replace id = 30 if name == "Nabukeera"
replace id = 31 if name == "Juliet"
replace id = 32 if name == "Nayiga"
replace id = 33 if name == "Prossie"
replace id = 34 if name == "Moses"
replace id = 35 if name == "Awachango"
replace id = 36 if name == "Wafula"
duplicates drop id, force

egen score_d2 = rowmean(project q_section2 q_section3 q_section5_acres q_section5 q_section11)
sum project q_section2 q_section3 q_section5_acres q_section5 q_section11 score_d2
list name if score_d2 == 1

/*********
	NOTES:
		Would be easier for merge if we already had everyones name in a mult choice selection, then could just match on #.
		Section 11 was very difficult for people
		
		
*********/


save "`edit'\tup_quiz_day2.dta", replace 

**************************************************************************

//********** Day 3 Quiz

do "`home'\scripts\import_tup_quiz_day2.do"

drop if name == "RESEARCH PROJECT AND HELPING THE NEEDY"

gen id = .
replace id = 1 if name == "Duchu henry"
replace id = 2 if name == "Bukirwa Rebecca"
replace id = 3 if name == "Wanga sarah" | name == "Wanga Sarah"
replace id = 4 if name == "Malengo Douglas"
replace id = 5 if name == "Namutamba Esther"
replace id = 6 if name == "Nakidde Agatha"
replace id = 7 if name == "Charles Mulondo"
replace id = 8 if name == "Ismail musana"
replace id = 9 if name == "Namatovu Bukenya Harriet"
replace id = 10 if name == "Waiswa jimmy"
replace id = 11 if name == "Oundo joseph"
replace id = 12 if name == "Steven" | name == "Steven wakalo"
replace id = 13 if name == "Aheebwa Aishah"
replace id = 15 if name == "Nsubuga Paul"
replace id = 16 if name == "Kanyemera fridah"
replace id = 17 if name == "Namatovu Catherine"
replace id = 18 if name == "Namugoya Susan"
replace id = 19 if name == "Nevis bukirwa"
replace id = 20 if name == "Shamim nalukenge"
replace id = 21 if name == "Namwanza lydia"
replace id = 22 if name == "Chloepatra Nakato"
replace id = 23 if name == "Nalubwama Christine"
replace id = 24 if name == "Nantume Flavia"
replace id = 25 if name == "David Baidu"
replace id = 26 if name == "Apio Florence"
replace id = 27 if name == "Ahimbisibwe Daisy"
replace id = 28 if name == "Omiat Samuel"
replace id = 29 if name == "Shafik Kikomeko"
replace id = 30 if name == "NABUKEERA WINFRED"
replace id = 31 if name == "Juliet Musiime"
replace id = 32 if name == "Nayiga sylvia"
replace id = 33 if name == "Prossy Nakiyimba"
replace id = 34 if name == "Moses Semujju"
replace id = 35 if name == "Awachango Annette"
replace id = 36 if name == "Wails protus"
duplicates drop id, force

replace name = strproper(name)
egen score_d3 = rowmean(sect2 sect4 sect5_1 sect5_2 sect5_3 sect11)
sum sect2 sect4 sect5_1 sect5_2 sect5_3 sect11 score_d3
list name if score_d3 == 1

/*********
	NOTES:
		Not very good at all!
		Sect4 and sect5_3 were just awful.
		Need improvement on sect2 and sect5_2
		
*********/

save "`edit'\tup_quiz_day3.dta", replace

**************************************************************************

//********** Day 4 Quiz

do "`home'\scripts\import_tup_quiz_day4.do"

replace name = strproper(name)

gen id = .
replace id = 1 if name == "Duchu Henry"
replace id = 2 if name == "Bukirwa Rebecca"
replace id = 3 if name == "Wanga Sara"
replace id = 4 if name == "Malengo Douglas"
replace id = 5 if name == "Namutamba Esther"
replace id = 6 if name == "Nakidde Agatha"
replace id = 7 if name == "Charles Mulondo"
replace id = 8 if name == "Ismail Musana"
replace id = 9 if name == "Namatovu Bukenya Harriet"
replace id = 10 if name == "Waiswa Jimmy"
replace id = 11 if name == "Oundo Joseph"
replace id = 12 if name == "Steven Wakaalo"
replace id = 13 if name == "Aheebwa Aisha"
replace id = 15 if name == "Nsubuga Paul"
replace id = 16 if name == "Kanyemera Fridah"
replace id = 17 if name == "Namatovu Catherine"
replace id = 18 if name == "Namugoya Susan"
replace id = 19 if name == "Nevis Bukirwa"
replace id = 20 if name == "Shamim Nalukenge"
replace id = 21 if name == "Namwanza Lydia"
replace id = 22 if name == "Chloepatra Nakato"
replace id = 23 if name == "Nalubwama Christine"
replace id = 24 if name == "Nantume Flavia"
replace id = 25 if name == "David Baidu"
replace id = 26 if name == "Apio Florence"
replace id = 27 if name == "Daisy Ahimbisibwe"
replace id = 28 if name == "Samuel Omiat"
replace id = 29 if name == "Shafik Kikomeko"
replace id = 30 if name == "Nabukeera Winfred"
replace id = 31 if name == "Juliet Musiime"
replace id = 32 if name == "Nayiga Sylvia"
replace id = 33 if name == "Nakiyimba Prossy"
replace id = 34 if name == "Moses Semujju"
replace id = 35 if name == "Awachango Annette"
replace id = 36 if name == "Wails Protus"
duplicates drop id, force

egen score_d4 = rowmean(section3 section4 section6 section8 section10 section11 vsla1 vsla2 vlsa3 vlsa4)
sum section3 section4 section6 section8 section10 section11 vsla1 vsla2 vlsa3 vlsa4
list name if score_d4 == 1

/*********
	NOTES:
		None. No better no worse!
		
*********/

save "`edit'\tup_quiz_day4.dta", replace

**************************************************************************

//*********** Merge, Total Score and Rank

merge m:m id using "`edit'\tup_quiz_day2.dta", keepusing(score_d2 name id)
drop _merge
merge m:m id using "`edit'\tup_quiz_day3.dta", keepusing(score_d3 name id)
drop _merge

foreach v of varlist score_d2 score_d3 score_d4{
	recode `v' (. = 0)
}
egen tot_score = rowmean(score_d2 score_d3 score_d4)
egen ranking = rank(tot_score), field
order ranking name tot_score
sort ranking
list ranking name tot_score

save "`edit'\tup_quiz_master.dta", replace
