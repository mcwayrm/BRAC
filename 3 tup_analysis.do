clear
set more off
log close _all

/*****************
Description:
	 Analysis for TUP Graduation Programme
		Baseline, Midline and Endline
	 
	 Sections:
		1. Logframe Indicators
		2. Summary Statistics
		3. Balance Table
		4. Graphics
		5. Regressions and Post-Estimations
*****************/

local date `c(current_date)'
local time `c(current_time)'
if "`c(username)'"=="Ryry"  ///
     local home "<local>"
	 global USER "Dennis Oundo"
//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
cd "`home'"
local input	"`home'\data"
local output "`home'\results"

use "`input'\single\tup_clean.dta", clear

//****************************************************************************
//*************		Section 1: Logframe Indicators


/*******************************
		Indicator 1: Poverty Line
********************************/

foreach v of varlist inc inc_30 pscore plikely{
	bysort round: tab `v' tup
}

/*******************************
		Indicator 2: % Asset Growth
********************************/

foreach v of varlist asset_grow acres_cult sec5_9_livestock_count{
	bysort round: tab `v' tup
}

/*******************************
		Indicator 3: % of targeted youth with 2 income sources
********************************/

foreach v of varlist num_jobs one_job two_jobs inc1_dum inc2_dum inc3_dum inc4_dum{
	bysort round: tab `v' tup
}

/*******************************
		Indicator 4: % at least 2 new tech. through training for agr. or livestock production
********************************/

foreach v of varlist train_num train_2 qn8_14_?a{
	bysort round: tab `v' tup
}

/*******************************
		Indicator 5: % families able to eat twice daily
********************************/

foreach v of varlist qn4_1 meals_2 meals_3 hfias HFIAS_*{
	bysort round: tab `v' tup
}

/*******************************
		Indicator 6: % of active monthly savers
********************************/

foreach v of varlist qn7_11 qn7_13 save_usd{
	bysort round: tab `v' tup
}

/*******************************
		Indicator 7: % youth group able to sell produce in mkt
********************************/

