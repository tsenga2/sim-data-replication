cls
clear all
set graph off

global mypath "/Users/tsenga/uim-empirics"

use $mypath/data/uim_panel.dta, clear


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
using $mypath/FigureTable/desc_all.tex, replace ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2)) p5(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p95(fmt(2)) ") ///
lines parentheses ///
label nonumber noobs nogaps


*************************************************** Low and High uncertainty subsamples (T2)
estpost sum sale_tr at_tr emp_tr age life numana lev_tr  if (lowdummy==1 & fyear==2012), d
eststo low 
estpost sum sale_tr at_tr emp_tr age life numana lev_tr  if (lowdummy==0 & fyear==2012), d
eststo high 
esttab  low high ///
using $mypath/FigureTable/desc_both_sub.tex, replace ///
mtitles(" \textbf{Low}" " \textbf{High}") ///
legend noabbrev style(tex) ///
cells("mean(fmt(2)) sd(fmt(2))  ") ///
lines parentheses ///
label nonumber noobs nogaps 


*************************************************************************************
************************************** plot distributions of umcertainty proxies (F1)
// Winsorize variables
winsor2 lndis1 lndis2 lnfe1 lnfe3, cuts(1 99) trim

// Set delimiter to semicolon for multi-line commands
#delimit ;

// Create kernel density plot for Great Recession
twoway (kdensity lndis1_tr if year==2007, lcolor(red) lwidth(medthick) lpattern(dash)) 
       (kdensity lndis1_tr if year==2008, lcolor(black) lwidth(medthick) lpattern(solid))
       (kdensity lndis1_tr if year==2009, lcolor(blue) lwidth(medthick) lpattern(longdash_dot)), 
        legend(on order(1 "2007" 2 "2008" 3 "2009") cols(1) position(1) ring(0)) 
        title("Great Recession")
        subtitle("2007-2009")
        xtitle("Forecast Dispersion") 
        ytitle("Density")
        graphregion(color(white)) 
        name(GR, replace);

// Create kernel density plot for Covid-19 Pandemic
twoway (kdensity lndis1_tr if year==2019, lcolor(green) lwidth(medthick) lpattern(dash)) 
       (kdensity lndis1_tr if year==2020, lcolor(orange) lwidth(medthick) lpattern(solid))
       (kdensity lndis1_tr if year==2021, lcolor(purple) lwidth(medthick) lpattern(longdash_dot)), 
        legend(on order(1 "2019" 2 "2020" 3 "2021") cols(1) position(1) ring(0)) 
        title("Covid-19 Pandemic")
        subtitle("2019-2021")
        xtitle("Forecast Dispersion") 
        ytitle("Density")
        graphregion(color(white)) 
        name(COVID, replace);

// Reset delimiter
#delimit cr

// Turn on graph display
set graph on

// Combine the two graphs
graph combine GR COVID, cols(2) title(" ") subtitle(" ") graphregion(color(white)) name(combined, replace)

// Export the combined graph as a PNG file
graph export $mypath/FigureTable/GR_Covid_Fdis.png, as(png) replace width(1600) height(900)



// Set delimiter to semicolon for multi-line commands
#delimit ;

// Create kernel density plot for Great Recession (lnfe1)
twoway (kdensity lnfe1_tr if year==2007, lcolor(red) lwidth(medthick) lpattern(dash)) 
       (kdensity lnfe1_tr if year==2008, lcolor(black) lwidth(medthick) lpattern(solid))
       (kdensity lnfe1_tr if year==2009, lcolor(blue) lwidth(medthick) lpattern(longdash_dot)), 
        legend(on order(1 "2007" 2 "2008" 3 "2009") cols(1) position(11) ring(0)) 
        title("Great Recession")
        subtitle("2007-2009")
        xtitle("Forecast Error") 
        ytitle("Density")
        graphregion(color(white)) 
        name(GR_fe1, replace);

// Create kernel density plot for Covid-19 Pandemic (lnfe1)
twoway (kdensity lnfe1_tr if year==2019, lcolor(green) lwidth(medthick) lpattern(dash)) 
       (kdensity lnfe1_tr if year==2020, lcolor(orange) lwidth(medthick) lpattern(solid))
       (kdensity lnfe1_tr if year==2021, lcolor(purple) lwidth(medthick) lpattern(longdash_dot)), 
        legend(on order(1 "2019" 2 "2020" 3 "2021") cols(1) position(11) ring(0)) 
        title("Covid-19 Pandemic")
        subtitle("2019-2021")
        xtitle("Forecast Error") 
        ytitle("Density")
        graphregion(color(white)) 
        name(COVID_fe1, replace);

// Reset delimiter
#delimit cr

// Turn on graph display
set graph on

// Combine the two graphs
graph combine GR_fe1 COVID_fe1, cols(2) title(" ") subtitle(" ") graphregion(color(white)) name(combined_fe1, replace)

// Export the combined graph as a PNG file
graph export $mypath/FigureTable/GR_Covid_FE.png, as(png) replace width(1600) height(900)
