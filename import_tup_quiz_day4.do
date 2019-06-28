* import_tup_quiz_day4.do
*
* 	Imports and aggregates "TUP Quiz Day 4" (ID: tup_quiz_day4) data.
*
*	Inputs: .csv file(s) exported by the SurveyCTO Sync
*	Outputs: "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/scripts/TUP Quiz Day 4.dta"
*
*	Output by the SurveyCTO Sync June 7, 2019 8:51 AM.

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
local csvfile "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/input/TUP Quiz Day 4.csv"
local dtafile "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/input/TUP Quiz Day 4.dta"
local corrfile "C:/Users/Ryry/Dropbox/Ryan Intern - TUP/input/TUP Quiz Day 4_corrections.csv"
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

	label variable section3 "Question 1: Teresa owns 2 radios, 1 TV, no refrigerator, and a panga. How should"
	note section3: "Question 1: Teresa owns 2 radios, 1 TV, no refrigerator, and a panga. How should this be recorded?"
	label define section3 0 "Radios: 2 | TVs : 1 | Refrigerators : 0 | Panga : 0" 1 "Radios: 2 | TVs : 1 | Refrigerators : 0 | Panga : 1"
	label values section3 section3

	label variable section4 "Question 2: In terms of consumption, a household consumes household items that a"
	note section4: "Question 2: In terms of consumption, a household consumes household items that are either purchased, produced, or received?"
	label define section4 1 "Yes" 0 "No"
	label values section4 section4

	label variable section6 "Question 3: If a household does not have a income generating activity, can they "
	note section6: "Question 3: If a household does not have a income generating activity, can they still earn a salary?"
	label define section6 0 "Yes" 1 "No"
	label values section6 section6

	label variable section8 "Question 4: Edgar's household has receives assistance in terms of gifts from the"
	note section8: "Question 4: Edgar's household has receives assistance in terms of gifts from their neighbors and an NGO. He does not know the extact amount or value of this assistance. What should you do?"
	label define section8 0 "Do a calculated report on the market price for the goods, cross check with the l" 1 "Estimate to the closest value"
	label values section8 section8

	label variable section10 "Question 5: Dennis gives you his weight as 2000 grams and a height of 1.5 meters"
	note section10: "Question 5: Dennis gives you his weight as 2000 grams and a height of 1.5 meters. This survey need these measures in kilograms and in centimeters. What is the correct way to report his weight and height?"
	label define section10 1 "Weight: 2 kgs | Height : 150 cms" 0 "Weight: 20 kgs | Height : 15 cms"
	label values section10 section10

	label variable section11 "Question 6: You are asking Anna about her life conditions. Asking her 'The condi"
	note section11: "Question 6: You are asking Anna about her life conditions. Asking her 'The conditions of my life are excellent' Anna shrugs and replies 'It makes no difference.' What is the appropriate way to record this?"
	label define section11 0 "Strongly agree" 1 "Neither agree or disagree"
	label values section11 section11

	label variable vsla1 "Question 7: If you have a VLSA with 12 members, 5 are women, the president is a "
	note vsla1: "Question 7: If you have a VLSA with 12 members, 5 are women, the president is a man, and the secretary is a man. How many members MUST the VSLA have?"
	label define vsla1 0 "5" 1 "12"
	label values vsla1 vsla1

	label variable vsla2 "Question 8: The interest rate in the VLSA is recorded as a percentage. Which of "
	note vsla2: "Question 8: The interest rate in the VLSA is recorded as a percentage. Which of these is the correct way to input the interest rate into the survey?"
	label define vsla2 0 "0.05" 1 "5"
	label values vsla2 vsla2

	label variable vlsa3 "Question 9: Can the VSLA have borrowers who are not VLSA members?"
	note vlsa3: "Question 9: Can the VSLA have borrowers who are not VLSA members?"
	label define vlsa3 1 "Yes" 0 "No"
	label values vlsa3 vlsa3

	label variable vlsa4 "Question 10: Which of the following is not a role in the VSLA?"
	note vlsa4: "Question 10: Which of the following is not a role in the VSLA?"
	label define vlsa4 1 "Vice President" 0 "President"
	label values vlsa4 vlsa4






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

