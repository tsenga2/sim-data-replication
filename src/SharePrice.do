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

* Winsorize the share price variable
winsor2 prcc_c, cuts(1 99) trim


** get the mean and medean of share price to spilit into the sub-samples (low- & high- share price firms)
egen cutoff_price=mean(prcc_c), by(year)
generate low_price = 0 
replace  low_price = 1 if prcc_c<cutoff_price

***************************************************** Low and High share price subsamples
replace strt_tr = 100*strt_tr
replace fdis1_tr = 100*fdis1_tr
replace fe1_tr = 100*fe1_tr
label variable sale_tr "\textbf{Sales (mil. $\textdollar$)}"
label variable at_tr "\textbf{Total assets (mil. $\textdollar$)}"
label variable emp_tr "\textbf{Employment (thous.)}"
label variable age "\textbf{Age}"
label variable life "\textbf{Years}"
label variable numana "\textbf{Analyst coverage ($\#$)}" 
label variable lev_tr "\textbf{Leverage}" 
label variable strt_tr "\textbf{\textit{ROA}}" 
label variable fdis1_tr "\textbf{Forecast dispersion (C.V.)}"
label variable fdis2_tr "\textbf{Forecast dispersion (S.D.)}"
label variable fe1_tr "\textbf{Forecast error: ROA (pc. deviation)}"
label variable fe2_tr "\textbf{Forecast error: EPS (pc. deviation)}"
label variable fe3_tr "\textbf{Forecast error: EPS (log deviation)}"


estpost sum sale_tr at_tr emp_tr age life numana lev_tr strt_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr if low_price==1, d
eststo low 
estpost sum sale_tr at_tr emp_tr age life numana lev_tr strt_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr if low_price==0, d
eststo high 
esttab  low high ///
using $mypath/FigureTable/desc_sprice_sub.tex, replace ///
mtitles(" \textbf{Low share price}" " \textbf{High share price}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2))  ") ///
lines parentheses ///
label nonumber noobs nogaps




***************************************************** Time series data
********************************************************************************
******************************************************************** Time series
foreach z of varlist fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
	gen `z'_low = .
	gen `z'_high = .
	replace `z'_low = `z'  if low_price==1
	replace `z'_high = `z' if low_price==0
}

sort year

by year: egen num=sum(ind)
by year: egen numest=mean(numana)

foreach z of varlist fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
by year: egen `z'_mean_low=mean(`z'_low)
by year: egen `z'_sdev_low=sd(`z'_low)
by year: egen `z'_skew_low=skew(`z'_low)
by year: egen `z'_kurt_low=kurt(`z'_low)
by year: egen `z'_mean_high=mean(`z'_high)
by year: egen `z'_sdev_high=sd(`z'_high)
by year: egen `z'_skew_high=skew(`z'_high)
by year: egen `z'_kurt_high=kurt(`z'_high)
}

#delimit;
collapse num numest 
         fdis1_tr_mean_low fdis1_tr_sdev_low fdis1_tr_skew_low fdis1_tr_kurt_low 
		 fdis2_tr_mean_low fdis2_tr_sdev_low fdis2_tr_skew_low fdis2_tr_kurt_low 
		 fe1_tr_mean_low fe1_tr_sdev_low fe1_tr_skew_low fe1_tr_kurt_low 
		 fe2_tr_mean_low fe2_tr_sdev_low fe2_tr_skew_low fe2_tr_kurt_low 
		 fe3_tr_mean_low fe3_tr_sdev_low fe3_tr_skew_low fe3_tr_kurt_low
		 fdis1_tr_mean_high fdis1_tr_sdev_high fdis1_tr_skew_high fdis1_tr_kurt_high 
		 fdis2_tr_mean_high fdis2_tr_sdev_high fdis2_tr_skew_high fdis2_tr_kurt_high 
		 fe1_tr_mean_high fe1_tr_sdev_high fe1_tr_skew_high fe1_tr_kurt_high 
		 fe2_tr_mean_high fe2_tr_sdev_high fe2_tr_skew_high fe2_tr_kurt_high 
		 fe3_tr_mean_high fe3_tr_sdev_high fe3_tr_skew_high fe3_tr_kurt_high
		 , by(year);
#delimit cr



tset year, yearly


