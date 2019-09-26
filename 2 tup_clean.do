clear
set more off
log close _all

/*****************
Description:
	 Clean for TUP final analysis
		Baseline, Midline and Endline
	 
	 Sections:
		1. Import merged dataset
		2. Drop variables and observations
		3. Clean variable names
		4. Create new variables
		5. Variable labels
		6. Order and Sort
		7. Save
*****************/

local date `c(current_date)'
local time `c(current_time)'
if "`c(username)'"=="Ryry"  ///
     local home "<local>"
	 global USER "Ryan McWay"

//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
cd "`home'"
local input	"`home'\data"
local output "`home'\results"

//*****************************************************************************
display "Analysis run by $USER for TUP clean at `date' and `time'"

//****************************************************************************
//*************		Section 1: Import Merged Dataset

use "`input'\single\tup_B_E_merged_final.dta", clear

//****************************************************************************
//*************		Section 2: Drop Variables and Observations

//* Drop non-consent and rich
drop if (consent == 0 | treatment == "Rich")
//* Drop unneeded var
drop drop merge _merge tag1 random_pick check_id treat_type simid subscriberid devicephone* submissiondate date1 date44 consent sec5_9_8 start* end* instancename formdef* instanceid deviceid sec5_9_livestockb_6 sec5_9_livestocka_6 audio_audit qn4_2_*b_label loan_count qn1_2 qn1_2a qn1_8

//* DK and Refusals to .
destring qn1_5, replace
recast byte qn1_4 qn3_3 qn7_13 qn5_8_1b qn5_8_2b qn5_10b1 qn5_10b2 qn5_10b3 qn5_10b4 qn7_6* qn7_13
recode qn1_4 qn3_3 qn7_13 qn5_8_1b qn5_8_2b qn5_10b1 qn5_10b2 qn5_10b3  qn5_10b4 qn7_6* qn7_13 ///
(98 99 999 = .)
replace qn1_5 = "" if (qn1_5 == "999" | qn1_5 == "99" | qn1_5 == "98")
foreach v of varlist qn8_7_*b qn8_9 qn8_11 qn8_13{
	replace `v'=. if `v'==99
	replace `v'=. if `v' >r(p95)
}

//* Known attritors
list idno if (sn == 1875 | sn == 1815 | sn == 2180 | sn == 2121 | sn == 2431 | sn == 1314 | sn == 1324 | sn == 1123 | sn == 1598 | sn == 1600 | sn == 1249 | sn == 1250 | sn == 1251 | sn == 1253 | sn == 561 | sn == 2432 | sn == 2369 | sn == 1789 | sn == 2 | sn == 419 | sn == 438 | sn == 1937 | sn == 1789 | sn == 1785 | sn == 1549 | sn == 1552 | sn == 673) 
drop if (idno == 266 | idno == 2750 | idno == 4058 | idno == 4544 | idno == 4723 | idno == 5023 | idno == 5024 | idno == 5028 | idno == 8894 | idno == 100075 | idno == 100202)
drop if (idno == 100219 | idno == 913 | idno == 4359 | idno == 6193 | idno == 6197 | idno == 6198 | idno == 4964 | idno == 8710 | idno == 8726 | idno == 8732 | idno == 8733 | idno == 8630 | idno == 5197 | idno == 7730 | idno == 1439 | idno == 5488 | idno == 5266 | idno == 5270 | idno == 100131 | idno == 7111 | idno == 7110 | idno == 6193 | idno == 6197 | idno == 7973 | idno == 5067 | idno == 7947 | idno == 5131 | idno == 6197  | idno == 6110 | idno ==  8632 | idno == 5019 | idno == 100091 | idno == 6197 | idno == 6110 | idno == 6142  | idno == 6198 | idno == 100061 | idno == 7096 | idno == 5067 | idno == 7848)
drop if (idno == .)

//****************************************************************************
//*************		Section 3: Clean Variable Names

