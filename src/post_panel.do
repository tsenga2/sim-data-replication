****23/08/2023: revision work for ECMA in Tokyo
****18/06/2018: revision work for ECMA in QMUL - final batch

****12/05/2018: revision work for ECMA in Barbican after E1Macro
****27/03/2018: revision work for ECMA in QMUL after the RES conference

****24/03/2018: revision work for ECMA in QMUL
****             - this re-considers stadard deviation and coefficiant variation of fdis and fe

****10/03/2018: revision work for ECMA in Nice --- hyappon knock

set matsize 1000

cls
clear all
set more off
set graphics off


log using log/post_panel.log, name(post_panel) replace


*****************************************************************************************************************************
* EAXMPLE
*use http://www.stata-press.codata/r13/auto2,clear

*regress mpg weight gear_ratio rep78
*regress mpg weight gear_ratio b5.rep78
*areg    mpg weight gear_ratio, absorb(rep78)
*areg    mpg weight gear_ratio, absorb(rep78) vce(r)
*areg    mpg weight gear_ratio, absorb(rep78) vce(cl rep78)
*areg    mpg weight gear_ratio, absorb(rep78) cluster(rep78)


*****************************************************************************************************************************
use data/uim_panel.dta, clear



* NONE
foreach y in fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
foreach x in vol_tr iv_tr V_jt_tr G_jt {
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
foreach x in vol_tr iv_tr V_jt_tr G_jt {
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
foreach x in vol_tr iv_tr V_jt_tr G_jt {
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
foreach x in vol_tr iv_tr V_jt_tr G_jt {
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
foreach x in vol_tr iv_tr V_jt_tr G_jt {
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
label variable G_jt "\textbf{\textit{GARCH}}"
label variable V_jt_tr "\textbf{V}"
label variable fe2_tr "\textbf{\textit{f.e.}2}"
label variable fe3_tr "\textbf{\textit{f.e.}3}"

esttab fdis1_tr_vol_tr_YYNY  fdis1_tr_iv_tr_YYNY fdis1_tr_vol_tr_YNYY  fdis1_tr_iv_tr_YNYY ///
       fe3_tr_vol_tr_YYNY    fe3_tr_iv_tr_YYNY   fe3_tr_vol_tr_YNYY    fe3_tr_iv_tr_YNYY   ///
using FigureTable/reg_T01.tex, replace ///
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
using FigureTable/reg_T02.tex, replace ///
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
using FigureTable/reg_T03.tex, replace ///
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




*===============================
* Generate one table for Table 04 (AT2 notes)
*===============================
esttab fe2_tr_vol_tr_YYNY fe2_tr_iv_tr_YYNY ///
	   fe2_tr_vol_tr_YNYY fe2_tr_iv_tr_YNYY ///
	   fe3_tr_vol_tr_YYNY fe3_tr_iv_tr_YYNY ///
	   fe3_tr_vol_tr_YNYY fe3_tr_iv_tr_YNYY ///
using FigureTable/reg_T04.tex, replace ///
tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE IndustryFE FirmFE N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Industry FE" "Firm FE" Observations R^2 )) t noconstant ///
keep(vol_tr iv_tr) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
 substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{4}{c}{\textbf{FE: log deviation} }& \multicolumn{4}{c}{\textbf{FE: percentage deviation} } \\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})





********************************************************************************
********************************************************************************
preserve
** get the mean and medean of fe1_tr (or fdis1_tr) to spilit into the sub-samples (low- & high- uncertainty firms)
egen cutoff_mean=mean(fdis1_tr), by(fyear)
generate lowdummy = 0 
replace  lowdummy = 1 if fdis1_tr<cutoff_mean


****************************************************** save at descriptive stats (T1)
replace strt_tr = 100*strt_tr
replace fdis1_tr = 100*fdis1_tr
replace fdis2_tr = 100*fdis2_tr
replace fe1_tr = 100*fe1_tr
replace fe2_tr = 100*fe2_tr
replace fe3_tr = 100*fe3_tr
replace fe4_tr = 100*fe4_tr
label variable sale_tr "\textbf{Sales (mil. $\textdollar$)}"
label variable at_tr "\textbf{Total assets (mil. $\textdollar$)}"
label variable emp_tr "\textbf{Employment (thous.)}"
label variable age "\textbf{Age}"
label variable life "\textbf{Years}"
label variable numana "\textbf{Analyst coverage ($\#$)}" 
label variable lev_tr "\textbf{Leverage}" 
label variable strt_tr "\textbf{ROA}	" 
label variable fdis1_tr "\textbf{Fdis_cv}"
label variable fdis2_tr "\textbf{Fdis_sd}"
label variable fe1_tr "\textbf{FE_roa}"
label variable fe2_tr "\textbf{FE_pct}"

estpost sum sale_tr at_tr emp_tr age life numana lev_tr strt_tr fdis1_tr fdis2_tr fe2_tr fe1_tr, d
est store all
esttab all ///
using FigureTable/desc_all.tex, replace ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2)) p5(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p95(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps


***************************************************** uncertainty measures summary stats
label variable fdis1_tr "\textbf{Fdis_cv}"
label variable fdis2_tr "\textbf{Fdis_sd}"
label variable fe1_tr "\textbf{FE_roa}"
label variable fe2_tr "\textbf{FE_pct}"
label variable fe3_tr "\textbf{FE_log}"
label variable fe4_tr "\textbf{FE_sqr}"

estpost sum fdis1_tr fdis2_tr fe2_tr fe3_tr fe1_tr fe4_tr, d
est store all
esttab all ///
using FigureTable/desc_unct.tex, replace ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2)) p5(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p95(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps


***************************************************** Low and High uncertainty subsamples
estpost sum sale_tr at_tr emp_tr age life numana lev_tr  if (lowdummy==1 & fyear==2012), d
eststo low 
estpost sum sale_tr at_tr emp_tr age life numana lev_tr  if (lowdummy==0 & fyear==2012), d
eststo high 
esttab  low high ///
using FigureTable/desc_both_sub.tex, replace ///
mtitles(" \textbf{Low}" " \textbf{High}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2))  ") ///
lines parentheses ///
label nonumber noobs nogaps 


restore
*preserve



********************************************************************************
************************************** plot distributions of umcertainty proxies
winsor2 lndis1 lndis2 lnfe1 lnfe3, cuts(1 99) trim
#delimit;
twoway (kdensity lndis1_tr if year==2007, lcolor(red) lwidth(medthick) lpattern(dash)) 
       (kdensity lndis1_tr if year==2008, lcolor(black) lwidth(medthick) lpattern(solid))
       (kdensity lndis1_tr if year==2009, lcolor(blue) lwidth(medthick) lpattern(longdash_dot)), 
        legend(on order(1 "2007" 2 "2008" 3 "2009") cols(1) position(1) ring(0)) title(Forecast dispersion) xtitle("") graphregion(color(white))  ytitle("") name(F1, replace);
#delimit cr
#delimit;
twoway (kdensity lnfe1_tr if year==2007, lcolor(red) lwidth(medthick) lpattern(dash)) 
       (kdensity lnfe1_tr if year==2008, lcolor(black) lwidth(medthick) lpattern(solid))
       (kdensity lnfe1_tr if year==2009, lcolor(blue) lwidth(medthick) lpattern(longdash_dot)),
        legend(on order(1 "2007" 2 "2008" 3 "2009") cols(1) position(1) ring(0)) title(Forecast error) xtitle("") graphregion(color(white))  ytitle("") name(F2, replace);
#delimit cr
#delimit;
twoway (kdensity lnfe1_tr if year==2007, lcolor(red) lwidth(medthick) lpattern(dash)) 
       (kdensity lnfe1_tr if year==2008, lcolor(black) lwidth(medthick) lpattern(solid))
       (kdensity lnfe1_tr if year==2009, lcolor(blue) lwidth(medthick) lpattern(longdash_dot)),
        legend(on order(1 "2007" 2 "2008" 3 "2009") cols(1) position(1) ring(0)) title(Forecast error) xtitle("") graphregion(color(white))  ytitle("") name(F3, replace);
#delimit cr


********************************************************************************
*********************************************************************time series
sort year

by year: egen num=sum(ind)
by year: egen numest=mean(numana)

foreach z of varlist strt_tr vol_tr iv_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr V_jt_w_tr G_jt_w mrpk_tr {
by year: egen `z'_mean=mean(`z')
by year: egen `z'_sdev=sd(`z')
by year: egen `z'_skew=skew(`z')
by year: egen `z'_kurt=kurt(`z')
}

#delimit;
collapse num numest 
         strt_tr_mean  strt_tr_sdev  strt_tr_skew  strt_tr_kurt  vol_tr_mean   vol_tr_sdev   vol_tr_skew   vol_tr_kurt 
         iv_tr_mean    iv_tr_sdev    iv_tr_skew    iv_tr_kurt    fdis1_tr_mean fdis1_tr_sdev fdis1_tr_skew fdis1_tr_kurt 
		 fdis2_tr_mean fdis2_tr_sdev fdis2_tr_skew fdis2_tr_kurt fe1_tr_mean   fe1_tr_sdev   fe1_tr_skew   fe1_tr_kurt 
		 fe2_tr_mean   fe2_tr_sdev   fe2_tr_skew   fe2_tr_kurt 
		 fe3_tr_mean   fe3_tr_sdev   fe3_tr_skew   fe3_tr_kurt   V_jt_w_tr_mean V_jt_w_tr_sdev V_jt_w_tr_skew V_jt_w_tr_kurt 
		 G_jt_w_mean   G_jt_w_sdev   G_jt_w_skew   G_jt_w_kurt   mrpk_tr_mean   mrpk_tr_sdev   mrpk_tr_skew   mrpk_tr_kurt
		 , by(year);
#delimit cr


*rename fyear year
tset year, yearly


********************************************************************************
************************************************************Detrend by hp filter
#delimit;
tsfilter hp iv_mean_hp 
            iv_sdev_hp 
			iv_skew_hp 
			iv_kurt_hp
			
			= iv_tr_mean 
			  iv_tr_sdev 
			  iv_tr_skew 
			  iv_tr_kurt
			  
		    , smooth(6.25);

#delimit cr

#delimit;
tsfilter hp strt_mean_hp vol_mean_hp fdis1_mean_hp fdis2_mean_hp fe1_mean_hp fe2_mean_hp fe3_mean_hp V_jt_w_mean_hp G_jt_w_mean_hp
            strt_sdev_hp vol_sdev_hp fdis1_sdev_hp fdis2_sdev_hp fe1_sdev_hp fe2_sdev_hp fe3_sdev_hp V_jt_w_sdev_hp G_jt_w_sdev_hp
			strt_skew_hp vol_skew_hp fdis1_skew_hp fdis2_skew_hp fe1_skew_hp fe2_skew_hp fe3_skew_hp V_jt_w_skew_hp G_jt_w_skew_hp
			strt_kurt_hp vol_kurt_hp fdis1_kurt_hp fdis2_kurt_hp fe1_kurt_hp fe2_kurt_hp fe3_kurt_hp V_jt_w_kurt_hp G_jt_w_kurt_hp mrpk_mean_hp mrpk_sdev_hp mrpk_skew_hp mrpk_kurt_hp
			
			= strt_tr_mean vol_tr_mean fdis1_tr_mean fdis2_tr_mean fe1_tr_mean fe2_tr_mean fe3_tr_mean V_jt_w_tr_mean G_jt_w_mean
			  strt_tr_sdev vol_tr_sdev fdis1_tr_sdev fdis2_tr_sdev fe1_tr_sdev fe2_tr_sdev fe3_tr_sdev V_jt_w_tr_sdev G_jt_w_sdev
			  strt_tr_skew vol_tr_skew fdis1_tr_skew fdis2_tr_skew fe1_tr_skew fe2_tr_skew fe3_tr_skew V_jt_w_tr_skew G_jt_w_skew
			  strt_tr_kurt vol_tr_kurt fdis1_tr_kurt fdis2_tr_kurt fe1_tr_kurt fe2_tr_kurt fe3_tr_kurt V_jt_w_tr_kurt G_jt_w_kurt mrpk_tr_mean mrpk_tr_sdev mrpk_tr_skew mrpk_tr_kurt
			   
		    , smooth(6.25);

#delimit cr
			
merge m:1  year using data/freduse_real.dta  
keep if _merge==3
drop _merge
drop if year < 1977



********************************************************************************
************************************************ merge with macro, Nick and Rudi
*gen year=year

merge m:1 year  using data/data_table1_census
drop _merge

merge m:m year  using data/data_bachmanetal
drop _merge
gen low=0



******************************************************************* Nick's part
tsset year
gen census=(year==1972|year==1977|year==1982|year==1987|year==1992|year==1997|year==2002|year==2007)
gen f1_census=f1.census
replace f1_census=0 if year==2009 

* Detrend and remove census spikes iqr_e_ltfp_25y
reg iqr_e_ltfp_25y year census
predict det_iqr_e_ltfp_25y , r
su iqr_e_ltfp_25y 
replace det_iqr_e_ltfp_25y =det_iqr_e_ltfp_25y +r(mean)

*** This is smoothing the huge spike of 1996, which is generated by the big change from SIC to NAICS in 1997 (our measure are always t to t+1)
label var det_iqr_e_ltfp_25y "iqr(tfp shock)"


*********************************************************************
*****************************************************plot time series
drop if num==.
* Time series plot 1 
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_mean_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Mean forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("mean",axis(2)) name(fdis1_mean_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_sdev_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "S.D. forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("s.d.",axis(2)) name(fdis1_sdev_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe1_mean_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Mean of forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("mean",axis(2)) name(fe1_mean_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe1_sdev_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "SD of forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("s.d.",axis(2)) name(fe1_sdev_hp, replace);;
#delimit cr

* Time series plot 3 
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_mean_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Mean of forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("g.d.p. growth") ytitle("mean",axis(2)) name(fdis2_mean_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_sdev_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "s.d. of forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("g.d.p. growth") ytitle("s.d.",axis(2)) name(fdis2_sdev_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_mean_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Mean forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("g.d.p. growth") ytitle("mean",axis(2)) name(fe3_mean_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_sdev_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "S.D. forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("g.d.p. growth") ytitle("s.d.",axis(2)) name(fe3_sdev_hp, replace);
#delimit cr

#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))        
        (scatter mrpk_mean_hp year, c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Mean mrpk") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("g.d.p. growth") ytitle("mean",axis(2)) name(mrpk_mean_hp, replace);
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter mrpk_sdev_hp year, c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "S.D. mrpk") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("g.d.p. growth") ytitle("s.d.",axis(2)) name(mrpk_sdev_hp, replace);
#delimit cr

#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_skew_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Skewness forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("skewness",axis(2)) name(fdis1_skew_hp, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe1_skew_hp year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "Skewness forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("skewness",axis(2)) name(fe1_skew_hp, replace);;
#delimit cr


********************************************************************************
************************** "Uncertainy is higher during recessions" regression 1
foreach y in fdis1 fdis2 fe1 fe3 V_jt_w mrpk {
foreach z in tr_mean tr_sdev tr_skew mean_hp sdev_hp skew_hp {
qui reg `y'_`z' recession
qui estadd ysumm
est store `y'_`z'_rec

}
}

********************************************************************************
************************** "Uncertainy is higher during recessions" regression 2
foreach y in fdis1 fdis2 fe1 fe3 V_jt_w mrpk {
foreach z in tr_mean tr_sdev tr_skew mean_hp sdev_hp skew_hp {
qui reg `y'_`z' dgdp
qui estadd ysumm
est store `y'_`z'_dgdp

}
}

********************************************************************************
************************** "Uncertainy is higher during recessions" regression 3
foreach y in fdis1 fdis2 fe1 fe3 V_jt_w mrpk {
foreach z in tr_mean tr_sdev tr_skew mean_hp sdev_hp skew_hp {
qui reg `y'_`z' ln_rgdp_hp
qui estadd ysumm
est store `y'_`z'_ln_rgdp_hp

}
}

label variable fdis1_mean_hp "\textbf{Forecast dispersion}"
label variable fdis2_mean_hp "\textbf{Forecast dispersion}"
label variable fe1_mean_hp "\textbf{Forecast error}"
label variable fe2_mean_hp "\textbf{Forecast error}"
label variable fe3_mean_hp "\textbf{Forecast error}"
label variable vol_mean_hp "\textbf{Realized stock market vol.}"
label variable iv_mean_hp "\textbf{Option-implied vol.}"

label variable fdis1_sdev_hp "\textbf{Forecast dispersion}"
label variable fdis2_sdev_hp "\textbf{\textit{f.d.}2}"
label variable fe1_sdev_hp "\textbf{\textit{f.e.}1}"
label variable fe2_sdev_hp "\textbf{\textit{f.e.}2}"
label variable fe3_sdev_hp "\textbf{Forecast error}"

label variable fdis1_skew_hp "\textbf{Forecast dispersion}"
label variable fdis2_skew_hp "\textbf{\textit{f.d.}2}"
label variable fe1_skew_hp "\textbf{\textit{f.e.}1}"
label variable fe2_skew_hp "\textbf{\textit{f.e.}2}"
label variable fe3_skew_hp "\textbf{Forecast error}"

label variable V_jt_w_mean_hp "\textbf{V}"
label variable V_jt_w_sdev_hp "\textbf{V}"
label variable V_jt_w_skew_hp "\textbf{V}"

label variable mrpk_mean_hp "\textbf{mrpk}"
label variable mrpk_sdev_hp "\textbf{mrpk}"
label variable mrpk_skew_hp "\textbf{mrpk}"
label variable mrpk_tr_mean "\textbf{mrpk}"
label variable mrpk_tr_sdev "\textbf{mrpk}"
label variable mrpk_tr_skew "\textbf{mrpk}"

label variable G_jt_w_mean_hp "\textbf{GARCH}"

label variable dgdp "\textbf{\textit{GDP} growth}"
label variable ln_rgdp_hp "\textbf{log(GDP)}"
label variable recession "\textbf{Recession}"

*======================================================================
* Generate one table for Table "Uncertainy is higher during recessions" (T5)
*======================================================================
esttab fdis1_mean_hp_dgdp  fe3_mean_hp_dgdp ///
	   fdis1_sdev_hp_dgdp  fe3_sdev_hp_dgdp ///
	   fdis1_skew_hp_dgdp  fe3_skew_hp_dgdp ///
using FigureTable/reg_ts1.tex, replace  ///
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
using FigureTable/reg_ts2.tex, replace  ///
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


esttab fdis1_mean_hp_rec  fe3_mean_hp_rec ///
	   fdis1_sdev_hp_rec  fe3_sdev_hp_rec ///
	   fdis1_skew_hp_rec  fe3_skew_hp_rec ///
using FigureTable/reg_ts3.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(recession) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{2}{c}{\textbf{Mean} }& \multicolumn{2}{c}{\textbf{S.D.}}& \multicolumn{2}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})



*======================================================================
esttab V_jt_w_mean_hp_dgdp  V_jt_w_mean_hp_ln_rgdp_hp /// 
       V_jt_w_sdev_hp_dgdp  V_jt_w_sdev_hp_ln_rgdp_hp ///
	   V_jt_w_skew_hp_dgdp  V_jt_w_skew_hp_ln_rgdp_hp ///
        ///
using FigureTable/reg_ts_v.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(dgdp ln_rgdp_hp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{2}{c}{\textbf{Mean} }& \multicolumn{2}{c}{\textbf{S.D.}}& \multicolumn{2}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})





*======================================================================
esttab mrpk_mean_hp_rec  mrpk_tr_mean_ln_rgdp_hp mrpk_tr_mean_dgdp /// 
       mrpk_sdev_hp_rec  mrpk_tr_sdev_ln_rgdp_hp mrpk_tr_sdev_dgdp ///
	   mrpk_skew_hp_rec  mrpk_tr_skew_ln_rgdp_hp mrpk_tr_skew_dgdp ///
using FigureTable/reg_ts_mrpk.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(recession ln_rgdp_hp dgdp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{3}{c}{\textbf{Mean} }& \multicolumn{3}{c}{\textbf{S.D.}}& \multicolumn{3}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})




*******************************************************************************
*************************************************************correlation matrix
label variable fdis1_mean_hp "\textbf{Mean}"
label variable fdis2_mean_hp "\textbf{Mean}"
label variable fe1_mean_hp "\textbf{Mean}"
label variable fe2_mean_hp "\textbf{Mean}"
label variable fe3_mean_hp "\textbf{Mean}"

label variable fdis1_sdev_hp "\textbf{S.D.}"
label variable fdis2_sdev_hp "\textbf{S.D.}"
label variable fe1_sdev_hp "\textbf{S.D.}"
label variable fe2_sdev_hp "\textbf{S.D.}"
label variable fe3_sdev_hp "\textbf{S.D.}"

label variable fdis1_skew_hp "\textbf{Skewness}"
label variable fdis2_skew_hp "\textbf{Skewness}"
label variable fe1_skew_hp "\textbf{Skewness}"
label variable fe2_skew_hp "\textbf{Skewness}"
label variable fe3_skew_hp "\textbf{Skewness}"

label variable fdis1_kurt_hp "\textbf{kurtsis}"
label variable fdis2_kurt_hp "\textbf{kurtsis}"
label variable fe1_kurt_hp "\textbf{kurtsis}"
label variable fe2_kurt_hp "\textbf{kurtsis}"
label variable fe3_kurt_hp "\textbf{kurtsis}"



foreach z in strt vol iv fdis1 fdis2 fe1 fe2 fe3 {
estpost corr  `z'_mean_hp `z'_sdev_hp `z'_skew_hp `z'_kurt_hp ln_rgdp_hp dgdp, matrix
est store `z'
esttab `z' ///
using FigureTable/corrmat_`z'_hp.tex, ///
label not unstack  noobs replace  ///
nonote nomtitle nonumber lines parentheses ///
addnotes("Notes: TBA") ///
legend noabbrev style(tex) ///
star(* 0.10 ** 0.05 *** 0.01) nogaps
}





******************************************************************************
*********************************************************** save the file here
save data/uim_tseries.dta, replace
use data/uim_tseries.dta, clear




********************************************************************************
***********************   predictive power of future economic activities (macro)
foreach y in dgdp ln_rgdp_hp gdp_growth_new {
foreach z in fdis1 fdis2 fe1 fe2 fe3 vol iv G_jt_w V_jt_w {
qui reg `y' `z'_mean_hp L.`y' L2.`y'
qui estadd beta, replace
est store `y'_`z'_t

}
}

foreach y in dgdp ln_rgdp_hp gdp_growth_new {
foreach z in fdis1 fdis2 fe1 fe2 fe3 vol iv G_jt_w V_jt_w {
qui reg F.`y' `z'_mean_hp L.`y' L2.`y'
qui estadd beta, replace
est store `y'_`z'_t1

}
}

foreach y in dgdp ln_rgdp_hp gdp_growth_new {
foreach z in fdis1 fdis2 fe1 fe2 fe3 vol iv G_jt_w V_jt_w {
qui reg F2.`y' `z'_mean_hp L.`y' L2.`y'
qui estadd beta, replace
est store `y'_`z'_t2

}
}




*======================================================================
* Generate one table for Table "Uncertainy and Economic Activity" lngdp
*======================================================================
esttab ln_rgdp_hp_fdis1_t  ln_rgdp_hp_fe3_t  ln_rgdp_hp_vol_t  ln_rgdp_hp_iv_t  ln_rgdp_hp_G_jt_w_t  ln_rgdp_hp_V_jt_w_t  /// 
       ln_rgdp_hp_fdis1_t1 ln_rgdp_hp_fe3_t1 ln_rgdp_hp_vol_t1 ln_rgdp_hp_iv_t1 ln_rgdp_hp_G_jt_w_t1 ln_rgdp_hp_V_jt_w_t1 ///
using FigureTable/reg_forecast_lngdp.tex, replace  ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(fdis1_mean_hp fe3_mean_hp vol_mean_hp iv_mean_hp G_jt_w_mean_hp V_jt_w_mean_hp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{5}{c}{\textbf{Current year} } & \multicolumn{5}{c}{\textbf{Next year} }\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})

