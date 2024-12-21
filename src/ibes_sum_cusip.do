****27/12/2023: revision work for ECMA in Tokyo - extending sample period
****23/08/2023: revision work for ECMA in Tokyo
****18/06/2018: revision work for ECMA in QMUL - final batch

****24/05/2018: revision work for ECMA in QMUL - adding fe4
****12/05/2018: revision work for ECMA in Barbican after E1Macro
****27/03/2018: revision work for ECMA in QMUL after the RES conference

****07/03/2018: revision work for ECMA in Nice

****21/02/2018: revision work for ECMA in London (just back from Lisbon)
****             - moving files from Google Drive to Dropbox folder
****             - evolved from ibes_sum_cusip_June2016a.do

*********************************************************************
* 23 August 2016: checking by reading "data" (ShareLaTeX\Bayesian Uncertainty Shock\empirics)
* from ibes_June2015 to new (trying to map ferror to model tightly)
* this is version a: to create fdis, frang, and ferror for forecasts made in 8 month prior

cls
clear all
set more off
set graphics on


log using log/build_ibes.log, name(build_ibes) replace

use data/ibes.dta, clear
rename *, lower

gen year=year(statpers)
gen m=month(statpers)
gen ym = ym(year, m)


gen fyear=year(fpedats)
gen fm=month(fpedats)
gen fym = ym(fyear, fm)
format fym %tm


*********************************************************** clearning data (fundamental)
drop if cusip==""
drop if cusip=="00000000"

duplicates tag cusip ym, gen(isdup)
drop if isdup == 1


************************************************************ setup a firm-by-month panel
******************************************************************** look st desc. stats
sort cusip ym
encode ticker, generate(tic)
drop oftic
xtset tic ym


********************************************************************************
* you might as well save the monthly panel here
* after winsor2...
********************************************************************************

******************************************* sample selection for fdis and ferror
drop if numest<2
drop if actual==.

** 18/05/2018: NEW
gen toward = fym - ym
keep if toward<13
keep if toward>-13
format ym %tmYY!mnn



********************************************************************************
************************************************************ construct variables 
gen coefv = stdev/abs(meanest)
gen ferr1 = abs(actual - medest)

** 28/03/2018: new
gen ferr2 = abs((actual - medest)/medest)


** 13/05/2018: new, following learning paper.
gen ferr3 = abs(log(actual/medest))

** 28/03/2018: new
gen id = 0.001


** 24/05/2018: NEW
gen ferr4 = (highest-actual)*(highest-actual) + (meanest-actual)*(meanest-actual) + (lowest-actual)*(lowest-actual)
replace ferr4 = sqrt(ferr4/3)


********************************************************************************
********************************************************************************
winsor2 actual medest meanest highest lowest coefv stdev ferr1 ferr2 ferr3 ferr4, cuts(1 99) trim

egen maxtow = max(toward),   by(fyear cusip)
egen countv = count(toward), by(fyear cusip)

foreach z in medest_tr meanest_tr highest_tr lowest_tr coefv_tr stdev_tr ferr1_tr ferr2_tr ferr3_tr ferr4_tr {
	egen `z'_aveval = mean(`z') , by(fyear cusip)
	egen `z'_fstval = first(`z'), by(fyear cusip)
	egen `z'_maxval = max(`z')  , by(fyear cusip)
	egen `z'_minval = min(`z')  , by(fyear cusip)
	gen  `z'_extrap = `z'_maxval + (13-maxtow)*((`z'_maxval-`z'_minval)/countv)
}
winsor2 coefv_tr_extrap stdev_tr_extrap ferr1_tr_extrap ferr2_tr_extrap ferr3_tr_extrap ferr4_tr_extrap, cuts(1 99) trim


save data/ibes_panel_m.dta, replace
use data/ibes_panel_m.dta


********************************************************************************
******************************************************** (1) average during year
preserve
collapse (sum) obs = id (mean) numana = numest medest = medest_tr_aveval meanest = meanest_tr_aveval highest = highest_tr_aveval lowest = lowest_tr_aveval actual = actual_tr coefv = coefv_tr_aveval stdev = stdev_tr_aveval ferror1 = ferr1_tr_aveval ferror2 = ferr2_tr_aveval ferror3 = ferr3_tr_aveval ferror4 = ferr4_tr_aveval,  by(cusip fyear)
rename cusip cusip8
save data/ibes_cusip_1yr.dta, replace
restore


********************************************************************************
******************************************************** (2) 12 month-ahead ****
preserve
collapse (sum) obs = id (mean) numana = numest medest = medest_tr_fstval meanest = meanest_tr_fstval highest = highest_tr_fstval lowest = lowest_tr_fstval actual = actual_tr coefv = coefv_tr_fstval stdev = stdev_tr_fstval ferror1 = ferr1_tr_fstval ferror2 = ferr2_tr_fstval  ferror3 = ferr3_tr_fstval ferror4 = ferr4_tr_fstval,  by(cusip fyear)
rename cusip cusip8
save data/ibes_cusip_ave.dta, replace
restore


********************************************************************************
******************************************************** (3) extraporated  *****
preserve
collapse (sum) obs = id (mean) numana = numest medest = medest_tr_extrap meanest = meanest_tr_extrap highest = highest_tr_extrap lowest = lowest_tr_extrap actual = actual_tr coefv = coefv_tr_extrap_tr stdev = stdev_tr_extrap_tr ferror1 = ferr1_tr_extrap_tr ferror2 = ferr2_tr_extrap_tr ferror3 = ferr3_tr_extrap_tr ferror4 = ferr4_tr_extrap_tr,  by(cusip fyear)
rename cusip cusip8
save data/ibes_cusip_extrp.dta, replace
restore



log close build_ibes


*if you need something below go back 20:49 17/05/2018 version of this

