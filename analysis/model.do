*Model do file

*When running in parallel locally use "C:\Program Files\Stata16\StataMP-64.exe"
*When running on server use "c:/program files/stata16/statamp-64.exe"

*Import dataset into STATA
*import delimited `c(pwd)'/output/input.csv, clear

cd  "`c(pwd)'/analysis" /*sets working directory to workspace folder*/
set more off 

***********************HOUSE-KEEPING*******************************************
* Create directories required 
capture mkdir output
capture mkdir log
capture mkdir tempdata


* Set globals that will print in programs and direct output
global outdir  	  "output" 
global logdir     "log"
global tempdir    "tempdata"

********************************************************************************


*  Pre-analysis data manipulation  *
do "01_cr_analysis_dataset.do" MAIN
do "01_cr_analysis_dataset.do" W2


/*  Checks  */
do "02_an_data_checks.do" MAIN
do "02_an_data_checks.do" W2



*********************************************************************
*IF PARALLEL WORKING - FOLLOWING CAN BE RUN IN ANY ORDER/IN PARALLEL*
*       PROVIDING THE ABOVE CR_ FILE HAS BEEN RUN FIRST				*
*********************************************************************

do "03a_an_descriptive_tables.do" MAIN
do "03a_an_descriptive_tables.do" W2

do "03b_an_descriptive_table_1.do" MAIN
do "03b_an_descriptive_table_1.do" W2 

do "04a_an_descriptive_tables.do" MAIN
do "04a_an_descriptive_tables.do" W2

do "04b_an_descriptive_table_2.do" MAIN
do "04b_an_descriptive_table_2.do" W2

*winexec "C:\Program Files\Stata16\StataMP-64.exee" do "05_an_descriptive_plots.do"

************************************************************
*UNIVARIATE MODELS (these fit the models needed for age/sex adj col of Table 2)
foreach dataset of any  MAIN W2  {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "06_univariate_analysis.do" `dataset'
}

*MULTIVARIATE MODELS (this fits the models needed for fully adj col of Table 2)
foreach dataset of any  MAIN W2  {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07a_an_multivariable_cox_models_demogADJ.do"  `dataset'
}

foreach outcome of any  non_covid_death covid_tpp_prob covid_death covid_icu covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07b_an_multivariable_cox_models_FULL.do" `outcome' MAIN
}

foreach outcome of any  non_covid_death covid_tpp_prob covid_death covid_icu covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07b_an_multivariable_cox_models_FULL.do" `outcome' W2
}


***SENSE ANALYSES
foreach outcome of any non_covid_death covid_tpp_prob covidadmission covid_icu covid_death {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense3.do" `outcome' MAIN
}

foreach outcome of any non_covid_death covid_tpp_prob covidadmission covid_icu covid_death {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense4.do" `outcome' MAIN
}

winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense5.do" MAIN

foreach outcome of any non_covid_death covid_tpp_prob covidadmission covid_icu covid_death {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense3.do" `outcome'  W2
}

foreach outcome of any non_covid_death covid_tpp_prob covidadmission covid_icu covid_death {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense4.do" `outcome'  W2
}

foreach outcome of any non_covid_death covid_tpp_prob covidadmission covid_icu covid_death {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense6.do" `outcome'  W2
}


foreach outcome of any non_covid_death covid_tpp_prob covidadmission covid_icu covid_death {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense5.do" `outcome' W2
}


foreach outcome of any non_covid_death covid_tpp_prob covidadmission covid_icu covid_death {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense5.do" `outcome' MAIN
}


foreach outcome of any covidadmission  {
winexec "C:\Program Files\Stata16\StataMP-64.exe" do "07d_an_multivariable_cox_models_FULL_Sense7.do" `outcome' W2
}




*INTERACTIONS 
*Sex
foreach outcome of any  non_covid_death covid_tpp_prob covid_death covid_icu covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_sex" `outcome'	MAIN
}

*Shield
foreach outcome of any  non_covid_death covid_tpp_prob covid_death covid_icu covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_shield" `outcome'	MAIN
}

*Time
foreach outcome of any  non_covid_death covid_tpp_prob covid_death covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_time" `outcome'	MAIN
}

*Sex
foreach outcome of any  non_covid_death covid_tpp_prob covid_death covid_icu covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_sex" `outcome'	W2
}

