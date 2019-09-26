clear
set more off
log close _all

/*****************
Description:
	 Merge for TUP final analysis
		Baseline, Midline, Endline and VSLA
	 
	 Sections:
		1. Import 
		6. Order and Sort
		7. Save
*****************/

local date `c(current_date)'
local time `c(current_time)'
if "`c(username)'"=="Ryry"  ///
     local home "<local>"
	 global USER "Ryan McWay"
else if "`c(username)'"=="Danish IERC"  ///
     local home "<local>" 
	 global USER "Danish Us Saleem"
else if "`c(username)'"=="DELL"  ///
     local home "<local>" 
	 global USER "Patrick Olobo"
else if "`c(username)'"=="KGC"  ///
     local home "<local>" 
	 global USER "Dennis Oundo"

//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
cd "`home'"
local input	"`home'\data"
local output "`home'\results"

//*****************************************************************************
display "Analysis run by $USER for TUP clean at `date' and `time'"

********************TUP Endline************
use "<local>" ,clear
*gen branch1=branch
*save "<local>" ,replace

do "E:\TUP endline\tup_endline_ug_stata_template_wide\import_tup_endline_ug.do"
do "E:\TUP endline\tup_endline_ug_v2_stata_template_wide\import_tup_endline_ug_v2.do"
merge m:m idno using "E:\TUP endline\(OLD. DO NOT USE!) Graduation Endline.dta",force
destring idno, replace force
destring qn7_2_*_4 qn7_2_*_3 qn5_2_cultivationa_* branch qn1_8 qn1_1 qn1_2 qn1_2a, replace force
destring qn7_2_*_2 qn7_2_*_1 loan_count qn6_*_1 qn6_1_igaa_* sec5_9_livestocka_* qn5_7e_*_5 qn5_7e_*_4  qn5_7e_*_3 qn5_7e_*_2 qn5_7e_*_1 qn5_2_cultivationa_* qn2_5_* qn1_7other qn1_4 qn1_2a, force replace
save "TUP_endline.dta", replace

duplicates drop idno, force
merge 1:1 idno using "E:\dell\Downloads_C+\baseline_data (1).dta",force gen(merge) //undone interviews
*outsheet idno qn2_2_1 village branch1 if merge==2 using "E:\TUP endline\TUP to followup.csv", replace c
append using "E:\dell\Downloads_C+\baseline_data (1).dta", force gen(round)
duplicates tag idno,gen(drop)
drop if drop==0
ed idno treat round
sort idno round treat 
replace treat=treat[_n-1] if missing(treat)
save "tup_B_E_final.dta",replace

sort idno



foreach v of varlist qn3_19_1 qn3_19_2 qn3_19_3 qn3_19_4 qn3_19_5 qn3_19_6 qn3_19_7 qn3_19_8electricke qn3_19_9dvdplay qn3_19_10 qn3_19_11 qn3_19_12 qn3_19_13 qn3_19_14 qn3_19_15 qn3_19_16 qn3_19_17 qn3_19_18 qn3_19_18a qn3_19_19 qn3_19_20 qn3_19_21 {
tab `v'
}

foreach v of varlist qn4_2_2?c{
sum `v',d
}


 strdist youth1 qn2_2_1,gen(tabb)
************************************************
************************************************
************************************************
 use "E:\TUP endline\Graduation Endline V2.dta", clear //midline data
keep idno key 
rename key parent_key
save "E:\TUP endline\TUP ID_key.dta",replace
************************************************
************************************************
************************************************

 
 *****************************
 *****************************
 *gps analysis****************
 *****************************
 use "E:\dell\Downloads_C+\baseline_data (1).dta" ,clear
 keep idno branch  treat geocoordinatelatitude geocoordinatelongitude geocoordinatealtitude geocoordinateaccuracy
 rename geocoordinatelatitude B_geocoordinatelatitude 
 rename geocoordinatelongitude B_geocoordinatelongitude
 rename geocoordinatealtitude B_geocoordinatealtitude
 rename geocoordinateaccuracy B_geocoordinateaccuracy