*======================================================================
* Generate one table for Table "Uncertainy and Economic Activity" lngdp
*======================================================================
esttab dgdp_fdis1_t  dgdp_fe3_t  dgdp_vol_t  dgdp_iv_t  dgdp_G_jt_w_t  dgdp_V_jt_w_t ///
       dgdp_fdis1_t1 dgdp_fe3_t1 dgdp_vol_t1 dgdp_iv_t1 dgdp_G_jt_w_t1 dgdp_V_jt_w_t1 ///
using FigureTable/reg_forecast_dgdp.tex, replace  ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(fdis1_mean_hp fe3_mean_hp vol_mean_hp iv_mean_hp G_jt_w_mean_hp V_jt_w_mean_hp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{5}{c}{\textbf{Current year} } & \multicolumn{5}{c}{\textbf{Next year} }\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})




******************************************************************************
********************************************************* all figures are here 
set graph on
graph combine F1 F2, cols(1) title("") graphregion(color(white)) name(combo_GR, replace)
graph export FigureTable/combo_GR.png, as(png) replace


graph combine fdis1_mean_hp fdis1_sdev_hp fe3_mean_hp fe3_sdev_hp, title("") graphregion(color(white)) name(combo_TS, replace)
graph export FigureTable/combo_TS.png, as(png) replace

