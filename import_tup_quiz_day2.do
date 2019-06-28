* import_tup_quiz_day2.do
*
* 	Imports and aggregates "TUP Quiz Day 2" (ID: tup_quiz_day2) data.
*
*	Inputs: .csv file(s) exported by the SurveyCTO Sync
*	Outputs: "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/input/TUP Quiz Day 2.dta"
*
*	Output by the SurveyCTO Sync June 6, 2019 12:42 PM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/input/TUP Quiz Day 2.csv"
local dtafile "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/input/TUP Quiz Day 2.dta"
local corrfile "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/input/TUP Quiz Day 2_corrections.csv"
local note_fields1 "info_note"
local text_fields1 "name instanceid instancename"
local date_fields1 "date"
local datetime_fields1 "submissiondate start end"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable date "When is the quiz been taken?"
	note date: "When is the quiz been taken?"

	label variable name "What is your name?"
	note name: "What is your name?"

	label variable sect2 "Question 1: A household has 7 people in it. 4 are men, 3 are women. 6 know their"
	note sect2: "Question 1: A household has 7 people in it. 4 are men, 3 are women. 6 know their age, and 2 are monogomously married. How many entries for age should I have for this household?"
	label define sect2 0 "7" 1 "6"
	label values sect2 sect2

	label variable sect4 "Question 2: Brandon eats 3 meals with his family each day in the household. He d"
	note sect4: "Question 2: Brandon eats 3 meals with his family each day in the household. He doesn't remember how much he has eaten over the past 3 days, but typically eats a whole mango each morning which costs him 200 UGX. How should Brandon be coded accroding to Section 4?"
	label define sect4 1 "Meals : 3 | HH eaten food in past 3 days : Yes | Quantity : Don't Know | Type of" 0 "Meals : 3 | HH eaten food in past 3 days : Yes | Quantity : Don't Know | Type of"
	label values sect4 sect4

	label variable sect5_1 "Question 3: Dennis has 3 acres of crops. He plants beans on 2 acres, plants corn"
	note sect5_1: "Question 3: Dennis has 3 acres of crops. He plants beans on 2 acres, plants corn on 1 acre and plants yams on 1 acre. He interplots corn and yams. How many acres total does Dennis have? How many acres are interplotted?"
	label define sect5_1 0 "Total : 4 | Interplotted : 1" 1 "Total : 3 | Interplotted : 1"
	label values sect5_1 sect5_1

	label variable sect5_2 "Question 4: Sinclaire is being interviewed about his interest rate. When you ask"
	note sect5_2: "Question 4: Sinclaire is being interviewed about his interest rate. When you ask him, he says he doesn't know but it is probably 105%. How should you code this response?"
	label define sect5_2 0 "Leave blank" 1 "Don't Know"
	label values sect5_2 sect5_2

	label variable sect5_3 "Question 5: Diana says she has 10 goats today. She bought 3 goats last year, and"
	note sect5_3: "Question 5: Diana says she has 10 goats today. She bought 3 goats last year, and eat 2 goats last year. 1 of the goats had 3 children this year. How many goats did Diana have last year?"
	label define sect5_3 1 "6" 0 "9"
	label values sect5_3 sect5_3

	label variable sect11 "Question 6: You are interviewing Martha. You are asking her about how happy she "
	note sect11: "Question 6: You are interviewing Martha. You are asking her about how happy she is. She says she is happy, but does not express it. How would you code this response?"
	label define sect11 0 "Not too happy" 1 "Somewhat happy"
	label values sect11 sect11






	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}


* launch .do files to process repeat groups