save "E:\TUP endline\TUP_B_gps.dta" , replace

do "E:\TUP endline\tup_endline_ug_v2_stata_template_wide\import_tup_endline_ug_v2.do"
destring idno, replace force
destring qn7_2_*_4 qn7_2_*_3 qn5_2_cultivationa_* branch qn1_8 qn1_1 qn1_2 qn1_2a, replace force
destring qn7_2_*_2 qn7_2_*_1 loan_count qn6_*_1 qn6_1_igaa_* sec5_9_livestocka_* qn5_7e_*_5 qn5_7e_*_4  qn5_7e_*_3 qn5_7e_*_2 qn5_7e_*_1 qn5_2_cultivationa_* qn2_5_* qn1_7other qn1_4 qn1_2a, force replace
 keep idno branch  treat geocoordinatelatitude geocoordinatelongitude geocoordinatealtitude geocoordinateaccuracy
save "E:\TUP endline\TUP_E_gps.dta", replace



*****************************************************************
************************Time use analysis************************
******constructing data for time decomposition graph*************
*****************************************************************
foreach v of varlist qn6_9_1 - qn6_9_24 {
tab `v'
}

*****************************************************************
************************ROSTERS************************
*******************CULTIVATION ROSTER******************
***************CONSTRUCTING FROM BASELINE************************

use "E:\dell\Downloads_C+\baseline_data (1).dta" ,clear
keep idno treat qn5_2_*
drop qn5_2_1 - qn5_2_37
reshape long qn5_2_cultivationa_ qn5_2_cultivationb_ qn5_2_1a_ qn5_2_1b_ qn5_2_1c_ qn5_2_1d_ qn5_2_1e_ qn5_2_1f_ qn5_2_1g_ qn5_2_1h_,i(idno) j(numcrop)
drop qn5_2_1c_other_* 
drop if qn5_2_cultivationa_==. & qn5_2_cultivationb_==""
capture {
foreach v of varlist qn5_2_cultivationa_ qn5_2_cultivationb_ qn5_2_1a_ qn5_2_1b_ qn5_2_1c_ qn5_2_1d_ qn5_2_1e_ qn5_2_1f_ qn5_2_1g_ qn5_2_1h_{
rename *_ *
}
}
save "E:\TUP endline\TUP_cultivation_B.dta",replace

use "E:\TUP endline\TUP_endline.dta", clear //midline data
keep idno key 
rename key parent_key
save "E:\TUP endline\TUP ID_key.dta",replace

use"E:\TUP endline\TUP ID_key.dta",clear
merge m:m parent_key using "E:\TUP endline\Graduation Endline V2-interview-Sect5-qn5_2_cultivation.dta", force
merge m:m parent_key using "E:\TUP endline\(OLD. DO NOT USE!) Graduation Endline-interview-Sect5-qn5_2_cultivation.dta",force gen(merge1)
egen sumtot=rowtotal(_merge merge1)
drop if sumtot==2
*drop if _merge!=3
destring idno, replace force 
merge m:m idno using "E:\TUP endline\TUP ID_B.dta", force gen(idmerge)
drop if idmerge!=3
destring qn5_2_cultivationa,force replace
save "E:\TUP endline\TUP Graduation Endline V2_cultivation_ID.dta",replace 

append using "E:\TUP endline\TUP_cultivation_B.dta",gen(round)
recode round (0=2) (1=3)
recode round (3=0) (2=1)
save "E:\TUP endline\TUP cultivation roster merged_unbalanced.dta",replace

forvalues i=1/33 {
use "E:\TUP endline\TUP cultivation roster merged_unbalanced.dta",clear
encode qn5_2_cultivationb, gen(crop_grown)
keep if crop_grown==`i'
save "E:\TUP endline\TUP cultivation roster (`i') merged_unbalanced.dta",replace
}

