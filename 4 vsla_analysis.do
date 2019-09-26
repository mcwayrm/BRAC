clear
set more off
log close _all

/*****************
Description:
	 Analysis for VSLA in association with TUP Graduation Programme
	 
	 Sections:
		1. Merge VSLA with TUP data 
		2. Summary Statistics
		3. Balance Table
		4. Graphics
		5. Regressions and Post-Estimations
*****************/

local date `c(current_date)'
local time `c(current_time)'
if "`c(username)'"=="Ryry"  ///
     local home "C:\Users\Ryry\Dropbox\Ryan_Intern\TUP Data Final"
	 global USER "Ryan McWay"
else if "`c(username)'"=="Danish IERC"  ///
     local home "C:\Users\Danish IERC\Dropbox\Ryan_Intern\TUP Data Final" 
	 global USER "Danish Us Saleem"
else if "`c(username)'"=="DELL"  ///
     local home "C:\Users\DELL\Dropbox\Ryan_Intern\TUP Data Final" 
	 global USER "Patrick Olobo"
else if "`c(username)'"=="KGC"  ///
     local home "C:\Users\KGC\Dropbox\Ryan_Intern\TUP Data Final" 
	 global USER "Dennis Oundo"
//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
cd "`home'"
local input	"`home'\data"
local output "`home'\results"

//*****************************************************************************
display "Analysis run by $USER for TUP clean at `date' and `time'"

//****************************************************************************
//*************		Section 1: Merge VSLA and TUP data

do "`home'\scripts\import_vsla_tup_ug.do"

/*
	Missing VSLA: Magamaga, Kyasnyi, Kito-WBZ, Kabuwombero, Buyuki

	Godown resp_name == "Wandera Wilson"
	Dyang resp_name == "Nalule Phiona" 
	Pocheng resp_name == "Wanchan Alfred"
	Siriba Central resp_name = "Byansi Fred"
*/

drop if resp_name == "Nyeko Joseph" | resp_name == "Omongole Moses" | resp_name == "Byaruhanga Emmanuel" | resp_name == "Opyem Jinaro" | resp_name == "Kusiima Beatrice" | resp_name == "Nayengo Jida"
drop formdef* key submission* start end date enumerator branch
rename (resp_name geocoordinatelatitude geocoordinatelongitude geocoordinatealtitude geocoordinateaccuracy vsla) (vsla_resp_name vsla_geo_lat vsla_geo_long vsla_geo_alt vsla_geo_acc vsla_branch) 

save "`input'\vsla_raw.dta", replace
use "`input'\single\tup_clean.dta", clear
merge m:1 vsla_branch using "`input'\vsla_raw.dta"
//	The reason that some of vsla_tup == 1 doesn't have a match is because in vsla_raw.dta there is no interview for that particular branch
drop _merge 
drop if vsla_tup == 14 | vsla_tup == 13 | vsla_tup == 16
save "`input'\vsla_clean.dta", replace

//****************************************************************************
//*************		Section 2: Summary Statistics

//**	Indicator Summary Table
preserve
keep idno tup treatment treat hhsize vsla_tup* inc inc_30 inc_grow pscore plikely asset_grow acres_cult sec5_9_livestock_count num_jobs one_job two_jobs inc1_dum inc2_dum inc3_dum inc4_dum train_num train_2 qn8_14_?a qn4_1 meals_2 meals_3 hfias HFIAS_* qn7_11 qn7_13 save_usd sold_mkt vsla_mem vsla_male vsla_female vsla_tup share_size total_savings saver_last_month total_loan total_loanee interest_rate profit default_amount registered vsla_start
outreg2 using "`output'\\vsla_sum_stats.xls", excel sum(log) replace
restore

//****************************************************************************
//*************		Section 3: Balance Table

// Endline
table1 if (round == 1), by(vsla_tup) vars(inc contn \ inc_30 contn \ inc_grow contn \ pscore contn \ plikely contn \ asset_grow conts \ acres_cult contn \ sec5_9_livestock_count contn \ num_jobs contn \ one_job bin \ two_jobs bin \ train_num contn \ train_2 bin  \ qn4_1 cat \ meals_2 bin \ meals_3 bin \  HFIAS_qual bin \ HFIAS_quant bin \ qn7_11 bin \ qn7_13 conts \ save_usd conts \ sold_mkt bin \) ///
pdp(3) saving("`output'\vsla_balance_table.xlsx", replace) onecol missing format(%2.1f)

//****************************************************************************
//*************		Section 4: Graphics


//****************************************************************************
//*************		Section 5: Regressions and Post-estimations

// Maybe fixed effects for ela branch?
foreach v of varlist inc pscore asset_grow meals_2 meals_3 num_jobs save_usd sold_mkt{
	reg `v' vsla_tup
	coefplot, drop(_cons) xline(0)
	reg `v' vsla_tup tup
	coefplot, drop(_cons) xline(0)
}

reg inc vsla_tup if (inc <= 50), absorb(branch_e)
coefplot, drop(_cons) xline(0)
reghdfe inc vsla_tup, absorb(branch_e)

reg inc_grow vsla_tup tup if (inc <= 50), absorb(branch_e)
coefplot, drop(_cons) xline(0)

//heterogenity
foreach v of varlist inc inc_grow pscore save_usd meals_2 asset_grow num_jobs{
	reg `v' round##vsla_tup
}