graph combine fdis1_mean_hp fe1_mean_hp fdis1_sdev_hp fe1_sdev_hp fdis1_skew_hp fe1_skew_hp, rows(3) cols(2) title("") graphregion(color(white)) name(combo_TS_skew, replace)
graph export FigureTable/combo_TS-skew.png, as(png) replace

graph combine mrpk_mean_hp mrpk_sdev_hp , title("") graphregion(color(white)) name(combo_TS_a, replace)
graph export FigureTable/combo_TS-a.png, as(png) replace
set graph off





********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************* share price robustness

use data/uim_panel.dta, clear

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
using FigureTable/desc_sprice_sub.tex, replace ///
mtitles(" \textbf{Low share price}" " \textbf{High share price}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2))  ") ///
lines parentheses ///
label nonumber noobs nogaps



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
			
merge m:1  year using data/freduse_real.dta  
keep if _merge==3
drop _merge
drop if year < 1977


********************************************************************************
************************************************ merge with macro, Nick and Rudi
*gen year=year 

merge m:1 year  using data/data_table1_census
drop _merge

merge m:m year  using data/data_bachmanetal
drop _merge
gen low=0



******************************************************************* Nick's part
tsset year
gen census=(year==1972|year==1977|year==1982|year==1987|year==1992|year==1997|year==2002|year==2007)
gen f1_census=f1.census
replace f1_census=0 if year==2009 

