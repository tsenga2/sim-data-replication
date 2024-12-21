****27/12/2023: revision work for ECMA in Tokyo - extending sample period
****23/08/2023: revision work for ECMA in Tokyo
****18/06/2018: revision work for ECMA in QMUL - final batch

****15/05/2018: revision work for ECMA in Barbican after E1Macro - new version of V_jt
****12/05/2018: revision work for ECMA in Barbican after E1Macro
****27/03/2018: revision work for ECMA in QMUL after the RES conference

****24/03/2018: revision work for ECMA in QMUL
****             - this re-considers stadard deviation and coefficiant variation of fdis and fe

****07/03/2018: revision work for ECMA in Nice
****             - this merge with Optionmatrix to do IV

****06/03/2018: revision work for ECMA in Nice

****20/02/2018: revision work for ECMA in Lisbon
****             - moving files from Google Drive to Dropbox folder

*********************************************************************
****20/09/2016: final version check in Mile End
****23/08/2016: re-checking in Geneva
*********************************************************************
****28/06/2016: to map ferror into model tightly, ferr_roa is now calculated in line 54 and 55, which is carried from IBES data too
****29/04/2016: This can do both panel and time series analysis. This way I can compare all versions of panel.
****28/04/2016: refer log dated 080416 too. This is for panel analysis. See compustat_CCM_CRSP_IBES for time series analysis.
****27/04/2016: this is to start from compustat, linking with ccm, crsp, ibes and optionmetrix, towards constructing a panel
****refer log file dated 26042016 too.
****
****31570 compustat
****23194 (compustat(gvkey)+(gvkey)ccm)
****22384 (compustat(gvkey)+(gvkey)ccm)(lpermno)+(lpermno)crsp
****11865 ((compustat(gvkey)+(gvkey)ccm)(lpermno)+(lpermno)crsp)(cusip8)+(cusip8)ibes
****5846  ((compustat(gvkey)+(gvkey)ccm)(lpermno)+(lpermno)crsp)(cusip8)+(cusip8)ibes(cusip8)+(cusip8)optionmetrix
*********************************************************************

cls
clear all
set more off
set graphics on

log using log/build_panel.log, name(build_panel) replace


********************************************************************************
************************************************************* setting up a panel
use data/crsp-compustat-merged-monthly.dta, clear
rename *, lower
save data/crsp-compustat-merged-monthly.dta, replace

use data/crsp-compustat-merged-fund.dta, clear
rename *, lower

merge 1:1 lpermno datadate using data/crsp-compustat-merged-monthly.dta
keep if _merge==3
drop _merge

gen year=year(datadate)
format year %ty

sort gvkey fyear sic
destring gvkey, replace
destring sic, replace



** 1: sample selection (keep fic or loc ==usa following Gabaix, 2011)
keep if loc=="USA"

** 2 sample selection (drop SIC following Gabaix, 2011)
*drop if (sic==2911 | sic==5172 | sic==1311 | sic==4922 | sic==4923 | sic==4924 | sic==1389)
drop if (sic >= 4900 & sic <= 4940)
drop if (sic >= 6000 & sic <= 6999)

** 3 sample selection (drop CAD currency data)
drop if curcd=="CAD"

** 4 drop bad data
replace sale   =. if sale<=0
replace at     =. if at<=0
replace ppegt  =. if ppegt<=0
replace csho   =. if csho<=0
*replace prccm  =. if prccm<=0(no such data)
*replace trfm   =. if trfm<=0 (no such data)
*replace ajexm  =. if ajexm<=0(no such data)


** 5 setting up a panel
sort gvkey fyear sic

duplicates tag gvkey fyear, gen(isdup)
drop if isdup >0
xtset gvkey fyear
xtsum gvkey

*cd "D:\Dropbox (QMUL-SEF)\Research\firm\Uncertainty\UIM\empirics\CCM"
*merge m:m gvkey using ccm_gvkeylANDpermno_April2016.dta
*keep if _merge==3
*drop _merge
*xtsum gvkey

merge m:m lpermno fyear using data/crsp_permno.dta
keep if _merge==3
drop _merge
xtsum gvkey


* until 17/05/18 and after 18/05/18
*merge m:m cusip8 year using ibes_cusip_May_ave.dta
*merge m:m cusip8 year using ibes_cusip_May_1yr.dta
*merge m:m cusip8 year using ibes_cusip_May_extrp.dta

* on 18/05/18
*merge m:m cusip8 fyear using ibes_cusip_May_ave.dta
*merge m:m cusip8 fyear using ibes_cusip_May_1yr.dta
merge m:m cusip8 fyear using data/ibes_cusip_extrp.dta
keep if _merge==3
drop _merge
xtsum gvkey	


