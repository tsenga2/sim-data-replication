****23/08/2023: revision work for ECMA in Tokyo
****18/06/2018: revision work for ECMA in QMUL - final batch

****24/05/2018: revision work for ECMA in QMUL - new to create ponch figure
****18/05/2018: revision work for ECMA in Barbican after E1Macro - new to creat auxiary figures and tables
****12/05/2018: revision work for ECMA in Barbican after E1Macro
****27/03/2018: revision work for ECMA in QMUL after the RES conference

****07/03/2018: revision work for ECMA in Nice

****21/02/2018: revision work for ECMA in London (just back from Lisbon)
****             - moving files from Google Drive to Dropbox folder
****             - evolved from ibes_sum_cusip_June2016a.do

*********************************************************************
* 23 August 2016: checking by reading "data" (ShareLaTeX\Bayesian Uncertainty Shock\empirics)
* from ibes_June2015 to new (trying to map ferror to model tightly)
* this is version a: to create fdis, frang, and ferror for forecasts made in 8 month prior

cls
clear all
set more off
set graphics on


log using log/ibes_fuzoku.log, name(ibes_fuzoku) replace

use data/ibes_panel_m.dta, clear



********************************************************************************
****************************************************************** Ford example
preserve
keep if ticker=="F"

keep if fyear>2006
keep if fyear<2012
	   
twoway (connected actual ym, yaxis(1) msize(vsmall) msymbol(square) lpattern(solid)) ///
	   (connected highest ym, yaxis(1)  msize(tiny)  msymbol(diamond) lpattern(dash)) ///
	   (connected meanest ym, yaxis(1)  msize(small) msymbol(none) lpattern(solid)) ///
	   (connected lowest  ym, yaxis(1)  msize(tiny)  msymbol(lgx) lpattern(dash)), ///
	   title(" ") xtitle(" ") ytitle(" ")  note(" ") graphregion(color(white)) ///
	   legend(pos(5) ring(0) col(1) order(1 "actual" 2 "high" 3 "mean" 4 "low") ///
	   ) tlabel(2007m2(12)2012m1) name(alcoa_example_1, replace)	   

set graphics on
graph combine alcoa_example_1, graphregion(color(white)) name(alcoa_example, replace)
graph export FigureTable/ford_example_ponch.png, as(png) replace
set graphics off



twoway (connected ferr1 ym, yaxis(1) msize(small) msymbol(lgx) lpattern(solid)) ///
	   (connected stdev ym, yaxis(1) msize(small) msymbol(lgx) lpattern(dash)), ///
	   title(" ") xtitle(" ") ytitle(" ") note(" ") graphregion(color(white)) ///
	   legend(pos(2) ring(0) col(1) order(1 "forecast error (FE)" 2 "forecast dispersion (Fdis)") ///
	   ) tlabel(2007m2(12)2012m1) name(alcoa_example_2, replace)	   

set graphics on
graph combine alcoa_example_1 alcoa_example_2, cols(1) xcommon imargin(zero) graphregion(color(white)) name(alcoa_example_fe, replace)
graph export FigureTable/ford_example_fefdis.png, as(png) replace
set graphics off


twoway (connected ferr1 ym, yaxis(1) msize(small) msymbol(lgx) lpattern(solid)) ///
	   (scatter ferr1_tr_fstval ym, yaxis(1) msize(small) msymbol(lgx) lpattern(dash)) ///
	   (scatter ferr1_tr_aveval ym, yaxis(1) msize(small) msymbol(triangle) lpattern(dash)) ///
	   (scatter ferr1_tr_extrap ym, yaxis(1)  msize(tiny) msymbol(lgx) lpattern(solid)), ///
	   title(" ") xtitle(" ") ytitle(" ") note(" ") graphregion(color(white)) ///
	   legend(on order(1 "forecast error (FE)" 2 "1st-month FE" 3 "year-average FE" 4 "year-ahead FE (extraporated)") ///
	   ) tlabel(2007m2(12)2012m1) name(alcoa_example_fe, replace)	   

set graphics on
graph combine alcoa_example_fe, graphregion(color(white)) name(alcoa_example_fe, replace)
graph export FigureTable/ford_example_fe.png, as(png) replace
set graphics off


twoway (connected stdev ym, yaxis(1) msize(small) msymbol(lgx) lpattern(solid)) ///
	   (scatter stdev_tr_fstval ym, yaxis(1) msize(small) msymbol(lgx) lpattern(dash)) ///
	   (scatter stdev_tr_aveval ym, yaxis(1) msize(small) msymbol(triangle) lpattern(dash)) ///
	   (scatter stdev_tr_extrap ym, yaxis(1)  msize(tiny) msymbol(lgx) lpattern(solid)), ///
	   title(" ") xtitle(" ") ytitle(" ") note(" ") graphregion(color(white)) ///
	   legend(on order(1 "forecast dispersion (Fdis)" 2 "year-ahead Fdis" 3 "year-average Fdis" 4 "year-ahead Fdis (extraporated)") ///
	   ) tlabel(2007m2(12)2012m1) name(alcoa_example_fdis, replace)	   

set graphics on
graph combine alcoa_example_fdis, graphregion(color(white)) name(alcoa_example_fdis, replace)
graph export FigureTable/ford_example_fdis.png, as(png) replace
set graphics off
	   
restore