rename (respo tupbenef tupcaretake vsla mainyouth youth1 age_1 tup_vsla tup_vsla_frq nloan branch) ///
(resp_e tup_benef_name tup_care_asset vsla_branch youth_main youth_name youth_age vsla_tup vsla_tup_frq loan_n branch_e)

//****************************************************************************
//*************		Section 4: Create new variables

//* determine # of nulls in df
egen miss = rowmiss(**)
total(miss) // Total number of null values in the dataset
drop miss

//* tup = official treatment var
gen tup = 0
replace tup = 1 if (treatment == "Treatment" & treat == 1)

//*	Poverty Score
recode p1 (1 = 0) (2 = 3) (3 = 4) (4 = 6) (5 = 8) (6 = 12) (7 = 21) (8 = 28)
recode p2 (1 = 0) (2 = 2) (3 = 5)
recode p3 (1 = 0) (2 = 0) (3 = 3)
recode p4 (1 = 0) (2 = 4) (3 = 4)
recode p5 (1 = 0) (2 = 5)
recode p6 (1 = 0) (2 = 6)
recode p7 (1 = 0) (2 = 4) (3 = 6) (4 = 11)
recode p8 (0 = 0) (1 = 7) (2 = 12) (3 = 22)
recode p9 (0 = 0) (1 = 7)
recode p10 (0 = 0) (1 = 9)

egen pscore = rowtotal(p*) // removed cellphone question

gen plikely = .
replace plikely = 96.7 if pscore >= 0 & pscore <= 4
replace plikely = 92.5 if pscore >= 5 & pscore <= 9
replace plikely = 81.1 if pscore >= 10 & pscore <= 14
replace plikely = 73.5 if pscore >= 15 & pscore <= 19
replace plikely = 68.3 if pscore >= 20 & pscore <= 24
replace plikely = 54.5 if pscore >= 25 & pscore <= 29
replace plikely = 37.5 if pscore >= 30 & pscore <= 34
replace plikely = 29.7 if pscore >= 35 & pscore <= 39
replace plikely = 26.0 if pscore >= 40 & pscore <= 44
replace plikely = 16.7 if pscore >= 45 & pscore <= 49
replace plikely = 8.1 if pscore >= 50 & pscore <= 54
replace plikely = 4.0 if pscore >= 55 & pscore <= 59
replace plikely = 0.6 if pscore >= 60 & pscore <= 64
replace plikely = 0.4 if pscore >= 65 & pscore <= 69
replace plikely = 0.0 if pscore >= 70 & pscore <= 74
replace plikely = 0.0 if pscore >= 75 & pscore <= 79
replace plikely = 0.0 if pscore >= 80 & pscore <= 84
replace plikely = 0.0 if pscore >= 85 & pscore <= 89
replace plikely = 0.0 if pscore >= 90 & pscore <= 94
replace plikely = 0.0 if pscore >= 95 & pscore <= 100

gen plikely_high = plikely > 54.5

//* Income
egen inc = rowtotal(qn6_6_1 qn6_6_2 qn6_6_3 qn6_6_4)
replace inc = inc/3600 if (round == 0)
replace inc = inc/3700 if (round == 1)
gen inc_30 = inc > 30


//* Jobs
split qn6_3, gen(inc)
destring inc1 inc2 inc3 inc4, replace force
recode inc1 inc2 inc3 inc4 (5 6 7 9 = 4) (11 16 = 10) (8 3 = 1) (14 15 2 12 = 13)
 
foreach v of varlist inc1 inc2 inc3 inc4{
	gen `v'_dum = `v' > 0 & `v' != .
}
egen num_jobs = rowtotal(inc1_dum inc2_dum inc3_dum inc4_dum)
gen one_job = num_jobs >= 1
gen two_jobs = num_jobs >= 2

//* Training
egen train_num = rowtotal(qn8_14_?a)
gen train_2 = train_num >= 2