* you have choice between 31days and 91day expiration 
merge m:m cusip8 fyear using data/optmtrx31_y.dta
*merge m:m cusip8 fyear using optmtrx91_y_Mar18.dta"

* Now I keep this to examine IV together (10 March 2018 @ NICE)
*keep if _merge==3
drop _merge
xtsum gvkey

*********************************************************************
********************************************** variable construction 
sort gvkey fyear sic

gen street_earnings = actual*l.csho
gen strt  = street_earnings/l.at
gen ayse  = (ib - dvp + txdi)/l.at
gen gaap  = oibdp/l.at

*gen fe1 = ferror1*l.csho/l.at

* 28/03/18 NEW
gen fe1 = ferror1*csho/at
gen lnfe1 =  log(fe1)

* 28/03/18 NEW
gen fe2 = ferror2
* 13/05/18 NEW
gen lnfe2 =  fe2

* 27/03/18 NEW
gen fe3 = ferror3
gen lnfe3 =  fe3

* 24/05/18 NEW
gen fe4 = ferror4
gen lnfe4 =  fe4

gen fdis1 = coefv
gen fdis2 = stdev
gen lndis1 = log(fdis1)
gen lndis2 = log(fdis2)

gen lev = (dltt + dlc)/at

gen vol = normret_vol
gen iv  = iv_mean

gen ind = 1
by gvkey: generate age = _n
by gvkey: generate life = _N


******************************************************************************** 
******************************************************************* Venky's V_jt
gen sic_3d=int(sic/10)
gen sic_2d=int(sic/100)
gen sic_1d=int(sic/1000)
egen sic2_fyear = group(sic_2d fyear)


***************************************************************** deflate by CPI
merge m:m year using data/freduse_cpi.dta
keep if _merge==3
drop _merge

sort gvkey fyear sic

*g r_sale = sale/cpi
*g r_ppeg = ppeg/cpi
*g r_at   = at/cpi
replace sale = 100*sale/defl
replace ppeg = 100*ppeg/defl
replace at   = 100*at/defl

gen ln_sales = log(sale)
gen ln_capital = log(ppeg)
gen ln_capital_lag = l.ln_capital
gen ln_at = log(at)
gen ln_emp = log(emp)


gen investment = ln_capital - ln_capital_lag
gen IK =  (ppeg-l.ppeg)/l.ppeg
gen emp_gr = emp - l.emp

** CALCULATE FUNDAMENTAL 
* fundamental = share_intermediates*log(value added) - alpha*log(capital)
* share_intermediates = 0.5 (page 19 appendix)
* log(value added) = log(sales)
* alpha = 0.83 (page 975 paper)

*gen fundamental = ln_sales - ln_material
*gen fundamental = 0.65*ln_sales - 0.83*ln_capital 
*gen fundamental = 0.65*ln_sales - 0.62*ln_capital 
gen fundamental = 0.5*ln_sales - 0.83*ln_capital
*gen fundamental = 0.5*ln_sales - 0.62*ln_capital
*gen fundamental = 0.5*ln_sales - 0.83*ln_emp

***************************************************************** 27 05 18 NEW
*gen mrpk = 0.5*ln_sales - ln_capital
gen mrpk = log(0.5*sale/ppeg)      // 180618 change

********************************************************************************
*************************************************************** sample selection
drop if gvkey==.
tsspell gvkey
by gvkey: egen maxrun = max(_seq)
egen new_gvkey = group(gvkey _spell)
drop _spell _seq _end maxrun

sort new_gvkey fyear
xtset new_gvkey fyear

tsspell new_gvkey
by new_gvkey: egen maxrun = max(_seq)


* 16/05/2018 NEW
*keep if maxrun>5
*xtreg fundamental l.fundamental i.year, fe robust
*gen sigma_mu=e(sigma_e)

* 25/05/2018 NEW
*keep if maxrun>5
*xtreg fundamental i.fyear, fe robust
*gen sigma_mu=e(sigma_e)


******************************************************************** 27 5 18 NEW
*keep if maxrun>5
xtreg   fundamental i.fyear, fe robust
*predict xb, xb
*predict stdp, stdp
*predict ue, ue
*predict xbu, xbu
*predict u, u
predict e, e
egen sigma_mu = sd(e), by(sic_3d fyear)
******************************************************************** 27 5 18 NEW


** Calculate the fundamental growth, investment, stock return
gen fundamental_gr = fundamental - L.fundamental
gen investment_gr = ln_capital - L.ln_capital
*gen stock_price1 = log(prcc_c)

* 26/05/2018 NEW
*gen stock_price2 = log(prccm)
gen stock_price    = log(prccm*trfm/ajexm)
gen stock_price_gr = stock_price - L.stock_price