* Detrend and remove census spikes iqr_e_ltfp_25y
reg iqr_e_ltfp_25y year census
predict det_iqr_e_ltfp_25y , r
su iqr_e_ltfp_25y 
replace det_iqr_e_ltfp_25y =det_iqr_e_ltfp_25y +r(mean)

*** This is smoothing the huge spike of 1996, which is generated by the big change from SIC to NAICS in 1997 (our measure are always t to t+1)
label var det_iqr_e_ltfp_25y "iqr(tfp shock)"

*********************************************************************
*****************************************************plot time series
drop if num==.

* Time series plot 1 
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis1_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK1mu, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis2_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK2mu, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe2_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe2_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK3mu, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe3_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK4mu, replace);;
#delimit cr

* Time series plot 2
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis1_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK1sd, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis2_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK2sd, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe2_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe2_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK3sd, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe3_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK4sd, replace);;
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
using FigureTable/reg_MK1.tex, replace  ///
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
using FigureTable/reg_MK2.tex, replace  ///
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
graph export FigureTable/comboMK1.png, as(png) replace


graph combine MK1sd MK2sd MK3sd MK4sd, title("") graphregion(color(white)) name(comboMK2, replace)
graph export FigureTable/comboMK2.png, as(png) replace
set graph off





********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************* Low and High uncertainty robustness

