****23/08/2023: revision work for ECMA in Tokyo
****18/06/2018: revision work for ECMA in QMUL after Townhall    - final version checked

****06/06/2018: revision work for ECMA in Barbican - moments for calibration and two-state Markov process new
****28/05/2018: revision work for ECMA in Barbican - moments for calibration and two-state Markov process
****16/05/2018: revision work for ECMA in Barbican - moments for calibration

cls
clear all
set more off
set graphics off


log using log/stats_panel.log, name(stats_panel) replace


********************************************************************************
use data/uim_panel.dta, clear


merge m:1  year using data/freduse_real.dta
keep if _merge==3
drop _merge

gen rec_dummy = 0
*replace rec_dummy = 1 if usrec>0
replace rec_dummy = 1 if ln_rgdp_hp<0

drop if gvkey==.
sort  gvkey fyear sic
xtset gvkey fyear

** CALCULATE ROA
*drop ROA_gr
gen  ROA  = strt
gen  ROA_gr = strt-l.strt

** CALCULATE EMPLOYMENT
gen employees = log(emp)

** CALCULATE TFP
gen tfp1 = 0.5*ln_sales - employees
gen tfp2 = ln_sales - employees

** CALCULATE Sale
gen sales_gr = ln_sales - l.ln_sales



*****************************************
*****************************************
***************************************** Winsorise growth rates & sample choice
*keep if maxrun>15
winsor2 IK investment investment_gr sales_gr fundamental_gr ROA_gr emp_gr, by(year) cut(1 99) trim


*****************************************
*****************************************
***************************************** AR(1) process of productivity
qui xtreg fundamental l.fundamental i.fyear, fe robust
gen   rho_funda  =_b[l.fundamental]
gen   sigma_funda=e(sigma_e)
predict fundamental_shock, e
gen fundamental_shock_lag = L.fundamental_shock

qui xtreg tfp1 l.tfp1 i.fyear, fe robust
gen   rho_tfp  =_b[l.tfp1]
gen   sigma_tfp=e(sigma_e)
predict tfp_shock, e
gen tfp_shock_lag = L.tfp_shock


*****************************************
*****************************************
***************************************** cross-sectional standard deviation
***************************************** investment growth
qui xtreg investment_tr i.fyear, fe robust
gen sigma_i = e(sigma_e)
predict investment_id, e
gen investment_id_lag = L.investment_id
***************************************** Sales growth
qui xtreg sales_gr_tr i.fyear, fe robust
gen sigma_s = e(sigma_e)
predict sales_gr_id, e
gen sales_gr_id_lag = L.sales_gr_id
***************************************** ROA growth
qui xtreg ROA_gr_tr i.fyear, fe robust
gen sigma_r = e(sigma_e)
predict ROA_gr_id, e
gen ROA_gr_id_lag = L.ROA_gr_id
***************************************** employment growth
qui xtreg emp_gr_tr i.fyear, fe robust
gen sigma_e = e(sigma_e)
predict emp_gr_id, e
gen emp_gr_id_lag = L.emp_gr_id


winsor2 sales_gr_id sales_gr_id_lag investment_id investment_id_lag emp_gr_id emp_gr_id_lag, cut(0.1, 99.9) trim


*****************************************
*****************************************
***************************************** Correlation between growth variables
***************************************** investment -v- sales
egen corr_is = corr(investment_id sales_gr_id)
***************************************** investment -v- fundamental
egen corr_ifund = corr(investment_id fundamental_shock)
***************************************** investment -v- tfp
egen corr_itfp = corr(investment_id tfp_shock)
***************************************** investment -v- fdis1
egen corr_ifdis = corr(investment_id fdis1_tr)
***************************************** investment -v- fe1
egen corr_ife = corr(investment_id fe1_tr)






*****************************************
*****************************************
***************************************** Sales growth rates by uncertainty
gen unct = .
label variable unct "uncertainty measure "
foreach y in sales_gr investment IK fundamental_gr {
foreach x in fdis1 fdis2 fe1 fe2 fe3 {
replace unct = `x'_tr
qui areg `y' unct i.fyear ln_capital age, absorb(gvkey) vce(robust)
qui estadd local YearFE = "Y", replace
qui estadd local FirmFE = "Y", replace
qui estadd local FirmControl = "Y", replace
est store `y'_`x'_YNYY
}
}
label variable ln_capital "Firm size"
label variable age "Firm age"

