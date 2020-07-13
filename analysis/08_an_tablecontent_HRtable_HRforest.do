*************************************************************************
*Do file: 08_an_tablecontent_HRtable_HRforest
*
*Purpose: Create content that is ready to paste into a pre-formatted Word 
* shell table containing minimally and fully-adjusted HRs for risk factors
* of interest, across 2 outcomes 
*
*Requires: final analysis dataset (analysis_dataset.dta)
*
*Coding: HFORBES, based on file from Krishnan Bhaskaran
*
*Date drafted: 30th June 2020
*************************************************************************

local outcome `1' 

* Open a log file
capture log close
log using "$logdir\08_an_tablecontent_HRtable_HRforest_`outcome'", text replace


***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real) outcome(string)
forvalues i=`min'/`max'{
local endwith "_tab"

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontents ("`variable'") _tab ("`i'") _tab
	
    use "$tempdir\cr_create_analysis_dataset_STSET_`outcome'.dta", clear
	*put total N, PYFU and Rate in table
	cou if `variable' == `i' & _d == 1
	local event = r(N)
    bysort `variable': egen total_follow_up = total(_t)
	su total_follow_up if `variable' == `i'
	local person_years = r(mean)
	local rate = 1000*(`event'/`person_years')
	
	file write tablecontents (`event') _tab %10.0f (`person_years') _tab %3.2f (`rate') _tab
	drop total_follow_up
	
	
	*models
	foreach modeltype of any minadj demogadj fulladj {
	
		local noestimatesflag 0 /*reset*/

*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if "`modeltype'"=="fulladj" local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY
		
		if "`modeltype'"=="minadj" {
			cap estimates use ./output/an_univariable_cox_models_`outcome'_AGESEX_`variable'
			if _rc!=0 local noestimatesflag 1
			}
		if "`modeltype'"=="demogadj" {
			cap estimates use ./output/an_multivariate_cox_models_`outcome'_`variable'_DEMOGADJ_noeth
			if _rc!=0 local noestimatesflag 1
			}
		if "`modeltype'"=="fulladj" {
				cap estimates use ./output/an_multivariate_cox_models_`outcome'_`variable'_MAINFULLYADJMODEL_noeth  
				if _rc!=0 local noestimatesflag 1
				}
		
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE
		
		if `noestimatesflag'==0{
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents %4.2f (r(estimate)) (" (") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") `endwith'
				else file write tablecontents %4.2f ("ERR IN MODEL") `endwith'
			}
			else file write tablecontents %4.2f ("DID NOT FIT") `endwith' 
			
		*3) Save the estimates for plotting
		if `noestimatesflag'==0{
			if "`modeltype'"=="fulladj" {
				local hr = r(estimate)
				local lb = r(lb)
				local ub = r(ub)
				cap gen `variable'=.
				testparm i.`variable'
				*drop `variable'
				}
		}	
		} /*min adj, full adj*/
		
} /*variable levels*/

end
***********************************************************************************************************************
*Generic code to write a full row of "ref category" to the output file
cap prog drop refline
prog define refline
file write tablecontents _tab _tab ("1.00 (ref)") _tab ("1.00 (ref)")  _n
end
***********************************************************************************************************************

*MAIN CODE TO PRODUCE TABLE CONTENTS

cap file close tablecontents
file open tablecontents using ./output/an_tablecontents_HRtable_`outcome'.txt, t w replace 

*Primary exposure
refline
outputHRsforvar, variable("kids_cat3") min(1) max(2) outcome(`outcome')
file write tablecontents _n

*Number kids
refline
outputHRsforvar, variable("gp_number_kids") min(1) max(4) outcome(`outcome')
file write tablecontents _n 

file close tablecontents


log close
