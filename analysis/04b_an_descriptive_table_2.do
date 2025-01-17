*************************************************************************

*Exposure children and COVID risk

*DO file name:  04b_an_descriptive_table_2

*Purpose: Create content that is ready to paste into a pre-formatted Word
* shell "Table 2" (main cohort descriptives by outcome status).
*
*Requires: final analysis dataset (analysis_dataset.dta)
*
*Coding: HFORBES, based on Krishnan Bhaskaran
*
*Date drafted: 30th June 2020
*************************************************************************


* Set globals that will print in programs and direct output
global outdir  	  "output"
global logdir     "log"
global tempdir    "tempdata"


local dataset `1'

* Open a log file
capture log close
log using "$logdir/04b_an_descriptive_table_2_`dataset'", text replace


*******************************************************************************
*Generic code to output one row of table
cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string)

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontent ("`variable'") _tab ("`condition'") _tab

	cou
	local overalldenom=r(N)

	cou if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab
	
	foreach outcome in covid_tpp_prob  covidadmission  covid_icu covid_death non_covid_death {
	cou if `outcome'==1 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom')
	file write tablecontent (r(N)) (" (") %4.2f  (`pct') (")") _tab 

}
	file write tablecontent _n 
end

*******************************************************************************
*Generic code to output one section (varible) within table (calls above)
cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) start(real) end(real) [missing] 

	foreach varlevel of numlist `start'/`end'{
		generaterow, variable(`variable') condition("==`varlevel'") 
	}
	if "`missing'"!="" generaterow, variable(`variable') condition(">=.") 

end

*******************************************************************************


forvalues x=0/1 {

*Set up output file
cap file close tablecontent
file open tablecontent using ./output/04b_an_descriptive_table_2_`dataset'_ageband`x'.txt, write text replace


use $tempdir/analysis_dataset_ageband_`x'`dataset', clear

gen byte cons=1
tabulatevariable, variable(cons) start(1) end(1) 
file write tablecontent _n

tabulatevariable, variable(agegroup) start(1) end(7) 
file write tablecontent _n

tabulatevariable, variable(male) start(0) end(1) 
file write tablecontent _n

tabulatevariable, variable(bmicat) start(1) end(6) missing 
file write tablecontent _n

tabulatevariable, variable(smoke) start(1) end(3) missing 
file write tablecontent _n

tabulatevariable, variable(ethnicity) start(1) end(5) missing 
file write tablecontent _n

tabulatevariable, variable(imd) start(1) end(5) 
file write tablecontent _n

tabulatevariable, variable(tot_adults_hh) start(1) end(3) 
file write tablecontent _n

tabulatevariable, variable(bpcat) start(1) end(4) missing 
tabulatevariable, variable(htdiag_or_highbp) start(1) end(1) 
file write tablecontent _n

**COMORBIDITIES
*RESPIRATORY
tabulatevariable, variable(chronic_respiratory_disease) start(1) end(1) 
*ASTHMA
tabulatevariable, variable(asthma) start(1) end(1)  /*ever asthma*/
*CARDIAC
tabulatevariable, variable(chronic_cardiac_disease) start(1) end(1) 
file write tablecontent _n
*DIABETES
tabulatevariable, variable(diabcat) start(1) end(6) 
file write tablecontent _n
*CANCER EX HAEM
tabulatevariable, variable(cancer_haem_cat) start(2) end(4)  /*<1, 1-4.9, 5+ years ago*/
file write tablecontent _n
*CANCER HAEM
tabulatevariable, variable(cancer_exhaem_cat) start(2) end(4)  /*<1, 1-4.9, 5+ years ago*/
file write tablecontent _n
*REDUCED KIDNEY FUNCTION
tabulatevariable, variable(reduced_kidney_function_cat) start(2) end(3) 
*ESRD
tabulatevariable, variable(esrd) start(1) end(1) 
*LIVER
tabulatevariable, variable(chronic_liver_disease) start(1) end(1) 
*STROKE/DEMENTIA
tabulatevariable, variable(stroke_dementia) start(1) end(1) 
*OTHER NEURO
tabulatevariable, variable(other_neuro) start(1) end(1) 
*ORGAN TRANSPLANT
tabulatevariable, variable(other_transplant) start(1) end(1) 
*SPLEEN
tabulatevariable, variable(asplenia) start(1) end(1) 
*RA_SLE_PSORIASIS
tabulatevariable, variable(ra_sle_psoriasis) start(1) end(1) 
*OTHER IMMUNOSUPPRESSION
tabulatevariable, variable(other_immuno) start(1) end(1) 

*OTHER IMMUNOSUPPRESSION
tabulatevariable, variable(shield) start(1) end(1) 

file close tablecontent

}

log close
