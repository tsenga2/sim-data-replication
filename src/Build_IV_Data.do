** This script is to build the IV data

** Data Source (WRDS)
* OptionMetrics / Ivy DB US / Options / Standardized Options
* Put Only (Option Type), Security Type (Equity)
* When downloading data from OptionMetrics, ensure that the following variables are included:

*1. cusip (CUSIP number)
   *Description*: A unique identifier for securities, used to identify a company or issuer.

*2. date (Date)
   *Description*: The date of the data entry (eg. 01/11/2022).

*3. days (Days to expiration)
   *Description*: Number of days until option expiration.

*4. impl_volatility (Implied Volatility)
   *Description*: The market's forecast of likely price movement, derived from option prices.
 

cls
clear all
set more off

global mypath "/Users/tsenga/uim-empirics"
log using $mypath/log/build_iv_data.log, name(build_iv_data) replace


import delimited $mypath/data/std_inv.csv, clear 

keep if days==30

gen date1=date(date,"DMY")
format date1 %td
gen fyear=year(date1)
gen ym = mofd(date1)
format ym %tm

sort cusip fyear ym
*drop if impl_volatility==.
drop if impl_volatility<0
collapse (mean) iv_mean =  impl_volatility, by(cusip fyear ym)

rename cusip cusip8
encode cusip, gen(cusip1)
recast int cusip1
xtset cusip1 ym, monthly

** Monthly data
save $mypath/data/optmtrx31_m.dta, replace

collapse (mean) iv_mean = iv_mean, by(cusip8 fyear)
encode cusip8, gen(cusip)
recast int cusip
xtset cusip fyear, yearly
xtsum cusip
drop cusip

** Yearly data
save $mypath/data/optmtrx31_y.dta, replace


log close build_iv_data

