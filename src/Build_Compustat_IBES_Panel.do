** This take the Compustat data and merge it with the IBES data

* The variables needed from crsp-compustat-merged-fund.dta are:
* - gvkey (a unique identifier for a firm)
* - fyear (fiscal year)
* - sic (standard industrial classification code)
* - loc (location code, 1 for USA, 2 for Canada, 3 for other countries)
* - sale (sales)
* - at (total assets)
* - csho (common shares outstanding)
* - dltt (long-term debt)
* - dlc (deferred loan charges)
* - lpermno (CRSP link number)

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


global mypath "/Users/tsenga/uim-empirics"

log using $mypath/log/build_compustat_ibes_panel.log, name(build_compustat_ibes_panel) replace


********************************************************************************
************************************************************* setting up a panel
use $mypath/data/crsp-compustat-merged-fund.dta, clear
rename *, lower

*gen year=year(datadate)
*format year %ty
gen year=fyear

sort gvkey fyear sic
destring gvkey, replace
destring sic, replace



** 1: sample selection (keep fic or loc == usa)
keep if loc=="USA"

** 2 sample selection (drop SIC finance and utility)
drop if (sic >= 4900 & sic <= 4940)
drop if (sic >= 6000 & sic <= 6999)

** 3 sample selection (drop CAD currency data)
drop if curcd=="CAD"

** 4 fix bad data
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
merge m:m cusip8 fyear using $mypath/data/optmtrx31_y.dta
drop _merge
save $mypath/data/uim_panel.dta, replace

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

** 1.6 Option Implied Volatility
gen iv = iv_mean
save $mypath/data/uim_panel.dta, replace

** 1.0 Merge uim-panel with CRSP monthly data
use $mypath/data/crsp_compustat_merged_security_monthly.dta, clear
rename *, lower
destring gvkey, replace
destring sic, replace
save $mypath/data/crsp_compustat_merged_security_monthly.dta, replace

use $mypath/data/uim_panel.dta, clear

merge m:m lpermno datadate using $mypath/data/crsp_compustat_merged_security_monthly.dta
keep if _merge==3
drop _merge



** 1.1 Generate sic_3d
gen sic_3d=int(sic/10)

** 1.2 Merge in CPI
*merge m:m year using $mypath/data/FRED_Data.dta
*keep if _merge==3
*drop _merge

sort gvkey fyear sic

** 1.3 Deflate sales and ppe
*replace sale = 100*sale/defl
*replace ppeg = 100*ppeg/defl
gen ln_sales = log(sale)
gen ln_capital = log(ppeg)
gen fundamental = 0.5*ln_sales - 0.83*ln_capital

drop if gvkey==.
egen new_gvkey = group(gvkey)
sort new_gvkey fyear
xtset new_gvkey fyear

** 1.4 Generate fundamental
xtreg fundamental i.fyear, fe robust
predict e, e
egen sigma_mu = sd(e), by(sic_3d fyear)

gen fundamental_gr = fundamental - L.fundamental
gen investment_gr = ln_capital - L.ln_capital
gen stock_price = log(prccm*trfm/ajexm)
gen stock_price_gr = stock_price - L.stock_price

qui xtreg stock_price_gr i.fyear, fe
qui predict stock_price_gr_id, e
qui xtreg investment_gr i.fyear, fe
qui predict investment_gr_id_tr, e
qui xtreg fundamental_gr i.fyear, fe
qui predict fundamental_gr_id_tr, e
gen stock_price_gr_id_lag_tr = L.stock_price_gr_id

sort fyear sic_3d
egen corr_spvsinv_tr = corr(stock_price_gr_id_lag_tr investment_gr_id_tr), by(fyear sic_3d)
egen corr_spvsfund_tr = corr(stock_price_gr_id_lag_tr fundamental_gr_id_tr), by(fyear sic_3d)

gen ratio_corr = (corr_spvsfund_tr/corr_spvsinv_tr)^2
replace ratio_corr = . if ratio_corr > 1.0
gen V_jt = sigma_mu*sigma_mu*(1 - ratio_corr)
gen mrpk = log(0.5*sale/ppeg)

egen total_sales_t  = sum(sale), by(fyear)
egen total_sales_jt = sum(sale), by(fyear sic_3d)
gen  share_sales_jt = total_sales_jt/total_sales_t 

****************************************************** deflate by CPI
merge m:m year using $mypath/data/FRED_Data.dta
keep if _merge==3
drop _merge

sort gvkey fyear

replace sale = 100*sale/defl
replace at   = 100*at/defl
replace ppegt = 100*ppegt/defl


*********************************************************************
******************************************* look at descriptive stats
******************************************* trim outliers and winsor2
winsor2 sale at emp lev strt fdis1 fdis2 fe1 fe2 fe3 vol iv V_jt mrpk, cuts(1 99) trim
gen      V_jt_w_tr = V_jt_tr*share_sales_jt
replace  V_jt_w_tr = V_jt_w_tr*100


***************************************************** save panel data
sort gvkey fyear

save $mypath/data/uim_panel.dta, replace

log close build_compustat_ibes_panel