foreach x in sales_gr investment IK fundamental_gr {
esttab `x'_fdis1_YNYY `x'_fdis2_YNYY `x'_fe1_YNYY `x'_fe2_YNYY `x'_fe3_YNYY ///
using FigureTable/reg_`x'.tex, replace ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(YearFE FirmFE N r2 , fmt(%9.0g %9.0g %9.0g %9.0g %8.3f) ///
labels("Year FE" "Firm FE" Observations R^2 )) t noconstant ///
keep(unct ln_capital age) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{1}{c}{Forecast dispersion}&\multicolumn{1}{c}{Forecast dispersion} ///
                                                          &\multicolumn{1}{c}{Forecast error} &\multicolumn{1}{c}{Forecast error} &\multicolumn{1}{c}{Forecast error} \\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})
}




*****************************************
*****************************************
***************************************** Cross-sectional dispersion of sales growth rates by uncertainty
gen neg_unct = fe1_tr
egen unct_pct = xtile(neg_unct), by(fyear) nq(10)

foreach z of varlist sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_gr {
egen mean_`z' = mean(`z'),  by(fyear unct_pct)
egen sd_`z'   = sd(`z'),    by(fyear unct_pct)
egen skew_`z' = skew(`z'),  by(fyear unct_pct)
egen kurt_`z' = kurt(`z'),  by(fyear unct_pct)
egen p25_`z'  = pctile(sd_`z'),p(25) by(unct_pct)
egen p50_`z'  = pctile(sd_`z'),p(50) by(unct_pct)
egen p75_`z'  = pctile(sd_`z'),p(75) by(unct_pct)

egen nber_mean_`z' = mean(`z') if usrec>0,  by(unct_pct)
egen nber_sd_`z'   = sd(`z')   if usrec>0,  by(unct_pct)
egen nber_skew_`z' = skew(`z') if usrec>0,  by(unct_pct)
egen nber_kurt_`z' = kurt(`z') if usrec>0,  by(unct_pct)
egen nonnber_mean_`z' = mean(`z') if usrec<1,  by(unct_pct)
egen nonnber_sd_`z'   = sd(`z')   if usrec<1,  by(unct_pct)
egen nonnber_skew_`z' = skew(`z') if usrec<1,  by(unct_pct)
egen nonnber_kurt_`z' = kurt(`z') if usrec<1,  by(unct_pct)