use "E:\TUP endline\TUP cultivation roster (15) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP cultivation roster (maize) merged_balanced.dta",replace


use "E:\TUP endline\TUP cultivation roster (3) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP cultivation roster (beans) merged_balanced.dta",replace

use "E:\TUP endline\TUP cultivation roster (33) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP cultivation roster (sweet) merged_balanced.dta",replace


*****************************************************************
************************ROSTERS************************
*******************Livestock ROSTER********************
***************CONSTRUCTING FROM BASELINE************************

use "E:\dell\Downloads_C+\baseline_data (1).dta" ,clear
keep idno treat qn5_9_* sec5_9_livestocka_* sec5_9_livestockb_*
reshape long sec5_9_livestocka_ sec5_9_livestockb_ qn5_9_1a_ qn5_9_1b_ qn5_9_1c_ qn5_9_1d_ qn5_9_1e_ qn5_9_1f_ qn5_9_1g_,i(idno) j(numlive)
drop if qn5_9_1a_==. & qn5_9_1b_==.
capture {
foreach v of varlist sec5_9_livestocka_ sec5_9_livestockb_ qn5_9_1a_ qn5_9_1b_ qn5_9_1c_ qn5_9_1d_ qn5_9_1e_ qn5_9_1f_ qn5_9_1g_{
rename *_ *
}
}
save "E:\TUP endline\TUP_livestock_B.dta",replace //baseline livestock roster

use "E:\TUP endline\TUP_endline.dta", clear //midline data
keep idno key 
rename key parent_key
save "E:\TUP endline\TUP ID_key.dta",replace

use"E:\TUP endline\TUP ID_key.dta",clear
use "E:\TUP endline\Graduation Endline V2-interview-Sect5-sec5_9_livestock.dta", clear //midline data roster
destring sec5_9_livestocka, replace force
save "E:\TUP endline\TUP Graduation Endline V2_livestock.dta",replace 

use "E:\dell\Downloads_C+\baseline_data (1).dta", clear //basline id data
keep idno treat
save "E:\TUP endline\TUP ID_B.dta",replace

use"E:\TUP endline\TUP ID_key.dta",clear
merge m:m parent_key using "E:\TUP endline\TUP Graduation Endline V2_livestock.dta", force
merge m:m parent_key using "E:\TUP endline\(OLD. DO NOT USE!) Graduation Endline-interview-Sect5-sec5_9_livestock.dta", force gen(merge1)
egen sumtot=rowtotal(_merge merge1)
drop if sumtot==2
*drop if _merge!=3
destring idno, replace force 
merge m:m idno using "E:\TUP endline\TUP ID_B.dta", force gen(idmerge)
drop if idmerge!=3
save "E:\TUP endline\TUP Graduation Endline V2_livestock_ID.dta",replace 

append using "E:\TUP endline\TUP_livestock_B.dta",gen(round)
recode round (0=2) (1=3)
recode round (3=0) (2=1)
save "E:\TUP endline\TUP Livestock roster merged_unbalanced.dta",replace

forvalues i=1/7 {
use "E:\TUP endline\TUP Livestock roster merged_unbalanced.dta",clear
encode sec5_9_livestockb, gen(livestock)
keep if livestock==`i'
save "E:\TUP endline\TUP Livestock roster (`i') merged_unbalanced.dta",replace
}

use "E:\TUP endline\TUP Livestock roster (1) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock roster (chicken) merged_balanced.dta",replace

use "E:\TUP endline\TUP Livestock roster (2) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock roster (cow) merged_balanced.dta",replace

use "E:\TUP endline\TUP Livestock roster (4) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock roster (goat) merged_balanced.dta",replace

use "E:\TUP endline\TUP Livestock roster (6) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock roster (pig) merged_balanced.dta",replace

