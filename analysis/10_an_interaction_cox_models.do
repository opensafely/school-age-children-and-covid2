********************************************************************************
*
*	Do-file:		10_an_interaction_cox_models.do
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
*					Cox models, with an interaction by age and sex. 
*  
********************************************************************************
*	
*	Stata routines needed:	stbrier	  
*
********************************************************************************

local outcome `1' 


************************************************************************************
*First clean up all old saved estimates for this outcome
*This is to guard against accidentally displaying left-behind results from old runs
************************************************************************************
cap erase ./output/an_interaction_cox_models_`outcome'_`exposure_type'_MAINFULLYADJMODEL_agespline_bmicat_noeth.ster
cap erase ./output/an_interaction_cox_models_`outcome'_`exposure_type'_MAINFULLYADJMODEL_agegroup_bmicat_noeth.ster
cap erase ./output/an_interaction_cox_models_`outcome'_`exposure_type'_MAINFULLYADJMODEL_agespline_bmicat_CCeth.ster
cap erase ./output/an_interaction_cox_models_`outcome'_`exposure_type'_MAINFULLYADJMODEL_agespline_bmicat_CCnoeth.ster



cap log close
log using "./output/an_interaction_cox_models_`outcome'", text replace


use "$tempdir\cr_create_analysis_dataset_STSET_`outcome'.dta", clear
stset

*Split data by time of study period: days to April 3rd (31 d March, 3d April)
stsplit cat_time, at(0,34, 200)
recode cat_time 34=1 200=2 
recode `outcome' .=0 
tab cat_time
 
/*Overlapping time periods
gen cat_time0=1 if cat==0
gen cat_time1=1 if cat==0 | cat==0.25
*/
	
*PROG TO DEFINE THE BASIC COX MODEL WITH OPTIONS FOR HANDLING OF AGE, BMI, ETHNICITY:
cap prog drop basemodel
prog define basemodel
	syntax , exposure(string)  age(string) [ethnicity(real 0) interaction(string)] 
	if `ethnicity'==1 local ethnicity "i.ethnicity"
	else local ethnicity
timer clear
timer on 1
 stcox 	`exposure' `age' 					///
			i.male 							///
			i.obese4cat						///
			i.smoke_nomiss					///
			i.imd 							///
			i.htdiag_or_highbp				///
			i.chronic_respiratory_disease 	///
			i.asthma						///
			i.chronic_cardiac_disease 		///
			i.diabetes						///
			i.cancer_exhaem_cat	 			///
			i.cancer_haem_cat  				///
			i.chronic_liver_disease 		///
			i.stroke_dementia		 		///
			i.other_neuro					///
			i.reduced_kidney_function_cat	///
			i.organ_trans			    	///
			i.asplenia 						///
			i.additional_people				///
			i.ra_sle_psoriasis  			///
			i.other_immuno			///
			`interaction'							///
			, strata(stp) vce(cluster household_size)
	timer off 1
timer list
end
*************************************************************************************

foreach int_type in age66 male cat_time shield {

*Age interaction for 3-level exposure vars
foreach exposure_type in kids_cat3  {

*Age spline model (not adj ethnicity, no interaction)
basemodel, exposure("i.`exposure_type'") age("age1 age2 age3")  

*Age spline model (not adj ethnicity, interaction)
basemodel, exposure("i.`exposure_type'") age("age1 age2 age3") interaction(1.`int_type'#1.`exposure_type' 1.`int_type'#2.`exposure_type')
if _rc==0{
testparm 1.`int_type'#i.`exposure_type'
di _n "`exposure_type' <66" _n "****************"
lincom 2.`exposure_type', eform
di "`exposure_type' 66+" _n "****************"
lincom 2.`exposure_type' + 1.`int_type'#2.`exposure_type', eform
estimates save ./output/an_interaction_cox_models_`outcome'_`exposure_type'_`int_type'_MAINFULLYADJMODEL_agespline_bmicat_noeth, replace
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"

}

/*Age interactions with 4-level vars: NOT in protocol - do not run
foreach exposure_type in gp_number_kids {
basemodel, exposure("i.`exposure_type'") age("age1 age2 age3")  bp("i.htdiag_or_highbp") ethnicity(0) interaction(1.`int_type'#1.`exposure_type' 1.`int_type'#2.`exposure_type' 1.`int_type'#3.`exposure_type' 1.`int_type'#4.`exposure_type')
if _rc==0{
testparm 1.`int_type'#i.`exposure_type'
di _n "`exposure_type' <66" _n "****************"
lincom 2.`exposure_type', eform
lincom 3.`exposure_type', eform
lincom 4.`exposure_type', eform
di "`exposure_type' 66+" _n "****************"
lincom 2.`exposure_type' + 1.`int_type'#2.`exposure_type', eform
lincom 3.`exposure_type' + 1.`int_type'#3.`exposure_type', eform
lincom 4.`exposure_type' + 1.`int_type'#4.`exposure_type', eform
estimates save ./output/an_interaction_cox_models_`outcome'_`exposure_type'_`int_type'_MAINFULLYADJMODEL_agespline_bmicat_noeth, replace
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"
}
*/

}

log close