//* Meals
gen meals_2 = qn4_1 >= 2
gen meals_3 = qn4_1 >= 3

//* Save in usd
gen save_usd = qn7_13/3600 if (round == 0)
replace save_usd = qn7_13/3700 if (round == 1)

//* Food Insecurity
egen hfias = rowtotal(qn8_1_*b)
replace hfias = . if hfias == 0
    *food security categories*
gen HFIAS_CAT = 0
replace HFIAS_CAT = 1 ///
if (qn8_1_1b==0 | qn8_1_1b==1) & qn8_1_2a==0 & qn8_1_3a==0 & qn8_1_4a==0 & qn8_1_5a==0 & qn8_1_6a==0 & qn8_1_7a==0 & qn8_1_8a==0 & qn8_1_9a==0 
replace HFIAS_CAT = 2 ///
if (qn8_1_1b==2 | qn8_1_1b==3 | qn8_1_2b==1 | qn8_1_2b==2 | qn8_1_2b==3 | qn8_1_3b==1 | qn8_1_4b==1) & qn8_1_5a==0 &  qn8_1_6a==0 & qn8_1_7a==0 & qn8_1_8a==0 & qn8_1_9a==0 
replace HFIAS_CAT = 3 ///
if (qn8_1_3b==2 | qn8_1_3b==3 | qn8_1_4b==2 | qn8_1_4b==3 | qn8_1_5b==1 | qn8_1_5b==2 | qn8_1_6b==1 | qn8_1_6b==2) & qn8_1_7a==0 & qn8_1_8a==0 & qn8_1_9a==0
replace HFIAS_CAT = 4 ///
if qn8_1_5b==3 | qn8_1_6b==3 | qn8_1_7b==1 | qn8_1_7b==2 | qn8_1_7b==3 | qn8_1_8b==1 | qn8_1_8b==2 | qn8_1_8b==3 | qn8_1_9b==1 | qn8_1_9b==2 | qn8_1_9b==3
	*domain insufficient food quality and quantity*
gen HFIAS_qual = 0
replace HFIAS_qual = qn8_1_2a==1 | qn8_1_3a==1 | qn8_1_4a==1
gen HFIAS_quant = 0
replace HFIAS_quant = qn8_1_5a==1 | qn8_1_6a==1 | qn8_1_7a==1 | qn8_1_8a==1 | qn8_1_8a==1

//* Precieved Well-Being
egen life_sat = anymatch(qn11_30 qn11_31 qn11_32), v(1)
gen satlife = qn11_26 == 4 | qn11_26 == 5
gen happynow = qn11_29 == 5 | qn11_29 == 6 | qn11_29 == 7
gen acheived = qn11_33 == 5 | qn11_33 == 6 | qn11_33 == 7
gen changelife = qn11_34 == 1 | qn11_34 == 2 | qn11_34 == 3

//* Raven Score
gen raven1 = qn12_2_1 == 5
gen raven2 = qn12_2_2 == 2
gen raven3 = qn12_2_3 == 3
gen raven4 = qn12_2_4 == 2
gen raven5 = qn12_2_5 == 5
gen raven6 = qn12_2_6 == 5
gen raven7 = qn12_2_7 == 5
gen raven8 = qn12_2_8 == 6
gen raven9 = qn12_2_9 == 1
gen raven10 = qn12_2_10 == 1
egen raven_tot = rowtotal(raven*)
drop raven1-raven10

//* WASH
egen wash = rowtotal(w1 w2 w3 w4 w5 w8 w9)
gen wash_pct = wash >= 5

//* Crops
split qn5_2, gen(crop)
destring crop*, replace
foreach v of varlist crop*{
	gen `v'_dum = 0
	replace `v'_dum = 1 if `v' != .
}
egen acres_cult = rowtotal(qn5_2_1a_*)
gen acres_cult_b = acres_cult if (round == 0)
gen acres_cult_e = acres_cult if (round == 1)

