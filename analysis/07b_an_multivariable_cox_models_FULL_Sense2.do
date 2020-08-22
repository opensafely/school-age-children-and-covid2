********************************************************************************
*
*	Do-file:		07b_an_multivariable_cox_models_FULL_Sense2.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	Hforbes, based on files from Fizz & Krishnan
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file:  an_multivariable_cox_models.log
*
********************************************************************************
*
*	Purpose:		This do-file performs multivariable (fully adjusted) 
*					Cox models for a sense analysis on cases with complete data
*					for ethnicity, bmi and smoking
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


local outcome `1' 


************************************************************************************
*First clean up all old saved estimates for this outcome
*This is to guard against accidentally displaying left-behind results from old runs
************************************************************************************
cap erase ./output/an_multivariate_cox_models_`outcome'_MAINFULLYADJMODEL_agespline_bmicat_noeth.ster
cap erase ./output/an_multivariate_cox_models_`outcome'_MAINFULLYADJMODEL_agegroup_bmicat_noeth.ster
cap erase ./output/an_multivariate_cox_models_`outcome'_MAINFULLYADJMODEL_agespline_bmicat_CCeth.ster
cap erase ./output/an_multivariate_cox_models_`outcome'_MAINFULLYADJMODEL_agespline_bmicat_CCnoeth.ster


* Open a log file
capture log close
log using "$logdir\07b_an_multivariable_cox_models_FULL_Sense2_`outcome'", text replace

*set trace on

******************************
*  Multivariable Cox models  *
******************************

*************************************************************************************
*PROG TO DEFINE THE BASIC COX MODEL WITH OPTIONS FOR HANDLING OF AGE, BMI, ETHNICITY:
cap prog drop basecoxmodel
prog define basecoxmodel
	syntax , exposure(string) age(string) [ethnicity(real 0) if(string)] bmi(string) smoking(string)
	if `ethnicity'==1 local ethnicity "i.ethnicity"
	else local ethnicitytimer clear
timer on 1
	capture stcox 	`exposure'			///
			`demogadjlist' 				///
			`comordidadjlist' 			///
			`if'						///
			, strata(stp) vce(cluster household_id)
timer off 1
timer list
end
*************************************************************************************


* Open dataset and fit specified model(s)
forvalues x=0/1 {

use "$tempdir\cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear

foreach exposure_type in 	kids_cat3  {
 
*Complete case ethnicity model
basecoxmodel, exposure("i.`exposure_type'") age("age1 age2 age3") ethnicity(1) bmi(i.bmicat) smoking(i.smoke)
if _rc==0{
estimates
estimates save ./output/an_multivariate_cox_models_`outcome'_`exposure_type'_MAINFULLYADJMODEL_CCeth_bmi_smok_ageband_`x', replace
*estat concordance /*c-statistic*/
 }
 else di "WARNING CC ETHN BMI SMOK MODEL WITH AGESPLINE DID NOT FIT (OUTCOME `outcome')" 
 
 }
 
 }


log close




exit, clear STATA
