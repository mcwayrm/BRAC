clear
set more off
log close _all

/*****************
Description:
	 Checking whether submit date and date placed by enum are the same
*****************/

global USER "Ryan McWay"
local date `c(current_date)'
local time `c(current_time)'
local home "C:\Users\Ryry\Dropbox\Ryan_Intern\Strong Minds - Mental Health & Adolescent Empowerment"
//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
**************************************************************************
cd "`home'"
local input	"`home'\input"
local edit "`home'\edit"
local output "`home'\output"
**************************************************************************
display "Analysis run by $USER at `date' and `time'"



//**************		LISTING
import delimited "`input'\finalbaseline_listing.csv", clear

//***	Reformat before check
split submissiondate, parse("")
egen date_sub = concat(submissiondate1 submissiondate2 submissiondate3), punct(" ")
split starttime
egen date_start = concat(starttime1 starttime2 starttime3), punct(" ")
order date_sub date_start date


//***	Check date_sub = date_start (tech issues)
gen tech_issue = 0
replace tech_issue = 1 if (date_sub != date_start)
list enum_name date_sub date if (tech_issue == 1)


//***	Check if date_sub = date (enum's fault)
gen enum_fault = 0
replace enum_fault = 1 if (date_sub != date)
list enum_name date_sub date if (enum_fault == 1)
/* 
	PROBLEM CHILD
*/
list enum_name date_sub date if (enum_fault == 1 & tech_issue == 0)



//************			CR SURVEY
import delimited "`input'\finalbaseline_CRsurvey.csv", clear

//***	Reformat before check
split submissiondate, parse("")
egen date_sub = concat(submissiondate1 submissiondate2 submissiondate3), punct(" ")
split starttime
egen date_start = concat(starttime1 starttime2 starttime3), punct(" ")
order date_sub date_start date


//***	Check date_sub = date_start (tech issues)
gen tech_issue = 0
replace tech_issue = 1 if (date_sub != date_start)
list enum_name date_sub date if (tech_issue == 1)


//***	Check if date_sub = date (enum's fault)
gen enum_fault = 0
replace enum_fault = 1 if (date_sub != date)
list enum_name date_sub date if (enum_fault == 1)
/* 
	PROBLEM CHILD
*/
list enum_name date_sub date if (enum_fault == 1 & tech_issue == 0)

