cls
clear all
set graph off

global mypath "/Users/tsenga/uim-replication-Sep2024/uim-empirics"

use $mypath/data/uim_tseries.dta, clear


*replace recession=0.25 if year==2020
gen low=0

* Time series plot 1 
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_mean_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Mean Forecast Dispersion") xlabel(1976(9)2022) legend(off) xtitle("") graphregion(color(white))  ytitle("GDP Growth") ytitle("",axis(2)) name(fdis1_mean_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_sdev_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "S.D. Forecast Dispersion") xlabel(1976(9)2022) legend(off) xtitle("") graphregion(color(white))  ytitle("GDP Growth") ytitle("",axis(2)) name(fdis1_sdev_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_mean_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Mean Forecast Error") xlabel(1976(9)2022) legend(off) xtitle("") graphregion(color(white))  ytitle("GDP Growth") ytitle("",axis(2)) name(fe3_mean_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_sdev_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "S.D. Forecast Error") xlabel(1976(9)2022) legend(off) xtitle("") graphregion(color(white))  ytitle("GDP Growth") ytitle("",axis(2)) name(fe3_sdev_hp, replace);;
#delimit cr

#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_skew_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Skewness Forecast Dispersion") xlabel(1976(9)2022) legend(off) xtitle("") graphregion(color(white))  ytitle("GDP Growth") ytitle("",axis(2)) name(fdis1_skew_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_skew_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Skewness Forecast Error") xlabel(1976(9)2022) legend(off) xtitle("") graphregion(color(white))  ytitle("GDP Growth") ytitle("",axis(2)) name(fe3_skew_hp, replace);;
#delimit cr


set graph on
graph combine fdis1_mean_hp fe3_mean_hp fdis1_sdev_hp fe3_sdev_hp fdis1_skew_hp fe3_skew_hp, rows(3) cols(2) title("") graphregion(color(white)) name(combo_TS_skew, replace)
graph export $mypath/FigureTable/combo_TS-skew.png, as(png) replace




********************************************************************************
************************** "Uncertainy is higher during recessions" regression 1
foreach y in fdis1 fe3 {
foreach z in mean_hp sdev_hp skew_hp {
qui reg `y'_`z' dgdp
qui estadd ysumm
est store `y'_`z'_dgdp

}
}

********************************************************************************
************************** "Uncertainty is higher during recessions" regression 2
foreach y in fdis1 fe3 {
foreach z in mean_hp sdev_hp skew_hp {
qui reg `y'_`z' ln_rgdp_hp
qui estadd ysumm
est store `y'_`z'_ln_rgdp_hp

}
}

label variable fdis1_mean_hp "\textbf{Forecast dispersion}"
label variable fe3_mean_hp "\textbf{Forecast error}"

label variable fdis1_sdev_hp "\textbf{Forecast dispersion}"
label variable fe3_sdev_hp "\textbf{Forecast error}"

label variable fdis1_skew_hp "\textbf{Forecast dispersion}"
label variable fe3_skew_hp "\textbf{Forecast error}"

label variable dgdp "\textbf{\textit{GDP} growth}"
label variable ln_rgdp_hp "\textbf{log(GDP)}"
label variable usrec "\textbf{Recession}"

*======================================================================
* Generate one table for Table "Uncertainy is higher during recessions"
*======================================================================
esttab fdis1_mean_hp_dgdp  fe3_mean_hp_dgdp ///
       fdis1_sdev_hp_dgdp  fe3_sdev_hp_dgdp ///
       fdis1_skew_hp_dgdp  fe3_skew_hp_dgdp ///
using $mypath/FigureTable/reg_ts1.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(dgdp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{2}{c}{\textbf{Mean} }& \multicolumn{2}{c}{\textbf{S.D.}}& \multicolumn{2}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})


esttab fdis1_mean_hp_ln_rgdp_hp  fe3_mean_hp_ln_rgdp_hp ///
       fdis1_sdev_hp_ln_rgdp_hp  fe3_sdev_hp_ln_rgdp_hp ///
       fdis1_skew_hp_ln_rgdp_hp  fe3_skew_hp_ln_rgdp_hp ///
using $mypath/FigureTable/reg_ts2.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(ln_rgdp_hp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{2}{c}{\textbf{Mean} }& \multicolumn{2}{c}{\textbf{S.D.}}& \multicolumn{2}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})
