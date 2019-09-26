clear
set more off
log close _all

/*****************
Description:
	 Checks for SMU baseline data.
	 
*****************/

global USER "Ryan McWay"
local date `c(current_date)'
local time `c(current_time)'
local home "C:\Users\Ryry\Dropbox\Ryan Intern - SMU\"
//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
cd "`home'"
local input	"`home'\input"
local edit "`home'\edit"
local output "`home'\output"
**************************************************************************
display "Analysis run by $USER at `date' and `time'"

****************************************************************************

//***** Check for specific day

* drop if submissiondate != ""

//***** Check a specific Enumerator

* drop if enum_id != 

****************************************************************************

//*******	Catchment Area
use "`edit'\baseline_catchmentarea.dta", clear

list instanceid enum_name if club_loc_acc >500 

save "`edit'\baseline_catchmentarea.dta", replace

****************************************************************************

//********	Listing
use "`edit'\baseline_listing.dta", clear

list instanceid enum_name if geoaccuracy > 500
list instanceid enum_name if date_check != date_match
/*******
	 Instances for Bisikwa Sharon on May 25th is most likely due to connectivity issue as they all arrive around the same time.
*******/
replace club_name = strproper(club_name)
*list instanceid enum_name if (branch = 11 & club = 13 & club_name != "Katongole" )
*| club_name != "Kiwafu" | club_name != "Mosque" | club_name != "Salaama" | club_name != "Kanyogoga" | club_name != "Green Hill" | club_name != "Luwafu" | club_name != "Gaaba" | club_name != "Massaja" | club_name != "Baba" | club_name != "Muswangali" | club_name != "Nsaabya" | club_name != "Namuwongo" | club_name != "Bbunga" | club_name != "Makindye" | club_name != "Kirombe A")

//****** hh Id 11134951 for seguya hilda is same person as hh id 11135241 for bisikwa sharon


save "`edit'\baseline_listing.dta", replace

*****************************************************************************

//********	CR Survey
use "`edit'\baseline_CRsurvey.dta", clear

list instanceid enum_name if date_check != date_match
/*********
	 instanceid = uuid:8598a6ec-47d7-4cb9-8c94-5092196e1326 is a connectivity issue, with correct date. 
	 instanceid = uuid:b952ceb3-c99a-4e37-8a58-383bab32d371 maybe that hilda is submitting her survey later. 
*********/
list instanceid enum_name if (branch != 11 & club != 2) 
list instanceid enum_name if (branch != 11 & club != 7)
list instanceid enum_name if (branch != 11 & club != 8)
list instanceid enum_name if (branch != 11 & club != 9)
list instanceid enum_name if (branch != 11 & club != 11)
list instanceid enum_name if (branch != 11 & club != 12)
list instanceid enum_name if (branch != 11 & club != 13)
list instanceid enum_name if (branch != 11 & club != 15)

//****** hh_id 11134951 for seguya hilda is same person as hh_id 11135241 for bisikwa sharon



save "`edit'\baseline_CRsurvey.dta", replace
