

********************************************************************************
*
*	Do-file:		03a_an_descriptive_tables.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	HFORBES based on Elizabeth Williamson
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file: output/04a_an_descriptive_tables.log
*
********************************************************************************
*
*	Purpose:		This do-file runs some basic safetabulations on the analysis
*					dataset.
*  
********************************************************************************


* Set globals that will print in programs and direct output
global outdir  	  "output" 
global logdir     "log"
global tempdir    "tempdata"

*first argument main W2 
local dataset `1'

* Open a log file
capture log close
log using "$logdir/03a_an_descriptive_tables`dataset'", replace t

forvalues x=0/1 {

use $tempdir/analysis_dataset_ageband_`x'`dataset', clear


**********************************
*  Distribution in whole cohort  *
**********************************


* Demographics
summ age
safetab agegroup
safetab age66
safetab male
safetab bmicat
safetab bmicat, m
safetab obese4cat
safetab smoke
safetab smoke, m
safetab bpcat
safetab bpcat, m
safetab htdiag_or_highbp
safetab htdiag_or_highbp, m
safetab imd 
safetab imd, m
safetab ethnicity
safetab ethnicity, m
safetab stp
safetab tot_adults_hh
safetab household_size
safetab household_size imd, col chi


* Comorbidities
foreach var in chronic_respiratory_disease ///
						asthma  ///
						chronic_cardiac_disease  ///
						diabcat   ///
						cancer_exhaem_cat 						///
						cancer_haem_cat 						///
						other_immuno 	///
						other_transplant 			/// 
						asplenia 			/// 
						chronic_liver_disease  ///
						other_neuro  ///
						stroke_dementia				///
						egfr_cat  ///
						reduced_kidney_function ///
						esrd 			///
						hypertension  ///
						ra_sle_psoriasis  ///
						{
						
safetab `var'
}
safetab shield


*Exposure 
foreach var in kids_cat4 gp_number_kids {
safetab `var'
}

* Outcomes
foreach var in  non_covid_death  ///
 covid_tpp_prob {
safetab `var'
}


* Outcomes by exposure
foreach var in non_covid_death  ///
 covid_tpp_prob {
safetab `var'
safetab `var' kids_cat4, col row
safetab `var' gp_number_kids, col row

}


**********************************
*  Number (%) with each exposure  *
**********************************

*** Repeat for each outcome

	* Demographics
	safetab agegroup 							kids_cat4, col
	safetab male 								kids_cat4, col
	safetab bmicat 								kids_cat4, col m 
	safetab smoke 								kids_cat4, col m
	safetab obese4cat							kids_cat4, col m 
	safetab shield   							kids_cat4, col m 
	safetab tot_adults_hh						kids_cat4, col m 
	safetab household_size						kids_cat4, col m 
	safetab imd  								kids_cat4, col m
	safetab ethnicity 							kids_cat4, col m
	safetab stp 								kids_cat4, col
	
	
	* Comorbidities
	foreach var in chronic_respiratory_disease ///
						asthma  ///
						chronic_cardiac_disease  ///
						diabcat  ///
						cancer_exhaem_cat 						///
						cancer_haem_cat 						///
						other_immuno 	///
						other_transplant 			/// 
						asplenia 			/// 
						chronic_liver_disease  ///
						other_neuro  ///
						stroke_dementia				///
						egfr_cat  ///
						reduced_kidney_function ///
						esrd 			///
						hypertension  ///
						ra_sle_psoriasis  ///
						{
	safetab `var' 		kids_cat4, col
}
	

}
* Close the log file
log close



