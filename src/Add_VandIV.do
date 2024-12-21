cls
clear all
set graph off

global mypath "/Users/tsenga/uim-replication-Sep2024/uim-empirics"

use $mypath/data/uim_panel.dta, clear

** merge in option implied volatilities
merge m:m cusip8 fyear using $mypath/data/optmtrx31_y.dta
drop _merge
gen iv = iv_mean

** 1.1 Generate sic_3d
gen sic_3d=int(sic/10)

** 1.2 Merge in CPI
merge m:m year using data/freduse_cpi.dta
keep if _merge==3
drop _merge

sort gvkey fyear sic

** 1.3 Deflate sales and ppe
*replace sale = 100*sale/defl
replace ppeg = 100*ppeg/defl
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

** 1.5 Winsorize V_jt and mrpk
winsor2 mrpk V_jt iv, cuts(3 97) trim

** 1.6 Generate summary statistics for V_jt
label variable sigma_mu "variance"
label variable corr_spvsinv_tr "rhopk"
label variable corr_spvsfund_tr "rhopa"
label variable V_jt_tr "\emph{V}"

estpost sum sigma_mu corr_spvsinv_tr corr_spvsfund_tr V_jt_tr, d
eststo deac_v_all
esttab  deac_v_all ///
using $mypath/FigureTable/desc_v_all.tex, replace ///
mtitles(" \textbf{0}" " \textbf{1}" " \textbf{2}" " \textbf{3}" " \textbf{4}" " \textbf{5}" " \textbf{7}" " \textbf{8}" " \textbf{9}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2)) p5(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p95(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps

** 1.7 Save the panel data with V and IV
save $mypath/data/uim_panel.dta, replace

