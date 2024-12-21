cls
clear all
set graph off

global mypath "/Users/tsenga/uim-empirics"

use $mypath/data/uim_panel.dta, clear

* NONE
foreach y in fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
foreach x in vol_tr iv_tr V_jt_tr {
qui regress `y' `x'
qui estadd local YearFE = "N", replace
qui estadd local IndustryFE = "N", replace
qui estadd local FirmFE = "N", replace
qui estadd local FirmControl = "N", replace
est store `y'_`x'_NNNN
}
}


* YEAR FE
foreach y in fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
foreach x in vol_tr iv_tr V_jt_tr {
qui areg `y' `x', absorb(fyear) vce(robust)
qui estadd local YearFE = "Y", replace
qui estadd local IndustryFE = "N", replace
qui estadd local FirmFE = "N", replace
qui estadd local FirmControl = "N", replace
est store `y'_`x'_YNNN
}
}


* YEAR FE & FIRM FE
foreach y in fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
foreach x in vol_tr iv_tr V_jt_tr {
qui areg `y' `x' i.fyear, absorb(gvkey) vce(robust)
qui estadd local YearFE = "Y", replace
qui estadd local IndustryFE = "N", replace
qui estadd local FirmFE = "Y", replace
qui estadd local FirmControl = "N", replace
est store `y'_`x'_YNYN
}
}


* YEAR FE & FIRM FE & FIRM CONTROL
foreach y in fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
foreach x in vol_tr iv_tr V_jt_tr {
qui areg `y' `x' i.fyear ln_sales age, absorb(gvkey) vce(robust)
qui estadd local YearFE = "Y", replace
qui estadd local IndustryFE = "N", replace
qui estadd local FirmFE = "Y", replace
qui estadd local FirmControl = "Y", replace
est store `y'_`x'_YNYY
}
}


* YEAR FE & INDUSTRY FE & FIRM CONTROL
foreach y in fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
foreach x in vol_tr iv_tr V_jt_tr {
qui areg `y' `x' i.fyear ln_sales age, absorb(sic) vce(robust)
qui estadd local YearFE = "Y", replace
qui estadd local IndustryFE = "Y", replace
qui estadd local FirmFE = "N", replace
qui estadd local FirmControl = "Y", replace
est store `y'_`x'_YYNY
}
}

********************************************************************************
********************************************************************************



*===============================
* Generate one table for Table 01 (T3 notes)
*===============================
label variable fdis1_tr "\textbf{\textit{f.d.}1}"
label variable fdis2_tr "\textbf{\textit{f.d.}2}"
label variable fe1_tr "\textbf{\textit{f.e.}1}"
label variable vol_tr "\textbf{Realized stock market vol.}"
label variable iv_tr "\textbf{Options implied vol.}"
label variable V_jt_tr "\textbf{V}"
label variable fe2_tr "\textbf{\textit{f.e.}2}"
label variable fe3_tr "\textbf{\textit{f.e.}3}"

esttab fdis1_tr_vol_tr_YYNY  fdis1_tr_iv_tr_YYNY fdis1_tr_vol_tr_YNYY  fdis1_tr_iv_tr_YNYY ///
       fe3_tr_vol_tr_YYNY    fe3_tr_iv_tr_YYNY   fe3_tr_vol_tr_YNYY    fe3_tr_iv_tr_YNYY   ///
using $mypath/FigureTable/reg_T01.tex, replace ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE IndustryFE FirmFE N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Industry FE" "Firm FE" Observations R^2 )) t noconstant ///
keep(vol_tr iv_tr) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
 substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{4}{c}{\textbf{Forecast dispersion} }&\multicolumn{4}{c}{\textbf{Forecast error}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})


*===============================
* Generate one table for Table 02 (T4 notes)
*===============================
esttab fdis1_tr_V_jt_tr_NNNN fdis1_tr_V_jt_tr_YNNN fdis1_tr_V_jt_tr_YNYN fdis1_tr_V_jt_tr_YNYY   ///
       fe3_tr_V_jt_tr_NNNN   fe3_tr_V_jt_tr_YNNN   fe3_tr_V_jt_tr_YNYN   fe3_tr_V_jt_tr_YNYY   ///
using $mypath/FigureTable/reg_T02.tex, replace ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE IndustryFE FirmFE FirmControl N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Industry FE" "Firm FE" "Firm Control" Observations R^2 )) t noconstant ///
keep(V_jt_tr) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
 substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{4}{c}{\textbf{Forecast dispersion} } & \multicolumn{4}{c}{\textbf{Forecast error} }\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})


*===============================
* Generate one table for Table 03 (AT1 notes)
*===============================
esttab fdis1_tr_vol_tr_YYNY fdis1_tr_iv_tr_YYNY ///
	   fdis1_tr_vol_tr_YNYY fdis1_tr_iv_tr_YNYY ///
	   fdis2_tr_vol_tr_YYNY fdis2_tr_iv_tr_YYNY ///
	   fdis2_tr_vol_tr_YNYY fdis2_tr_iv_tr_YNYY ///
using $mypath/FigureTable/reg_T03.tex, replace ///
tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE IndustryFE FirmFE N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Industry FE" "Firm FE" Observations R^2 )) t noconstant ///
keep(vol_tr iv_tr) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
 substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{4}{c}{\textbf{Forecast dispersion (C.V.)} }&\multicolumn{4}{c}{\textbf{Forecast dispersion (S.D.)}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})
