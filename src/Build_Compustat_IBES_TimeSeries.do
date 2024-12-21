** This do file takes the Compustat-IBES panel and creates a time series of the variables


cls
clear all
set graph off

global mypath "/Users/tsenga/uim-replication-Sep2024/uim-empirics"

use $mypath/data/uim_panel.dta, clear


********************************************************************************
*********************************************************************time series
sort year
drop if year == .

by year: egen num=sum(ind)
by year: egen numest=mean(numana)

foreach z of varlist strt_tr fdis1_tr fdis2_tr fe1_tr fe2_tr fe3_tr {
by year: egen `z'_mean=mean(`z')
by year: egen `z'_sdev=sd(`z')
by year: egen `z'_skew=skew(`z')
by year: egen `z'_kurt=kurt(`z')
}

#delimit;
collapse num numest 
         strt_tr_mean  strt_tr_sdev  strt_tr_skew  strt_tr_kurt 
         fdis1_tr_mean fdis1_tr_sdev fdis1_tr_skew fdis1_tr_kurt 
		 fdis2_tr_mean fdis2_tr_sdev fdis2_tr_skew fdis2_tr_kurt fe1_tr_mean   fe1_tr_sdev   fe1_tr_skew   fe1_tr_kurt 
		 fe2_tr_mean   fe2_tr_sdev   fe2_tr_skew   fe2_tr_kurt
         fe3_tr_mean   fe3_tr_sdev   fe3_tr_skew   fe3_tr_kurt
		 , by(year);
#delimit cr


*rename fyear year
tset year, yearly


********************************************************************************
************************************************************Detrend by hp filter
#delimit;
tsfilter hp strt_mean_hp fdis1_mean_hp fdis2_mean_hp fe1_mean_hp fe2_mean_hp fe3_mean_hp
            strt_sdev_hp fdis1_sdev_hp fdis2_sdev_hp fe1_sdev_hp fe2_sdev_hp fe3_sdev_hp
			strt_skew_hp fdis1_skew_hp fdis2_skew_hp fe1_skew_hp fe2_skew_hp fe3_skew_hp
			strt_kurt_hp fdis1_kurt_hp fdis2_kurt_hp fe1_kurt_hp fe2_kurt_hp fe3_kurt_hp
			
			= strt_tr_mean fdis1_tr_mean fdis2_tr_mean fe1_tr_mean fe2_tr_mean fe3_tr_mean 
			  strt_tr_sdev fdis1_tr_sdev fdis2_tr_sdev fe1_tr_sdev fe2_tr_sdev fe3_tr_sdev 
			  strt_tr_skew fdis1_tr_skew fdis2_tr_skew fe1_tr_skew fe2_tr_skew fe3_tr_skew 
			  strt_tr_kurt fdis1_tr_kurt fdis2_tr_kurt fe1_tr_kurt fe2_tr_kurt fe3_tr_kurt 
			   
		    , smooth(6.25);

#delimit cr
			
merge m:1  year using $mypath/data/FRED_Data.dta  
keep if _merge==3
drop _merge
drop if year < 1977



save $mypath/data/uim_tseries.dta, replace
