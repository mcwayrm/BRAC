clear
set more off
log close _all

/*****************
Description:
	 Cleaning SMU baseline data.
	 
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

*****************************************************************************

//*******	Catchment Area
use "`edit'\baseline_catchmentarea.dta", clear

gen club_name = ""
replace club_name = "Luwafu" if (enum_id == 1 & submissiondate == "May 21, 2019 2:02:22 PM") 
replace club_name = "Makindye" if (enum_id == 1 & submissiondate == "May 29, 2019 3:30:36 PM")
replace club_name = "Kanyogoga" if (enum_id == 5 & submissiondate == "May 21, 2019 12:03:33 PM")
replace club_name = "NAMUWONGO" if (enum_id == 5 & submissiondate == "May 29, 2019 11:48:39 AM")
replace club_name = "KATONGOLE" if (enum_id == 7 & submissiondate == "May 24, 2019 2:27:51 PM")
replace club_name = "MASSAJA" if (enum_id == 7 & submissiondate == "May 29, 2019 12:05:07 PM")
replace club_name = "GREEN HILL" if (enum_id == 8 & submissiondate == "May 21, 2019 11:02:50 AM")
replace club_name = "BBUNGA" if (enum_id == 8 & submissiondate == "May 29, 2019 11:49:21 AM")
replace club_name = "MOSQUE" if (enum_id == 13 & submissiondate == "May 21, 2019 11:01:17 AM")
replace club_name = "MUSWANGALI" if (enum_id == 13 & submissiondate == "May 29, 2019 12:13:25 PM")
replace club_name = "GAABA" if (enum_id == 25 & submissiondate == "May 21, 2019 11:36:23 AM")
replace club_name = "KIROMBE A" if (enum_id == 25 & submissiondate == "May 29, 2019 10:45:50 AM")
replace club_name = "SALAAMA" if (enum_id == 32 & submissiondate == "May 21, 2019 1:07:55 PM")
replace club_name = "NSAABYA" if (enum_id == 32 & submissiondate == "May 29, 2019 12:15:22 PM")
replace club_name = "KIWAFU" if (enum_id == 41 & submissiondate == "May 21, 2019 11:48:02 AM")
replace club_name = "BABA" if (enum_id == 41 & submissiondate == "May 29, 2019 11:50:37 AM")
replace club_name = strproper(club_name)
/*
gen club = .
replace club = "Luwafu" if (enum_id == 1 & submissiondate == "May 21, 2019 2:02:22 PM") 
replace club = "Makindye" if (enum_id == 1 & submissiondate == "May 29, 2019 3:30:36 PM")
replace club = "Kanyogoga" if (enum_id == 5 & submissiondate == "May 21, 2019 12:03:33 PM")
replace club = "NAMUWONGO" if (enum_id == 5 & submissiondate == "May 29, 2019 11:48:39 AM")
replace club = "KATONGOLE" if (enum_id == 7 & submissiondate == "May 24, 2019 2:27:51 PM")
replace club = "MASSAJA" if (enum_id == 7 & submissiondate == "May 29, 2019 12:05:07 PM")
replace club = "GREEN HILL" if (enum_id == 8 & submissiondate == "May 21, 2019 11:02:50 AM")
replace club = "BBUNGA" if (enum_id == 8 & submissiondate == "May 29, 2019 11:49:21 AM")
replace club = "MOSQUE" if (enum_id == 13 & submissiondate == "May 21, 2019 11:01:17 AM")
replace club = "MUSWANGALI" if (enum_id == 13 & submissiondate == "May 29, 2019 12:13:25 PM")
replace club = "GAABA" if (enum_id == 25 & submissiondate == "May 21, 2019 11:36:23 AM")
replace club = "KIROMBE A" if (enum_id == 25 & submissiondate == "May 29, 2019 10:45:50 AM")
replace club = "SALAAMA" if (enum_id == 32 & submissiondate == "May 21, 2019 1:07:55 PM")
replace club = "NSAABYA" if (enum_id == 32 & submissiondate == "May 29, 2019 12:15:22 PM")
replace club = "KIWAFU" if (enum_id == 41 & submissiondate == "May 21, 2019 11:48:02 AM")
replace club = "BABA" if (enum_id == 41 & submissiondate == "May 29, 2019 11:50:37 AM")
*/
order club_name, after(enum_name)