preserve
collapse nber_mean_`z' nber_sd_`z' nber_skew_`z' nber_kurt_`z' nonnber_mean_`z' nonnber_sd_`z' nonnber_skew_`z' nonnber_kurt_`z', by(rec_dummy unct_pct)
#delimit;
twoway (scatter nber_mean_`z' unct_pct)
       (lowess  nber_mean_`z' unct_pct)
       (scatter nonnber_mean_`z' unct_pct)
	   (lowess  nonnber_mean_`z' unct_pct), graphregion(color(white)) legend(off) xtitle("uncertaitny decile") title("mean") name(unct_mean_`z', replace);

twoway (scatter nber_sd_`z' unct_pct)
       (lowess  nber_sd_`z' unct_pct)
       (scatter nonnber_sd_`z' unct_pct)
	   (lowess  nonnber_sd_`z' unct_pct), graphregion(color(white)) legend(off) xtitle("uncertaitny decile") title("sd") name(unct_sd_`z', replace);

twoway (scatter nber_skew_`z' unct_pct)
       (lowess  nber_skew_`z' unct_pct)
       (scatter nonnber_skew_`z' unct_pct)
	   (lowess  nonnber_skew_`z' unct_pct), graphregion(color(white)) legend(off) xtitle("uncertaitny decile") title("skew") name(unct_skew_`z', replace);  

twoway (scatter nber_kurt_`z' unct_pct)
       (lowess  nber_kurt_`z' unct_pct)
       (scatter nonnber_kurt_`z' unct_pct)
	   (lowess  nonnber_kurt_`z' unct_pct), legend(on order(1 "Recession" 3 "Non-recession" ) cols(1) position(1) ring(0)) graphregion(color(white)) xtitle("uncertaitny decile") title("kurt") name(unct_kurt_`z', replace);

	   set graphics on;
	   graph combine unct_mean_`z' unct_sd_`z' unct_skew_`z' unct_kurt_`z', title("") graphregion(color(white)) name(unct_`z'_bcycle, replace);
	   graph export FigureTable/unct_`z'_nber.png, as(png) replace;	   
	   set graphics off;
#delimit cr
restore
}


foreach z of varlist sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_gr {
foreach w of varlist unct_pct {
preserve
statsby mean = r(mean) sd = r(sd) skew = r(skewness) kurt = r(kurtosis) N=r(N) , by(`w') clear: sum  `z', det
twoway (scatter mean `w') (lowess mean `w'), graphregion(color(white)) legend(off) xtitle("uncertaitny decile") title("mean") name(mean_`z'_`w', replace)
twoway (scatter sd `w')   (lowess sd `w'), graphregion(color(white))   legend(off) xtitle("uncertaitny decile") title("sd") name(sd_`z'_`w', replace)
twoway (scatter skew `w') (lowess skew `w'), graphregion(color(white)) legend(off) xtitle("uncertaitny decile") title("skewness") name(skew_`z'_`w', replace)
twoway (scatter kurt `w') (lowess kurt `w'), graphregion(color(white)) legend(off) xtitle("uncertaitny decile") title("kurtosis") name(kurt_`z'_`w', replace)
restore
}
}

foreach z of varlist sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_gr {
foreach w in mean sd skew kurt {
preserve
statsby p25 = r(p25) p50 = r(p50) p75= r(p75), by(unct_pct) clear: sum `w'_`z', det
#delimit;
twoway (scatter p25 unct_pct) (lowess p25 unct_pct)
	   (scatter p50 unct_pct) (lowess p50 unct_pct)
       (scatter p75 unct_pct) (lowess p75 unct_pct), graphregion(color(white)) legend(off) xtitle("uncertaitny decile") title("`w'") name(`w'_`z'_bcycle, replace);
#delimit cr
restore
}
}

foreach z of varlist sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_gr {
foreach w in unct_pct bcycle {
set graphics on
graph combine mean_`z'_`w' sd_`z'_`w' , title("") graphregion(color(white)) name(F_`z'_`w', replace)
graph export FigureTable/F4_`z'_`w'.png, as(png) replace
set graphics off
}
}

foreach z of varlist sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_gr {
foreach w in unct_pct bcycle {
set graphics on
graph combine mean_`z'_`w' sd_`z'_`w' skew_`z'_`w' kurt_`z'_`w' , title("") graphregion(color(white)) name(F2_`z'_`w', replace)
graph export FigureTable/F_`z'_`w'.png, as(png) replace
set graphics off
}
}


*****************************************
*****************************************
***************************************** model and data matching
egen sd_sales_gr_cali   = sd(sales_gr),       by(fyear unct_pct)
egen sd_sales_gr_tr_cali   = sd(sales_gr_tr),    by(fyear unct_pct)
egen sd_sales_gr_id_cali   = sd(sales_gr_id), by(fyear unct_pct)


foreach y in sd_sales_gr_cali  sd_sales_gr_tr_cali  sd_sales_gr_id_cali{
preserve
statsby p25_`y' = r(p25) p50_`y' = r(p50) p75_`y' = r(p75), by(unct_pct) clear: sum `y', det


gen uimL_sd_sales_gr=.
gen uimH_sd_sales_gr=.
replace uimH_sd_sales_gr=0.5145 if unct_pct==1
replace uimH_sd_sales_gr=0.5349 if unct_pct==2
replace uimH_sd_sales_gr=0.2761 if unct_pct==3
replace uimH_sd_sales_gr=0.2617 if unct_pct==4
replace uimH_sd_sales_gr=0.2572 if unct_pct==5
replace uimH_sd_sales_gr=0.2596 if unct_pct==6
replace uimH_sd_sales_gr=0.2681 if unct_pct==7
replace uimH_sd_sales_gr=0.2442 if unct_pct==8
replace uimH_sd_sales_gr=0.2535 if unct_pct==9
replace uimH_sd_sales_gr=0.2698 if unct_pct==10

replace uimL_sd_sales_gr=0.5953 if unct_pct==1
replace uimL_sd_sales_gr=0.5793 if unct_pct==2
replace uimL_sd_sales_gr=0.3330 if unct_pct==3
replace uimL_sd_sales_gr=0.1936 if unct_pct==4
replace uimL_sd_sales_gr=0.1768 if unct_pct==5
replace uimL_sd_sales_gr=0.1717 if unct_pct==6
replace uimL_sd_sales_gr=0.1606 if unct_pct==7
replace uimL_sd_sales_gr=0.1421 if unct_pct==8
replace uimL_sd_sales_gr=0.1474 if unct_pct==9
replace uimL_sd_sales_gr=0.1513 if unct_pct==10


set graphics on
#delimit;
twoway (lowess p25_`y' unct_pct, lpattern(solid) lwidth(thick) color(red))
	   (connected uimL_sd_sales_gr unct_pct, lpattern(solid) lwidth(medthick) color(red))
       (connected uimH_sd_sales_gr unct_pct, lpattern(dash) lwidth(medthick) color(blue))
	   (lowess p75_`y' unct_pct, lpattern(dash) lwidth(thick) color(blue)), graphregion(color(white)) xlabel(1(1)10) legend(off) xtitle("uncertaitny decile") title("") name(calibration_`y', replace);
#delimit cr
restore
}
graph combine calibration_sd_sales_gr_cali, title("") graphregion(color(white)) name(unct_sales_gr_bcycle, replace)
graph export FigureTable/calibration1.png, as(png) replace
graph combine calibration_sd_sales_gr_tr_cali, title("") graphregion(color(white)) name(unct_sales_gr_bcycle, replace)
graph export FigureTable/calibration2.png, as(png) replace
graph combine calibration_sd_sales_gr_id_cali, title("") graphregion(color(white)) name(unct_sales_gr_bcycle, replace)
graph export FigureTable/calibration3.png, as(png) replace
set graphics off



*****************************************
*****************************************
***************************************** Record all these moments
label variable rho_funda "Rho Fundamental"
label variable rho_tfp   "Rho Labor Productivity"
label variable sigma_funda  "SD Fundamental Shock"
label variable sigma_tfp    "SD Labor Productivity Shock"
label variable sigma_i      "SD Investment"
label variable sigma_s      "SD Sales Growth"
label variable sigma_r      "SD ROA Growth"
label variable sigma_e      "SD Employment Growth"
label variable corr_is "Corr(Investment, Sales Growth)"
label variable corr_ifund "Corr(Investment, Fundamental Shock)"
label variable corr_itfp "Corr(Investment, Labor productivity Shock)"
label variable corr_ifdis "Corr(Investment, Fdis)"
label variable corr_ife "Corr(Investment, FE)"
estpost sum rho_funda rho_tfp sigma_funda sigma_tfp sigma_i sigma_s sigma_r sigma_e corr_is corr_ifund corr_itfp corr_ifdis corr_ife , d
est store all
esttab all ///
using FigureTable/panel_moment_unbala.tex, replace ///
legend noabbrev style(tex) ///
cells("mean(fmt(3)) ") ///
lines parentheses ///
label nonumber noobs nogaps


*****************************************
*****************************************
***************************************** Descriptive stats
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
label variable sales_gr "\textbf{Sales growth}"
label variable sales_gr_id "\textbf{Sales growth shock}"
label variable investment "\textbf{Investment}"
label variable fundamental_shock "\textbf{Fundamental shock}"

estpost sum sale_tr at_tr emp_tr age life numana lev_tr strt_tr fdis1_tr fdis2_tr fe2_tr fe1_tr sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_shock, d
est store all
esttab all ///
using FigureTable/panel_moment_unbala_des.tex, replace ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2)) p5(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p95(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps




********************************************************************************
***************************************************** Low and High uncertainty subsamples
egen cutoff_mean=mean(fdis1_tr), by(fyear)
generate lowdummy = 0 
replace  lowdummy = 1 if fdis1_tr<cutoff_mean

estpost sum sale_tr at_tr emp_tr age life numana lev_tr sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_shock if lowdummy==1, d
eststo low 
estpost sum sale_tr at_tr emp_tr age life numana lev_tr sales_gr sales_gr_tr sales_gr_id IK IK_tr investment fundamental_shock if lowdummy==0, d
eststo high 
esttab  low high ///
using FigureTable/panel_moment_unbala_sub.tex, replace ///
mtitles(" \textbf{Low}" " \textbf{High}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps 



********************************************************************************
***************************************************** Uncertainty decile subsamples
estpost sum sd_sales_gr_cali if unct_pct==1, d
eststo low 
estpost sum sd_sales_gr_cali if unct_pct==5, d
eststo mid 
estpost sum sd_sales_gr_cali if unct_pct==10, d
eststo high 
estpost sum sd_sales_gr_cali			    , d
eststo all 
esttab  low mid high all ///
using FigureTable/panel_moment_unbala_unct_pct.tex, replace ///
mtitles(" \textbf{Low}" " \textbf{Mid}" " \textbf{High}" " \textbf{All}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2))  p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps 

********************************************************************************
* We stop here in this verion of "2023DecReplicationExtention"
* We close the log file here
********************************************************************************
log close stats_panel
555

********************************************************************************
************************************** plot distributions of umcertainty proxies
set graphics on
#delimit;
twoway (kdensity sales_gr_tr if usrec<1, lcolor(red) lwidth(medthick) lpattern(dash)) 
       (kdensity sales_gr_tr if usrec<1, lcolor(black) lwidth(medthick) lpattern(solid))
       (kdensity sales_gr_tr if usrec>1, lcolor(blue) lwidth(medthick) lpattern(longdash_dot)), 
        legend(on order(1 "2007" 2 "2008" 3 "2009") cols(1) position(1) ring(0)) title("") xtitle("") graphregion(color(white))  ytitle("") name(F1, replace);
#delimit cr



sum sales_gr sales_gr_tr sales_gr_id if usrec>1
sum sales_gr sales_gr_tr sales_gr_id if usrec<1
sum sales_gr sales_gr_tr sales_gr_id if (usrec>1 & unct_pct==10)
sum sales_gr sales_gr_tr sales_gr_id if (usrec<1 & unct_pct==10)

********************************************************************************
*********************************************************************time series
sort year

by year: egen num=sum(ind)
by year: egen numest=mean(numana)

foreach z of varlist strt_tr vol_tr iv_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr V_jt_w_tr G_jt_w mrpk_tr sales_gr_tr sales_gr_id investment fundamental_shock {
*replace `z' = log(`z')
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
		 sales_gr_tr_mean   sales_gr_tr_sdev   sales_gr_tr_skew   sales_gr_tr_kurt
		 sales_gr_id_mean   sales_gr_id_sdev   sales_gr_id_skew   sales_gr_id_kurt
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
			sales_gr_mean_hp sales_gr_sdev_hp sales_gr_skew_hp sales_gr_kurt_hp
			sales_gr_id_mean_hp sales_gr_id_sdev_hp sales_gr_id_skew_hp sales_gr_id_kurt_hp
			
			= strt_tr_mean vol_tr_mean fdis1_tr_mean fdis2_tr_mean fe1_tr_mean fe2_tr_mean fe3_tr_mean V_jt_w_tr_mean G_jt_w_mean
			  strt_tr_sdev vol_tr_sdev fdis1_tr_sdev fdis2_tr_sdev fe1_tr_sdev fe2_tr_sdev fe3_tr_sdev V_jt_w_tr_sdev G_jt_w_sdev
			  strt_tr_skew vol_tr_skew fdis1_tr_skew fdis2_tr_skew fe1_tr_skew fe2_tr_skew fe3_tr_skew V_jt_w_tr_skew G_jt_w_skew
			  strt_tr_kurt vol_tr_kurt fdis1_tr_kurt fdis2_tr_kurt fe1_tr_kurt fe2_tr_kurt fe3_tr_kurt V_jt_w_tr_kurt G_jt_w_kurt mrpk_tr_mean mrpk_tr_sdev mrpk_tr_skew mrpk_tr_kurt
			  sales_gr_tr_mean sales_gr_tr_sdev sales_gr_tr_skew sales_gr_tr_kurt
			  sales_gr_id_mean sales_gr_id_sdev sales_gr_id_skew sales_gr_id_kurt
			   
		    , smooth(6.25);

#delimit cr


*********************************************************************
*****************************************************plot time series
drop if num==.


foreach z in strt_tr vol_tr iv_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr sales_gr_tr sales_gr_id {
mswitch dr `z'_mean
predict pre_`z'_mean, pr
mswitch dr `z'_sdev
predict pre_`z'_sdev, pr

#delimit;
twoway  (scatter `z'_mean year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter `z'_sdev year, c(l) lwidth(medthick)  ms(p) yaxis(1) color(red) ),
        title( "`z'") xlabel(1976(6)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle(" ") name(`z', replace);
#delimit cr
#delimit;
twoway  (scatter `z'_mean year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter pre_`z'_mean year, c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "`z'") xlabel(1976(6)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle(" ") name(`z'_mean, replace);
#delimit cr
#delimit;
twoway  (scatter `z'_sdev year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter pre_`z'_sdev year, c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "`z'") xlabel(1976(6)2022) legend(off) xtitle("years") graphregion(color(white))  ytitle(" ") name(`z'_sdev, replace);
#delimit cr
}


set graph on
graph combine vol_tr iv_tr fdis1_tr fdis2_tr fe1_tr fe3_tr, title("") graphregion(color(white)) name(combo_rowts, replace)
graph combine vol_tr_mean iv_tr_mean fdis1_tr_mean fdis2_tr_mean fe1_tr_mean fe3_tr_mean, title("") graphregion(color(white)) name(combo_mrko_mean, replace)
graph combine vol_tr_sdev iv_tr_sdev fdis1_tr_sdev fdis2_tr_sdev fe1_tr_sdev fe3_tr_sdev, title("") graphregion(color(white)) name(combo_mrko_sdev, replace)
set graph off
set graph on
graph combine combo_rowts, title("") graphregion(color(white)) name(combo_rowts1, replace)
graph combine combo_mrko_mean, title("") graphregion(color(white)) name(combo_mrko_mean1, replace)
graph combine combo_mrko_sdev, title("") graphregion(color(white)) name(combo_mrko_sdev1, replace)
set graph off



foreach z in strt vol iv fdis1 fdis2 fe1 fe2 fe3 sales_gr sales_gr_id {
mswitch dr `z'_mean_hp
predict pre_`z'_mean_hp, pr
mswitch dr `z'_sdev_hp
predict pre_`z'_sdev_hp, pr

#delimit;
twoway  (scatter `z'_mean_hp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter `z'_sdev_hp year, c(l) lwidth(medthick)  ms(p) yaxis(1) color(red) ),
        title( "`z'") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle(" ") name(`z', replace);
#delimit cr
#delimit;
twoway  (scatter `z'_mean_hp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter pre_`z'_mean_hp year, c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "`z'") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle(" ") name(`z'_mean, replace);
#delimit cr
#delimit;
twoway  (scatter `z'_sdev_hp year, c(l) ms(p) lwidth(medthick) lp(-) yaxis(1) ysc(alt ax(1)) color(black))
        (scatter pre_`z'_sdev_hp year, c(l) lwidth(medthick)  ms(p) yaxis(2) color(red) ),
        title( "`z'") xlabel(1976(6)2015) legend(off) xtitle("years") graphregion(color(white))  ytitle(" ") name(`z'_sdev, replace);
#delimit cr
}

set graph on
graph combine vol iv fdis1 fdis2 fe1 fe3, title("") graphregion(color(white)) name(combo_hpts, replace)
graph combine vol_mean iv_mean fdis1_mean fdis2_mean fe1_mean fe3_mean, title("") graphregion(color(white)) name(combo_mrko_mean_hp, replace)
graph combine vol_sdev iv_sdev fdis1_sdev fdis2_sdev fe1_sdev fe3_sdev, title("") graphregion(color(white)) name(combo_mrko_sdev_hp, replace)
set graph off
set graph on
graph combine combo_hpts, title("") graphregion(color(white)) name(combo_rowts1, replace)
graph combine combo_mrko_mean_hp, title("") graphregion(color(white)) name(combo_mrko_mean_hp1, replace)
graph combine combo_mrko_sdev_hp, title("") graphregion(color(white)) name(combo_mrko_sdev_hp1, replace)
set graphics off



******************************************************************************** recap
foreach z in fe1 fe2 fe3 fdis1 fdis2 {
qui mswitch dr `z'_tr_mean
estat transition

qui mswitch dr `z'_mean_hp
estat transition

}

set graph on
graph combine sales_gr, title("") graphregion(color(white)) name(sales_gr_hp, replace)
graph combine sales_gr_hp, title("") graphregion(color(white)) name(sales_gr_hp, replace)
graph combine sales_gr_id_mean sales_gr_id_sdev, title("") graphregion(color(white)) name(sales_gr_id_hp, replace)
set graph off



log close stats_panel


