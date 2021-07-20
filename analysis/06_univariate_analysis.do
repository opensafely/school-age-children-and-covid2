********************************************************************************
*
*	Do-file:		06_univariate_analysis.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	Hforbes, based on files from Fizz & Krishnan
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file: an_univariable_cox_models.log 
*
********************************************************************************
*
*	Purpose:		Fit age/sex adjusted Cox models, stratified by STP and 
*with hh size as random effect
*  
********************************************************************************

* Set globals that will print in programs and direct output
global outdir  	  "output" 
global logdir     "log"
global tempdir    "tempdata"

local dataset `1'
pwd

*PARSE DO-FILE ARGUMENTS (first should be outcome, rest should be variables)
local arguments = wordcount("`0'") 
local outcome `1'
local varlist
forvalues i=2/`arguments'{
	local varlist = "`varlist' " + word("`0'", `i')
	}
local firstvar = word("`0'", 2)
local lastvar = word("`0'", `arguments')

	

* Open a log file
capture log close
log using "$logdir/06_univariate_analysis_`dataset'", replace t

* Open dataset and fit specified model(s)
foreach outcome in covid_tpp_prob  covidadmission  covid_icu covid_death non_covid_death {
forvalues x=0/1 {

use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'`dataset'.dta", clear

foreach exposure_type in kids_cat4  ///
		gp_number_kids {

	*Fit and save model
	cap erase ./output/an_univariable_cox_models_`outcome'_AGESEX_ageband_`x'`dataset'.ster
	capture stcox i.`exposure_type' age1 age2 age3 i.male , strata(stp) vce(cluster household_id)
	if _rc==0 {
		estimates
		estimates save ./output/an_univariable_cox_models_`exposure_type'_`outcome'_AGESEX_ageband_`x'`dataset'.ster, replace
		}
	else di "WARNING - `var' vs `outcome' MODEL DID NOT SUCCESSFULLY FIT"

}
}
}
* Close log file
log close

exit, clear 
