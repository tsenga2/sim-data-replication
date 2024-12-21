** This file takes the FRED data and creates a panel with the following variables:
* - year 
* - usrec 
* - gdp_growth
* - rinv (real investment)
* - rcomsp (real consumption)
* - rgdp (real GDP)
* - ln_rgdp (log of real GDP)
* - ln_rcomsp (log of real consumption)
* - ln_rinv (log of real investment)
* - dgdp (growth rate of GDP)
* - ln_rgdp_hp (log of real GDP HP filter)
* - ln_rcomsp_hp (log of real consumption HP filter)
* - ln_rinv_hp (log of real investment HP filter)
* - cpi (consumer price index)
* - defl (GDP deflator)


cls
clear all
set more off
set graphics on

global mypath "/Users/tsenga/uim-empirics"

log using $mypath/log/build_fred_data.log, name(build_fred_data) replace

** (1) CPI (OECD CPI TOtal for U.S. and OECD GDP Deflator for U.S.)
************************************************************************* annual	
import fred CPALTT01USA661S USAGDPDEFAISMEI

gen year = yofd(daten)
format year %ty

drop datestr
drop daten
rename CPALTT01USA661S cpi
rename USAGDPDEFAISMEI defl


tsset year, yearly

tempfile fred_cpi
save `fred_cpi' 


** (2) Real GDP
************************************************************************* annual	
import fred GDPCA PCECCA GPDICA A191RL1A225NBEA USREC, clear

gen year = yofd(daten)
format year %ty

collapse (sum) USREC (min) A191RL1A225NBEA GPDICA PCECCA GDPCA, by(year)

rename GPDICA rinv
rename PCECCA rcomsp
rename GDPCA rgdp
rename USREC usrec

* This is [Percent Change from Preceding Period, Not Seasonally Adjusted}
rename A191RL1A225NBEA gdp_growth

tsset year, yearly


gen ln_rgdp = ln(rgdp)
gen ln_rcomsp = ln(rcomsp)
gen ln_rinv = ln(rinv)

gen dgdp = ln_rgdp - l.ln_rgdp

tsfilter hp ln_rgdp_hp ln_rcomsp_hp ln_rinv_hp = ln_rgdp ln_rcomsp ln_rinv, smooth(100)

corr gdp_growth ln_rgdp_hp dgdp

sum  ln_rgdp_hp ln_rcomsp_hp ln_rinv_hp
corr ln_rgdp_hp ln_rcomsp_hp ln_rinv_hp

sum  ln_rgdp_hp ln_rcomsp_hp ln_rinv_hp if (year>1977 & year<2015)
corr ln_rgdp_hp ln_rcomsp_hp ln_rinv_hp if (year>1977 & year<2015)


** (3) Merge CPI and GDP
*************************************************************************
merge 1:1 year using `fred_cpi'
drop _merge
drop if year<1960
drop if year>2022


** (4) Save
*************************************************************************
save "$mypath/data/FRED_Data.dta", replace

log close build_fred_data