********************************************************************************
************************************************************Detrend by hp filter
#delimit;
tsfilter hp fdis1_mean_hp_low fdis2_mean_hp_low fe1_mean_hp_low fe2_mean_hp_low fe3_mean_hp_low		    
            fdis1_sdev_hp_low fdis2_sdev_hp_low fe1_sdev_hp_low fe2_sdev_hp_low fe3_sdev_hp_low			
			fdis1_skew_hp_low fdis2_skew_hp_low fe1_skew_hp_low fe2_skew_hp_low fe3_skew_hp_low			
			fdis1_kurt_hp_low fdis2_kurt_hp_low fe1_kurt_hp_low fe2_kurt_hp_low fe3_kurt_hp_low			
			fdis1_mean_hp_high fdis2_mean_hp_high fe1_mean_hp_high fe2_mean_hp_high fe3_mean_hp_high
			fdis1_sdev_hp_high fdis2_sdev_hp_high fe1_sdev_hp_high fe2_sdev_hp_high fe3_sdev_hp_high
			fdis1_skew_hp_high fdis2_skew_hp_high fe1_skew_hp_high fe2_skew_hp_high fe3_skew_hp_high
			fdis1_kurt_hp_high fdis2_kurt_hp_high fe1_kurt_hp_high fe2_kurt_hp_high fe3_kurt_hp_high
			
			= fdis1_tr_mean_low fdis2_tr_mean_low fe1_tr_mean_low fe2_tr_mean_low fe3_tr_mean_low			  
			  fdis1_tr_sdev_low fdis2_tr_sdev_low fe1_tr_sdev_low fe2_tr_sdev_low fe3_tr_sdev_low			  
			  fdis1_tr_skew_low fdis2_tr_skew_low fe1_tr_skew_low fe2_tr_skew_low fe3_tr_skew_low			  
			  fdis1_tr_kurt_low fdis2_tr_kurt_low fe1_tr_kurt_low fe2_tr_kurt_low fe3_tr_kurt_low			  
			  fdis1_tr_mean_high fdis2_tr_mean_high fe1_tr_mean_high fe2_tr_mean_high fe3_tr_mean_high 
			  fdis1_tr_sdev_high fdis2_tr_sdev_high fe1_tr_sdev_high fe2_tr_sdev_high fe3_tr_sdev_high
			  fdis1_tr_skew_high fdis2_tr_skew_high fe1_tr_skew_high fe2_tr_skew_high fe3_tr_skew_high
			  fdis1_tr_kurt_high fdis2_tr_kurt_high fe1_tr_kurt_high fe2_tr_kurt_high fe3_tr_kurt_high
		    , smooth(6.25);

#delimit cr


merge m:1  year using $mypath/data/FRED_Data.dta  
keep if _merge==3
drop _merge
drop if year < 1977

gen low=0
drop if num==.

******************************************************plot time series
* Time series plot 1 
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis1_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast dispersion") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK1mu, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis2_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast dispersion") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK2mu, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe2_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe2_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast error") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK3mu, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe3_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast error") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK4mu, replace);;
#delimit cr

* Time series plot 2
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis1_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast dispersion") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK1sd, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis2_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast dispersion") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK2sd, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe2_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe2_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast error") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK3sd, replace);;
#delimit cr
#delimit;
twoway  (rbar usrec low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe3_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast error") xlabel(1976(9)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK4sd, replace);;
#delimit cr

est clear
********************************************************************************
************************** "Uncertainy is higher during recessions" regression
foreach y in fdis1 fdis2 fe1 fe3 {
foreach z in mean_hp_low sdev_hp_low skew_hp_low mean_hp_high sdev_hp_high skew_hp_high {
qui reg `y'_`z' dgdp
qui estadd ysumm
est store `y'_`z'_dgdp

}
}




*======================================================================
* Generate one table for Table "Uncertainy is higher during recessions" (Appendix)
*======================================================================
label variable fdis1_mean_hp_low  "\textbf{Low share price}"
label variable fe3_mean_hp_low    "\textbf{Low share price}"
label variable fdis1_mean_hp_high "\textbf{High share price}"
label variable fe3_mean_hp_high   "\textbf{High share price}"
label variable fdis1_sdev_hp_low  "\textbf{Low share price}"
label variable fe3_sdev_hp_low    "\textbf{Low share price}"
label variable fdis1_sdev_hp_high "\textbf{High share price}"
label variable fe3_sdev_hp_high   "\textbf{High share price}"
label variable fdis1_skew_hp_low  "\textbf{Low share price}"  
label variable fe3_skew_hp_low    "\textbf{Low share price}"
label variable fdis1_skew_hp_high "\textbf{High share price}" 
label variable fe3_skew_hp_high   "\textbf{High share price}"

label variable dgdp "\textbf{\textit{GDP} growth}"
label variable ln_rgdp_hp "\textbf{log(GDP)}"

*======================================================================
* Generate one table for Table "Uncertainy is higher during recessions" (Appendix: low-high share price)
*======================================================================
esttab fdis1_mean_hp_low_dgdp  fdis1_mean_hp_high_dgdp  fdis1_sdev_hp_low_dgdp  fdis1_sdev_hp_high_dgdp  fdis1_skew_hp_low_dgdp fdis1_skew_hp_high_dgdp ///
using $mypath/FigureTable/reg_MK1.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(dgdp ) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{2}{c}{\textbf{Mean} }& \multicolumn{2}{c}{\textbf{S.D.}}& \multicolumn{2}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})


*======================================================================
* Generate one table for Table "Uncertainy is higher during recessions" (Appendix: low-high share price)
*======================================================================
esttab fe3_mean_hp_low_dgdp fe3_mean_hp_high_dgdp fe3_sdev_hp_low_dgdp fe3_sdev_hp_high_dgdp fe3_skew_hp_low_dgdp fe3_skew_hp_high_dgdp ///
using $mypath/FigureTable/reg_MK2.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(dgdp ) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{2}{c}{\textbf{Mean} }& \multicolumn{2}{c}{\textbf{S.D.}}& \multicolumn{2}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})



******************************************************************************
********************************************************* all figures are here 
set graph on
graph combine MK1mu MK2mu MK3mu MK4mu, title("") graphregion(color(white)) name(comboMK1, replace)
graph export $mypath/FigureTable/comboMK1.png, as(png) replace


graph combine MK1sd MK2sd MK3sd MK4sd, title("") graphregion(color(white)) name(comboMK2, replace)
graph export $mypath/FigureTable/comboMK2.png, as(png) replace
set graph off