//* Animals
split sec5_9,gen(animal)
destring animal*, replace
destring sec5_9_livestock_count, force replace
gen livestock_count_b = sec5_9_livestock_count if (round == 0)
gen livestock_count_e = sec5_9_livestock_count if (round == 1)

//* Sell in MKT
egen crops_sold = rowtotal(qn5_2_1e_?)
gen sold_mkt = crops_sold >= 1


//* Self-Percieved Health
*qn10_13_1 qn10_13_2 qn10_13_3 qn10_13_4 qn10_13_5 qn10_13_6 qn10_13_7 
 
//* Family and Community life 
*qn11_1 qn11_2 qn11_3 qn11_4 qn11_5 qn11_6 qn11_7 qn11_8 qn11_9 qn11_10 

//****************************************************************************
//*************		Section 5: Variable Labels

label define a 0 "Control" 1 "Treatment"
label values tup a
label define b 0 "Baseline" 1 "Endline"
label values round b
label define c 0 "" 1 "" 2 "" 3 "" 4 ""
label values HFIAS_CAT c
label define d 0 "Poor Qualtiy" 1 "High Quality"
label values HFIAS_qual d
label define e 0 "Low Quantity" 1 "High Quantity"
label values HFIAS_quant e
label define jobb 0	"No IGA" ///
1	"Agricultural day labor" ///
2	"Non-agri. day labor" ///
3	"Fishing" ///
4	"Food processing for sale" ///
5	"Stitching/tailoring" ///
6	"Brick-making" ///
7	"Charcoal-making" ///
8	"Bee-keeping" ///
9	"Timber cutting           " ///
10	"Home-based business or  small- scale trading" ///
11	"Small shop or retail" ///
12	"Driver (taxi, boda, etc.)" ///
13	"Teacher" ///
14	"Government worker" ///
15	"Other salaried worker" ///
16	"Other self-employed" ///
96	"Other"
label values inc1 inc2 inc3 inc4 jobb 

label var idno "Household ID"
label var sn "HH Serial #"
label var round "0 Baseline / 1 Endline"
label var tup "0 control / 1 treated"
label var treatment "OG assignment of treatment"
label var treat "self reported"
label var branch_e "BRAC branch"
label var resp_b "respondent @ Baseline"
label var village "village"
label var branch_b "branch @ baseline"
label var district "district"
label var hhsize "househould size"
label var resp_e "respondent @ endline"
label var hh_member_count "# of people in hh"
label var qn5_2_cultivation_count "# plants cultivated" 
label var pscore "poverty score"
label var plikely "poverty likelihood"
label var plikely_high "high poverty likelihood"
label var inc "income in usd"
label var inc_30 "income > 30 usd"
label var num_jobs "number of jobs"
label var one_job "if >= 1 job"
label var two_jobs "if >= 2 jobs"
label var meals_2 "if >= 2 meals daily"
label var meals_3 "if >= 3 meals daily"
label var hfias "food insecurity"
label var HFIAS_CAT "food insecurity category 0-4"
label var HFIAS_qual "food insecurity quality"
label var HFIAS_quant "food insecurity quantity"
label var life_sat "life satisfaction"
label var satlife "0/1 life satisfaction"
label var happynow "0/1 happy today"
label var acheived "0/1 achivement"
label var changelife "0/1 changed life"
label var raven_tot "raven score"
label var wash "wash score"
label var wash_pct "percent with wash > 5"
label var acres_cult "tot acres cultivated"
label var acres_cult_b "tot acres baseline"
label var acres_cult_e "tot acres endline"
label var livestock_count_b "livestock count baseline"
label var livestock_count_e "livestock count endline"
//label var asset_grow "% asset growth"
label var train_num "number of trainings household has attended"
label var train_2 "if attended >= 2 trainings"


label var tup_asset_1 "chicken"
label var tup_asset_2 "goat"
label var tup_asset_3 "pig"
label var tup_asset_4 "non-farm business"

