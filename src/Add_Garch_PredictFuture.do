cls
clear
set more off, perm
set graphics on

*log using garch.log, name(garch) replace


global mypath "/Users/tsenga/uim-empirics"

use $mypath/data/compustat-quarterly-garch.dta, clear

********************************************************************************
** GENERATE THE VARIABLE TIME
gen y=substr(datacqtr,1,4)
destring y,replace
gen q=substr(datacqtr,6,1)
destring q, replace
gen time = yq(y, q)
format time %tq

rename y fyear

sort gvkey time sic
destring gvkey, replace
destring sic, replace


** 1: sample selection (keep fic or loc ==usa following Gabaix, 2011)
keep if loc=="USA"

** 2 sample selection (drop SIC following Gabaix, 2011)
*drop if (sic==2911 | sic==5172 | sic==1311 | sic==4922 | sic==4923 | sic==4924 | sic==1389)
*drop if (sic >= 4900 & sic <= 4940)
*drop if (sic >= 6000 & sic <= 6999)

** 3 sample selection (drop CAD currency data)
drop if curcd=="CAD"

** 4 drop bad data (fyear==.)
*drop if fyear==.| fyear<1978 | fyear>2016
drop if fyear==.| fyear<1978 | fyear>2022
drop if time==.
drop if saleq==0 | saleq==. | saleq<0
drop if ajexq==0 | ajexq==. | ajexq<0 
*drop if optrfr==0 | optrfr==. | optrfr<0 
drop if ppegtq==0 | ppegtq==. | ppegtq<0
drop if prccq==0 | prccq==. | prccq<0
** NB
* ajexq from 1950
* optrfr from 2002

** 5 setting up a panel
xtset gvkey time
xtsum gvkey


keep gvkey time fyear saleq sic ajexq ppegtq prccq
univar time fyear saleq sic ajexq ppegtq prccq

********************************************************************************
*************************************************** Variable construction 
gen sic_3d=int(sic/10)
gen sic_2d=int(sic/100)
gen sic_1d=int(sic/1000)


*******************************************************************************************************************************************************************************************************************************







** WINSORIZE SALE LAST (W1)
winsor2 saleq, by(time) cuts(2 98) trim 







** CALCULATE Vjt WEIGHTED 

* Total saleqs per year (W4)

egen total_saleqs_t = sum(saleq_tr), by(time)

* Total saleqs per year per sector
egen total_saleqs_jt = sum(saleq_tr), by(time sic_2d)



** CALCULATE LOG TOTAL SALES
gen log_total_saleqs_jt = log(total_saleqs_jt)



** DETREND THE VARIABLES

* Use hp filter to detrend
drop gvkey
gen gvkey = sic_2d
collapse fyear log_total_saleqs_jt, by(time sic_2d)



drop if log_total_saleqs_jt==.
gen ind = 1
egen life = sum(ind), by(sic_2d)

*drop if life <156
drop if life <180

reshape wide log_total_saleqs_jt, i(time) j(sic_2d)


tsset time, quarterly
tsfilter hp hp_* = log_total_saleqs_*, smooth(1600)


*forvalues i = 1(1)61 {
*gen fd_`i' = hp_`i' - l.hp_`i'
*}

