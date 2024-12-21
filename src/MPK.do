cls
clear all
set graph off

global mypath "/Users/tsenga/uim-empirics"

use $mypath/data/uim_panel.dta, clear


*===============================
* Generate one table for MPK
*===============================
collapse (sum) sale_tr (mean) fdis1_tr fe1_tr V_jt_tr vol_tr iv_tr (sd) mrpk_tr, by(fyear sic_3d)

label variable mrpk_tr "\textbf{SD(MPK)}"

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


esttab  fdis1_mrpk_YY fe1_mrpk_YY V_jt_mrpk_YY vol_mrpk_YY iv_mrpk_YY  ///
using $mypath/FigureTable/reg_mrpk_sic3d.tex, replace ///
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









