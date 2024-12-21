* This takes the IBES data and creates a panel with 3 different estimates of earnings
* 1. Average of the estimates for the year (ibes_cusip_1yr)
* 2. The estimate for the 12-month ahead (ibes_cusip_ave)
* 3. The extrapolated estimate (using the min, max, and count of estimates) (ibes_cusip_extrp)

* The variables needed from ibes.data.dta are:
* - cusip (8-digit) ---> cusip8
* - ticker (ticker symbol)
* - statpers (date of the estimate) ---> year
* - fpedats (date of the fiscal year end) ---> fyear
* - numest (number of estimates)
* - medest (median estimate)
* - meanest (mean estimate)
* - stdev (standard deviation of the estimates)
* - highest (highest estimate)
* - lowest (lowest estimate)
* - actual (actual earnings)

cls
clear all
set more off
set graphics on


global mypath "/Users/tsenga/uim-replication-Sep2024/uim-empirics"

*log using $mypath/log/build_ibes_panel.log, name(build_ibes_panel) replace

use $mypath/data/ibes.dta, clear
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


******************************************* sample selection for fdis and ferror
drop if numest<2
drop if actual==.

gen toward = fym - ym
keep if toward<13
keep if toward>-13
format ym %tmYY!mnn


********************************************************************************
************************************************************ construct variables 
gen fdis = stdev/abs(meanest)
gen fe = abs(log(actual/medest))
gen id = 0.001

********************************************************************************
winsor2 actual medest meanest highest lowest stdev fdis fe, cuts(1 99) trim

egen maxtow = max(toward),   by(fyear cusip)
egen countv = count(toward), by(fyear cusip)

foreach z in medest_tr meanest_tr highest_tr lowest_tr stdev_tr fdis_tr fe_tr {
	egen `z'_aveval = mean(`z') , by(fyear cusip)
	egen `z'_fstval = first(`z'), by(fyear cusip)
	egen `z'_maxval = max(`z')  , by(fyear cusip)
	egen `z'_minval = min(`z')  , by(fyear cusip)
	gen  `z'_extrap = `z'_maxval + (13-maxtow)*((`z'_maxval-`z'_minval)/countv)
}
winsor2 stdev_tr_extrap fdis_tr_extrap fe_tr_extrap, cuts(1 99) trim


*save $mypath/data/ibes_panel_m.dta, replace
*use $mypath/data/ibes_panel_m.dta




********************************************************************************
******************************************************** (1) average during year
preserve
collapse (sum) obs = id (mean) numana = numest medest = medest_tr_aveval meanest = meanest_tr_aveval highest = highest_tr_aveval lowest = lowest_tr_aveval actual = actual_tr stdev = stdev_tr_aveval fdis = fdis_tr_aveval fe = fe_tr_aveval,  by(cusip fyear)
rename cusip cusip8
save $mypath/data/ibes_cusip_1yr.dta, replace
restore


********************************************************************************
******************************************************** (2) 12 month-ahead ****
preserve
collapse (sum) obs = id (mean) numana = numest medest = medest_tr_fstval meanest = meanest_tr_fstval highest = highest_tr_fstval lowest = lowest_tr_fstval actual = actual_tr stdev = stdev_tr_fstval fdis = fdis_tr_fstval fe = fe_tr_fstval,  by(cusip fyear)
rename cusip cusip8
save $mypath/data/ibes_cusip_ave.dta, replace
restore


********************************************************************************
******************************************************** (3) extraporated  *****
preserve
collapse (sum) obs = id (mean) numana = numest medest = medest_tr_extrap meanest = meanest_tr_extrap highest = highest_tr_extrap lowest = lowest_tr_extrap actual = actual_tr stdev = stdev_tr_extrap fdis = fdis_tr_extrap fe = fe_tr_extrap,  by(cusip fyear)
rename cusip cusip8
save $mypath/data/ibes_cusip_extrp.dta, replace
restore



*log close build_ibes_panel