*forvalues i = 1(1)27{
*arch fd_`i' l.fd_`i', arch(1/1) garch(1/1)
*predict volatility_`i', variance
*}
*forvalues i = 30(1)33{
*arch fd_`i' l.fd_`i', arch(1/1) garch(1/1)
*predict volatility_`i', variance
*}
*forvalues i = 35(1)61{
*arch fd_`i' l.fd_`i', arch(1/1) garch(1/1)
*predict volatility_`i', variance
*}


forvalues i = 1(1)60 {
gen fd_`i' = hp_`i' - l.hp_`i'
}

forvalues i = 1(1)4{
arch fd_`i' l.fd_`i', arch(1/1) garch(1/1)
predict volatility_`i', variance
}

forvalues i = 7(1)28{
arch fd_`i' l.fd_`i', arch(1/1) garch(1/1)
predict volatility_`i', variance
}


forvalues i = 30(1)33{
arch fd_`i' l.fd_`i', arch(1/1) garch(1/1)
predict volatility_`i', variance
}


forvalues i = 35(1)60{
arch fd_`i' l.fd_`i', arch(1/1) garch(1/1)
predict volatility_`i', variance
}

reshape long volatility_, i(time) j(sic_2d)

sort sic_2d time

gen sic = sic_2d

replace sic_2d = 1 if sic==1
replace sic_2d = 10 if sic==2
replace sic_2d = 12 if sic==3
replace sic_2d = 13 if sic==4
replace sic_2d = 14 if sic==5
replace sic_2d = 15 if sic==6
replace sic_2d = 16 if sic==7
replace sic_2d = 17 if sic==8
replace sic_2d = 20 if sic==9
replace sic_2d = 22 if sic==10
replace sic_2d = 23 if sic==11
replace sic_2d = 24 if sic==12
replace sic_2d = 25 if sic==13
replace sic_2d = 26 if sic==14
replace sic_2d = 27 if sic==15
replace sic_2d = 28 if sic==16
replace sic_2d = 29 if sic==17
replace sic_2d = 30 if sic==18
replace sic_2d = 31 if sic==19
replace sic_2d = 32 if sic==20
replace sic_2d = 33 if sic==21
replace sic_2d = 34 if sic==22
replace sic_2d = 35 if sic==23
replace sic_2d = 36 if sic==24
replace sic_2d = 37 if sic==25
replace sic_2d = 38 if sic==26
replace sic_2d = 39 if sic==27
replace sic_2d = 40 if sic==28
replace sic_2d = 42 if sic==29
replace sic_2d = 44 if sic==30
replace sic_2d = 45 if sic==31
replace sic_2d = 47 if sic==32
replace sic_2d = 48 if sic==33
replace sic_2d = 49 if sic==34
replace sic_2d = 50 if sic==35
replace sic_2d = 51 if sic==36
replace sic_2d = 52 if sic==37
replace sic_2d = 53 if sic==38
replace sic_2d = 54 if sic==39
replace sic_2d = 55 if sic==40
replace sic_2d = 56 if sic==41
replace sic_2d = 57 if sic==42
replace sic_2d = 58 if sic==43
replace sic_2d = 59 if sic==44
replace sic_2d = 60 if sic==45
replace sic_2d = 61 if sic==46
replace sic_2d = 62 if sic==47
replace sic_2d = 63 if sic==48
replace sic_2d = 64 if sic==49
replace sic_2d = 65 if sic==50
replace sic_2d = 67 if sic==51
replace sic_2d = 70 if sic==52
replace sic_2d = 72 if sic==53
replace sic_2d = 73 if sic==54
replace sic_2d = 75 if sic==55
replace sic_2d = 78 if sic==56
replace sic_2d = 79 if sic==57
replace sic_2d = 80 if sic==58
replace sic_2d = 82 if sic==59
replace sic_2d = 87 if sic==60

sort sic_2d time
rename volatility_ volatility

** WINSORIZE SALE LAST (W2)
*winsor2 volatility, by(time) cuts(2 98) trim
egen G_jt = mean(volatility), by(fyear sic_2d)

winsor2 G_jt, cuts(1 99) trim

keep fyear sic_2d G_jt_tr

collapse  G_jt_tr, by(fyear sic_2d)
 
sort sic_2d fyear 
save $mypath/data/compustat_garch.dta, replace

use $mypath/data/uim_panel.dta, clear
gen sic_2d = int(sic/100)

merge m:1  fyear sic_2d using $mypath/data/compustat_garch.dta


********************************************************************************
*********************************************************************time series
sort year
drop if year == .

by year: egen num=sum(ind)
by year: egen numest=mean(numana)

foreach z of varlist strt_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr vol_tr iv_tr G_jt_tr V_jt_tr mrpk_tr {
by year: egen `z'_mean=mean(`z')
by year: egen `z'_sdev=sd(`z')
by year: egen `z'_skew=skew(`z')
by year: egen `z'_kurt=kurt(`z')
}

#delimit;
collapse num numest 
         strt_tr_mean  strt_tr_sdev  strt_tr_skew  strt_tr_kurt 
         fdis1_tr_mean fdis1_tr_sdev fdis1_tr_skew fdis1_tr_kurt 
	  fdis2_tr_mean fdis2_tr_sdev fdis2_tr_skew fdis2_tr_kurt 
	  fe1_tr_mean   fe1_tr_sdev   fe1_tr_skew   fe1_tr_kurt 
	  fe2_tr_mean   fe2_tr_sdev   fe2_tr_skew   fe2_tr_kurt
	  fe3_tr_mean   fe3_tr_sdev   fe3_tr_skew   fe3_tr_kurt
	  vol_tr_mean   vol_tr_sdev   vol_tr_skew   vol_tr_kurt
	  iv_tr_mean   iv_tr_sdev   iv_tr_skew   iv_tr_kurt
	  G_jt_tr_mean   G_jt_tr_sdev   G_jt_tr_skew   G_jt_tr_kurt
	  V_jt_tr_mean   V_jt_tr_sdev   V_jt_tr_skew   V_jt_tr_kurt
	  mrpk_tr_mean   mrpk_tr_sdev   mrpk_tr_skew   mrpk_tr_kurt
	, by(year);
#delimit cr


*rename fyear year
tset year, yearly


