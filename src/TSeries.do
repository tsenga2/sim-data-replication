cls
clear all
set graph off

global mypath "/Users/tsenga/uim-empirics"

use $mypath/data/uim_tseries.dta, clear


*replace recession=0.25 if year==2020
gen low=0



********************************************************************************
********************* "V and SD (mrpk) is higher during recessions" regression 1
foreach y in V_jt mrpk {
foreach z in mean_hp sdev_hp skew_hp {
qui reg `y'_`z' dgdp
qui estadd ysumm
est store `y'_`z'_dgdp

}
}

********************************************************************************
********************* "V and SD (mrpk) is higher during recessions" regression 2
foreach y in V_jt mrpk {
foreach z in mean_hp sdev_hp skew_hp {
qui reg `y'_`z' ln_rgdp_hp
qui estadd ysumm
est store `y'_`z'_ln_rgdp_hp

}
}

********************************************************************************
********************* "V and SD (mrpk) is higher during recessions" regression 3
foreach y in V_jt mrpk {
foreach z in mean_hp sdev_hp skew_hp {
qui reg `y'_`z' usrec 
qui estadd ysumm
est store `y'_`z'_rec

}
}


label variable V_jt_mean_hp "\textbf{Forecast dispersion}"
label variable mrpk_mean_hp "\textbf{Forecast error}"
label variable dgdp "\textbf{\textit{GDP} growth}"
label variable ln_rgdp_hp "\textbf{log(GDP)}"
label variable usrec "\textbf{Recession}"


*======================================================================
esttab V_jt_mean_hp_dgdp  V_jt_mean_hp_ln_rgdp_hp /// 
       V_jt_sdev_hp_dgdp  V_jt_sdev_hp_ln_rgdp_hp ///
	   V_jt_skew_hp_dgdp  V_jt_skew_hp_ln_rgdp_hp ///
        ///
using $mypath/FigureTable/reg_ts_v.tex, replace  ///
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
esttab mrpk_mean_hp_rec  mrpk_mean_hp_ln_rgdp_hp mrpk_mean_hp_dgdp /// 
       mrpk_sdev_hp_rec  mrpk_sdev_hp_ln_rgdp_hp mrpk_sdev_hp_dgdp ///
	   mrpk_skew_hp_rec  mrpk_skew_hp_ln_rgdp_hp mrpk_skew_hp_dgdp ///
using $mypath/FigureTable/reg_ts_mrpk.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) nogaps ///
depvars beta(%6.3f) legend noabbrev style(tex) ///
label stats(N r2 , fmt(%9.0g %5.0g) ///
labels(Observations R^2 )) t noconstant ///
keep(usrec ln_rgdp_hp dgdp) ///
noomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_  $  \\$  %  \% ) ///
prehead(\begin{tabular}{l*{@M}{c}}\tabularnewline \hline & \multicolumn{3}{c}{\textbf{Mean} }& \multicolumn{3}{c}{\textbf{S.D.}}& \multicolumn{3}{c}{\textbf{Skewness}}\\\) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline  \end{tabular})


esttab mrpk_mean_hp_rec mrpk_mean_hp_ln_rgdp_hp mrpk_mean_hp_dgdp /// 
      mrpk_sdev_hp_rec mrpk_sdev_hp_ln_rgdp_hp mrpk_sdev_hp_dgdp /// 
      mrpk_skew_hp_rec mrpk_skew_hp_ln_rgdp_hp mrpk_skew_hp_dgdp /// 
using $mypath/FigureTable/reg_ts_mrpk.tex, replace ///
star(* 0.10 ** 0.05 *** 0.01) noeps ///
depvars beta(.5,3f) legend noabbrev style(tex) ///
label stats(N r2, fmt(%0.0g %5.0g)) ///
labels(Observations R^2 ) t noconstant ///
keep(usrec ln_rgdp_hp dgdp) ///
nomitted ///
addnotes("\textbf{Notes: TBA}") ///
se numbers lines parentheses ///
substitute(_ \_ $ \\$ % \%) ///
prehead(\begin{tabular}{l@{\hspace{1cm}}\tabular{newline \hline & \multicolumn{3}{c}{\textbf{Mean} }& \multicolumn{3}{c}{\textbf{S.D.}}& \multicolumn{3}{c}{\textbf{Skewness}}\\\\}) ///
posthead("\hline") prefoot("\hline") ///
postfoot(\hline \hline \end{tabular})