clear
set more off
log close _all

/*****************
Description:
	 Labeling for SMU baseline data from SurveyCTO export.
	 Create .dta file in edit folder
*****************/

global USER "Ryan McWay"
local date `c(current_date)'
local time `c(current_time)'
local home "C:\Users\Ryry\Dropbox\Ryan Intern - SMU\"
//***** All paths should be relative so that all you need to change is `home' and $USER in order to run the dofile.
**************************************************************************
cd "`home'"
local input	"`home'\input"
local edit "`home'\edit"
local output "`home'\output"
**************************************************************************
display "Analysis run by $USER at `date' and `time'"

**********************************************************************

//********	Catchment Area

import delimited "`input'\finalbaseline_catchmentarea.csv", clear

drop catchment_clubpicture

labvars starttime endtime deviceid devicephonenum subscriberid duration formdef_version "Survey start time" "Survey end time" "Device ID" "Device Phone #" "Subscriber ID" "Duration in sec." "Form Version"

rename (profile_id profile_name catchment_clublocation_note catchment_clublocationlatitude catchment_clublocationlongitude catchment_clublocationaltitude catchment_clublocationaccuracy catchment_clubpicture_note catchment_point1_gpslatitude catchment_point1_gpslongitude catchment_point1_gpsaltitude catchment_point1_gpsaccuracy cathment_point1_description catchment_point2_gpslatitude catchment_point2_gpslongitude catchment_point2_gpsaltitude catchment_point2_gpsaccuracy cathment_point2_description catchment_point3_gpslatitude catchment_point3_gpslongitude catchment_point3_gpsaltitude catchment_point3_gpsaccuracy cathment_point3_description catchment_point4_gpslatitude catchment_point4_gpslongitude catchment_point4_gpsaltitude catchment_point4_gpsaccuracy cathment_point4_description) (enum_id enum_name club_loc_note club_loc_lat club_loc_long club_loc_alt club_loc_acc club_pic_note point1_lat point1_long point1_alt point1_acc point1_desc point2_lat point2_long point2_alt point2_acc point2_desc point3_lat point3_long point3_alt point3_acc point3_desc point4_lat point4_long point4_alt point4_acc point4_desc)

label define enum_names	1 "Isilo Irene" 2 "Mutebi Ronald" 3 "Wamala Denis" 4 "Dakasi Simon Peter" 5 "Wamanga Johnior" 6 "Adrine Kanyebaze" 7 "Tebagerwa Diana" 8 "Kalemba Edgar" 9 "Mutoto Emmanuel" 10 "Nasuuna Lydia" 11 "Nantongo Rebecca" 12 "Ilopu Irene Gertrude" 13 "Awori Jane" 14 "Aujo Mary Gorrety" 15 "Mulinda Alone" 16 "Akadu Enok" 17 "Kanyemera Fridah" 18 "Seguya Hilda" 19 "Wandhawa Catherine" 20 "Kabwama Brian" 21 "Ntono Lydia" 22 "Egesa Babra" 23 "Asere Juliet" 24 "Nabulo Brenda Phoebe" 25 "Kaffuuma Frank" 26 "Odongo Moses Ojulu" 27 "Ssebyooto Lawrence" 28 "Burungi Helen" 29 "Nakabuye Rashidah" 30 "Nalikiti Zeridah" 31 "Nankabirwa Maria Brenda" 32 "Aryemo Betty" 33 "Wambi Irene" 34 "Nabbuto Majorine" 35 "Yafesi Namakajjo" 36 "Turyamureeba Eliud" 37 "Mutonyi Suzan" 38 "Nandawula Lydia" 39 "Nalubwama Christine" 40 "Bagatya Nelson" 41 "Nakagolo Zahara" 42 "Akello Salume" 43 "Alenyo Joyce" 44 "Omunyini Abraham" 45 "Aseno Sandra" 46 "Outa Benjamin" 47 "Namuganza Majorine" 48 "Kalala Lawerence" 49 "Mazima Didas" 50 "Bisikwa Sharon" 51 "Saire Kimalyo Denis" 52 "Mugerwa John Paul" 53 "Kusemererwa Patrick" 54 "Nabuyungo Irene Sandra"
label values enum_name enum_names

sort enum_id submissiondate

save "`edit'\baseline_catchmentarea.dta", replace

**********************************************************************

//*********	Listing

import delimited "`input'\finalbaseline_listing.csv", clear


rename (start_time_hidden club_typed geopoint2latitude geopoint2longitude geopoint2altitude geopoint2accuracy) (hidden_start club_name latitude longitude altitude geoaccuracy)

labvars duration "Duration in sec." starttime "Survey Start time" endtime "Survey end time" branch "Branch" club "Club #" club_name "Name of Club" enum_id "Enumerator ID" enum_name "Enumerator's Name" nr_visit "# of visits to hh" anybody_home "Anybody at home" anybody_home_old "Girl >13 years at home" comment "Comments on survey" if_talkokay "Can talk to girl" if_talknotokay "Cannot talk to girl" if_talkokaylater "Can talk to girl later" any_young_female "girls <13 in HH" any_neighbors "Noone home, neighbor to talk to" any_neighbors_revisit "On revisit, neighbor to talk to" if_talkokay_neig "Can talk to neighbor" if_talkokaylater_neig "Can talk to neighbor later" any_young_female_neighbor "neighbor says HH has young girls" atleast_1_nr "Had at least 1 neighbor" latitude "geo latitude" longitude "geo longitude" altitude "geo altitude" geoaccuracy "geo accuracy" nr_hh "HH #", alternate