label var qn6_3_0 "Activity: NO IGA"
label var qn6_3_1 "Activity: agr. day labor"
label var qn6_3_2 "Activity: non-agr. day labor"
label var qn6_3_3 "Activity: fishing"
label var qn6_3_4 "Activity: food processing"
label var qn6_3_5 "Activity: stitching/tailoring"
label var qn6_3_6 "Activity: brick-maker"
label var qn6_3_7 "Activity: charcoal-maker"
label var qn6_3_8 "Activity: bee-keeper"
label var qn6_3_9 "Activity: timber cutter"
label var qn6_3_10 "Activity: home biz"
label var qn6_3_11 "Activity: small shop"
label var qn6_3_12 "Activity: driver"
label var qn6_3_13 "Activity: teacher"
label var qn6_3_14 "Activity: gov worker"
label var qn6_3_15 "Activity: other salaried worker"
label var qn6_3_16 "Activity: other self-employed"
label var qn6_3_96 "Activity: Other"

label var qn2_2_1 "hh member 1"
label var qn2_2_2 "hh member 2"
label var qn2_2_3 "hh member 3"
label var qn2_2_4 "hh member 4"
label var qn2_2_5 "hh member 5"
label var qn2_2_6 "hh member 6"
label var qn2_2_7 "hh member 7"
label var qn2_2_8 "hh member 8"
label var qn2_2_9 "hh member 9"
label var qn2_2_10 "hh member 10"
label var qn2_2_11 "hh member 11"
label var qn2_2_12 "hh member 12"
label var qn2_2_13 "hh member 13"
label var qn2_2_14 "hh member 14"
label var qn2_2_15 "hh member 15"
label var qn2_2_16 "hh member 16"
label var qn2_2_17 "hh member 17"
label var qn2_2_18 "hh member 18"
label var qn2_2_19 "hh member 19"
label var qn2_2_20 "hh member 20"
label var qn2_2_21 "hh member 21"
label var qn2_2_22 "hh member 22"
label var qn2_2_23 "hh member 23"
label var qn2_2_24 "hh member 24"

label var qn2_5_1 "age member 1"
label var qn2_5_2 "age member 2"
label var qn2_5_3 "age member 3"
label var qn2_5_4 "age member 4"
label var qn2_5_5 "age member 5"
label var qn2_5_6 "age member 6"
label var qn2_5_7 "age member 7"
label var qn2_5_8 "age member 8"
label var qn2_5_9 "age member 9"
label var qn2_5_10 "age member 10"
label var qn2_5_11 "age member 11"
label var qn2_5_12 "age member 12"
label var qn2_5_13 "age member 13"
label var qn2_5_14 "age member 14"
label var qn2_5_15 "age member 15"
label var qn2_5_16 "age member 16"
label var qn2_5_17 "age member 17"
label var qn2_5_18 "age member 18"
label var qn2_5_19 "age member 19"
label var qn2_5_20 "age member 20"
label var qn2_5_21 "age member 21"
label var qn2_5_22 "age member 22"
label var qn2_5_23 "age member 23"
label var qn2_5_24 "age member 24"

