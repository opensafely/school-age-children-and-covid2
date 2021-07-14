********************************************************************************
*
*	Do-file:		10_an_interaction_cox_models_weeks.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	Hforbes, based on files from Fizz & Krishnan
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file:  10_an_interaction_cox_models.log
*
********************************************************************************
*
*	Purpose:		This do-file performs multivariable (fully adjusted)
*					Cox models, with an interaction by week of pandemic.
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
global demogadjlist  age1 age2 age3 i.male i.ethnicity	i.obese4cat i.smoke_nomiss i.imd i.tot_adults_hh
global comordidadjlist  i.htdiag_or_highbp				///
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
local outcome `1'


************************************************************************************
*First clean up all old saved estimates for this outcome
*This is to guard against accidentally displaying left-behind results from old runs
************************************************************************************
log using "$logdir/10_an_interaction_cox_models_ethcat_`outcome'", text replace

*************************************************************************************
* Open dataset and fit specified model(s)
forvalues x=0/1 {

use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear


*Age spline model (not adj ethnicity, interaction)
stcox i.kids_cat3##i.ethnicity  								///
			$demogadjlist							///
			$comordidadjlist						///
			, strata(stp) vce(cluster household_id)
			estimates save ./output/an_interaction_cox_models_`outcome'_kids_cat3_ethnicity_MAINFULLYADJMODEL_agespline_bmicat_noeth_ageband_`x', replace
foreach ethcat in 1 2 3 4 5 {
if _rc==0 {
*testparm `ethcat'.ethnicity#i.kids_cat3
*di _n "kids_cat3 " _n "****************"
lincom 1.kids_cat3 + `ethcat'.ethnicity#1.kids_cat3, eform
di "kids_cat3" _n "****************"
lincom 2.kids_cat3 + `ethcat'.ethnicity#2.kids_cat3, eform

}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"
}
}
log close

exit, clear STATA


