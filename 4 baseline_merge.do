clear
set more off
log close _all

/*****************
Description:
	 Merge SMU baseline catchment, listing and CR survey into a master do.
	 
*****************/

global USER "Ryan McWay"
local date `c(current_date)'
local time `c(current_time)'
local home "<local>"
//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
**************************************************************************
cd "`home'"
local input	"`home'\input"
local edit "`home'\edit"
local output "`home'\output"
**************************************************************************
display "Analysis run by $USER at `date' and `time'"

use "`edit'\baseline_catchmentarea.dta", clear


save "`edit'\baseline_master.dta", replace