use "E:\TUP endline\TUP Livestock roster (7) merged_unbalanced.dta",clear
duplicates tag idno, gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock roster (sheep) merged_balanced.dta",replace

*Goats 
keep if sec5_9_livestockb=="Goat" //goats only data
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock(goat) roster merged_balanced.dta",replace

*Chicken
use "E:\TUP endline\TUP Livestock roster merged_unbalanced.dta",clear
keep if sec5_9_livestockb=="Chicken" //Chicken only data
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock(Chicken) roster merged_balanced.dta",replace

*Pig
use "E:\TUP endline\TUP Livestock roster merged_unbalanced.dta",clear
keep if sec5_9_livestockb=="Pig" //Pig only data
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP Livestock(Pig) roster merged_balanced.dta",replace


reg numgoat treat##round
reg numgoatsell treat##round
reg numgoatcons treat##round

reg numchick treat##round
reg numchicksell treat##round
reg numchickcons treat##round

reg numchick treat##round
reg numchicksell treat##round
reg numchickcons treat##round

/*****************************************************************
************************ROSTERS************************
*******************IGA ROSTER**************************
***************CONSTRUCTING FROM BASELINE************************

use "E:\dell\Downloads_C+\baseline_data (1).dta" ,clear
keep idno treat qn7_* 
tostring qn7_2_3 qn7_2_5, replace
reshape long qn7_2_ qn7_3_ qn7_4_ qn7_5_ qn7_2_1_ qn7_2_2_ qn7_2_3_ qn7_2_4_ qn7_2_5_ qn7_2_6_ qn7_2_8_ qn7_2_9_ qn7_2_10_ qn7_2_11_ qn7_2_96_,i(idno) j(numloan)
drop if qn7_2_1_==. & qn7_3_==.

save "E:\TUP endline\TUP_loan_B.dta",replace*/

*****************************************************************
*********************ROSTERS************************
*******************loan ROSTER**********************
***************CONSTRUCTING FROM BASELINE************************

use "E:\dell\Downloads_C+\baseline_data (1).dta" ,clear
keep idno treat qn7_* 
tostring qn7_2_3 qn7_2_5, replace
reshape long qn7_2_ qn7_3_ qn7_4_ qn7_5_ qn7_2_1_ qn7_2_2_ qn7_2_3_ qn7_2_4_ qn7_2_5_ qn7_2_6_ qn7_2_8_ qn7_2_9_ qn7_2_10_ qn7_2_11_ qn7_2_96_,i(idno) j(numloan)
drop if qn7_2_1_==. & qn7_3_==.


capture {
foreach v of varlist qn7_2_1_ qn7_2_2_ qn7_2_3_ qn7_2_4_ qn7_2_5_ qn7_2_6_ qn7_2_8_ qn7_2_9_ qn7_2_10_ qn7_2_11_ qn7_2_96_ qn7_3_ qn7_4_ qn7_5_{
rename *_ *
}
}
save "E:\TUP endline\TUP_loan_B.dta",replace

use "E:\TUP endline\TUP ID_key.dta",clear //merging idno into roster by parent key
merge m:m parent_key using "E:\TUP endline\Graduation Endline V2-interview-Sect7-loan.dta",force
merge m:m parent_key using "E:\TUP endline\(OLD. DO NOT USE!) Graduation Endline-interview-Sect7-loan.dta", force gen(merge1)
egen sumtot=rowtotal(_merge merge1)
drop if sumtot==2
*drop if _merge!=3
destring idno, replace force 
merge m:m idno using "E:\TUP endline\TUP ID_B.dta", force gen(idmerge) //
drop if idmerge!=3
*destring qn5_2_cultivationa,force replace
save "E:\TUP endline\TUP Graduation Endline V2_loan_ID.dta",replace 