use data/uim_panel.dta, clear

** get the mean and medean of fe1_tr (or fdis1_tr) to spilit into the sub-samples (low- & high- uncertainty firms)
egen cutoff_mean=mean(fdis1_tr), by(year)
generate lowdummy = 0 
replace  lowdummy = 1 if fdis1_tr<cutoff_mean


***************************************************** Low and High uncertainty subsamples
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
label variable fe1_tr "\textbf{Forecast error}"


estpost sum sale_tr at_tr emp_tr age life numana lev_tr  if lowdummy==1, d
eststo low 
estpost sum sale_tr at_tr emp_tr age life numana lev_tr  if lowdummy==0, d
eststo high 
esttab  low high ///
using FigureTable/desc_both_sub.tex, replace ///
mtitles(" \textbf{Low}" " \textbf{High}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2))  ") ///
lines parentheses ///
label nonumber noobs nogaps



********************************************************************************
******************************************************************** Time series
foreach z of varlist fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
	gen `z'_low = .
	gen `z'_high = .
	replace `z'_low = `z'  if lowdummy==1
	replace `z'_high = `z' if lowdummy==0
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
			
merge m:1  year using data/freduse_real.dta  
keep if _merge==3
drop _merge
drop if year < 1977


********************************************************************************
************************************************ merge with macro, Nick and Rudi
*gen year=year 