*Shield
foreach outcome of any  non_covid_death covid_tpp_prob covid_death covid_icu covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_shield" `outcome'	W2
}

*Time
foreach outcome of any  non_covid_death covid_tpp_prob covid_death covidadmission   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_time" `outcome'	W2
}

*****MULTIPLE IMPUTATION to account for missing ethnicity data 
**MULTIPLE IMPUTATION: create the datasets (~3 hours each outcome)
foreach outcome of any covid_tpp_prob covidadmission covid_icu covid_death  {
do "13_multiple_imputation_dataset.do" `outcome' MAIN
	} 
	
*****MULTIPLE IMPUTATION to account for missing ethnicity data 
**MULTIPLE IMPUTATION: create the datasets (~3 hours each outcome)
foreach outcome of any covid_tpp_prob covidadmission covid_death  {
do "13_multiple_imputation_dataset.do" `outcome' W2
	} 


**MULTIPLE IMPUTAION: run (~20 hours each outcome - 80 hours)
foreach outcome of any covid_tpp_prob covidadmission covid_icu covid_death  {
do "14_multiple_imputation_analysis.do" `outcome' MAIN
}

**MULTIPLE IMPUTAION: run (~20 hours each outcome - 80 hours)
foreach outcome of any covid_tpp_prob covidadmission covid_death  {
do "14_multiple_imputation_analysis.do" `outcome' W2
}

*********************************************************************
*		WORMS ANALYSIS CONTROL OUTCOME REQUIRES NEW STUDY POP		*
*********************************************************************	

cd ..
import delimited `c(pwd)'/output/input_worms.csv, clear

cd  `c(pwd)'/analysis /*sets working directory to workspace folder*/
set more off 

/*  Pre-analysis data manipulation  */
do "WORMS_01_cr_analysis_dataset.do"

/*  Checks  */
do "WORMS_02_an_data_checks.do"


*UNIVARIATE MODELS (these fit the models needed for age/sex adj col of Table 2)
foreach outcome of any worms {
winexec "C:\Program Files\Stata16\StataMP-64.exe" 	do "WORMS_06_univariate_analysis.do" `outcome' ///
		kids_cat4  ///
		gp_number_kids
		
************************************************************
*MULTIVARIATE MODELS (this fits the models needed for fully adj col of Table 2)
winexec "C:\Program Files\Stata16\StataMP-64.exe" 	do "WORMS_07a_an_multivariable_cox_models_demogADJ.do" `outcome'
winexec "C:\Program Files\Stata16\StataMP-64.exe" 	do "WORMS_07b_an_multivariable_cox_models_FULL.do" `outcome'
}	

*********************************************************************
********FOLLOWING RELIES ON ALL MODELS ABOVE HAVING RUN**************
*********************************************************************

*Pause for 4 hours
forvalues i = 1/5 {
    di `i'
    sleep 10000
}
*pause Stata for 8 hours: 1/1440 whilst testing on server, on full data


*Tabulate results
foreach outcome of any  non_covid_death covid_tpp_prob covid_death covid_icu covidadmission   {
	do "08_an_tablecontent_HRtable.do" `outcome'
}

*put results in figure
do "15_anHRfigure_all_outcomes.do"


foreach outcome of any worms  {
	do "WORMS_08_an_tablecontent_HRtable.do" `outcome'
}

foreach outcome of any  non_covid_death covid_tpp_prob covidadmission covid_icu covid_death     {
	do "11_an_interaction_HR_tables_forest.do" 	 `outcome'
}


*Revised time periods
foreach outcome of any  non_covid_death covid_tpp_prob covidadmission covid_icu covid_death     {
	do "11a_an_interaction_HR_tables_forest_CAT_TIME_REVISED" 	 `outcome'
}
/*
foreach outcome of any  covid_tpp_prob covidadmission covid_icu covid_death   {
	do "09_an_agesplinevisualisation.do" `outcome'
}
*/

***SENSE ANALYSIS
foreach outcome of any covid_tpp_prob covidadmission covid_icu covid_death    {
	do "10_an_interaction_cox_models_ethnicity_strat.do" `outcome'  W2
	}
	
foreach outcome of any covid_tpp_prob covidadmission covid_icu covid_death    {
	do "11a_an_interaction_HR_tables_forest_eth_strat.do" `outcome'
	}	
	