append using "E:\TUP endline\TUP_loan_B.dta",gen(round)
recode round (0=2) (1=3)
recode round (3=0) (2=1)
*bysort idno round:gen panel=_n
*bysort idno:egen panel1=sum(panel)
*duplicates tag idno, gen(tagg)
*drop if tagg==0 & panel==1
*duplicates tag idno round, gen(tagg1)
*bysort idno round:gen panel3=_N
*bysort idno round:egen panel1=sum(panel)
*drop if panel==1
save "E:\TUP endline\TUP loan roster merged_unbalanced.dta",replace

use "E:\TUP endline\TUP loan roster merged_unbalanced.dta",clear
drop qn7_2_* qn7_12_* qn7_2other qn7_3other qn7_2other_1 qn7_3other_1 qn7_2other_2 qn7_3other_2 qn7_12other qn7_2other_3 qn7_3other_3 qn7_2other_4 qn7_3other_4 qn7_2other_5 qn7_3other_5 parent_key key merge merge1 sumtot idmerge setofloan
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6|panmax==9|panmax==12 //creating a balanced panel
save "E:\TUP endline\TUP loan roster merged_balanced.dta",replace


*****************************************************************
************************ROSTERS************************
*******************IGA ROSTER**************************
***************CONSTRUCTING FROM BASELINE************************
use "E:\dell\Downloads_C+\baseline_data (1).dta" ,clear
keep idno treat qn6_3_igaa_* qn6_3_igab_* qn6_4days_* qn6_4hours_* qn6_5_* qn6_6_* 
*tostring qn7_2_3 qn7_2_5, replace
reshape long qn6_3_igaa_ qn6_3_igab_ qn6_4days_ qn6_4hours_ qn6_5_ qn6_6_,i(idno) j(numIGA)
drop if qn6_3_igaa_==. & qn6_3_igab_==""
capture {
foreach v of varlist qn6_3_igaa_ qn6_3_igab_ qn6_4days_ qn6_4hours_ qn6_5_ qn6_6_{
rename *_ *
}
}
save "E:\TUP endline\TUP_IGA_B.dta",replace

use "E:\TUP endline\Graduation Endline V2-qn6_3_IGA.dta",clear
split parent_key , p(/)
save "E:\TUP endline\Graduation Endline V2-qn6_3_IGA1.dta",replace

use "E:\TUP endline\(OLD. DO NOT USE!) Graduation Endline-qn6_3_IGA.dta",clear
split parent_key , p(/)
save "E:\TUP endline\(OLD. DO NOT USE!) Graduation Endline-qn6_3_IGA1.dta",replace

use "E:\TUP endline\TUP ID_key.dta",clear
rename parent_key parent_key1
merge m:m parent_key1 using "E:\TUP endline\Graduation Endline V2-qn6_3_IGA1.dta",force
merge m:m parent_key1 using "E:\TUP endline\(OLD. DO NOT USE!) Graduation Endline-qn6_3_IGA1.dta", force gen(merge1)
drop if _merge!=3
destring idno qn6_3_igaa, replace force 
merge m:m idno using "E:\TUP endline\TUP ID_B.dta", force gen(idmerge)
drop if idmerge!=3
*destring qn5_2_cultivationa,force replace
save "E:\TUP endline\TUP Graduation Endline V2_IGA_ID.dta",replace 

append using "E:\TUP endline\TUP_IGA_B.dta",gen(round)
recode round (0=2) (1=3)
recode round (3=0) (2=1)
save "E:\TUP endline\TUP IGA roster merged.dta",replace

use "E:\TUP endline\TUP IGA roster merged.dta",clear
duplicates tag idno,gen(tagg)
replace _merge=1 if _merge==.
bysort idno:gen panel=sum(_merge)
bysort idno:egen panmax=max(panel)
drop if panmax==1|panmax==2|panmax==3|panmax==6 //creating a balanced panel
drop if (panmax==9 & tagg==2) | (panmax==12 & tagg==3)
save "E:\TUP endline\TUP loan roster merged_balanced.dta",replace