label define enum_names	1 "Isilo Irene" 2 "Mutebi Ronald" 3 "Wamala Denis" 4 "Dakasi Simon Peter" 5 "Wamanga Johnior" 6 "Adrine Kanyebaze" 7 "Tebagerwa Diana" 8 "Kalemba Edgar" 9 "Mutoto Emmanuel" 10 "Nasuuna Lydia" 11 "Nantongo Rebecca" 12 "Ilopu Irene Gertrude" 13 "Awori Jane" 14 "Aujo Mary Gorrety" 15 "Mulinda Alone" 16 "Akadu Enok" 17 "Kanyemera Fridah" 18 "Seguya Hilda" 19 "Wandhawa Catherine" 20 "Kabwama Brian" 21 "Ntono Lydia" 22 "Egesa Babra" 23 "Asere Juliet" 24 "Nabulo Brenda Phoebe" 25 "Kaffuuma Frank" 26 "Odongo Moses Ojulu" 27 "Ssebyooto Lawrence" 28 "Burungi Helen" 29 "Nakabuye Rashidah" 30 "Nalikiti Zeridah" 31 "Nankabirwa Maria Brenda" 32 "Aryemo Betty" 33 "Wambi Irene" 34 "Nabbuto Majorine" 35 "Yafesi Namakajjo" 36 "Turyamureeba Eliud" 37 "Mutonyi Suzan" 38 "Nandawula Lydia" 39 "Nalubwama Christine" 40 "Bagatya Nelson" 41 "Nakagolo Zahara" 42 "Akello Salume" 43 "Alenyo Joyce" 44 "Omunyini Abraham" 45 "Aseno Sandra" 46 "Outa Benjamin" 47 "Namuganza Majorine" 48 "Kalala Lawerence" 49 "Mazima Didas" 50 "Bisikwa Sharon" 51 "Saire Kimalyo Denis" 52 "Mugerwa John Paul" 53 "Kusemererwa Patrick" 54 "Nabuyungo Irene Sandra"
label values enum_name enum_names

split submissiondate, p(,) generate(date_check)
split date, p(,) generate(ndate)
drop date_check2 ndate2
rename (date_check1 ndate1) (date_check date_match)

sort enum_id date

save "`edit'\baseline_listing.dta", replace

**********************************************************************

//*********	CR Survey

import delimited "`input'\finalbaseline_CRsurvey.csv", clear

rename (location_branch location_club) (branch club)

/************************
							NEED HELP WITH LABELING THE VARIABLES.

***********************/
labvars submissiondate "Submission Date" duration "Duration in sec." comment "Comments on survey" starttime "Survey Start time" endtime "Survey end time" enum_id "Enumerator ID" enum_name "Enumerator's Name" branch "Branch #" club "Club #" hh_id "Household ID" nr_visit "# of visits to hh", alternate

label define enum_names	1 "Isilo Irene" 2 "Mutebi Ronald" 3 "Wamala Denis" 4 "Dakasi Simon Peter" 5 "Wamanga Johnior" 6 "Adrine Kanyebaze" 7 "Tebagerwa Diana" 8 "Kalemba Edgar" 9 "Mutoto Emmanuel" 10 "Nasuuna Lydia" 11 "Nantongo Rebecca" 12 "Ilopu Irene Gertrude" 13 "Awori Jane" 14 "Aujo Mary Gorrety" 15 "Mulinda Alone" 16 "Akadu Enok" 17 "Kanyemera Fridah" 18 "Seguya Hilda" 19 "Wandhawa Catherine" 20 "Kabwama Brian" 21 "Ntono Lydia" 22 "Egesa Babra" 23 "Asere Juliet" 24 "Nabulo Brenda Phoebe" 25 "Kaffuuma Frank" 26 "Odongo Moses Ojulu" 27 "Ssebyooto Lawrence" 28 "Burungi Helen" 29 "Nakabuye Rashidah" 30 "Nalikiti Zeridah" 31 "Nankabirwa Maria Brenda" 32 "Aryemo Betty" 33 "Wambi Irene" 34 "Nabbuto Majorine" 35 "Yafesi Namakajjo" 36 "Turyamureeba Eliud" 37 "Mutonyi Suzan" 38 "Nandawula Lydia" 39 "Nalubwama Christine" 40 "Bagatya Nelson" 41 "Nakagolo Zahara" 42 "Akello Salume" 43 "Alenyo Joyce" 44 "Omunyini Abraham" 45 "Aseno Sandra" 46 "Outa Benjamin" 47 "Namuganza Majorine" 48 "Kalala Lawerence" 49 "Mazima Didas" 50 "Bisikwa Sharon" 51 "Saire Kimalyo Denis" 52 "Mugerwa John Paul" 53 "Kusemererwa Patrick" 54 "Nabuyungo Irene Sandra"
label values enum_name enum_names

split submissiondate, p(,) generate(date_check)
split date, p(,) generate(ndate)
drop date_check2 ndate2
rename (date_check1 ndate1) (date_check date_match)

sort enum_id submissiondate

save "`edit'\baseline_CRsurvey.dta", replace