label var qn5_2_1 "cultivated maize"
label var qn5_2_2 "cultivated matooke"
label var qn5_2_3 "cultivated cassave"
label var qn5_2_4 "cultivated millet"
label var qn5_2_5 "cultivated sorghum"
label var qn5_2_6 "cultivated rice"
label var qn5_2_7 "cultivated irish potatoes"
label var qn5_2_8 "cultivated sweet potatoes"
label var qn5_2_9 "cultivated yams"
label var qn5_2_10 "cultivated ground nuts"
label var qn5_2_11 "cultivated simsim"
label var qn5_2_12 "cultivated beans"
label var qn5_2_13 "cultivated soya beans"
label var qn5_2_14 "cultivated cowpeas"
label var qn5_2_15 "cultivated peas"
label var qn5_2_16 "cultivated kale/sukuma wiki"
label var qn5_2_17 "cultivated local greens"
label var qn5_2_18 "cultivated eggplants"
label var qn5_2_19 "cultivated okra"
label var qn5_2_20 "cultivated onions"
label var qn5_2_21 "cultivated tomatoes"
label var qn5_2_22 "cultivated carrots"
label var qn5_2_23 "cultivated pumkins"
label var qn5_2_24 "cultivated cabbage"
label var qn5_2_25 "cultivated watermelon"
label var qn5_2_26 "cultivated bananas"
label var qn5_2_27 "cultivated avocados"
label var qn5_2_28 "cultivated pineapple"
label var qn5_2_29 "cultivated coffee"
label var qn5_2_30 "cultivated tea"
label var qn5_2_31 "cultivated sugercane"
label var qn5_2_32 "cultivated cotton"
label var qn5_2_33 "cultivated tobacco"
label var qn5_2_34 "cultivated other cerals/staple crops"
label var qn5_2_35 "cultivated other beans/ nuts"
label var qn5_2_36 "cultivated other vegestables"
label var qn5_2_37 "cultivated other fruits"

label var qn6_1_1 "income earner member 1"
label var qn6_1_2 "income earner member 2"
label var qn6_1_3 "income earner member 3"
label var qn6_1_4 "income earner member 4"
label var qn6_1_5 "income earner member 5"
label var qn6_1_6 "income earner member 6"
label var qn6_1_7 "income earner member 7"
label var qn6_1_8 "income earner member 8"
label var qn6_1_9 "income earner member 9"
label var qn6_1_10 "income earner member 10"
label var qn6_1_11 "income earner member 11"
label var qn6_1_12 "income earner member 12"
label var qn6_1_13 "income earner member 13"
label var qn6_1_14 "income earner member 14"
label var qn6_1_15 "income earner member 15"
label var qn6_1_16 "income earner member 16"
label var qn6_1_17 "income earner member 17"
label var qn6_1_18 "income earner member 18"
label var qn6_1_19 "income earner member 19"
label var qn6_1_20 "income earner member 20"
label var qn6_1_21 "income earner member 21"
label var qn6_1_22 "income earner member 22"
label var qn6_1_23 "income earner member 23"
label var qn6_1_24 "income earner member 24"

label var qn7_12_1 "saving kept in: home"
label var qn7_12_2 "saving kept in: outside hh"
label var qn7_12_3 "saving kept in: neighbor/friend"
label var qn7_12_4 "saving kept in: shopekeeper"
label var qn7_12_5 "saving kept in: ROSCA/ similar"
label var qn7_12_6 "saving kept in: NGO"
label var qn7_12_7 "saving kept in: Bank"
label var qn7_12_96 "saving kept in: other"

label var qn8_14_1b_1 "attended agr. training member 1"
label var qn8_14_1b_2 "attended agr. training member 2"
label var qn8_14_1b_3 "attended agr. training member 3"
label var qn8_14_1b_4 "attended agr. training member 4"
label var qn8_14_1b_5 "attended agr. training member 5"
label var qn8_14_1b_6 "attended agr. training member 6"
label var qn8_14_1b_7 "attended agr. training member 7"
label var qn8_14_1b_8 "attended agr. training member 8"
label var qn8_14_1b_9 "attended agr. training member 9"
label var qn8_14_1b_10 "attended agr. training member 10"
label var qn8_14_1b_11 "attended agr. training member 11"
label var qn8_14_1b_12 "attended agr. training member 12"
label var qn8_14_1b_13 "attended agr. training member 13"
label var qn8_14_1b_14 "attended agr. training member 14"
label var qn8_14_1b_15 "attended agr. training member 15"
label var qn8_14_1b_16 "attended agr. training member 16"
label var qn8_14_1b_17 "attended agr. training member 17"
label var qn8_14_1b_18 "attended agr. training member 18"
label var qn8_14_1b_19 "attended agr. training member 19"
label var qn8_14_1b_20 "attended agr. training member 20"
label var qn8_14_1b_21 "attended agr. training member 21"
label var qn8_14_1b_22 "attended agr. training member 22"
label var qn8_14_1b_23 "attended agr. training member 23"
label var qn8_14_1b_24 "attended agr. training member 24"