********************************************************************************
************************************************************Detrend by hp filter
#delimit;
tsfilter hp strt_mean_hp fdis1_mean_hp fdis2_mean_hp fe1_mean_hp fe2_mean_hp fe3_mean_hp vol_mean_hp iv_mean_hp G_jt_mean_hp V_jt_mean_hp mrpk_mean_hp
            strt_sdev_hp fdis1_sdev_hp fdis2_sdev_hp fe1_sdev_hp fe2_sdev_hp fe3_sdev_hp vol_sdev_hp iv_sdev_hp G_jt_sdev_hp V_jt_sdev_hp mrpk_sdev_hp
			strt_skew_hp fdis1_skew_hp fdis2_skew_hp fe1_skew_hp fe2_skew_hp fe3_skew_hp vol_skew_hp iv_skew_hp G_jt_skew_hp V_jt_skew_hp mrpk_skew_hp
			strt_kurt_hp fdis1_kurt_hp fdis2_kurt_hp fe1_kurt_hp fe2_kurt_hp fe3_kurt_hp vol_kurt_hp iv_kurt_hp G_jt_kurt_hp V_jt_kurt_hp mrpk_kurt_hp
			
			= strt_tr_mean fdis1_tr_mean fdis2_tr_mean fe1_tr_mean fe2_tr_mean fe3_tr_mean vol_tr_mean iv_tr_mean G_jt_tr_mean V_jt_tr_mean mrpk_tr_mean 
			  strt_tr_sdev fdis1_tr_sdev fdis2_tr_sdev fe1_tr_sdev fe2_tr_sdev fe3_tr_sdev vol_tr_sdev iv_tr_sdev G_jt_tr_sdev V_jt_tr_sdev mrpk_tr_sdev 
			  strt_tr_skew fdis1_tr_skew fdis2_tr_skew fe1_tr_skew fe2_tr_skew fe3_tr_skew vol_tr_skew iv_tr_skew G_jt_tr_skew V_jt_tr_skew mrpk_tr_skew 
			  strt_tr_kurt fdis1_tr_kurt fdis2_tr_kurt fe1_tr_kurt fe2_tr_kurt fe3_tr_kurt vol_tr_kurt iv_tr_kurt G_jt_tr_kurt V_jt_tr_kurt mrpk_tr_kurt 
			   
		    , smooth(100);

#delimit cr
			
merge m:1  year using $mypath/data/FRED_Data.dta  
keep if _merge==3
drop _merge
drop if year < 1977



sort year

********************************************************************************
***********************   predictive power of future economic activities (macro)
foreach y in dgdp ln_rgdp_hp {
foreach z in fdis1 fdis2 fe1 fe2 fe3 vol iv G_jt V_jt {
qui reg `y' `z'_mean_hp L.`y' L2.`y'
qui estadd beta, replace
est store `y'_`z'_t

}
}

foreach y in dgdp ln_rgdp_hp {
foreach z in fdis1 fdis2 fe1 fe2 fe3 vol iv G_jt V_jt {
qui reg F.`y' `z'_mean_hp L.`y' L2.`y'
qui estadd beta, replace
est store `y'_`z'_t1

}
}

foreach y in dgdp ln_rgdp_hp {
foreach z in fdis1 fdis2 fe1 fe2 fe3 vol iv G_jt V_jt {
qui reg F2.`y' `z'_mean_hp L.`y' L2.`y'
qui estadd beta, replace
est store `y'_`z'_t2

}
}

label variable fdis1_mean_hp "\textbf{Fdis_CV}"
label variable fdis2_mean_hp "\textbf{Fdis_SD}"
label variable fe1_mean_hp "\textbf{FE_roa}"
label variable fe2_mean_hp "\textbf{FE_pct}"
label variable fe3_mean_hp "\textbf{FE_pct}"
label variable vol_mean_hp "\textbf{Vol}"
label variable iv_mean_hp "\textbf{IV}"
label variable G_jt_mean_hp "\textbf{Garch}"
label variable V_jt_mean_hp "\textbf{VIX}"


*======================================================================
* Generate one table for Table "Uncertainy and Economic Activity" lngdp
*======================================================================
esttab ln_rgdp_hp_fdis1_t  ln_rgdp_hp_fe3_t  ln_rgdp_hp_vol_t  ln_rgdp_hp_iv_t  ln_rgdp_hp_G_jt_t  ln_rgdp_hp_V_jt_t  /// 
       ln_rgdp_hp_fdis1_t1 ln_rgdp_hp_fe3_t1 ln_rgdp_hp_vol_t1 ln_rgdp_hp_iv_t1 ln_rgdp_hp_G_jt_t1 ln_rgdp_hp_V_jt_t1 ///
using $mypath/FigureTable/reg_forecast_lngdp.tex, replace  ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(fdis1_mean_hp fe3_mean_hp vol_mean_hp iv_mean_hp G_jt_mean_hp V_jt_mean_hp) ///
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
esttab dgdp_fdis1_t  dgdp_fe3_t  dgdp_vol_t  dgdp_iv_t  dgdp_G_jt_t  dgdp_V_jt_t ///
       dgdp_fdis1_t1 dgdp_fe3_t1 dgdp_vol_t1 dgdp_iv_t1 dgdp_G_jt_t1 dgdp_V_jt_t1 ///
using $mypath/FigureTable/reg_forecast_dgdp.tex, replace  ///
beta(%6.3f) tex nomti nodepvars ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(fdis1_mean_hp fe3_mean_hp vol_mean_hp iv_mean_hp G_jt_mean_hp V_jt_mean_hp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{5}{c}{\textbf{Current year} } & \multicolumn{5}{c}{\textbf{Next year} }\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline\end{tabular})
*log close garch