********************************************************************************
*************************************************************** pattern analysis
preserve
collapse (sum) obs = id (mean) numest stdev_tr ferr1_tr,  by(toward)
twoway (dropline obs      toward if toward>-2 & toward<13), ytitle("") xtitle("horizon") xlabel(#11) title("observation")  graphregion(color(white)) tlabel(-1(1)12) name(obs_mean_tow, replace)
twoway (dropline numest   toward if toward>-2 & toward<13), ytitle("") xtitle("horizon") xlabel(#11) title("analyst coverage")  graphregion(color(white)) tlabel(-1(1)12) name(numest_mean_tow, replace)
twoway (dropline stdev_tr toward if toward>-2 & toward<13), ytitle("") xtitle("horizon") xlabel(#11) title("forecast dispersion")  graphregion(color(white)) tlabel(-1(1)12) name(stdev_tr_mean_tow, replace)
twoway (dropline ferr1_tr toward if toward>-2 & toward<13), ytitle("") xtitle("horizon") xlabel(#11) title("forecast error")  graphregion(color(white)) tlabel(-1(1)12) name(ferr1_tr_mean_tow, replace)
set graphics on
graph combine obs_mean_tow stdev_tr_mean_tow numest_mean_tow ferr1_tr_mean_tow, graphregion(color(white)) name(box_tow, replace)
graph export FigureTable/box_tow.png, as(png) replace
set graphics off
restore

preserve
collapse (sum) obs = id (mean) numest stdev_tr ferr1_tr if fm==12,  by(m)
twoway (dropline obs      m), ytitle("") xlabel(#11) title("observation")  graphregion(color(white)) name(obs_mean_m_12, replace)
twoway (dropline numest   m), ytitle("") xlabel(#11) title("analyst coverage")  graphregion(color(white)) name(numest_mean_m_12, replace)
twoway (dropline stdev_tr m), ytitle("") xlabel(#11) title("forecast dispersion")  graphregion(color(white)) name(stdev_tr_mean_m_12, replace)
twoway (dropline ferr1_tr m), ytitle("") xlabel(#11) title("forecast error")  graphregion(color(white)) name(ferr1_tr_mean_m_12, replace)
set graphics on
graph combine obs_mean_m_12 stdev_tr_mean_m_12 numest_mean_m_12 ferr1_tr_mean_m_12, graphregion(color(white)) name(box_m_12, replace)
graph export FigureTable/box_m_12.png, as(png) replace
set graphics off
restore


preserve
collapse (sum) obs = id (mean) numest stdev_tr ferr1_tr if fm==9,  by(m)
twoway (dropline obs      m), ytitle("") xlabel(#11) title("observation")  graphregion(color(white)) name(obs_mean_m_9, replace)
twoway (dropline numest   m), ytitle("") xlabel(#11) title("analyst coverage")  graphregion(color(white)) name(numest_mean_m_9, replace)
twoway (dropline stdev_tr m), ytitle("") xlabel(#11) title("forecast dispersion")  graphregion(color(white)) name(stdev_tr_mean_m_9, replace)
twoway (dropline ferr1_tr m), ytitle("") xlabel(#11) title("forecast error")  graphregion(color(white)) name(ferr1_tr_mean_m_9, replace)
set graphics on
graph combine obs_mean_m_9 stdev_tr_mean_m_9 numest_mean_m_9 ferr1_tr_mean_m_9, graphregion(color(white)) name(box_m_9, replace)
graph export FigureTable/box_m_9.png, as(png) replace
set graphics off
restore


preserve
collapse (sum) obs = id (mean) numest stdev_tr ferr1_tr if fm==6,  by(m)
twoway (dropline obs      m), ytitle("") xlabel(#11) title("observation")  graphregion(color(white)) name(obs_mean_m_6, replace)
twoway (dropline numest   m), ytitle("") xlabel(#11) title("analyst coverage")  graphregion(color(white)) name(numest_mean_m_6, replace)
twoway (dropline stdev_tr m), ytitle("") xlabel(#11) title("forecast dispersion")  graphregion(color(white)) name(stdev_tr_mean_m_6, replace)
twoway (dropline ferr1_tr m), ytitle("") xlabel(#11) title("forecast error")  graphregion(color(white)) name(ferr1_tr_mean_m_6, replace)
set graphics on
graph combine obs_mean_m_6 stdev_tr_mean_m_6 numest_mean_m_6 ferr1_tr_mean_m_6, graphregion(color(white)) name(box_m_6, replace)
graph export FigureTable/box_m_6.png, as(png) replace
set graphics off
restore


preserve
collapse (sum) obs = id (mean) numest stdev_tr ferr1_tr if fm==3,  by(m)
twoway (dropline obs      m), ytitle("") xlabel(#11) title("observation")  graphregion(color(white)) name(obs_mean_m_3, replace)
twoway (dropline numest   m), ytitle("") xlabel(#11) title("analyst coverage")  graphregion(color(white)) name(numest_mean_m_3, replace)
twoway (dropline stdev_tr m), ytitle("") xlabel(#11) title("forecast dispersion")  graphregion(color(white)) name(stdev_tr_mean_m_3, replace)
twoway (dropline ferr1_tr m), ytitle("") xlabel(#11) title("forecast error")  graphregion(color(white)) name(ferr1_tr_mean_m_3, replace)
set graphics on
graph combine obs_mean_m_3 stdev_tr_mean_m_3 numest_mean_m_3 ferr1_tr_mean_m_3, graphregion(color(white)) name(box_m_3, replace)
graph export FigureTable/box_m_3.png, as(png) replace
set graphics off
restore



log close ibes_fuzoku


*if you need something below go back 20:49 17/05/2018 version of this