label var qn8_14_2b_1 "vocational training member 1"
label var qn8_14_2b_2 "vocational training member 2"
label var qn8_14_2b_3 "vocational training member 3"
label var qn8_14_2b_4 "vocational training member 4"
label var qn8_14_2b_5 "vocational training member 5"
label var qn8_14_2b_6 "vocational training member 6"
label var qn8_14_2b_7 "vocational training member 7"
label var qn8_14_2b_8 "vocational training member 8"
label var qn8_14_2b_9 "vocational training member 9"
label var qn8_14_2b_10 "vocational training member 10"
label var qn8_14_2b_11 "vocational training member 11"
label var qn8_14_2b_12 "vocational training member 12"
label var qn8_14_2b_13 "vocational training member 13"
label var qn8_14_2b_14 "vocational training member 14"
label var qn8_14_2b_15 "vocational training member 15"
label var qn8_14_2b_16 "vocational training member 16"
label var qn8_14_2b_17 "vocational training member 17"
label var qn8_14_2b_18 "vocational training member 18"
label var qn8_14_2b_19 "vocational training member 19"
label var qn8_14_2b_20 "vocational training member 20"
label var qn8_14_2b_21 "vocational training member 21"
label var qn8_14_2b_22 "vocational training member 22"
label var qn8_14_2b_23 "vocational training member 23"
label var qn8_14_2b_24 "vocational training member 24"

label var qn8_14_3b_1 "business training member 1"
label var qn8_14_3b_2 "business training member 2"
label var qn8_14_3b_3 "business training member 3"
label var qn8_14_3b_4 "business training member 4"
label var qn8_14_3b_5 "business training member 5"
label var qn8_14_3b_6 "business training member 6"
label var qn8_14_3b_7 "business training member 7"
label var qn8_14_3b_8 "business training member 8"
label var qn8_14_3b_9 "business training member 9"
label var qn8_14_3b_10 "business training member 10"
label var qn8_14_3b_11 "business training member 11"
label var qn8_14_3b_12 "business training member 12"
label var qn8_14_3b_13 "business training member 13"
label var qn8_14_3b_14 "business training member 14"
label var qn8_14_3b_15 "business training member 15"
label var qn8_14_3b_16 "business training member 16"
label var qn8_14_3b_17 "business training member 17"
label var qn8_14_3b_18 "business training member 18"
label var qn8_14_3b_19 "business training member 19"
label var qn8_14_3b_20 "business training member 20"
label var qn8_14_3b_21 "business training member 21"
label var qn8_14_3b_22 "business training member 22"
label var qn8_14_3b_23 "business training member 23"
label var qn8_14_3b_24 "business training member 24"

label var qn8_14_4b_1 "vsla training member 1"
label var qn8_14_4b_2 "vsla training member 2"
label var qn8_14_4b_3 "vsla training member 3"
label var qn8_14_4b_4 "vsla training member 4"
label var qn8_14_4b_5 "vsla training member 5"
label var qn8_14_4b_6 "vsla training member 6"
label var qn8_14_4b_7 "vsla training member 7"
label var qn8_14_4b_8 "vsla training member 8"
label var qn8_14_4b_9 "vsla training member 9"
label var qn8_14_4b_10 "vsla training member 10"
label var qn8_14_4b_11 "vsla training member 11"
label var qn8_14_4b_12 "vsla training member 12"
label var qn8_14_4b_13 "vsla training member 13"
label var qn8_14_4b_14 "vsla training member 14"
label var qn8_14_4b_15 "vsla training member 15"
label var qn8_14_4b_16 "vsla training member 16"
label var qn8_14_4b_17 "vsla training member 17"
label var qn8_14_4b_18 "vsla training member 18"
label var qn8_14_4b_19 "vsla training member 19"
label var qn8_14_4b_20 "vsla training member 20"
label var qn8_14_4b_21 "vsla training member 21"
label var qn8_14_4b_22 "vsla training member 22"
label var qn8_14_4b_23 "vsla training member 23"
label var qn8_14_4b_24 "vsla training member 24"

