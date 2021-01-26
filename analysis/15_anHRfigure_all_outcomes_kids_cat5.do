*************************************************************************
*Purpose: Create content that is ready to paste into a pre-formatted Word 
* shell table containing sensitivity analysis (complete case for BMI and smoking, 
*and ethnicity) 
*
*Requires: final analysis dataset (analysis_dataset.dta)
*
*Coding: HFORBES, based on file from Krishnan Bhaskaran
*
*Date drafted: 30th June 2020
*************************************************************************


***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real)
file write tablecontents_all_outcomes ("dataset") _tab ("age") _tab ("exposure") _tab ("exposure level") ///
_tab ("outcome") _tab ("HR")  _tab ("lci")  _tab ("uci")  _n
foreach dataset in MAIN W2 {
forvalues x=0/1 {
foreach outcome in  covid_tpp_prob covidadmission covid_icu covid_death non_covid_death  {
forvalues i=1/4 {
local endwith "_tab"

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontents_all_outcomes ("`dataset'") _tab ("`x'") _tab ("`variable'") _tab ("`i'") _tab ("`outcome'") _tab

	foreach modeltype of any plus_ethadj {
	
		local noestimatesflag 0 /*reset*/

*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if "`modeltype'"=="plus_ethadj" local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY
	
		if "`modeltype'"=="plus_ethadj" {
				cap estimates use ./output/an_sense_`outcome'_nursery_cat_ageband_`x'`dataset'
				if _rc!=0 local noestimatesflag 1
				}
		
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE
		
		if `noestimatesflag'==0 & "`modeltype'"=="plus_ethadj"  {
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents_all_outcomes %4.2f (r(estimate)) _tab %4.2f (r(lb)) _tab %4.2f (r(ub)) _tab (e(N))  `endwith'
				else file write tablecontents_all_outcomes %4.2f ("ERR IN MODEL") `endwith'
			}
			
		*3) Save the estimates for plotting
		if `noestimatesflag'==0{
			if "`modeltype'"=="plus_ethadj"   {
				local hr = r(estimate)
				local lb = r(lb)
				local ub = r(ub)
				local N=e(N)
				post HRestimates_all_outcomes ("`dataset'") ("`x'") ("`outcome'") ("`variable'") (`i') (`hr') (`lb') (`ub') (`N') 
				}
		}	
		} /*min adj, full adj*/
	} /*datasets*/
		
} /*variable levels*/
} /*age levels*/
} /*sense levels*/

end

*MAIN CODE TO PRODUCE TABLE CONTENTS


cap file close tablecontents_all_outcomes
file open tablecontents_all_outcomes using ./output/15_an_tablecontents_HRtable_all_outcomes_KIDS_CAT5.txt, t w replace 

tempfile HRestimates_all_outcomes
cap postutil clear
postfile HRestimates_all_outcomes str10 dataset str10 x str10 outcome str27 variable i hr lci uci N using `HRestimates_all_outcomes'


*Primary exposure
outputHRsforvar, variable("kids_cat5") min(1) max(3) 
file write tablecontents_all_outcomes _n

file close tablecontents_all_outcomes

postclose HRestimates_all_outcomes

use `HRestimates_all_outcomes', clear
save ./output/HRestimates_all_outcomes, replace

foreach dataset in MAIN W2 { 
foreach age in 0 1 {
use `HRestimates_all_outcomes', clear
keep if dataset=="`dataset'"
keep if x=="`age'"
gen littlen=_n
sort littlen i
drop variable N 

gen obsorder=_n
expand 2 if outcome!=outcome[_n-1], gen(expanded)
gsort obsorder -expanded 

for var hr lci uci: replace X = . if expanded==1

drop obsorder 
gen obsorder=_n



*Levels
gen leveldesc = ""
replace leveldesc = "Only children aged 0-4 years" if i==1 & hr!=1 & hr!=.
replace leveldesc = "Only children aged 5-11 years" if i==2 & hr!=1 & hr!=.
replace leveldesc = "Only children aged ≥12 years" if i==3 & hr!=1 & hr!=.
replace leveldesc = "Children in a least 2 of above age categories" if i==4 & hr!=1 & hr!=.


gen Name = outcome if hr==.
replace Name = "COVID-19 death" if Name=="covid_deat"
replace Name = "COVID-19 ICU admission" if Name=="covid_icu"
replace Name = "Reported SARS-CoV-2 infection" if Name=="covid_tpp_"
replace Name = "COVID-19 hospital admission" if Name=="covidadmis"
replace Name = "Non COVID-19 death" if Name=="non_covid_"

expand 2 if Name=="COVID-19 death or ICU admission"
gsort obsorder -expanded 


gen displayhrci = string(hr, "%3.2f") + " (" + string(lci, "%3.2f") + "-" + string(uci, "%3.2f") + ")"
replace displayhrci="" if hr==.
list display 

gen varx = 0.03
gen levelx = 0.033
gen intx=0.04
gen lowerlimit = 0.15
gen disx=3


drop obsorder
gen obsorder=_n
gsort -obsorder
gen graphorder = _n
sort obsorder


list 

gen hrtitle="Hazard Ratio (95% CI)" if graphorder == 38
gen bf_hrtitle = "{bf:" + hrtitle + "}" 
gen bf_Name = "{bf:" + Name + "}" 


scatter graphorder hr, mcol(black)	msize(small)		///										///
	|| rcap lci uci graphorder, hor mcol(black)	lcol(black)			///
	|| scatter graphorder levelx, m(i) mlab(bf_Name) mlabsize(vsmall) mlabcol(black) 	///
	|| scatter graphorder intx, m(i) mlab(leveldesc) mlabsize(vsmall) mlabcol(black) 	///
	|| scatter graphorder disx, m(i) mlab(displayhrci) mlabsize(vsmall) mlabcol(black) ///
	|| scatter graphorder disx, m(i) mlab(bf_hrtitle) mlabsize(vsmall) mlabcol(black) ///
		xline(1,lp(solid)) 															///
		xscale(log range(0.1 6)) xlab(0.5 1 2, labsize(vsmall)) xtitle("")  ///
		ylab(none) ytitle("")		yscale( lcolor(white))					/// 
		graphregion(color(white))  legend(off)  ysize(4) ///
		text(-0.5 0.1 "Lower risk in those living with children", place(e) size(vsmall)) ///
		text(-0.5 1.5 "Higher risk in those living with children", place(e) size(vsmall))

graph export ./output/15_an_HRforest_all_outcomes_ageband_`age'_`dataset'_KIDS_CAT5.svg, as(svg) replace
}
}
