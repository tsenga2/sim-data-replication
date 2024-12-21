** This take the Compustat data and merge it with the IBES data

* The variables needed from crsp-compustat-merged-fund.dta are:
* - gvkey (Global Vault Key, a unique identifier for a firm across time and space)
* - fyear (fiscal year)
* - sic (standard industrial classification code)
* - loc (location code, 1 for USA, 2 for Canada, 3 for other countries)
* - sale (sales)
* - at (total assets)
* - csho (common shares outstanding)
* - lpermno (CRSP link number)
* - dltt (long-term debt)
* - dlc (deferred loan charges)

* The variables needed from crsp_permno.dta are:
* - lpermno (CRSP link number)
* - fyear (fiscal year)
* - cusip8 (8-character CUSIP number)

* The variables needed from ibes_cusip_extrp.dta are:
* - cusip8 (8-character CUSIP number)
* - fyear (fiscal year)
* - actual (actual earnings)
* - medest (median estimate of earnings)
* - fdis (coefficient of variation of the estimates)
* - stdev (standard deviation of the estimate)
* - numest (number of estimates)


cls
clear all
set more off
set graphics on


global mypath "/Users/tsenga/uim-replication-Sep2024/uim-empirics"

*log using $mypath/log/build_ibes_panel.log, name(build_ibes_panel) replace


********************************************************************************
************************************************************* setting up a panel
use $mypath/data/crsp-compustat-merged-monthly.dta, clear
rename *, lower
save $mypath/data/crsp-compustat-merged-monthly.dta, replace

use $mypath/data/crsp-compustat-merged-fund.dta, clear
rename *, lower

merge 1:1 lpermno datadate using $mypath/data/crsp-compustat-merged-monthly.dta
keep if _merge==3
drop _merge

gen year=year(datadate)
format year %ty

sort gvkey fyear sic
destring gvkey, replace
destring sic, replace



** 1: sample selection (keep fic or loc == usa following Gabaix, 2011)
keep if loc=="USA"

** 2 sample selection (drop SIC following Gabaix, 2011)
drop if (sic >= 4900 & sic <= 4940)
drop if (sic >= 6000 & sic <= 6999)

** 3 sample selection (drop CAD currency data)
drop if curcd=="CAD"

** 4 drop bad data
replace sale   =. if sale<=0
replace at     =. if at<=0
replace csho   =. if csho<=0

** 5 setting up a panel
sort gvkey fyear sic

duplicates tag gvkey fyear, gen(isdup)
drop if isdup >0
xtset gvkey fyear
xtsum gvkey

** 6 merge in CRSP permno
merge m:m lpermno fyear using $mypath/data/crsp_permno.dta
keep if _merge==3
drop _merge
xtsum gvkey

** 7 merge in IBES estimates
merge m:m cusip8 fyear using $mypath/data/ibes_cusip_extrp.dta
keep if _merge==3
drop _merge
xtsum gvkey

** 8 merge in option implied volatilities
*merge m:m cusip8 fyear using $mypath/data/optmtrx31_y.dta
*drop _merge
*xtsum gvkey


********************************************************************************
****************************************** variable construction 
sort gvkey fyear sic

** 1.1 ROA
gen street_earnings = actual*l.csho
gen strt  = street_earnings/l.at

** 1.2 FE
gen fe1 = abs(actual-medest)*csho/at
gen fe2 = abs((actual-medest)/medest)
gen fe3 = abs(log(actual/medest))
gen lnfe1 = log(fe1)
gen lnfe2 = log(fe2)
gen lnfe3 = log(fe3)

** 1.3 Fdis
gen fdis1 = fdis
gen fdis2 = stdev
gen lndis1 = log(fdis1)
gen lndis2 = log(fdis2)
gen lev = (dltt + dlc)/at

** 1.4 Firm lifespan and age (time-elapsed-since-ipo)
gen ind = 1
by gvkey: generate age = _n
by gvkey: generate life = _N

** 1.5 Realized volatility
gen vol = normret_vol

****************************************************** deflate by CPI
merge m:m year using $mypath/data/FRED_Data.dta
keep if _merge==3
drop _merge

sort gvkey fyear

replace sale = 100*sale/defl
replace at   = 100*at/defl


*********************************************************************
******************************************* look at descriptive stats
******************************************* trim outliers and winsor2
winsor2 sale at emp lev strt fdis1 fdis2 fe1 fe2 fe3 vol, cuts(1 99) trim


***************************************************** save panel data
sort gvkey fyear

save $mypath/data/uim_panel.dta, replace