foreach v of varlist sold_mkt{
	bysort round: tab `v' tup
}

//****************************************************************************
//*************		Section 2: Summary Statistics

//* Attrition
tab round tup	// 106 lost, 4.45% from baseline

//**	Didn't recieve treatment
count if (treatment == "Treatment" & treat == 0)
//****	sn 1874 135 138 132 142 344 109 1316, idno 5436 3432 4430 7521 4140 1627 4609 4984 7011 8789 8795 8833 9016 8824 1141 7382 7399 8660 

//**	Control recieved treatment
count if (treatment == "Control" & treat == 1)
//****	idno 4736 9007

//**	Indicator Summary Table
preserve
keep idno tup treatment treat hhsize vsla_tup* inc inc_30 pscore plikely asset_grow acres_cult sec5_9_livestock_count num_jobs one_job two_jobs inc1_dum inc2_dum inc3_dum inc4_dum train_num train_2 qn8_14_?a qn4_1 meals_2 meals_3 hfias HFIAS_* qn7_11 qn7_13 save_usd sold_mkt
outreg2 using "`output'\\tup_sum_stats.xlsx", excel sum(log) replace
restore

/*******************************
		Combined Indicators Table
********************************/
// Baseline
table1 if (round == 0), by(tup) vars(inc contn \ inc_30 contn \ pscore contn \ plikely contn \ acres_cult contn \ num_jobs contn \ one_job bin \ two_jobs bin \ train_num contn \ train_2 bin \ qn4_1 cat \ meals_2 bin \ meals_3 bin \ HFIAS_qual bin \ HFIAS_quant bin \ qn7_11 bin \ qn7_13 conts \ save_usd conts \ sold_mkt bin \) ///
pdp(3) saving("`output'\tup_logframe_indicators_baseline.xlsx", replace) onecol missing format(%2.1f)

// Endline
table1 if (round == 1), by(tup) vars(inc contn \ inc_30 contn \ pscore contn \ plikely contn \ asset_grow conts \ acres_cult contn \ sec5_9_livestock_count contn \ num_jobs contn \ one_job bin \ two_jobs bin \ train_num contn \ train_2 bin  \ qn4_1 cat \ meals_2 bin \ meals_3 bin \  HFIAS_qual bin \ HFIAS_quant bin \ qn7_11 bin \ qn7_13 conts \ save_usd conts \ sold_mkt bin \) ///
pdp(3) saving("`output'\tup_logframe_indicators_endline.xlsx", replace) onecol missing format(%2.1f)
* Maybe add \ qn8_14_1a bin \ qn8_14_2a bin \ qn8_14_3a bin \ qn8_14_4a bin \ qn8_14_5a bin \ qn8_14_6a bin


//****************************************************************************
//*************		Section 3: Balance Table

// Poverty and Income
table1, by(tup) vars(pscore contn %2.1f \ plikely contn %2.1f) onecol  missing format(%2.1f) pdp(3) saving("`output'\tup_balance_poverty.xlsx", replace)

// Food Insecurity
table1, by(tup) vars(hfias cat \ HFIAS_CAT cat \ HFIAS_qual cat \ HFIAS_quant cat) onecol missing format(%2.1f) pdp(3) saving("`output'\tup_balance_food.xlsx", replace)

// Health
table1, by(tup) vars(qn10_13_1 cat\ qn10_13_2 cat\qn10_13_1 cat\ qn10_13_5 bin\qn10_13_6 bin\ qn10_13_7 bin) pdp(3) saving("`output'\tup_balance_health.xlsx", replace) onecol  missing format(%2.1f) 

// Vulnerability
table1, by(tup) vars(qn8_2 bin\ qn8_3 bin\qn8_4 bin\ qn8_5 bin \qn8_6 bin) onecol missing format(%2.1f) pdp(3) saving("`output'\tup_balance_vulnerability.xlsx", replace)

// Support
table1, by(tup) vars(qn8_7_1a bin\ qn8_7_1b conts\ qn8_7_2a bin\ qn8_7_2b conts\ qn8_7_3a bin\qn8_7_3b conts\qn8_7_4a bin\qn8_7_4b conts\qn8_7_5a bin\ qn8_7_5b conts\ qn8_7_9a bin\ qn8_7_9b conts\qn8_8 bin\qn8_9 conts\qn8_10 bin\ qn8_11 conts\qn8_12 bin\ qn8_13 conts)  saving("`output'\tup_balance_support_skew.xlsx", replace) onecol missing pdp(3) format(%2.1f) 
	//skewed option

table1, by(tup) vars(qn8_7_1a bin\ qn8_7_1b contn\ qn8_7_2a bin\ qn8_7_2b contn\ qn8_7_3a bin\qn8_7_3b contn\qn8_7_4a bin\qn8_7_4b contn\qn8_7_5a bin\ qn8_7_5b contn\ qn8_7_9a bin\ qn8_7_9b contn\qn8_8 bin\qn8_9 contn\qn8_10 bin\ qn8_11 contn\qn8_12 bin\ qn8_13 contn)  saving("`output'\tup_balance_support.xlsx", replace) onecol missing pdp(3) format(%2.1f)
	//normal option

// Training
table1, by(tup) vars(qn8_14_1a bin\ qn8_14_2a bin\qn8_14_3a bin\ qn8_14_4a bin\qn8_14_5a bin\ qn8_14_6a bin) pdp(3) saving("`output'\tup_balance_training.xlsx", replace) onecol  missing format(%2.1f)

// WASH
table1, by(tup) vars(wash cont \ wash_pct cont \ w1 bin\ w2 bin\w3 bin\ w4 bin\w5 bin\ w6 bin\ w7 bin\ w8 bin\ w9 bin) pdp(3) saving("`output'\tup_balance_WASH.xlsx", replace) onecol  missing format(%2.1f)

// Precieved Well-Being
table1, by(tup) vars(qn11_26 cat\ qn11_27 cat\qn11_28 cat\ life_sat bin\qn11_29 cat\ qn11_33 cat\qn11_34 cat\qn11_35 cat\qn11_36 cat) pdp(3) saving("`output'\tup_balance_wellbeing.xlsx", replace) onecol  missing format(%2.1f) 
table1, by(tup) vars(satlife bin\ happynow bin\acheived bin\ life_sat bin\changelife bin) pdp(3) saving("`output'\tup_balance_wellbeing_2.xlsx", replace) onecol  missing format(%2.1f)

// Ravens Score
factor qn12_2_*,pcf 
table1, by(tup) vars(raven_tot contn) pdp(3) saving("`output'\tup_balance_ravens.xlsx", replace) onecol  missing format(%2.1f) 

// Food

// Market

// Savings

// Trainings

// Crops and Livestock

//****************************************************************************
//*************		Section 4: Graphics

// NOTE FROM BASELINE ***graphs***
*food security, asset ownership, coping mechanisms,training, WASH practices,health and depression,earnigns and emploment, hours and days worked,

//* Poverty
hist plikely , by(tup) normal addlabels percent scheme(sj)
hist plikely , by(round) normal addlabels percent scheme(sj)
hist plikely, by(tup round) normal addlabels percent scheme(sj)
kdensity pscore if (tup == 0 & round == 0), normal scheme(sj)
kdensity pscore if (tup == 1 & round == 1), normal scheme(sj)

//* Food

//* Health

//* Vulnerbility


//****************************************************************************
//*************		Section 5: Regressions and Post-Estimations

// Vulnerability
foreach v of varlist qn8_2 qn8_3 qn8_4 qn8_5 qn8_6 qn8_7_1a{
 reg `v' treat
}

// HH Assistance
foreach v of varlist qn8_7_*a{
  reg `v' treat
}
foreach v of varlist qn8_7_*b{
  reg `v' treat
}

// WASH
foreach v of varlist w?{
  reg `v' treat
}

// Health
logit qn10_13_7 qn10_13_5,or

// Ravens
reg  raven_tot f3 // What are the f1 f2 f3 var from baseline analysis?

******************************************************************************
******************************************************************************


  //////////////////////////////////
  *******family life*******
  //////////////////////////////////

	 ****factor analysis*****
alpha qn11_1-qn11_10
 factor qn11_1-qn11_10,pcf factors(3) //factor 1-7-10(sponteneity) , factor 2-1,2,3(rash,impulsive, hasty), factor 3-4,5,6(self controlled)
 rotate
 predict f1 f2 f3
 
  factor qn11_26-qn11_34,pcf 
  
  foreach var of varlist f1 f2 f3{
  logit qn10_13_7 `var',or
  }
  
pctile perc=plikely, nq(10)
collapse (mean) qn8_2 qn8_3 qn8_4,by(perc)
 
logit qn8_2 qn8_3 qn8_4 qn8_5 qn8_6 plikely,or //higher liklihood of being poor are more vulnerable
 
 foreach var of varlist f1 f2 f3{
 logit qn8_14_1a `var',or //training have higher sponteneity
 }

 logit qn8_14_1a f1 //training have higher sponteneity
 
 gen perc1=perc
 format perc1 %9.0f
 logit qn8_3 i.perc1,or

foreach var of varlist f1 f2 f3{
logistic qn10_13_7 qn10_13_5 qn2_10_1 `var' if resp1 ==1
}

foreach var of varlist f1 f2 f3{
logit qn10_13_7 qn10_13_5 qn2_10_1  qn8_4 qn8_6 hfias `var' if resp1 ==1, or
}

reg wash f1 f2 f3   qn2_10_1 //education has a bearing on f3 and wash
ologit wash f1 f2 f3 hfas3  qn2_10_1, or //hfias on wash
logit qn10_13_7 qn10_13_5 qn2_10_1  qn8_4 qn8_6 hfias,or //living with aids, orphaned exibit higher depression and school lower depression

global controlvars  "qn2_3_ qn2_5_ qn2_6_ qn2_10_ qn2_9_"
 logit qn10_13_7 qn10_13_5  qn8_4 qn8_6 plikely2 $controlvars ,or //higher liklihood of being poor are more vulnerable
logit qn10_13_7 qn10_13_5  qn8_4 qn8_6  plikely2 $controlvars 

logit qn10_13_7 qn10_13_5 qn2_10_1  qn8_4 qn8_6 ,or

logit qn8_2 qn8_3 qn8_4 qn8_5 qn8_6 plikely2 $controlvars ,or //higher liklihood of being poor are more vulnerable