drop if instanceid == "uuid:95e9cc30-b28b-402e-9bef-854ce98da56b"

save "`edit'\baseline_catchmentarea.dta", replace

*****************************************************************************

//********	Listing
use "`edit'\baseline_listing.dta", clear

drop date_check date_match

/*******
	 Droping to see outliers. Can remove later if you'd like.
	 -99 = Don't Know
	 -98 = No Phone
*******/
foreach v of varlist any_young_female any_young_female_neighbor nr_cr_neighbor cr_roster_neig_count atleast_1_nr{
	recode `v' (-99 = .)
	recode `v' (-98 = .)
}

replace club_name = "Nsambya" if enum_id == 15 & date == "May 29, 2019"
replace club_name = strproper(club_name)

replace date = "May 25, 2019" if instanceid == "uuid:5e084036-0e09-4f05-a05a-2ee1bc1db457"
replace date = "May 24, 2019" if instanceid == "uuid:75705d8f-b2ff-4ee3-bce1-2382ef7f9f0a"
replace date = "May 24, 2019" if instanceid == "uuid:e1062d9d-a1a2-41b5-b068-fc5002639ac3"
replace date = "May 24, 2019" if instanceid == "uuid:7b2f833d-acbd-412e-8b84-27e97b6565a0"
replace date = "May 29, 2019" if instanceid == "uuid:d32327fb-254a-44da-a9eb-790c77c52d4a"

save "`edit'\baseline_listing.dta", replace

*****************************************************************************

//********	CR Survey
use "`edit'\baseline_CRsurvey.dta", clear

/*******
	 Droping to see outliers. Can remove later if you'd like.
	 -99 = Don't Know
	 -98 = General N/A taking different specific forms
 	 -97 = Ref
	 -96 = Other
*******/
foreach v of varlist contact_planning_move contact_number_father2 contact_number_father1 contact_number_mother2 contact_number_mother1 concl13 concl5 contact_move_planning_when contact_cr_phone com_scenariob_answer f_hopedyrs f_raisechild f_outcomepreg s_partnerold s_agetest s_nr100yo s_nrpartners s_sexage s_eversex ms_yrshoped ms_bfold fie_informalloan fie_formalloan fie_futurejob fie_mainuse pw_mainweekearned pw_mainactivityhours pw_mainactivity mh_rosb_qualities ta_childcare ta_typicalday ta_hrschildren ta_2021 ta_1819 ta_1617 ta_1516 ta_1415 ta_1314 ta_910 mh_ghq12_problems ed_age_stoppedattending self_ethnic fb_mother_alive fb_father_alive fb_hhhead_relationship sn_nrfriends ed_insession consent_club consent_elanotela consent_knowsdob ed_insession_listing_string ed_insession_listing{
	recode `v' (-99 = .)
	recode `v' (-98 = .)
	recode `v' (-97 = .)
	recode `v' (-96 = .)
}
foreach v of varlist cr_name female_name lit_consent_name_cg enum_cg_name lit_consent_name_emanccr enum_emanc_cr_name lit_consent_name_cg_2 enum_cg_2_name lit_consent_name_adultcr enum_adult_cr_name lit_consent_name_nonemanccr illit_consent_witness_name_nonem illit_consent_name_nonemanccr enum_nonemanc_cr_name fb_hhhead_name contact_cr_nickname contact_name_mother contact_name_father{
	replace `v' = strproper(`v')
}
 

save "`edit'\baseline_CRsurvey.dta", replace


