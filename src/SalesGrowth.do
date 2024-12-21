* Set up the environment
clear all
set more off
capture log close
set scheme s1mono
set linesize 200

* Set the working directory (adjust as needed)
global mypath "/Users/tsenga/uim-empirics"

* Load the data
use $mypath/data/uim_panel.dta, clear

*merge m:1 year using $mypath/data/freduse_real.dta
*keep if _merge==3
*drop _merge

drop if gvkey==.
sort gvkey fyear sic
xtset gvkey fyear

** CALCULATE Sale growth
gen sales_gr = ln_sales - l.ln_sales

***************************************** Winsorise growth rates
winsor2 sales_gr, by(year) cut(1 99) trim

label variable fdis1 "\textbf{Fdis_cv}"
label variable fdis2 "\textbf{Fdis_sd}"
label variable fe1 "\textbf{FE_roa}"
label variable fe2 "\textbf{FE_pct}"

***************************************** Sales growth regression
gen unct = .
label variable unct "uncertainty measure "
foreach x in fdis1 fdis2 fe1 fe2 fe3 {
    replace unct = `x'_tr
    qui areg sales_gr unct i.fyear ln_capital age, absorb(gvkey) vce(robust)
    qui estadd local YearFE = "Y", replace
    qui estadd local FirmFE = "Y", replace
    qui estadd local FirmControl = "Y", replace
    est store sales_gr_`x'_YNYY
}
label variable ln_capital "Firm size"
label variable age "Firm age"

esttab sales_gr_fdis1_YNYY sales_gr_fdis2_YNYY sales_gr_fe1_YNYY sales_gr_fe2_YNYY ///
using $mypath/FigureTable/reg_sales_gr.tex, replace ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE FirmFE N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Firm FE" Observations R^2 )) t noconstant ///
keep(unct ln_capital age) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{1}{c}{Fdis_CV}&\multicolumn{1}{c}{Fdis_SD} ///
                                                          &\multicolumn{1}{c}{FE_roa} &\multicolumn{1}{c}{FE_pct} \\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})