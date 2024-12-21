** This script is to build the CRSP data

** Data Source (WRDS)
* CRSP / Annual Update / Stock / Security Files / Daily Stock File
* When downloading data from CRSP, ensure that the following variables are included:

*1. permno (CRSP link number)
   *Description*: A unique identifier assigned by CRSP to each security. It is used to link different datasets within CRSP.

*2. cusip (8-character CUSIP number)
   *Description*: A unique identifier for securities, used to identify a company or issuer.

*3. date (Date)
   *Description*: The date of the data entry (eg. 07jan1986).

*4. retx (Return)
   *Description*: The return on the security, excluding dividends.

*5. sprtrn (Spread Return)
   *Description*: The return spread, often used as a benchmark or market return.



cls
clear all
set more off

global mypath "/Users/tsenga/uim-empirics"
log using $mypath/log/build_crsp_data.log, name(build_crsp_data) replace

use $mypath/data/crsp_daily_stock.dta, clear

rename *, lower

gen fyear = year(date)

encode cusip, gen(cusip1)

gen relretx = retx - sprtrn

sort permno fyear
	
collapse (mean) ret_mean = retx normret_mean = relretx sprtrn_mean = sprtrn (sd) ret_vol = retx normret_vol = relretx sprtrn_vol = sprtrn, by(permno cusip1 fyear)
rename permno lpermno
decode cusip1, generate(cusip8)


** annualised in percentage**
replace ret_mean = ret_mean
replace normret_mean = normret_mean
replace sprtrn_mean = sprtrn_mean

replace ret_vol = ret_vol*sqrt(250)
replace normret_vol = normret_vol*sqrt(250)
replace sprtrn_vol = sprtrn_vol*sqrt(250)

save $mypath/data/crsp_permno.dta, replace


********************************************************************************
************************************* Addiotnal analysis how the data looks like
univar ret_mean normret_mean sprtrn_mean ret_vol normret_vol sprtrn_vol


log close build_crsp_data