univar stock_price_gr investment_gr fundamental_gr


** USE TIME FIX EFFECT TO GET IDIOSYNCRATIC COMPONENT
qui xtreg stock_price_gr fyear, fe
*qui predict stock_price_gr_id, residuals
qui predict stock_price_gr_id, e

qui xtreg investment_gr fyear, fe
*qui predict investment_gr_id_tr, residuals
qui predict investment_gr_id_tr, e

qui xtreg fundamental_gr fyear, fe
*qui predict fundamental_gr_id_tr, residuals
qui predict fundamental_gr_id_tr, e

gen stock_price_gr_id_lag_tr = L.stock_price_gr_id

*winsor2 stock_price_gr_id_lag investment_gr_id fundamental_gr_id, cuts(0.1 99.9) trim
univar  stock_price_gr_id_lag_tr investment_gr_id_tr fundamental_gr_id_tr

** CALCULATE THE CORRELATIONS AND STANDARD DEVIATIONS FOR EACH YEAR AND SECTOR
sort fyear sic_3d
egen corr_spvsinv_tr = corr(stock_price_gr_id_lag_tr investment_gr_id_tr),  by(fyear sic_3d)
egen corr_spvsfund_tr= corr(stock_price_gr_id_lag_tr fundamental_gr_id_tr), by(fyear sic_3d)

*winsor2 corr_spvsinv corr_spvsfund, cuts(0.1 99.9) trim
gen ratio_corr = (corr_spvsfund_tr/corr_spvsinv_tr)^2
replace ratio_corr=. if ratio_corr>1.0

gen V_jt = sigma_mu*sigma_mu*(1 - ratio_corr)

egen total_sales_t  = sum(sale), by(fyear)
egen total_sales_jt = sum(sale), by(fyear sic_3d)
gen  share_sales_jt = total_sales_jt/total_sales_t 



*********************************************************************
******************************************* look at descriptive stats
***************************************** delete outliers and winsor2
winsor2 sale at emp lev strt fdis1 fdis2 fe1 fe2 fe3 fe4 vol iv V_jt mrpk, cuts(1 99) trim
gen      V_jt_w_tr = V_jt_tr*share_sales_jt
replace  V_jt_w_tr = V_jt_w_tr*100


********************************************************************************
************************************************************* Merging GARCh sets
merge m:1  fyear sic_2d using data/compustat_Garch.dta
drop _merge

gen  G_jt_w = G_jt*share_sales_jt


***************************************************** save panel data
sort gvkey fyear
save data/uim_panel.dta, replace






**********************************************************************
**********************************************************************
********************************************************************** V summary
use  data/uim_panel.dta, clear

sum  V_jt_tr

label variable sigma_mu "variance"
label variable stock_price_gr_id "ep"
label variable investment_gr_id_tr "ek"
label variable fundamental_gr_id_tr "ea"
label variable corr_spvsinv_tr "rhopk"
label variable corr_spvsfund_tr "rhopa"
label variable V_jt_tr "\emph{V}"
foreach z in 0 1 2 3 4 5 7 8 9  {
	estpost sum sigma_mu corr_spvsinv_tr corr_spvsfund_tr V_jt_tr if sic_1d==`z', d
	eststo desc_`z'
}
esttab  desc_0 desc_1 desc_2 desc_3 desc_4 desc_5 desc_7 desc_8 desc_9 ///
using FigureTable/desc_ind.tex, replace ///
mtitles(" \textbf{0}" " \textbf{1}" " \textbf{2}" " \textbf{3}" " \textbf{4}" " \textbf{5}" " \textbf{7}" " \textbf{8}" " \textbf{9}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2))  ") ///
lines parentheses ///
label nonumber nogaps 