merge m:1 year  using data/data_table1_census
drop _merge

merge m:m year  using data/data_bachmanetal
drop _merge
gen low=0



******************************************************************* Nick's part
tsset year
gen census=(year==1972|year==1977|year==1982|year==1987|year==1992|year==1997|year==2002|year==2007)
gen f1_census=f1.census
replace f1_census=0 if year==2009 

* Detrend and remove census spikes iqr_e_ltfp_25y
reg iqr_e_ltfp_25y year census
predict det_iqr_e_ltfp_25y , r
su iqr_e_ltfp_25y 
replace det_iqr_e_ltfp_25y =det_iqr_e_ltfp_25y +r(mean)

*** This is smoothing the huge spike of 1996, which is generated by the big change from SIC to NAICS in 1997 (our measure are always t to t+1)
label var det_iqr_e_ltfp_25y "iqr(tfp shock)"

*********************************************************************
*****************************************************plot time series
drop if num==.

* Time series plot 1 
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis1_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK1mu, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis2_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK2mu, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe2_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe2_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK3mu, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_mean_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe3_mean_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "Mean forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK4mu, replace);;
#delimit cr

* Time series plot 2
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis1_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis1_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK1sd, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fdis2_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fdis2_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast dispersion") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK2sd, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe2_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe2_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK3sd, replace);;
#delimit cr
#delimit;
twoway  (rbar recession low year, color(ebg) c(l) yaxis(3) ysc(off ax(3)) barwidth(1))
        (scatter dgdp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter fe3_sdev_hp_low year , c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) )
		(scatter fe3_sdev_hp_high year, c(l) lwidth(thick)  ms(p) yaxis(2) color(blue) ),
        title( "S.D. forecast error") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle("GDP growth") ytitle("",axis(2)) name(MK4sd, replace);;
