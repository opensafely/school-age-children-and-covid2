********************************************************************************
*
*	Do-file:		07d_an_multivariable_cox_models_Sense5.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	Hforbes, based on files from Fizz & Krishnan
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file:  07b_an_multivariable_cox_models_`outcome'.log
*
********************************************************************************
*
*	Purpose:		This do-file performs multivariable (fully adjusted) 
*					Cox models, with time interactions
*  
********************************************************************************
*	
*	Stata routines needed:	stbrier	  
*
********************************************************************************

* Set globals that will print in programs and direct output
global outdir  	  "output" 
global logdir     "log"
global tempdir    "tempdata"

local comordidadjlist  i.htdiag_or_highbp				///
			i.chronic_respiratory_disease 	///
			i.asthma						///
			i.chronic_cardiac_disease 		///
			i.diabcat						///
			i.cancer_exhaem_cat	 			///
			i.cancer_haem_cat  				///
			i.chronic_liver_disease 		///
			i.stroke_dementia		 		///
			i.other_neuro					///
			i.reduced_kidney_function_cat	///
			i.esrd							///
			i.other_transplant 				///
			i.asplenia 						///
			i.ra_sle_psoriasis  			///
			i.other_immuno		

************************************************************************************
*First clean up all old saved estimates for this outcome
*This is to guard against accidentally displaying left-behind results from old runs
************************************************************************************
local outcome `1' 
local dataset `2'

* Open a log file
capture log close
log using "$logdir/07d_an_multivariable_cox_models_`outcome'_Sense5_time_ints`dataset'", text replace


foreach x in 0 1 {
******************************
*  Multivariable Cox models  *
******************************
display "$S_TIME  $S_DATE"
use "$tempdir/cr_create_analysis_dataset_STSET_covid_tpp_prob_ageband_`x'`dataset'.dta", clear
display "$S_TIME  $S_DATE"
stsplit timeperiod, at(60 90)

*make vars binary
gen anyreduced_kidney_function = reduced_kidney_function_cat>=2
gen anyobesity = obese4cat>=2
gen highimd = imd>=3
gen anydiab= diabcat>=2
gen any_nonwhite=ethnicity>=2
   
*Fully adjusted
stcox 	i.kids_cat4 	 ///
			age1 age2 age3		///
			i.tot_adults_hh ///
			i.male 							///
			i.obese4cat 					///
			i.smoke_nomiss					///
			i.imd 						///
			i.ethnicity ///
			`comordidadjlist'	///	
			60.timeperiod#1.male							///
			90.timeperiod#1.male						///
			60.timeperiod#1.tot_adults_hh							///
			90.timeperiod#1.tot_adults_hh						///
			60.timeperiod#1.anyobesity							///
			90.timeperiod#1.anyobesity						///
			60.timeperiod#1.any_nonwhite							///
			90.timeperiod#1.any_nonwhite						///
			60.timeperiod#3.smoke_nomiss						///
			90.timeperiod#3.smoke_nomiss					///
			60.timeperiod#1.highimd								///
			90.timeperiod#1.highimd							///
			, strata(stp) vce(cluster household_id)
display "$S_TIME  $S_DATE"
estimates save "./output/an_sense_`outcome'_time_int_ageband_`x'`dataset'", replace
estat phtest, d
display "$S_TIME  $S_DATE"
}

cap log close
exit, clear STATA