estpost sum sigma_mu corr_spvsinv_tr corr_spvsfund_tr V_jt_tr, d
eststo deac_v_all
esttab  deac_v_all ///
using FigureTable/desc_v_all.tex, replace ///
mtitles(" \textbf{0}" " \textbf{1}" " \textbf{2}" " \textbf{3}" " \textbf{4}" " \textbf{5}" " \textbf{7}" " \textbf{8}" " \textbf{9}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2)) p5(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p95(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps




drop if V_jt==.
drop if V_jt==0
collapse sale_tr at_tr emp_tr lev_tr strt_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr fe4_tr vol_tr iv_tr V_jt_tr V_jt_w_tr G_jt G_jt_w ///
         sic sic_1d sic_2d sigma investment_gr_id_tr fundamental_gr_id_tr stock_price_gr_id_lag_tr corr_spvsinv_tr corr_spvsfund_tr ratio_corr V_jt , by(sic_3d fyear)
order sic_3d
xtset sic_3d fyear


*===============================
* Generate one table for Table
*===============================

* YEAR FE & INDUSTRY FE & FIRM CONTROL
foreach y in fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr vol_tr iv_tr {
foreach x in V_jt_tr {
qui areg `y' `x' i.fyear, absorb(sic_3d) vce(robust)
qui estadd local YearFE = "Y", replace
est store `y'_`x'
}
}

label variable fdis1_tr "\textbf{\textit{f.d.}1}"
label variable fdis2_tr "\textbf{\textit{f.d.}2}"
label variable fe1_tr "\textbf{\textit{f.e.}1}"
label variable vol_tr "\textbf{Realized stock market vol.}"
label variable iv_tr "\textbf{Options implied vol.}"
label variable G_jt "\textbf{\textit{GARCH}}"
label variable V_jt_tr "\textbf{V}"
label variable fe2_tr "\textbf{\textit{f.e.}2}"
label variable fe3_tr "\textbf{\textit{f.e.}3}"

esttab fdis1_tr_V_jt_tr fe1_tr_V_jt_tr vol_tr_V_jt_tr iv_tr_V_jt_tr ///
using FigureTable/reg_ind.tex, replace ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE N r2 , fmt(%9.0g %9.0g %8.3f) ///
labels("Year FE" Observations R^2 )) t noconstant ///
keep(V_jt_tr) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
 substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{1}{c}{\textbf{Forecast dispersion} }&\multicolumn{1}{c}{\textbf{Forecast error}} ///
                                                           &\multicolumn{1}{c}{\textbf{Realized stock returns volatility}}     &\multicolumn{1}{c}{\textbf{Options-implied volatility}} \\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})


*foreach z in sigma_mu investment_gr_id_tr fundamental_gr_id_tr stock_price_gr_id_lag_tr corr_spvsinv_tr corr_spvsfund_tr ratio_corr V_jt {
*	egen `z'_mean = mean(`z') , by(fyear)

*}



**********************************************************************
**********************************************************************
********************************************************************** MRPK summary
use data/uim_panel.dta, clear



****************************************************************** year $ sic_3d
preserve
collapse (sum) sale_tr (mean) fdis1_tr fe1_tr V_jt_tr vol_tr iv_tr (sd) mrpk_tr, by(fyear sic_3d)

sort fyear sic_3d
xtset fyear sic_3d

gen sales_gr = log(sale_tr/L.sale_tr)
gen ln_sales = log(sale_tr)

foreach y in fdis1 fe1 V_jt vol iv {
foreach x in mrpk  {
qui areg `y'_tr `x'_tr i.fyear, absorb(sic_3d) vce(robust)
qui estadd local YearFE = "Y", replace
qui estadd local IndustryFE = "Y", replace
est store `y'_`x'_YY
}
}

foreach y in mrpk {
foreach x in sales  {
qui areg `y'_tr `x'_gr i.fyear ln_sales, absorb(sic_3d) vce(robust)
est store `y'_`x'_NN
}
}


*===============================
*===============================
esttab  fdis1_mrpk_YY fe1_mrpk_YY V_jt_mrpk_YY vol_mrpk_YY iv_mrpk_YY  ///
using FigureTable/reg_mrpk_sic3d.tex, replace ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE IndustryFE FirmFE N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Industry FE" "Firm FE" Observations R^2 )) t noconstant ///
keep(mrpk_tr ) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
 substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{1}{c}{\textbf{Forecast dispersion} }&\multicolumn{1}{c}{\textbf{Forecast error}} ///
& \multicolumn{1}{c}{\textbf{V} }&\multicolumn{1}{c}{\textbf{Vol}}  &\multicolumn{1}{c}{\textbf{IV}} \\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})


restore
************************************************************** year $ sic_3d end

*************************************************************************** year
gen mrpk_tr1 = mrpk_tr
collapse (sum) sale_tr (mean) fdis1_tr fe1_tr V_jt_tr vol_tr iv_tr mrpk_tr1 (sd) mrpk_tr, by(fyear)

sort fyear
tset fyear
gen year = fyear
merge m:1  year using data/freduse_real.dta  
keep if _merge==3
drop _merge

drop if year < 1976
drop if year > 2014

foreach y in mrpk {
foreach x in usrec gdp_growth_new dgdp ln_rgdp_hp  {
reg `y'_tr `x' i 
est store `y'_`x'
}
}

*===============================
*===============================
esttab  mrpk_dgdp mrpk_ln_rgdp_hp ///
using ./FigureTable/reg_mrpk_agg.tex, replace ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE IndustryFE FirmFE N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Industry FE" "Firm FE" Observations R^2 )) t noconstant ///
keep(dgdp ln_rgdp_hp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
 substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{2}{c}{\textbf{S.D. (MRPK)} }\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})



log close build_panel