#delimit cr



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
label variable fdis1_mean_hp_low  "\textbf{Low uncetainty}"
label variable fe3_mean_hp_low    "\textbf{Low uncetainty}"
label variable fdis1_mean_hp_high "\textbf{High uncetainty}"
label variable fe3_mean_hp_high   "\textbf{High uncetainty}"
label variable fdis1_sdev_hp_low  "\textbf{Low uncetainty}"
label variable fe3_sdev_hp_low    "\textbf{Low uncetainty}"
label variable fdis1_sdev_hp_high "\textbf{High uncetainty}"
label variable fe3_sdev_hp_high   "\textbf{High uncetainty}"
label variable fdis1_skew_hp_low  "\textbf{Low uncetainty}"  
label variable fe3_skew_hp_low    "\textbf{Low uncetainty}"
label variable fdis1_skew_hp_high "\textbf{High uncetainty}" 
label variable fe3_skew_hp_high   "\textbf{High uncetainty}"

label variable dgdp "\textbf{\textit{GDP} growth}"
label variable ln_rgdp_hp "\textbf{log(GDP)}"

*======================================================================
* Generate one table for Table "Uncertainy is higher during recessions" (Appendix: low-high uncetainty)
*======================================================================
esttab fdis1_mean_hp_low_dgdp  fdis1_mean_hp_high_dgdp  fdis1_sdev_hp_low_dgdp  fdis1_sdev_hp_high_dgdp  fdis1_skew_hp_low_dgdp fdis1_skew_hp_high_dgdp ///
using FigureTable/reg_MK3.tex, replace  ///
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
* Generate one table for Table "Uncertainy is higher during recessions" (Appendix: low-high uncetainty)
*======================================================================
esttab fe3_mean_hp_low_dgdp fe3_mean_hp_high_dgdp fe3_sdev_hp_low_dgdp fe3_sdev_hp_high_dgdp fe3_skew_hp_low_dgdp fe3_skew_hp_high_dgdp ///
using FigureTable/reg_MK4.tex, replace  ///
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
graph export FigureTable/comboMK3.png, as(png) replace

graph combine MK1sd MK2sd MK3sd MK4sd, title("") graphregion(color(white)) name(comboMK2, replace)
graph export FigureTable/comboMK4.png, as(png) replace
set graph off


log close post_panel


