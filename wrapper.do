
log using log/uim_replication.log, name(uim_replication) replace

do src/Build_CRSP_Data.do
do src/Build_IV_Data.do
do src/Build_FRED_Data.do
do src/Build_IBES_Panel.do
do src/Build_Compustat_IBES_Panel.do
do src/T1-2andF1.do
do src/MPK.do
do src/Cross_regressions.do
do src/Build_Compustat_IBES_TimeSeries.do
do src/T3andF2.do
do src/TSeries.do
do src/SharePrice.do
do src/Uncertainty.do
do src/SalesGrowth.do
do src/Add_Garch_PredictFuture.do

log close uim_replication