label var qn8_14_5b_1 "leadership training member 1"
label var qn8_14_5b_2 "leadership training member 2"
label var qn8_14_5b_3 "leadership training member 3"
label var qn8_14_5b_4 "leadership training member 4"
label var qn8_14_5b_5 "leadership training member 5"
label var qn8_14_5b_6 "leadership training member 6"
label var qn8_14_5b_7 "leadership training member 7"
label var qn8_14_5b_8 "leadership training member 8"
label var qn8_14_5b_9 "leadership training member 9"
label var qn8_14_5b_10 "leadership training member 10"
label var qn8_14_5b_11 "leadership training member 11"
label var qn8_14_5b_12 "leadership training member 12"
label var qn8_14_5b_13 "leadership training member 13"
label var qn8_14_5b_14 "leadership training member 14"
label var qn8_14_5b_15 "leadership training member 15"
label var qn8_14_5b_16 "leadership training member 16"
label var qn8_14_5b_17 "leadership training member 17"
label var qn8_14_5b_18 "leadership training member 18"
label var qn8_14_5b_19 "leadership training member 19"
label var qn8_14_5b_20 "leadership training member 20"
label var qn8_14_5b_21 "leadership training member 21"
label var qn8_14_5b_22 "leadership training member 22"
label var qn8_14_5b_23 "leadership training member 23"
label var qn8_14_5b_24 "leadership training member 24"

label var qn8_14_6b_1 "community development training member 1"
label var qn8_14_6b_2 "community development training member 2"
label var qn8_14_6b_3 "community development training member 3"
label var qn8_14_6b_4 "community development training member 4"
label var qn8_14_6b_5 "community development training member 5"
label var qn8_14_6b_6 "community development training member 6"
label var qn8_14_6b_7 "community development training member 7"
label var qn8_14_6b_8 "community development training member 8"
label var qn8_14_6b_9 "community development training member 9"
label var qn8_14_6b_10 "community development training member 10"
label var qn8_14_6b_11 "community development training member 11"
label var qn8_14_6b_12 "community development training member 12"
label var qn8_14_6b_13 "community development training member 13"
label var qn8_14_6b_14 "community development training member 14"
label var qn8_14_6b_15 "community development training member 15"
label var qn8_14_6b_16 "community development training member 16"
label var qn8_14_6b_17 "community development training member 17"
label var qn8_14_6b_18 "community development training member 18"
label var qn8_14_6b_19 "community development training member 19"
label var qn8_14_6b_20 "community development training member 20"
label var qn8_14_6b_21 "community development training member 21"
label var qn8_14_6b_22 "community development training member 22"
label var qn8_14_6b_23 "community development training member 23"
label var qn8_14_6b_24 "community development training member 24"


//****************************************************************************
//*************		Section 6: Order and Sort

order _all, sequential
order key idno sn round tup treat* youth* hh* 
order subcounty village, after(district)
order resp_e, after(resp_b)
order branch_e, after(branch_b)
order qn1_1, after(subcounty)
order g*, last
order vsla*, last

sort idno round

//****************************************************************************
//*************		Section 7: Save Dataset
xtset idno round
gen asset_grow = (acres_cult - L1.acres_cult)/2
gen inc_grow = (inc - L1.inc)/2

save "`input'\single\tup_clean.dta", replace
